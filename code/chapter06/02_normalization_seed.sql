-- Chapter 06. 02 정규화 전·후 정상 샘플 입력
-- 시작 상태: 01_normalization_schema.sql 실행 완료, 네 테이블이 모두 비어 있음
-- 완료 상태: raw 3행, members 2행, books 2행, loans 3행
-- 관계를 쉽게 확인하기 위해 명시적 실습 ID를 사용합니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

DO $$
DECLARE
    v_raw_count bigint;
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
        RAISE EXCEPTION '입력 중단: 현재 연결이 읽기 전용입니다.';
    END IF;

    IF to_regclass('public.library_records_raw') IS NULL
       OR to_regclass('public.members_nf') IS NULL
       OR to_regclass('public.books_nf') IS NULL
       OR to_regclass('public.loans_nf') IS NULL THEN
        RAISE EXCEPTION
            '입력 중단: Chapter 06 테이블이 모두 존재하지 않습니다.';
    END IF;

    SELECT COUNT(*) INTO v_raw_count FROM public.library_records_raw;
    SELECT COUNT(*) INTO v_member_count FROM public.members_nf;
    SELECT COUNT(*) INTO v_book_count FROM public.books_nf;
    SELECT COUNT(*) INTO v_loan_count FROM public.loans_nf;

    IF v_raw_count <> 0
       OR v_member_count <> 0
       OR v_book_count <> 0
       OR v_loan_count <> 0 THEN
        RAISE EXCEPTION
            '입력 중단: 빈 테이블이 아닙니다. raw=%, members=%, books=%, loans=%',
            v_raw_count, v_member_count, v_book_count, v_loan_count;
    END IF;
END
$$;

INSERT INTO public.library_records_raw (
    loan_id,
    member_name,
    member_email,
    book_title,
    author,
    borrowed_at,
    due_at,
    returned_at
)
VALUES
    (1001, '김민지', 'minji@example.com', '데이터베이스 입문', '문길래', '2026-04-01', '2026-04-15', '2026-04-02'),
    (1002, '김민지', 'minji@example.com', 'SQL 기초', '홍길동', '2026-04-02', '2026-04-16', NULL),
    (1003, '이준호', 'junho@example.com', '데이터베이스 입문', '문길래', '2026-04-03', '2026-04-17', NULL);

INSERT INTO public.members_nf (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-05');

INSERT INTO public.books_nf (id, title, author, published_year, isbn)
VALUES
    (201, '데이터베이스 입문', '문길래', 2026, 'ISBN-001'),
    (202, 'SQL 기초', '홍길동', 2025, 'ISBN-002');

INSERT INTO public.loans_nf (
    id,
    member_id,
    book_id,
    borrowed_at,
    due_at,
    returned_at
)
VALUES
    (1001, 101, 201, '2026-04-01', '2026-04-15', '2026-04-02'),
    (1002, 101, 202, '2026-04-02', '2026-04-16', NULL),
    (1003, 102, 201, '2026-04-03', '2026-04-17', NULL);

-- 명시적 ID 뒤의 자동 생성값이 샘플 ID와 충돌하지 않도록 조정합니다.
ALTER TABLE public.library_records_raw
    ALTER COLUMN loan_id RESTART WITH 1004;

ALTER TABLE public.members_nf
    ALTER COLUMN id RESTART WITH 103;

ALTER TABLE public.books_nf
    ALTER COLUMN id RESTART WITH 203;

ALTER TABLE public.loans_nf
    ALTER COLUMN id RESTART WITH 1004;

SELECT COUNT(*) AS raw_count FROM public.library_records_raw;
SELECT COUNT(*) AS member_count FROM public.members_nf;
SELECT COUNT(*) AS book_count FROM public.books_nf;
SELECT COUNT(*) AS loan_count FROM public.loans_nf;
