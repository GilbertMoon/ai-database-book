-- Chapter 11. 역할·권한 계획
-- 주의: Role은 클러스터 전역 객체입니다.
-- 관리자 권한이 있는 테스트 환경에서만 필요한 문장을 한 줄씩 선택 실행합니다.
-- 실제 비밀번호는 이 파일이나 저장소에 기록하지 않습니다.

SELECT
    current_user,
    current_database();

-- 1. 실습 역할 이름 충돌 확인
SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole
FROM pg_roles
WHERE rolname IN (
    'lab_role_security_owner',
    'lab_role_report_reader',
    'lab_role_enrollment_app',
    'lab_readonly_user',
    'lab_enrollment_user'
)
ORDER BY rolname;

-- 2. 권한 역할과 로그인 역할 생성
-- 기존 역할이 없는지 확인한 뒤 필요한 문장만 실행합니다.

-- CREATE ROLE lab_role_security_owner NOLOGIN;
-- CREATE ROLE lab_role_report_reader NOLOGIN;
-- CREATE ROLE lab_role_enrollment_app NOLOGIN;
-- CREATE ROLE lab_readonly_user LOGIN;
-- CREATE ROLE lab_enrollment_user LOGIN;

-- 실제 인증 정보는 별도 비밀 관리 절차에서 설정합니다.
-- 예제에 PASSWORD '...'를 작성하지 않습니다.

-- 3. 역할 멤버십
-- GRANT lab_role_report_reader TO lab_readonly_user;
-- GRANT lab_role_enrollment_app TO lab_enrollment_user;

-- 4. 데이터베이스 접속 권한
-- 실제 DB 이름이 ai_database_book인지 먼저 확인합니다.
-- GRANT CONNECT ON DATABASE ai_database_book
-- TO lab_role_report_reader, lab_role_enrollment_app;

-- 5. security_lab 스키마 사용 권한
-- GRANT USAGE ON SCHEMA security_lab
-- TO lab_role_report_reader, lab_role_enrollment_app;

-- 스키마 CREATE는 앱·보고 역할에 부여하지 않습니다.

-- 6. 보고 역할: 세 테이블 읽기만 허용
-- GRANT SELECT ON TABLE
--     security_lab.students,
--     security_lab.courses,
--     security_lab.enrollments
-- TO lab_role_report_reader;

-- 7. 수강신청 앱 역할
-- 학생·강의·신청 조회
-- GRANT SELECT ON TABLE
--     security_lab.students,
--     security_lab.courses,
--     security_lab.enrollments
-- TO lab_role_enrollment_app;

-- 신청 생성
-- GRANT INSERT ON TABLE security_lab.enrollments
-- TO lab_role_enrollment_app;

-- 신청 상태 컬럼만 변경
-- GRANT UPDATE (status) ON TABLE security_lab.enrollments
-- TO lab_role_enrollment_app;

-- IDENTITY 기본값 사용에 필요한 시퀀스 권한
-- GRANT USAGE, SELECT
-- ON SEQUENCE security_lab.enrollments_id_seq
-- TO lab_role_enrollment_app;

-- DELETE, TRUNCATE, 전체 UPDATE, 스키마 CREATE는 부여하지 않습니다.

-- 8. 명시적 권한 회수 예시
-- 변경 전 다른 역할과 애플리케이션 의존성을 먼저 확인합니다.

-- REVOKE INSERT, UPDATE, DELETE
-- ON TABLE security_lab.students
-- FROM lab_role_enrollment_app;

-- REVOKE DELETE, TRUNCATE
-- ON TABLE security_lab.enrollments
-- FROM lab_role_enrollment_app;

-- 9. 미래 객체 Default Privileges 예시
-- FOR ROLE은 실제로 미래 객체를 생성할 소유 역할이어야 합니다.
-- 기존 객체 권한은 이 명령으로 바뀌지 않습니다.

-- ALTER DEFAULT PRIVILEGES
-- FOR ROLE lab_role_security_owner
-- IN SCHEMA security_lab
-- GRANT SELECT ON TABLES
-- TO lab_role_report_reader;

-- ALTER DEFAULT PRIVILEGES
-- FOR ROLE lab_role_security_owner
-- IN SCHEMA security_lab
-- GRANT SELECT ON TABLES
-- TO lab_role_enrollment_app;

-- 10. 선택적 소유권 분리 예시
-- 소유 역할 생성과 실행 권한을 검토한 뒤 테스트 환경에서만 실행합니다.

-- ALTER SCHEMA security_lab OWNER TO lab_role_security_owner;
-- ALTER TABLE security_lab.students OWNER TO lab_role_security_owner;
-- ALTER TABLE security_lab.courses OWNER TO lab_role_security_owner;
-- ALTER TABLE security_lab.enrollments OWNER TO lab_role_security_owner;
-- ALTER SEQUENCE security_lab.students_id_seq OWNER TO lab_role_security_owner;
-- ALTER SEQUENCE security_lab.courses_id_seq OWNER TO lab_role_security_owner;
-- ALTER SEQUENCE security_lab.enrollments_id_seq OWNER TO lab_role_security_owner;

-- 11. 역할 정리 예시
-- 역할은 다른 DB와 객체에서 사용 중일 수 있으므로 자동 실행하지 않습니다.
-- 권한·소유 객체·멤버십을 모두 조사한 뒤 역순으로 정리합니다.

-- REVOKE lab_role_report_reader FROM lab_readonly_user;
-- REVOKE lab_role_enrollment_app FROM lab_enrollment_user;
-- DROP ROLE lab_readonly_user;
-- DROP ROLE lab_enrollment_user;
-- DROP ROLE lab_role_report_reader;
-- DROP ROLE lab_role_enrollment_app;
-- DROP ROLE lab_role_security_owner;
