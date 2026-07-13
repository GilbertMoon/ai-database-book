# Chapter 12 이미지 자료

## Chapter 12. NoSQL 이해와 선택 기준

Chapter 12는 온라인 강의 서비스의 데이터를 기준으로 RDBMS와 NoSQL 계열 저장소의 역할을 구분하는 장입니다. 도식은 `images/SVG_STYLE_GUIDE.md`를 따르며, 입문 독자가 저장 방식과 조회 패턴을 직관적으로 이해할 수 있도록 구성합니다.

## 공통 원칙

- NoSQL을 RDBMS의 대체재가 아니라 상황별 선택 가능한 저장 방식의 계열로 표현한다.
- 제품명을 나열하기보다 데이터 구조와 조회 패턴을 중심으로 설명한다.
- 온라인 강의 서비스 도메인 용어를 사용한다.
- PostgreSQL JSONB는 실제 Document DB 자체가 아니라 문서형 데이터 맛보기로 표현한다.
- Key-Value 캐시는 원본이 아니라 파생 데이터임을 보여 준다.
- SVG는 접근성 제목과 설명을 포함하고, 한글 렌더링을 위해 `Malgun Gothic` 글꼴을 포함한다.

## 그림 목록

| 번호 | 파일 | 설명 | 본문 위치 |
|---|---|---|---|
| 그림 12-1 | `ch12_01_rdbms_vs_nosql_overview.svg` | RDBMS와 NoSQL 역할 나누기 | 2장 RDBMS와 NoSQL의 역할 나누기 |
| 그림 12-2 | `ch12_02_nosql_types_map.svg` | NoSQL 유형 정리 | 4장 NoSQL 유형 한눈에 보기 |
| 그림 12-3 | `ch12_03_key_value_lookup.svg` | Key-Value 조회와 캐시 미스 | 5장 Key-Value DB |
| 그림 12-4 | `ch12_04_document_json_structure.svg` | Document JSON 구조 | 6장 Document DB |
| 그림 12-5 | `ch12_05_column_family_log_flow.svg` | Column-Family 조회 패턴 | 7장 Column-Family DB |
| 그림 12-6 | `ch12_06_graph_relationship_search.svg` | Graph 관계 탐색 | 8장 Graph DB |
| 그림 12-7 | `ch12_07_jsonb_practice_flow.svg` | PostgreSQL JSONB 실습 흐름 | 9장 PostgreSQL JSONB 실습 |
| 그림 12-8 | `ch12_08_ai_nosql_choice_review.svg` | AI 추천 NoSQL 선택 검토 흐름 | 11장 AI 추천 검토 |

## 원본 Mermaid와 SVG

| Mermaid | SVG |
|---|---|
| `ch12_01_rdbms_vs_nosql_overview.mmd` | `ch12_01_rdbms_vs_nosql_overview.svg` |
| `ch12_02_nosql_types_map.mmd` | `ch12_02_nosql_types_map.svg` |
| `ch12_03_key_value_lookup.mmd` | `ch12_03_key_value_lookup.svg` |
| `ch12_04_document_json_structure.mmd` | `ch12_04_document_json_structure.svg` |
| `ch12_05_column_family_log_flow.mmd` | `ch12_05_column_family_log_flow.svg` |
| `ch12_06_graph_relationship_search.mmd` | `ch12_06_graph_relationship_search.svg` |
| `ch12_07_jsonb_practice_flow.mmd` | `ch12_07_jsonb_practice_flow.svg` |
| `ch12_08_ai_nosql_choice_review.mmd` | `ch12_08_ai_nosql_choice_review.svg` |

## 검수 기준

- 그림 번호와 본문 삽입 순서가 일치하는가?
- RDBMS와 NoSQL 비교가 기술 우열이 아니라 역할 차이로 표현되는가?
- Key-Value, Document, Column-Family, Graph DB만 Chapter 12 범위로 표현되는가?
- Column-Family 그림이 partition key, sort key, target query 중심으로 표현되는가?
- Graph 그림이 Student, Course, Topic 노드와 ENROLLED, INTERESTED_IN, RELATED_TO 관계를 표현하는가?
- JSONB와 Document DB가 동일한 것으로 오해되지 않는가?
