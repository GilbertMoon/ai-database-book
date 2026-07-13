-- Chapter 15 호환 안내: 검증 쿼리
-- 이 파일은 기존 링크 호환용 상태 확인 파일입니다.
-- 실제 검증은 다음 파일을 순서대로 실행합니다.
--
-- 03_metadata_validation.sql
-- 04_requirement_queries.sql
-- 05_transaction_checks.sql
-- 06_negative_tests.sql
-- 07_performance_checks.sql
-- 08_operations_checks.sql

SELECT
    current_database() AS current_database_name,
    to_regnamespace('tutor_project') AS tutor_project_schema,
    to_regclass('tutor_project.questions') AS questions_table,
    to_regclass('tutor_project.answers') AS answers_table,
    to_regclass('tutor_project.learning_materials') AS materials_table;

-- 기대 기준:
-- 행 수 4 / 3 / 5 / 5 / 6 / 7
-- FK 5 / 업무 인덱스 3 / CASCADE 0
-- 질문 없는 학생 1 / 연결되지 않은 자료 1
-- 정합성 이상 0행 / 자동 반례 unexpected 0
