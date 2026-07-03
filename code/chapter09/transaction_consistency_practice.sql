-- Chapter 09. 트랜잭션과 데이터 정합성
-- 목적: 수강신청, 결제, 잔여 좌석 차감을 하나의 트랜잭션으로 처리하는 실습

-- 1. 반복 실습을 위한 기존 테이블 삭제
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;

-- 2. 기본 테이블 생성
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE instructors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    specialty VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    instructor_id INT NOT NULL REFERENCES instructors(id),
    title VARCHAR(200) NOT NULL,
    price INT NOT NULL,
    capacity INT NOT NULL,
    remaining_seats INT NOT NULL
);

CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    paid_amount INT NOT NULL
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    amount INT NOT NULL,
    paid_at DATE NOT NULL
);

-- 3. 샘플 데이터 입력
INSERT INTO students (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-03'),
    ('박서연', 'seoyeon@example.com', '2026-03-05');

INSERT INTO instructors (name, email, specialty)
VALUES
    ('문길래', 'gilbert@example.com', 'Database'),
    ('홍길동', 'hong@example.com', 'Python');

INSERT INTO courses (instructor_id, title, price, capacity, remaining_seats)
VALUES
    (1, '데이터베이스 입문', 100000, 2, 2),
    (1, '정규화 실습', 120000, 1, 1),
    (2, '파이썬 데이터 분석', 150000, 1, 1);

-- 4. 초기 상태 확인
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;
SELECT * FROM payments;

-- 5. 성공하는 트랜잭션 예제
BEGIN;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (1, 1, CURRENT_DATE, '결제완료', 100000);

INSERT INTO payments (student_id, course_id, amount, paid_at)
VALUES (1, 1, 100000, CURRENT_DATE);

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 1
  AND remaining_seats > 0;

COMMIT;

-- 6. COMMIT 후 결과 확인
SELECT * FROM enrollments;
SELECT * FROM payments;
SELECT id, title, capacity, remaining_seats
FROM courses
ORDER BY id;

-- 7. ROLLBACK 예제
BEGIN;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (2, 2, CURRENT_DATE, '결제대기', 120000);

INSERT INTO payments (student_id, course_id, amount, paid_at)
VALUES (2, 2, 120000, CURRENT_DATE);

-- 결제 검증 실패 상황이라고 가정하고 전체 취소
ROLLBACK;

-- 8. ROLLBACK 후 결과 확인
SELECT * FROM enrollments
WHERE student_id = 2 AND course_id = 2;

SELECT * FROM payments
WHERE student_id = 2 AND course_id = 2;

-- 9. 잔여 좌석 조건 검증 예제
BEGIN;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (3, 2, CURRENT_DATE, '결제완료', 120000);

INSERT INTO payments (student_id, course_id, amount, paid_at)
VALUES (3, 2, 120000, CURRENT_DATE);

COMMIT;

-- 10. 좌석 확인
SELECT id, title, remaining_seats
FROM courses
WHERE id = 2;

-- 11. 좌석이 부족한 상황 확인
-- remaining_seats가 0이면 아래 UPDATE는 영향을 주는 행이 없어야 한다.
BEGIN;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0;

-- 실무에서는 UPDATE된 행 수를 확인한 뒤 수강신청 INSERT 여부를 결정해야 한다.
ROLLBACK;

-- 12. 최종 정합성 확인
SELECT
    c.id,
    c.title,
    c.capacity,
    c.remaining_seats,
    COUNT(e.id) AS enrollment_count
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title, c.capacity, c.remaining_seats
ORDER BY c.id;
