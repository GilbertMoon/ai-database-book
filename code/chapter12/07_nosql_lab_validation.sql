-- Chapter 12. nosql_lab 최종 자동 검증
-- 실행 전 01→06 파일을 순서대로 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_user AS current_user_name;
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 0. 실행 위치와 객체 존재 차단
-- ============================================================
DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '검증 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('course_project.students') IS NULL
       OR to_regclass('course_project.instructors') IS NULL
       OR to_regclass('course_project.courses') IS NULL
       OR to_regclass('course_project.enrollments') IS NULL
       OR to_regclass('nosql_lab.course_documents') IS NULL
       OR to_regclass('nosql_lab.key_value_cache_examples') IS NULL
       OR to_regclass('nosql_lab.storage_choice_cases') IS NULL THEN
        RAISE EXCEPTION
            '검증 중단: Chapter 07 또는 Chapter 12 핵심 객체가 없습니다.';
    END IF;
END
$$;

-- ============================================================
-- 1. 사람이 읽는 기준 결과
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM course_project.students) AS source_students,
    (SELECT COUNT(*) FROM course_project.instructors) AS source_instructors,
    (SELECT COUNT(*) FROM course_project.courses) AS source_courses,
    (SELECT COUNT(*) FROM course_project.enrollments) AS source_enrollments,
    (SELECT COUNT(*) FROM nosql_lab.course_documents) AS course_documents,
    (SELECT COUNT(*) FROM nosql_lab.key_value_cache_examples) AS cache_examples,
    (SELECT COUNT(*) FROM nosql_lab.storage_choice_cases) AS storage_choices;

SELECT
    COUNT(*) AS total_cache_rows,
    COUNT(*) FILTER (
        WHERE expired_at IS NULL OR expired_at > created_at
    ) AS valid_at_seed_rows,
    COUNT(*) FILTER (
        WHERE expired_at IS NOT NULL AND expired_at <= created_at
    ) AS expired_at_seed_rows,
    COUNT(*) FILTER (
        WHERE expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP
    ) AS currently_valid_rows
FROM nosql_lab.key_value_cache_examples;

SELECT
    source_course_id,
    course_code,
    title,
    level,
    metadata #>> '{instructor_snapshot,source_instructor_id}'
        AS snapshot_instructor_id,
    metadata #>> '{options,online}' AS online,
    document_version
FROM nosql_lab.course_documents
ORDER BY source_course_id;

SELECT
    case_name,
    system_role,
    candidate_storage,
    decision_status
FROM nosql_lab.storage_choice_cases
ORDER BY id;

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'nosql_lab'
  AND indexname IN (
      'idx_nosql_course_documents_metadata_gin',
      'idx_nosql_course_documents_online'
  )
ORDER BY indexname;

-- ============================================================
-- 2. 전체 자동 판정
-- ============================================================
DO $$
DECLARE
    source_mismatch_count BIGINT;
    instructor_snapshot_mismatch_count BIGINT;
    invalid_document_count BIGINT;
    blank_decision_count BIGINT;
    popular_cache_mismatch_count BIGINT;
    metadata_index_definition TEXT;
    online_index_definition TEXT;
BEGIN
    -- Chapter 07 기준 상태
    IF (SELECT COUNT(*) FROM course_project.students) <> 3
       OR (SELECT COUNT(*) FROM course_project.instructors) <> 2
       OR (SELECT COUNT(*) FROM course_project.courses) <> 3
       OR (SELECT COUNT(*) FROM course_project.enrollments) <> 5 THEN
        RAISE EXCEPTION
            '검증 실패: Chapter 07 기준 상태는 3/2/3/5여야 합니다.';
    END IF;

    -- Chapter 12 기준 행 수
    IF (SELECT COUNT(*) FROM nosql_lab.course_documents) <> 3
       OR (SELECT COUNT(*) FROM nosql_lab.key_value_cache_examples) <> 4
       OR (SELECT COUNT(*) FROM nosql_lab.storage_choice_cases) <> 6 THEN
        RAISE EXCEPTION
            '검증 실패: Chapter 12 기준 행 수는 3/4/6이어야 합니다.';
    END IF;

    -- 원본 강의 301~303과 안정된 문서 컬럼 대조
    SELECT COUNT(*)
    INTO source_mismatch_count
    FROM nosql_lab.course_documents AS d
    FULL JOIN course_project.courses AS c
        ON c.id = d.source_course_id
       AND c.id IN (301, 302, 303)
    WHERE d.source_course_id IS NULL
       OR c.id IS NULL
       OR d.course_code <> 'COURSE-' || c.id
       OR d.title <> c.title
       OR d.level <> c.level;

    IF source_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: Chapter 07 원본과 불일치하는 강의 문서가 %건 있습니다.',
            source_mismatch_count;
    END IF;

    -- 강사 스냅샷의 원본 ID·이름·전문분야 대조
    SELECT COUNT(*)
    INTO instructor_snapshot_mismatch_count
    FROM nosql_lab.course_documents AS d
    JOIN course_project.courses AS c
        ON c.id = d.source_course_id
    JOIN course_project.instructors AS i
        ON i.id = c.instructor_id
    WHERE (d.metadata #>> '{instructor_snapshot,source_instructor_id}')::INTEGER <> i.id
       OR d.metadata #>> '{instructor_snapshot,name}' <> i.name
       OR d.metadata #>> '{instructor_snapshot,specialty}' <> i.specialty;

    IF instructor_snapshot_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 원본과 다른 instructor_snapshot이 %건 있습니다.',
            instructor_snapshot_mismatch_count;
    END IF;

    -- JSONB 핵심 구조
    SELECT COUNT(*)
    INTO invalid_document_count
    FROM nosql_lab.course_documents
    WHERE jsonb_typeof(metadata) <> 'object'
       OR jsonb_typeof(metadata -> 'tags') <> 'array'
       OR jsonb_typeof(metadata -> 'options') <> 'object'
       OR jsonb_typeof(metadata #> '{options,online}') <> 'boolean'
       OR jsonb_typeof(metadata #> '{options,certificate}') <> 'boolean'
       OR jsonb_typeof(metadata -> 'instructor_snapshot') <> 'object'
       OR document_version < 1
       OR updated_at < created_at;

    IF invalid_document_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: JSONB 구조·버전·시각 규칙 위반 문서가 %건 있습니다.',
            invalid_document_count;
    END IF;

    -- 03 파일의 ROLLBACK 후 기준값
    IF NOT EXISTS (
        SELECT 1
        FROM nosql_lab.course_documents
        WHERE course_code = 'COURSE-301'
          AND metadata #>> '{options,certificate}' = 'true'
          AND document_version = 1
    ) THEN
        RAISE EXCEPTION
            '검증 실패: COURSE-301 문서가 certificate=true, version=1 기준으로 복구되지 않았습니다.';
    END IF;

    -- 재현 가능한 Seed 기준 캐시 4/3/1
    IF (
        SELECT COUNT(*)
        FROM nosql_lab.key_value_cache_examples
    ) <> 4
       OR (
        SELECT COUNT(*)
        FROM nosql_lab.key_value_cache_examples
        WHERE expired_at IS NULL OR expired_at > created_at
    ) <> 3
       OR (
        SELECT COUNT(*)
        FROM nosql_lab.key_value_cache_examples
        WHERE expired_at IS NOT NULL AND expired_at <= created_at
    ) <> 1 THEN
        RAISE EXCEPTION
            '검증 실패: Seed 기준 캐시는 전체 4, 유효 3, 만료 1이어야 합니다.';
    END IF;

    -- 인기 강의 캐시가 실제 원본 course ID를 사용해야 함
    SELECT COUNT(*)
    INTO popular_cache_mismatch_count
    FROM nosql_lab.key_value_cache_examples
    WHERE cache_key = 'course:popular:v1:top3'
      AND cache_value -> 'course_ids' <> '[301, 302, 303]'::jsonb;

    IF popular_cache_mismatch_count <> 0
       OR NOT EXISTS (
            SELECT 1
            FROM nosql_lab.key_value_cache_examples
            WHERE cache_key = 'course:popular:v1:top3'
       ) THEN
        RAISE EXCEPTION
            '검증 실패: 인기 강의 캐시의 원본 course_ids가 301~303이 아닙니다.';
    END IF;

    -- 선택 근거·역할·결정 상태
    SELECT COUNT(*)
    INTO blank_decision_count
    FROM nosql_lab.storage_choice_cases
    WHERE char_length(trim(primary_query)) = 0
       OR char_length(trim(candidate_storage)) = 0
       OR char_length(trim(source_of_truth)) = 0
       OR char_length(trim(consistency_requirement)) = 0
       OR char_length(trim(synchronization_strategy)) = 0
       OR char_length(trim(recovery_strategy)) = 0
       OR char_length(trim(poc_success_criteria)) = 0
       OR char_length(trim(reason)) = 0;

    IF blank_decision_count <> 0
       OR (SELECT COUNT(DISTINCT system_role) FROM nosql_lab.storage_choice_cases) <> 6
       OR (SELECT COUNT(*) FROM nosql_lab.storage_choice_cases WHERE system_role = 'source_of_truth') <> 1
       OR (SELECT COUNT(*) FROM nosql_lab.storage_choice_cases WHERE decision_status = 'adopted') <> 1 THEN
        RAISE EXCEPTION
            '검증 실패: 저장소 선택 근거·역할·결정 상태가 기대와 다릅니다.';
    END IF;

    -- 실험 인덱스 존재와 정의
    IF to_regclass('nosql_lab.idx_nosql_course_documents_metadata_gin') IS NULL
       OR to_regclass('nosql_lab.idx_nosql_course_documents_online') IS NULL THEN
        RAISE EXCEPTION
            '검증 실패: JSONB 실험 인덱스 2개가 모두 존재해야 합니다.';
    END IF;

    SELECT pg_get_indexdef(to_regclass('nosql_lab.idx_nosql_course_documents_metadata_gin'))
    INTO metadata_index_definition;

    SELECT pg_get_indexdef(to_regclass('nosql_lab.idx_nosql_course_documents_online'))
    INTO online_index_definition;

    IF lower(metadata_index_definition) NOT LIKE '%using gin%metadata%'
       OR online_index_definition NOT LIKE '%#>>%options%online%' THEN
        RAISE EXCEPTION
            '검증 실패: JSONB 인덱스 정의가 기대한 GIN·options.online 표현식과 다릅니다.';
    END IF;

    RAISE NOTICE 'Chapter 12 nosql_lab validation passed';
END
$$;
