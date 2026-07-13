-- Chapter 15. 최종 완료 게이트
-- 실행 전 01→08 파일을 순서대로 실행합니다.
-- 선택 RAG 확장 여부와 무관하게 필수 프로젝트 상태를 읽기 전용으로 판정합니다.

SELECT
    current_user AS current_user_name,
    current_database() AS current_database_name,
    current_schema() AS current_schema_name;

-- 1. 기준 행 수
WITH row_counts AS (
    SELECT
        (SELECT COUNT(*) FROM tutor_project.students) AS students_count,
        (SELECT COUNT(*) FROM tutor_project.tutors) AS tutors_count,
        (SELECT COUNT(*) FROM tutor_project.questions) AS questions_count,
        (SELECT COUNT(*) FROM tutor_project.answers) AS answers_count,
        (SELECT COUNT(*) FROM tutor_project.learning_materials) AS materials_count,
        (SELECT COUNT(*) FROM tutor_project.question_materials) AS links_count
)
SELECT
    students_count,
    tutors_count,
    questions_count,
    answers_count,
    materials_count,
    links_count,
    students_count = 4 AS students_ok,
    tutors_count = 3 AS tutors_ok,
    questions_count = 5 AS questions_ok,
    answers_count = 5 AS answers_ok,
    materials_count = 6 AS materials_ok,
    links_count = 7 AS links_ok
FROM row_counts;

-- 2. 실제 구조 수치
WITH metadata_counts AS (
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
)
SELECT
    table_count,
    foreign_key_count,
    identity_pk_count,
    cascade_fk_count,
    business_index_count,
    table_count = 6 AS tables_ok,
    foreign_key_count = 5 AS foreign_keys_ok,
    identity_pk_count = 5 AS identity_pks_ok,
    cascade_fk_count = 0 AS no_cascade_ok,
    business_index_count = 3 AS business_indexes_ok
FROM metadata_counts;

-- 3. 경계 시나리오
WITH boundary_counts AS (
    SELECT
        (
            SELECT COUNT(*)
            FROM tutor_project.students AS s
            LEFT JOIN tutor_project.questions AS q
                ON q.student_id = s.id
            WHERE q.id IS NULL
        ) AS students_without_questions,
        (
            SELECT COUNT(*)
            FROM tutor_project.learning_materials AS m
            LEFT JOIN tutor_project.question_materials AS qm
                ON qm.material_id = m.id
            WHERE qm.material_id IS NULL
        ) AS unlinked_materials,
        (
            SELECT COUNT(*)
            FROM tutor_project.questions AS q
            LEFT JOIN tutor_project.answers AS a
                ON a.question_id = q.id
            WHERE q.status = 'open'
            GROUP BY q.id
            HAVING COUNT(a.id) = 0
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
)
SELECT
    students_without_questions,
    unlinked_materials,
    unanswered_open_questions,
    two_answer_questions,
    students_without_questions = 1 AS student_boundary_ok,
    unlinked_materials = 1 AS material_boundary_ok,
    unanswered_open_questions = 1 AS unanswered_boundary_ok,
    two_answer_questions = 1 AS multi_answer_boundary_ok
FROM boundary_counts;

-- 4. 업무 정합성 이상 수치
WITH anomaly_counts AS (
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
            FROM tutor_project.questions AS q
            LEFT JOIN tutor_project.answers AS a
                ON a.question_id = q.id
            WHERE q.status = 'answered'
            GROUP BY q.id
            HAVING COUNT(a.id) = 0
        ) AS answered_without_answer,
        (
            SELECT COUNT(*)
            FROM (
                SELECT question_id, display_order
                FROM tutor_project.question_materials
                GROUP BY question_id, display_order
                HAVING COUNT(*) > 1
            ) AS duplicate_orders
)
SELECT
    orphan_questions,
    orphan_answers,
    orphan_material_links,
    answered_without_answer,
    duplicate_orders,
    orphan_questions = 0
        AND orphan_answers = 0
        AND orphan_material_links = 0
        AND answered_without_answer = 0
        AND duplicate_orders = 0 AS business_consistency_ok
FROM anomaly_counts;

-- 5. 비밀·개인정보 형태 확인
WITH security_checks AS (
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
    sensitive_column_count,
    non_test_email_count,
    sensitive_column_count = 0 AS sensitive_columns_ok,
    non_test_email_count = 0 AS test_data_privacy_ok
FROM security_checks;

-- 6. 필수 완료 상태 단일 판정
WITH final_checks AS (
    SELECT
        (SELECT COUNT(*) FROM tutor_project.students) = 4 AS students_ok,
        (SELECT COUNT(*) FROM tutor_project.tutors) = 3 AS tutors_ok,
        (SELECT COUNT(*) FROM tutor_project.questions) = 5 AS questions_ok,
        (SELECT COUNT(*) FROM tutor_project.answers) = 5 AS answers_ok,
        (SELECT COUNT(*) FROM tutor_project.learning_materials) = 6 AS materials_ok,
        (SELECT COUNT(*) FROM tutor_project.question_materials) = 7 AS links_ok,
        (
            SELECT COUNT(*) = 5
            FROM information_schema.table_constraints
            WHERE constraint_schema = 'tutor_project'
              AND constraint_type = 'FOREIGN KEY'
        ) AS foreign_keys_ok,
        (
            SELECT COUNT(*) = 0
            FROM pg_constraint
            WHERE connamespace = 'tutor_project'::regnamespace
              AND contype = 'f'
              AND pg_get_constraintdef(oid) ILIKE '%ON DELETE CASCADE%'
        ) AS no_cascade_ok,
        (
            SELECT COUNT(*) = 3
            FROM pg_indexes
            WHERE schemaname = 'tutor_project'
              AND indexname IN (
                  'idx_tutor_project_questions_student_status_created',
                  'idx_tutor_project_answers_question_created',
                  'idx_tutor_project_qm_material'
              )
        ) AS indexes_ok,
        NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'tutor_project'
              AND lower(column_name)
                  SIMILAR TO '%(password|secret|token|card|resident|ssn)%'
        ) AS no_sensitive_columns_ok
)
SELECT
    *,
    students_ok
    AND tutors_ok
    AND questions_ok
    AND answers_ok
    AND materials_ok
    AND links_ok
    AND foreign_keys_ok
    AND no_cascade_ok
    AND indexes_ok
    AND no_sensitive_columns_ok AS required_completion_gate_passed
FROM final_checks;

-- required_completion_gate_passed가 true여야 합니다.
-- 이 결과는 실제 백업·복원 시험, Role 권한 시험, API·RAG·배포 완료를 의미하지 않습니다.
-- 미실행 항목은 OPERATIONS_RUNBOOK.md와 final_report.md에 별도로 기록합니다.
