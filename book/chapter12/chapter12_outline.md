# Chapter 12 구성안

## 제목

조회 패턴으로 RDBMS와 NoSQL 선택하기

## 권장 분량

24~28페이지

## 이 장의 역할

Chapter 12는 NoSQL 제품을 나열하는 장이 아니라, 데이터의 시스템 역할과 반복되는 조회·실패 패턴을 기준으로 RDBMS, PostgreSQL JSONB와 NoSQL 유형 후보를 비교하는 장이다.

```text
시스템 역할
→ 원본·파생·캐시·이벤트·관계 인덱스
→ 주 읽기·쓰기 패턴
→ 트랜잭션·일관성 범위
→ 저장 모델 후보
→ 중복·동기화 실패
→ 작은 PoC
→ 운영·백업·복구 비용
```

## 핵심 질문

```text
최종 판단 기준이 되는 원본은 어디인가?
가장 중요한 읽기·쓰기 문장은 무엇인가?
한 키·문서·파티션 또는 여러 객체 중 어디까지 원자성이 필요한가?
오래된 읽기와 중복을 얼마나 허용할 수 있는가?
RDBMS와 JSONB로 먼저 해결할 수 있는가?
새 저장소와 원본 사이 불일치를 어떻게 탐지·복구할 것인가?
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

이 장은 별도 NoSQL 서버를 설치하지 않는다. PostgreSQL JSONB와 일반 테이블로 개념 일부와 선택 기준만 검증한다.

## 기준 데이터

```text
course_documents 3
key_value_cache_examples 4
storage_choice_cases 6

유효 캐시 3
만료 캐시 1
```

## 핵심 개념

- NoSQL
- Key-Value
- Document
- Column-Family
- Graph
- Source of Truth
- Derived Cache
- Ephemeral State
- Event Log
- Relationship Index
- 조회 패턴
- 문서 경계
- 파티션 키
- 정렬·클러스터링 키
- 비정규화
- 트랜잭션 범위
- 일관성 모델
- 네트워크 분할
- 이중 쓰기
- 변경 이벤트·CDC
- 재시도·멱등성
- PostgreSQL JSONB
- GIN·표현식 인덱스
- PoC
- 운영 복잡도
- AI 저장소 추천 검토

## 본문 구성

1. NoSQL의 의미와 오해
2. RDBMS와 NoSQL 역할 분리
3. 데이터의 시스템 역할
4. NoSQL 네 유형
5. Key-Value와 캐시
6. Document와 문서 경계
7. Column-Family와 조회 패턴
8. Graph와 관계 탐색
9. 트랜잭션·일관성 범위
10. 여러 저장소의 동기화
11. PostgreSQL JSONB 실습 구조
12. 핵심 컬럼과 가변 메타데이터
13. JSONB 조회·수정·검증
14. JSONB 인덱스 후보
15. Key-Value 시뮬레이션 한계
16. 저장 방식 선택표
17. 작은 PoC
18. AI 추천 검토
19. 자주 하는 실수
20. 스스로 확인하기
21. 핵심 정리
22. 다음 장 연결

## 코드 파일

```text
code/chapter12/
├── 01_nosql_lab_schema.sql
├── 02_nosql_lab_seed.sql
├── 03_document_jsonb_queries.sql
├── 04_key_value_cache_queries.sql
├── 05_storage_choice_review.sql
├── reset_nosql_lab.sql
├── nosql_jsonb_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_nosql_lab_schema.sql` | 전용 스키마와 세 테이블 생성 |
| `02_nosql_lab_seed.sql` | JSON 문서·캐시·선택 사례 입력 |
| `03_document_jsonb_queries.sql` | JSONB 연산자·검증·ROLLBACK 수정·인덱스 후보 |
| `04_key_value_cache_queries.sql` | 유효·만료·캐시 미스 시뮬레이션 |
| `05_storage_choice_review.sql` | 시스템 역할·조회·일관성·원본 선택 검토 |
| `reset_nosql_lab.sql` | nosql_lab만 초기화 |
| `nosql_jsonb_practice.sql` | 안전한 호환 진입점 |

## 안전성 원칙

- 기존 스키마를 삭제·변경하지 않는다.
- 생성 파일에서 자동 DROP을 실행하지 않는다.
- 모든 실습 객체에 `nosql_lab` 스키마를 명시한다.
- 기준 문서 수정은 트랜잭션 후 ROLLBACK한다.
- Key-Value 테이블을 실제 Redis 계열 기능으로 설명하지 않는다.
- JSONB를 전용 Document DB와 동일하게 설명하지 않는다.
- 작은 데이터의 Seq Scan을 오류로 단정하지 않는다.
- 제품별 트랜잭션·일관성을 추측하지 않는다.

## AI 활용 원칙

- 원본 위치와 시스템 역할을 먼저 제공한다.
- 대표 읽기·쓰기 문장을 구체적으로 제공한다.
- RDBMS·JSONB로 충분한지 비교하게 한다.
- 일관성·트랜잭션 범위를 제품·설정별로 검증하게 한다.
- 이중 쓰기·재시도·멱등성·재구축 방안을 요구한다.
- PoC에 실패·복구·운영·비용 기준을 포함한다.

## 다음 장 연결

Chapter 13에서는 ChatGPT와 Codex를 사용해 요구사항·DDL·SQL·검증 결과를 체계적으로 리뷰하는 방법을 다룬다.
