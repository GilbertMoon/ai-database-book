-- Chapter 14. 기간별·범주별 분석
-- 목적: 월별 변화, 범주별 차이와 완료 기간을 분석합니다.

-- 1. 월별 신청 건수와 결제금액
SELECT
    DATE_TRUNC('month', enrolled_at)::date AS enrollment_month,
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS paid_amount_sum
FROM analysis_lab.enrollments
GROUP BY DATE_TRUNC('month', enrolled_at)
ORDER BY enrollment_month;

-- 기대:
-- 2026-01 3 / 200000
-- 2026-02 4 / 520000
-- 2026-03 5 / 540000
-- 2026-04 4 / 550000
-- 2026-05 4 / 390000
-- 2026-06 4 / 570000

-- 2. 이전 달 신청 건수와 비교
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', enrolled_at)::date AS enrollment_month,
        COUNT(*) AS enrollment_count,
        SUM(paid_amount) AS paid_amount_sum
    FROM analysis_lab.enrollments
    GROUP BY DATE_TRUNC('month', enrolled_at)
)
SELECT
    enrollment_month,
    enrollment_count,
    LAG(enrollment_count) OVER (
        ORDER BY enrollment_month
    ) AS previous_enrollment_count,
    enrollment_count
        - LAG(enrollment_count) OVER (
            ORDER BY enrollment_month
        ) AS enrollment_count_change,
    paid_amount_sum,
    LAG(paid_amount_sum) OVER (
        ORDER BY enrollment_month
    ) AS previous_paid_amount_sum,
    paid_amount_sum
        - LAG(paid_amount_sum) OVER (
            ORDER BY enrollment_month
        ) AS paid_amount_change
FROM monthly
ORDER BY enrollment_month;

-- 3. 월별 상태 구성
SELECT
    DATE_TRUNC('month', enrolled_at)::date AS enrollment_month,
    status,
    COUNT(*) AS enrollment_count
FROM analysis_lab.enrollments
GROUP BY DATE_TRUNC('month', enrolled_at), status
ORDER BY enrollment_month, status;

-- 4. 범주별 신청 건수와 결제금액
SELECT
    c.category,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.paid_amount), 0) AS paid_amount_sum,
    ROUND(AVG(e.paid_amount), 2) AS avg_paid_amount
FROM analysis_lab.courses c
LEFT JOIN analysis_lab.enrollments e
    ON e.course_id = c.id
GROUP BY c.category
ORDER BY enrollment_count DESC, c.category;

-- 기대:
-- Database 10 / 1120000
-- Python 5 / 450000
-- Data Analysis 5 / 560000
-- AI 4 / 640000

-- 5. 범주별 완료율
SELECT
    c.category,
    COUNT(e.id) AS enrollment_count,
    COUNT(e.id) FILTER (
        WHERE e.status = '완료'
    ) AS completed_count,
    ROUND(
        COUNT(e.id) FILTER (WHERE e.status = '완료')
        * 100.0
        / NULLIF(COUNT(e.id), 0),
        2
    ) AS completion_rate_pct
FROM analysis_lab.courses c
LEFT JOIN analysis_lab.enrollments e
    ON e.course_id = c.id
GROUP BY c.category
ORDER BY c.category;

-- 6. 완료 기간 요약
SELECT
    COUNT(*) AS completed_count,
    ROUND(AVG(completed_at - enrolled_at), 2) AS avg_completion_days,
    MIN(completed_at - enrolled_at) AS min_completion_days,
    MAX(completed_at - enrolled_at) AS max_completion_days
FROM analysis_lab.enrollments
WHERE status = '완료';

-- 기대: completed_count 12, avg 25, min 18, max 36

-- 7. 강의별 평균 완료 기간
SELECT
    c.id AS course_id,
    c.title,
    COUNT(e.id) FILTER (
        WHERE e.status = '완료'
    ) AS completed_count,
    ROUND(
        AVG(e.completed_at - e.enrolled_at)
            FILTER (WHERE e.status = '완료'),
        2
    ) AS avg_completion_days
FROM analysis_lab.courses c
LEFT JOIN analysis_lab.enrollments e
    ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY c.id;

-- 8. 분석 기간 검산
SELECT
    MIN(enrolled_at) AS min_enrolled_at,
    MAX(enrolled_at) AS max_enrolled_at,
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS paid_amount_sum
FROM analysis_lab.enrollments
WHERE enrolled_at >= DATE '2026-01-01'
  AND enrolled_at < DATE '2026-07-01';

-- 기대: 2026-01-10 / 2026-06-22 / 24 / 2770000
