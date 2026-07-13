# Chapter 14 리뷰 반영 기록

## 대상

Chapter 14. Vector DB와 RAG 기초

## 반영 요약

이번 수정에서는 Chapter 14를 검색 방식 비교, 임베딩 조건, pgvector의 정확한 거리 연산자, RAG의 근거 검토 흐름 중심으로 재정리했습니다. Chapter 13과 Chapter 15 파일은 수정하지 않았습니다.

## 주요 변경 사항

| 영역 | 반영 내용 |
|---|---|
| 본문 순서 | 그림 14-1부터 14-8까지 본문 흐름에 맞게 재배치 |
| 검색 용어 | 구조화 조건 검색, 키워드 검색, 벡터 의미 검색, 혼합 검색으로 보정 |
| SQL 설명 | 벡터 검색도 PostgreSQL에서는 SQL로 실행할 수 있음을 명시 |
| 임베딩 | 같은 모델, 버전, 차원, 전처리, 거리 함수 조건 추가 |
| Vector DB | 임베딩 생성 주체가 아니라 벡터 저장과 검색 기능으로 설명 |
| 거리 함수 | `<->` L2 거리, `<=>` 코사인 거리, `1 - cosine distance` 설명 추가 |
| Top-k | 상대 순위와 관련성 판정을 분리 |
| 정확/근사 검색 | 기본 exact search와 HNSW/IVFFlat approximate index 구분 |
| SQL | Section A/B 데이터셋을 같은 7개 문서로 통일 |
| 수동 벡터 | `manual-demo-3d`가 실제 임베딩 결과가 아님을 명시 |
| RAG | 모델 재학습이 아니라 검색 문서를 컨텍스트로 제공하는 방식으로 설명 |
| 평가 | 검색 적합성과 답변 근거성, unsupported claim을 분리 |
| 문서 갱신 | 문서 변경, 삭제, 재임베딩, 접근 권한 필터 설명 추가 |
| 이미지 | SVG 8개를 800px 이하 단순 구조로 갱신 |
| 활동지 | 점수/배점보다 자기 점검과 결과 기록 중심으로 변경 |

## 공식 pgvector 확인 결과

pgvector 공식 README를 확인해 다음 개념을 본문과 README에 반영했습니다.

- `<->`: L2 또는 Euclidean distance
- `<=>`: cosine distance
- `1 - (embedding <=> query)`: cosine similarity 계산 방식
- 기본 검색: exact nearest neighbor search
- HNSW, IVFFlat: approximate nearest neighbor search index
- approximate index는 속도를 얻는 대신 일부 recall을 희생할 수 있음

## SQL 기대 결과

| 항목 | 기대 행 수 |
|---|---:|
| `simple_document_chunks` | 7 |
| `rag_search_logs` | 3 |
| `rag_answer_reviews` | 3 |

환불 질문 Top-3 예상 순위는 `구독 취소`, `환불 기준`, `이용권 변경`입니다.

## 미확인 항목

| 항목 | 상태 | 이유 |
|---|---|---|
| PostgreSQL Section B 실제 실행 | 미확인 | 현재 환경에서 `psql` 명령 사용 불가 |
| pgvector Section A 실제 실행 | 미확인 | 현재 환경에서 `psql` 및 pgvector 실행 불가 |
| GitHub/브라우저 렌더링 | 미확인 | 자동 렌더링 검증 도구 미사용 |
| Word/PDF/eBook 변환 | 미확인 | 변환 작업 미수행 |

## 추가 확인 권장

- PostgreSQL 환경에서 `code/chapter14/vector_rag_practice.sql` Section B를 실행한다.
- pgvector가 준비된 환경에서 Section A의 주석을 해제해 Top-3 순서를 비교한다.
- 브라우저 또는 GitHub 미리보기에서 SVG 텍스트 위치를 확인한다.
- Word/PDF/eBook 변환 후 SVG 축소 상태의 가독성을 확인한다.
