# Chapter 09 구성안

## 제목

트랜잭션으로 데이터 정합성 지키기

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 07·08의 `course_project` 데이터를 보호하면서 별도 `transaction_lab` 스키마에서 좌석·수강신청·결제 변경을 하나의 업무 단위로 처리한다. 성공·ROLLBACK·좌석 부족·오류 상태·SAVEPOINT·취소·동시성 경로를 구분하고 실제 PostgreSQL 결과로 검증한다.

```text
업무 단위 정의
→ 실행 전 상태 검사
→ BEGIN
→ 행 잠금과 최신 상태 확인
→ 조건부 좌석 확보
→ 신청·결제 생성
→ COMMIT 전 자동 검증
→ COMMIT 또는 ROLLBACK
→ 최종 정합성 판정
→ 취소·오류·동시성 선택 실습
```

## 핵심 질문

```text
어떤 변경들이 하나의 업무 단위인가?
제약조건과 트랜잭션은 무엇을 각각 보장하는가?
좌석 UPDATE가 실제로 1행을 변경했는가?
FOR UPDATE와 조건부 UPDATE의 역할은 어떻게 다른가?
신청과 결제가 정확히 연결되었는가?
FK와 UNIQUE가 보장하지 못하는 최소 한 건 규칙은 무엇인가?
0행 반환과 SQL 오류는 어떻게 다른가?
ROLLBACK은 IDENTITY 자동 번호도 되돌리는가?
취소 시 좌석을 어떻게 복구해야 하는가?
격리 수준에 따라 Lock 대기 결과가 어떻게 달라지는가?
```

## 독자가 얻게 될 것

- 트랜잭션 경계를 업무 단위로 설명할 수 있다.
- `BEGIN`, `COMMIT`, `ROLLBACK`을 같은 세션에서 실행할 수 있다.
- ACID의 기본 의미와 대표적인 오해를 설명할 수 있다.
- 제약조건·고유 인덱스·트랜잭션·업무 검증의 역할을 구분할 수 있다.
- 사전 조건 검사로 잘못된 실행 위치와 재실행을 차단할 수 있다.
- `SELECT ... FOR UPDATE`와 조건부 UPDATE의 역할을 구분할 수 있다.
- 데이터 변경 CTE와 `RETURNING`으로 후속 변경을 성공 결과에 연결할 수 있다.
- COMMIT 전 자동 판정 구문을 사용할 수 있다.
- UPDATE 0행과 SQL 오류를 구분할 수 있다.
- 명시적 ID와 IDENTITY 자동 번호의 ROLLBACK 차이를 설명할 수 있다.
- `SAVEPOINT`, `ROLLBACK TO SAVEPOINT`의 기본 역할을 설명할 수 있다.
- 동일 학생·강의의 중복 활성 신청을 차단할 수 있다.
- 취소와 좌석 복구를 같은 트랜잭션으로 처리할 수 있다.
- READ COMMITTED 기준 Lock 대기와 Deadlock을 구분할 수 있다.
- 외부 결제와 DB 트랜잭션의 경계를 검토할 수 있다.
- AI가 만든 트랜잭션 SQL의 정상·실패·복구·재실행 경로를 검토할 수 있다.

## 핵심 개념

- 트랜잭션 경계
- `BEGIN`, `COMMIT`, `ROLLBACK`
- ACID
- 제약조건과 업무 규칙
- 사전 조건 보호 구문
- 조건부 UPDATE
- 영향 행 수
- 데이터 변경 CTE
- `RETURNING`
- COMMIT 전 판정
- aborted transaction
- `SAVEPOINT`
- `ROLLBACK TO SAVEPOINT`
- IDENTITY와 시퀀스 번호 공백
- 부분 고유 인덱스
- `SELECT ... FOR UPDATE`
- READ COMMITTED
- `lock_timeout`
- Lock 대기
- Deadlock
- 취소와 좌석 복구
- 외부 결제·멱등성·보상 처리 개요
- AI SQL 검토

## 실습 구조

```text
course_project.students
course_project.courses
        ↑ 참조
transaction_lab.course_inventory
transaction_lab.enrollments
transaction_lab.payments
```

`course_project`는 읽기와 외래키 참조만 수행한다.

## 사전 조건

```text
current_database() = ai_database_book
course_project 핵심 테이블 존재
학생 101~103 존재
강의 301~303 존재
강의 가격 100000·120000·150000
course_project.enrollments = 5
transaction_lab 미생성 상태
```

## 핵심 규칙

```text
capacity > 0
0 <= remaining_seats <= capacity
status IN ('수강중', '취소')
recorded_amount >= 0
payment.amount >= 0
동일 학생·강의의 수강중 신청 최대 한 건
payment는 존재하는 enrollment만 참조
한 enrollment의 payment 최대 한 건
수강중 enrollment에는 payment 한 건 필요
신청·결제 금액 일치
활성 신청 수 = 사용 좌석 수
```

다음 규칙은 제약조건 하나로 완전히 보장되지 않으며 트랜잭션 흐름과 최종 검증이 담당한다.

```text
모든 수강중 신청에 결제가 최소 한 건 존재
신청 금액과 결제 금액 일치
활성 신청 수와 사용 좌석 수 일치
취소 상태와 좌석 복구 일치
```

## 초기 데이터

```text
course_inventory 3행
lab enrollments 0행
payments 0행

course 301: price 100000 / capacity 2 / remaining 2
course 302: price 120000 / capacity 1 / remaining 1
course 303: price 150000 / capacity 1 / remaining 1
```

## 주 실습 최종 상태

```text
lab enrollments 2
payments 2
course 301 remaining 1
course 302 remaining 0
course 303 remaining 1
course_project.enrollments 5 유지

9001 / 9901 = 정상 COMMIT
9002 / 9902 = ROLLBACK 후 명시적 ID 재사용·최종 COMMIT
9003 / 9903 = 좌석 부족으로 생성되지 않음
```

## IDENTITY 기준

```text
명시적 ID 행 ROLLBACK
→ 동일 값을 다시 직접 입력 가능

IDENTITY 자동값 ROLLBACK
→ 번호가 회수되지 않을 수 있음

명시적 ID 입력
→ IDENTITY 다음 값 자동 이동 없음
```

주 실습 완료 후:

```text
transaction_lab.enrollments.id → 9003
transaction_lab.payments.id    → 9903
```

## 본문 구성

1. 트랜잭션 필요성
2. 프로젝트 보호와 `transaction_lab`
3. 실습 파일과 실행 순서
4. 실행 전 사전 조건
5. 기본 흐름
6. 데이터 정합성과 안전장치
7. ACID
8. 실습 구조와 초기 상태
9. 성공 COMMIT
10. ROLLBACK과 IDENTITY
11. 좌석 부족 0행
12. 오류 상태와 SAVEPOINT
13. 최종 정합성 검증
14. 취소와 좌석 복구
15. READ COMMITTED와 Lock
16. Lock 대기와 Deadlock
17. 트랜잭션 경계
18. AI SQL 검토
19. 자주 하는 실수
20. 스스로 확인하기
21. 권장 해설
22. 핵심 정리
23. 다음 장 연결

## 코드 파일 구성

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

| 파일 | 역할 |
| --- | --- |
| `01_transaction_lab_schema.sql` | 사전 검사와 원자적 스키마·테이블·인덱스 생성 |
| `02_transaction_lab_seed.sql` | 좌석 초기 상태 입력과 자동 검증 |
| `03_commit_transaction.sql` | 학생 101·강의 301 성공 COMMIT과 자동 판정 |
| `04_rollback_transaction.sql` | 학생 102·강의 302 임시 변경 후 ROLLBACK |
| `05_commit_and_sold_out.sql` | 학생 103 정상 COMMIT, 좌석 부족, IDENTITY 조정 |
| `06_transaction_validation.sql` | 최종 조회와 전체 pass/fail 판정 |
| `07_concurrency_two_sessions.sql` | READ COMMITTED 기준 Lock 대기 선택 실습 |
| `08_cancel_and_restore.sql` | 취소·좌석 복구 후 기본 ROLLBACK |
| `09_error_and_savepoint.sql` | 중복 활성 신청 오류와 SAVEPOINT 복구 |
| `reset_transaction_lab.sql` | DB 보호 구문 안에서 lab만 삭제 |
| `transaction_consistency_practice.sql` | 읽기 전용 호환 상태 확인 |

## 안전성 원칙

- 모든 파일에서 DB·스키마·`search_path`를 확인한다.
- `course_project` 테이블을 DROP·ALTER·UPDATE하지 않는다.
- 사전 조건이 다르면 예외를 발생시킨다.
- 스키마 생성은 하나의 트랜잭션에서 처리한다.
- 주 성공 파일은 COMMIT 전 자동 판정을 수행한다.
- 재실행 전에 좌석·ID·행 존재 여부를 검사한다.
- 좌석 UPDATE 0행이면 후속 신청·결제를 만들지 않는다.
- SQL 오류 후 `ROLLBACK` 또는 SAVEPOINT 복구를 수행한다.
- 명시적 ID와 IDENTITY 자동값을 구분한다.
- 취소와 좌석 복구를 같은 트랜잭션으로 처리한다.
- 동시성 실습은 두 세션에서 선택 실행하고 timeout 후 ROLLBACK한다.
- Deadlock 유발 SQL은 자동 실행하지 않는다.
- 초기화는 현재 DB를 검증한 뒤 `transaction_lab`만 삭제한다.

## AI 활용 원칙

- 업무 단위와 성공·실패 조건을 프롬프트에 명시한다.
- 기존 `course_project` 변경 금지를 명시한다.
- 영향 행 수, COMMIT 전 검증과 ROLLBACK 경로를 요구한다.
- 중복 활성 신청과 취소·좌석 복구를 검토한다.
- 0행, 문장 오류와 aborted 상태를 구분하도록 요구한다.
- 격리 수준, Lock, 재실행과 IDENTITY 위험을 검토한다.
- 외부 API 대기와 DB 트랜잭션 경계를 분리한다.

## 다음 장 연결

Chapter 10에서는 `course_project`의 조회 패턴을 기준으로 인덱스와 실행 계획을 검토한다. Chapter 09의 `transaction_lab`은 성능 실습과 분리한다.
