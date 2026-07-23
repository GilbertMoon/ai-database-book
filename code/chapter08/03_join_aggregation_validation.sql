-- Chapter 08. JOIN·집계 결과 검산
-- 목적: 상세 데이터와 그룹별 결과가 같은 기준으로 합산되는지 확인합니다.
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 전체 신청 행 수와 상태별 건수 합 비교
-- 둘 다 5여야 합니다.
-- ============================================================
SELECT COUNT(*) AS detail_count
FROM course_project.enrollments;

SELECT SUM(enrollment_count) AS grouped_count
FROM (
    SELECT
        status,
        COUNT(*) AS enrollment_count
    FROM course_project.enrollments
    GROUP BY status
) AS status_summary;

-- ============================================================
-- 2. 전체 기록 금액과 강의별 기록 금액 합 비교
-- 둘 다 590000이어야 합니다.
-- ============================================================
SELECT SUM(paid_amount) AS detail_total_recorded_amount
FROM course_project.enrollments;

SELECT SUM(total_recorded_amount) AS grouped_total_recorded_amount
FROM (
    SELECT
        course_id,
        SUM(paid_amount) AS total_recorded_amount
    FROM course_project.enrollments
    GROUP BY course_id
) AS course_summary;

-- ============================================================
-- 3. 활성 신청 상세 기준
-- Chapter 07과 동일하게 신청·수강중 상태입니다.
-- 기대 결과: 3 / 340000
-- ============================================================
SELECT
    COUNT(*) AS active_enrollment_count,
    SUM(paid_amount) AS active_recorded_amount
FROM course_project.enrollments
WHERE status IN ('신청', '수강중');

-- ============================================================
-- 4. 활성 신청 상태별 합
-- 기대 결과: 3 / 340000
-- ============================================================
SELECT
    SUM(active_count) AS grouped_active_count,
    SUM(active_recorded_amount) AS grouped_active_recorded_amount
FROM (
    SELECT
        status,
        COUNT(*) AS active_count,
        SUM(paid_amount) AS active_recorded_amount
    FROM course_project.enrollments
    WHERE status IN ('신청', '수강중')
    GROUP BY status
) AS active_summary;

-- ============================================================
-- 5. 취소 제외 신청 이력 상세 기준
-- 기대 결과: 4 / 440000
-- ============================================================
SELECT
    COUNT(*) AS non_cancelled_count,
    SUM(paid_amount) AS non_cancelled_recorded_amount
FROM course_project.enrollments
WHERE status <> '취소';

-- ============================================================
-- 6. 취소 제외 강의별 집계 합
-- 기대 결과: 4 / 440000
-- ============================================================
SELECT
    SUM(non_cancelled_count) AS grouped_non_cancelled_count,
    SUM(non_cancelled_recorded_amount)
        AS grouped_non_cancelled_recorded_amount
FROM (
    SELECT
        c.id,
        COUNT(e.id) AS non_cancelled_count,
        COALESCE(SUM(e.paid_amount), 0)
            AS non_cancelled_recorded_amount
    FROM course_project.courses AS c
    LEFT JOIN course_project.enrollments AS e
        ON c.id = e.course_id
       AND e.status <> '취소'
    GROUP BY c.id
) AS course_summary;

-- ============================================================
-- 7. INNER JOIN 결과 행 수가 원본 신청 수와 같은지 확인
-- 기대 결과: 5
-- ============================================================
SELECT COUNT(*) AS joined_count
FROM course_project.enrollments AS e
JOIN course_project.students AS s
    ON e.student_id = s.id
JOIN course_project.courses AS c
    ON e.course_id = c.id
JOIN course_project.instructors AS i
    ON c.instructor_id = i.id;

-- ============================================================
-- 8. 고아 관계 확인: 모두 0행이어야 합니다.
-- ============================================================
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

-- ============================================================
-- 9. 기준 상태 확인
-- 기대 결과: 신청 2 / 수강중 1 / 완료 1 / 취소 1
-- 업무 순서를 CASE로 명시합니다.
-- ============================================================
SELECT
    status,
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS recorded_amount
FROM course_project.enrollments
GROUP BY status
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END;
