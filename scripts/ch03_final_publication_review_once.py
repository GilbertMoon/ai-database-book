from pathlib import Path
import subprocess


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected 1 match, found {count}")
    return text.replace(old, new, 1)


# -----------------------------------------------------------------------------
# Chapter 03 manuscript
# -----------------------------------------------------------------------------
p = Path("book/chapter03/chapter03.md")
text = p.read_text(encoding="utf-8")

text = replace_once(
    text,
    "- 공식 설치 프로그램\n- Postgres.app\n- Homebrew",
    "- PostgreSQL 다운로드 페이지에서 안내하는 설치 프로그램\n- Postgres.app\n- Homebrew",
    "macOS installer wording",
)

text = replace_once(
    text,
    "Test Connection이 성공하면 서버, 네트워크, 인증과 지정한 데이터베이스 접속이 가능하다는 뜻입니다. 하지만 다른 데이터베이스의 존재, 쓰기 권한과 스키마 사용 권한까지 모두 확인한 것은 아닙니다.",
    "Test Connection이 성공하면 서버, 네트워크, 인증과 지정한 데이터베이스 접속이 가능하다는 뜻입니다. 하지만 다른 데이터베이스의 존재나 실제 변경 권한, `public` 스키마의 `USAGE`·`CREATE` 권한까지 모두 확인한 것은 아닙니다.",
    "test connection scope",
)

text = replace_once(
    text,
    "| `current_schema()` | 검색 경로에서 현재 사용할 스키마 |",
    "| `current_schema()` | `search_path`에서 실제로 사용할 수 있는 첫 번째 스키마 |",
    "current_schema exact wording",
)

text = replace_once(
    text,
    "- `transaction_read_only = off`: 현재 세션에서 일반적인 변경 작업이 가능한 상태\n- `TimeZone`: 날짜와 시각을 해석하고 표시할 때 사용하는 세션 시간대",
    "- `transaction_read_only = off`: 현재 트랜잭션이 읽기 전용으로 강제되지 않은 상태. 실제 변경 가능 여부는 데이터베이스·스키마·객체 권한에 따라 달라질 수 있음\n- `TimeZone`: 날짜와 시각을 해석하고 표시할 때 사용하는 세션 시간대",
    "transaction read only wording",
)

text = replace_once(
    text,
    "경로:\n\n```text\ncode/chapter03/setup_check.sql\n```",
    "파일: [`setup_check.sql`](../../code/chapter03/setup_check.sql)",
    "setup check clickable link",
)

text = replace_once(
    text,
    "경로:\n\n```text\ncode/chapter03/setup_validate_local.sql\n```",
    "파일: [`setup_validate_local.sql`](../../code/chapter03/setup_validate_local.sql)",
    "setup validate clickable link",
)

text = replace_once(
    text,
    "PostgreSQL 15 이상\n현재 데이터베이스 = ai_database_book\n현재 사용자의 CONNECT 권한\npublic 스키마 존재와 USAGE 권한\n읽기 전용 상태가 아님\n기본 SQL 계산 정상",
    "PostgreSQL 15 이상\n현재 데이터베이스 = ai_database_book\n현재 사용자의 CONNECT 권한\npublic 스키마 존재\npublic 스키마 USAGE 권한\npublic 스키마 CREATE 권한\n읽기 전용 상태가 아님\n기본 SQL 계산 정상",
    "validation criteria add create",
)

text = replace_once(
    text,
    "모두 통과하면 다음 메시지가 표시됩니다.",
    "`USAGE`는 스키마 안의 객체를 참조할 때 필요한 권한이고, `CREATE`는 그 스키마에 새 객체를 만들 때 필요한 권한입니다. Chapter 04에서 `public.students`를 생성하려면 권장 로컬 경로에서 두 권한을 모두 확인하는 편이 안전합니다.\n\n모두 통과하면 다음 메시지가 표시됩니다.",
    "explain schema usage create",
)

text = replace_once(
    text,
    "| Permission denied to create database | 접속 사용자와 생성 권한 |\n| Cannot run inside a transaction block | 실행 범위, 열린 트랜잭션과 Auto-commit |",
    "| Permission denied to create database | 접속 사용자와 데이터베이스 생성 권한 |\n| Permission denied for schema public | 현재 사용자와 `public` 스키마의 `CREATE` 권한 |\n| Cannot run inside a transaction block | 실행 범위, 열린 트랜잭션과 Auto-commit |",
    "schema permission error row",
)

p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# setup_check.sql
# -----------------------------------------------------------------------------
p = Path("code/chapter03/setup_check.sql")
text = p.read_text(encoding="utf-8")
text = replace_once(
    text,
    "-- 목적: 서버, 데이터베이스, 스키마, 검색 경로, 사용자, 읽기 전용 상태와 시간대를 확인합니다.",
    "-- 목적: 서버, 데이터베이스, 스키마, 검색 경로, 사용자, public 사용·생성 권한, 읽기 전용 상태와 시간대를 확인합니다.",
    "setup check purpose",
)
text = replace_once(
    text,
    "    END AS public_schema_usage_ok,\n    1 + 1 = 2 AS sql_execution_ok;",
    "    END AS public_schema_usage_ok,\n    CASE\n        WHEN to_regnamespace('public') IS NULL THEN false\n        ELSE has_schema_privilege(current_user, 'public', 'CREATE')\n    END AS public_schema_create_ok,\n    1 + 1 = 2 AS sql_execution_ok;",
    "setup check create privilege",
)
p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# setup_validate_local.sql
# -----------------------------------------------------------------------------
p = Path("code/chapter03/setup_validate_local.sql")
text = p.read_text(encoding="utf-8")
text = replace_once(
    text,
    "    END AS public_schema_usage_ok;",
    "    END AS public_schema_usage_ok,\n    CASE\n        WHEN to_regnamespace('public') IS NULL THEN false\n        ELSE has_schema_privilege(current_user, 'public', 'CREATE')\n    END AS public_schema_create_ok;",
    "validation summary create privilege",
)
text = replace_once(
    text,
    "    IF NOT has_schema_privilege(current_user, 'public', 'USAGE') THEN\n        RAISE EXCEPTION\n            '환경 확인 중단: 사용자 %에게 public 스키마 USAGE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF current_setting('transaction_read_only')::boolean THEN",
    "    IF NOT has_schema_privilege(current_user, 'public', 'USAGE') THEN\n        RAISE EXCEPTION\n            '환경 확인 중단: 사용자 %에게 public 스키마 USAGE 권한이 없습니다.',\n            current_user;\n    END IF;\n\n    IF NOT has_schema_privilege(current_user, 'public', 'CREATE') THEN\n        RAISE EXCEPTION\n            '환경 확인 중단: 사용자 %에게 public 스키마 CREATE 권한이 없습니다. Chapter 04에서 public.students를 만들 수 있는 연결을 선택하세요.',\n            current_user;\n    END IF;\n\n    IF current_setting('transaction_read_only')::boolean THEN",
    "validation create privilege gate",
)
p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# code/chapter03 README
# -----------------------------------------------------------------------------
p = Path("code/chapter03/README.md")
text = p.read_text(encoding="utf-8")
text = replace_once(
    text,
    "`current_schema()`가 항상 `public`이어야 하는 것은 아닙니다. 현재 스키마와 `search_path`는 `setup_check.sql`에서 확인하고, `public`의 존재와 사용 권한은 검증 파일에서 별도로 판정합니다.",
    "`current_schema()`가 항상 `public`이어야 하는 것은 아닙니다. 현재 스키마와 `search_path`는 `setup_check.sql`에서 확인하고, `public`의 존재와 `USAGE`·`CREATE` 권한은 검증 파일에서 별도로 판정합니다.",
    "code README schema privileges",
)
text = replace_once(
    text,
    "Chapter 03 local environment validation passed",
    "Chapter 03 recommended local environment validation passed",
    "code README exact pass message",
)
text = replace_once(
    text,
    "| 요약 결과 | DB·public·USAGE·읽기 전용 상태를 한 행으로 확인 |",
    "| 요약 결과 | DB·public·USAGE·CREATE·읽기 전용 상태를 한 행으로 확인 |",
    "code README summary row",
)
text = replace_once(
    text,
    "public 스키마 존재\n현재 사용자의 public USAGE 권한\ntransaction_read_only = off",
    "public 스키마 존재\n현재 사용자의 public USAGE 권한\n현재 사용자의 public CREATE 권한\ntransaction_read_only = off",
    "code README validation criteria",
)
p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# Workbook
# -----------------------------------------------------------------------------
p = Path("book/chapter03/chapter03_activity.md")
text = p.read_text(encoding="utf-8")
text = replace_once(
    text,
    "| `public` USAGE 권한 |  |\n| 읽기 전용 상태 아님 |  |",
    "| `public` USAGE 권한 |  |\n| `public` CREATE 권한 |  |\n| 읽기 전용 상태 아님 |  |",
    "workbook validation create privilege",
)
text = replace_once(
    text,
    "| Permission denied to create database |  |  |\n| Cannot run inside a transaction block |  |  |",
    "| Permission denied to create database |  |  |\n| Permission denied for schema public |  |  |\n| Cannot run inside a transaction block |  |  |",
    "workbook schema error",
)
p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# Outline
# -----------------------------------------------------------------------------
p = Path("book/chapter03/chapter03_outline.md")
text = p.read_text(encoding="utf-8")
text = replace_once(
    text,
    "환경 조회와 자동 확인 파일은 어떻게 다른가?",
    "환경 조회와 자동 확인 파일은 어떻게 다른가?\nChapter 04의 테이블 생성을 위해 `public`에서 어떤 권한을 확인해야 하는가?",
    "outline core question create privilege",
)
text = replace_once(
    text,
    "권장 로컬 환경의 주요 조건을 자동 확인한다.\n관리형 환경을 통과시키기 위해 권한을 억지로 변경하지 않는다.",
    "권장 로컬 환경의 주요 조건을 자동 확인한다.\n`public` 스키마의 존재와 `USAGE`·`CREATE` 권한을 확인한다.\n관리형 환경을 통과시키기 위해 권한을 억지로 변경하지 않는다.",
    "outline validation details",
)
p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# Review revision history: append final publication review note
# -----------------------------------------------------------------------------
p = Path("book/chapter03/chapter03_review_revision.md")
text = p.read_text(encoding="utf-8").rstrip()
append = r'''

---

## 최종 출판 검수 추가 반영

최종 PDF 제작 전 Chapter 04의 실제 테이블 생성 조건과 다시 교차 검토해 다음을 보완했다.

```text
DBeaver Test Connection 성공과 실제 객체 생성 권한을 구분
current_schema()를 search_path의 첫 사용 가능 스키마로 정확히 표현
transaction_read_only = off와 실제 쓰기 권한을 구분
public USAGE뿐 아니라 CREATE 권한도 로컬 자동 확인에 추가
setup_check.sql 한 행 요약에 public CREATE 상태 추가
permission denied for schema public 오류 점검 추가
본문의 Chapter 03 SQL 파일 경로를 독자용 링크로 변경
code/chapter03/README.md의 통과 메시지를 실제 SQL과 일치시킴
```

`setup_validate_local.sql`은 이제 Chapter 04에서 `CREATE TABLE public.students`를 실행할 권장 로컬 환경인지 판단할 때 `public`의 `USAGE`와 `CREATE`를 모두 확인한다. `transaction_read_only = off`만으로 실제 변경 권한이 보장되는 것은 아니라는 점도 본문에 명시했다.
'''
if "## 최종 출판 검수 추가 반영" not in text:
    text += append
p.write_text(text + "\n", encoding="utf-8")


# -----------------------------------------------------------------------------
# Review checklist
# -----------------------------------------------------------------------------
p = Path("notes/chapter03_review_checklist.md")
text = p.read_text(encoding="utf-8")
text = replace_once(
    text,
    "| Test Connection 한계 | 통과 | 쓰기·스키마 권한까지 보장하지 않음 |",
    "| Test Connection 한계 | 통과 | 실제 변경 권한과 `public`의 `USAGE`·`CREATE`까지 보장하지 않음 |",
    "checklist test connection limitation",
)
text = replace_once(
    text,
    "| 읽기 전용·시간대 | 통과 | 참고 확인 항목으로 축소 |",
    "| 읽기 전용·시간대 | 통과 | `off`가 객체 생성 권한까지 보장하지 않음을 명시하고 시간대는 참고 항목으로 유지 |",
    "checklist read only nuance",
)
text = replace_once(
    text,
    "| `setup_validate_local.sql` | 통과 | 권장 로컬 환경 주요 조건 자동 확인 |",
    "| `setup_validate_local.sql` | 통과 | 권장 로컬 환경에서 `public`의 `USAGE`·`CREATE`를 포함한 주요 조건 자동 확인 |",
    "checklist validation create privilege",
)
text = replace_once(
    text,
    "| 연결값 | 통과 | Host·Port·Database·Username 점검 |",
    "| 연결값 | 통과 | Host·Port·Database·Username 점검 |\n| 스키마 생성 권한 | 통과 | `permission denied for schema public` 발생 시 `public`의 `CREATE` 권한 확인 |",
    "checklist schema error",
)
p.write_text(text, encoding="utf-8")


# -----------------------------------------------------------------------------
# Regenerate integrated manuscript and run static validations
# -----------------------------------------------------------------------------
subprocess.run(["python", "-m", "py_compile", "scripts/merge_chapters.py"], check=True)
subprocess.run(["python", "scripts/merge_chapters.py"], check=True)

chapter = Path("book/chapter03/chapter03.md").read_text(encoding="utf-8")
validate = Path("code/chapter03/setup_validate_local.sql").read_text(encoding="utf-8")
check = Path("code/chapter03/setup_check.sql").read_text(encoding="utf-8")
readme = Path("code/chapter03/README.md").read_text(encoding="utf-8")
full = Path("publish/full_manuscript.md").read_text(encoding="utf-8")

assert "has_schema_privilege(current_user, 'public', 'CREATE')" in validate
assert "public_schema_create_ok" in validate
assert "public_schema_create_ok" in check
assert "Chapter 03 recommended local environment validation passed" in readme
assert "Chapter 03 local environment validation passed" not in readme
assert "[`setup_check.sql`](../../code/chapter03/setup_check.sql)" in chapter
assert "[`setup_validate_local.sql`](../../code/chapter03/setup_validate_local.sql)" in chapter
assert "`transaction_read_only = off`: 현재 트랜잭션이 읽기 전용으로 강제되지 않은 상태" in chapter
assert "Permission denied for schema public" in chapter
assert "public 스키마 CREATE 권한" in chapter
assert "../code/chapter03/setup_check.sql" in full
assert "../code/chapter03/setup_validate_local.sql" in full
assert "public_schema_create_ok" not in full  # code is linked, not embedded

print("Chapter 03 final publication review completed successfully")
