-- Chapter 07. 온라인 강의 수강신청 기본 샘플 데이터
-- 실행 전 01_course_project_schema.sql을 먼저 실행합니다.
-- 명시적 ID를 사용해 자동 증가값의 이전 상태를 가정하지 않습니다.

SELECT current_database();
SELECT current_schema();

INSERT INTO course_project.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon@example.com', '2026-03-05');

INSERT INTO course_project.instructors (id, name, email, specialty)
VALUES
    (201, '문길래', 'gilbert@example.com', 'Database'),
    (202, '홍길동', 'hong@example.com', 'Python');

INSERT INTO course_project.courses (
    id, instructor_id, title, description, level, price, opened_at
)
VALUES
    (301, 201, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (302, 201, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (303, 202, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

INSERT INTO course_project.enrollments (
    id, student_id, course_id, enrolled_at, status, paid_amount
)
VALUES
    (1001, 101, 301, '2026-04-02', '수강중', 100000),
    (1002, 101, 302, '2026-04-06', '신청', 120000),
    (1003, 102, 301, '2026-04-03', '수강중', 100000),
    (1004, 103, 303, '2026-04-11', '신청', 150000);

-- 기본 기대 행 수: students 3, instructors 2, courses 3, enrollments 4
-- 같은 파일을 다시 실행하면 PK 또는 UNIQUE 오류가 발생할 수 있습니다.
