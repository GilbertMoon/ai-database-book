# Chapter 08 출간용 문체 정리 기록

## 대상 원고

```text
book/chapter08/chapter08.md
```

## 목적

Chapter 08의 리뷰 반영과 정합성 보정 작업을 기존 기록에 이어 추가합니다.

---

## 기존 요약 유지

Chapter 08은 JOIN과 집계 쿼리를 처음 접하는 독자에게 설명하기 위한 원고, 실습 SQL, 활동 자료, 도식이 함께 연결된 장입니다.

---

## 추가 작업 기록

| 작업 항목 | 반영 상태 | 비고 |
| --- | --- | --- |
| Chapter 07 연결 설명 보정 | 완료 | 같은 스키마, 다른 Chapter 08 데이터셋 설명 추가 |
| 잘못된 파일 경로 수정 | 완료 | `midterm_project_template.sql` 제거 |
| Chapter 08 데이터 기준표 추가 | 완료 | 표와 주요 예상 결과 표 추가 |
| 결과 행 수와 집계값 정합성 보정 | 완료 | 5행, 6행, 620000, 124000 기준 통일 |
| COUNT와 고유 학생 수 개념 분리 | 완료 | `COUNT(DISTINCT e.student_id)` 설명 추가 |
| 결제금액과 매출 표현 보정 | 완료 | 결제금액 합계 중심으로 용어 수정 |
| SVG 8개 단순화 | 완료 | 한 그림당 한 질문 원칙 적용 |
| Mermaid 원본 동기화 | 완료 | SVG 역할과 동일한 제목·흐름으로 재작성 |
| 접근성 속성 보완 | 완료 | SVG title, desc, role, aria-labelledby 반영 |
| README와 활동 자료 갱신 | 완료 | 실행 경고, 예상값, 개념 구분 반영 |
| 렌더링 검증 결과 정리 | 부분 완료 | XML 검증 예정, 브라우저/GitHub/PDF는 수동 확인 필요 |

---

## 추가 메모

```text
- Chapter 07과 Chapter 09는 정합성 비교만 수행했고 파일은 수정하지 않았다.
- Chapter 08 실행 기준은 join_aggregation_practice.sql로 통일했다.
- AI SQL은 초안이며 원본 행 수와 합계로 다시 검산해야 한다는 메시지를 강화했다.
```
# Chapter 08 출간용 문체 정리 기록

## 대상 원고

```text
book/chapter08/chapter08.md
```

## 목적

Chapter 08을 일반 실용서 문체에 맞게 정리한 내용을 기록합니다.

---

## 1. 리뷰 결과 요약

Chapter 08은 JOIN과 집계 쿼리를 처음 접하는 독자에게 설명하기 위한 1차 원고로 사용 가능한 수준입니다.

본문, 실습 SQL, 활동 자료, 도식, AI SQL 검토 흐름이 다음과 같이 연결되어 있습니다.

| 구성 요소 | 상태 | 비고 |
| --- | --- | --- |
| 본문 원고 | 완료 | JOIN, LEFT JOIN, GROUP BY, HAVING 설명 포함 |
| 실습 SQL | 완료 | `code/chapter08/join_aggregation_practice.sql` 작성 완료 |
| 코드 README | 완료 | `code/chapter08/README.md` 작성 완료 |
| 활동 자료 | 완료 | `book/chapter08/chapter08_activity.md` 작성 완료 |
| 도식 설계 | 완료 | `images/chapter08/README.md` 작성 완료 |
| Mermaid 원본 | 완료 | 8종 작성 완료 |
| SVG 도식 | 완료 | 8종 생성 완료 |
| 본문 그림 삽입 | 완료 | 그림 8-1부터 그림 8-8까지 삽입 완료 |
| AI SQL 검토 흐름 | 완료 | JOIN 조건, GROUP BY, COUNT, NULL 처리, 실행 검증 기준 포함 |

---

## 2. 반영 완료 항목

| 보완 항목 | 반영 상태 | 반영 위치 |
| --- | --- | --- |
| JOIN/집계 SQL 실행 전 확인표 추가 | 완료 | Chapter 08 본문 17장 |
| LEFT JOIN COUNT 대상 주의 문장 강화 | 완료 | 본문 9장 |
| 본문 그림 링크와 캡션 삽입 | 완료 | Chapter 08 본문 전반 |
| 도식 설계 문서 상태 갱신 | 완료 | `images/chapter08/README.md` |
| README 진행 상태 갱신 | 완료 | `README.md` |
| TODO 진행 상태 갱신 | 완료 | `notes/todo.md` |
| 리뷰 체크리스트 작성 | 완료 | `notes/chapter08_review_checklist.md` |
| Chapter 상태 문구 변경 | 완료 | `book/chapter08/chapter08.md` 상단 |
| 강의안형 표현 완화 | 완료 | Chapter 08 본문, 실습 자료 |
| 제출/평가 표현 전환 | 완료 | Chapter 08 실습 자료 18~19장 |

---

## 3. 보완 판단

추가적인 본문 내용 보강은 현재 단계에서는 필요하지 않습니다.

다만 출판 변환 단계에서는 다음을 다시 확인해야 합니다.

```text
- SVG 도식이 PDF 변환 시 정상 표시되는가?
- Word 또는 eBook 변환 시 그림 크기가 적절한가?
- SQL 코드 블록 줄바꿈이 지나치게 길지 않은가?
```

---

## 4. 최종 반영 상태

| 항목 | 상태 |
| --- | --- |
| 리뷰 체크리스트 작성 | 완료 |
| 리뷰 후 보완 반영 기록 | 완료 |
| 원고 상태 변경 | 완료 |
| Chapter 08 1차 완료 판정 | 완료 |

---

## 5. 결론

```text
Chapter 08은 일반 독자가 혼자 읽고 따라갈 수 있는 실용서형 문체로 1차 정리했다.
다음 작업은 다른 장에도 같은 기준을 적용하는 것이다.
```
