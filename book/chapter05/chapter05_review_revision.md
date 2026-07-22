# Chapter 05 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter05/chapter05.md
book/chapter05/chapter05_activity.md
book/chapter05/chapter05_outline.md
code/chapter05/library_schema.sql
code/chapter05/library_seed.sql
code/chapter05/library_validation.sql
code/chapter05/reset_library.sql
code/chapter05/README.md
images/chapter05/README.md
notes/chapter05_review_checklist.md
README.md
```

## 검수 목적

Chapter 05의 요구사항 중심 모델링 흐름은 유지하면서, 예제 범위와 샘플 데이터의 모순, 미확정 정책의 임의 제약조건화, 명시적 ID와 IDENTITY 시퀀스 불일치, 스키마·초기화 안전성 문제를 제거했습니다.

```text
요구사항
→ 확정·미확정·가정·범위 제외
→ 개념 엔터티와 관계
→ 논리 구조와 키
→ PostgreSQL DDL
→ 샘플 데이터
→ 요구사항 추적과 실행 검증
```

---

## 1. 모델 수준 구분

기존의 “엔터티는 테이블, 속성은 열”이라는 단순 대응을 다음 흐름으로 보완했습니다.

```text
현실의 대상과 사건
→ 개념 모델의 엔터티와 관계
→ 논리 모델의 엔터티·속성·키
→ PostgreSQL 물리 모델의 테이블·열·타입·제약조건
```

이 책에서는 개념·논리 모델을 PostgreSQL 구조와 가깝게 표현하는 실무형 ERD를 사용한다는 점을 명시했습니다.

---

## 2. 미확정 고유성 정책 처리

원래 요구사항은 이메일과 ISBN을 저장한다고만 설명하며 시스템 내 고유성을 확정하지 않습니다.

기존 DDL의 다음 제약조건을 제거했습니다.

```text
members.email UNIQUE
books.isbn UNIQUE
```

최종 Chapter 05 DDL은 다음과 같습니다.

```sql
email VARCHAR(100) NOT NULL
isbn VARCHAR(20) NOT NULL
```

이메일·ISBN은 업무상 고유값 **후보**로 유지하고, 고유성·대소문자·복본 정책은 Chapter 06에서 요구사항을 확인한 뒤 `UNIQUE` 적용 여부를 검토합니다.

---

## 3. 미확정 질문 확대

다음 정책 질문을 추가했습니다.

```text
회원 이메일의 고유성과 대소문자 처리
ISBN 고유성과 ISBN 없는 도서 허용 여부
동일 ISBN 복본 관리
여러 저자 처리
최대 대여 권수와 연체 정책
날짜 선후 관계
같은 한 권의 동시 활성 대여 차단
회원 삭제 후 이력 보존
```

이 항목들은 Chapter 06의 `UNIQUE`, `CHECK`, 정규화와 참조 무결성으로 연결합니다.

---

## 4. 샘플 대여 상태 정합성 수정

기존 샘플은 도서 201이 두 회원에게 동시에 미반납 상태였습니다. `books` 한 행을 대여 대상 한 권으로 보는 범위 가정과 충돌했습니다.

최종 샘플은 다음과 같습니다.

| 대여 ID | 회원 | 도서 | 대여일 | 실제반납일 | 상태 |
| ---: | ---: | ---: | --- | --- | --- |
| 1001 | 101 | 201 | 2026-04-01 | 2026-04-02 | 반납 완료 |
| 1002 | 101 | 202 | 2026-04-02 | NULL | 미반납 |
| 1003 | 102 | 201 | 2026-04-03 | NULL | 미반납 |
| 1004 | 103 | 203 | 2026-04-05 | NULL | 미반납 |

도서 201은 첫 대여가 반납된 다음 날 다시 대여됩니다. 다음 조건은 그대로 유지됩니다.

```text
회원 101의 여러 대여 기록
도서 201의 시간에 따른 여러 대여 기록
미반납 returned_at NULL 3건
동일한 한 권의 동시 미반납 상태 없음
```

---

## 5. 명시적 ID와 IDENTITY 조정

샘플 관계 재현을 위해 명시적 ID를 유지합니다.

```text
members: 101~103
books: 201~203
loans: 1001~1004
```

명시적 ID는 연결된 IDENTITY의 다음 값을 자동으로 변경하지 않으므로 `library_seed.sql` 마지막에 다음 구문을 추가했습니다.

```sql
ALTER TABLE public.members
    ALTER COLUMN id RESTART WITH 104;

ALTER TABLE public.books
    ALTER COLUMN id RESTART WITH 204;

ALTER TABLE public.loans
    ALTER COLUMN id RESTART WITH 1005;
```

---

## 6. 스키마와 실행 위치 기준 통일

본문, 워크북과 모든 SQL 파일의 위치 확인을 다음으로 통일했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

테이블, 외래키, 입력과 조회에는 `public` 스키마를 명시했습니다.

```text
public.members
public.books
public.loans
```

```text
public.loans.member_id → public.members.id
public.loans.book_id   → public.books.id
```

---

## 7. 초기화 파일 안전성 강화

기존 초기화 파일은 위치를 출력한 뒤 곧바로 스키마가 생략된 `DROP TABLE`을 실행했습니다.

최종 파일은 하나의 `DO` 보호 구문 안에서 다음 조건을 확인합니다.

```text
current_database() = ai_database_book
current_schema() = public
```

조건이 맞을 때만 다음 순서로 삭제합니다.

```text
public.loans
→ public.books
→ public.members
```

잘못된 데이터베이스나 스키마에서는 예외를 발생시키고 삭제하지 않습니다.

---

## 8. 관계 설명 보완

### 1:1 관계

그림 표기만으로 1:1이 보장되지 않음을 추가했습니다.

```text
자식 외래키에 UNIQUE 적용
또는 부모 PK를 자식의 PK이자 FK로 사용
```

### N:M 관계

N:M은 한쪽 외래키 한 열이나 문자열·배열 목록이 아니라, 정규화된 관계형 모델에서 중간 또는 사건 테이블을 통해 두 개의 1:N 관계로 구성한다고 설명했습니다.

---

## 9. 요구사항 추적표 강화

기존 세 열 추적표를 다음 구조로 확장했습니다.

```text
ID | 요구사항·가정 | 상태 | 반영 구조 | 확인 방법
```

상태는 다음 네 가지로 구분합니다.

```text
확정
미확정
임시 가정
범위 제외
```

이메일·ISBN 고유성, 복본 범위와 책 한 행 가정을 추적표에 명시했습니다.

---

## 10. 자동 커밋과 부분 반영 경고

`library_schema.sql`과 `library_seed.sql`의 여러 문장이 자동으로 하나의 원자적 작업이 되지 않을 수 있음을 추가했습니다.

```text
자동 커밋 상태에서는 일부 CREATE 또는 INSERT만 반영될 수 있다.
실행 후 library_validation.sql의 행 수·관계·시간 순서로 전체 상태를 확인한다.
```

---

## 11. 자기주도 학습 보완

본문과 워크북에 다음 권장 해설을 추가했습니다.

- 개념·논리·물리 모델 구분
- 1:1 구현 조건
- 고유값 후보와 `UNIQUE` 차이
- 명시적 ID와 IDENTITY 재시작
- 샘플 대여 시간 순서
- 쇼핑몰 권장 모델
- AI가 제안한 잘못된 구조의 문제점

쇼핑몰 권장 엔터티는 다음과 같습니다.

```text
customers
orders
products
order_items
```

`order_items.unit_price`는 현재 가격이 아니라 주문 당시 가격을 저장하도록 설명했습니다.

---

## 12. 최종 상태

| 항목 | 상태 |
| --- | --- |
| 본문 최종 출판 검수 반영 | 완료 |
| 워크북 동기화 | 완료 |
| 구성안 동기화 | 완료 |
| 미확정 UNIQUE 제거 | 완료 |
| 샘플 동시 대여 모순 제거 | 완료 |
| IDENTITY 다음 값 조정 | 완료 |
| `public` 스키마 명시 | 완료 |
| `SHOW search_path` 통일 | 완료 |
| 초기화 보호 구문 | 완료 |
| 1:1 구현 설명 | 완료 |
| 추적표 ID·상태 강화 | 완료 |
| 권장 해설 추가 | 완료 |
| 코드 README 갱신 | 완료 |
| 이미지 문서 정합성 갱신 | 완료 |
| 루트 README 상태 갱신 | 완료 |

## 결론

```text
Chapter 05는 요구사항을 근거로 모델을 만드는 흐름을 유지하면서,
미확정 정책을 제약조건으로 확정하지 않고,
샘플 데이터·IDENTITY·스키마·초기화까지 일관되게 검증하는 장으로 보완되었다.
```

실제 PostgreSQL 통합 실행과 Word·PDF·eBook 렌더링은 전체 제작 단계에서 별도로 확인합니다.
