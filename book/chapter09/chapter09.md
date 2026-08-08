# Chapter 09. 트랜잭션으로 데이터 정합성 지키기

---

## 이 장에서 살펴볼 내용

Chapter 08에서는 `course_project` 데이터를 JOIN하고 집계해 결과를 검산했습니다. 이번 장에서는 조회가 아니라 여러 변경이 하나의 업무 단위로 함께 성공하거나 실패하도록 만드는 **트랜잭션**을 다룹니다.

```text
업무 단위 정의
→ 실행 전 상태 검사
→ BEGIN
→ 좌석 행 잠금과 최신 상태 확인
→ 조건부 좌석 확보
→ 신청·결제 생성
→ 영향 행 수와 관계 검증
→ 정상: COMMIT
→ 문제: ROLLBACK
→ 확정 후 정합성 재검증
→ 동시 실행·취소·오류 복구 검토
```

이 장에서는 다음 내용을 살펴봅니다.

- `BEGIN`, `COMMIT`, `ROLLBACK`
- ACID의 기본 의미
- 제약조건·트랜잭션·업무 검증의 역할 차이
- 조건부 좌석 차감과 영향 행 수
- 데이터 변경 CTE와 `RETURNING`
- 신청·결제·좌석 변경의 원자적 처리
- ROLLBACK과 IDENTITY 번호의 차이
- SQL 오류가 발생한 트랜잭션과 `SAVEPOINT`
- `SELECT ... FOR UPDATE`, Lock 대기와 Deadlock
- 취소와 좌석 복구 트랜잭션
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

트랜잭션은 SQL을 여러 줄 묶는 문법이 아니라, 하나의 업무가 어디에서 시작하고 어디에서 확정되는지를 정하는 설계입니다.

---

## 2. Chapter 07·08 데이터를 보호하는 실습 구조

기존 프로젝트 테이블을 삭제하거나 다시 만들면 앞 장의 데이터가 손상됩니다. Chapter 09에서는 별도의 실습 스키마를 사용합니다.

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

`transaction_lab`은 좌석과 트랜잭션 실험 상태만 저장합니다. 학생과 강의 마스터는 Chapter 07의 데이터를 외래키로 참조합니다.

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
├── 08_cancel_and_restore.sql
├── 09_error_and_savepoint.sql
├── reset_transaction_lab.sql
├── transaction_consistency_practice.sql
└── README.md
```

주 실습 순서:

```text
01 schema
→ 02 seed
→ 03 성공 COMMIT
→ 04 실패 가정 ROLLBACK
→ 05 두 번째 COMMIT과 좌석 부족
→ 06 최종 검증
```

선택 실습:

```text
07 두 세션 Lock 대기
08 취소와 좌석 복구
09 오류 상태와 SAVEPOINT
```

`transaction_consistency_practice.sql`은 기존 링크 호환용 상태 확인 파일입니다.

트랜잭션 실습은 같은 DBeaver SQL Editor와 같은 연결 세션에서 문장 순서대로 실행합니다. 다른 연결에서 `COMMIT`이나 `ROLLBACK`을 실행해도 현재 트랜잭션을 제어할 수 없습니다.

모든 파일은 다음 위치 정보를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

모든 객체를 스키마 한정 이름으로 사용하므로 `current_schema()`가 `transaction_lab`일 필요는 없습니다.

---

## 4. 실행 전 사전 조건을 실제로 검사한다

`01_transaction_lab_schema.sql`은 단순히 행 수를 출력한 뒤 계속 진행하지 않습니다. 다음 조건이 맞지 않으면 예외를 발생시킵니다.

```text
현재 데이터베이스 = ai_database_book
course_project 핵심 테이블 존재
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
학생 101~103 존재
강의 301~303와 기준 가격 100000 / 120000 / 150000 일치
recorded_amount = NUMERIC(12,0)
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 신청 이력 = 4 / 440000
신청 1001·1004·1005의 상태와 기록 금액 일치
course_project.uq_course_enrollments_active 존재
transaction_lab 스키마가 아직 없음
```

스키마와 세 테이블 생성은 하나의 트랜잭션 안에서 실행합니다.

```sql
BEGIN;

-- 사전 조건 검사
-- CREATE SCHEMA
-- CREATE TABLE
-- CREATE INDEX

COMMIT;
```

중간의 `CREATE TABLE`이 실패하면 전체 생성 단위가 확정되지 않으므로 일부 객체만 남는 위험을 줄일 수 있습니다.

---

## 5. 트랜잭션의 기본 흐름

![BEGIN부터 COMMIT·ROLLBACK까지](../../images/chapter09/ch09_02_transaction_basic_flow.svg)

그림 9-2 BEGIN부터 COMMIT·ROLLBACK까지

| 명령 | 역할 | 주의점 |
| --- | --- | --- |
| `BEGIN` | 현재 세션에서 트랜잭션 시작 | 관련 변경 전에 실행 |
| `COMMIT` | 현재 트랜잭션의 변경 확정 | 검증이 끝난 뒤 실행 |
| `ROLLBACK` | 아직 확정되지 않은 변경 취소 | 오류·검증 실패 시 실행 |

기본 패턴은 다음과 같습니다.

```sql
SELECT ...;  -- 변경 전 상태 확인

BEGIN;

UPDATE ...;
INSERT ...;

SELECT ...;  -- COMMIT 전 검증

COMMIT;
-- 또는 ROLLBACK;
```

이미 `COMMIT`된 변경은 같은 트랜잭션의 `ROLLBACK`으로 되돌릴 수 없습니다.

이 장의 성공 SQL 파일은 사람이 확인할 조회 결과와 함께 `DO` 검증 구문을 사용합니다. 기대 결과가 다르면 예외를 발생시켜 `COMMIT` 전에 중단합니다.

---

## 6. 데이터 정합성과 안전장치의 역할

데이터 정합성은 여러 값과 관계가 정의된 업무 규칙과 모순되지 않는 상태입니다.

![데이터 정합성이 깨지는 예](../../images/chapter09/ch09_03_consistency_problem_examples.svg)

그림 9-3 데이터 정합성이 깨지는 예

이 장의 단순 규칙은 다음과 같습니다.

```text
remaining_seats는 0 이상 capacity 이하다.
각 payment는 하나의 유효한 lab enrollment를 참조한다.
한 enrollment에는 payment가 최대 한 건 연결된다.
수강중 enrollment에는 payment가 한 건 존재해야 한다.
enrollment.recorded_amount와 payment.amount는 같아야 한다.
학생·강의 조합의 수강중 enrollment는 최대 한 건이다.
활성 신청 수와 사용 좌석 수가 같아야 한다.
```

| 안전장치 | 담당 역할 | 예 |
| --- | --- | --- |
| 제약조건 | 한 행의 값과 참조 오류 차단 | 음수 좌석, 없는 FK, 음수 금액 |
| 고유 인덱스 | 조건에 맞는 중복 행 차단 | 동일 학생·강의의 중복 수강중 신청 |
| 트랜잭션 | 여러 변경의 확정·취소 경계 | 좌석·신청·결제 함께 처리 |
| 업무 조건 | 변경 가능 여부 판단 | 남은 좌석이 0보다 큰가? |
| 영향 행 수 | 조건부 변경의 성공 확인 | 좌석 UPDATE가 1행인가? |
| 검증 SELECT | 여러 테이블의 최종 의미 확인 | 신청·결제·좌석 일치 |

외래키와 `UNIQUE`는 결제의 유효한 참조와 신청당 **최대 한 건**을 보장합니다. 모든 수강중 신청에 결제가 **최소 한 건** 존재해야 한다는 규칙은 여러 테이블에 걸친 업무 규칙이므로 트랜잭션 흐름과 검증 SQL이 담당합니다.

트랜잭션만 사용한다고 정합성이 자동 보장되는 것은 아닙니다. 잘못된 SQL도 함께 `COMMIT`할 수 있으므로 업무 조건과 검증이 필요합니다.

---

## 7. ACID를 업무 사례로 이해하기

![ACID의 네 가지 기본 특성](../../images/chapter09/ch09_04_acid_overview.svg)

그림 9-4 ACID의 네 가지 기본 특성

| 특성 | 입문 수준 의미 | 수강신청 사례 |
| --- | --- | --- |
| Atomicity | 모두 반영되거나 모두 취소 | 좌석·신청·결제 |
| Consistency | 전후 상태가 정의된 규칙을 만족 | 좌석 범위·결제 연결 |
| Isolation | 동시 작업의 간섭을 정해진 수준에서 제어 | 마지막 좌석 경쟁 |
| Durability | 확정된 변경을 장애 이후에도 유지 | COMMIT된 신청·결제 |

```text
Atomicity가 업무 규칙의 옳고 그름을 판단하지 않는다.
Consistency에는 제약조건과 올바른 업무 로직이 필요하다.
Isolation의 가시성과 충돌 방식은 격리 수준에 따라 달라진다.
Durability는 DBMS의 로그·저장·복구 기능과 연결된다.
```

---

## 8. 실습 구조와 초기 상태

`transaction_lab.enrollments`에는 동일 학생·강의의 중복 활성 신청을 차단하는 부분 고유 인덱스가 있습니다.

```sql
CREATE UNIQUE INDEX uq_transaction_enrollments_active
ON transaction_lab.enrollments (student_id, course_id)
WHERE status = '수강중';
```

초기 좌석 상태:

| course_id | 강의 | 가격 | capacity | remaining_seats |
| ---: | --- | ---: | ---: | ---: |
| 301 | 데이터베이스 입문 | 100000 | 2 | 2 |
| 302 | 정규화 실습 | 120000 | 1 | 1 |
| 303 | 파이썬 데이터 분석 | 150000 | 1 | 1 |

```text
course_inventory 3행
lab enrollments 0행
payments 0행
```

Chapter 07의 `course_project.enrollments` 5건은 그대로 유지됩니다.

---

## 9. 성공 트랜잭션: 좌석·신청·결제를 함께 확정한다

![수강신청·결제·좌석 변경 트랜잭션](../../images/chapter09/ch09_05_enrollment_payment_transaction.svg)

그림 9-5 수강신청·결제·좌석 변경 트랜잭션

학생 101이 강의 301을 신청하는 사례입니다.

### 9.1 행 잠금과 최신 상태 확인

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

`FOR UPDATE OF ci`는 좌석 상태 행을 수정 대상으로 잠급니다. 그러나 잠금만으로 업무 성공이 결정되는 것은 아닙니다.

```text
SELECT ... FOR UPDATE
→ 대상 행 잠금과 현재 상태 관찰

UPDATE ... WHERE remaining_seats > 0
→ 좌석이 실제로 남아 있을 때만 변경

RETURNING·영향 행 수
→ 좌석 확보 성공 여부 확인
```

### 9.2 조건부 변경과 연결 INSERT

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
        enrolled_at, status, recorded_amount
    )
    SELECT
        9001, 101, course_id,
        CURRENT_TIMESTAMP, '수강중', price
    FROM seat
    RETURNING id, recorded_amount
)
INSERT INTO transaction_lab.payments (
    id, enrollment_id, amount, paid_at
)
SELECT
    9901, id, recorded_amount, CURRENT_TIMESTAMP
FROM new_enrollment
RETURNING id, enrollment_id, amount;
```

좌석 UPDATE가 1행이면 신청과 결제가 각각 1건 생성됩니다. 좌석이 없어 UPDATE가 0행이면 `seat` CTE가 비어 후속 INSERT도 실행 대상이 없습니다.

이 실습에서는 할인과 쿠폰을 적용하지 않습니다. 신청 당시 `course_project.courses.price`를 `recorded_amount`와 `payment.amount`에 기록합니다. 이후 강의의 현재 가격이 바뀌더라도 과거 신청 금액을 자동으로 변경하지 않습니다.

### 9.3 COMMIT 전 검증

```text
신청 9001 = 1행
결제 9901 = 1행
두 저장 금액 = 100000
강의 301 잔여 좌석 = 1
```

실습 파일은 이 조건을 `DO` 블록으로 다시 판정합니다. 하나라도 다르면 예외가 발생해 트랜잭션이 확정되지 않습니다.

---

## 10. 실패를 가정한 ROLLBACK

학생 102가 강의 302를 신청하는 변경을 트랜잭션 안에서 만든 뒤 외부 결제 승인 실패를 가정하고 취소합니다.

![ROLLBACK 전후 상태 비교](../../images/chapter09/ch09_06_rollback_before_after.svg)

그림 9-6 ROLLBACK 전후 상태 비교

트랜잭션 안에서는 다음 임시 상태가 보입니다.

| 대상 | ROLLBACK 전 임시 상태 |
| --- | --- |
| course 302 | remaining_seats 0 |
| enrollment 9002 | 1행 존재 |
| payment 9902 | 1행 존재 |

```sql
ROLLBACK;
```

ROLLBACK 후 기대 상태:

```text
course 302 remaining_seats = 1
enrollment 9002 = 없음
payment 9902 = 없음
```

### ROLLBACK과 IDENTITY 번호는 다르다

이 실습은 결과 비교를 위해 `9002`, `9902`를 **명시적으로 입력**합니다. 따라서 ROLLBACK 후 같은 숫자를 다시 직접 사용할 수 있습니다.

IDENTITY 자동값은 내부 시퀀스에서 생성됩니다. 자동값이 할당된 뒤 트랜잭션이 취소되어도 그 번호는 일반적으로 회수되지 않으며 빈 번호가 생길 수 있습니다.

또한 명시적 ID 입력은 IDENTITY의 다음 값을 자동으로 이동시키지 않습니다. 주 실습 마지막에는 다음 값을 조정합니다.

```sql
ALTER TABLE transaction_lab.enrollments
    ALTER COLUMN id RESTART WITH 9003;

ALTER TABLE transaction_lab.payments
    ALTER COLUMN id RESTART WITH 9903;
```

---

## 11. 좌석 부족은 SQL 오류가 아니라 0행일 수 있다

학생 103의 강의 302 신청을 정상 확정하면 잔여 좌석은 0이 됩니다. 그 뒤 추가 신청의 조건부 UPDATE는 0행을 반환합니다.

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

CTE로 후속 INSERT를 좌석 UPDATE 결과에 연결하면 신청과 결제도 0건이 됩니다. 해당 트랜잭션은 업무상 좌석 확보 실패이므로 `ROLLBACK`으로 종료합니다.

애플리케이션에서는 반환 행 수가 0이면 “정원 마감” 같은 업무 결과로 처리해야 합니다.

---

## 12. PostgreSQL 문장 오류와 SAVEPOINT

조건 불충족으로 UPDATE가 0행인 것과 제약조건 오류가 발생한 것은 다릅니다.

PostgreSQL에서는 트랜잭션 안의 문장이 실패하면 현재 트랜잭션이 오류 상태가 될 수 있습니다.

```text
current transaction is aborted
```

기본 대응은 전체 트랜잭션 취소입니다.

```sql
ROLLBACK;
```

일부 단계만 되돌릴 필요가 있다면 오류가 발생하기 전에 `SAVEPOINT`를 설정합니다.

```sql
BEGIN;
SAVEPOINT before_optional_step;

-- 오류 가능 단계

ROLLBACK TO SAVEPOINT before_optional_step;

-- 트랜잭션 계속
COMMIT;
```

`09_error_and_savepoint.sql`은 좌석을 임시 차감한 뒤 중복 활성 신청 오류를 발생시키고, `ROLLBACK TO SAVEPOINT`로 좌석 차감까지 되돌리는 선택 실습입니다. 오류 유발 문장은 안전을 위해 기본 주석 상태입니다.

---

## 13. 최종 정합성 검증

주 실습의 최종 상태는 다음과 같습니다.

| 항목 | 기대 결과 |
| --- | ---: |
| course_project enrollments | 5 |
| lab enrollments | 2 |
| payments | 2 |
| course 301 remaining_seats | 1 |
| course 302 remaining_seats | 0 |
| course 303 remaining_seats | 1 |

검증 파일은 다음 위반이 모두 0행인지 확인합니다.

```text
좌석 범위 위반
수강중 신청의 결제 누락
신청·결제 금액 불일치
고아 payment
중복 활성 신청
좌석 부족 테스트의 잔여 행
```

또한 다음 관계를 확인합니다.

```text
활성 수강신청 수
= capacity - remaining_seats
```

마지막 `DO` 판정에서 하나라도 어긋나면 예외가 발생하며, 모두 맞으면 다음 결과를 표시합니다.

```text
Chapter 09 main transaction validation passed
```

---

## 14. 취소와 좌석 복구도 하나의 트랜잭션이다

`취소` 상태만 바꾸고 좌석을 복구하지 않으면 활성 신청 수와 사용 좌석 수가 달라집니다.

```text
수강중 → 취소
+ remaining_seats 1 증가
```

`08_cancel_and_restore.sql`은 신청 9001을 임시로 취소하고 강의 301 좌석을 1개 복구합니다.

```sql
BEGIN;

UPDATE transaction_lab.enrollments
SET status = '취소'
WHERE id = 9001
  AND status = '수강중';

UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats + 1
WHERE course_id = 301
  AND remaining_seats < capacity;

-- 검증
ROLLBACK;
```

선택 실습은 주 실습의 최종 상태를 보존하기 위해 기본적으로 ROLLBACK합니다.

결제 행은 신청 당시 기록으로 남습니다. 실제 환불 업무에는 환불 금액, 환불 상태, 승인 ID, 재시도와 보상 처리 같은 별도 구조가 필요하며 이번 장의 범위에 포함하지 않습니다.

---

## 15. Lock과 동시성

잔여 좌석이 1인 강의에 두 사용자가 동시에 신청하면 둘 다 같은 초기 값을 읽으려 할 수 있습니다.

![동시 좌석 신청과 Lock](../../images/chapter09/ch09_07_concurrency_lock_deadlock.svg)

그림 9-7 동시 좌석 신청과 Lock

`07_concurrency_two_sessions.sql`은 두 SQL Editor를 서로 다른 연결 세션으로 열어 실행합니다.

```sql
SHOW transaction_isolation;
```

이 실습은 PostgreSQL 기본 격리 수준인 `READ COMMITTED`를 기준으로 설명합니다.

### 세션 A

```sql
BEGIN;

SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 303
FOR UPDATE;
```

### 세션 B

```sql
BEGIN;
SET LOCAL lock_timeout = '5s';

SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 303
FOR UPDATE;
```

세션 B는 세션 A가 끝날 때까지 대기할 수 있습니다. A가 종료된 뒤 READ COMMITTED에서는 B가 최신 행을 잠그고 확인할 수 있습니다.

`REPEATABLE READ`나 `SERIALIZABLE`에서는 동시 변경 상황에서 오류가 발생할 수 있습니다. `lock_timeout` 오류가 발생하면 해당 트랜잭션을 `ROLLBACK`으로 종료합니다.

트랜잭션을 사용자 입력이나 외부 응답을 기다리며 오래 열어 두지 않습니다.

---

## 16. Lock 대기와 Deadlock은 다르다

한 트랜잭션이 다른 트랜잭션의 한 행 잠금 해제를 기다리는 것은 일반적인 Lock 대기입니다.

Deadlock은 서로가 가진 잠금을 기다리는 순환 구조입니다.

```text
트랜잭션 A: course 301 잠금 → course 302 대기
트랜잭션 B: course 302 잠금 → course 301 대기
```

PostgreSQL은 Deadlock을 감지하면 한 트랜잭션을 오류로 종료할 수 있습니다.

```text
여러 행을 잠글 때 같은 순서로 접근한다.
트랜잭션을 짧게 유지한다.
불필요한 행을 잠그지 않는다.
오류 발생 시 재시도 정책을 검토한다.
```

실제 Deadlock 유발 SQL은 기본 실습에 포함하지 않습니다.

---

## 17. 트랜잭션 경계를 어디에 둘 것인가

트랜잭션이 너무 짧으면 하나의 업무가 부분 확정될 수 있고, 너무 길면 잠금 유지 시간이 길어집니다.

같은 트랜잭션에 포함할 후보:

```text
좌석 확보
수강신청 생성
결제 성공 결과 저장
관련 내부 상태 변경
COMMIT 전 내부 검증
```

오래 기다리지 않아야 하는 작업:

```text
사용자의 추가 입력
외부 결제창 응답의 장시간 대기
느린 외부 API 호출
대용량 파일 처리
```

외부 결제는 데이터베이스 트랜잭션만으로 전체 세계를 원자적으로 묶을 수 없습니다. 실제 시스템에서는 결제 승인 ID, 상태 전이, 멱등성 키, 재시도와 보상 처리 설계가 필요합니다.

이 장은 성공한 결제 결과를 내부 DB에 기록하는 단순화된 상황을 다룹니다.

---

## 18. AI가 만든 트랜잭션 SQL 검토

![AI 생성 트랜잭션 SQL 검토 흐름](../../images/chapter09/ch09_08_ai_transaction_review_flow.svg)

그림 9-8 AI 생성 트랜잭션 SQL 검토 흐름

AI에게 다음 정보를 함께 제공합니다.

```text
업무 단위: 좌석 차감 + lab enrollment 생성 + payment 생성
성공 조건: 좌석 1행, 신청 1행, 결제 1행, 금액 일치
실패 조건: 좌석 0행, SQL 오류, 관계 검증 실패
변경 대상: transaction_lab만
course_project 데이터 변경 금지
동일 학생·강의의 중복 수강중 신청 금지
```

| 검토 항목 | 확인 질문 |
| --- | --- |
| 경계 | `BEGIN`과 최종 확정 범위가 업무 단위와 맞는가? |
| 격리 | 기존 `course_project`를 변경하지 않는가? |
| 좌석 | `remaining_seats > 0`과 영향 행 수를 확인하는가? |
| 원자성 | 좌석 성공 결과에 신청·결제 INSERT가 연결되는가? |
| 관계 | payment가 올바른 enrollment를 참조하는가? |
| 중복 | 같은 학생·강의의 활성 신청을 막는가? |
| 검증 | COMMIT 전에 좌석·신청·결제를 함께 확인하는가? |
| 오류 | aborted 상태와 SAVEPOINT 복구를 고려하는가? |
| 잠금 | 마지막 좌석 경쟁과 격리 수준을 고려하는가? |
| 재실행 | 명시적 ID, 자동 ID, 멱등성 위험을 설명하는가? |
| 외부 작업 | 외부 API 대기를 DB 트랜잭션 안에 오래 두지 않는가? |

대표적인 잘못된 예:

```text
좌석 UPDATE가 0행이어도 신청 INSERT 실행
신청을 COMMIT한 뒤 별도 트랜잭션에서 결제 INSERT
취소 상태만 바꾸고 좌석은 복구하지 않음
동일 학생·강의의 중복 수강중 신청 허용
COMMIT 전에 결과 검증 없음
오류 상태에서 계속 SQL 실행
FOR UPDATE만 사용하고 조건부 UPDATE 결과를 확인하지 않음
```

AI SQL은 정상 경로뿐 아니라 실패·복구·재실행 경로까지 검토해야 합니다.

---

## 19. 자주 하는 실수

1. 트랜잭션이 업무 규칙을 자동 판단한다고 생각한다.
2. UPDATE 0행을 성공으로 간주한다.
3. COMMIT 전에 결과를 검증하지 않는다.
4. SQL 오류 후 aborted 트랜잭션을 계속 사용한다.
5. `BEGIN`과 `COMMIT`을 서로 다른 연결에서 실행한다.
6. 기존 `course_project`를 실습용으로 변경한다.
7. ROLLBACK이 IDENTITY 시퀀스 번호도 되돌린다고 생각한다.
8. 명시적 ID를 입력하고 IDENTITY 다음 값도 자동으로 이동한다고 생각한다.
9. 취소 상태만 바꾸고 좌석을 복구하지 않는다.
10. Lock 대기를 Deadlock이라고 부른다.
11. 외부 API를 기다리며 트랜잭션을 오래 유지한다.
12. 성공 파일을 기준 상태 확인 없이 반복 실행한다.

---

## 20. 스스로 확인하기

1. 트랜잭션의 업무 경계란 무엇인가요?
2. 제약조건과 트랜잭션의 역할은 어떻게 다른가요?
3. `COMMIT`과 `ROLLBACK`의 차이는 무엇인가요?
4. 좌석 UPDATE 0행과 SQL 오류는 어떻게 다른가요?
5. `FOR UPDATE`와 조건부 UPDATE의 역할은 어떻게 다른가요?
6. CTE로 좌석 결과에 INSERT를 연결한 이유는 무엇인가요?
7. payment의 FK·UNIQUE가 보장하는 것과 보장하지 못하는 것은 무엇인가요?
8. ROLLBACK과 IDENTITY 자동 번호의 관계를 설명해 보세요.
9. `SAVEPOINT`는 언제 사용할 수 있나요?
10. READ COMMITTED에서 Lock 대기 후 어떤 상태를 확인해야 하나요?
11. Lock 대기와 Deadlock의 차이는 무엇인가요?
12. 취소 시 좌석 복구를 같은 트랜잭션에 넣어야 하는 이유는 무엇인가요?
13. 외부 결제 API를 DB 트랜잭션 안에서 오래 기다리면 안 되는 이유는 무엇인가요?
14. AI 트랜잭션 SQL에서 실패 경로가 중요한 이유는 무엇인가요?

실행 결과를 기록하려면 `book/chapter09/chapter09_activity.md`의 독자 워크북을 사용합니다.

---

## 21. 권장 해설

### 업무 경계와 안전장치

- 트랜잭션 경계는 하나의 업무로 함께 성공하거나 취소되어야 하는 변경의 범위입니다.
- 제약조건은 값·참조·중복을 차단하고, 트랜잭션은 여러 변경의 원자성을 담당합니다.
- 업무 조건과 최종 검증은 DBMS 제약조건만으로 표현하기 어려운 여러 테이블의 의미를 확인합니다.

### 0행과 오류

- 조건부 UPDATE 0행은 조건을 만족하는 행이 없다는 정상 실행 결과입니다.
- 제약조건 위반이나 문법 오류는 트랜잭션을 오류 상태로 만들 수 있습니다.
- 오류 상태에서는 `ROLLBACK` 또는 미리 만든 SAVEPOINT로 복구해야 합니다.

### 잠금과 변경

- `FOR UPDATE`는 대상 행을 잠그고 상태를 관찰합니다.
- `UPDATE ... WHERE remaining_seats > 0`은 실제 변경 가능 여부를 결정합니다.
- `RETURNING`과 영향 행 수는 좌석 확보 성공 여부의 증거입니다.

### 결제 관계

- payment의 FK는 존재하는 enrollment만 참조하게 합니다.
- payment의 UNIQUE는 enrollment당 결제가 최대 한 건이 되게 합니다.
- 수강중 enrollment에 결제가 최소 한 건 존재하는지는 트랜잭션 흐름과 검증 SQL이 확인합니다.

### IDENTITY

- 명시적 ID 행이 ROLLBACK되면 같은 값을 다시 직접 입력할 수 있습니다.
- IDENTITY 자동 번호는 트랜잭션 취소로 회수되지 않을 수 있습니다.
- 명시적 ID는 IDENTITY의 다음 값을 자동으로 조정하지 않습니다.

### 취소와 외부 결제

- 수강중 신청을 취소하면 좌석도 같은 트랜잭션에서 복구해야 합니다.
- 결제 환불은 별도 상태·금액·승인 ID와 보상 처리 설계가 필요합니다.
- 외부 시스템의 응답을 기다리는 동안 DB 잠금을 오래 유지하지 않습니다.

---

## 22. 핵심 정리

```text
1. 트랜잭션은 여러 변경의 성공·실패 경계다.
2. 제약조건, 업무 조건, 영향 행 수와 검증 SELECT를 함께 사용한다.
3. COMMIT 전에 신청·결제·좌석의 최종 의미를 검증한다.
4. 좌석 UPDATE 0행은 오류가 아니라 업무상 실패일 수 있다.
5. 데이터 변경 CTE와 RETURNING으로 후속 변경을 성공 결과에 연결할 수 있다.
6. ROLLBACK은 행 변경을 취소하지만 IDENTITY 자동 번호까지 회수하지 않는다.
7. SQL 오류 후에는 ROLLBACK 또는 SAVEPOINT 복구가 필요하다.
8. FOR UPDATE와 조건부 UPDATE의 역할을 구분한다.
9. 동시성 결과는 격리 수준과 잠금에 영향을 받는다.
10. 취소와 좌석 복구도 하나의 트랜잭션으로 처리한다.
11. AI SQL은 정상·실패·복구·재실행 경로를 모두 검토한다.
```

이 장에서 기억할 문장은 다음과 같습니다.

```text
변경이 실행됐는지가 아니라,
업무 단위 전체가 검증된 상태로 확정됐는지를 확인한다.
```

---

## 23. 다음 장에서는

Chapter 10에서는 같은 온라인 강의 도메인의 조회 패턴을 바탕으로 인덱스와 실행 계획을 살펴봅니다.

```text
어떤 WHERE·JOIN·ORDER BY가 느린가?
인덱스는 어떤 탐색을 줄이는가?
EXPLAIN은 무엇을 보여 주는가?
인덱스가 많으면 왜 쓰기 비용이 증가하는가?
AI가 제안한 인덱스를 어떻게 검증하는가?
```

트랜잭션이 변경의 정확성을 지키는 장치라면, 인덱스는 필요한 데이터를 효율적으로 찾도록 돕는 구조입니다.
