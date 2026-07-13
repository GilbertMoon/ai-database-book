-- Chapter 09. 두 번째 COMMIT과 좌석 부족 처리
-- 실행 전 01→02→03→04 파일을 실행합니다.
-- 04의 ROLLBACK 덕분에 ID 9002와 9902를 다시 사용할 수 있습니다.

SELECT current_database();

-- ============================================================
-- 1. 학생 103, 강의 302 정상 신청
-- ============================================================
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

-- COMMIT 전 확인
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

COMMIT;

-- 기대 결과: course 302 remaining 0
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 302;

-- ============================================================
-- 2. 좌석이 0인 강의 302에 추가 신청 시도
-- seat CTE가 0행이면 신청과 결제도 0행입니다.
-- ============================================================
BEGIN;

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

-- 기대 결과: 위 문장은 0행 반환
SELECT *
FROM transaction_lab.enrollments
WHERE id = 9003;

SELECT *
FROM transaction_lab.payments
WHERE id = 9903;

-- 업무상 좌석 확보 실패로 처리
ROLLBACK;

-- 최종 확인: 9003/9903 없음, course 302 remaining 0
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 302;

SELECT *
FROM transaction_lab.enrollments
WHERE id = 9003;

SELECT *
FROM transaction_lab.payments
WHERE id = 9903;
