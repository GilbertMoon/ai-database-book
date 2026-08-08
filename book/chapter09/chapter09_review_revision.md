# Chapter 09 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter09/chapter09.md
book/chapter09/chapter09_activity.md
book/chapter09/chapter09_outline.md
code/chapter09/01_transaction_lab_schema.sql
code/chapter09/02_transaction_lab_seed.sql
code/chapter09/03_commit_transaction.sql
code/chapter09/04_rollback_transaction.sql
code/chapter09/05_commit_and_sold_out.sql
code/chapter09/06_transaction_validation.sql
code/chapter09/07_concurrency_two_sessions.sql
code/chapter09/08_cancel_and_restore.sql
code/chapter09/09_error_and_savepoint.sql
code/chapter09/reset_transaction_lab.sql
code/chapter09/transaction_consistency_practice.sql
code/chapter09/README.md
notes/chapter09_review_checklist.md
README.md
```

## 검수 목적

Chapter 09가 기존 `course_project`를 보호하면서 트랜잭션의 성공·ROLLBACK·좌석 부족·오류·취소·동시성 경로를 재현하고, 잘못된 상태에서는 실행 또는 COMMIT을 실제로 차단하도록 보완했습니다.

```text
사전 조건 검사
→ BEGIN
→ 잠금과 조건부 변경
→ 연결된 신청·결제 생성
→ COMMIT 전 자동 판정
→ COMMIT 또는 ROLLBACK
→ 전체 정합성 판정
→ 오류·취소·동시성 선택 실습
```

---

## 1. 사전 조건 보호 구문

`01_transaction_lab_schema.sql`은 다음 조건을 검사합니다.

```text
현재 DB = ai_database_book
course_project 핵심 테이블 존재
학생 101~103 존재
강의 301~303와 기준 가격 일치
course_project.enrollments = 5
transaction_lab 스키마가 아직 없음
```

스키마와 세 테이블, 부분 고유 인덱스의 생성은 하나의 트랜잭션으로 묶었습니다. 중간 실패 시 일부 객체만 확정되는 문제를 줄였습니다.

`02_transaction_lab_seed.sql`도 lab이 비어 있는지 검사하고 좌석 입력 결과를 자동 검증합니다.

---

## 2. COMMIT 전 자동 판정

성공 파일의 기존 문제는 결과 조회 뒤 `COMMIT`이 바로 실행되어 사용자가 검증 결과를 읽기 전에 확정될 수 있다는 점이었습니다.

최종 구조는 다음과 같습니다.

```text
시작 상태 검사
→ 변경 실행
→ 사람이 확인할 SELECT
→ DO 블록에서 기대 상태 자동 판정
→ 조건이 맞을 때만 COMMIT
```

다음 항목을 COMMIT 전에 검사합니다.

```text
신청 ID·학생·강의·상태
결제 ID와 신청 연결
신청 금액과 결제 금액
강의 잔여 좌석
```

기대 상태가 다르면 예외가 발생해 트랜잭션이 확정되지 않습니다.

---

## 3. 명시적 ID와 IDENTITY 구분

실습은 결과 비교를 위해 `9001`, `9002`, `9901`, `9902`를 명시적으로 입력합니다.

```text
명시적 ID 행 ROLLBACK
→ 같은 값을 다시 직접 입력 가능

IDENTITY 자동 번호 할당 후 ROLLBACK
→ 번호가 회수되지 않을 수 있음

명시적 ID 입력
→ IDENTITY 다음 값이 자동 이동하지 않음
```

주 실습 완료 후 다음 값으로 조정합니다.

```text
transaction_lab.enrollments.id → 9003
transaction_lab.payments.id    → 9903
```

기존의 “ROLLBACK 덕분에 ID 재사용” 표현을 명시적 ID 행의 재사용으로 제한했습니다.

---

## 4. 결제 관계 규칙의 범위 명확화

DDL이 보장하는 규칙:

```text
payment는 존재하는 enrollment를 참조한다.
한 enrollment의 payment는 최대 한 건이다.
```

트랜잭션 흐름과 검증이 담당하는 규칙:

```text
모든 수강중 enrollment에는 payment가 최소 한 건 존재한다.
recorded_amount와 payment.amount는 같다.
```

“정확히 한 건”을 FK·UNIQUE만으로 보장하는 것처럼 보이던 표현을 수정했습니다.

---

## 5. 중복 활성 신청 차단

Chapter 07의 활성 신청 정책을 lab에도 적용했습니다.

```sql
CREATE UNIQUE INDEX uq_transaction_enrollments_active
ON transaction_lab.enrollments (student_id, course_id)
WHERE status = '수강중';
```

동일 학생·강의의 수강중 신청은 최대 한 건만 허용합니다. 최종 검증과 SAVEPOINT 오류 실습에도 같은 규칙을 연결했습니다.

---

## 6. ROLLBACK·좌석 부족 경로 강화

`04_rollback_transaction.sql`은 다음 임시 상태를 검사한 뒤 전체 취소합니다.

```text
course 302 remaining = 0
enrollment 9002 존재
payment 9902 존재
```

ROLLBACK 후에는 다음을 확인합니다.

```text
course 302 remaining = 1
enrollment 9002 없음
payment 9902 없음
```

`05_commit_and_sold_out.sql`은 좌석 부족 시 신청·결제가 0건이고 좌석이 0으로 유지되는지 프로그램으로 판정한 뒤 ROLLBACK합니다.

---

## 7. 취소와 좌석 복구 실습 추가

새 파일:

```text
08_cancel_and_restore.sql
```

실습 흐름:

```text
신청 9001 수강중 확인
→ course 301 좌석 행 잠금
→ 상태를 취소로 변경
→ remaining_seats 1 증가
→ payment와 좌석 상태 검증
→ 기본 ROLLBACK으로 기준 상태 보존
```

환불 금액·상태·승인 ID는 이번 장의 범위가 아님을 명시했습니다. 결제 행은 신청 당시 기록으로 유지합니다.

---

## 8. 오류 상태와 SAVEPOINT 실습 추가

새 파일:

```text
09_error_and_savepoint.sql
```

선택 실습 흐름:

```text
BEGIN
→ SAVEPOINT
→ 좌석 임시 차감
→ 중복 활성 신청 오류
→ current transaction is aborted 확인
→ ROLLBACK TO SAVEPOINT
→ 좌석·행 복구 확인
→ 전체 ROLLBACK
```

오류 유발 문장은 기본 주석 상태로 제공해 같은 연결에서 단계별로 실행하도록 했습니다.

---

## 9. 동시성 격리 수준 명시

동시성 실습은 PostgreSQL 기본 격리 수준인 `READ COMMITTED`를 기준으로 설명합니다.

```sql
SHOW transaction_isolation;
```

세션 B에는 선택적으로 다음 설정을 제공합니다.

```sql
SET LOCAL lock_timeout = '5s';
```

READ COMMITTED에서는 대기 후 최신 상태를 확인할 수 있으며, REPEATABLE READ·SERIALIZABLE에서는 동시 변경 오류가 발생할 수 있음을 설명했습니다. timeout 오류 후에는 `ROLLBACK`하도록 안내했습니다.

---

## 10. FOR UPDATE와 조건부 UPDATE 구분

```text
SELECT ... FOR UPDATE
→ 대상 행 잠금과 상태 관찰

UPDATE ... WHERE remaining_seats > 0
→ 실제 변경 가능 여부 결정

RETURNING·영향 행 수
→ 좌석 확보 성공 증거
```

잠금만으로 좌석 확보가 성공한다고 오해하지 않도록 본문·워크북·코드 주석을 수정했습니다.

---

## 11. 최종 검증을 pass/fail 판정으로 강화

`06_transaction_validation.sql`은 다음 조회와 판정을 수행합니다.

```text
project 신청 5행
lab 신청 2행
payment 2행
강의별 좌석 기대값
좌석 범위 위반 0행
결제 누락·금액 불일치 0행
고아 payment 0행
중복 활성 신청 0행
활성 신청 수 = 사용 좌석 수
9003·9903 미생성
```

전체 조건이 맞지 않으면 예외를 발생시키고, 통과하면 다음 메시지를 출력합니다.

```text
Chapter 09 main transaction validation passed
```

---

## 12. 실행 위치와 초기화 안전성

모든 SQL 파일의 위치 확인을 다음으로 통일했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

`reset_transaction_lab.sql`은 현재 DB가 `ai_database_book`인지 보호 구문 안에서 확인한 뒤 lab 객체만 삭제합니다. `course_project`는 변경하지 않습니다.

호환 상태 파일도 필요한 테이블이 없으면 안내된 예외를 발생시키고 잘못된 조회를 계속하지 않습니다.

---

## 13. 워크북·문서 동기화

본문과 워크북에 다음 내용을 추가했습니다.

```text
사전 조건과 재실행 검사
명시적 ID·IDENTITY 번호 차이
결제 최대 한 건·최소 한 건 구분
활성 신청 부분 고유 인덱스
취소와 좌석 복구
READ COMMITTED와 lock_timeout
SAVEPOINT 실행 기록
최종 pass/fail 결과
권장 해설
```

구성안과 코드 README에는 새 파일, 실행 순서, 기준 상태와 안전성 원칙을 동기화했습니다.

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 사전 조건 실제 차단 | 완료 |
| 원자적 스키마 생성 | 완료 |
| COMMIT 전 자동 판정 | 완료 |
| 명시적 ID·IDENTITY 설명 | 완료 |
| IDENTITY 다음 값 조정 | 완료 |
| 결제 규칙 범위 구분 | 완료 |
| 중복 활성 신청 차단 | 완료 |
| ROLLBACK 상태 검증 | 완료 |
| 좌석 부족 0행 검증 | 완료 |
| 취소·좌석 복구 선택 실습 | 완료 |
| 오류·SAVEPOINT 선택 실습 | 완료 |
| READ COMMITTED 기준 명시 | 완료 |
| lock timeout 안내 | 완료 |
| 초기화 보호 구문 | 완료 |
| 최종 자동 판정 | 완료 |
| 권장 해설 | 완료 |

## 결론

```text
Chapter 09는 트랜잭션 문법을 소개하는 장을 넘어,
실행 전 상태·정상 경로·실패 경로·오류 복구·취소·동시성을
실제 검증 증거로 확인하는 안전한 변경 실습 장으로 최종 보완되었다.
```

실제 PostgreSQL에서 `01→06` 주 실습과 `07→09` 선택 실습의 수동 통합 실행은 별도 제작 단계에서 확인합니다.
