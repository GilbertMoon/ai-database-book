-- Chapter 11. 데이터베이스 보안과 백업 기초
-- 목적: security_ 실습 테이블로 권한, SQL Injection 방어 원칙, 백업/복구 검증 항목을 점검한다.

-- 주의:
-- 이 파일은 security_ 실습 테이블을 삭제하고 다시 생성합니다.
-- 개인 실습용 ai_database_book 데이터베이스에서만 실행하세요.
-- CREATE ROLE, GRANT, REVOKE, 백업/복구 명령은 대부분 주석 상태로 제공됩니다.
-- pg_dump, pg_restore, createdb, psql은 SQL Editor가 아니라 터미널에서 실행합니다.

-- 1. 현재 연결 정보 확인
SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name;

SELECT
    current_setting('server_version') AS postgresql_version,
    inet_server_addr() AS server_address,
    inet_server_port() AS server_port;

-- 로컬 환경에서는 server_address가 NULL로 표시될 수 있습니다.
-- 운영 주소나 실제 접속 정보를 문서 예시에 복사하지 않습니다.

-- 2. Chapter 11 전용 실습 테이블 초기화
DROP TABLE IF EXISTS public.security_enrollments;
DROP TABLE IF EXISTS public.security_courses;
DROP TABLE IF EXISTS public.security_students;

CREATE TABLE public.security_students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE public.security_courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    level VARCHAR(20) NOT NULL,
    price INT NOT NULL CHECK (price >= 0)
);

CREATE TABLE public.security_enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES public.security_students(id),
    course_id INT NOT NULL REFERENCES public.security_courses(id),
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('신청', '수강중', '완료', '취소')),
    paid_amount INT NOT NULL CHECK (paid_amount >= 0),
    enrolled_at DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Chapter 07에서 같은 학생의 같은 강의 재신청 정책은 확정하지 않았다.
-- 따라서 Chapter 11 보안 실습 테이블에도 UNIQUE(student_id, course_id)를 추가하지 않는다.

INSERT INTO public.security_students (name, email, joined_at)
VALUES
    ('김민지', 'minji.security@example.com', '2026-03-01'),
    ('이준호', 'junho.security@example.com', '2026-03-03'),
    ('박서연', 'seoyeon.security@example.com', '2026-03-05');

INSERT INTO public.security_courses (title, level, price)
VALUES
    ('데이터베이스 보안 기초', 'basic', 100000),
    ('백업과 복구 이해', 'basic', 120000),
    ('권한 관리 입문', 'basic', 90000);

INSERT INTO public.security_enrollments (
    student_id,
    course_id,
    status,
    paid_amount,
    enrolled_at
)
VALUES
    (1, 1, '수강중', 100000, '2026-04-01'),
    (2, 2, '신청', 120000, '2026-04-02'),
    (3, 3, '완료', 90000, '2026-04-03');

-- 3. 기본 데이터 검증
SELECT COUNT(*) AS expected_3_students
FROM public.security_students;

SELECT COUNT(*) AS expected_3_courses
FROM public.security_courses;

SELECT COUNT(*) AS expected_3_enrollments
FROM public.security_enrollments;

SELECT COUNT(*) AS expected_3_join_rows
FROM public.security_enrollments AS e
JOIN public.security_students AS s
    ON e.student_id = s.id
JOIN public.security_courses AS c
    ON e.course_id = c.id;

-- 4. 역할 모델 예시
-- 실제 역할 생성과 권한 변경은 관리자 권한이 있는 테스트 환경에서만 수행합니다.
-- 실제 비밀번호를 SQL 파일이나 저장소에 기록하지 않습니다.

-- CREATE ROLE role_report_reader NOLOGIN;
-- CREATE ROLE role_enrollment_app NOLOGIN;
-- CREATE ROLE readonly_user LOGIN;
-- CREATE ROLE app_enrollment_user LOGIN;
-- GRANT role_report_reader TO readonly_user;
-- GRANT role_enrollment_app TO app_enrollment_user;

-- 5. 읽기 전용 권한 역할 예시
-- GRANT CONNECT
-- ON DATABASE ai_database_book
-- TO role_report_reader;
--
-- GRANT USAGE
-- ON SCHEMA public
-- TO role_report_reader;
--
-- GRANT SELECT
-- ON TABLE
--     public.security_students,
--     public.security_courses,
--     public.security_enrollments
-- TO role_report_reader;

-- 6. 수강신청 애플리케이션 권한 역할 예시
-- GRANT CONNECT
-- ON DATABASE ai_database_book
-- TO role_enrollment_app;
--
-- GRANT USAGE
-- ON SCHEMA public
-- TO role_enrollment_app;
--
-- GRANT SELECT
-- ON TABLE
--     public.security_students,
--     public.security_courses
-- TO role_enrollment_app;
--
-- GRANT SELECT, INSERT, UPDATE
-- ON TABLE public.security_enrollments
-- TO role_enrollment_app;
--
-- GRANT USAGE, SELECT
-- ON SEQUENCE public.security_enrollments_id_seq
-- TO role_enrollment_app;

-- 7. 유효 권한 확인 예시
-- REVOKE는 특정 경로로 부여된 권한을 회수한다.
-- 다른 역할 멤버십이나 PUBLIC 권한으로 같은 권한이 남아 있을 수 있으므로 유효 권한을 다시 확인한다.

-- SELECT
--     has_database_privilege(
--         'readonly_user',
--         'ai_database_book',
--         'CONNECT'
--     ) AS can_connect,
--     has_schema_privilege(
--         'readonly_user',
--         'public',
--         'USAGE'
--     ) AS can_use_schema,
--     has_table_privilege(
--         'readonly_user',
--         'public.security_courses',
--         'SELECT'
--     ) AS can_select_courses;
--
-- SELECT pg_has_role(
--     'readonly_user',
--     'role_report_reader',
--     'MEMBER'
-- ) AS is_report_reader;

-- 8. 명시적 테이블 권한 목록 확인 예시
-- SELECT
--     grantee,
--     table_schema,
--     table_name,
--     privilege_type
-- FROM information_schema.role_table_grants
-- WHERE table_schema = 'public'
--   AND table_name IN (
--       'security_students',
--       'security_courses',
--       'security_enrollments'
--   )
-- ORDER BY grantee, table_name, privilege_type;

-- 9. 현재 객체와 미래 객체 권한 메모
-- 현재 존재하는 테이블 GRANT와 ALTER DEFAULT PRIVILEGES는 적용 범위가 다르다.
-- 기본 실습에서는 자동 실행하지 않는다.

-- ALTER DEFAULT PRIVILEGES
-- FOR ROLE <object_owner_role>
-- IN SCHEMA public
-- GRANT SELECT ON TABLES
-- TO role_report_reader;
--
-- ALTER DEFAULT PRIVILEGES
-- FOR ROLE <object_owner_role>
-- IN SCHEMA public
-- GRANT USAGE, SELECT ON SEQUENCES
-- TO role_enrollment_app;

-- 10. SQL Injection 안전 처리 메모
-- 위험한 방향: 사용자 입력을 SQL 문자열에 직접 결합한다.
-- 안전한 방향: SQL 구조와 값을 분리하고 파라미터 바인딩을 사용한다.
-- 동적 테이블명과 컬럼명은 파라미터 바인딩 대상이 아니므로 허용 목록으로 제한한다.

-- 허용 목록 개념 예시:
-- allowed_sort_columns = ('name', 'joined_at')
-- 사용자가 보낸 정렬 컬럼이 목록에 없으면 SQL을 만들지 않는다.

-- 11. 민감 정보와 로그 점검 메모
-- .env, .env.local, *.backup, *.dump, *.sql 백업 파일은 공개 저장소에 커밋하지 않는다.
-- .env.example에는 실제 값 없이 변수 이름만 둔다.
-- 노출된 비밀번호는 파일 삭제보다 자격 증명 회전을 우선한다.

-- 12. 논리 백업 명령 예시: 터미널에서 실행
-- pg_dump는 데이터베이스 단위 논리 백업 도구이며 결과 파일을 자동 암호화하지 않는다.
-- 역할 같은 클러스터 전역 객체는 pg_dump에 포함되지 않으므로 별도 관리가 필요할 수 있다.

-- pg_dump -U postgres -d ai_database_book -f ai_database_book_backup.sql
-- pg_dump -U postgres -d ai_database_book -Fc -f ai_database_book.backup
-- pg_dumpall --globals-only -U postgres -f globals.sql

-- 13. 별도 DB 복구 검증 예시: 터미널에서 실행
-- 원본 운영 DB가 아니라 별도 복구 확인 DB에서 검증한다.
-- 오류 발생 시 즉시 중단하는 옵션을 사용한다.

-- createdb -U postgres ai_database_book_restore
-- psql -U postgres -d ai_database_book_restore -v ON_ERROR_STOP=1 -f ai_database_book_backup.sql
--
-- createdb -U postgres ai_database_book_restore
-- pg_restore -U postgres -d ai_database_book_restore --exit-on-error ai_database_book.backup

-- 14. 복구 후 검증 SQL 예시
SELECT COUNT(*) AS restored_students_expected_3
FROM public.security_students;

SELECT COUNT(*) AS restored_courses_expected_3
FROM public.security_courses;

SELECT COUNT(*) AS restored_enrollments_expected_3
FROM public.security_enrollments;

SELECT COUNT(*) AS restored_join_rows_expected_3
FROM public.security_enrollments AS e
JOIN public.security_students AS s
    ON e.student_id = s.id
JOIN public.security_courses AS c
    ON e.course_id = c.id;

-- 제약조건 확인
SELECT
    conname,
    contype
FROM pg_constraint
WHERE conrelid IN (
    'public.security_students'::regclass,
    'public.security_courses'::regclass,
    'public.security_enrollments'::regclass
)
ORDER BY conrelid::regclass::text, conname;

-- 시퀀스 존재 확인
SELECT
    sequence_schema,
    sequence_name
FROM information_schema.sequences
WHERE sequence_schema = 'public'
  AND sequence_name LIKE 'security_%_id_seq'
ORDER BY sequence_name;

-- 15. AI 명령 검토 체크리스트
-- 1. 대상 환경이 테스트 DB인가?
-- 2. 실제 비밀번호나 접속 URL이 포함되어 있지 않은가?
-- 3. GRANT 범위가 최소 권한인가?
-- 4. REVOKE 후 유효 권한을 확인하는가?
-- 5. 백업 파일 보호와 복구 검증 절차가 있는가?
-- 6. 복구 명령에 오류 중단 옵션이 있는가?
