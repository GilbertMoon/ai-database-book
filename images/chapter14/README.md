# Chapter 14 이미지/도식 설계

## Chapter 14. Vector DB와 RAG 기초

이 문서는 Chapter 14 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 14는 임베딩, 벡터, 유사도 검색, 문서 청킹, Vector DB, RAG 답변 근거성 검토를 입문 독자에게 설명하는 장입니다. 따라서 도식은 **일반 검색과 의미 기반 검색 비교, 임베딩 변환, 벡터 거리와 Top-k 검색, 문서 청킹, RAG 전체 흐름, pgvector 실습 흐름, RAG 답변 근거성 검토, 기존 DB와 Vector DB 역할 분리**를 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- Vector DB를 기존 DB의 대체재가 아니라 의미 기반 검색을 위한 보완적 저장소로 표현한다.
- 임베딩은 텍스트 의미를 숫자 벡터로 바꾸는 과정으로 설명한다.
- 벡터 거리는 수학적으로 깊게 설명하기보다 가까울수록 의미가 비슷하다는 직관을 강조한다.
- RAG는 질문 → 검색 → 근거 문서 → 답변 생성 → 근거성 검토 흐름으로 표현한다.
- 답변 생성보다 검색 결과와 근거 검토가 중요하다는 점을 시각적으로 드러낸다.
- pgvector 실습은 실제 AI 서비스 전체 구현이 아니라 개념 확인용 실습임을 보여 준다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 14-1 | `ch14_01_sql_vs_semantic_search.svg` | 일반 SQL 검색과 의미 기반 검색 비교 | 2장 일반 검색과 의미 기반 검색 | 삽입 완료 |
| 그림 14-2 | `ch14_02_embedding_vector_conversion.svg` | 텍스트 임베딩 변환 흐름 | 3장 임베딩이란 무엇인가 | 삽입 완료 |
| 그림 14-3 | `ch14_03_vector_similarity_topk.svg` | 벡터 거리와 Top-k 유사도 검색 | 4장 벡터와 유사도 검색 | 삽입 완료 |
| 그림 14-4 | `ch14_04_document_chunking.svg` | 문서 청킹 구조 | 7장 문서 청킹이란 무엇인가 | 삽입 완료 |
| 그림 14-5 | `ch14_05_rag_pipeline.svg` | RAG 기본 파이프라인 | 8장 RAG란 무엇인가 | 삽입 완료 |
| 그림 14-6 | `ch14_06_pgvector_practice_flow.svg` | pgvector 실습 흐름 | 6장 PostgreSQL과 pgvector | 삽입 완료 |
| 그림 14-7 | `ch14_07_rag_answer_grounding_review.svg` | RAG 답변 근거성 검토 | 11장 RAG 답변 검토 기준 | 삽입 완료 |
| 그림 14-8 | `ch14_08_db_role_separation.svg` | Vector DB와 기존 DB 역할 분리 | 12장 Vector DB와 기존 DB의 관계 | 삽입 완료 |

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch14_01_sql_vs_semantic_search.mmd` | `ch14_01_sql_vs_semantic_search.svg` |
| `ch14_02_embedding_vector_conversion.mmd` | `ch14_02_embedding_vector_conversion.svg` |
| `ch14_03_vector_similarity_topk.mmd` | `ch14_03_vector_similarity_topk.svg` |
| `ch14_04_document_chunking.mmd` | `ch14_04_document_chunking.svg` |
| `ch14_05_rag_pipeline.mmd` | `ch14_05_rag_pipeline.svg` |
| `ch14_06_pgvector_practice_flow.mmd` | `ch14_06_pgvector_practice_flow.svg` |
| `ch14_07_rag_answer_grounding_review.mmd` | `ch14_07_rag_answer_grounding_review.svg` |
| `ch14_08_db_role_separation.mmd` | `ch14_08_db_role_separation.svg` |

---

## 4. 도식 제작 후 점검 항목

```text
- 일반 검색과 의미 기반 검색의 차이가 명확한가?
- 임베딩이 텍스트를 숫자 벡터로 변환하는 과정으로 표현되는가?
- Top-k 검색에서 distance가 작을수록 관련 문서일 가능성이 높다는 점이 드러나는가?
- 문서 청킹이 검색 품질에 영향을 준다는 메시지가 포함되는가?
- RAG 흐름에 문서 수집, 청킹, 임베딩, 저장, 검색, 답변 생성, 검토가 포함되는가?
- pgvector 실습 흐름이 PostgreSQL 테이블과 벡터 거리 검색으로 단순하게 표현되는가?
- RAG 답변 검토에서 검색 문서에 없는 내용을 추가하는 위험이 드러나는가?
- Vector DB와 관계형 DB의 역할 차이가 명확한가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 14 도식 후보 8종 정리 완료
- Chapter 14 Mermaid 원본 8종 작성 완료
- Chapter 14 SVG 도식 8종 생성 완료
- Chapter 14 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 14 리뷰 체크리스트 작성
```
