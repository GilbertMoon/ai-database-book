-- Chapter 09. 두 번째 COMMIT과 좌석 부족 처리
-- 실행 전 01→02→03→04 파일을 실행합니다.
-- 04에서 명시적 ID 9002·9902 행을 ROLLBACK했으므로 같은 숫자를 다시 사용합니다.
-- IDENTITY 자동값의 번호는 ROLLBACK으로 회수되지 않는다는 점과 구분합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 학생 103, 강의 302 정상 신청
-- ============================================================
BEGIN;

DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF (SELECT remaining_seats
        FROM transaction_lab.course_inventory
        WHERE course_id = 302) IS DISTINCT FROM 1 THEN
        RAISE EXCEPTION
            '실행 중단: 강의 302의 시작 잔여 좌석은 1이어야 합니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM transaction_lab.enrollments
        WHERE id = 9002
           OR (student_id = 103 AND course_id = 302 AND status = '수강중')
    ) THEN
        RAISE EXCEPTION
            '실행 중단: 신청 9002 또는 동일 활성 신청이 이미 존재합니다.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM transaction_lab.payments
        WHERE id = 9902
    ) THEN
        RAISE EXCEPTION
            '실행 중단: 결제 9902가 이미 존재합니다.';
    END IF;
END
$$;

SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 302
FOR UPDATE;

WITH seat AS (
    UPDATE transaction_lab.course_inventory AS ci
    SET remaining_seats = ci.remaining_seats - 1
    FROM course_project.courses AS c
    WHERE ci.course_id = c.id
      AND ci.course_id = 302
      AND ci.remaining_seats > 0
    RETURNING ci.course_id, c.price
),
new_enrollment AS (
    INSERT INTO transaction_lab.enrollments (
        id,
        student_id,
        course_id,
        enrolled_at,
        status,
        paid_amount
    )
    SELECT
        9002,
        103,
        course_id,
        CURRENT_TIMESTAMP,
        '수강중',
        price
    FROM seat
    RETURNING id, course_id, paid_amount
)
INSERT INTO transaction_lab.payments (
    id,
    enrollment_id,
    amount,
    paid_at
)
SELECT
    9902,
    id,
    paid_amount,
    CURRENT_TIMESTAMP
FROM new_enrollment
RETURNING id, enrollment_id, amount;

SELECT
    e.id AS enrollment_id,
    e.student_id,
    e.course_id,
    p.id AS payment_id,
    p.amount,
    ci.remaining_seats
FROM transaction_lab.enrollments AS e
JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
JOIN transaction_lab.course_inventory AS ci
    ON ci.course_id = e.course_id
WHERE e.id = 9002;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM transaction_lab.enrollments AS e
        JOIN transaction_lab.payments AS p
            ON p.enrollment_id = e.id
        JOIN transaction_lab.course_inventory AS ci
            ON ci.course_id = e.course_id
        WHERE e.id = 9002
          AND e.student_id = 103
          AND e.course_id = 302
          AND e.status = '수강중'
          AND e.paid_amount = 120000
          AND p.id = 9902
          AND p.amount = 120000
          AND ci.remaining_seats = 0
    ) THEN
        RAISE EXCEPTION
            'COMMIT 중단: 두 번째 신청·결제·좌석 결과가 기대 상태와 다릅니다.';
    END IF;
END
$$;

COMMIT;

-- ============================================================
-- 2. 좌석이 0인 강의 302에 추가 신청 시도
-- seat CTE가 0행이면 신청과 결제도 0행입니다.
-- ============================================================
BEGIN;

DO $$
BEGIN
    IF (SELECT remaining_seats
        FROM transaction_lab.course_inventory
        WHERE course_id = 302) IS DISTINCT FROM 0 THEN
        RAISE EXCEPTION
            '실행 중단: 좌석 부족 실습 전 강의 302 잔여 좌석은 0이어야 합니다.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM transaction_lab.enrollments WHERE id = 9003
    ) OR EXISTS (
        SELECT 1 FROM transaction_lab.payments WHERE id = 9903
    ) THEN
        RAISE EXCEPTION
            '실행 중단: 9003 또는 9903 행이 이미 존재합니다.';
    END IF;
END
$$;

WITH seat AS (
    UPDATE transaction_lab.course_inventory AS ci
    SET remaining_seats = ci.remaining_seats - 1
    FROM course_project.courses AS c
    WHERE ci.course_id = c.id
      AND ci.course_id = 302
      AND ci.remaining_seats > 0
    RETURNING ci.course_id, c.price
),
new_enrollment AS (
    INSERT INTO transaction_lab.enrollments (
        id,
        student_id,
        course_id,
        enrolled_at,
        status,
        paid_amount
    )
    SELECT
        9003,
        102,
        course_id,
        CURRENT_TIMESTAMP,
        '수강중',
        price
    FROM seat
    RETURNING id, course_id, paid_amount
)
INSERT INTO transaction_lab.payments (
    id,
    enrollment_id,
    amount,
    paid_at
)
SELECT
    9903,
    id,
    paid_amount,
    CURRENT_TIMESTAMP
FROM new_enrollment
RETURNING id, enrollment_id, amount;

-- 기대 결과: 위 문장은 0행을 반환합니다.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM transaction_lab.enrollments WHERE id = 9003
    ) OR EXISTS (
        SELECT 1 FROM transaction_lab.payments WHERE id = 9903
    ) OR (SELECT remaining_seats
          FROM transaction_lab.course_inventory
          WHERE course_id = 302) IS DISTINCT FROM 0 THEN
        RAISE EXCEPTION
            '좌석 부족 처리 실패: 신청·결제가 생성되지 않고 좌석이 0이어야 합니다.';
    END IF;
END
$$;

-- SQL 오류는 아니지만 업무상 좌석 확보 실패이므로 트랜잭션을 종료합니다.
ROLLBACK;

-- ============================================================
-- 3. 명시적 샘플 ID 이후 IDENTITY 다음 값 조정
-- 명시적 ID 입력은 연결된 IDENTITY 시퀀스를 자동으로 이동시키지 않습니다.
-- ============================================================
ALTER TABLE transaction_lab.enrollments
    ALTER COLUMN id RESTART WITH 9003;

ALTER TABLE transaction_lab.payments
    ALTER COLUMN id RESTART WITH 9903;

-- 최종 확인
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 302;

SELECT *
FROM transaction_lab.enrollments
WHERE id IN (9002, 9003)
ORDER BY id;

SELECT *
FROM transaction_lab.payments
WHERE id IN (9902, 9903)
ORDER BY id;

-- 기대 결과:
-- enrollment 9002 / payment 9902 존재
-- enrollment 9003 / payment 9903 없음
-- course 302 remaining 0
