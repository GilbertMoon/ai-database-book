from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path_str: str, old: str, new: str) -> None:
    path = ROOT / path_str
    text = path.read_text(encoding='utf-8')
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path_str}: expected exactly 1 match, found {count}: {old[:80]!r}')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')


def append_once(path_str: str, marker: str, block: str) -> None:
    path = ROOT / path_str
    text = path.read_text(encoding='utf-8')
    if marker in text:
        return
    path.write_text(text.rstrip() + '\n\n' + block.strip() + '\n', encoding='utf-8')

# -----------------------------------------------------------------------------
# book/chapter04/chapter04.md
# -----------------------------------------------------------------------------
replace_once(
    'book/chapter04/chapter04.md',
    'code/chapter04의 SQL 파일을 열 수 있다.',
    'Chapter 04 실습 SQL 파일을 열 수 있다.'
)
replace_once(
    'book/chapter04/chapter04.md',
    '이번 장에서는 처음으로 테이블과 데이터를 직접 변경합니다. 따라서 SQL 문법을 많이 외우는 것보다 다음 순환을 반복하는 습관이 중요합니다.',
    '실습 파일과 실행 순서는 [Chapter 04 실습 코드 안내](../../code/chapter04/README.md)에서 확인할 수 있습니다.\n\n이번 장에서는 처음으로 테이블과 데이터를 직접 변경합니다. 따라서 SQL 문법을 많이 외우는 것보다 다음 순환을 반복하는 습관이 중요합니다.'
)
replace_once(
    'book/chapter04/chapter04.md',
    '현재 스키마는 환경에 따라 `public`이 아닐 수 있습니다. 이 장에서는 대상을 분명히 하기 위해 모든 주요 테이블 이름을 `public.students`처럼 스키마와 함께 작성합니다.',
    '현재 스키마는 환경에 따라 `public`이 아닐 수 있습니다. 이 장에서는 대상을 분명히 하기 위해 모든 주요 테이블 이름을 `public.students`처럼 스키마와 함께 작성합니다. 권장 로컬 경로에서는 Chapter 03의 `setup_validate_local.sql`로 `public` 스키마의 `USAGE`와 `CREATE` 권한까지 확인합니다. `transaction_read_only = off`라는 사실만으로 실제 객체 생성 권한까지 보장되는 것은 아닙니다.'
)
replace_once(
    'book/chapter04/chapter04.md',
    '| `NOT NULL` | 값 생략 금지 |\n| `UNIQUE` | 같은 값의 중복 금지 |\n| `DEFAULT` | 값을 생략했을 때 사용할 기본값 |\n| `IDENTITY` | 값을 생략하면 자동 번호 생성 |\n| `TIMESTAMPTZ` | 시간대를 고려하는 날짜와 시각 타입 |',
    '| `NOT NULL` | 최종 저장값으로 `NULL`을 허용하지 않음 |\n| `UNIQUE` | 같은 비-`NULL` 값의 중복을 제한 |\n| `DEFAULT` | 열 값을 생략했을 때 사용할 기본값 |\n| `IDENTITY` | 값을 생략하면 자동 번호 생성 |\n| `TIMESTAMPTZ` | 절대 시점을 저장하고 세션 `TimeZone`에 맞춰 표시하는 날짜·시각 타입 |'
)
replace_once(
    'book/chapter04/chapter04.md',
    '`major`와 `grade`에는 `NOT NULL`이 없으므로 값을 생략하면 `NULL`이 저장될 수 있습니다.',
    '`major`와 `grade`에는 `NOT NULL`이 없으므로 값을 생략하면 `NULL`이 저장될 수 있습니다. `NOT NULL`은 INSERT 문에서 해당 열 이름을 반드시 적어야 한다는 뜻이 아니라, 최종적으로 저장되는 값이 `NULL`일 수 없다는 뜻입니다. 예를 들어 `created_at`은 `NOT NULL`이지만 `DEFAULT CURRENT_TIMESTAMP`가 있으므로 INSERT에서 열을 생략할 수 있습니다.'
)
replace_once(
    'book/chapter04/chapter04.md',
    '`created_at`을 생략하면 `CURRENT_TIMESTAMP`가 기본값으로 사용됩니다. 같은 문장이나 트랜잭션에서 여러 행을 입력하면 같은 시각 값을 가질 수 있으므로 최신 순서가 필요할 때는 `id` 같은 보조 기준을 함께 사용할 수 있습니다.',
    '`TIMESTAMPTZ`는 시간대가 포함된 입력을 하나의 절대 시점으로 변환해 저장하고, 조회할 때는 현재 세션의 `TimeZone`에 맞춰 표시합니다. 입력할 때 사용한 원래 시간대 이름 자체를 보존하는 타입은 아닙니다.\n\n`created_at`을 생략하면 `CURRENT_TIMESTAMP`가 기본값으로 사용됩니다. PostgreSQL의 `CURRENT_TIMESTAMP`는 현재 트랜잭션의 시작 시각을 사용하므로 같은 트랜잭션에서 입력한 여러 행은 같은 값을 가질 수 있습니다. 이 장의 `02_insert_students.sql`도 여섯 학생을 하나의 명시적 트랜잭션으로 입력하므로 `created_at`이 모두 같을 수 있습니다. 이때 `id`는 결과 순서를 안정적으로 만드는 **동률 해소 기준**으로 사용할 뿐, 실제 생성 시각을 대신하는 업무 시간으로 해석하지 않습니다.'
)
replace_once(
    'book/chapter04/chapter04.md',
    '`LIMIT`을 사용할 때는 먼저 정렬 기준을 명시합니다. 동률이 생길 수 있으면 `id` 같은 보조 기준을 추가합니다.',
    '`LIMIT`을 사용할 때는 먼저 정렬 기준을 명시합니다. 위 예제는 `created_at`이 큰 행부터 정렬하고, 같은 시각이면 `id`로 순서를 고정한 뒤 상위 3행을 가져옵니다. `id`는 여기서 동률 해소용일 뿐 실제 시간의 대체값은 아닙니다.'
)
replace_once(
    'book/chapter04/chapter04.md',
    '**삭제 실습 후 상태**는 학생 5명, 이준호 학년 4, 박서연 삭제입니다.\n\n---\n\n## 15. AI가 만든 SQL 검토하기',
    '**삭제 실습 후 상태**는 학생 5명, 이준호 학년 4, 박서연 삭제입니다.\n\n이 장에서는 SQL `DELETE`의 동작을 배우기 위해 행을 실제로 삭제합니다. 실제 서비스의 “삭제” 기능은 보존 정책과 감사 요구사항에 따라 상태값을 바꾸는 `UPDATE` 등으로 구현할 수도 있습니다. 어떤 삭제 정책을 사용할지는 업무 규칙과 함께 별도로 결정해야 합니다.\n\n---\n\n## 15. AI가 만든 SQL 검토하기'
)
replace_once(
    'book/chapter04/chapter04.md',
    '최신 등록 학생 3명을 안정적인 순서로 조회하기',
    '`created_at` 기준 상위 3행을 동률까지 안정적인 순서로 조회하기'
)
replace_once(
    'book/chapter04/chapter04.md',
    '더 많은 기록 활동과 권장 해설은 `book/chapter04/chapter04_activity.md`에서 확인합니다.',
    '더 많은 기록 활동과 권장 해설은 [Chapter 04 독자 워크북](chapter04_activity.md)에서 확인합니다.'
)

# -----------------------------------------------------------------------------
# workbook
# -----------------------------------------------------------------------------
replace_once(
    'book/chapter04/chapter04_activity.md',
    '다음 중 올바른 조건을 표시합니다.\n\n```sql\nWHERE grade = \'3\'\nWHERE grade = 3\nWHERE major = 컴퓨터공학\nWHERE major = \'컴퓨터공학\'\n```',
    '다음 중 **이 책의 작성 규칙과 열의 타입 의도에 맞는 표현**을 표시합니다. PostgreSQL은 일부 문자열 리터럴을 문맥에 맞게 변환할 수 있지만, 초급 실습에서는 숫자 열에는 숫자 리터럴을, 문자열 열에는 작은따옴표로 감싼 문자열 리터럴을 명확하게 사용합니다.\n\n```sql\nWHERE grade = \'3\'\nWHERE grade = 3\nWHERE major = 컴퓨터공학\nWHERE major = \'컴퓨터공학\'\n```'
)
replace_once(
    'book/chapter04/chapter04_activity.md',
    '2. 값을 반드시 입력해야 하는 열은 무엇인가요?\n3. 중복을 허용하지 않는 열은 무엇인가요?\n4. 값을 생략하면 `NULL`이 될 수 있는 열은 무엇인가요?\n5. 자동으로 값이 결정될 수 있는 열은 무엇인가요?',
    '2. `NULL`로 저장할 수 없는 열은 무엇인가요?\n3. 중복을 허용하지 않는 열은 무엇인가요?\n4. 값을 생략하면 `NULL`이 될 수 있는 열은 무엇인가요?\n5. 값을 생략해도 IDENTITY나 DEFAULT로 자동값이 채워질 수 있는 열은 무엇인가요?\n6. `NOT NULL`인데도 INSERT에서 직접 값을 생략할 수 있는 열은 무엇이며, 그 이유는 무엇인가요?'
)
replace_once(
    'book/chapter04/chapter04_activity.md',
    '최신 등록 학생 3명을 안정적인 순서로 조회합니다.',
    '`created_at` 기준 상위 3행을 동률까지 안정적인 순서로 조회합니다.'
)
replace_once(
    'book/chapter04/chapter04_activity.md',
    '| 같은 문장으로 입력한 행의 `created_at`이 같을 수 있다. |  |  |',
    '| 같은 트랜잭션에서 입력한 여러 행의 `created_at`이 같을 수 있다. |  |  |\n| `id`가 더 크면 항상 실제 생성 시각도 더 늦다고 단정할 수 있다. |  |  |'
)
replace_once(
    'book/chapter04/chapter04_activity.md',
    '- 자동 생성 `id`는 학생 수나 학번이 아니다.\n- AI SQL은 예상 반환 행 또는 영향받는 행 수를 먼저 확인한다.',
    '- `NOT NULL`은 최종 저장값이 `NULL`일 수 없다는 뜻이며, DEFAULT가 있으면 INSERT에서 열을 생략할 수 있다.\n- 자동 생성 `id`는 학생 수·학번·실제 생성 시각의 대체값이 아니다.\n- 같은 트랜잭션에서는 `CURRENT_TIMESTAMP`가 같은 값일 수 있으므로 정렬의 동률 기준을 따로 둔다.\n- AI SQL은 예상 반환 행 또는 영향받는 행 수를 먼저 확인한다.'
)

# -----------------------------------------------------------------------------
# SQL files
# -----------------------------------------------------------------------------
replace_once(
    'code/chapter04/01_create_students.sql',
    "    IF current_setting('transaction_read_only')::boolean THEN\n        RAISE EXCEPTION\n            '생성 중단: 현재 연결이 읽기 전용입니다.';\n    END IF;",
    "    IF NOT has_schema_privilege(current_user, 'public', 'USAGE') THEN\n        RAISE EXCEPTION\n            '생성 중단: 사용자 %에게 public 스키마 USAGE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_schema_privilege(current_user, 'public', 'CREATE') THEN\n        RAISE EXCEPTION\n            '생성 중단: 사용자 %에게 public 스키마 CREATE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF current_setting('transaction_read_only')::boolean THEN\n        RAISE EXCEPTION\n            '생성 중단: 현재 연결이 읽기 전용입니다.';\n    END IF;"
)
replace_once(
    'code/chapter04/02_insert_students.sql',
    '-- 안전성: 세 INSERT를 한 트랜잭션으로 묶어 중간 실패 시 부분 입력을 남기지 않습니다.',
    '-- 안전성: 세 INSERT를 한 트랜잭션으로 묶어 중간 실패 시 부분 입력을 남기지 않습니다.\n-- 시간 주의: CURRENT_TIMESTAMP는 트랜잭션 시작 시각이므로 이 파일에서 입력한 6명의 created_at은 같을 수 있습니다.'
)
replace_once(
    'code/chapter04/02_insert_students.sql',
    "    IF to_regclass('public.students') IS NULL THEN\n        RAISE EXCEPTION\n            '입력 중단: public.students가 없습니다. 01_create_students.sql을 먼저 실행하세요.';\n    END IF;\n\n    SELECT COUNT(*) INTO v_count",
    "    IF to_regclass('public.students') IS NULL THEN\n        RAISE EXCEPTION\n            '입력 중단: public.students가 없습니다. 01_create_students.sql을 먼저 실행하세요.';\n    END IF;\n\n    IF NOT has_table_privilege(current_user, 'public.students', 'SELECT') THEN\n        RAISE EXCEPTION\n            '입력 중단: 사용자 %에게 public.students SELECT 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_table_privilege(current_user, 'public.students', 'INSERT') THEN\n        RAISE EXCEPTION\n            '입력 중단: 사용자 %에게 public.students INSERT 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    SELECT COUNT(*) INTO v_count"
)
replace_once(
    'code/chapter04/03_select_students.sql',
    "SELECT id, name\nFROM public.students\nWHERE name LIKE '%민%'\nORDER BY id ASC;\n\nSELECT id, name\nFROM public.students\nWHERE name LIKE '김__'",
    "SELECT id, name\nFROM public.students\nWHERE name LIKE '%민%'\nORDER BY id ASC;\n\nSELECT id, name\nFROM public.students\nWHERE name LIKE '%우'\nORDER BY id ASC;\n\nSELECT id, name\nFROM public.students\nWHERE name LIKE '김__'"
)
replace_once(
    'code/chapter04/04_update_delete_students.sql',
    "    IF to_regclass('public.students') IS NULL THEN\n        RAISE EXCEPTION\n            '변경 중단: public.students가 없습니다.';\n    END IF;\n\n    SELECT COUNT(*) INTO v_count",
    "    IF to_regclass('public.students') IS NULL THEN\n        RAISE EXCEPTION\n            '변경 중단: public.students가 없습니다.';\n    END IF;\n\n    IF NOT has_table_privilege(current_user, 'public.students', 'SELECT') THEN\n        RAISE EXCEPTION\n            '변경 중단: 사용자 %에게 public.students SELECT 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_table_privilege(current_user, 'public.students', 'UPDATE') THEN\n        RAISE EXCEPTION\n            '변경 중단: 사용자 %에게 public.students UPDATE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_table_privilege(current_user, 'public.students', 'DELETE') THEN\n        RAISE EXCEPTION\n            '변경 중단: 사용자 %에게 public.students DELETE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    SELECT COUNT(*) INTO v_count"
)
replace_once(
    'code/chapter04/verify_students.sql',
    "DO $$\nBEGIN\n    IF to_regclass('public.students') IS NULL THEN",
    "DO $$\nBEGIN\n    IF current_database() <> 'ai_database_book' THEN\n        RAISE EXCEPTION\n            '상태 확인 중단: 현재 데이터베이스는 %입니다. ai_database_book 연결을 선택하세요.',\n            current_database();\n    END IF;\n\n    IF to_regclass('public.students') IS NULL THEN"
)
replace_once(
    'code/chapter04/basic_crud.sql',
    '-- 이 파일은 기존 링크와 사용자를 위한 통합 참고 자료입니다.\n-- 파일 전체를 한꺼번에 실행하지 말고 필요한 구간만 선택합니다.',
    '-- 이 파일은 기존 링크와 사용자를 위한 통합 참고 자료입니다.\n-- 번호 SQL 파일에 있는 시작 상태·권한 검사는 가독성을 위해 일부 생략되어 있습니다.\n-- 파일 전체를 한꺼번에 실행하지 말고 필요한 구간만 선택합니다.'
)

# -----------------------------------------------------------------------------
# code README
# -----------------------------------------------------------------------------
replace_once(
    'code/chapter04/README.md',
    'id\n→ 내부 식별자이며 학생 수나 학번이 아님\n\nmajor, grade\n→ 값을 생략하면 NULL 가능\n\ncreated_at\n→ 값을 생략하면 기본 시각 값 저장',
    'id\n→ 내부 식별자이며 학생 수·학번·실제 생성 시각의 대체값이 아님\n\nmajor, grade\n→ 값을 생략하면 NULL 가능\n\ncreated_at\n→ 값을 생략하면 CURRENT_TIMESTAMP 사용\n→ 같은 트랜잭션의 여러 행은 같은 시각일 수 있음'
)
replace_once(
    'code/chapter04/README.md',
    '현재 데이터베이스 = ai_database_book\npublic 스키마 존재\n읽기 전용 연결이 아님\npublic.students 존재\n현재 행 수 = 0',
    '현재 데이터베이스 = ai_database_book\npublic 스키마 존재\n읽기 전용 연결이 아님\npublic.students 존재\npublic.students SELECT·INSERT 권한\n현재 행 수 = 0'
)
replace_once(
    'code/chapter04/README.md',
    '`04_update_delete_students.sql`은 현재 데이터베이스와 쓰기 가능 상태, 초기 데이터 상태를 먼저 확인합니다.',
    '`04_update_delete_students.sql`은 현재 데이터베이스와 읽기 전용 상태, `public.students`의 SELECT·UPDATE·DELETE 권한, 초기 데이터 상태를 먼저 확인합니다.'
)
replace_once(
    'code/chapter04/README.md',
    '`basic_crud.sql`은 기본 실습 파일이 아니라 통합 참고 파일로 표시합니다.',
    '`basic_crud.sql`은 기본 실습 파일이 아니라 통합 참고 파일로 표시합니다. 번호 파일의 시작 상태·권한 보호 로직을 일부 생략하므로 초보자는 번호 파일을 우선 사용합니다.'
)
append_once(
    'code/chapter04/README.md',
    '## 생성 파일 권한 확인',
    '''## 생성 파일 권한 확인

`01_create_students.sql`은 `public.students`를 만들기 전에 다음을 확인합니다.

```text
현재 데이터베이스 = ai_database_book
public 스키마 존재
public USAGE 권한
public CREATE 권한
읽기 전용 연결이 아님
```

`transaction_read_only = off`만으로 객체 생성 권한이 보장되는 것은 아니므로 스키마 권한을 별도로 확인합니다.'''
)

# -----------------------------------------------------------------------------
# outline
# -----------------------------------------------------------------------------
replace_once(
    'book/chapter04/chapter04_outline.md',
    '- `CURRENT_TIMESTAMP`와 트랜잭션 시각\n- `NULL`의 3값 논리',
    '- `TIMESTAMPTZ` 저장·표시 의미와 `CURRENT_TIMESTAMP`의 트랜잭션 시각\n- `id`를 시간 대체값으로 사용하지 않는 동률 정렬 원칙\n- `NULL`의 3값 논리'
)
replace_once(
    'book/chapter04/chapter04_outline.md',
    '- 주요 테이블은 `public.students`처럼 스키마를 명시한다.\n- SQL 기본 작성 규칙을 한 절에 모아 설명한다.',
    '- 주요 테이블은 `public.students`처럼 스키마를 명시한다.\n- Chapter 03의 권장 로컬 경로와 맞춰 `public`의 `USAGE`·`CREATE` 권한을 생성 전 확인한다.\n- `NOT NULL`은 “열 생략 금지”가 아니라 최종 저장값의 `NULL` 금지로 설명한다.\n- SQL 기본 작성 규칙을 한 절에 모아 설명한다.'
)
replace_once(
    'book/chapter04/chapter04_outline.md',
    '- `LIMIT`에는 안정적인 정렬 기준을 함께 사용한다.',
    '- `LIMIT`에는 안정적인 정렬 기준을 함께 사용한다. `id`는 동률 해소용이며 실제 시간의 대체값으로 설명하지 않는다.'
)
replace_once(
    'book/chapter04/chapter04_outline.md',
    '| 정규화와 이메일 업무 규칙 | Chapter 06 |',
    '| 정규화, 이메일 업무 규칙과 삭제 정책 | Chapter 06 |'
)

# -----------------------------------------------------------------------------
# review revision + checklist
# -----------------------------------------------------------------------------
append_once(
    'book/chapter04/chapter04_review_revision.md',
    '## 최종 출판 정확성 보완',
    '''## 최종 출판 정확성 보완

최종 PDF 제작 전 기술 정확성과 Chapter 03·04 코드 일치를 다시 점검해 다음 내용을 보완했습니다.

```text
NOT NULL = 열 생략 금지라는 오해 제거
TIMESTAMPTZ의 절대 시점 저장·세션 TimeZone 표시 의미 보완
CURRENT_TIMESTAMP = 트랜잭션 시작 시각으로 명확화
02_insert_students.sql의 6행이 같은 created_at을 가질 수 있음을 명시
id는 최신 시각의 대체값이 아니라 동률 해소 기준으로 제한
public USAGE·CREATE 권한을 01_create_students.sql에서 재확인
02 입력 전 SELECT·INSERT 권한 확인
04 변경 전 SELECT·UPDATE·DELETE 권한 확인
LIKE 표의 %우 예제를 03_select_students.sql에도 추가
verify_students.sql에서 ai_database_book 연결을 재확인
실제 서비스의 삭제 정책과 SQL DELETE 실습을 구분
워크북의 grade = '3'을 “문법 오류”가 아니라 권장 타입 표현 관점으로 정리
```

`basic_crud.sql`은 보호 로직이 일부 생략된 통합 참고 파일임을 더 분명하게 표시하고, 초보자의 기본 경로는 계속 번호 SQL 파일로 유지합니다.'''
)
replace_once(
    'notes/chapter04_review_checklist.md',
    '| 제약조건 | 완료 | PK, NOT NULL, UNIQUE, DEFAULT |',
    '| 제약조건 | 완료 | PK, NOT NULL, UNIQUE, DEFAULT |\n| `NOT NULL` 의미 | 완료 | 열 생략 금지가 아니라 최종 `NULL` 저장 금지로 정정 |'
)
replace_once(
    'notes/chapter04_review_checklist.md',
    '| `CURRENT_TIMESTAMP` | 완료 | 기본 등록 시각 |\n| 트랜잭션 시각 | 완료 | 심화 설명 |\n| 최신 정렬 | 완료 | `created_at`, `id` 보조 기준 |',
    '| `TIMESTAMPTZ` | 완료 | 절대 시점 저장·세션 `TimeZone` 기준 표시 |\n| `CURRENT_TIMESTAMP` | 완료 | 트랜잭션 시작 시각 |\n| 트랜잭션 시각 | 완료 | `02_insert_students.sql`의 여러 행이 같은 시각일 수 있음 |\n| 정렬 동률 | 완료 | `id`는 동률 해소용이며 실제 시간 대체값이 아님 |'
)
replace_once(
    'notes/chapter04_review_checklist.md',
    '| public 스키마 존재 | 코드 반영 |\n| 읽기 전용 연결 차단 | 코드 반영 |',
    '| public 스키마 존재 | 코드 반영 |\n| public USAGE 권한 | 코드 반영 |\n| public CREATE 권한 | 코드 반영 |\n| 읽기 전용 연결 차단 | 코드 반영 |'
)
replace_once(
    'notes/chapter04_review_checklist.md',
    '| students 존재 검사 | 코드 반영 |\n| 시작 행 수 0 검사 | 코드 반영 |',
    '| students 존재 검사 | 코드 반영 |\n| SELECT·INSERT 권한 | 코드 반영 |\n| 시작 행 수 0 검사 | 코드 반영 |'
)
replace_once(
    'notes/chapter04_review_checklist.md',
    '| 초기 박서연 | 코드 반영 | 1행 |\n| 변경 전 SELECT | 완료 | 동일 WHERE로 대상 확인 |',
    '| 초기 박서연 | 코드 반영 | 1행 |\n| SELECT·UPDATE·DELETE 권한 | 코드 반영 | 실제 변경 전에 명시적으로 확인 |\n| 변경 전 SELECT | 완료 | 동일 WHERE로 대상 확인 |'
)

# -----------------------------------------------------------------------------
# Static checks + regenerate manuscript
# -----------------------------------------------------------------------------
checks = {
    'book/chapter04/chapter04.md': [
        '최종 저장값으로 `NULL`을 허용하지 않음',
        '현재 트랜잭션의 시작 시각',
        '동률 해소 기준',
        '[Chapter 04 독자 워크북](chapter04_activity.md)',
    ],
    'code/chapter04/01_create_students.sql': ["has_schema_privilege(current_user, 'public', 'CREATE')"],
    'code/chapter04/02_insert_students.sql': ["has_table_privilege(current_user, 'public.students', 'INSERT')", 'created_at은 같을 수 있습니다'],
    'code/chapter04/03_select_students.sql': ["WHERE name LIKE '%우'"],
    'code/chapter04/04_update_delete_students.sql': ["has_table_privilege(current_user, 'public.students', 'DELETE')"],
    'code/chapter04/verify_students.sql': ["current_database() <> 'ai_database_book'"],
}
for file_name, required in checks.items():
    text = (ROOT / file_name).read_text(encoding='utf-8')
    for needle in required:
        if needle not in text:
            raise RuntimeError(f'{file_name}: missing required text: {needle}')

subprocess.run(['python', '-m', 'py_compile', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)
subprocess.run(['python', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)

manuscript = (ROOT / 'publish/full_manuscript.md').read_text(encoding='utf-8')
for needle in [
    '최종 저장값으로 `NULL`을 허용하지 않음',
    '현재 트랜잭션의 시작 시각',
    'Chapter 04 독자 워크북',
]:
    if needle not in manuscript:
        raise RuntimeError(f'full_manuscript.md missing Chapter 04 update: {needle}')

print('Chapter 04 final publication review applied successfully.')
