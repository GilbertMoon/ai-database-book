-- Chapter 12. nosql_lab 초기화
-- 주의: nosql_lab 스키마와 실습 데이터만 삭제합니다.
-- course_project, transaction_lab, performance_lab, security_lab, public 객체는 변경하지 않습니다.

SELECT
    current_user,
    current_database(),
    current_schema();

-- 현재 데이터베이스와 보존 대상 스키마를 확인한 뒤
-- 아래 DROP 구간만 선택 실행합니다.

DROP TABLE IF EXISTS nosql_lab.storage_choice_cases;
DROP TABLE IF EXISTS nosql_lab.key_value_cache_examples;
DROP TABLE IF EXISTS nosql_lab.course_documents;
DROP SCHEMA IF EXISTS nosql_lab;

-- 삭제 후 실행 순서:
-- 1. 01_nosql_lab_schema.sql
-- 2. 02_nosql_lab_seed.sql
-- 3. 03_document_jsonb_queries.sql
-- 4. 04_key_value_cache_queries.sql
-- 5. 05_storage_choice_review.sql
