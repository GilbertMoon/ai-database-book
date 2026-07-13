-- Chapter 14. 벡터 검색과 RAG로 근거 있는 답변 만들기
--
-- 이 파일은 기존 링크 호환용 안내·상태 확인 진입점입니다.
-- 기존 프로젝트 테이블을 삭제하거나 다시 만들지 않습니다.
-- rag_lab이 아직 생성되지 않은 상태에서도 안전하게 실행할 수 있습니다.
-- 실제 실습은 다음 파일을 순서대로 사용합니다.
--
-- 1. 01_rag_lab_schema.sql
-- 2. 02_rag_lab_seed.sql
-- 3. 03_manual_vector_search.sql
-- 4. 04_retrieval_evaluation.sql
-- 5. 05_rag_answer_reviews.sql
-- 6. 06_rag_lifecycle_checks.sql
-- 7. pgvector가 준비된 경우 07_pgvector_optional.sql 선택 실행
-- 8. RAG_EVALUATION_REPORT_TEMPLATE.md 기록
--
-- 처음부터 다시 시작할 때만 reset_rag_lab.sql을 사용합니다.

SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name;

-- vector 확장 사용 가능 여부와 현재 DB의 vector 타입 확인
SELECT
    name,
    default_version,
    installed_version
FROM pg_available_extensions
WHERE name = 'vector';

SELECT to_regtype('vector') AS vector_type_in_current_database;

-- 앞 장과 Chapter 14 스키마 존재 여부 확인
SELECT
    to_regnamespace('course_project') AS course_project_schema,
    to_regnamespace('transaction_lab') AS transaction_lab_schema,
    to_regnamespace('performance_lab') AS performance_lab_schema,
    to_regnamespace('security_lab') AS security_lab_schema,
    to_regnamespace('nosql_lab') AS nosql_lab_schema,
    to_regnamespace('ai_review_lab') AS ai_review_lab_schema,
    to_regnamespace('rag_lab') AS rag_lab_schema;

-- rag_lab 객체 확인
SELECT
    to_regclass('rag_lab.document_sources') AS document_sources_table,
    to_regclass('rag_lab.document_chunks') AS document_chunks_table,
    to_regclass('rag_lab.query_cases') AS query_cases_table,
    to_regclass('rag_lab.relevance_judgments') AS relevance_judgments_table,
    to_regclass('rag_lab.retrieval_runs') AS retrieval_runs_table,
    to_regclass('rag_lab.answer_reviews') AS answer_reviews_table;

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'rag_lab'
ORDER BY table_name;

-- 기준 행 수 조회는 01→05 파일을 실행한 뒤 사용합니다.
-- SELECT COUNT(*) FROM rag_lab.document_sources;      -- 7
-- SELECT COUNT(*) FROM rag_lab.document_chunks;       -- 9
-- SELECT COUNT(*) FROM rag_lab.query_cases;           -- 4
-- SELECT COUNT(*) FROM rag_lab.relevance_judgments;   -- 6
-- SELECT COUNT(*) FROM rag_lab.retrieval_runs;        -- 9
-- SELECT COUNT(*) FROM rag_lab.answer_reviews;        -- 4

-- CREATE EXTENSION, HNSW와 IVFFlat 인덱스는 자동 실행하지 않습니다.
-- Top-k 결과는 정답이 아니며, relevance judgments와 검색 지표로 평가합니다.
-- 권한·최신성 필터, 답변 근거·인용과 올바른 보류를 함께 검증합니다.
