-- Chapter 13. 안전한 반례·정상 경계값 테스트
-- 실행 전 01→06 파일을 순서대로 실행합니다.
-- 각 테스트는 PostgreSQL 예외 블록의 독립 하위 트랜잭션에서 실행됩니다.
-- 테스트 SQL은 성공하더라도 의도적으로 예외를 발생시켜 자동 취소합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '테스트 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('ai_review_lab.payments') IS NULL
       OR (SELECT COUNT(*) FROM ai_review_lab.students) <> 3
       OR (SELECT COUNT(*) FROM ai_review_lab.instructors) <> 2
       OR (SELECT COUNT(*) FROM ai_review_lab.courses) <> 3
       OR (SELECT COUNT(*) FROM ai_review_lab.enrollments) <> 4
       OR (SELECT COUNT(*) FROM ai_review_lab.payments) <> 4 THEN
        RAISE EXCEPTION
            '테스트 중단: 01→06 기준 상태가 준비되지 않았습니다.';
    END IF;
END
$$;

DROP TABLE IF EXISTS pg_temp.negative_test_results;

CREATE TEMP TABLE negative_test_results (
    test_order INTEGER PRIMARY KEY,
    test_id TEXT NOT NULL,
    test_name TEXT NOT NULL,
    expected_result TEXT NOT NULL,
    expected_sqlstate TEXT,
    actual_sqlstate TEXT,
    expected_constraint TEXT,
    actual_constraint TEXT,
    actual_table TEXT,
    actual_column TEXT,
    actual_result TEXT NOT NULL,
    detail TEXT
);

-- 예상 실패 테스트를 실행하고 SQLSTATE와 제약조건 이름을 구조적으로 기록합니다.
CREATE OR REPLACE PROCEDURE pg_temp.expect_failure(
    p_test_order INTEGER,
    p_test_id TEXT,
    p_test_name TEXT,
    p_sql TEXT,
    p_expected_sqlstate TEXT,
    p_expected_constraint TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate TEXT;
    v_message TEXT;
    v_constraint TEXT;
    v_table TEXT;
    v_column TEXT;
BEGIN
    BEGIN
        EXECUTE p_sql;

        -- 예상과 달리 성공했으면 이 하위 트랜잭션을 취소합니다.
        RAISE EXCEPTION USING
            ERRCODE = 'P0001',
            MESSAGE = '__UNEXPECTED_SUCCESS__';
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS
                v_sqlstate = RETURNED_SQLSTATE,
                v_message = MESSAGE_TEXT,
                v_constraint = CONSTRAINT_NAME,
                v_table = TABLE_NAME,
                v_column = COLUMN_NAME;

            IF v_sqlstate = 'P0001'
               AND v_message = '__UNEXPECTED_SUCCESS__' THEN
                INSERT INTO pg_temp.negative_test_results
                VALUES (
                    p_test_order,
                    p_test_id,
                    p_test_name,
                    'expected_failure',
                    p_expected_sqlstate,
                    NULL,
                    p_expected_constraint,
                    NULL,
                    NULL,
                    NULL,
                    'unexpected_success',
                    'SQL이 예상과 달리 성공했습니다.'
                );
            ELSIF v_sqlstate = p_expected_sqlstate
                  AND (
                      p_expected_constraint IS NULL
                      OR v_constraint = p_expected_constraint
                  ) THEN
                INSERT INTO pg_temp.negative_test_results
                VALUES (
                    p_test_order,
                    p_test_id,
                    p_test_name,
                    'expected_failure',
                    p_expected_sqlstate,
                    v_sqlstate,
                    p_expected_constraint,
                    v_constraint,
                    v_table,
                    v_column,
                    'expected_failure',
                    v_message
                );
            ELSE
                INSERT INTO pg_temp.negative_test_results
                VALUES (
                    p_test_order,
                    p_test_id,
                    p_test_name,
                    'expected_failure',
                    p_expected_sqlstate,
                    v_sqlstate,
                    p_expected_constraint,
                    v_constraint,
                    v_table,
                    v_column,
                    'unexpected_error',
                    v_message
                );
            END IF;
    END;
END
$$;

-- 정상 경계값 테스트도 마지막에 의도적으로 예외를 발생시켜 변경을 취소합니다.
CREATE OR REPLACE PROCEDURE pg_temp.expect_success(
    p_test_order INTEGER,
    p_test_id TEXT,
    p_test_name TEXT,
    p_sql TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlstate TEXT;
    v_message TEXT;
    v_constraint TEXT;
    v_table TEXT;
    v_column TEXT;
BEGIN
    BEGIN
        EXECUTE p_sql;

        RAISE EXCEPTION USING
            ERRCODE = 'P0001',
            MESSAGE = '__ROLLBACK_EXPECTED_SUCCESS__';
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS
                v_sqlstate = RETURNED_SQLSTATE,
                v_message = MESSAGE_TEXT,
                v_constraint = CONSTRAINT_NAME,
                v_table = TABLE_NAME,
                v_column = COLUMN_NAME;

            IF v_sqlstate = 'P0001'
               AND v_message = '__ROLLBACK_EXPECTED_SUCCESS__' THEN
                INSERT INTO pg_temp.negative_test_results
                VALUES (
                    p_test_order,
                    p_test_id,
                    p_test_name,
                    'expected_success',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    'expected_success',
                    '정상 경계값이 허용되었으며 변경은 자동 취소되었습니다.'
                );
            ELSE
                INSERT INTO pg_temp.negative_test_results
                VALUES (
                    p_test_order,
                    p_test_id,
                    p_test_name,
                    'expected_success',
                    NULL,
                    v_sqlstate,
                    NULL,
                    v_constraint,
                    v_table,
                    v_column,
                    'unexpected_error',
                    v_message
                );
            END IF;
    END;
END
$$;

-- ============================================================
-- P13-T01~P13-T22. 예상 실패 반례
-- ============================================================
CALL pg_temp.expect_failure(
    1, 'P13-T01', 'duplicate_student_email',
    $$INSERT INTO ai_review_lab.students (id, name, email, joined_at)
      VALUES (1901, '중복학생', 'kim.review@example.com', CURRENT_DATE)$$,
    '23505', 'uq_ai_review_students_email'
);

CALL pg_temp.expect_failure(
    2, 'P13-T02', 'blank_student_email',
    $$INSERT INTO ai_review_lab.students (id, name, email, joined_at)
      VALUES (1902, '공백학생', '   ', CURRENT_DATE)$$,
    '23514', 'chk_ai_review_students_email_not_blank'
);

CALL pg_temp.expect_failure(
    3, 'P13-T03', 'duplicate_instructor_email',
    $$INSERT INTO ai_review_lab.instructors (id, name, email, specialty)
      VALUES (2901, '중복강사', 'teacher-park.review@example.com', 'Database')$$,
    '23505', 'uq_ai_review_instructors_email'
);

CALL pg_temp.expect_failure(
    4, 'P13-T04', 'blank_instructor_specialty',
    $$INSERT INTO ai_review_lab.instructors (id, name, email, specialty)
      VALUES (2902, '강사', 'blank-specialty@example.com', ' ')$$,
    '23514', 'chk_ai_review_instructors_specialty_not_blank'
);

CALL pg_temp.expect_failure(
    5, 'P13-T05', 'missing_instructor_fk',
    $$INSERT INTO ai_review_lab.courses
      (id, instructor_id, course_code, title, level, price, opened_at)
      VALUES (3901, 999999, 'BAD-FK-I', '없는 강사', 'basic', 1000, CURRENT_DATE)$$,
    '23503', 'fk_ai_review_courses_instructor'
);

CALL pg_temp.expect_failure(
    6, 'P13-T06', 'invalid_course_level',
    $$INSERT INTO ai_review_lab.courses
      (id, instructor_id, course_code, title, level, price, opened_at)
      VALUES (3902, 201, 'BAD-LEVEL', '잘못된 레벨', 'expert', 1000, CURRENT_DATE)$$,
    '23514', 'chk_ai_review_courses_level'
);

CALL pg_temp.expect_failure(
    7, 'P13-T07', 'negative_course_price',
    $$INSERT INTO ai_review_lab.courses
      (id, instructor_id, course_code, title, level, price, opened_at)
      VALUES (3903, 201, 'BAD-PRICE', '음수 가격', 'basic', -1000, CURRENT_DATE)$$,
    '23514', 'chk_ai_review_courses_price'
);

CALL pg_temp.expect_failure(
    8, 'P13-T08', 'blank_course_code',
    $$INSERT INTO ai_review_lab.courses
      (id, instructor_id, course_code, title, level, price, opened_at)
      VALUES (3904, 201, '   ', '공백 코드', 'basic', 1000, CURRENT_DATE)$$,
    '23514', 'chk_ai_review_courses_code_not_blank'
);

CALL pg_temp.expect_failure(
    9, 'P13-T09', 'missing_student_fk',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19001, 999999, 301, '신청', 100000, CURRENT_DATE)$$,
    '23503', 'fk_ai_review_enrollments_student'
);

CALL pg_temp.expect_failure(
    10, 'P13-T10', 'missing_course_fk',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19002, 101, 999999, '신청', 100000, CURRENT_DATE)$$,
    '23503', 'fk_ai_review_enrollments_course'
);

CALL pg_temp.expect_failure(
    11, 'P13-T11', 'invalid_enrollment_status',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19003, 102, 302, '결제완료', 150000, CURRENT_DATE)$$,
    '23514', 'chk_ai_review_enrollments_status'
);

CALL pg_temp.expect_failure(
    12, 'P13-T12', 'negative_agreed_amount',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19004, 102, 302, '신청', -1000, CURRENT_DATE)$$,
    '23514', 'chk_ai_review_enrollments_amount'
);

CALL pg_temp.expect_failure(
    13, 'P13-T13', 'duplicate_active_enrollment',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19005, 102, 301, '수강중', 100000, CURRENT_DATE)$$,
    '23505', 'uq_ai_review_enrollments_active'
);

CALL pg_temp.expect_failure(
    14, 'P13-T14', 'missing_enrollment_fk',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9901, 999999, 100000, '결제대기', NULL, NULL, 'NEG-MISSING-ENROLLMENT')$$,
    '23503', 'fk_ai_review_payments_enrollment'
);

CALL pg_temp.expect_failure(
    15, 'P13-T15', 'negative_payment_amount',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9911, 1001, -5000, '결제완료', CURRENT_TIMESTAMP, NULL, 'NEG-AMOUNT')$$,
    '23514', 'chk_ai_review_payments_amount'
);

CALL pg_temp.expect_failure(
    16, 'P13-T16', 'invalid_payment_status',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9912, 1001, 100000, '처리완료', CURRENT_TIMESTAMP, NULL, 'NEG-STATUS')$$,
    '23514', 'chk_ai_review_payments_status'
);

CALL pg_temp.expect_failure(
    17, 'P13-T17', 'completed_without_paid_at',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9913, 1001, 100000, '결제완료', NULL, NULL, 'NEG-PAID-NULL')$$,
    '23514', 'chk_ai_review_payments_timestamps'
);

CALL pg_temp.expect_failure(
    18, 'P13-T18', 'refund_without_refunded_at',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9914, 1001, 100000, '환불', CURRENT_TIMESTAMP, NULL, 'NEG-REFUND-NULL')$$,
    '23514', 'chk_ai_review_payments_timestamps'
);

CALL pg_temp.expect_failure(
    19, 'P13-T19', 'refund_before_payment',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9915, 1001, 100000, '환불', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP - INTERVAL '1 day', 'NEG-REFUND-BEFORE')$$,
    '23514', 'chk_ai_review_payments_timestamps'
);

CALL pg_temp.expect_failure(
    20, 'P13-T20', 'blank_payment_reference',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9916, 1001, 100000, '결제완료', CURRENT_TIMESTAMP, NULL, '   ')$$,
    '23514', 'chk_ai_review_payments_reference_not_blank'
);

CALL pg_temp.expect_failure(
    21, 'P13-T21', 'duplicate_payment_reference',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9917, 1001, 100000, '결제완료', CURRENT_TIMESTAMP, NULL, 'PAY-REVIEW-TEST-001')$$,
    '23505', 'uq_ai_review_payments_reference'
);

CALL pg_temp.expect_failure(
    22, 'P13-T22', 'duplicate_payment_for_enrollment',
    $$INSERT INTO ai_review_lab.payments
      (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      VALUES (9918, 1001, 100000, '결제완료', CURRENT_TIMESTAMP, NULL, 'NEG-DUP-ENROLLMENT')$$,
    '23505', 'uq_ai_review_payments_enrollment'
);

-- ============================================================
-- P13-T23~P13-T27. 정상 경계값
-- ============================================================
CALL pg_temp.expect_success(
    23, 'P13-T23', 'zero_price_one_character_and_null_description',
    $$WITH new_instructor AS (
          INSERT INTO ai_review_lab.instructors (id, name, email, specialty)
          VALUES (2991, '가', 'boundary-instructor@example.com', 'D')
          RETURNING id
      )
      INSERT INTO ai_review_lab.courses
          (id, instructor_id, course_code, title, description, level, price, opened_at)
      SELECT 3991, id, 'ZERO-001', '나', NULL, 'basic', 0, CURRENT_DATE
      FROM new_instructor$$
);

CALL pg_temp.expect_success(
    24, 'P13-T24', 'application_without_payment',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19901, 103, 302, '신청', 0, CURRENT_DATE)$$
);

CALL pg_temp.expect_success(
    25, 'P13-T25', 'reenroll_after_completed_history',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19902, 101, 301, '신청', 100000, CURRENT_DATE)$$
);

CALL pg_temp.expect_success(
    26, 'P13-T26', 'reenroll_after_cancelled_history',
    $$INSERT INTO ai_review_lab.enrollments
      (id, student_id, course_id, status, agreed_amount, enrolled_at)
      VALUES (19903, 103, 303, '신청', 120000, CURRENT_DATE)$$
);

CALL pg_temp.expect_success(
    27, 'P13-T27', 'failed_zero_payment_with_null_timestamps',
    $$WITH new_enrollment AS (
          INSERT INTO ai_review_lab.enrollments
              (id, student_id, course_id, status, agreed_amount, enrolled_at)
          VALUES (19904, 102, 302, '신청', 0, CURRENT_DATE)
          RETURNING id
      )
      INSERT INTO ai_review_lab.payments
          (id, enrollment_id, amount, payment_status, paid_at, refunded_at, payment_reference)
      SELECT 9994, id, 0, '결제실패', NULL, NULL, 'BOUNDARY-FAILED-000'
      FROM new_enrollment$$
);

-- ============================================================
-- 결과와 전체 자동 판정
-- ============================================================
SELECT
    test_order,
    test_id,
    test_name,
    expected_result,
    expected_sqlstate,
    actual_sqlstate,
    expected_constraint,
    actual_constraint,
    actual_table,
    actual_column,
    actual_result,
    detail
FROM pg_temp.negative_test_results
ORDER BY test_order;

SELECT
    COUNT(*) AS total_tests_expected_27,
    COUNT(*) FILTER (
        WHERE actual_result IN ('expected_failure', 'expected_success')
    ) AS passed_tests_expected_27,
    COUNT(*) FILTER (
        WHERE actual_result LIKE 'unexpected%'
    ) AS unexpected_tests_expected_0
FROM pg_temp.negative_test_results;

DO $$
DECLARE
    total_count INTEGER;
    pass_count INTEGER;
    unexpected_count INTEGER;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (
            WHERE actual_result IN ('expected_failure', 'expected_success')
        ),
        COUNT(*) FILTER (
            WHERE actual_result LIKE 'unexpected%'
        )
    INTO total_count, pass_count, unexpected_count
    FROM pg_temp.negative_test_results;

    IF total_count <> 27
       OR pass_count <> 27
       OR unexpected_count <> 0 THEN
        RAISE EXCEPTION
            '반례 검증 실패: total %, passed %, unexpected %.',
            total_count,
            pass_count,
            unexpected_count;
    END IF;

    IF (SELECT COUNT(*) FROM ai_review_lab.students) <> 3
       OR (SELECT COUNT(*) FROM ai_review_lab.instructors) <> 2
       OR (SELECT COUNT(*) FROM ai_review_lab.courses) <> 3
       OR (SELECT COUNT(*) FROM ai_review_lab.enrollments) <> 4
       OR (SELECT COUNT(*) FROM ai_review_lab.payments) <> 4 THEN
        RAISE EXCEPTION
            '반례 검증 실패: 테스트 후 기준 행 수가 변경되었습니다.';
    END IF;

    RAISE NOTICE 'Chapter 13 negative and boundary tests passed: 27/27';
END
$$;

SELECT
    (SELECT COUNT(*) FROM ai_review_lab.students) AS students_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.instructors) AS instructors_expected_2,
    (SELECT COUNT(*) FROM ai_review_lab.courses) AS courses_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.enrollments) AS enrollments_expected_4,
    (SELECT COUNT(*) FROM ai_review_lab.payments) AS payments_expected_4;
