-- Chapter 06. 정규화 전후 구조 비교와 검증
-- 실행 전 normalization_schema.sql과 normalization_seed.sql을 순서대로 실행합니다.
-- 이 파일은 테이블을 삭제하거나 새로 만들지 않습니다.
-- UPDATE 예시는 기본적으로 주석 처리되어 있습니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- 기대 결과: ai_database_book / public
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 정규화 전 원시 데이터 확인: 기대 결과 3행
-- ============================================================
SELECT *
FROM public.library_records_raw
ORDER BY loan_id;

-- ============================================================
-- 2. 회원 정보 반복 확인
-- 김민지 정보가 2행에 반복됩니다.
-- ============================================================
SELECT
    member_name,
    member_email,
    COUNT(*) AS repeated_rows
FROM public.library_records_raw
GROUP BY member_name, member_email
ORDER BY repeated_rows DESC, member_name;

-- ============================================================
-- 3. 도서 정보 반복 확인
-- 데이터베이스 입문 정보가 2행에 반복됩니다.
-- ============================================================
SELECT
    book_title,
    author,
    COUNT(*) AS repeated_rows
FROM public.library_records_raw
GROUP BY book_title, author
ORDER BY repeated_rows DESC, book_title;

-- ============================================================
-- 4. 정규화 후 행 수 확인
-- 기대 결과: members_nf 2, books_nf 2, loans_nf 3
-- ============================================================
SELECT COUNT(*) AS member_count FROM public.members_nf;
SELECT COUNT(*) AS book_count FROM public.books_nf;
SELECT COUNT(*) AS loan_count FROM public.loans_nf;

-- ============================================================
-- 5. 정규화 후 테이블 확인
-- ============================================================
SELECT * FROM public.members_nf ORDER BY id;
SELECT * FROM public.books_nf ORDER BY id;
SELECT * FROM public.loans_nf ORDER BY id;

-- ============================================================
-- 6. 정규화된 관계가 원래 업무 결과를 만들 수 있는지 확인
-- JOIN 문법은 Chapter 08에서 자세히 다룹니다.
-- 기대 결과: 3행
-- ============================================================
SELECT
    l.id AS loan_id,
    m.name AS member_name,
    m.email AS member_email,
    b.title AS book_title,
    b.author,
    l.borrowed_at,
    l.due_at,
    l.returned_at
FROM public.loans_nf AS l
JOIN public.members_nf AS m ON l.member_id = m.id
JOIN public.books_nf AS b ON l.book_id = b.id
ORDER BY l.id;

-- ============================================================
-- 7. 1:N 관계 확인
-- 회원 101과 도서 201은 각각 여러 대여 기록을 가집니다.
-- ============================================================
SELECT *
FROM public.loans_nf
WHERE member_id = 101
ORDER BY id;

SELECT *
FROM public.loans_nf
WHERE book_id = 201
ORDER BY id;

-- ============================================================
-- 8. 선택 속성 returned_at 확인
-- 기대 결과: 미반납 기록 2행
-- ============================================================
SELECT *
FROM public.loans_nf
WHERE returned_at IS NULL
ORDER BY due_at, id;

-- ============================================================
-- 9. 도서 201의 대여 이력 시간 순서 확인
-- 첫 대여는 4월 2일 반납되고 두 번째 대여는 4월 3일 시작합니다.
-- ============================================================
SELECT id, book_id, borrowed_at, returned_at
FROM public.loans_nf
WHERE book_id = 201
ORDER BY borrowed_at, id;

-- ============================================================
-- 10. 수정 이상 감소 확인
-- 체크포인트 A: 샘플 입력 완료, 회원 101 이메일은 minji@example.com
-- 아래 UPDATE는 필요할 때만 한 문장씩 선택 실행합니다.
-- 체크포인트 B: 회원 101 이메일을 kimminji@example.com으로 수정 완료
-- ============================================================
SELECT *
FROM public.members_nf
WHERE id = 101;

-- UPDATE public.members_nf
-- SET email = 'kimminji@example.com'
-- WHERE id = 101
-- RETURNING id, name, email;

-- 수정 후에는 회원 행과 JOIN 결과를 다시 확인합니다.
-- SELECT *
-- FROM public.members_nf
-- WHERE id = 101;

-- SELECT
--     l.id AS loan_id,
--     m.name AS member_name,
--     m.email AS member_email,
--     b.title AS book_title
-- FROM public.loans_nf AS l
-- JOIN public.members_nf AS m ON l.member_id = m.id
-- JOIN public.books_nf AS b ON l.book_id = b.id
-- ORDER BY l.id;

-- 중복 이메일 오류 테스트는 변경하지 않은 회원 102의
-- junho@example.com을 사용하므로 체크포인트 A와 B 모두에서 실패해야 합니다.

-- 삭제 이상 비교용 DELETE는 자동 실행하지 않습니다.
-- 삭제 정책과 참조 무결성은 integrity_tests.sql에서 확인합니다.
