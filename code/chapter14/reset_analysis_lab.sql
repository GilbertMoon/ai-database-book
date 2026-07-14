-- Chapter 14. analysis_lab 초기화
-- 주의: analysis_lab의 VIEW와 테이블, 데이터가 모두 삭제됩니다.
-- 처음부터 다시 시작해야 할 때만 대상 스키마를 확인한 뒤 선택 실행합니다.

SELECT current_database();
SELECT current_user;

DROP SCHEMA analysis_lab CASCADE;

-- 초기화 후 01_analysis_lab_schema.sql부터 다시 실행합니다.
