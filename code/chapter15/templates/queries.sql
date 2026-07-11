-- Chapter 15. 실전 프로젝트 2 - queries.sql
-- 목적: 요구사항을 증명하는 조회, JOIN, 집계와 검증 SQL을 작성한다.
-- 실행 순서: schema.sql → seed.sql → queries.sql

-- ============================================================
-- 1. 기본 조회
-- ============================================================

SELECT id, name, email, role, created_at
FROM example_users
ORDER BY id;

SELECT id, title, status, created_at, updated_at
FROM example_items
ORDER BY id;

-- ============================================================
-- 2. 조건 조회
-- ============================================================

SELECT id, title, status
FROM example_items
WHERE status = 'active'
ORDER BY id;

-- ============================================================
-- 3. INNER JOIN: 관계가 있는 데이터만 조회
-- ============================================================

SELECT
    ui.id AS relation_id,
    u.id AS user_id,
    u.name AS user_name,
    i.id AS item_id,
    i.title AS item_title,
    ui.relation_role,
    ui.created_at
FROM example_user_items AS ui
JOIN example_users AS u ON ui.user_id = u.id
JOIN example_items AS i ON ui.item_id = i.id
ORDER BY ui.id;

-- ============================================================
-- 4. LEFT JOIN과 집계: 관계가 없는 사용자도 포함
-- ============================================================

SELECT
    u.id,
    u.name,
    COUNT(ui.id) AS item_count
FROM example_users AS u
LEFT JOIN example_user_items AS ui ON ui.user_id = u.id
GROUP BY u.id, u.name
ORDER BY item_count DESC, u.id;

-- COUNT(*)를 사용하면 관계가 없는 사용자의 가상 행도 1로 셀 수 있다.
-- LEFT JOIN 집계에서는 자식 테이블의 실제 PK인 COUNT(ui.id)를 사용하는 것이 안전하다.

-- ============================================================
-- 5. 상태별 집계
-- ============================================================

SELECT
    status,
    COUNT(*) AS item_count
FROM example_items
GROUP BY status
ORDER BY status;

-- ============================================================
-- 6. 검증 쿼리: 어떤 사용자와도 연결되지 않은 항목
-- ============================================================

SELECT
    i.id,
    i.title,
    i.status
FROM example_items AS i
LEFT JOIN example_user_items AS ui ON ui.item_id = i.id
WHERE ui.id IS NULL
ORDER BY i.id;

-- ============================================================
-- 7. 검증 쿼리: 어떤 항목과도 연결되지 않은 사용자
-- ============================================================

SELECT
    u.id,
    u.name,
    u.email
FROM example_users AS u
LEFT JOIN example_user_items AS ui ON ui.user_id = u.id
WHERE ui.id IS NULL
ORDER BY u.id;

-- ============================================================
-- 8. 검증 쿼리: 외래키 관계 확인
-- ============================================================
-- FK가 정상적으로 설정되어 있다면 아래 결과는 0건이어야 한다.
-- 제약조건을 비활성화하거나 외부 데이터 적재를 사용한 경우 점검에 활용할 수 있다.

SELECT
    ui.id,
    ui.user_id,
    ui.item_id
FROM example_user_items AS ui
LEFT JOIN example_users AS u ON ui.user_id = u.id
LEFT JOIN example_items AS i ON ui.item_id = i.id
WHERE u.id IS NULL OR i.id IS NULL;

-- ============================================================
-- 9. 안전한 UPDATE 흐름 예시
-- ============================================================
-- 실제 변경 전 같은 조건으로 대상을 먼저 조회한다.

SELECT id, title, status
FROM example_items
WHERE id = 2;

-- 필요할 때만 실행한다.
-- UPDATE example_items
-- SET status = 'inactive',
--     updated_at = CURRENT_TIMESTAMP
-- WHERE id = 2;

-- 변경 후 다시 같은 조건으로 확인한다.
-- SELECT id, title, status, updated_at
-- FROM example_items
-- WHERE id = 2;

-- ============================================================
-- 10. 실제 프로젝트 핵심 SQL 작성 영역
-- ============================================================
-- 각 SQL 위에 어떤 요구사항을 확인하는지 주석을 남긴다.

-- 요구사항:
-- SELECT ...

-- ============================================================
-- 11. SQL 점검
-- ============================================================
-- 1. 주요 테이블의 기본 조회가 있는가?
-- 2. 실제 검색 기능을 재현하는 조건 조회가 있는가?
-- 3. 필요한 정보를 연결하는 JOIN이 있는가?
-- 4. LEFT JOIN에서 COUNT(*)와 COUNT(child.id)의 차이를 검토했는가?
-- 5. GROUP BY 또는 집계 SQL이 있는가?
-- 6. 최근·상위 데이터를 위한 ORDER BY와 LIMIT가 필요한가?
-- 7. 누락, 불일치 또는 업무 규칙 위반을 찾는 검증 SQL이 있는가?
-- 8. UPDATE와 DELETE 전에 대상 확인 SELECT가 있는가?
-- 9. 실행 결과가 어떤 요구사항을 증명하는지 설명할 수 있는가?
