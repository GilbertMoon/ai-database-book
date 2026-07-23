-- Chapter 08. course_project 실행 상태 확인
-- 목적: Chapter 07 최종 데이터가 정확히 준비되었는지 확인합니다.
-- 이 파일은 데이터를 변경하지 않습니다.
-- 조건이 맞지 않으면 예외를 발생시켜 Chapter 08 실행을 중단합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- course_project를 완전한 이름으로 사용하므로
-- current_schema()가 course_project일 필요는 없습니다.

DO $$
DECLARE
    v_student_count BIGINT;
    v_instructor_count BIGINT;
    v_course_count BIGINT;
    v_enrollment_count BIGINT;
    v_total_recorded_amount BIGINT;
    v_active_count BIGINT;
    v_active_recorded_amount BIGINT;
    v_non_cancelled_count BIGINT;
    v_non_cancelled_recorded_amount BIGINT;
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

    EXECUTE 'SELECT COUNT(*) FROM course_project.students'
        INTO v_student_count;
    EXECUTE 'SELECT COUNT(*) FROM course_project.instructors'
        INTO v_instructor_count;
    EXECUTE 'SELECT COUNT(*) FROM course_project.courses'
        INTO v_course_count;
    EXECUTE 'SELECT COUNT(*) FROM course_project.enrollments'
        INTO v_enrollment_count;

    EXECUTE 'SELECT COALESCE(SUM(paid_amount), 0) FROM course_project.enrollments'
        INTO v_total_recorded_amount;
    EXECUTE $sql$
        SELECT COUNT(*)
        FROM course_project.enrollments
        WHERE status IN ('신청', '수강중')
    $sql$ INTO v_active_count;
    EXECUTE $sql$
        SELECT COALESCE(SUM(paid_amount), 0)
        FROM course_project.enrollments
        WHERE status IN ('신청', '수강중')
    $sql$ INTO v_active_recorded_amount;
    EXECUTE $sql$
        SELECT COUNT(*)
        FROM course_project.enrollments
        WHERE status <> '취소'
    $sql$ INTO v_non_cancelled_count;
    EXECUTE $sql$
        SELECT COALESCE(SUM(paid_amount), 0)
        FROM course_project.enrollments
        WHERE status <> '취소'
    $sql$ INTO v_non_cancelled_recorded_amount;

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
            '실행 중단: Chapter 07 기준 상태와 다릅니다. students=%, instructors=%, courses=%, enrollments=%, total=%, active=%/%원, non_cancelled=%/%원',
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
END
$$;

-- 프로젝트 스키마와 테이블 확인
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'course_project'
ORDER BY table_name;

-- 기대 행 수: 3 / 2 / 3 / 5
SELECT COUNT(*) AS student_count
FROM course_project.students;

SELECT COUNT(*) AS instructor_count
FROM course_project.instructors;

SELECT COUNT(*) AS course_count
FROM course_project.courses;

SELECT COUNT(*) AS enrollment_count
FROM course_project.enrollments;

-- 최종 변경 상태 확인
SELECT id, student_id, course_id, status, paid_amount
FROM course_project.enrollments
ORDER BY id;

-- 기대 상태:
-- 1001 완료 / 1004 취소 / 1005 신청

-- 기본 검산값
SELECT
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS total_recorded_amount,
    ROUND(AVG(paid_amount), 2) AS avg_recorded_amount,
    COUNT(*) FILTER (
        WHERE status IN ('신청', '수강중')
    ) AS active_enrollment_count,
    SUM(paid_amount) FILTER (
        WHERE status IN ('신청', '수강중')
    ) AS active_recorded_amount,
    COUNT(*) FILTER (
        WHERE status <> '취소'
    ) AS non_cancelled_count,
    SUM(paid_amount) FILTER (
        WHERE status <> '취소'
    ) AS non_cancelled_recorded_amount
FROM course_project.enrollments;

-- 기대 결과:
-- 전체 5 / 590000 / 118000.00
-- 활성 신청 3 / 340000
-- 취소 제외 신청 이력 4 / 440000
