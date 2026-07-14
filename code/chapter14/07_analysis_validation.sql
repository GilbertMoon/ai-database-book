-- Chapter 14. SQL 분석 최종 검증
-- 목적: 기준 행 수와 상태·월별·금액·완료 기간 결과를 한 번 더 확인합니다.
-- 이 파일은 읽기 전용 조회만 수행합니다.

-- 1. 테이블과 VIEW 행 수
SELECT
    (SELECT COUNT(*) FROM analysis_lab.students) AS students_count,
    (SELECT COUNT(*) FROM analysis_lab.instructors) AS instructors_count,
    (SELECT COUNT(*) FROM analysis_lab.courses) AS courses_count,
    (SELECT COUNT(*) FROM analysis_lab.enrollments) AS enrollments_count,
    (SELECT COUNT(*) FROM analysis_lab.enrollment_analysis_dataset)
        AS dataset_count;

-- 기대: 8 / 3 / 5 / 24 / 24

-- 2. 상태별 기대값과 실제값 비교
WITH expected(status, expected_count) AS (
    VALUES
        ('완료'::varchar, 12),
        ('수강중'::varchar, 5),
        ('신청'::varchar, 4),
        ('취소'::varchar, 3)
),
actual AS (
    SELECT
        status,
        COUNT(*)::integer AS actual_count
    FROM analysis_lab.enrollments
    GROUP BY status
)
SELECT
    e.status,
    e.expected_count,
    COALESCE(a.actual_count, 0) AS actual_count,
    e.expected_count = COALESCE(a.actual_count, 0) AS passed
FROM expected e
LEFT JOIN actual a
    ON a.status = e.status
ORDER BY e.status;

-- 3. 월별 기대값과 실제값 비교
WITH expected(
    enrollment_month,
    expected_count,
    expected_paid_amount
) AS (
    VALUES
        (DATE '2026-01-01', 3, 200000),
        (DATE '2026-02-01', 4, 520000),
        (DATE '2026-03-01', 5, 540000),
        (DATE '2026-04-01', 4, 550000),
        (DATE '2026-05-01', 4, 390000),
        (DATE '2026-06-01', 4, 570000)
),
actual AS (
    SELECT
        DATE_TRUNC('month', enrolled_at)::date AS enrollment_month,
        COUNT(*)::integer AS actual_count,
        SUM(paid_amount)::integer AS actual_paid_amount
    FROM analysis_lab.enrollments
    GROUP BY DATE_TRUNC('month', enrolled_at)
)
SELECT
    e.enrollment_month,
    e.expected_count,
    COALESCE(a.actual_count, 0) AS actual_count,
    e.expected_count = COALESCE(a.actual_count, 0)
        AS count_passed,
    e.expected_paid_amount,
    COALESCE(a.actual_paid_amount, 0) AS actual_paid_amount,
    e.expected_paid_amount = COALESCE(a.actual_paid_amount, 0)
        AS paid_amount_passed
FROM expected e
LEFT JOIN actual a
    ON a.enrollment_month = e.enrollment_month
ORDER BY e.enrollment_month;

-- 4. 완료 기간 기준값
SELECT
    COUNT(*) AS completed_count,
    ROUND(AVG(completed_at - enrolled_at), 2) AS avg_completion_days,
    MIN(completed_at - enrolled_at) AS min_completion_days,
    MAX(completed_at - enrolled_at) AS max_completion_days,
    COUNT(*) = 12 AS completed_count_passed,
    ROUND(AVG(completed_at - enrolled_at), 2) = 25.00
        AS avg_completion_days_passed,
    MIN(completed_at - enrolled_at) = 18
        AS min_completion_days_passed,
    MAX(completed_at - enrolled_at) = 36
        AS max_completion_days_passed
FROM analysis_lab.enrollments
WHERE status = '완료';

-- 5. 데이터셋 중복과 핵심 합계
SELECT
    COUNT(*) AS dataset_row_count,
    COUNT(DISTINCT enrollment_id) AS distinct_enrollment_count,
    SUM(paid_amount) AS paid_amount_sum,
    COUNT(*) FILTER (WHERE is_completed) AS completed_count,
    COUNT(*) = 24 AS dataset_row_count_passed,
    COUNT(DISTINCT enrollment_id) = 24
        AS distinct_enrollment_count_passed,
    SUM(paid_amount) = 2770000 AS paid_amount_sum_passed,
    COUNT(*) FILTER (WHERE is_completed) = 12
        AS completed_count_passed
FROM analysis_lab.enrollment_analysis_dataset;

-- 6. 데이터 품질 이상 건수
WITH quality_issues AS (
    SELECT 'orphan_student' AS issue_type, COUNT(*) AS issue_count
    FROM analysis_lab.enrollments e
    LEFT JOIN analysis_lab.students s
        ON s.id = e.student_id
    WHERE s.id IS NULL

    UNION ALL

    SELECT 'orphan_course', COUNT(*)
    FROM analysis_lab.enrollments e
    LEFT JOIN analysis_lab.courses c
        ON c.id = e.course_id
    WHERE c.id IS NULL

    UNION ALL

    SELECT 'completed_without_date', COUNT(*)
    FROM analysis_lab.enrollments
    WHERE status = '완료'
      AND completed_at IS NULL

    UNION ALL

    SELECT 'non_completed_with_date', COUNT(*)
    FROM analysis_lab.enrollments
    WHERE status <> '완료'
      AND completed_at IS NOT NULL

    UNION ALL

    SELECT 'invalid_cancel_amount', COUNT(*)
    FROM analysis_lab.enrollments
    WHERE status = '취소'
      AND paid_amount <> 0

    UNION ALL

    SELECT 'duplicate_dataset_id', COUNT(*)
    FROM (
        SELECT enrollment_id
        FROM analysis_lab.enrollment_analysis_dataset
        GROUP BY enrollment_id
        HAVING COUNT(*) > 1
    ) duplicates
)
SELECT
    issue_type,
    issue_count,
    issue_count = 0 AS passed
FROM quality_issues
ORDER BY issue_type;

-- 7. Chapter 14 SQL 완료 게이트
WITH checks AS (
    SELECT
        (SELECT COUNT(*) FROM analysis_lab.students) = 8
            AS students_passed,
        (SELECT COUNT(*) FROM analysis_lab.instructors) = 3
            AS instructors_passed,
        (SELECT COUNT(*) FROM analysis_lab.courses) = 5
            AS courses_passed,
        (SELECT COUNT(*) FROM analysis_lab.enrollments) = 24
            AS enrollments_passed,
        (SELECT COUNT(*) FROM analysis_lab.enrollment_analysis_dataset) = 24
            AS dataset_passed,
        (SELECT SUM(paid_amount) FROM analysis_lab.enrollments) = 2770000
            AS paid_amount_passed,
        (
            SELECT COUNT(*)
            FROM analysis_lab.enrollments
            WHERE status = '완료'
        ) = 12 AS completed_count_passed
)
SELECT
    *,
    students_passed
    AND instructors_passed
    AND courses_passed
    AND enrollments_passed
    AND dataset_passed
    AND paid_amount_passed
    AND completed_count_passed
        AS chapter14_sql_validation_passed
FROM checks;
