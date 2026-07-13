-- Chapter 10. 최종 인덱스 목록·크기·사용 통계 검토
-- 이 파일은 인덱스를 자동 삭제하지 않습니다.

SELECT current_database();

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

-- 4. 인덱스 키 컬럼 확인
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

-- 최종 수동 후보:
-- idx_performance_courses_title
-- idx_performance_enrollments_student_id
-- idx_performance_enrollments_course_status

-- 제거는 자동 실행하지 않습니다.
-- 전후 측정과 워크로드를 검토한 뒤 필요한 문장만 선택 실행합니다.
-- DROP INDEX performance_lab.idx_performance_courses_title;
-- DROP INDEX performance_lab.idx_performance_enrollments_student_id;
-- DROP INDEX performance_lab.idx_performance_enrollments_course_status;

-- 주의: idx_scan = 0만으로 삭제를 결정하지 않습니다.
-- 통계 수집 기간, PK·UNIQUE 역할과 드물지만 중요한 쿼리를 함께 확인합니다.
