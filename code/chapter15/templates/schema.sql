-- Chapter 15 최종 프로젝트 schema.sql
-- 목적: 프로젝트에 필요한 테이블을 생성한다.
-- 주의: 운영 DB가 아닌 실습 DB에서 실행하세요.

-- ============================================================
-- 1. 기존 테이블 삭제
-- ============================================================
-- 외래키 관계가 있는 경우 자식 테이블부터 삭제합니다.

-- DROP TABLE IF EXISTS example_child_tables;
-- DROP TABLE IF EXISTS example_parent_tables;

-- ============================================================
-- 2. 테이블 생성 예시
-- ============================================================
-- 아래 예시는 참고용입니다. 프로젝트 주제에 맞게 수정하세요.

CREATE TABLE example_users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE example_items (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE example_user_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES example_users(id),
    item_id INTEGER NOT NULL REFERENCES example_items(id),
    relation_status VARCHAR(20) NOT NULL DEFAULT 'created'
        CHECK (relation_status IN ('created', 'updated', 'deleted')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, item_id)
);

-- ============================================================
-- 3. 프로젝트 테이블 작성 공간
-- ============================================================
-- 아래에 자신의 프로젝트 테이블을 작성하세요.

-- CREATE TABLE ...

-- ============================================================
-- 4. 설계 점검 메모
-- ============================================================
-- 확인할 항목:
-- 1. 모든 핵심 테이블에 PRIMARY KEY가 있는가?
-- 2. 필요한 FOREIGN KEY가 설정되어 있는가?
-- 3. 필수 컬럼에 NOT NULL이 있는가?
-- 4. 중복 금지가 필요한 컬럼에 UNIQUE가 있는가?
-- 5. 상태값, 금액, 수량 등에 CHECK가 있는가?
-- 6. TEXT를 남용하지 않고 적절한 타입을 사용했는가?
