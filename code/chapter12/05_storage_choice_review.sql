-- Chapter 12. 저장 방식 선택 검토
-- 실행 전 01, 02 파일을 실행합니다.
-- 이 파일은 저장소 선택 사례를 조회·검증하며 데이터를 변경하지 않습니다.

SELECT current_database();

-- 1. 전체 선택 사례
SELECT
    case_name,
    system_role,
    primary_query,
    candidate_storage,
    source_of_truth,
    consistency_requirement,
    synchronization_strategy,
    reason
FROM nosql_lab.storage_choice_cases
ORDER BY id;

-- 2. 시스템 역할별 건수
SELECT
    system_role,
    COUNT(*) AS case_count
FROM nosql_lab.storage_choice_cases
GROUP BY system_role
ORDER BY system_role;

-- 3. Source of Truth와 파생 저장소 구분
SELECT
    case_name,
    system_role,
    candidate_storage,
    source_of_truth,
    synchronization_strategy
FROM nosql_lab.storage_choice_cases
WHERE system_role <> 'source_of_truth'
ORDER BY case_name;

-- 4. 별도 동기화 전략이 필요한 사례
SELECT
    case_name,
    candidate_storage,
    synchronization_strategy
FROM nosql_lab.storage_choice_cases
WHERE system_role IN (
    'derived_cache',
    'event_log',
    'relationship_index',
    'flexible_metadata'
)
ORDER BY case_name;

-- 5. 선택 근거 필수값 검증: 기대 0행
SELECT *
FROM nosql_lab.storage_choice_cases
WHERE char_length(trim(primary_query)) = 0
   OR char_length(trim(candidate_storage)) = 0
   OR char_length(trim(source_of_truth)) = 0
   OR char_length(trim(consistency_requirement)) = 0
   OR char_length(trim(synchronization_strategy)) = 0
   OR char_length(trim(reason)) = 0;

-- 6. 기준 행 수와 역할 다양성 확인
SELECT
    COUNT(*) AS total_cases,
    COUNT(DISTINCT system_role) AS distinct_system_roles,
    COUNT(*) FILTER (
        WHERE system_role = 'source_of_truth'
    ) AS source_of_truth_cases,
    COUNT(*) FILTER (
        WHERE system_role <> 'source_of_truth'
    ) AS non_source_cases
FROM nosql_lab.storage_choice_cases;

-- 기대 결과: 6 / 6 / 1 / 5

-- 7. AI 추천 검토에 사용할 요약
SELECT
    case_name,
    candidate_storage,
    primary_query,
    consistency_requirement,
    synchronization_strategy
FROM nosql_lab.storage_choice_cases
ORDER BY id;
