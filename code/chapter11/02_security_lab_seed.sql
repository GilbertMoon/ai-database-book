-- Chapter 11. security_lab 정상 샘플 데이터
-- 실행 전 01_security_lab_schema.sql을 먼저 실행합니다.
-- 관계를 쉽게 재현하기 위해 명시적 ID를 사용하고 마지막에 IDENTITY 시작값을 조정합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 0. 실행 전 상태 확인
-- ============================================================
DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('security_lab.students') IS NULL
       OR to_regclass('security_lab.courses') IS NULL
       OR to_regclass('security_lab.enrollments') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: security_lab 핵심 테이블이 없습니다. 01 파일을 먼저 실행하세요.';
    END IF;

    IF (SELECT COUNT(*) FROM security_lab.students) <> 0
       OR (SELECT COUNT(*) FROM security_lab.courses) <> 0
       OR (SELECT COUNT(*) FROM security_lab.enrollments) <> 0 THEN
        RAISE EXCEPTION
            '실행 중단: security_lab 테이블은 비어 있어야 합니다. 기존 데이터를 확인하세요.';
    END IF;
END
$$;

BEGIN;

INSERT INTO security_lab.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji.security@example.com', '2026-03-01'),
    (102, '이준호', 'junho.security@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon.security@example.com', '2026-03-05');

INSERT INTO security_lab.courses (id, title, level, price)
VALUES
    (201, '데이터베이스 보안 기초', 'basic', 100000),
    (202, '백업과 복구 이해', 'basic', 120000),
    (203, '권한 관리 입문', 'basic', 90000);

INSERT INTO security_lab.enrollments (
    id,
    student_id,
    course_id,
    status,
    paid_amount,
    enrolled_at
)
VALUES
    (1001, 101, 201, '수강중', 100000, '2026-04-01'),
    (1002, 102, 202, '신청', 120000, '2026-04-02'),
    (1003, 103, 203, '완료', 90000, '2026-04-03');

-- 명시적 ID 입력은 IDENTITY 내부 시퀀스의 다음 값을 자동으로 이동시키지 않습니다.
ALTER TABLE security_lab.students
    ALTER COLUMN id RESTART WITH 104;

ALTER TABLE security_lab.courses
    ALTER COLUMN id RESTART WITH 204;

ALTER TABLE security_lab.enrollments
    ALTER COLUMN id RESTART WITH 1004;

-- COMMIT 전 기준 상태를 자동 판정합니다.
DO $$
DECLARE
    duplicate_active_pair_count BIGINT;
BEGIN
    IF (SELECT COUNT(*) FROM security_lab.students) <> 3
       OR (SELECT COUNT(*) FROM security_lab.courses) <> 3
       OR (SELECT COUNT(*) FROM security_lab.enrollments) <> 3 THEN
        RAISE EXCEPTION
            '샘플 입력 중단: 기준 행 수가 예상과 다릅니다.';
    END IF;

    SELECT COUNT(*)
    INTO duplicate_active_pair_count
    FROM (
        SELECT student_id, course_id
        FROM security_lab.enrollments
        WHERE status IN ('신청', '수강중')
        GROUP BY student_id, course_id
        HAVING COUNT(*) > 1
    ) AS duplicated_active_pairs;

    IF duplicate_active_pair_count <> 0 THEN
        RAISE EXCEPTION
            '샘플 입력 중단: 활성 신청 중복 조합이 %건 있습니다.',
            duplicate_active_pair_count;
    END IF;
END
$$;

COMMIT;

-- ============================================================
-- 1. 결과 확인
-- 기대 결과: 3 / 3 / 3 / 3
-- ============================================================
SELECT COUNT(*) AS student_count
FROM security_lab.students;

SELECT COUNT(*) AS course_count
FROM security_lab.courses;

SELECT COUNT(*) AS enrollment_count
FROM security_lab.enrollments;

SELECT COUNT(*) AS joined_row_count
FROM security_lab.enrollments AS e
JOIN security_lab.students AS s
    ON s.id = e.student_id
JOIN security_lab.courses AS c
    ON c.id = e.course_id;

-- IDENTITY 다음 값은 104 / 204 / 1004입니다.
-- 복원 검증에서는 시퀀스 상태도 함께 확인합니다.
