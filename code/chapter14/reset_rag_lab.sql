-- Chapter 14. rag_lab 초기화
-- 주의: rag_lab 스키마와 실습 데이터만 삭제합니다.
-- 기존 프로젝트·앞 장 스키마·Role·vector 확장은 변경하지 않습니다.

SELECT
    current_user,
    current_database(),
    current_schema();

-- 현재 데이터베이스와 보존 대상을 확인한 뒤
-- 아래 DROP 구간만 선택 실행합니다.

DROP TABLE IF EXISTS rag_lab.vector_document_chunks;
DROP TABLE IF EXISTS rag_lab.answer_reviews;
DROP TABLE IF EXISTS rag_lab.retrieval_runs;
DROP TABLE IF EXISTS rag_lab.relevance_judgments;
DROP TABLE IF EXISTS rag_lab.query_cases;
DROP TABLE IF EXISTS rag_lab.document_chunks;
DROP TABLE IF EXISTS rag_lab.document_sources;
DROP SCHEMA IF EXISTS rag_lab;

-- 삭제 후 실행 순서:
-- 1. 01_rag_lab_schema.sql
-- 2. 02_rag_lab_seed.sql
-- 3. 03_manual_vector_search.sql
-- 4. 04_retrieval_evaluation.sql
-- 5. 05_rag_answer_reviews.sql
-- 6. 06_rag_lifecycle_checks.sql
-- 7. 필요 시 07_pgvector_optional.sql
