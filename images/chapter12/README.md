# Chapter 12 이미지/도식 설계

## Chapter 12. NoSQL 이해와 선택 기준

이 문서는 Chapter 12 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 12는 관계형 데이터베이스와 NoSQL의 차이를 이해하고, 데이터 구조와 조회 패턴에 맞는 저장 방식을 선택하는 장입니다. 따라서 도식은 **RDBMS와 NoSQL 비교, NoSQL 유형 분류, JSONB 문서형 데이터 구조, Key-Value 조회, 대규모 로그 저장, Graph 관계 탐색, DB 선택 기준, AI 추천 검토 흐름**을 초급자가 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- NoSQL을 관계형 DB의 대체재가 아니라 선택 가능한 저장 방식의 계열로 설명한다.
- RDBMS와 NoSQL의 차이를 좋고 나쁨이 아니라 목적과 사용 방식의 차이로 보여 준다.
- Key-Value, Document, Column-Family, Graph DB의 특징을 한눈에 비교한다.
- PostgreSQL JSONB는 Document DB의 완전한 대체가 아니라 문서형 데이터 맛보기로 표현한다.
- 데이터 저장 방식 선택은 데이터 구조, 조회 패턴, 정합성, 운영 난이도를 함께 고려해야 함을 강조한다.
- AI가 추천한 DB 선택 결과는 사람이 검토해야 한다는 흐름을 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 12-1 | `ch12_01_rdbms_vs_nosql_overview.svg` | RDBMS와 NoSQL의 차이 | 3장 관계형 데이터베이스와 NoSQL 비교 | 삽입 완료 |
| 그림 12-2 | `ch12_02_nosql_types_map.svg` | NoSQL 유형 분류 | 2장 NoSQL이란 무엇인가 | 삽입 완료 |
| 그림 12-3 | `ch12_03_key_value_lookup.svg` | Key-Value DB 조회 흐름 | 4장 Key-Value DB | 삽입 완료 |
| 그림 12-4 | `ch12_04_document_json_structure.svg` | Document DB와 JSON 문서 구조 | 5장 Document DB | 삽입 완료 |
| 그림 12-5 | `ch12_05_column_family_log_flow.svg` | Column-Family와 대규모 로그 흐름 | 6장 Column-Family DB | 삽입 완료 |
| 그림 12-6 | `ch12_06_graph_relationship_search.svg` | Graph DB 관계 탐색 | 7장 Graph DB | 삽입 완료 |
| 그림 12-7 | `ch12_07_jsonb_practice_flow.svg` | PostgreSQL JSONB 문서형 데이터 맛보기 | 8장 PostgreSQL JSONB로 문서형 데이터 맛보기 | 삽입 완료 |
| 그림 12-8 | `ch12_08_ai_nosql_choice_review.svg` | AI 추천 NoSQL 선택 검토 흐름 | 11장 AI가 추천한 NoSQL 선택 결과 검토하기 | 삽입 완료 |

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch12_01_rdbms_vs_nosql_overview.mmd` | `ch12_01_rdbms_vs_nosql_overview.svg` |
| `ch12_02_nosql_types_map.mmd` | `ch12_02_nosql_types_map.svg` |
| `ch12_03_key_value_lookup.mmd` | `ch12_03_key_value_lookup.svg` |
| `ch12_04_document_json_structure.mmd` | `ch12_04_document_json_structure.svg` |
| `ch12_05_column_family_log_flow.mmd` | `ch12_05_column_family_log_flow.svg` |
| `ch12_06_graph_relationship_search.mmd` | `ch12_06_graph_relationship_search.svg` |
| `ch12_07_jsonb_practice_flow.mmd` | `ch12_07_jsonb_practice_flow.svg` |
| `ch12_08_ai_nosql_choice_review.mmd` | `ch12_08_ai_nosql_choice_review.svg` |

---

## 4. 도식 제작 후 점검 항목

```text
- RDBMS와 NoSQL의 차이가 기술 우열이 아니라 목적 차이로 표현되는가?
- NoSQL 유형별 저장 구조와 사용 사례가 명확한가?
- Key-Value DB의 키 기반 조회 장점과 복잡한 조건 검색 한계가 표현되는가?
- Document DB와 JSONB의 문서형 구조가 초급자에게 직관적인가?
- Column-Family DB가 대규모 로그/이벤트 데이터와 연결되는가?
- Graph DB가 노드와 관계 탐색으로 표현되는가?
- DB 선택 기준에 데이터 구조, 조회 패턴, 정합성, 운영 난이도가 포함되는가?
- AI 추천 검토 흐름에 사람의 최종 판단이 포함되는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 12 도식 후보 8종 정리 완료
- Chapter 12 Mermaid 원본 8종 작성 완료
- Chapter 12 SVG 도식 8종 생성 완료
- Chapter 12 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 12 리뷰 체크리스트 작성
```
