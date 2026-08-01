-- Chapter 07. 06 선택 경계·무결성 테스트
-- 실행 전 01 → 02 → 03 → 04 파일을 순서대로 실행합니다.
-- 아래 SQL은 모두 주석 상태입니다.
-- 하나의 테스트 구간만 주석 해제하고, 임시 행은 안내 순서대로 삭제합니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 선택 테스트 A. description = NULL과 한 글자 학생 이름 허용
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1803, '김', 'one-char@example.com', '2026-03-20');
--
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (
--     1804, 202, '설명 없는 강의', NULL, 'basic', 10000, '2026-05-01'
-- );
--
-- DELETE FROM course_project.courses
-- WHERE id = 1804;
--
-- DELETE FROM course_project.students
-- WHERE id = 1803;

-- ============================================================
-- 선택 테스트 B. 완료 이력 뒤 동일 학생·강의 재신청 허용
-- 신청 1001은 완료 상태이므로 학생 101·강의 301의 새 신청이 허용됩니다.
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, recorded_amount
-- )
-- VALUES (
--     1805, 101, 301, '2026-05-03', '신청', 100000
-- );
--
-- DELETE FROM course_project.enrollments
-- WHERE id = 1805;

-- ============================================================
-- 선택 테스트 C. 참조되지 않는 학생 삭제 허용
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1806, '미신청 학생', 'unused-student@example.com', '2026-03-20');
--
-- DELETE FROM course_project.students
-- WHERE id = 1806;

-- ============================================================
-- 선택 오류 테스트 1. 학생 이름 공백
-- 기대 결과: chk_course_students_name_not_blank 오류
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1906, '   ', 'blank-student@example.com', '2026-03-20');

-- ============================================================
-- 선택 오류 테스트 2. 학생 이메일 공백
-- 기대 결과: chk_course_students_email_not_blank 오류
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1907, '공백 이메일 학생', '   ', '2026-03-20');

-- ============================================================
-- 선택 오류 테스트 3. 강사 이메일 중복
-- 기대 결과: uq_course_instructors_email 오류
-- ============================================================
-- INSERT INTO course_project.instructors (id, name, email, specialty)
-- VALUES (1908, '중복 강사', 'gilbert@example.com', 'Database');

-- ============================================================
-- 선택 오류 테스트 4. 강사 전문 분야 공백
-- 기대 결과: chk_course_instructors_specialty_not_blank 오류
-- ============================================================
-- INSERT INTO course_project.instructors (id, name, email, specialty)
-- VALUES (1909, '전문분야 없음', 'blank-specialty@example.com', '   ');

-- ============================================================
-- 선택 오류 테스트 5. 강의 제목 공백
-- 기대 결과: chk_course_courses_title_not_blank 오류
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (
--     1910, 201, '   ', NULL, 'basic', 10000, '2026-05-01'
-- );

-- ============================================================
-- 선택 오류 테스트 6. 음수 강의 가격
-- 기대 결과: chk_course_courses_price 오류
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (
--     1911, 201, '잘못된 가격', NULL, 'basic', -1000, '2026-05-01'
-- );

-- ============================================================
-- 선택 오류 테스트 7. 허용되지 않은 신청 상태
-- 기대 결과: chk_course_enrollments_status 오류
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, recorded_amount
-- )
-- VALUES (
--     1912, 101, 303, '2026-05-02', '대기', 150000
-- );

-- ============================================================
-- 테스트 후 기준 상태 확인
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

-- 오류 후 트랜잭션이 실패 상태라면 다음 테스트 전에 실행합니다.
-- ROLLBACK;
