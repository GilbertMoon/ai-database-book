-- Chapter 08. course_project 실행 상태 확인
-- 목적: Chapter 07 최종 데이터가 정확히 준비되었는지 확인합니다.
-- 이 파일은 데이터를 변경하지 않습니다.
-- 조건이 맞지 않으면 예외를 발생시켜 Chapter 08 실행을 중단합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

DO $$
DECLARE
    v_student_count BIGINT;
    v_instructor_count BIGINT;
    v_course_count BIGINT;
    v_enrollment_count BIGINT;
    v_total_recorded_amount NUMERIC;
    v_active_count BIGINT;
    v_active_recorded_amount NUMERIC;
    v_non_cancelled_count BIGINT;
    v_non_cancelled_recorded_amount NUMERIC;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    IF to_regclass('course_project.students') IS NULL
       OR to_regclass('course_project.instructors') IS NULL
       OR to_regclass('course_project.courses') IS NULL
       OR to_regclass('course_project.enrollments') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: Chapter 07의 course_project 테이블이 모두 준비되지 않았습니다.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'course_project'
          AND table_name = 'enrollments'
          AND column_name = 'recorded_amount'
    ) THEN
        RAISE EXCEPTION
            '실행 중단: Chapter 07의 recorded_amount 열이 없습니다.';
    END IF;

    SELECT COUNT(*) INTO v_student_count
    FROM course_project.students;

    SELECT COUNT(*) INTO v_instructor_count
    FROM course_project.instructors;

    SELECT COUNT(*) INTO v_course_count
    FROM course_project.courses;

    SELECT COUNT(*) INTO v_enrollment_count
    FROM course_project.enrollments;

    SELECT COALESCE(SUM(recorded_amount), 0)
    INTO v_total_recorded_amount
    FROM course_project.enrollments;

    SELECT
        COUNT(*),
        COALESCE(SUM(recorded_amount), 0)
    INTO v_active_count, v_active_recorded_amount
    FROM course_project.enrollments
    WHERE status IN ('신청', '수강중');

    SELECT
        COUNT(*),
        COALESCE(SUM(recorded_amount), 0)
    INTO v_non_cancelled_count, v_non_cancelled_recorded_amount
    FROM course_project.enrollments
    WHERE status <> '취소';

    IF v_student_count <> 3
       OR v_instructor_count <> 2
       OR v_course_count <> 3
       OR v_enrollment_count <> 5
       OR v_total_recorded_amount <> 590000
       OR v_active_count <> 3
       OR v_active_recorded_amount <> 340000
       OR v_non_cancelled_count <> 4
       OR v_non_cancelled_recorded_amount <> 440000 THEN
        RAISE EXCEPTION
            '실행 중단: Chapter 07 기준 상태와 다릅니다. students=%, instructors=%, courses=%, enrollments=%, total=%, active=%/%, non_cancelled=%/%',
            v_student_count,
            v_instructor_count,
            v_course_count,
            v_enrollment_count,
            v_total_recorded_amount,
            v_active_count,
            v_active_recorded_amount,
            v_non_cancelled_count,
            v_non_cancelled_recorded_amount;
    END IF;

    RAISE NOTICE 'Chapter 08 prerequisite check passed';
END
$$;

SELECT id, student_id, course_id, status, recorded_amount
FROM course_project.enrollments
ORDER BY id;

SELECT
    COUNT(*) AS enrollment_count,
    SUM(recorded_amount) AS total_recorded_amount,
    ROUND(AVG(recorded_amount), 2) AS avg_recorded_amount,
    COUNT(*) FILTER (
        WHERE status IN ('신청', '수강중')
    ) AS active_enrollment_count,
    SUM(recorded_amount) FILTER (
        WHERE status IN ('신청', '수강중')
    ) AS active_recorded_amount,
    COUNT(*) FILTER (
        WHERE status <> '취소'
    ) AS non_cancelled_count,
    SUM(recorded_amount) FILTER (
        WHERE status <> '취소'
    ) AS non_cancelled_recorded_amount
FROM course_project.enrollments;
