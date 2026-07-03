-- Chapter 13. ChatGPT와 Codex로 DB 설계 검증하기
-- 목적: AI가 생성한 나쁜 설계 예시와 사람이 검토해 보완한 설계를 비교한다.
-- 핵심: AI 생성 SQL은 정답이 아니라 검토와 수정이 필요한 초안이다.

-- ============================================================
-- 실행 전 주의 사항
-- ============================================================
-- 1. 이 파일은 교육용 실습 예제입니다.
-- 2. 운영 데이터베이스에서 실행하지 마세요.
-- 3. DROP TABLE 구문은 실습 테이블 초기화를 위한 것입니다.
-- 4. AI가 만든 SQL을 실행하기 전에는 항상 읽고 검토해야 합니다.
-- 5. 실제 개인정보, 실제 결제 정보, 실제 카드 정보를 사용하지 않습니다.

-- ============================================================
-- 0. 실습 테이블 초기화
-- ============================================================

DROP TABLE IF EXISTS ai_bad_enrollments;
DROP TABLE IF EXISTS ai_good_payments;
DROP TABLE IF EXISTS ai_good_enrollments;
DROP TABLE IF EXISTS ai_good_courses;
DROP TABLE IF EXISTS ai_good_instructors;
DROP TABLE IF EXISTS ai_good_students;

-- ============================================================
-- 1. AI가 만든 나쁜 설계 예시
-- ============================================================
-- 아래 테이블은 일부러 문제를 포함한 예시입니다.
-- 실제 설계에서는 그대로 사용하면 안 됩니다.

CREATE TABLE ai_bad_enrollments (
    id SERIAL PRIMARY KEY,
    student_name TEXT,
    student_email TEXT,
    course_title TEXT,
    course_price TEXT,
    instructor_name TEXT,
    payment_status TEXT,
    card_number TEXT,
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
    card_number,
    enrollment_status,
    created_at
)
VALUES
('김학생', 'kim@example.com', '데이터베이스 입문', '100000', '박강사', 'paid', '1111-2222-3333-4444', 'completed', '2026-07-01'),
('김학생', 'kim@example.com', 'AI 데이터 분석', '150000', '이강사', 'paid', '1111-2222-3333-4444', 'completed', '2026-07-02'),
('이학생', 'lee@example.com', '데이터베이스 입문', 'one hundred thousand', '박강사', 'done', '5555-6666-7777-8888', 'finished', 'yesterday');

-- 나쁜 설계 확인
SELECT *
FROM ai_bad_enrollments
ORDER BY id;

-- ============================================================
-- 2. 나쁜 설계의 문제 확인
-- ============================================================

-- 문제 1: 같은 학생 정보가 반복된다.
SELECT
    student_email,
    COUNT(*) AS duplicated_rows
FROM ai_bad_enrollments
GROUP BY student_email
HAVING COUNT(*) > 1;

-- 문제 2: 가격이 TEXT라서 숫자 계산이 안전하지 않다.
-- 아래 쿼리는 숫자로 변환 가능한 값만 계산한다.
SELECT
    course_title,
    course_price
FROM ai_bad_enrollments;

-- 문제 3: 상태값이 일관되지 않다.
SELECT DISTINCT payment_status
FROM ai_bad_enrollments;

SELECT DISTINCT enrollment_status
FROM ai_bad_enrollments;

-- 문제 4: 민감 정보로 볼 수 있는 카드번호가 평문으로 저장되어 있다.
SELECT
    id,
    student_email,
    card_number
FROM ai_bad_enrollments;

-- 문제 5: 외래키가 없으므로 실제 학생, 강의, 결제의 관계를 보장하지 못한다.
-- ai_bad_enrollments 테이블은 학생, 강의, 강사, 결제, 수강신청 역할이 섞여 있다.

-- ============================================================
-- 3. 사람이 검토해 보완한 좋은 설계 예시
-- ============================================================

CREATE TABLE ai_good_students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    joined_at DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE ai_good_instructors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    specialty VARCHAR(100)
);

CREATE TABLE ai_good_courses (
    id SERIAL PRIMARY KEY,
    instructor_id INTEGER NOT NULL REFERENCES ai_good_instructors(id),
    title VARCHAR(200) NOT NULL,
    level VARCHAR(30) NOT NULL CHECK (level IN ('basic', 'intermediate', 'advanced')),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (instructor_id, title)
);

CREATE TABLE ai_good_enrollments (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES ai_good_students(id),
    course_id INTEGER NOT NULL REFERENCES ai_good_courses(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('applied', 'cancelled', 'completed')),
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, course_id)
);

CREATE TABLE ai_good_payments (
    id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL UNIQUE REFERENCES ai_good_enrollments(id),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    payment_status VARCHAR(20) NOT NULL CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    paid_at TIMESTAMP,
    payment_reference VARCHAR(100) UNIQUE
);

-- ============================================================
-- 4. 좋은 설계 샘플 데이터 입력
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

INSERT INTO ai_good_courses (instructor_id, title, level, price)
VALUES
(1, '데이터베이스 입문', 'basic', 100000),
(2, 'AI 데이터 분석', 'intermediate', 150000),
(1, 'SQL 실습 심화', 'intermediate', 120000);

INSERT INTO ai_good_enrollments (student_id, course_id, status)
VALUES
(1, 1, 'completed'),
(1, 2, 'completed'),
(2, 1, 'applied'),
(3, 3, 'cancelled');

INSERT INTO ai_good_payments (enrollment_id, amount, payment_status, paid_at, payment_reference)
VALUES
(1, 100000, 'paid', '2026-07-01 10:00:00', 'PAY-20260701-001'),
(2, 150000, 'paid', '2026-07-02 11:00:00', 'PAY-20260702-001'),
(3, 100000, 'pending', NULL, 'PAY-20260702-002'),
(4, 120000, 'refunded', '2026-07-03 15:00:00', 'PAY-20260703-001');

-- ============================================================
-- 5. 좋은 설계 조회 확인
-- ============================================================

SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    s.email AS student_email,
    c.title AS course_title,
    c.level AS course_level,
    c.price AS course_price,
    i.name AS instructor_name,
    e.status AS enrollment_status,
    p.payment_status,
    p.amount
FROM ai_good_enrollments e
JOIN ai_good_students s ON e.student_id = s.id
JOIN ai_good_courses c ON e.course_id = c.id
JOIN ai_good_instructors i ON c.instructor_id = i.id
LEFT JOIN ai_good_payments p ON p.enrollment_id = e.id
ORDER BY e.id;

-- ============================================================
-- 6. 제약조건 검증 예시
-- ============================================================
-- 아래 INSERT들은 오류를 확인하기 위한 예시입니다.
-- 수업 중에는 하나씩 주석을 해제하고 오류 메시지를 확인하세요.

-- 6-1. 이메일 중복 오류 확인
-- INSERT INTO ai_good_students (name, email)
-- VALUES ('중복학생', 'kim@example.com');

-- 6-2. 존재하지 않는 학생으로 수강신청 시도
-- INSERT INTO ai_good_enrollments (student_id, course_id, status)
-- VALUES (999, 1, 'applied');

-- 6-3. 잘못된 상태값 입력 시도
-- INSERT INTO ai_good_enrollments (student_id, course_id, status)
-- VALUES (2, 2, 'finished');

-- 6-4. 음수 가격 입력 시도
-- INSERT INTO ai_good_courses (instructor_id, title, level, price)
-- VALUES (1, '잘못된 가격 강의', 'basic', -1000);

-- 6-5. 결제 금액 음수 입력 시도
-- INSERT INTO ai_good_payments (enrollment_id, amount, payment_status)
-- VALUES (3, -5000, 'paid');

-- ============================================================
-- 7. 메타데이터를 활용한 설계 점검 쿼리
-- ============================================================

-- 7-1. Chapter 13 실습 테이블 목록
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'ai_%'
ORDER BY table_name;

-- 7-2. 각 테이블의 컬럼과 데이터 타입 확인
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name LIKE 'ai_good_%'
ORDER BY table_name, ordinal_position;

-- 7-3. 제약조건 확인
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.table_name LIKE 'ai_good_%'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 7-4. 외래키 관계 확인
SELECT
    tc.table_name AS source_table,
    kcu.column_name AS source_column,
    ccu.table_name AS target_table,
    ccu.column_name AS target_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name LIKE 'ai_good_%'
ORDER BY source_table, source_column;

-- ============================================================
-- 8. AI 설계 검토 체크 쿼리
-- ============================================================

-- 8-1. 학생 이메일 중복 여부 확인
SELECT email, COUNT(*) AS cnt
FROM ai_good_students
GROUP BY email
HAVING COUNT(*) > 1;

-- 8-2. 같은 학생이 같은 강의를 중복 신청했는지 확인
SELECT student_id, course_id, COUNT(*) AS cnt
FROM ai_good_enrollments
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;

-- 8-3. 결제 금액과 강의 가격이 다른 경우 확인
SELECT
    e.id AS enrollment_id,
    c.title,
    c.price AS course_price,
    p.amount AS paid_amount
FROM ai_good_enrollments e
JOIN ai_good_courses c ON e.course_id = c.id
JOIN ai_good_payments p ON p.enrollment_id = e.id
WHERE p.amount <> c.price;

-- 8-4. 결제 상태가 paid인데 paid_at이 없는 경우 확인
SELECT id, enrollment_id, payment_status, paid_at
FROM ai_good_payments
WHERE payment_status = 'paid'
  AND paid_at IS NULL;

-- 8-5. 수강신청 상태와 결제 상태를 함께 확인
SELECT
    e.id AS enrollment_id,
    e.status AS enrollment_status,
    p.payment_status
FROM ai_good_enrollments e
LEFT JOIN ai_good_payments p ON p.enrollment_id = e.id
ORDER BY e.id;

-- ============================================================
-- 9. SQL Anti-pattern 점검 메모
-- ============================================================
-- 다음 항목은 AI가 만든 SQL을 사람이 검토할 때 확인해야 합니다.
-- 1. 모든 컬럼이 TEXT로 되어 있지 않은가?
-- 2. 하나의 테이블에 여러 역할이 섞여 있지 않은가?
-- 3. FK 없이 id만 저장하고 있지 않은가?
-- 4. 상태값에 CHECK 제약조건이 없는가?
-- 5. 이메일이나 코드에 UNIQUE가 필요한데 빠져 있지 않은가?
-- 6. 금액, 날짜, Boolean 값을 적절한 타입으로 저장하는가?
-- 7. 개인정보나 결제정보를 불필요하게 평문으로 저장하지 않는가?
-- 8. 운영 DB에서 바로 DROP/DELETE/UPDATE를 실행하지 않는가?

-- ============================================================
-- 10. AI 검토 프롬프트 예시
-- ============================================================
-- 다음 프롬프트를 ChatGPT 또는 Codex에 사용할 수 있습니다.
--
-- "아래 PostgreSQL DDL을 검토해 주세요.
--  검토 기준은 다음과 같습니다.
--  1. 기본키가 모든 테이블에 있는가?
--  2. 필요한 외래키가 누락되지 않았는가?
--  3. N:M 관계가 중간 테이블로 표현되었는가?
--  4. NOT NULL, UNIQUE, CHECK 제약조건이 적절한가?
--  5. 데이터 타입이 적절한가?
--  6. 정규화 관점에서 중복이 과도하지 않은가?
--  7. 개인정보나 보안 위험이 있는 컬럼이 있는가?
--  8. PostgreSQL에서 실행 가능한 문법인가?
--  문제점과 수정안을 표로 정리해 주세요."

-- ============================================================
-- 11. 정리용 조회
-- ============================================================

SELECT 'bad design table' AS category, COUNT(*) AS row_count
FROM ai_bad_enrollments
UNION ALL
SELECT 'good students' AS category, COUNT(*) AS row_count
FROM ai_good_students
UNION ALL
SELECT 'good instructors' AS category, COUNT(*) AS row_count
FROM ai_good_instructors
UNION ALL
SELECT 'good courses' AS category, COUNT(*) AS row_count
FROM ai_good_courses
UNION ALL
SELECT 'good enrollments' AS category, COUNT(*) AS row_count
FROM ai_good_enrollments
UNION ALL
SELECT 'good payments' AS category, COUNT(*) AS row_count
FROM ai_good_payments;
