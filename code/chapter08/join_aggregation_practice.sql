-- Chapter 08. JOIN과 집계로 서비스 질문에 답하기
--
-- 이 파일은 기존 링크 호환용 읽기 전용 진입점입니다.
-- 테이블을 삭제하거나 생성하지 않으며 데이터를 변경하지 않습니다.
-- 실제 학습은 다음 파일을 순서대로 실행합니다.
--
-- 1. 00_check_course_project.sql
-- 2. 01_join_queries.sql
-- 3. 02_aggregation_queries.sql
-- 4. 03_join_aggregation_validation.sql
--
-- Chapter 07의 course_project 최종 데이터가 먼저 준비되어 있어야 합니다.
-- 이 파일은 프로젝트 생성 파일이 아니며 기준 상태가 다르면 결과도 달라집니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 1. 기준 데이터 확인
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

-- 2. 신청 한 건 기준 다중 JOIN
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount
FROM course_project.enrollments AS e
JOIN course_project.students AS s
    ON e.student_id = s.id
JOIN course_project.courses AS c
    ON e.course_id = c.id
JOIN course_project.instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;

-- 3. 모든 강의를 유지한 취소 제외 집계
SELECT
    c.id,
    c.title,
    COUNT(e.id) AS non_cancelled_count,
    COUNT(DISTINCT e.student_id) AS student_count,
    COALESCE(SUM(e.paid_amount), 0)
        AS non_cancelled_recorded_amount
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
GROUP BY c.id, c.title
ORDER BY c.id;

-- 4. 상태별 집계: 업무 순서를 명시
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
