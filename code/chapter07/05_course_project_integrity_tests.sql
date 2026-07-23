-- Chapter 07. 온라인 강의 프로젝트 정상 경계·무결성 오류 테스트
-- 실행 전 01 → 02 → 03 → 04 파일을 순서대로 실행합니다.
-- 아래 변경 SQL은 모두 주석 처리되어 있습니다.
-- 한 번에 하나의 테스트 구간만 주석 해제해 실행합니다.
-- 실패해야 하는 테스트는 오류가 발생해야 정상입니다.
-- 수동 커밋 상태에서 오류 후 current transaction is aborted가 나타나면
-- ROLLBACK;을 실행한 뒤 다음 테스트로 이동합니다.

-- ============================================================
-- 0. 현재 실행 위치와 기준 행 수 확인
-- ============================================================
SELECT current_database();
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
-- 경계 테스트 A. 무료 강의와 무료 신청은 0으로 저장
-- P07-D01 검증. 네 문장을 순서대로 실행한 뒤 임시 행을 삭제합니다.
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (
--     1801, 202, '무료 체험 강의', NULL, 'basic', 0, '2026-05-01'
-- );
--
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (
--     1802, 103, 1801, '2026-05-02', '신청', 0
-- );
--
-- DELETE FROM course_project.enrollments
-- WHERE id = 1802;
--
-- DELETE FROM course_project.courses
-- WHERE id = 1801;

-- ============================================================
-- 경계 테스트 B. 선택 설명 NULL과 한 글자 학생 이름 허용
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1803, '김', 'one-char@example.com', '2026-03-20');
--
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1804, 202, '설명 없는 강의', NULL, 'basic', 10000, '2026-05-01');
--
-- DELETE FROM course_project.courses
-- WHERE id = 1804;
--
-- DELETE FROM course_project.students
-- WHERE id = 1803;

-- ============================================================
-- 경계 테스트 C. 완료·취소 이력 뒤 동일 학생·강의 재신청 허용
-- 부분 고유 인덱스는 신청·수강중 상태만 제한합니다.
-- 기존 1001은 완료 상태이므로 학생 101·강의 301의 새 신청이 허용됩니다.
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1805, 101, 301, '2026-05-03', '신청', 100000);
--
-- DELETE FROM course_project.enrollments
-- WHERE id = 1805;

-- ============================================================
-- 테스트 1. 학생 이름 NOT NULL 위반
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1901, NULL, 'null-name@example.com', '2026-03-20');

-- ============================================================
-- 테스트 2. 학생 이름 공백 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1902, '   ', 'blank-student@example.com', '2026-03-20');

-- ============================================================
-- 테스트 3. 학생 이메일 공백 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1903, '공백 이메일 학생', '   ', '2026-03-20');

-- ============================================================
-- 테스트 4. 학생 이메일 UNIQUE 위반
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1904, '중복 학생', 'minji@example.com', '2026-03-20');

-- ============================================================
-- 테스트 5. 강사 이름 공백 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.instructors (id, name, email, specialty)
-- VALUES (1905, '   ', 'blank-instructor-name@example.com', 'Database');

-- ============================================================
-- 테스트 6. 강사 이메일 공백 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.instructors (id, name, email, specialty)
-- VALUES (1906, '공백 이메일 강사', '   ', 'Database');

-- ============================================================
-- 테스트 7. 강사 이메일 UNIQUE 위반
-- ============================================================
-- INSERT INTO course_project.instructors (id, name, email, specialty)
-- VALUES (1907, '중복 강사', 'gilbert@example.com', 'Database');

-- ============================================================
-- 테스트 8. 강사 전문분야 공백 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.instructors (id, name, email, specialty)
-- VALUES (1908, '전문분야 없음', 'blank-specialty@example.com', '   ');

-- ============================================================
-- 테스트 9. 강의 제목 공백 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1909, 201, '   ', NULL, 'basic', 10000, '2026-05-01');

-- ============================================================
-- 테스트 10. 허용되지 않은 난이도 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1910, 201, '잘못된 난이도', NULL, 'expert', 10000, '2026-05-01');

-- ============================================================
-- 테스트 11. 음수 강의 가격 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1911, 201, '잘못된 가격', NULL, 'basic', -1000, '2026-05-01');

-- ============================================================
-- 테스트 12. 존재하지 않는 강사 FOREIGN KEY 위반
-- ============================================================
-- INSERT INTO course_project.courses (
--     id, instructor_id, title, description, level, price, opened_at
-- )
-- VALUES (1912, 999, '없는 강사 강의', NULL, 'basic', 10000, '2026-05-01');

-- ============================================================
-- 테스트 13. 존재하지 않는 학생 FOREIGN KEY 위반
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1913, 999, 301, '2026-05-02', '신청', 100000);

-- ============================================================
-- 테스트 14. 존재하지 않는 강의 FOREIGN KEY 위반
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1914, 101, 999, '2026-05-02', '신청', 100000);

-- ============================================================
-- 테스트 15. 허용되지 않은 상태 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1915, 101, 303, '2026-05-02', '대기', 150000);

-- ============================================================
-- 테스트 16. 음수 결제 금액 CHECK 위반
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1916, 101, 303, '2026-05-02', '신청', -1);

-- ============================================================
-- 테스트 17. 같은 학생·강의의 두 번째 활성 신청
-- 기대 결과: uq_course_enrollments_active 오류
-- 학생 101·강의 302에는 신청 1002가 활성 상태로 존재합니다.
-- ============================================================
-- INSERT INTO course_project.enrollments (
--     id, student_id, course_id, enrolled_at, status, paid_amount
-- )
-- VALUES (1917, 101, 302, '2026-05-03', '수강중', 120000);

-- ============================================================
-- 테스트 18. 참조 중인 학생 삭제 RESTRICT/FK 위반
-- ============================================================
-- DELETE FROM course_project.students WHERE id = 101;

-- ============================================================
-- 테스트 19. 참조 중인 강사 삭제 RESTRICT/FK 위반
-- ============================================================
-- DELETE FROM course_project.instructors WHERE id = 201;

-- ============================================================
-- 테스트 20. 참조 중인 강의 삭제 RESTRICT/FK 위반
-- ============================================================
-- DELETE FROM course_project.courses WHERE id = 301;

-- ============================================================
-- 테스트 21. 참조되지 않는 부모 삭제 성공
-- 두 문장을 순서대로 실행할 수 있습니다.
-- ============================================================
-- INSERT INTO course_project.students (id, name, email, joined_at)
-- VALUES (1921, '미신청 학생', 'unused-student@example.com', '2026-03-20');
--
-- DELETE FROM course_project.students
-- WHERE id = 1921;

-- ============================================================
-- 오류 테스트 후 정상 데이터 보존 확인
-- 경계·정상 테스트의 임시 행은 삭제한 상태여야 합니다.
-- 기대 결과: students 3 / instructors 2 / courses 3 / enrollments 5
-- ============================================================
SELECT COUNT(*) AS student_count_after
FROM course_project.students;

SELECT COUNT(*) AS instructor_count_after
FROM course_project.instructors;

SELECT COUNT(*) AS course_count_after
FROM course_project.courses;

SELECT COUNT(*) AS enrollment_count_after
FROM course_project.enrollments;

SELECT id, status, paid_amount
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;
