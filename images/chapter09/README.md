# Chapter 09 이미지/도식 설계

## Chapter 09. 트랜잭션으로 데이터 정합성 지키기

Chapter 09 도식은 트랜잭션의 성공·실패 경계, 정합성 검증과 동시성 개념을 설명합니다. 구체적인 스키마·ID·SQL 전체는 본문과 코드 파일에서 관리합니다.

## 도식 목록

| 번호 | 파일 | 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 9-1 | `ch09_01_transaction_need.svg` | 트랜잭션이 필요한 이유 | 좌석·신청·결제 부분 성공 문제 |
| 그림 9-2 | `ch09_02_transaction_basic_flow.svg` | BEGIN부터 COMMIT·ROLLBACK까지 | 검증 후 확정·취소 분기 |
| 그림 9-3 | `ch09_03_consistency_problem_examples.svg` | 데이터 정합성이 깨지는 예 | 여러 테이블 업무 규칙 불일치 |
| 그림 9-4 | `ch09_04_acid_overview.svg` | ACID의 네 가지 기본 특성 | ACID 입문 개념과 역할 구분 |
| 그림 9-5 | `ch09_05_enrollment_payment_transaction.svg` | 수강신청·결제·좌석 변경 트랜잭션 | 성공 트랜잭션 실행 흐름 |
| 그림 9-6 | `ch09_06_rollback_before_after.svg` | ROLLBACK 전후 상태 비교 | 임시 변경과 원상 복구 |
| 그림 9-7 | `ch09_07_concurrency_lock_deadlock.svg` | 동시 좌석 신청과 Lock | Lock 대기와 Deadlock 구분 |
| 그림 9-8 | `ch09_08_ai_transaction_review_flow.svg` | AI 생성 트랜잭션 SQL 검토 흐름 | 정상·실패·복구 경로 검토 |

## 2차 재구성 스키마 기준

```text
course_project
- 기존 학생·강의 마스터와 신청 데이터
- Chapter 09에서 변경하지 않음

transaction_lab
- course_inventory
- enrollments
- payments
- 트랜잭션 실습 상태
```

관계:

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

## 핵심 정합성 기준

```text
capacity > 0
0 <= remaining_seats <= capacity
payment는 enrollment를 UNIQUE FK로 참조
수강중 신청의 paid_amount와 payment.amount 일치
active enrollment 수 = capacity - remaining_seats
좌석 UPDATE 0행이면 신청·결제 미생성
COMMIT 전 좌석·신청·결제 확인
```

## Mermaid 원본과 SVG 결과물

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다. 기존 8종은 특정 테이블 ID보다 일반적인 트랜잭션 흐름을 설명하므로 새 본문에서 계속 사용합니다.

## 공통 SVG 기준

```text
- 표준 SVG와 안전한 시스템 폰트 사용
- title, desc, role="img", aria-labelledby 포함
- width="100%"와 적절한 viewBox
- 외부 CSS·JavaScript·웹폰트·foreignObject 미사용
- 성공·실패를 색상과 텍스트로 함께 표현
- COMMIT·ROLLBACK 분기와 검증 단계를 생략하지 않음
- 전체 SQL과 대형 결과표를 이미지에 반복하지 않음
```

## 검수 기준

```text
- 본문 그림 번호 9-1~9-8 일치
- Lock 대기와 Deadlock을 동일 개념으로 표현하지 않음
- UPDATE 0행을 자동 오류·자동 ROLLBACK으로 표현하지 않음
- transaction_lab과 course_project의 역할 충돌 없음
- GitHub·Word·PDF·eBook 실제 렌더링은 수동 확인
```
