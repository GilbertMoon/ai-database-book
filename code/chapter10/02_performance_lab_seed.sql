-- Chapter 10. performance_lab 대량 데이터 생성
-- 실행 전 01_performance_lab_schema.sql을 먼저 실행합니다.
-- 기본값: students 10003 / instructors 2 / courses 2003 / enrollments 100005

SELECT current_database();
SELECT current_schema();

-- 1. 기본 학생
INSERT INTO performance_lab.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon@example.com', '2026-03-05');

-- 2. 기본 강사
INSERT INTO performance_lab.instructors (id, name, email, specialty)
VALUES
    (201, '문길래', 'gilbert@example.com', 'Database'),
    (202, '홍길동', 'hong@example.com', 'Python');

-- 3. 기본 강의
INSERT INTO performance_lab.courses (
    id, instructor_id, title, description, level, price, opened_at
)
VALUES
    (301, 201, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (302, 201, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (303, 202, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

-- 4. 기본 신청 5건
INSERT INTO performance_lab.enrollments (
    id, student_id, course_id, enrolled_at, status, paid_amount
)
VALUES
    (1001, 101, 301, '2026-04-02', '완료', 100000),
    (1002, 101, 302, '2026-04-06', '신청', 120000),
    (1003, 102, 301, '2026-04-03', '수강중', 100000),
    (1004, 103, 303, '2026-04-11', '취소', 150000),
    (1005, 102, 302, '2026-04-07', '신청', 120000);

-- 5. 성능 학생 10000명: id 1001~11000
INSERT INTO performance_lab.students (id, name, email, joined_at)
SELECT
    1000 + gs,
    '성능학생' || LPAD(gs::text, 5, '0'),
    'performance' || gs || '@example.com',
    DATE '2025-01-01' + (gs % 365)
FROM generate_series(1, 10000) AS gs;

-- 6. 성능 강의 2000개: id 1001~3000
INSERT INTO performance_lab.courses (
    id, instructor_id, title, description, level, price, opened_at
)
SELECT
    1000 + gs,
    CASE WHEN gs % 2 = 0 THEN 201 ELSE 202 END,
    '성능 테스트 강의 ' || LPAD(gs::text, 5, '0'),
    '인덱스 실습을 위한 자동 생성 강의',
    CASE gs % 3
        WHEN 0 THEN 'advanced'
        WHEN 1 THEN 'basic'
        ELSE 'intermediate'
    END,
    50000 + ((gs % 10) * 10000),
    DATE '2025-01-01' + (gs % 365)
FROM generate_series(1, 2000) AS gs;

-- 7. 성능 신청 100000건: id 10001~110000
-- 각 성능 학생은 약 10건, 각 성능 강의는 약 50건을 가집니다.
INSERT INTO performance_lab.enrollments (
    id, student_id, course_id, enrolled_at, status, paid_amount
)
SELECT
    10000 + gs,
    1001 + ((gs - 1) % 10000),
    1001 + ((gs - 1) % 2000),
    DATE '2025-01-01' + (gs % 365),
    CASE gs % 4
        WHEN 0 THEN '신청'
        WHEN 1 THEN '수강중'
        WHEN 2 THEN '완료'
        ELSE '취소'
    END,
    50000 + ((gs % 10) * 10000)
FROM generate_series(1, 100000) AS gs;

-- 8. 통계 갱신
ANALYZE performance_lab.students;
ANALYZE performance_lab.instructors;
ANALYZE performance_lab.courses;
ANALYZE performance_lab.enrollments;

-- 9. 행 수 확인
SELECT COUNT(*) AS student_count FROM performance_lab.students;
SELECT COUNT(*) AS instructor_count FROM performance_lab.instructors;
SELECT COUNT(*) AS course_count FROM performance_lab.courses;
SELECT COUNT(*) AS enrollment_count FROM performance_lab.enrollments;

-- 기대 결과: 10003 / 2 / 2003 / 100005

-- 10. 상태 분포 확인
SELECT status, COUNT(*) AS row_count
FROM performance_lab.enrollments
GROUP BY status
ORDER BY status;
