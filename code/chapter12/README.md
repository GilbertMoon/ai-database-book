# Chapter 12 SQL 실습

## NoSQL 이해와 선택 기준

이 폴더는 Chapter 12의 PostgreSQL 실습 파일을 관리합니다.

별도 NoSQL 서버를 설치하지 않습니다. 이 장에서는 PostgreSQL의 `JSONB`를 사용해 문서형 데이터 개념을 맛보고, 일반 테이블로 Key-Value 캐시 개념을 단순 시뮬레이션합니다.

## 파일

| 파일 | 설명 |
|---|---|
| `nosql_jsonb_practice.sql` | `course_documents`, `key_value_cache_examples`, `storage_choice_cases`를 생성하고 JSONB 조회와 저장 방식 선택 기준을 확인합니다. |

## 실행 전 확인

- PostgreSQL 접속이 가능한지 확인합니다.
- Chapter 12는 MongoDB, Redis, Cassandra, Neo4j 같은 별도 NoSQL 서버를 설치하지 않습니다.
- PostgreSQL JSONB는 실제 Document DB 자체가 아닙니다.
- `key_value_cache_examples`는 실제 Key-Value DB의 메모리 저장, 분산, 자동 TTL 삭제, 복제, 성능 특성을 구현하지 않습니다.
- `expired_at`은 만료 기준 시각을 저장할 뿐이며 행을 자동 삭제하지 않습니다.

## 실행 방법

```bash
psql -U postgres -d ai_database_book -f code/chapter12/nosql_jsonb_practice.sql
```

## 실행 흐름

1. 현재 접속 데이터베이스 확인
2. 기존 실습 테이블 삭제
3. `course_documents` 생성 및 3행 입력
4. JSONB 연산자 `->`, `->>`, `?`, `@>` 조회
5. `course_code` 기준 JSONB 수정
6. JSONB GIN 인덱스와 표현식 인덱스 생성
7. `key_value_cache_examples` 생성 및 4행 입력
8. 유효 캐시 3건, 만료 캐시 1건 확인
9. `storage_choice_cases` 생성 및 5행 입력
10. 최종 행 수 3 / 4 / 5 확인

## 기대 결과

JSONB 기본 조회 결과는 다음 형태입니다.

| course_code | title | level | online |
|---|---|---|---|
| DB-101 | 데이터베이스 입문 | basic | true |
| AI-201 | AI 데이터 분석 | intermediate | true |
| GRAPH-301 | 그래프 데이터 이해 | advanced | false |

최종 행 수는 다음과 같아야 합니다.

| table_name | expected_count |
|---|---:|
| course_documents | 3 |
| key_value_cache_examples | 4 |
| storage_choice_cases | 5 |

## 인덱스 해석 주의

- `idx_course_documents_metadata_gin`은 JSONB 전체 문서 포함 검색에 사용할 수 있는 GIN 인덱스입니다.
- `idx_course_documents_level_text`는 `metadata ->> 'level'` 조건을 자주 사용할 때 고려하는 표현식 인덱스입니다.
- 표본 데이터가 작으면 인덱스를 만들어도 `EXPLAIN`에서 `Seq Scan`이 나올 수 있습니다. 이것은 오류가 아닙니다.
