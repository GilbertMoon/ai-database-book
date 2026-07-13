-- Chapter 04. students 실습 초기화
-- 주의: 이 파일은 students 테이블과 저장된 모든 데이터를 삭제합니다.
-- 실습을 처음부터 다시 시작해야 할 때만 실행합니다.

-- 1. 현재 위치 확인
SELECT current_database();
SELECT current_schema();

-- 기대 결과가 ai_database_book / public인지 반드시 확인한 뒤
-- 아래 DROP TABLE 문만 선택하여 실행합니다.

DROP TABLE IF EXISTS students;

-- 삭제 후 basic_crud.sql의 테이블 생성 구간부터 다시 실행합니다.
