-- Chapter 05. 도서 대여 시스템 구조 확인
-- 목적: 샘플 데이터의 행 수, 선택값과 테이블 관계가 ERD와 일치하는지 확인합니다.
-- 실행 전 library_schema.sql과 library_seed.sql을 순서대로 실행합니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- ============================================================
SELECT current_database();
SELECT current_schema();

-- ============================================================
-- 1. 테이블별 행 수 확인
-- 기대 결과: members 3, books 3, loans 4
-- ============================================================
SELECT COUNT(*) AS member_count FROM members;
SELECT COUNT(*) AS book_count FROM books;
SELECT COUNT(*) AS loan_count FROM loans;

-- ============================================================
-- 2. 각 테이블의 원본 데이터 확인
-- ============================================================
SELECT * FROM members ORDER BY id;
SELECT * FROM books ORDER BY id;
SELECT * FROM loans ORDER BY id;

-- ============================================================
-- 3. ERD 관계가 실제 데이터로 연결되는지 확인
-- JOIN 문법은 Chapter 08에서 자세히 다룹니다.
-- 기대 결과: 대여 기록 4행
-- ============================================================
SELECT
    loans.id,
    members.name AS member_name,
    books.title AS book_title,
    loans.borrowed_at,
    loans.due_at,
    loans.returned_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
ORDER BY loans.id;

-- ============================================================
-- 4. 선택 속성 returned_at 확인
-- 기대 결과: 미반납 기록 3행
-- ============================================================
SELECT
    id,
    member_id,
    book_id,
    borrowed_at,
    due_at
FROM loans
WHERE returned_at IS NULL
ORDER BY due_at;

-- ============================================================
-- 5. 1:N 관계 확인
-- 회원 101과 도서 201이 여러 대여 기록을 가지는지 확인합니다.
-- ============================================================
SELECT *
FROM loans
WHERE member_id = 101
ORDER BY id;

SELECT *
FROM loans
WHERE book_id = 201
ORDER BY id;
