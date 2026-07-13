-- Chapter 12. PostgreSQL JSONB 문서형 데이터 실습
-- 실행 전 01, 02 파일을 실행합니다.
-- 기준 데이터 수정 예제는 ROLLBACK으로 원상 복구합니다.

SELECT current_database();

-- 1. 안정된 일반 컬럼과 JSONB 필드 함께 조회
SELECT
    course_code,
    title,
    metadata ->> 'level' AS level,
    metadata -> 'options' ->> 'online' AS online,
    document_version
FROM nosql_lab.course_documents
ORDER BY CASE course_code
    WHEN 'DB-101' THEN 1
    WHEN 'AI-201' THEN 2
    WHEN 'GRAPH-301' THEN 3
    ELSE 99
END;

-- 기대 결과:
-- DB-101 / 데이터베이스 입문 / basic / true / 1
-- AI-201 / AI 데이터 분석 / intermediate / true / 1
-- GRAPH-301 / 그래프 데이터 이해 / advanced / false / 1

-- 2. 최상위 키 존재 여부
SELECT
    course_code,
    title
FROM nosql_lab.course_documents
WHERE metadata ? 'instructor'
ORDER BY course_code;

-- 3. JSONB 포함 조건
SELECT
    course_code,
    title
FROM nosql_lab.course_documents
WHERE metadata @> '{"tags": ["PostgreSQL"]}'::jsonb;

-- 4. 특정 JSON 경로 값 조건
SELECT
    course_code,
    title
FROM nosql_lab.course_documents
WHERE metadata ->> 'level' = 'basic';

-- 5. 문서 구조 검증
SELECT
    course_code,
    jsonb_typeof(metadata) = 'object' AS metadata_is_object,
    metadata ? 'level' AS has_level,
    metadata ->> 'level' IN ('basic', 'intermediate', 'advanced')
        AS level_is_allowed,
    jsonb_typeof(metadata -> 'tags') = 'array' AS tags_is_array,
    jsonb_typeof(metadata #> '{options,online}') = 'boolean'
        AS online_is_boolean,
    document_version >= 1 AS version_is_valid
FROM nosql_lab.course_documents
ORDER BY course_code;

-- 모든 boolean 결과가 true여야 합니다.

-- 6. 트랜잭션 안에서 문서 변경 후 원복
SELECT
    course_code,
    metadata #>> '{options,certificate}' AS certificate,
    document_version
FROM nosql_lab.course_documents
WHERE course_code = 'DB-101';

BEGIN;

UPDATE nosql_lab.course_documents
SET
    metadata = jsonb_set(
        metadata,
        '{options,certificate}',
        'false'::jsonb
    ),
    document_version = document_version + 1,
    updated_at = CURRENT_TIMESTAMP
WHERE course_code = 'DB-101';

SELECT
    course_code,
    metadata #>> '{options,certificate}' AS certificate,
    document_version
FROM nosql_lab.course_documents
WHERE course_code = 'DB-101';

-- 변경 결과를 확인한 뒤 기준 데이터를 유지하기 위해 취소합니다.
ROLLBACK;

SELECT
    course_code,
    metadata #>> '{options,certificate}' AS certificate,
    document_version
FROM nosql_lab.course_documents
WHERE course_code = 'DB-101';

-- 기대: true / 1 → false / 2 → true / 1

-- 7. 질의 형태별 JSONB 인덱스 후보
CREATE INDEX IF NOT EXISTS idx_nosql_course_documents_metadata_gin
ON nosql_lab.course_documents
USING GIN (metadata);

CREATE INDEX IF NOT EXISTS idx_nosql_course_documents_level
ON nosql_lab.course_documents ((metadata ->> 'level'));

ANALYZE nosql_lab.course_documents;

-- 8. 포함 검색 실행 계획
EXPLAIN
SELECT course_code, title
FROM nosql_lab.course_documents
WHERE metadata @> '{"tags": ["PostgreSQL"]}'::jsonb;

-- 9. 특정 경로 텍스트 조건 실행 계획
EXPLAIN
SELECT course_code, title
FROM nosql_lab.course_documents
WHERE metadata ->> 'level' = 'basic';

-- 표본이 3행뿐이므로 인덱스가 있어도 Seq Scan이 나올 수 있습니다.
