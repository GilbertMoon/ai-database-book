# Chapter 05 이미지/도식 설계

## Chapter 05. 데이터 모델링과 ERD

이 문서는 Chapter 05 본문과 활동 자료에 삽입한 Mermaid 원본과 SVG 결과물을 정리합니다.

Chapter 05의 도식은 상세 표나 전체 SQL을 이미지로 반복하지 않고, 요구사항 분석 흐름, 엔터티와 속성 구분, PK/FK 연결, 1:N과 N:M 관계, 도서 대여 ERD, ERD와 PostgreSQL 변환, AI 생성 ERD 검토 흐름을 빠르게 이해하도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 상세 비교와 검토 기준은 본문 Markdown 표에서 설명한다.
- 실행 가능한 DDL, INSERT, JOIN은 본문 코드 블록과 SQL 파일에 둔다.
- SVG는 흐름, 관계, FK 위치처럼 한눈에 볼 구조만 표현한다.
- Mermaid는 SVG의 의미적·구조적 원본으로 관리한다.
- Chapter 05 범위를 벗어난 삭제 정책, 복본 관리, 동시성 제어는 도식에 넣지 않는다.
```

---

## 2. 도식 목록

| 번호 | 파일 | 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 5-1 | `ch05_01_modeling_process.svg` | 요구사항에서 데이터베이스 구조까지의 모델링 흐름 | 2장 데이터 모델링의 기본 흐름 | 삽입 완료 |
| 그림 5-2 | `ch05_02_entity_attribute_classification.svg` | 엔터티와 속성 구분하기 | 4장 엔터티와 속성 구분하기 | 삽입 완료 |
| 그림 5-3 | `ch05_03_primary_foreign_key_relationship.svg` | 기본키와 외래키로 테이블 연결하기 | 5장 기본키와 외래키 설계하기 | 삽입 완료 |
| 그림 5-4 | `ch05_04_one_to_many_relationship.svg` | 1:N 관계와 외래키 위치 | 6.1장 1:N 관계 | 삽입 완료 |
| 그림 5-5 | `ch05_05_many_to_many_bridge_table.svg` | N:M 관계를 연결 테이블로 풀기 | 6.2장 N:M 관계 | 삽입 완료 |
| 그림 5-6 | `ch05_06_library_erd_overview.svg` | 도서 대여 시스템 핵심 ERD | 9장 ERD 초안 작성하기 | 삽입 완료 |
| 그림 5-7 | `ch05_07_erd_to_sql_flow.svg` | ERD를 PostgreSQL 테이블로 변환하기 | 10장 ERD를 PostgreSQL 테이블로 바꾸기 | 삽입 완료 |
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

## 4. 공통 SVG 생성 기준

```text
- 표준 SVG만 사용하고 외부 CSS, JavaScript, 웹폰트, 외부 이미지는 사용하지 않는다.
- role="img", aria-labelledby, title, desc를 포함한다.
- width="100%"와 viewBox를 사용한다.
- 흰색 배경과 안전한 한글 폰트 스택을 사용한다.
- 핵심 글자는 12px 이상으로 유지한다.
- 박스당 1~2줄 중심으로 작성한다.
- PK, FK, 1, 0..N 같은 의미 표기를 텍스트로 함께 표시한다.
```

---

## 5. 현재 상태

```text
- Chapter 05 Mermaid 원본 8종 단순화 완료
- Chapter 05 SVG 도식 8종 직접 보정 완료
- 본문 그림 링크, alt text, 캡션 갱신 완료
- 데이터 모델링 단계별 산출물 표 추가 완료
- ERD와 PostgreSQL 구현 대응표 추가 완료
- 리뷰 체크리스트와 수정 기록 문서 갱신 완료
```
