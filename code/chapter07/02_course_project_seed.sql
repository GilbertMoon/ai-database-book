-- Chapter 07. 02 온라인 강의 프로젝트 기본 샘플 입력
-- 시작 상태: 프로젝트 객체 존재, 네 테이블 모두 비어 있음
-- 완료 상태: students 3 / instructors 2 / courses 3 / enrollments 4
-- 전체 입력과 IDENTITY 조정을 하나의 트랜잭션으로 실행합니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

BEGIN;

DO $$
DECLARE
    v_student_count bigint;
    v_instructor_count bigint;
    v_course_count bigint;
    v_enrollment_count bigint;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '샘플 입력 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    IF current_setting('transaction_read_only')::boolean THEN
        RAISE EXCEPTION
            '샘플 입력 중단: 현재 연결이 읽기 전용입니다.';
    END IF;

    IF to_regclass('course_project.students') IS NULL
       OR to_regclass('course_project.instructors') IS NULL
       OR to_regclass('course_project.courses') IS NULL
       OR to_regclass('course_project.enrollments') IS NULL
       OR to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN
        RAISE EXCEPTION
            '샘플 입력 중단: 01_course_project_schema.sql 실행 결과를 확인하세요.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'course_project'
          AND table_name = 'enrollments'
          AND column_name = 'recorded_amount'
          AND data_type = 'numeric'
    ) THEN
        RAISE EXCEPTION
            '샘플 입력 중단: enrollments.recorded_amount NUMERIC 열이 없습니다.';
    END IF;

    SELECT COUNT(*) INTO v_student_count
    FROM course_project.students;

    SELECT COUNT(*) INTO v_instructor_count
    FROM course_project.instructors;

    SELECT COUNT(*) INTO v_course_count
    FROM course_project.courses;

    SELECT COUNT(*) INTO v_enrollment_count
    FROM course_project.enrollments;

    IF v_student_count <> 0
       OR v_instructor_count <> 0
       OR v_course_count <> 0
       OR v_enrollment_count <> 0 THEN
        RAISE EXCEPTION
            '샘플 입력 중단: 테이블이 비어 있지 않습니다. students=%, instructors=%, courses=%, enrollments=%',
            v_student_count,
            v_instructor_count,
            v_course_count,
            v_enrollment_count;
    END IF;
END
$$;

INSERT INTO course_project.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon@example.com', '2026-03-05');

INSERT INTO course_project.instructors (id, name, email, specialty)
VALUES
    (201, '문길래', 'gilbert@example.com', 'Database'),
    (202, '홍길동', 'hong@example.com', 'Python');

INSERT INTO course_project.courses (
    id,
    instructor_id,
    title,
    description,
    level,
    price,
    opened_at
)
VALUES
    (301, 201, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (302, 201, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (303, 202, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

INSERT INTO course_project.enrollments (
    id,
    student_id,
    course_id,
    enrolled_at,
    status,
    recorded_amount
)
VALUES
    (1001, 101, 301, '2026-04-02', '수강중', 100000),
    (1002, 101, 302, '2026-04-06', '신청',   120000),
    (1003, 102, 301, '2026-04-03', '수강중', 100000),
    (1004, 103, 303, '2026-04-11', '신청',   150000);

ALTER TABLE course_project.students
    ALTER COLUMN id RESTART WITH 104;

ALTER TABLE course_project.instructors
    ALTER COLUMN id RESTART WITH 203;

ALTER TABLE course_project.courses
    ALTER COLUMN id RESTART WITH 304;

ALTER TABLE course_project.enrollments
    ALTER COLUMN id RESTART WITH 1005;

DO $$
DECLARE
    v_student_count bigint;
    v_instructor_count bigint;
    v_course_count bigint;
    v_enrollment_count bigint;
    v_recorded_total numeric;
BEGIN
    SELECT COUNT(*) INTO v_student_count
    FROM course_project.students;

    SELECT COUNT(*) INTO v_instructor_count
    FROM course_project.instructors;

    SELECT COUNT(*) INTO v_course_count
    FROM course_project.courses;

    SELECT COUNT(*), SUM(recorded_amount)
    INTO v_enrollment_count, v_recorded_total
    FROM course_project.enrollments;

    IF v_student_count <> 3
       OR v_instructor_count <> 2
       OR v_course_count <> 3
       OR v_enrollment_count <> 4
       OR v_recorded_total <> 470000 THEN
        RAISE EXCEPTION
            '샘플 입력 검증 실패: students=%, instructors=%, courses=%, enrollments=%, recorded_total=%',
            v_student_count,
            v_instructor_count,
            v_course_count,
            v_enrollment_count,
            v_recorded_total;
    END IF;
END
$$;

COMMIT;

SELECT 'students' AS object_name, COUNT(*) AS row_count
FROM course_project.students
UNION ALL
SELECT 'instructors', COUNT(*)
FROM course_project.instructors
UNION ALL
SELECT 'courses', COUNT(*)
FROM course_project.courses
UNION ALL
SELECT 'enrollments', COUNT(*)
FROM course_project.enrollments
ORDER BY object_name;
