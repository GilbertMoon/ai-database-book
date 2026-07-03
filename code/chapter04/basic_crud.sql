-- Chapter 04. 관계형 데이터베이스와 SQL 기초
-- 목적: SELECT, INSERT, UPDATE, DELETE, WHERE, ORDER BY 기본 실습

-- 1. 반복 실습을 위한 기존 테이블 삭제
DROP TABLE IF EXISTS students;

-- 2. students 테이블 생성
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    major VARCHAR(100),
    grade INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 샘플 데이터 입력
INSERT INTO students (name, email, major, grade)
VALUES
    ('김민지', 'minji@example.com', '컴퓨터공학', 2),
    ('이준호', 'junho@example.com', '데이터사이언스', 3),
    ('박서연', 'seoyeon@example.com', '경영학', 1),
    ('최현우', 'hyunwoo@example.com', '컴퓨터공학', 4),
    ('정하늘', 'haneul@example.com', 'AI데이터공학', 2);

-- 4. 전체 데이터 조회
SELECT *
FROM students;

-- 5. 특정 컬럼만 조회
SELECT name, email, major
FROM students;

-- 6. WHERE 조건 조회
SELECT *
FROM students
WHERE major = '컴퓨터공학';

-- 7. 비교 연산자 사용
SELECT *
FROM students
WHERE grade >= 3;

-- 8. AND 조건 사용
SELECT *
FROM students
WHERE major = '컴퓨터공학'
  AND grade >= 3;

-- 9. OR 조건 사용
SELECT *
FROM students
WHERE major = '컴퓨터공학'
   OR major = '데이터사이언스';

-- 10. ORDER BY 오름차순
SELECT *
FROM students
ORDER BY grade ASC;

-- 11. ORDER BY 내림차순
SELECT *
FROM students
ORDER BY grade DESC;

-- 12. UPDATE 전 대상 확인
SELECT *
FROM students
WHERE email = 'junho@example.com';

-- 13. UPDATE 실행
UPDATE students
SET grade = 4
WHERE email = 'junho@example.com';

-- 14. UPDATE 후 결과 확인
SELECT *
FROM students
WHERE email = 'junho@example.com';

-- 15. DELETE 전 대상 확인
SELECT *
FROM students
WHERE email = 'seoyeon@example.com';

-- 16. DELETE 실행
DELETE FROM students
WHERE email = 'seoyeon@example.com';

-- 17. DELETE 후 전체 조회
SELECT *
FROM students;

-- 18. 위험한 UPDATE 예시
-- 아래 SQL은 모든 학생의 학년을 1로 바꾸므로 실행하지 않습니다.
-- UPDATE students
-- SET grade = 1;

-- 19. 위험한 DELETE 예시
-- 아래 SQL은 모든 학생 데이터를 삭제하므로 실행하지 않습니다.
-- DELETE FROM students;
