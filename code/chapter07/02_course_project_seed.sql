-- Chapter 07. 온라인 강의 수강신청 기본 샘플 데이터
-- 실행 전 01_course_project_schema.sql을 먼저 실행합니다.
-- 관계를 재현하기 위해 명시적 ID를 사용합니다.
-- 명시적 ID 입력은 IDENTITY의 다음 값을 자동으로 변경하지 않으므로 마지막에 시작값을 조정합니다.
-- 자동 커밋 상태에서는 일부 INSERT만 반영될 수 있으므로 실행 후 행 수를 확인합니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- 기대 데이터베이스: ai_database_book
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 학생 3명
-- ============================================================
INSERT INTO course_project.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon@example.com', '2026-03-05');

-- ============================================================
-- 2. 강사 2명
-- ============================================================
INSERT INTO course_project.instructors (id, name, email, specialty)
VALUES
    (201, '문길래', 'gilbert@example.com', 'Database'),
    (202, '홍길동', 'hong@example.com', 'Python');

-- ============================================================
-- 3. 강의 3개
-- description은 선택 속성이지만 정상 샘플에서는 값을 입력합니다.
-- ============================================================
INSERT INTO course_project.courses (
    id, instructor_id, title, description, level, price, opened_at
)
VALUES
    (301, 201, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (302, 201, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (303, 202, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

-- ============================================================
-- 4. 기본 수강신청 4건
-- 같은 학생·강의 조합의 활성 신청은 한 건만 존재합니다.
-- paid_amount는 신청 당시 기록된 금액입니다.
-- ============================================================
INSERT INTO course_project.enrollments (
    id, student_id, course_id, enrolled_at, status, paid_amount
)
VALUES
    (1001, 101, 301, '2026-04-02', '수강중', 100000),
    (1002, 101, 302, '2026-04-06', '신청', 120000),
    (1003, 102, 301, '2026-04-03', '수강중', 100000),
    (1004, 103, 303, '2026-04-11', '신청', 150000);

-- ============================================================
-- 5. IDENTITY 다음 값 조정
-- 03 변경 파일에서 신청 1005를 명시적으로 입력하므로 seed 단계의 다음 값은 1005입니다.
-- ============================================================
ALTER TABLE course_project.students
    ALTER COLUMN id RESTART WITH 104;

ALTER TABLE course_project.instructors
    ALTER COLUMN id RESTART WITH 203;

ALTER TABLE course_project.courses
    ALTER COLUMN id RESTART WITH 304;

ALTER TABLE course_project.enrollments
    ALTER COLUMN id RESTART WITH 1005;

-- 기본 기대 행 수: students 3, instructors 2, courses 3, enrollments 4
-- 같은 파일을 다시 실행하면 PK 또는 UNIQUE 오류가 발생할 수 있습니다.
