# Chapter 02 이미지/도식 설계

## Chapter 02. 데이터와 DBMS의 기본 개념

이 문서는 Chapter 02 본문과 활동 자료에 사용할 도식과 현재 삽입 상태를 정리합니다.

Chapter 02는 PostgreSQL 실습 전에 필요한 기본 용어를 다루므로, 도식은 **테이블 구조, 기본키와 외래키, 관계 유형, AI 생성 구조 검토**를 초급자가 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 초급자가 테이블, 행, 열을 직관적으로 구분할 수 있어야 한다.
- 기본키와 외래키의 차이 및 정확한 참조 대상을 시각적으로 보여 준다.
- 학생-강의-수강신청 예제를 중심으로 관계를 설명한다.
- 본문에서 다루지 않는 상세 설계 문법은 도식에 과도하게 추가하지 않는다.
- 본문 그림 번호와 실제 삽입 상태를 일치시킨다.
```

---

## 2. 본문에 사용 중인 도식

| 본문 번호 | 파일명 | 도식 제목 | 본문 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 2-1 | `ch02_02_table_row_column.svg` | 테이블, 행, 열과 셀의 구조 | 5장 테이블, 행, 열과 셀 | 사용 중 |
| 그림 2-2 | `ch02_03_primary_key_concept.svg` | 기본키가 행을 구분하는 방식 | 7.1 기본키 | 사용 중 |
| 그림 2-3 | `ch02_04_foreign_key_relationship.svg` | 외래키로 연결되는 학생·강의·수강신청 관계 | 7.2 외래키 | 사용 중 |
| 그림 2-4 | `ch02_05_relationship_types.svg` | 1:1, 1:N, N:M 관계 유형 | 8장 데이터 관계 미리보기 | 사용 중 |
| 그림 2-5 | `ch02_08_ai_table_review.svg` | AI 생성 테이블 구조 검토 흐름 | 13장 AI가 만든 구조 검토 | 사용 중 |

---

## 3. 현재 본문에서 제외된 도식

다음 파일은 보존하지만 현재 `book/chapter02/chapter02.md` 본문에서는 사용하지 않습니다.

| 파일명 | 기존 목적 | 현재 처리 |
| --- | --- | --- |
| `ch02_01_dbms_hierarchy.svg` | DBMS, 데이터베이스, 테이블 계층 | 스키마 단계가 포함되지 않아 본문에서 제외하고 텍스트 계층 구조로 대체 |
| `ch02_06_crud_flow.svg` | CRUD와 SQL 명령어 흐름 | CRUD를 용어 소개 수준으로 축소하면서 본문에서 제외 |
| `ch02_07_constraints_guardrail.svg` | 제약조건 안전장치 | 제약조건을 개요 수준으로 축소하면서 본문에서 제외 |

사용하지 않는 SVG와 Mermaid 원본은 삭제하지 않습니다. 향후 활동 자료나 개정판에서 다시 사용할 수 있습니다.

---

## 4. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 | 현재 본문 사용 |
| --- | --- | --- |
| `ch02_01_dbms_hierarchy.mmd` | `ch02_01_dbms_hierarchy.svg` | 미사용 |
| `ch02_02_table_row_column.mmd` | `ch02_02_table_row_column.svg` | 사용 |
| `ch02_03_primary_key_concept.mmd` | `ch02_03_primary_key_concept.svg` | 사용 |
| `ch02_04_foreign_key_relationship.mmd` | `ch02_04_foreign_key_relationship.svg` | 사용 |
| `ch02_05_relationship_types.mmd` | `ch02_05_relationship_types.svg` | 사용 |
| `ch02_06_crud_flow.mmd` | `ch02_06_crud_flow.svg` | 미사용 |
| `ch02_07_constraints_guardrail.mmd` | `ch02_07_constraints_guardrail.svg` | 미사용 |
| `ch02_08_ai_table_review.mmd` | `ch02_08_ai_table_review.svg` | 사용 |

---

## 5. 도식 제작 및 검수 항목

```text
- Chapter 02 본문 설명과 도식 내용이 일치하는가?
- 테이블, 행, 열이 초급자에게 직관적으로 보이는가?
- PK와 FK가 시각적으로 구분되는가?
- FK 연결선이 실제로 참조하는 PK 필드에 정확히 도착하는가?
- 같은 관계를 여러 선으로 중복 표현하지 않았는가?
- 640px 너비에서도 핵심 필드와 라벨을 읽을 수 있는가?
- SVG title, desc와 aria-labelledby가 포함되었는가?
- 본문 그림 번호와 README의 번호가 일치하는가?
```

---

## 6. 현재 상태

```text
- Chapter 02 본문 사용 도식: 5종
- 현재 본문 미사용 도식: 3종
- ch02_04 외래키 관계 SVG와 Mermaid 원본 동기화 완료
- 본문 그림 번호 기준으로 README 갱신 완료
- 미사용 도식 파일은 삭제하지 않고 보존
```
