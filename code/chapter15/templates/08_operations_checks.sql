-- Chapter 15. 운영 준비 상태 읽기 전용 점검
-- Role·GRANT·백업·복원은 자동 실행하지 않습니다.

SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name,
    current_setting('server_version') AS postgresql_version;

-- 1. 객체 소유자
SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    c.relkind,
    pg_get_userbyid(c.relowner) AS owner_name
FROM pg_class AS c
JOIN pg_namespace AS n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'tutor_project'
  AND c.relkind IN ('r', 'S', 'v')
ORDER BY c.relkind, c.relname;

-- 2. 명시적 테이블 권한
SELECT
    grantee,
    table_name,
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'tutor_project'
ORDER BY grantee, table_name, privilege_type;

-- 3. PUBLIC 권한
SELECT
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'tutor_project'
  AND grantee = 'PUBLIC'
ORDER BY table_name, privilege_type;

-- 4. 민감정보 형태 컬럼: 기대 0행
SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'tutor_project'
  AND lower(column_name) SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
ORDER BY table_name, column_name;

-- 5. 테스트 데이터의 이메일 도메인 확인
-- 실제 주소가 아니라 example.test만 사용해야 합니다.
SELECT email
FROM tutor_project.students
WHERE email NOT LIKE '%@example.test'
UNION ALL
SELECT email
FROM tutor_project.tutors
WHERE email NOT LIKE '%@example.test';

-- 기대: 0행

-- 6. 활성·비활성 자료와 접근 범위
SELECT
    access_scope,
    is_active,
    COUNT(*) AS material_count
FROM tutor_project.learning_materials
GROUP BY access_scope, is_active
ORDER BY access_scope, is_active DESC;

-- 7. 백업·복원 전 기준 행 수
SELECT
    (SELECT COUNT(*) FROM tutor_project.students) AS students_expected_4,
    (SELECT COUNT(*) FROM tutor_project.tutors) AS tutors_expected_3,
    (SELECT COUNT(*) FROM tutor_project.questions) AS questions_expected_5,
    (SELECT COUNT(*) FROM tutor_project.answers) AS answers_expected_5,
    (SELECT COUNT(*) FROM tutor_project.learning_materials) AS materials_expected_6,
    (SELECT COUNT(*) FROM tutor_project.question_materials) AS links_expected_7;

-- 8. 구조 검증용 기대 수치
SELECT
    (
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'tutor_project'
    ) AS tables_expected_6,
    (
        SELECT COUNT(*)
        FROM information_schema.table_constraints
        WHERE constraint_schema = 'tutor_project'
          AND constraint_type = 'FOREIGN KEY'
    ) AS foreign_keys_expected_5;

-- 역할 계획 예시:
-- tutor_project_owner      NOLOGIN: 객체 소유
-- tutor_project_app        NOLOGIN: students·questions·answers 제한 작업
-- tutor_project_report     NOLOGIN: SELECT 전용
-- 실제 Role·GRANT는 관리자 테스트 환경에서 OPERATIONS_RUNBOOK.md를 검토해 선택 실행합니다.
