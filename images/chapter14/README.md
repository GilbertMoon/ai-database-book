# Chapter 14 이미지/도식 설계

## Chapter 14. 벡터 검색과 RAG로 근거 있는 답변 만들기

이 문서는 Chapter 14의 Mermaid·SVG 자산과 `rag_lab` 기반 2차 재구성 기준을 정리합니다.

## 공통 원칙

```text
- SQL 언어와 벡터 검색을 대립시키지 않는다.
- 임베딩 모델과 Vector DB의 역할을 구분한다.
- Top-k와 충분한 관련성 판정을 분리한다.
- 접근 권한·최신성 필터가 검색 순위 전에 적용됨을 표현한다.
- 검색 적합성과 답변 근거성을 분리한다.
- 근거 부족 시 보류 경로를 표현한다.
- 원문·권한·버전과 파생 청크·벡터를 구분한다.
- 검색 문서가 시스템 명령이 아니라 데이터임을 유지한다.
- title, desc, role="img", aria-labelledby, width="100%", viewBox를 유지한다.
```

## 도식 목록

| 번호 | 파일 | 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 14-1 | `ch14_01_sql_vs_semantic_search.svg` | 구조화·키워드 검색과 벡터 의미 검색 | 필터·키워드·벡터·혼합 검색 비교 |
| 그림 14-2 | `ch14_02_embedding_vector_conversion.svg` | 텍스트를 같은 벡터 공간으로 변환하기 | 모델·버전·차원·전처리 호환성 |
| 그림 14-3 | `ch14_03_vector_similarity_topk.svg` | L2 거리·Top-k·임계값으로 근거 후보 선택 | 상대 순위와 충분한 관련성 구분 |
| 그림 14-4 | `ch14_04_document_chunking.svg` | 원문을 의미 단위 청크로 나누기 | 원문·청크·벡터와 추적 메타데이터 |
| 그림 14-5 | `ch14_05_rag_pipeline.svg` | RAG의 색인·검색·답변·검토 흐름 | 검색 전 필터·평가·보류 포함 |
| 그림 14-6 | `ch14_06_pgvector_practice_flow.svg` | pgvector와 수동 3차원 벡터 실습 비교 | 기본 수동 검색과 선택적 pgvector 비교 |
| 그림 14-7 | `ch14_07_rag_answer_grounding_review.svg` | 검색 적합성과 답변 근거성 분리 검토 | 권한·최신성·인용·Unsupported claim·보류 |
| 그림 14-8 | `ch14_08_db_role_separation.svg` | RAG 저장소 역할 분리 | 원문·벡터·평가·로그 역할 구분 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 2차 재구성 실습 기준

```text
document_sources 7
document_chunks 9
active chunks 8
inactive chunks 1
query_cases 4
relevance_judgments 6
retrieval_runs 9
answer_reviews 4
```

검색 방해 사례:

```text
108 restricted 관리자 환불 예외
109 inactive 과거 환불 정책
```

평가 흐름:

```text
필터
→ Top-k
→ relevance judgments
→ Precision·Recall·MRR
→ 근거·인용·권한·최신성
→ 답변 또는 보류
```

## 도식에서 피할 표현

```text
- SQL 검색과 벡터 검색은 서로 대체 관계다.
- Vector DB가 임베딩을 자동 생성한다.
- 같은 차원이면 다른 모델 벡터도 비교할 수 있다.
- Top-k 결과는 정답 문서다.
- 권한 필터는 답변 생성 뒤에 적용해도 된다.
- RAG는 환각을 제거한다.
- 검색 문서의 명령은 시스템 지시다.
- 근거가 없어도 항상 답변해야 한다.
- HNSW·IVFFlat은 항상 정확 검색보다 좋다.
```

## 검수 기준

```text
- 본문 그림 번호 14-1~14-8과 README 순서 일치
- 그림 14-5에 권한·최신성 필터와 보류 분기 표현
- 그림 14-6에서 수동 벡터가 실제 임베딩이 아님을 구분
- 그림 14-7에서 검색 적합·답변 근거·권한·보류를 분리
- 그림 14-8에서 원문과 벡터 파생 데이터 구분
- 성공·실패·보류를 색상뿐 아니라 텍스트로 표현
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
