-- Chapter 14. pgvector 선택 실습
-- 기본 실습은 pgvector 없이 01→06 파일로 완료할 수 있습니다.
-- 이 파일은 vector 확장이 서버에 준비되어 있고 테스트 DB에서 사용 권한이 있을 때만 선택 실행합니다.
-- CREATE EXTENSION과 객체 생성 문장은 기본 주석 상태입니다.

SELECT
    current_database() AS current_database_name,
    current_user AS current_user_name,
    current_schema() AS current_schema_name;

-- 1. 서버에서 vector 확장을 사용할 수 있는지 확인
SELECT
    name,
    default_version,
    installed_version
FROM pg_available_extensions
WHERE name = 'vector';

-- 2. 현재 DB에 vector 타입이 활성화되었는지 확인
SELECT to_regtype('vector') AS vector_type_in_current_database;

-- CREATE EXTENSION은 운영체제에 pgvector를 설치하지 않습니다.
-- 서버에 확장 파일이 있고 현재 DB에서 확장 생성 권한이 있을 때만 활성화합니다.
-- 운영 DB나 공유 DB에서는 임의로 실행하지 않습니다.
--
-- CREATE EXTENSION IF NOT EXISTS vector;

-- 3. vector(3) 비교 테이블 생성
-- 아래 전체 구간은 vector 타입이 활성화된 경우에만 선택 실행합니다.
--
-- CREATE TABLE rag_lab.vector_document_chunks (
--     chunk_id INTEGER PRIMARY KEY
--         REFERENCES rag_lab.document_chunks(id)
--         ON DELETE RESTRICT,
--     embedding vector(3) NOT NULL
-- );
--
-- INSERT INTO rag_lab.vector_document_chunks (
--     chunk_id,
--     embedding
-- )
-- SELECT
--     id,
--     (
--         '['
--         || embedding_x::TEXT || ','
--         || embedding_y::TEXT || ','
--         || embedding_z::TEXT
--         || ']'
--     )::vector(3)
-- FROM rag_lab.document_chunks;

-- 4. public 환불 질문 L2 Top-3
-- 권한·활성 상태 필터를 먼저 적용합니다.
--
-- SELECT
--     c.id AS chunk_id,
--     s.title,
--     v.embedding <-> '[0.88,0.12,0.22]'::vector(3)
--         AS l2_distance
-- FROM rag_lab.vector_document_chunks AS v
-- JOIN rag_lab.document_chunks AS c
--     ON c.id = v.chunk_id
-- JOIN rag_lab.document_sources AS s
--     ON s.id = c.source_id
-- WHERE s.is_active = TRUE
--   AND c.is_active = TRUE
--   AND s.access_scope = 'public'
-- ORDER BY v.embedding <-> '[0.88,0.12,0.22]'::vector(3), c.id
-- LIMIT 3;
--
-- 기대 순위: 103, 102, 101

-- 5. 코사인 거리와 코사인 유사도
--
-- SELECT
--     c.id AS chunk_id,
--     s.title,
--     v.embedding <=> '[0.88,0.12,0.22]'::vector(3)
--         AS cosine_distance,
--     1 - (
--         v.embedding <=> '[0.88,0.12,0.22]'::vector(3)
--     ) AS cosine_similarity
-- FROM rag_lab.vector_document_chunks AS v
-- JOIN rag_lab.document_chunks AS c
--     ON c.id = v.chunk_id
-- JOIN rag_lab.document_sources AS s
--     ON s.id = c.source_id
-- WHERE s.is_active = TRUE
--   AND c.is_active = TRUE
--   AND s.access_scope = 'public'
-- ORDER BY v.embedding <=> '[0.88,0.12,0.22]'::vector(3), c.id
-- LIMIT 3;

-- 6. 근사 인덱스 예시
-- 데이터가 9건뿐이므로 이 장에서는 생성하지 않습니다.
-- 실제 데이터와 정확 검색 기준으로 recall·속도·필터 결과를 비교한 뒤 적용합니다.
--
-- CREATE INDEX idx_rag_vector_chunks_hnsw_l2
-- ON rag_lab.vector_document_chunks
-- USING hnsw (embedding vector_l2_ops);
--
-- CREATE INDEX idx_rag_vector_chunks_ivfflat_l2
-- ON rag_lab.vector_document_chunks
-- USING ivfflat (embedding vector_l2_ops)
-- WITH (lists = 10);

-- 7. 선택 실습 정리
-- vector_document_chunks는 파생 데이터이므로 필요할 때 다음 문장을 직접 검토해 실행합니다.
-- DROP TABLE rag_lab.vector_document_chunks;
