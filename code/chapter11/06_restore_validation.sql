-- Chapter 11. 별도 복원 DB 검증
-- 원본 ai_database_book이 아니라 ai_database_book_restore에서만 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_user AS current_user_name;
SELECT current_database();
SELECT current_schema();
SHOW search_path;
SELECT current_setting('server_version') AS postgresql_version;

-- ============================================================
-- 0. 잘못된 데이터베이스와 불완전한 복원 차단
-- ============================================================
DO $$
BEGIN
    IF current_database() <> 'ai_database_book_restore' THEN
        RAISE EXCEPTION
            '검증 중단: 현재 데이터베이스는 %입니다. ai_database_book_restore에서 실행하세요.',
            current_database();
    END IF;

    IF to_regclass('security_lab.students') IS NULL
       OR to_regclass('security_lab.courses') IS NULL
       OR to_regclass('security_lab.enrollments') IS NULL THEN
        RAISE EXCEPTION
            '검증 중단: 복원된 security_lab 핵심 테이블이 없습니다.';
    END IF;
END
$$;

-- ============================================================
-- 1. 스키마·테이블과 행 수
-- ============================================================
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'security_lab'
ORDER BY table_name;

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

-- ============================================================
-- 2. 복원 데이터 상세
-- ============================================================
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

-- ============================================================
-- 3. 고아 관계와 활성 신청 중복
-- 모두 0행이어야 합니다.
-- ============================================================
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

SELECT
    student_id,
    course_id,
    COUNT(*) AS active_count
FROM security_lab.enrollments
WHERE status IN ('신청', '수강중')
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 4. 컬럼 타입·NULL·IDENTITY
-- ============================================================
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

-- ============================================================
-- 5. PK·FK·UNIQUE·CHECK와 부분 고유 인덱스
-- ============================================================
SELECT
    conrelid::regclass::text AS table_name,
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE connamespace = 'security_lab'::regnamespace
ORDER BY conrelid::regclass::text, contype, conname;

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'security_lab'
ORDER BY tablename, indexname;

-- ============================================================
-- 6. IDENTITY 시퀀스와 다음 자동값
-- 권한 동작 테스트를 백업 전에 실행했다면 번호 공백이 있을 수 있습니다.
-- 다음 값이 현재 최대 ID보다 크면 정상입니다.
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
    'students' AS table_name,
    last_value,
    is_called,
    CASE WHEN is_called THEN last_value + 1 ELSE last_value END AS next_value,
    (SELECT MAX(id) FROM security_lab.students) AS max_id
FROM security_lab.students_id_seq
UNION ALL
SELECT
    'courses',
    last_value,
    is_called,
    CASE WHEN is_called THEN last_value + 1 ELSE last_value END,
    (SELECT MAX(id) FROM security_lab.courses)
FROM security_lab.courses_id_seq
UNION ALL
SELECT
    'enrollments',
    last_value,
    is_called,
    CASE WHEN is_called THEN last_value + 1 ELSE last_value END,
    (SELECT MAX(id) FROM security_lab.enrollments)
FROM security_lab.enrollments_id_seq;

-- ============================================================
-- 7. --no-owner 복원 직후 소유권
-- 복원 역할이 schema·table·sequence의 owner여야 합니다.
-- ============================================================
SELECT
    n.nspname AS schema_name,
    pg_get_userbyid(n.nspowner) AS owner_name,
    n.nspacl
FROM pg_namespace AS n
WHERE n.nspname = 'security_lab';

SELECT
    n.nspname AS schema_name,
    c.relname AS object_name,
    c.relkind,
    pg_get_userbyid(c.relowner) AS owner_name,
    c.relacl
FROM pg_class AS c
JOIN pg_namespace AS n
    ON n.oid = c.relnamespace
WHERE n.nspname = 'security_lab'
  AND c.relkind IN ('r', 'S')
ORDER BY c.relkind, c.relname;

-- --no-privileges를 사용했다면 원본 ACL은 복원되지 않습니다.
-- 복원 역할의 Default Privileges가 별도로 적용될 수 있으므로 실제 ACL을 조회합니다.

-- ============================================================
-- 8. 값 규칙 위반 행
-- 모두 0행이어야 합니다.
-- ============================================================
SELECT *
FROM security_lab.students
WHERE char_length(trim(name)) = 0
   OR char_length(trim(email)) = 0;

SELECT *
FROM security_lab.courses
WHERE char_length(trim(title)) = 0
   OR level NOT IN ('basic', 'intermediate', 'advanced')
   OR price < 0;

SELECT *
FROM security_lab.enrollments
WHERE status NOT IN ('신청', '수강중', '완료', '취소')
   OR paid_amount < 0;

-- ============================================================
-- 9. 전체 자동 판정
-- ============================================================
DO $$
DECLARE
    orphan_student_count BIGINT;
    orphan_course_count BIGINT;
    duplicate_active_count BIGINT;
    expected_constraint_count INTEGER;
    expected_sequence_count INTEGER;
    expected_owner_count INTEGER;
    students_next BIGINT;
    courses_next BIGINT;
    enrollments_next BIGINT;
BEGIN
    IF (SELECT COUNT(*) FROM security_lab.students) <> 3
       OR (SELECT COUNT(*) FROM security_lab.courses) <> 3
       OR (SELECT COUNT(*) FROM security_lab.enrollments) <> 3 THEN
        RAISE EXCEPTION '복원 검증 실패: 기준 행 수가 일치하지 않습니다.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM security_lab.enrollments AS e
        JOIN security_lab.students AS s ON s.id = e.student_id
        JOIN security_lab.courses AS c ON c.id = e.course_id
    ) <> 3 THEN
        RAISE EXCEPTION '복원 검증 실패: JOIN 결과는 3행이어야 합니다.';
    END IF;

    SELECT COUNT(*) INTO orphan_student_count
    FROM security_lab.enrollments AS e
    LEFT JOIN security_lab.students AS s ON s.id = e.student_id
    WHERE s.id IS NULL;

    SELECT COUNT(*) INTO orphan_course_count
    FROM security_lab.enrollments AS e
    LEFT JOIN security_lab.courses AS c ON c.id = e.course_id
    WHERE c.id IS NULL;

    SELECT COUNT(*) INTO duplicate_active_count
    FROM (
        SELECT student_id, course_id
        FROM security_lab.enrollments
        WHERE status IN ('신청', '수강중')
        GROUP BY student_id, course_id
        HAVING COUNT(*) > 1
    ) AS duplicated_active_pairs;

    IF orphan_student_count <> 0
       OR orphan_course_count <> 0
       OR duplicate_active_count <> 0 THEN
        RAISE EXCEPTION
            '복원 검증 실패: 고아 student %, 고아 course %, 활성 중복 %.',
            orphan_student_count,
            orphan_course_count,
            duplicate_active_count;
    END IF;

    SELECT COUNT(*) INTO expected_constraint_count
    FROM pg_constraint
    WHERE connamespace = 'security_lab'::regnamespace
      AND conname IN (
          'students_pkey',
          'uq_security_students_email',
          'chk_security_students_name_not_blank',
          'chk_security_students_email_not_blank',
          'courses_pkey',
          'chk_security_courses_title_not_blank',
          'chk_security_courses_level',
          'chk_security_courses_price',
          'enrollments_pkey',
          'fk_security_enrollments_student',
          'fk_security_enrollments_course',
          'chk_security_enrollments_status',
          'chk_security_enrollments_amount'
      );

    IF expected_constraint_count <> 13
       OR to_regclass('security_lab.uq_security_enrollments_active') IS NULL THEN
        RAISE EXCEPTION
            '복원 검증 실패: 제약조건 또는 활성 신청 인덱스가 누락되었습니다.';
    END IF;

    SELECT COUNT(*) INTO expected_sequence_count
    FROM information_schema.sequences
    WHERE sequence_schema = 'security_lab'
      AND sequence_name IN (
          'students_id_seq',
          'courses_id_seq',
          'enrollments_id_seq'
      );

    IF expected_sequence_count <> 3 THEN
        RAISE EXCEPTION
            '복원 검증 실패: IDENTITY 시퀀스는 3개여야 합니다.';
    END IF;

    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO students_next
    FROM security_lab.students_id_seq;

    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO courses_next
    FROM security_lab.courses_id_seq;

    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO enrollments_next
    FROM security_lab.enrollments_id_seq;

    IF students_next <= (SELECT MAX(id) FROM security_lab.students)
       OR courses_next <= (SELECT MAX(id) FROM security_lab.courses)
       OR enrollments_next <= (SELECT MAX(id) FROM security_lab.enrollments) THEN
        RAISE EXCEPTION
            '복원 검증 실패: IDENTITY 다음 값이 기존 최대 ID보다 크지 않습니다.';
    END IF;

    SELECT COUNT(*) INTO expected_owner_count
    FROM pg_class AS c
    JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'security_lab'
      AND c.relkind IN ('r', 'S')
      AND pg_get_userbyid(c.relowner) = current_user;

    IF expected_owner_count <> 6
       OR (
            SELECT pg_get_userbyid(nspowner)
            FROM pg_namespace
            WHERE nspname = 'security_lab'
          ) <> current_user THEN
        RAISE EXCEPTION
            '복원 검증 실패: --no-owner 복원 객체 소유자가 현재 복원 역할과 다릅니다.';
    END IF;

    RAISE NOTICE 'Chapter 11 restore structure and data validation passed';
END
$$;

-- 1단계 통과 뒤 복원 DB에 역할·GRANT를 재적용할 경우
-- 04_permission_checks.sql과 05_permission_behavior_tests.sql로 2단계 권한을 검증합니다.
