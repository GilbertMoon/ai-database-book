-- Chapter 05. 데이터 모델링과 ERD
-- 목적: 도서 대여 시스템 요구사항을 PostgreSQL 테이블 구조로 구현하고 검증한다.
-- 범위: books 한 행을 하나의 대여 대상 도서 레코드로 취급하며 복본 구분은 다루지 않는다.

-- 1. 반복 실습을 위한 기존 테이블 삭제
-- 외래키 관계가 있으므로 자식 테이블인 loans를 먼저 삭제한다.
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;

-- 2. 부모 테이블: 회원
CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

-- 3. 부모 테이블: 도서
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INT,
    isbn VARCHAR(20) UNIQUE NOT NULL
);

-- 4. 자식·사건 테이블: 대여 기록
-- member_id와 book_id는 각각 기존 회원과 도서 행을 참조한다.
-- returned_at은 미반납 상태를 표현하기 위해 NULL을 허용한다.
CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(id),
    book_id INT NOT NULL REFERENCES books(id),
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE
);

-- 5. 회원 샘플 데이터 입력: 3명
INSERT INTO members (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-05'),
    ('박서연', 'seoyeon@example.com', '2026-03-10');

-- 6. 도서 샘플 데이터 입력: 3건
INSERT INTO books (title, author, published_year, isbn)
VALUES
    ('데이터베이스 입문', '문길래', 2026, 'ISBN-001'),
    ('SQL 기초', '홍길동', 2025, 'ISBN-002'),
    ('ERD 설계 연습', '이몽룡', 2024, 'ISBN-003');

-- 7. 대여 기록 샘플 데이터 입력: 4건
-- 같은 member_id 또는 book_id가 여러 행에 반복되는 것은 1:N 관계의 정상 표현이다.
INSERT INTO loans (member_id, book_id, borrowed_at, due_at, returned_at)
VALUES
    (1, 1, '2026-04-01', '2026-04-15', NULL),
    (1, 2, '2026-04-02', '2026-04-16', '2026-04-10'),
    (2, 1, '2026-04-03', '2026-04-17', NULL),
    (3, 3, '2026-04-05', '2026-04-19', NULL);

-- 8. 각 테이블 데이터 확인
SELECT * FROM members ORDER BY id;
SELECT * FROM books ORDER BY id;
SELECT * FROM loans ORDER BY id;

-- 9. JOIN으로 대여 기록 확인: 4행
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

-- 10. 아직 반납되지 않은 대여 기록 조회: 3행
SELECT
    members.name AS member_name,
    books.title AS book_title,
    loans.borrowed_at,
    loans.due_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
WHERE loans.returned_at IS NULL
ORDER BY loans.due_at;

-- 11. 외래키 제약조건 확인용 오류 실습
-- 존재하지 않는 member_id 또는 book_id를 입력하면 오류가 발생해야 정상이다.
-- INSERT INTO loans (member_id, book_id, borrowed_at, due_at, returned_at)
-- VALUES (999, 1, '2026-04-10', '2026-04-24', NULL);
