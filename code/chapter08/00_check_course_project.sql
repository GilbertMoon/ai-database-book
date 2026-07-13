-- Chapter 08. course_project 실행 상태 확인
-- 목적: Chapter 07 최종 데이터가 준비되었는지 확인합니다.
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();

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
    SUM(paid_amount) AS total_paid_amount,
    AVG(paid_amount) AS avg_paid_amount,
    COUNT(*) FILTER (WHERE status <> '취소') AS non_cancelled_count,
    SUM(paid_amount) FILTER (WHERE status <> '취소')
        AS non_cancelled_paid_amount
FROM course_project.enrollments;

-- 기대 결과: 5 / 590000 / 118000 / 4 / 440000
