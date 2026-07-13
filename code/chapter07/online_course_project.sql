-- Chapter 07. 온라인 강의 수강신청 프로젝트 안내·최종 확인
--
-- 이 파일은 기존 링크 호환을 위한 안전한 진입점입니다.
-- 테이블을 삭제하거나 생성하지 않으며 데이터를 변경하지 않습니다.
-- 실제 프로젝트는 다음 파일을 순서대로 실행합니다.
--
-- 1. 01_course_project_schema.sql
-- 2. 02_course_project_seed.sql
-- 3. 03_course_project_changes.sql
-- 4. 04_course_project_validation.sql
-- 5. 05_course_project_integrity_tests.sql에서 필요한 오류 테스트만 실행
--
-- 처음부터 다시 시작해야 할 때만 reset_course_project.sql을 사용합니다.

SELECT current_database();
SELECT current_schema();

-- 프로젝트 스키마와 테이블 존재 확인
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'course_project'
ORDER BY table_name;

-- 최종 기대 행 수 확인
SELECT COUNT(*) AS student_count
FROM course_project.students;

SELECT COUNT(*) AS instructor_count
FROM course_project.instructors;

SELECT COUNT(*) AS course_count
FROM course_project.courses;

SELECT COUNT(*) AS enrollment_count
FROM course_project.enrollments;

-- 기대 결과: students 3 / instructors 2 / courses 3 / enrollments 5

-- Chapter 08 인계 상태 확인
SELECT id, student_id, course_id, status, paid_amount
FROM course_project.enrollments
ORDER BY id;

-- 기대 상태:
-- 1001 완료
-- 1004 취소
-- 1005 신청
