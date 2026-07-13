-- Chapter 10. 후보 인덱스 생성
-- 실행 전 03_baseline_explain.sql의 결과를 기록합니다.
-- 이 파일은 performance_lab에만 수동 인덱스를 생성합니다.

SELECT current_database();

CREATE INDEX idx_performance_courses_title
ON performance_lab.courses(title);

CREATE INDEX idx_performance_enrollments_student_id
ON performance_lab.enrollments(student_id);

CREATE INDEX idx_performance_enrollments_course_status
ON performance_lab.enrollments(course_id, status);

ANALYZE performance_lab.courses;
ANALYZE performance_lab.enrollments;

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'performance_lab'
ORDER BY tablename, indexname;
