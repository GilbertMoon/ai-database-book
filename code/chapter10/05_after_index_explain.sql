-- Chapter 10. 후보 인덱스 생성 후 실행 계획
-- 실행 전 01→02→03→04 파일을 순서대로 실행합니다.
-- 03과 완전히 같은 SELECT를 사용해 비교합니다.
-- 세 실험 후보 인덱스가 모두 존재하지 않으면 사후 측정을 중단합니다.

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

    IF to_regclass('performance_lab.idx_performance_courses_title') IS NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_student_id') IS NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_course_status') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: 세 실험 후보 인덱스가 모두 필요합니다. 04 파일을 확인하세요.';
    END IF;
END
$$;

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
    e.recorded_amount
FROM performance_lab.enrollments AS e
JOIN performance_lab.students AS s ON s.id = e.student_id
JOIN performance_lab.courses AS c ON c.id = e.course_id
WHERE e.student_id = 5000;

-- 4. 복합 인덱스 선두 컬럼만 사용
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, recorded_amount
FROM performance_lab.enrollments
WHERE course_id = 1500;

-- 5. 복합 인덱스 두 컬럼 사용
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status, recorded_amount
FROM performance_lab.enrollments
WHERE course_id = 1500
  AND status = '수강중';

-- 6. 선두 컬럼 없이 status만 사용
-- 데이터 분포와 비용에 따라 PostgreSQL 18+ Skip Scan 가능성도 있지만,
-- course_id 고유값이 많고 반환 비율이 높아 Seq Scan이 더 합리적일 수 있습니다.
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
