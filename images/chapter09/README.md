# Chapter 09 이미지/도식 설계

## Chapter 09. 트랜잭션과 데이터 정합성

이 문서는 Chapter 09 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 09는 여러 SQL 작업을 하나의 안전한 작업 단위로 묶고, 데이터 정합성을 지키는 방법을 설명하는 장입니다. 따라서 도식은 **트랜잭션 필요성, BEGIN-COMMIT-ROLLBACK 흐름, ACID, 수강신청/결제/좌석 차감, ROLLBACK 전후 비교, 동시성/Lock, AI 트랜잭션 SQL 검토**를 초급자가 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 트랜잭션을 단순 SQL 묶음이 아니라 데이터 정합성을 지키는 안전 장치로 표현한다.
- 수강신청, 결제, 좌석 차감이 함께 성공하거나 함께 실패해야 하는 이유를 보여 준다.
- COMMIT과 ROLLBACK의 차이를 시각적으로 비교한다.
- ACID는 초급자가 이해할 수 있는 짧은 의미 중심으로 표현한다.
- 동시성, Lock, Deadlock은 맛보기 수준으로 단순하게 표현한다.
- AI가 만든 트랜잭션 SQL을 업무 규칙과 정합성 기준으로 검토하는 흐름을 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 9-1 | `ch09_01_transaction_need.svg` | 트랜잭션이 필요한 이유 | 1장 왜 트랜잭션을 배워야 하는가 | 수강신청, 결제, 좌석 차감 중 일부만 성공할 때 생기는 문제 설명 | 높음 |
| 그림 9-2 | `ch09_02_transaction_basic_flow.svg` | BEGIN-COMMIT-ROLLBACK 기본 흐름 | 2장 트랜잭션이란 무엇인가 | 트랜잭션 시작, 확정, 취소 흐름 설명 | 높음 |
| 그림 9-3 | `ch09_03_consistency_problem_examples.svg` | 데이터 정합성이 깨지는 예 | 3장 데이터 정합성이란 무엇인가 | 결제와 수강신청 불일치, 좌석 음수 같은 문제 설명 | 높음 |
| 그림 9-4 | `ch09_04_acid_overview.svg` | ACID 개요 | 6장 ACID 특성 | 원자성, 일관성, 격리성, 영속성 요약 | 높음 |
| 그림 9-5 | `ch09_05_enrollment_payment_transaction.svg` | 수강신청-결제-좌석 차감 트랜잭션 | 8장 성공하는 트랜잭션 예제 | 세 작업이 하나의 트랜잭션으로 처리되는 구조 설명 | 높음 |
| 그림 9-6 | `ch09_06_rollback_before_after.svg` | ROLLBACK 전후 비교 | 9장 실패 상황과 ROLLBACK | 실패 시 변경 내용이 취소되는 흐름 설명 | 높음 |
| 그림 9-7 | `ch09_07_concurrency_lock_deadlock.svg` | 동시성, Lock, Deadlock 맛보기 | 12~13장 Isolation/Lock/Deadlock | 마지막 좌석 동시 신청과 잠금 개념 설명 | 중간 |
| 그림 9-8 | `ch09_08_ai_transaction_review_flow.svg` | AI 트랜잭션 SQL 검토 흐름 | 14장 AI가 만든 트랜잭션 SQL 검토 | AI SQL을 트랜잭션 범위, 실패 처리, 좌석 조건, 정합성 기준으로 검토 | 높음 |

---

## 3. 본문 삽입 권장 위치

| 그림 | 삽입 권장 위치 |
| --- | --- |
| 그림 9-1 | 1. 왜 트랜잭션을 배워야 하는가 |
| 그림 9-2 | 2. 트랜잭션이란 무엇인가 |
| 그림 9-3 | 3. 데이터 정합성이란 무엇인가 |
| 그림 9-4 | 6. ACID 특성 |
| 그림 9-5 | 8. 성공하는 트랜잭션 예제 |
| 그림 9-6 | 9. 실패 상황과 ROLLBACK |
| 그림 9-7 | 12. Isolation 맛보기 또는 13. Lock과 Deadlock 맛보기 |
| 그림 9-8 | 14. AI가 만든 트랜잭션 SQL 검토하기 |

---

## 4. Mermaid 원본 파일 계획

| Mermaid 파일 | 대상 이미지 |
| --- | --- |
| `ch09_01_transaction_need.mmd` | `ch09_01_transaction_need.svg` |
| `ch09_02_transaction_basic_flow.mmd` | `ch09_02_transaction_basic_flow.svg` |
| `ch09_03_consistency_problem_examples.mmd` | `ch09_03_consistency_problem_examples.svg` |
| `ch09_04_acid_overview.mmd` | `ch09_04_acid_overview.svg` |
| `ch09_05_enrollment_payment_transaction.mmd` | `ch09_05_enrollment_payment_transaction.svg` |
| `ch09_06_rollback_before_after.mmd` | `ch09_06_rollback_before_after.svg` |
| `ch09_07_concurrency_lock_deadlock.mmd` | `ch09_07_concurrency_lock_deadlock.svg` |
| `ch09_08_ai_transaction_review_flow.mmd` | `ch09_08_ai_transaction_review_flow.svg` |

---

## 5. 도식 제작 후 점검 항목

```text
- 트랜잭션이 필요한 이유가 업무 흐름과 연결되어 보이는가?
- COMMIT과 ROLLBACK의 차이가 분명한가?
- 데이터 정합성이 깨지는 예가 직관적인가?
- ACID가 너무 어렵지 않게 요약되어 있는가?
- 수강신청, 결제, 좌석 차감이 하나의 작업 단위로 표현되는가?
- 동시성/Lock/Deadlock은 맛보기 수준으로 단순하게 표현되는가?
- AI 트랜잭션 SQL 검토 흐름에 BEGIN/COMMIT/ROLLBACK, 좌석 조건, 결과 검증이 포함되는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 09 도식 후보 8종 정리 완료
- 다음 작업: Chapter 09 Mermaid 도식 원본 8종 작성
```
