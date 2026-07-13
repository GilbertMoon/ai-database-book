-- Chapter 15. 답변 등록과 질문 상태 변경 트랜잭션 검증
-- 실행 전 01→04 파일을 실행합니다.
-- 모든 변경은 ROLLBACK하여 기준 데이터를 유지합니다.

SELECT current_database();

-- 실행 전 기준
SELECT
    (SELECT COUNT(*) FROM tutor_project.answers) AS answers_before_expected_5,
    (SELECT status FROM tutor_project.questions WHERE id = 303)
        AS question_303_status_before_expected_open;

BEGIN;

INSERT INTO tutor_project.answers (
    id,
    question_id,
    tutor_id,
    answer_body,
    created_at
)
VALUES (
    9901,
    303,
    201,
    '트랜잭션 테스트 답변입니다.',
    TIMESTAMPTZ '2026-07-13 15:00:00+09'
);

UPDATE tutor_project.questions
SET
    status = 'answered',
    updated_at = TIMESTAMPTZ '2026-07-13 15:00:00+09'
WHERE id = 303;

-- 트랜잭션 내부 기대: answers 6 / status answered
SELECT
    (SELECT COUNT(*) FROM tutor_project.answers)
        AS answers_inside_expected_6,
    (SELECT status FROM tutor_project.questions WHERE id = 303)
        AS question_303_status_inside_expected_answered;

ROLLBACK;

-- ROLLBACK 후 기대: answers 5 / status open / 테스트 답변 0
SELECT
    (SELECT COUNT(*) FROM tutor_project.answers)
        AS answers_after_expected_5,
    (SELECT status FROM tutor_project.questions WHERE id = 303)
        AS question_303_status_after_expected_open,
    (SELECT COUNT(*) FROM tutor_project.answers WHERE id = 9901)
        AS rolled_back_answer_expected_0;

-- 최종 boolean
SELECT
    (SELECT COUNT(*) FROM tutor_project.answers) = 5
        AS answer_count_restored,
    (SELECT status FROM tutor_project.questions WHERE id = 303) = 'open'
        AS question_status_restored,
    NOT EXISTS (
        SELECT 1
        FROM tutor_project.answers
        WHERE id = 9901
    ) AS temporary_answer_absent;

-- 모든 결과가 true여야 합니다.
