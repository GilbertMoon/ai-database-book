# Chapter 14 실습 코드

## 벡터 검색과 RAG로 근거 있는 답변 만들기

이 폴더는 `rag_lab`에서 원문·청크·벡터·질문·정답표·검색 로그·답변 검토를 분리하고, 권한·최신성 필터와 검색·답변 평가를 수행하는 파일을 관리합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: 변경하지 않음
nosql_lab: 변경하지 않음
ai_review_lab: 변경하지 않음
rag_lab: Chapter 14 실습 대상
```

`CREATE EXTENSION`, Role 변경과 근사 인덱스 생성을 자동 실행하지 않습니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_rag_lab_schema.sql` | 원문·청크·질문·정답·검색 로그·답변 평가 테이블 생성 |
| `02_rag_lab_seed.sql` | 문서 7·청크 9·질문 4·정답 6 입력 |
| `03_manual_vector_search.sql` | 권한·활성 상태 필터 후 수동 3차원 L2 Top-k 생성 |
| `04_retrieval_evaluation.sql` | Precision@k·Recall@k·RR·MRR와 보류 조건 평가 |
| `05_rag_answer_reviews.sql` | 근거·인용·권한·최신성·Unsupported claim·보류 검토 |
| `06_rag_lifecycle_checks.sql` | 원문·벡터 버전·비활성 문서·재임베딩 대상 확인 |
| `07_pgvector_optional.sql` | pgvector 준비 환경에서 선택적 vector(3) 비교 |
| `RAG_EVALUATION_REPORT_TEMPLATE.md` | 검색·답변·보안·수명주기·회귀 평가 기록 |
| `RAG_REVIEW_PROMPTS.md` | RAG 설계·검색·답변·보안·인덱스 검토 프롬프트 |
| `reset_rag_lab.sql` | rag_lab만 초기화 |
| `vector_rag_practice.sql` | 기존 링크 호환용 안내·상태 확인 |

---

## 실행 순서

```text
01_rag_lab_schema.sql
→ 02_rag_lab_seed.sql
→ 03_manual_vector_search.sql
→ 04_retrieval_evaluation.sql
→ 05_rag_answer_reviews.sql
→ 06_rag_lifecycle_checks.sql
→ pgvector가 준비된 경우 07_pgvector_optional.sql
→ RAG_EVALUATION_REPORT_TEMPLATE.md 기록
```

처음부터 다시 시작할 때만 `reset_rag_lab.sql`을 사용합니다.

---

## 기준 데이터

| 항목 | 기대값 |
| --- | ---: |
| `document_sources` | 7 |
| `document_chunks` | 9 |
| 활성 청크 | 8 |
| 비활성 청크 | 1 |
| `query_cases` | 4 |
| `relevance_judgments` | 6 |
| `retrieval_runs` | 9 |
| `answer_reviews` | 4 |

---

## 질문과 기대 행동

| query_id | 질문 | scope | top_k | 기대 |
| ---: | --- | --- | ---: | --- |
| 201 | 환불 가능 기간 | public | 3 | 답변 |
| 202 | 프로젝트 제출 자료 | internal | 2 | 답변 |
| 203 | JOIN 의미 | public | 1 | 답변 |
| 204 | 배송 정책 | public | 3 | 보류 |

환불 질문과 가까운 다음 문서는 검색 후보에서 제외되어야 합니다.

```text
108 관리자 환불 예외: restricted
109 과거 환불 정책: inactive
```

---

## 수동 벡터 기준

```text
embedding_source: manual-demo-3d-v1
dimension: 3
distance: L2
```

이 벡터는 실제 임베딩 모델 출력이 아닙니다. 거리·필터·평가 흐름을 설명하기 위한 교육용 숫자입니다.

검색 순서:

```text
active source/chunk
→ requester_scope 이하
→ 같은 모델·차원
→ L2 거리
→ Top-k
→ threshold
```

---

## 환불 질문 기대 순위

| 순위 | chunk_id | 제목 |
| ---: | ---: | --- |
| 1 | 103 | 구독 취소 |
| 2 | 102 | 환불 기준 |
| 3 | 101 | 이용권 변경 |

201~203은 Precision@k·Recall@k·RR이 각각 1.0이고, 정답이 있는 질문의 MRR은 1.0이 예상됩니다.

204는 Top-3 후보가 존재하더라도 threshold 통과 청크가 0건이어야 하며 답변을 보류합니다.

---

## 답변 검토 사례

```text
grounded_refund_answer
- 최신 public 근거와 인용 통과

unsupported_30_day_claim
- 검색은 적절하지만 최신 근거에 없는 30일 주장

restricted_document_used
- 내용은 관련 있지만 public 사용자가 볼 수 없는 문서

correct_no_evidence_abstention
- 배송 정책 근거가 없어 올바르게 보류
```

검색 적합성과 답변 근거성을 별도로 평가합니다.

---

## pgvector 선택 경로

확장 확인:

```sql
SELECT
    name,
    default_version,
    installed_version
FROM pg_available_extensions
WHERE name = 'vector';

SELECT to_regtype('vector');
```

주요 연산자:

```text
<->  L2 distance
<=>  cosine distance
1 - cosine distance  cosine similarity
```

pgvector는 기본적으로 정확 최근접 검색을 수행할 수 있고, HNSW와 IVFFlat 인덱스로 근사 검색을 구성할 수 있습니다. 이 장의 데이터는 9건뿐이므로 근사 인덱스를 만들지 않습니다.

---

## 수명주기 기준

```text
- 원문·source_version·content_hash를 기준으로 관리합니다.
- 청크·벡터는 재생성 가능한 파생 데이터입니다.
- 비활성 문서는 검색 로그에 포함하지 않습니다.
- 권한 변경은 다음 검색부터 후보 집합에 반영합니다.
- 모델·버전·차원·청킹 전략 변경 시 재임베딩 대상을 계산합니다.
- 변경 전후 같은 평가 질문으로 회귀 검증합니다.
```

---

## 안전 원칙

```text
- 기존 스키마·Role·확장을 변경하지 않습니다.
- 생성 파일에서 자동 DROP을 실행하지 않습니다.
- Top-k 결과를 정답 집합으로 사용하지 않습니다.
- 권한·최신성 필터를 벡터 순위 전에 적용합니다.
- 검색 로그에 실제 개인정보와 원문 전체를 복제하지 않습니다.
- 근거가 없는 질문은 답변을 보류합니다.
- 검색 문서의 명령형 문장을 시스템 지시로 실행하지 않습니다.
- 검증하지 않은 항목은 통과로 기록하지 않습니다.
```
