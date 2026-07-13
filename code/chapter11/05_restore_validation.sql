-- Chapter 11. 별도 복원 DB 검증
-- 이 파일은 원본 DB가 아니라 ai_database_book_restore 같은 복원 확인 DB에서 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name,
    current_setting('server_version') AS postgresql_version;

-- 1. security_lab 스키마와 테이블 존재 확인
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'security_lab'
ORDER BY table_name;

-- 기대: courses, enrollments, students

-- 2. 행 수 확인
SELECT COUNT(*) AS student_count
FROM security_lab.students;

SELECT COUNT(*) AS course_count
FROM security_lab.courses;

SELECT COUNT(*) AS enrollment_count
FROM security_lab.enrollments;

SELECT COUNT(*) AS joined_row_count
FROM security_lab.enrollments AS e
JOIN security_lab.students AS s
    ON s.id = e.student_id
JOIN security_lab.courses AS c
    ON c.id = e.course_id;

-- 기대: 3 / 3 / 3 / 3

-- 3. 복원 데이터 상세 확인
SELECT
    e.id AS enrollment_id,
    s.id AS student_id,
    s.name AS student_name,
    c.id AS course_id,
    c.title AS course_title,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM security_lab.enrollments AS e
JOIN security_lab.students AS s
    ON s.id = e.student_id
JOIN security_lab.courses AS c
    ON c.id = e.course_id
ORDER BY e.id;

-- 4. 고아 관계 확인: 모두 0행이어야 합니다.
SELECT e.*
FROM security_lab.enrollments AS e
LEFT JOIN security_lab.students AS s
    ON s.id = e.student_id
WHERE s.id IS NULL;

SELECT e.*
FROM security_lab.enrollments AS e
LEFT JOIN security_lab.courses AS c
    ON c.id = e.course_id
WHERE c.id IS NULL;

-- 5. 컬럼 타입·NULL 허용·IDENTITY 확인
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    is_identity,
    identity_generation,
    column_default
FROM information_schema.columns
WHERE table_schema = 'security_lab'
ORDER BY table_name, ordinal_position;

-- 6. PK·FK·UNIQUE·CHECK 제약조건 확인
SELECT
    conrelid::regclass::text AS table_name,
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE connamespace = 'security_lab'::regnamespace
ORDER BY conrelid::regclass::text, contype, conname;

-- 기대 제약조건 유형:
-- p = PRIMARY KEY
-- f = FOREIGN KEY
-- u = UNIQUE
-- c = CHECK

-- 7. IDENTITY 시퀀스 존재 확인
SELECT
    sequence_schema,
    sequence_name,
    data_type,
    start_value,
    increment
FROM information_schema.sequences
WHERE sequence_schema = 'security_lab'
ORDER BY sequence_name;

-- 기대:
-- students_id_seq
-- courses_id_seq
-- enrollments_id_seq

-- 8. 테이블과 시퀀스 소유자 확인
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

-- 9. 복원된 명시적 테이블·컬럼 권한 확인
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

-- --no-owner --no-privileges로 복원했다면 원본 owner·ACL이 없는 것이 정상입니다.
-- 역할·권한 계획을 별도로 적용한 뒤 04_permission_checks.sql을 다시 실행합니다.

-- 10. 값·관계 규칙 위반 행 확인: 모두 0행이어야 합니다.
SELECT *
FROM security_lab.students
WHERE char_length(trim(name)) = 0;

SELECT *
FROM security_lab.courses
WHERE char_length(trim(title)) = 0
   OR level NOT IN ('basic', 'intermediate', 'advanced')
   OR price < 0;

SELECT *
FROM security_lab.enrollments
WHERE status NOT IN ('신청', '수강중', '완료', '취소')
   OR paid_amount < 0;

-- 11. 최종 통과 기준 요약
SELECT
    (SELECT COUNT(*) FROM security_lab.students) = 3
        AS students_ok,
    (SELECT COUNT(*) FROM security_lab.courses) = 3
        AS courses_ok,
    (SELECT COUNT(*) FROM security_lab.enrollments) = 3
        AS enrollments_ok,
    (
        SELECT COUNT(*)
        FROM security_lab.enrollments AS e
        JOIN security_lab.students AS s ON s.id = e.student_id
        JOIN security_lab.courses AS c ON c.id = e.course_id
    ) = 3 AS relationships_ok;

-- 모든 결과가 true여야 합니다.
