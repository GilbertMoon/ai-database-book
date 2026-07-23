-- Chapter 14. analysis_lab 초기화
-- 주의: analysis_lab의 VIEW와 테이블, 데이터만 삭제합니다.
-- 처음부터 다시 시작해야 할 때만 실행합니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '초기화 중단: 현재 데이터베이스는 %입니다. ai_database_book에서만 실행하세요.',
            current_database();
    END IF;

    DROP VIEW IF EXISTS analysis_lab.enrollment_analysis_dataset;
    DROP VIEW IF EXISTS analysis_lab.analysis_parameters;
    DROP TABLE IF EXISTS analysis_lab.enrollments;
    DROP TABLE IF EXISTS analysis_lab.courses;
    DROP TABLE IF EXISTS analysis_lab.instructors;
    DROP TABLE IF EXISTS analysis_lab.students;
    DROP SCHEMA IF EXISTS analysis_lab;
END
$$;

-- 초기화 후 01_analysis_lab_schema.sql부터 다시 실행합니다.
