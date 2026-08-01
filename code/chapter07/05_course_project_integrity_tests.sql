-- Chapter 07. 05 핵심 경계·무결성 테스트
-- 실행 전 01 → 02 → 03 → 04 파일을 순서대로 실행합니다.
-- 아래 변경 SQL은 모두 주석 상태입니다.
-- 한 번에 하나의 테스트 구간만 주석 해제해 실행합니다.
-- 실패해야 하는 테스트는 오류가 발생해야 정상입니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

SELECT COUNT(*) AS student_count_before
FROM course_project.students;

SELECT COUNT(*) AS instructor_count_before
FROM course_project.instructors;

SELECT COUNT(*) AS course_count_before
FROM course_project.courses;

SELECT COUNT(*) AS enrollment_count_before
FROM course_project.enrollments;

-- ============================================================
-- 경계 테스트 A. 무료 강의와 무료 신청 금액 0 허용
-- 기대 결과: 두 INSERT 성공, 확인 후 임시 행 삭제
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (
--     1801, 202, '무료 체험 강의', NULL, 'basic', 0, '2026-05-01'
-- );
--
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, recorded_amount
-- )
-- VALUES (
--     1802, 103, 1801, '2026-05-02', '신청', 0
-- );
--
-- SELECT id, price
-- FROM course_project.courses
-- WHERE id = 1801;
--
-- SELECT id, status, recorded_amount
-- FROM course_project.enrollments
-- WHERE id = 1802;
--
-- DELETE FROM course_project.enrollments
-- WHERE id = 1802;
--
-- DELETE FROM course_project.courses
-- WHERE id = 1801;

-- ============================================================
-- 오류 테스트 1. 학생 이메일 중복
-- 기대 결과: uq_course_students_email 오류
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1901, '중복 학생', 'minji@example.com', '2026-03-20');

-- ============================================================
-- 오류 테스트 2. 허용되지 않은 강의 난이도
-- 기대 결과: chk_course_courses_level 오류
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (
--     1902, 201, '잘못된 난이도', NULL, 'expert', 10000, '2026-05-01'
-- );

-- ============================================================
-- 오류 테스트 3. 음수 신청 기록 금액
-- 기대 결과: chk_course_enrollments_recorded_amount 오류
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, recorded_amount
-- )
-- VALUES (
--     1903, 101, 303, '2026-05-02', '신청', -1
-- );

-- ============================================================
-- 오류 테스트 4. 존재하지 않는 학생 참조
-- 기대 결과: fk_course_enrollments_student 오류
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, recorded_amount
-- )
-- VALUES (
--     1904, 999, 303, '2026-05-02', '신청', 150000
-- );

-- ============================================================
-- 오류 테스트 5. 같은 학생·강의의 두 번째 활성 신청
-- 학생 101·강의 302에는 신청 1002가 활성 상태로 존재합니다.
-- 기대 결과: uq_course_enrollments_active 오류
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, recorded_amount
-- )
-- VALUES (
--     1905, 101, 302, '2026-05-03', '수강중', 120000
-- );

-- ============================================================
-- 오류 테스트 6. 참조 중인 부모 삭제
-- 학생 101은 여러 신청에서 참조 중입니다.
-- 기대 결과: 외래키 또는 RESTRICT 오류
-- ============================================================
-- DELETE FROM course_project.students
-- WHERE id = 101;

-- ============================================================
-- 테스트 후 기준 상태 확인
-- 경계 테스트의 임시 행은 삭제한 상태여야 합니다.
-- 기대 결과: 3 / 2 / 3 / 5
-- ============================================================
SELECT COUNT(*) AS student_count_after
FROM course_project.students;

SELECT COUNT(*) AS instructor_count_after
FROM course_project.instructors;

SELECT COUNT(*) AS course_count_after
FROM course_project.courses;

SELECT COUNT(*) AS enrollment_count_after
FROM course_project.enrollments;

SELECT id, status, recorded_amount
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;

-- 오류 후 트랜잭션이 실패 상태라면 다음 테스트 전에 실행합니다.
-- ROLLBACK;
