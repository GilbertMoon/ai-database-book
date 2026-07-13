-- Chapter 13. 실제 PostgreSQL 메타데이터 검증
-- 실행 전 01→04 파일을 순서대로 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_database();

-- 1. Chapter 13 테이블 목록: 기대 6개
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'ai_review_lab'
ORDER BY table_name;

-- 2. 좋은 설계 컬럼·타입·NULL·IDENTITY
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
WHERE table_schema = 'ai_review_lab'
  AND table_name IN (
      'students',
      'instructors',
      'courses',
      'enrollments',
      'payments'
  )
ORDER BY table_name, ordinal_position;

-- 3. 제약조건과 PostgreSQL 실제 정의
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
WHERE connamespace = 'ai_review_lab'::regnamespace
ORDER BY conrelid::regclass::text, contype, conname;

-- 4. 외래키 관계: 기대 4개
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
WHERE tc.constraint_schema = 'ai_review_lab'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY source_table, source_column;

-- 5. 자동·수동 인덱스 정의
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ai_review_lab'
ORDER BY tablename, indexname;

-- 6. 좋은 설계에 민감정보 형태 컬럼이 있는지 확인: 기대 0행
SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'ai_review_lab'
  AND table_name IN (
      'students',
      'instructors',
      'courses',
      'enrollments',
      'payments'
  )
  AND lower(column_name) SIMILAR TO '%(card|password|secret|token)%'
ORDER BY table_name, column_name;

-- 7. 미확정 재신청 정책이 복합 UNIQUE로 고정되었는지 확인: 기대 0행
SELECT
    conrelid::regclass::text AS table_name,
    conname,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE connamespace = 'ai_review_lab'::regnamespace
  AND contype = 'u'
  AND conrelid = 'ai_review_lab.enrollments'::regclass
  AND pg_get_constraintdef(oid) LIKE '%student_id%course_id%';

-- 8. 기본 기대 수치 요약
SELECT
    (
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'ai_review_lab'
    ) AS total_tables_expected_6,
    (
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'ai_review_lab'
          AND table_name IN (
              'students',
              'instructors',
              'courses',
              'enrollments',
              'payments'
          )
    ) AS good_tables_expected_5,
    (
        SELECT COUNT(*)
        FROM information_schema.table_constraints
        WHERE constraint_schema = 'ai_review_lab'
          AND constraint_type = 'FOREIGN KEY'
    ) AS foreign_keys_expected_4,
    (
        SELECT COUNT(*)
        FROM information_schema.columns
        WHERE table_schema = 'ai_review_lab'
          AND table_name IN (
              'students',
              'instructors',
              'courses',
              'enrollments',
              'payments'
          )
          AND column_name = 'id'
          AND is_identity = 'YES'
    ) AS identity_primary_keys_expected_5;

-- 기대 결과: 6 / 5 / 4 / 5

-- 9. 최종 boolean 요약
SELECT
    (
        SELECT COUNT(*) = 6
        FROM information_schema.tables
        WHERE table_schema = 'ai_review_lab'
    ) AS table_count_ok,
    (
        SELECT COUNT(*) = 4
        FROM information_schema.table_constraints
        WHERE constraint_schema = 'ai_review_lab'
          AND constraint_type = 'FOREIGN KEY'
    ) AS foreign_key_count_ok,
    NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'ai_review_lab'
          AND table_name IN (
              'students',
              'instructors',
              'courses',
              'enrollments',
              'payments'
          )
          AND lower(column_name) SIMILAR TO '%(card|password|secret|token)%'
    ) AS sensitive_column_absent,
    NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE connamespace = 'ai_review_lab'::regnamespace
          AND contype = 'u'
          AND conrelid = 'ai_review_lab.enrollments'::regclass
          AND pg_get_constraintdef(oid) LIKE '%student_id%course_id%'
    ) AS reenrollment_policy_not_forced;

-- 모든 결과가 true여야 합니다.
