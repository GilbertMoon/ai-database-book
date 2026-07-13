-- Chapter 09. transaction_lab 초기화
-- 주의: transaction_lab 스키마와 실습 데이터만 삭제합니다.
-- course_project 스키마와 Chapter 07·08 데이터는 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();

-- 현재 데이터베이스가 ai_database_book인지 확인한 뒤
-- 아래 DROP 구간만 선택 실행합니다.

DROP TABLE IF EXISTS transaction_lab.payments;
DROP TABLE IF EXISTS transaction_lab.enrollments;
DROP TABLE IF EXISTS transaction_lab.course_inventory;
DROP SCHEMA IF EXISTS transaction_lab;

-- 삭제 후 실행 순서:
-- 1. 01_transaction_lab_schema.sql
-- 2. 02_transaction_lab_seed.sql
-- 3. 03_commit_transaction.sql
-- 4. 04_rollback_transaction.sql
-- 5. 05_commit_and_sold_out.sql
-- 6. 06_transaction_validation.sql
