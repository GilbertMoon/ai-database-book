# Chapter 12 구성안

## 제목

조회 패턴으로 RDBMS와 NoSQL 선택하기

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 12는 NoSQL 제품을 나열하는 장이 아니라 데이터의 시스템 역할과 반복되는 조회·실패·복구 패턴을 기준으로 RDBMS, PostgreSQL JSONB와 NoSQL 유형 후보를 비교하는 장이다.

```text
시스템 역할
→ 원본·파생·캐시·이벤트·관계 인덱스
→ 핵심 읽기·쓰기 문장
→ 트랜잭션·일관성 범위
→ RDBMS·JSONB·NoSQL 후보
→ 중복·동기화 실패·복구
→ 작은 PoC
→ 후보·채택 상태 기록
```

## 핵심 질문

```text
최종 판단 기준이 되는 원본은 어디인가?
가장 중요한 읽기·쓰기 문장은 무엇인가?
한 키·문서·파티션 또는 여러 객체 중 어디까지 원자성이 필요한가?
오래된 읽기와 중복을 얼마나 허용할 수 있는가?
RDBMS와 JSONB로 먼저 해결할 수 있는가?
파생 저장소를 원본에서 다시 만들 수 있는가?
Seed 기준 상태와 실제 현재 상태를 구분했는가?
문서 스냅샷의 원본 식별자가 있는가?
후보 저장소와 최종 채택 상태를 구분했는가?
운영·보안·백업·복구 담당과 비용이 준비되어 있는가?
```

## 실습 구조

```text
nosql_lab.course_documents
nosql_lab.key_value_cache_examples
nosql_lab.storage_choice_cases
```

앞 장 스키마:

```text
course_project: 변경 금지
transaction_lab: 변경 금지
performance_lab: 변경 금지
security_lab: 변경 금지
```

## 기준 데이터

```text
course_project
- students 3
- instructors 2
- courses 3
- enrollments 5
- 상태: 신청 2 / 수강중 1 / 완료 1 / 취소 1
- recorded_amount: NUMERIC(12,0)
- 전체 기록 금액: 590000
- 활성 신청: 3 / 340000
- 취소 제외: 4 / 440000
- 1001 완료/100000, 1004 취소/150000, 1005 신청/120000

nosql_lab
- course_documents 3
- key_value_cache_examples 4
- storage_choice_cases 6
- Seed 기준 유효 3
- Seed 기준 만료 1
```

## 강의 문서 원본 매핑

```text
301 → COURSE-301 → 데이터베이스 입문
302 → COURSE-302 → 정규화 실습
303 → COURSE-303 → 파이썬 데이터 분석
```

물리적 FK 대신 최종 검증 SQL에서 원본 제목·난이도·강사 스냅샷을 대조한다.

## 혼합 문서 구조

일반 컬럼:

```text
source_course_id
course_code
title
level
document_version
created_at
updated_at
```

JSONB:

```text
tags
options
instructor_snapshot
```

`instructor_snapshot`은 표시용 파생 복사본이며 최종 원본은 `course_project.instructors`다.

## 핵심 개념

- NoSQL
- Key-Value
- Document
- Column-Family
- Graph
- Source of Truth
- Derived Cache
- Ephemeral State
- Flexible Metadata
- Event Log
- Relationship Index
- 조회 패턴
- 문서 경계
- 안정 컬럼·가변 JSONB
- 스냅샷과 원본
- partition key
- clustering key
- Cassandra 계열 용어 범위
- 트랜잭션·일관성
- 네트워크 분할
- 이중 쓰기
- 변경 이벤트·CDC
- 재시도·멱등성
- JSONB 연산자
- `jsonb_set`
- `document_version`
- 낙관적 잠금
- GIN·표현식 B-tree
- `jsonb_ops`·`jsonb_path_ops`
- Seed 기준 TTL·현재 TTL
- 후보 저장소·결정 상태
- PoC
- 운영·복구 비용
- AI 추천 검토

## 본문 구성

1. NoSQL의 의미와 오해
2. RDBMS와 NoSQL 역할 분리
3. 시스템 역할
4. NoSQL 네 유형
5. Key-Value와 Seed·현재 TTL
6. Document와 문서 경계
7. 안정 컬럼·JSONB·강사 스냅샷
8. Column-Family와 조회 패턴
9. Graph와 관계 탐색
10. 트랜잭션·일관성 범위
11. 여러 저장소 동기화
12. PostgreSQL JSONB 실습 구조
13. JSONB 연산자·검증 책임
14. document_version 낙관적 잠금
15. GIN·표현식 인덱스 후보
16. 후보 저장소·결정 상태
17. 작은 PoC
18. AI 추천 검토
19. 실행 안전성과 최종 검증
20. 자주 하는 실수
21. 스스로 확인하기
22. 권장 해설
23. 핵심 정리
24. 다음 장 연결

## 코드 파일

```text
code/chapter12/
├── 01_nosql_lab_schema.sql
├── 02_nosql_lab_seed.sql
├── 03_document_jsonb_queries.sql
├── 04_key_value_cache_queries.sql
├── 05_storage_choice_review.sql
├── 06_jsonb_index_candidates.sql
├── 07_nosql_lab_validation.sql
├── reset_nosql_lab.sql
├── nosql_jsonb_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_nosql_lab_schema.sql` | DB·Chapter 07 상태 검사 후 원자적 구조 생성 |
| `02_nosql_lab_seed.sql` | 원본 연계 문서·재현 TTL·선택 사례 입력과 자동 판정 |
| `03_document_jsonb_queries.sql` | JSONB 조회·원본 대조·낙관적 잠금·ROLLBACK |
| `04_key_value_cache_queries.sql` | Seed 기준과 현재 기준 TTL·미스·무만료 키 |
| `05_storage_choice_review.sql` | 원본·동기화·복구·PoC·결정 상태 검토 |
| `06_jsonb_index_candidates.sql` | 인덱스 미존재 검사·GIN·표현식 인덱스 정의 확인 |
| `07_nosql_lab_validation.sql` | 원본 매핑·JSON·TTL·결정·인덱스 전체 자동 판정 |
| `reset_nosql_lab.sql` | DB 보호 구문 안에서 nosql_lab만 초기화 |
| `nosql_jsonb_practice.sql` | 읽기 전용 호환 진입점 |

## 저장소 선택 기록

```text
system_role
primary_query
candidate_storage
source_of_truth
consistency_requirement
synchronization_strategy
recovery_strategy
poc_success_criteria
decision_status
reason
```

결정 상태:

```text
candidate
poc_planned
hold
adopted
rejected
```

## JSONB 검증 책임

| 규칙 | DB | 애플리케이션·검증 |
| --- | --- | --- |
| metadata 객체 | CHECK | 재확인 |
| course_code·title·level | 컬럼·CHECK | 보조 |
| tags 배열 | 선택 | 주 검증 |
| options 객체·boolean | 선택 | 주 검증 |
| instructor_snapshot 원본 대조 | 미적용 | 주 검증 |
| document_version 충돌 | 조건부 UPDATE | 재시도 |
| 문서 마이그레이션 | 제한적 | 주 책임 |

## 캐시 기준

```text
Seed 기준
→ expired_at IS NULL OR expired_at > created_at
→ 4/3/1 고정

현재 기준
→ expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP
→ 실행 시각에 따라 변화
```

## 인덱스 후보

```text
metadata @> ...
→ 기본 jsonb_ops GIN

metadata #>> '{options,online}' = 'true'
→ 표현식 B-tree
```

`CREATE INDEX IF NOT EXISTS`는 정의 동일성을 보장하지 않으므로 사용하지 않는다. 작은 표본의 Seq Scan은 오류로 판단하지 않는다.

## 안전성 원칙

- 기존 스키마를 삭제·변경하지 않는다.
- 생성·Seed·초기화 파일은 현재 DB와 기준 상태를 실제 검사한다.
- 스키마·테이블과 샘플 데이터는 각각 하나의 트랜잭션으로 처리한다.
- 모든 객체에 `nosql_lab`을 명시한다.
- 기준 문서 수정은 버전 조건과 ROLLBACK을 사용한다.
- 원본 식별자와 스냅샷 의미를 기록한다.
- 현재 TTL 결과를 고정 정답으로 사용하지 않는다.
- JSONB를 전용 Document DB와 동일하게 설명하지 않는다.
- Key-Value 시뮬레이션을 실제 분산 제품으로 과장하지 않는다.
- 제품별 트랜잭션·일관성·키 구조를 추측하지 않는다.
- 후보와 채택 상태를 구분한다.

## AI 활용 원칙

- 현재 원본 테이블을 정확히 제공한다.
- 별도 결제·환불 원장이 없음을 명시한다.
- 시스템 역할과 대표 읽기·쓰기 문장을 제공한다.
- RDBMS·JSONB로 충분한지 먼저 비교한다.
- 이중 쓰기·재시도·멱등성·재구축을 요구한다.
- PoC에 실패·복구·보안·비용을 포함한다.
- 후보와 결정 상태를 별도로 기록한다.

## 다음 장 연결

Chapter 13에서는 ChatGPT와 Codex를 사용해 요구사항·DDL·SQL·검증 결과를 체계적으로 리뷰한다.
