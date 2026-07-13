-- Chapter 12. NoSQL 이해와 선택 기준
-- 목적: PostgreSQL JSONB로 문서형 데이터 개념을 맛보고,
--       Key-Value 캐시 개념과 저장 방식 선택 기준을 확인합니다.
-- 주의: 이 파일은 별도 NoSQL 서버를 설치하지 않습니다.
--       PostgreSQL JSONB는 실제 Document DB 자체가 아니라 문서형 데이터 실습을 위한 기능입니다.
--       key_value_cache_examples 테이블은 Key-Value DB 개념을 단순 시뮬레이션할 뿐입니다.

SELECT current_database() AS current_database;

DROP TABLE IF EXISTS storage_choice_cases;
DROP TABLE IF EXISTS key_value_cache_examples;
DROP TABLE IF EXISTS course_documents;

CREATE TABLE course_documents (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    metadata JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT course_documents_metadata_object_chk
        CHECK (jsonb_typeof(metadata) = 'object')
);

INSERT INTO course_documents (course_code, title, metadata) VALUES
(
    'DB-101',
    '데이터베이스 입문',
    '{
      "level": "basic",
      "tags": ["SQL", "PostgreSQL", "DB"],
      "instructor": {"name": "김강사", "specialty": "Database"},
      "options": {"online": true, "certificate": true}
    }'::jsonb
),
(
    'AI-201',
    'AI 데이터 분석',
    '{
      "level": "intermediate",
      "tags": ["AI", "Data Analysis", "Python"],
      "instructor": {"name": "이강사", "specialty": "AI"},
      "options": {"online": true, "certificate": false}
    }'::jsonb
),
(
    'GRAPH-301',
    '그래프 데이터 이해',
    '{
      "level": "advanced",
      "tags": ["Graph", "Recommendation", "Network"],
      "instructor": {"name": "박강사", "specialty": "Graph Data"},
      "options": {"online": false, "certificate": true}
    }'::jsonb
);

-- JSONB 필드 조회: -> 는 JSONB 값을, ->> 는 text 값을 반환합니다.
SELECT
    course_code,
    title,
    metadata ->> 'level' AS level,
    metadata -> 'options' ->> 'online' AS online
FROM course_documents
ORDER BY CASE course_code
    WHEN 'DB-101' THEN 1
    WHEN 'AI-201' THEN 2
    WHEN 'GRAPH-301' THEN 3
    ELSE 99
END;

-- ? 연산자: 최상위 키 존재 여부를 확인합니다.
SELECT course_code, title
FROM course_documents
WHERE metadata ? 'instructor'
ORDER BY course_code;

-- @> 연산자: JSONB 포함 조건을 확인합니다.
SELECT course_code, title
FROM course_documents
WHERE metadata @> '{"tags": ["PostgreSQL"]}'::jsonb;

-- course_code를 기준으로 안전하게 JSONB 필드를 수정합니다.
UPDATE course_documents
SET metadata = jsonb_set(metadata, '{options,certificate}', 'false'::jsonb)
WHERE course_code = 'DB-101';

SELECT course_code, metadata -> 'options' AS options
FROM course_documents
WHERE course_code = 'DB-101';

-- JSONB 전체 문서 검색에는 GIN 인덱스를 고려할 수 있습니다.
CREATE INDEX idx_course_documents_metadata_gin
ON course_documents
USING GIN (metadata);

-- 특정 JSONB 필드를 자주 조건으로 사용하면 표현식 인덱스를 고려할 수 있습니다.
CREATE INDEX idx_course_documents_level_text
ON course_documents ((metadata ->> 'level'));

ANALYZE course_documents;

-- 표본이 작으면 인덱스가 있어도 Seq Scan이 나올 수 있습니다.
EXPLAIN
SELECT course_code, title
FROM course_documents
WHERE metadata ->> 'level' = 'basic';

CREATE TABLE key_value_cache_examples (
    cache_key TEXT PRIMARY KEY,
    cache_value JSONB NOT NULL,
    expired_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT key_value_cache_examples_value_object_chk
        CHECK (jsonb_typeof(cache_value) = 'object')
);

INSERT INTO key_value_cache_examples (cache_key, cache_value, expired_at) VALUES
(
    'student:1001:session',
    '{"student_id": 1001, "login_device": "browser", "status": "active"}'::jsonb,
    now() + interval '30 minutes'
),
(
    'course:popular:top3',
    '{"course_codes": ["DB-101", "AI-201", "GRAPH-301"], "source": "daily_batch"}'::jsonb,
    now() + interval '1 hour'
),
(
    'feature:recommendation:v1',
    '{"enabled": true, "target": "student_course_topic"}'::jsonb,
    now() + interval '1 day'
),
(
    'student:9999:session',
    '{"student_id": 9999, "login_device": "mobile", "status": "expired"}'::jsonb,
    now() - interval '10 minutes'
);

-- expired_at은 만료 기준 시각을 저장할 뿐이며, 행을 자동 삭제하지 않습니다.
SELECT cache_key, expired_at, expired_at > now() AS is_valid
FROM key_value_cache_examples
ORDER BY cache_key;

SELECT
    COUNT(*) AS total_cache_rows,
    COUNT(*) FILTER (WHERE expired_at > now()) AS valid_cache_rows,
    COUNT(*) FILTER (WHERE expired_at <= now()) AS expired_cache_rows
FROM key_value_cache_examples;

-- 실제 Key-Value DB의 캐시 미스 흐름은 보통 다음처럼 설계합니다.
-- 1. cache_key로 캐시를 조회합니다.
-- 2. 없거나 만료되면 원본 RDBMS에서 데이터를 읽습니다.
-- 3. 캐시를 갱신합니다.
-- 4. 사용자에게 결과를 반환합니다.
-- 이 테이블은 메모리 저장, 분산, 자동 TTL 삭제, 복제, 고성능 조회를 구현하지 않습니다.
-- DELETE FROM key_value_cache_examples WHERE expired_at <= now();

CREATE TABLE storage_choice_cases (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_name TEXT NOT NULL,
    example_data TEXT NOT NULL,
    recommended_storage TEXT NOT NULL,
    reason TEXT NOT NULL,
    system_role TEXT NOT NULL,
    consistency_level TEXT NOT NULL,
    CONSTRAINT storage_choice_cases_system_role_chk
        CHECK (system_role IN ('source_of_truth', 'derived_cache', 'event_log', 'relationship_index', 'flexible_metadata')),
    CONSTRAINT storage_choice_cases_consistency_level_chk
        CHECK (consistency_level IN ('strong', 'eventual', 'context_dependent'))
);

INSERT INTO storage_choice_cases
(case_name, example_data, recommended_storage, reason, system_role, consistency_level) VALUES
(
    '수강 신청과 결제',
    'students, courses, enrollments, payments',
    'RDBMS',
    '정합성, 트랜잭션, 제약 조건이 중요합니다.',
    'source_of_truth',
    'strong'
),
(
    '학생 로그인 세션',
    'student:1001:session',
    'Key-Value DB',
    '정확한 키로 빠르게 읽고 만료 시간을 관리하는 패턴에 적합합니다.',
    'derived_cache',
    'eventual'
),
(
    '강의 유연 메타데이터',
    'course_documents.metadata',
    'Document DB or PostgreSQL JSONB',
    '강의별 옵션과 태그 구조가 조금씩 다를 수 있습니다.',
    'flexible_metadata',
    'context_dependent'
),
(
    '학습 행동 이벤트',
    'student_id + event_date / event_time',
    'Column-Family DB',
    '특정 학생의 특정 날짜 이벤트를 시간순으로 읽는 조회 패턴에 맞출 수 있습니다.',
    'event_log',
    'eventual'
),
(
    '학생-강의-주제 추천 관계',
    'Student, Course, Topic nodes and edges',
    'Graph DB',
    '관계를 여러 단계 따라가며 추천 후보를 찾는 문제에 적합합니다.',
    'relationship_index',
    'context_dependent'
);

SELECT case_name, recommended_storage, system_role, consistency_level
FROM storage_choice_cases
ORDER BY id;

SELECT 'course_documents' AS table_name, COUNT(*) AS expected_count
FROM course_documents
UNION ALL
SELECT 'key_value_cache_examples', COUNT(*)
FROM key_value_cache_examples
UNION ALL
SELECT 'storage_choice_cases', COUNT(*)
FROM storage_choice_cases
ORDER BY table_name;
