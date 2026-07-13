-- Chapter 11. 유효 권한 확인
-- 03_role_permission_plan.sql에서 역할·권한을 선택 적용한 뒤 실행합니다.
-- 역할을 생성하지 않은 환경에서도 기본 객체·현재 사용자 확인 부분은 실행할 수 있습니다.

SELECT
    current_user AS current_user_name,
    session_user AS session_user_name,
    current_database() AS current_database_name;

-- 1. security_lab 객체와 소유자 확인
SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    c.relkind,
    pg_get_userbyid(c.relowner) AS owner_name
FROM pg_class AS c
JOIN pg_namespace AS n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'security_lab'
  AND c.relkind IN ('r', 'S')
ORDER BY c.relkind, c.relname;

-- 2. 실습 역할 존재·위험 속성 확인
SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole,
    rolinherit
FROM pg_roles
WHERE rolname LIKE 'lab_%'
ORDER BY rolname;

-- 기대: 앱·보고 역할과 로그인 역할 모두
-- rolsuper=false, rolcreatedb=false, rolcreaterole=false

-- 3. 명시적 테이블 권한
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'security_lab'
ORDER BY grantee, table_name, privilege_type;

-- 4. 컬럼 단위 권한
SELECT
    grantee,
    table_schema,
    table_name,
    column_name,
    privilege_type,
    is_grantable
FROM information_schema.role_column_grants
WHERE table_schema = 'security_lab'
ORDER BY grantee, table_name, column_name, privilege_type;

-- 5. 시퀀스와 소유자 확인
SELECT
    sequence_schema,
    sequence_name,
    data_type,
    start_value,
    increment
FROM information_schema.sequences
WHERE sequence_schema = 'security_lab'
ORDER BY sequence_name;

-- 6. PUBLIC에 부여된 명시적 테이블 권한
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'security_lab'
  AND grantee = 'PUBLIC'
ORDER BY table_name, privilege_type;

-- 7. 현재 접속 사용자의 유효 권한
SELECT
    has_schema_privilege(current_user, 'security_lab', 'USAGE')
        AS current_can_use_schema,
    has_schema_privilege(current_user, 'security_lab', 'CREATE')
        AS current_can_create_in_schema,
    has_table_privilege(current_user, 'security_lab.students', 'SELECT')
        AS current_can_select_students,
    has_table_privilege(current_user, 'security_lab.enrollments', 'INSERT')
        AS current_can_insert_enrollments,
    has_table_privilege(current_user, 'security_lab.enrollments', 'DELETE')
        AS current_can_delete_enrollments;

-- 8. 역할 멤버십과 특정 사용자의 유효 권한
-- 해당 역할이 실제로 존재하는 테스트 환경에서만 주석 해제합니다.

-- SELECT pg_has_role(
--     'lab_readonly_user',
--     'lab_role_report_reader',
--     'MEMBER'
-- ) AS readonly_is_report_reader;

-- SELECT pg_has_role(
--     'lab_enrollment_user',
--     'lab_role_enrollment_app',
--     'MEMBER'
-- ) AS app_is_enrollment_role;

-- 9. 읽기 계정 기대 권한
-- SELECT
--     has_database_privilege(
--         'lab_readonly_user',
--         'ai_database_book',
--         'CONNECT'
--     ) AS can_connect,
--     has_schema_privilege(
--         'lab_readonly_user',
--         'security_lab',
--         'USAGE'
--     ) AS can_use_schema,
--     has_table_privilege(
--         'lab_readonly_user',
--         'security_lab.enrollments',
--         'SELECT'
--     ) AS can_select_enrollments,
--     has_table_privilege(
--         'lab_readonly_user',
--         'security_lab.enrollments',
--         'INSERT'
--     ) AS can_insert_enrollments,
--     has_table_privilege(
--         'lab_readonly_user',
--         'security_lab.enrollments',
--         'UPDATE'
--     ) AS can_update_enrollments,
--     has_table_privilege(
--         'lab_readonly_user',
--         'security_lab.enrollments',
--         'DELETE'
--     ) AS can_delete_enrollments;

-- 기대: true / true / true / false / false / false

-- 10. 앱 계정 기대 권한
-- SELECT
--     has_database_privilege(
--         'lab_enrollment_user',
--         'ai_database_book',
--         'CONNECT'
--     ) AS can_connect,
--     has_schema_privilege(
--         'lab_enrollment_user',
--         'security_lab',
--         'USAGE'
--     ) AS can_use_schema,
--     has_schema_privilege(
--         'lab_enrollment_user',
--         'security_lab',
--         'CREATE'
--     ) AS can_create_in_schema,
--     has_table_privilege(
--         'lab_enrollment_user',
--         'security_lab.students',
--         'SELECT'
--     ) AS can_select_students,
--     has_table_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'INSERT'
--     ) AS can_insert_enrollments,
--     has_column_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'status',
--         'UPDATE'
--     ) AS can_update_status,
--     has_table_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'DELETE'
--     ) AS can_delete_enrollments,
--     has_sequence_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments_id_seq',
--         'USAGE'
--     ) AS can_use_enrollment_sequence;

-- 기대: true / true / false / true / true / true / false / true

-- 11. 실제 로그인 전환 테스트 예시
-- 관리자 테스트 세션에서만 사용합니다.
-- SET ROLE lab_readonly_user;
-- SELECT * FROM security_lab.students;
-- INSERT INTO security_lab.enrollments (...) VALUES (...); -- 실패해야 정상
-- RESET ROLE;

-- SET ROLE lab_enrollment_user;
-- SELECT * FROM security_lab.courses;
-- UPDATE security_lab.enrollments SET status = '완료' WHERE id = 1001;
-- DELETE FROM security_lab.enrollments WHERE id = 1001; -- 실패해야 정상
-- RESET ROLE;
