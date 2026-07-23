-- Chapter 08. 집계 쿼리
-- 실행 전 Chapter 07 최종 데이터와 00_check_course_project.sql을 확인합니다.
-- 이 파일은 데이터를 변경하지 않습니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 용어
-- 전체 신청 이력: 모든 enrollments 행
-- 활성 신청: status IN ('신청', '수강중')
-- 취소 제외 신청 이력: status <> '취소'
-- paid_amount: 신청 당시 기록 금액이며 실제 회계 매출이 아닙니다.

-- ============================================================
-- 1. 기본 집계 기준값
-- 기대 결과: 5 / 590000 / 118000.00 / 100000 / 150000
-- AVG(INTEGER)는 PostgreSQL에서 numeric을 반환하므로 ROUND로 표시를 고정합니다.
-- ============================================================
SELECT
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS total_recorded_amount,
    ROUND(AVG(paid_amount), 2) AS avg_recorded_amount,
    MIN(paid_amount) AS min_recorded_amount,
    MAX(paid_amount) AS max_recorded_amount
FROM course_project.enrollments;

-- ============================================================
-- 2. 활성 신청 기준값
-- 신청 2건 + 수강중 1건 = 3건 / 기록 금액 340000
-- ============================================================
SELECT
    COUNT(*) AS active_enrollment_count,
    SUM(paid_amount) AS active_recorded_amount,
    ROUND(AVG(paid_amount), 2) AS active_avg_recorded_amount
FROM course_project.enrollments
WHERE status IN ('신청', '수강중');

-- ============================================================
-- 3. 취소 제외 신청 이력 기준값
-- 신청·수강중·완료 = 4건 / 440000 / 110000.00
-- ============================================================
SELECT
    COUNT(*) AS non_cancelled_count,
    SUM(paid_amount) AS non_cancelled_recorded_amount,
    ROUND(AVG(paid_amount), 2) AS non_cancelled_avg_recorded_amount
FROM course_project.enrollments
WHERE status <> '취소';

-- ============================================================
-- 4. 상태별 GROUP BY
-- 업무 순서: 신청 → 수강중 → 완료 → 취소
-- 문자열 정렬에 의존하지 않고 CASE로 순서를 명시합니다.
-- ============================================================
SELECT
    status,
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS total_recorded_amount
FROM course_project.enrollments
GROUP BY status
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END;

-- 기대 결과:
-- 신청 2 / 240000
-- 수강중 1 / 100000
-- 완료 1 / 100000
-- 취소 1 / 150000

-- ============================================================
-- 5. PostgreSQL FILTER 조건부 집계
-- requested_count는 신청, learning_count는 수강중만 셉니다.
-- active_enrollment_count는 Chapter 07과 동일하게 신청+수강중입니다.
-- 기대 결과: 5 / 2 / 1 / 3 / 1 / 1 / 340000 / 440000
-- ============================================================
SELECT
    COUNT(*) AS total_count,
    COUNT(*) FILTER (
        WHERE status = '신청'
    ) AS requested_count,
    COUNT(*) FILTER (
        WHERE status = '수강중'
    ) AS learning_count,
    COUNT(*) FILTER (
        WHERE status IN ('신청', '수강중')
    ) AS active_enrollment_count,
    COUNT(*) FILTER (
        WHERE status = '완료'
    ) AS completed_count,
    COUNT(*) FILTER (
        WHERE status = '취소'
    ) AS cancelled_count,
    SUM(paid_amount) FILTER (
        WHERE status IN ('신청', '수강중')
    ) AS active_recorded_amount,
    SUM(paid_amount) FILTER (
        WHERE status <> '취소'
    ) AS non_cancelled_recorded_amount
FROM course_project.enrollments;

-- ============================================================
-- 6. 강의별 COUNT 대상 비교
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
-- 7. 강의별 취소 제외 신청·학생·기록 금액
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
    COALESCE(SUM(e.paid_amount), 0) AS non_cancelled_recorded_amount
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
GROUP BY c.id, c.title
ORDER BY c.id;

-- COUNT(column)은 NULL을 제외하고 0을 반환할 수 있습니다.
-- SUM·AVG·MIN·MAX는 입력값이 없으면 NULL을 반환할 수 있습니다.
-- COALESCE(..., 0)는 업무적으로 데이터 없음과 0을 같게 표시해도 될 때만 사용합니다.

-- ============================================================
-- 8. HAVING: 취소 제외 신청 2건 이상 강의
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
-- 9. 강사별 강의 수·신청 수
-- course_count는 JOIN 반복을 피하기 위해 DISTINCT 사용
-- ============================================================
SELECT
    i.id AS instructor_id,
    i.name AS instructor_name,
    COUNT(DISTINCT c.id) AS course_count,
    COUNT(e.id) AS enrollment_count,
    COUNT(e.id) FILTER (
        WHERE e.status <> '취소'
    ) AS non_cancelled_count
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
-- 10. 여러 JOIN에서 강의 가격을 잘못 합산하는 예
-- 아래 쿼리는 실행 가능하지만 강의가 신청 수만큼 반복되어 가격이 과대 합산됩니다.
-- ============================================================
SELECT
    i.id AS instructor_id,
    i.name AS instructor_name,
    SUM(c.price) AS wrong_course_price_sum
FROM course_project.instructors AS i
JOIN course_project.courses AS c
    ON i.id = c.instructor_id
JOIN course_project.enrollments AS e
    ON c.id = e.course_id
GROUP BY i.id, i.name
ORDER BY i.id;

-- SUM(DISTINCT c.price)도 정답이 아닐 수 있습니다.
-- 서로 다른 강의가 같은 가격이면 한 번만 합산되기 때문입니다.
-- 강의 가격 합계가 질문이라면 신청 테이블을 JOIN하지 않고 강의 수준에서 계산합니다.
SELECT
    i.id AS instructor_id,
    i.name AS instructor_name,
    COALESCE(SUM(c.price), 0) AS course_price_sum
FROM course_project.instructors AS i
LEFT JOIN course_project.courses AS c
    ON i.id = c.instructor_id
GROUP BY i.id, i.name
ORDER BY i.id;

-- ============================================================
-- 11. 학생별 전체 신청·취소 제외 신청
-- ============================================================
SELECT
    s.id,
    s.name,
    COUNT(e.id) AS total_enrollment_count,
    COUNT(e.id) FILTER (
        WHERE e.status <> '취소'
    ) AS non_cancelled_count
FROM course_project.students AS s
LEFT JOIN course_project.enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name
ORDER BY s.id;
