-- Chapter 06. 정규화와 좋은 테이블 설계
-- 목적: 나쁜 테이블 구조와 정규화된 테이블 구조를 비교한다.

-- 1. 반복 실습을 위한 기존 테이블 삭제
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS library_records;

-- 2. 정규화 전 나쁜 예시 테이블
CREATE TABLE library_records (
    loan_id SERIAL PRIMARY KEY,
    member_name VARCHAR(50) NOT NULL,
    member_email VARCHAR(100) NOT NULL,
    book_title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE
);

-- 3. 중복이 있는 샘플 데이터 입력
INSERT INTO library_records (member_name, member_email, book_title, author, borrowed_at, due_at, returned_at)
VALUES
    ('김민지', 'minji@example.com', '데이터베이스 입문', '문길래', '2026-04-01', '2026-04-15', NULL),
    ('김민지', 'minji@example.com', 'SQL 기초', '홍길동', '2026-04-02', '2026-04-16', '2026-04-10'),
    ('이준호', 'junho@example.com', '데이터베이스 입문', '문길래', '2026-04-03', '2026-04-17', NULL);

-- 4. 정규화 전 데이터 확인
SELECT *
FROM library_records
ORDER BY loan_id;

-- 5. 수정 이상 예시
-- 김민지 이메일이 여러 행에 반복되므로 여러 행을 함께 수정해야 한다.
SELECT loan_id, member_name, member_email
FROM library_records
WHERE member_name = '김민지';

-- 6. 정규화된 테이블 생성
CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INT,
    isbn VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(id),
    book_id INT NOT NULL REFERENCES books(id),
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE
);

-- 7. 정규화된 테이블에 샘플 데이터 입력
INSERT INTO members (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-05');

INSERT INTO books (title, author, published_year, isbn)
VALUES
    ('데이터베이스 입문', '문길래', 2026, 'ISBN-001'),
    ('SQL 기초', '홍길동', 2025, 'ISBN-002');

INSERT INTO loans (member_id, book_id, borrowed_at, due_at, returned_at)
VALUES
    (1, 1, '2026-04-01', '2026-04-15', NULL),
    (1, 2, '2026-04-02', '2026-04-16', '2026-04-10'),
    (2, 1, '2026-04-03', '2026-04-17', NULL);

-- 8. 정규화 후 데이터 확인
SELECT * FROM members;
SELECT * FROM books;
SELECT * FROM loans;

-- 9. JOIN으로 정규화 전과 같은 조회 결과 만들기
SELECT
    loans.id AS loan_id,
    members.name AS member_name,
    members.email AS member_email,
    books.title AS book_title,
    books.author,
    loans.borrowed_at,
    loans.due_at,
    loans.returned_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
ORDER BY loans.id;

-- 10. 정규화 후 이메일 수정
-- 회원 이메일은 members 테이블의 한 행만 수정하면 된다.
UPDATE members
SET email = 'kimminji@example.com'
WHERE id = 1;

SELECT *
FROM members
WHERE id = 1;

-- 11. 정규화 후에도 JOIN 결과가 유지되는지 확인
SELECT
    loans.id AS loan_id,
    members.name AS member_name,
    members.email AS member_email,
    books.title AS book_title,
    loans.borrowed_at,
    loans.due_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
ORDER BY loans.id;

-- 12. 삭제 이상 비교용 설명
-- 정규화된 구조에서는 loans를 삭제해도 books의 책 정보는 남는다.
-- DELETE FROM loans WHERE id = 1;
-- SELECT * FROM books;
