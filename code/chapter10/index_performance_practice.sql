-- Chapter 10. 인덱스와 성능 기초
-- 목적: 온라인 강의 수강신청 데이터셋에서 인덱스 생성 전후 실행 계획을 비교한다.

-- 주의:
-- 이 파일은 Chapter 10 실습 테이블을 삭제하고
-- 성능 비교용 데이터를 다시 생성합니다.
-- 개인 실습용 ai_database_book 데이터베이스에서만 실행하세요.
-- 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 마세요.

SELECT current_database();

-- 1. 반복 실습을 위한 기존 테이블 삭제
-- Chapter 09에서 payments가 enrollments를 참조했을 수 있으므로 먼저 삭제한다.
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
    opened_at DATE NOT NULL
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

-- 3. 기본 예제 데이터 입력
INSERT INTO students (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-03'),
    ('박서연', 'seoyeon@example.com', '2026-03-05'),
    ('최현우', 'hyunwoo@example.com', '2026-03-07'),
    ('정하늘', 'haneul@example.com', '2026-03-09');

INSERT INTO instructors (name, email, specialty)
VALUES
    ('문길버트', 'gilbert@example.com', 'Database'),
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

-- 4. 성능 비교용 대량 데이터 생성
-- 개인 PC에서 시간이 오래 걸리면 enrollments generate_series의 100000을 50000으로 줄여도 된다.
INSERT INTO students (name, email, joined_at)
SELECT
    '성능학생' || gs,
    'performance' || gs || '@example.com',
    DATE '2025-01-01' + (gs % 365)
FROM generate_series(1, 10000) AS gs;

INSERT INTO courses (instructor_id, title, description, level, price, opened_at)
SELECT
    1 + ((gs - 1) % 3),
    '성능 테스트 강의 ' || LPAD(gs::text, 5, '0'),
    '인덱스 실습을 위한 자동 생성 강의',
    CASE
        WHEN gs % 2 = 0 THEN 'basic'
        ELSE 'intermediate'
    END,
    50000 + ((gs % 10) * 10000),
    DATE '2025-01-01' + (gs % 365)
FROM generate_series(1, 2000) AS gs;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
SELECT
    1 + ((gs - 1) % 10005),
    1 + ((gs - 1) % 2005),
    DATE '2025-01-01' + (gs % 365),
    CASE gs % 4
        WHEN 0 THEN '신청'
        WHEN 1 THEN '수강중'
        WHEN 2 THEN '완료'
        ELSE '취소'
    END,
    50000 + ((gs % 10) * 10000)
FROM generate_series(1, 100000) AS gs;

-- 5. 통계 갱신
ANALYZE students;
ANALYZE instructors;
ANALYZE courses;
ANALYZE enrollments;

-- 6. 예상 행 수 확인
SELECT COUNT(*) AS students_count FROM students;       -- 예상 10005
SELECT COUNT(*) AS instructors_count FROM instructors; -- 예상 3
SELECT COUNT(*) AS courses_count FROM courses;         -- 예상 2005
SELECT COUNT(*) AS enrollments_count FROM enrollments; -- 예상 100007

-- 7. 자동 생성 인덱스 확인
-- PRIMARY KEY와 UNIQUE는 자동으로 고유 인덱스를 만든다.
-- FOREIGN KEY 자식 컬럼에는 인덱스가 자동 생성되지 않는다.
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('students', 'instructors', 'courses', 'enrollments')
ORDER BY tablename, indexname;

-- 8. students.email 조회 계획 확인
-- students.email은 UNIQUE 제약조건으로 자동 인덱스가 이미 있으므로 idx_students_email을 만들지 않는다.
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, email
FROM students
WHERE email = 'performance5000@example.com';

-- 9. courses.title 인덱스 생성 전 조회 계획
DROP INDEX IF EXISTS idx_courses_title;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM courses
WHERE title = '데이터베이스 입문';

CREATE INDEX idx_courses_title
ON courses(title);

ANALYZE courses;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM courses
WHERE title = '데이터베이스 입문';

-- 10. ORDER BY와 LIMIT 비교
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM courses
ORDER BY title;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM courses
ORDER BY title
LIMIT 20;

-- 11. enrollments.student_id 인덱스 비교
DROP INDEX IF EXISTS idx_enrollments_student_id;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
WHERE e.student_id = 1;

CREATE INDEX idx_enrollments_student_id
ON enrollments(student_id);

ANALYZE enrollments;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
WHERE e.student_id = 1;

-- 12. course_id 단일 인덱스 비교
DROP INDEX IF EXISTS idx_enrollments_course_id;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5;

CREATE INDEX idx_enrollments_course_id
ON enrollments(course_id);

ANALYZE enrollments;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5;

-- 복합 인덱스와 역할이 겹치는지 비교하기 위해 단일 course_id 인덱스는 제거한다.
DROP INDEX IF EXISTS idx_enrollments_course_id;

-- 13. 복합 인덱스 생성 전 계획
DROP INDEX IF EXISTS idx_enrollments_course_status;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5
  AND status = '수강중';

CREATE INDEX idx_enrollments_course_status
ON enrollments(course_id, status);

ANALYZE enrollments;

-- 14. 복합 인덱스 생성 후 세 가지 조건 비교
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 5
  AND status = '수강중';

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE status = '수강중';

-- 15. 최종 인덱스 목록 확인
-- idx_% 조건만 사용하지 않고 PK와 UNIQUE 자동 인덱스까지 함께 확인한다.
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('students', 'instructors', 'courses', 'enrollments')
ORDER BY tablename, indexname;

-- 최종 수동 인덱스 기준:
-- idx_courses_title
-- idx_enrollments_student_id
-- idx_enrollments_course_status
