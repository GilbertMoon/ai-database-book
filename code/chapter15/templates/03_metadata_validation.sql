-- Chapter 15. tutor_project 실제 메타데이터 검증
-- 실행 전 01_schema.sql과 02_seed.sql을 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_database();

-- 1. 테이블 목록: 기대 6개
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'tutor_project'
ORDER BY table_name;

-- 2. 컬럼·타입·NULL·IDENTITY
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    is_identity,
    identity_generation,
    column_default
FROM information_schema.columns
WHERE table_schema = 'tutor_project'
ORDER BY table_name, ordinal_position;

-- 3. 제약조건 실제 정의
SELECT
    conrelid::regclass::text AS table_name,
    conname AS constraint_name,
    CASE contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
        ELSE contype::text
    END AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE connamespace = 'tutor_project'::regnamespace
ORDER BY conrelid::regclass::text, contype, conname;

-- 4. 외래키 5개와 삭제 규칙
SELECT
    tc.table_name AS source_table,
    kcu.column_name AS source_column,
    ccu.table_name AS target_table,
    ccu.column_name AS target_column,
    rc.delete_rule,
    rc.update_rule,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON kcu.constraint_schema = tc.constraint_schema
   AND kcu.constraint_name = tc.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_schema = tc.constraint_schema
   AND ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
    ON rc.constraint_schema = tc.constraint_schema
   AND rc.constraint_name = tc.constraint_name
WHERE tc.constraint_schema = 'tutor_project'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY source_table, source_column;

-- 5. 인덱스 정의
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'tutor_project'
ORDER BY tablename, indexname;

-- 6. 민감정보 형태 컬럼: 기대 0행
SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'tutor_project'
  AND lower(column_name) SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
ORDER BY table_name, column_name;

-- 7. CASCADE FK: 기대 0행
SELECT
    tc.table_name,
    tc.constraint_name,
    rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.referential_constraints AS rc
    ON rc.constraint_schema = tc.constraint_schema
   AND rc.constraint_name = tc.constraint_name
WHERE tc.constraint_schema = 'tutor_project'
  AND tc.constraint_type = 'FOREIGN KEY'
  AND rc.delete_rule = 'CASCADE';

-- 8. 기대 수치
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
    ) AS foreign_keys_expected_5,
    (
        SELECT COUNT(*)
        FROM information_schema.columns
        WHERE table_schema = 'tutor_project'
          AND column_name = 'id'
          AND is_identity = 'YES'
    ) AS identity_keys_expected_5,
    (
        SELECT COUNT(*)
        FROM pg_indexes
        WHERE schemaname = 'tutor_project'
          AND indexname IN (
              'idx_tutor_project_questions_student_status_created',
              'idx_tutor_project_answers_question_created',
              'idx_tutor_project_qm_material'
          )
    ) AS business_indexes_expected_3;

-- 9. 최종 boolean
SELECT
    (
        SELECT COUNT(*) = 6
        FROM information_schema.tables
        WHERE table_schema = 'tutor_project'
    ) AS table_count_ok,
    (
        SELECT COUNT(*) = 5
        FROM information_schema.table_constraints
        WHERE constraint_schema = 'tutor_project'
          AND constraint_type = 'FOREIGN KEY'
    ) AS foreign_key_count_ok,
    (
        SELECT COUNT(*) = 5
        FROM information_schema.columns
        WHERE table_schema = 'tutor_project'
          AND column_name = 'id'
          AND is_identity = 'YES'
    ) AS identity_count_ok,
    NOT EXISTS (
        SELECT 1
        FROM information_schema.referential_constraints
        WHERE constraint_schema = 'tutor_project'
          AND delete_rule = 'CASCADE'
    ) AS cascade_absent,
    NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'tutor_project'
          AND lower(column_name) SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
    ) AS sensitive_columns_absent;

-- 모든 결과가 true여야 합니다.
