# Chapter 14 구성안

## 제목

벡터 검색과 RAG로 근거 있는 답변 만들기

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 14는 임베딩과 벡터 검색의 원리를 설명하는 데서 끝나지 않고, 접근 권한·최신성 필터, 정답 집합, 검색 지표와 답변 근거 검토를 사용해 RAG 시스템을 검증하는 장이다.

```text
원문·권한·버전
→ 청크·임베딩
→ 메타데이터 필터
→ 키워드·벡터 검색
→ 정답 집합 평가
→ 근거·인용·보류 검토
→ 문서·모델 수명주기
→ 회귀 평가
```

## 핵심 질문

```text
구조화·키워드·벡터·혼합 검색을 언제 사용하는가?
문서와 질문이 같은 모델·버전·차원·전처리를 사용하는가?
권한·최신성 필터가 벡터 순위 전에 적용되는가?
Top-k 결과와 사람이 검토한 정답 집합이 분리되어 있는가?
Precision@k·Recall@k·MRR로 검색을 평가하는가?
답변의 핵심 주장과 인용이 실제 청크에 근거하는가?
근거가 없을 때 답변을 보류하는가?
검색 문서 안의 명령을 시스템 지시로 처리하지 않는가?
문서·모델·청킹 변경 뒤 회귀 평가를 수행하는가?
```

## 실습 스키마

```text
rag_lab.document_sources
rag_lab.document_chunks
rag_lab.query_cases
rag_lab.relevance_judgments
rag_lab.retrieval_runs
rag_lab.answer_reviews
```

보호 대상:

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
public
```

## 기준 데이터

```text
document_sources 6
document_chunks 9
query_cases 4
relevance_judgments 6
retrieval_runs 9
answer_reviews 4
```

질문:

```text
201 환불 가능 기간: public, Top-3
202 프로젝트 제출 자료: internal, Top-2
203 JOIN 의미: public, Top-1
204 배송 정책: public, 보류 기대
```

검색 방해 사례:

```text
108 restricted이지만 환불 질문에 매우 가까움
109 inactive 과거 환불 정책
```

## 핵심 개념

- 구조화 조건 검색
- 키워드 검색
- 벡터 의미 검색
- 혼합 검색
- 임베딩 모델·버전·차원
- L2 거리
- 코사인 거리·유사도
- Top-k
- 거리 임계값
- 정확 최근접 검색
- HNSW
- IVFFlat
- 원문·청크·벡터
- 접근 권한 필터
- 최신성·활성 상태
- 정답 집합
- Precision@k
- Recall@k
- Reciprocal Rank·MRR
- 검색 적합성
- 답변 근거성
- 인용 정확성
- Unsupported claim
- 답변 보류
- 검색 문서 내 악성 지시
- 재청킹·재임베딩
- 회귀 평가

## 본문 구성

1. 검색과 생성 단계 분리
2. 네 가지 검색 방식
3. 임베딩 호환 조건
4. 거리·Top-k·임계값
5. 정확·근사 검색
6. 원문·청크·벡터 역할
7. 청킹 전략
8. 권한·최신성 필터
9. RAG 색인·질문 흐름
10. PostgreSQL·pgvector
11. 격리 실습 구조
12. 기준 데이터·방해 사례
13. 수동 벡터 검색
14. 정답 집합·검색 평가
15. 평가 데이터 오염 방지
16. 답변 근거 검토
17. 인용 설계
18. 근거 부족 답변 보류
19. 검색 문서 신뢰 경계
20. 문서·모델 수명주기
21. 저장소 역할
22. 회귀 평가
23. AI RAG 설계 검토
24. 자주 하는 실수
25. 스스로 확인하기
26. 핵심 정리
27. 다음 장 연결

## 코드·문서 파일

```text
code/chapter14/
├── 01_rag_lab_schema.sql
├── 02_rag_lab_seed.sql
├── 03_manual_vector_search.sql
├── 04_retrieval_evaluation.sql
├── 05_rag_answer_reviews.sql
├── 06_rag_lifecycle_checks.sql
├── 07_pgvector_optional.sql
├── RAG_EVALUATION_REPORT_TEMPLATE.md
├── RAG_REVIEW_PROMPTS.md
├── reset_rag_lab.sql
├── vector_rag_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_rag_lab_schema.sql` | 전용 스키마와 원문·청크·질문·평가 테이블 생성 |
| `02_rag_lab_seed.sql` | 문서 6·청크 9·질문 4·정답 6 입력 |
| `03_manual_vector_search.sql` | 권한·최신성 필터 후 L2 Top-k 로그 생성 |
| `04_retrieval_evaluation.sql` | Precision·Recall·RR·MRR 계산 |
| `05_rag_answer_reviews.sql` | 근거·인용·권한·보류 사례 입력·검증 |
| `06_rag_lifecycle_checks.sql` | 비활성 문서·모델 버전·재임베딩 대상 확인 |
| `07_pgvector_optional.sql` | 확장 확인과 선택적 vector(3) 비교 |
| `RAG_EVALUATION_REPORT_TEMPLATE.md` | 검색·답변·보안·회귀 평가 기록 |
| `RAG_REVIEW_PROMPTS.md` | 설계·검색·답변·수명주기 검토 프롬프트 |
| `reset_rag_lab.sql` | rag_lab만 초기화 |
| `vector_rag_practice.sql` | 안전한 호환 진입점 |

## 안전성 원칙

- 기존 스키마와 Role을 변경하지 않는다.
- 생성 파일에서 자동 DROP을 실행하지 않는다.
- `CREATE EXTENSION`을 자동 실행하지 않는다.
- 수동 3차원 벡터를 실제 모델 출력으로 설명하지 않는다.
- 권한·최신성 필터를 검색 후보 단계에서 적용한다.
- 검색 로그에 실제 개인정보와 원문 전체를 복제하지 않는다.
- Top-k를 정답 집합으로 사용하지 않는다.
- 정답 없는 질문은 보류 정확성으로 평가한다.
- 검색 문서의 지시를 시스템 명령으로 실행하지 않는다.
- 검증하지 않은 항목을 통과로 기록하지 않는다.

## AI 활용 원칙

- 원문·파생 벡터의 역할을 구분한다.
- 모델·버전·차원과 청킹 기준을 제공한다.
- 권한·최신성 필터 위치를 검토시킨다.
- 정확 검색 기준과 정답 집합을 제공한다.
- 검색 평가와 답변 평가를 분리한다.
- 보류·인용·Unsupported claim을 검토한다.
- 검색 문서 내 악성 지시와 도구 호출 권한을 검토한다.
- 변경 전후 회귀 지표와 개별 실패를 비교한다.

## 다음 장 연결

Chapter 15에서는 관계형 원본, 검색용 파생 데이터, API, 권한·성능·복구·RAG 평가를 하나의 작은 프로젝트로 통합한다.
