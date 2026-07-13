-- Chapter 12. nosql_lab 기준 데이터 입력
-- 실행 전 01_nosql_lab_schema.sql을 먼저 실행합니다.
-- 자동 생성 ID를 업무 의미나 후속 참조에 사용하지 않습니다.

SELECT current_database();
SELECT current_schema();

-- 1. 문서형 강의 메타데이터 3건
INSERT INTO nosql_lab.course_documents (
    course_code,
    title,
    metadata
)
VALUES
(
    'DB-101',
    '데이터베이스 입문',
    '{
      "level": "basic",
      "tags": ["SQL", "PostgreSQL", "DB"],
      "instructor": {
        "name": "김강사",
        "specialty": "Database"
      },
      "options": {
        "online": true,
        "certificate": true
      }
    }'::jsonb
),
(
    'AI-201',
    'AI 데이터 분석',
    '{
      "level": "intermediate",
      "tags": ["AI", "Data Analysis", "Python"],
      "instructor": {
        "name": "이강사",
        "specialty": "AI"
      },
      "options": {
        "online": true,
        "certificate": false
      }
    }'::jsonb
),
(
    'GRAPH-301',
    '그래프 데이터 이해',
    '{
      "level": "advanced",
      "tags": ["Graph", "Recommendation", "Network"],
      "instructor": {
        "name": "박강사",
        "specialty": "Graph Data"
      },
      "options": {
        "online": false,
        "certificate": true
      }
    }'::jsonb
);

-- 2. Key-Value 개념 시뮬레이션 4건
INSERT INTO nosql_lab.key_value_cache_examples (
    cache_key,
    cache_value,
    source_name,
    expired_at
)
VALUES
(
    'student:101:session',
    '{
      "student_id": 101,
      "login_device": "browser",
      "status": "active"
    }'::jsonb,
    'authentication_service',
    CURRENT_TIMESTAMP + INTERVAL '30 minutes'
),
(
    'course:popular:v1:top3',
    '{
      "course_codes": ["DB-101", "AI-201", "GRAPH-301"],
      "generated_by": "daily_batch"
    }'::jsonb,
    'course_project',
    CURRENT_TIMESTAMP + INTERVAL '1 hour'
),
(
    'feature:recommendation:v1',
    '{
      "enabled": true,
      "target": "student_course_topic"
    }'::jsonb,
    'feature_configuration',
    CURRENT_TIMESTAMP + INTERVAL '1 day'
),
(
    'student:9999:session',
    '{
      "student_id": 9999,
      "login_device": "mobile",
      "status": "expired"
    }'::jsonb,
    'authentication_service',
    CURRENT_TIMESTAMP - INTERVAL '10 minutes'
);

-- 3. 저장 방식 선택 사례 6건
INSERT INTO nosql_lab.storage_choice_cases (
    case_name,
    system_role,
    primary_query,
    candidate_storage,
    source_of_truth,
    consistency_requirement,
    synchronization_strategy,
    reason
)
VALUES
(
    '수강신청과 결제',
    'source_of_truth',
    '학생·강의·결제 관계를 트랜잭션과 JOIN으로 조회',
    'RDBMS',
    'PostgreSQL course_project와 결제 원본',
    '강한 무결성과 다중 변경 원자성 필요',
    '원본 내부 트랜잭션으로 처리',
    'PK·FK·제약조건·트랜잭션이 핵심입니다.'
),
(
    '학생 로그인 세션',
    'ephemeral_state',
    '정확한 세션 키로 읽고 TTL 이후 만료',
    'Key-Value DB 후보',
    '인증 시스템의 사용자·로그인 원본',
    '짧은 지연은 가능하지만 탈취·만료 정책이 중요',
    '세션 생성·폐기 이벤트와 TTL 정책',
    '정확한 키 조회와 만료가 중심입니다.'
),
(
    '인기 강의 캐시',
    'derived_cache',
    '고정 키로 상위 강의 목록 읽기',
    'Key-Value DB 후보',
    'PostgreSQL 신청·강의 데이터',
    '일시적으로 오래된 값 허용 가능',
    '배치·이벤트 갱신과 캐시 미스 재생성',
    '원본에서 다시 만들 수 있는 파생 데이터입니다.'
),
(
    '강의 유연 메타데이터',
    'flexible_metadata',
    '강의 코드 또는 문서 필드로 상세 조회',
    'PostgreSQL JSONB 또는 Document DB 후보',
    '업무 정책에 따라 PostgreSQL 강의 원본 또는 문서 원본',
    '가격·상태 같은 핵심 규칙과 분리해 결정',
    '문서 버전·마이그레이션·검증 정책',
    '가변 속성은 문서형 저장을 검토할 수 있습니다.'
),
(
    '학습 행동 이벤트',
    'event_log',
    '학생·날짜 파티션에서 시간 범위 순서 조회',
    'Column-Family DB 후보',
    '이벤트 수집 로그 또는 검증된 이벤트 저장소',
    '중복·늦은 도착·재처리 정책 필요',
    'event_id 멱등성·실패 대기열·분석 파이프라인',
    '파티션 키와 정렬 키가 대표 조회와 맞아야 합니다.'
),
(
    '학생-강의-주제 추천 관계',
    'relationship_index',
    '여러 단계 관계를 따라 추천 후보 탐색',
    'Graph DB 후보',
    'RDBMS·이벤트·추천 모델 입력 데이터',
    '원본보다 지연된 파생 관계를 허용할 수 있음',
    '변경 이벤트·주기적 재구축·대조 작업',
    '다단계 관계 탐색이 핵심일 때 검토합니다.'
);

-- 4. 기준 행 수
SELECT COUNT(*) AS course_document_count
FROM nosql_lab.course_documents;

SELECT COUNT(*) AS cache_example_count
FROM nosql_lab.key_value_cache_examples;

SELECT COUNT(*) AS storage_choice_count
FROM nosql_lab.storage_choice_cases;

-- 기대 결과: 3 / 4 / 6
