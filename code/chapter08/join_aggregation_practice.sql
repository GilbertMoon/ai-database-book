-- Chapter 08. JOIN과 집계 쿼리
-- 목적: 온라인 강의 수강신청 시스템에서 JOIN과 집계 쿼리를 실습한다.

-- 1. 반복 실습을 위한 기존 테이블 삭제
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
    price INT NOT NULL,
    opened_at DATE NOT NULL
);

CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    paid_amount INT NOT NULL
);

-- 3. 샘플 데이터 입력
INSERT INTO students (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-03'),
    ('박서연', 'seoyeon@example.com', '2026-03-05'),
    ('최현우', 'hyunwoo@example.com', '2026-03-07');

INSERT INTO instructors (name, email, specialty)
VALUES
    ('문길래', 'gilbert@example.com', 'Database'),
    ('홍길동', 'hong@example.com', 'Python'),
    ('김데이터', 'data@example.com', 'Data Analysis');

INSERT INTO courses (instructor_id, title, description, level, price, opened_at)
VALUES
    (1, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (1, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (2, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10'),
    (3, '집계 쿼리 실습', 'GROUP BY와 HAVING 실습', 'intermediate', 130000, '2026-04-15');

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (1, 1, '2026-04-02', '수강중', 100000),
    (1, 2, '2026-04-06', '신청', 120000),
    (2, 1, '2026-04-03', '수강중', 100000),
    (3, 3, '2026-04-11', '신청', 150000),
    (2, 3, '2026-04-12', '완료', 150000);

-- 4. INNER JOIN: 학생별 수강 강의 조회
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM students AS s
JOIN enrollments AS e ON s.id = e.student_id
JOIN courses AS c ON e.course_id = c.id
ORDER BY s.id, c.id;

-- 5. 여러 테이블 JOIN: 수강신청 현황 전체 조회
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
JOIN instructors AS i ON c.instructor_id = i.id
ORDER BY e.id;

-- 6. LEFT JOIN: 수강신청이 없는 학생도 포함
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM students AS s
LEFT JOIN enrollments AS e ON s.id = e.student_id
LEFT JOIN courses AS c ON e.course_id = c.id
ORDER BY s.id, c.id;

-- 7. 수강신청이 없는 학생 찾기
SELECT
    s.id,
    s.name,
    s.email
FROM students AS s
LEFT JOIN enrollments AS e ON s.id = e.student_id
WHERE e.id IS NULL;

-- 8. 전체 수강신청 수
SELECT COUNT(*) AS enrollment_count
FROM enrollments;

-- 9. 전체 결제금액 합계와 평균
SELECT
    SUM(paid_amount) AS total_paid_amount,
    AVG(paid_amount) AS avg_paid_amount
FROM enrollments;

-- 10. 수강상태별 수강신청 수
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY status
ORDER BY status;

-- 11. 강의별 수강생 수
SELECT
    c.id AS course_id,
    c.title AS course_title,
    COUNT(e.id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
ORDER BY c.id;

-- 12. 강의별 매출
SELECT
    c.title AS course_title,
    COALESCE(SUM(e.paid_amount), 0) AS total_amount
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
ORDER BY total_amount DESC;

-- 13. 강사별 개설 강의 수
SELECT
    i.name AS instructor_name,
    COUNT(c.id) AS course_count
FROM instructors AS i
LEFT JOIN courses AS c ON i.id = c.instructor_id
GROUP BY i.id, i.name
ORDER BY course_count DESC;

-- 14. HAVING: 수강생이 2명 이상인 강의
SELECT
    c.title AS course_title,
    COUNT(e.id) AS student_count
FROM courses AS c
JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
HAVING COUNT(e.id) >= 2
ORDER BY student_count DESC;

-- 15. WHERE + GROUP BY: 수강중 상태만 대상으로 강의별 수강생 수
SELECT
    c.title AS course_title,
    COUNT(e.id) AS active_student_count
FROM courses AS c
JOIN enrollments AS e ON c.id = e.course_id
WHERE e.status = '수강중'
GROUP BY c.id, c.title
ORDER BY active_student_count DESC;
