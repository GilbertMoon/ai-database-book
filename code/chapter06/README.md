# Chapter 06 실습 코드

## 정규화와 데이터 무결성으로 좋은 테이블 만들기

이 폴더는 정규화 전후 구조를 비교하고, 확정된 업무 규칙이 PostgreSQL 제약조건과 부분 고유 인덱스로 올바르게 구현되는지 검증하는 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `normalization_schema.sql` | 원시·정규화 테이블, 제약조건과 활성 대여 부분 고유 인덱스 생성 |
| `normalization_seed.sql` | 정상 샘플 데이터 입력과 IDENTITY 시작값 조정 |
| `normalization_practice.sql` | 중복, 행 수, 관계와 수정 이상 감소 확인 |
| `integrity_tests.sql` | 허용되어야 하는 경계값과 실패해야 하는 오류값 테스트 |
| `reset_normalization.sql` | DB·스키마를 검증한 뒤 실습 테이블 삭제 |

Chapter 05 테이블과 충돌하지 않도록 다음 이름을 사용합니다.

```text
public.library_records_raw
public.members_nf
public.books_nf
public.loans_nf
```

---

## 기본 실행 순서

```text
normalization_schema.sql
→ normalization_seed.sql
→ normalization_practice.sql
→ integrity_tests.sql에서 한 테스트씩 선택 실행
```

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. 다음 SQL로 현재 위치를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

3. 자동 커밋 상태를 확인합니다.
4. `normalization_schema.sql`을 실행합니다.
5. `normalization_seed.sql`을 실행합니다.
6. `normalization_practice.sql`로 행 수와 관계를 확인합니다.
7. `integrity_tests.sql`에서 경계·오류 테스트를 하나씩 실행합니다.

> 자동 커밋 상태에서는 일부 `CREATE`나 `INSERT`만 반영된 뒤 뒤 문장에서 오류가 날 수 있습니다. 각 파일 실행 후 기대 행 수와 객체를 확인합니다.

---

## 확정 규칙

| ID | 규칙 | 구현 |
| --- | --- | --- |
| C-01 | 정확히 같은 이메일 문자열 중복 금지 | `UNIQUE (email)` |
| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |
| C-03 | 회원 이름·도서 제목의 공백 문자열 금지 | `CHECK` |
| C-04 | 반납예정일은 대여일 이상 | `CHECK` |
| C-05 | 실제반납일은 `NULL` 또는 대여일 이상 | `CHECK` |
| C-06 | 존재하는 회원·도서만 참조 | `FOREIGN KEY` |
| C-07 | 대여 이력 보유 부모 삭제 금지 | `ON DELETE RESTRICT` |
| C-08 | 도서당 미반납 대여 최대 한 건 | 부분 고유 인덱스 |

이메일 대소문자 정규화, 동일 ISBN 복본, 여러 저자와 과거 대여 기간 전체 중첩 검사는 이 장의 범위가 아닙니다.

---

## 기대 행 수와 샘플 상태

| 테이블 | 기대 행 수 |
| --- | ---: |
| `public.library_records_raw` | 3 |
| `public.members_nf` | 2 |
| `public.books_nf` | 2 |
| `public.loans_nf` | 3 |

샘플 ID:

```text
members_nf: 101, 102
books_nf: 201, 202
loans_nf: 1001, 1002, 1003
```

대여 상태:

```text
1001: 도서 201, 2026-04-02 반납
1002: 도서 202, 미반납
1003: 도서 201, 2026-04-03 시작·미반납
```

따라서 다음 결과가 기대됩니다.

```text
회원 101의 대여 기록: 2건
도서 201의 대여 기록: 2건
미반납 기록: 2건
동일 도서의 동시 미반납: 없음
```

---

## IDENTITY 시작값

명시적 ID 입력은 IDENTITY의 다음 값을 자동으로 변경하지 않습니다. `normalization_seed.sql`은 샘플 입력 뒤 다음 값으로 조정합니다.

```text
library_records_raw.loan_id → 1004
members_nf.id               → 103
books_nf.id                 → 203
loans_nf.id                 → 1004
```

---

## 활성 대여 중복 차단

```sql
CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;
```

반납된 같은 도서의 과거 이력은 여러 건 저장할 수 있지만 미반납 대여는 도서당 한 건만 허용합니다. 이 인덱스는 과거 날짜 구간 전체의 중첩까지 검사하지 않습니다.

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

`integrity_tests.sql`의 경계 테스트는 임시 행을 입력한 뒤 삭제하도록 구성되어 있습니다.

---

## 오류 테스트 방법

오류 SQL은 모두 주석 처리되어 있습니다.

```text
1. 테스트 하나만 주석 해제한다.
2. 해당 문장만 선택 실행한다.
3. 오류 메시지와 제약조건·인덱스 이름을 확인한다.
4. 행 수를 다시 조회해 기존 데이터가 유지되는지 확인한다.
5. SQL을 다시 주석 처리하고 다음 테스트로 이동한다.
```

테스트 종류:

```text
NOT NULL 위반
이메일·ISBN UNIQUE 위반
공백 이름·제목 CHECK 위반
FOREIGN KEY 위반
날짜 순서 CHECK 위반
두 번째 미반납 대여 부분 고유 인덱스 위반
참조 중인 부모 삭제 RESTRICT 위반
```

중복 이메일 테스트는 변경하지 않은 회원 102의 `junho@example.com`을 사용하므로 회원 101 이메일 수정 전후 모두 실패해야 합니다.

### 오류 후 트랜잭션 상태

자동 커밋 상태에서 한 문장씩 실행하는 것이 가장 단순합니다. 수동 커밋 상태나 명시적 트랜잭션에서 오류 후 다음 메시지가 나타나면:

```text
current transaction is aborted
```

다음 명령으로 실패한 트랜잭션을 종료합니다.

```sql
ROLLBACK;
```

트랜잭션의 상세 원리는 Chapter 09에서 다룹니다.

---

## 초기화가 필요한 경우

생성·샘플·검증 파일에는 자동 `DROP TABLE`이 없습니다.

처음부터 다시 시작해야 할 때만 다음 파일을 사용합니다.

```text
reset_normalization.sql
```

파일은 하나의 보호 구문 안에서 다음을 검사합니다.

```text
current_database = ai_database_book
current_schema   = public
```

조건이 맞을 때만 다음 순서로 삭제합니다.

```text
public.loans_nf
→ public.books_nf
→ public.members_nf
→ public.library_records_raw
```

---

## 범위 안내

```text
- JOIN 문법과 다양한 결합 방식은 Chapter 08에서 자세히 다룹니다.
- 트랜잭션을 이용한 여러 단계 정합성은 Chapter 09에서 다룹니다.
- 인덱스와 성능을 근거로 한 반정규화 검토는 Chapter 10에서 다룹니다.
- 운영 데이터 정제와 마이그레이션은 이 장의 범위가 아닙니다.
- published_year의 범위 CHECK는 요구사항이 확정되지 않아 적용하지 않습니다.
```
