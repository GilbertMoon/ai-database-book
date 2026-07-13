-- Chapter 15. 자동 반례 테스트
-- 실행 전 01→05 파일을 실행합니다.
-- 각 반례는 독립 하위 트랜잭션에서 실행되어 기준 데이터를 유지합니다.

SELECT current_database();

DROP TABLE IF EXISTS pg_temp.project_negative_results;

CREATE TEMP TABLE project_negative_results (
    test_order INTEGER PRIMARY KEY,
    test_name TEXT NOT NULL,
    expected_result TEXT NOT NULL,
    actual_result TEXT NOT NULL,
    sqlstate TEXT,
    detail TEXT
);

-- 1. 중복 학생 이메일
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.students (id, name, email, joined_at)
        VALUES (9101, '중복학생', 'student.a@example.test', CURRENT_DATE);
        DELETE FROM tutor_project.students WHERE id = 9101;
        INSERT INTO pg_temp.project_negative_results VALUES
        (1, 'duplicate_student_email', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN unique_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (1, 'duplicate_student_email', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (1, 'duplicate_student_email', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 2. 중복 튜터 이메일
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.tutors (id, name, email, specialty)
        VALUES (9201, '중복튜터', 'tutor.sql@example.test', 'SQL');
        DELETE FROM tutor_project.tutors WHERE id = 9201;
        INSERT INTO pg_temp.project_negative_results VALUES
        (2, 'duplicate_tutor_email', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN unique_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (2, 'duplicate_tutor_email', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (2, 'duplicate_tutor_email', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 3. 없는 학생 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.questions
            (id, student_id, question_code, title, body, status)
        VALUES (9301, 999999, 'NEG-Q-01', '없는 학생', 'FK 오류', 'open');
        DELETE FROM tutor_project.questions WHERE id = 9301;
        INSERT INTO pg_temp.project_negative_results VALUES
        (3, 'missing_student_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN foreign_key_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (3, 'missing_student_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (3, 'missing_student_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 4. 잘못된 질문 상태
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.questions
            (id, student_id, question_code, title, body, status)
        VALUES (9302, 101, 'NEG-Q-02', '잘못된 상태', 'CHECK 오류', 'waiting');
        DELETE FROM tutor_project.questions WHERE id = 9302;
        INSERT INTO pg_temp.project_negative_results VALUES
        (4, 'invalid_question_status', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN check_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (4, 'invalid_question_status', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (4, 'invalid_question_status', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 5. 빈 질문 제목
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.questions
            (id, student_id, question_code, title, body, status)
        VALUES (9303, 101, 'NEG-Q-03', '   ', '빈 제목 오류', 'open');
        DELETE FROM tutor_project.questions WHERE id = 9303;
        INSERT INTO pg_temp.project_negative_results VALUES
        (5, 'blank_question_title', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN check_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (5, 'blank_question_title', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (5, 'blank_question_title', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 6. 없는 질문 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.answers
            (id, question_id, tutor_id, answer_body)
        VALUES (9401, 999999, 201, '없는 질문 답변');
        DELETE FROM tutor_project.answers WHERE id = 9401;
        INSERT INTO pg_temp.project_negative_results VALUES
        (6, 'missing_question_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN foreign_key_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (6, 'missing_question_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (6, 'missing_question_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 7. 없는 튜터 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.answers
            (id, question_id, tutor_id, answer_body)
        VALUES (9402, 303, 999999, '없는 튜터 답변');
        DELETE FROM tutor_project.answers WHERE id = 9402;
        INSERT INTO pg_temp.project_negative_results VALUES
        (7, 'missing_tutor_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN foreign_key_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (7, 'missing_tutor_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (7, 'missing_tutor_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 8. 빈 답변
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.answers
            (id, question_id, tutor_id, answer_body)
        VALUES (9403, 303, 201, '   ');
        DELETE FROM tutor_project.answers WHERE id = 9403;
        INSERT INTO pg_temp.project_negative_results VALUES
        (8, 'blank_answer_body', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN check_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (8, 'blank_answer_body', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (8, 'blank_answer_body', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 9. 잘못된 자료 유형
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.learning_materials
            (id, material_code, title, material_type, content_summary,
             access_scope, source_version, content_hash, updated_at)
        VALUES
            (9501, 'NEG-M-01', '잘못된 자료', 'audio', '유형 오류',
             'public', 'v1', 'neg-hash-01', CURRENT_TIMESTAMP);
        DELETE FROM tutor_project.learning_materials WHERE id = 9501;
        INSERT INTO pg_temp.project_negative_results VALUES
        (9, 'invalid_material_type', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN check_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (9, 'invalid_material_type', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (9, 'invalid_material_type', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 10. 잘못된 접근 범위
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.learning_materials
            (id, material_code, title, material_type, content_summary,
             access_scope, source_version, content_hash, updated_at)
        VALUES
            (9502, 'NEG-M-02', '잘못된 범위', 'document', '범위 오류',
             'secret', 'v1', 'neg-hash-02', CURRENT_TIMESTAMP);
        DELETE FROM tutor_project.learning_materials WHERE id = 9502;
        INSERT INTO pg_temp.project_negative_results VALUES
        (10, 'invalid_access_scope', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN check_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (10, 'invalid_access_scope', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (10, 'invalid_access_scope', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 11. 없는 자료 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.question_materials
            (question_id, material_id, display_order, note)
        VALUES (303, 999999, 2, '없는 자료');
        DELETE FROM tutor_project.question_materials
        WHERE question_id = 303 AND material_id = 999999;
        INSERT INTO pg_temp.project_negative_results VALUES
        (11, 'missing_material_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN foreign_key_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (11, 'missing_material_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (11, 'missing_material_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 12. 표시 순서 0
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.question_materials
            (question_id, material_id, display_order, note)
        VALUES (303, 505, 0, '잘못된 순서');
        DELETE FROM tutor_project.question_materials
        WHERE question_id = 303 AND material_id = 505;
        INSERT INTO pg_temp.project_negative_results VALUES
        (12, 'invalid_display_order', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN check_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (12, 'invalid_display_order', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (12, 'invalid_display_order', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 13. 중복 질문·자료 연결
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.question_materials
            (question_id, material_id, display_order, note)
        VALUES (301, 501, 3, '중복 연결');
        DELETE FROM tutor_project.question_materials
        WHERE question_id = 301 AND material_id = 501 AND display_order = 3;
        INSERT INTO pg_temp.project_negative_results VALUES
        (13, 'duplicate_question_material', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN unique_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (13, 'duplicate_question_material', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (13, 'duplicate_question_material', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 14. 한 질문 안에서 표시 순서 중복
DO $$
BEGIN
    BEGIN
        INSERT INTO tutor_project.question_materials
            (question_id, material_id, display_order, note)
        VALUES (301, 503, 1, '중복 표시 순서');
        DELETE FROM tutor_project.question_materials
        WHERE question_id = 301 AND material_id = 503;
        INSERT INTO pg_temp.project_negative_results VALUES
        (14, 'duplicate_display_order', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION WHEN unique_violation THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (14, 'duplicate_display_order', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
    WHEN OTHERS THEN
        INSERT INTO pg_temp.project_negative_results VALUES
        (14, 'duplicate_display_order', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

SELECT
    test_order,
    test_name,
    expected_result,
    actual_result,
    sqlstate,
    detail
FROM pg_temp.project_negative_results
ORDER BY test_order;

SELECT
    COUNT(*) AS total_tests_expected_14,
    COUNT(*) FILTER (
        WHERE actual_result = 'expected_failure'
    ) AS passed_tests_expected_14,
    COUNT(*) FILTER (
        WHERE actual_result LIKE 'unexpected%'
    ) AS unexpected_tests_expected_0
FROM pg_temp.project_negative_results;

-- 기준 데이터 유지
SELECT
    (SELECT COUNT(*) FROM tutor_project.students) AS students_expected_4,
    (SELECT COUNT(*) FROM tutor_project.tutors) AS tutors_expected_3,
    (SELECT COUNT(*) FROM tutor_project.questions) AS questions_expected_5,
    (SELECT COUNT(*) FROM tutor_project.answers) AS answers_expected_5,
    (SELECT COUNT(*) FROM tutor_project.learning_materials) AS materials_expected_6,
    (SELECT COUNT(*) FROM tutor_project.question_materials) AS links_expected_7;
