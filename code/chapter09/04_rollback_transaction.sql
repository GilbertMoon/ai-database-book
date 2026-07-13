-- Chapter 09. ROLLBACK 예제
-- 학생 102가 강의 302를 신청하는 임시 변경을 만든 뒤 전체 취소합니다.
-- 실행 전 01, 02, 03 파일을 실행합니다.
-- 같은 SQL Editor와 같은 연결 세션에서 순서대로 실행합니다.

SELECT current_database();

-- 변경 전 상태: course 302 remaining 1, 9002/9902 없음
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 302;

SELECT *
FROM transaction_lab.enrollments
WHERE id = 9002;

SELECT *
FROM transaction_lab.payments
WHERE id = 9902;

BEGIN;

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
    9902,
    id,
    paid_amount,
    CURRENT_TIMESTAMP
FROM new_enrollment
RETURNING id, enrollment_id, amount;

-- 같은 세션에서 임시 변경 확인
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

-- 외부 결제 승인 실패를 가정하고 전체 취소
ROLLBACK;

-- ROLLBACK 후 원상 복구 확인
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 302;

SELECT *
FROM transaction_lab.enrollments
WHERE id = 9002;

SELECT *
FROM transaction_lab.payments
WHERE id = 9902;

-- 기대 결과:
-- course 302 remaining 1
-- enrollment 9002 0행
-- payment 9902 0행
