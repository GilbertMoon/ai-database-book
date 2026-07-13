# Chapter 14 이미지 자료

## Chapter 14. Vector DB와 RAG 기초

Chapter 14의 도식은 `images/SVG_STYLE_GUIDE.md`를 따르며, 구조화 조건 검색, 키워드 검색, 벡터 의미 검색, 문서 청킹, RAG, pgvector 실습, 저장소 역할 분리를 입문 독자가 빠르게 구분하도록 구성합니다.

## 공통 원칙

- SQL 언어와 벡터 검색을 대립시키지 않는다.
- 벡터 검색도 PostgreSQL에서는 SQL로 실행될 수 있음을 드러낸다.
- Vector DB와 임베딩 모델의 역할을 구분한다.
- Top-k와 관련성 판정을 구분한다.
- 검색 적합성과 답변 근거성을 분리한다.
- 접근 권한과 최신성 필터는 검색 전에 적용되어야 함을 표현한다.
- 모든 SVG는 `title`, `desc`, `role`, `aria-labelledby`, `width="100%"`, `viewBox`를 포함한다.
- SVG 높이는 800px 이하로 단순화한다.

## 그림 목록

| 번호 | 파일 | 표시 제목 | 본문 위치 |
|---|---|---|---|
| 그림 14-1 | `ch14_01_sql_vs_semantic_search.svg` | 구조화·키워드 검색과 벡터 의미 검색 | 2장 검색 방식 비교 |
| 그림 14-2 | `ch14_02_embedding_vector_conversion.svg` | 텍스트를 같은 벡터 공간으로 변환하기 | 3장 임베딩 |
| 그림 14-3 | `ch14_03_vector_similarity_topk.svg` | L2 거리·Top-k·임계값으로 근거 후보 선택 | 4장 벡터 거리와 Top-k |
| 그림 14-4 | `ch14_04_document_chunking.svg` | 원문을 의미 단위 청크로 나누기 | 6장 문서 청킹 |
| 그림 14-5 | `ch14_05_rag_pipeline.svg` | RAG의 색인·검색·답변·검토 흐름 | 7장 RAG 기본 흐름 |
| 그림 14-6 | `ch14_06_pgvector_practice_flow.svg` | pgvector와 수동 3차원 벡터 실습 비교 | 8장 PostgreSQL과 pgvector |
| 그림 14-7 | `ch14_07_rag_answer_grounding_review.svg` | 검색 적합성과 답변 근거성 분리 검토 | 12장 평가 |
| 그림 14-8 | `ch14_08_db_role_separation.svg` | RAG 저장소 역할 분리 | 14장 저장소 역할 |

## Mermaid와 SVG

| Mermaid | SVG |
|---|---|
| `ch14_01_sql_vs_semantic_search.mmd` | `ch14_01_sql_vs_semantic_search.svg` |
| `ch14_02_embedding_vector_conversion.mmd` | `ch14_02_embedding_vector_conversion.svg` |
| `ch14_03_vector_similarity_topk.mmd` | `ch14_03_vector_similarity_topk.svg` |
| `ch14_04_document_chunking.mmd` | `ch14_04_document_chunking.svg` |
| `ch14_05_rag_pipeline.mmd` | `ch14_05_rag_pipeline.svg` |
| `ch14_06_pgvector_practice_flow.mmd` | `ch14_06_pgvector_practice_flow.svg` |
| `ch14_07_rag_answer_grounding_review.mmd` | `ch14_07_rag_answer_grounding_review.svg` |
| `ch14_08_db_role_separation.mmd` | `ch14_08_db_role_separation.svg` |

## 검수 기준

- 그림 14-6이 그림 14-4, 14-5 이후에 등장하는가?
- 각 그림이 본문에서 담당하는 역할과 중복되지 않는가?
- `<->`가 L2 거리로 설명되는가?
- 근거 충분/부족, 검색 적합/부적합 분기가 명확한가?
- 원본 데이터와 파생 데이터의 역할이 구분되는가?
- GitHub 미리보기와 브라우저에서 한글이 정상 표시되는가?
