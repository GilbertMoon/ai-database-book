-- Chapter 13. ChatGPT와 Codex로 DB 설계 검증하기
-- 목적: AI가 만든 나쁜 설계와 요구사항을 기준으로 보완한 설계를 비교하고 검증한다.
--
-- 주의:
-- 이 파일은 ai_bad_ 및 ai_good_ 실습 테이블을 삭제하고 다시 생성합니다.
-- 개인 실습용 데이터베이스에서만 실행하세요.
-- 실제 개인정보, 카드번호, 비밀번호, API 키와 접속 URL을 사용하지 않습니다.
-- 선택적 오류 SQL은 한 번에 하나씩 주석을 해제하고 확인하세요.
-- 오류로 현재 트랜잭션이 중단 상태가 되면 ROLLBACK 후 다시 확인하세요.

-- ============================================================
-- 0. 현재 연결 환경 확인
-- ============================================================

SELECT
    current_database() AS current_database_name,
    current_user AS current_user_name,
    current_schema() AS current_schema_name;

-- ============================================================
-- 1. Chapter 13 실습 테이블 초기화
-- ============================================================

DROP TABLE IF EXISTS ai_bad_enrollments;
DROP TABLE IF EXISTS ai_good_payments;
DROP TABLE IF EXISTS ai_good_enrollments;
DROP TABLE IF EXISTS ai_good_courses;
DROP TABLE IF EXISTS ai_good_instructors;
DROP TABLE IF EXISTS ai_good_students;

-- ============================================================
-- 2. AI가 만든 나쁜 설계 예시
-- ============================================================
-- 교육 목적상 일부러 역할 혼합, 약한 타입, FK 부재와 민감정보 평문 저장 문제를 포함합니다.
-- card_number_plaintext의 값은 실제 카드번호가 아닌 명확한 가상 문자열입니다.

CREATE TABLE ai_bad_enrollments (
    id SERIAL PRIMARY KEY,
    student_name TEXT,
    student_email TEXT,
    course_title TEXT,
    course_price TEXT,
    instructor_name TEXT,
    payment_status TEXT,
    card_number_plaintext TEXT,
    enrollment_status TEXT,
    created_at TEXT
);

INSERT INTO ai_bad_enrollments (
    student_name,
    student_email,
    course_title,
    course_price,
    instructor_name,
    payment_status,
    card_number_plaintext,
    enrollment_status,
    created_at
)
VALUES
    ('김학생', 'kim@example.com', '데이터베이스 입문', '100000', '박강사', 'paid', 'TEST-CARD-PLAINTEXT-01', 'completed', '2026-07-01'),
    ('김학생', 'kim@example.com', 'AI 데이터 분석', '150000', '이강사', 'paid', 'TEST-CARD-PLAINTEXT-01', 'completed', '2026-07-02'),
    ('이학생', 'lee@example.com', '데이터베이스 입문', 'one hundred thousand', '박강사', 'done', 'TEST-CARD-PLAINTEXT-02', 'finished', 'yesterday');

-- 나쁜 설계 확인: 민감값은 전체 표시하지 않고 일부만 확인합니다.
SELECT
    id,
    student_email,
    course_title,
    course_price,
    payment_status,
    LEFT(card_number_plaintext, 9) || '...' AS unsafe_value_preview,
    enrollment_status,
    created_at
FROM ai_bad_enrollments
ORDER BY id;

SELECT student_email, COUNT(*) AS duplicated_rows
FROM ai_bad_enrollments
GROUP BY student_email
HAVING COUNT(*) > 1;

SELECT DISTINCT payment_status
FROM ai_bad_enrollments
ORDER BY payment_status;

SELECT DISTINCT enrollment_status
FROM ai_bad_enrollments
ORDER BY enrollment_status;

-- ============================================================
-- 3. 확인된 요구사항과 미확정 규칙
-- ============================================================
-- 확인된 요구사항
-- R1 학생 이메일 UNIQUE
-- R2 강사 이메일 UNIQUE
-- R3 강의는 강사 한 명을 FK로 참조
-- R4 학생과 강의 N:M은 enrollments로 해소
-- R5 수강 상태는 신청, 수강중, 완료, 취소
-- R6 가격과 금액은 음수가 될 수 없음
-- R7 결제는 수강신청을 FK로 참조
-- R8 실제 카드번호를 저장하지 않고 payment_reference만 저장
--
-- 미확정 규칙
-- - 취소 후 같은 강의 재신청 허용 여부
-- - 결제 재시도와 결제 이력 저장 방식
-- - 삭제 시 기존 이력 처리 방식
--
-- 따라서 요구사항에 없는 UNIQUE(student_id, course_id)와
-- ON DELETE CASCADE는 이 기본 예제에 추가하지 않습니다.

-- ============================================================
-- 4. 사람이 검토해 보완한 좋은 설계
-- ============================================================

CREATE TABLE ai_good_students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    joined_at DATE NOT NULL
);

CREATE TABLE ai_good_instructors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    specialty VARCHAR(100) NOT NULL
);

CREATE TABLE ai_good_courses (
    id SERIAL PRIMARY KEY,
    instructor_id INT NOT NULL
        REFERENCES ai_good_instructors(id),
    course_code VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL
        CHECK (level IN ('basic', 'intermediate', 'advanced')),
    price INT NOT NULL
        CHECK (price >= 0),
    opened_at DATE NOT NULL
);

CREATE TABLE ai_good_enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL
        REFERENCES ai_good_students(id),
    course_id INT NOT NULL
        REFERENCES ai_good_courses(id),
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('신청', '수강중', '완료', '취소')),
    agreed_amount INT NOT NULL
        CHECK (agreed_amount >= 0),
    enrolled_at DATE NOT NULL
);

-- 단순화 가정:
-- 이 장에서는 한 수강신청에 현재 결제 상태 한 건만 저장합니다.
-- 결제 시도, 실패, 재결제와 환불 이력을 모두 저장하려면
-- enrollment_id UNIQUE를 제거하고 결제 이벤트 모델을 별도로 설계해야 합니다.
CREATE TABLE ai_good_payments (
    id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE
        REFERENCES ai_good_enrollments(id),
    amount INT NOT NULL
        CHECK (amount >= 0),
    payment_status VARCHAR(20) NOT NULL
        CHECK (
            payment_status IN (
                '결제대기',
                '결제완료',
                '결제실패',
                '환불'
            )
        ),
    paid_at TIMESTAMPTZ,
    payment_reference VARCHAR(100) NOT NULL UNIQUE,
    CHECK (
        (
            payment_status IN ('결제완료', '환불')
            AND paid_at IS NOT NULL
        )
        OR
        (
            payment_status IN ('결제대기', '결제실패')
            AND paid_at IS NULL
        )
    )
);

-- ============================================================
-- 5. 좋은 설계 샘플 데이터
-- ============================================================

INSERT INTO ai_good_students (name, email, joined_at)
VALUES
    ('김학생', 'kim@example.com', '2026-07-01'),
    ('이학생', 'lee@example.com', '2026-07-02'),
    ('박학생', 'park@example.com', '2026-07-03');

INSERT INTO ai_good_instructors (name, email, specialty)
VALUES
    ('박강사', 'teacher-park@example.com', 'Database'),
    ('이강사', 'teacher-lee@example.com', 'AI Data Analysis');

INSERT INTO ai_good_courses (
    instructor_id,
    course_code,
    title,
    description,
    level,
    price,
    opened_at
)
VALUES
    (1, 'DB-101', '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-07-01'),
    (2, 'AI-201', 'AI 데이터 분석', 'AI 기반 데이터 분석 입문', 'intermediate', 150000, '2026-07-02'),
    (1, 'SQL-301', 'SQL 실습 심화', 'JOIN과 트랜잭션 심화', 'advanced', 120000, '2026-07-03');

INSERT INTO ai_good_enrollments (
    student_id,
    course_id,
    status,
    agreed_amount,
    enrolled_at
)
VALUES
    (1, 1, '완료', 100000, '2026-07-01'),
    (1, 2, '완료', 150000, '2026-07-02'),
    (2, 1, '신청', 100000, '2026-07-02'),
    (3, 3, '취소', 120000, '2026-07-03');

INSERT INTO ai_good_payments (
    enrollment_id,
    amount,
    payment_status,
    paid_at,
    payment_reference
)
VALUES
    (1, 100000, '결제완료', '2026-07-01 10:00:00+09', 'PAY-TEST-001'),
    (2, 150000, '결제완료', '2026-07-02 11:00:00+09', 'PAY-TEST-002'),
    (3, 100000, '결제대기', NULL, 'PAY-TEST-003'),
    (4, 120000, '환불', '2026-07-03 15:00:00+09', 'PAY-TEST-004');

-- ============================================================
-- 6. 정상 JOIN 확인: 예상 4행
-- ============================================================

SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    s.email AS student_email,
    c.course_code,
    c.title AS course_title,
    c.price AS current_course_price,
    i.name AS instructor_name,
    e.status AS enrollment_status,
    e.agreed_amount,
    p.payment_status,
    p.amount AS payment_amount,
    p.paid_at,
    p.payment_reference
FROM ai_good_enrollments AS e
JOIN ai_good_students AS s
    ON e.student_id = s.id
JOIN ai_good_courses AS c
    ON e.course_id = c.id
JOIN ai_good_instructors AS i
    ON c.instructor_id = i.id
LEFT JOIN ai_good_payments AS p
    ON p.enrollment_id = e.id
ORDER BY e.id;

-- ============================================================
-- 7. 예상 행 수 확인
-- ============================================================

SELECT COUNT(*) AS expected_3_bad_rows FROM ai_bad_enrollments;
SELECT COUNT(*) AS expected_3_students FROM ai_good_students;
SELECT COUNT(*) AS expected_2_instructors FROM ai_good_instructors;
SELECT COUNT(*) AS expected_3_courses FROM ai_good_courses;
SELECT COUNT(*) AS expected_4_enrollments FROM ai_good_enrollments;
SELECT COUNT(*) AS expected_4_payments FROM ai_good_payments;

SELECT 'bad design table' AS category, COUNT(*) AS row_count
FROM ai_bad_enrollments
UNION ALL
SELECT 'good students', COUNT(*) FROM ai_good_students
UNION ALL
SELECT 'good instructors', COUNT(*) FROM ai_good_instructors
UNION ALL
SELECT 'good courses', COUNT(*) FROM ai_good_courses
UNION ALL
SELECT 'good enrollments', COUNT(*) FROM ai_good_enrollments
UNION ALL
SELECT 'good payments', COUNT(*) FROM ai_good_payments;

-- ============================================================
-- 8. 선택적 제약조건 오류 테스트
-- ============================================================
-- 아래 SQL은 오류가 발생하는 것이 정상입니다.
-- 한 번에 하나씩 주석을 해제해 실행하세요.
-- 명시적 트랜잭션에서 오류가 발생해 aborted 상태가 되면 ROLLBACK하세요.
-- 오류 테스트 후 기본 데이터 행 수가 변하지 않았는지 다시 확인하세요.

-- 8-1. 중복 학생 이메일
-- INSERT INTO ai_good_students (name, email, joined_at)
-- VALUES ('중복학생', 'kim@example.com', CURRENT_DATE);

-- 8-2. 중복 강사 이메일
-- INSERT INTO ai_good_instructors (name, email, specialty)
-- VALUES ('중복강사', 'teacher-park@example.com', 'Database');

-- 8-3. 존재하지 않는 학생 FK
-- INSERT INTO ai_good_enrollments (student_id, course_id, status, agreed_amount, enrolled_at)
-- VALUES (999, 1, '신청', 100000, CURRENT_DATE);

-- 8-4. 존재하지 않는 강의 FK
-- INSERT INTO ai_good_enrollments (student_id, course_id, status, agreed_amount, enrolled_at)
-- VALUES (1, 999, '신청', 100000, CURRENT_DATE);

-- 8-5. 잘못된 수강 상태
-- INSERT INTO ai_good_enrollments (student_id, course_id, status, agreed_amount, enrolled_at)
-- VALUES (2, 2, '결제완료', 150000, CURRENT_DATE);

-- 8-6. 음수 강의 가격
-- INSERT INTO ai_good_courses (instructor_id, course_code, title, level, price, opened_at)
-- VALUES (1, 'BAD-PRICE', '잘못된 가격', 'basic', -1000, CURRENT_DATE);

-- 8-7. 음수 신청 합의 금액
-- INSERT INTO ai_good_enrollments (student_id, course_id, status, agreed_amount, enrolled_at)
-- VALUES (2, 2, '신청', -1000, CURRENT_DATE);

-- 8-8. 음수 결제금액
-- INSERT INTO ai_good_payments (enrollment_id, amount, payment_status, paid_at, payment_reference)
-- VALUES (3, -5000, '결제대기', NULL, 'PAY-BAD-AMOUNT');

-- 8-9. 잘못된 결제 상태
-- INSERT INTO ai_good_payments (enrollment_id, amount, payment_status, paid_at, payment_reference)
-- VALUES (3, 100000, '완료됨', CURRENT_TIMESTAMP, 'PAY-BAD-STATUS');

-- 8-10. 결제완료인데 paid_at NULL
-- UPDATE ai_good_payments
-- SET payment_status = '결제완료', paid_at = NULL
-- WHERE id = 3;

-- 8-11. 중복 payment_reference
-- INSERT INTO ai_good_payments (enrollment_id, amount, payment_status, paid_at, payment_reference)
-- VALUES (3, 100000, '결제대기', NULL, 'PAY-TEST-001');

-- ============================================================
-- 9. 실제 메타데이터 확인
-- ============================================================

-- 9-1. Chapter 13 실습 테이블 목록: 예상 6개
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (
      table_name = 'ai_bad_enrollments'
      OR table_name LIKE 'ai_good_%'
  )
ORDER BY table_name;

-- 9-2. 좋은 설계 컬럼·타입·NULL 허용
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name LIKE 'ai_good_%'
ORDER BY table_name, ordinal_position;

-- 9-3. 제약조건 종류와 실제 CHECK 정의
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    cc.check_clause
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.check_constraints AS cc
    ON cc.constraint_schema = tc.constraint_schema
   AND cc.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name LIKE 'ai_good_%'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 9-4. 외래키 관계: 예상 4행
SELECT
    tc.table_name AS source_table,
    kcu.column_name AS source_column,
    ccu.table_name AS target_table,
    ccu.column_name AS target_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.constraint_schema = kcu.constraint_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
   AND ccu.constraint_schema = tc.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name LIKE 'ai_good_%'
ORDER BY source_table, source_column;

-- 9-5. PostgreSQL 인덱스 정의
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename LIKE 'ai_good_%'
ORDER BY tablename, indexname;

-- ============================================================
-- 10. 업무 정합성 검증
-- ============================================================

-- 10-1. 학생 이메일 중복: 예상 0행
SELECT email, COUNT(*) AS duplicate_count
FROM ai_good_students
GROUP BY email
HAVING COUNT(*) > 1;

-- 10-2. 강사 이메일 중복: 예상 0행
SELECT email, COUNT(*) AS duplicate_count
FROM ai_good_instructors
GROUP BY email
HAVING COUNT(*) > 1;

-- 10-3. 신청 시점 합의 금액과 결제금액 불일치: 예상 0행
SELECT e.id AS enrollment_id, e.agreed_amount, p.amount AS payment_amount
FROM ai_good_enrollments AS e
JOIN ai_good_payments AS p ON p.enrollment_id = e.id
WHERE e.agreed_amount <> p.amount;

-- 10-4. 결제완료·환불인데 paid_at 없음: 예상 0행
SELECT id, enrollment_id, payment_status, paid_at
FROM ai_good_payments
WHERE payment_status IN ('결제완료', '환불')
  AND paid_at IS NULL;

-- 10-5. 결제대기·결제실패인데 paid_at 존재: 예상 0행
SELECT id, enrollment_id, payment_status, paid_at
FROM ai_good_payments
WHERE payment_status IN ('결제대기', '결제실패')
  AND paid_at IS NOT NULL;

-- 10-6. 수강 상태와 결제 상태 표시용 검토
-- 이 장의 단순 샘플 가정: 완료→결제완료, 신청→결제대기, 취소→환불
SELECT
    e.id AS enrollment_id,
    e.status AS enrollment_status,
    p.payment_status,
    e.agreed_amount,
    p.amount AS payment_amount
FROM ai_good_enrollments AS e
LEFT JOIN ai_good_payments AS p ON p.enrollment_id = e.id
ORDER BY e.id;

-- 10-7. 현재 가격과 신청 시점 금액 차이: 정보용
-- 결과가 있어도 할인·가격 변경일 수 있으므로 자동 오류로 판정하지 않습니다.
SELECT
    e.id AS enrollment_id,
    c.price AS current_course_price,
    e.agreed_amount
FROM ai_good_enrollments AS e
JOIN ai_good_courses AS c ON c.id = e.course_id
WHERE c.price <> e.agreed_amount
ORDER BY e.id;

-- ============================================================
-- 11. 최종 예상 결과 요약
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM ai_bad_enrollments) AS bad_rows_expected_3,
    (SELECT COUNT(*) FROM ai_good_students) AS students_expected_3,
    (SELECT COUNT(*) FROM ai_good_instructors) AS instructors_expected_2,
    (SELECT COUNT(*) FROM ai_good_courses) AS courses_expected_3,
    (SELECT COUNT(*) FROM ai_good_enrollments) AS enrollments_expected_4,
    (SELECT COUNT(*) FROM ai_good_payments) AS payments_expected_4;

-- ============================================================
-- 12. AI 검토 프롬프트 예시
-- ============================================================
-- 다음 PostgreSQL 설계를 검토해 주세요.
-- 1. 확인된 요구사항별 반영 위치를 설명합니다.
-- 2. 미확정 정책을 임의로 UNIQUE 또는 CASCADE로 고정하지 않습니다.
-- 3. PK, FK, CHECK, UNIQUE, NOT NULL과 타입을 검토합니다.
-- 4. courses.price, enrollments.agreed_amount, payments.amount의 의미를 구분합니다.
-- 5. 실제 카드번호, 비밀번호, 토큰과 연결 URL이 없는지 확인합니다.
-- 6. information_schema와 pg_indexes의 예상 결과를 제시합니다.
-- 7. 정상 JOIN 4행과 FK 4개를 검증합니다.
-- 8. 수정이 필요하면 최소 변경과 검증 SQL을 함께 제시합니다.
