-- Chapter 07. 온라인 강의 프로젝트 변경 시나리오
-- 실행 전 01_course_project_schema.sql과 02_course_project_seed.sql을 실행합니다.
-- 이 파일은 한 번만 실행하는 것을 기준으로 합니다.

SELECT current_database();
SELECT current_schema();

-- 1. 신규 신청 전 참조 대상 확인
SELECT *
FROM course_project.students
WHERE id = 102;

SELECT *
FROM course_project.courses
WHERE id = 302;

-- 2. 이준호 학생이 정규화 실습 강의를 신청
INSERT INTO course_project.enrollments (
    id, student_id, course_id, enrolled_at, status, paid_amount
)
VALUES (
    1005, 102, 302, '2026-04-07', '신청', 120000
)
RETURNING *;

-- 3. 상태 변경 전 대상 확인
SELECT *
FROM course_project.enrollments
WHERE id IN (1001, 1004)
ORDER BY id;

-- 4. 신청 1001을 완료 상태로 변경
UPDATE course_project.enrollments
SET status = '완료'
WHERE id = 1001
RETURNING *;

-- 5. 신청 1004를 취소 상태로 변경
UPDATE course_project.enrollments
SET status = '취소'
WHERE id = 1004
RETURNING *;

-- 6. 최종 변경 결과 확인
SELECT id, student_id, course_id, status, paid_amount
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;

SELECT COUNT(*) AS enrollment_count
FROM course_project.enrollments;

-- 기대 결과: enrollments 5행, 1001 완료, 1004 취소, 1005 신청
