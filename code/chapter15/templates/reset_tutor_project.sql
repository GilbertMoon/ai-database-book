-- Chapter 15. tutor_project 초기화
-- 주의: tutor_project 스키마와 프로젝트 데이터만 삭제합니다.
-- 앞 장 스키마, public 객체와 Role은 변경하지 않습니다.

SELECT
    current_user,
    current_database(),
    current_schema();

-- 현재 데이터베이스와 보존 대상을 확인한 뒤
-- 아래 DROP 구간만 선택 실행합니다.

DROP VIEW IF EXISTS tutor_project.rag_source_documents;
DROP TABLE IF EXISTS tutor_project.question_materials;
DROP TABLE IF EXISTS tutor_project.answers;
DROP TABLE IF EXISTS tutor_project.learning_materials;
DROP TABLE IF EXISTS tutor_project.questions;
DROP TABLE IF EXISTS tutor_project.tutors;
DROP TABLE IF EXISTS tutor_project.students;
DROP SCHEMA IF EXISTS tutor_project;

-- 삭제 후 실행 순서:
-- 1. 01_schema.sql
-- 2. 02_seed.sql
-- 3. 03_metadata_validation.sql
-- 4. 04_requirement_queries.sql
-- 5. 05_transaction_checks.sql
-- 6. 06_negative_tests.sql
-- 7. 07_performance_checks.sql
-- 8. 08_operations_checks.sql
-- 9. 필요하면 09_optional_rag_extension.sql
