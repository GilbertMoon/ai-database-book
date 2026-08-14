# [AI 시대의 데이터베이스 입문 09] PostgreSQL 트랜잭션으로 데이터 정합성 지키기

안녕하세요. 아토믹데브입니다.

지난 Chapter 08에서는 JOIN과 집계로 여러 테이블의 데이터를 연결하고 서비스 질문에 답하는 방법을 실습했습니다.

이번 시간에는 데이터를 **조회하는 것에서 한 단계 더 나아가 안전하게 변경하는 방법**을 배웁니다.

온라인 강의 수강신청을 생각해 보면 신청 한 번에 좌석 차감, 수강신청 생성, 결제 생성처럼 여러 데이터가 함께 변경될 수 있습니다. 이 중 하나만 성공하고 나머지가 실패하면 데이터가 서로 맞지 않는 상태가 됩니다.

이 문제를 해결하는 핵심 기능이 바로 **트랜잭션(Transaction)** 입니다.

---

## 오늘 배울 내용

이번 글을 끝까지 따라오면 다음 내용을 이해할 수 있습니다.

- 트랜잭션이 필요한 이유
- `BEGIN`, `COMMIT`, `ROLLBACK`
- ACID의 기본 개념
- 여러 SQL을 하나의 업무 단위로 처리하는 방법
- 조건부 `UPDATE`와 영향 행 수 확인
- `RETURNING` 활용
- `SELECT ... FOR UPDATE`와 Lock
- 동시 수강신청에서 마지막 좌석을 보호하는 방법
- `SAVEPOINT`의 역할
- AI가 만든 트랜잭션 SQL을 검증하는 방법

---

## STEP 1. 트랜잭션이 왜 필요할까요?

온라인 강의 수강신청을 확정할 때 다음 세 작업이 필요하다고 가정해 보겠습니다.

```text
1. 남은 좌석 1개 차감
2. 수강신청 데이터 생성
3. 결제 데이터 생성
```

이 작업들을 각각 따로 확정하면 문제가 발생할 수 있습니다.

```text
좌석만 줄었는데 신청 데이터가 없다.
신청은 생성됐는데 결제가 없다.
결제는 생성됐는데 신청 데이터가 없다.
신청과 결제는 있는데 좌석이 줄지 않았다.
```

따라서 세 작업을 하나의 업무 단위로 묶어야 합니다.

```text
모든 작업 성공
→ COMMIT

하나라도 실패
→ ROLLBACK
```

이것이 트랜잭션의 가장 중요한 목적입니다.

---

## STEP 2. BEGIN, COMMIT, ROLLBACK부터 이해해 봅시다

PostgreSQL의 기본 트랜잭션 구조는 매우 단순합니다.

```sql
BEGIN;

-- 변경 SQL

COMMIT;
```

`BEGIN`은 트랜잭션의 시작을 의미하고 `COMMIT`은 지금까지 변경한 내용을 확정합니다.

문제가 발견되면 `COMMIT` 대신 다음 명령을 사용합니다.

```sql
ROLLBACK;
```

정리하면 다음과 같습니다.

| 명령 | 의미 |
| --- | --- |
| `BEGIN` | 트랜잭션 시작 |
| `COMMIT` | 변경 내용 확정 |
| `ROLLBACK` | 아직 확정하지 않은 변경 취소 |

중요한 점이 있습니다.

```text
COMMIT하기 전 → ROLLBACK 가능
COMMIT한 후 → 같은 트랜잭션의 ROLLBACK으로 취소할 수 없음
```

그래서 중요한 데이터를 변경할 때는 **COMMIT 전에 반드시 결과를 확인**해야 합니다.

---

## STEP 3. 가장 기본적인 안전한 변경 패턴

실무와 실습에서 다음 패턴을 습관화하면 좋습니다.

```sql
-- 1. 변경 전 확인
SELECT ...;

-- 2. 트랜잭션 시작
BEGIN;

-- 3. 데이터 변경
UPDATE ...;
INSERT ...;

-- 4. 변경 결과 확인
SELECT ...;

-- 5. 정상일 때만 확정
COMMIT;
```

결과가 예상과 다르면 다음처럼 처리합니다.

```sql
ROLLBACK;
```

즉 중요한 데이터는 다음 순서로 다룹니다.

```text
확인 → 변경 → 다시 확인 → 확정
```

---

## STEP 4. 실습용 transaction_lab을 사용합니다

이번 Chapter에서는 앞에서 만든 `course_project` 데이터를 직접 변경하지 않습니다.

별도의 실습 스키마를 사용합니다.

```text
transaction_lab
├── course_inventory
├── enrollments
└── payments
```

역할은 다음과 같습니다.

| 테이블 | 역할 |
| --- | --- |
| `course_inventory` | 강의별 정원과 남은 좌석 |
| `enrollments` | 트랜잭션 실습용 수강신청 |
| `payments` | 신청과 연결된 결제 |

학생과 강의 정보는 기존 프로젝트 데이터를 참조합니다.

```text
transaction_lab.enrollments.student_id
→ course_project.students.id

transaction_lab.enrollments.course_id
→ course_project.courses.id
```

이렇게 실습 환경을 분리하면 Chapter 07과 Chapter 08의 기준 데이터를 안전하게 유지할 수 있습니다.

---

## STEP 5. 데이터 정합성이란 무엇일까요?

데이터 정합성은 서로 관련된 데이터가 업무 규칙에 맞게 일관된 상태를 유지하는 것을 의미합니다.

이번 수강신청 실습에서는 다음과 같은 규칙이 있습니다.

```text
남은 좌석은 0보다 작을 수 없다.
남은 좌석은 전체 정원보다 클 수 없다.
결제는 실제 존재하는 수강신청을 참조해야 한다.
한 수강신청에는 결제가 최대 한 건 존재한다.
수강신청 금액과 결제 금액은 일치해야 한다.
```

이 규칙을 지키는 방법은 하나가 아닙니다.

| 안전장치 | 역할 |
| --- | --- |
| `CHECK` | 잘못된 값 차단 |
| `FOREIGN KEY` | 존재하지 않는 데이터 참조 차단 |
| `UNIQUE` | 중복 데이터 차단 |
| 트랜잭션 | 여러 변경을 함께 확정 또는 취소 |
| 조건부 SQL | 변경 가능한 상태인지 확인 |
| 검증 SQL | 최종 결과가 업무 규칙과 맞는지 확인 |

따라서 **트랜잭션만 사용한다고 데이터가 자동으로 올바르게 되는 것은 아닙니다.**

잘못된 SQL도 `COMMIT`하면 그대로 확정될 수 있습니다.

---

## STEP 6. ACID를 어렵지 않게 이해해 봅시다

트랜잭션을 설명할 때 ACID라는 용어가 자주 등장합니다.

| 특성 | 의미 | 수강신청 예 |
| --- | --- | --- |
| Atomicity | 모두 성공하거나 모두 취소 | 좌석·신청·결제를 함께 처리 |
| Consistency | 규칙에 맞는 상태 유지 | 남은 좌석이 음수가 되지 않음 |
| Isolation | 동시에 실행되는 작업의 간섭 제어 | 마지막 좌석 경쟁 처리 |
| Durability | COMMIT된 데이터 유지 | 확정된 신청과 결제 보존 |

처음에는 영어 단어를 외우기보다 다음 흐름으로 이해하면 됩니다.

```text
Atomicity → 함께 처리
Consistency → 규칙 유지
Isolation → 동시 작업 제어
Durability → 확정 결과 유지
```

---

## STEP 7. 좌석을 무조건 감소시키면 위험합니다

다음 SQL을 생각해 보겠습니다.

```sql
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 301;
```

문법은 맞습니다.

하지만 남은 좌석이 이미 `0`이라면 어떻게 될까요?

따라서 업무 조건을 SQL에 포함시키는 것이 안전합니다.

```sql
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 301
  AND remaining_seats > 0;
```

이제 좌석이 있을 때만 변경됩니다.

---

## STEP 8. UPDATE가 몇 행을 변경했는지 확인해야 합니다

조건부 `UPDATE`에서는 SQL이 오류 없이 실행됐다고 해서 업무가 성공한 것은 아닙니다.

예를 들어 좌석이 없다면 다음 SQL은 오류 없이 **0행을 변경**할 수 있습니다.

```sql
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 301
  AND remaining_seats > 0;
```

따라서 기대 결과를 먼저 정해야 합니다.

```text
1행 변경 → 좌석 확보 성공
0행 변경 → 좌석 없음 또는 조건 불일치
2행 이상 → 데이터 구조 또는 조건 오류 의심
```

AI가 만든 SQL을 검토할 때도 **영향 행 수를 확인하는지** 살펴봐야 합니다.

---

## STEP 9. PostgreSQL RETURNING을 활용해 봅시다

PostgreSQL에서는 변경된 데이터를 바로 반환할 수 있습니다.

```sql
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 301
  AND remaining_seats > 0
RETURNING course_id, capacity, remaining_seats;
```

좌석 확보에 성공하면 변경된 행이 반환됩니다.

실패하면 결과 행이 없습니다.

따라서 `RETURNING`은 다음 두 가지를 동시에 확인하는 데 유용합니다.

```text
변경이 실제 발생했는가?
변경 후 값이 무엇인가?
```

---

## STEP 10. 수강신청과 결제를 같은 트랜잭션에 넣습니다

개념적인 흐름은 다음과 같습니다.

```sql
BEGIN;

-- 1. 좌석 확보
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 301
  AND remaining_seats > 0
RETURNING course_id, remaining_seats;

-- 2. 수강신청 생성
INSERT INTO transaction_lab.enrollments (
    student_id,
    course_id,
    status,
    recorded_amount
)
VALUES (
    101,
    301,
    '수강중',
    100000
);

-- 3. 결제 생성
-- 실제 실습에서는 생성된 enrollment_id를 연결합니다.

-- 4. 결과 검증
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 301;

-- 5. 정상일 때만 확정
COMMIT;
```

실제 Chapter 실습 SQL에서는 신청 ID와 결제 연결까지 안전하게 처리하도록 구성합니다.

핵심은 세 SQL을 각각 독립적으로 확정하지 않는 것입니다.

---

## STEP 11. 실패하면 ROLLBACK합니다

예를 들어 좌석은 감소했지만 결제 생성 과정에서 문제가 발견됐다고 가정해 보겠습니다.

```sql
BEGIN;

UPDATE ...;
INSERT ...;
INSERT ...;

-- 검증 결과 문제 발견
ROLLBACK;
```

그러면 해당 트랜잭션 안에서 아직 확정되지 않은 변경들이 취소됩니다.

```text
좌석 감소 취소
수강신청 생성 취소
결제 생성 취소
```

이것이 트랜잭션의 원자성(Atomicity)을 이해하는 가장 쉬운 사례입니다.

---

## STEP 12. ROLLBACK 후 ID 번호가 건너뛸 수 있습니다

초보자가 자주 당황하는 부분입니다.

`IDENTITY`나 시퀀스를 사용해 자동 번호를 만들었다면 트랜잭션을 `ROLLBACK`해도 사용된 번호가 다시 돌아오지 않을 수 있습니다.

예를 들어 다음과 같은 결과가 가능합니다.

```text
1
2
3
5
6
```

`4`가 없다고 해서 데이터가 손상된 것은 아닙니다.

자동 증가 ID는 일반적으로 다음 목적입니다.

```text
각 행을 유일하게 식별한다.
```

다음 목적이 아닙니다.

```text
번호가 절대로 빠지지 않도록 한다.
```

따라서 ID의 연속성을 업무 규칙으로 사용하면 안 됩니다.

---

## STEP 13. 동시에 마지막 좌석을 신청하면 어떻게 될까요?

사용자 A와 사용자 B가 거의 동시에 마지막 좌석 하나를 신청한다고 가정해 보겠습니다.

두 사용자가 모두 다음 값을 먼저 읽을 수 있습니다.

```text
remaining_seats = 1
```

각자 좌석이 있다고 판단하고 신청을 진행하면 문제가 생길 수 있습니다.

이것이 **동시성(Concurrency)** 문제입니다.

---

## STEP 14. SELECT ... FOR UPDATE로 행을 잠글 수 있습니다

PostgreSQL에서는 변경할 행을 트랜잭션 안에서 잠글 수 있습니다.

```sql
BEGIN;

SELECT course_id, capacity, remaining_seats
FROM transaction_lab.course_inventory
WHERE course_id = 301
FOR UPDATE;
```

이 행을 다른 트랜잭션도 `FOR UPDATE`로 잠그려고 하면 먼저 실행 중인 트랜잭션이 끝날 때까지 기다릴 수 있습니다.

그 뒤 최신 좌석 상태를 다시 확인하고 변경합니다.

```text
행 잠금
→ 최신 상태 확인
→ 조건부 UPDATE
→ 신청/결제 생성
→ 검증
→ COMMIT
```

Lock은 동시 작업을 안전하게 만드는 중요한 도구지만, 필요 이상으로 오래 유지하면 다른 작업을 기다리게 만들 수 있습니다.

---

## STEP 15. Deadlock도 알아둡시다

두 트랜잭션이 서로 상대방이 가진 Lock을 기다리는 상황을 Deadlock이라고 합니다.

예를 들어 다음과 같습니다.

```text
트랜잭션 A
→ 행 1 잠금
→ 행 2를 기다림

트랜잭션 B
→ 행 2 잠금
→ 행 1을 기다림
```

PostgreSQL은 이런 교착 상태를 감지하면 한 트랜잭션을 중단시킬 수 있습니다.

입문 단계에서는 다음 원칙을 기억하면 좋습니다.

```text
트랜잭션은 가능한 짧게 유지한다.
여러 자원을 잠글 때는 일관된 순서를 사용한다.
오류 발생 시 ROLLBACK하고 재시도 전략을 고려한다.
```

---

## STEP 16. SQL 오류가 나면 현재 트랜잭션 상태를 확인합니다

PostgreSQL에서는 트랜잭션 중 SQL 오류가 발생하면 현재 트랜잭션이 실패 상태가 될 수 있습니다.

이 상태에서는 다른 SQL을 계속 실행하기보다 먼저 정리해야 합니다.

```sql
ROLLBACK;
```

DBeaver에서 트랜잭션 실습을 하다가 이후 SQL이 계속 실패한다면 현재 트랜잭션이 오류 상태인지 확인해 보세요.

---

## STEP 17. SAVEPOINT로 일부 구간을 되돌릴 수 있습니다

트랜잭션 전체를 바로 취소하지 않고 중간 지점을 만들 수도 있습니다.

```sql
BEGIN;

INSERT INTO ...;

SAVEPOINT before_payment;

-- 추가 작업

ROLLBACK TO SAVEPOINT before_payment;

COMMIT;
```

`SAVEPOINT`는 긴 트랜잭션 안에서 특정 구간만 되돌릴 필요가 있을 때 사용할 수 있습니다.

처음 트랜잭션을 배울 때는 우선 `BEGIN → COMMIT/ROLLBACK`을 확실하게 이해한 뒤 `SAVEPOINT`로 확장하면 됩니다.

---

## STEP 18. 취소도 하나의 트랜잭션으로 생각합니다

수강신청 취소도 단순히 신청 상태 하나만 바꾸는 작업이 아닐 수 있습니다.

예를 들어 다음 작업이 함께 필요할 수 있습니다.

```text
신청 상태를 취소로 변경
결제 상태 변경 또는 환불 기록
남은 좌석 1개 복구
```

이 역시 하나의 업무 단위이므로 트랜잭션으로 처리해야 합니다.

```text
취소 관련 모든 변경 성공
→ COMMIT

하나라도 실패
→ ROLLBACK
```

트랜잭션은 INSERT할 때만 사용하는 기능이 아닙니다.

**여러 데이터 변경이 하나의 업무 의미를 가질 때** 사용합니다.

---

## STEP 19. COMMIT 전에 무엇을 검증해야 할까요?

수강신청 트랜잭션이라면 최소한 다음 내용을 확인할 수 있습니다.

```text
좌석이 정확히 1개 감소했는가?
수강신청이 정확히 1건 생성됐는가?
결제가 정확히 1건 생성됐는가?
신청과 결제가 올바르게 연결됐는가?
신청 금액과 결제 금액이 같은가?
중복 활성 신청이 생기지 않았는가?
```

즉 다음 흐름을 습관화합니다.

```text
BEGIN
→ 변경
→ 검증
→ COMMIT 또는 ROLLBACK
```

---

## AI 활용 실습 1. 트랜잭션 SQL을 만들어 보세요

ChatGPT 또는 Codex에 다음과 같이 요청해 보세요.

```text
PostgreSQL에서 온라인 강의 수강신청을 처리하려고 합니다.

업무는 다음 세 작업으로 구성됩니다.
1. 남은 좌석 1개 감소
2. 수강신청 생성
3. 결제 생성

세 작업이 모두 성공할 때만 확정되어야 합니다.
남은 좌석이 0이면 신청되지 않아야 합니다.

BEGIN, COMMIT, ROLLBACK을 사용하는
트랜잭션 SQL의 기본 구조를 작성하고
초보자가 이해할 수 있게 설명해 주세요.
```

AI가 작성한 결과에서 다음을 확인합니다.

```text
좌석 부족 조건이 있는가?
UPDATE 성공 여부를 확인하는가?
세 변경이 같은 트랜잭션 안에 있는가?
COMMIT 전에 결과를 검증하는가?
```

---

## AI 활용 실습 2. 동시성 문제를 검토해 보세요

다음 프롬프트를 사용해 보세요.

```text
PostgreSQL에서 남은 좌석이 1개인 강의를
두 사용자가 동시에 신청한다고 가정합니다.

단순히 SELECT로 remaining_seats를 확인한 뒤
UPDATE하는 방식에서 어떤 문제가 발생할 수 있는지 설명하고,

SELECT ... FOR UPDATE 또는 조건부 UPDATE를 사용해
안전하게 처리하는 방법을 초보자 눈높이에서 설명해 주세요.

마지막에는 AI가 만든 SQL을 검증할 체크리스트도 작성해 주세요.
```

중요한 것은 AI의 SQL이 실행된다는 사실만 확인하는 것이 아닙니다.

**동시에 두 번 실행했을 때도 업무 규칙이 지켜지는지** 생각해야 합니다.

---

## 오늘의 핵심 정리

이번 Chapter에서 꼭 기억할 내용입니다.

```text
트랜잭션
→ 여러 변경을 하나의 업무 단위로 처리

BEGIN
→ 트랜잭션 시작

COMMIT
→ 변경 내용 확정

ROLLBACK
→ 아직 확정하지 않은 변경 취소

조건부 UPDATE
→ 변경 가능한 상태에서만 데이터 수정

RETURNING
→ 변경된 행과 값을 즉시 확인

SELECT ... FOR UPDATE
→ 동시 작업에서 대상 행 잠금

SAVEPOINT
→ 트랜잭션 중간 복구 지점
```

그리고 가장 중요한 습관은 다음입니다.

```text
변경 전 상태 확인
→ BEGIN
→ 업무 조건 확인
→ 데이터 변경
→ 영향 행 수 확인
→ 최종 상태 검증
→ 정상일 때 COMMIT
→ 문제가 있으면 ROLLBACK
```

AI 시대에도 이 판단은 개발자가 해야 합니다.

```text
AI가 SQL을 만들 수 있다.
하지만 어떤 변경을 하나의 트랜잭션으로 묶을지,
어떤 상태를 성공으로 볼지,
COMMIT해도 되는지는 사람이 검증해야 한다.
```

---

## 다음 시간에는

다음 Chapter에서는 SQL이 느려졌을 때 원인을 찾고 개선하는 방법을 배웁니다.

PostgreSQL의 **인덱스(Index), `EXPLAIN`, `EXPLAIN ANALYZE`**를 사용해 쿼리 실행 계획을 확인하고, 인덱스를 무조건 만드는 것이 아니라 실제 실행 결과를 기준으로 성능을 판단하는 방법을 실습합니다.

---

## 관련 글

- Chapter 08. JOIN과 집계로 서비스 질문에 답하기
- Chapter 10. 인덱스와 실행 계획으로 SQL 성능 이해하기

---

#PostgreSQL #트랜잭션 #SQL #데이터베이스 #COMMIT #ROLLBACK #ACID #DBeaver #ChatGPT #데이터베이스강의