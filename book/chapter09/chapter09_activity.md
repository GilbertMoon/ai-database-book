# Chapter 09 독자 워크북

## 트랜잭션으로 데이터 정합성 지키기

> 이 워크북은 `transaction_lab` 스키마에서 좌석·수강신청·결제 변경을 안전하게 실행하고 COMMIT·ROLLBACK 전후 상태를 기록하기 위한 보조 자료입니다. Chapter 07의 `course_project` 데이터는 변경하지 않습니다.

---

## 1. 실습 구조 확인

```text
course_project.students
course_project.courses
        ↑ 외래키 참조
transaction_lab.course_inventory
transaction_lab.enrollments
transaction_lab.payments
```

파일:

```text
01_transaction_lab_schema.sql
02_transaction_lab_seed.sql
03_commit_transaction.sql
04_rollback_transaction.sql
05_commit_and_sold_out.sql
06_transaction_validation.sql
07_concurrency_two_sessions.sql
reset_transaction_lab.sql
```

실행 순서:

```text
01 → 02 → 03 → 04 → 05 → 06
```

---

## 2. 실행 환경 기록

| 확인 항목 | 기록 |
| --- | --- |
| 현재 데이터베이스 |  |
| 같은 SQL Editor·연결 세션 사용 |  |
| course_project 준비 여부 |  |
| transaction_lab 기존 존재 여부 |  |
| 초기화 필요 여부 |  |

Chapter 07 기준 행 수:

| 테이블 | 기대 | 실제 |
| --- | ---: | ---: |
| course_project.students | 3 |  |
| course_project.courses | 3 |  |
| course_project.enrollments | 5 |  |

---

## 3. 업무 단위 정의

이 장에서 하나의 트랜잭션으로 묶을 변경을 작성합니다.

```text
1.
2.
3.
```

부분 성공 시 발생할 문제:

| 남은 상태 | 문제 |
| --- | --- |
| 좌석만 감소 |  |
| 신청만 생성 |  |
| 결제만 생성 |  |
| 신청·결제 생성, 좌석 미차감 |  |

---

## 4. 안전장치 역할 구분

| 안전장치 | 담당 역할 | 이 장의 예 |
| --- | --- | --- |
| 제약조건 |  |  |
| 트랜잭션 |  |  |
| 업무 조건 |  |  |
| 영향 행 수 |  |  |
| 검증 SELECT |  |  |

트랜잭션만으로 모든 업무 규칙이 자동 보장되지 않는 이유:

```text
_______________________________________________________________
```

---

## 5. ACID 작성하기

| 특성 | 나의 설명 | 수강신청 사례 |
| --- | --- | --- |
| Atomicity |  |  |
| Consistency |  |  |
| Isolation |  |  |
| Durability |  |  |

다음 문장을 검토합니다.

| 문장 | 맞음/아님 | 이유 |
| --- | --- | --- |
| Atomicity가 결제금액이 올바른지 판단한다 |  |  |
| Consistency에는 제약조건과 업무 로직이 필요하다 |  |  |
| Isolation의 동작은 격리 수준과 관련된다 |  |  |
| COMMIT된 변경은 Durability와 관련된다 |  |  |

---

## 6. 초기 상태 확인

| course_id | title | capacity | remaining_seats |
| ---: | --- | ---: | ---: |
| 301 | 데이터베이스 입문 | 2 |  |
| 302 | 정규화 실습 | 1 |  |
| 303 | 파이썬 데이터 분석 | 1 |  |

| 테이블 | 기대 행 수 | 실제 행 수 |
| --- | ---: | ---: |
| transaction_lab.course_inventory | 3 |  |
| transaction_lab.enrollments | 0 |  |
| transaction_lab.payments | 0 |  |

---

## 7. 성공 COMMIT 실습

`03_commit_transaction.sql`을 같은 세션에서 순서대로 실행합니다.

### 변경 전

| 항목 | 기대 | 실제 |
| --- | ---: | ---: |
| course 301 remaining_seats | 2 |  |
| enrollment 9001 | 0행 |  |
| payment 9901 | 0행 |  |

### CTE 실행 결과

| 확인 항목 | 기대 | 실제 |
| --- | ---: | ---: |
| 좌석 UPDATE 행 수 | 1 |  |
| enrollment 생성 | 1 |  |
| payment 생성 | 1 |  |
| paid_amount | 100000 |  |
| payment amount | 100000 |  |

### COMMIT 전

| 확인 항목 | 기대 | 실제 |
| --- | ---: | ---: |
| course 301 remaining_seats | 1 |  |
| enrollment 9001 | 1행 |  |
| payment 9901 | 1행 |  |

검증 후 선택한 명령:

```text
COMMIT / ROLLBACK
```

선택 이유:

```text
_______________________________________________________________
```

---

## 8. ROLLBACK 전후 비교

`04_rollback_transaction.sql`의 학생 102·강의 302 사례를 실행합니다.

| 대상 | 트랜잭션 전 | 트랜잭션 내부 | ROLLBACK 후 |
| --- | ---: | ---: | ---: |
| course 302 remaining_seats | 1 |  |  |
| enrollment 9002 행 수 | 0 |  |  |
| payment 9902 행 수 | 0 |  |  |

트랜잭션 내부의 변경이 같은 세션에서 보이는 이유:

```text
_______________________________________________________________
```

ROLLBACK 후 원래 상태로 돌아가는 이유:

```text
_______________________________________________________________
```

---

## 9. 두 번째 COMMIT과 좌석 부족

`05_commit_and_sold_out.sql` 결과를 기록합니다.

### 두 번째 정상 신청

| 항목 | 기대 | 실제 |
| --- | ---: | ---: |
| enrollment 9002 | 1행 |  |
| payment 9902 | 1행 |  |
| course 302 remaining_seats | 0 |  |

### 좌석 부족 시도

| 질문 | 답변 |
| --- | --- |
| 좌석 UPDATE 결과 행 수 |  |
| 신청 INSERT 행 수 |  |
| 결제 INSERT 행 수 |  |
| PostgreSQL 문법 오류가 발생했는가 |  |
| 업무상 성공인가 |  |
| 종료 명령 |  |

`0행 반환`과 `SQL 오류`의 차이를 설명합니다.

```text
_______________________________________________________________
```

---

## 10. SQL 오류와 aborted 상태

다음 상황을 설명합니다.

```text
BEGIN 안에서 UNIQUE 또는 CHECK 오류 발생
→ 현재 트랜잭션이 오류 상태
→ 후속 일반 SQL이 실행되지 않을 수 있음
→ ROLLBACK 필요
```

| 처리 방법 | 사용 상황 |
| --- | --- |
| ROLLBACK |  |
| SAVEPOINT |  |
| ROLLBACK TO SAVEPOINT |  |

SAVEPOINT를 남용하면 안 되는 이유:

```text
_______________________________________________________________
```

---

## 11. 최종 정합성 검증

`06_transaction_validation.sql` 결과:

| 검증 항목 | 기대 | 실제 |
| --- | ---: | ---: |
| lab enrollments | 2 |  |
| payments | 2 |  |
| course 301 remaining_seats | 1 |  |
| course 302 remaining_seats | 0 |  |
| course 303 remaining_seats | 1 |  |
| 좌석 범위 위반 | 0행 |  |
| 결제 누락·금액 불일치 | 0행 |  |
| 고아 payment | 0행 |  |

좌석 사용량:

| course_id | active enrollment | used_seats | 일치 |
| ---: | ---: | ---: | --- |
| 301 |  |  |  |
| 302 |  |  |  |
| 303 |  |  |  |

---

## 12. 두 세션 동시성 실습

`07_concurrency_two_sessions.sql`은 두 SQL Editor에서 실행합니다.

| 항목 | 세션 A | 세션 B |
| --- | --- | --- |
| BEGIN |  |  |
| course 303 FOR UPDATE |  |  |
| 대기 발생 여부 |  |  |
| A 종료 명령 |  |  |
| B가 본 최신 좌석 |  |  |
| B의 최종 판단 |  |  |

Lock 대기와 Deadlock 차이:

```text
Lock 대기:

Deadlock:
```

---

## 13. 트랜잭션 경계 검토

다음 작업을 같은 DB 트랜잭션에 포함할지 판단합니다.

| 작업 | 포함/제외 | 이유 |
| --- | --- | --- |
| 좌석 차감 |  |  |
| 신청 행 생성 |  |  |
| 결제 성공 결과 저장 |  |  |
| 사용자의 카드번호 재입력 대기 |  |  |
| 외부 API를 수십 초 기다림 |  |  |
| 내부 상태 검증 |  |  |

트랜잭션을 너무 오래 유지하면 발생할 수 있는 문제:

```text
_______________________________________________________________
```

---

## 14. AI 트랜잭션 SQL 검토

| 검토 항목 | AI 제안 | 문제 | 수정 내용 |
| --- | --- | --- | --- |
| 업무 경계 |  |  |  |
| transaction_lab 격리 |  |  |  |
| 좌석 조건 |  |  |  |
| 영향 행 수 |  |  |  |
| 신청·결제 연결 |  |  |  |
| COMMIT 전 검증 |  |  |  |
| 오류 처리 |  |  |  |
| Lock |  |  |  |
| 재실행 위험 |  |  |  |

다음 AI SQL의 문제를 찾습니다.

```sql
UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats - 1
WHERE course_id = 302;

INSERT INTO transaction_lab.enrollments (...);
COMMIT;

INSERT INTO transaction_lab.payments (...);
```

문제점:

```text
1.
2.
3.
4.
```

---

## 15. 최종 점검

| 점검 항목 | 완료 |
| --- | --- |
| course_project를 변경하지 않았다 |  |
| transaction_lab만 생성·초기화했다 |  |
| BEGIN·COMMIT·ROLLBACK을 같은 세션에서 실행했다 |  |
| 좌석 UPDATE 영향 행 수를 확인했다 |  |
| COMMIT 전 신청·결제·좌석을 검증했다 |  |
| ROLLBACK 전후 상태를 비교했다 |  |
| 좌석 부족 0행을 업무 실패로 처리했다 |  |
| SQL 오류와 aborted 상태를 이해했다 |  |
| SAVEPOINT의 역할을 설명할 수 있다 |  |
| Lock 대기와 Deadlock을 구분했다 |  |
| 최종 정합성 오류가 0행인지 확인했다 |  |
| AI SQL의 실패 경로를 검토했다 |  |

이 장의 핵심을 자신의 말로 작성합니다.

```text
안전한 트랜잭션은 _________________________________________________이다.
```
