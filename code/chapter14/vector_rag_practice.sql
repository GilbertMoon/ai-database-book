-- Chapter 14. Vector DB와 RAG 기초
-- 목적: pgvector 또는 단순 3차원 벡터 계산을 통해 의미 기반 검색과 RAG 흐름을 이해한다.
-- 핵심: RAG는 문서 검색 품질과 근거 검토가 중요하다.

-- ============================================================
-- 실행 전 주의 사항
-- ============================================================
-- 1. 이 파일은 실습용 예제입니다.
-- 2. 운영 데이터베이스에서 실행하지 마세요.
-- 3. pgvector가 설치되어 있으면 Section A를 실행할 수 있습니다.
-- 4. pgvector가 설치되어 있지 않아도 Section B의 대체 실습을 실행할 수 있습니다.
-- 5. 실제 개인정보나 민감 문서는 사용하지 않습니다.

-- ============================================================
-- Section A. pgvector 사용 실습
-- ============================================================
-- 아래 구문은 PostgreSQL에 pgvector 확장이 설치되어 있어야 실행됩니다.
-- 설치되어 있지 않은 환경에서는 Section B로 이동하세요.

-- CREATE EXTENSION IF NOT EXISTS vector;

-- DROP TABLE IF EXISTS rag_document_embeddings;

-- CREATE TABLE rag_document_embeddings (
--     id SERIAL PRIMARY KEY,
--     title VARCHAR(200) NOT NULL,
--     chunk_text TEXT NOT NULL,
--     source_name VARCHAR(200) NOT NULL,
--     chunk_no INTEGER NOT NULL,
--     embedding vector(3) NOT NULL
-- );

-- INSERT INTO rag_document_embeddings (title, chunk_text, source_name, chunk_no, embedding)
-- VALUES
-- ('프로젝트 자료 안내', '프로젝트 자료는 정해진 위치에 정리해 두어야 합니다.', 'service_notice.md', 1, '[0.10, 0.80, 0.20]'),
-- ('서비스 업데이트 안내', '서비스 업데이트에는 변경 내용과 검증 결과를 함께 정리합니다.', 'service_notice.md', 2, '[0.20, 0.75, 0.25]'),
-- ('구독 취소와 환불', '구독 취소와 환불은 서비스 약관에 따라 처리됩니다.', 'service_notice.md', 3, '[0.90, 0.10, 0.20]'),
-- ('고객 문의 안내', '문의는 고객지원 페이지 또는 이메일로 남길 수 있습니다.', 'service_notice.md', 4, '[0.25, 0.25, 0.85]'),
-- ('SQL JOIN 복습', 'JOIN은 여러 테이블의 데이터를 연결해 조회할 때 사용합니다.', 'sql_review.md', 1, '[0.15, 0.30, 0.90]');

-- 질문 예시: "서비스 업데이트에는 무엇을 정리해야 하나요?"
-- 질문 벡터를 [0.18, 0.78, 0.22]라고 가정한다.

-- SELECT
--     id,
--     title,
--     chunk_text,
--     source_name,
--     chunk_no,
--     embedding <-> '[0.18, 0.78, 0.22]' AS distance
-- FROM rag_document_embeddings
-- ORDER BY embedding <-> '[0.18, 0.78, 0.22]'
-- LIMIT 3;

-- ============================================================
-- Section B. pgvector 없이 실행 가능한 3차원 벡터 대체 실습
-- ============================================================
-- 이 섹션은 pgvector가 없어도 실행됩니다.
-- embedding_x, embedding_y, embedding_z 컬럼으로 단순 벡터를 표현합니다.

DROP TABLE IF EXISTS rag_answer_reviews;
DROP TABLE IF EXISTS rag_search_logs;
DROP TABLE IF EXISTS simple_document_chunks;

CREATE TABLE simple_document_chunks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    chunk_text TEXT NOT NULL,
    source_name VARCHAR(200) NOT NULL,
    chunk_no INTEGER NOT NULL,
    embedding_x NUMERIC(8, 4) NOT NULL,
    embedding_y NUMERIC(8, 4) NOT NULL,
    embedding_z NUMERIC(8, 4) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (source_name, chunk_no)
);

INSERT INTO simple_document_chunks (
    title,
    chunk_text,
    source_name,
    chunk_no,
    embedding_x,
    embedding_y,
    embedding_z
)
VALUES
('프로젝트 자료 안내', '프로젝트 자료는 정해진 위치에 정리해 두어야 합니다.', 'service_notice.md', 1, 0.10, 0.80, 0.20),
('서비스 업데이트 안내', '서비스 업데이트에는 변경 내용과 검증 결과를 함께 정리합니다.', 'service_notice.md', 2, 0.20, 0.75, 0.25),
('구독 취소와 환불', '구독 취소와 환불은 서비스 약관에 따라 처리됩니다.', 'service_notice.md', 3, 0.90, 0.10, 0.20),
('고객 문의 안내', '문의는 고객지원 페이지 또는 이메일로 남길 수 있습니다.', 'service_notice.md', 4, 0.25, 0.25, 0.85),
('SQL JOIN 복습', 'JOIN은 여러 테이블의 데이터를 연결해 조회할 때 사용합니다.', 'sql_review.md', 1, 0.15, 0.30, 0.90),
('Vector DB 설명', 'Vector DB는 임베딩 벡터를 저장하고 유사도 검색을 수행합니다.', 'ai_db_note.md', 1, 0.70, 0.20, 0.60),
('RAG 기본 흐름', 'RAG는 관련 문서를 검색한 뒤 그 문서를 근거로 답변을 생성합니다.', 'ai_db_note.md', 2, 0.72, 0.25, 0.58);

-- ============================================================
-- 1. 저장된 문서 청크 확인
-- ============================================================

SELECT
    id,
    title,
    source_name,
    chunk_no,
    chunk_text
FROM simple_document_chunks
ORDER BY id;

-- ============================================================
-- 2. 질문 벡터와 가까운 문서 검색
-- ============================================================
-- 질문: "서비스 업데이트에는 무엇을 정리해야 하나요?"
-- 질문 벡터 예시: [0.18, 0.78, 0.22]
-- 거리 계산: sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2)

SELECT
    id,
    title,
    chunk_text,
    source_name,
    chunk_no,
    SQRT(
        POWER(embedding_x - 0.18, 2) +
        POWER(embedding_y - 0.78, 2) +
        POWER(embedding_z - 0.22, 2)
    ) AS distance
FROM simple_document_chunks
ORDER BY distance ASC
LIMIT 3;

-- ============================================================
-- 3. 다른 질문 벡터로 검색하기
-- ============================================================
-- 질문: "구독을 취소하면 환불은 어떻게 되나요?"
-- 질문 벡터 예시: [0.88, 0.12, 0.22]

SELECT
    id,
    title,
    chunk_text,
    source_name,
    chunk_no,
    SQRT(
        POWER(embedding_x - 0.88, 2) +
        POWER(embedding_y - 0.12, 2) +
        POWER(embedding_z - 0.22, 2)
    ) AS distance
FROM simple_document_chunks
ORDER BY distance ASC
LIMIT 3;

-- 질문: "JOIN은 언제 사용하나요?"
-- 질문 벡터 예시: [0.12, 0.32, 0.88]

SELECT
    id,
    title,
    chunk_text,
    source_name,
    chunk_no,
    SQRT(
        POWER(embedding_x - 0.12, 2) +
        POWER(embedding_y - 0.32, 2) +
        POWER(embedding_z - 0.88, 2)
    ) AS distance
FROM simple_document_chunks
ORDER BY distance ASC
LIMIT 3;

-- ============================================================
-- 4. RAG 검색 로그 테이블
-- ============================================================
-- 실제 RAG 시스템에서는 어떤 질문에 어떤 문서가 검색되었는지 기록하면 품질 검토에 도움이 됩니다.

CREATE TABLE rag_search_logs (
    id SERIAL PRIMARY KEY,
    user_question TEXT NOT NULL,
    query_vector_x NUMERIC(8, 4) NOT NULL,
    query_vector_y NUMERIC(8, 4) NOT NULL,
    query_vector_z NUMERIC(8, 4) NOT NULL,
    retrieved_chunk_id INTEGER NOT NULL REFERENCES simple_document_chunks(id),
    distance NUMERIC(10, 6) NOT NULL,
    rank_no INTEGER NOT NULL CHECK (rank_no > 0),
    searched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO rag_search_logs (
    user_question,
    query_vector_x,
    query_vector_y,
    query_vector_z,
    retrieved_chunk_id,
    distance,
    rank_no
)
SELECT
    '서비스 업데이트에는 무엇을 정리해야 하나요?' AS user_question,
    0.18,
    0.78,
    0.22,
    id AS retrieved_chunk_id,
    SQRT(
        POWER(embedding_x - 0.18, 2) +
        POWER(embedding_y - 0.78, 2) +
        POWER(embedding_z - 0.22, 2)
    ) AS distance,
    ROW_NUMBER() OVER (
        ORDER BY SQRT(
            POWER(embedding_x - 0.18, 2) +
            POWER(embedding_y - 0.78, 2) +
            POWER(embedding_z - 0.22, 2)
        )
    ) AS rank_no
FROM simple_document_chunks
ORDER BY distance ASC
LIMIT 3;

SELECT
    l.user_question,
    l.rank_no,
    c.title,
    c.chunk_text,
    l.distance
FROM rag_search_logs l
JOIN simple_document_chunks c ON l.retrieved_chunk_id = c.id
ORDER BY l.user_question, l.rank_no;

-- ============================================================
-- 5. RAG 답변 검토 테이블
-- ============================================================
-- RAG는 답변만 판단하면 안 됩니다.
-- 검색된 문서가 적절했는지, 답변이 문서에 근거했는지 함께 검토해야 합니다.

CREATE TABLE rag_answer_reviews (
    id SERIAL PRIMARY KEY,
    user_question TEXT NOT NULL,
    generated_answer TEXT NOT NULL,
    evidence_chunk_id INTEGER NOT NULL REFERENCES simple_document_chunks(id),
    is_retrieval_relevant BOOLEAN NOT NULL,
    is_answer_grounded BOOLEAN NOT NULL,
    has_unsupported_claim BOOLEAN NOT NULL,
    reviewer_note TEXT,
    reviewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO rag_answer_reviews (
    user_question,
    generated_answer,
    evidence_chunk_id,
    is_retrieval_relevant,
    is_answer_grounded,
    has_unsupported_claim,
    reviewer_note
)
VALUES
(
    '서비스 업데이트에는 무엇을 정리해야 하나요?',
    '서비스 업데이트에는 변경 내용과 검증 결과를 함께 정리해야 합니다.',
    2,
    TRUE,
    TRUE,
    FALSE,
    '검색된 문서 내용에 근거한 답변입니다.'
),
(
    '서비스 업데이트에는 무엇을 정리해야 하나요?',
    '서비스 업데이트에는 변경 내용, 검증 결과, 본인 확인 서류와 결제 영수증을 함께 정리해야 합니다.',
    2,
    TRUE,
    FALSE,
    TRUE,
    '본인 확인 서류와 결제 영수증은 검색 문서에 없는 내용입니다.'
);

SELECT
    r.user_question,
    c.title AS evidence_title,
    r.generated_answer,
    r.is_retrieval_relevant,
    r.is_answer_grounded,
    r.has_unsupported_claim,
    r.reviewer_note
FROM rag_answer_reviews r
JOIN simple_document_chunks c ON r.evidence_chunk_id = c.id
ORDER BY r.id;

-- ============================================================
-- 6. RAG 품질 점검 쿼리
-- ============================================================

-- 6-1. 검색 결과가 질문과 관련 없다고 판단된 사례
SELECT *
FROM rag_answer_reviews
WHERE is_retrieval_relevant = FALSE;

-- 6-2. 답변이 근거 문서에 충실하지 않은 사례
SELECT *
FROM rag_answer_reviews
WHERE is_answer_grounded = FALSE;

-- 6-3. 검색 문서에 없는 내용을 추가한 사례
SELECT *
FROM rag_answer_reviews
WHERE has_unsupported_claim = TRUE;

-- ============================================================
-- 7. RAG 설계 검토 메모
-- ============================================================
-- 다음 항목은 RAG 시스템 설계 시 반드시 확인해야 합니다.
-- 1. 문서 청킹 기준이 적절한가?
-- 2. 문서 원문과 임베딩 벡터를 함께 관리하는가?
-- 3. 질문 벡터와 문서 벡터의 유사도 검색 결과를 기록하는가?
-- 4. 검색된 문서가 질문과 관련 있는지 검토하는가?
-- 5. 답변이 검색 문서를 근거로 하는지 검토하는가?
-- 6. 검색 문서에 없는 내용을 LLM이 추가하지 않았는가?
-- 7. 문서가 변경되면 임베딩을 다시 생성하는 흐름이 있는가?
-- 8. 민감정보가 검색 결과와 답변에 노출되지 않도록 관리하는가?

-- ============================================================
-- 8. 정리용 조회
-- ============================================================

SELECT 'document chunks' AS item, COUNT(*) AS count
FROM simple_document_chunks
UNION ALL
SELECT 'search logs' AS item, COUNT(*) AS count
FROM rag_search_logs
UNION ALL
SELECT 'answer reviews' AS item, COUNT(*) AS count
FROM rag_answer_reviews;
