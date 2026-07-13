-- Chapter 12. Key-Value 캐시 개념 시뮬레이션
-- 실행 전 01, 02 파일을 실행합니다.
-- 이 테이블은 실제 Key-Value DB의 TTL·복제·메모리 정책을 구현하지 않습니다.

SELECT current_database();

-- 1. 전체 캐시와 유효 여부
SELECT
    cache_key,
    source_name,
    expired_at,
    expired_at > CURRENT_TIMESTAMP AS is_valid
FROM nosql_lab.key_value_cache_examples
ORDER BY cache_key;

-- 2. 유효·만료 행 수
SELECT
    COUNT(*) AS total_cache_rows,
    COUNT(*) FILTER (
        WHERE expired_at > CURRENT_TIMESTAMP
    ) AS valid_cache_rows,
    COUNT(*) FILTER (
        WHERE expired_at <= CURRENT_TIMESTAMP
    ) AS expired_cache_rows
FROM nosql_lab.key_value_cache_examples;

-- 기대 결과: 4 / 3 / 1

-- 3. 정확한 키 조회와 만료 조건
SELECT
    cache_key,
    cache_value,
    expired_at
FROM nosql_lab.key_value_cache_examples
WHERE cache_key = 'student:101:session'
  AND expired_at > CURRENT_TIMESTAMP;

-- 4. 만료된 키는 행이 있어도 유효 캐시 조회에서는 제외됩니다.
SELECT
    cache_key,
    cache_value,
    expired_at
FROM nosql_lab.key_value_cache_examples
WHERE cache_key = 'student:9999:session'
  AND expired_at > CURRENT_TIMESTAMP;

-- 기대 결과: 0행

-- 5. 캐시 미스 시뮬레이션
WITH requested_key(cache_key) AS (
    VALUES ('course:popular:v2:top3')
)
SELECT
    r.cache_key AS requested_key,
    c.cache_value,
    CASE
        WHEN c.cache_key IS NULL THEN 'cache_miss'
        WHEN c.expired_at <= CURRENT_TIMESTAMP THEN 'expired'
        ELSE 'cache_hit'
    END AS cache_status
FROM requested_key AS r
LEFT JOIN nosql_lab.key_value_cache_examples AS c
    ON c.cache_key = r.cache_key;

-- cache_miss 이후 실제 서비스에서는 다음 흐름을 검토합니다.
-- 1. Source of Truth에서 데이터를 읽습니다.
-- 2. 중복 재생성을 줄이기 위한 잠금·요청 병합 정책을 확인합니다.
-- 3. TTL과 버전이 포함된 키로 캐시를 저장합니다.
-- 4. 사용자에게 결과를 반환합니다.

-- 6. 파생 캐시의 원본 위치 확인
SELECT
    cache_key,
    source_name,
    cache_value
FROM nosql_lab.key_value_cache_examples
WHERE cache_key LIKE 'course:popular:%';

-- 7. 만료 행 정리 문장은 자동 실행하지 않습니다.
-- expired_at은 자동 TTL 삭제 기능이 아닙니다.
-- DELETE FROM nosql_lab.key_value_cache_examples
-- WHERE expired_at <= CURRENT_TIMESTAMP;
