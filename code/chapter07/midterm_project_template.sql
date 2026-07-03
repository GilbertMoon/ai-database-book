-- Chapter 07. 중간 프로젝트 또는 중간 평가
-- 프로젝트: 온라인 강의 수강신청 시스템
-- 목적: Chapter 01~06에서 학습한 DB 설계, SQL, 정규화, AI 검토 흐름을 종합한다.

-- 1. 반복 실습을 위한 기존 테이블 삭제
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;

-- 2. 학생 테이블
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

-- 3. 강사 테이블
CREATE TABLE instructors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    specialty VARCHAR(100) NOT NULL
);

-- 4. 강의 테이블
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    instructor_id INT NOT NULL REFERENCES instructors(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL,
    price INT NOT NULL,
    opened_at DATE NOT NULL
);

-- 5. 수강신청 테이블
CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    paid_amount INT NOT NULL
);

-- 6. 학생 샘플 데이터
INSERT INTO students (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-03'),
    ('박서연', 'seoyeon@example.com', '2026-03-05');

-- 7. 강사 샘플 데이터
INSERT INTO instructors (name, email, specialty)
VALUES
    ('문길래', 'gilbert@example.com', 'Database'),
    ('홍길동', 'hong@example.com', 'Python');

-- 8. 강의 샘플 데이터
INSERT INTO courses (instructor_id, title, description, level, price, opened_at)
VALUES
    (1, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (1, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (2, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

-- 9. 수강신청 샘플 데이터
INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (1, 1, '2026-04-02', '수강중', 100000),
    (1, 2, '2026-04-06', '신청', 120000),
    (2, 1, '2026-04-03', '수강중', 100000),
    (3, 3, '2026-04-11', '신청', 150000);

-- 10. 기본 테이블 확인
SELECT * FROM students;
SELECT * FROM instructors;
SELECT * FROM courses;
SELECT * FROM enrollments;

-- 11. 수강신청 현황 조회
SELECT
    enrollments.id,
    students.name AS student_name,
    courses.title AS course_title,
    instructors.name AS instructor_name,
    enrollments.status,
    enrollments.paid_amount,
    enrollments.enrolled_at
FROM enrollments
JOIN students ON enrollments.student_id = students.id
JOIN courses ON enrollments.course_id = courses.id
JOIN instructors ON courses.instructor_id = instructors.id
ORDER BY enrollments.id;

-- 12. 특정 학생의 수강신청 목록 조회
SELECT
    students.name AS student_name,
    courses.title AS course_title,
    enrollments.status
FROM enrollments
JOIN students ON enrollments.student_id = students.id
JOIN courses ON enrollments.course_id = courses.id
WHERE students.email = 'minji@example.com';

-- 13. 새로운 수강신청 추가
INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (2, 2, '2026-04-07', '신청', 120000);

-- 14. UPDATE 전 대상 확인
SELECT *
FROM enrollments
WHERE id = 1;

-- 15. 수강상태 변경
UPDATE enrollments
SET status = '완료'
WHERE id = 1;

-- 16. UPDATE 후 결과 확인
SELECT *
FROM enrollments
WHERE id = 1;

-- 17. DELETE 전 대상 확인
SELECT *
FROM enrollments
WHERE id = 4;

-- 18. 수강신청 삭제 예시
-- 실제 서비스에서는 삭제보다 status='취소' 업데이트를 우선 검토한다.
DELETE FROM enrollments
WHERE id = 4;

-- 19. DELETE 후 결과 확인
SELECT *
FROM enrollments
WHERE id = 4;

-- 20. 정규화 검토용 확인
-- 학생 이메일은 students에 한 번만 저장된다.
SELECT id, name, email
FROM students;

-- 강사 정보는 instructors에 한 번만 저장된다.
SELECT id, name, email, specialty
FROM instructors;

-- 학생과 강의의 N:M 관계는 enrollments로 풀었다.
SELECT student_id, course_id, status
FROM enrollments
ORDER BY student_id, course_id;
