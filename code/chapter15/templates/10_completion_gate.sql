-- Chapter 15. 최종 완료 게이트
-- 실행 전 01→08 파일을 순서대로 실행합니다.
-- 선택 RAG 확장 여부와 무관하게 필수 프로젝트 상태를 읽기 전용으로 판정합니다.

SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name;

WITH row_counts AS (
    SELECT
        (SELECT COUNT(*) FROM tutor_project.students) AS students_count,
        (SELECT COUNT(*) FROM tutor_project.tutors) AS tutors_count,
        (SELECT COUNT(*) FROM tutor_project.questions) AS questions_count,
        (SELECT COUNT(*) FROM tutor_project.answers) AS answers_count,
        (SELECT COUNT(*) FROM tutor_project.learning_materials) AS materials_count,
        (SELECT COUNT(*) FROM tutor_project.question_materials) AS links_count
),
metadata_counts AS (
    SELECT
        (
            SELECT COUNT(*)
            FROM information_schema.tables
            WHERE table_schema = 'tutor_project'
              AND table_type = 'BASE TABLE'
        ) AS table_count,
        (
            SELECT COUNT(*)
            FROM information_schema.table_constraints
            WHERE constraint_schema = 'tutor_project'
              AND constraint_type = 'FOREIGN KEY'
        ) AS foreign_key_count,
        (
            SELECT COUNT(*)
            FROM information_schema.columns
            WHERE table_schema = 'tutor_project'
              AND column_name = 'id'
              AND is_identity = 'YES'
        ) AS identity_pk_count,
        (
            SELECT COUNT(*)
            FROM pg_constraint
            WHERE connamespace = 'tutor_project'::regnamespace
              AND contype = 'f'
              AND pg_get_constraintdef(oid) ILIKE '%ON DELETE CASCADE%'
        ) AS cascade_fk_count,
        (
            SELECT COUNT(*)
            FROM pg_indexes
            WHERE schemaname = 'tutor_project'
              AND indexname IN (
                  'idx_tutor_project_questions_student_status_created',
                  'idx_tutor_project_answers_question_created',
                  'idx_tutor_project_qm_material'
              )
        ) AS business_index_count
),
boundary_counts AS (
    SELECT
        (
            SELECT COUNT(*)
            FROM (
                SELECT s.id
                FROM tutor_project.students AS s
                LEFT JOIN tutor_project.questions AS q
                    ON q.student_id = s.id
                GROUP BY s.id
                HAVING COUNT(q.id) = 0
            ) AS no_question_students
        ) AS students_without_questions,
        (
            SELECT COUNT(*)
            FROM (
                SELECT m.id
                FROM tutor_project.learning_materials AS m
                LEFT JOIN tutor_project.question_materials AS qm
                    ON qm.material_id = m.id
                GROUP BY m.id
                HAVING COUNT(qm.question_id) = 0
            ) AS unlinked_materials
        ) AS unlinked_materials,
        (
            SELECT COUNT(*)
            FROM (
                SELECT q.id
                FROM tutor_project.questions AS q
                LEFT JOIN tutor_project.answers AS a
                    ON a.question_id = q.id
                WHERE q.status = 'open'
                GROUP BY q.id
                HAVING COUNT(a.id) = 0
            ) AS unanswered_open_questions
        ) AS unanswered_open_questions,
        (
            SELECT COUNT(*)
            FROM (
                SELECT q.id
                FROM tutor_project.questions AS q
                JOIN tutor_project.answers AS a
                    ON a.question_id = q.id
                GROUP BY q.id
                HAVING COUNT(*) = 2
            ) AS two_answer_questions
        ) AS two_answer_questions
),
anomaly_counts AS (
    SELECT
        (
            SELECT COUNT(*)
            FROM tutor_project.questions AS q
            LEFT JOIN tutor_project.students AS s
                ON s.id = q.student_id
            WHERE s.id IS NULL
        ) AS orphan_questions,
        (
            SELECT COUNT(*)
            FROM tutor_project.answers AS a
            LEFT JOIN tutor_project.questions AS q
                ON q.id = a.question_id
            LEFT JOIN tutor_project.tutors AS t
                ON t.id = a.tutor_id
            WHERE q.id IS NULL OR t.id IS NULL
        ) AS orphan_answers,
        (
            SELECT COUNT(*)
            FROM tutor_project.question_materials AS qm
            LEFT JOIN tutor_project.questions AS q
                ON q.id = qm.question_id
            LEFT JOIN tutor_project.learning_materials AS m
                ON m.id = qm.material_id
            WHERE q.id IS NULL OR m.id IS NULL
        ) AS orphan_material_links,
        (
            SELECT COUNT(*)
            FROM (
                SELECT q.id
                FROM tutor_project.questions AS q
                LEFT JOIN tutor_project.answers AS a
                    ON a.question_id = q.id
                WHERE q.status = 'answered'
                GROUP BY q.id
                HAVING COUNT(a.id) = 0
            ) AS answered_without_answer
        ) AS answered_without_answer,
        (
            SELECT COUNT(*)
            FROM (
                SELECT question_id, display_order
                FROM tutor_project.question_materials
                GROUP BY question_id, display_order
                HAVING COUNT(*) > 1
            ) AS duplicate_orders
        ) AS duplicate_orders
),
security_counts AS (
    SELECT
        (
            SELECT COUNT(*)
            FROM information_schema.columns
            WHERE table_schema = 'tutor_project'
              AND lower(column_name)
                  SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
        ) AS sensitive_column_count,
        (
            SELECT COUNT(*)
            FROM tutor_project.students
            WHERE email NOT LIKE '%@example.test'
        ) + (
            SELECT COUNT(*)
            FROM tutor_project.tutors
            WHERE email NOT LIKE '%@example.test'
        ) AS non_test_email_count
)
SELECT
    r.students_count,
    r.tutors_count,
    r.questions_count,
    r.answers_count,
    r.materials_count,
    r.links_count,
    m.table_count,
    m.foreign_key_count,
    m.identity_pk_count,
    m.cascade_fk_count,
    m.business_index_count,
    b.students_without_questions,
    b.unlinked_materials,
    b.unanswered_open_questions,
    b.two_answer_questions,
    a.orphan_questions,
    a.orphan_answers,
    a.orphan_material_links,
    a.answered_without_answer,
    a.duplicate_orders,
    s.sensitive_column_count,
    s.non_test_email_count,
    r.students_count = 4
        AND r.tutors_count = 3
        AND r.questions_count = 5
        AND r.answers_count = 5
        AND r.materials_count = 6
        AND r.links_count = 7
        AND m.table_count = 6
        AND m.foreign_key_count = 5
        AND m.identity_pk_count = 5
        AND m.cascade_fk_count = 0
        AND m.business_index_count = 3
        AND b.students_without_questions = 1
        AND b.unlinked_materials = 1
        AND b.unanswered_open_questions = 1
        AND b.two_answer_questions = 1
        AND a.orphan_questions = 0
        AND a.orphan_answers = 0
        AND a.orphan_material_links = 0
        AND a.answered_without_answer = 0
        AND a.duplicate_orders = 0
        AND s.sensitive_column_count = 0
        AND s.non_test_email_count = 0
        AS required_completion_gate_passed
FROM row_counts AS r
CROSS JOIN metadata_counts AS m
CROSS JOIN boundary_counts AS b
CROSS JOIN anomaly_counts AS a
CROSS JOIN security_counts AS s;

-- required_completion_gate_passed가 true여야 합니다.
-- 이 결과는 실제 백업·복원 시험, Role 권한 시험, API·RAG·배포 완료를 의미하지 않습니다.
-- 미실행 항목은 OPERATIONS_RUNBOOK.md와 final_report.md에 별도로 기록합니다.
