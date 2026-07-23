-- Chapter 11. 유효 권한 확인
-- 03_role_permission_plan.sql에서 역할·권한을 선택 적용한 뒤 실행합니다.
-- 역할을 만들지 않은 환경에서도 객체·현재 사용자 확인 구간은 실행할 수 있습니다.

SELECT current_user AS current_user_name;
SELECT session_user AS session_user_name;
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. security_lab 객체와 소유자 확인
-- ============================================================
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

SELECT
    nspname AS schema_name,
    pg_get_userbyid(nspowner) AS owner_name,
    nspacl
FROM pg_namespace
WHERE nspname = 'security_lab';

-- ============================================================
-- 2. 실습 역할 존재·위험 속성 확인
-- ============================================================
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

-- 기대: 실습 역할은 rolsuper=false, rolcreatedb=false, rolcreaterole=false

-- ============================================================
-- 3. 데이터베이스 ACL과 PUBLIC CONNECT 경로 확인
-- ============================================================
SELECT
    datname,
    pg_get_userbyid(datdba) AS owner_name,
    datacl
FROM pg_database
WHERE datname = current_database();

SELECT
    has_database_privilege('PUBLIC', current_database(), 'CONNECT')
        AS public_can_connect,
    has_database_privilege(current_user, current_database(), 'CONNECT')
        AS current_user_can_connect;

-- has_database_privilege는 최종 유효 권한을 보여 줍니다.
-- datacl은 직접 GRANT와 PUBLIC 같은 권한 경로를 검토하는 근거입니다.

-- ============================================================
-- 4. 명시적 테이블·컬럼 권한
-- ============================================================
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'security_lab'
ORDER BY grantee, table_name, privilege_type;

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

-- ============================================================
-- 5. PUBLIC 권한 확인
-- role_table_grants와 role_column_grants는 PUBLIC 경로를 제외할 수 있으므로
-- table_privileges와 column_privileges를 사용합니다.
-- ============================================================
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'security_lab'
  AND grantee = 'PUBLIC'
ORDER BY table_name, privilege_type;

SELECT
    grantee,
    table_schema,
    table_name,
    column_name,
    privilege_type,
    is_grantable
FROM information_schema.column_privileges
WHERE table_schema = 'security_lab'
  AND grantee = 'PUBLIC'
ORDER BY table_name, column_name, privilege_type;

-- ============================================================
-- 6. 시퀀스와 소유자 확인
-- ============================================================
SELECT
    sequence_schema,
    sequence_name,
    data_type,
    start_value,
    increment
FROM information_schema.sequences
WHERE sequence_schema = 'security_lab'
ORDER BY sequence_name;

SELECT
    n.nspname AS schema_name,
    c.relname AS sequence_name,
    pg_get_userbyid(c.relowner) AS owner_name,
    c.relacl
FROM pg_class AS c
JOIN pg_namespace AS n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'security_lab'
  AND c.relkind = 'S'
ORDER BY c.relname;

-- ============================================================
-- 7. 현재 접속 사용자의 유효 권한
-- 소유자는 일반 GRANT와 별도로 강한 객체 제어 권한을 가질 수 있습니다.
-- ============================================================
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

-- ============================================================
-- 8. 역할 멤버십과 권한 상속
-- 실제 역할이 존재하는 테스트 환경에서만 주석을 해제합니다.
-- MEMBER는 멤버십 존재, USAGE는 권한을 즉시 사용할 수 있는지를 확인합니다.
-- ============================================================
-- SELECT
--     pg_has_role(
--         'lab_readonly_user',
--         'lab_role_report_reader',
--         'MEMBER'
--     ) AS readonly_is_member,
--     pg_has_role(
--         'lab_readonly_user',
--         'lab_role_report_reader',
--         'USAGE'
--     ) AS readonly_privileges_available;
--
-- SELECT
--     pg_has_role(
--         'lab_enrollment_user',
--         'lab_role_enrollment_app',
--         'MEMBER'
--     ) AS app_is_member,
--     pg_has_role(
--         'lab_enrollment_user',
--         'lab_role_enrollment_app',
--         'USAGE'
--     ) AS app_privileges_available;

-- ============================================================
-- 9. 읽기 계정 기대 권한
-- ============================================================
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
--     has_schema_privilege(
--         'lab_readonly_user',
--         'security_lab',
--         'CREATE'
--     ) AS can_create_in_schema,
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
--
-- 기대: true / true / false / true / false / false / false

-- ============================================================
-- 10. 앱 계정 기대 권한
-- 테이블 전체 UPDATE는 false이고 status 컬럼 UPDATE만 true여야 합니다.
-- ============================================================
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
--         'SELECT'
--     ) AS can_select_enrollments,
--     has_table_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'INSERT'
--     ) AS can_insert_enrollments,
--     has_table_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'UPDATE'
--     ) AS can_update_all_columns,
--     has_column_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'status',
--         'UPDATE'
--     ) AS can_update_status,
--     has_column_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'paid_amount',
--         'UPDATE'
--     ) AS can_update_paid_amount,
--     has_table_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments',
--         'DELETE'
--     ) AS can_delete_enrollments,
--     has_sequence_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments_id_seq',
--         'USAGE'
--     ) AS can_use_enrollment_sequence,
--     has_sequence_privilege(
--         'lab_enrollment_user',
--         'security_lab.enrollments_id_seq',
--         'SELECT'
--     ) AS can_select_enrollment_sequence;
--
-- 기대:
-- true / true / false / true / true / true / false / true / false / false / true / false

-- 실제 허용·차단 DML은 05_permission_behavior_tests.sql에서 안전하게 확인합니다.
