-- Chapter 05. 02 도서 대여 시스템 샘플 데이터
-- 시작 상태: 세 테이블이 존재하며 모두 비어 있음
-- 완료 상태: members 3행, books 3행, loans 4행
-- 샘플 관계를 쉽게 확인하기 위해 명시적 ID를 사용합니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

DO $$
DECLARE
    v_member_count bigint;
    v_book_count bigint;
    v_loan_count bigint;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '입력 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    IF current_setting('transaction_read_only')::boolean THEN
        RAISE EXCEPTION
            '입력 중단: 현재 연결이 읽기 전용입니다.';
    END IF;

    IF to_regclass('public.members') IS NULL
       OR to_regclass('public.books') IS NULL
       OR to_regclass('public.loans') IS NULL THEN
        RAISE EXCEPTION
            '입력 중단: Chapter 05 테이블이 모두 존재하지 않습니다. 01_library_schema.sql을 먼저 실행하세요.';
    END IF;

    SELECT COUNT(*) INTO v_member_count FROM public.members;
    SELECT COUNT(*) INTO v_book_count FROM public.books;
    SELECT COUNT(*) INTO v_loan_count FROM public.loans;

    IF v_member_count <> 0 OR v_book_count <> 0 OR v_loan_count <> 0 THEN
        RAISE EXCEPTION
            '입력 중단: 테이블이 비어 있지 않습니다. members=%, books=%, loans=%',
            v_member_count, v_book_count, v_loan_count;
    END IF;
END
$$;

INSERT INTO public.members (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', DATE '2026-03-01'),
    (102, '이준호', 'junho@example.com', DATE '2026-03-05'),
    (103, '박서연', 'seoyeon@example.com', DATE '2026-03-10');

INSERT INTO public.books (id, title, author, published_year, isbn)
VALUES
    (201, '데이터베이스 입문', '문길래', 2026, 'ISBN-001'),
    (202, 'SQL 기초', '홍길동', 2025, 'ISBN-002'),
    (203, 'ERD 설계 연습', '이몽룡', 2024, 'ISBN-003');

-- 도서 201의 첫 대여는 반납된 뒤 다음 날 다시 시작됩니다.
-- 샘플에서는 같은 도서의 동시 미반납 상태를 만들지 않습니다.
INSERT INTO public.loans (
    id,
    member_id,
    book_id,
    borrowed_at,
    due_at,
    returned_at
)
VALUES
    (1001, 101, 201, DATE '2026-04-01', DATE '2026-04-15', DATE '2026-04-02'),
    (1002, 101, 202, DATE '2026-04-02', DATE '2026-04-16', NULL),
    (1003, 102, 201, DATE '2026-04-03', DATE '2026-04-17', NULL),
    (1004, 103, 203, DATE '2026-04-05', DATE '2026-04-19', NULL);

-- 명시적 ID 입력은 IDENTITY의 다음 값을 자동으로 이동시키지 않습니다.
ALTER TABLE public.members
    ALTER COLUMN id RESTART WITH 104;

ALTER TABLE public.books
    ALTER COLUMN id RESTART WITH 204;

ALTER TABLE public.loans
    ALTER COLUMN id RESTART WITH 1005;

SELECT
    (SELECT COUNT(*) FROM public.members) AS member_count,
    (SELECT COUNT(*) FROM public.books) AS book_count,
    (SELECT COUNT(*) FROM public.loans) AS loan_count;
