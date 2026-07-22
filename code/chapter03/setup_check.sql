-- Chapter 03. PostgreSQL 실습 환경 확인
-- 목적: PostgreSQL 서버, 현재 데이터베이스, 스키마, 검색 경로, 사용자와 SQL 실행 상태를 확인합니다.
-- 이 파일은 데이터를 변경하지 않는 조회문만 포함하므로 여러 번 안전하게 실행할 수 있습니다.

-- 1. PostgreSQL 서버 버전 확인
SELECT version();

-- 2. 현재 연결된 데이터베이스 확인
-- 로컬 필수 경로의 기대 결과: ai_database_book
SELECT current_database();

-- 3. 현재 스키마 확인
-- 로컬 필수 경로의 일반적인 기대 결과: public
SELECT current_schema();

-- 4. 스키마 검색 순서 확인
SHOW search_path;

-- 5. 현재 접속 사용자 확인
SELECT current_user;

-- 6. PostgreSQL이 현재 트랜잭션의 시각 값을 정상적으로 반환하는지 확인
-- CURRENT_TIMESTAMP는 같은 트랜잭션 안에서 트랜잭션 시작 시각을 반환합니다.
SELECT CURRENT_TIMESTAMP AS checked_at;

-- 7. SQL 편집기 실행과 결과 표시 확인
-- 기대 결과: 2
SELECT 1 + 1 AS result;
