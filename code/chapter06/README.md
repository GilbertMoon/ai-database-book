# Chapter 06 실습 코드

## 정규화와 데이터 무결성으로 좋은 테이블 만들기

이 폴더는 정규화 전후 구조를 비교하고, 기존 데이터가 새 업무 규칙을 만족하는지 확인한 뒤 PostgreSQL 제약조건을 추가·검증하는 SQL 파일을 관리합니다.

---

## 권장 번호형 파일

| 파일 | 시작 상태 | 완료 상태 | 반복 실행 |
| --- | --- | --- | --- |
| `01_normalization_schema.sql` | 실습 테이블 없음 | 제약조건 전 기본 구조 | 한 번 |
| `02_normalization_seed.sql` | 네 테이블이 비어 있음 | 정상 샘플 입력 | 한 번 |
| `03_normalization_compare.sql` | 정상 샘플 존재 | 정규화 전후 비교·자동 확인 | 가능 |
| `04_add_integrity_rules.sql` | 업무 규칙 미적용 | C-01~C-08 적용 | 한 번 |
| `05_integrity_tests.sql` | 규칙 적용 완료 | 경계·오류 테스트 | 한 테스트씩 |
| `reset_normalization.sql` | 어떤 실습 상태 | 실습 객체 삭제 | 필요할 때만 |

## 기존 파일명

다음 파일은 기존 링크와 자료 호환을 위해 유지합니다.

| 기존 파일 | 대응 번호 파일 |
| --- | --- |
| `normalization_schema.sql` | `01_normalization_schema.sql` |
| `normalization_seed.sql` | `02_normalization_seed.sql` |
| `normalization_practice.sql` | `03_normalization_compare.sql` |
| `integrity_tests.sql` | `05_integrity_tests.sql` |

기존 파일과 번호 파일은 같은 역할이므로 둘 중 하나만 실행합니다. 무결성 규칙 추가는 공통으로 `04_add_integrity_rules.sql`을 사용합니다.

---

## 권장 실행 순서

```text
현재 연결 확인
→ 01_normalization_schema.sql
→ 02_normalization_seed.sql
→ 03_normalization_compare.sql
→ 04_add_integrity_rules.sql
→ 05_integrity_tests.sql에서 한 테스트씩 실행
```

처음부터 다시 시작할 때는 다음 순서를 사용합니다.

```text
reset_normalization.sql
→ 01_normalization_schema.sql
→ 02_normalization_seed.sql
→ 03_normalization_compare.sql
→ 04_add_integrity_rules.sql
```

---

## 공통 실행 원칙

```text
1. ai_database_book 연결인지 확인한다.
2. 현재 사용자와 search_path를 확인한다.
3. Auto-commit 상태를 확인한다.
4. public.table_name처럼 스키마를 명시한다.
5. 파일의 시작 상태를 확인한다.
6. 오류 테스트는 한 번에 하나씩 실행한다.
7. 오류 후 기준 데이터가 유지되는지 확인한다.
```

현재 스키마는 환경에 따라 `public`이 아닐 수 있습니다. 모든 주요 객체는 `public.members_nf`처럼 스키마를 명시하므로 `current_schema() = public`을 강제하지 않습니다.

---

## 학습 흐름이 두 단계인 이유

`01_normalization_schema.sql`은 기본 테이블 구조만 만듭니다. `02_normalization_seed.sql`로 정상 샘플을 넣고, `03_normalization_compare.sql`에서 정규화 전후를 확인합니다.

그 뒤 `04_add_integrity_rules.sql`이 현재 데이터를 먼저 검사하고 다음 규칙을 추가합니다.

```text
NOT NULL
UNIQUE
CHECK
FOREIGN KEY
ON DELETE RESTRICT
부분 고유 인덱스
```

이 흐름은 기존 데이터가 새 규칙을 위반하면 `ALTER TABLE`이 실패할 수 있다는 점을 보여 줍니다.

---

## 실습 테이블

```text
public.library_records_raw
public.members_nf
public.books_nf
public.loans_nf
```

| 테이블 | 한 행의 의미 |
| --- | --- |
| `library_records_raw` | 대여 사건과 회원·도서 현재 사실이 섞인 한 건 |
| `members_nf` | 회원 한 명 |
| `books_nf` | 대여 대상으로 관리하는 도서 한 건 |
| `loans_nf` | 특정 회원의 특정 도서 대여 사건 한 건 |

---

## 확정 규칙

| ID | 규칙 | 구현 |
| --- | --- | --- |
| C-01 | 정확히 같은 이메일 문자열 중복 금지 | `UNIQUE (email)` |
| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |
| C-03 | 공백 이름·제목 금지 | `CHECK` |
| C-04 | 반납예정일은 대여일 이상 | `CHECK` |
| C-05 | 실제반납일은 `NULL` 또는 대여일 이상 | `CHECK` |
| C-06 | 존재하는 회원·도서만 참조 | `FOREIGN KEY` |
| C-07 | 참조 중인 부모 삭제 금지 | `ON DELETE RESTRICT` |
| C-08 | 도서당 미반납 대여 최대 한 건 | 부분 고유 인덱스 |

이메일 대소문자 정규화, 동일 ISBN 복본, 여러 저자와 과거 기간 전체의 중첩은 이 장에서 다루지 않습니다.

---

## 기대 샘플 상태

```text
library_records_raw = 3
members_nf = 2
books_nf = 2
loans_nf = 3
미반납 = 2
회원 고아 참조 = 0
도서 고아 참조 = 0
도서 201 대여 이력 = 2
활성 대여 중복 = 0
```

샘플 ID:

```text
members_nf: 101, 102
books_nf: 201, 202
loans_nf: 1001, 1002, 1003
```

명시적 ID 입력 뒤 번호 파일이 IDENTITY의 다음 값을 조정합니다.

---

## ALTER TABLE 단계

`04_add_integrity_rules.sql`은 하나의 트랜잭션 안에서 다음 순서로 동작합니다.

```text
현재 DB·쓰기 가능 여부 확인
→ 테이블과 기존 규칙 존재 여부 확인
→ NULL·중복·공백·날짜·고아 참조·활성 중복 검사
→ ALTER COLUMN SET NOT NULL
→ UNIQUE·CHECK·FOREIGN KEY 추가
→ 부분 고유 인덱스 생성
→ COMMIT
```

중간에 오류가 발생하면 `ROLLBACK;`을 실행하고 위반 데이터를 확인합니다.

---

## 경계 테스트

다음 값은 허용되어야 합니다.

```text
due_at = borrowed_at
returned_at = borrowed_at
returned_at = NULL
published_year = NULL
공백이 아닌 한 글자 이름
```

## 오류 테스트

```text
NOT NULL 위반
이메일·ISBN UNIQUE 위반
공백 이름·제목 CHECK 위반
FOREIGN KEY 위반
날짜 순서 CHECK 위반
두 번째 미반납 대여 부분 고유 인덱스 위반
참조 중 부모 삭제 RESTRICT 위반
```

오류 SQL은 기본적으로 주석 처리되어 있습니다. 실패해야 하는 SQL에서 오류가 발생하면 정상적인 테스트 결과입니다.

수동 커밋 상태에서 다음 메시지가 나타나면:

```text
current transaction is aborted
```

다음 명령으로 실패한 트랜잭션을 종료합니다.

```sql
ROLLBACK;
```

---

## 범위 안내

```text
JOIN 상세는 Chapter 08
트랜잭션과 오류 복구는 Chapter 09
인덱스와 성능은 Chapter 10
JSONB 구조는 Chapter 12
운영 데이터 정제·무중단 마이그레이션은 심화 범위
```
