-- Chapter 05. 도서 대여 시스템 초기화
-- 주의: 이 파일은 public.members, public.books, public.loans 테이블과 저장된 데이터를 모두 삭제합니다.
-- 실습을 처음부터 다시 시작해야 할 때만 사용합니다.

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

    -- 외래키를 가진 자식 테이블을 먼저 삭제합니다.
    DROP TABLE IF EXISTS public.loans;
    DROP TABLE IF EXISTS public.books;
    DROP TABLE IF EXISTS public.members;
END
$$;

-- 삭제 후 다음 순서로 다시 실행합니다.
-- 1. library_schema.sql
-- 2. library_seed.sql
-- 3. library_validation.sql
