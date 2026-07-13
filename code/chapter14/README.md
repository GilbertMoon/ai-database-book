# Chapter 14 SQL 실습

## Vector DB와 RAG 기초

이 폴더는 Chapter 14의 벡터 검색과 RAG 실습 파일을 관리합니다.

`vector_rag_practice.sql`은 두 경로를 제공합니다.

- Section A: pgvector가 준비된 경우 선택적으로 실행하는 `vector(3)` 실습
- Section B: pgvector 없이 실행 가능한 3차원 수동 벡터 실습

두 경로는 같은 7개 문서 청크와 같은 질문 벡터를 사용합니다. 수동 3차원 벡터는 실제 임베딩 모델 결과가 아니라 거리 계산 원리를 설명하기 위한 `manual-demo-3d` 예시입니다.

## 실행 순서

1. 현재 DB와 사용자를 확인합니다.
2. pgvector 사용 가능 여부를 확인합니다.
3. 기본적으로 Section B를 실행합니다.
4. 문서 청크 7건을 확인합니다.
5. 환불 질문 Top-3, 업데이트 질문 Top-2, JOIN 질문 Top-1을 확인합니다.
6. 검색 로그 3건을 확인합니다.
7. 답변 검토 3건을 비교합니다.
8. 최종 요약 7 / 3 / 3을 확인합니다.
9. pgvector 사용 가능 환경에서는 Section A를 별도로 실행해 Section B와 Top-3 순서를 비교합니다.

## pgvector 확인

```sql
SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE name = 'vector';

SELECT to_regtype('vector') AS vector_type_in_current_database;
```

`CREATE EXTENSION`은 운영체제에 pgvector를 설치하는 명령이 아닙니다. 서버에 확장 파일이 준비되어 있고 현재 DB에서 확장 생성 권한이 있을 때만 실행됩니다. 운영 DB에서는 임의로 실행하지 않습니다.

## pgvector 공식 개념 요약

- `<->`는 L2 거리입니다.
- `<=>`는 코사인 거리입니다.
- `1 - cosine distance`로 코사인 유사도를 계산할 수 있습니다.
- 기본 검색은 정확 최근접 검색입니다.
- HNSW와 IVFFlat은 근사 최근접 검색 인덱스입니다.
- 근사 검색은 속도를 얻는 대신 일부 결과 재현율을 희생할 수 있습니다.

## 기대 결과

| 항목 | 기대 행 수 |
|---|---:|
| `simple_document_chunks` | 7 |
| `rag_search_logs` | 3 |
| `rag_answer_reviews` | 3 |

환불 질문 Top-3 예상 순위:

| 순위 | title |
|---:|---|
| 1 | 구독 취소 |
| 2 | 환불 기준 |
| 3 | 이용권 변경 |

## 해석 주의

- 벡터 검색도 PostgreSQL에서는 SQL로 실행할 수 있습니다.
- 비교 대상은 SQL이라는 언어와 벡터 검색의 대립이 아니라, 정확한 조건/키워드 검색과 임베딩 거리 기반 의미 검색의 차이입니다.
- Top-k에 포함되었다고 모두 충분히 관련 있는 것은 아닙니다.
- 검색 적합성과 답변 근거성은 별도로 평가해야 합니다.
- 근거가 부족하면 답변을 보류하거나 검색 조건, 청킹, Top-k, 임계값을 조정해야 합니다.
- 문서가 변경되면 벡터 인덱스와 검색 로그도 함께 관리해야 합니다.
