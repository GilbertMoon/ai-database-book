-- Chapter 13. 역할이 섞인 나쁜 설계 샘플
-- 실행 전 01_ai_review_lab_schema.sql을 먼저 실행합니다.
-- 실제 카드번호·개인정보가 아닌 명확한 가상값만 사용합니다.

SELECT current_database();

INSERT INTO ai_review_lab.bad_enrollments (
    id,
    student_name,
    student_email,
    course_title,
    course_price,
    instructor_name,
    payment_status,
    sensitive_value_plaintext,
    enrollment_status,
    created_at
)
VALUES
(
    1,
    '김학생',
    'kim.review@example.com',
    '데이터베이스 입문',
    '100000',
    '박강사',
    'paid',
    'TEST-SENSITIVE-PLAINTEXT-01',
    'completed',
    '2026-07-01'
),
(
    2,
    '김학생',
    'kim.review@example.com',
    'AI 데이터 분석',
    '150000',
    '이강사',
    'paid',
    'TEST-SENSITIVE-PLAINTEXT-01',
    'completed',
    '2026-07-02'
),
(
    3,
    '이학생',
    'lee.review@example.com',
    '데이터베이스 입문',
    'one hundred thousand',
    '박강사',
    'done',
    'TEST-SENSITIVE-PLAINTEXT-02',
    'finished',
    'yesterday'
);

-- 전체 민감값은 표시하지 않고 일부만 확인합니다.
SELECT
    id,
    student_email,
    course_title,
    course_price,
    payment_status,
    LEFT(sensitive_value_plaintext, 14) || '...' AS unsafe_value_preview,
    enrollment_status,
    created_at
FROM ai_review_lab.bad_enrollments
ORDER BY id;

-- 반복 데이터 확인
SELECT
    student_email,
    COUNT(*) AS duplicated_rows
FROM ai_review_lab.bad_enrollments
GROUP BY student_email
HAVING COUNT(*) > 1;

-- 통제되지 않은 상태값 확인
SELECT DISTINCT payment_status
FROM ai_review_lab.bad_enrollments
ORDER BY payment_status;

SELECT DISTINCT enrollment_status
FROM ai_review_lab.bad_enrollments
ORDER BY enrollment_status;

SELECT COUNT(*) AS bad_enrollment_count
FROM ai_review_lab.bad_enrollments;

-- 기대 결과: 3
