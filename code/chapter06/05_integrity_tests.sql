-- Chapter 06. 05 정상·경계·오류 데이터 테스트
-- 시작 상태: 04_add_integrity_rules.sql 실행 완료
-- 중요: 주석 처리된 테스트를 한 번에 하나씩 실행합니다.
-- 실패해야 하는 SQL에서 오류가 발생하면 테스트가 성공한 것입니다.
-- 수동 커밋 상태에서 오류 후 트랜잭션이 중단되면 ROLLBACK;을 실행하세요.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '테스트 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    IF to_regclass('public.members_nf') IS NULL
       OR to_regclass('public.books_nf') IS NULL
       OR to_regclass('public.loans_nf') IS NULL THEN
        RAISE EXCEPTION
            '테스트 중단: Chapter 06 테이블이 모두 존재하지 않습니다.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'uq_members_nf_email'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_loans_nf_member'
    ) OR to_regclass('public.uq_loans_nf_active_book') IS NULL THEN
        RAISE EXCEPTION
            '테스트 중단: 04_add_integrity_rules.sql을 먼저 실행하세요.';
    END IF;
END
$$;

-- 기준 상태: raw 3, members 2, books 2, loans 3
SELECT COUNT(*) AS raw_count_before FROM public.library_records_raw;
SELECT COUNT(*) AS member_count_before FROM public.members_nf;
SELECT COUNT(*) AS book_count_before FROM public.books_nf;
SELECT COUNT(*) AS loan_count_before FROM public.loans_nf;

-- ============================================================
-- 경계 테스트 A: 같은 날 대여·반납 허용
-- C-04·C-05 경계값
-- 아래 네 문장을 순서대로 실행한 뒤 임시 행을 삭제합니다.
-- ============================================================
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1800, '경계값 테스트 도서', '테스트 저자', 2026, 'ISBN-BOUNDARY-LOAN-001');
--
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id, borrowed_at, due_at, returned_at
-- )
-- VALUES (1801, 101, 1800, '2026-05-01', '2026-05-01', '2026-05-01');
--
-- DELETE FROM public.loans_nf WHERE id = 1801;
-- DELETE FROM public.books_nf WHERE id = 1800;

-- ============================================================
-- 경계 테스트 B: published_year = NULL 허용
-- ============================================================
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1802, '연도 미상 도서', '익명', NULL, 'ISBN-BOUNDARY-001');
-- DELETE FROM public.books_nf WHERE id = 1802;

-- ============================================================
-- 경계 테스트 C: 공백이 아닌 한 글자 이름 허용
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1803, '김', 'one-char@example.com', '2026-03-20');
-- DELETE FROM public.members_nf WHERE id = 1803;

-- ============================================================
-- 오류 테스트 1: NOT NULL 위반
-- 기대 결과: members_nf.name NOT NULL 오류
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1901, NULL, 'null-name@example.com', '2026-03-20');

-- 오류 테스트 2: C-01 이메일 UNIQUE 위반
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1902, '중복 이메일 회원', 'junho@example.com', '2026-03-20');

-- 오류 테스트 3: C-02 ISBN UNIQUE 위반
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1903, '중복 ISBN 도서', '테스트 저자', 2026, 'ISBN-001');

-- 오류 테스트 4: C-03 공백 이름 CHECK 위반
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1904, '   ', 'blank-name@example.com', '2026-03-20');

-- 오류 테스트 5: C-03 공백 제목 CHECK 위반
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1905, '   ', '테스트 저자', 2026, 'ISBN-BLANK-001');

-- 오류 테스트 6: C-06 존재하지 않는 회원 FOREIGN KEY 위반
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id, borrowed_at, due_at, returned_at
-- )
-- VALUES (1906, 999, 201, '2026-04-10', '2026-04-24', '2026-04-12');

-- 오류 테스트 7: C-04 잘못된 반납예정일 CHECK 위반
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id, borrowed_at, due_at, returned_at
-- )
-- VALUES (1907, 101, 202, '2026-04-20', '2026-04-10', '2026-04-21');

-- 오류 테스트 8: C-05 실제반납일 CHECK 위반
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id, borrowed_at, due_at, returned_at
-- )
-- VALUES (1908, 101, 202, '2026-04-20', '2026-05-04', '2026-04-10');

-- 오류 테스트 9: C-08 같은 도서의 두 번째 미반납 대여
-- 도서 201에는 대여 1003이 미반납 상태로 존재합니다.
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id, borrowed_at, due_at, returned_at
-- )
-- VALUES (1909, 101, 201, '2026-04-10', '2026-04-24', NULL);

-- 오류 테스트 10: C-07 참조 중인 부모 삭제
-- DELETE FROM public.members_nf WHERE id = 101;

-- 정상 테스트: 참조되지 않는 부모는 삭제 가능
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1911, '미대여 회원', 'unused@example.com', '2026-03-20');
-- DELETE FROM public.members_nf WHERE id = 1911;

-- 테스트 후 기준 데이터 확인
SELECT COUNT(*) AS raw_count_after FROM public.library_records_raw;
SELECT COUNT(*) AS member_count_after FROM public.members_nf;
SELECT COUNT(*) AS book_count_after FROM public.books_nf;
SELECT COUNT(*) AS loan_count_after FROM public.loans_nf;

SELECT * FROM public.members_nf ORDER BY id;
SELECT * FROM public.books_nf ORDER BY id;
SELECT * FROM public.loans_nf ORDER BY id;
