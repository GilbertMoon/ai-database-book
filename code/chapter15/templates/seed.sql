-- Chapter 15 호환 안내: 기준 데이터 입력
-- 이 파일은 기존 링크 호환용 상태 확인 파일입니다.
-- 데이터를 입력·수정·삭제하지 않습니다.
-- 실제 기준 데이터는 02_seed.sql을 실행합니다.

SELECT
    current_database() AS current_database_name,
    to_regnamespace('tutor_project') AS tutor_project_schema,
    to_regclass('tutor_project.students') AS students_table,
    to_regclass('tutor_project.questions') AS questions_table;

-- 02_seed.sql 기준:
-- students 4 / tutors 3 / questions 5 / answers 5
-- learning_materials 6 / question_materials 7
-- 명시적 ID로 이전 시퀀스 상태에 의존하지 않습니다.
