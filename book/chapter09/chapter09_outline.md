# Chapter 09 구성안

## 제목

트랜잭션으로 데이터 정합성 지키기

## 권장 분량

24~28페이지

## 이 장의 역할

Chapter 07·08의 `course_project` 데이터를 보호하면서, 별도 `transaction_lab` 스키마에서 좌석·수강신청·결제 변경을 하나의 업무 단위로 처리한다.

```text
업무 단위 정의
→ 변경 전 확인
→ BEGIN
→ 조건부 좌석 확보
→ 신청·결제 생성
→ 영향 행 수·관계 검증
→ COMMIT 또는 ROLLBACK
→ 정합성 재검증
→ 동시성·잠금 검토
```

## 핵심 질문

```text
어떤 변경들이 하나의 업무 단위인가?
부분 성공이 남으면 어떤 모순이 생기는가?
좌석 UPDATE가 실제로 1행을 변경했는가?
신청과 결제가 정확히 연결되었는가?
COMMIT 전에 무엇을 검증해야 하는가?
0행 반환과 SQL 오류는 어떻게 다른가?
같은 행을 동시에 변경하면 어떻게 되는가?
트랜잭션을 얼마나 짧게 유지해야 하는가?
```

## 독자가 얻게 될 것

- 트랜잭션 경계를 업무 단위로 설명할 수 있다.
- `BEGIN`, `COMMIT`, `ROLLBACK`을 같은 세션에서 실행할 수 있다.
- ACID의 기본 의미와 오해를 설명할 수 있다.
- 제약조건·트랜잭션·업무 검증의 역할을 구분할 수 있다.
- 조건부 UPDATE의 영향 행 수를 확인할 수 있다.
- CTE로 좌석 확보 결과에 신청·결제 INSERT를 연결할 수 있다.
- COMMIT 전과 ROLLBACK 후 상태를 검증할 수 있다.
- 0행 반환과 SQL 오류를 구분할 수 있다.
- PostgreSQL의 aborted 트랜잭션을 처리할 수 있다.
- `SAVEPOINT`의 기본 역할을 설명할 수 있다.
- `SELECT ... FOR UPDATE`, Lock 대기와 Deadlock을 구분할 수 있다.
- 외부 API와 DB 트랜잭션 경계를 검토할 수 있다.
- AI가 만든 트랜잭션 SQL의 정상·실패 경로를 검토할 수 있다.

## 핵심 개념

- 트랜잭션 경계
- BEGIN
- COMMIT
- ROLLBACK
- ACID
- 원자성
- 정합성
- 격리성
- 지속성
- 조건부 UPDATE
- 영향 행 수
- CTE
- RETURNING
- aborted transaction
- SAVEPOINT
- 행 잠금
- SELECT FOR UPDATE
- Lock 대기
- Deadlock
- 장기 트랜잭션
- 멱등성·보상 처리 개요
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

`course_project`는 읽기·참조만 하고 변경하지 않는다.

## 실습 데이터

초기 상태:

```text
course_inventory 3
lab enrollments 0
payments 0

course 301: capacity 2 / remaining 2
course 302: capacity 1 / remaining 1
course 303: capacity 1 / remaining 1
```

최종 상태:

```text
lab enrollments 2
payments 2
course 301 remaining 1
course 302 remaining 0
course 303 remaining 1
```

## 본문 구성

1. 트랜잭션 필요성
2. 프로젝트 보호와 transaction_lab
3. 실습 파일·실행 순서
4. 기본 흐름
5. 데이터 정합성과 안전장치
6. ACID
7. 초기 상태
8. 성공 COMMIT
9. 실패 가정 ROLLBACK
10. 좌석 부족 0행
11. PostgreSQL 오류 상태와 SAVEPOINT
12. 최종 정합성 검증
13. Lock과 동시성
14. Lock 대기와 Deadlock
15. 트랜잭션 경계
16. AI SQL 검토
17. 자주 하는 실수
18. 스스로 확인하기
19. 핵심 정리
20. 다음 장 연결

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
├── reset_transaction_lab.sql
├── transaction_consistency_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_transaction_lab_schema.sql` | 격리 스키마와 좌석·신청·결제 테이블 생성 |
| `02_transaction_lab_seed.sql` | 강의 301~303 좌석 초기화 |
| `03_commit_transaction.sql` | 학생 101·강의 301 성공 COMMIT |
| `04_rollback_transaction.sql` | 학생 102·강의 302 임시 변경 후 ROLLBACK |
| `05_commit_and_sold_out.sql` | 학생 103 정상 COMMIT과 좌석 부족 0행 처리 |
| `06_transaction_validation.sql` | 최종 행 수·좌석·결제·사용량 검증 |
| `07_concurrency_two_sessions.sql` | 두 세션 Lock 대기 관찰용 주석 실습 |
| `reset_transaction_lab.sql` | lab 스키마만 초기화 |
| `transaction_consistency_practice.sql` | 기존 링크 호환용 안내·상태 확인 |

## 안전성 원칙

- `course_project` 테이블을 DROP·ALTER·UPDATE하지 않는다.
- `transaction_lab`만 생성·초기화한다.
- 트랜잭션 문장은 같은 연결 세션에서 실행한다.
- COMMIT 전 영향 행 수와 관계를 확인한다.
- 좌석 UPDATE 0행이면 후속 신청·결제를 만들지 않는다.
- SQL 오류 후 ROLLBACK 또는 SAVEPOINT 복구를 수행한다.
- 동시성 실습은 두 세션에서 선택적으로 실행한다.
- Deadlock 유발 SQL은 자동 실행하지 않는다.

## AI 활용 원칙

- 업무 단위와 성공·실패 조건을 프롬프트에 명시한다.
- 기존 `course_project` 변경 금지를 명시한다.
- 영향 행 수, COMMIT 전 검증과 ROLLBACK 경로를 요구한다.
- 좌석 부족 0행과 SQL 오류를 구분하도록 요구한다.
- Lock·재실행·장기 트랜잭션 위험을 검토한다.

## 다음 장 연결

Chapter 10에서는 `course_project`의 조회 패턴을 기준으로 인덱스와 실행 계획을 검토한다. Chapter 09의 `transaction_lab`은 성능 실습과 분리한다.
