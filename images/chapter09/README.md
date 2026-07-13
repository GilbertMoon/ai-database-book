# Chapter 09 이미지/도식 설계

## Chapter 09. 트랜잭션과 데이터 정합성

Chapter 09 도식은 `images/SVG_STYLE_GUIDE.md`를 공통 기준으로 사용합니다. 하나의 SVG가 하나의 핵심 질문에 답하도록 본문 표와 전체 SQL의 중복을 제거했습니다.

## 1. 그림 번호와 파일 연결

| 번호 | 파일 | 제목 | 본문의 역할 |
| --- | --- | --- | --- |
| 그림 9-1 | `ch09_01_transaction_need.svg` | 트랜잭션이 필요한 이유 | 세 변경 중 일부만 성공할 때의 문제 |
| 그림 9-2 | `ch09_02_transaction_basic_flow.svg` | BEGIN부터 COMMIT·ROLLBACK까지 | 검증 후 확정·취소 분기 |
| 그림 9-3 | `ch09_03_consistency_problem_examples.svg` | 데이터 정합성이 깨지는 예 | 대표적인 업무 규칙 불일치 |
| 그림 9-4 | `ch09_04_acid_overview.svg` | ACID의 네 가지 기본 특성 | ACID 입문 개념 |
| 그림 9-5 | `ch09_05_enrollment_payment_transaction.svg` | 수강신청·결제·좌석 변경 트랜잭션 | 성공 트랜잭션의 실행 순서 |
| 그림 9-6 | `ch09_06_rollback_before_after.svg` | ROLLBACK 전후 상태 비교 | 세 테이블의 임시 변경과 복구 |
| 그림 9-7 | `ch09_07_concurrency_lock_deadlock.svg` | 동시 좌석 신청과 Lock | Lock 대기와 Deadlock 구분 |
| 그림 9-8 | `ch09_08_ai_transaction_review_flow.svg` | AI 생성 트랜잭션 SQL 검토 흐름 | AI 초안의 반복 검증 |

본문에서는 그림 9-1부터 9-8까지 각각 다른 SVG를 한 번씩 사용합니다.

## 2. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch09_01_transaction_need.mmd` | `ch09_01_transaction_need.svg` |
| `ch09_02_transaction_basic_flow.mmd` | `ch09_02_transaction_basic_flow.svg` |
| `ch09_03_consistency_problem_examples.mmd` | `ch09_03_consistency_problem_examples.svg` |
| `ch09_04_acid_overview.mmd` | `ch09_04_acid_overview.svg` |
| `ch09_05_enrollment_payment_transaction.mmd` | `ch09_05_enrollment_payment_transaction.svg` |
| `ch09_06_rollback_before_after.mmd` | `ch09_06_rollback_before_after.svg` |
| `ch09_07_concurrency_lock_deadlock.mmd` | `ch09_07_concurrency_lock_deadlock.svg` |
| `ch09_08_ai_transaction_review_flow.mmd` | `ch09_08_ai_transaction_review_flow.svg` |

Mermaid는 의미적·구조적 원본이며 SVG는 출판과 GitHub 표시를 위한 보정 결과물입니다. 핵심 단계, 분기와 피드백 경로는 동기화합니다.

## 3. 공통 SVG 기준

```text
- 표준 SVG만 사용하고 외부 CSS, JavaScript, 웹폰트와 raster 이미지를 사용하지 않는다.
- role="img", aria-labelledby, title, desc를 포함한다.
- width="100%"와 내용에 맞는 viewBox를 사용한다.
- Malgun Gothic 중심의 안전한 한글 폰트 스택을 사용한다.
- SQL과 컬럼명은 Consolas, D2Coding, Courier New 계열을 사용한다.
- 핵심 글자는 12px 이상으로 유지한다.
- 성공·실패, COMMIT·ROLLBACK, 대기·Deadlock을 색상과 텍스트로 함께 표시한다.
- 전체 SQL과 본문 표를 SVG에 반복하지 않는다.
- 피드백 루프는 점선으로 주 흐름과 구분한다.
```

## 4. 정합성 기준

- PostgreSQL 기준
- `payments.enrollment_id → enrollments.id`
- `payments.enrollment_id`는 UNIQUE
- 상태: `신청`, `수강중`, `완료`, `취소`
- `remaining_seats`: 0 이상 capacity 이하
- 좌석 UPDATE 0행이면 후속 INSERT 없이 ROLLBACK
- COMMIT 전 세 테이블 SELECT 검증
- Lock 대기와 Deadlock을 구분

## 5. 검증 상태

```text
- Mermaid 원본 8종 단순화 및 SVG 논리 동기화 완료
- SVG 8종 접근성 구조와 유지보수 가능한 XML 적용 완료
- XML 파싱 및 임시 PNG 렌더링 확인 완료
- 검토용 PNG는 저장소에 포함하지 않음
- GitHub 실제 미리보기는 수동 확인 필요
- Word/PDF/eBook 변환은 수동 확인 필요
- 리뷰 체크리스트와 개정 기록 존재 및 갱신 완료
```
