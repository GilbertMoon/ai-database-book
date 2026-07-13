-- Chapter 14. Vector DB와 RAG 기초
-- 목적: PostgreSQL에서 벡터 검색과 RAG 검토 흐름을 작은 데이터셋으로 확인합니다.
-- 주의: 이 파일은 운영 DB에서 실행하지 않습니다. 실습 테이블을 DROP 후 다시 만듭니다.
--      Section A는 pgvector가 준비된 경우에만 주석을 해제해 실행합니다.
--      Section B는 pgvector 없이 실행 가능한 3차원 수동 벡터 실습입니다.

SELECT current_database() AS current_database, current_user AS current_user;

SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE name = 'vector';

SELECT to_regtype('vector') AS vector_type_in_current_database;

-- ============================================================
-- Section A. pgvector 선택 실습
-- ============================================================
-- CREATE EXTENSION은 운영체제에 pgvector를 설치하는 명령이 아닙니다.
-- 서버에 확장 파일이 준비되어 있고, 현재 DB에서 확장을 생성할 권한이 있을 때만 실행됩니다.
-- 운영 DB에서는 임의로 실행하지 않습니다.
--
-- CREATE EXTENSION IF NOT EXISTS vector;
-- DROP TABLE IF EXISTS rag_document_embeddings;
-- CREATE TABLE rag_document_embeddings (
--     id INTEGER PRIMARY KEY,
--     title TEXT NOT NULL,
--     chunk_text TEXT NOT NULL,
--     source_name TEXT NOT NULL,
--     chunk_no INTEGER NOT NULL,
--     source_version TEXT NOT NULL,
--     embedding_source TEXT NOT NULL,
--     updated_at TIMESTAMPTZ NOT NULL,
--     embedding vector(3) NOT NULL,
--     UNIQUE (source_name, chunk_no)
-- );
-- INSERT INTO rag_document_embeddings
-- (id, title, chunk_text, source_name, chunk_no, source_version, embedding_source, updated_at, embedding) VALUES
-- (1, '이용권 변경', '이용권 변경은 계정 설정에서 신청할 수 있으며 다음 결제일부터 적용됩니다.', 'service_notice.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-01 09:00:00+09', '[0.72,0.25,0.18]'),
-- (2, '환불 기준', '결제 후 7일 이내에는 전액 환불이 가능하며 이용 내역에 따라 제한될 수 있습니다.', 'service_notice.md', 2, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-01 09:00:00+09', '[0.92,0.08,0.16]'),
-- (3, '구독 취소', '구독 취소는 계정 설정에서 신청할 수 있으며 환불 여부는 환불 기준에 따릅니다.', 'service_notice.md', 3, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-01 09:00:00+09', '[0.86,0.14,0.20]'),
-- (4, '서비스 업데이트', '서비스 업데이트 공지는 프로젝트 일정과 변경된 기능을 안내합니다.', 'project_guide.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-02 10:00:00+09', '[0.20,0.75,0.25]'),
-- (5, '프로젝트 자료', '프로젝트 자료는 코드, 결과 파일, 그래프, 보고서를 함께 제출해야 합니다.', 'project_guide.md', 2, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-02 10:00:00+09', '[0.10,0.80,0.20]'),
-- (6, '고객 문의', '고객 문의 답변은 출처 문서를 확인하고 개인정보를 포함하지 않아야 합니다.', 'support_guide.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-03 11:00:00+09', '[0.25,0.25,0.85]'),
-- (7, 'SQL JOIN 복습', 'JOIN은 여러 테이블의 데이터를 연결해 조회할 때 사용합니다.', 'sql_review.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-04 12:00:00+09', '[0.15,0.30,0.90]');
--
-- -- <-> 는 pgvector의 L2(Euclidean) 거리입니다. 작은 값일수록 가깝습니다.
-- SELECT id, title, source_name, chunk_no, embedding <-> '[0.88,0.12,0.22]' AS l2_distance
-- FROM rag_document_embeddings
-- ORDER BY embedding <-> '[0.88,0.12,0.22]'
-- LIMIT 3;
--
-- -- <=> 는 cosine distance입니다. cosine similarity는 1 - cosine distance로 계산할 수 있습니다.
-- SELECT id, title, 1 - (embedding <=> '[0.88,0.12,0.22]') AS cosine_similarity
-- FROM rag_document_embeddings
-- ORDER BY embedding <=> '[0.88,0.12,0.22]'
-- LIMIT 3;

-- ============================================================
-- Section B. pgvector 없이 실행 가능한 3차원 수동 벡터 실습
-- ============================================================

DROP TABLE IF EXISTS rag_answer_reviews;
DROP TABLE IF EXISTS rag_search_logs;
DROP TABLE IF EXISTS simple_document_chunks;

CREATE TABLE simple_document_chunks (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    chunk_text TEXT NOT NULL,
    source_name TEXT NOT NULL,
    chunk_no INTEGER NOT NULL,
    source_version TEXT NOT NULL,
    embedding_source TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    embedding_x NUMERIC(8, 4) NOT NULL,
    embedding_y NUMERIC(8, 4) NOT NULL,
    embedding_z NUMERIC(8, 4) NOT NULL,
    UNIQUE (source_name, chunk_no)
);

INSERT INTO simple_document_chunks
(id, title, chunk_text, source_name, chunk_no, source_version, embedding_source, updated_at, embedding_x, embedding_y, embedding_z) VALUES
(1, '이용권 변경', '이용권 변경은 계정 설정에서 신청할 수 있으며 다음 결제일부터 적용됩니다.', 'service_notice.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-01 09:00:00+09', 0.72, 0.25, 0.18),
(2, '환불 기준', '결제 후 7일 이내에는 전액 환불이 가능하며 이용 내역에 따라 제한될 수 있습니다.', 'service_notice.md', 2, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-01 09:00:00+09', 0.92, 0.08, 0.16),
(3, '구독 취소', '구독 취소는 계정 설정에서 신청할 수 있으며 환불 여부는 환불 기준에 따릅니다.', 'service_notice.md', 3, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-01 09:00:00+09', 0.86, 0.14, 0.20),
(4, '서비스 업데이트', '서비스 업데이트 공지는 프로젝트 일정과 변경된 기능을 안내합니다.', 'project_guide.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-02 10:00:00+09', 0.20, 0.75, 0.25),
(5, '프로젝트 자료', '프로젝트 자료는 코드, 결과 파일, 그래프, 보고서를 함께 제출해야 합니다.', 'project_guide.md', 2, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-02 10:00:00+09', 0.10, 0.80, 0.20),
(6, '고객 문의', '고객 문의 답변은 출처 문서를 확인하고 개인정보를 포함하지 않아야 합니다.', 'support_guide.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-03 11:00:00+09', 0.25, 0.25, 0.85),
(7, 'SQL JOIN 복습', 'JOIN은 여러 테이블의 데이터를 연결해 조회할 때 사용합니다.', 'sql_review.md', 1, 'v1', 'manual-demo-3d', TIMESTAMPTZ '2026-07-04 12:00:00+09', 0.15, 0.30, 0.90);

SELECT id, title, source_name, chunk_no, embedding_source
FROM simple_document_chunks
ORDER BY id;

-- 환불 질문 벡터: [0.88, 0.12, 0.22]
WITH ranked AS (
    SELECT id, title, source_name, chunk_no, chunk_text,
           SQRT(POWER(embedding_x - 0.88, 2) + POWER(embedding_y - 0.12, 2) + POWER(embedding_z - 0.22, 2)) AS l2_distance
    FROM simple_document_chunks
)
SELECT id, title, source_name, chunk_no, ROUND(l2_distance, 4) AS l2_distance
FROM ranked
ORDER BY l2_distance
LIMIT 3;

-- 업데이트 질문 벡터: [0.18, 0.78, 0.22]
WITH ranked AS (
    SELECT id, title, source_name, chunk_no,
           SQRT(POWER(embedding_x - 0.18, 2) + POWER(embedding_y - 0.78, 2) + POWER(embedding_z - 0.22, 2)) AS l2_distance
    FROM simple_document_chunks
)
SELECT id, title, source_name, chunk_no, ROUND(l2_distance, 4) AS l2_distance
FROM ranked
ORDER BY l2_distance
LIMIT 2;

-- JOIN 질문 벡터: [0.12, 0.32, 0.88]
WITH ranked AS (
    SELECT id, title, source_name, chunk_no,
           SQRT(POWER(embedding_x - 0.12, 2) + POWER(embedding_y - 0.32, 2) + POWER(embedding_z - 0.88, 2)) AS l2_distance
    FROM simple_document_chunks
)
SELECT id, title, source_name, chunk_no, ROUND(l2_distance, 4) AS l2_distance
FROM ranked
ORDER BY l2_distance
LIMIT 1;

CREATE TABLE rag_search_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_text TEXT NOT NULL,
    query_vector_label TEXT NOT NULL,
    rank_no INTEGER NOT NULL CHECK (rank_no > 0),
    retrieved_chunk_id INTEGER NOT NULL REFERENCES simple_document_chunks(id),
    l2_distance NUMERIC(10, 6) NOT NULL,
    is_search_relevant BOOLEAN NOT NULL,
    search_note TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

WITH ranked AS (
    SELECT id, SQRT(POWER(embedding_x - 0.88, 2) + POWER(embedding_y - 0.12, 2) + POWER(embedding_z - 0.22, 2)) AS l2_distance,
           ROW_NUMBER() OVER (ORDER BY SQRT(POWER(embedding_x - 0.88, 2) + POWER(embedding_y - 0.12, 2) + POWER(embedding_z - 0.22, 2))) AS rank_no
    FROM simple_document_chunks
)
INSERT INTO rag_search_logs (question_text, query_vector_label, rank_no, retrieved_chunk_id, l2_distance, is_search_relevant, search_note)
SELECT '환불은 언제까지 가능한가요?', '[0.88,0.12,0.22]', rank_no, id, ROUND(l2_distance, 6), rank_no <= 2,
       CASE WHEN rank_no <= 2 THEN '환불 질문과 관련성이 높음' ELSE '구독 취소 문서이므로 보조 근거로만 사용' END
FROM ranked
WHERE rank_no <= 3;

CREATE TABLE rag_answer_reviews (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    review_case TEXT NOT NULL,
    question_text TEXT NOT NULL,
    generated_answer TEXT NOT NULL,
    evidence_chunk_id INTEGER NOT NULL REFERENCES simple_document_chunks(id),
    is_search_relevant BOOLEAN NOT NULL,
    has_answer_evidence BOOLEAN NOT NULL,
    has_unsupported_claim BOOLEAN NOT NULL,
    review_note TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO rag_answer_reviews
(review_case, question_text, generated_answer, evidence_chunk_id, is_search_relevant, has_answer_evidence, has_unsupported_claim, review_note) VALUES
('정상 답변', '환불은 언제까지 가능한가요?', '결제 후 7일 이내에는 전액 환불이 가능하며 이용 내역에 따라 제한될 수 있습니다.', 2, TRUE, TRUE, FALSE, '검색 문서와 답변 근거가 일치합니다.'),
('근거 없는 주장', '환불은 언제까지 가능한가요?', '결제 후 30일 이내에는 언제든 전액 환불됩니다.', 2, TRUE, FALSE, TRUE, '검색은 적합했지만 답변에 문서에 없는 30일 기준이 포함되었습니다.'),
('부적합 검색', '환불은 언제까지 가능한가요?', 'JOIN은 여러 테이블의 데이터를 연결해 조회할 때 사용합니다.', 7, FALSE, TRUE, FALSE, '답변은 선택된 문서에는 근거가 있지만 질문과 검색 문서가 맞지 않습니다.');

SELECT l.rank_no, c.title, c.source_name, c.chunk_no, l.l2_distance, l.is_search_relevant, l.search_note
FROM rag_search_logs l
JOIN simple_document_chunks c ON c.id = l.retrieved_chunk_id
ORDER BY l.rank_no;

SELECT r.review_case, c.title AS evidence_title, r.is_search_relevant, r.has_answer_evidence, r.has_unsupported_claim, r.review_note
FROM rag_answer_reviews r
JOIN simple_document_chunks c ON c.id = r.evidence_chunk_id
ORDER BY r.id;

SELECT 'normal_answer' AS check_name, COUNT(*) AS row_count
FROM rag_answer_reviews
WHERE is_search_relevant = TRUE AND has_answer_evidence = TRUE AND has_unsupported_claim = FALSE
UNION ALL
SELECT 'unsupported_claim', COUNT(*)
FROM rag_answer_reviews
WHERE is_search_relevant = TRUE AND has_answer_evidence = FALSE AND has_unsupported_claim = TRUE
UNION ALL
SELECT 'bad_retrieval', COUNT(*)
FROM rag_answer_reviews
WHERE is_search_relevant = FALSE AND has_answer_evidence = TRUE;

SELECT 'simple_document_chunks' AS table_name, COUNT(*) AS row_count FROM simple_document_chunks
UNION ALL
SELECT 'rag_search_logs', COUNT(*) FROM rag_search_logs
UNION ALL
SELECT 'rag_answer_reviews', COUNT(*) FROM rag_answer_reviews
ORDER BY table_name;
