-- Chapter 13. 안전한 반례 테스트
-- 실행 전 01→06 파일을 순서대로 실행합니다.
-- 각 반례는 PostgreSQL 예외 블록의 독립 하위 트랜잭션에서 실행됩니다.
-- 예상 오류가 발생하면 해당 변경은 자동 취소되고 결과만 임시 테이블에 기록됩니다.

SELECT current_database();

DROP TABLE IF EXISTS pg_temp.negative_test_results;

CREATE TEMP TABLE negative_test_results (
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
        INSERT INTO ai_review_lab.students (id, name, email, joined_at)
        VALUES (1901, '중복학생', 'kim.review@example.com', CURRENT_DATE);
        DELETE FROM ai_review_lab.students WHERE id = 1901;
        INSERT INTO pg_temp.negative_test_results
        VALUES (1, 'duplicate_student_email', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN unique_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (1, 'duplicate_student_email', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (1, 'duplicate_student_email', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 2. 중복 강사 이메일
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.instructors (id, name, email, specialty)
        VALUES (2901, '중복강사', 'teacher-park.review@example.com', 'Database');
        DELETE FROM ai_review_lab.instructors WHERE id = 2901;
        INSERT INTO pg_temp.negative_test_results
        VALUES (2, 'duplicate_instructor_email', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN unique_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (2, 'duplicate_instructor_email', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (2, 'duplicate_instructor_email', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 3. 존재하지 않는 강사 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.courses (
            id, instructor_id, course_code, title, level, price, opened_at
        )
        VALUES (3901, 999999, 'BAD-FK-I', '없는 강사', 'basic', 1000, CURRENT_DATE);
        DELETE FROM ai_review_lab.courses WHERE id = 3901;
        INSERT INTO pg_temp.negative_test_results
        VALUES (3, 'missing_instructor_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN foreign_key_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (3, 'missing_instructor_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (3, 'missing_instructor_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 4. 잘못된 강의 level
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.courses (
            id, instructor_id, course_code, title, level, price, opened_at
        )
        VALUES (3902, 201, 'BAD-LEVEL', '잘못된 레벨', 'expert', 1000, CURRENT_DATE);
        DELETE FROM ai_review_lab.courses WHERE id = 3902;
        INSERT INTO pg_temp.negative_test_results
        VALUES (4, 'invalid_course_level', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (4, 'invalid_course_level', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (4, 'invalid_course_level', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 5. 음수 강의 가격
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.courses (
            id, instructor_id, course_code, title, level, price, opened_at
        )
        VALUES (3903, 201, 'BAD-PRICE', '음수 가격', 'basic', -1000, CURRENT_DATE);
        DELETE FROM ai_review_lab.courses WHERE id = 3903;
        INSERT INTO pg_temp.negative_test_results
        VALUES (5, 'negative_course_price', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (5, 'negative_course_price', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (5, 'negative_course_price', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 6. 존재하지 않는 학생 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments (
            id, student_id, course_id, status, agreed_amount, enrolled_at
        )
        VALUES (19001, 999999, 301, '신청', 100000, CURRENT_DATE);
        DELETE FROM ai_review_lab.enrollments WHERE id = 19001;
        INSERT INTO pg_temp.negative_test_results
        VALUES (6, 'missing_student_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN foreign_key_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (6, 'missing_student_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (6, 'missing_student_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 7. 존재하지 않는 강의 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments (
            id, student_id, course_id, status, agreed_amount, enrolled_at
        )
        VALUES (19002, 101, 999999, '신청', 100000, CURRENT_DATE);
        DELETE FROM ai_review_lab.enrollments WHERE id = 19002;
        INSERT INTO pg_temp.negative_test_results
        VALUES (7, 'missing_course_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN foreign_key_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (7, 'missing_course_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (7, 'missing_course_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 8. 잘못된 수강 상태
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments (
            id, student_id, course_id, status, agreed_amount, enrolled_at
        )
        VALUES (19003, 102, 302, '결제완료', 150000, CURRENT_DATE);
        DELETE FROM ai_review_lab.enrollments WHERE id = 19003;
        INSERT INTO pg_temp.negative_test_results
        VALUES (8, 'invalid_enrollment_status', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (8, 'invalid_enrollment_status', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (8, 'invalid_enrollment_status', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 9. 음수 신청 합의 금액
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments (
            id, student_id, course_id, status, agreed_amount, enrolled_at
        )
        VALUES (19004, 102, 302, '신청', -1000, CURRENT_DATE);
        DELETE FROM ai_review_lab.enrollments WHERE id = 19004;
        INSERT INTO pg_temp.negative_test_results
        VALUES (9, 'negative_agreed_amount', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (9, 'negative_agreed_amount', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (9, 'negative_agreed_amount', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 10. 존재하지 않는 수강신청 FK
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.payments (
            id, enrollment_id, amount, payment_status, paid_at, payment_reference
        )
        VALUES (9901, 999999, 100000, '결제대기', NULL, 'NEG-MISSING-ENROLLMENT');
        DELETE FROM ai_review_lab.payments WHERE id = 9901;
        INSERT INTO pg_temp.negative_test_results
        VALUES (10, 'missing_enrollment_fk', 'foreign_key_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN foreign_key_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (10, 'missing_enrollment_fk', 'foreign_key_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (10, 'missing_enrollment_fk', 'foreign_key_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 11. 음수 결제금액
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments
            (id, student_id, course_id, status, agreed_amount, enrolled_at)
        VALUES (19101, 102, 302, '신청', 150000, CURRENT_DATE);

        INSERT INTO ai_review_lab.payments
            (id, enrollment_id, amount, payment_status, paid_at, payment_reference)
        VALUES (9911, 19101, -5000, '결제대기', NULL, 'NEG-AMOUNT');

        DELETE FROM ai_review_lab.payments WHERE id = 9911;
        DELETE FROM ai_review_lab.enrollments WHERE id = 19101;
        INSERT INTO pg_temp.negative_test_results
        VALUES (11, 'negative_payment_amount', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (11, 'negative_payment_amount', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (11, 'negative_payment_amount', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 12. 잘못된 결제 상태
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments
            (id, student_id, course_id, status, agreed_amount, enrolled_at)
        VALUES (19102, 102, 302, '신청', 150000, CURRENT_DATE);

        INSERT INTO ai_review_lab.payments
            (id, enrollment_id, amount, payment_status, paid_at, payment_reference)
        VALUES (9912, 19102, 150000, '처리완료', CURRENT_TIMESTAMP, 'NEG-STATUS');

        DELETE FROM ai_review_lab.payments WHERE id = 9912;
        DELETE FROM ai_review_lab.enrollments WHERE id = 19102;
        INSERT INTO pg_temp.negative_test_results
        VALUES (12, 'invalid_payment_status', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (12, 'invalid_payment_status', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (12, 'invalid_payment_status', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 13. 결제완료인데 paid_at NULL
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments
            (id, student_id, course_id, status, agreed_amount, enrolled_at)
        VALUES (19103, 102, 302, '완료', 150000, CURRENT_DATE);

        INSERT INTO ai_review_lab.payments
            (id, enrollment_id, amount, payment_status, paid_at, payment_reference)
        VALUES (9913, 19103, 150000, '결제완료', NULL, 'NEG-PAID-NULL');

        DELETE FROM ai_review_lab.payments WHERE id = 9913;
        DELETE FROM ai_review_lab.enrollments WHERE id = 19103;
        INSERT INTO pg_temp.negative_test_results
        VALUES (13, 'paid_status_without_paid_at', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (13, 'paid_status_without_paid_at', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (13, 'paid_status_without_paid_at', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 14. 결제대기인데 paid_at 존재
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments
            (id, student_id, course_id, status, agreed_amount, enrolled_at)
        VALUES (19104, 102, 302, '신청', 150000, CURRENT_DATE);

        INSERT INTO ai_review_lab.payments
            (id, enrollment_id, amount, payment_status, paid_at, payment_reference)
        VALUES (9914, 19104, 150000, '결제대기', CURRENT_TIMESTAMP, 'NEG-PENDING-TIME');

        DELETE FROM ai_review_lab.payments WHERE id = 9914;
        DELETE FROM ai_review_lab.enrollments WHERE id = 19104;
        INSERT INTO pg_temp.negative_test_results
        VALUES (14, 'pending_status_with_paid_at', 'check_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN check_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (14, 'pending_status_with_paid_at', 'check_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (14, 'pending_status_with_paid_at', 'check_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 15. 중복 payment_reference
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments
            (id, student_id, course_id, status, agreed_amount, enrolled_at)
        VALUES (19105, 102, 302, '신청', 150000, CURRENT_DATE);

        INSERT INTO ai_review_lab.payments
            (id, enrollment_id, amount, payment_status, paid_at, payment_reference)
        VALUES (9915, 19105, 150000, '결제대기', NULL, 'PAY-REVIEW-TEST-001');

        DELETE FROM ai_review_lab.payments WHERE id = 9915;
        DELETE FROM ai_review_lab.enrollments WHERE id = 19105;
        INSERT INTO pg_temp.negative_test_results
        VALUES (15, 'duplicate_payment_reference', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN unique_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (15, 'duplicate_payment_reference', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (15, 'duplicate_payment_reference', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 16. 한 수강신청에 결제 상태 두 건
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.payments
            (id, enrollment_id, amount, payment_status, paid_at, payment_reference)
        VALUES (9916, 1001, 100000, '결제완료', CURRENT_TIMESTAMP, 'NEG-DUP-ENROLLMENT');
        DELETE FROM ai_review_lab.payments WHERE id = 9916;
        INSERT INTO pg_temp.negative_test_results
        VALUES (16, 'duplicate_payment_for_enrollment', 'unique_violation', 'unexpected_success', NULL, NULL);
    EXCEPTION
        WHEN unique_violation THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (16, 'duplicate_payment_for_enrollment', 'unique_violation', 'expected_failure', SQLSTATE, SQLERRM);
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (16, 'duplicate_payment_for_enrollment', 'unique_violation', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 17. 재신청 정책을 UNIQUE로 강제하지 않았는지 확인
DO $$
BEGIN
    BEGIN
        INSERT INTO ai_review_lab.enrollments (
            id, student_id, course_id, status, agreed_amount, enrolled_at
        )
        VALUES (19107, 101, 301, '신청', 100000, CURRENT_DATE);

        DELETE FROM ai_review_lab.enrollments WHERE id = 19107;
        INSERT INTO pg_temp.negative_test_results
        VALUES (17, 'reenrollment_policy_not_forced', 'expected_success', 'expected_success', NULL, NULL);
    EXCEPTION
        WHEN OTHERS THEN
            INSERT INTO pg_temp.negative_test_results
            VALUES (17, 'reenrollment_policy_not_forced', 'expected_success', 'unexpected_error', SQLSTATE, SQLERRM);
    END;
END $$;

-- 결과 확인
SELECT
    test_order,
    test_name,
    expected_result,
    actual_result,
    sqlstate,
    detail
FROM pg_temp.negative_test_results
ORDER BY test_order;

-- 기대: 1~16은 expected_failure, 17은 expected_success
SELECT
    COUNT(*) AS total_tests_expected_17,
    COUNT(*) FILTER (
        WHERE actual_result IN ('expected_failure', 'expected_success')
    ) AS passed_tests_expected_17,
    COUNT(*) FILTER (
        WHERE actual_result LIKE 'unexpected%'
    ) AS unexpected_tests_expected_0
FROM pg_temp.negative_test_results;

-- 기준 데이터 유지 확인
SELECT
    (SELECT COUNT(*) FROM ai_review_lab.students) AS students_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.instructors) AS instructors_expected_2,
    (SELECT COUNT(*) FROM ai_review_lab.courses) AS courses_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.enrollments) AS enrollments_expected_4,
    (SELECT COUNT(*) FROM ai_review_lab.payments) AS payments_expected_4;
