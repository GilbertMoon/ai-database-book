-- Chapter 08. 집계 쿼리
-- 실행 전 Chapter 07 최종 데이터와 00_check_course_project.sql을 확인합니다.
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();

-- ============================================================
-- 1. 기본 집계 기준값
-- 기대 결과: 5 / 590000 / 118000 / 100000 / 150000
-- ============================================================
SELECT
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS total_paid_amount,
    AVG(paid_amount) AS avg_paid_amount,
    MIN(paid_amount) AS min_paid_amount,
    MAX(paid_amount) AS max_paid_amount
FROM course_project.enrollments;

-- ============================================================
-- 2. 취소 제외 기준값
-- 기대 결과: 4 / 440000 / 110000
-- ============================================================
SELECT
    COUNT(*) AS non_cancelled_count,
    SUM(paid_amount) AS non_cancelled_paid_amount,
    AVG(paid_amount) AS non_cancelled_avg_amount
FROM course_project.enrollments
WHERE status <> '취소';

-- ============================================================
-- 3. 상태별 GROUP BY
-- 기대 건수: 신청 2 / 수강중 1 / 완료 1 / 취소 1
-- ============================================================
SELECT
    status,
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS total_paid_amount
FROM course_project.enrollments
GROUP BY status
ORDER BY status;

-- ============================================================
-- 4. PostgreSQL FILTER 조건부 집계
-- 기대 결과: 5 / 2 / 1 / 1 / 1 / 440000
-- ============================================================
SELECT
    COUNT(*) AS total_count,
    COUNT(*) FILTER (WHERE status = '신청') AS requested_count,
    COUNT(*) FILTER (WHERE status = '수강중') AS active_count,
    COUNT(*) FILTER (WHERE status = '완료') AS completed_count,
    COUNT(*) FILTER (WHERE status = '취소') AS cancelled_count,
    SUM(paid_amount) FILTER (WHERE status <> '취소')
        AS non_cancelled_paid_amount
FROM course_project.enrollments;

-- ============================================================
-- 5. 강의별 COUNT 대상 비교
-- 강의 303: COUNT(*)=1, COUNT(e.id)=0, student_count=0
-- ============================================================
SELECT
    c.id AS course_id,
    c.title AS course_title,
    COUNT(*) AS joined_row_count,
    COUNT(e.id) AS enrollment_count,
    COUNT(DISTINCT e.student_id) AS student_count
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
GROUP BY c.id, c.title
ORDER BY c.id;

-- ============================================================
-- 6. 강의별 취소 제외 신청·학생·금액
-- 기대 결과:
-- 301 = 2 / 2 / 200000
-- 302 = 2 / 2 / 240000
-- 303 = 0 / 0 / 0
-- ============================================================
SELECT
    c.id AS course_id,
    c.title AS course_title,
    COUNT(e.id) AS non_cancelled_count,
    COUNT(DISTINCT e.student_id) AS student_count,
    COALESCE(SUM(e.paid_amount), 0) AS non_cancelled_paid_amount
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
GROUP BY c.id, c.title
ORDER BY c.id;

-- ============================================================
-- 7. HAVING: 취소 제외 신청 2건 이상 강의
-- 기대 결과: 강의 301, 302
-- ============================================================
SELECT
    c.id,
    c.title,
    COUNT(e.id) AS enrollment_count
FROM course_project.courses AS c
JOIN course_project.enrollments AS e
    ON c.id = e.course_id
WHERE e.status <> '취소'
GROUP BY c.id, c.title
HAVING COUNT(e.id) >= 2
ORDER BY c.id;

-- ============================================================
-- 8. 강사별 강의 수·신청 수
-- course_count는 JOIN 반복을 피하기 위해 DISTINCT 사용
-- ============================================================
SELECT
    i.id AS instructor_id,
    i.name AS instructor_name,
    COUNT(DISTINCT c.id) AS course_count,
    COUNT(e.id) AS enrollment_count,
    COUNT(e.id) FILTER (WHERE e.status <> '취소')
        AS non_cancelled_count
FROM course_project.instructors AS i
LEFT JOIN course_project.courses AS c
    ON i.id = c.instructor_id
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
GROUP BY i.id, i.name
ORDER BY i.id;

-- 기대 결과:
-- 201 문길래 = 강의 2 / 전체 신청 4 / 취소 제외 4
-- 202 홍길동 = 강의 1 / 전체 신청 1 / 취소 제외 0

-- ============================================================
-- 9. 학생별 전체 신청·취소 제외 신청
-- ============================================================
SELECT
    s.id,
    s.name,
    COUNT(e.id) AS total_enrollment_count,
    COUNT(e.id) FILTER (WHERE e.status <> '취소')
        AS non_cancelled_count
FROM course_project.students AS s
LEFT JOIN course_project.enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name
ORDER BY s.id;
