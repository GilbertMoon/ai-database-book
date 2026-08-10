from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def read(path):
    return (ROOT / path).read_text(encoding='utf-8')

def write(path, text):
    (ROOT / path).write_text(text, encoding='utf-8')

def replace_exact(path, old, new, count=1):
    text = read(path)
    actual = text.count(old)
    if actual < count:
        raise RuntimeError(f'{path}: expected at least {count} occurrence(s), found {actual}: {old[:100]!r}')
    write(path, text.replace(old, new, count))

# ------------------------------------------------------------------
# Main manuscript
# ------------------------------------------------------------------
p = 'book/chapter06/chapter06.md'
replace_exact(p,
    'Chapter 05에서는 요구사항을 바탕으로 `members`, `books`, `loans` 구조를 설계하고, 이메일·ISBN 고유성, 날짜 순서와 동시 활성 대여 같은 정책을 미확정 질문으로 남겼습니다. 이번 장에서는 서로 다른 사실이 한 테이블에 섞일 때 생기는 문제를 분석하고, 필요한 정책을 확정한 뒤 PostgreSQL 제약조건으로 구현합니다.',
    'Chapter 05에서는 요구사항을 바탕으로 `members`, `books`, `loans` 구조를 설계하고, 이메일·ISBN 고유성, ISBN의 필수 여부, 날짜 순서와 동시 활성 대여 같은 정책을 미확정 질문으로 남겼습니다. 이번 장에서는 서로 다른 사실이 한 테이블에 섞일 때 생기는 문제를 분석하고, 필요한 정책을 확정한 뒤 PostgreSQL 제약조건으로 구현합니다.')
replace_exact(p,
    'books_nf 한 행\n→ 대여 대상으로 관리하는 도서 한 건',
    'books_nf 한 행\n→ 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건')
replace_exact(p,
    '제1정규형은 한 열의 값이 그 열에서 정의한 하나의 도메인 값으로 취급되도록 구성하는 단계입니다. 검색·연결·수정해야 할 독립 값들을 쉼표 문자열이나 반복 열에 함께 넣지 않습니다.',
    '제1정규형은 각 속성이 정의된 도메인의 값을 갖고 반복 그룹이 없도록 관계를 구성하는 기준입니다. 이 책에서는 입문 단계의 판단 질문으로, 개별적으로 검색·연결·수정해야 할 반복값을 쉼표 목록이나 `book1`, `book2` 같은 반복 열에 묶어 두지 않는지 확인합니다.')
replace_exact(p,
    '제2정규형은 복합 후보키가 있을 때 일반 열이 키 전체가 아니라 일부에만 의존하는지 확인합니다.',
    '제2정규형은 제1정규형을 만족한 관계에서 비키 속성이 후보키 전체가 아니라 그 일부에만 의존하는 부분 종속이 있는지 확인합니다. 입문 단계에서는 복합 후보키가 있는 테이블을 중심으로 살펴보면 이해하기 쉽습니다.')
replace_exact(p,
    '단일 열 후보키만 있는 테이블에서는 부분 종속이 발생하지 않습니다. 재수강·학기·분반을 관리한다면 `term_id`, `section_id` 같은 식별 요소를 추가로 검토해야 합니다.',
    '모든 후보키가 단일 열이라면 후보키의 일부라는 개념이 없으므로 부분 종속은 발생하지 않습니다. 재수강·학기·분반을 관리한다면 `term_id`, `section_id` 같은 식별 요소를 추가로 검토해야 합니다.')
replace_exact(p,
    '제3정규형은 기본키가 아닌 열이 다른 일반 열을 결정하는 업무 규칙이 있는지 확인합니다.',
    '제3정규형은 제2정규형을 만족한 관계에서 비키 속성이 다른 비키 속성을 통해 후보키에 전이적으로 의존하는 구조가 있는지 확인합니다. 이 책에서는 대표적인 전이 종속 패턴을 중심으로 살펴봅니다.')
replace_exact(p,
    '`joined_at`, `published_year`, `isbn`은 원시 테이블을 나누는 과정에서 자동으로 생긴 값이 아닙니다. Chapter 05의 전체 요구사항에서 가져온 속성입니다. 정규화는 존재하지 않던 업무 데이터를 만들어 내는 작업이 아닙니다.',
    '`joined_at`, `published_year`, `isbn`은 원시 테이블을 나누는 과정에서 자동으로 생긴 값이 아닙니다. Chapter 05의 전체 요구사항에서 가져온 속성입니다. 정규화는 존재하지 않던 업무 데이터를 만들어 내는 작업이 아닙니다. 또한 위 구조는 개념을 설명하기 위한 정규화 결과입니다. 실제 원시 데이터를 새 테이블로 이전하려면 회원·도서를 식별할 원천 키나 매핑 규칙, 중복 처리 기준과 데이터 검증 절차가 별도로 필요합니다.')
replace_exact(p,
    'Chapter 05에서 남긴 질문 가운데 이번 실습에 필요한 정책을 다음처럼 확정합니다.\n\n| ID | 확정 규칙 | 구현 후보 |',
    'Chapter 05에서 남긴 질문 가운데 이번 실습에 필요한 정책을 다음처럼 확정합니다. Chapter 05에서 이미 필수로 사용한 회원 이름·이메일·가입일, 도서 제목·저자, 대여의 회원·도서·대여일·반납예정일도 정규화 후 테이블에 다시 적용합니다. `01_normalization_schema.sql`에서는 제약조건 추가 과정을 보여 주기 위해 이 규칙들을 잠시 생략하고, `04_add_integrity_rules.sql`에서 기존 데이터 검사 후 복원합니다.\n\n| ID | 확정 규칙 | 구현 후보 |')
replace_exact(p,
    '| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |',
    '| C-02 | ISBN은 필수이며 같은 ISBN 문자열 중복 금지 | `NOT NULL` + `UNIQUE (isbn)` |')
replace_exact(p,
    '동일 ISBN의 여러 복본은 별도 모델로 분리하지 않는다.',
    '동일 ISBN의 여러 실물 복본은 별도 모델로 분리하지 않는다. 따라서 이번 실습에서는 ISBN을 도서 항목의 필수 고유값으로 확정한다.')
replace_exact(p,
    '필수값을 생략하지 못하게 합니다.\n\n```sql\nname VARCHAR(50) NOT NULL\n```\n\n`NOT NULL`은 빈 문자열이나 공백 문자열까지 막지는 않습니다.',
    '열의 최종 저장값으로 `NULL`을 허용하지 않습니다.\n\n```sql\nname VARCHAR(50) NOT NULL\n```\n\n`INSERT`에서 열을 생략했더라도 `DEFAULT`가 있으면 기본값이 채워질 수 있습니다. 기본값도 없어서 최종 값이 `NULL`이 되면 `NOT NULL` 위반입니다. `NOT NULL`은 빈 문자열이나 공백 문자열까지 막지는 않습니다.')
replace_exact(p,
    'PostgreSQL의 일반적인 `UNIQUE`에서는 `NULL`을 서로 같은 값으로 보지 않으므로, NULL을 허용하는 열에는 여러 NULL이 존재할 수 있습니다. 이번 실습의 이메일과 ISBN은 `NOT NULL`과 `UNIQUE`를 함께 적용합니다.',
    'PostgreSQL의 기본 `UNIQUE` 동작에서는 `NULL`을 서로 같은 값으로 보지 않으므로, NULL을 허용하는 열에는 여러 NULL이 존재할 수 있습니다. 필요하면 `NULLS NOT DISTINCT`를 사용해 NULL도 같은 값처럼 취급할 수 있습니다. 이번 실습의 이메일과 ISBN은 `NOT NULL`과 `UNIQUE`를 함께 적용하므로 이 차이가 실제 저장 결과에 영향을 주지는 않습니다.')
replace_exact(p,
    '`CHECK` 식이 `FALSE`이면 저장이 거부됩니다. 식의 결과가 `UNKNOWN`이면 통과할 수 있으므로 필수값까지 보장하려면 `NOT NULL`이 별도로 필요합니다.',
    '`CHECK` 식이 `FALSE`이면 저장이 거부됩니다. PostgreSQL에서는 식의 결과가 `TRUE`이거나 `NULL`이면 제약조건을 만족한 것으로 처리하므로, 필수값까지 보장하려면 `NOT NULL`이 별도로 필요합니다.')
replace_exact(p,
    '> - `RESTRICT`·`NO ACTION`: 참조 중인 부모 삭제를 차단\n> - `CASCADE`: 부모 삭제 시 자식도 함께 삭제\n> - `SET NULL`: 자식의 외래키를 NULL로 변경',
    '> - `RESTRICT`: 참조 중인 부모 삭제를 즉시 차단하며 검사를 지연할 수 없음\n> - `NO ACTION`: 기본 동작이며, 일반적인 즉시 검사에서는 참조 중인 부모 삭제를 차단함. 지연 가능한 외래키라면 트랜잭션 뒤로 검사를 미룰 수 있음\n> - `CASCADE`: 부모 삭제 시 자식도 함께 삭제\n> - `SET NULL`: 자식의 외래키를 NULL로 변경')
replace_exact(p,
    '이번 장의 번호형 실습 파일은 다음 흐름을 사용합니다.\n\n```text\n01_normalization_schema.sql\n→ 기본 테이블 생성\n\n02_normalization_seed.sql\n→ 정상 샘플 입력\n\n03_normalization_compare.sql\n→ 정규화 전후 비교\n\n04_add_integrity_rules.sql\n→ 기존 데이터 검사 후 ALTER TABLE과 인덱스로 규칙 추가\n\n05_integrity_tests.sql\n→ 정상·경계·오류 테스트\n```',
    '이번 장의 번호형 실습 파일은 다음 흐름을 사용합니다.\n\n- [`01_normalization_schema.sql`](../../code/chapter06/01_normalization_schema.sql): 기본 테이블 생성\n- [`02_normalization_seed.sql`](../../code/chapter06/02_normalization_seed.sql): 정상 샘플 입력\n- [`03_normalization_compare.sql`](../../code/chapter06/03_normalization_compare.sql): 정규화 전후 비교\n- [`04_add_integrity_rules.sql`](../../code/chapter06/04_add_integrity_rules.sql): 기존 데이터 검사 후 `ALTER TABLE`과 인덱스로 규칙 추가\n- [`05_integrity_tests.sql`](../../code/chapter06/05_integrity_tests.sql): 정상·경계·오류 테스트')
replace_exact(p,
    '`CHECK`는 보통 현재 행의 값 관계를 검사합니다. 같은 도서의 미반납 대여가 이미 있는지처럼 여러 행을 비교하는 규칙에는 다른 수단이 필요합니다.',
    'PostgreSQL의 `CHECK`는 현재 행의 값으로 판단하는 규칙에 사용하며, 다른 행이나 다른 테이블의 현재 데이터를 참조하는 교차 행 규칙을 보장하는 용도로 사용하지 않습니다. 같은 도서의 미반납 대여가 이미 있는지처럼 여러 행을 비교하는 규칙에는 `UNIQUE`, 부분 고유 인덱스, 제외 제약조건 같은 다른 수단을 검토합니다.')
replace_exact(p,
    '이 규칙은 현재 미반납 상태의 중복만 막습니다. 과거 대여 기간 전체의 중첩까지 검사하지는 않습니다.',
    '이 규칙은 현재 미반납 상태의 중복만 막습니다. 과거 대여 기간 전체의 중첩까지 검사하지는 않습니다. 또한 이것은 `UNIQUE` 제약조건이 아니라 조건을 만족하는 행에만 적용되는 **고유 인덱스 객체**이므로 메타데이터와 오류 메시지에서도 인덱스 이름으로 확인합니다.')
replace_exact(p,
    '| 중복 이메일·ISBN | `UNIQUE` 오류 |',
    '| ISBN `NULL` | `NOT NULL` 오류 |\n| 중복 이메일·ISBN | `UNIQUE` 오류 |')
replace_exact(p,
    '정규화는 테이블 수를 최대한 늘리는 작업이 아닙니다. 서로 다른 사실과 수명, 반복 관계나 보안·보존 경계가 있을 때 분리해야 합니다.\n\n---\n\n## 18. 핵심 정리와 다음 장',
    '정규화는 테이블 수를 최대한 늘리는 작업이 아닙니다. 서로 다른 사실과 수명, 반복 관계나 보안·보존 경계가 있을 때 분리해야 합니다.\n\n[Chapter 06 독자 워크북](chapter06_activity.md)에서 정규형 판단과 제약조건 검증 결과를 직접 기록할 수 있습니다.\n\n---\n\n## 18. 핵심 정리와 다음 장')
replace_exact(p,
    '1NF·2NF·3NF는 각각 다중값, 부분 종속, 일반 열 간 종속을 점검한다.',
    '1NF·2NF·3NF는 각각 반복 그룹과 독립값 표현, 후보키 일부에 대한 부분 종속, 비키 속성을 거치는 전이 종속을 점검한다.')

# ------------------------------------------------------------------
# Outline
# ------------------------------------------------------------------
p = 'book/chapter06/chapter06_outline.md'
replace_exact(p, '| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |', '| C-02 | ISBN은 필수이며 같은 ISBN 문자열 중복 금지 | `NOT NULL` + `UNIQUE (isbn)` |')
replace_exact(p, '| `books_nf` | 대여 대상으로 관리하는 도서 한 건 |', '| `books_nf` | 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건 |')
replace_exact(p,
    '1NF\n→ 검색·연결·수정할 독립 값을 쉼표 문자열이나 반복 열로 저장하지 않음\n\n2NF\n→ 복합 후보키 일부에만 의존하는 일반 열을 분리\n\n3NF\n→ 일반 열이 다른 일반 열을 결정하는 업무 규칙 확인',
    '1NF\n→ 각 속성의 도메인과 반복 그룹을 확인하고, 독립적으로 다룰 반복값을 쉼표 목록·반복 열에 묶지 않음\n\n2NF\n→ 비키 속성이 후보키 일부에만 의존하는 부분 종속을 분리\n\n3NF\n→ 비키 속성이 다른 비키 속성을 통해 후보키에 전이적으로 의존하는지 확인')
replace_exact(p,
    '- `NOT NULL`은 값 생략을 막는다.\n- `CHECK`가 `UNKNOWN`이면 통과할 수 있으므로 필수값에는 `NOT NULL`이 별도로 필요하다.\n- 일반적인 PostgreSQL `UNIQUE`는 여러 NULL을 허용할 수 있다.',
    '- `NOT NULL`은 열의 최종 저장값이 `NULL`이 되는 것을 막는다. 열을 생략해도 `DEFAULT`가 있으면 저장될 수 있다.\n- PostgreSQL `CHECK`는 결과가 `TRUE` 또는 `NULL`이면 통과하므로 필수값에는 `NOT NULL`이 별도로 필요하다.\n- PostgreSQL의 기본 `UNIQUE`는 여러 `NULL`을 허용하며, 필요하면 `NULLS NOT DISTINCT`를 검토할 수 있다.')

# ------------------------------------------------------------------
# Workbook
# ------------------------------------------------------------------
p = 'book/chapter06/chapter06_activity.md'
replace_exact(p,
    '단일 열 후보키에서는 부분 종속이 발생하지 않는 이유:',
    '모든 후보키가 단일 열이면 부분 종속이 발생하지 않는 이유:')
replace_exact(p, '| C-02 | ISBN 중복 금지 |  |  |  |', '| C-02 | ISBN 필수·중복 금지 |  |  |  |')
replace_exact(p,
    '기존 위반 데이터가 존재하면 `ADD CONSTRAINT`가 실패하는 이유를 설명합니다.',
    '기존 위반 데이터가 존재하면 `ADD CONSTRAINT` 또는 `SET NOT NULL`이 실패하는 이유를 설명합니다.\n\nChapter 05에서는 `isbn`의 필수 여부가 미확정이어서 `NULL`을 허용했습니다. Chapter 06에서 ISBN을 필수값으로 확정했다면, `SET NOT NULL` 전에 기존 `NULL` ISBN을 먼저 찾아야 하는 이유를 적으세요.\n\n```text\n________________________________________________________________________\n```')
replace_exact(p,
    'CHECK의 결과가 UNKNOWN일 때:\n일반 UNIQUE 열에서 여러 NULL이 존재할 수 있는 이유:',
    'CHECK의 결과가 NULL일 때 PostgreSQL이 처리하는 방식:\n기본 UNIQUE 열에서 여러 NULL이 존재할 수 있는 이유:\nNOT NULL 열을 INSERT에서 생략해도 DEFAULT가 있으면 저장될 수 있는 이유:')

# ------------------------------------------------------------------
# SQL schema permissions: numbered + compatibility
# ------------------------------------------------------------------
for p in ['code/chapter06/01_normalization_schema.sql', 'code/chapter06/normalization_schema.sql']:
    replace_exact(p,
        "    IF to_regnamespace('public') IS NULL THEN\n        RAISE EXCEPTION '생성 중단: public 스키마가 존재하지 않습니다.';\n    END IF;",
        "    IF to_regnamespace('public') IS NULL THEN\n        RAISE EXCEPTION '생성 중단: public 스키마가 존재하지 않습니다.';\n    END IF;\n\n    IF NOT has_schema_privilege(current_user, 'public', 'USAGE') THEN\n        RAISE EXCEPTION\n            '생성 중단: 사용자 %에게 public 스키마 USAGE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_schema_privilege(current_user, 'public', 'CREATE') THEN\n        RAISE EXCEPTION\n            '생성 중단: 사용자 %에게 public 스키마 CREATE 권한이 없습니다.',\n            current_user;\n    END IF;")

# ------------------------------------------------------------------
# Integrity rules SQL
# ------------------------------------------------------------------
p = 'code/chapter06/04_add_integrity_rules.sql'
replace_exact(p,
    '-- C-02·C-03: 도서 필수값·ISBN 고유성·공백 제목 금지',
    '-- Chapter 05 기존 필수값 + C-02·C-03: 도서 제목·저자 필수, ISBN 필수·고유, 공백 제목 금지')

# ------------------------------------------------------------------
# Integrity tests: numbered + compatibility
# ------------------------------------------------------------------
for p in ['code/chapter06/05_integrity_tests.sql', 'code/chapter06/integrity_tests.sql']:
    replace_exact(p,
        'DO $$\nDECLARE\n    v_constraint_count bigint;\nBEGIN',
        'DO $$\nDECLARE\n    v_constraint_count bigint;\n    v_not_null_count bigint;\nBEGIN',
        count=1)
    replace_exact(p,
        "    IF v_constraint_count <> 8\n       OR to_regclass('public.uq_loans_nf_active_book') IS NULL THEN\n        RAISE EXCEPTION\n            '테스트 중단: 04_add_integrity_rules.sql 적용 상태가 아닙니다. constraints=%, active_index=%',\n            v_constraint_count,\n            to_regclass('public.uq_loans_nf_active_book');\n    END IF;",
        "    SELECT COUNT(*) INTO v_not_null_count\n    FROM pg_attribute\n    WHERE (attrelid = 'public.members_nf'::regclass\n           AND attname IN ('name', 'email', 'joined_at') AND attnotnull)\n       OR (attrelid = 'public.books_nf'::regclass\n           AND attname IN ('title', 'author', 'isbn') AND attnotnull)\n       OR (attrelid = 'public.loans_nf'::regclass\n           AND attname IN ('member_id', 'book_id', 'borrowed_at', 'due_at') AND attnotnull);\n\n    IF v_constraint_count <> 8\n       OR v_not_null_count <> 10\n       OR to_regclass('public.uq_loans_nf_active_book') IS NULL THEN\n        RAISE EXCEPTION\n            '테스트 중단: 04_add_integrity_rules.sql 적용 상태가 아닙니다. constraints=%, not_null_columns=%, active_index=%',\n            v_constraint_count,\n            v_not_null_count,\n            to_regclass('public.uq_loans_nf_active_book');\n    END IF;")
    replace_exact(p,
        '-- 오류 테스트 3: C-02 ISBN UNIQUE 위반\n-- 기대 제약조건: uq_books_nf_isbn\n-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)\n-- VALUES (1903, \'중복 ISBN 도서\', \'테스트 저자\', 2026, \'ISBN-001\');',
        '-- 오류 테스트 3A: C-02 ISBN NOT NULL 위반\n-- 기대: null value in column "isbn" ... violates not-null constraint\n-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)\n-- VALUES (1912, \'ISBN 없음 도서\', \'테스트 저자\', 2026, NULL);\n\n-- 오류 테스트 3B: C-02 ISBN UNIQUE 위반\n-- 기대 제약조건: uq_books_nf_isbn\n-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)\n-- VALUES (1903, \'중복 ISBN 도서\', \'테스트 저자\', 2026, \'ISBN-001\');')

# ------------------------------------------------------------------
# Code README
# ------------------------------------------------------------------
p = 'code/chapter06/README.md'
replace_exact(p, '| `books_nf` | 이 장에서 대여 대상으로 관리하는 도서 한 건 |', '| `books_nf` | 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건 |')
replace_exact(p,
    '8. 오류 후 기준 데이터가 유지되는지 확인한다.\n```',
    '8. 오류 후 기준 데이터가 유지되는지 확인한다.\n9. 01에서 테이블을 생성한 사용자와 같은 PostgreSQL 역할로 02~05를 실행한다.\n```')
replace_exact(p, '| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |', '| C-02 | ISBN 필수·같은 문자열 중복 금지 | `NOT NULL` + `UNIQUE (isbn)` |')
replace_exact(p,
    '현재 DB·쓰기 가능 여부 확인\n→ 정확한 대상 테이블의 기존 규칙 존재 여부 확인',
    '현재 DB·쓰기 가능 여부 확인\n→ Chapter 05에서 확정된 필수값과 Chapter 06의 새 정책을 기존 데이터에서 검사\n→ 정확한 대상 테이블의 기존 규칙 존재 여부 확인')
replace_exact(p,
    'NOT NULL 위반\n이메일·ISBN UNIQUE 위반',
    'NOT NULL 위반\nISBN NULL 위반\n이메일·ISBN UNIQUE 위반')

# ------------------------------------------------------------------
# Review record: update current definitions, then append publication review note
# ------------------------------------------------------------------
p = 'book/chapter06/chapter06_review_revision.md'
text = read(p)
text = text.replace('books_nf 한 행\n= 이 장에서 대여 대상으로 관리하는 도서 한 건', 'books_nf 한 행\n= 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건')
text = text.replace('| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |', '| C-02 | ISBN 필수·같은 ISBN 문자열 중복 금지 | `NOT NULL` + `UNIQUE (isbn)` |')
text = text.replace('단일 열 후보키만 있는 경우 부분 종속은 발생하지 않는다.', '모든 후보키가 단일 열인 경우 부분 종속은 발생하지 않는다.')
append = '''\n\n---\n\n## 최종 출판 검수 추가 반영 (2026-08-10)\n\n- Chapter 05에서 `isbn`의 필수 여부를 미확정으로 둔 흐름과 연결해 C-02를 **ISBN 필수 + 동일 문자열 중복 금지**로 명확히 했다.\n- `NOT NULL`을 “값 생략 금지”가 아니라 최종 저장값의 `NULL` 금지로 바로잡고 `DEFAULT`와의 관계를 보완했다.\n- PostgreSQL 기본 `UNIQUE`의 NULL 처리와 `NULLS NOT DISTINCT` 선택지를 구분했다.\n- 1NF·2NF·3NF 설명을 반복 그룹·부분 종속·전이 종속 기준으로 정밀화했다.\n- `CHECK`는 교차 행 검증 용도로 사용하지 않는다는 PostgreSQL 기준을 명시하고, C-08 부분 고유 인덱스를 별도 인덱스 객체로 설명했다.\n- `RESTRICT`와 `NO ACTION`의 지연 가능성 차이를 보완했다.\n- 01 생성 SQL에 `public`의 `USAGE`·`CREATE` 권한 검사를 추가했다.\n- 05 테스트에 C-02 ISBN `NOT NULL` 실패 사례와 NOT NULL 10열 시작 상태 검증을 추가했다.\n- 실습 파일 링크와 Chapter 06 독자 워크북 링크를 출판용 Markdown 링크로 정리했다.\n'''
if '## 최종 출판 검수 추가 반영 (2026-08-10)' not in text:
    text += append
write(p, text)

# ------------------------------------------------------------------
# Checklist current criteria
# ------------------------------------------------------------------
p = 'notes/chapter06_review_checklist.md'
text = read(p)
text = text.replace('books_nf\n→ 이 장에서 대여 대상으로 관리하는 도서 한 건', 'books_nf\n→ 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건')
text = text.replace('| C-02 동일 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` | PostgreSQL 실제 검증 |', '| C-02 ISBN 필수·동일 문자열 중복 금지 | `NOT NULL` + `UNIQUE (isbn)` | PostgreSQL 검증 대상 |')
text = text.replace('- [x] `public` 스키마 존재 검사', '- [x] `public` 스키마 존재 검사\n- [x] `public` 스키마 `USAGE`·`CREATE` 권한 검사')
text = text.replace('- [x] ISBN UNIQUE', '- [x] ISBN UNIQUE\n- [ ] ISBN NOT NULL — 최종 출판 검수에서 추가, 최신 CI 재검증 대상')
if '## 19. 2026-08-10 최종 출판 보완' not in text:
    text += '''\n\n---\n\n## 19. 2026-08-10 최종 출판 보완\n\n- [x] Chapter 05의 ISBN NULL 허용 상태와 Chapter 06 정책 확정 흐름 연결\n- [x] C-02를 ISBN `NOT NULL` + `UNIQUE`로 문서·SQL 테스트에 일치시킴\n- [x] `NOT NULL`/`DEFAULT` 설명 교정\n- [x] PostgreSQL 기본 `UNIQUE` NULL 동작과 `NULLS NOT DISTINCT` 구분\n- [x] 1NF·2NF·3NF 표현 정밀화\n- [x] `CHECK`의 교차 행 검증 한계와 부분 고유 인덱스 역할 구분\n- [x] `RESTRICT`와 `NO ACTION` 차이 보완\n- [x] 생성 SQL의 `public USAGE/CREATE` 권한 검사 추가\n- [ ] ISBN NULL 실패 테스트의 최신 PostgreSQL CI 실행 결과 확인\n'''
write(p, text)

# ------------------------------------------------------------------
# CI workflow: align publication terms and add actual ISBN-null test
# ------------------------------------------------------------------
p = '.github/workflows/validate-chapter06.yml'
replace_exact(p, "'05_integrity_tests.sql', '대여 대상으로 관리하는 도서 한 건',", "'05_integrity_tests.sql', '대여 대상으로 취급하는 간소화된 도서 항목 한 건',")
replace_exact(p,
    "for term in ['BEGIN;', 'COMMIT;', 'v_raw_count <> 0', 'CREATE TABLE public.loans_nf']:",
    "for term in ['BEGIN;', 'COMMIT;', 'v_raw_count <> 0', 'CREATE TABLE public.loans_nf', 'has_schema_privilege']:")
replace_exact(p,
    "'uq_loans_nf_active_book', 'v_member_101_count <> 2',\n              'Chapter 06 integrity test baseline preserved',",
    "'uq_loans_nf_active_book', 'v_member_101_count <> 2',\n              'v_not_null_count <> 10', 'ISBN NOT NULL',\n              'Chapter 06 integrity test baseline preserved',")
replace_exact(p,
    'expect_fail "duplicate isbn" "uq_books_nf_isbn" "INSERT INTO public.books_nf (id,title,author,published_year,isbn) VALUES (1903,\'중복 ISBN\',\'테스트\',2026,\'ISBN-001\');"',
    'expect_fail "isbn not null" "not-null constraint" "INSERT INTO public.books_nf (id,title,author,published_year,isbn) VALUES (1912,\'ISBN 없음\',\'테스트\',2026,NULL);"\n          expect_fail "duplicate isbn" "uq_books_nf_isbn" "INSERT INTO public.books_nf (id,title,author,published_year,isbn) VALUES (1903,\'중복 ISBN\',\'테스트\',2026,\'ISBN-001\');"')

# ------------------------------------------------------------------
# Regenerate merged manuscript and static assertions
# ------------------------------------------------------------------
subprocess.run(['python', '-m', 'py_compile', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)
subprocess.run(['python', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)

chapter = read('book/chapter06/chapter06.md')
assert chapter.count('\n## ') >= 18
for term in [
    'ISBN은 필수이며 같은 ISBN 문자열 중복 금지',
    'NULLS NOT DISTINCT',
    '간소화된 도서 항목 한 건',
    '모든 후보키가 단일 열',
    '고유 인덱스 객체',
    '[Chapter 06 독자 워크북](chapter06_activity.md)'
]:
    assert term in chapter, term

for p in ['code/chapter06/01_normalization_schema.sql', 'code/chapter06/normalization_schema.sql']:
    t = read(p)
    assert "has_schema_privilege(current_user, 'public', 'USAGE')" in t
    assert "has_schema_privilege(current_user, 'public', 'CREATE')" in t

for p in ['code/chapter06/05_integrity_tests.sql', 'code/chapter06/integrity_tests.sql']:
    t = read(p)
    assert 'v_not_null_count <> 10' in t
    assert '오류 테스트 3A: C-02 ISBN NOT NULL 위반' in t

merged = read('publish/full_manuscript.md')
assert 'ISBN은 필수이며 같은 ISBN 문자열 중복 금지' in merged
assert 'Chapter 06 독자 워크북' in merged
print('Chapter 06 final publication review applied successfully')
