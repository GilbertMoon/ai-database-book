-- Chapter 07. 온라인 강의 프로젝트 최종 검증
-- 실행 전 01 → 02 → 03 파일을 순서대로 실행합니다.
-- 이 파일은 데이터를 변경하지 않는 조회문만 포함합니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 최종 행 수
-- ============================================================
SELECT COUNT(*) AS student_count FROM course_project.students;
SELECT COUNT(*) AS instructor_count FROM course_project.instructors;
SELECT COUNT(*) AS course_count FROM course_project.courses;
SELECT COUNT(*) AS enrollment_count FROM course_project.enrollments;

-- 기대 결과: 3 / 2 / 3 / 5

-- ============================================================
-- 2. 개별 테이블 확인
-- ============================================================
SELECT * FROM course_project.students ORDER BY id;
SELECT * FROM course_project.instructors ORDER BY id;
SELECT * FROM course_project.courses ORDER BY id;
SELECT * FROM course_project.enrollments ORDER BY id;

-- ============================================================
-- 3. 최종 서비스 조회: 기대 결과 5행
-- ============================================================
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM course_project.enrollments AS e
JOIN course_project.students AS s
    ON e.student_id = s.id
JOIN course_project.courses AS c
    ON e.course_id = c.id
JOIN course_project.instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;

-- ============================================================
-- 4. 관계 검증
-- ============================================================
-- 학생 101이 여러 강의를 신청했는지 확인: 기대 2행
SELECT *
FROM course_project.enrollments
WHERE student_id = 101
ORDER BY id;

-- 강의 301에 여러 학생이 신청했는지 확인: 기대 2행
SELECT *
FROM course_project.enrollments
WHERE course_id = 301
ORDER BY id;

-- 강사 201이 여러 강의를 담당하는지 확인: 기대 2행
SELECT *
FROM course_project.courses
WHERE instructor_id = 201
ORDER BY id;

-- ============================================================
-- 5. 변경 시나리오 결과 확인
-- ============================================================
SELECT id, status, paid_amount
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;

-- 기대 결과:
-- 1001 완료 / 100000
-- 1004 취소 / 150000
-- 1005 신청 / 120000
-- 취소된 1004의 paid_amount는 신청 당시 이력 값으로 유지됩니다.

-- ============================================================
-- 6. 고아 관계 확인: 모두 0행이어야 함
-- ============================================================
SELECT e.*
FROM course_project.enrollments AS e
LEFT JOIN course_project.students AS s
    ON e.student_id = s.id
WHERE s.id IS NULL;

SELECT e.*
FROM course_project.enrollments AS e
LEFT JOIN course_project.courses AS c
    ON e.course_id = c.id
WHERE c.id IS NULL;

SELECT c.*
FROM course_project.courses AS c
LEFT JOIN course_project.instructors AS i
    ON c.instructor_id = i.id
WHERE i.id IS NULL;

-- ============================================================
-- 7. 도메인 규칙 위반 행 확인: 모두 0행이어야 함
-- ============================================================
SELECT *
FROM course_project.students
WHERE char_length(trim(name)) = 0
   OR char_length(trim(email)) = 0;

SELECT *
FROM course_project.instructors
WHERE char_length(trim(name)) = 0
   OR char_length(trim(email)) = 0
   OR char_length(trim(specialty)) = 0;

SELECT *
FROM course_project.courses
WHERE char_length(trim(title)) = 0
   OR level NOT IN ('basic', 'intermediate', 'advanced')
   OR price < 0;

SELECT *
FROM course_project.enrollments
WHERE status NOT IN ('신청', '수강중', '완료', '취소')
   OR paid_amount < 0;

-- ============================================================
-- 8. 동시에 진행 중인 중복 신청 확인: 0행이어야 함
-- ============================================================
SELECT
    student_id,
    course_id,
    COUNT(*) AS active_enrollment_count
FROM course_project.enrollments
WHERE status IN ('신청', '수강중')
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 9. 최종 검산값
-- ============================================================
SELECT
    COUNT(*) AS total_enrollments,
    SUM(paid_amount) AS total_stored_paid_amount,
    COUNT(*) FILTER (WHERE status <> '취소') AS non_cancelled_enrollments,
    SUM(paid_amount) FILTER (WHERE status <> '취소') AS non_cancelled_paid_amount
FROM course_project.enrollments;

-- 기대 결과:
-- total_enrollments = 5
-- total_stored_paid_amount = 590000
-- non_cancelled_enrollments = 4
-- non_cancelled_paid_amount = 440000
