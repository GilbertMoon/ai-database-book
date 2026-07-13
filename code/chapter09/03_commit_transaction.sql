-- Chapter 09. 성공 COMMIT 예제
-- 학생 101이 강의 301을 신청합니다.
-- 실행 전 01, 02 파일을 실행합니다.
-- 같은 DBeaver SQL Editor와 같은 연결 세션에서 순서대로 실행합니다.

SELECT current_database();

-- 변경 전 확인
SELECT
    ci.course_id,
    c.title,
    c.price,
    ci.capacity,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
WHERE ci.course_id = 301;

SELECT *
FROM transaction_lab.enrollments
WHERE id = 9001;

SELECT *
FROM transaction_lab.payments
WHERE id = 9901;

BEGIN;

-- 대상 좌석 행 잠금과 최신 상태 확인
SELECT
    ci.course_id,
    c.title,
    c.price,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
WHERE ci.course_id = 301
FOR UPDATE OF ci;

-- 좌석 확보가 성공한 경우에만 신청과 결제를 생성합니다.
WITH seat AS (
    UPDATE transaction_lab.course_inventory AS ci
    SET remaining_seats = ci.remaining_seats - 1
    FROM course_project.courses AS c
    WHERE ci.course_id = c.id
      AND ci.course_id = 301
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
        9001,
        101,
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
    9901,
    id,
    paid_amount,
    CURRENT_TIMESTAMP
FROM new_enrollment
RETURNING id, enrollment_id, amount;

-- COMMIT 전 검증: 반드시 1행이어야 합니다.
SELECT
    e.id AS enrollment_id,
    e.student_id,
    e.course_id,
    e.status,
    e.paid_amount,
    p.id AS payment_id,
    p.amount,
    ci.remaining_seats
FROM transaction_lab.enrollments AS e
JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
JOIN transaction_lab.course_inventory AS ci
    ON ci.course_id = e.course_id
WHERE e.id = 9001;

-- 기대 결과가 맞을 때만 확정합니다.
COMMIT;

-- COMMIT 후 확인
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
WHERE e.id = 9001;

-- 기대 결과:
-- enrollment 9001 / payment 9901 / amount 100000 / course 301 remaining 1
