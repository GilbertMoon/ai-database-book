-- Chapter 06. 데이터 무결성 정상·경계·오류 테스트
-- 목적: 확정 규칙 C-01~C-08이 PostgreSQL에서 올바르게 동작하는지 확인합니다.
-- 실행 전 normalization_schema.sql과 normalization_seed.sql을 실행합니다.
--
-- 중요:
-- 1. 아래 테스트 SQL은 모두 주석 처리되어 있습니다.
-- 2. 한 번에 하나의 테스트만 주석 해제해 실행합니다.
-- 3. 실패해야 하는 테스트는 오류가 발생해야 정상입니다.
-- 4. 자동 커밋 상태에서 한 문장씩 실행하는 것이 가장 단순합니다.
-- 5. 수동 커밋 상태에서 오류 후 current transaction is aborted가 나타나면
--    ROLLBACK;을 실행한 뒤 다음 테스트로 이동합니다.

-- ============================================================
-- 0. 현재 실행 위치와 기준 행 수 확인
-- 기대 결과: ai_database_book / public
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

SELECT COUNT(*) AS raw_count_before FROM public.library_records_raw;
SELECT COUNT(*) AS member_count_before FROM public.members_nf;
SELECT COUNT(*) AS book_count_before FROM public.books_nf;
SELECT COUNT(*) AS loan_count_before FROM public.loans_nf;

-- ============================================================
-- 경계 테스트 A. due_at = borrowed_at, returned_at = borrowed_at 허용
-- C-04·C-05의 경계값입니다.
-- 기존 활성 대여와 충돌하지 않도록 임시 도서를 먼저 만든 뒤 테스트합니다.
-- 네 문장을 순서대로 선택 실행하고 임시 행을 삭제합니다.
-- ============================================================
-- INSERT INTO public.books_nf (
--     id, title, author, published_year, isbn
-- )
-- VALUES (
--     1800, '경계값 테스트 도서', '테스트 저자', 2026, 'ISBN-BOUNDARY-LOAN-001'
-- );
--
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1801, 101, 1800,
--     '2026-05-01', '2026-05-01', '2026-05-01'
-- );
--
-- DELETE FROM public.loans_nf
-- WHERE id = 1801;
--
-- DELETE FROM public.books_nf
-- WHERE id = 1800;

-- ============================================================
-- 경계 테스트 B. published_year = NULL 허용
-- 출판연도 범위는 이 장에서 확정하지 않았습니다.
-- ============================================================
-- INSERT INTO public.books_nf (
--     id, title, author, published_year, isbn
-- )
-- VALUES (
--     1802, '연도 미상 도서', '익명', NULL, 'ISBN-BOUNDARY-001'
-- );
--
-- DELETE FROM public.books_nf
-- WHERE id = 1802;

-- ============================================================
-- 경계 테스트 C. 공백이 아닌 한 글자 이름 허용
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1803, '김', 'one-char@example.com', '2026-03-20');
--
-- DELETE FROM public.members_nf
-- WHERE id = 1803;

-- ============================================================
-- 테스트 1. NOT NULL 위반
-- 기대 결과: name의 NOT NULL 제약조건 오류
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1901, NULL, 'null-name@example.com', '2026-03-20');

-- ============================================================
-- 테스트 2. UNIQUE 위반: 이메일
-- 기대 결과: uq_members_nf_email 오류
-- 회원 101의 이메일을 수정해도 회원 102의 junho@example.com은 유지됩니다.
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1902, '중복 이메일 회원', 'junho@example.com', '2026-03-20');

-- ============================================================
-- 테스트 3. UNIQUE 위반: ISBN
-- 기대 결과: uq_books_nf_isbn 오류
-- ============================================================
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1903, '중복 ISBN 도서', '테스트 저자', 2026, 'ISBN-001');

-- ============================================================
-- 테스트 4. CHECK 위반: 공백 이름
-- 기대 결과: chk_members_nf_name_not_blank 오류
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1904, '   ', 'blank-name@example.com', '2026-03-20');

-- ============================================================
-- 테스트 5. CHECK 위반: 공백 제목
-- 기대 결과: chk_books_nf_title_not_blank 오류
-- ============================================================
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1905, '   ', '테스트 저자', 2026, 'ISBN-BLANK-001');

-- ============================================================
-- 테스트 6. FOREIGN KEY 위반
-- 기대 결과: 존재하지 않는 member_id 999 참조 오류
-- ============================================================
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1906, 999, 201,
--     '2026-04-10', '2026-04-24', '2026-04-12'
-- );

-- ============================================================
-- 테스트 7. CHECK 위반: 잘못된 반납예정일
-- 기대 결과: chk_loans_nf_due_date 오류
-- ============================================================
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1907, 101, 202,
--     '2026-04-20', '2026-04-10', '2026-04-21'
-- );

-- ============================================================
-- 테스트 8. CHECK 위반: 실제반납일이 대여일보다 빠름
-- 기대 결과: chk_loans_nf_returned_date 오류
-- ============================================================
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1908, 101, 202,
--     '2026-04-20', '2026-05-04', '2026-04-10'
-- );

-- ============================================================
-- 테스트 9. 같은 도서의 두 번째 활성 대여
-- 기대 결과: uq_loans_nf_active_book 고유 인덱스 오류
-- 도서 201에는 대여 1003이 미반납 상태로 존재합니다.
-- ============================================================
-- INSERT INTO public.loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1909, 101, 201,
--     '2026-04-10', '2026-04-24', NULL
-- );

-- ============================================================
-- 테스트 10. 참조 중인 부모 삭제
-- 기대 결과: ON DELETE RESTRICT 또는 외래키 오류
-- 회원 101은 public.loans_nf에서 참조 중입니다.
-- ============================================================
-- DELETE FROM public.members_nf
-- WHERE id = 101;

-- ============================================================
-- 테스트 11. 참조되지 않는 부모는 삭제 가능
-- 정상 동작 확인용 선택 테스트입니다.
-- 두 문장을 순서대로 선택 실행할 수 있습니다.
-- ============================================================
-- INSERT INTO public.members_nf (id, name, email, joined_at)
-- VALUES (1911, '미대여 회원', 'unused@example.com', '2026-03-20');
--
-- DELETE FROM public.members_nf
-- WHERE id = 1911;

-- ============================================================
-- 오류 테스트 후 기준 데이터가 유지되는지 확인
-- 기대 결과: raw 3, members 2, books 2, loans 3
-- 경계·정상 테스트의 임시 행은 삭제한 상태여야 합니다.
-- ============================================================
SELECT COUNT(*) AS raw_count_after FROM public.library_records_raw;
SELECT COUNT(*) AS member_count_after FROM public.members_nf;
SELECT COUNT(*) AS book_count_after FROM public.books_nf;
SELECT COUNT(*) AS loan_count_after FROM public.loans_nf;

SELECT * FROM public.members_nf ORDER BY id;
SELECT * FROM public.books_nf ORDER BY id;
SELECT * FROM public.loans_nf ORDER BY id;
