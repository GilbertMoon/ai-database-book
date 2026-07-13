-- Chapter 14. 문서·청크·임베딩 수명주기 검증
-- 실행 전 01→05 파일을 순서대로 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_database();

-- 1. 문서와 청크 활성 상태 불일치: 기대 0행
SELECT
    s.id AS source_id,
    s.document_key,
    s.source_version,
    s.is_active AS source_is_active,
    c.id AS chunk_id,
    c.is_active AS chunk_is_active
FROM rag_lab.document_sources AS s
JOIN rag_lab.document_chunks AS c
    ON c.source_id = s.id
WHERE s.is_active <> c.is_active
ORDER BY s.id, c.id;

-- 2. 원문 업데이트보다 임베딩이 오래된 활성 청크: 기대 0행
SELECT
    s.id AS source_id,
    s.title,
    s.updated_at,
    c.id AS chunk_id,
    c.embedded_at
FROM rag_lab.document_sources AS s
JOIN rag_lab.document_chunks AS c
    ON c.source_id = s.id
WHERE s.is_active = TRUE
  AND c.is_active = TRUE
  AND c.embedded_at < s.updated_at
ORDER BY s.id, c.id;

-- 3. 활성 질문과 활성 청크의 임베딩 호환성 문제: 기대 0행
SELECT DISTINCT
    q.id AS query_id,
    q.embedding_source AS query_embedding_source,
    q.embedding_dimension AS query_dimension,
    c.embedding_source AS chunk_embedding_source,
    c.embedding_dimension AS chunk_dimension
FROM rag_lab.query_cases AS q
JOIN rag_lab.document_chunks AS c
    ON c.is_active = TRUE
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
   AND s.is_active = TRUE
WHERE q.embedding_source <> c.embedding_source
   OR q.embedding_dimension <> c.embedding_dimension
ORDER BY q.id;

-- 4. 임베딩 모델을 v2로 교체한다고 가정할 때 재임베딩 대상
WITH target_model AS (
    SELECT
        'manual-demo-3d-v2'::TEXT AS embedding_source,
        3::INTEGER AS embedding_dimension
)
SELECT
    c.id AS chunk_id,
    s.title,
    c.embedding_source AS current_embedding_source,
    c.embedding_dimension AS current_dimension,
    target_model.embedding_source AS target_embedding_source,
    target_model.embedding_dimension AS target_dimension
FROM rag_lab.document_chunks AS c
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
CROSS JOIN target_model
WHERE s.is_active = TRUE
  AND c.is_active = TRUE
  AND (
      c.embedding_source <> target_model.embedding_source
      OR c.embedding_dimension <> target_model.embedding_dimension
  )
ORDER BY c.id;

-- 기대: 활성 청크 8건이 모두 재임베딩 대상

-- 5. 비활성 문서가 검색 로그에 포함되었는지 확인: 기대 0행
SELECT
    r.query_id,
    r.rank_no,
    r.chunk_id,
    s.title,
    s.is_active AS source_is_active,
    c.is_active AS chunk_is_active
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND (s.is_active = FALSE OR c.is_active = FALSE);

-- 6. 질문자 권한보다 높은 문서가 검색 로그에 포함되었는지 확인: 기대 0행
SELECT
    r.query_id,
    q.requester_scope,
    r.rank_no,
    r.chunk_id,
    s.access_scope
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.query_cases AS q
    ON q.id = r.query_id
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE r.run_label = 'manual-l2-v1'
  AND (
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
  );

-- 7. 동일 document_key의 활성 버전 수: 각 키당 최대 1개 기대
SELECT
    document_key,
    COUNT(*) FILTER (WHERE is_active = TRUE) AS active_version_count,
    ARRAY_AGG(source_version ORDER BY updated_at DESC) AS versions
FROM rag_lab.document_sources
GROUP BY document_key
HAVING COUNT(*) FILTER (WHERE is_active = TRUE) > 1;

-- 기대: 0행

-- 8. 출처·청킹·임베딩 추적 정보 누락: 기대 0행
SELECT
    c.id AS chunk_id,
    s.document_key,
    s.source_version,
    s.content_hash,
    c.chunk_strategy_version,
    c.embedding_source,
    c.embedding_dimension,
    c.embedded_at
FROM rag_lab.document_chunks AS c
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
WHERE char_length(trim(s.content_hash)) = 0
   OR char_length(trim(c.chunk_strategy_version)) = 0
   OR char_length(trim(c.embedding_source)) = 0
   OR c.embedding_dimension <= 0
   OR c.embedded_at IS NULL;

-- 9. 최종 수명주기 요약
SELECT
    COUNT(*) FILTER (
        WHERE s.is_active = TRUE AND c.is_active = TRUE
    ) AS active_chunks_expected_8,
    COUNT(*) FILTER (
        WHERE s.is_active = FALSE OR c.is_active = FALSE
    ) AS inactive_chunks_expected_1,
    COUNT(*) FILTER (
        WHERE s.is_active = TRUE
          AND c.is_active = TRUE
          AND c.embedding_source <> 'manual-demo-3d-v2'
    ) AS reembedding_for_v2_expected_8
FROM rag_lab.document_chunks AS c
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id;
