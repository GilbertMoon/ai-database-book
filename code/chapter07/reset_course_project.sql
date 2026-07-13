-- Chapter 07. 온라인 강의 프로젝트 초기화
-- 주의: course_project 스키마와 모든 프로젝트 데이터를 삭제합니다.
-- 처음부터 다시 시작해야 할 때만 사용합니다.

SELECT current_database();
SELECT current_schema();

-- 기대 결과가 ai_database_book인지 반드시 확인한 뒤
-- 아래 DROP 구간만 선택하여 실행합니다.

DROP TABLE IF EXISTS course_project.enrollments;
DROP TABLE IF EXISTS course_project.courses;
DROP TABLE IF EXISTS course_project.instructors;
DROP TABLE IF EXISTS course_project.students;
DROP SCHEMA IF EXISTS course_project;

-- 삭제 후 실행 순서:
-- 1. 01_course_project_schema.sql
-- 2. 02_course_project_seed.sql
-- 3. 03_course_project_changes.sql
-- 4. 04_course_project_validation.sql
-- 5. 05_course_project_integrity_tests.sql에서 필요한 테스트만 실행
