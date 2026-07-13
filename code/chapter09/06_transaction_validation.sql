-- Chapter 09. 최종 트랜잭션 정합성 검증
-- 실행 전 01→02→03→04→05 파일을 순서대로 실행합니다.
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();

-- 1. Chapter 07 프로젝트 데이터가 유지되는지 확인
SELECT COUNT(*) AS project_enrollment_count
FROM course_project.enrollments;

-- 기대 결과: 5

-- 2. lab 최종 행 수
SELECT COUNT(*) AS lab_enrollment_count
FROM transaction_lab.enrollments;

SELECT COUNT(*) AS payment_count
FROM transaction_lab.payments;

-- 기대 결과: 2 / 2

-- 3. 최종 좌석 상태
SELECT
    ci.course_id,
    c.title,
    ci.capacity,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
ORDER BY ci.course_id;

-- 기대 결과:
-- 301 = 2 / 1
-- 302 = 1 / 0
-- 303 = 1 / 1

-- 4. 신청·결제 연결 전체 확인
SELECT
    e.id AS enrollment_id,
    e.student_id,
    s.name AS student_name,
    e.course_id,
    c.title AS course_title,
    e.status,
    e.paid_amount,
    p.id AS payment_id,
    p.amount,
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

-- 5. 좌석 범위 위반: 기대 0행
SELECT *
FROM transaction_lab.course_inventory
WHERE remaining_seats < 0
   OR remaining_seats > capacity;

-- 6. 수강중 신청의 결제 누락·금액 불일치: 기대 0행
SELECT
    e.id AS enrollment_id,
    e.paid_amount,
    p.amount AS payment_amount
FROM transaction_lab.enrollments AS e
LEFT JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
WHERE e.status = '수강중'
  AND (
      p.id IS NULL
      OR e.paid_amount <> p.amount
  );

-- 7. 고아 payment: 기대 0행
SELECT p.*
FROM transaction_lab.payments AS p
LEFT JOIN transaction_lab.enrollments AS e
    ON e.id = p.enrollment_id
WHERE e.id IS NULL;

-- 8. 좌석 사용량과 active enrollment 비교
SELECT
    ci.course_id,
    c.title,
    ci.capacity,
    ci.remaining_seats,
    COUNT(e.id) FILTER (WHERE e.status = '수강중')
        AS active_enrollment_count,
    ci.capacity - ci.remaining_seats AS used_seats,
    COUNT(e.id) FILTER (WHERE e.status = '수강중')
        = ci.capacity - ci.remaining_seats
        AS is_consistent
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

-- 모든 is_consistent가 true여야 합니다.

-- 9. ROLLBACK·좌석 부족 테스트의 잔여 행 확인: 모두 0행
SELECT *
FROM transaction_lab.enrollments
WHERE id = 9003;

SELECT *
FROM transaction_lab.payments
WHERE id = 9903;
