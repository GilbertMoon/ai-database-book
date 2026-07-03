# Chapter 09 활동 자료

## 트랜잭션과 데이터 정합성

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 09 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 09의 트랜잭션과 데이터 정합성을 실습하기 위한 자료입니다.

학습자는 온라인 강의 수강신청 시스템에서 수강신청, 결제 기록, 잔여 좌석 차감이 하나의 작업 단위로 처리되어야 하는 이유를 이해하고, `COMMIT`과 `ROLLBACK` 결과를 직접 확인합니다.

이 활동의 핵심 질문은 다음과 같습니다.

```text
- 어떤 SQL들이 반드시 함께 성공해야 하는가?
- 중간에 실패하면 어디까지 되돌려야 하는가?
- COMMIT 후 데이터는 어떻게 확정되는가?
- ROLLBACK 후 데이터는 어떻게 취소되는가?
- 잔여 좌석이 음수가 되지 않도록 어떻게 막을 수 있는가?
- AI가 만든 트랜잭션 SQL은 업무 규칙을 제대로 반영했는가?
```

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. 트랜잭션이 필요한 상황을 설명할 수 있다.
2. BEGIN, COMMIT, ROLLBACK의 역할을 설명할 수 있다.
3. 수강신청과 결제 처리를 하나의 트랜잭션으로 묶을 수 있다.
4. ROLLBACK 전후 결과를 비교할 수 있다.
5. 잔여 좌석 조건을 검증할 수 있다.
6. 데이터 정합성이 깨지는 상황을 찾을 수 있다.
7. AI가 만든 트랜잭션 SQL을 검토할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 데이터베이스
- code/chapter09/transaction_consistency_practice.sql
- ChatGPT 또는 Codex
```

### 제출 파일명 권장

```text
학번_이름_chapter09_activity.md
```

예시:

```text
20260001_홍길동_chapter09_activity.md
```

---

## 4. 활동 1: 실습 SQL 실행 준비

다음 파일을 실행합니다.

```text
code/chapter09/transaction_consistency_practice.sql
```

실행 전 이 파일에 `DROP TABLE IF EXISTS`가 포함되어 있음을 확인하세요.

| 항목 | 작성 |
| --- | --- |
| SQL 파일 실행 성공 여부 |  |
| 생성된 테이블 목록 |  |
| students 데이터 수 |  |
| courses 데이터 수 |  |
| enrollments 데이터 수 |  |
| payments 데이터 수 |  |
| 오류가 있었다면 오류 메시지 |  |
| 오류를 어떻게 해결했는가? |  |

---

## 5. 활동 2: 초기 상태 확인

트랜잭션 실습 전 초기 상태를 기록하세요.

```sql
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;
SELECT * FROM payments;
```

### courses 초기 상태

| id | title | capacity | remaining_seats |
| ---: | --- | ---: | ---: |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

### enrollments 초기 상태

| id | student_id | course_id | status | paid_amount |
| ---: | ---: | ---: | --- | ---: |
|  |  |  |  |  |

### payments 초기 상태

| id | student_id | course_id | amount | paid_at |
| ---: | ---: | ---: | ---: | --- |
|  |  |  |  |  |

---

## 6. 활동 3: COMMIT 결과 확인

다음 트랜잭션은 수강신청, 결제 기록, 잔여 좌석 차감을 함께 처리합니다.

```sql
BEGIN;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (1, 1, CURRENT_DATE, '결제완료', 100000);

INSERT INTO payments (student_id, course_id, amount, paid_at)
VALUES (1, 1, 100000, CURRENT_DATE);

UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 1
  AND remaining_seats > 0;

COMMIT;
```

COMMIT 후 결과를 기록하세요.

| 확인 항목 | 실행 결과 |
| --- | --- |
| enrollments에 수강신청이 저장되었는가? |  |
| payments에 결제 기록이 저장되었는가? |  |
| courses.remaining_seats가 1 감소했는가? |  |
| 세 작업이 모두 반영되었는가? |  |

### 질문

```text
이 예제에서 세 SQL 중 하나만 성공하고 나머지가 실패하면 어떤 문제가 생길까요?
```

---

## 7. 활동 4: ROLLBACK 결과 확인

다음 트랜잭션은 결제 검증 실패 상황을 가정하고 ROLLBACK합니다.

```sql
BEGIN;

INSERT INTO enrollments (student_id, course_id, enrolled_at, status, paid_amount)
VALUES (2, 2, CURRENT_DATE, '결제대기', 120000);

INSERT INTO payments (student_id, course_id, amount, paid_at)
VALUES (2, 2, 120000, CURRENT_DATE);

ROLLBACK;
```

ROLLBACK 후 결과를 기록하세요.

```sql
SELECT * FROM enrollments
WHERE student_id = 2 AND course_id = 2;

SELECT * FROM payments
WHERE student_id = 2 AND course_id = 2;
```

| 확인 항목 | 실행 결과 |
| --- | --- |
| ROLLBACK 후 enrollments 데이터가 남아 있는가? |  |
| ROLLBACK 후 payments 데이터가 남아 있는가? |  |
| ROLLBACK이 필요한 이유를 설명할 수 있는가? |  |

### 질문

```text
ROLLBACK은 COMMIT 이후에도 실행한 내용을 되돌릴 수 있나요?
그 이유는 무엇인가요?
```

---

## 8. 활동 5: 잔여 좌석 조건 검증

수강신청은 잔여 좌석이 있을 때만 가능해야 합니다.

다음 SQL의 조건을 확인하세요.

```sql
UPDATE courses
SET remaining_seats = remaining_seats - 1
WHERE id = 2
  AND remaining_seats > 0;
```

| 확인 항목 | 작성 |
| --- | --- |
| 조건에 사용된 컬럼 |  |
| 조건의 의미 |  |
| remaining_seats가 0이면 UPDATE가 실행되어야 하는가? |  |
| 이 조건이 없으면 어떤 문제가 생기는가? |  |

---

## 9. 활동 6: 최종 정합성 확인

다음 쿼리로 강의별 수강신청 수와 잔여 좌석을 확인합니다.

```sql
SELECT
    c.id,
    c.title,
    c.capacity,
    c.remaining_seats,
    COUNT(e.id) AS enrollment_count
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title, c.capacity, c.remaining_seats
ORDER BY c.id;
```

| id | title | capacity | remaining_seats | enrollment_count |
| ---: | --- | ---: | ---: | ---: |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

### 질문

```text
capacity, remaining_seats, enrollment_count를 함께 볼 때 데이터 정합성을 어떻게 판단할 수 있나요?
```

---

## 10. 활동 7: ACID 개념 정리

ACID의 의미를 본인의 말로 작성하세요.

| 항목 | 의미 | 수강신청 예시 |
| --- | --- | --- |
| Atomicity |  |  |
| Consistency |  |  |
| Isolation |  |  |
| Durability |  |  |

### 질문

```text
초급 단계에서 가장 먼저 이해해야 할 ACID 특성은 무엇이라고 생각하나요?
그 이유는 무엇인가요?
```

---

## 11. 활동 8: 데이터 정합성이 깨지는 상황 찾기

다음 상황 중 정합성이 깨지는 경우를 찾고 이유를 작성하세요.

| 상황 | 정합성 문제 여부 | 이유 |
| --- | --- | --- |
| 결제 기록은 있는데 수강신청 기록이 없음 |  |  |
| 수강신청은 있는데 결제 금액이 0원임 |  |  |
| remaining_seats가 -1임 |  |  |
| 수강신청 상태가 결제완료인데 payments에 기록이 없음 |  |  |
| 수강신청과 결제 기록이 모두 있고 좌석도 정상 차감됨 |  |  |

---

## 12. 활동 9: AI 생성 트랜잭션 SQL 검토

AI에게 다음 프롬프트를 입력했다고 가정합니다.

```text
PostgreSQL에서 수강신청, 결제 기록, 잔여 좌석 차감을 하나의 트랜잭션으로 처리하는 SQL 예제를 작성해 주세요.
실패 시 ROLLBACK이 필요한 이유도 설명해 주세요.
```

AI가 만든 SQL을 다음 기준으로 검토하세요.

| 검토 항목 | 확인 결과 | 수정 필요 여부 |
| --- | --- | --- |
| BEGIN과 COMMIT이 포함되어 있는가? |  |  |
| 수강신청 INSERT가 트랜잭션 안에 있는가? |  |  |
| 결제 INSERT가 트랜잭션 안에 있는가? |  |  |
| 잔여 좌석 UPDATE가 트랜잭션 안에 있는가? |  |  |
| remaining_seats > 0 조건이 있는가? |  |  |
| 실패 시 ROLLBACK 흐름을 고려했는가? |  |  |
| SELECT로 결과를 검증하는가? |  |  |
| 업무 규칙과 맞지 않는 부분은 없는가? |  |  |

### 사람이 수정한 내용

| AI 제안 | 문제점 | 수정한 내용 |
| --- | --- | --- |
|  |  |  |
|  |  |  |

---

## 13. 활동 10: 직접 트랜잭션 작성하기

다음 요구사항에 맞는 SQL 흐름을 작성하세요.

### 문제 1. 수강신청과 결제 기록을 함께 저장

```sql
-- 여기에 작성
```

### 문제 2. 결제 실패 시 전체 취소

```sql
-- 여기에 작성
```

### 문제 3. 잔여 좌석이 있을 때만 좌석 차감

```sql
-- 여기에 작성
```

### 문제 4. COMMIT 후 결과 확인 SELECT

```sql
-- 여기에 작성
```

### 문제 5. 데이터 정합성 확인 쿼리

```sql
-- 여기에 작성
```

---

## 14. 제출 양식

아래 형식을 그대로 복사해서 제출 파일에 사용할 수 있습니다.

```markdown
# Chapter 09 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. SQL 실행 준비

[활동 1 작성]

## 3. COMMIT 결과 확인

[활동 2~3 작성]

## 4. ROLLBACK 결과 확인

[활동 4 작성]

## 5. 잔여 좌석과 정합성 검토

[활동 5~8 작성]

## 6. AI 트랜잭션 SQL 검토

[활동 9 작성]

## 7. 직접 작성한 트랜잭션 SQL

[활동 10 작성]

## 8. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 15. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| 트랜잭션 이해 | 20 | BEGIN, COMMIT, ROLLBACK의 역할을 설명했는가 |
| 실행 결과 확인 | 25 | COMMIT/ROLLBACK 전후 결과를 정확히 기록했는가 |
| 데이터 정합성 검토 | 20 | 수강신청, 결제, 잔여 좌석의 관계를 검토했는가 |
| SQL 작성 능력 | 15 | 요구사항에 맞는 트랜잭션 SQL을 직접 작성했는가 |
| AI SQL 검토 | 10 | AI가 만든 SQL을 업무 규칙 기준으로 검토했는가 |
| 제출 형식 | 10 | 지정된 형식에 맞게 명확히 작성했는가 |

---

## 16. 피드백 코멘트 예시

### 우수한 경우

```text
COMMIT과 ROLLBACK의 차이를 실행 결과로 정확히 설명했습니다.
수강신청, 결제 기록, 잔여 좌석 차감을 하나의 트랜잭션으로 이해했고,
remaining_seats > 0 조건과 정합성 확인 쿼리까지 적절히 검토한 점이 우수합니다.
```

### 보완이 필요한 경우

```text
트랜잭션 문법은 작성했지만 COMMIT 전후와 ROLLBACK 전후의 결과 비교가 부족합니다.
또한 잔여 좌석 조건이 없으면 좌석 수가 음수가 될 수 있으므로 WHERE 조건을 반드시 확인해야 합니다.
AI가 만든 SQL은 실행 여부뿐 아니라 업무 규칙과 데이터 정합성 기준으로도 검토해야 합니다.
```

---

## 17. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. 트랜잭션 필요성 설명: 10분
2. COMMIT 실습: 20분
3. ROLLBACK 실습: 20분
4. 잔여 좌석 조건 검증: 20분
5. 데이터 정합성 확인 쿼리 실습: 20분
6. AI 트랜잭션 SQL 검토 활동: 20분
7. 직접 SQL 작성 및 공유: 25분
```

초급자에게는 트랜잭션을 “SQL 묶음”이 아니라 “업무 규칙을 지키는 안전 장치”로 설명하는 것이 좋습니다.

---

## 18. 핵심 정리

이 활동의 핵심은 트랜잭션으로 데이터 정합성을 지키는 방법을 직접 확인하는 것입니다.

```text
BEGIN은 트랜잭션 시작이다.
COMMIT은 변경 내용을 확정한다.
ROLLBACK은 변경 내용을 취소한다.
트랜잭션은 여러 SQL을 하나의 작업 단위로 묶는다.
수강신청, 결제, 좌석 차감은 함께 성공하거나 함께 실패해야 한다.
데이터 정합성은 데이터가 업무 규칙과 모순되지 않는 상태이다.
AI가 만든 트랜잭션 SQL도 반드시 사람이 업무 규칙 기준으로 검토해야 한다.
```
