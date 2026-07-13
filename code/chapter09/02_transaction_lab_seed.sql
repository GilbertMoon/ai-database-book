-- Chapter 09. transaction_lab 초기 좌석 데이터
-- 실행 전 01_transaction_lab_schema.sql을 먼저 실행합니다.
-- 이 파일은 Chapter 07의 course_project 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();

-- 필요한 학생·강의 마스터 존재 확인
SELECT id, name
FROM course_project.students
WHERE id IN (101, 102, 103)
ORDER BY id;

SELECT id, title, price
FROM course_project.courses
WHERE id IN (301, 302, 303)
ORDER BY id;

INSERT INTO transaction_lab.course_inventory (
    course_id,
    capacity,
    remaining_seats
)
VALUES
    (301, 2, 2),
    (302, 1, 1),
    (303, 1, 1);

-- 초기 상태 확인
SELECT
    ci.course_id,
    c.title,
    c.price,
    ci.capacity,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
ORDER BY ci.course_id;

SELECT COUNT(*) AS inventory_count
FROM transaction_lab.course_inventory;

SELECT COUNT(*) AS lab_enrollment_count
FROM transaction_lab.enrollments;

SELECT COUNT(*) AS payment_count
FROM transaction_lab.payments;

-- 기대 결과: inventory 3 / lab enrollment 0 / payment 0
