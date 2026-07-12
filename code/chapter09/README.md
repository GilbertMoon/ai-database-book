# Chapter 09 실습 코드

## 트랜잭션과 데이터 정합성

이 폴더는 수강신청, 결제, 잔여 좌석 변경을 하나의 트랜잭션으로 처리하는 PostgreSQL 실습 파일을 관리합니다.

## 파일

| 파일 | 설명 |
| --- | --- |
| `transaction_consistency_practice.sql` | Chapter 09 확장 스키마 생성, 성공·실패 트랜잭션, Lock과 정합성 검증 |

## 실행 전 경고

`transaction_consistency_practice.sql`은 다음 테이블을 삭제하고 다시 생성합니다.

```text
payments → enrollments → courses → instructors → students
```

개인 실습용 `ai_database_book`에서만 실행하고 먼저 다음 결과를 확인합니다.

```sql
SELECT current_database();
```

보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

## Chapter 09 확장 구조

Chapter 07·08의 기본 구조에 다음을 추가합니다.

- `courses.capacity`
- `courses.remaining_seats`
- `payments`
- `payments.enrollment_id → enrollments.id`

이 장에서는 수강신청 한 건당 성공 결제 한 건만 저장한다고 가정합니다. `enrollments.paid_amount`와 `payments.amount`는 일치해야 합니다.

## 권장 실행 순서

1. 스키마와 기준 데이터를 실행합니다.
2. 초기 행 수가 students 3, instructors 2, courses 3, enrollments 0, payments 0인지 확인합니다.
3. 성공 트랜잭션은 문장별로 실행합니다.
4. `SELECT ... FOR UPDATE`로 대상 강의 행을 잠급니다.
5. `UPDATE ... RETURNING`이 1행인지 확인합니다.
6. 1행인 경우에만 수강신청과 결제를 추가합니다.
7. `COMMIT` 전에 courses, enrollments, payments를 JOIN하여 확인합니다.
8. ROLLBACK 예제에서는 취소 후 세 테이블을 다시 확인합니다.
9. 좌석 0행 예제에서는 후속 INSERT 없이 즉시 `ROLLBACK`합니다.

## 중요한 주의 사항

`remaining_seats > 0` 조건은 음수 차감을 막지만, `UPDATE`가 0행이어도 후속 SQL을 자동으로 중단하지 않습니다. 반환 행이 없으면 이후 INSERT를 실행하지 말고 `ROLLBACK`합니다.

Lock 대기는 다른 트랜잭션이 잠금을 해제하기를 기다리는 정상적인 충돌 조정일 수 있습니다. Deadlock은 서로의 잠금을 기다리는 순환 대기이며 같은 개념이 아닙니다.

## 전체 실습 후 예상 상태

| 항목 | 예상 결과 |
| --- | ---: |
| enrollments | 2 |
| payments | 2 |
| 데이터베이스 입문 잔여 좌석 | 1 |
| 정규화 실습 잔여 좌석 | 0 |
| 파이썬 데이터 분석 잔여 좌석 | 1 |
| 정합성 오류 조회 | 0행 |
