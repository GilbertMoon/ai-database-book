-- Chapter 15. 선택적 RAG 원문 후보 뷰
-- 필수 프로젝트 완료 후, 학습 자료 의미 검색 요구사항이 있을 때만 실행합니다.
-- pgvector·임베딩·외부 API를 생성하거나 호출하지 않습니다.

SELECT current_database();

CREATE OR REPLACE VIEW tutor_project.rag_source_documents AS
SELECT
    id AS material_id,
    material_code AS document_key,
    title,
    content_summary AS source_text,
    material_type,
    source_url,
    access_scope,
    source_version,
    content_hash,
    updated_at
FROM tutor_project.learning_materials
WHERE is_active = TRUE;

-- public 사용자가 색인 후보로 사용할 수 있는 원문
SELECT
    document_key,
    title,
    source_text,
    access_scope,
    source_version,
    content_hash,
    updated_at
FROM tutor_project.rag_source_documents
WHERE access_scope = 'public'
ORDER BY document_key;

-- internal 사용자는 public+internal 범위를 사용할 수 있습니다.
SELECT
    document_key,
    title,
    access_scope
FROM tutor_project.rag_source_documents
WHERE access_scope IN ('public', 'internal')
ORDER BY document_key;

-- 기대:
-- 비활성 MAT-OLD-01은 뷰에 포함되지 않습니다.
-- public 검색 후보에는 internal MAT-TX-01이 포함되지 않습니다.

SELECT
    COUNT(*) AS active_rag_sources_expected_5,
    COUNT(*) FILTER (
        WHERE access_scope = 'public'
    ) AS public_rag_sources_expected_4,
    COUNT(*) FILTER (
        WHERE access_scope = 'internal'
    ) AS internal_rag_sources_expected_1
FROM tutor_project.rag_source_documents;

-- 다음 단계는 별도 파생 파이프라인입니다.
-- 1. source_version·content_hash로 변경 감지
-- 2. 청킹 기준과 임베딩 모델·버전 기록
-- 3. 접근 범위를 검색 후보 단계에서 적용
-- 4. 정답 집합으로 검색 품질 평가
-- 5. 답변 근거·인용·보류 검증
-- 6. 원문 변경 시 재청킹·재임베딩
