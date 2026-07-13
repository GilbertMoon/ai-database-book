-- Chapter 10. 실행 계획으로 인덱스 효과 검증하기
--
-- 이 파일은 기존 링크 호환용 안내·상태 확인 진입점입니다.
-- 기존 프로젝트 테이블을 삭제하거나 다시 만들지 않습니다.
-- 실제 실습은 다음 파일을 순서대로 실행합니다.
--
-- 1. 01_performance_lab_schema.sql
-- 2. 02_performance_lab_seed.sql
-- 3. 03_baseline_explain.sql
-- 4. 04_create_candidate_indexes.sql
-- 5. 05_after_index_explain.sql
-- 6. 06_index_review.sql
--
-- 처음부터 다시 시작할 때만 reset_performance_lab.sql을 사용합니다.

SELECT current_database();
SELECT current_schema();

-- 앞 장 데이터 보호 확인
SELECT COUNT(*) AS project_enrollment_count
FROM course_project.enrollments;

-- performance_lab 테이블 존재 확인
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'performance_lab'
ORDER BY table_name;

-- performance_lab이 준비된 경우 행 수 확인
SELECT COUNT(*) AS student_count
FROM performance_lab.students;

SELECT COUNT(*) AS instructor_count
FROM performance_lab.instructors;

SELECT COUNT(*) AS course_count
FROM performance_lab.courses;

SELECT COUNT(*) AS enrollment_count
FROM performance_lab.enrollments;

-- 기대 결과: 10003 / 2 / 2003 / 100005

-- 자동·수동 인덱스 확인
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'performance_lab'
ORDER BY tablename, indexname;

-- 최종 수동 후보:
-- idx_performance_courses_title
-- idx_performance_enrollments_student_id
-- idx_performance_enrollments_course_status
