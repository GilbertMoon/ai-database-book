-- Chapter 06. 정규화와 좋은 테이블 설계
-- 목적: 정규화 전 library_records와 정규화 후 members, books, loans를 비교한다.
--
-- 주의:
-- 이 파일은 loans, books, members, library_records를 삭제하고 다시 생성합니다.
-- 개인 실습용 ai_database_book 데이터베이스에서만 실행하세요.

SELECT current_database();

-- 1. 반복 실습을 위한 기존 테이블 삭제
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS library_records;

-- 2. 정규화 전 테이블
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

-- 3. 정규화 전 샘플 데이터: 3행
INSERT INTO library_records (
    member_name, member_email, book_title, author,
    borrowed_at, due_at, returned_at
)
VALUES
    ('김민지', 'minji@example.com', '데이터베이스 입문', '문길래', '2026-04-01', '2026-04-15', NULL),
    ('김민지', 'minji@example.com', 'SQL 기초', '홍길동', '2026-04-02', '2026-04-16', '2026-04-10'),
    ('이준호', 'junho@example.com', '데이터베이스 입문', '문길래', '2026-04-03', '2026-04-17', NULL);

-- 4. 정규화 전 데이터와 중복 확인
SELECT * FROM library_records ORDER BY loan_id;

SELECT member_name, member_email, COUNT(*) AS repeated_rows
FROM library_records
GROUP BY member_name, member_email
ORDER BY repeated_rows DESC, member_name;

SELECT book_title, author, COUNT(*) AS repeated_rows
FROM library_records
GROUP BY book_title, author
ORDER BY repeated_rows DESC, book_title;

-- 5. 정규화 후 부모 테이블
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

-- 6. 정규화 후 자식·사건 테이블
CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(id),
    book_id INT NOT NULL REFERENCES books(id),
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE
);

-- 7. 정규화 후 샘플 데이터: members 2행, books 2행, loans 3행
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

-- 8. 정규화 후 세 테이블 확인
SELECT * FROM members ORDER BY id;
SELECT * FROM books ORDER BY id;
SELECT * FROM loans ORDER BY id;

-- 9. JOIN으로 정규화 전과 같은 업무 결과 복원
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

-- 10. 수정 이상 감소 확인: 회원 한 행만 수정
UPDATE members
SET email = 'kimminji@example.com'
WHERE id = 1;

SELECT * FROM members WHERE id = 1;

-- 11. 수정 후에도 모든 JOIN 행에 같은 최신 이메일이 표시되는지 확인
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

-- 12. 삭제 이상 비교 예시: 위험한 DELETE는 자동 실행하지 않는다.
-- DELETE FROM loans WHERE id = 1;
-- SELECT * FROM books ORDER BY id;
