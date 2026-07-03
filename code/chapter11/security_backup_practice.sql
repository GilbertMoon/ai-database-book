-- Chapter 11. 데이터베이스 보안과 백업
-- 목적: PostgreSQL에서 사용자, 권한, GRANT/REVOKE, 백업/복구 점검 흐름을 학습한다.

-- 중요 주의:
-- 1. 이 파일은 교육용 예제입니다.
-- 2. 운영 데이터베이스에서 그대로 실행하지 마세요.
-- 3. CREATE ROLE, GRANT, REVOKE는 권한이 있는 계정에서만 실행됩니다.
-- 4. 실습 전 반드시 별도의 실습용 데이터베이스에서 실행하세요.
-- 5. 예시 비밀번호는 실제 환경에서 절대 사용하지 마세요.

-- ============================================================
-- 1. 실습용 테이블 준비
-- ============================================================

CREATE TABLE IF NOT EXISTS security_students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS security_courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    level VARCHAR(20) NOT NULL,
    price INT NOT NULL
);

CREATE TABLE IF NOT EXISTS security_enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES security_students(id),
    course_id INT NOT NULL REFERENCES security_courses(id),
    status VARCHAR(20) NOT NULL,
    paid_amount INT NOT NULL
);

INSERT INTO security_students (name, email, joined_at)
VALUES
    ('김민지', 'minji.security@example.com', '2026-03-01'),
    ('이준호', 'junho.security@example.com', '2026-03-03'),
    ('박서연', 'seoyeon.security@example.com', '2026-03-05')
ON CONFLICT DO NOTHING;

INSERT INTO security_courses (title, level, price)
VALUES
    ('데이터베이스 보안 기초', 'basic', 100000),
    ('백업과 복구 실습', 'basic', 120000),
    ('권한 관리 입문', 'basic', 90000)
ON CONFLICT DO NOTHING;

INSERT INTO security_enrollments (student_id, course_id, status, paid_amount)
VALUES
    (1, 1, '수강중', 100000),
    (2, 2, '신청', 120000),
    (3, 3, '완료', 90000)
ON CONFLICT DO NOTHING;

-- 데이터 확인
SELECT * FROM security_students;
SELECT * FROM security_courses;
SELECT * FROM security_enrollments;

-- ============================================================
-- 2. 현재 사용자와 데이터베이스 확인
-- ============================================================

SELECT current_user AS current_user_name;
SELECT current_database() AS current_database_name;

-- 현재 세션에서 보이는 주요 역할 목록 확인
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
FROM pg_roles
ORDER BY rolname;

-- ============================================================
-- 3. 읽기 전용 역할 생성 예시
-- ============================================================

-- 아래 명령은 관리자 권한이 있는 계정에서만 실행될 수 있습니다.
-- 이미 역할이 존재하면 오류가 날 수 있으므로 실습 환경에서만 사용하세요.

-- CREATE ROLE readonly_user LOGIN PASSWORD 'change_this_password';

-- 실습 환경에서 역할을 만들었다면 다음 권한을 부여할 수 있습니다.
-- GRANT CONNECT ON DATABASE ai_database_book TO readonly_user;
-- GRANT USAGE ON SCHEMA public TO readonly_user;
-- GRANT SELECT ON security_students TO readonly_user;
-- GRANT SELECT ON security_courses TO readonly_user;
-- GRANT SELECT ON security_enrollments TO readonly_user;

-- ============================================================
-- 4. 권한 확인
-- ============================================================

-- 특정 역할이 테이블에 대해 어떤 권한을 갖는지 확인하는 예시입니다.
-- readonly_user가 아직 생성되지 않았다면 결과가 false로 나올 수 있습니다.

SELECT
    'readonly_user' AS role_name,
    'security_students' AS table_name,
    has_table_privilege('readonly_user', 'security_students', 'SELECT') AS can_select,
    has_table_privilege('readonly_user', 'security_students', 'INSERT') AS can_insert,
    has_table_privilege('readonly_user', 'security_students', 'UPDATE') AS can_update,
    has_table_privilege('readonly_user', 'security_students', 'DELETE') AS can_delete;

SELECT
    'readonly_user' AS role_name,
    'security_courses' AS table_name,
    has_table_privilege('readonly_user', 'security_courses', 'SELECT') AS can_select,
    has_table_privilege('readonly_user', 'security_courses', 'INSERT') AS can_insert,
    has_table_privilege('readonly_user', 'security_courses', 'UPDATE') AS can_update,
    has_table_privilege('readonly_user', 'security_courses', 'DELETE') AS can_delete;

-- ============================================================
-- 5. 권한 회수 예시
-- ============================================================

-- 읽기 권한을 회수하는 예시입니다.
-- 실제 수업에서는 권한 부여 후 회수 전후 결과를 비교하세요.

-- REVOKE SELECT ON security_courses FROM readonly_user;

-- 회수 후 다시 확인하는 예시
-- SELECT
--     'readonly_user' AS role_name,
--     'security_courses' AS table_name,
--     has_table_privilege('readonly_user', 'security_courses', 'SELECT') AS can_select;

-- ============================================================
-- 6. 애플리케이션용 역할 권한 예시
-- ============================================================

-- 서비스 계정은 필요한 작업만 수행하도록 제한해야 합니다.
-- 예를 들어 수강신청 서비스 계정은 enrollments 테이블에만 제한적으로 쓰기 권한을 가질 수 있습니다.

-- CREATE ROLE app_enrollment_user LOGIN PASSWORD 'change_this_password';
-- GRANT CONNECT ON DATABASE ai_database_book TO app_enrollment_user;
-- GRANT USAGE ON SCHEMA public TO app_enrollment_user;
-- GRANT SELECT ON security_students TO app_enrollment_user;
-- GRANT SELECT ON security_courses TO app_enrollment_user;
-- GRANT SELECT, INSERT, UPDATE ON security_enrollments TO app_enrollment_user;

-- DELETE 권한은 기본적으로 부여하지 않는 편이 안전합니다.

-- ============================================================
-- 7. 권한 설계 점검 쿼리
-- ============================================================

-- 현재 public 스키마의 테이블별 권한 정보를 조회합니다.
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name LIKE 'security_%'
ORDER BY grantee, table_name, privilege_type;

-- ============================================================
-- 8. SQL Injection 위험 패턴과 안전한 방향
-- ============================================================

-- 위험한 방식의 개념 예시:
-- 사용자 입력값을 SQL 문자열에 직접 이어 붙이면 안 됩니다.
-- 예: SELECT * FROM users WHERE email = '입력값'; 형태를 문자열 결합으로 만들면 위험할 수 있습니다.

-- 안전한 방향:
-- 애플리케이션 코드에서는 파라미터 바인딩을 사용합니다.
-- 예: WHERE email = ?
-- 예: WHERE email = $1
-- 예: WHERE email = :email

-- 데이터베이스 실습에서는 다음처럼 값이 고정된 SQL을 사용합니다.
SELECT id, name, email
FROM security_students
WHERE email = 'minji.security@example.com';

-- ============================================================
-- 9. 개인정보/민감정보 점검 예시
-- ============================================================

-- 수업용 데이터는 반드시 가상 데이터를 사용합니다.
-- 실제 전화번호, 주민등록번호, 결제카드 정보, 개인 이메일 원본을 실습 DB에 넣지 않습니다.

SELECT id, name, email, joined_at
FROM security_students;

-- 민감정보가 로그나 결과표에 과도하게 노출되지 않는지 확인해야 합니다.

-- ============================================================
-- 10. 백업 명령 구조 확인
-- ============================================================

-- 아래 명령은 SQL Editor에서 실행하는 SQL이 아니라 터미널에서 실행하는 명령입니다.
-- 실제 실행 전 데이터베이스 이름, 사용자, 파일 경로를 반드시 확인하세요.

-- 백업 예시:
-- pg_dump -U postgres -d ai_database_book -f ai_database_book_backup.sql

-- 복구 예시:
-- psql -U postgres -d ai_database_book_restore -f ai_database_book_backup.sql

-- 중요:
-- 운영 DB에 바로 복구 테스트를 하지 마세요.
-- 별도의 복구 테스트용 DB에서 백업 파일이 정상 복구되는지 확인하세요.

-- ============================================================
-- 11. 백업 후 확인할 SQL 예시
-- ============================================================

-- 복구 테스트용 DB에서 다음과 같은 쿼리로 데이터가 정상 복구되었는지 확인할 수 있습니다.

SELECT COUNT(*) AS restored_student_count
FROM security_students;

SELECT COUNT(*) AS restored_course_count
FROM security_courses;

SELECT COUNT(*) AS restored_enrollment_count
FROM security_enrollments;

-- 주요 조회가 정상 동작하는지도 확인합니다.
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM security_enrollments AS e
JOIN security_students AS s ON e.student_id = s.id
JOIN security_courses AS c ON e.course_id = c.id
ORDER BY e.id;

-- ============================================================
-- 12. AI 생성 보안/백업 명령 검토 질문
-- ============================================================

-- 다음 질문에 답해 보세요.
-- 1. AI가 관리자 권한을 과도하게 부여하고 있지 않은가?
-- 2. 예시 비밀번호를 그대로 사용하고 있지 않은가?
-- 3. 운영 DB와 실습 DB를 혼동할 가능성은 없는가?
-- 4. GRANT 권한이 최소 권한 원칙에 맞는가?
-- 5. REVOKE가 필요한 권한은 없는가?
-- 6. 백업 파일 저장 위치와 접근 권한이 안전한가?
-- 7. 복구 테스트를 별도 DB에서 수행하는가?
-- 8. 삭제, 덮어쓰기, 권한 확대 같은 위험 명령이 포함되어 있지 않은가?
