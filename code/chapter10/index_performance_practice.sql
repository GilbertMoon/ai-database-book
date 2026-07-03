-- Chapter 10. 인덱스와 성능 기초
-- 목적: 온라인 강의 수강신청 시스템에서 인덱스 생성 전후 EXPLAIN 결과를 비교한다.

-- 주의:
-- 1. 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
-- 2. 실제 운영 데이터베이스에서는 DROP TABLE, CREATE INDEX, DROP INDEX를 신중하게 실행해야 합니다.
-- 3. 샘플 데이터가 적으면 인덱스가 있어도 PostgreSQL이 Seq Scan을 선택할 수 있습니다.

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
    ('최현우', 'hyunwoo@example.com', '2026-03-07'),
    ('정하늘', 'haneul@example.com', '2026-03-09');

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
    (3, '집계 쿼리 실습', 'GROUP BY와 HAVING 실습', 'intermediate', 130000, '2026-04-15'),
    (1, '인덱스와 성능 기초', 'EXPLAIN과 인덱스 기본 원리', 'intermediate', 140000, '2026-04-20');

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (1, 1, '2026-04-02', '수강중', 100000),
    (1, 2, '2026-04-06', '신청', 120000),
    (2, 1, '2026-04-03', '수강중', 100000),
    (3, 3, '2026-04-11', '신청', 150000),
    (2, 3, '2026-04-12', '완료', 150000),
    (4, 5, '2026-04-21', '수강중', 140000),
    (5, 5, '2026-04-22', '신청', 140000);

-- 4. 실습용 데이터 확인
SELECT COUNT(*) AS student_count FROM students;
SELECT COUNT(*) AS course_count FROM courses;
SELECT COUNT(*) AS enrollment_count FROM enrollments;

-- 5. 인덱스 생성 전 EXPLAIN: 이메일 검색
EXPLAIN
SELECT id, name, email
FROM students
WHERE email = 'minji@example.com';

-- 6. students.email 인덱스 생성
CREATE INDEX idx_students_email
ON students(email);

-- 7. 인덱스 생성 후 EXPLAIN: 이메일 검색
EXPLAIN
SELECT id, name, email
FROM students
WHERE email = 'minji@example.com';

-- 8. courses.title 인덱스 생성 전 EXPLAIN: 강의 제목 검색
EXPLAIN
SELECT id, title, level, price
FROM courses
WHERE title = '데이터베이스 입문';

-- 9. courses.title 인덱스 생성
CREATE INDEX idx_courses_title
ON courses(title);

-- 10. courses.title 인덱스 생성 후 EXPLAIN
EXPLAIN
SELECT id, title, level, price
FROM courses
WHERE title = '데이터베이스 입문';

-- 11. ORDER BY와 인덱스 확인
EXPLAIN
SELECT id, title, level, price
FROM courses
ORDER BY title;

-- 12. JOIN 조건 인덱스 생성 전 EXPLAIN: 특정 학생 수강신청 조회
EXPLAIN
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
WHERE e.student_id = 1;

-- 13. enrollments.student_id 인덱스 생성
CREATE INDEX idx_enrollments_student_id
ON enrollments(student_id);

-- 14. student_id 인덱스 생성 후 EXPLAIN
EXPLAIN
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
WHERE e.student_id = 1;

-- 15. 특정 강의의 수강생 조회를 위한 course_id 인덱스
EXPLAIN
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5;

CREATE INDEX idx_enrollments_course_id
ON enrollments(course_id);

EXPLAIN
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5;

-- 16. 복합 인덱스 생성 전 EXPLAIN: 특정 강의의 특정 상태 조회
EXPLAIN
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5 AND status = '수강중';

-- 17. 복합 인덱스 생성
CREATE INDEX idx_enrollments_course_status
ON enrollments(course_id, status);

-- 18. 복합 인덱스 생성 후 EXPLAIN
EXPLAIN
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5 AND status = '수강중';

-- 19. 현재 생성된 사용자 인덱스 확인
SELECT
    indexname,
    tablename,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- 20. 인덱스 검토 질문
-- 다음 질문에 답해 보세요.
-- 1. students.email 인덱스는 어떤 조회에 도움이 되나요?
-- 2. enrollments.student_id 인덱스는 어떤 JOIN 또는 WHERE 조건에 도움이 되나요?
-- 3. idx_enrollments_course_status에서 컬럼 순서가 중요한 이유는 무엇인가요?
-- 4. 샘플 데이터가 적을 때 EXPLAIN 결과가 예상과 다를 수 있는 이유는 무엇인가요?
-- 5. AI가 모든 컬럼에 인덱스를 만들라고 추천한다면 어떻게 검토해야 하나요?
