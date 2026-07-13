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
```

Chapter 09는 이 데이터를 읽고 외래키로 참조하지만 변경하지 않습니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_transaction_lab_schema.sql` | 격리 스키마와 좌석·신청·결제 테이블 생성 |
| `02_transaction_lab_seed.sql` | 강의 301~303 좌석 초기화 |
| `03_commit_transaction.sql` | 학생 101·강의 301 성공 COMMIT |
| `04_rollback_transaction.sql` | 학생 102·강의 302 임시 변경 후 ROLLBACK |
| `05_commit_and_sold_out.sql` | 학생 103 정상 COMMIT과 좌석 부족 처리 |
| `06_transaction_validation.sql` | 최종 행 수·좌석·결제·사용량 검증 |
| `07_concurrency_two_sessions.sql` | 두 세션 Lock 대기 선택 실습 |
| `reset_transaction_lab.sql` | lab 스키마만 초기화 |
| `transaction_consistency_practice.sql` | 기존 링크 호환용 안내·상태 확인 |

---

## 실행 순서

```text
01_transaction_lab_schema.sql
→ 02_transaction_lab_seed.sql
→ 03_commit_transaction.sql
→ 04_rollback_transaction.sql
→ 05_commit_and_sold_out.sql
→ 06_transaction_validation.sql
```

`07_concurrency_two_sessions.sql`은 최종 검증 후 선택적으로 실행합니다.

트랜잭션 파일은 같은 DBeaver SQL Editor와 같은 연결 세션에서 문장 순서대로 실행합니다.

---

## 스키마 관계

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

`transaction_lab`만 삭제·재생성할 수 있으므로 Chapter 07·08의 프로젝트 데이터는 유지됩니다.

---

## 초기 상태

| course_id | capacity | remaining_seats |
| ---: | ---: | ---: |
| 301 | 2 | 2 |
| 302 | 1 | 1 |
| 303 | 1 | 1 |

```text
lab enrollments 0
payments 0
```

---

## 최종 상태

| 항목 | 기대값 |
| --- | ---: |
| transaction_lab.enrollments | 2 |
| transaction_lab.payments | 2 |
| course 301 remaining_seats | 1 |
| course 302 remaining_seats | 0 |
| course 303 remaining_seats | 1 |
| course_project.enrollments | 5 |

```text
9001 → student 101 / course 301 / payment 9901
9002 → student 103 / course 302 / payment 9902
9003·9903 → 좌석 부족으로 생성되지 않음
```

---

## 핵심 실행 원칙

```text
- BEGIN·변경·COMMIT/ROLLBACK은 같은 연결에서 실행합니다.
- 좌석 확보 UPDATE의 결과 행 수를 확인합니다.
- 좌석 결과에 신청·결제 INSERT를 CTE로 연결합니다.
- COMMIT 전에 신청·결제·좌석을 함께 조회합니다.
- UPDATE 0행은 SQL 오류가 아니라 업무상 실패일 수 있습니다.
- PostgreSQL 문장 오류 후에는 ROLLBACK 또는 SAVEPOINT 복구가 필요합니다.
- 트랜잭션을 오래 열어 두지 않습니다.
```

---

## 초기화

처음부터 다시 시작할 때만 다음 파일을 사용합니다.

```text
reset_transaction_lab.sql
```

이 파일은 다음 객체만 삭제합니다.

```text
transaction_lab.payments
transaction_lab.enrollments
transaction_lab.course_inventory
transaction_lab 스키마
```

`course_project`는 삭제하거나 변경하지 않습니다.

---

## 동시성 실습 주의

`07_concurrency_two_sessions.sql`은 두 연결 세션이 필요하며 모든 위험 구간이 주석 처리되어 있습니다.

```text
- 필요한 블록만 선택 실행합니다.
- 대기 중인 세션을 방치하지 않습니다.
- 실습이 끝나면 두 세션 모두 COMMIT 또는 ROLLBACK합니다.
- Deadlock 유발 SQL은 포함하지 않습니다.
```
