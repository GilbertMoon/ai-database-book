# Chapter 09 실습 코드

## 트랜잭션으로 데이터 정합성 지키기

이 폴더는 Chapter 07의 `course_project` 데이터를 보호하면서 별도 `transaction_lab` 스키마에서 좌석·수강신청·결제 트랜잭션을 실습합니다.

## 실행 전 조건

Chapter 07의 다음 파일을 완료합니다.

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

기준 상태:

```text
students 3
courses 3
enrollments 5
recorded_amount 열 존재
강의 301/302/303 가격 = 100000/120000/150000
```

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_transaction_lab_schema.sql` | 격리 스키마·좌석·신청·결제 테이블 생성 |
| `02_transaction_lab_seed.sql` | 강의 301~303 좌석 초기화 |
| `03_commit_transaction.sql` | 학생 101·강의 301 성공 COMMIT |
| `04_rollback_transaction.sql` | 임시 신청·결제·좌석 변경 ROLLBACK |
| `05_commit_and_sold_out.sql` | 정상 COMMIT과 좌석 부족 0행 처리 |
| `06_transaction_validation.sql` | 최종 좌석·신청·결제 정합성 자동 판정 |
| `07_concurrency_two_sessions.sql` | 두 세션 잠금 대기 선택 실습 |
| `08_cancel_and_restore.sql` | 취소와 좌석 복구 선택 실습 |
| `09_error_and_savepoint.sql` | 오류 상태와 SAVEPOINT 선택 실습 |
| `reset_transaction_lab.sql` | transaction_lab만 초기화 |

주 실습:

```text
01 → 02 → 03 → 04 → 05 → 06
```

## 금액 의미

```text
transaction_lab.enrollments.recorded_amount
→ 신청을 만들 때 기록한 금액

transaction_lab.payments.amount
→ 이 트랜잭션 실습에서 생성한 결제 기록 금액
```

두 열은 `NUMERIC(12,0)`을 사용합니다. 성공 트랜잭션에서는 두 값이 일치하는지 검증합니다.

## 스키마 관계

```text
course_inventory.course_id → course_project.courses.id
transaction_lab.enrollments.student_id → course_project.students.id
transaction_lab.enrollments.course_id → course_project.courses.id
transaction_lab.payments.enrollment_id → transaction_lab.enrollments.id
```

핵심 규칙:

```text
capacity > 0
0 <= remaining_seats <= capacity
status IN ('수강중', '취소')
recorded_amount >= 0
payment.amount >= 0
학생·강의의 수강중 신청 최대 한 건
신청당 payment 최대 한 건
```

## 최종 상태

```text
transaction_lab.enrollments = 2
transaction_lab.payments = 2
course 301 remaining = 1
course 302 remaining = 0
course 303 remaining = 1
course_project.enrollments = 5
```

```text
9001 → student 101 / course 301 / payment 9901
9002 → student 103 / course 302 / payment 9902
9003·9903 → 좌석 부족으로 생성되지 않음
```

## COMMIT 보호 흐름

```text
시작 상태 검사
→ 대상 좌석 잠금
→ 조건부 좌석 차감
→ 신청·결제 생성
→ 자동 상태 판정
→ COMMIT
```

좌석 확보가 0행이면 후속 신청·결제도 생성되지 않으며 업무상 실패로 `ROLLBACK`합니다.

## ROLLBACK과 SAVEPOINT

```text
ROLLBACK
→ 트랜잭션 전체 변경 취소

ROLLBACK TO SAVEPOINT
→ SAVEPOINT 이후 변경만 취소
```

명시적 ID 행이 취소되면 같은 값을 다시 직접 입력할 수 있지만, IDENTITY 자동 번호는 트랜잭션 취소로 회수되지 않을 수 있습니다.

## 동시성 실습

`07_concurrency_two_sessions.sql`은 기본 격리 수준 `READ COMMITTED`를 기준으로 합니다.

```sql
SHOW transaction_isolation;
SET LOCAL lock_timeout = '5s';
```

대기 중인 세션을 방치하지 않고 두 세션 모두 `COMMIT` 또는 `ROLLBACK`으로 종료합니다.

## 초기화

`reset_transaction_lab.sql`은 `transaction_lab` 객체만 삭제하며 `course_project`는 변경하지 않습니다.
