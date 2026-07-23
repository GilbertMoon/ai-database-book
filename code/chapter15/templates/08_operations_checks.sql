-- Chapter 15. 운영 준비 상태 읽기 전용 점검
-- P15-V06: PUBLIC·직접 GRANT·소유권·유효 권한·비밀 데이터 경로를 구분합니다.
-- Role·GRANT·백업·복원은 자동 실행하지 않습니다.

SELECT current_user AS current_user_name;
SELECT session_user AS session_user_name;
SELECT current_database();
SELECT current_schema();
SHOW search_path;
SELECT current_setting('server_version') AS postgresql_version;

-- 객체 소유자와 ACL
SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    c.relkind,
    pg_get_userbyid(c.relowner) AS owner_name,
    c.relacl
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'tutor_project'
  AND c.relkind IN ('r', 'S', 'v')
ORDER BY c.relkind, c.relname;

SELECT
    nspname AS schema_name,
    pg_get_userbyid(nspowner) AS owner_name,
    nspacl
FROM pg_namespace
WHERE nspname = 'tutor_project';

-- DB CONNECT 경로와 PUBLIC
SELECT datname, pg_get_userbyid(datdba) AS owner_name, datacl
FROM pg_database
WHERE datname = current_database();

SELECT
    has_database_privilege('PUBLIC', current_database(), 'CONNECT') AS public_can_connect,
    has_database_privilege(current_user, current_database(), 'CONNECT') AS current_user_can_connect;

-- 직접 테이블·컬럼 권한
SELECT grantee, table_name, privilege_type, is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'tutor_project'
ORDER BY grantee, table_name, privilege_type;

SELECT grantee, table_name, column_name, privilege_type, is_grantable
FROM information_schema.role_column_grants
WHERE table_schema = 'tutor_project'
ORDER BY grantee, table_name, column_name, privilege_type;

-- PUBLIC 권한은 table_privileges·column_privileges에서 확인합니다.
SELECT grantee, table_name, privilege_type, is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'tutor_project'
  AND grantee = 'PUBLIC'
ORDER BY table_name, privilege_type;

SELECT grantee, table_name, column_name, privilege_type, is_grantable
FROM information_schema.column_privileges
WHERE table_schema = 'tutor_project'
  AND grantee = 'PUBLIC'
ORDER BY table_name, column_name, privilege_type;

-- 현재 사용자의 최종 유효 권한
SELECT
    has_schema_privilege(current_user, 'tutor_project', 'USAGE') AS can_use_schema,
    has_schema_privilege(current_user, 'tutor_project', 'CREATE') AS can_create_in_schema,
    has_table_privilege(current_user, 'tutor_project.questions', 'SELECT') AS can_select_questions,
    has_table_privilege(current_user, 'tutor_project.questions', 'INSERT') AS can_insert_questions,
    has_table_privilege(current_user, 'tutor_project.questions', 'DELETE') AS can_delete_questions,
    has_table_privilege(current_user, 'tutor_project.question_analysis_dataset', 'SELECT') AS can_select_analysis_view;

-- IDENTITY 시퀀스 권한
SELECT
    n.nspname AS schema_name,
    c.relname AS sequence_name,
    pg_get_userbyid(c.relowner) AS owner_name,
    c.relacl
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'tutor_project'
  AND c.relkind = 'S'
ORDER BY c.relname;

-- 민감정보 형태 컬럼과 가상 데이터 규칙: 모두 0행이어야 합니다.
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'tutor_project'
  AND lower(column_name) SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
ORDER BY table_name, column_name;

SELECT email
FROM tutor_project.students
WHERE email NOT LIKE '%@example.test'
UNION ALL
SELECT email
FROM tutor_project.tutors
WHERE email NOT LIKE '%@example.test';

SELECT source_url
FROM tutor_project.learning_materials
WHERE source_url IS NOT NULL
  AND source_url NOT LIKE 'https://example.test/%';

SELECT content_hash
FROM tutor_project.learning_materials
WHERE content_hash NOT LIKE 'demo-sha256-%';

-- access_scope는 업무 분류 값일 뿐 실제 DB 접근 통제가 아닙니다.
-- restricted 값도 Role·GRANT·VIEW·RLS 같은 별도 통제 없이는 읽기를 차단하지 않습니다.
SELECT access_scope, is_active, COUNT(*) AS material_count
FROM tutor_project.learning_materials
GROUP BY access_scope, is_active
ORDER BY access_scope, is_active DESC;

DO $$
DECLARE
    violation_count BIGINT;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION 'P15-V06 실패: 현재 데이터베이스는 %입니다.', current_database();
    END IF;

    SELECT COUNT(*) INTO violation_count
    FROM (
        SELECT column_name AS value
        FROM information_schema.columns
        WHERE table_schema = 'tutor_project'
          AND lower(column_name) SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
        UNION ALL
        SELECT email FROM tutor_project.students WHERE email NOT LIKE '%@example.test'
        UNION ALL
        SELECT email FROM tutor_project.tutors WHERE email NOT LIKE '%@example.test'
        UNION ALL
        SELECT source_url FROM tutor_project.learning_materials
        WHERE source_url IS NOT NULL AND source_url NOT LIKE 'https://example.test/%'
        UNION ALL
        SELECT content_hash FROM tutor_project.learning_materials
        WHERE content_hash NOT LIKE 'demo-sha256-%'
    ) AS violations;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'P15-V06 실패: 민감정보·가상 데이터 규칙 위반이 %건 있습니다.', violation_count;
    END IF;

    RAISE NOTICE 'P15-V06 operational read-only checks passed';
END
$$;

-- 권장 역할 방향
-- tutor_project_owner  NOLOGIN: 객체 소유
-- tutor_project_app    NOLOGIN: 필요한 업무 작업만 허용
-- tutor_project_report NOLOGIN: 분석 VIEW와 필요한 조회만 허용
-- 실제 Role·GRANT·멤버십·PUBLIC 변경은 관리자 테스트 환경에서 Runbook을 검토해 선택 적용합니다.
