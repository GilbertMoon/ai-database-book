-- Chapter 15. 질문 단위 분석 데이터셋
-- 실행 전 01→08 파일을 순서대로 실행합니다.
-- 한 행은 질문 1건이며 원본 테이블을 변경하지 않습니다.

SELECT current_database();

CREATE OR REPLACE VIEW tutor_project.question_analysis_dataset AS
WITH answer_summary AS (
    SELECT
        question_id,
        COUNT(*) AS answer_count,
        MIN(created_at) AS first_answer_at
    FROM tutor_project.answers
    GROUP BY question_id
),
material_summary AS (
    SELECT
        question_id,
        COUNT(*) AS material_count
    FROM tutor_project.question_materials
    GROUP BY question_id
)
SELECT
    q.id AS question_id,
    q.question_code,
    q.created_at AS question_created_at,
    DATE_TRUNC('month', q.created_at)::date AS question_month,
    s.id AS student_id,
    s.name AS student_name,
    q.status,
    COALESCE(a.answer_count, 0) AS answer_count,
    a.first_answer_at,
    CASE
        WHEN a.first_answer_at IS NULL THEN NULL
        ELSE ROUND(
            EXTRACT(EPOCH FROM (a.first_answer_at - q.created_at)) / 3600.0,
            2
        )
    END AS first_response_hours,
    COALESCE(m.material_count, 0) AS material_count,
    COALESCE(a.answer_count, 0) > 0 AS has_answer,
    COALESCE(m.material_count, 0) > 0 AS has_material
FROM tutor_project.questions AS q
JOIN tutor_project.students AS s
    ON s.id = q.student_id
LEFT JOIN answer_summary AS a
    ON a.question_id = q.id
LEFT JOIN material_summary AS m
    ON m.question_id = q.id;

-- 분석 데이터셋 기본 확인
SELECT *
FROM tutor_project.question_analysis_dataset
ORDER BY question_id;

-- 기대: 5행, question_id 중복 0, 답변 합계 5, 자료 연결 합계 7
SELECT
    COUNT(*) AS dataset_rows_expected_5,
    COUNT(DISTINCT question_id) AS distinct_questions_expected_5,
    SUM(answer_count) AS answer_count_sum_expected_5,
    SUM(material_count) AS material_count_sum_expected_7,
    COUNT(*) FILTER (WHERE has_answer = FALSE) AS no_answer_questions_expected_1
FROM tutor_project.question_analysis_dataset;

-- question_id 중복 검증: 기대 0행
SELECT
    question_id,
    COUNT(*) AS duplicate_count
FROM tutor_project.question_analysis_dataset
GROUP BY question_id
HAVING COUNT(*) > 1;

-- 상태별 SQL 기준값: answered 3, open 1, closed 1
SELECT
    status,
    COUNT(*) AS question_count
FROM tutor_project.question_analysis_dataset
GROUP BY status
ORDER BY status;

-- 학생별 질문 수
SELECT
    student_id,
    student_name,
    COUNT(*) AS question_count
FROM tutor_project.question_analysis_dataset
GROUP BY student_id, student_name
ORDER BY student_id;

-- 월별 질문 수: 기준 데이터는 2026-07 5건
SELECT
    question_month,
    COUNT(*) AS question_count,
    SUM(answer_count) AS answer_count,
    SUM(material_count) AS material_count
FROM tutor_project.question_analysis_dataset
GROUP BY question_month
ORDER BY question_month;

-- 첫 답변 시간 요약: 답변이 있는 질문만 계산
SELECT
    COUNT(*) FILTER (WHERE has_answer) AS answered_questions_expected_4,
    ROUND(AVG(first_response_hours) FILTER (WHERE has_answer), 2)
        AS avg_first_response_hours_expected_2
FROM tutor_project.question_analysis_dataset;
