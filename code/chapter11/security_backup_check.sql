-- Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법
-- 목적: 별도의 테스트 환경에서 계정·권한·데이터 보호·복구 검증 흐름을 확인한다.

-- 중요:
-- 1. 운영 데이터베이스에서 이 파일을 그대로 실행하지 않는다.
-- 2. 아래 역할 생성과 권한 변경 명령은 기본적으로 주석 처리되어 있다.
-- 3. 예시 비밀번호를 실제 환경에서 사용하지 않는다.
-- 4. pg_dump, psql, pg_restore는 SQL Editor가 아니라 터미널에서 실행한다.
-- 5. 비밀번호, 접속 URL, 실제 개인정보가 포함된 백업을 저장소에 커밋하지 않는다.

-- ============================================================
-- 1. 현재 연결 상태 확인
-- ============================================================

SELECT current_user AS current_user_name;
SELECT current_database() AS current_database_name;
SELECT current_schema() AS current_schema_name;

-- 의도한 테스트용 DB가 아니라면 여기서 실행을 중단한다.

-- ============================================================
-- 2. 반복 가능한 가상 데이터 준비
-- ============================================================

DROP TABLE IF EXISTS security_enrollments;
DROP TABLE IF EXISTS security_courses;
DROP TABLE IF EXISTS security_students;

CREATE TABLE security_students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE security_courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) UNIQUE NOT NULL,
    level VARCHAR(20) NOT NULL
        CHECK (level IN ('basic', 'intermediate', 'advanced')),
    price INT NOT NULL
        CHECK (price >= 0)
);

CREATE TABLE security_enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL
        REFERENCES security_students(id),
    course_id INT NOT NULL
        REFERENCES security_courses(id),
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('신청', '수강중', '완료', '취소')),
    paid_amount INT NOT NULL
        CHECK (paid_amount >= 0),
    enrolled_at DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (student_id, course_id)
);

-- 실제 개인정보 대신 가상 데이터를 사용한다.
INSERT INTO security_students (name, email, joined_at)
VALUES
    ('김민지', 'minji.security@example.com', '2026-03-01'),
    ('이준호', 'junho.security@example.com', '2026-03-03'),
    ('박서연', 'seoyeon.security@example.com', '2026-03-05');

INSERT INTO security_courses (title, level, price)
VALUES
    ('데이터베이스 보안 기초', 'basic', 100000),
    ('백업과 복구 이해', 'basic', 120000),
    ('권한 관리 입문', 'basic', 90000);

INSERT INTO security_enrollments (
    student_id,
    course_id,
    status,
    paid_amount,
    enrolled_at
)
VALUES
    (
        (SELECT id FROM security_students WHERE email = 'minji.security@example.com'),
        (SELECT id FROM security_courses WHERE title = '데이터베이스 보안 기초'),
        '수강중',
        100000,
        '2026-04-01'
    ),
    (
        (SELECT id FROM security_students WHERE email = 'junho.security@example.com'),
        (SELECT id FROM security_courses WHERE title = '백업과 복구 이해'),
        '신청',
        120000,
        '2026-04-02'
    ),
    (
        (SELECT id FROM security_students WHERE email = 'seoyeon.security@example.com'),
        (SELECT id FROM security_courses WHERE title = '권한 관리 입문'),
        '완료',
        90000,
        '2026-04-03'
    );

SELECT * FROM security_students ORDER BY id;
SELECT * FROM security_courses ORDER BY id;
SELECT * FROM security_enrollments ORDER BY id;

-- ============================================================
-- 3. 역할 존재 여부와 현재 역할 정보 확인
-- ============================================================

SELECT
    rolname,
    rolsuper,
    rolcreatedb,
    rolcreaterole,
    rolcanlogin
FROM pg_roles
WHERE rolname IN ('readonly_user', 'app_enrollment_user')
ORDER BY rolname;

-- ============================================================
-- 4. 읽기 전용 역할 설계 예시
-- ============================================================

-- 아래 명령은 관리자 권한이 있는 테스트 환경에서만 검토한다.
-- 이미 같은 역할이 존재하면 CREATE ROLE은 오류가 발생할 수 있다.

-- CREATE ROLE readonly_user
--     LOGIN
--     PASSWORD 'replace_with_a_secure_password';

-- GRANT CONNECT ON DATABASE ai_database_book TO readonly_user;
-- GRANT USAGE ON SCHEMA public TO readonly_user;
-- GRANT SELECT ON
--     security_students,
--     security_courses,
--     security_enrollments
-- TO readonly_user;

-- 역할을 실제로 만든 뒤 다음 권한 확인 쿼리의 주석을 해제한다.

-- SELECT
--     has_table_privilege(
--         'readonly_user',
--         'security_students',
--         'SELECT'
--     ) AS can_select_students,
--     has_table_privilege(
--         'readonly_user',
--         'security_students',
--         'INSERT'
--     ) AS can_insert_students,
--     has_table_privilege(
--         'readonly_user',
--         'security_students',
--         'UPDATE'
--     ) AS can_update_students,
--     has_table_privilege(
--         'readonly_user',
--         'security_students',
--         'DELETE'
--     ) AS can_delete_students;

-- ============================================================
-- 5. 애플리케이션 역할 설계 예시
-- ============================================================

-- CREATE ROLE app_enrollment_user
--     LOGIN
--     PASSWORD 'replace_with_a_different_secure_password';

-- GRANT CONNECT ON DATABASE ai_database_book TO app_enrollment_user;
-- GRANT USAGE ON SCHEMA public TO app_enrollment_user;

-- 학생과 강의는 조회만 허용한다.
-- GRANT SELECT ON
--     security_students,
--     security_courses
-- TO app_enrollment_user;

-- 수강신청에는 필요한 작업만 허용한다.
-- GRANT SELECT, INSERT, UPDATE
-- ON security_enrollments
-- TO app_enrollment_user;

-- SERIAL 기본값으로 새 id를 만들려면 관련 시퀀스 권한도 필요할 수 있다.
-- GRANT USAGE, SELECT
-- ON SEQUENCE security_enrollments_id_seq
-- TO app_enrollment_user;

-- DELETE와 관리자 권한은 기본적으로 부여하지 않는다.

-- ============================================================
-- 6. 권한 회수 예시
-- ============================================================

-- REVOKE SELECT ON security_courses FROM readonly_user;
-- REVOKE UPDATE ON security_enrollments FROM app_enrollment_user;

-- 권한 회수 후 has_table_privilege로 실제 상태를 다시 확인한다.

-- ============================================================
-- 7. 현재 테이블 권한 목록 확인
-- ============================================================

SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name LIKE 'security_%'
ORDER BY grantee, table_name, privilege_type;

-- 참고:
-- 현재 테이블에 부여한 권한과 앞으로 생성될 테이블의 기본 권한은
-- 별도로 설계해야 할 수 있다.

-- ============================================================
-- 8. SQL Injection 점검 메모
-- ============================================================

-- 위험한 개념 패턴:
-- SQL 문자열 + 사용자 입력값 + SQL 문자열

-- 안전한 방향:
-- 애플리케이션의 DB 드라이버 또는 프레임워크가 제공하는
-- 파라미터 바인딩 기능을 사용한다.

-- placeholder 예시는 라이브러리에 따라 다르다.
-- WHERE email = ?
-- WHERE email = $1
-- WHERE email = :email

-- 아래 쿼리는 값이 고정된 SQL 확인 예시일 뿐,
-- 애플리케이션 입력 처리 코드의 파라미터 바인딩 예시는 아니다.
SELECT id, name, email
FROM security_students
WHERE email = 'minji.security@example.com';

-- ============================================================
-- 9. 개인정보와 로그 점검
-- ============================================================

-- 실제 전화번호, 주민등록번호, 결제카드 정보, 실제 개인 이메일을
-- 테스트 데이터로 사용하지 않는다.

-- SELECT * 대신 필요한 열만 조회하는 방식을 검토한다.
SELECT id, name, joined_at
FROM security_students
ORDER BY id;

-- 로그와 오류 메시지에 비밀번호, 전체 연결 URL, Access Token을 남기지 않는다.

-- ============================================================
-- 10. 백업 명령 예시: 터미널에서 실행
-- ============================================================

-- SQL 텍스트 형식 백업:
-- pg_dump -U postgres -d ai_database_book -f ai_database_book_backup.sql

-- 사용자 정의 형식 백업:
-- pg_dump -U postgres -d ai_database_book -Fc -f ai_database_book.backup

-- 백업 전 확인:
-- 1. 대상 DB 이름
-- 2. 접속 사용자
-- 3. 출력 파일 경로
-- 4. 기존 파일 덮어쓰기 가능성
-- 5. 백업 파일 접근 권한
-- 6. 실제 개인정보 포함 여부

-- ============================================================
-- 11. 복구 명령 예시: 별도 DB에서 터미널로 실행
-- ============================================================

-- SQL 텍스트 형식 복구:
-- createdb -U postgres ai_database_book_restore
-- psql -U postgres -d ai_database_book_restore -f ai_database_book_backup.sql

-- 사용자 정의 형식 복구:
-- createdb -U postgres ai_database_book_restore
-- pg_restore -U postgres -d ai_database_book_restore ai_database_book.backup

-- 운영 DB에 복구 테스트를 직접 수행하지 않는다.

-- ============================================================
-- 12. 복구 후 검증 SQL
-- ============================================================

SELECT COUNT(*) AS restored_student_count
FROM security_students;

SELECT COUNT(*) AS restored_course_count
FROM security_courses;

SELECT COUNT(*) AS restored_enrollment_count
FROM security_enrollments;

SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM security_enrollments AS e
JOIN security_students AS s
    ON e.student_id = s.id
JOIN security_courses AS c
    ON e.course_id = c.id
ORDER BY e.id;

-- 추가 검증 항목:
-- 1. PK, FK, UNIQUE, CHECK 제약조건 유지 여부
-- 2. 필요한 역할과 권한 복구 여부
-- 3. 필요한 확장 기능과 함수 존재 여부
-- 4. 애플리케이션 핵심 기능 연결 여부
-- 5. 복구에 걸린 시간과 수동 작업 기록

-- ============================================================
-- 13. AI 생성 명령 검토 체크리스트
-- ============================================================

-- 1. 대상이 개발 DB인지 운영 DB인지 확인했는가?
-- 2. SUPERUSER 또는 ALL PRIVILEGES를 과도하게 부여하지 않는가?
-- 3. 예시 비밀번호나 실제 접속 정보가 포함되어 있지 않은가?
-- 4. DROP, DELETE, REVOKE, 덮어쓰기 범위를 확인했는가?
-- 5. 백업 형식과 복구 도구가 서로 맞는가?
-- 6. 백업 파일 저장 위치와 접근 권한이 안전한가?
-- 7. 별도 복구 확인용 DB를 사용하는가?
-- 8. 실행 전 되돌리는 방법과 영향 범위를 확인했는가?