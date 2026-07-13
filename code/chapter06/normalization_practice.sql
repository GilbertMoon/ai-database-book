-- Chapter 06. 정규화 전후 구조 비교와 검증
-- 실행 전 normalization_schema.sql과 normalization_seed.sql을 순서대로 실행합니다.
-- 이 파일은 테이블을 삭제하거나 새로 만들지 않습니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- ============================================================
SELECT current_database();
SELECT current_schema();

-- ============================================================
-- 1. 정규화 전 원시 데이터 확인: 기대 결과 3행
-- ============================================================
SELECT *
FROM library_records_raw
ORDER BY loan_id;

-- ============================================================
-- 2. 회원 정보 반복 확인
-- 김민지 정보가 2행에 반복됩니다.
-- ============================================================
SELECT
    member_name,
    member_email,
    COUNT(*) AS repeated_rows
FROM library_records_raw
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
FROM library_records_raw
GROUP BY book_title, author
ORDER BY repeated_rows DESC, book_title;

-- ============================================================
-- 4. 정규화 후 행 수 확인
-- 기대 결과: members_nf 2, books_nf 2, loans_nf 3
-- ============================================================
SELECT COUNT(*) AS member_count FROM members_nf;
SELECT COUNT(*) AS book_count FROM books_nf;
SELECT COUNT(*) AS loan_count FROM loans_nf;

-- ============================================================
-- 5. 정규화 후 원본 테이블 확인
-- ============================================================
SELECT * FROM members_nf ORDER BY id;
SELECT * FROM books_nf ORDER BY id;
SELECT * FROM loans_nf ORDER BY id;

-- ============================================================
-- 6. 정규화된 관계가 원래 업무 결과를 만들 수 있는지 확인
-- JOIN 문법은 Chapter 08에서 자세히 다룹니다.
-- 기대 결과: 3행
-- ============================================================
SELECT
    loans_nf.id AS loan_id,
    members_nf.name AS member_name,
    members_nf.email AS member_email,
    books_nf.title AS book_title,
    books_nf.author,
    loans_nf.borrowed_at,
    loans_nf.due_at,
    loans_nf.returned_at
FROM loans_nf
JOIN members_nf ON loans_nf.member_id = members_nf.id
JOIN books_nf ON loans_nf.book_id = books_nf.id
ORDER BY loans_nf.id;

-- ============================================================
-- 7. 1:N 관계 확인
-- 회원 101과 도서 201은 각각 여러 대여 기록을 가집니다.
-- ============================================================
SELECT *
FROM loans_nf
WHERE member_id = 101
ORDER BY id;

SELECT *
FROM loans_nf
WHERE book_id = 201
ORDER BY id;

-- ============================================================
-- 8. 선택 속성 returned_at 확인
-- 기대 결과: 미반납 기록 2행
-- ============================================================
SELECT *
FROM loans_nf
WHERE returned_at IS NULL
ORDER BY due_at;

-- ============================================================
-- 9. 수정 이상 감소 확인
-- 먼저 아래 SELECT로 수정 대상을 확인한 뒤 UPDATE만 선택 실행합니다.
-- ============================================================
SELECT *
FROM members_nf
WHERE id = 101;

-- UPDATE members_nf
-- SET email = 'kimminji@example.com'
-- WHERE id = 101;

-- 수정 후에는 회원 행과 JOIN 결과를 다시 확인합니다.
-- SELECT * FROM members_nf WHERE id = 101;

-- SELECT
--     loans_nf.id AS loan_id,
--     members_nf.name AS member_name,
--     members_nf.email AS member_email,
--     books_nf.title AS book_title
-- FROM loans_nf
-- JOIN members_nf ON loans_nf.member_id = members_nf.id
-- JOIN books_nf ON loans_nf.book_id = books_nf.id
-- ORDER BY loans_nf.id;

-- 삭제 이상 비교용 DELETE는 자동 실행하지 않습니다.
-- 삭제 정책과 참조 무결성은 integrity_tests.sql에서 별도로 확인합니다.
