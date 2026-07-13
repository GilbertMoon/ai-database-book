# Chapter 12 실습 코드

## 조회 패턴으로 RDBMS와 NoSQL 선택하기

이 폴더는 기존 프로젝트를 변경하지 않고 `nosql_lab`에서 PostgreSQL JSONB, Key-Value 캐시 개념과 저장 방식 선택 기준을 검증하는 파일을 관리합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: 변경하지 않음
nosql_lab: Chapter 12 실습 대상
```

별도 NoSQL 서버를 설치하지 않습니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_nosql_lab_schema.sql` | 전용 스키마와 문서·캐시·선택 사례 테이블 생성 |
| `02_nosql_lab_seed.sql` | JSONB 문서 3건, 캐시 4건, 선택 사례 6건 입력 |
| `03_document_jsonb_queries.sql` | JSONB 연산자·구조 검증·ROLLBACK 수정·인덱스 후보 |
| `04_key_value_cache_queries.sql` | 유효·만료 캐시와 캐시 미스 시뮬레이션 |
| `05_storage_choice_review.sql` | 원본·조회·일관성·동기화 전략 검토 |
| `reset_nosql_lab.sql` | nosql_lab만 초기화 |
| `nosql_jsonb_practice.sql` | 기존 링크 호환용 안내·상태 확인 |

---

## 실행 순서

```text
01_nosql_lab_schema.sql
→ 02_nosql_lab_seed.sql
→ 03_document_jsonb_queries.sql
→ 04_key_value_cache_queries.sql
→ 05_storage_choice_review.sql
```

처음부터 다시 실행할 때만 `reset_nosql_lab.sql`을 사용합니다.

---

## 기준 데이터

| 테이블 | 기대 행 수 |
| --- | ---: |
| `nosql_lab.course_documents` | 3 |
| `nosql_lab.key_value_cache_examples` | 4 |
| `nosql_lab.storage_choice_cases` | 6 |

캐시 기준:

```text
전체 4
유효 3
만료 1
```

---

## JSONB 기본 결과

| course_code | title | level | online |
| --- | --- | --- | --- |
| DB-101 | 데이터베이스 입문 | basic | true |
| AI-201 | AI 데이터 분석 | intermediate | true |
| GRAPH-301 | 그래프 데이터 이해 | advanced | false |

`course_code`, `title`, 문서 버전과 시각은 일반 컬럼으로 두고, 가변적인 태그·옵션·강사 부가 정보는 `metadata JSONB`에 둡니다.

---

## JSONB 연산자와 인덱스 후보

```text
->   JSONB 값
->>  text 값
?    최상위 키 존재
@>   JSONB 포함 조건
```

후보 인덱스:

```text
idx_nosql_course_documents_metadata_gin
idx_nosql_course_documents_level
```

표본이 3행뿐이므로 인덱스가 있어도 `Seq Scan`이 나올 수 있습니다.

---

## Key-Value 시뮬레이션 한계

`key_value_cache_examples`는 다음 기능을 구현하지 않습니다.

```text
메모리 저장
자동 TTL 삭제
eviction
복제
샤딩
고성능 네트워크 조회
실제 장애 동작
```

`expired_at`은 만료 기준 시각일 뿐 자동 삭제 기능이 아닙니다.

---

## 저장 방식 선택 기준

각 사례에는 다음 근거를 함께 저장합니다.

```text
system_role
primary_query
candidate_storage
source_of_truth
consistency_requirement
synchronization_strategy
reason
```

후보 유형:

```text
RDBMS
Key-Value DB
PostgreSQL JSONB 또는 Document DB
Column-Family DB
Graph DB
```

후보는 정답이 아니라 PoC와 운영 검토가 필요한 초안입니다.

---

## 안전 원칙

```text
- 생성 파일에서 자동 DROP을 실행하지 않습니다.
- 모든 객체에 nosql_lab 스키마를 명시합니다.
- 기준 문서 수정은 트랜잭션 후 ROLLBACK합니다.
- JSONB를 전용 Document DB와 동일하게 설명하지 않습니다.
- 캐시 테이블을 실제 Key-Value DB로 과장하지 않습니다.
- 제품별 트랜잭션·일관성·확장성을 추측하지 않습니다.
- 새 저장소 도입 시 동기화·재시도·멱등성·복구를 검토합니다.
```
