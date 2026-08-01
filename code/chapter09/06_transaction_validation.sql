-- Chapter 09. 최종 트랜잭션 정합성 검증
-- 실행 전 01→02→03→04→05 파일을 순서대로 실행합니다.
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 1. Chapter 07 프로젝트 데이터 보호 확인
SELECT
    COUNT(*) AS project_enrollment_count,
    COUNT(*) = 5 AS project_enrollment_count_ok
FROM course_project.enrollments;

-- 2. lab 최종 행 수
SELECT COUNT(*) AS lab_enrollment_count
FROM transaction_lab.enrollments;

SELECT COUNT(*) AS payment_count
FROM transaction_lab.payments;

-- 3. 최종 좌석 상태
SELECT
    ci.course_id,
    c.title,
    ci.capacity,
    ci.remaining_seats,
    CASE ci.course_id
        WHEN 301 THEN ci.remaining_seats = 1
        WHEN 302 THEN ci.remaining_seats = 0
        WHEN 303 THEN ci.remaining_seats = 1
        ELSE FALSE
    END AS expected_remaining_ok
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
ORDER BY ci.course_id;

-- 4. 신청·결제 연결 확인
SELECT
    e.id AS enrollment_id,
    e.student_id,
    s.name AS student_name,
    e.course_id,
    c.title AS course_title,
    e.status,
    e.recorded_amount,
    p.id AS payment_id,
    p.amount,
    e.recorded_amount = p.amount AS amount_matches,
    ci.remaining_seats
FROM transaction_lab.enrollments AS e
JOIN course_project.students AS s
    ON s.id = e.student_id
JOIN course_project.courses AS c
    ON c.id = e.course_id
JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
JOIN transaction_lab.course_inventory AS ci
    ON ci.course_id = e.course_id
ORDER BY e.id;

-- 5. 위반 데이터 조회: 모두 0행
SELECT *
FROM transaction_lab.course_inventory
WHERE remaining_seats < 0
   OR remaining_seats > capacity;

SELECT
    e.id AS enrollment_id,
    e.recorded_amount,
    p.amount AS payment_amount
FROM transaction_lab.enrollments AS e
LEFT JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
WHERE e.status = '수강중'
  AND (
      p.id IS NULL
      OR e.recorded_amount <> p.amount
  );

SELECT p.*
FROM transaction_lab.payments AS p
LEFT JOIN transaction_lab.enrollments AS e
    ON e.id = p.enrollment_id
WHERE e.id IS NULL;

SELECT student_id, course_id, COUNT(*) AS active_count
FROM transaction_lab.enrollments
WHERE status = '수강중'
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;

-- 6. 좌석 사용량과 활성 신청 비교
SELECT
    ci.course_id,
    c.title,
    ci.capacity,
    ci.remaining_seats,
    COUNT(e.id) FILTER (WHERE e.status = '수강중') AS active_enrollment_count,
    ci.capacity - ci.remaining_seats AS used_seats,
    COUNT(e.id) FILTER (WHERE e.status = '수강중')
        = ci.capacity - ci.remaining_seats AS is_consistent
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
LEFT JOIN transaction_lab.enrollments AS e
    ON e.course_id = ci.course_id
GROUP BY
    ci.course_id,
    c.title,
    ci.capacity,
    ci.remaining_seats
ORDER BY ci.course_id;

-- 7. 좌석 부족 테스트 잔여 행: 모두 0행
SELECT *
FROM transaction_lab.enrollments
WHERE id = 9003;

SELECT *
FROM transaction_lab.payments
WHERE id = 9903;

-- 8. 전체 상태 자동 판정
DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '최종 검증 실패: 현재 데이터베이스가 ai_database_book이 아닙니다.';
    END IF;

    IF (SELECT COUNT(*) FROM course_project.enrollments) <> 5 THEN
        RAISE EXCEPTION
            '최종 검증 실패: course_project.enrollments는 5행이어야 합니다.';
    END IF;

    IF (SELECT COUNT(*) FROM transaction_lab.enrollments) <> 2
       OR (SELECT COUNT(*) FROM transaction_lab.payments) <> 2 THEN
        RAISE EXCEPTION
            '최종 검증 실패: lab enrollment와 payment는 각각 2행이어야 합니다.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM transaction_lab.course_inventory
        WHERE course_id = 301 AND capacity = 2 AND remaining_seats = 1
    ) OR NOT EXISTS (
        SELECT 1
        FROM transaction_lab.course_inventory
        WHERE course_id = 302 AND capacity = 1 AND remaining_seats = 0
    ) OR NOT EXISTS (
        SELECT 1
        FROM transaction_lab.course_inventory
        WHERE course_id = 303 AND capacity = 1 AND remaining_seats = 1
    ) THEN
        RAISE EXCEPTION
            '최종 검증 실패: 강의별 좌석 상태가 기대값과 다릅니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM transaction_lab.course_inventory
        WHERE remaining_seats < 0
           OR remaining_seats > capacity
    ) THEN
        RAISE EXCEPTION
            '최종 검증 실패: 좌석 범위 위반이 있습니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM transaction_lab.enrollments AS e
        LEFT JOIN transaction_lab.payments AS p
            ON p.enrollment_id = e.id
        WHERE e.status = '수강중'
          AND (p.id IS NULL OR e.recorded_amount <> p.amount)
    ) THEN
        RAISE EXCEPTION
            '최종 검증 실패: 수강중 신청의 결제 누락 또는 금액 불일치가 있습니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM transaction_lab.course_inventory AS ci
        LEFT JOIN transaction_lab.enrollments AS e
            ON e.course_id = ci.course_id
        GROUP BY ci.course_id, ci.capacity, ci.remaining_seats
        HAVING COUNT(e.id) FILTER (WHERE e.status = '수강중')
               <> ci.capacity - ci.remaining_seats
    ) THEN
        RAISE EXCEPTION
            '최종 검증 실패: 활성 신청 수와 사용 좌석 수가 다릅니다.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM transaction_lab.enrollments WHERE id = 9003
    ) OR EXISTS (
        SELECT 1 FROM transaction_lab.payments WHERE id = 9903
    ) THEN
        RAISE EXCEPTION
            '최종 검증 실패: 좌석 부족 테스트 행이 남아 있습니다.';
    END IF;
END
$$;

SELECT 'Chapter 09 main transaction validation passed' AS validation_result;
