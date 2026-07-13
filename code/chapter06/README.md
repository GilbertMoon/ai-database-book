# Chapter 06 실습 코드

## 정규화와 데이터 무결성으로 좋은 테이블 만들기

이 폴더는 정규화 전후 구조를 비교하고, 무결성 제약조건이 잘못된 값과 관계를 차단하는지 확인하는 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `normalization_schema.sql` | 원시 테이블과 정규화 후 테이블·제약조건 생성 |
| `normalization_seed.sql` | 명시적 ID를 사용한 정상 샘플 데이터 입력 |
| `normalization_practice.sql` | 중복, 행 수, 관계와 수정 이상 감소 확인 |
| `integrity_tests.sql` | 실패해야 하는 무결성 오류 SQL 모음 |
| `reset_normalization.sql` | 필요할 때만 실습 테이블 삭제 |

Chapter 05 테이블과 충돌하지 않도록 다음 이름을 사용합니다.

```text
library_records_raw
members_nf
books_nf
loans_nf
```

---

## 기본 실행 순서

```text
normalization_schema.sql
→ normalization_seed.sql
→ normalization_practice.sql
→ integrity_tests.sql에서 한 문장씩 선택 실행
```

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. `current_database()`와 `current_schema()`를 확인합니다.
3. `normalization_schema.sql`을 실행합니다.
4. `normalization_seed.sql`을 실행합니다.
5. `normalization_practice.sql`로 정규화 전후 결과를 비교합니다.
6. `integrity_tests.sql`에서 오류 테스트를 하나씩 실행합니다.

---

## 기대 행 수

| 테이블 | 기대 행 수 |
| --- | ---: |
| `library_records_raw` | 3 |
| `members_nf` | 2 |
| `books_nf` | 2 |
| `loans_nf` | 3 |

샘플 ID:

```text
members_nf: 101, 102
books_nf: 201, 202
loans_nf: 1001, 1002, 1003
```

자동 증가값의 이전 상태를 가정하지 않도록 명시적 ID를 사용합니다.

---

## 적용된 무결성 규칙

| 규칙 | 적용 위치 |
| --- | --- |
| 기본키와 자동 ID | 모든 테이블의 `id` 또는 `loan_id` |
| 필수값 | 회원 이름·이메일, 도서 제목·저자·ISBN, 대여 날짜와 FK |
| 중복 금지 | `members_nf.email`, `books_nf.isbn` |
| 공백 이름·제목 차단 | `CHECK (char_length(trim(...)) > 0)` |
| 날짜 순서 | `due_at >= borrowed_at` |
| 실제반납일 | NULL 또는 대여일 이후 |
| 참조 무결성 | `loans_nf.member_id`, `loans_nf.book_id` |
| 부모 삭제 제한 | `ON DELETE RESTRICT` |

---

## 오류 테스트 방법

`integrity_tests.sql`의 오류 SQL은 모두 주석 처리되어 있습니다.

```text
1. 테스트 하나만 주석 해제한다.
2. 해당 SQL만 선택 실행한다.
3. 오류 메시지와 제약조건 이름을 확인한다.
4. 행 수를 다시 조회해 기존 데이터가 유지되는지 확인한다.
5. SQL을 다시 주석 처리하고 다음 테스트로 이동한다.
```

테스트 종류:

```text
NOT NULL 위반
UNIQUE 위반
CHECK 위반
FOREIGN KEY 위반
참조 중인 부모 삭제
```

오류가 발생해야 정상인 테스트입니다. 오류를 없애기 위해 제약조건을 바로 제거하지 않습니다.

---

## 초기화가 필요한 경우

생성·샘플·검증 파일에는 자동 `DROP TABLE`이 없습니다.

처음부터 다시 시작해야 할 때만 다음 파일을 사용합니다.

```text
reset_normalization.sql
```

다음 값을 반드시 확인한 뒤 DROP 구간만 선택 실행합니다.

```text
current_database = ai_database_book
current_schema   = public
```

---

## 범위 안내

```text
- JOIN 문법과 다양한 결합 방식은 Chapter 08에서 자세히 다룹니다.
- 트랜잭션을 이용한 여러 단계 정합성은 Chapter 09에서 다룹니다.
- 인덱스와 성능을 근거로 한 구조 검토는 Chapter 10에서 다룹니다.
- 운영 데이터 정제와 마이그레이션은 이 장의 범위가 아닙니다.
```
