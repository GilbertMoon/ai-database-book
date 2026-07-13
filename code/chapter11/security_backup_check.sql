-- Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법
--
-- 이 파일은 기존 링크 호환용 안내·상태 확인 진입점입니다.
-- 기존 프로젝트 테이블을 삭제하거나 다시 만들지 않습니다.
-- security_lab이 아직 생성되지 않은 상태에서도 안전하게 실행할 수 있습니다.
-- 실제 실습은 다음 파일을 순서대로 사용합니다.
--
-- 1. 01_security_lab_schema.sql
-- 2. 02_security_lab_seed.sql
-- 3. 03_role_permission_plan.sql
-- 4. 04_permission_checks.sql
-- 5. 터미널에서 백업·별도 DB 복원
-- 6. 복원 DB에서 05_restore_validation.sql
-- 7. BACKUP_RESTORE_RUNBOOK.md 기록
--
-- 처음부터 다시 시작할 때만 reset_security_lab.sql을 사용합니다.

SELECT
    current_user AS current_user_name,
    session_user AS session_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name,
    current_setting('server_version') AS postgresql_version;

-- 앞 장과 Chapter 11 객체 존재 여부 확인
-- 존재하지 않는 객체는 NULL로 표시되며 오류를 발생시키지 않습니다.
SELECT
    to_regclass('course_project.enrollments')
        AS project_enrollments_table,
    to_regclass('security_lab.students')
        AS security_students_table,
    to_regclass('security_lab.courses')
        AS security_courses_table,
    to_regclass('security_lab.enrollments')
        AS security_enrollments_table;

-- security_lab 테이블 목록
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'security_lab'
ORDER BY table_name;

-- 기준 행 수 조회는 01·02 파일을 실행한 뒤 사용합니다.
-- SELECT COUNT(*) AS student_count
-- FROM security_lab.students;
--
-- SELECT COUNT(*) AS course_count
-- FROM security_lab.courses;
--
-- SELECT COUNT(*) AS enrollment_count
-- FROM security_lab.enrollments;
--
-- SELECT COUNT(*) AS joined_row_count
-- FROM security_lab.enrollments AS e
-- JOIN security_lab.students AS s
--     ON s.id = e.student_id
-- JOIN security_lab.courses AS c
--     ON c.id = e.course_id;
--
-- 기대 결과: 3 / 3 / 3 / 3

-- 실습 Role 확인
SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole
FROM pg_roles
WHERE rolname LIKE 'lab_%'
ORDER BY rolname;

-- 실제 비밀번호·접속 URL·백업 파일은 저장소에 기록하지 않습니다.
-- 역할 변경은 03 파일에서 주석 상태의 문장을 검토해 선택 실행합니다.
-- 백업·복원 명령은 BACKUP_RESTORE_RUNBOOK.md를 참고합니다.
