# Chapter 08 이미지/도식 설계

## Chapter 08. JOIN과 집계 쿼리

이 문서는 Chapter 08 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 08은 정규화된 여러 테이블을 실제 조회와 통계 결과로 연결하는 장입니다. 따라서 도식은 **JOIN 구조, INNER JOIN과 LEFT JOIN 차이, 여러 테이블 JOIN 경로, GROUP BY와 집계 함수 흐름, HAVING, AI SQL 검토**를 초급자가 직관적으로 이해할 수 있도록 구성합니다.

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

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 8-1 | `ch08_01_join_why_needed.svg` | JOIN이 필요한 이유 | 1장 왜 JOIN과 집계 쿼리를 배워야 하는가 | 정규화로 나뉜 테이블을 다시 연결하는 이유 설명 | 높음 |
| 그림 8-2 | `ch08_02_inner_join_concept.svg` | INNER JOIN 개념 | 3장 INNER JOIN 이해하기 | 양쪽 조건이 일치하는 데이터만 조회되는 구조 설명 | 높음 |
| 그림 8-3 | `ch08_03_multi_table_join_path.svg` | 여러 테이블 JOIN 경로 | 5장 여러 테이블 JOIN | enrollments에서 students/courses/instructors로 이어지는 FK 경로 설명 | 높음 |
| 그림 8-4 | `ch08_04_left_join_null_rows.svg` | LEFT JOIN과 NULL 결과 | 6장 LEFT JOIN 이해하기 | 기준 테이블 행을 유지하고 없는 값은 NULL로 표시되는 구조 설명 | 높음 |
| 그림 8-5 | `ch08_05_group_by_aggregation_flow.svg` | GROUP BY와 집계 흐름 | 8장 GROUP BY 이해하기 | 행을 그룹으로 묶고 COUNT/SUM/AVG를 계산하는 흐름 설명 | 높음 |
| 그림 8-6 | `ch08_06_course_revenue_summary.svg` | 강의별 수강생 수와 매출 집계 | 9~10장 강의별 수강생 수/매출 | JOIN과 집계가 결합되는 분석 예시 설명 | 중간 |
| 그림 8-7 | `ch08_07_where_group_having_order.svg` | SQL 실행 순서: WHERE, GROUP BY, HAVING | 12~13장 HAVING/WHERE 함께 사용 | WHERE와 HAVING의 차이 및 실행 흐름 설명 | 높음 |
| 그림 8-8 | `ch08_08_ai_join_sql_review_flow.svg` | AI 생성 JOIN/집계 SQL 검토 | 14장 AI가 만든 SQL 검토 | AI SQL을 JOIN 조건, GROUP BY, COUNT, NULL 처리 기준으로 검토 | 높음 |

---

## 3. 본문 삽입 권장 위치

| 그림 | 삽입 권장 위치 |
| --- | --- |
| 그림 8-1 | 1. 왜 JOIN과 집계 쿼리를 배워야 하는가 |
| 그림 8-2 | 3. INNER JOIN 이해하기 |
| 그림 8-3 | 5. 여러 테이블 JOIN |
| 그림 8-4 | 6. LEFT JOIN 이해하기 |
| 그림 8-5 | 8. GROUP BY 이해하기 |
| 그림 8-6 | 9. 강의별 수강생 수 구하기 또는 10. 강의별 매출 구하기 |
| 그림 8-7 | 12. HAVING 이해하기 또는 13. WHERE와 GROUP BY 함께 사용하기 |
| 그림 8-8 | 14. AI가 만든 JOIN/집계 SQL 검토하기 |

---

## 4. Mermaid 원본 파일 계획

| Mermaid 파일 | 대상 이미지 |
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

## 5. 도식 제작 후 점검 항목

```text
- JOIN이 왜 필요한지 정규화 구조와 연결되어 보이는가?
- INNER JOIN과 LEFT JOIN의 차이가 분명한가?
- 여러 테이블 JOIN 경로에서 FK 연결 방향이 명확한가?
- GROUP BY와 집계 함수의 관계가 잘 드러나는가?
- WHERE와 HAVING의 차이가 실행 흐름으로 표현되는가?
- AI SQL 검토 흐름에 JOIN 조건, GROUP BY, COUNT, NULL 처리, 실행 검증이 포함되는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 08 도식 후보 8종 정리 완료
- 다음 작업: Chapter 08 Mermaid 도식 원본 8종 작성
```
