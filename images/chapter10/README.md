# Chapter 10 이미지/도식 설계

## Chapter 10. 인덱스와 성능 기초

이 문서는 Chapter 10 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 10은 데이터가 많아질 때 조회 속도가 느려지는 이유와 인덱스를 통해 검색 경로가 어떻게 달라지는지 설명하는 장입니다. 따라서 도식은 **전체 테이블 스캔과 인덱스 검색 차이, WHERE/ORDER BY/JOIN 조건에서의 인덱스 활용, 복합 인덱스, EXPLAIN 비교, AI 추천 인덱스 검토**를 초급자가 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 인덱스를 책의 색인처럼 이해할 수 있도록 표현한다.
- 전체 테이블 스캔과 인덱스 검색의 차이를 시각적으로 비교한다.
- WHERE, ORDER BY, JOIN 조건에서 인덱스 후보를 찾는 흐름을 보여 준다.
- 복합 인덱스는 컬럼 순서가 중요하다는 점을 포함한다.
- EXPLAIN은 완전한 해석보다 실행 계획 비교 습관을 강조한다.
- AI가 추천한 인덱스를 사람이 검토하는 절차를 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 10-1 | `ch10_01_index_need_overview.svg` | 인덱스가 필요한 이유 | 1장 왜 인덱스를 배워야 하는가 | 데이터 증가에 따라 검색 비용이 커지는 상황 설명 | 높음 |
| 그림 10-2 | `ch10_02_table_scan_vs_index_scan.svg` | 전체 테이블 스캔과 인덱스 검색 비교 | 4장 인덱스가 없는 조회와 있는 조회 | Seq Scan과 Index Scan 차이를 직관적으로 비교 | 높음 |
| 그림 10-3 | `ch10_03_where_index_candidate.svg` | WHERE 조건과 인덱스 후보 | 5장 WHERE 조건과 인덱스 | 자주 검색되는 컬럼이 인덱스 후보가 되는 흐름 설명 | 높음 |
| 그림 10-4 | `ch10_04_order_by_index_flow.svg` | ORDER BY와 인덱스 | 6장 ORDER BY와 인덱스 | 정렬 작업과 인덱스의 관계 설명 | 중간 |
| 그림 10-5 | `ch10_05_join_foreign_key_index.svg` | JOIN 조건과 외래키 인덱스 | 7장 JOIN 조건과 인덱스 | JOIN 조건에 사용되는 외래키 컬럼을 인덱스 후보로 보는 이유 설명 | 높음 |
| 그림 10-6 | `ch10_06_composite_index_order.svg` | 복합 인덱스와 컬럼 순서 | 8장 복합 인덱스 맛보기 | `(course_id, status)`처럼 컬럼 순서가 중요한 이유 설명 | 높음 |
| 그림 10-7 | `ch10_07_explain_before_after.svg` | EXPLAIN 생성 전후 비교 | 9장 EXPLAIN 실행 계획 맛보기 | 인덱스 생성 전후 실행 계획 비교 절차 설명 | 높음 |
| 그림 10-8 | `ch10_08_ai_index_review_flow.svg` | AI 추천 인덱스 검토 흐름 | 13장 AI가 추천한 인덱스 검토하기 | AI 추천을 쿼리 패턴, 데이터 양, 실행 계획으로 검토 | 높음 |

---

## 3. 본문 삽입 권장 위치

| 그림 | 삽입 권장 위치 |
| --- | --- |
| 그림 10-1 | 1. 왜 인덱스를 배워야 하는가 |
| 그림 10-2 | 4. 인덱스가 없는 조회와 있는 조회 |
| 그림 10-3 | 5. WHERE 조건과 인덱스 |
| 그림 10-4 | 6. ORDER BY와 인덱스 |
| 그림 10-5 | 7. JOIN 조건과 인덱스 |
| 그림 10-6 | 8. 복합 인덱스 맛보기 |
| 그림 10-7 | 9. EXPLAIN 실행 계획 맛보기 |
| 그림 10-8 | 13. AI가 추천한 인덱스 검토하기 |

---

## 4. Mermaid 원본 파일 계획

| Mermaid 파일 | 대상 이미지 |
| --- | --- |
| `ch10_01_index_need_overview.mmd` | `ch10_01_index_need_overview.svg` |
| `ch10_02_table_scan_vs_index_scan.mmd` | `ch10_02_table_scan_vs_index_scan.svg` |
| `ch10_03_where_index_candidate.mmd` | `ch10_03_where_index_candidate.svg` |
| `ch10_04_order_by_index_flow.mmd` | `ch10_04_order_by_index_flow.svg` |
| `ch10_05_join_foreign_key_index.mmd` | `ch10_05_join_foreign_key_index.svg` |
| `ch10_06_composite_index_order.mmd` | `ch10_06_composite_index_order.svg` |
| `ch10_07_explain_before_after.mmd` | `ch10_07_explain_before_after.svg` |
| `ch10_08_ai_index_review_flow.mmd` | `ch10_08_ai_index_review_flow.svg` |

---

## 5. 도식 제작 후 점검 항목

```text
- 인덱스가 필요한 이유가 데이터 증가 상황과 연결되어 보이는가?
- Seq Scan과 Index Scan 차이가 초급자에게 직관적으로 전달되는가?
- WHERE, ORDER BY, JOIN 조건에서 인덱스 후보를 찾는 흐름이 명확한가?
- 복합 인덱스의 컬럼 순서 중요성이 표현되는가?
- EXPLAIN은 실행 계획 비교 도구로 설명되는가?
- AI 추천 인덱스 검토 흐름에 쿼리 패턴, 데이터 양, 선택도, 쓰기 비용, 실행 계획이 포함되는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 10 도식 후보 8종 정리 완료
- 다음 작업: Chapter 10 Mermaid 도식 원본 8종 작성
```
