# Chapter 05 이미지/도식 설계

## Chapter 05. 요구사항에서 데이터 모델과 ERD 만들기

이 문서는 Chapter 05 본문에 사용하는 Mermaid 원본과 SVG 결과물의 역할과 공통 기준을 정리합니다.

각 SVG는 상세 표나 전체 SQL을 반복하지 않고, 요구사항을 구조로 바꾸는 과정에서 하나의 핵심 질문에 답하도록 구성합니다.

---

## 1. 도식 목록

| 번호 | 파일 | 제목 | 현재 역할 |
| --- | --- | --- | --- |
| 그림 5-1 | `ch05_01_modeling_process.svg` | 요구사항에서 데이터베이스 구조까지의 모델링 흐름 | 요구사항에서 ERD·SQL·검증까지의 전체 흐름 |
| 그림 5-2 | `ch05_02_entity_attribute_classification.svg` | 엔터티와 속성 구분하기 | 일반 엔터티·사건 엔터티·속성 구분 |
| 그림 5-3 | `ch05_04_one_to_many_relationship.svg` | 1:N 관계와 외래키 위치 | N쪽 `loans`에 FK가 위치하는 이유 |
| 그림 5-4 | `ch05_05_many_to_many_bridge_table.svg` | N:M 관계를 연결 테이블로 풀기 | N:M을 사건 테이블을 통한 두 개의 1:N으로 구현 |
| 그림 5-5 | `ch05_03_primary_foreign_key_relationship.svg` | 기본키와 외래키로 테이블 연결하기 | PK와 FK의 역할 및 참조 방향 |
| 그림 5-6 | `ch05_06_library_erd_overview.svg` | 도서 대여 시스템 핵심 ERD | `members`, `loans`, `books` 관계와 핵심 열 |
| 그림 5-7 | `ch05_07_erd_to_sql_flow.svg` | ERD를 PostgreSQL 테이블로 변환하기 | ERD 요소의 DDL 변환과 부모→자식 생성 순서 |
| 그림 5-8 | `ch05_08_ai_erd_review_flow.svg` | AI 생성 ERD 검토 흐름 | AI 초안, 사람 검토, 구현과 재검증의 반복 |

기존 SVG 파일명은 유지하고 본문 등장 순서에 맞춰 그림 번호와 캡션을 사용합니다.

---

## 2. Mermaid 원본과 SVG 결과물

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

Mermaid는 의미적·구조적 원본이며 SVG는 출판과 GitHub 표시를 위한 보정 결과물입니다. 두 파일의 핵심 노드와 관계 의미를 동일하게 유지합니다.

---

## 3. 공통 SVG 기준

```text
- 표준 SVG만 사용하고 외부 CSS, JavaScript, 웹폰트와 raster 이미지를 사용하지 않는다.
- role="img", aria-labelledby, title, desc를 포함한다.
- width="100%"와 내용에 맞는 viewBox를 사용한다.
- 일반 한글은 안전한 시스템 폰트 스택을 사용한다.
- 테이블명과 열 이름은 코드용 폰트 스택을 사용한다.
- PK와 FK는 색상뿐 아니라 텍스트로도 구분한다.
- 관계 표기는 한 그림 안에서 일관되게 사용한다.
- 전체 CREATE TABLE SQL, 대형 표와 전체 샘플 데이터를 SVG에 넣지 않는다.
- foreignObject를 사용하지 않는다.
```

---

## 4. 2차 재구성 정합성 기준

- 실행 기준 파일은 `library_schema.sql`, `library_seed.sql`, `library_validation.sql`로 분리한다.
- 테이블은 `members`, `books`, `loans`를 사용한다.
- 기본키는 `IDENTITY` 방식으로 구현한다.
- 외래키는 `loans.member_id → members.id`, `loans.book_id → books.id`이다.
- 관계는 `members 1 : 0..N loans`, `books 1 : 0..N loans`이다.
- `loans`는 날짜와 상태를 가진 사건·업무 테이블이다.
- `returned_at`은 선택 속성으로 NULL을 허용한다.
- 샘플 데이터는 회원 3명, 도서 3건, 대여 4건이다.
- 복본, 동시 대여 방지, 삭제 정책, 정규화 상세와 JOIN 상세는 핵심 도식에 추가하지 않는다.
- 요구사항 추적표, 확정·미확정 규칙과 선택성 설명은 본문 표와 문장으로 보완한다.

---

## 5. 현재 상태

```text
- 기존 Mermaid 원본 8종과 SVG 8종 유지
- 새 본문 제목과 그림 등장 순서 반영
- 사건 테이블, 관계와 ERD 중심 역할 유지
- 요구사항 추적과 미확정 규칙은 본문에서 보완
- XML·접근성 구조의 기존 검증 결과 유지
- GitHub 화면, Word, PDF, eBook 실제 렌더링은 수동 확인 필요
```
