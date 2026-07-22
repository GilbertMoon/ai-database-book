-- Chapter 04. students 실습 초기화
-- 주의: 이 파일은 public.students 테이블과 저장된 모든 데이터를 삭제합니다.
-- 실습을 처음부터 다시 시작해야 할 때만 사용합니다.
-- 파일 전체를 무조건 실행하지 말고 아래 보호 구문의 의미를 확인합니다.

-- 현재 위치 확인
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 안전 보호 구문
-- ai_database_book 데이터베이스의 public 스키마가 아니면 예외를 발생시키며
-- DROP TABLE을 실행하지 않습니다.
DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '초기화 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    IF current_schema() <> 'public' THEN
        RAISE EXCEPTION
            '초기화 중단: 현재 스키마는 %입니다. public 스키마를 확인하세요.',
            current_schema();
    END IF;

    DROP TABLE IF EXISTS public.students;
END
$$;

-- 삭제 후 basic_crud.sql의 테이블 생성 구간과 입력 구간까지만 다시 실행합니다.
