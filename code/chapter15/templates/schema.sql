-- Chapter 15 호환 안내: 스키마 생성
-- 이 파일은 기존 링크 호환용 상태 확인 파일입니다.
-- 테이블과 스키마를 삭제하거나 생성하지 않습니다.
-- 실제 생성은 01_schema.sql을 실행합니다.

SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name,
    to_regnamespace('tutor_project') AS tutor_project_schema;

SELECT
    to_regclass('tutor_project.students') AS students_table,
    to_regclass('tutor_project.tutors') AS tutors_table,
    to_regclass('tutor_project.questions') AS questions_table,
    to_regclass('tutor_project.answers') AS answers_table,
    to_regclass('tutor_project.learning_materials') AS materials_table,
    to_regclass('tutor_project.question_materials') AS question_materials_table;

-- 실행 순서:
-- 01_schema.sql → 02_seed.sql → 03_metadata_validation.sql
-- 처음부터 다시 시작할 때만 reset_tutor_project.sql을 별도로 검토합니다.
