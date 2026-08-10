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
        raise RuntimeError(f'{path}: expected at least {count} occurrence(s), found {actual}: {old[:80]!r}')
    text = text.replace(old, new, count)
    write(path, text)

# ------------------------------------------------------------------
# Chapter 05 manuscript: prerequisite accuracy and model semantics
# ------------------------------------------------------------------
path = 'book/chapter05/chapter05.md'
replace_exact(path,
    '이 장은 데이터 모델링과 ERD를 처음 배우는 독자를 대상으로 합니다. Chapter 04에서 테이블, 열, 기본키와 외래키의 기본 의미를 이해했다면 별도의 설계 경험은 필요하지 않습니다.',
    '이 장은 데이터 모델링과 ERD를 처음 배우는 독자를 대상으로 합니다. Chapter 02에서 기본키·외래키와 관계의 기본 의미를 살펴보고, Chapter 04에서 테이블과 열을 직접 만들고 SQL을 실행했다면 별도의 설계 경험은 필요하지 않습니다.')
replace_exact(path,
    '- **심화 학습**: 복본·여러 저자·동시 대여·모델 변경을 다루는 내용',
    '- **심화 학습**: 실물 복본(copy)·여러 저자·동시 대여·모델 변경을 다루는 내용')
replace_exact(path,
    'R-03. 도서는 제목, 저자, 출판연도, ISBN을 가진다.',
    'R-03. 도서는 제목과 저자를 관리하며, 출판연도와 ISBN 정보도 저장할 수 있다.')
replace_exact(path,
    '> - `books` 한 행을 대여 대상으로 관리하는 도서 한 건으로 취급한다.\n> - 같은 ISBN의 여러 실제 복본은 별도 구분하지 않는다.',
    '> - `books` 한 행은 이 장에서 대여 대상으로 취급하는 **간소화된 도서 항목 한 건**이다.\n> - 실제 서가의 개별 복본(copy)은 별도 엔터티로 모델링하지 않으므로, 같은 ISBN을 가진 여러 실물 책을 서로 구분할 수 없다.')
replace_exact(path,
    '이 범위에서는 `books`가 도서 제목·판본과 실제 복본을 완전히 구분한 실무 모델은 아닙니다. 입문 실습을 위한 의도적인 단순화입니다.',
    '따라서 이 장의 `books`는 서지 정보와 실제 복본을 완전히 분리한 실무형 도서관 모델이 아닙니다. “도서 항목 하나를 대여 대상으로 취급한다”는 입문용 단순화이며, 복본별 바코드·소장 위치·분실 상태 같은 정보는 표현하지 않습니다.')
replace_exact(path,
    '| R-03 | 제목, 저자, 출판연도, ISBN | 도서의 속성 |',
    '| R-03 | 제목, 저자, 출판연도, ISBN | 도서의 속성 후보, 일부 값의 필수 여부는 추가 확인 |')
replace_exact(path,
    '| `books` | 대여 대상으로 관리하는 도서 한 건 |',
    '| `books` | 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건 |')
replace_exact(path,
    'books.member_ids\n→ 여러 회원 ID를 문자열이나 배열로 저장하면 개별 관계 검증이 어려움',
    'books.member_ids\n→ 여러 회원 ID를 문자열이나 배열 한 값처럼 저장하면 대여 시점·반납 상태와 개별 관계를 독립적으로 검증하기 어려움')
replace_exact(path,
    '관계형 모델에서는 이를 사건 테이블을 통해 두 개의 1:N 관계로 바꿉니다.',
    '관계형 데이터베이스에서는 N:M 관계를 보통 연결(교차) 테이블로 풀어 두 개의 1:N 관계로 표현합니다. 이 사례의 `loans`는 연결 정보뿐 아니라 대여일과 반납 상태 같은 사건 속성까지 가지므로 **연결 엔터티이자 사건 테이블**로 이해할 수 있습니다.')
replace_exact(path,
    'books 한 행은 이 장에서 대여 대상으로 취급하는 도서 한 건이다.',
    'books 한 행은 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건이다.')
replace_exact(path,
    '| 선택 속성 | NULL 허용 후보 |',
    '| 선택 속성 또는 필수 여부 미확정 속성 | NULL 허용 후보 |')
replace_exact(path,
    "    isbn VARCHAR(20) NOT NULL\n);",
    "    isbn VARCHAR(20)\n);",
    count=1)
replace_exact(path,
    '이메일과 ISBN에는 아직 `UNIQUE`를 적용하지 않았습니다. 중복을 허용하기로 확정한 것이 아니라 정책이 미확정이므로 적용을 보류한 것입니다.',
    '이메일과 ISBN에는 아직 `UNIQUE`를 적용하지 않았습니다. 중복을 허용하기로 확정한 것이 아니라 고유성 정책이 미확정이므로 적용을 보류한 것입니다. 또한 ISBN이 없는 도서를 허용할지도 미확정이므로 Chapter 05의 `isbn`은 `NULL`을 허용합니다. Chapter 06에서 정책을 확정한 뒤 기존 데이터와 함께 `NOT NULL`·`UNIQUE` 적용 여부를 검토합니다.')
replace_exact(path,
    'code/chapter05/01_library_schema.sql\ncode/chapter05/02_library_seed.sql\ncode/chapter05/03_library_validation.sql\ncode/chapter05/reset_library.sql',
    '[`01_library_schema.sql`](../../code/chapter05/01_library_schema.sql)\n[`02_library_seed.sql`](../../code/chapter05/02_library_seed.sql)\n[`03_library_validation.sql`](../../code/chapter05/03_library_validation.sql)\n[`reset_library.sql`](../../code/chapter05/reset_library.sql)')
replace_exact(path,
    '도서 201은 첫 대여가 2026년 4월 2일 반납된 뒤 2026년 4월 3일 다시 대여됩니다. 시간에 따른 반복 이력을 표현하지만 동시 미반납 상태는 만들지 않습니다.',
    '도서 201은 첫 대여가 2026년 4월 2일 반납된 뒤 2026년 4월 3일 다시 대여됩니다. 이 샘플은 시간에 따른 반복 이력을 표현하지만 동시 미반납 상태는 만들지 않습니다. 다만 `books`가 실물 복본을 구분하지 않는 간소화 모델이므로, 이 사실만으로 실제 도서관의 복본별 대여 가능성을 완전하게 표현했다고 볼 수는 없습니다.')
replace_exact(path,
    '더 많은 기록 활동과 권장 해설은 `book/chapter05/chapter05_activity.md`에서 확인합니다.' if '더 많은 기록 활동과 권장 해설은 `book/chapter05/chapter05_activity.md`에서 확인합니다.' in read(path) else '### 핵심 정리',
    '[Chapter 05 독자 워크북](chapter05_activity.md)에서 요구사항 분석과 ERD 판단 근거를 직접 기록할 수 있습니다.\n\n### 핵심 정리' if '더 많은 기록 활동과 권장 해설은 `book/chapter05/chapter05_activity.md`에서 확인합니다.' not in read(path) else '[Chapter 05 독자 워크북](chapter05_activity.md)에서 더 많은 기록 활동과 권장 해설을 확인합니다.')

# ------------------------------------------------------------------
# Outline sync
# ------------------------------------------------------------------
path = 'book/chapter05/chapter05_outline.md'
replace_exact(path,
    'Chapter 04에서 테이블, 열, 기본키와 외래키의 기본 의미를 이해했다면 별도의 설계 경험은 필요하지 않다.',
    'Chapter 02에서 기본키·외래키와 관계의 기본 의미를 살펴보고 Chapter 04에서 테이블·열과 SQL 실행을 경험했다면 별도의 설계 경험은 필요하지 않다.')
replace_exact(path,
    '- N:M 관계를 사건 테이블로 변환한다.',
    '- N:M 관계를 연결 테이블로 풀고, 사건 속성이 있는 연결 엔터티를 설명한다.')
replace_exact(path,
    '→ 복본·여러 저자·동시 대여·모델 변경과 마이그레이션',
    '→ 실물 복본(copy)·여러 저자·동시 대여·모델 변경과 마이그레이션')
replace_exact(path,
    'books 한 행을 대여 대상으로 관리하는 도서 한 건으로 취급한다.\n동일 ISBN의 여러 실제 복본은 별도로 구분하지 않는다.',
    'books 한 행을 대여 대상으로 취급하는 간소화된 도서 항목 한 건으로 정의한다.\n실제 복본(copy)은 별도 엔터티로 모델링하지 않아 같은 ISBN의 여러 실물 책을 구분하지 않는다.')
replace_exact(path,
    '이메일과 ISBN의 고유성은 미확정이므로 Chapter 05에서는 UNIQUE를 적용하지 않는다.',
    '이메일과 ISBN의 고유성은 미확정이므로 Chapter 05에서는 UNIQUE를 적용하지 않는다. ISBN 존재 여부도 미확정이므로 isbn은 NULL을 허용한다.')
replace_exact(path,
    '| `books` | 대여 대상으로 관리하는 도서 한 건 |',
    '| `books` | 대여 대상으로 취급하는 간소화된 도서 항목 한 건 |')
replace_exact(path,
    'R-03. 도서는 제목, 저자, 출판연도, ISBN을 가진다.',
    'R-03. 도서는 제목과 저자를 관리하며, 출판연도와 ISBN 정보도 저장할 수 있다.')

# ------------------------------------------------------------------
# Workbook sync
# ------------------------------------------------------------------
path = 'book/chapter05/chapter05_activity.md'
replace_exact(path,
    'R-03. 도서는 제목, 저자, 출판연도, ISBN을 가진다.',
    'R-03. 도서는 제목과 저자를 관리하며, 출판연도와 ISBN 정보도 저장할 수 있다.')
replace_exact(path,
    '| `books` 한 행을 대여 대상 한 건으로 취급한다 |  |  |',
    '| `books` 한 행을 간소화된 대여 대상 도서 항목 한 건으로 취급한다 |  |  |')
replace_exact(path,
    '| 동일 ISBN의 실제 복본을 별도 관리한다 |  |  |',
    '| 동일 ISBN의 실제 복본(copy)을 별도 관리한다 |  |  |')
replace_exact(path,
    'books 한 행은 __________________________________________________________이다.',
    'books 한 행은 __________________________________________________________이다.\n\n이 모델이 실제 복본(copy)을 구분하지 못한다는 뜻을 한 문장으로 설명하세요.\n\n________________________________________________________________________')
replace_exact(path,
    'books.isbn에 바로 UNIQUE를 적용하지 않는 이유:',
    'books.isbn에 바로 UNIQUE를 적용하지 않는 이유:\n\nISBN이 없는 도서를 허용할지 미확정일 때 NOT NULL을 바로 적용하면 안 되는 이유:')

# ------------------------------------------------------------------
# Schema SQL: permissions + unresolved ISBN nullability
# ------------------------------------------------------------------
path = 'code/chapter05/01_library_schema.sql'
replace_exact(path,
    "    IF to_regnamespace('public') IS NULL THEN\n        RAISE EXCEPTION\n            '생성 중단: public 스키마가 존재하지 않습니다.';\n    END IF;",
    "    IF to_regnamespace('public') IS NULL THEN\n        RAISE EXCEPTION\n            '생성 중단: public 스키마가 존재하지 않습니다.';\n    END IF;\n\n    IF NOT has_schema_privilege(current_user, 'public', 'USAGE') THEN\n        RAISE EXCEPTION\n            '생성 중단: 사용자 %에게 public 스키마 USAGE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_schema_privilege(current_user, 'public', 'CREATE') THEN\n        RAISE EXCEPTION\n            '생성 중단: 사용자 %에게 public 스키마 CREATE 권한이 없습니다.',\n            current_user;\n    END IF;")
replace_exact(path,
    '-- ISBN 고유성·복본 정책은 미확정이므로 UNIQUE를 적용하지 않습니다.',
    '-- ISBN 존재 여부·고유성·복본 정책은 미확정이므로 NOT NULL·UNIQUE를 적용하지 않습니다.')
replace_exact(path, '    isbn VARCHAR(20) NOT NULL\n);', '    isbn VARCHAR(20)\n);')

# Keep legacy compatibility schema synchronized with numbered schema.
legacy = 'code/chapter05/library_schema.sql'
if (ROOT / legacy).exists():
    write(legacy, read(path))

# ------------------------------------------------------------------
# Validation: explicitly verify unresolved ISBN nullability and FK shape
# ------------------------------------------------------------------
path = 'code/chapter05/03_library_validation.sql'
replace_exact(path,
    '    v_book_201_invalid_order bigint;\nBEGIN',
    '    v_book_201_invalid_order bigint;\n    v_isbn_nullable text;\n    v_fk_count bigint;\nBEGIN')
replace_exact(path,
    "    SELECT COUNT(*) INTO v_book_201_invalid_order\n    FROM public.loans AS earlier\n    JOIN public.loans AS later\n        ON earlier.book_id = later.book_id\n       AND earlier.borrowed_at < later.borrowed_at\n    WHERE earlier.book_id = 201\n      AND earlier.returned_at IS NOT NULL\n      AND earlier.returned_at >= later.borrowed_at;",
    "    SELECT COUNT(*) INTO v_book_201_invalid_order\n    FROM public.loans AS earlier\n    JOIN public.loans AS later\n        ON earlier.book_id = later.book_id\n       AND earlier.borrowed_at < later.borrowed_at\n    WHERE earlier.book_id = 201\n      AND earlier.returned_at IS NOT NULL\n      AND earlier.returned_at >= later.borrowed_at;\n\n    SELECT is_nullable INTO v_isbn_nullable\n    FROM information_schema.columns\n    WHERE table_schema = 'public'\n      AND table_name = 'books'\n      AND column_name = 'isbn';\n\n    SELECT COUNT(*) INTO v_fk_count\n    FROM pg_constraint\n    WHERE conrelid = 'public.loans'::regclass\n      AND contype = 'f'\n      AND confrelid IN ('public.members'::regclass, 'public.books'::regclass);")
replace_exact(path,
    '       OR v_book_201_count <> 2\n       OR v_book_201_invalid_order <> 0 THEN',
    "       OR v_book_201_count <> 2\n       OR v_book_201_invalid_order <> 0\n       OR v_isbn_nullable IS DISTINCT FROM 'YES'\n       OR v_fk_count <> 2 THEN")
replace_exact(path,
    "            '검증 실패: members=%, books=%, loans=%, open=%, orphan_member=%, orphan_book=%, member101=%, book201=%, invalid_order=%',",
    "            '검증 실패: members=%, books=%, loans=%, open=%, orphan_member=%, orphan_book=%, member101=%, book201=%, invalid_order=%, isbn_nullable=%, fk_count=%',")
replace_exact(path,
    '            v_book_201_count,\n            v_book_201_invalid_order;',
    '            v_book_201_count,\n            v_book_201_invalid_order,\n            v_isbn_nullable,\n            v_fk_count;')
legacy = 'code/chapter05/library_validation.sql'
if (ROOT / legacy).exists():
    write(legacy, read(path))

# ------------------------------------------------------------------
# Code README sync
# ------------------------------------------------------------------
path = 'code/chapter05/README.md'
replace_exact(path,
    'books 한 행\n→ 이 장에서 대여 대상으로 관리하는 도서 한 건',
    'books 한 행\n→ 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건')
replace_exact(path,
    '동일 ISBN의 실제 복본 구분',
    '동일 ISBN의 실제 복본(copy) 구분')
replace_exact(path,
    '이메일과 ISBN의 고유성은 미확정이므로 `UNIQUE`를 적용하지 않습니다. 날짜 선후 관계와 동시 활성 대여 제약은 Chapter 06에서 보완합니다.',
    '이메일과 ISBN의 고유성은 미확정이므로 `UNIQUE`를 적용하지 않습니다. ISBN이 없는 도서를 허용할지도 미확정이므로 Chapter 05의 `isbn`은 `NULL`을 허용합니다. 날짜 선후 관계와 동시 활성 대여 제약은 Chapter 06에서 보완합니다.')
replace_exact(path, '    isbn VARCHAR(20) NOT NULL\n);', '    isbn VARCHAR(20)\n);')
replace_exact(path,
    'public 스키마 존재\n세 테이블이 존재하지 않음',
    'public 스키마 존재\npublic 스키마 USAGE·CREATE 권한\n세 테이블이 존재하지 않음')
replace_exact(path,
    '도서 201 시간 순서 오류 = 0',
    '도서 201 시간 순서 오류 = 0\nbooks.isbn NULL 허용 = YES\nloans 외래키 = 2개')

# ------------------------------------------------------------------
# Review records: append publication-final notes idempotently
# ------------------------------------------------------------------
marker = '## 최종 출판 검수 추가 반영 (2026-08-10)'
for path in ['book/chapter05/chapter05_review_revision.md', 'notes/chapter05_review_checklist.md']:
    text = read(path)
    if marker not in text:
        text += f'''\n\n---\n\n{marker}\n\n- Chapter 02의 키·관계 개념과 Chapter 04의 SQL 실행 경험을 선수 지식으로 정확히 구분했습니다.\n- `books` 한 행을 실물 복본이 아닌 간소화된 도서 항목으로 명확히 정의했습니다.\n- 실제 복본(copy)을 별도 모델링하지 않는 범위와 그 한계를 명시했습니다.\n- R-03을 제목·저자는 관리하고 출판연도·ISBN은 저장 가능한 정보로 정리해 필수 여부 판단과 분리했습니다.\n- ISBN 존재 여부와 고유성이 미확정인 상태에서 `NOT NULL`을 먼저 적용하던 모순을 제거해 Chapter 05에서는 `isbn`이 NULL을 허용하도록 했습니다.\n- N:M 관계는 일반적으로 연결(교차) 테이블로 풀고, `loans`는 사건 속성을 가진 연결 엔터티라는 설명으로 정밀화했습니다.\n- `01_library_schema.sql`에 `public` USAGE·CREATE 권한 확인을 추가했습니다.\n- 검증 SQL에서 `books.isbn`의 NULL 허용 상태와 `loans`의 두 외래키 존재를 확인하도록 보강했습니다.\n- Chapter 06에서 정책 확정 후 `NOT NULL`·`UNIQUE`를 적용하는 흐름과 일치시켰습니다.\n'''
        write(path, text)

# ------------------------------------------------------------------
# Static checks and manuscript regeneration
# ------------------------------------------------------------------
subprocess.run(['python', '-m', 'py_compile', str(ROOT / 'scripts/merge_chapters.py')], check=True)
subprocess.run(['python', str(ROOT / 'scripts/merge_chapters.py')], cwd=ROOT, check=True)

# Sanity assertions
manuscript = read('book/chapter05/chapter05.md')
assert 'Chapter 04에서 테이블, 열, 기본키와 외래키의 기본 의미' not in manuscript
assert 'isbn VARCHAR(20) NOT NULL' not in manuscript
assert 'isbn VARCHAR(20)' in manuscript
assert '연결 엔터티이자 사건 테이블' in manuscript
assert '실제 복본(copy)' in manuscript
schema = read('code/chapter05/01_library_schema.sql')
assert "has_schema_privilege(current_user, 'public', 'CREATE')" in schema
assert 'isbn VARCHAR(20) NOT NULL' not in schema
validation = read('code/chapter05/03_library_validation.sql')
assert 'v_isbn_nullable' in validation and 'v_fk_count' in validation
full = read('publish/full_manuscript.md')
assert '연결 엔터티이자 사건 테이블' in full

# Remove this helper after it has done its job.
Path(__file__).unlink()
