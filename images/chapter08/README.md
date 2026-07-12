# Chapter 08 이미지/도식 설계

## Chapter 08. JOIN과 집계 쿼리

이 문서는 Chapter 08 본문에 삽입하는 8개 정식 SVG 도식의 역할과 검증 상태를 정리합니다.

모든 도식은 `images/SVG_STYLE_GUIDE.md`를 최우선 기준으로 따릅니다.

---

## 공통 원칙

```text
- 하나의 SVG는 하나의 핵심 메시지만 전달한다.
- 전체 SQL과 대형 결과표를 SVG 안에 반복하지 않는다.
- 관계 도식과 작업 흐름 도식을 분리한다.
- Mermaid 원본과 SVG의 핵심 노드, 분기, 결론을 동기화한다.
- 실제 렌더링 확인 결과를 문서에 기록한다.
```

---

## 도식 목록

| 번호 | 파일 | 제목 |
| --- | --- | --- |
| 그림 8-1 | `ch08_01_join_why_needed.svg` | 정규화된 테이블에 JOIN이 필요한 이유 |
| 그림 8-2 | `ch08_02_inner_join_concept.svg` | INNER JOIN은 일치하는 행만 포함한다 |
| 그림 8-3 | `ch08_03_multi_table_join_path.svg` | 수강신청 현황을 만드는 다중 JOIN 경로 |
| 그림 8-4 | `ch08_04_left_join_null_rows.svg` | LEFT JOIN은 왼쪽 행을 모두 유지한다 |
| 그림 8-5 | `ch08_05_group_by_aggregation_flow.svg` | GROUP BY로 상태별 행 묶기 |
| 그림 8-6 | `ch08_06_course_revenue_summary.svg` | 강의별 신청 건수와 결제금액 집계 |
| 그림 8-7 | `ch08_07_where_group_having_order.svg` | 집계 쿼리의 논리적 처리 흐름 |
| 그림 8-8 | `ch08_08_ai_join_sql_review_flow.svg` | AI 생성 JOIN·집계 SQL 검토 흐름 |

---

## Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch08_01_join_why_needed.mmd` | `ch08_01_join_why_needed.svg` |
| `ch08_02_inner_join_concept.mmd` | `ch08_02_inner_join_concept.svg` |
| `ch08_03_multi_table_join_path.mmd` | `ch08_03_multi_table_join_path.svg` |
| `ch08_04_left_join_null_rows.mmd` | `ch08_04_left_join_null_rows.svg` |
| `ch08_05_group_by_aggregation_flow.mmd` | `ch08_05_group_by_aggregation_flow.svg` |
| `ch08_06_course_revenue_summary.mmd` | `ch08_06_course_revenue_summary.svg` |
| `ch08_07_where_group_having_order.mmd` | `ch08_07_where_group_having_order.svg` |
| `ch08_08_ai_join_sql_review_flow.mmd` | `ch08_08_ai_join_sql_review_flow.svg` |

---

## 역할 요약

```text
- 그림 8-1: 정규화된 사실을 JOIN으로 조립하는 이유
- 그림 8-2: INNER JOIN의 포함 범위와 5행 결과
- 그림 8-3: 정확한 FK 경로를 통한 다중 JOIN
- 그림 8-4: LEFT JOIN의 6행 결과와 NULL 생성
- 그림 8-5: 5개 원본 행이 3개 그룹으로 바뀌는 과정
- 그림 8-6: 신청 건수, 고유 학생 수, 결제금액 합계의 구분
- 그림 8-7: WHERE와 HAVING을 포함한 논리적 처리 흐름
- 그림 8-8: AI SQL 수정·재실행 피드백 루프
```

---

## 검증 상태

| 항목 | 상태 | 비고 |
| --- | --- | --- |
| SVG_STYLE_GUIDE.md 준수 기준 반영 | 완료 | 단일 메시지, 중복 제거, 역할 분리 기준 반영 |
| Mermaid 원본 8종 갱신 | 완료 | SQL 전문과 대형 표 복제 제거 |
| SVG 결과물 8종 갱신 | 완료 | 접근성 요소와 단순 레이아웃 적용 |
| 본문 그림 제목 동기화 | 완료 | 장 본문 캡션과 동일 제목 사용 |
| 렌더링 검증 기록 갱신 | 부분 완료 | XML 검증과 파일 확인 완료, 브라우저/GitHub/PDF 축소는 수동 확인 필요 |

리뷰 체크리스트는 이미 `notes/chapter08_review_checklist.md`에 존재하므로, 별도의 “다음 작업: 리뷰 체크리스트 작성” 항목은 제거했습니다.
# Chapter 08 이미지/도식 설계

## Chapter 08. JOIN과 집계 쿼리

이 문서는 Chapter 08 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 08은 정규화된 여러 테이블을 실제 조회와 통계 결과로 연결하는 장입니다. 따라서 도식은 **JOIN 구조, INNER JOIN과 LEFT JOIN 차이, 여러 테이블 JOIN 경로, GROUP BY와 집계 함수 흐름, HAVING, AI SQL 검토**를 입문 독자가 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- JOIN을 단순 문법이 아니라 외래키 관계를 따라 테이블을 연결하는 과정으로 보여 준다.
- INNER JOIN과 LEFT JOIN의 결과 차이를 시각적으로 비교한다.
- Chapter 07의 students, instructors, courses, enrollments 구조를 이어서 사용한다.
- GROUP BY는 같은 값을 가진 행을 묶는 흐름으로 표현한다.
- COUNT, SUM, AVG는 그룹별 요약값을 만드는 과정으로 표현한다.
- HAVING은 집계 이후 결과를 필터링하는 단계로 보여 준다.
- AI가 만든 JOIN/집계 SQL을 검토하는 절차를 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 8-1 | `ch08_01_join_why_needed.svg` | JOIN이 필요한 이유 | 1장 왜 JOIN과 집계 쿼리를 배워야 하는가 | 삽입 완료 |
| 그림 8-2 | `ch08_02_inner_join_concept.svg` | INNER JOIN 개념 | 3장 INNER JOIN 이해하기 | 삽입 완료 |
| 그림 8-3 | `ch08_03_multi_table_join_path.svg` | 여러 테이블 JOIN 경로 | 5장 여러 테이블 JOIN | 삽입 완료 |
| 그림 8-4 | `ch08_04_left_join_null_rows.svg` | LEFT JOIN과 NULL 결과 | 6장 LEFT JOIN 이해하기 | 삽입 완료 |
| 그림 8-5 | `ch08_05_group_by_aggregation_flow.svg` | GROUP BY와 집계 흐름 | 8장 GROUP BY 이해하기 | 삽입 완료 |
| 그림 8-6 | `ch08_06_course_revenue_summary.svg` | 강의별 수강생 수와 매출 집계 | 9장 강의별 수강생 수 구하기 | 삽입 완료 |
| 그림 8-7 | `ch08_07_where_group_having_order.svg` | SQL 실행 순서: WHERE, GROUP BY, HAVING | 12장 HAVING 이해하기 | 삽입 완료 |
| 그림 8-8 | `ch08_08_ai_join_sql_review_flow.svg` | AI 생성 JOIN/집계 SQL 검토 | 14장 AI가 만든 SQL 검토 | 삽입 완료 |

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch08_01_join_why_needed.mmd` | `ch08_01_join_why_needed.svg` |
| `ch08_02_inner_join_concept.mmd` | `ch08_02_inner_join_concept.svg` |
| `ch08_03_multi_table_join_path.mmd` | `ch08_03_multi_table_join_path.svg` |
| `ch08_04_left_join_null_rows.mmd` | `ch08_04_left_join_null_rows.svg` |
| `ch08_05_group_by_aggregation_flow.mmd` | `ch08_05_group_by_aggregation_flow.svg` |
| `ch08_06_course_revenue_summary.mmd` | `ch08_06_course_revenue_summary.svg` |
| `ch08_07_where_group_having_order.mmd` | `ch08_07_where_group_having_order.svg` |
| `ch08_08_ai_join_sql_review_flow.mmd` | `ch08_08_ai_join_sql_review_flow.svg` |

---

## 4. 도식 제작 후 점검 항목

```text
- JOIN이 왜 필요한지 정규화 구조와 연결되어 보이는가?
- INNER JOIN과 LEFT JOIN의 차이가 분명한가?
- 여러 테이블 JOIN 경로에서 FK 연결 방향이 명확한가?
- GROUP BY와 집계 함수의 관계가 잘 드러나는가?
- WHERE와 HAVING의 차이가 실행 흐름으로 표현되는가?
- AI SQL 검토 흐름에 JOIN 조건, GROUP BY, COUNT, NULL 처리, 실행 검증이 포함되는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 08 도식 후보 8종 정리 완료
- Chapter 08 Mermaid 원본 8종 작성 완료
- Chapter 08 SVG 도식 8종 생성 완료
- Chapter 08 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 08 리뷰 체크리스트 작성
```
