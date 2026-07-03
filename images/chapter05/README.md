# Chapter 05 이미지/도식 설계

## Chapter 05. 데이터 모델링과 ERD

이 문서는 Chapter 05 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 05는 요구사항을 데이터베이스 구조로 바꾸는 장이므로, 도식은 **요구사항 분석 흐름, 엔터티/속성 구분, 기본키/외래키, 1:N 관계, N:M 관계와 중간 테이블, 도서 대여 ERD, AI 생성 ERD 검토**를 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 요구사항 문장에서 테이블 후보를 찾는 과정을 보여 준다.
- 엔터티와 속성의 차이를 시각적으로 구분한다.
- 기본키와 외래키가 관계를 만드는 방식을 표현한다.
- 1:N 관계에서는 N쪽에 외래키가 들어간다는 점을 강조한다.
- N:M 관계는 중간 테이블로 풀어야 한다는 점을 보여 준다.
- 도서 대여 시스템의 members, books, loans 구조와 연결한다.
- AI가 만든 ERD를 사람이 검토하는 흐름을 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 5-1 | `ch05_01_modeling_process.svg` | 데이터 모델링 전체 흐름 | 2장 데이터 모델링의 기본 흐름 | 삽입 완료 |
| 그림 5-2 | `ch05_02_entity_attribute_classification.svg` | 엔터티와 속성 구분 | 4장 엔터티와 속성 구분하기 | 삽입 완료 |
| 그림 5-3 | `ch05_03_primary_foreign_key_relationship.svg` | 기본키와 외래키 관계 | 5장 기본키와 외래키 설계하기 | 삽입 완료 |
| 그림 5-4 | `ch05_04_one_to_many_relationship.svg` | 1:N 관계 구조 | 6.1장 1:N 관계 | 삽입 완료 |
| 그림 5-5 | `ch05_05_many_to_many_bridge_table.svg` | N:M 관계와 중간 테이블 | 6.2장 N:M 관계 | 삽입 완료 |
| 그림 5-6 | `ch05_06_library_erd_overview.svg` | 도서 대여 시스템 ERD | 9장 ERD 초안 작성하기 | 삽입 완료 |
| 그림 5-7 | `ch05_07_erd_to_sql_flow.svg` | ERD에서 SQL로 변환 | 10장 ERD를 PostgreSQL 테이블로 바꾸기 | 삽입 완료 |
| 그림 5-8 | `ch05_08_ai_erd_review_flow.svg` | AI 생성 ERD 검토 흐름 | 15장 AI가 만든 ERD 검토하기 | 삽입 완료 |

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch05_01_modeling_process.mmd` | `ch05_01_modeling_process.svg` |
| `ch05_02_entity_attribute_classification.mmd` | `ch05_02_entity_attribute_classification.svg` |
| `ch05_03_primary_foreign_key_relationship.mmd` | `ch05_03_primary_foreign_key_relationship.svg` |
| `ch05_04_one_to_many_relationship.mmd` | `ch05_04_one_to_many_relationship.svg` |
| `ch05_05_many_to_many_bridge_table.mmd` | `ch05_05_many_to_many_bridge_table.svg` |
| `ch05_06_library_erd_overview.mmd` | `ch05_06_library_erd_overview.svg` |
| `ch05_07_erd_to_sql_flow.mmd` | `ch05_07_erd_to_sql_flow.svg` |
| `ch05_08_ai_erd_review_flow.mmd` | `ch05_08_ai_erd_review_flow.svg` |

---

## 4. 도식 제작 후 점검 항목

```text
- 요구사항에서 엔터티 후보를 찾는 흐름이 명확한가?
- 엔터티와 속성이 혼동되지 않도록 표현되었는가?
- 기본키와 외래키의 역할이 분리되어 있는가?
- 1:N 관계에서 외래키 위치가 정확한가?
- N:M 관계가 중간 테이블로 풀리는 과정이 보이는가?
- 도서 대여 시스템 ERD가 library_schema.sql과 일치하는가?
- AI 생성 ERD 검토 흐름에 요구사항, 관계, 중복, 확장성 검토가 포함되는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 05 도식 후보 8종 정리 완료
- Chapter 05 Mermaid 원본 8종 작성 완료
- Chapter 05 SVG 도식 8종 생성 완료
- Chapter 05 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 05 리뷰 체크리스트 작성
```
