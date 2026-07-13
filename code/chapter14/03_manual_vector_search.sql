-- Chapter 14. 수동 3차원 L2 벡터 검색
-- 실행 전 01, 02 파일을 실행합니다.
-- 권한·활성 상태·임베딩 호환 필터를 먼저 적용한 뒤 거리를 계산합니다.

SELECT current_database();

WITH eligible_candidates AS (
    SELECT
        q.id AS query_id,
        q.top_k,
        q.distance_threshold,
        q.embedding_source,
        c.id AS chunk_id,
        s.access_scope,
        SQRT(
            POWER(c.embedding_x - q.embedding_x, 2)
          + POWER(c.embedding_y - q.embedding_y, 2)
          + POWER(c.embedding_z - q.embedding_z, 2)
        ) AS l2_distance
    FROM rag_lab.query_cases AS q
    JOIN rag_lab.document_chunks AS c
        ON c.embedding_source = q.embedding_source
       AND c.embedding_dimension = q.embedding_dimension
    JOIN rag_lab.document_sources AS s
        ON s.id = c.source_id
    WHERE s.is_active = TRUE
      AND c.is_active = TRUE
      AND (
          CASE s.access_scope
              WHEN 'public' THEN 1
              WHEN 'internal' THEN 2
              WHEN 'restricted' THEN 3
          END
          <=
          CASE q.requester_scope
              WHEN 'public' THEN 1
              WHEN 'internal' THEN 2
              WHEN 'restricted' THEN 3
          END
      )
),
ranked AS (
    SELECT
        query_id,
        top_k,
        distance_threshold,
        embedding_source,
        chunk_id,
        access_scope,
        l2_distance,
        ROW_NUMBER() OVER (
            PARTITION BY query_id
            ORDER BY l2_distance, chunk_id
        ) AS rank_no
    FROM eligible_candidates
)
INSERT INTO rag_lab.retrieval_runs (
    run_label,
    query_id,
    rank_no,
    chunk_id,
    l2_distance,
    passed_threshold,
    embedding_source,
    filter_note
)
SELECT
    'manual-l2-v1',
    query_id,
    rank_no,
    chunk_id,
    ROUND(l2_distance, 8),
    l2_distance <= distance_threshold,
    embedding_source,
    'active source/chunk + access_scope filter before ranking'
FROM ranked
WHERE rank_no <= top_k
ON CONFLICT (run_label, query_id, rank_no)
DO UPDATE SET
    chunk_id = EXCLUDED.chunk_id,
    l2_distance = EXCLUDED.l2_distance,
    passed_threshold = EXCLUDED.passed_threshold,
    embedding_source = EXCLUDED.embedding_source,
    filter_note = EXCLUDED.filter_note,
    created_at = CURRENT_TIMESTAMP;

-- 1. 전체 검색 로그: 기대 9행
SELECT
    r.query_id,
    q.question_text,
    q.requester_scope,
    r.rank_no,
    r.chunk_id,
    s.title AS source_title,
    s.access_scope,
    r.l2_distance,
    q.distance_threshold,
    r.passed_threshold
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.query_cases AS q
    ON q.id = r.query_id
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
ORDER BY r.query_id, r.rank_no;

-- 2. 환불 질문 Top-3
SELECT
    r.rank_no,
    r.chunk_id,
    s.title,
    c.chunk_text,
    r.l2_distance,
    r.passed_threshold
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND r.query_id = 201
ORDER BY r.rank_no;

-- 기대 순위: 103 구독 취소, 102 환불 기준, 101 이용권 변경

-- 3. 프로젝트 질문 Top-2
SELECT
    r.rank_no,
    r.chunk_id,
    s.title,
    s.access_scope,
    r.l2_distance,
    r.passed_threshold
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND r.query_id = 202
ORDER BY r.rank_no;

-- 기대: 105 내부 프로젝트 제출 안내, 104 서비스 업데이트 안내

-- 4. JOIN 질문 Top-1
SELECT
    r.rank_no,
    r.chunk_id,
    s.title,
    r.l2_distance,
    r.passed_threshold
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND r.query_id = 203;

-- 기대: 107 SQL JOIN 복습

-- 5. 배송 질문: Top-3은 존재하지만 threshold 통과는 0건이어야 합니다.
SELECT
    r.rank_no,
    r.chunk_id,
    s.title,
    r.l2_distance,
    r.passed_threshold
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND r.query_id = 204
ORDER BY r.rank_no;

-- 6. 제한·비활성 문서가 검색 로그에 포함되었는지 확인: 기대 0행
SELECT
    r.query_id,
    r.rank_no,
    r.chunk_id,
    s.title,
    s.access_scope,
    s.is_active AS source_is_active,
    c.is_active AS chunk_is_active
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.query_cases AS q
    ON q.id = r.query_id
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND (
      s.is_active = FALSE
      OR c.is_active = FALSE
      OR (
          CASE s.access_scope
              WHEN 'public' THEN 1
              WHEN 'internal' THEN 2
              WHEN 'restricted' THEN 3
          END
          >
          CASE q.requester_scope
              WHEN 'public' THEN 1
              WHEN 'internal' THEN 2
              WHEN 'restricted' THEN 3
          END
      )
  );

-- 7. 기준 결과 요약
SELECT
    COUNT(*) AS retrieval_rows_expected_9,
    COUNT(*) FILTER (
        WHERE query_id = 204
          AND passed_threshold = TRUE
    ) AS shipping_passed_threshold_expected_0,
    COUNT(*) FILTER (
        WHERE chunk_id IN (108, 109)
    ) AS forbidden_or_inactive_chunks_expected_0
FROM rag_lab.retrieval_runs
WHERE run_label = 'manual-l2-v1';
