-- Chapter 10. 후보 인덱스 생성 전 기준 실행 계획
-- 실행 전 01, 02 파일을 실행합니다.
-- 이 파일은 SELECT만 실제 실행합니다.

SELECT current_database();

-- 현재 자동 인덱스 확인
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'performance_lab'
ORDER BY tablename, indexname;

-- 1. UNIQUE 자동 인덱스가 있는 이메일 검색
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';

-- 2. 일반 컬럼 title 정확 일치
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM performance_lab.courses
WHERE title = '성능 테스트 강의 00500';

-- 3. 학생별 신청 JOIN
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM performance_lab.enrollments AS e
JOIN performance_lab.students AS s ON s.id = e.student_id
JOIN performance_lab.courses AS c ON c.id = e.course_id
WHERE e.student_id = 5000;

-- 4. course_id 단독 조건
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM performance_lab.enrollments
WHERE course_id = 1500;

-- 5. course_id + status 복합 조건
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM performance_lab.enrollments
WHERE course_id = 1500
  AND status = '수강중';

-- 6. status 단독 조건
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status
FROM performance_lab.enrollments
WHERE status = '수강중';

-- 7. 전체 정렬
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM performance_lab.courses
ORDER BY title;

-- 8. 정렬 + LIMIT
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM performance_lab.courses
ORDER BY title
LIMIT 20;
