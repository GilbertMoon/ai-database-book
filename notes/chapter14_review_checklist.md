# Chapter 14 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 14. 벡터 검색과 RAG로 근거 있는 답변 만들기
```

## 리뷰 목적

Chapter 14가 벡터 검색 원리뿐 아니라 권한·최신성 필터, 정답 집합, 검색 지표, 답변 근거·인용·보류와 문서 수명주기를 검증하도록 구성되었는지 점검합니다. 실제 실행하지 않은 항목은 통과로 표시하지 않습니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| course_project 보호 | 통과 | Chapter 14에서 변경 없음 |
| transaction_lab 보호 | 통과 | Chapter 14에서 변경 없음 |
| performance_lab 보호 | 통과 | Chapter 14에서 변경 없음 |
| security_lab 보호 | 통과 | Chapter 14에서 변경 없음 |
| nosql_lab 보호 | 통과 | Chapter 14에서 변경 없음 |
| ai_review_lab 보호 | 통과 | Chapter 14에서 변경 없음 |
| rag_lab 전용 | 통과 | 여섯 평가 테이블 격리 |
| 자동 DROP 제거 | 통과 | 생성 파일에서 삭제 없음 |
| 초기화 분리 | 통과 | reset_rag_lab.sql만 사용 |

---

## 2. 검색 개념 정확성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 구조화·키워드·벡터·혼합 검색 | 통과 | 상호 보완 관계로 설명 |
| SQL과 벡터 검색 대립 방지 | 통과 | PostgreSQL SQL 실행 명시 |
| 임베딩 생성 주체 | 통과 | 모델과 저장소 역할 분리 |
| 모델·버전·차원·전처리 | 통과 | 호환 조건 반영 |
| 수동 3D 벡터 | 통과 | 실제 모델 출력 아님 명시 |
| L2·cosine distance | 통과 | 점수 방향 구분 |
| Top-k·threshold | 통과 | 상대 순위와 충분한 관련성 구분 |

---

## 3. 정확·근사 검색

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 기본 exact search | 통과 | pgvector 공식 개념과 일치 |
| HNSW | 통과 | 속도·recall·메모리·구축 비용 설명 |
| IVFFlat | 통과 | lists·probes·학습 데이터 개념 설명 |
| 작은 데이터 ANN 제외 | 통과 | 9개 청크에서 인덱스 미생성 |
| 정확 검색 기준 | 통과 | ANN 전 Top-k·평가 결과 확보 |
| CREATE EXTENSION 자동 실행 금지 | 통과 | 선택 파일에서 주석 상태 |

---

## 4. 원문·청크·벡터 추적

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| document_sources | 7 | 코드 반영 |
| document_chunks | 9 | 코드 반영 |
| active chunks | 8 | 코드 반영 |
| inactive chunks | 1 | 코드 반영 |
| document_key·source_version | 필수 | 통과 |
| content_hash | 필수 | 통과 |
| chunk_strategy_version | 필수 | 통과 |
| embedding_source·dimension | 필수 | 통과 |
| embedded_at | 필수 | 통과 |

---

## 5. 권한·최신성 필터

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 필터 후 거리 계산 | 통과 | active·scope·모델·차원 우선 |
| restricted 방해 청크 | 통과 | 108 검색 로그 0 기대 |
| inactive 과거 정책 | 통과 | 109 검색 로그 0 기대 |
| public·internal·restricted 순서 | 통과 | 명시적 CASE 비교 |
| 필터 위반 조회 | 통과 | 기대 0행 |
| 근사 검색 필터 주의 | 통과 | 실제 반환 수·recall 검증 요구 |

---

## 6. 질문·정답·검색 로그

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| query_cases | 4 | 코드 반영 |
| relevance_judgments | 6 | 코드 반영 |
| retrieval_runs | 9 | 코드 반영 |
| 환불 Top-3 | 103·102·101 | 코드 반영 |
| 프로젝트 Top-2 | 105·104 | 코드 반영 |
| JOIN Top-1 | 107 | 코드 반영 |
| 배송 threshold 통과 | 0 | 코드 반영 |

---

## 7. 검색 품질 평가

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 201 Precision@3 | 1.0 | 코드 반영 |
| 201 Recall@3 | 1.0 | 코드 반영 |
| 202 Precision@2 | 1.0 | 코드 반영 |
| 202 Recall@2 | 1.0 | 코드 반영 |
| 203 Precision@1 | 1.0 | 코드 반영 |
| 203 Recall@1 | 1.0 | 코드 반영 |
| MRR | 1.0 | 코드 반영 |
| 정답 누락 | 0행 | 코드 반영 |
| 배송 보류 조건 | true | 코드 반영 |
| 평가 데이터 독립성 설명 | 통과 | 검색 결과를 정답으로 사용하지 않음 |

---

## 8. 답변 근거·인용·보류

| 사례 | 기대 | 상태 |
| --- | --- | --- |
| grounded_refund_answer | 전체 통과 | 코드 반영 |
| unsupported_30_day_claim | unsupported 1 | 코드 반영 |
| restricted_document_used | access violation 1 | 코드 반영 |
| correct_no_evidence_abstention | correct abstention 1 | 코드 반영 |
| answer_reviews | 4 | 코드 반영 |
| 잘못된 인용 ID | 0행 | 코드 반영 |
| 논리 불일치 | 0행 | 코드 반영 |

---

## 9. 검색 문서 신뢰 경계

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 검색 문서를 데이터로 취급 | 통과 | 시스템 지시와 분리 |
| 악성 명령형 문장 | 통과 | 실행하지 않도록 설명 |
| 출처 허용 목록 | 통과 | 신뢰 경계 검토 포함 |
| HTML·스크립트 정제 | 통과 | 숨김 지시 검토 포함 |
| 도구 호출 권한 | 통과 | 검색 권한과 실행 권한 분리 |
| 데이터 변경 승인 | 통과 | 별도 승인 필요 |

---

## 10. 수명주기·회귀

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| source·chunk 활성 불일치 | 0행 | 코드 반영 |
| 원문보다 오래된 embedding | 0행 | 코드 반영 |
| 모델·차원 불일치 | 0행 | 코드 반영 |
| v2 재임베딩 대상 | 8 | 코드 반영 |
| 비활성 문서 검색 | 0행 | 코드 반영 |
| 권한 초과 검색 | 0행 | 코드 반영 |
| document_key 활성 버전 중복 | 0행 | 코드 반영 |
| 추적 메타데이터 누락 | 0행 | 코드 반영 |
| 변경 전후 회귀 기준 | 통과 | 검색·답변·성능 지표 포함 |

---

## 11. 단계별 파일

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_rag_lab_schema.sql` | 전용 평가 스키마 | 통과 |
| `02_rag_lab_seed.sql` | 원문·청크·질문·정답 | 통과 |
| `03_manual_vector_search.sql` | 필터 후 L2 Top-k | 통과 |
| `04_retrieval_evaluation.sql` | 검색 지표·보류 | 통과 |
| `05_rag_answer_reviews.sql` | 근거·인용·권한·보류 | 통과 |
| `06_rag_lifecycle_checks.sql` | 수명주기·재임베딩 | 통과 |
| `07_pgvector_optional.sql` | 선택적 pgvector 비교 | 통과 |
| `RAG_EVALUATION_REPORT_TEMPLATE.md` | 평가·승인 기록 | 통과 |
| `RAG_REVIEW_PROMPTS.md` | 설계·품질·보안 프롬프트 | 통과 |
| `reset_rag_lab.sql` | 전용 스키마 초기화 | 통과 |
| `vector_rag_practice.sql` | 안전한 호환 진입점 | 통과 |
| `README.md` | 실행 순서·기대값·원칙 | 통과 |

---

## 12. 워크북

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 보호 범위 | 통과 | 일곱 스키마 구분 |
| 임베딩 호환 조건 | 통과 | 모델·버전·차원·전처리 |
| 검색 방해 사례 | 통과 | 108·109 |
| 정답 집합 | 통과 | 관련성 등급 기록 |
| 검색 지표 | 통과 | Precision·Recall·RR·MRR |
| 정답 없는 질문 | 통과 | 보류 평가 |
| 답변·인용 검토 | 통과 | 네 사례 |
| 악성 문서 지시 | 통과 | 신뢰 경계 활동 |
| 수명주기 | 통과 | 재임베딩·회귀 계획 |
| 최종 승인 상태 | 통과 | 네 상태와 미실행 기록 |

---

## 13. 도식

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 기존 SVG 8종 | 통과 | 새 검색·평가 흐름과 호환 |
| 새 제목·rag_lab 기준 | 통과 | 이미지 README 갱신 |
| 필터·보류·근거 표현 | 기존 확인 필요 | 실제 렌더링 수동 검수 |
| 접근성·XML | 기존 검증 유지 | 출판 변환 확인 필요 |

---

## 14. 남은 확인

```text
- 실제 PostgreSQL에서 01→06 실행
- retrieval 9·108/109 검색 0 확인
- Precision·Recall·MRR 실제 결과 확인
- 답변 검토 4사례 실제 결과 확인
- lifecycle 8/1/8 확인
- pgvector 환경에서 07 선택 실행
- 정확 검색과 선택 경로 Top-3 비교
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 15. 최종 판정

```text
Chapter 14는 벡터 검색 원리와 RAG 개념을 넘어 권한·최신성·검색 지표·답변 근거·보류·문서 수명주기를 검증하는 장으로 2차 재구성했다.
실제 PostgreSQL·pgvector 실행과 출판 렌더링은 수동 확인이 필요하다.
```
