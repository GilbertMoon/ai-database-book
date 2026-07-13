-- Chapter 07. 온라인 강의 프로젝트 무결성 오류 테스트
-- 실행 전 01 → 02 → 03 파일을 순서대로 실행합니다.
-- 아래 오류 SQL은 모두 주석 처리되어 있습니다.
-- 한 번에 하나만 주석 해제하여 실행합니다.

SELECT current_database();
SELECT current_schema();
SELECT COUNT(*) AS enrollment_count_before
FROM course_project.enrollments;

-- 1. 학생 이름 NOT NULL 위반
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1901, NULL, 'null-name@example.com', '2026-03-20');

-- 2. 학생 이메일 UNIQUE 위반
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1902, '중복 학생', 'minji@example.com', '2026-03-20');

-- 3. 강의 제목 공백 CHECK 위반
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1903, 201, '   ', NULL, 'basic', 10000, '2026-05-01');

-- 4. 허용되지 않은 난이도 CHECK 위반
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1904, 201, '잘못된 난이도', NULL, 'expert', 10000, '2026-05-01');

-- 5. 음수 강의 가격 CHECK 위반
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1905, 201, '잘못된 가격', NULL, 'basic', -1000, '2026-05-01');

-- 6. 존재하지 않는 강사 FOREIGN KEY 위반
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1906, 999, '없는 강사 강의', NULL, 'basic', 10000, '2026-05-01');

-- 7. 존재하지 않는 학생 FOREIGN KEY 위반
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1907, 999, 301, '2026-05-02', '신청', 100000);

-- 8. 존재하지 않는 강의 FOREIGN KEY 위반
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1908, 101, 999, '2026-05-02', '신청', 100000);

-- 9. 허용되지 않은 상태 CHECK 위반
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1909, 101, 303, '2026-05-02', '대기', 150000);

-- 10. 음수 결제 금액 CHECK 위반
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1910, 101, 303, '2026-05-02', '신청', -1);

-- 11. 참조 중인 학생 삭제 RESTRICT/FK 위반
-- DELETE FROM course_project.students WHERE id = 101;

-- 12. 참조 중인 강사 삭제 RESTRICT/FK 위반
-- DELETE FROM course_project.instructors WHERE id = 201;

-- 13. 참조 중인 강의 삭제 RESTRICT/FK 위반
-- DELETE FROM course_project.courses WHERE id = 301;

-- 오류 테스트 후 정상 데이터 보존 확인
SELECT COUNT(*) AS student_count_after
FROM course_project.students;

SELECT COUNT(*) AS course_count_after
FROM course_project.courses;

SELECT COUNT(*) AS enrollment_count_after
FROM course_project.enrollments;

SELECT id, status
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;
