-- Chapter 13. ai_review_lab 초기화
-- 주의: ai_review_lab 스키마와 실습 데이터만 삭제합니다.
-- 기존 프로젝트·앞 장 스키마·Role은 변경하지 않습니다.

SELECT
    current_user,
    current_database(),
    current_schema();

-- 현재 데이터베이스와 보존 대상을 확인한 뒤
-- 아래 DROP 구간만 선택 실행합니다.

DROP TABLE IF EXISTS ai_review_lab.payments;
DROP TABLE IF EXISTS ai_review_lab.enrollments;
DROP TABLE IF EXISTS ai_review_lab.courses;
DROP TABLE IF EXISTS ai_review_lab.instructors;
DROP TABLE IF EXISTS ai_review_lab.students;
DROP TABLE IF EXISTS ai_review_lab.bad_enrollments;
DROP SCHEMA IF EXISTS ai_review_lab;

-- 삭제 후 실행 순서:
-- 1. 01_ai_review_lab_schema.sql
-- 2. 02_bad_design_seed.sql
-- 3. 03_good_design_schema.sql
-- 4. 04_good_design_seed.sql
-- 5. 05_metadata_validation.sql
-- 6. 06_business_validation.sql
-- 7. 07_negative_tests.sql
