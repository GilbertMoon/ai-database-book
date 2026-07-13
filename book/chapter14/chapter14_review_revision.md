# Chapter 14 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter14/chapter14.md
book/chapter14/chapter14_activity.md
book/chapter14/chapter14_outline.md
code/chapter14/01_rag_lab_schema.sql
code/chapter14/02_rag_lab_seed.sql
code/chapter14/03_manual_vector_search.sql
code/chapter14/04_retrieval_evaluation.sql
code/chapter14/05_rag_answer_reviews.sql
code/chapter14/06_rag_lifecycle_checks.sql
code/chapter14/07_pgvector_optional.sql
code/chapter14/RAG_EVALUATION_REPORT_TEMPLATE.md
code/chapter14/RAG_REVIEW_PROMPTS.md
code/chapter14/reset_rag_lab.sql
code/chapter14/vector_rag_practice.sql
code/chapter14/README.md
images/chapter14/README.md
notes/chapter14_review_checklist.md
README.md
```

## 목적

Chapter 14를 `public` 테이블을 자동 삭제하는 단일 Top-k 실습에서 **권한·최신성 필터, 사람이 검토한 정답 집합, 검색 지표, 답변 근거·인용·보류와 문서 수명주기를 검증하는 RAG 평가 장**으로 재구성한다.

```text
원문·권한·버전
→ 청크·임베딩
→ 검색 전 필터
→ 정확 검색 기준
→ relevance judgments
→ Precision·Recall·MRR
→ 답변 근거·인용·보류
→ 수명주기·회귀 평가
```

---

## 1. 제목 변경

```text
기존: Vector DB와 RAG 기초
변경: 벡터 검색과 RAG로 근거 있는 답변 만들기
```

---

## 2. 실습 스키마 격리

기존:

```text
public.simple_document_chunks
public.rag_search_logs
public.rag_answer_reviews
자동 DROP 후 재생성
```

변경:

```text
rag_lab.document_sources
rag_lab.document_chunks
rag_lab.query_cases
rag_lab.relevance_judgments
rag_lab.retrieval_runs
rag_lab.answer_reviews
```

앞 장 스키마는 변경하지 않는다.

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
public
```

---

## 3. SQL 구조 변경

### 기존

```text
vector_rag_practice.sql
- pgvector 선택 구간과 수동 벡터 실습 혼합
- 기본 스키마 테이블 자동 DROP
- Top-k와 답변 사례 중심
```

### 변경

```text
01_rag_lab_schema.sql
- 원문·청크·질문·정답·검색·답변 평가 테이블

02_rag_lab_seed.sql
- 문서 7·청크 9·질문 4·정답 6

03_manual_vector_search.sql
- active·access_scope·모델·차원 필터 후 L2 Top-k

04_retrieval_evaluation.sql
- Precision@k·Recall@k·RR·MRR·보류 평가

05_rag_answer_reviews.sql
- 근거·인용·권한·최신성·Unsupported claim·보류

06_rag_lifecycle_checks.sql
- 비활성 문서·임베딩 호환·재임베딩 대상

07_pgvector_optional.sql
- 확장 확인과 선택적 vector(3) 비교

reset_rag_lab.sql
- rag_lab만 초기화

vector_rag_practice.sql
- 생성 전에도 안전한 호환 진입점
```

---

## 4. 기준 데이터

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

질문:

```text
201 환불 가능 기간: public Top-3
202 프로젝트 제출 자료: internal Top-2
203 JOIN 의미: public Top-1
204 배송 정책: public, 근거 없음·보류
```

---

## 5. 검색 방해 사례 추가

```text
108 관리자 환불 예외
- 환불 질문과 가깝지만 restricted

109 과거 환불 정책
- 환불 질문과 가깝지만 inactive
```

거리 정렬 전에 권한·활성 상태 필터를 적용해 검색 로그에서 두 청크가 0건인지 검증한다.

---

## 6. 검색 평가 강화

기존 Top-k 순위 확인에 다음을 추가했다.

```text
relevance_judgments
Precision@k
Recall@k
Reciprocal Rank
MRR
정답 누락 조회
정답 없는 질문의 threshold·보류 평가
권한·최신성 위반 검색 0건
```

기준 데이터에서는 201~203의 Precision·Recall·RR이 1.0이고 MRR 1.0을 기대한다. 204는 관련 정답이 없으므로 숫자를 강제하지 않고 threshold 통과 0건과 올바른 보류를 평가한다.

---

## 7. 답변 평가 강화

```text
grounded_refund_answer
- 최신 public 문서와 인용 통과

unsupported_30_day_claim
- 검색은 적절하지만 최신 근거에 없는 주장

restricted_document_used
- 내용 근거는 있으나 접근 권한 실패

correct_no_evidence_abstention
- 배송 근거가 없어 올바르게 보류
```

검색 적합성, 권한, 최신성, 답변 근거성, 인용, Unsupported claim과 보류를 각각 분리한다.

---

## 8. 수명주기·신뢰 경계 강화

추가 내용:

```text
원문·source_version·content_hash 추적
청킹 전략·임베딩 모델·차원 추적
원문 변경 후 재청킹·재임베딩
비활성 문서 검색 제외
모델 v2 전환 시 활성 청크 8건 재임베딩
검색 문서 내 악성 지시를 시스템 명령과 분리
답변 생성과 도구·데이터 변경 권한 분리
변경 전후 회귀 평가
```

---

## 9. pgvector 처리

```text
- CREATE EXTENSION 자동 실행 제거
- vector 사용 가능 여부와 타입만 읽기 전용 확인
- vector(3) 테이블·L2·cosine 예시는 선택 주석
- HNSW·IVFFlat 인덱스는 생성하지 않고 선택 예시만 제공
- 작은 9건 데이터에서 근사 인덱스 불필요 명시
- 정확 검색 기준과 recall 비교 후 적용하도록 보정
```

pgvector 공식 문서의 `<->` L2, `<=>` cosine distance, 기본 exact search와 HNSW·IVFFlat approximate index 설명을 재확인했다.

---

## 10. 평가 산출물 추가

### `RAG_EVALUATION_REPORT_TEMPLATE.md`

```text
원문·청크·벡터 추적
권한·최신성 필터
Precision·Recall·MRR
답변 근거·인용·보류
검색 문서 신뢰 경계
수명주기·재임베딩
정확·근사 검색 비교
승인·조건부 승인·보류·거절
```

### `RAG_REVIEW_PROMPTS.md`

```text
RAG 전체 설계
청킹 전략
검색 품질 평가
답변 근거·인용
검색 문서 내 악성 지시
문서·모델 회귀
pgvector 인덱스
```

---

## 11. 도식 처리

기존 Mermaid·SVG 8종은 검색 방식, 임베딩, 거리·Top-k, 청킹, RAG 파이프라인, pgvector, 답변 근거와 저장소 역할이라는 새 본문 흐름과 호환되어 유지한다.

이미지 문서에는 새 제목, 검색 전 필터, 검색·답변 평가 분리와 `rag_lab` 기준을 반영한다.

---

## 12. 남은 확인 항목

```text
- 실제 PostgreSQL에서 01→06 실행
- retrieval_runs 9와 108·109 검색 0 확인
- Precision·Recall·RR·MRR 기대값 확인
- 배송 질문 threshold 0·보류 true 확인
- 답변 검토 4사례 확인
- lifecycle 8 active·1 inactive·v2 대상 8 확인
- pgvector 환경에서 07 선택 실행
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 13. 최종 상태

```text
Chapter 14 본문, 워크북, 구성안, 단계별 SQL, RAG 평가 보고서와 검토 프롬프트를 2차 재구성했다.
벡터 검색 원리 소개에서 권한·최신성·검색 지표·답변 근거·보류·수명주기를 검증하는 흐름으로 강화했다.
원격 main에 모든 변경을 직접 반영했다.
```
