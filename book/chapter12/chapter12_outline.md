# Chapter 12. NoSQL 이해와 선택 기준

## 장의 목표

관계형 데이터베이스와 NoSQL 계열 저장소의 차이를 이해하고, 온라인 강의 서비스의 데이터 성격과 조회 패턴에 맞는 저장 방식을 판단할 수 있도록 한다.

## 학습 목표

- NoSQL을 관계형 DB의 대체재가 아니라 다양한 저장 방식의 계열로 설명할 수 있다.
- Key-Value, Document, Column-Family, Graph DB의 적합한 사용 상황을 구분할 수 있다.
- 온라인 강의 서비스에서 세션, 캐시, 강의 메타데이터, 학습 이벤트, 추천 관계에 맞는 저장 방식을 판단할 수 있다.
- PostgreSQL JSONB와 실제 Document DB의 차이를 설명할 수 있다.
- JSONB 연산자와 인덱스가 어떤 상황에서 필요한지 해석할 수 있다.
- AI가 추천한 NoSQL 선택 결과를 데이터 구조, 조회 패턴, 정합성, 운영 난이도 기준으로 검토할 수 있다.

## 핵심 개념

- NoSQL
- Key-Value DB
- Document DB
- 와이드 컬럼(Column-Family) DB
- Graph DB
- JSONB
- query pattern
- data modeling
- flexible schema
- consistency model
- transaction scope
- source of truth
- cache / derived data
- partition key
- sort key
- denormalization
- operational complexity
- small-scale validation
- AI recommendation validation

## 구성

1. NoSQL을 왜 배우는가
2. RDBMS와 NoSQL의 역할 나누기
3. NoSQL의 의미와 오해 정리
4. NoSQL 유형 한눈에 보기
5. Key-Value DB: 세션과 캐시
6. Document DB: 강의 문서와 유연한 메타데이터
7. Column-Family DB: 학습 이벤트 조회 패턴
8. Graph DB: 학생-강의-주제 관계 탐색
9. PostgreSQL JSONB로 문서형 데이터 맛보기
10. 온라인 강의 데이터 저장 방식 선택 기준
11. AI 추천 결과 검토하기

## 실습 파일

| 파일 | 설명 |
|---|---|
| `code/chapter12/nosql_jsonb_practice.sql` | PostgreSQL JSONB 실습, Key-Value 개념 시뮬레이션, 저장 방식 선택 사례 |
| `book/chapter12/chapter12_activity.md` | 실습 활동지와 자기 점검 문항 |

## 그림 구성

| 번호 | 파일 | 위치 |
|---|---|---|
| 그림 12-1 | `ch12_01_rdbms_vs_nosql_overview.svg` | RDBMS와 NoSQL 역할 비교 |
| 그림 12-2 | `ch12_02_nosql_types_map.svg` | NoSQL 유형 정리 |
| 그림 12-3 | `ch12_03_key_value_lookup.svg` | Key-Value 조회와 캐시 미스 |
| 그림 12-4 | `ch12_04_document_json_structure.svg` | Document JSON 구조 |
| 그림 12-5 | `ch12_05_column_family_log_flow.svg` | Column-Family 조회 패턴 |
| 그림 12-6 | `ch12_06_graph_relationship_search.svg` | Graph 관계 탐색 |
| 그림 12-7 | `ch12_07_jsonb_practice_flow.svg` | JSONB 실습 흐름 |
| 그림 12-8 | `ch12_08_ai_nosql_choice_review.svg` | AI 추천 검토 흐름 |

## 주의할 점

- NoSQL을 항상 빠르거나 항상 스키마가 없는 기술로 설명하지 않는다.
- NoSQL 제품명을 암기하는 장으로 만들지 않는다.
- PostgreSQL JSONB를 실제 Document DB와 동일한 것으로 설명하지 않는다.
- Column-Family DB를 아무 조건이나 자유롭게 분석하는 저장소로 설명하지 않는다.
- Key-Value 실습 테이블을 실제 Key-Value DB의 성능, 분산, 자동 TTL, 복제 기능으로 오해하지 않게 한다.
