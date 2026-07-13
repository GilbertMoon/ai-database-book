-- Chapter 10. performance_lab 초기화
-- 주의: performance_lab 스키마와 성능 실험 데이터만 삭제합니다.
-- course_project, transaction_lab, public 객체는 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();

-- 현재 데이터베이스를 확인한 뒤 아래 DROP 구간만 선택 실행합니다.
DROP TABLE IF EXISTS performance_lab.enrollments;
DROP TABLE IF EXISTS performance_lab.courses;
DROP TABLE IF EXISTS performance_lab.instructors;
DROP TABLE IF EXISTS performance_lab.students;
DROP SCHEMA IF EXISTS performance_lab;

-- 삭제 후 실행 순서:
-- 1. 01_performance_lab_schema.sql
-- 2. 02_performance_lab_seed.sql
-- 3. 03_baseline_explain.sql
-- 4. 04_create_candidate_indexes.sql
-- 5. 05_after_index_explain.sql
-- 6. 06_index_review.sql
