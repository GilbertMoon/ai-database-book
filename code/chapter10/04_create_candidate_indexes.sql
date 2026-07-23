-- Chapter 10. 전후 측정을 위한 실험 후보 인덱스 생성
-- 실행 전 03_baseline_explain.sql의 결과를 기록합니다.
-- 이 파일은 performance_lab에만 세 인덱스를 생성합니다.
-- 테이블 데이터와 통계 표본을 동일하게 유지하기 위해 생성 후 ANALYZE를 다시 실행하지 않습니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('performance_lab.students') IS NULL
       OR to_regclass('performance_lab.courses') IS NULL
       OR to_regclass('performance_lab.enrollments') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: performance_lab이 준비되지 않았습니다.';
    END IF;

    IF (SELECT COUNT(*) FROM performance_lab.students) <> 10003
       OR (SELECT COUNT(*) FROM performance_lab.courses) <> 2003
       OR (SELECT COUNT(*) FROM performance_lab.enrollments) <> 100005 THEN
        RAISE EXCEPTION
            '실행 중단: 기준 데이터 행 수가 예상과 다릅니다.';
    END IF;

    IF to_regclass('performance_lab.idx_performance_courses_title') IS NOT NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_student_id') IS NOT NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_course_status') IS NOT NULL THEN
        RAISE EXCEPTION
            '실행 중단: 실험 후보 인덱스가 이미 존재합니다. 중복 생성하지 마세요.';
    END IF;
END
$$;

BEGIN;

CREATE INDEX idx_performance_courses_title
ON performance_lab.courses(title);

CREATE INDEX idx_performance_enrollments_student_id
ON performance_lab.enrollments(student_id);

CREATE INDEX idx_performance_enrollments_course_status
ON performance_lab.enrollments(course_id, status);

COMMIT;

-- 실험 통제 원칙:
-- 02 파일에서 수집한 동일한 테이블 통계를 기준 계획과 사후 계획이 함께 사용합니다.
-- 일반 컬럼 인덱스 생성만으로 테이블 데이터 분포는 바뀌지 않으므로 여기서는 ANALYZE를 다시 실행하지 않습니다.

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'performance_lab'
ORDER BY tablename, indexname;

-- 운영 환경 안내:
-- 이 실습은 격리된 실험 스키마이므로 일반 CREATE INDEX를 사용합니다.
-- 운영 테이블에서는 쓰기 잠금 영향과 작업 시간을 검토하고 필요하면
-- CREATE INDEX CONCURRENTLY를 고려합니다. CONCURRENTLY는 트랜잭션 블록 안에서 실행할 수 없으며,
-- 실패하면 INVALID 인덱스가 남았는지 확인해야 합니다.
