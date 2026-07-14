-- Chapter 14. 데이터 품질 점검
-- 목적: 집계 전에 행 수, 중복, 참조 관계와 업무 규칙을 확인합니다.

-- 1. 테이블별 행 수
SELECT 'students' AS table_name, COUNT(*) AS row_count
FROM analysis_lab.students
UNION ALL
SELECT 'instructors', COUNT(*)
FROM analysis_lab.instructors
UNION ALL
SELECT 'courses', COUNT(*)
FROM analysis_lab.courses
UNION ALL
SELECT 'enrollments', COUNT(*)
FROM analysis_lab.enrollments
ORDER BY table_name;

-- 기대: courses 5, enrollments 24, instructors 3, students 8

-- 2. enrollments PK 중복: 기대 0행
SELECT id, COUNT(*) AS duplicate_count
FROM analysis_lab.enrollments
GROUP BY id
HAVING COUNT(*) > 1;

-- 3. 없는 학생을 참조하는 수강신청: 기대 0행
SELECT e.*
FROM analysis_lab.enrollments e
LEFT JOIN analysis_lab.students s
    ON s.id = e.student_id
WHERE s.id IS NULL;

-- 4. 없는 강의를 참조하는 수강신청: 기대 0행
SELECT e.*
FROM analysis_lab.enrollments e
LEFT JOIN analysis_lab.courses c
    ON c.id = e.course_id
WHERE c.id IS NULL;

-- 5. 없는 강사를 참조하는 강의: 기대 0행
SELECT c.*
FROM analysis_lab.courses c
LEFT JOIN analysis_lab.instructors i
    ON i.id = c.instructor_id
WHERE i.id IS NULL;

-- 6. 완료인데 완료일이 없는 행: 기대 0행
SELECT id, status, completed_at
FROM analysis_lab.enrollments
WHERE status = '완료'
  AND completed_at IS NULL;

-- 7. 완료가 아닌데 완료일이 있는 행: 기대 0행
SELECT id, status, completed_at
FROM analysis_lab.enrollments
WHERE status <> '완료'
  AND completed_at IS NOT NULL;

-- 8. 완료일이 신청일보다 빠른 행: 기대 0행
SELECT id, enrolled_at, completed_at
FROM analysis_lab.enrollments
WHERE completed_at < enrolled_at;

-- 9. 음수 결제금액: 기대 0행
SELECT id, status, paid_amount
FROM analysis_lab.enrollments
WHERE paid_amount < 0;

-- 10. 취소인데 결제금액이 0이 아닌 행: 기대 0행
SELECT id, status, paid_amount
FROM analysis_lab.enrollments
WHERE status = '취소'
  AND paid_amount <> 0;

-- 11. 허용되지 않은 상태: 기대 0행
SELECT id, status
FROM analysis_lab.enrollments
WHERE status NOT IN ('신청', '수강중', '완료', '취소')
   OR status IS NULL;

-- 12. 전체 요약
SELECT
    COUNT(*) AS enrollment_count,
    COUNT(DISTINCT id) AS distinct_enrollment_count,
    COUNT(*) FILTER (WHERE completed_at IS NULL) AS completed_at_null_count,
    COUNT(*) FILTER (WHERE status = '완료') AS completed_count,
    SUM(paid_amount) AS paid_amount_sum
FROM analysis_lab.enrollments;

-- 기대:
-- enrollment_count 24
-- distinct_enrollment_count 24
-- completed_at_null_count 12
-- completed_count 12
-- paid_amount_sum 2770000
