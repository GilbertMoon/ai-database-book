# Chapter 05 이미지/도식 설계

## Chapter 05. 데이터 모델링과 ERD

이 문서는 Chapter 05 본문에 사용하는 Mermaid 원본과 SVG 결과물의 역할과 공통 기준을 정리합니다.

각 SVG는 상세 표나 전체 SQL을 반복하지 않고, 하나의 핵심 질문에 답하도록 구성합니다.

---

## 1. 도식 목록

| 번호 | 파일 | 제목 | 최종 역할 |
| --- | --- | --- | --- |
| 그림 5-1 | `ch05_01_modeling_process.svg` | 요구사항에서 데이터베이스 구조까지의 모델링 흐름 | 요구사항에서 ERD·SQL·검증까지의 전체 흐름 |
| 그림 5-2 | `ch05_02_entity_attribute_classification.svg` | 엔터티와 속성 구분하기 | 일반 엔터티·사건 엔터티·속성 구분 |
| 그림 5-3 | `ch05_03_primary_foreign_key_relationship.svg` | 기본키와 외래키로 테이블 연결하기 | PK와 FK의 역할 및 참조 방향 |
| 그림 5-4 | `ch05_04_one_to_many_relationship.svg` | 1:N 관계와 외래키 위치 | N쪽 `loans`에 FK가 위치하는 이유 |
| 그림 5-5 | `ch05_05_many_to_many_bridge_table.svg` | N:M 관계를 연결 테이블로 풀기 | 개념상 N:M을 두 개의 1:N으로 구현 |
| 그림 5-6 | `ch05_06_library_erd_overview.svg` | 도서 대여 시스템 핵심 ERD | `members`, `loans`, `books` 최종 관계 |
| 그림 5-7 | `ch05_07_erd_to_sql_flow.svg` | ERD를 PostgreSQL 테이블로 변환하기 | ERD 요소의 DDL 변환과 생성 순서 |
| 그림 5-8 | `ch05_08_ai_erd_review_flow.svg` | AI 생성 ERD 검토 흐름 | AI 초안의 사람 검토와 반복 검증 |

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

Mermaid는 의미적·구조적 원본이며 SVG는 출판과 GitHub 표시를 위한 보정 결과물입니다. 두 파일의 핵심 노드, 관계, 분기 의미는 동일하게 유지합니다.

---

## 3. 공통 SVG 생성 기준

```text
- 표준 SVG만 사용하고 외부 CSS, JavaScript, 웹폰트, raster 이미지를 사용하지 않는다.
- role="img", aria-labelledby, title, desc를 포함한다.
- width="100%"와 내용에 맞는 viewBox를 사용한다.
- 일반 한글은 Malgun Gothic 중심의 안전한 폰트 스택을 사용한다.
- 테이블명과 컬럼명은 Consolas, D2Coding, Courier New 계열을 사용한다.
- 핵심 글자는 12px 이상으로 유지한다.
- PK와 FK는 색상뿐 아니라 PK, FK 텍스트로도 구분한다.
- 관계 표기는 한 그림 안에서 일관되게 사용한다.
- 전체 CREATE TABLE SQL과 대형 비교표는 SVG에 넣지 않는다.
- foreignObject를 사용하지 않는다.
```

---

## 4. 정합성 기준

- 실행 기준 파일: `code/chapter05/library_schema.sql`
- 테이블: `members`, `books`, `loans`
- 외래키: `loans.member_id → members.id`, `loans.book_id → books.id`
- 관계: `members 1 : 0..N loans`, `books 1 : 0..N loans`
- `returned_at`: NULL 허용
- 샘플 데이터: 회원 3명, 도서 3건, 대여 4건
- Chapter 05 핵심 도식에는 복본 테이블, 삭제 정책, 동시성 제어 등 후속 범위의 내용을 추가하지 않음

---

## 5. 현재 상태

```text
- Chapter 05 Mermaid 원본 8종 단순화 완료
- Chapter 05 SVG 8종 단순화 및 접근성 구조 반영 완료
- 본문 alt text와 캡션을 실제 도식 제목에 맞게 갱신 완료
- Mermaid와 SVG 의미 정합성 검토 완료
- XML 파싱 검증 완료
- 리뷰 체크리스트 존재 및 갱신 완료
- GitHub 화면, Word, PDF, eBook 실제 렌더링은 수동 확인 필요
```
