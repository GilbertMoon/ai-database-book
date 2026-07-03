-- Chapter 15 최종 프로젝트 queries.sql
-- 목적: 핵심 조회, JOIN, 집계, 검증 SQL을 작성한다.
-- 실행 순서: schema.sql → seed.sql → queries.sql

-- ============================================================
-- 1. 기본 조회
-- ============================================================

SELECT *
FROM example_users
ORDER BY id;

SELECT *
FROM example_items
ORDER BY id;

-- ============================================================
-- 2. 조건 조회
-- ============================================================

SELECT *
FROM example_items
WHERE status = 'active'
ORDER BY id;

-- ============================================================
-- 3. JOIN 조회
-- ============================================================

SELECT
    u.name AS user_name,
    u.email,
    i.title AS item_title,
    ui.relation_status,
    ui.created_at
FROM example_user_items ui
JOIN example_users u ON ui.user_id = u.id
JOIN example_items i ON ui.item_id = i.id
ORDER BY ui.created_at DESC;

-- ============================================================
-- 4. 집계 조회
-- ============================================================

SELECT
    u.name AS user_name,
    COUNT(ui.id) AS item_count
FROM example_users u
LEFT JOIN example_user_items ui ON u.id = ui.user_id
GROUP BY u.id, u.name
ORDER BY item_count DESC;

-- ============================================================
-- 5. 검증 쿼리
-- ============================================================
-- 데이터 정합성에 문제가 있는지 확인하는 쿼리를 작성하세요.

-- 예: 관계 데이터가 없는 항목 확인
SELECT
    i.id,
    i.title
FROM example_items i
LEFT JOIN example_user_items ui ON i.id = ui.item_id
WHERE ui.id IS NULL;

-- ============================================================
-- 6. 프로젝트 핵심 SQL 작성 공간
-- ============================================================
-- 아래에 자신의 프로젝트 핵심 SQL을 작성하세요.

-- SELECT ...

-- ============================================================
-- 7. SQL 점검 메모
-- ============================================================
-- 확인할 항목:
-- 1. 기본 조회 SQL이 있는가?
-- 2. 조건 조회 SQL이 있는가?
-- 3. JOIN SQL이 있는가?
-- 4. GROUP BY 또는 집계 SQL이 있는가?
-- 5. 데이터 오류 또는 누락을 찾는 검증 쿼리가 있는가?
