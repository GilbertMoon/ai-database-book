-- Chapter 03. 로컬 PostgreSQL 실습 환경 자동 검증
-- 목적: Chapter 04 이후 실습에 필요한 로컬 환경을 예외 기반으로 판정합니다.
-- 이 파일은 테이블과 데이터를 생성·수정·삭제하지 않습니다.
-- 관리형 PostgreSQL 또는 Supabase 선택 경로의 완료 기준으로 사용하지 않습니다.

SELECT
    current_setting('server_version_num')::integer AS server_version_num,
    current_database() AS database_name,
    current_schema() AS current_schema_name,
    current_user AS user_name,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('TimeZone') AS timezone,
    to_regnamespace('public') IS NOT NULL AS public_schema_exists,
    has_schema_privilege(current_user, 'public', 'USAGE')
        AS public_schema_usage_ok;

DO $$
DECLARE
    v_server_version_num integer :=
        current_setting('server_version_num')::integer;
BEGIN
    IF v_server_version_num < 150000 THEN
        RAISE EXCEPTION
            '실행 중단: PostgreSQL 15 이상이 필요합니다. server_version_num=%',
            v_server_version_num;
    END IF;

    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '실행 중단: 현재 데이터베이스는 %입니다. ai_database_book 연결을 선택하세요.',
            current_database();
    END IF;

    IF NOT has_database_privilege(
        current_user,
        current_database(),
        'CONNECT'
    ) THEN
        RAISE EXCEPTION
            '실행 중단: 사용자 %에게 데이터베이스 CONNECT 권한이 없습니다.',
            current_user;
    END IF;

    IF to_regnamespace('public') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: public 스키마가 존재하지 않습니다.';
    END IF;

    IF NOT has_schema_privilege(current_user, 'public', 'USAGE') THEN
        RAISE EXCEPTION
            '실행 중단: 사용자 %에게 public 스키마 USAGE 권한이 없습니다.',
            current_user;
    END IF;

    IF current_setting('transaction_read_only')::boolean THEN
        RAISE EXCEPTION
            '실행 중단: 현재 연결이 읽기 전용입니다. 쓰기 가능한 로컬 연결을 선택하세요.';
    END IF;

    IF 1 + 1 <> 2 THEN
        RAISE EXCEPTION
            '실행 중단: SQL 계산 결과 검증에 실패했습니다.';
    END IF;

    RAISE NOTICE 'Chapter 03 local environment validation passed';
END
$$;