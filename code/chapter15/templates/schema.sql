-- Chapter 15. 실전 프로젝트 2 - schema.sql
-- 목적: 프로젝트의 테이블, 관계와 제약조건을 PostgreSQL에 구현한다.
-- 주의: 운영 DB가 아닌 별도의 작업용 또는 테스트용 DB에서 실행한다.

-- 현재 연결 대상을 먼저 확인한다.
SELECT current_database() AS current_database_name;
SELECT current_schema() AS current_schema_name;

-- ============================================================
-- 1. 예제 테이블 초기화
-- ============================================================
-- 외래키로 참조하는 자식 테이블부터 삭제한다.
-- 아래 example_* 테이블은 템플릿 구조를 설명하기 위한 가상 예제이다.

DROP TABLE IF EXISTS example_user_items;
DROP TABLE IF EXISTS example_items;
DROP TABLE IF EXISTS example_users;

-- ============================================================
-- 2. 예제 사용자 테이블
-- ============================================================

CREATE TABLE example_users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'manager', 'admin')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. 예제 항목 테이블
-- ============================================================

CREATE TABLE example_items (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'archived')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. N:M 관계를 표현하는 예제 중간 테이블
-- ============================================================

CREATE TABLE example_user_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES example_users(id),
    item_id INTEGER NOT NULL REFERENCES example_items(id),
    relation_role VARCHAR(20) NOT NULL DEFAULT 'member'
        CHECK (relation_role IN ('member', 'owner', 'viewer')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, item_id)
);

-- ============================================================
-- 5. 생성 결과 확인
-- ============================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = current_schema()
  AND table_name LIKE 'example_%'
ORDER BY table_name;

-- ============================================================
-- 6. 실제 프로젝트 작성 영역
-- ============================================================
-- 위 example_* 테이블을 참고하되, 프로젝트 요구사항에 맞는 이름과 구조로 교체한다.
-- 예제 테이블과 실제 프로젝트 테이블을 함께 유지할 필요는 없다.

-- DROP TABLE IF EXISTS child_table;
-- DROP TABLE IF EXISTS parent_table;
--
-- CREATE TABLE parent_table (
--     id SERIAL PRIMARY KEY
-- );
--
-- CREATE TABLE child_table (
--     id SERIAL PRIMARY KEY,
--     parent_id INTEGER NOT NULL REFERENCES parent_table(id)
-- );

-- ============================================================
-- 7. 설계 점검
-- ============================================================
-- 1. 요구사항의 핵심 엔터티가 모두 테이블로 표현되었는가?
-- 2. 모든 핵심 테이블에 PRIMARY KEY가 있는가?
-- 3. 필요한 관계가 FOREIGN KEY로 보호되는가?
-- 4. 필수 값에 NOT NULL이 있는가?
-- 5. 중복 금지 값에 UNIQUE가 있는가?
-- 6. 상태, 금액, 수량에 CHECK가 필요한가?
-- 7. DEFAULT가 데이터 오류를 숨기지 않는가?
-- 8. 날짜, 금액, 본문에 적절한 데이터 타입을 사용했는가?
-- 9. 삭제 시 보존해야 할 이력과 참조 동작을 검토했는가?
-- 10. ERD와 이 파일의 테이블 및 컬럼 이름이 일치하는가?
