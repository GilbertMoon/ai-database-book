-- Chapter 13. 좋은 설계 기준 데이터
-- 실행 전 01→03 파일을 순서대로 실행합니다.
-- 자동 증가값의 이전 상태를 가정하지 않도록 명시적 ID를 사용합니다.

SELECT current_database();

INSERT INTO ai_review_lab.students (
    id,
    name,
    email,
    joined_at
)
VALUES
    (101, '김학생', 'kim.review@example.com', '2026-07-01'),
    (102, '이학생', 'lee.review@example.com', '2026-07-02'),
    (103, '박학생', 'park.review@example.com', '2026-07-03');

INSERT INTO ai_review_lab.instructors (
    id,
    name,
    email,
    specialty
)
VALUES
    (201, '박강사', 'teacher-park.review@example.com', 'Database'),
    (202, '이강사', 'teacher-lee.review@example.com', 'AI Data Analysis');

INSERT INTO ai_review_lab.courses (
    id,
    instructor_id,
    course_code,
    title,
    description,
    level,
    price,
    opened_at
)
VALUES
(
    301,
    201,
    'DB-101',
    '데이터베이스 입문',
    '관계형 데이터베이스와 SQL 기초',
    'basic',
    100000,
    '2026-07-01'
),
(
    302,
    202,
    'AI-201',
    'AI 데이터 분석',
    'AI 기반 데이터 분석 입문',
    'intermediate',
    180000,
    '2026-07-02'
),
(
    303,
    201,
    'SQL-301',
    'SQL 실습 심화',
    'JOIN과 트랜잭션 심화',
    'advanced',
    120000,
    '2026-07-03'
);

INSERT INTO ai_review_lab.enrollments (
    id,
    student_id,
    course_id,
    status,
    agreed_amount,
    enrolled_at
)
VALUES
    (1001, 101, 301, '완료', 100000, '2026-07-01'),
    -- 현재 강의 가격은 180000원이지만 신청 당시 150000원으로 합의했습니다.
    (1002, 101, 302, '완료', 150000, '2026-07-02'),
    (1003, 102, 301, '신청', 100000, '2026-07-02'),
    (1004, 103, 303, '취소', 120000, '2026-07-03');

INSERT INTO ai_review_lab.payments (
    id,
    enrollment_id,
    amount,
    payment_status,
    paid_at,
    payment_reference
)
VALUES
(
    9001,
    1001,
    100000,
    '결제완료',
    '2026-07-01 10:00:00+09',
    'PAY-REVIEW-TEST-001'
),
(
    9002,
    1002,
    150000,
    '결제완료',
    '2026-07-02 11:00:00+09',
    'PAY-REVIEW-TEST-002'
),
(
    9003,
    1003,
    100000,
    '결제대기',
    NULL,
    'PAY-REVIEW-TEST-003'
),
(
    9004,
    1004,
    120000,
    '환불',
    '2026-07-03 15:00:00+09',
    'PAY-REVIEW-TEST-004'
);

SELECT COUNT(*) AS student_count
FROM ai_review_lab.students;

SELECT COUNT(*) AS instructor_count
FROM ai_review_lab.instructors;

SELECT COUNT(*) AS course_count
FROM ai_review_lab.courses;

SELECT COUNT(*) AS enrollment_count
FROM ai_review_lab.enrollments;

SELECT COUNT(*) AS payment_count
FROM ai_review_lab.payments;

-- 기대 결과: 3 / 2 / 3 / 4 / 4
