-- Chapter 10. 후보 인덱스 생성 후 실행 계획
-- 실행 전 01→02→03→04 파일을 순서대로 실행합니다.
-- 03과 완전히 같은 SELECT를 사용해 비교합니다.

SELECT current_database();

-- 1. 이메일 검색: 자동 UNIQUE 인덱스 사용 확인
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';

-- 2. title 정확 일치
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

-- 4. 복합 인덱스 선두 컬럼만 사용
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM performance_lab.enrollments
WHERE course_id = 1500;

-- 5. 복합 인덱스 두 컬럼 사용
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, paid_amount
FROM performance_lab.enrollments
WHERE course_id = 1500
  AND status = '수강중';

-- 6. 선두 컬럼 없이 status만 사용
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
