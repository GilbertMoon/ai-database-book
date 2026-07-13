# Chapter 09 실습 자료

## 트랜잭션과 데이터 정합성

> 용도: 자기주도 실습 / Chapter 09 보조 자료

---

## 1. 실습 목표

이 실습에서는 온라인 강의 수강신청, 결제 기록, 잔여 좌석 변경을 하나의 트랜잭션으로 처리하고 `COMMIT`과 `ROLLBACK`의 차이를 확인합니다.

```text
- 여러 변경이 왜 함께 성공하거나 함께 실패해야 하는지 설명한다.
- UPDATE 영향 행 수를 확인하고 후속 SQL 실행 여부를 판단한다.
- COMMIT 전과 ROLLBACK 후 결과를 SELECT로 검증한다.
- Lock 대기와 Deadlock을 구분한다.
- AI 생성 SQL을 업무 규칙 기준으로 검토한다.
```

---

## 2. 실습 준비와 DB 경고

필요한 도구와 파일은 다음과 같습니다.

```text
- PostgreSQL
- DBeaver Community Edition
- 개인 실습용 ai_database_book 데이터베이스
- code/chapter09/transaction_consistency_practice.sql
```

> **실습 DB 확인**
>
> 실습 SQL은 `payments`, `enrollments`, `courses`, `instructors`, `students` 테이블을 삭제한 후 다시 생성합니다. 보존해야 할 데이터가 있는 DB에서는 실행하지 않습니다.

먼저 다음 SQL을 실행하고 연결 대상을 기록합니다.

```sql
SELECT current_database();
```

| 확인 항목 | 기록 |
| --- | --- |
| 현재 데이터베이스 |  |
| 개인 실습용 DB 여부 |  |
| 보존해야 할 데이터 없음 확인 |  |

---

## 3. Chapter 09 확장 스키마 확인

Chapter 09는 Chapter 07·08의 온라인 강의 구조에 정원·잔여 좌석과 결제 테이블을 추가합니다.

```text
courses(..., capacity, remaining_seats)
payments(id, enrollment_id, amount, paid_at)
```

결제는 학생과 강의를 각각 복사해 연결하지 않고 특정 수강신청을 참조합니다.

```text
payments.enrollment_id → enrollments.id
```

이 단순 예제에서는 한 수강신청에 성공 결제 한 건만 저장하며 `enrollments.paid_amount`와 `payments.amount`가 일치해야 합니다.

---

## 4. 초기 상태 확인

스키마와 기준 데이터 구간을 실행한 뒤 행 수를 확인합니다.

| 테이블 | 예상값 | 실행 결과 |
| --- | ---: | ---: |
| students | 3 |  |
| instructors | 2 |  |
| courses | 3 |  |
| enrollments | 0 |  |
| payments | 0 |  |

### courses 초기 상태

| id | title | capacity | remaining_seats |
| ---: | --- | ---: | ---: |
| 1 | 데이터베이스 입문 | 2 | 2 |
| 2 | 정규화 실습 | 1 | 1 |
| 3 | 파이썬 데이터 분석 | 1 | 1 |

---

## 5. 트랜잭션 기본 흐름 작성

다음 흐름에서 빈칸을 채웁니다.

```text
변경 전 SELECT
→ __________
→ 여러 변경 SQL
→ __________ 전 SELECT 검증
→ 정상: __________
→ 문제: __________
```

| 명령 | 본인의 설명 |
| --- | --- |
| BEGIN |  |
| COMMIT |  |
| ROLLBACK |  |

`ROLLBACK`은 이미 `COMMIT`된 같은 트랜잭션을 취소할 수 있는지 설명해 보세요.

---

## 6. 성공 트랜잭션 문장별 실행

`transaction_consistency_practice.sql`의 성공 트랜잭션 1 구간을 **문장별로** 실행합니다.

### 6.1 대상과 Lock 확인

```sql
BEGIN;

SELECT id, title, price, remaining_seats
FROM courses
WHERE id = 1
FOR UPDATE;
```

| 확인 항목 | 예상값 | 실행 결과 |
| --- | --- | --- |
| 대상 강의 | 데이터베이스 입문 |  |
| 실행 전 잔여 좌석 | 2 |  |
| Lock 대상 | courses의 id=1 행 |  |

### 6.2 좌석 확보 결과 확인

```sql
UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 1
  AND remaining_seats > 0
RETURNING id, title, price, remaining_seats;
```

| 확인 항목 | 예상값 | 실행 결과 |
| --- | ---: | ---: |
| 반환 행 수 | 1 |  |
| 변경 후 remaining_seats | 1 |  |

반환 행 수가 0이면 이후 수강신청·결제 INSERT를 실행하지 않고 `ROLLBACK`해야 합니다.

### 6.3 신청과 결제 연결 확인

SQL 파일의 `WITH new_enrollment ... INSERT INTO payments` 문장을 실행합니다.

| 확인 항목 | 예상 결과 | 실행 결과 |
| --- | --- | --- |
| enrollment 생성 | 1건 |  |
| payment 생성 | 1건 |  |
| payment 연결 컬럼 | enrollment_id |  |
| 신청 상태 | 수강중 |  |
| paid_amount와 amount | 둘 다 100000 |  |

### 6.4 COMMIT 전 SELECT 검증

| 확인 항목 | 예상값 | 실행 결과 |
| --- | ---: | ---: |
| 학생 ID | 1 |  |
| 강의 ID | 1 |  |
| 수강신청 행 수 | 1 |  |
| 결제 행 수 | 1 |  |
| 강의 잔여 좌석 | 1 |  |

모든 결과가 맞을 때만 `COMMIT`합니다.

```sql
COMMIT;
```

---

## 7. ROLLBACK 전후 비교

학생 2가 강의 2를 신청하는 ROLLBACK 예제를 문장별로 실행합니다.

### 7.1 트랜잭션 내부 임시 상태

결제 검증 실패를 가정하기 전에 같은 세션에서 세 테이블을 조회합니다.

| 확인 대상 | 트랜잭션 내부 예상 | 실행 결과 |
| --- | --- | --- |
| enrollments | 새 행 1건 보임 |  |
| payments | 새 행 1건 보임 |  |
| courses.remaining_seats | 1 → 0 |  |

### 7.2 ROLLBACK 실행

```sql
ROLLBACK;
```

### 7.3 ROLLBACK 후 확인

| 확인 대상 | 예상값 | 실행 결과 |
| --- | ---: | ---: |
| 학생 2·강의 2 enrollment | 0행 |  |
| 연결 payment | 0행 |  |
| 강의 2 remaining_seats | 1 |  |

같은 세션에서 임시 변경이 보였지만 최종 상태에 남지 않는 이유를 설명해 보세요.

---

## 8. 두 번째 성공 트랜잭션

학생 3이 강의 2를 신청하는 성공 트랜잭션을 문장별로 실행합니다.

| 확인 항목 | 예상값 | 실행 결과 |
| --- | ---: | ---: |
| 좌석 UPDATE 반환 행 | 1 |  |
| 신청 상태 | 수강중 |  |
| 결제 금액 | 120000 |  |
| COMMIT 후 강의 2 잔여 좌석 | 0 |  |

---

## 9. 좌석 UPDATE 0행 처리

강의 2의 좌석이 0인 상태에서 다음 SQL을 실행합니다.

```sql
BEGIN;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0
RETURNING id, title, remaining_seats;
```

| 질문 | 답변 |
| --- | --- |
| 반환 행 수는 몇 개인가? |  |
| PostgreSQL 오류가 자동 발생했는가? |  |
| 후속 enrollment INSERT를 실행해야 하는가? |  |
| 어떤 명령으로 종료해야 하는가? |  |

```sql
ROLLBACK;
```

핵심: `remaining_seats > 0`은 음수 차감을 막지만, 0행일 때 후속 SQL을 자동 중단하지 않습니다.

---

## 10. 정합성 검증 SQL

### 10.1 좌석 범위 위반

```sql
SELECT id, title, capacity, remaining_seats
FROM courses
WHERE remaining_seats < 0
   OR remaining_seats > capacity;
```

예상 결과: **0행**

### 10.2 수강중 신청과 결제 불일치

```sql
SELECT
    e.id AS enrollment_id,
    e.paid_amount,
    p.amount AS payment_amount
FROM enrollments AS e
LEFT JOIN payments AS p ON p.enrollment_id = e.id
WHERE e.status = '수강중'
  AND (p.id IS NULL OR e.paid_amount <> p.amount);
```

예상 결과: **0행**

### 10.3 좌석 사용량

| course_id | 예상 active_enrollment_count | 예상 used_seats | 일치 여부 |
| ---: | ---: | ---: | --- |
| 1 | 1 | 1 |  |
| 2 | 1 | 1 |  |
| 3 | 0 | 0 |  |

이 장에서는 `수강중` 상태가 좌석을 사용한다고 가정합니다. 취소·환불 시 좌석 복구 정책은 범위에서 제외합니다.

---

## 11. ACID 활동

| 특성 | 본인의 설명 | 수강신청 예시 |
| --- | --- | --- |
| Atomicity |  |  |
| Consistency |  |  |
| Isolation |  |  |
| Durability |  |  |

다음 문장이 맞는지 검토하고 이유를 작성합니다.

| 문장 | 맞음/아님 | 이유 |
| --- | --- | --- |
| Atomicity가 결제금액 업무 규칙을 자동 검증한다 |  |  |
| Consistency에는 제약조건과 올바른 SQL이 필요하다 |  |  |
| Isolation의 보이는 범위는 격리 수준과 관련된다 |  |  |
| COMMIT된 결과는 Durability와 연결된다 |  |  |

---

## 12. Lock 대기와 Deadlock 구분

### 정상적인 Lock 대기

```text
학생 A: 강의 행 Lock → 좌석 차감 → COMMIT
학생 B: 같은 행 변경 시도 → 대기 → 최신 좌석 확인 → 좌석 0 → ROLLBACK
```

### Deadlock

```text
트랜잭션 A: 강의 1 잠금 → 강의 2 대기
트랜잭션 B: 강의 2 잠금 → 강의 1 대기
```

| 상황 | Lock 대기 또는 Deadlock | 이유 |
| --- | --- | --- |
| B가 A의 한 행 Lock 해제를 기다림 |  |  |
| A와 B가 서로 가진 잠금을 기다림 |  |  |

실제 Deadlock SQL은 기본 실습에서 실행하지 않습니다.

---

## 13. AI 생성 트랜잭션 SQL 검토

AI가 만든 SQL을 다음 기준으로 검토합니다.

| 검토 항목 | 확인 결과 | 수정 필요 여부 |
| --- | --- | --- |
| 신청·결제·좌석이 하나의 업무 단위인가? |  |  |
| BEGIN과 COMMIT·ROLLBACK 경계가 있는가? |  |  |
| 대상 학생과 강의를 먼저 확인하는가? |  |  |
| SELECT FOR UPDATE 또는 동시성 검토가 있는가? |  |  |
| 좌석 UPDATE의 영향 행 수를 확인하는가? |  |  |
| UPDATE 0행이면 후속 INSERT를 중단하는가? |  |  |
| payment가 enrollment_id로 연결되는가? |  |  |
| COMMIT 전에 세 테이블을 SELECT하는가? |  |  |
| 개인 실습 DB에서 문장별 실행하는가? |  |  |

### 사람이 수정한 내용

| AI 제안 | 문제점 | 수정한 내용 |
| --- | --- | --- |
|  |  |  |
|  |  |  |

---

## 14. 전체 실습 후 예상 상태

| 항목 | 예상값 | 실행 결과 |
| --- | ---: | ---: |
| 최종 enrollments | 2 |  |
| 최종 payments | 2 |  |
| 데이터베이스 입문 잔여 좌석 | 1 |  |
| 정규화 실습 잔여 좌석 | 0 |  |
| 파이썬 데이터 분석 잔여 좌석 | 1 |  |
| 좌석 범위 오류 조회 | 0행 |  |
| 결제 누락·금액 불일치 조회 | 0행 |  |

---

## 15. 실습 기록 양식

```markdown
# Chapter 09 실습 기록

## 1. 현재 DB와 초기 상태
## 2. 성공 트랜잭션 문장별 결과
## 3. COMMIT 전 검증
## 4. ROLLBACK 전후 비교
## 5. UPDATE 0행 처리
## 6. ACID 정리
## 7. Lock 대기와 Deadlock 구분
## 8. 정합성 검증 결과
## 9. AI SQL 검토와 수정 근거
## 10. 느낀 점
```

---

## 16. 완성도 점검

| 점검 항목 | 중요도 | 확인 기준 |
| --- | ---: | --- |
| 안전한 실행 준비 | 15 | 현재 DB와 DROP 대상을 확인했는가 |
| 성공 트랜잭션 | 20 | 영향 행 수와 COMMIT 전 결과를 확인했는가 |
| ROLLBACK 비교 | 20 | 세 테이블의 임시·복구 상태를 기록했는가 |
| 정합성 검증 | 20 | 좌석, 결제, 상태 규칙을 SQL로 확인했는가 |
| 동시성 이해 | 10 | Lock 대기와 Deadlock을 구분했는가 |
| AI SQL 검토 | 15 | 실패 경로와 관계를 근거로 수정했는가 |

---

## 17. 핵심 정리

```text
COMMIT은 검증 후 실행한다.
ROLLBACK은 아직 확정되지 않은 현재 트랜잭션의 변경을 취소한다.
UPDATE 0행은 자동 오류가 아니므로 후속 INSERT를 중단한다.
payments는 enrollment_id로 수강신청에 연결한다.
Lock 대기와 Deadlock은 다르다.
AI SQL은 영향 행 수와 실패 경로까지 검토한다.
```
