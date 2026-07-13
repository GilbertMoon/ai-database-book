-- Chapter 09. 트랜잭션으로 데이터 정합성 지키기
--
-- 이 파일은 기존 링크 호환용 안내·상태 확인 진입점입니다.
-- 기존 course_project 테이블을 삭제하거나 변경하지 않습니다.
-- 실제 실습은 다음 파일을 순서대로 실행합니다.
--
-- 1. 01_transaction_lab_schema.sql
-- 2. 02_transaction_lab_seed.sql
-- 3. 03_commit_transaction.sql
-- 4. 04_rollback_transaction.sql
-- 5. 05_commit_and_sold_out.sql
-- 6. 06_transaction_validation.sql
-- 7. 07_concurrency_two_sessions.sql은 선택 실습
--
-- 처음부터 다시 시작할 때만 reset_transaction_lab.sql을 사용합니다.

SELECT current_database();
SELECT current_schema();

-- Chapter 07 프로젝트 보호 상태 확인
SELECT COUNT(*) AS project_student_count
FROM course_project.students;

SELECT COUNT(*) AS project_course_count
FROM course_project.courses;

SELECT COUNT(*) AS project_enrollment_count
FROM course_project.enrollments;

-- transaction_lab 테이블 존재 확인
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'transaction_lab'
ORDER BY table_name;

-- lab이 준비된 경우 현재 상태 확인
SELECT
    ci.course_id,
    c.title,
    ci.capacity,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
ORDER BY ci.course_id;

SELECT COUNT(*) AS lab_enrollment_count
FROM transaction_lab.enrollments;

SELECT COUNT(*) AS payment_count
FROM transaction_lab.payments;

-- 최종 기대 상태:
-- course_project.enrollments = 5
-- transaction_lab.enrollments = 2
-- transaction_lab.payments = 2
-- course 301 remaining 1
-- course 302 remaining 0
-- course 303 remaining 1
