-- Chapter 10. 인덱스 목록·크기·사용 통계 검토
-- 이 파일은 인덱스를 자동 삭제하지 않습니다.
-- 세 실험 후보 인덱스가 생성된 상태에서 실행합니다.

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

    IF to_regclass('performance_lab.idx_performance_courses_title') IS NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_student_id') IS NULL
       OR to_regclass('performance_lab.idx_performance_enrollments_course_status') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: 세 실험 후보 인덱스가 모두 필요합니다.';
    END IF;
END
$$;

-- 1. 자동·수동 인덱스 전체 정의
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'performance_lab'
ORDER BY tablename, indexname;

-- 2. 인덱스 크기와 사용 통계
SELECT
    psi.schemaname,
    psi.relname AS table_name,
    psi.indexrelname AS index_name,
    psi.idx_scan,
    psi.idx_tup_read,
    psi.idx_tup_fetch,
    pg_size_pretty(pg_relation_size(psi.indexrelid)) AS index_size
FROM pg_stat_user_indexes AS psi
WHERE psi.schemaname = 'performance_lab'
ORDER BY psi.relname, psi.indexrelname;

-- idx_scan은 단순한 사용자 SQL 실행 횟수와 항상 같지 않습니다.
-- 하나의 실행 계획 안에서도 내부 인덱스 탐색 방식에 따라 값이 증가할 수 있습니다.
-- 통계 수집 기간과 실제 워크로드를 함께 해석합니다.

-- 3. 테이블·인덱스 전체 크기
SELECT
    schemaname,
    relname AS table_name,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_indexes_size(relid)) AS all_indexes_size,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE schemaname = 'performance_lab'
ORDER BY relname;

-- 4. 인덱스 키 컬럼과 제약조건 역할 확인
SELECT
    t.relname AS table_name,
    i.relname AS index_name,
    ix.indisprimary AS is_primary,
    ix.indisunique AS is_unique,
    pg_get_indexdef(ix.indexrelid) AS index_definition
FROM pg_index AS ix
JOIN pg_class AS i
    ON i.oid = ix.indexrelid
JOIN pg_class AS t
    ON t.oid = ix.indrelid
JOIN pg_namespace AS n
    ON n.oid = t.relnamespace
WHERE n.nspname = 'performance_lab'
ORDER BY t.relname, i.relname;

-- 전후 측정을 위한 실험 후보:
-- idx_performance_courses_title
-- idx_performance_enrollments_student_id
-- idx_performance_enrollments_course_status

-- 제거는 자동 실행하지 않습니다.
-- 전후 측정과 워크로드를 검토한 뒤 필요한 문장만 선택 실행합니다.
-- DROP INDEX performance_lab.idx_performance_courses_title;
-- DROP INDEX performance_lab.idx_performance_enrollments_student_id;
-- DROP INDEX performance_lab.idx_performance_enrollments_course_status;

-- 주의:
-- PK·UNIQUE 인덱스는 제약조건 유지에 직접 사용됩니다.
-- FK 자식 컬럼 인덱스는 FK 정확성을 위해 필수는 아니지만 JOIN과 부모 삭제·키 변경 성능에 도움이 될 수 있습니다.
-- idx_scan = 0만으로 어떤 인덱스도 즉시 삭제하지 않습니다.
