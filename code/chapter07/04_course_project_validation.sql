-- Chapter 07. 온라인 강의 프로젝트 최종 검증
-- 실행 전 01 → 02 → 03 파일을 순서대로 실행합니다.

SELECT current_database();
SELECT current_schema();

-- 1. 최종 행 수
SELECT COUNT(*) AS student_count FROM course_project.students;
SELECT COUNT(*) AS instructor_count FROM course_project.instructors;
SELECT COUNT(*) AS course_count FROM course_project.courses;
SELECT COUNT(*) AS enrollment_count FROM course_project.enrollments;

-- 기대 결과: 3 / 2 / 3 / 5

-- 2. 개별 테이블 확인
SELECT * FROM course_project.students ORDER BY id;
SELECT * FROM course_project.instructors ORDER BY id;
SELECT * FROM course_project.courses ORDER BY id;
SELECT * FROM course_project.enrollments ORDER BY id;

-- 3. 최종 서비스 조회: 기대 결과 5행
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

-- 4. 학생 101이 여러 강의를 신청했는지 확인: 기대 2행
SELECT *
FROM course_project.enrollments
WHERE student_id = 101
ORDER BY id;

-- 5. 강의 301에 여러 학생이 신청했는지 확인: 기대 2행
SELECT *
FROM course_project.enrollments
WHERE course_id = 301
ORDER BY id;

-- 6. 강사 201이 여러 강의를 담당하는지 확인: 기대 2행
SELECT *
FROM course_project.courses
WHERE instructor_id = 201
ORDER BY id;

-- 7. 변경 시나리오 결과 확인
SELECT id, status
FROM course_project.enrollments
WHERE id IN (1001, 1004, 1005)
ORDER BY id;

-- 기대 결과: 1001 완료 / 1004 취소 / 1005 신청

-- 8. 고아 관계 확인: 모두 0행이어야 함
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

-- 9. 도메인 규칙 위반 행 확인: 모두 0행이어야 함
SELECT *
FROM course_project.courses
WHERE level NOT IN ('basic', 'intermediate', 'advanced')
   OR price < 0;

SELECT *
FROM course_project.enrollments
WHERE status NOT IN ('신청', '수강중', '완료', '취소')
   OR paid_amount < 0;
