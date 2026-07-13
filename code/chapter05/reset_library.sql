-- Chapter 05. 도서 대여 시스템 초기화
-- 주의: 이 파일은 members, books, loans 테이블과 저장된 데이터를 모두 삭제합니다.
-- 실습을 처음부터 다시 시작해야 할 때만 사용합니다.

-- 1. 현재 위치 확인
SELECT current_database();
SELECT current_schema();

-- 기대 결과가 ai_database_book / public인지 반드시 확인한 뒤
-- 아래 DROP TABLE 구간만 선택하여 실행합니다.

-- 외래키를 가진 자식 테이블을 먼저 삭제합니다.
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;

-- 삭제 후 다음 순서로 다시 실행합니다.
-- 1. library_schema.sql
-- 2. library_seed.sql
-- 3. library_validation.sql
