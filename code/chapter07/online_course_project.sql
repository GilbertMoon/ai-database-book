-- Chapter 07. 실전 프로젝트 1
-- 프로젝트: 온라인 강의 수강신청 데이터베이스 설계
-- 목적: 요구사항, 관계, 제약조건, 샘플 데이터, JOIN과 CRUD를 하나의 실행 흐름으로 검증한다.

-- 주의:
-- 이 파일은 enrollments, courses, instructors, students 테이블을
-- 삭제하고 다시 생성합니다.
-- 개인 실습용 데이터베이스에서만 실행하세요.

-- 0. 현재 연결된 데이터베이스 확인
SELECT current_database();

-- 1. 반복 실행을 위한 기존 테이블 삭제
-- 외래키로 참조하는 테이블부터 먼저 삭제한다.
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
    price INT NOT NULL CHECK (price >= 0),
    opened_at DATE NOT NULL
);

-- 5. 수강신청 테이블
CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('신청', '수강중', '완료', '취소')),
    paid_amount INT NOT NULL CHECK (paid_amount >= 0)
);

-- 같은 학생의 같은 강의 중복 신청을 막으려면 다음 제약조건을 선택적으로 추가할 수 있다.
-- 취소 후 재신청 이력을 별도로 남겨야 한다면 업무 규칙을 먼저 검토한다.
-- ALTER TABLE enrollments
-- ADD CONSTRAINT uq_enrollments_student_course
-- UNIQUE (student_id, course_id);

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
INSERT INTO courses
    (instructor_id, title, description, level, price, opened_at)
VALUES
    (1, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (1, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (2, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

-- 9. 수강신청 샘플 데이터
INSERT INTO enrollments
    (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (1, 1, '2026-04-02', '수강중', 100000),
    (1, 2, '2026-04-06', '신청', 120000),
    (2, 1, '2026-04-03', '수강중', 100000),
    (3, 3, '2026-04-11', '신청', 150000);

-- 10. 개별 테이블 확인
SELECT * FROM students ORDER BY id;
SELECT * FROM instructors ORDER BY id;
SELECT * FROM courses ORDER BY id;
SELECT * FROM enrollments ORDER BY id;

-- 11. 기본 데이터 건수 확인
-- 기본 샘플 입력 직후 기준이다.
SELECT COUNT(*) FROM students;      -- 예상 3
SELECT COUNT(*) FROM instructors;   -- 예상 2
SELECT COUNT(*) FROM courses;       -- 예상 3
SELECT COUNT(*) FROM enrollments;   -- 예상 4

-- 12. 수강신청 현황 JOIN 조회
-- enrollments 4건, INNER JOIN 결과 예상 4행
-- 이 시점은 CRUD 추가 전 기준선이다.
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
JOIN instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;

-- 13. 특정 학생의 수강신청 목록 조회
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
WHERE s.email = 'minji@example.com'
ORDER BY e.id;

-- 14. 새로운 수강신청 추가
-- 이준호가 정규화 실습을 신청한다.
INSERT INTO enrollments
    (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (2, 2, '2026-04-07', '신청', 120000);

-- 신규 신청 추가 후 enrollments는 5행이다.
SELECT COUNT(*) FROM enrollments;   -- 예상 5

-- 15. UPDATE 전 대상 확인
SELECT *
FROM enrollments
WHERE id = 1;

-- 16. 수강 상태 변경
UPDATE enrollments
SET status = '완료'
WHERE id = 1;

-- 17. UPDATE 후 결과 확인
SELECT *
FROM enrollments
WHERE id = 1;

-- 18. 삭제보다 상태 변경을 우선 검토
SELECT *
FROM enrollments
WHERE id = 4;

UPDATE enrollments
SET status = '취소'
WHERE id = 4;

SELECT *
FROM enrollments
WHERE id = 4;

-- 상태 변경 후 최종 상태 확인
-- id 1은 완료, id 4는 취소, 전체 enrollments는 5행이어야 한다.
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE id IN (1, 4)
ORDER BY id;

SELECT COUNT(*) FROM enrollments;   -- 예상 5

-- 19. 실제 삭제가 필요한 경우의 예시
-- 반드시 같은 WHERE 조건으로 SELECT를 먼저 실행한다.
-- SELECT * FROM enrollments WHERE id = 4;
-- DELETE FROM enrollments WHERE id = 4;
-- SELECT * FROM enrollments WHERE id = 4;

-- 20. Chapter 08 인계 상태 확인
-- 전체 SQL 파일을 끝까지 실행한 뒤의 기준 JOIN이다.
-- 최종 JOIN 결과 예상 5행
-- id 1 완료, id 4 취소, 신규 신청 행이 포함되어야 한다.
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
JOIN instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;

-- 21. 정규화 검토용 조회
-- 학생 이메일은 students에 한 번만 저장된다.
SELECT id, name, email
FROM students
ORDER BY id;

-- 강사 정보는 instructors에 한 번만 저장된다.
SELECT id, name, email, specialty
FROM instructors
ORDER BY id;

-- 학생과 강의의 N:M 관계는 enrollments로 해소한다.
SELECT student_id, course_id, status
FROM enrollments
ORDER BY student_id, course_id;

-- 22. 선택적 오류 검증 예시
-- 아래 SQL은 제약조건이 정상적으로 작동하는지 확인할 때
-- 한 문장씩 주석을 해제하여 선택적으로 실행한다.

-- 중복 이메일: UNIQUE 오류가 발생해야 정상이다.
-- INSERT INTO students (name, email, joined_at)
-- VALUES ('중복학생', 'minji@example.com', CURRENT_DATE);

-- 음수 가격: CHECK 오류가 발생해야 정상이다.
-- INSERT INTO courses
--     (instructor_id, title, description, level, price, opened_at)
-- VALUES
--     (1, '잘못된 가격 강의', NULL, 'basic', -1000, CURRENT_DATE);

-- 허용되지 않은 상태: CHECK 오류가 발생해야 정상이다.
-- INSERT INTO enrollments
--     (student_id, course_id, enrolled_at, status, paid_amount)
-- VALUES
--     (1, 3, CURRENT_DATE, '알 수 없음', 150000);

-- 존재하지 않는 학생 참조: FOREIGN KEY 오류가 발생해야 정상이다.
-- INSERT INTO enrollments
--     (student_id, course_id, enrolled_at, status, paid_amount)
-- VALUES
--     (999, 1, CURRENT_DATE, '신청', 100000);
