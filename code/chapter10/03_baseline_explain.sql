-- Chapter 10. 후보 인덱스 생성 전 기준 실행 계획
-- 실행 전 01, 02 파일을 실행합니다.
-- 이 파일은 SELECT만 실제 실행합니다.
-- 세 실험 후보 인덱스가 하나라도 존재하면 기준 측정을 중단합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('performance_lab.students') IS NULL
       OR to_regclass('performance_lab.courses') IS NULL
       OR to_regclass('performance_lab.enrollments') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: performance_lab이 준비되지 않았습니다.';
    END IF;

    IF (SELECT COUNT(*) FROM performance_lab.students) <> 10003
       OR (SELECT COUNT(*) FROM performance_lab.courses) <> 2003
       OR (SELECT COUNT(*) FROM performance_lab.enrollments) <> 100005 THEN
        RAISE EXCEPTION
            '실행 중단: 기준 데이터 행 수가 예상과 다릅니다.';
    END IF;

    IF to_regclass('performance_lab.idx_performance_courses_title') IS NOT NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_student_id') IS NOT NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_course_status') IS NOT NULL THEN
        RAISE EXCEPTION
            '실행 중단: 실험 후보 인덱스가 이미 존재합니다. 기준 계획을 다시 측정하려면 performance_lab을 초기화하세요.';
    END IF;
END
$$;

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

-- 3. 학생별 신청 JOIN: student_id 5000은 10행
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.recorded_amount
FROM performance_lab.enrollments AS e
JOIN performance_lab.students AS s ON s.id = e.student_id
JOIN performance_lab.courses AS c ON c.id = e.course_id
WHERE e.student_id = 5000;

-- 4. course_id 단독 조건: 50행
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, recorded_amount
FROM performance_lab.enrollments
WHERE course_id = 1500;

-- 5. course_id + status 복합 조건: 수강중 15행
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, recorded_amount
FROM performance_lab.enrollments
WHERE course_id = 1500
  AND status = '수강중';

-- 6. status 단독 조건: 수강중 30001행
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
