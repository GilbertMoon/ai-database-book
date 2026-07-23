# Chapter 09 실습 코드

## 트랜잭션으로 데이터 정합성 지키기

이 폴더는 Chapter 07의 `course_project` 데이터를 보호하면서 별도 `transaction_lab` 스키마에서 좌석·수강신청·결제 트랜잭션을 실습하는 SQL 파일을 관리합니다.

---

## 실행 전 조건

Chapter 07의 다음 파일이 실행되어 있어야 합니다.

```text
code/chapter07/01_course_project_schema.sql
code/chapter07/02_course_project_seed.sql
code/chapter07/03_course_project_changes.sql
code/chapter07/04_course_project_validation.sql
```

기대 상태:

```text
course_project.students 3
course_project.courses 3
course_project.enrollments 5
학생 ID 101~103
강의 301 = 100000
강의 302 = 120000
강의 303 = 150000
```

`01_transaction_lab_schema.sql`은 이 조건과 현재 데이터베이스를 실제로 검사하고, 맞지 않으면 예외를 발생시킵니다.

모든 파일은 다음 위치 정보를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

모든 객체에 스키마 이름을 명시하므로 현재 스키마가 `transaction_lab`일 필요는 없습니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_transaction_lab_schema.sql` | 사전 검사 후 격리 스키마·테이블·부분 고유 인덱스 생성 |
| `02_transaction_lab_seed.sql` | 강의 301~303 좌석 초기화와 자동 검증 |
| `03_commit_transaction.sql` | 학생 101·강의 301 성공 COMMIT |
| `04_rollback_transaction.sql` | 학생 102·강의 302 임시 변경 후 ROLLBACK |
| `05_commit_and_sold_out.sql` | 학생 103 정상 COMMIT, 좌석 부족 0행과 IDENTITY 조정 |
| `06_transaction_validation.sql` | 최종 행 수·좌석·결제·중복·사용량 자동 판정 |
| `07_concurrency_two_sessions.sql` | READ COMMITTED 기준 두 세션 Lock 대기 선택 실습 |
| `08_cancel_and_restore.sql` | 취소와 좌석 복구를 같은 트랜잭션으로 검증 후 ROLLBACK |
| `09_error_and_savepoint.sql` | 중복 활성 신청 오류와 SAVEPOINT 복구 선택 실습 |
| `reset_transaction_lab.sql` | 현재 DB를 검증한 뒤 lab 스키마만 초기화 |
| `transaction_consistency_practice.sql` | 기존 링크 호환용 읽기 전용 상태 확인 |

---

## 실행 순서

주 실습:

```text
01_transaction_lab_schema.sql
→ 02_transaction_lab_seed.sql
→ 03_commit_transaction.sql
→ 04_rollback_transaction.sql
→ 05_commit_and_sold_out.sql
→ 06_transaction_validation.sql
```

선택 실습:

```text
07_concurrency_two_sessions.sql
08_cancel_and_restore.sql
09_error_and_savepoint.sql
```

`03~05` 파일은 같은 DBeaver SQL Editor와 같은 연결 세션에서 문장 순서대로 실행합니다.

---

## 스키마 관계와 규칙

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

핵심 규칙:

```text
capacity > 0
0 <= remaining_seats <= capacity
status IN ('수강중', '취소')
금액 >= 0
동일 학생·강의의 수강중 신청 최대 한 건
payment는 유효한 enrollment를 참조
한 enrollment의 payment 최대 한 건
```

```sql
CREATE UNIQUE INDEX uq_transaction_enrollments_active
ON transaction_lab.enrollments (student_id, course_id)
WHERE status = '수강중';
```

FK와 UNIQUE는 payment의 유효한 참조와 최대 한 건을 보장합니다. 모든 수강중 신청에 payment가 최소 한 건 존재하는지는 트랜잭션 흐름과 검증 SQL이 확인합니다.

---

## 초기 상태

| course_id | price | capacity | remaining_seats |
| ---: | ---: | ---: | ---: |
| 301 | 100000 | 2 | 2 |
| 302 | 120000 | 1 | 1 |
| 303 | 150000 | 1 | 1 |

```text
lab enrollments 0
payments 0
```

---

## 최종 상태

| 항목 | 기대값 |
| --- | ---: |
| `transaction_lab.enrollments` | 2 |
| `transaction_lab.payments` | 2 |
| course 301 remaining | 1 |
| course 302 remaining | 0 |
| course 303 remaining | 1 |
| `course_project.enrollments` | 5 |

```text
9001 → student 101 / course 301 / payment 9901
9002 → student 103 / course 302 / payment 9902
9003·9903 → 좌석 부족으로 생성되지 않음
```

`06_transaction_validation.sql`은 조회 결과뿐 아니라 전체 조건을 `DO` 블록으로 판정합니다.

---

## COMMIT·ROLLBACK과 IDENTITY

이 실습은 비교하기 쉬운 `9001`, `9002`, `9901`, `9902`를 직접 입력합니다.

```text
명시적 ID 행이 ROLLBACK됨
→ 같은 값을 다시 직접 입력 가능

IDENTITY 자동값 할당 후 ROLLBACK
→ 번호가 회수되지 않을 수 있음

명시적 ID 입력
→ IDENTITY 다음 값은 자동으로 이동하지 않음
```

`05_commit_and_sold_out.sql`은 최종적으로 다음 값으로 조정합니다.

```text
enrollments.id → 9003
payments.id    → 9903
```

---

## 성공 파일의 COMMIT 보호

성공 파일은 COMMIT 전 다음을 수행합니다.

```text
시작 상태 검사
→ FOR UPDATE
→ 조건부 UPDATE
→ CTE로 신청·결제 연결
→ 사람이 확인할 SELECT
→ DO 블록 자동 판정
→ 조건이 맞을 때 COMMIT
```

따라서 파일 전체를 실행하더라도 기대 상태가 다르면 COMMIT 전에 예외가 발생합니다.

---

## 좌석 부족과 문장 오류

```text
UPDATE 0행
→ SQL 문장은 정상 실행
→ 업무상 좌석 확보 실패
→ 후속 INSERT 0건
→ ROLLBACK으로 종료

제약조건·문법 오류
→ 트랜잭션 오류 상태 가능
→ ROLLBACK 또는 SAVEPOINT 복구 필요
```

---

## 취소와 좌석 복구

`08_cancel_and_restore.sql`은 다음 변경이 같은 트랜잭션이어야 함을 보여 줍니다.

```text
수강중 → 취소
+ 남은 좌석 1 증가
```

기존 payment는 신청 당시 기록으로 남습니다. 환불 금액·상태·승인 ID는 이번 장의 범위가 아닙니다. 선택 파일은 기본적으로 ROLLBACK해 주 실습의 최종 상태를 보존합니다.

---

## 동시성 실습 주의

`07_concurrency_two_sessions.sql`은 PostgreSQL 기본 격리 수준인 `READ COMMITTED`를 기준으로 합니다.

```sql
SHOW transaction_isolation;
```

세션 B에는 선택적으로 다음 제한을 사용할 수 있습니다.

```sql
SET LOCAL lock_timeout = '5s';
```

```text
- 필요한 블록만 선택 실행합니다.
- 대기 중인 세션을 방치하지 않습니다.
- timeout 오류 후에는 ROLLBACK합니다.
- 두 세션 모두 COMMIT 또는 ROLLBACK으로 종료합니다.
- Deadlock 유발 SQL은 포함하지 않습니다.
```

---

## SAVEPOINT 실습 주의

`09_error_and_savepoint.sql`의 오류 유발 SQL은 기본 주석 상태입니다.

```text
BEGIN
→ SAVEPOINT
→ 좌석 임시 차감
→ 중복 활성 신청 오류
→ ROLLBACK TO SAVEPOINT
→ 좌석 복구 확인
→ 전체 ROLLBACK
```

같은 연결에서 구간별로 선택 실행합니다.

---

## 초기화

처음부터 다시 시작할 때만 다음 파일을 사용합니다.

```text
reset_transaction_lab.sql
```

이 파일은 현재 데이터베이스가 `ai_database_book`인지 보호 구문 안에서 검사한 뒤 다음 객체만 삭제합니다.

```text
transaction_lab.payments
transaction_lab.enrollments
transaction_lab.course_inventory
transaction_lab 스키마
```

`course_project`는 삭제하거나 변경하지 않습니다.
