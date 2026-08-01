-- Chapter 08. JOIN·집계 결과 검산
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 1. 전체 신청 행 수와 상태별 건수 합 비교: 모두 5
SELECT COUNT(*) AS detail_count
FROM course_project.enrollments;

SELECT SUM(enrollment_count) AS grouped_count
FROM (
    SELECT status, COUNT(*) AS enrollment_count
    FROM course_project.enrollments
    GROUP BY status
) AS status_summary;

-- 2. 전체 기록 금액과 강의별 기록 금액 합: 모두 590000
SELECT SUM(recorded_amount) AS detail_total_recorded_amount
FROM course_project.enrollments;

SELECT SUM(total_recorded_amount) AS grouped_total_recorded_amount
FROM (
    SELECT course_id, SUM(recorded_amount) AS total_recorded_amount
    FROM course_project.enrollments
    GROUP BY course_id
) AS course_summary;

-- 3. 활성 신청 상세 기준: 3 / 340000
SELECT
    COUNT(*) AS active_enrollment_count,
    SUM(recorded_amount) AS active_recorded_amount
FROM course_project.enrollments
WHERE status IN ('신청', '수강중');

-- 4. 활성 신청 상태별 합
SELECT
    SUM(active_count) AS grouped_active_count,
    SUM(active_recorded_amount) AS grouped_active_recorded_amount
FROM (
    SELECT
        status,
        COUNT(*) AS active_count,
        SUM(recorded_amount) AS active_recorded_amount
    FROM course_project.enrollments
    WHERE status IN ('신청', '수강중')
    GROUP BY status
) AS active_summary;

-- 5. 취소 제외 상세 기준: 4 / 440000
SELECT
    COUNT(*) AS non_cancelled_count,
    SUM(recorded_amount) AS non_cancelled_recorded_amount
FROM course_project.enrollments
WHERE status <> '취소';

-- 6. 취소 제외 강의별 집계 합
SELECT
    SUM(non_cancelled_count) AS grouped_non_cancelled_count,
    SUM(non_cancelled_recorded_amount) AS grouped_non_cancelled_recorded_amount
FROM (
    SELECT
        c.id,
        COUNT(e.id) AS non_cancelled_count,
        COALESCE(SUM(e.recorded_amount), 0) AS non_cancelled_recorded_amount
    FROM course_project.courses AS c
    LEFT JOIN course_project.enrollments AS e
        ON c.id = e.course_id
       AND e.status <> '취소'
    GROUP BY c.id
) AS course_summary;

-- 7. INNER JOIN 결과 행 수: 5
SELECT COUNT(*) AS joined_count
FROM course_project.enrollments AS e
JOIN course_project.students AS s
    ON e.student_id = s.id
JOIN course_project.courses AS c
    ON e.course_id = c.id
JOIN course_project.instructors AS i
    ON c.instructor_id = i.id;

-- 8. 고아 관계: 모두 0행
SELECT e.*
FROM course_project.enrollments AS e
LEFT JOIN course_project.students AS s
    ON e.student_id = s.id
WHERE s.id IS NULL;

SELECT e.*
FROM course_project.enrollments AS e
LEFT JOIN course_project.courses AS c
    ON e.course_id = c.id
WHERE c.id IS NULL;

SELECT c.*
FROM course_project.courses AS c
LEFT JOIN course_project.instructors AS i
    ON c.instructor_id = i.id
WHERE i.id IS NULL;

-- 9. 상태별 기준
SELECT
    status,
    COUNT(*) AS enrollment_count,
    SUM(recorded_amount) AS recorded_amount_total
FROM course_project.enrollments
GROUP BY status
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END;
