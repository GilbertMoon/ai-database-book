-- Chapter 12. NoSQL 이해와 선택 기준
-- 목적: PostgreSQL JSONB를 사용해 문서형 데이터와 Key-Value 개념을 맛보고,
--       데이터 유형별 저장 방식 선택 기준을 연습한다.

-- 중요 주의:
-- 1. 이 파일은 실습용 예제입니다.
-- 2. 별도 NoSQL 서버를 설치하지 않고 PostgreSQL 안에서 JSONB를 사용합니다.
-- 3. JSONB는 Document DB를 완전히 대체한다는 의미가 아니라 문서형 데이터 개념을 이해하기 위한 맛보기입니다.
-- 4. 실제 서비스에서는 데이터 구조, 조회 패턴, 정합성, 운영 난이도를 함께 검토해야 합니다.

-- ============================================================
-- 1. 문서형 데이터 맛보기: content_documents
-- ============================================================

CREATE TABLE IF NOT EXISTS content_documents (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    metadata JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO content_documents (title, metadata)
VALUES
(
    '데이터베이스 입문',
    '{
        "level": "basic",
        "tags": ["SQL", "PostgreSQL", "DB"],
        "online": true,
        "certificate": true,
        "creator": {
            "name": "김작가",
            "specialty": "Database"
        }
    }'::jsonb
),
(
    'AI 데이터 분석',
    '{
        "level": "intermediate",
        "tags": ["Python", "Pandas", "AI"],
        "online": true,
        "certificate": true,
        "creator": {
            "name": "이작가",
            "specialty": "Data Analysis"
        }
    }'::jsonb
),
(
    '그래프 데이터 이해',
    '{
        "level": "advanced",
        "tags": ["Graph", "Recommendation", "Network"],
        "online": false,
        "certificate": false,
        "creator": {
            "name": "박작가",
            "specialty": "Graph Data"
        }
    }'::jsonb
);

-- 전체 문서 조회
SELECT id, title, metadata
FROM content_documents
ORDER BY id;

-- JSONB의 특정 필드 조회
SELECT
    id,
    title,
    metadata ->> 'level' AS level,
    metadata ->> 'online' AS online
FROM content_documents
ORDER BY id;

-- 중첩 객체 필드 조회
SELECT
    title,
    metadata -> 'creator' ->> 'name' AS creator_name,
    metadata -> 'creator' ->> 'specialty' AS creator_specialty
FROM content_documents;

-- 특정 조건의 JSONB 필드 조회
SELECT id, title, metadata ->> 'level' AS level
FROM content_documents
WHERE metadata ->> 'level' = 'basic';

-- 배열에 특정 태그가 포함된 문서 조회
SELECT id, title, metadata -> 'tags' AS tags
FROM content_documents
WHERE metadata -> 'tags' ? 'SQL';

-- JSONB 포함 연산자를 사용한 조회
SELECT id, title, metadata
FROM content_documents
WHERE metadata @> '{"online": true}'::jsonb;

-- ============================================================
-- 2. JSONB 필드 업데이트 맛보기
-- ============================================================

-- certificate 값을 true로 변경하는 예시
UPDATE content_documents
SET metadata = jsonb_set(metadata, '{certificate}', 'true'::jsonb)
WHERE title = '그래프 데이터 이해';

SELECT
    title,
    metadata ->> 'certificate' AS certificate
FROM content_documents
WHERE title = '그래프 데이터 이해';

-- 새 필드 추가 예시
UPDATE content_documents
SET metadata = jsonb_set(metadata, '{duration_hours}', '24'::jsonb)
WHERE title = '데이터베이스 입문';

SELECT
    title,
    metadata ->> 'duration_hours' AS duration_hours
FROM content_documents
WHERE title = '데이터베이스 입문';

-- ============================================================
-- 3. JSONB 인덱스 맛보기
-- ============================================================

-- JSONB 전체 문서에 대한 GIN 인덱스 예시
CREATE INDEX IF NOT EXISTS idx_content_documents_metadata_gin
ON content_documents
USING GIN (metadata);

-- level 필드에 대한 표현식 인덱스 예시
CREATE INDEX IF NOT EXISTS idx_content_documents_level
ON content_documents ((metadata ->> 'level'));

-- 실행 계획 확인
EXPLAIN
SELECT id, title
FROM content_documents
WHERE metadata ->> 'level' = 'basic';

EXPLAIN
SELECT id, title
FROM content_documents
WHERE metadata @> '{"online": true}'::jsonb;

-- 주의:
-- 샘플 데이터가 적으면 인덱스가 있어도 Seq Scan이 나올 수 있습니다.
-- 이는 오류가 아니라 데이터가 적을 때 전체를 읽는 것이 더 싸다고 판단한 결과일 수 있습니다.

-- ============================================================
-- 4. Key-Value DB 개념 시뮬레이션
-- ============================================================

CREATE TABLE IF NOT EXISTS key_value_cache_examples (
    cache_key VARCHAR(200) PRIMARY KEY,
    cache_value JSONB NOT NULL,
    expired_at TIMESTAMP
);

INSERT INTO key_value_cache_examples (cache_key, cache_value, expired_at)
VALUES
(
    'content:popular:top3',
    '{"content_ids": [1, 2, 3], "description": "인기 콘텐츠 Top 3"}'::jsonb,
    CURRENT_TIMESTAMP + INTERVAL '1 hour'
),
(
    'user:1001:session',
    '{"user_id": 1001, "login": true, "role": "member"}'::jsonb,
    CURRENT_TIMESTAMP + INTERVAL '30 minutes'
),
(
    'feature:recommendation:v1',
    '{"enabled": true, "ratio": 0.5}'::jsonb,
    NULL
)
ON CONFLICT (cache_key) DO UPDATE
SET cache_value = EXCLUDED.cache_value,
    expired_at = EXCLUDED.expired_at;

-- 키로 빠르게 조회하는 예시
SELECT cache_key, cache_value, expired_at
FROM key_value_cache_examples
WHERE cache_key = 'content:popular:top3';

-- 만료되지 않은 캐시만 확인
SELECT cache_key, cache_value, expired_at
FROM key_value_cache_examples
WHERE expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP;

-- Key-Value 방식의 한계:
-- 키를 모르면 복잡한 조건 검색이나 JOIN에는 적합하지 않을 수 있습니다.

-- ============================================================
-- 5. 데이터 유형별 저장 방식 선택 연습용 테이블
-- ============================================================

CREATE TABLE IF NOT EXISTS storage_choice_cases (
    id SERIAL PRIMARY KEY,
    data_name VARCHAR(100) NOT NULL,
    data_description TEXT NOT NULL,
    consistency_required VARCHAR(20) NOT NULL,
    query_pattern VARCHAR(200) NOT NULL,
    suggested_storage VARCHAR(100),
    review_reason TEXT
);

INSERT INTO storage_choice_cases (
    data_name,
    data_description,
    consistency_required,
    query_pattern,
    suggested_storage,
    review_reason
)
VALUES
(
    '주문/결제 내역',
    '회원이 콘텐츠를 결제하고 이용신청하는 핵심 거래 데이터',
    'high',
    '회원별 주문 조회, 결제 상태 변경, 정산 조회',
    'Relational DB',
    '정합성과 트랜잭션이 중요하므로 관계형 DB가 적합하다.'
),
(
    '로그인 세션',
    '로그인 유지와 만료 시간을 관리하는 임시 데이터',
    'medium',
    '세션 키로 빠른 조회',
    'Key-Value DB',
    '키 기반 조회와 만료 처리에 적합하다.'
),
(
    '콘텐츠 상세 옵션',
    '콘텐츠별로 서로 다른 설정값과 태그를 포함하는 데이터',
    'medium',
    '콘텐츠별 문서 조회, 일부 필드 조건 검색',
    'Document DB or PostgreSQL JSONB',
    '필드 구조가 유연하므로 문서형 저장이 유리할 수 있다.'
),
(
    '사용자 행동 로그',
    '페이지 조회, 콘텐츠 재생, 리뷰 작성 등 대량 이벤트 데이터',
    'low',
    '시간대별 대량 저장과 분석',
    'Column-Family DB or Log System',
    '대량 쓰기와 분석이 중요하다.'
),
(
    '추천 관계',
    '회원, 콘텐츠, 태그, 이용 이력 사이의 관계 데이터',
    'medium',
    '관계 탐색과 추천 경로 조회',
    'Graph DB',
    '관계 탐색이 중요하므로 그래프 구조가 적합할 수 있다.'
);

SELECT
    data_name,
    consistency_required,
    query_pattern,
    suggested_storage,
    review_reason
FROM storage_choice_cases
ORDER BY id;

-- ============================================================
-- 6. AI 추천 결과 검토 질문
-- ============================================================

-- AI가 다음처럼 추천했다고 가정합니다.
-- "모든 데이터를 Document DB에 저장하면 유연하고 빠르므로 가장 좋습니다."

-- 아래 기준으로 검토하세요.
-- 1. 주문/결제 데이터에 강한 정합성이 필요한가?
-- 2. 트랜잭션이 필요한 데이터가 포함되어 있는가?
-- 3. JOIN이나 복잡한 SQL 분석이 필요한가?
-- 4. 기존 관계형 DB로 충분히 해결 가능한가?
-- 5. 새 NoSQL을 운영할 팀 역량이 있는가?
-- 6. 백업, 복구, 모니터링 방법이 준비되어 있는가?
-- 7. NoSQL 도입으로 얻는 이점이 운영 복잡도보다 큰가?

-- ============================================================
-- 7. 정리용 조회
-- ============================================================

SELECT 'Document DB taste with JSONB' AS practice_topic, COUNT(*) AS row_count
FROM content_documents
UNION ALL
SELECT 'Key-Value concept simulation' AS practice_topic, COUNT(*) AS row_count
FROM key_value_cache_examples
UNION ALL
SELECT 'Storage choice cases' AS practice_topic, COUNT(*) AS row_count
FROM storage_choice_cases;
