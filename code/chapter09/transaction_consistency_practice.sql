-- Chapter 09. 트랜잭션과 데이터 정합성
-- 목적: 수강신청, 결제, 잔여 좌석 변경을 하나의 트랜잭션으로 처리하고 검증한다.
--
-- 주의:
-- 이 파일은 payments, enrollments, courses, instructors, students를 삭제하고 다시 생성합니다.
-- 개인 실습용 ai_database_book 데이터베이스에서만 실행하세요.
-- 성공·실패 트랜잭션 구간은 DBeaver에서 문장별로 실행하고 반환 행과 SELECT 결과를 확인하세요.

-- 0. 현재 연결 데이터베이스 확인
SELECT current_database();

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
    description TEXT,
    level VARCHAR(20) NOT NULL,
    price INT NOT NULL CHECK (price >= 0),
    opened_at DATE NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    remaining_seats INT NOT NULL,
    CHECK (
        remaining_seats >= 0
        AND remaining_seats <= capacity
    )
);

CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('신청', '수강중', '완료', '취소')),
    paid_amount INT NOT NULL CHECK (paid_amount >= 0)
);

-- 단순 예제 가정: 수강신청 한 건당 성공한 결제 기록은 최대 한 건
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    enrollment_id INT UNIQUE NOT NULL REFERENCES enrollments(id),
    amount INT NOT NULL CHECK (amount >= 0),
    paid_at DATE NOT NULL
);

-- 3. 기준 데이터 입력
INSERT INTO students (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-03'),
    ('박서연', 'seoyeon@example.com', '2026-03-05');

INSERT INTO instructors (name, email, specialty)
VALUES
    ('문길래', 'gilbert@example.com', 'Database'),
    ('홍길동', 'hong@example.com', 'Python');

INSERT INTO courses (
    instructor_id, title, description, level, price, opened_at,
    capacity, remaining_seats
)
VALUES
    (1, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01', 2, 2),
    (1, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05', 1, 1),
    (2, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10', 1, 1);

-- 4. 초기 상태 확인
SELECT COUNT(*) AS student_count FROM students;       -- 예상 3
SELECT COUNT(*) AS instructor_count FROM instructors; -- 예상 2
SELECT COUNT(*) AS course_count FROM courses;         -- 예상 3
SELECT COUNT(*) AS enrollment_count FROM enrollments; -- 예상 0
SELECT COUNT(*) AS payment_count FROM payments;       -- 예상 0

SELECT id, title, capacity, remaining_seats
FROM courses
ORDER BY id;

-- ==================================================
-- 5. 성공 트랜잭션 1: 학생 1, 강의 1
-- 각 문장을 순서대로 실행합니다.
-- ==================================================
BEGIN;

SELECT id, name
FROM students
WHERE id = 1;

-- 대상 강의 행을 잠그고 최신 좌석을 확인
SELECT id, title, price, remaining_seats
FROM courses
WHERE id = 1
FOR UPDATE;

-- 반드시 1행이 반환되는지 확인
UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 1
  AND remaining_seats > 0
RETURNING id, title, price, remaining_seats;

-- 위 UPDATE가 1행을 반환한 경우에만 실행
WITH new_enrollment AS (
    INSERT INTO enrollments (
        student_id,
        course_id,
        enrolled_at,
        status,
        paid_amount
    )
    VALUES (
        1,
        1,
        CURRENT_DATE,
        '수강중',
        100000
    )
    RETURNING id, paid_amount
)
INSERT INTO payments (
    enrollment_id,
    amount,
    paid_at
)
SELECT
    id,
    paid_amount,
    CURRENT_DATE
FROM new_enrollment
RETURNING id, enrollment_id, amount;

-- COMMIT 전 세 테이블 결과 검증
SELECT
    e.id AS enrollment_id,
    e.student_id,
    e.course_id,
    e.status,
    e.paid_amount,
    p.id AS payment_id,
    p.amount,
    c.remaining_seats
FROM enrollments AS e
JOIN payments AS p
    ON p.enrollment_id = e.id
JOIN courses AS c
    ON c.id = e.course_id
WHERE e.student_id = 1
  AND e.course_id = 1;

-- 결과가 정확한 경우에만 확정
COMMIT;
-- 결과가 다르면 COMMIT 대신 ROLLBACK;

-- 6. 성공 COMMIT 후 확인
SELECT * FROM enrollments ORDER BY id;
SELECT * FROM payments ORDER BY id;
SELECT id, title, capacity, remaining_seats
FROM courses
ORDER BY id;

-- ==================================================
-- 7. ROLLBACK 예제: 학생 2, 강의 2
-- 세 테이블을 임시로 변경한 뒤 결제 검증 실패를 가정합니다.
-- ==================================================
BEGIN;

SELECT id, title, price, remaining_seats
FROM courses
WHERE id = 2
FOR UPDATE;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0
RETURNING id, title, price, remaining_seats;

-- UPDATE가 1행을 반환한 경우에만 실행
WITH new_enrollment AS (
    INSERT INTO enrollments (
        student_id, course_id, enrolled_at, status, paid_amount
    )
    VALUES (2, 2, CURRENT_DATE, '수강중', 120000)
    RETURNING id, paid_amount
)
INSERT INTO payments (enrollment_id, amount, paid_at)
SELECT id, paid_amount, CURRENT_DATE
FROM new_enrollment
RETURNING id, enrollment_id, amount;

-- 같은 세션에서는 아직 확정되지 않은 임시 변경이 보임
SELECT
    e.id AS enrollment_id,
    p.id AS payment_id,
    c.remaining_seats
FROM enrollments AS e
JOIN payments AS p ON p.enrollment_id = e.id
JOIN courses AS c ON c.id = e.course_id
WHERE e.student_id = 2
  AND e.course_id = 2;

-- 결제 검증 실패를 가정하고 전체 취소
ROLLBACK;

-- 8. ROLLBACK 후 세 테이블이 원래 상태인지 확인
SELECT *
FROM enrollments
WHERE student_id = 2 AND course_id = 2; -- 예상 0행

SELECT p.*
FROM payments AS p
JOIN enrollments AS e ON e.id = p.enrollment_id
WHERE e.student_id = 2 AND e.course_id = 2; -- 예상 0행

SELECT id, title, remaining_seats
FROM courses
WHERE id = 2; -- 예상 1

-- ==================================================
-- 9. 성공 트랜잭션 2: 학생 3, 강의 2
-- 최종 예상 상태를 만들기 위한 두 번째 성공 예제
-- ==================================================
BEGIN;

SELECT id, title, price, remaining_seats
FROM courses
WHERE id = 2
FOR UPDATE;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0
RETURNING id, title, price, remaining_seats;

-- UPDATE가 1행을 반환한 경우에만 실행
WITH new_enrollment AS (
    INSERT INTO enrollments (
        student_id, course_id, enrolled_at, status, paid_amount
    )
    VALUES (3, 2, CURRENT_DATE, '수강중', 120000)
    RETURNING id, paid_amount
)
INSERT INTO payments (enrollment_id, amount, paid_at)
SELECT id, paid_amount, CURRENT_DATE
FROM new_enrollment
RETURNING id, enrollment_id, amount;

SELECT
    e.id AS enrollment_id,
    e.status,
    e.paid_amount,
    p.amount,
    c.remaining_seats
FROM enrollments AS e
JOIN payments AS p ON p.enrollment_id = e.id
JOIN courses AS c ON c.id = e.course_id
WHERE e.student_id = 3
  AND e.course_id = 2;

COMMIT;

-- ==================================================
-- 10. 좌석 부족과 UPDATE 0행 확인
-- course 2의 remaining_seats는 현재 0이다.
-- ==================================================
BEGIN;

SELECT id, title, remaining_seats
FROM courses
WHERE id = 2
FOR UPDATE;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0
RETURNING id, title, remaining_seats;

-- 예상: 0행 반환
-- 0행은 자동 오류가 아니다.
-- 이후 enrollments와 payments INSERT를 실행하지 말고 즉시 취소한다.
ROLLBACK;

-- 11. 정합성 검증: 음수 또는 정원 초과 좌석, 예상 0행
SELECT id, title, capacity, remaining_seats
FROM courses
WHERE remaining_seats < 0
   OR remaining_seats > capacity;

-- 12. 정합성 검증: 수강중 신청과 결제 누락·금액 불일치, 예상 0행
SELECT
    e.id AS enrollment_id,
    e.paid_amount,
    p.amount AS payment_amount
FROM enrollments AS e
LEFT JOIN payments AS p
    ON p.enrollment_id = e.id
WHERE e.status = '수강중'
  AND (
      p.id IS NULL
      OR e.paid_amount <> p.amount
  );

-- 13. 좌석 사용량 검증
-- 이 단순 예제에서는 수강중 상태가 좌석을 사용한다고 가정한다.
SELECT
    c.id,
    c.title,
    c.capacity,
    c.remaining_seats,
    COUNT(e.id) FILTER (
        WHERE e.status = '수강중'
    ) AS active_enrollment_count,
    c.capacity - c.remaining_seats AS used_seats
FROM courses AS c
LEFT JOIN enrollments AS e
    ON e.course_id = c.id
GROUP BY
    c.id,
    c.title,
    c.capacity,
    c.remaining_seats
ORDER BY c.id;

-- 검증 기준: active_enrollment_count = used_seats
-- 취소·환불 시 좌석 복구 정책은 Chapter 09 범위에서 제외한다.

-- 14. 전체 실습 후 최종 상태
SELECT COUNT(*) AS final_enrollment_count FROM enrollments; -- 예상 2
SELECT COUNT(*) AS final_payment_count FROM payments;       -- 예상 2

SELECT id, title, capacity, remaining_seats
FROM courses
ORDER BY id;
-- 예상:
-- 데이터베이스 입문 remaining_seats = 1
-- 정규화 실습 remaining_seats = 0
-- 파이썬 데이터 분석 remaining_seats = 1
