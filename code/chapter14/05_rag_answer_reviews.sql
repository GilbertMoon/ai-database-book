-- Chapter 14. RAG 답변 근거·인용·권한·보류 검토
-- 실행 전 01→04 파일을 순서대로 실행합니다.

SELECT current_database();

INSERT INTO rag_lab.answer_reviews (
    id,
    query_id,
    review_case,
    generated_answer,
    cited_chunk_ids,
    is_search_relevant,
    access_allowed,
    freshness_ok,
    citations_present,
    all_claims_supported,
    has_unsupported_claim,
    expected_abstain,
    answer_abstained,
    review_note
)
VALUES
(
    301,
    201,
    'grounded_refund_answer',
    '결제 후 7일 이내에는 전액 환불이 가능하며, 구독 취소는 계정 설정에서 신청할 수 있습니다.',
    ARRAY[102, 103],
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    '최신 public 문서의 핵심 주장과 인용이 일치합니다.'
),
(
    302,
    201,
    'unsupported_30_day_claim',
    '결제 후 30일 이내에는 언제든 전액 환불됩니다.',
    ARRAY[102],
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    TRUE,
    FALSE,
    FALSE,
    '검색은 적절하지만 최신 근거에는 30일 기준이 없습니다.'
),
(
    303,
    201,
    'restricted_document_used',
    '승인된 예외 사유가 있으면 관리자 전용 절차로 환불할 수 있습니다.',
    ARRAY[108],
    TRUE,
    FALSE,
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    '문서 내용에는 근거가 있지만 public 질문자가 접근할 수 없는 restricted 문서입니다.'
),
(
    304,
    204,
    'correct_no_evidence_abstention',
    '제공된 최신 문서에서는 상품 배송 기간을 확인할 수 없습니다.',
    ARRAY[]::INTEGER[],
    FALSE,
    TRUE,
    TRUE,
    FALSE,
    TRUE,
    FALSE,
    TRUE,
    TRUE,
    '관련 근거가 없으므로 문서 밖 내용을 만들지 않고 답변을 보류했습니다.'
)
ON CONFLICT (review_case)
DO UPDATE SET
    query_id = EXCLUDED.query_id,
    generated_answer = EXCLUDED.generated_answer,
    cited_chunk_ids = EXCLUDED.cited_chunk_ids,
    is_search_relevant = EXCLUDED.is_search_relevant,
    access_allowed = EXCLUDED.access_allowed,
    freshness_ok = EXCLUDED.freshness_ok,
    citations_present = EXCLUDED.citations_present,
    all_claims_supported = EXCLUDED.all_claims_supported,
    has_unsupported_claim = EXCLUDED.has_unsupported_claim,
    expected_abstain = EXCLUDED.expected_abstain,
    answer_abstained = EXCLUDED.answer_abstained,
    review_note = EXCLUDED.review_note;

-- 1. 전체 검토 결과
SELECT
    id,
    review_case,
    query_id,
    generated_answer,
    cited_chunk_ids,
    is_search_relevant,
    access_allowed,
    freshness_ok,
    citations_present,
    all_claims_supported,
    has_unsupported_claim,
    expected_abstain,
    answer_abstained,
    review_note
FROM rag_lab.answer_reviews
ORDER BY id;

-- 2. 정상 답변: 기대 1행
SELECT *
FROM rag_lab.answer_reviews
WHERE is_search_relevant = TRUE
  AND access_allowed = TRUE
  AND freshness_ok = TRUE
  AND citations_present = TRUE
  AND all_claims_supported = TRUE
  AND has_unsupported_claim = FALSE
  AND expected_abstain = FALSE
  AND answer_abstained = FALSE;

-- 3. Unsupported claim: 기대 1행
SELECT *
FROM rag_lab.answer_reviews
WHERE has_unsupported_claim = TRUE;

-- 4. 권한 위반 문서 사용: 기대 1행
SELECT *
FROM rag_lab.answer_reviews
WHERE access_allowed = FALSE;

-- 5. 정답 없는 질문의 올바른 보류: 기대 1행
SELECT *
FROM rag_lab.answer_reviews
WHERE expected_abstain = TRUE
  AND answer_abstained = TRUE
  AND has_unsupported_claim = FALSE;

-- 6. 인용 청크 상세
SELECT
    ar.review_case,
    cited.chunk_id,
    s.title,
    s.source_version,
    s.access_scope,
    s.is_active AS source_is_active,
    c.is_active AS chunk_is_active,
    c.chunk_no
FROM rag_lab.answer_reviews AS ar
CROSS JOIN LATERAL unnest(ar.cited_chunk_ids) AS cited(chunk_id)
JOIN rag_lab.document_chunks AS c
    ON c.id = cited.chunk_id
JOIN rag_lab.document_sources AS s
    ON s.id = c.source_id
ORDER BY ar.id, cited.chunk_id;

-- 7. 인용 ID가 존재하지 않는 사례: 기대 0행
SELECT
    ar.review_case,
    cited.chunk_id
FROM rag_lab.answer_reviews AS ar
CROSS JOIN LATERAL unnest(ar.cited_chunk_ids) AS cited(chunk_id)
LEFT JOIN rag_lab.document_chunks AS c
    ON c.id = cited.chunk_id
WHERE c.id IS NULL;

-- 8. 논리 불일치 사례: 기대 0행
SELECT *
FROM rag_lab.answer_reviews
WHERE
    (all_claims_supported = TRUE AND has_unsupported_claim = TRUE)
    OR (expected_abstain = TRUE AND answer_abstained = FALSE)
    OR (array_length(cited_chunk_ids, 1) IS NOT NULL AND citations_present = FALSE)
    OR (array_length(cited_chunk_ids, 1) IS NULL AND citations_present = TRUE);

-- 9. 최종 요약
SELECT
    COUNT(*) AS answer_reviews_expected_4,
    COUNT(*) FILTER (
        WHERE review_case = 'grounded_refund_answer'
          AND all_claims_supported = TRUE
          AND access_allowed = TRUE
    ) AS grounded_expected_1,
    COUNT(*) FILTER (
        WHERE has_unsupported_claim = TRUE
    ) AS unsupported_expected_1,
    COUNT(*) FILTER (
        WHERE access_allowed = FALSE
    ) AS access_violation_expected_1,
    COUNT(*) FILTER (
        WHERE expected_abstain = TRUE
          AND answer_abstained = TRUE
    ) AS correct_abstention_expected_1
FROM rag_lab.answer_reviews;
