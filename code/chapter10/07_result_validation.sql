-- Chapter 10. 성능 실험 결과·데이터 상태 검증
-- 실행 전 01→06 파일을 순서대로 실행합니다.
-- 실행 계획 노드 자체는 환경에 따라 달라질 수 있으므로 자동 판정하지 않습니다.
-- 대신 데이터 상태, 결과 행 수, 기존 프로젝트 보호와 실험 후보 인덱스 존재를 검증합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 핵심 결과 행 수 확인
-- ============================================================
SELECT COUNT(*) AS email_result_count
FROM performance_lab.students
WHERE email = 'performance5000@example.com';

SELECT COUNT(*) AS title_result_count
FROM performance_lab.courses
WHERE title = '성능 테스트 강의 00500';

SELECT COUNT(*) AS student_5000_enrollment_count
FROM performance_lab.enrollments
WHERE student_id = 5000;

SELECT COUNT(*) AS course_1500_enrollment_count
FROM performance_lab.enrollments
WHERE course_id = 1500;

SELECT COUNT(*) AS course_1500_learning_count
FROM performance_lab.enrollments
WHERE course_id = 1500
  AND status = '수강중';

SELECT COUNT(*) AS all_learning_count
FROM performance_lab.enrollments
WHERE status = '수강중';

-- 기대 결과: 1 / 1 / 10 / 50 / 15 / 30001

-- ============================================================
-- 2. 활성 신청 중복 확인
-- 기대 결과: 0행
-- ============================================================
SELECT
    student_id,
    course_id,
    COUNT(*) AS active_count
FROM performance_lab.enrollments
WHERE status IN ('신청', '수강중')
GROUP BY student_id, course_id
HAVING COUNT(*) > 1
ORDER BY student_id, course_id;

-- ============================================================
-- 3. 자동 판정
-- ============================================================
DO $$
DECLARE
    duplicate_active_pair_count BIGINT;
    experiment_index_count INTEGER;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '검증 실패: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('course_project.enrollments') IS NULL
       OR (SELECT COUNT(*) FROM course_project.enrollments) <> 5 THEN
        RAISE EXCEPTION
            '검증 실패: course_project.enrollments 기준 5행이 유지되지 않았습니다.';
    END IF;

    IF (SELECT COUNT(*) FROM performance_lab.students) <> 10003
       OR (SELECT COUNT(*) FROM performance_lab.instructors) <> 2
       OR (SELECT COUNT(*) FROM performance_lab.courses) <> 2003
       OR (SELECT COUNT(*) FROM performance_lab.enrollments) <> 100005 THEN
        RAISE EXCEPTION
            '검증 실패: performance_lab 기준 행 수가 예상과 다릅니다.';
    END IF;

    IF (SELECT COUNT(*) FROM performance_lab.students
        WHERE email = 'performance5000@example.com') <> 1
       OR (SELECT COUNT(*) FROM performance_lab.courses
           WHERE title = '성능 테스트 강의 00500') <> 1
       OR (SELECT COUNT(*) FROM performance_lab.enrollments
           WHERE student_id = 5000) <> 10
       OR (SELECT COUNT(*) FROM performance_lab.enrollments
           WHERE course_id = 1500) <> 50
       OR (SELECT COUNT(*) FROM performance_lab.enrollments
           WHERE course_id = 1500 AND status = '수강중') <> 15
       OR (SELECT COUNT(*) FROM performance_lab.enrollments
           WHERE status = '수강중') <> 30001 THEN
        RAISE EXCEPTION
            '검증 실패: 기준 SQL의 결과 행 수가 예상과 다릅니다.';
    END IF;

    SELECT COUNT(*)
    INTO duplicate_active_pair_count
    FROM (
        SELECT student_id, course_id
        FROM performance_lab.enrollments
        WHERE status IN ('신청', '수강중')
        GROUP BY student_id, course_id
        HAVING COUNT(*) > 1
    ) AS duplicated_active_pairs;

    IF duplicate_active_pair_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 활성 신청 중복 조합이 %건 있습니다.',
            duplicate_active_pair_count;
    END IF;

    SELECT COUNT(*)
    INTO experiment_index_count
    FROM pg_indexes
    WHERE schemaname = 'performance_lab'
      AND indexname IN (
          'idx_performance_courses_title',
          'idx_performance_enrollments_student_id',
          'idx_performance_enrollments_course_status'
      );

    IF experiment_index_count <> 3 THEN
        RAISE EXCEPTION
            '검증 실패: 실험 후보 인덱스는 3개여야 하지만 현재 %개입니다.',
            experiment_index_count;
    END IF;

    RAISE NOTICE 'Chapter 10 data and result validation passed';
END
$$;

-- 실행 계획의 최종 적용·보류·제거 판단은 워크북에 기록합니다.
-- 계획 노드, Buffers와 시간은 PostgreSQL 버전·장비·캐시 상태에 따라 달라질 수 있습니다.
