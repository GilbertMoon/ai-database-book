# Chapter 09 실습 코드

## 트랜잭션과 데이터 정합성

이 폴더는 Chapter 09의 트랜잭션과 데이터 정합성 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `transaction_consistency_practice.sql` | 수강신청, 결제, 잔여 좌석 차감을 하나의 트랜잭션으로 처리하는 PostgreSQL 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `transaction_consistency_practice.sql`을 실행합니다.
4. COMMIT 예제에서 수강신청, 결제, 잔여 좌석이 함께 반영되는지 확인합니다.
5. ROLLBACK 예제에서 INSERT 결과가 취소되는지 확인합니다.
6. 잔여 좌석 조건이 0보다 클 때만 차감되는지 확인합니다.
7. 최종 정합성 확인 쿼리로 강의별 수강신청 수와 잔여 좌석을 비교합니다.

---

## 확인할 핵심 결과

```text
- COMMIT 후 enrollments와 payments에 데이터가 확정되는가?
- COMMIT 후 courses.remaining_seats가 감소하는가?
- ROLLBACK 후 실습 데이터가 남지 않는가?
- remaining_seats > 0 조건이 좌석 부족 상황을 막는가?
- 수강신청 수와 잔여 좌석이 업무 규칙과 맞는가?
```

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
- 실제 서비스 데이터베이스에서는 DROP TABLE을 함부로 실행하면 안 됩니다.
- 트랜잭션 실습 중 COMMIT을 실행하면 변경 내용이 확정됩니다.
- ROLLBACK은 COMMIT 전에만 변경 내용을 되돌릴 수 있습니다.
- AI가 만든 트랜잭션 SQL은 반드시 업무 규칙과 정합성 기준으로 검토해야 합니다.
```
