# Chapter 09. 트랜잭션으로 데이터 정합성 지키기

---

## 이 장에서 살펴볼 내용

Chapter 08에서는 `course_project` 데이터를 JOIN하고 집계해 결과를 검산했습니다. 이번 장에서는 조회가 아니라 여러 변경이 하나의 업무 단위로 함께 성공하거나 실패하도록 만드는 **트랜잭션**을 다룹니다.

```text
업무 단위 정의
→ 변경 전 상태 확인
→ BEGIN
→ 좌석 확보·신청·결제 변경
→ 영향 행 수와 관계 검증
→ 정상: COMMIT
→ 문제: ROLLBACK
→ 확정 후 정합성 재검증
→ 동시 실행과 잠금 검토
```

이 장에서는 다음 내용을 학습합니다.

- 트랜잭션이 필요한 이유
- `BEGIN`, `COMMIT`, `ROLLBACK`
- ACID의 기본 의미
- 제약조건·트랜잭션·업무 검증의 역할 차이
- 조건부 좌석 차감과 영향 행 수
- 신청·결제·좌석 변경의 원자적 처리
- 실패 상황과 `ROLLBACK`
- PostgreSQL에서 오류가 난 트랜잭션의 처리
- `SAVEPOINT`의 기본 개념
- `SELECT ... FOR UPDATE`, Lock과 Deadlock
- AI가 만든 트랜잭션 SQL 검토

> **핵심 원칙**
>
> 관련 변경은 같은 트랜잭션 안에서 실행하고, 영향 행 수와 최종 상태가 모두 맞을 때만 `COMMIT`합니다.

---

## 1. 왜 트랜잭션이 필요한가

온라인 강의 수강신청을 확정하는 업무에 다음 세 변경이 필요하다고 가정합니다.

```text
1. 남은 좌석 1개 차감
2. 수강신청 행 생성
3. 결제 행 생성
```

![트랜잭션이 필요한 이유](../../images/chapter09/ch09_01_transaction_need.svg)

그림 9-1 트랜잭션이 필요한 이유

세 작업을 각각 독립적으로 확정하면 중간 실패가 남을 수 있습니다.

```text
좌석만 감소하고 신청은 없음
신청은 있지만 결제가 없음
결제는 있지만 연결된 신청이 없음
신청·결제는 있지만 좌석은 감소하지 않음
```

트랜잭션은 이 변경들을 하나의 성공·실패 경계로 묶습니다.

```text
모든 변경과 검증 성공 → COMMIT
하나라도 실패하거나 결과가 예상과 다름 → ROLLBACK
```

트랜잭션은 SQL을 단순히 여러 줄 묶는 문법이 아닙니다. 하나의 업무가 어디에서 시작하고 어디에서 확정되는지를 정하는 설계입니다.

---

## 2. Chapter 07 프로젝트를 보호하는 실습 구조

기존 방식처럼 `students`, `courses`, `enrollments`를 삭제하고 다시 만들면 Chapter 07·08의 프로젝트 데이터가 손상됩니다.

Chapter 09에서는 별도의 실습 스키마를 사용합니다.

```text
course_project
- students
- instructors
- courses
- enrollments

transaction_lab
- course_inventory
- enrollments
- payments
```

`transaction_lab`은 좌석·트랜잭션 실험 상태만 저장합니다. 학생과 강의 마스터는 Chapter 07의 데이터를 외래키로 참조합니다.

```text
transaction_lab.course_inventory.course_id
→ course_project.courses.id

transaction_lab.enrollments.student_id
→ course_project.students.id

transaction_lab.enrollments.course_id
→ course_project.courses.id

transaction_lab.payments.enrollment_id
→ transaction_lab.enrollments.id
```

이 구조의 장점은 다음과 같습니다.

```text
Chapter 07·08 데이터가 변경되지 않는다.
트랜잭션 실습만 독립적으로 초기화할 수 있다.
같은 학생·강의 ID를 사용해 도메인 연속성을 유지한다.
삭제 대상을 transaction_lab으로 제한할 수 있다.
```

---

## 3. 실습 파일과 실행 순서

```text
code/chapter09/
├── 01_transaction_lab_schema.sql
├── 02_transaction_lab_seed.sql
├── 03_commit_transaction.sql
├── 04_rollback_transaction.sql
├── 05_commit_and_sold_out.sql
├── 06_transaction_validation.sql
├── 07_concurrency_two_sessions.sql
├── reset_transaction_lab.sql
├── transaction_consistency_practice.sql
└── README.md
```

권장 실행 순서:

```text
01 schema
→ 02 seed
→ 03 성공 COMMIT
→ 04 실패 가정 ROLLBACK
→ 05 두 번째 COMMIT과 좌석 부족 처리
→ 06 최종 검증
→ 07 두 세션 동시성 실습은 선택
```

`transaction_consistency_practice.sql`은 기존 링크 호환용 안내·상태 확인 파일입니다.

트랜잭션 실습은 같은 DBeaver SQL Editor와 같은 연결 세션에서 문장 순서대로 실행합니다. 다른 연결에서 `COMMIT`이나 `ROLLBACK`을 실행하면 현재 트랜잭션을 제어할 수 없습니다.

---

## 4. 트랜잭션의 기본 흐름

![BEGIN부터 COMMIT·ROLLBACK까지](../../images/chapter09/ch09_02_transaction_basic_flow.svg)

그림 9-2 BEGIN부터 COMMIT·ROLLBACK까지

| 명령 | 역할 | 주의점 |
| --- | --- | --- |
| `BEGIN` | 현재 세션에서 트랜잭션 시작 | 관련 변경 전에 실행 |
| `COMMIT` | 현재 트랜잭션의 변경 확정 | 검증이 끝난 뒤 실행 |
| `ROLLBACK` | 아직 확정되지 않은 변경 취소 | 오류·검증 실패 시 실행 |

기본 패턴은 다음과 같습니다.

```sql
-- 변경 전 상태 확인
SELECT ...;

BEGIN;

-- 여러 변경 SQL
UPDATE ...;
INSERT ...;

-- COMMIT 전 검증
SELECT ...;

-- 둘 중 하나만 선택
COMMIT;
-- ROLLBACK;
```

이미 `COMMIT`된 변경은 같은 트랜잭션의 `ROLLBACK`으로 되돌릴 수 없습니다. `COMMIT`은 확인 버튼처럼 생각해야 합니다.

---

## 5. 데이터 정합성과 안전장치의 역할

데이터 정합성은 여러 값과 관계가 정의된 업무 규칙과 모순되지 않는 상태입니다.

![데이터 정합성이 깨지는 예](../../images/chapter09/ch09_03_consistency_problem_examples.svg)

그림 9-3 데이터 정합성이 깨지는 예

이 장의 단순 규칙은 다음과 같습니다.

```text
remaining_seats는 0 이상 capacity 이하다.
payment는 정확히 하나의 lab enrollment를 참조한다.
수강중 신청에는 결제 행이 있어야 한다.
enrollment.paid_amount와 payment.amount는 같아야 한다.
좌석을 사용하는 lab enrollment 수와 사용 좌석 수가 같아야 한다.
```

| 안전장치 | 담당 역할 | 예 |
| --- | --- | --- |
| 제약조건 | 한 행의 값과 참조 오류 차단 | 음수 좌석, 없는 FK, 음수 금액 |
| 트랜잭션 | 여러 변경의 확정·취소 경계 | 좌석·신청·결제 함께 처리 |
| 업무 조건 | 변경 가능 여부 판단 | 남은 좌석이 0보다 큰가? |
| 영향 행 수 | 조건부 변경의 성공 확인 | 좌석 UPDATE가 1행인가? |
| 검증 SELECT | 여러 테이블의 최종 의미 확인 | 신청·결제·좌석 일치 |

트랜잭션만 사용한다고 정합성이 자동 보장되지는 않습니다. 잘못된 SQL 세 개도 하나의 트랜잭션으로 함께 `COMMIT`할 수 있습니다.

---

## 6. ACID를 업무 사례로 이해하기

![ACID의 네 가지 기본 특성](../../images/chapter09/ch09_04_acid_overview.svg)

그림 9-4 ACID의 네 가지 기본 특성

| 특성 | 입문 수준 의미 | 수강신청 사례 |
| --- | --- | --- |
| Atomicity | 모두 반영되거나 모두 취소 | 좌석·신청·결제 |
| Consistency | 전후 상태가 정의된 규칙을 만족 | 좌석 범위·결제 연결 |
| Isolation | 동시 작업의 간섭을 정해진 수준에서 제어 | 마지막 좌석 경쟁 |
| Durability | 확정된 변경을 장애 이후에도 유지 | COMMIT된 신청·결제 |

ACID를 과도하게 단순화해서는 안 됩니다.

```text
Atomicity가 업무 규칙의 옳고 그름을 판단하지 않는다.
Consistency에는 제약조건과 올바른 업무 로직이 필요하다.
Isolation의 가시성과 충돌 방식은 격리 수준에 따라 달라진다.
Durability는 DBMS의 로그·저장·복구 기능과 연결된다.
```

---

## 7. 실습 초기 상태

`01_transaction_lab_schema.sql`은 다음 테이블을 만듭니다.

```text
transaction_lab.course_inventory(
    course_id PK/FK,
    capacity,
    remaining_seats
)

transaction_lab.enrollments(
    id PK,
    student_id FK,
    course_id FK,
    enrolled_at,
    status,
    paid_amount
)

transaction_lab.payments(
    id PK,
    enrollment_id UNIQUE FK,
    amount,
    paid_at
)
```

`02_transaction_lab_seed.sql`은 Chapter 07의 강의 301~303에 좌석 정보를 설정합니다.

| course_id | 강의 | capacity | remaining_seats |
| ---: | --- | ---: | ---: |
| 301 | 데이터베이스 입문 | 2 | 2 |
| 302 | 정규화 실습 | 1 | 1 |
| 303 | 파이썬 데이터 분석 | 1 | 1 |

초기 행 수:

```text
course_inventory 3
lab enrollments 0
payments 0
```

Chapter 07의 `course_project.enrollments` 5건은 그대로 유지됩니다. 이 장의 신청은 `transaction_lab.enrollments`에 별도로 저장됩니다.

---

## 8. 성공 트랜잭션: 좌석·신청·결제를 함께 확정한다

![수강신청·결제·좌석 변경 트랜잭션](../../images/chapter09/ch09_05_enrollment_payment_transaction.svg)

그림 9-5 수강신청·결제·좌석 변경 트랜잭션

학생 101이 강의 301을 신청하는 사례입니다.

### 변경 전 확인

```sql
SELECT
    ci.course_id,
    c.title,
    c.price,
    ci.capacity,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
WHERE ci.course_id = 301;
```

기대 잔여 좌석은 `2`입니다.

### 트랜잭션 시작과 행 잠금

```sql
BEGIN;

SELECT
    ci.course_id,
    c.title,
    c.price,
    ci.remaining_seats
FROM transaction_lab.course_inventory AS ci
JOIN course_project.courses AS c
    ON c.id = ci.course_id
WHERE ci.course_id = 301
FOR UPDATE OF ci;
```

`FOR UPDATE OF ci`는 좌석 상태 행을 수정 대상으로 잠급니다. 같은 좌석 행을 변경하려는 다른 트랜잭션은 대기할 수 있습니다.

### 조건부 변경과 연결 INSERT

실습 파일은 하나의 CTE 문장으로 좌석 확보 성공 여부를 후속 INSERT에 전달합니다.

```sql
WITH seat AS (
    UPDATE transaction_lab.course_inventory AS ci
    SET remaining_seats = ci.remaining_seats - 1
    FROM course_project.courses AS c
    WHERE ci.course_id = c.id
      AND ci.course_id = 301
      AND ci.remaining_seats > 0
    RETURNING ci.course_id, c.price
),
new_enrollment AS (
    INSERT INTO transaction_lab.enrollments (
        id, student_id, course_id,
        enrolled_at, status, paid_amount
    )
    SELECT
        9001, 101, course_id,
        CURRENT_TIMESTAMP, '수강중', price
    FROM seat
    RETURNING id, paid_amount
)
INSERT INTO transaction_lab.payments (
    id, enrollment_id, amount, paid_at
)
SELECT
    9901, id, paid_amount, CURRENT_TIMESTAMP
FROM new_enrollment
RETURNING id, enrollment_id, amount;
```

좌석 UPDATE가 1행이면 신청과 결제가 각각 1건 생성됩니다. 좌석이 없어 UPDATE가 0행이면 `seat` CTE가 비어 후속 두 INSERT도 0건이 됩니다.

이 방식은 수동으로 “0행인데도 INSERT를 실행하는” 실수를 줄여 줍니다. 그래도 반환 행과 최종 상태를 확인해야 합니다.

### COMMIT 전 검증

```sql
SELECT
    e.id AS enrollment_id,
    e.student_id,
    e.course_id,
    e.status,
    e.paid_amount,
    p.id AS payment_id,
    p.amount,
    ci.remaining_seats
FROM transaction_lab.enrollments AS e
JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
JOIN transaction_lab.course_inventory AS ci
    ON ci.course_id = e.course_id
WHERE e.id = 9001;
```

다음을 확인합니다.

```text
신청 1건
결제 1건
두 금액 100000
강의 301 잔여 좌석 1
```

결과가 맞으면 확정합니다.

```sql
COMMIT;
```

---

## 9. 실패를 가정한 ROLLBACK

학생 102가 강의 302를 신청하는 변경을 트랜잭션 내부에서 실행한 뒤, 외부 결제 승인 실패를 가정하고 취소합니다.

![ROLLBACK 전후 상태 비교](../../images/chapter09/ch09_06_rollback_before_after.svg)

그림 9-6 ROLLBACK 전후 상태 비교

```sql
BEGIN;

-- 강의 302 좌석 1 → 0
-- lab enrollment 9002 생성
-- payment 9902 생성
```

같은 세션의 트랜잭션 내부에서는 임시 상태가 보입니다.

| 대상 | ROLLBACK 전 임시 상태 |
| --- | --- |
| course 302 | remaining_seats 0 |
| enrollment 9002 | 1행 존재 |
| payment 9902 | 1행 존재 |

결제 승인 실패를 가정합니다.

```sql
ROLLBACK;
```

ROLLBACK 후 기대 상태:

```text
course 302 remaining_seats = 1
lab enrollment 9002 = 없음
payment 9902 = 없음
```

트랜잭션 내부에서 임시 행이 보였다는 사실과 최종 확정되었다는 사실은 다릅니다.

---

## 10. 좌석 부족은 SQL 오류가 아니라 0행일 수 있다

ROLLBACK 후 학생 103의 강의 302 신청을 정상 `COMMIT`하면 잔여 좌석은 0이 됩니다.

그 뒤 다른 학생이 같은 강의를 신청하려고 하면 다음 UPDATE는 0행을 반환합니다.

```sql
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 302
  AND remaining_seats > 0
RETURNING course_id, remaining_seats;
```

```text
0행 반환
≠ PostgreSQL 문법 오류
≠ 자동 ROLLBACK
≠ 후속 작업 성공
```

CTE로 후속 INSERT를 좌석 UPDATE 결과에 연결하면 신청과 결제도 0건이 됩니다. 해당 트랜잭션은 변경이 없더라도 업무상 좌석 확보 실패이므로 `ROLLBACK`으로 종료합니다.

```sql
ROLLBACK;
```

애플리케이션에서는 반환 행 수가 0이면 “정원 마감”과 같은 업무 결과로 처리하고 후속 작업을 진행하지 않아야 합니다.

---

## 11. PostgreSQL에서 문장 오류가 발생한 트랜잭션

조건 불충족으로 UPDATE가 0행인 것과 SQL 오류가 발생한 것은 다릅니다.

PostgreSQL에서는 트랜잭션 안의 문장이 제약조건 오류 등으로 실패하면 현재 트랜잭션이 오류 상태가 됩니다. 이후 일반 SQL은 다음과 유사한 메시지로 실행되지 않을 수 있습니다.

```text
current transaction is aborted
```

이 경우 기본 대응은 다음과 같습니다.

```sql
ROLLBACK;
```

전체 작업을 취소하지 않고 일부 단계만 되돌릴 필요가 있다면 미리 `SAVEPOINT`를 설정할 수 있습니다.

```sql
BEGIN;

SAVEPOINT before_optional_step;

-- 오류 가능성이 있는 선택 단계

ROLLBACK TO SAVEPOINT before_optional_step;

-- 트랜잭션을 계속 진행할 수 있음
COMMIT;
```

`SAVEPOINT`는 잘못된 업무 설계를 숨이는 기능이 아닙니다. 어떤 실패를 부분 복구하고 어떤 실패에서 전체 취소할지 트랜잭션 경계와 함께 설계해야 합니다.

---

## 12. 최종 정합성 검증

두 성공 트랜잭션과 한 ROLLBACK, 좌석 부족 테스트를 마친 최종 상태는 다음과 같습니다.

| 항목 | 기대 결과 |
| --- | ---: |
| lab enrollments | 2 |
| payments | 2 |
| course 301 remaining_seats | 1 |
| course 302 remaining_seats | 0 |
| course 303 remaining_seats | 1 |

### 좌석 범위 위반 확인

```sql
SELECT *
FROM transaction_lab.course_inventory
WHERE remaining_seats < 0
   OR remaining_seats > capacity;
```

기대 결과: `0행`

### 결제 누락·금액 불일치 확인

```sql
SELECT
    e.id AS enrollment_id,
    e.paid_amount,
    p.amount AS payment_amount
FROM transaction_lab.enrollments AS e
LEFT JOIN transaction_lab.payments AS p
    ON p.enrollment_id = e.id
WHERE e.status = '수강중'
  AND (
      p.id IS NULL
      OR e.paid_amount <> p.amount
  );
```

기대 결과: `0행`

### 좌석 사용량 확인

```sql
SELECT
    ci.course_id,
    ci.capacity,
    ci.remaining_seats,
    COUNT(e.id) FILTER (WHERE e.status = '수강중')
        AS active_enrollment_count,
    ci.capacity - ci.remaining_seats AS used_seats
FROM transaction_lab.course_inventory AS ci
LEFT JOIN transaction_lab.enrollments AS e
    ON e.course_id = ci.course_id
GROUP BY ci.course_id, ci.capacity, ci.remaining_seats
ORDER BY ci.course_id;
```

각 강의에서 `active_enrollment_count = used_seats`인지 확인합니다.

이 검증은 이 장의 단순 정책에만 적용됩니다. 취소·환불·좌석 복구·예약 만료가 추가되면 규칙과 SQL도 함께 변경해야 합니다.

---

## 13. Lock과 동시성

잔여 좌석이 1인 강의에 두 사용자가 동시에 신청하면 둘 다 같은 초기 값을 읽을 수 있습니다.

![동시 좌석 신청과 Lock](../../images/chapter09/ch09_07_concurrency_lock_deadlock.svg)

그림 9-7 동시 좌석 신청과 Lock

두 SQL Editor를 서로 다른 연결 세션으로 열고 다음 흐름을 관찰할 수 있습니다.

### 세션 A

```sql
BEGIN;

SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 303
FOR UPDATE;
```

세션 A는 트랜잭션을 끝내지 않고 잠시 유지합니다.

### 세션 B

```sql
BEGIN;

SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 303
FOR UPDATE;
```

세션 B는 세션 A가 `COMMIT` 또는 `ROLLBACK`할 때까지 대기할 수 있습니다.

세션 A가 좌석을 차감하고 `COMMIT`한 뒤 세션 B는 최신 좌석 값을 확인해야 합니다. 0이면 신청을 진행하지 않습니다.

트랜잭션은 사용자 입력을 기다리며 오래 열어 두지 않고 가능한 짧게 유지합니다.

---

## 14. Lock 대기와 Deadlock은 다르다

한 트랜잭션이 다른 트랜잭션의 한 행 잠금 해제를 기다리는 것은 일반적인 Lock 대기일 수 있습니다.

Deadlock은 서로가 가진 잠금을 기다리는 순환 구조입니다.

```text
트랜잭션 A: course 301 잠금 → course 302 대기
트랜잭션 B: course 302 잠금 → course 301 대기
```

PostgreSQL은 Deadlock을 감지하면 한 트랜잭션을 오류로 종료할 수 있습니다.

Deadlock 가능성을 낮추는 기본 원칙:

```text
여러 행을 잠글 때 항상 같은 순서로 접근한다.
트랜잭션을 짧게 유지한다.
불필요한 행을 잠그지 않는다.
오류 발생 시 애플리케이션의 재시도 정책을 검토한다.
```

실제 Deadlock 유발 SQL은 기본 실습에서 자동 실행하지 않습니다.

---

## 15. 트랜잭션 경계를 어디에 둘 것인가

트랜잭션이 너무 짧으면 하나의 업무가 부분 확정될 수 있고, 너무 길면 잠금 유지 시간이 길어집니다.

다음은 일반적으로 같은 트랜잭션에 포함할 후보입니다.

```text
좌석 확보
수강신청 생성
결제 성공 기록
관련 내부 상태 변경
```

다음 작업을 트랜잭션 안에서 오래 기다리면 위험할 수 있습니다.

```text
사용자의 추가 입력 대기
외부 결제창 응답을 무기한 대기
느린 외부 API 호출
대용량 파일 처리
```

외부 결제는 데이터베이스 트랜잭션만으로 전체 세계를 원자적으로 묶을 수 없습니다. 실제 시스템에서는 결제 승인 ID, 상태 전이, 재시도, 멱등성 키와 보상 처리 같은 별도 설계가 필요합니다.

이 장은 성공 결제 결과가 이미 확보되었다고 가정한 단순 실습입니다.

---

## 16. AI가 만든 트랜잭션 SQL 검토

![AI 생성 트랜잭션 SQL 검토 흐름](../../images/chapter09/ch09_08_ai_transaction_review_flow.svg)

그림 9-8 AI 생성 트랜잭션 SQL 검토 흐름

AI에게 다음 정보를 함께 제공합니다.

```text
업무 단위: 좌석 차감 + lab enrollment 생성 + payment 생성
성공 조건: 좌석 UPDATE 1행, 신청 1행, 결제 1행, 금액 일치
실패 조건: 좌석 0행, SQL 오류, 결제 검증 실패
삭제·변경 대상: transaction_lab만
기존 course_project 데이터는 변경 금지
```

검토표:

| 검토 항목 | 확인 질문 |
| --- | --- |
| 경계 | BEGIN과 최종 COMMIT/ROLLBACK 범위가 업무 단위와 맞는가? |
| 격리 | 기존 `course_project` 데이터를 덮어쓰지 않는가? |
| 좌석 | `remaining_seats > 0`과 영향 행 수를 확인하는가? |
| 원자성 | 좌석 성공 결과에 신청·결제 INSERT가 연결되는가? |
| 관계 | payment가 enrollment ID를 참조하는가? |
| 검증 | COMMIT 전에 좌석·신청·결제를 함께 확인하는가? |
| 오류 | SQL 오류 후 ROLLBACK 또는 SAVEPOINT 처리가 있는가? |
| 잠금 | 동시 마지막 좌석 경쟁을 고려하는가? |
| 장기 작업 | 외부 API 대기를 DB 트랜잭션 안에 오래 두지 않는가? |
| 재실행 | 중복 실행과 멱등성 위험을 설명하는가? |

대표적인 잘못된 예:

```text
좌석 UPDATE 결과가 0행이어도 신청 INSERT 실행
신청을 COMMIT한 뒤 별도 트랜잭션에서 결제 INSERT
모든 실습 테이블을 DROP하고 course_project를 덮어씀
COMMIT 전에 결과 조회 없음
오류 후 aborted 트랜잭션에서 계속 SQL 실행
동시성 문제를 단순 SELECT로만 해결
```

AI SQL은 실행 가능 여부뿐 아니라 실패 경로와 복구 상태까지 검토해야 합니다.

---

## 17. 자주 하는 실수

### 실수 1. 트랜잭션이 업무 규칙을 자동으로 판단한다고 생각한다

업무 조건과 검증 SQL을 별도로 설계합니다.

### 실수 2. UPDATE 0행을 성공으로 간주한다

오류가 없다는 뜻일 뿐 좌석 확보 성공은 아닙니다.

### 실수 3. 변경을 먼저 COMMIT하고 나중에 확인한다

COMMIT 전 같은 세션에서 결과를 검증합니다.

### 실수 4. SQL 오류 후 트랜잭션을 계속 사용한다

오류 상태에서는 `ROLLBACK` 또는 적절한 `ROLLBACK TO SAVEPOINT`가 필요합니다.

### 실수 5. 트랜잭션을 여러 연결에 나누어 실행한다

BEGIN·변경·COMMIT은 같은 세션에서 실행해야 합니다.

### 실수 6. 기존 프로젝트 테이블을 실습용으로 삭제한다

`transaction_lab`만 초기화합니다.

### 실수 7. Lock 대기를 Deadlock이라고 부른다

단순 대기와 순환 대기를 구분합니다.

### 실수 8. 외부 API 응답을 기다리며 트랜잭션을 오래 유지한다

트랜잭션 경계와 외부 시스템 연동 방식을 별도로 설계합니다.

---

## 18. 스스로 확인하기

1. 트랜잭션의 업무 경계란 무엇인가요?
2. 제약조건과 트랜잭션의 역할 차이는 무엇인가요?
3. `COMMIT`과 `ROLLBACK`의 차이는 무엇인가요?
4. 좌석 UPDATE 0행과 SQL 오류는 어떻게 다른가요?
5. CTE로 좌석 UPDATE 결과에 INSERT를 연결한 이유는 무엇인가요?
6. PostgreSQL 트랜잭션이 aborted 상태가 되면 어떻게 처리해야 하나요?
7. `SAVEPOINT`는 언제 사용할 수 있나요?
8. `SELECT ... FOR UPDATE`는 어떤 행을 보호하나요?
9. Lock 대기와 Deadlock의 차이는 무엇인가요?
10. 외부 결제 API를 데이터베이스 트랜잭션 안에서 오래 기다리면 안 되는 이유는 무엇인가요?
11. AI 트랜잭션 SQL을 검토할 때 실패 경로가 중요한 이유는 무엇인가요?

---

## 19. 핵심 정리

```text
1. 트랜잭션은 하나의 업무를 구성하는 여러 변경의 성공·실패 경계다.
2. 제약조건은 값과 관계를, 트랜잭션은 여러 변경의 원자성을 담당한다.
3. COMMIT 전 영향 행 수와 최종 상태를 확인한다.
4. 좌석 UPDATE 0행은 오류가 아니라 업무상 실패일 수 있다.
5. 조건부 UPDATE 결과에 후속 INSERT를 연결하면 부분 반영 위험을 줄일 수 있다.
6. ROLLBACK은 아직 확정되지 않은 변경을 취소한다.
7. SQL 오류 후 PostgreSQL 트랜잭션은 ROLLBACK이 필요할 수 있다.
8. SAVEPOINT는 트랜잭션 일부 복구 경계를 제공한다.
9. 동시 변경에는 행 잠금과 최신 상태 재확인이 필요하다.
10. AI SQL은 정상 경로뿐 아니라 실패·복구·재실행 경로까지 검토한다.
```

이 장에서 기억할 문장은 다음과 같습니다.

```text
변경이 실행됐는지가 아니라,
업무 단위 전체가 검증된 상태로 확정됐는지를 확인한다.
```

---

## 20. 다음 장에서는

Chapter 10에서는 같은 온라인 강의 도메인의 조회 패턴을 바탕으로 인덱스와 실행 계획을 살펴봅니다.

```text
어떤 WHERE·JOIN·ORDER BY가 느린가?
인덱스는 어떤 탐색을 줄이는가?
EXPLAIN은 무엇을 보여 주는가?
인덱스가 많으면 왜 쓰기 비용이 증가하는가?
AI가 제안한 인덱스를 어떻게 검증하는가?
```

트랜잭션이 변경의 정확성을 지키는 장치라면, 인덱스는 필요한 데이터를 효율적으로 찾도록 돕는 구조입니다.
