# Chapter 09. 트랜잭션과 데이터 정합성

---

## 이 장에서 살펴볼 내용

이 장에서는 여러 데이터베이스 변경을 하나의 논리적 단위로 처리하는 **트랜잭션**을 살펴봅니다.

Chapter 08에서는 `students`, `instructors`, `courses`, `enrollments`를 JOIN하여 수강신청 현황과 결제금액을 조회했습니다. Chapter 09에서는 같은 온라인 강의 도메인에 정원과 잔여 좌석, 결제 기록을 추가하여 여러 변경을 안전하게 처리하는 방법을 다룹니다.

이 장에서 다룰 내용은 다음과 같습니다.

- 트랜잭션이 필요한 이유
- `BEGIN`, `COMMIT`, `ROLLBACK`
- 데이터 정합성과 안전장치의 역할
- ACID의 기본 의미
- 수강신청·결제·잔여 좌석 변경
- 실패와 `ROLLBACK`
- 동시성·Lock·Deadlock 기초
- AI가 만든 트랜잭션 SQL 검토

트랜잭션은 여러 SQL을 단순히 묶는 문법이 아닙니다. 하나의 업무를 구성하는 변경이 일부만 반영되지 않도록 성공과 실패의 경계를 정하는 장치입니다.

---

## 1. 왜 트랜잭션을 배워야 하는가

온라인 강의에서 수강신청을 확정하려면 다음 세 변경이 서로 맞아야 합니다.

```text
- enrollments에 수강신청 저장
- payments에 결제 기록 저장
- courses.remaining_seats 1 감소
```

![트랜잭션이 필요한 이유](../../images/chapter09/ch09_01_transaction_need.svg)

그림 9-1 트랜잭션이 필요한 이유

신청만 있고 결제가 없거나, 결제만 있고 연결된 신청이 없거나, 좌석만 줄어들면 데이터가 업무 규칙과 모순됩니다. 세 작업을 하나의 트랜잭션으로 처리하면 모두 정상일 때만 확정하고, 문제가 있으면 모두 취소할 수 있습니다.

---

## 2. 트랜잭션의 기본 흐름

트랜잭션의 기본 흐름은 변경 전 확인, 트랜잭션 시작, 변경 실행, 결과 검증, 확정 또는 취소입니다.

![BEGIN부터 COMMIT·ROLLBACK까지](../../images/chapter09/ch09_02_transaction_basic_flow.svg)

그림 9-2 BEGIN부터 COMMIT·ROLLBACK까지

| 명령 | 의미 | 실행 시점 |
| --- | --- | --- |
| `BEGIN` | 현재 세션에서 트랜잭션 시작 | 관련 변경을 실행하기 전 |
| `COMMIT` | 현재 트랜잭션의 변경 확정 | 결과가 예상과 일치할 때 |
| `ROLLBACK` | 아직 확정되지 않은 현재 트랜잭션의 변경 취소 | 오류 또는 검증 실패 시 |

```sql
SELECT * FROM courses WHERE id = 1;

BEGIN;

-- 여러 변경 SQL

-- COMMIT 전에 결과 확인
SELECT * FROM courses WHERE id = 1;

-- 둘 중 하나만 선택
COMMIT;
-- ROLLBACK;
```

이미 `COMMIT`한 변경은 같은 트랜잭션의 `ROLLBACK`으로 되돌릴 수 없습니다. 따라서 `COMMIT` 전에 영향 행 수와 실제 결과를 확인해야 합니다.

---

## 3. 데이터 정합성이란 무엇인가

데이터 정합성은 여러 테이블과 상태가 정해진 업무 규칙과 모순되지 않는 상태를 의미합니다.

![데이터 정합성이 깨지는 예](../../images/chapter09/ch09_03_consistency_problem_examples.svg)

그림 9-3 데이터 정합성이 깨지는 예

이 장의 단순 예제에서는 다음 규칙을 사용합니다.

```text
- remaining_seats는 0 이상 capacity 이하여야 한다.
- payments는 반드시 하나의 enrollments 행을 참조한다.
- 수강중 상태의 신청에는 결제 기록이 있어야 한다.
- enrollments.paid_amount와 payments.amount는 일치해야 한다.
```

단, 상태가 `신청`인 행의 `paid_amount = 0`은 결제 전 상태로 허용될 수 있습니다. 값 하나만 보고 오류라고 단정하지 않고 상태와 관련 테이블을 함께 확인해야 합니다.

| 안전장치 | 담당 역할 | 예시 |
| --- | --- | --- |
| 제약조건 | 잘못된 값이나 참조를 DB 수준에서 차단 | 음수 금액, 없는 FK, 음수·초과 좌석 |
| 트랜잭션 | 여러 변경을 하나의 성공·실패 단위로 처리 | 신청·결제·좌석 차감 |
| 업무 검증 | 여러 테이블과 상태 사이의 업무 규칙 확인 | 결제금액과 상태 일치 |
| 실행 후 `SELECT` | 실제 결과가 예상과 같은지 확인 | 영향 행 수, 잔여 좌석, 결제 기록 |

트랜잭션은 여러 작업을 함께 확정하거나 취소하지만 업무 규칙 자체를 자동으로 정의하지는 않습니다. 제약조건, 올바른 SQL, 업무 검증을 함께 사용해야 합니다.

---

## 4. COMMIT과 ROLLBACK

`COMMIT`은 검증이 끝난 변경을 최종 확정합니다. `ROLLBACK`은 현재 트랜잭션에서 아직 확정되지 않은 변경을 취소합니다.

```text
결과가 예상과 일치함 → COMMIT
오류 또는 업무 규칙 불일치 → ROLLBACK
```

같은 세션에서는 `ROLLBACK` 전의 임시 변경을 조회할 수 있습니다. 그러나 `COMMIT`되지 않은 변경은 최종 확정 상태가 아닙니다. `ROLLBACK` 후에는 다시 `SELECT`하여 원래 상태로 복구되었는지 확인합니다.

---

## 5. 실습에 사용할 확장 테이블 구조

Chapter 09는 Chapter 07·08과 같은 온라인 강의 도메인을 사용하지만, 트랜잭션 실습을 위해 강의 정원과 잔여 좌석 컬럼을 추가하고 결제 기록을 저장하는 `payments` 테이블을 새로 사용합니다. Chapter 09 실습 파일은 별도의 테스트 데이터를 다시 구성합니다.

```text
students(id, name, email, joined_at)
instructors(id, name, email, specialty)
courses(id, instructor_id, title, description, level, price, opened_at,
        capacity, remaining_seats)
enrollments(id, student_id, course_id, enrolled_at, status, paid_amount)
payments(id, enrollment_id, amount, paid_at)
```

관계는 다음과 같습니다.

```text
instructors 1:N courses
students 1:N enrollments
courses 1:N enrollments
enrollments 1:0..1 payments
```

이 장에서는 수강신청 한 건당 성공한 결제 기록 한 건만 저장한다고 가정합니다. 결제 시도, 재결제, 부분결제, 환불 이력은 범위에서 제외합니다. `enrollments.paid_amount`는 신청에 반영된 결제금액 요약값이고, `payments.amount`는 실제 결제 기록입니다. 이 단순 모델에서는 두 값이 일치해야 합니다.

> **실습 DB 확인**
>
> `transaction_consistency_practice.sql`은 `payments`, `enrollments`, `courses`, `instructors`, `students` 테이블을 삭제한 후 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 먼저 `SELECT current_database();`로 연결 대상을 확인합니다. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

초기 상태는 다음과 같습니다.

| 테이블 | 초기 행 수 | 역할 |
| --- | ---: | --- |
| students | 3 | 신청 학생 |
| instructors | 2 | 강의 담당 강사 |
| courses | 3 | 정원과 잔여 좌석 관리 |
| enrollments | 0 | 트랜잭션에서 생성 |
| payments | 0 | 수강신청별 결제 기록 |

---

## 6. ACID의 기본 의미

ACID는 트랜잭션이 안전하게 동작하기 위해 이해해야 할 네 가지 기본 특성입니다.

| 특성 | 입문 수준 의미 | 수강신청 예시 |
| --- | --- | --- |
| Atomicity | 변경이 모두 반영되거나 모두 취소됨 | 신청·결제·좌석 차감 |
| Consistency | 트랜잭션 전후에 정해진 규칙을 만족하는 상태 유지 | 좌석 범위, 금액·상태 일치 |
| Isolation | 동시에 실행되는 트랜잭션의 간섭을 정해진 수준에서 제어 | 같은 마지막 좌석 신청 |
| Durability | `COMMIT`된 변경이 장애 이후에도 유지되도록 보장 | 확정된 신청과 결제 유지 |

![ACID의 네 가지 기본 특성](../../images/chapter09/ch09_04_acid_overview.svg)

그림 9-4 ACID의 네 가지 기본 특성

Atomicity가 업무 규칙을 자동으로 검증하는 것은 아닙니다. Consistency에는 올바른 제약조건과 업무 로직이 필요합니다. Isolation에서 다른 작업이 보이는 범위는 격리 수준에 따라 달라질 수 있습니다. Durability는 DBMS의 로그와 복구 기능에 연결됩니다.

---

## 7. 트랜잭션 없이 처리할 때의 문제

수강신청, 결제, 좌석 차감을 각각 독립적으로 실행하면 중간 실패가 그대로 남을 수 있습니다.

```sql
INSERT INTO enrollments (...);
INSERT INTO payments (...);
UPDATE courses SET remaining_seats = remaining_seats - 1 ...;
```

첫 번째 SQL 뒤에 오류가 발생하면 신청만 남을 수 있습니다. 반대로 결제 연결을 잘못 작성하면 신청과 결제의 대응 관계를 확인하기 어렵습니다. 관련 변경은 같은 트랜잭션 경계 안에 두고 결과를 함께 검증해야 합니다.

---

## 8. 수강신청·결제·좌석 변경 트랜잭션

성공 예제의 순서는 다음과 같습니다.

![수강신청·결제·좌석 변경 트랜잭션](../../images/chapter09/ch09_05_enrollment_payment_transaction.svg)

그림 9-5 수강신청·결제·좌석 변경 트랜잭션

`transaction_consistency_practice.sql`의 성공 구간은 DBeaver에서 문장별로 실행합니다.

```sql
BEGIN;

SELECT id, title, price, remaining_seats
FROM courses
WHERE id = 1
FOR UPDATE;

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 1
  AND remaining_seats > 0
RETURNING id, title, price, remaining_seats;
```

`UPDATE ... RETURNING`이 **1행을 반환한 경우에만** 신청과 결제를 추가합니다.

```sql
WITH new_enrollment AS (
    INSERT INTO enrollments (
        student_id, course_id, enrolled_at, status, paid_amount
    )
    VALUES (1, 1, CURRENT_DATE, '수강중', 100000)
    RETURNING id, paid_amount
)
INSERT INTO payments (enrollment_id, amount, paid_at)
SELECT id, paid_amount, CURRENT_DATE
FROM new_enrollment
RETURNING id, enrollment_id, amount;
```

`WITH ... RETURNING`은 새 수강신청 ID를 결제 기록에 바로 연결하기 위한 PostgreSQL 예제입니다. 이 장의 핵심은 CTE 문법이 아니라 세 변경이 하나의 트랜잭션에서 함께 처리된다는 점입니다.

`COMMIT` 전에 다음을 확인합니다.

```sql
SELECT
    e.id AS enrollment_id,
    e.status,
    e.paid_amount,
    p.id AS payment_id,
    p.amount,
    c.remaining_seats
FROM enrollments AS e
JOIN payments AS p ON p.enrollment_id = e.id
JOIN courses AS c ON c.id = e.course_id
WHERE e.student_id = 1
  AND e.course_id = 1;
```

결과가 정확하면 `COMMIT`, 다르면 `ROLLBACK`합니다.

---

## 9. 실패 상황과 ROLLBACK

실패 예제도 `courses`, `enrollments`, `payments`를 모두 변경한 뒤 결제 검증 실패를 가정하고 취소합니다.

![ROLLBACK 전후 상태 비교](../../images/chapter09/ch09_06_rollback_before_after.svg)

그림 9-6 ROLLBACK 전후 상태 비교

| 확인 대상 | 트랜잭션 내부 | `ROLLBACK` 후 |
| --- | --- | --- |
| enrollments | 새 행이 임시로 보임 | 새 행 없음 |
| payments | 새 결제가 임시로 보임 | 새 결제 없음 |
| remaining_seats | 임시로 감소 | 원래 값 복구 |

같은 세션에서는 `ROLLBACK` 전 임시 변경을 확인할 수 있습니다. `ROLLBACK` 후 다시 세 테이블을 조회하여 원래 상태인지 확인합니다. 이미 `COMMIT`된 트랜잭션에는 같은 `ROLLBACK`을 적용할 수 없습니다.

---

## 10. 정합성 검증과 안전한 실행 원칙

잔여 좌석 차감 SQL은 다음처럼 조건을 포함해야 합니다.

```sql
UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0
RETURNING id, title, remaining_seats;
```

이 SQL은 좌석이 없으면 오류를 발생시키는 대신 **0행을 반환**합니다. 0행이어도 트랜잭션이 자동 실패하거나 후속 SQL이 자동 중단되거나 자동 `ROLLBACK`되지는 않습니다.

```text
1행 반환 → 좌석 확보 성공, 다음 단계 진행
0행 반환 → 후속 INSERT 실행 금지, 즉시 ROLLBACK
```

검증 SQL의 기대 결과는 다음과 같습니다.

```sql
-- 음수 또는 정원 초과 좌석: 예상 0행
SELECT id, title, capacity, remaining_seats
FROM courses
WHERE remaining_seats < 0
   OR remaining_seats > capacity;
```

```sql
-- 수강중 신청과 결제의 누락·금액 불일치: 예상 0행
SELECT
    e.id AS enrollment_id,
    e.paid_amount,
    p.amount AS payment_amount
FROM enrollments AS e
LEFT JOIN payments AS p ON p.enrollment_id = e.id
WHERE e.status = '수강중'
  AND (p.id IS NULL OR e.paid_amount <> p.amount);
```

이 장에서는 `수강중` 상태가 좌석을 사용한다고 가정합니다. 취소와 환불 시 좌석 복구 정책은 이번 장의 범위에서 제외합니다.

전체 실습을 순서대로 마친 뒤 예상 상태는 다음과 같습니다.

| 항목 | 예상 결과 |
| --- | ---: |
| 성공 `COMMIT` 수강신청 | 2건 유지 |
| 성공 `COMMIT` 결제 | 2건 유지 |
| `ROLLBACK` 예제 수강신청·결제 | 남지 않음 |
| 데이터베이스 입문 잔여 좌석 | 1 |
| 정규화 실습 잔여 좌석 | 0 |
| 최종 enrollments | 2 |
| 최종 payments | 2 |

---

## 11. 동시성·Lock·Deadlock 맛보기

잔여 좌석이 1인 강의에 학생 A와 학생 B가 동시에 신청한다고 가정합니다.

![동시 좌석 신청과 Lock](../../images/chapter09/ch09_07_concurrency_lock_deadlock.svg)

그림 9-7 동시 좌석 신청과 Lock

```sql
BEGIN;

SELECT id, title, remaining_seats
FROM courses
WHERE id = 1
FOR UPDATE;
```

`FOR UPDATE`는 선택한 행을 수정 대상으로 잠급니다. 학생 A의 트랜잭션이 같은 강의 행을 잠그고 있으면 학생 B의 변경 작업은 대기할 수 있습니다. A가 `COMMIT`한 뒤 B는 최신 좌석 값을 다시 확인하고, 0이면 신청을 진행하지 않고 `ROLLBACK`합니다. 트랜잭션은 가능한 짧게 유지합니다.

단순히 다른 트랜잭션이 잠금을 해제하기를 기다리는 것은 Deadlock이 아닙니다. Deadlock은 다음처럼 서로가 가진 잠금을 기다리는 **순환 대기**입니다.

```text
트랜잭션 A: 강의 1 잠금 → 강의 2 대기
트랜잭션 B: 강의 2 잠금 → 강의 1 대기
```

PostgreSQL은 Deadlock을 감지하면 한 트랜잭션을 오류로 종료할 수 있습니다. 실제 Deadlock SQL은 기본 실습에서 자동 실행하지 않습니다.

---

## 12. AI가 만든 트랜잭션 SQL 검토

AI가 만든 SQL은 검증되지 않은 초안입니다.

![AI 생성 트랜잭션 SQL 검토 흐름](../../images/chapter09/ch09_08_ai_transaction_review_flow.svg)

그림 9-8 AI 생성 트랜잭션 SQL 검토 흐름

| 검토 항목 | 확인 질문 |
| --- | --- |
| 업무 단위 | 신청·결제·좌석 변경이 모두 포함되는가? |
| 트랜잭션 경계 | `BEGIN`, `COMMIT`, 실패 시 `ROLLBACK`이 있는가? |
| 대상과 조건 | 학생·강의·좌석·금액 조건이 정확한가? |
| 영향 행 수 | 좌석 `UPDATE`가 1행인지 확인하는가? |
| 관계 | payment가 `enrollment_id`로 연결되는가? |
| Lock | 동시 신청 시 필요한 행 잠금을 검토했는가? |
| 결과 검증 | `COMMIT` 전에 세 테이블을 확인하는가? |
| 실행 환경 | 개인 실습 DB에서 문장별로 검증하는가? |

검증에 실패하면 `ROLLBACK`하고 SQL 또는 요구사항을 수정한 뒤 다시 실행합니다. 검증된 경우에만 `COMMIT`하고 판단 근거를 기록합니다.

---

## 13. 자주 하는 실수

### 실수 1. 트랜잭션만 사용하면 정합성이 자동 보장된다고 생각한다

트랜잭션은 변경의 성공·실패 단위를 제공하지만 업무 규칙을 자동으로 만들지 않습니다.

### 실수 2. 좌석 UPDATE 0행을 성공으로 간주한다

0행은 좌석을 확보하지 못했다는 의미입니다. 후속 INSERT를 실행하지 말고 `ROLLBACK`해야 합니다.

### 실수 3. COMMIT 전에 결과를 확인하지 않는다

`COMMIT`은 확인 후 실행합니다. 이미 확정된 변경은 같은 트랜잭션의 `ROLLBACK`으로 취소할 수 없습니다.

### 실수 4. 결제를 학생과 강의에만 연결한다

이 장에서는 결제를 특정 수강신청 행에 연결하기 위해 `payments.enrollment_id`를 사용합니다.

### 실수 5. Lock 대기를 Deadlock이라고 부른다

한 행의 잠금을 기다리는 것은 정상적인 충돌 조정일 수 있습니다. Deadlock은 순환 대기 구조입니다.

---

## 14. 스스로 확인하기

1. 트랜잭션이 필요한 이유를 설명해 보세요.
2. `COMMIT`과 `ROLLBACK`의 차이를 설명해 보세요.
3. 제약조건, 트랜잭션, 업무 검증의 역할을 구분해 보세요.
4. `UPDATE ... RETURNING`이 0행을 반환했을 때 해야 할 일을 설명해 보세요.
5. Lock 대기와 Deadlock의 차이를 설명해 보세요.
6. AI 생성 SQL에서 반드시 확인할 항목을 다섯 가지 이상 정리해 보세요.

---

## 15. 정리

```text
1. 트랜잭션은 여러 변경을 하나의 논리적 성공·실패 단위로 처리한다.
2. COMMIT은 현재 트랜잭션을 확정하고 ROLLBACK은 미확정 변경을 취소한다.
3. SQL 실행 성공과 업무상 정합성은 서로 다르다.
4. 제약조건, 트랜잭션, 업무 검증을 함께 사용한다.
5. 좌석 UPDATE 0행은 자동 오류가 아니므로 후속 작업을 중단해야 한다.
6. payments는 enrollment_id로 수강신청에 연결한다.
7. COMMIT 전과 ROLLBACK 후에 실제 결과를 SELECT로 확인한다.
8. Lock 대기와 Deadlock을 구분한다.
9. AI가 만든 트랜잭션 SQL은 영향 행 수와 실패 경로까지 검토한다.
```

이 장에서 가장 중요한 문장은 다음입니다.

```text
관련 변경은 함께 검증하고, 모두 맞을 때만 COMMIT한다.
```

---

## 16. 다음 장에서는

다음 장에서는 인덱스와 성능 기초를 살펴봅니다. Chapter 10에서는 데이터가 많아졌을 때 조회 속도가 느려지는 이유와 `WHERE`, `ORDER BY`, JOIN 조건을 위한 인덱스의 기본 원리를 다룹니다.
