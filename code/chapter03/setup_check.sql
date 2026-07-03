-- Chapter 03. PostgreSQL 환경 확인 실습
-- 목적: PostgreSQL 연결, 현재 데이터베이스, 기본 SQL 실행, students 테이블 생성과 제약조건 확인

-- 1. PostgreSQL 버전 확인
SELECT version();

-- 2. 현재 연결된 데이터베이스 확인
SELECT current_database();

-- 3. 간단한 SQL 실행 테스트
SELECT 1 + 1 AS result;

-- 4. 기존 실습 테이블이 있다면 삭제
-- 반복 실습을 위해 필요할 때만 사용합니다.
-- DROP TABLE IF EXISTS students;

-- 5. students 테이블 생성
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. 샘플 데이터 입력
INSERT INTO students (name, email)
VALUES
    ('김민지', 'minji@example.com'),
    ('이준호', 'junho@example.com'),
    ('박서연', 'seoyeon@example.com');

-- 7. 입력 데이터 조회
SELECT *
FROM students;

-- 8. UNIQUE 제약조건 확인용 오류 실습
-- 아래 SQL은 이미 존재하는 이메일을 다시 입력하므로 오류가 발생해야 정상입니다.
-- INSERT INTO students (name, email)
-- VALUES ('중복학생', 'minji@example.com');
