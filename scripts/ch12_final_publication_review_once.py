from pathlib import Path


def replace_once(path, old, new, label):
    p = Path(path)
    text = p.read_text(encoding='utf-8')
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 match, found {count}')
    p.write_text(text.replace(old, new, 1), encoding='utf-8')


def append_once(path, marker, addition):
    p = Path(path)
    text = p.read_text(encoding='utf-8')
    if marker not in text:
        p.write_text(text.rstrip() + '\n\n' + addition.strip() + '\n', encoding='utf-8')

# ------------------------------------------------------------------
# Main chapter: product-neutral guarantees + current official nuances.
# ------------------------------------------------------------------
replace_once(
    'book/chapter12/chapter12.md',
    '한 서비스에서 여러 저장소를 목적별로 사용하는 방식을 흔히 polyglot persistence라고 부릅니다. 저장소 수가 늘어날수록 동기화·보안·백업·장애 대응 범위도 늘어납니다.\n',
    '한 서비스에서 여러 저장소를 목적별로 사용하는 방식을 흔히 polyglot persistence라고 부릅니다. 저장소 수가 늘어날수록 동기화·보안·백업·장애 대응 범위도 늘어납니다.\n\n위 표는 데이터베이스 계열별 **절대 보장 목록**이 아닙니다. 같은 Document·Key-Value·Wide-Column 계열 안에서도 트랜잭션, 일관성, 인덱스, 분산 동작은 제품과 배포 구성에 따라 달라질 수 있습니다. 따라서 실제 선택에서는 제품 공식 문서와 작은 PoC로 보장 범위를 다시 확인합니다.\n',
    'chapter product-neutral guarantee note',
)

replace_once(
    'book/chapter12/chapter12.md',
    '```text\nTTL은 얼마인가?\nTTL이 없는 키도 허용하는가?\n원본 변경 시 삭제할 것인가, 갱신할 것인가?\n동시 재생성 요청을 어떻게 줄이는가?\n캐시 장애 시 원본 부하 급증을 막을 수 있는가?\n오래된 값을 얼마 동안 허용하는가?\n```\n\n### 실습 모델의 범위\n',
    '```text\nTTL은 얼마인가?\nTTL이 없는 키도 허용하는가?\n원본 변경 시 삭제할 것인가, 갱신할 것인가?\n동시 재생성 요청을 어떻게 줄이는가?\n캐시 장애 시 원본 부하 급증을 막을 수 있는가?\n오래된 값을 얼마 동안 허용하는가?\n```\n\nKey-Value 모델의 중심은 **키를 기준으로 값을 찾는 접근 방식**이며 TTL은 선택 가능한 정책 중 하나입니다. 예를 들어 Redis에서 key expiration은 지정한 시간이 지나 키를 만료시키는 기능이고, eviction은 메모리 한도에 도달했을 때 설정한 정책으로 키를 제거하는 동작입니다. 둘은 같은 개념이 아니므로 “TTL이 곧 eviction”이라고 설명하지 않습니다.\n\n### 실습 모델의 범위\n',
    'chapter expiration eviction distinction',
)

replace_once(
    'book/chapter12/chapter12.md',
    '유연한 스키마는 규칙이 없다는 뜻이 아닙니다. 필드 이름, 타입, 필수 여부, 문서 버전과 마이그레이션 정책을 관리해야 합니다.\n',
    '유연한 스키마는 규칙이 없다는 뜻이 아닙니다. 필드 이름, 타입, 필수 여부, 문서 버전과 마이그레이션 정책을 관리해야 합니다.\n\n문서 단위 원자성도 Document DB 전체의 공통 보장으로 외우지 않습니다. 예를 들어 MongoDB는 단일 문서 쓰기를 원자적으로 처리하고, replica set·sharded cluster에서는 여러 문서를 묶는 트랜잭션도 지원합니다. 다른 Document DB의 지원 범위와 비용은 다를 수 있으므로 제품·배포 구성별로 확인합니다.\n',
    'chapter document transaction nuance',
)

replace_once(
    'book/chapter12/chapter12.md',
    '여기서 partition key와 clustering key는 Cassandra 계열을 중심으로 한 개념 예시입니다. 제품마다 키 구조, 정렬, 보조 인덱스와 트랜잭션 범위가 다릅니다.\n',
    '여기서 partition key와 clustering key는 Cassandra 계열을 중심으로 한 개념 예시입니다. Apache Cassandra CQL에서는 partition key가 같은 값을 가진 행을 하나의 파티션으로 묶고, clustering column이 그 파티션 안의 행 정렬을 정의합니다. 그래서 먼저 목표 조회를 정하고 그 조회에 맞춰 키를 설계합니다. 제품마다 키 구조, 정렬, 보조 인덱스와 트랜잭션 범위는 다를 수 있습니다.\n',
    'chapter Cassandra query-driven nuance',
)

replace_once(
    'book/chapter12/chapter12.md',
    '이 실습은 전용 NoSQL 제품의 분산 처리·성능·TTL·복제·장애 동작을 구현하지 않습니다.\n',
    '이 실습은 전용 NoSQL 제품의 분산 처리·성능·TTL·복제·장애 동작을 구현하지 않습니다. 교재의 SQL 자동 검증 기준은 **PostgreSQL 16**이며, 전용 NoSQL 제품의 기능 보장은 각 제품 공식 문서와 별도 PoC에서 확인합니다.\n',
    'chapter PostgreSQL 16 baseline',
)

replace_once(
    'book/chapter12/chapter12.md',
    '기본 `jsonb_ops`는 다양한 연산을 지원합니다. `jsonb_path_ops`는 포함·JSON path 중심 후보지만 키 존재 `?` 연산은 지원하지 않습니다. 실제 질의에 따라 선택합니다.\n',
    '기본 `jsonb_ops`는 `?`, `?|`, `?&`, `@>`, `@?`, `@@` 등 다양한 연산을 지원합니다. `jsonb_path_ops`는 `@>`, `@?`, `@@`를 지원하지만 키 존재 계열 `?`, `?|`, `?&`는 지원하지 않습니다. 실제 질의 형태에 따라 선택합니다.\n',
    'chapter jsonb operator classes',
)

replace_once(
    'book/chapter12/chapter12.md',
    '활성 신청 부분 고유 인덱스 존재\nnosql_lab 미존재\n```\n\n스키마와 테이블은 하나의 트랜잭션에서 생성합니다.\n',
    '활성 신청 부분 고유 인덱스 존재\nChapter 07 명명 제약조건 15개 / NOT NULL 열 20개 유지\n현재 역할에 ai_database_book CREATE 권한 존재\nnosql_lab 미존재\n```\n\nChapter 12는 `security_lab`의 존재를 시작 조건으로 요구하지 않습니다. 앞 장 실습이 남아 있다면 변경하지 않고, 없어도 Chapter 07·08의 canonical `course_project`만 맞으면 시작할 수 있습니다.\n\n스키마와 테이블은 하나의 트랜잭션에서 생성합니다.\n',
    'chapter execution preflight contract',
)

replace_once(
    'book/chapter12/chapter12.md',
    'Chapter 07 기준 3/2/3/5\nChapter 12 기준 3/4/6\n',
    'Chapter 07 기준 3/2/3/5 + 명명 제약조건 15개 + NOT NULL 열 20개\nChapter 12 기준 3/4/6\n',
    'chapter final validation contract',
)

# ------------------------------------------------------------------
# Outline / workbook.
# ------------------------------------------------------------------
replace_once(
    'book/chapter12/chapter12_outline.md',
    'Seed 기준 상태와 실제 현재 상태를 구분했는가?\n문서 스냅샷의 원본 식별자가 있는가?\n',
    'Seed 기준 상태와 실제 현재 상태를 구분했는가?\nTTL 기반 expiration과 메모리 압박에 따른 eviction을 구분했는가?\n제품·배포 구성별 트랜잭션과 일관성 보장을 공식 문서에서 확인했는가?\n문서 스냅샷의 원본 식별자가 있는가?\n',
    'outline core questions',
)

replace_once(
    'book/chapter12/chapter12_outline.md',
    '- 1001 완료/100000, 1004 취소/150000, 1005 신청/120000\n',
    '- 1001 완료/100000, 1004 취소/150000, 1005 신청/120000\n- Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개\n',
    'outline inherited structure',
)

replace_once(
    'book/chapter12/chapter12_outline.md',
    '- Seed 기준 TTL·현재 TTL\n',
    '- Seed 기준 TTL·현재 TTL\n- expiration과 eviction 구분\n- 제품·배포 구성별 트랜잭션·일관성 보장 확인\n',
    'outline concept additions',
)

replace_once(
    'book/chapter12/chapter12_outline.md',
    '`CREATE INDEX IF NOT EXISTS`는 정의 동일성을 보장하지 않으므로 사용하지 않는다. 작은 표본의 Seq Scan은 오류로 판단하지 않는다.\n',
    '`CREATE INDEX IF NOT EXISTS`는 정의 동일성을 보장하지 않으므로 사용하지 않는다. 기본 `jsonb_ops`와 `jsonb_path_ops`가 지원하는 연산자 범위도 실제 질의 형태에 맞춰 구분한다. 작은 표본의 Seq Scan은 오류로 판단하지 않는다.\n',
    'outline jsonb opclass nuance',
)

replace_once(
    'book/chapter12/chapter12_outline.md',
    '- 생성·Seed·초기화 파일은 현재 DB와 기준 상태를 실제 검사한다.\n',
    '- 생성·Seed·초기화 파일은 현재 DB와 기준 상태를 실제 검사한다.\n- 생성 전 Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개와 현재 역할의 DB CREATE 권한을 확인한다.\n',
    'outline safety preflight',
)

replace_once(
    'book/chapter12/chapter12_activity.md',
    '| recorded_amount 타입 | `NUMERIC(12,0)` |  |\n| 전체 기록 금액 | 590000 |  |\n',
    '| recorded_amount 타입 | `NUMERIC(12,0)` |  |\n| Chapter 07 명명 제약조건 | 15개 |  |\n| Chapter 07 NOT NULL 열 | 20개 |  |\n| 현재 역할 DB CREATE 권한 | 있음 |  |\n| 전체 기록 금액 | 590000 |  |\n',
    'activity execution preflight',
)

replace_once(
    'book/chapter12/chapter12_activity.md',
    '| 캐시 장애 대응 |  |\n',
    '| 캐시 장애 대응 |  |\n| expiration과 eviction 차이 |  |\n',
    'activity expiration eviction',
)

replace_once(
    'book/chapter12/chapter12_activity.md',
    '| 충돌 해결 규칙 |  |\n\n“NoSQL은 모두 최종 일관성이다”라는 설명이 부정확한 이유:\n',
    '| 충돌 해결 규칙 |  |\n| 제품·배포 구성별 보장 확인 |  |\n\n“NoSQL은 모두 최종 일관성이다”라는 설명이 부정확한 이유:\n',
    'activity product guarantee row',
)

# ------------------------------------------------------------------
# SQL preflight and final gate.
# ------------------------------------------------------------------
replace_once(
    'code/chapter12/01_nosql_lab_schema.sql',
    '    v_non_cancelled_amount NUMERIC;\n    v_active_duplicate_count BIGINT;\nBEGIN\n',
    '    v_non_cancelled_amount NUMERIC;\n    v_active_duplicate_count BIGINT;\n    v_project_named_constraint_count BIGINT;\n    v_project_not_null_count BIGINT;\nBEGIN\n',
    '01 declarations',
)

replace_once(
    'code/chapter12/01_nosql_lab_schema.sql',
    "    IF v_active_duplicate_count <> 0 THEN\n        RAISE EXCEPTION\n            '실행 중단: 활성 신청 중복이 %건 있습니다.',\n            v_active_duplicate_count;\n    END IF;\n\n    IF EXISTS (\n",
    "    IF v_active_duplicate_count <> 0 THEN\n        RAISE EXCEPTION\n            '실행 중단: 활성 신청 중복이 %건 있습니다.',\n            v_active_duplicate_count;\n    END IF;\n\n    IF NOT has_database_privilege(current_user, current_database(), 'CREATE') THEN\n        RAISE EXCEPTION\n            '실행 중단: 현재 역할 %에는 데이터베이스 %의 CREATE 권한이 없습니다.',\n            current_user, current_database();\n    END IF;\n\n    SELECT COUNT(*) INTO v_project_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_project_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_project_named_constraint_count <> 15 OR v_project_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '실행 중단: Chapter 07 구조 기준과 다릅니다. named_constraints=%, not_null_columns=%',\n            v_project_named_constraint_count, v_project_not_null_count;\n    END IF;\n\n    IF EXISTS (\n",
    '01 create privilege and inherited structure gate',
)

replace_once(
    'code/chapter12/04_key_value_cache_queries.sql',
    '-- 이 테이블은 실제 Key-Value DB의 TTL·복제·메모리 정책을 구현하지 않습니다.\n',
    '-- 이 테이블은 실제 Key-Value DB의 TTL·복제·메모리 정책을 구현하지 않습니다.\n-- 실제 제품에서 expiration(TTL 만료)과 eviction(메모리 정책에 따른 제거)은 서로 다른 동작일 수 있습니다.\n',
    '04 expiration eviction comment',
)

replace_once(
    'code/chapter12/07_nosql_lab_validation.sql',
    '    v_active_duplicate_count BIGINT;\n    v_source_mismatch_count BIGINT;\n',
    '    v_active_duplicate_count BIGINT;\n    v_project_named_constraint_count BIGINT;\n    v_project_not_null_count BIGINT;\n    v_source_mismatch_count BIGINT;\n',
    '07 declarations',
)

replace_once(
    'code/chapter12/07_nosql_lab_validation.sql',
    "    IF v_active_duplicate_count <> 0 THEN\n        RAISE EXCEPTION\n            '검증 실패: course_project 활성 신청 중복이 %건 있습니다.',\n            v_active_duplicate_count;\n    END IF;\n\n    -- --------------------------------------------------------\n    -- Chapter 12 schema and row state\n",
    "    IF v_active_duplicate_count <> 0 THEN\n        RAISE EXCEPTION\n            '검증 실패: course_project 활성 신청 중복이 %건 있습니다.',\n            v_active_duplicate_count;\n    END IF;\n\n    SELECT COUNT(*) INTO v_project_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_project_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_project_named_constraint_count <> 15 OR v_project_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '검증 실패: Chapter 07 구조 기준은 named constraints 15 / NOT NULL 20이어야 합니다. 실제 %/%.',\n            v_project_named_constraint_count, v_project_not_null_count;\n    END IF;\n\n    -- --------------------------------------------------------\n    -- Chapter 12 schema and row state\n",
    '07 inherited structure gate',
)

# ------------------------------------------------------------------
# Code README.
# ------------------------------------------------------------------
replace_once(
    'code/chapter12/README.md',
    '| `01_nosql_lab_schema.sql` | DB·Chapter 07 상태를 검사하고 문서·캐시·의사결정 테이블을 한 트랜잭션에서 생성 |\n',
    '| `01_nosql_lab_schema.sql` | DB·Chapter 07 상태·15개 명명 제약조건·20개 NOT NULL·DB CREATE 권한을 검사하고 문서·캐시·의사결정 테이블을 한 트랜잭션에서 생성 |\n',
    'README 01 description',
)

replace_once(
    'code/chapter12/README.md',
    '1005 = 신청 / 120000\n```\n',
    '1005 = 신청 / 120000\nChapter 07 명명 제약조건 = 15\nChapter 07 NOT NULL 열 = 20\n```\n\n`01_nosql_lab_schema.sql`은 `nosql_lab` DDL 전에 현재 역할이 `ai_database_book`에 `CREATE` 권한을 갖는지도 확인합니다.\n',
    'README inherited structure and CREATE',
)

replace_once(
    'code/chapter12/README.md',
    '`expired_at IS NULL`은 만료 정책이 없는 키입니다. PostgreSQL 테이블은 자동 TTL 삭제를 구현하지 않습니다.\n',
    '`expired_at IS NULL`은 만료 정책이 없는 키입니다. PostgreSQL 테이블은 자동 TTL 삭제를 구현하지 않습니다. 실제 Key-Value 제품에서도 TTL 기반 expiration과 메모리 압박에 따른 eviction은 구분해서 확인합니다. 예를 들어 Redis에서는 `EXPIRE`로 만료 시간을 지정하는 동작과 메모리 한도에서 eviction policy가 키를 제거하는 동작이 별개입니다.\n',
    'README expiration eviction',
)

replace_once(
    'code/chapter12/README.md',
    '기본 `jsonb_ops`는 다양한 연산을 지원합니다. `jsonb_path_ops`는 포함·JSON path 중심 후보지만 키 존재 `?` 연산은 지원하지 않으므로 실제 질의에 맞게 선택합니다.\n',
    '기본 `jsonb_ops`는 `?`, `?|`, `?&`, `@>`, `@?`, `@@` 등 다양한 연산을 지원합니다. `jsonb_path_ops`는 `@>`, `@?`, `@@`를 지원하지만 `?`, `?|`, `?&`는 지원하지 않으므로 실제 질의에 맞게 선택합니다.\n',
    'README jsonb opclass',
)

replace_once(
    'code/chapter12/README.md',
    'Chapter 07 기준 3/2/3/5 유지\nChapter 12 기준 3/4/6\n',
    'Chapter 07 기준 3/2/3/5 + 명명 제약조건 15 + NOT NULL 20 유지\nChapter 12 기준 3/4/6\n',
    'README final validation contract',
)

# ------------------------------------------------------------------
# Theory / practice presentation source synchronization.
# ------------------------------------------------------------------
replace_once(
    'presentation/chapter12/chapter12_theory_lecture_plan.md',
    '한 서비스가 여러 저장소를 목적별로 사용하는 것도 가능합니다. 하지만 저장소가 늘어나면 동기화, 보안, 백업, 장애 대응 범위도 함께 늘어납니다.\n',
    '한 서비스가 여러 저장소를 목적별로 사용하는 것도 가능합니다. 하지만 저장소가 늘어나면 동기화, 보안, 백업, 장애 대응 범위도 함께 늘어납니다. 또한 같은 NoSQL 계열이라도 제품과 배포 구성에 따라 트랜잭션·일관성 보장이 달라질 수 있으므로 표를 절대 보장처럼 읽지 않습니다.\n',
    'theory product-neutral table',
)

replace_once(
    'presentation/chapter12/chapter12_theory_lecture_plan.md',
    'Key-Value는 정확한 키로 값을 찾고 만료시키는 데 적합합니다. Document는 문서마다 구조가 조금씩 다른 메타데이터를 다룰 때 후보가 됩니다.\n',
    'Key-Value는 정확한 키로 값을 찾는 접근이 중심이고 TTL은 선택 가능한 정책입니다. Document는 문서마다 구조가 조금씩 다른 메타데이터를 다룰 때 후보가 됩니다.\n',
    'theory key-value definition',
)

replace_once(
    'presentation/chapter12/chapter12_theory_lecture_plan.md',
    '캐시는 원본이 아닙니다. 값이 없거나 만료되면 원본 알디비엠에스에서 다시 계산해 만들 수 있어야 합니다. TTL, 무효화, 캐시 장애 시 원본 부하도 함께 설계해야 합니다.\n',
    '캐시는 원본이 아닙니다. 값이 없거나 만료되면 원본 알디비엠에스에서 다시 계산해 만들 수 있어야 합니다. TTL, 무효화, 캐시 장애 시 원본 부하도 함께 설계해야 합니다. Redis 같은 제품에서는 TTL 만료와 메모리 부족 시 eviction도 서로 다른 정책이라는 점을 구분해야 합니다.\n',
    'theory expiration eviction',
)

replace_once(
    'presentation/chapter12/chapter12_theory_lecture_plan.md',
    '문서 설계의 핵심은 “한 문서의 경계가 어디까지인가”입니다.\n',
    '문서 설계의 핵심은 “한 문서의 경계가 어디까지인가”입니다. 문서 단위 원자성도 제품 공통 보장으로 외우지 않습니다. 예를 들어 MongoDB는 단일 문서 쓰기가 원자적이고, 다중 문서 트랜잭션도 특정 배포 구성에서 지원하지만 제품별 범위와 비용은 다시 확인해야 합니다.\n',
    'theory document transaction',
)

replace_once(
    'presentation/chapter12/chapter12_theory_lecture_plan.md',
    '이 용어는 Cassandra 계열 중심 예시입니다. 다른 제품에 그대로 적용되는 공식이라고 생각하면 안 됩니다.\n',
    '이 용어는 Cassandra 계열 중심 예시입니다. Cassandra CQL에서는 partition key가 파티션을 정하고 clustering column이 파티션 안의 행 순서를 정의합니다. 다른 제품에 그대로 적용되는 공식이라고 생각하면 안 됩니다.\n',
    'theory Cassandra semantics',
)

replace_once(
    'presentation/chapter12/chapter12_theory_lecture_plan.md',
    '이번 실습 데이터는 3행뿐이라 성능 향상을 증명하기 어렵습니다. 목적은 질의 형태와 인덱스 구조의 대응을 확인하는 것입니다.\n',
    '이번 실습 데이터는 3행뿐이라 성능 향상을 증명하기 어렵습니다. 목적은 질의 형태와 인덱스 구조의 대응을 확인하는 것입니다. 기본 `jsonb_ops`와 `jsonb_path_ops`가 지원하는 연산자 범위도 다르므로 실제 쿼리에 맞춰 선택합니다.\n',
    'theory jsonb opclass',
)

replace_once(
    'presentation/chapter12/chapter12_practice_lecture_plan.md',
    '1001 완료·100000 / 1004 취소·150000 / 1005 신청·120000\nnosql_lab = 생성 전 미존재\n',
    '1001 완료·100000 / 1004 취소·150000 / 1005 신청·120000\nChapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20\n현재 역할의 ai_database_book CREATE 권한 = 있음\nnosql_lab = 생성 전 미존재\n',
    'practice preflight screen',
)

replace_once(
    'presentation/chapter12/chapter12_practice_lecture_plan.md',
    '현재 기준은 지금 이 순간 만료되었는지 봅니다. 시간이 지나면 결과가 바뀔 수 있으므로, 자동 검증 기준과 운영 판단 기준을 구분해야 합니다.\n',
    '현재 기준은 지금 이 순간 만료되었는지 봅니다. 시간이 지나면 결과가 바뀔 수 있으므로, 자동 검증 기준과 운영 판단 기준을 구분해야 합니다. 실제 Key-Value 제품에서는 이 TTL 기반 만료와 메모리 압박 시 eviction도 별개의 정책으로 확인합니다.\n',
    'practice expiration eviction',
)

replace_once(
    'presentation/chapter12/chapter12_practice_lecture_plan.md',
    '이번 데이터는 3행뿐입니다. 실행 계획에서 큰 성능 향상을 기대하기보다, 질의 형태와 인덱스 정의가 맞는지를 확인하는 것이 목표입니다.\n',
    '이번 데이터는 3행뿐입니다. 실행 계획에서 큰 성능 향상을 기대하기보다, 질의 형태와 인덱스 정의가 맞는지를 확인하는 것이 목표입니다. `jsonb_ops`와 `jsonb_path_ops`의 지원 연산자 범위도 다르므로 인덱스 방식은 실제 질의에서 출발해야 합니다.\n',
    'practice jsonb opclass',
)

replace_once(
    'presentation/chapter12/chapter12_practice_lecture_plan.md',
    'Chapter 07·08 기준: 3 / 2 / 3 / 5, 상태 2 / 1 / 1 / 1\nrecorded_amount = NUMERIC(12,0), 전체 590000\n',
    'Chapter 07·08 기준: 3 / 2 / 3 / 5, 상태 2 / 1 / 1 / 1\nChapter 07 구조: 명명 제약조건 15 / NOT NULL 열 20\nrecorded_amount = NUMERIC(12,0), 전체 590000\n',
    'practice final validation contract',
)

replace_once(
    'presentation/chapter12/chapter12_script.html',
    '<body>\n',
    '<body data-script-content-enhancer="off">\n',
    'script enhancer disable',
)

# ------------------------------------------------------------------
# Review records (validation run details are recorded after execution).
# ------------------------------------------------------------------
append_once(
    'book/chapter12/chapter12_review_revision.md',
    '## 17. 2026-08-10 최종 출판 정밀 검수 추가 반영',
    '''---

## 17. 2026-08-10 최종 출판 정밀 검수 추가 반영

최종 출판 직전 Chapter 11에서 강화한 실행 안전성 기준과 PostgreSQL·MongoDB·Redis·Cassandra 공식 문서를 다시 대조했습니다.

추가 반영:

```text
Chapter 07 구조 계약 = 명명 제약조건 15 / NOT NULL 열 20
nosql_lab 생성 전 현재 역할 DB CREATE 권한 확인
Key-Value의 핵심을 정확 키 조회로 설명하고 TTL을 선택 정책으로 구분
TTL expiration과 메모리 압박 eviction 구분
Document DB의 원자성·트랜잭션 보장을 제품·배포 구성별 확인으로 명시
MongoDB 단일 문서 원자성 / 다중 문서 트랜잭션 사례를 제품 예시로 한정
Cassandra partition key / clustering column 설명을 CQL 의미에 맞게 정밀화
PostgreSQL jsonb_ops / jsonb_path_ops 지원 연산자 범위 정밀화
PostgreSQL 16 자동 검증 기준 명시
Chapter 11 security_lab 존재를 Chapter 12 시작 조건으로 만들지 않음
작성된 발표자 스크립트의 generic content enhancer 비활성화
```

별도 NoSQL 제품의 성능·분산·장애 특성은 여전히 이 장의 PostgreSQL 실습만으로 검증되었다고 주장하지 않습니다.''',
)

append_once(
    'notes/chapter12_review_checklist.md',
    '## 20. 2026-08-10 최종 출판 정밀 검수',
    '''---

## 20. 2026-08-10 최종 출판 정밀 검수

- [x] Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 12 시작·최종 게이트에 추가
- [x] 현재 역할의 `ai_database_book` CREATE 권한을 `nosql_lab` DDL 전에 확인
- [x] Chapter 11 `security_lab` 존재를 Chapter 12 시작 조건으로 요구하지 않음
- [x] Key-Value의 핵심을 정확 키 조회로 정리하고 TTL을 선택 정책으로 구분
- [x] expiration과 eviction을 별도 동작으로 설명
- [x] Document DB 트랜잭션 보장을 제품·배포 구성별 확인하도록 정리
- [x] MongoDB 단일 문서 원자성·다중 문서 트랜잭션은 제품 사례로만 제시
- [x] Cassandra partition key·clustering column 설명을 공식 CQL 의미와 정렬
- [x] PostgreSQL `jsonb_ops` / `jsonb_path_ops` 지원 연산자 범위를 정밀화
- [x] 본문·구성안·워크북·코드 README·이론/실습 발표자료 정합성 반영
- [x] Chapter 12 작성 발표 스크립트 자동 확장 비활성화

최종 PostgreSQL 16 재검증 결과는 `notes/chapter12_validation_result.md`에 별도로 기록합니다.''',
)

# Sanity checks before commit.
chapter = Path('book/chapter12/chapter12.md').read_text(encoding='utf-8')
schema = Path('code/chapter12/01_nosql_lab_schema.sql').read_text(encoding='utf-8')
validation = Path('code/chapter12/07_nosql_lab_validation.sql').read_text(encoding='utf-8')
script_html = Path('presentation/chapter12/chapter12_script.html').read_text(encoding='utf-8')
for token in [
    'expiration', 'eviction', '명명 제약조건 15개', 'NOT NULL 열 20개',
    'PostgreSQL 16', '`jsonb_path_ops`', 'security_lab',
]:
    if token not in chapter:
        raise SystemExit(f'chapter missing final token: {token}')
for text, label in [(schema, '01'), (validation, '07')]:
    for token in ['v_project_named_constraint_count', 'v_project_not_null_count', '<> 15', '<> 20']:
        if token not in text:
            raise SystemExit(f'{label} missing {token}')
if "has_database_privilege(current_user, current_database(), 'CREATE')" not in schema:
    raise SystemExit('01 missing CREATE privilege preflight')
if 'data-script-content-enhancer="off"' not in script_html:
    raise SystemExit('presenter script enhancer was not disabled')

print('Chapter 12 final publication review patch prepared successfully')
