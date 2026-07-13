-- Chapter 06. 정규화 실습 초기화
-- 주의: 이 파일은 Chapter 06 실습 테이블과 데이터를 모두 삭제합니다.
-- 처음부터 다시 시작해야 할 때만 사용합니다.

-- 1. 현재 위치 확인
SELECT current_database();
SELECT current_schema();

-- 기대 결과가 ai_database_book / public인지 반드시 확인한 뒤
-- 아래 DROP TABLE 구간만 선택하여 실행합니다.

-- 외래키를 가진 자식 테이블을 먼저 삭제합니다.
DROP TABLE IF EXISTS loans_nf;
DROP TABLE IF EXISTS books_nf;
DROP TABLE IF EXISTS members_nf;
DROP TABLE IF EXISTS library_records_raw;

-- 삭제 후 다음 순서로 다시 실행합니다.
-- 1. normalization_schema.sql
-- 2. normalization_seed.sql
-- 3. normalization_practice.sql
-- 4. integrity_tests.sql에서 필요한 오류 테스트만 한 문장씩 실행
