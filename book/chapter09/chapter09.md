# Chapter 09. 트랜잭션과 데이터 정합성

> 상태: 원고 1차 리뷰 및 보완 완료

---

## 이 장에서 배울 내용

이 장에서는 여러 데이터베이스 작업을 하나의 단위로 처리하는 **트랜잭션**을 학습합니다.

Chapter 08에서는 JOIN과 집계 쿼리를 사용해 수강신청 현황과 매출 정보를 조회했습니다. 하지만 실제 서비스에서는 단순 조회보다 더 중요한 문제가 있습니다. 바로 여러 변경 작업이 함께 성공하거나 함께 실패해야 한다는 점입니다.

예를 들어 학생이 강의를 신청하고 결제까지 완료하는 과정은 다음 두 작업이 함께 일어나야 합니다.

```text
1. 수강신청 정보를 저장한다.
2. 결제 정보를 저장하거나 결제금액을 반영한다.
```

첫 번째 작업만 성공하고 두 번째 작업이 실패하면 데이터는 앞뒤가 맞지 않게 됩니다. 이런 문제를 막기 위해 트랜잭션이 필요합니다.

이 장에서 다룰 내용은 다음과 같습니다.

- 트랜잭션이 필요한 이유
- 데이터 정합성
- BEGIN
- COMMIT
- ROLLBACK
- 작업 전후 SELECT 검증
- 수강신청/결제 흐름 실습
- AI가 만든 트랜잭션 SQL 검토

---

## 1. 왜 트랜잭션을 배워야 하는가

데이터베이스 작업은 하나의 SQL로 끝나지 않는 경우가 많습니다.

온라인 강의 서비스에서 학생이 강의를 신청하는 상황을 생각해 보겠습니다.

![트랜잭션이 필요한 상황](../../images/chapter09/ch09_01_transaction_need.svg)

그림 9-1 트랜잭션이 필요한 상황

```text
1. 학생이 강의를 선택한다.
2. 수강신청 기록을 만든다.
3. 결제금액을 저장한다.
4. 수강상태를 신청 또는 수강중으로 변경한다.
5. 최종 결과를 확인한다.
```

이 과정에서 중간에 오류가 발생할 수 있습니다.

예를 들어 수강신청 기록은 저장되었지만 결제 정보가 반영되지 않았다면 다음과 같은 문제가 생깁니다.

```text
- 학생은 강의를 신청한 것으로 보인다.
- 하지만 결제금액은 반영되지 않았다.
- 관리자 화면에서는 수강상태와 결제상태가 맞지 않는다.
```

이처럼 데이터가 앞뒤로 맞지 않는 상태를 막기 위해 트랜잭션을 사용합니다.

---

## 2. 트랜잭션이란 무엇인가

트랜잭션은 여러 데이터베이스 작업을 하나의 논리적 단위로 묶는 것입니다.

```text
트랜잭션 = 함께 성공하거나 함께 실패해야 하는 작업 묶음
```

예를 들어 다음 두 작업은 하나의 트랜잭션으로 묶는 것이 좋습니다.

```text
1. enrollments 테이블에 수강신청 행 추가
2. 결제금액 또는 상태 변경
```

둘 다 성공하면 결과를 확정합니다. 중간에 문제가 생기면 전체 작업을 되돌립니다.

![트랜잭션 기본 흐름](../../images/chapter09/ch09_02_transaction_basic_flow.svg)

그림 9-2 트랜잭션 기본 흐름

트랜잭션을 사용하는 기본 흐름은 다음과 같습니다.

```sql
BEGIN;

-- 여러 SQL 작업 실행

COMMIT;
```

문제가 생겼거나 결과가 예상과 다르면 다음처럼 되돌릴 수 있습니다.

```sql
ROLLBACK;
```

---

## 3. COMMIT과 ROLLBACK

트랜잭션에서 가장 중요한 명령은 `COMMIT`과 `ROLLBACK`입니다.

| 명령 | 의미 | 사용 상황 |
| --- | --- | --- |
| BEGIN | 트랜잭션 시작 | 여러 작업을 하나로 묶기 시작할 때 |
| COMMIT | 변경 내용 확정 | 모든 결과가 정상일 때 |
| ROLLBACK | 변경 내용 되돌리기 | 오류가 있거나 결과가 잘못되었을 때 |

![COMMIT과 ROLLBACK 비교](../../images/chapter09/ch09_03_commit_rollback_compare.svg)

그림 9-3 COMMIT과 ROLLBACK 비교

`COMMIT`을 실행하면 트랜잭션 안에서 변경한 내용이 데이터베이스에 확정됩니다.

반대로 `ROLLBACK`을 실행하면 트랜잭션 안에서 변경한 내용이 취소됩니다.

초급 단계에서는 다음 원칙을 기억하면 좋습니다.

```text
COMMIT은 확인 후 실행한다.
ROLLBACK은 잘못되었을 때 되돌리는 안전장치이다.
```

---

## 4. 실습에 사용할 테이블 구조

이 장에서는 Chapter 07과 Chapter 08에서 사용한 온라인 강의 수강신청 시스템을 계속 사용합니다.

기본 테이블은 다음과 같습니다.

```text
students(id, name, email, joined_at)
instructors(id, name, email, specialty)
courses(id, instructor_id, title, description, level, price, opened_at)
enrollments(id, student_id, course_id, enrolled_at, status, paid_amount)
```

관계는 다음과 같습니다.

```text
students 1:N enrollments
courses 1:N enrollments
instructors 1:N courses
```

트랜잭션 실습에서는 주로 `enrollments` 테이블의 수강신청 추가, 상태 변경, 결제금액 변경을 다룹니다.

---

## 5. 트랜잭션 없이 처리할 때의 문제

먼저 트랜잭션 없이 수강신청과 상태 변경을 따로 처리한다고 가정합니다.

```sql
INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (4, 2, CURRENT_DATE, '신청', 0);

UPDATE enrollments
SET status = '수강중', paid_amount = 120000
WHERE student_id = 4 AND course_id = 2;
```

두 SQL이 모두 성공하면 문제가 없어 보입니다. 하지만 첫 번째 SQL만 성공하고 두 번째 SQL이 실패하면 데이터가 불완전하게 남을 수 있습니다.

![트랜잭션 없이 처리할 때의 문제](../../images/chapter09/ch09_04_without_transaction_problem.svg)

그림 9-4 트랜잭션 없이 처리할 때의 문제

따라서 관련 있는 변경 작업은 트랜잭션으로 묶는 것이 안전합니다.

---

## 6. 트랜잭션으로 수강신청 처리하기

트랜잭션을 사용하면 여러 작업을 하나의 단위로 묶을 수 있습니다.

```sql
BEGIN;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (4, 2, CURRENT_DATE, '신청', 0);

UPDATE enrollments
SET status = '수강중', paid_amount = 120000
WHERE student_id = 4 AND course_id = 2;

SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
WHERE e.student_id = 4 AND e.course_id = 2;

COMMIT;
```

이 흐름에서 중요한 부분은 `COMMIT` 전에 `SELECT`로 결과를 확인하는 것입니다.

```text
1. BEGIN으로 트랜잭션 시작
2. INSERT 실행
3. UPDATE 실행
4. SELECT로 결과 확인
5. 결과가 맞으면 COMMIT
```

---

## 7. ROLLBACK으로 되돌리기

트랜잭션 안에서 실행한 결과가 예상과 다르다면 `ROLLBACK`으로 되돌릴 수 있습니다.

```sql
BEGIN;

UPDATE enrollments
SET paid_amount = 999999
WHERE id = 1;

SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE id = 1;

ROLLBACK;
```

`ROLLBACK`을 실행하면 트랜잭션 안에서 변경한 `paid_amount = 999999`는 취소됩니다.

![ROLLBACK으로 되돌리기](../../images/chapter09/ch09_05_rollback_restore.svg)

그림 9-5 ROLLBACK으로 되돌리기

ROLLBACK 후에는 다시 조회해서 값이 원래대로 돌아왔는지 확인합니다.

```sql
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE id = 1;
```

---

## 8. 데이터 정합성 확인하기

데이터 정합성이란 데이터가 앞뒤로 맞는 상태를 의미합니다.

예를 들어 온라인 강의 수강신청 시스템에서는 다음 조건을 확인할 수 있습니다.

```text
- 수강신청에 존재하는 student_id는 students 테이블에 존재해야 한다.
- 수강신청에 존재하는 course_id는 courses 테이블에 존재해야 한다.
- paid_amount가 음수이면 안 된다.
- status가 완료인데 paid_amount가 0이면 이상할 수 있다.
- 취소 상태인데 paid_amount가 남아 있다면 환불 여부를 검토해야 한다.
```

![데이터 정합성 검증 흐름](../../images/chapter09/ch09_06_consistency_check_flow.svg)

그림 9-6 데이터 정합성 검증 흐름

정합성 확인 SQL 예시는 다음과 같습니다.

```sql
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE paid_amount < 0;
```

```sql
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE status = '완료' AND paid_amount = 0;
```

실무에서는 이런 검증 SQL을 운영 점검 또는 테스트 과정에서 반복적으로 사용합니다.

---

## 9. 트랜잭션 실습 시 안전 원칙

트랜잭션 실습에서는 다음 원칙을 지켜야 합니다.

```text
1. 변경 전 SELECT로 대상 데이터를 확인한다.
2. BEGIN으로 트랜잭션을 시작한다.
3. INSERT, UPDATE 등 변경 SQL을 실행한다.
4. COMMIT 전에 SELECT로 결과를 확인한다.
5. 예상과 다르면 ROLLBACK한다.
6. 예상과 맞으면 COMMIT한다.
```

![트랜잭션 실습 안전 원칙](../../images/chapter09/ch09_07_transaction_safety_rules.svg)

그림 9-7 트랜잭션 실습 안전 원칙

초급 학습자는 특히 `COMMIT`을 너무 빨리 실행하지 않도록 주의해야 합니다.

---

## 10. AI가 만든 트랜잭션 SQL 검토하기

AI에게 다음처럼 요청할 수 있습니다.

```text
PostgreSQL에서 수강신청을 추가하고 결제금액을 반영하는 트랜잭션 SQL을 작성해 주세요.
students, courses, enrollments 테이블을 사용합니다.
```

AI가 만든 SQL은 반드시 검토해야 합니다.

![AI 생성 트랜잭션 SQL 검토](../../images/chapter09/ch09_08_ai_transaction_review_flow.svg)

그림 9-8 AI 생성 트랜잭션 SQL 검토

검토 기준은 다음과 같습니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 트랜잭션 시작 | BEGIN 또는 START TRANSACTION이 있는가? |
| 변경 전 확인 | 대상 학생과 강의를 먼저 SELECT로 확인하는가? |
| 변경 SQL | INSERT 또는 UPDATE 조건이 정확한가? |
| 결과 확인 | COMMIT 전에 SELECT로 결과를 확인하는가? |
| 실패 처리 | 문제가 있을 때 ROLLBACK할 수 있는가? |
| 정합성 | 상태와 결제금액이 서로 모순되지 않는가? |
| 실행 환경 | PostgreSQL에서 실행 가능한 문법인가? |

AI가 만든 SQL은 편리하지만, 트랜잭션에서는 특히 더 조심해야 합니다. 잘못된 SQL을 `COMMIT`하면 변경 내용이 확정되기 때문입니다.

---

## 11. 자주 하는 실수

### 실수 1. BEGIN 없이 여러 변경 작업을 실행한다

관련 있는 여러 변경 작업은 트랜잭션으로 묶어야 합니다. 그렇지 않으면 일부만 성공한 상태가 남을 수 있습니다.

### 실수 2. COMMIT을 너무 빨리 실행한다

`COMMIT`은 변경 결과를 확인한 뒤 실행해야 합니다.

### 실수 3. ROLLBACK을 확인 없이 기대한다

이미 `COMMIT`한 뒤에는 같은 트랜잭션에서 `ROLLBACK`으로 되돌릴 수 없습니다. 따라서 확정 전에 반드시 확인해야 합니다.

### 실수 4. UPDATE 조건을 넓게 작성한다

`WHERE` 조건이 부정확하면 예상보다 많은 행이 변경될 수 있습니다.

### 실수 5. 정합성 확인 SQL을 작성하지 않는다

트랜잭션이 끝난 뒤에도 데이터가 앞뒤로 맞는지 확인해야 합니다.

---

## 12. 연습 문제

### 12.1 개념 확인

1. 트랜잭션이 필요한 이유를 설명하세요.
2. COMMIT과 ROLLBACK의 차이를 설명하세요.
3. 데이터 정합성이란 무엇인지 설명하세요.
4. COMMIT 전에 SELECT로 확인해야 하는 이유를 설명하세요.
5. AI가 만든 트랜잭션 SQL을 검토할 때 확인해야 할 항목을 3가지 이상 쓰세요.

### 12.2 SQL 작성 문제

다음 요구사항에 맞는 SQL 흐름을 작성하세요.

```text
1. 특정 학생이 특정 강의를 신청한다.
2. 신청 직후 상태는 '신청'으로 저장한다.
3. 결제금액을 반영하면서 상태를 '수강중'으로 변경한다.
4. 결과를 SELECT로 확인한다.
5. 결과가 맞으면 COMMIT한다.
```

또한 결과가 예상과 다를 때 사용할 ROLLBACK 흐름도 작성하세요.

---

## 13. 정리

이번 장에서는 트랜잭션과 데이터 정합성을 학습했습니다.

핵심 내용을 정리하면 다음과 같습니다.

```text
1. 트랜잭션은 여러 SQL 작업을 하나의 논리적 단위로 묶는다.
2. 관련 있는 작업은 함께 성공하거나 함께 실패해야 한다.
3. COMMIT은 변경 내용을 확정한다.
4. ROLLBACK은 트랜잭션 안의 변경 내용을 되돌린다.
5. COMMIT 전에는 반드시 SELECT로 결과를 확인해야 한다.
6. 데이터 정합성은 데이터가 앞뒤로 맞는 상태를 의미한다.
7. AI가 만든 트랜잭션 SQL도 사람이 검토한 뒤 실행해야 한다.
```

이 장에서 가장 중요한 문장은 다음입니다.

```text
트랜잭션은 데이터베이스 변경 작업을 안전하게 확정하거나 되돌리기 위한 기본 장치이다.
```

---

## 14. 다음 장에서는

다음 장에서는 인덱스와 성능 기초를 학습합니다.

Chapter 10에서는 데이터가 많아졌을 때 조회 속도가 느려지는 이유를 살펴보고, 인덱스를 사용해 검색 성능을 높이는 기본 원리를 배웁니다.
