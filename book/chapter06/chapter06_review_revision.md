# Chapter 06 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter06/chapter06.md
book/chapter06/chapter06_activity.md
book/chapter06/chapter06_outline.md
code/chapter06/normalization_schema.sql
code/chapter06/normalization_seed.sql
code/chapter06/normalization_practice.sql
code/chapter06/integrity_tests.sql
code/chapter06/reset_normalization.sql
code/chapter06/README.md
notes/chapter06_review_checklist.md
README.md
```

## 검수 목적

Chapter 06의 정규화 설명을 Chapter 05의 요구사항·정책 추적 흐름과 연결하고, 실제 PostgreSQL 실습에서 데이터 상태와 제약조건 테스트가 충돌하지 않도록 보완했습니다.

```text
행 의미·컬럼 주인
→ 중복과 이상 현상
→ 1NF·2NF·3NF
→ 미확정 정책 확인
→ 확정 규칙 ID
→ 제약조건·부분 고유 인덱스
→ 정상·경계·오류 데이터 검증
```

---

## 1. 샘플 데이터 정합성 수정

도서 201이 동시에 두 건의 미반납 대여에 포함되던 문제를 수정했습니다.

```text
대여 1001: 2026-04-01 시작, 2026-04-02 반납
대여 1003: 2026-04-03 시작, 미반납
```

따라서 다음 조건이 모두 유지됩니다.

```text
회원 101의 대여 기록 2건
도서 201의 시간에 따른 대여 기록 2건
미반납 기록 2건
동일 도서의 동시 미반납 없음
```

본문, 원시 데이터, 정규화 데이터, 워크북과 SQL 검증 기준을 동기화했습니다.

---

## 2. 미확정 정책과 확정 규칙 구분

Chapter 05에서 후보로 남긴 이메일·ISBN 고유성 등을 Chapter 06에서 다음 규칙으로 확정했습니다.

| ID | 규칙 | 구현 |
| --- | --- | --- |
| C-01 | 정확히 같은 이메일 문자열 중복 금지 | `UNIQUE` |
| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE` |
| C-03 | 이름·제목의 공백 문자열 금지 | `CHECK` |
| C-04 | 반납예정일은 대여일 이상 | `CHECK` |
| C-05 | 실제반납일은 `NULL` 또는 대여일 이상 | `CHECK` |
| C-06 | 존재하는 회원·도서만 참조 | `FOREIGN KEY` |
| C-07 | 대여 이력 보유 부모 삭제 금지 | `RESTRICT` |
| C-08 | 도서당 미반납 대여 최대 한 건 | 부분 고유 인덱스 |

이메일 대소문자, 동일 ISBN 복본, 여러 저자와 과거 기간 전체 중첩 검사는 범위 밖으로 명시했습니다.

---

## 3. 활성 대여 중복 차단 추가

Chapter 05에서 후속 구현으로 남긴 도서별 활성 대여 중복을 다음 부분 고유 인덱스로 차단했습니다.

```sql
CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;
```

반납된 과거 대여는 여러 건 허용하지만 같은 도서의 미반납 행은 한 건만 허용합니다. 전체 과거 날짜 구간의 중첩 검사는 범위에서 제외했습니다.

---

## 4. 스키마와 실행 위치 기준 통일

모든 본문·워크북·SQL 파일의 위치 확인을 다음으로 통일했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

모든 주요 객체는 `public.members_nf`, `public.loans_nf`처럼 스키마 한정 이름을 사용합니다.

---

## 5. IDENTITY 시작값 조정

명시적 샘플 ID 입력 뒤 다음 자동값을 조정했습니다.

```text
library_records_raw.loan_id → 1004
members_nf.id               → 103
books_nf.id                 → 203
loans_nf.id                 → 1004
```

명시적 ID 입력이 연결된 IDENTITY 시퀀스를 자동으로 소비하지 않는다는 설명을 본문·워크북·SQL에 반영했습니다.

---

## 6. 요구사항 근거 없는 CHECK 제거

기존 `published_year >= 1000` 조건은 요구사항 근거가 없어 삭제했습니다. `published_year = NULL`은 허용되어야 하는 경계값으로 테스트합니다.

---

## 7. 오류 테스트 데이터 상태 충돌 해결

회원 101 이메일을 수정한 뒤 기존 이메일을 사용하는 중복 테스트가 성공할 수 있던 문제를 해결했습니다.

중복 이메일 테스트는 변경하지 않은 회원 102의 다음 값을 사용합니다.

```text
junho@example.com
```

따라서 회원 101 수정 전후 모두 `UNIQUE` 오류가 발생해야 합니다.

---

## 8. 정상·경계·오류 테스트 확대

### 허용 경계값

```text
due_at = borrowed_at
returned_at = borrowed_at
returned_at = NULL
published_year = NULL
공백이 아닌 한 글자 이름
```

### 실패 테스트

```text
NOT NULL
이메일·ISBN UNIQUE
공백 이름·제목 CHECK
없는 회원 FOREIGN KEY
날짜 순서 CHECK
두 번째 미반납 대여 부분 고유 인덱스
참조 중 부모 삭제 RESTRICT
```

오류 후 기준 행 수와 데이터를 다시 확인하도록 구성했습니다.

---

## 9. 오류 후 트랜잭션 복구 안내

수동 커밋이나 명시적 트랜잭션에서 오류 후 다음 메시지가 나타날 수 있음을 설명했습니다.

```text
current transaction is aborted
```

이때 다음 명령으로 실패한 트랜잭션을 종료한 뒤 다음 테스트로 이동합니다.

```sql
ROLLBACK;
```

상세 트랜잭션 원리는 Chapter 09로 연결했습니다.

---

## 10. 초기화 파일 안전성 강화

`reset_normalization.sql`은 하나의 보호 구문 안에서 다음을 검증합니다.

```text
current_database() = ai_database_book
current_schema()   = public
```

조건이 맞을 때만 다음 순서로 삭제합니다.

```text
public.loans_nf
→ public.books_nf
→ public.members_nf
→ public.library_records_raw
```

---

## 11. 정규형·삭제 정책 설명 보완

- 제2정규형 수강 예제에 같은 강의를 한 번만 수강한다는 가정을 명시했습니다.
- 재수강·학기·분반에는 추가 식별자가 필요함을 설명했습니다.
- `NO ACTION`의 지연 가능성과 `RESTRICT`의 즉시 거부 차이를 입문 수준으로 보완했습니다.
- 주문 실습의 이메일·수량·가격 제약조건은 정책 확정 후 적용하는 후보로 수정했습니다.

---

## 12. 자기주도 학습 보완

본문과 워크북에 다음 권장 해설을 추가했습니다.

```text
위험한 중복과 정상 반복
삽입·수정·삭제 이상
함수적 종속
1NF·2NF·3NF 핵심 판단
제약조건 대응
부분 고유 인덱스
IDENTITY 시작값
ROLLBACK 상황
주문 당시 가격
```

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 샘플 동시 미반납 문제 해결 | 완료 |
| 정책 후보와 확정 규칙 분리 | 완료 |
| 활성 대여 부분 고유 인덱스 | 완료 |
| `public`·`SHOW search_path` 통일 | 완료 |
| IDENTITY 시작값 조정 | 완료 |
| 초기화 보호 구문 | 완료 |
| 중복 이메일 테스트 충돌 해결 | 완료 |
| 정상·경계·오류 테스트 | 완료 |
| `ROLLBACK` 안내 | 완료 |
| 근거 없는 출판연도 CHECK 제거 | 완료 |
| 권장 해설 추가 | 완료 |

## 결론

```text
Chapter 06은 정규형 설명에 머물지 않고,
요구사항 근거·확정 규칙·PostgreSQL 구현·실패 증거를 연결하는
데이터 무결성 검증 장으로 최종 보완되었다.
```

실제 PostgreSQL에서 `schema → seed → practice → integrity → reset` 전체 실행과 출판 렌더링은 별도 제작 단계에서 확인합니다.
