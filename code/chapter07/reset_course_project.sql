-- Chapter 07. 온라인 강의 프로젝트 초기화
-- 주의: course_project 스키마와 모든 프로젝트 데이터를 삭제합니다.
-- 처음부터 다시 시작해야 할 때만 사용합니다.

-- 현재 위치 확인
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 안전 보호 구문
-- ai_database_book 데이터베이스가 아니면 예외를 발생시키며 삭제하지 않습니다.
-- 전용 스키마의 알려진 테이블만 자식에서 부모 순서로 삭제합니다.
-- DROP SCHEMA에 CASCADE를 사용하지 않으므로 예상하지 않은 객체가 남아 있으면 마지막 문장이 실패합니다.
DO $$
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '초기화 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    DROP TABLE IF EXISTS course_project.enrollments;
    DROP TABLE IF EXISTS course_project.courses;
    DROP TABLE IF EXISTS course_project.instructors;
    DROP TABLE IF EXISTS course_project.students;
    DROP SCHEMA IF EXISTS course_project;
END
$$;

-- 삭제 후 실행 순서:
-- 1. 01_course_project_schema.sql
-- 2. 02_course_project_seed.sql
-- 3. 03_course_project_changes.sql
-- 4. 04_course_project_validation.sql
-- 5. 05_course_project_integrity_tests.sql에서 필요한 테스트만 실행
