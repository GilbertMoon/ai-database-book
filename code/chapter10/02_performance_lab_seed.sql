-- Chapter 10. performance_lab 대량 데이터 생성
-- 실행 전 01_performance_lab_schema.sql을 먼저 실행합니다.
-- 기본값: students 10003 / instructors 2 / courses 2003 / enrollments 100005
-- 합성 데이터는 학생별 10개 강의를 배정하며 동일 학생·강의의 활성 신청 중복을 만들지 않습니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 사전 조건 검사
-- - performance_lab 네 테이블이 존재해야 합니다.
-- - 네 테이블이 모두 비어 있어야 합니다.
-- - 실험 후보 인덱스는 아직 없어야 합니다.
-- ============================================================
DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('performance_lab.students') IS NULL
       OR to_regclass('performance_lab.instructors') IS NULL
       OR to_regclass('performance_lab.courses') IS NULL
       OR to_regclass('performance_lab.enrollments') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: performance_lab 테이블이 준비되지 않았습니다. 01 파일을 먼저 실행하세요.';
    END IF;

    IF EXISTS (SELECT 1 FROM performance_lab.students)
       OR EXISTS (SELECT 1 FROM performance_lab.instructors)
       OR EXISTS (SELECT 1 FROM performance_lab.courses)
       OR EXISTS (SELECT 1 FROM performance_lab.enrollments) THEN
        RAISE EXCEPTION
            '실행 중단: performance_lab에 데이터가 이미 있습니다. 중복 실행하지 마세요.';
    END IF;

    IF to_regclass('performance_lab.idx_performance_courses_title') IS NOT NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_student_id') IS NOT NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_course_status') IS NOT NULL THEN
        RAISE EXCEPTION
            '실행 중단: 실험 후보 인덱스가 이미 존재합니다. 초기 상태를 확인하세요.';
    END IF;
END
$$;

-- ============================================================
-- 2. 기본·대량 데이터를 하나의 트랜잭션에서 생성
-- ============================================================
BEGIN;

-- 기본 학생 3명
INSERT INTO performance_lab.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon@example.com', '2026-03-05');

-- 기본 강사 2명
INSERT INTO performance_lab.instructors (id, name, email, specialty)
VALUES
    (201, '문길래', 'gilbert@example.com', 'Database'),
    (202, '홍길동', 'hong@example.com', 'Python');

-- 기본 강의 3개
INSERT INTO performance_lab.courses (
    id, instructor_id, title, description, level, price, opened_at
)
VALUES
    (301, 201, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (302, 201, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (303, 202, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

-- 기본 신청 5건
INSERT INTO performance_lab.enrollments (
    id, student_id, course_id, enrolled_at, status, recorded_amount
)
VALUES
    (1001, 101, 301, '2026-04-02', '완료', 100000),
    (1002, 101, 302, '2026-04-06', '신청', 120000),
    (1003, 102, 301, '2026-04-03', '수강중', 100000),
    (1004, 103, 303, '2026-04-11', '취소', 150000),
    (1005, 102, 302, '2026-04-07', '신청', 120000);

-- 성능 학생 10000명: id 1001~11000
-- 이메일 번호와 실제 학생 ID를 일치시킵니다.
INSERT INTO performance_lab.students (id, name, email, joined_at)
SELECT
    1000 + gs,
    '성능학생' || LPAD((1000 + gs)::text, 5, '0'),
    'performance' || (1000 + gs) || '@example.com',
    DATE '2025-01-01' + (gs % 365)
FROM generate_series(1, 10000) AS gs;

-- 성능 강의 2000개: id 1001~3000
INSERT INTO performance_lab.courses (
    id, instructor_id, title, description, level, price, opened_at
)
SELECT
    1000 + gs,
    CASE WHEN gs % 2 = 0 THEN 201 ELSE 202 END,
    '성능 테스트 강의 ' || LPAD(gs::text, 5, '0'),
    '인덱스 실습을 위한 자동 생성 강의',
    CASE gs % 3
        WHEN 0 THEN 'advanced'
        WHEN 1 THEN 'basic'
        ELSE 'intermediate'
    END,
    50000 + ((gs % 10) * 10000),
    DATE '2025-01-01' + (gs % 365)
FROM generate_series(1, 2000) AS gs;

-- 성능 신청 100000건: id 10001~110000
-- 각 학생은 서로 다른 강의 10개를 가지며 각 강의는 정확히 50건을 가집니다.
-- 같은 학생·강의 조합은 한 번만 생성되므로 활성 상태 중복이 없습니다.
WITH generated_enrollments AS (
    SELECT
        10000 + gs AS enrollment_id,
        1001 + ((gs - 1) / 10) AS student_id,
        1001 + (
            (
                ((gs - 1) / 10)
                + (((gs - 1) % 10) * 200)
            ) % 2000
        ) AS course_id,
        DATE '2025-01-01' + (gs % 365) AS enrolled_at,
        CASE (((gs - 1) % 10) % 4)
            WHEN 0 THEN '신청'
            WHEN 1 THEN '수강중'
            WHEN 2 THEN '완료'
            ELSE '취소'
        END AS status
    FROM generate_series(1, 100000) AS gs
)
INSERT INTO performance_lab.enrollments (
    id, student_id, course_id, enrolled_at, status, recorded_amount
)
SELECT
    g.enrollment_id,
    g.student_id,
    g.course_id,
    g.enrolled_at,
    g.status,
    c.price
FROM generated_enrollments AS g
JOIN performance_lab.courses AS c
    ON c.id = g.course_id;

-- 명시적 ID 입력은 IDENTITY의 다음 값을 자동으로 이동시키지 않습니다.
ALTER TABLE performance_lab.students
    ALTER COLUMN id RESTART WITH 11001;

ALTER TABLE performance_lab.instructors
    ALTER COLUMN id RESTART WITH 203;

ALTER TABLE performance_lab.courses
    ALTER COLUMN id RESTART WITH 3001;

ALTER TABLE performance_lab.enrollments
    ALTER COLUMN id RESTART WITH 110001;

COMMIT;

-- ============================================================
-- 3. 통계 수집
-- 기준 계획과 사후 계획은 이 통계를 공통으로 사용합니다.
-- 후보 인덱스 생성 뒤에는 다시 ANALYZE하지 않아 통계 표본 변화를 섞지 않습니다.
-- ============================================================
ANALYZE performance_lab.students;
ANALYZE performance_lab.instructors;
ANALYZE performance_lab.courses;
ANALYZE performance_lab.enrollments;

-- ============================================================
-- 4. 데이터 상태 자동 검증
-- ============================================================
DO $$
DECLARE
    duplicate_active_pair_count BIGINT;
BEGIN
    IF (SELECT COUNT(*) FROM performance_lab.students) <> 10003
       OR (SELECT COUNT(*) FROM performance_lab.instructors) <> 2
       OR (SELECT COUNT(*) FROM performance_lab.courses) <> 2003
       OR (SELECT COUNT(*) FROM performance_lab.enrollments) <> 100005 THEN
        RAISE EXCEPTION
            '검증 실패: performance_lab 기준 행 수가 예상과 다릅니다.';
    END IF;

    SELECT COUNT(*)
    INTO duplicate_active_pair_count
    FROM (
        SELECT student_id, course_id
        FROM performance_lab.enrollments
        WHERE status IN ('신청', '수강중')
        GROUP BY student_id, course_id
        HAVING COUNT(*) > 1
    ) AS duplicated_active_pairs;

    IF duplicate_active_pair_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 동일 학생·강의의 활성 신청 중복 조합이 %건 있습니다.',
            duplicate_active_pair_count;
    END IF;
END
$$;

-- ============================================================
-- 5. 행 수와 분포 확인
-- ============================================================
SELECT COUNT(*) AS student_count FROM performance_lab.students;
SELECT COUNT(*) AS instructor_count FROM performance_lab.instructors;
SELECT COUNT(*) AS course_count FROM performance_lab.courses;
SELECT COUNT(*) AS enrollment_count FROM performance_lab.enrollments;

-- 기대 결과: 10003 / 2 / 2003 / 100005

SELECT status, COUNT(*) AS row_count
FROM performance_lab.enrollments
GROUP BY status
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END;

-- 기대 결과: 신청 30002 / 수강중 30001 / 완료 20001 / 취소 20001

SELECT course_id, status, COUNT(*) AS row_count
FROM performance_lab.enrollments
WHERE course_id = 1500
GROUP BY course_id, status
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END;

-- course_id 1500 기대 결과: 신청 15 / 수강중 15 / 완료 10 / 취소 10
