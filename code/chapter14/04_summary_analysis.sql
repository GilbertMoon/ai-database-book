-- Chapter 14. 기본 요약 분석
-- 목적: 상태, 강의, 지역을 기준으로 수강신청 데이터를 집계합니다.

-- 1. 상태별 수강신청 건수
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM analysis_lab.enrollments
GROUP BY status
ORDER BY enrollment_count DESC, status;

-- 기대: 완료 12, 수강중 5, 신청 4, 취소 3

-- 2. 상태별 건수와 비율
SELECT
    status,
    COUNT(*) AS enrollment_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS enrollment_rate_pct
FROM analysis_lab.enrollments
GROUP BY status
ORDER BY enrollment_count DESC, status;

-- 3. 강의별 신청 건수와 결제금액
SELECT
    c.id AS course_id,
    c.title,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.paid_amount), 0) AS paid_amount_sum
FROM analysis_lab.courses c
LEFT JOIN analysis_lab.enrollments e
    ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY enrollment_count DESC, c.id;

-- 기대:
-- 301 데이터베이스 입문 6 / 600000
-- 302 SQL 데이터 분석 4 / 520000
-- 303 파이썬 데이터 분석 5 / 450000
-- 304 데이터 시각화 5 / 560000
-- 305 AI 활용 데이터 설계 4 / 640000

-- 4. 강사별 강의 수와 신청 건수
SELECT
    i.id AS instructor_id,
    i.name AS instructor_name,
    COUNT(DISTINCT c.id) AS course_count,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.paid_amount), 0) AS paid_amount_sum
FROM analysis_lab.instructors i
LEFT JOIN analysis_lab.courses c
    ON c.instructor_id = i.id
LEFT JOIN analysis_lab.enrollments e
    ON e.course_id = c.id
GROUP BY i.id, i.name
ORDER BY enrollment_count DESC, i.id;

-- 5. 지역별 학생 수와 신청 건수
SELECT
    s.region,
    COUNT(DISTINCT s.id) AS student_count,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.paid_amount), 0) AS paid_amount_sum,
    ROUND(
        COUNT(e.id)::numeric / NULLIF(COUNT(DISTINCT s.id), 0),
        2
    ) AS enrollments_per_student
FROM analysis_lab.students s
LEFT JOIN analysis_lab.enrollments e
    ON e.student_id = s.id
GROUP BY s.region
ORDER BY enrollment_count DESC, s.region;

-- 기대:
-- 서울 학생 3 / 신청 9 / 910000
-- 경기 학생 2 / 신청 6 / 830000
-- 부산 학생 2 / 신청 6 / 770000
-- 대구 학생 1 / 신청 3 / 260000

-- 6. 학생별 신청 수
SELECT
    s.id AS student_id,
    s.name,
    s.region,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.paid_amount), 0) AS paid_amount_sum
FROM analysis_lab.students s
LEFT JOIN analysis_lab.enrollments e
    ON e.student_id = s.id
GROUP BY s.id, s.name, s.region
ORDER BY enrollment_count DESC, s.id;

-- 7. 신청이 없는 학생
SELECT
    s.id,
    s.name,
    s.region
FROM analysis_lab.students s
LEFT JOIN analysis_lab.enrollments e
    ON e.student_id = s.id
WHERE e.id IS NULL
ORDER BY s.id;

-- 기준 데이터에서는 기대 0행입니다.
