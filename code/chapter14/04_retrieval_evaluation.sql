-- Chapter 14. 검색 품질 평가
-- 실행 전 01→03 파일을 순서대로 실행합니다.
-- 현재 검색 순위와 사람이 검토한 relevance_judgments를 비교합니다.

SELECT current_database();

-- 1. 질문별 Precision@k, Recall@k, Reciprocal Rank
WITH retrieved AS (
    SELECT
        r.query_id,
        r.rank_no,
        r.chunk_id,
        r.passed_threshold
    FROM rag_lab.retrieval_runs AS r
    WHERE r.run_label = 'manual-l2-v1'
),
query_counts AS (
    SELECT
        q.id AS query_id,
        q.question_text,
        q.top_k,
        q.expected_action,
        COUNT(r.chunk_id) AS retrieved_count,
        COUNT(r.chunk_id) FILTER (
            WHERE j.relevance_grade IS NOT NULL
        ) AS relevant_retrieved_count,
        (
            SELECT COUNT(*)
            FROM rag_lab.relevance_judgments AS all_j
            WHERE all_j.query_id = q.id
        ) AS total_relevant_count,
        MIN(r.rank_no) FILTER (
            WHERE j.relevance_grade IS NOT NULL
        ) AS first_relevant_rank,
        COUNT(r.chunk_id) FILTER (
            WHERE r.passed_threshold = TRUE
        ) AS threshold_passed_count
    FROM rag_lab.query_cases AS q
    LEFT JOIN retrieved AS r
        ON r.query_id = q.id
    LEFT JOIN rag_lab.relevance_judgments AS j
        ON j.query_id = r.query_id
       AND j.chunk_id = r.chunk_id
    GROUP BY
        q.id,
        q.question_text,
        q.top_k,
        q.expected_action
)
SELECT
    query_id,
    question_text,
    top_k,
    expected_action,
    retrieved_count,
    relevant_retrieved_count,
    total_relevant_count,
    ROUND(
        relevant_retrieved_count::NUMERIC
        / NULLIF(retrieved_count, 0),
        4
    ) AS precision_at_k,
    CASE
        WHEN total_relevant_count = 0 THEN NULL
        ELSE ROUND(
            relevant_retrieved_count::NUMERIC
            / total_relevant_count,
            4
        )
    END AS recall_at_k,
    CASE
        WHEN first_relevant_rank IS NULL THEN NULL
        ELSE ROUND(1.0 / first_relevant_rank, 4)
    END AS reciprocal_rank,
    threshold_passed_count
FROM query_counts
ORDER BY query_id;

-- 기대:
-- 201 Precision 1.0 / Recall 1.0 / RR 1.0
-- 202 Precision 1.0 / Recall 1.0 / RR 1.0
-- 203 Precision 1.0 / Recall 1.0 / RR 1.0
-- 204 relevant 0 / threshold passed 0 / 답변 보류 평가

-- 2. 정답이 있는 질문의 MRR
WITH first_relevant AS (
    SELECT
        q.id AS query_id,
        MIN(r.rank_no) AS first_relevant_rank
    FROM rag_lab.query_cases AS q
    JOIN rag_lab.relevance_judgments AS j
        ON j.query_id = q.id
    JOIN rag_lab.retrieval_runs AS r
        ON r.query_id = j.query_id
       AND r.chunk_id = j.chunk_id
       AND r.run_label = 'manual-l2-v1'
    GROUP BY q.id
)
SELECT
    ROUND(AVG(1.0 / first_relevant_rank), 4) AS mrr_expected_1
FROM first_relevant;

-- 3. 관련성 등급과 실제 순위 비교
SELECT
    r.query_id,
    r.rank_no,
    r.chunk_id,
    s.title,
    j.relevance_grade,
    r.l2_distance,
    r.passed_threshold
FROM rag_lab.retrieval_runs AS r
JOIN rag_lab.document_chunks AS c
    ON c.id = r.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
LEFT JOIN rag_lab.relevance_judgments AS j
    ON j.query_id = r.query_id
   AND j.chunk_id = r.chunk_id
WHERE r.run_label = 'manual-l2-v1'
ORDER BY r.query_id, r.rank_no;

-- 4. 정답 청크가 Top-k에서 누락되었는지 확인: 기대 0행
SELECT
    j.query_id,
    j.chunk_id,
    s.title,
    j.relevance_grade
FROM rag_lab.relevance_judgments AS j
JOIN rag_lab.document_chunks AS c
    ON c.id = j.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
LEFT JOIN rag_lab.retrieval_runs AS r
    ON r.run_label = 'manual-l2-v1'
   AND r.query_id = j.query_id
   AND r.chunk_id = j.chunk_id
WHERE r.id IS NULL
ORDER BY j.query_id, j.chunk_id;

-- 5. 정답이 없는 질문의 보류 조건
SELECT
    q.id AS query_id,
    q.question_text,
    q.expected_action,
    COUNT(r.id) FILTER (
        WHERE r.passed_threshold = TRUE
    ) AS threshold_passed_count,
    (
        q.expected_action = 'abstain'
        AND COUNT(r.id) FILTER (
            WHERE r.passed_threshold = TRUE
        ) = 0
    ) AS abstention_condition_ok
FROM rag_lab.query_cases AS q
LEFT JOIN rag_lab.retrieval_runs AS r
    ON r.query_id = q.id
   AND r.run_label = 'manual-l2-v1'
WHERE q.id = 204
GROUP BY q.id, q.question_text, q.expected_action;

-- 기대: threshold_passed_count 0 / abstention_condition_ok true

-- 6. 권한·최신성 위반 검색: 기대 0행
SELECT
    r.query_id,
    r.rank_no,
    r.chunk_id,
    q.requester_scope,
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

-- 7. 최종 boolean 요약
WITH metrics AS (
    SELECT
        q.id AS query_id,
        COUNT(r.id) AS retrieved_count,
        COUNT(r.id) FILTER (
            WHERE j.relevance_grade IS NOT NULL
        ) AS relevant_retrieved_count,
        (
            SELECT COUNT(*)
            FROM rag_lab.relevance_judgments AS all_j
            WHERE all_j.query_id = q.id
        ) AS total_relevant_count,
        COUNT(r.id) FILTER (
            WHERE r.passed_threshold = TRUE
        ) AS threshold_passed_count
    FROM rag_lab.query_cases AS q
    LEFT JOIN rag_lab.retrieval_runs AS r
        ON r.query_id = q.id
       AND r.run_label = 'manual-l2-v1'
    LEFT JOIN rag_lab.relevance_judgments AS j
        ON j.query_id = r.query_id
       AND j.chunk_id = r.chunk_id
    GROUP BY q.id
)
SELECT
    COUNT(*) = 4 AS four_queries_evaluated,
    BOOL_AND(
        CASE
            WHEN total_relevant_count > 0
                THEN relevant_retrieved_count = total_relevant_count
            ELSE TRUE
        END
    ) AS all_relevant_chunks_retrieved,
    BOOL_AND(
        CASE
            WHEN query_id = 204
                THEN threshold_passed_count = 0
            ELSE TRUE
        END
    ) AS no_evidence_query_abstains
FROM metrics;

-- 모든 결과가 true여야 합니다.
