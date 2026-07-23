-- Chapter 07. 온라인 강의 프로젝트 변경 시나리오
-- 실행 전 01_course_project_schema.sql과 02_course_project_seed.sql을 실행합니다.
-- 이 파일은 한 번만 실행하는 것을 기준으로 합니다.
-- 자동 커밋 상태에서는 일부 변경만 반영될 수 있으므로 각 문장을 순서대로 실행하고 결과를 확인합니다.
-- 여러 변경을 하나의 작업으로 묶는 트랜잭션은 Chapter 09에서 다룹니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 신규 신청 전 참조 대상과 기존 활성 신청 확인
-- ============================================================
SELECT *
FROM course_project.students
WHERE id = 102;

SELECT *
FROM course_project.courses
WHERE id = 302;

SELECT *
FROM course_project.enrollments
WHERE student_id = 102
  AND course_id = 302
  AND status IN ('신청', '수강중')
ORDER BY id;

-- 기대 결과: 활성 신청 0행

-- ============================================================
-- 2. 이준호 학생이 정규화 실습 강의를 신청
-- ============================================================
INSERT INTO course_project.enrollments (
    id, student_id, course_id,
    enrolled_at, status, paid_amount
)
VALUES (
    1005, 102, 302,
    '2026-04-07', '신청', 120000
)
RETURNING *;

-- 명시적 ID 1005 입력 뒤 다음 자동값을 1006으로 조정합니다.
ALTER TABLE course_project.enrollments
    ALTER COLUMN id RESTART WITH 1006;

-- ============================================================
-- 3. 상태 변경 전 대상과 현재 상태 확인
-- ============================================================
SELECT *
FROM course_project.enrollments
WHERE id IN (1001, 1004)
ORDER BY id;

-- ============================================================
-- 4. 신청 1001을 수강중에서 완료로 변경
-- 이전 상태가 예상과 다르면 RETURNING 결과가 0행입니다.
-- ============================================================
UPDATE course_project.enrollments
SET status = '완료'
WHERE id = 1001
  AND status = '수강중'
RETURNING *;

-- ============================================================
-- 5. 신청 1004를 신청에서 취소로 변경
-- 취소해도 신청 당시 paid_amount는 이력 값으로 유지합니다.
-- 환불 금액과 환불 상태는 현재 프로젝트 범위가 아닙니다.
-- ============================================================
UPDATE course_project.enrollments
SET status = '취소'
WHERE id = 1004
  AND status = '신청'
RETURNING *;

-- ============================================================
-- 6. 최종 변경 결과 확인
-- ============================================================
SELECT id, student_id, course_id, status, paid_amount
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;

SELECT COUNT(*) AS enrollment_count
FROM course_project.enrollments;

-- 기대 결과: enrollments 5행, 1001 완료, 1004 취소, 1005 신청
-- UPDATE의 RETURNING이 0행이면 예상 이전 상태와 실제 상태가 다르므로 다음 파일로 넘어가지 않습니다.
