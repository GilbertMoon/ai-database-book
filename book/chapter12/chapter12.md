# Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기

---

## 이 장에서 살펴볼 내용

Chapter 11에서는 최소 권한과 백업·복원 검증을 통해 데이터베이스를 안전하게 운영하는 방법을 살펴봤습니다. 이번 장에서는 데이터를 모두 같은 저장소에 넣는 대신, **데이터의 역할과 반복되는 조회·실패 패턴에 맞는 저장 모델을 선택하는 방법**을 다룹니다.

온라인 강의 서비스에는 성격이 다른 데이터가 함께 존재합니다.

```text
수강신청·신청 당시 금액
→ 관계·제약조건·트랜잭션이 중요한 원본 데이터

로그인 세션·인기 강의 캐시
→ 키로 빠르게 읽고 만료하거나 다시 만들 수 있는 상태·파생 데이터

강의 옵션·태그·표시용 강사 스냅샷
→ 문서마다 구조가 달라질 수 있는 부가 메타데이터

학습 행동 이벤트
→ 학생·날짜 범위에서 시간순으로 읽는 대량 이벤트

학생·강의·주제 추천 관계
→ 여러 단계 관계 탐색이 중요한 파생 인덱스
```

이번 장의 판단 흐름은 다음과 같습니다.

```text
데이터의 시스템 역할 확인
→ 원본·파생·캐시·이벤트·관계 인덱스 구분
→ 가장 중요한 읽기·쓰기 문장 정의
→ 트랜잭션·일관성 범위 결정
→ RDBMS·JSONB·NoSQL 후보 비교
→ 중복·동기화·장애 복구 검토
→ 작은 PoC
→ 운영·보안·백업 비용까지 포함해 결정
```

이 장에서는 다음 내용을 다룹니다.

- RDBMS와 NoSQL의 역할 차이
- Key-Value, Document, Column-Family, Graph 모델
- Source of Truth와 파생 저장소
- 조회 패턴에서 출발하는 데이터 모델링
- 트랜잭션·일관성 범위
- 비정규화와 동기화 실패
- PostgreSQL JSONB와 전용 Document DB의 차이
- 안정된 컬럼과 가변 메타데이터의 혼합 설계
- 문서 버전과 낙관적 잠금
- 캐시의 Seed 기준 상태와 실제 현재 상태
- JSONB GIN·표현식 인덱스 후보
- 후보 저장소와 최종 결정 상태
- AI 저장소 추천 검토

> **핵심 원칙**
>
> 저장소는 이름이나 유행으로 선택하지 않습니다. 반드시 보존해야 할 원본, 반복되는 조회 패턴, 허용 가능한 불일치와 복구 책임을 먼저 정의합니다.

---

## 1. NoSQL은 관계형 데이터베이스의 반대말이 아니다

NoSQL은 관계형 테이블 모델만으로 설명되지 않는 여러 저장 모델을 묶어 부르는 넓은 표현입니다. 흔히 “Not Only SQL”이라고 설명하지만, 하나의 공식 제품 유형처럼 외우기보다 다양한 비관계형 모델의 계열로 이해하는 편이 안전합니다.

```text
NoSQL은 SQL을 절대 사용하지 않는다.
→ 제품마다 질의 방식이 다르다.

NoSQL에는 스키마가 없다.
→ 저장 전·후 어디선가 구조 규칙이 필요하다.

NoSQL에는 트랜잭션이 없다.
→ 제품·설정·작업 범위에 따라 지원이 다르다.

NoSQL은 항상 RDBMS보다 빠르다.
→ 조회 패턴과 데이터 모델이 맞을 때 장점이 난다.

NoSQL은 자동으로 무한 확장된다.
→ 파티션 키, 핫스팟, 복제와 운영 설계가 필요하다.
```

기술 선택은 다음 질문에서 시작해야 합니다.

```text
어떤 데이터를 어떤 키·조건·정렬·관계 깊이로 얼마나 자주 읽고 쓰는가?
```

---

## 2. RDBMS와 NoSQL은 역할을 나눌 수 있다

![RDBMS와 NoSQL 역할 나누기](../../images/chapter12/ch12_01_rdbms_vs_nosql_overview.svg)

그림 12-1 RDBMS와 NoSQL 역할 나누기

| 판단 항목 | RDBMS가 유리한 경우 | NoSQL을 검토할 수 있는 경우 |
| --- | --- | --- |
| 구조 | 테이블·컬럼·관계가 명확 | 키·문서·파티션·그래프 중심 |
| 무결성 | PK·FK·UNIQUE·CHECK 중요 | 애플리케이션·모델 규칙 비중이 큼 |
| 트랜잭션 | 여러 테이블 변경 원자성 중요 | 한 키·문서·파티션 중심일 수 있음 |
| 조회 | JOIN·집계·다양한 조건 | 고정 키·문서·파티션·관계 탐색 |
| 변경 | 명시적 마이그레이션 선호 | 문서·속성 변화가 잦을 수 있음 |
| 운영 | 기존 SQL·권한·백업 체계 활용 | 별도 모니터링·백업·장애 대응 필요 |

온라인 강의 서비스의 수강신청과 신청 당시 금액 기록은 `course_project`의 RDBMS 원본에 두는 것이 자연스럽습니다. 인기 강의 목록은 원본에서 계산한 파생 데이터이므로 Key-Value 캐시 후보가 될 수 있습니다.

한 서비스에서 여러 저장소를 목적별로 사용하는 방식을 흔히 polyglot persistence라고 부릅니다. 저장소 수가 늘어날수록 동기화·보안·백업·장애 대응 범위도 늘어납니다.

---

## 3. 저장소보다 먼저 시스템 역할을 정한다

| 시스템 역할 | 설명 | 온라인 강의 예 |
| --- | --- | --- |
| Source of Truth | 최종 판단 기준이 되는 원본 | 수강신청·신청 당시 금액 |
| Derived Cache | 원본에서 계산·복사한 파생 데이터 | 인기 강의 TOP 3 |
| Ephemeral State | 만료되거나 다시 만들 수 있는 상태 | 로그인 세션 |
| Flexible Metadata | 항목별 구조가 달라질 수 있는 부가 정보 | 태그·옵션·표시용 스냅샷 |
| Event Log | 시간순으로 쌓이는 사실 기록 | 재생·정지·완료 이벤트 |
| Relationship Index | 관계 탐색을 빠르게 하는 파생 구조 | 추천 그래프 |

원본과 파생 데이터를 구분하지 않으면 장애 시 무엇을 신뢰하고 무엇을 재구축해야 하는지 판단하기 어렵습니다.

```text
캐시와 원본이 다르면 어느 쪽을 신뢰하는가?
추천 그래프를 잃으면 원본에서 다시 만들 수 있는가?
이벤트가 중복 수집되면 제거할 event_id가 있는가?
문서 메타데이터가 가격·신청 상태 같은 핵심 규칙을 대신해도 되는가?
```

---

## 4. NoSQL 유형 한눈에 보기

![NoSQL 유형 정리](../../images/chapter12/ch12_02_nosql_types_map.svg)

그림 12-2 NoSQL 유형 정리

| 유형 | 중심 모델 | 주된 접근 방식 | 온라인 강의 예 |
| --- | --- | --- | --- |
| Key-Value | 키 → 값 | 정확한 키 조회·만료 | 세션, 캐시, 기능 플래그 |
| Document | 독립 문서 | 문서 ID·필드 조건 | 강의 메타데이터·설정 문서 |
| Column-Family | 파티션·정렬 키 | 특정 파티션 범위 조회 | 학생별 날짜별 이벤트 |
| Graph | 노드·관계 | 다단계 관계 탐색 | 학생·강의·주제 추천 |

검색 엔진, 벡터 DB와 오브젝트 스토어도 데이터 시스템 구성 요소가 될 수 있지만 이 장에서는 제외합니다.

---

## 5. Key-Value DB: 정확한 키와 만료가 중심이다

![Key-Value 조회와 캐시 미스](../../images/chapter12/ch12_03_key_value_lookup.svg)

그림 12-3 Key-Value 조회와 캐시 미스

예시 키:

| 키 | 의미 | 원본 여부 |
| --- | --- | --- |
| `student:101:session` | 로그인 세션 상태 | 임시 상태 |
| `course:popular:v1:top3` | 인기 강의 ID 목록 | 파생 캐시 |
| `feature:recommendation:v1` | 기능 활성화 설정 | 운영 상태 |

좋은 키는 네임스페이스, 식별자, 버전과 목적이 드러납니다.

```text
좋은 방향: course:popular:v1:top3
주의 방향: top3
```

캐시 미스 흐름:

```text
1. 정확한 키로 캐시를 조회한다.
2. 값이 없거나 만료되면 원본 RDBMS를 조회한다.
3. 원본 결과로 캐시를 다시 만든다.
4. 사용자에게 결과를 반환한다.
```

추가 결정:

```text
TTL은 얼마인가?
TTL이 없는 키도 허용하는가?
원본 변경 시 삭제할 것인가, 갱신할 것인가?
동시 재생성 요청을 어떻게 줄이는가?
캐시 장애 시 원본 부하 급증을 막을 수 있는가?
오래된 값을 얼마 동안 허용하는가?
```

### 실습 모델의 범위

`nosql_lab.key_value_cache_examples`는 PostgreSQL 일반 테이블입니다.

```text
자동 TTL 삭제 없음
메모리 저장·eviction 없음
복제·샤딩 없음
실제 Key-Value 네트워크 성능 없음
```

`cache_value`는 편의를 위해 JSONB로 저장하지만 JSON 객체만 강제하지 않습니다. `expired_at IS NULL`은 만료 정책이 없는 키를 의미합니다.

### Seed 기준과 현재 기준을 구분한다

Seed 기준은 다음처럼 각 행의 생성 시각과 만료 시각을 비교합니다.

```sql
expired_at IS NULL OR expired_at > created_at
```

기대 결과:

```text
전체 4
Seed 시점 유효 3
Seed 시점 만료 1
```

실제 현재 상태는 다음 조건으로 확인합니다.

```sql
expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP
```

현재 유효 건수는 시간이 지나면 달라질 수 있으므로 고정 정답으로 사용하지 않습니다.

---

## 6. Document DB: 함께 읽고 쓰는 문서 경계를 정한다

![Document JSON 구조](../../images/chapter12/ch12_04_document_json_structure.svg)

그림 12-4 Document JSON 구조

문서에 포함할 데이터는 관련 있어 보이는 모든 것이 아니라 **함께 읽고 쓰는 경계**로 결정합니다.

문서 안에 포함할 수 있는 방향:

```text
상세 화면에서 항상 함께 읽는 태그·옵션
문서와 수명이 같고 독립적으로 공유되지 않는 값
문서 단위 원자적 갱신이 필요한 값
```

별도 원본·참조를 검토하는 방향:

```text
여러 문서가 공유하는 강사 원본
매우 자주 독립적으로 바뀌는 데이터
크기가 계속 증가하는 배열
강한 관계 무결성이 필요한 데이터
```

유연한 스키마는 규칙이 없다는 뜻이 아닙니다. 필드 이름, 타입, 필수 여부, 문서 버전과 마이그레이션 정책을 관리해야 합니다.

---

## 7. 안정된 컬럼과 가변 메타데이터를 분리한다

Chapter 12는 Chapter 07 원본과 맞춘 다음 문서를 사용합니다.

| source_course_id | course_code | title | level |
| ---: | --- | --- | --- |
| 301 | COURSE-301 | 데이터베이스 입문 | basic |
| 302 | COURSE-302 | 정규화 실습 | basic |
| 303 | COURSE-303 | 파이썬 데이터 분석 | basic |

```sql
CREATE TABLE nosql_lab.course_documents (
    id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_course_id INTEGER NOT NULL UNIQUE,
    course_code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    level TEXT NOT NULL,
    metadata JSONB NOT NULL,
    document_version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
```

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

`level`은 모든 문서에서 중요하고 자주 검증·검색하므로 일반 컬럼으로 둡니다. JSONB에 모든 것을 넣으면 타입·제약·통계·JOIN과 변경 관리가 어려워질 수 있습니다.

### 강사 스냅샷의 의미

```json
{
  "instructor_snapshot": {
    "source_instructor_id": 201,
    "name": "문길래",
    "specialty": "Database",
    "copied_at": "..."
  }
}
```

이 값은 상세 화면 표시를 위한 파생 복사본입니다. 최종 원본은 `course_project.instructors`입니다. 변경 이벤트가 누락되면 `source_instructor_id`로 대조하고 다시 만들어야 합니다.

외부 FK를 만들면 `nosql_lab` 단독 이동성이 낮아질 수 있으므로 물리적 FK 대신 최종 검증 SQL에서 원본과 대조합니다.

---

## 8. Column-Family DB: 조회 문장에서 역으로 설계한다

![Column-Family 조회 패턴](../../images/chapter12/ch12_05_column_family_log_flow.svg)

그림 12-5 Column-Family 조회 패턴

목표 조회:

```text
학생 101의 2026-07-13 학습 이벤트를 시간순으로 읽는다.
```

| 설계 요소 | 예시 |
| --- | --- |
| partition key | `(student_id, event_date)` |
| clustering key | `event_time` |
| row data | event_id, event_type, course_id, position_seconds |
| target query | 특정 학생·날짜의 시간 범위 조회 |

여기서 partition key와 clustering key는 Cassandra 계열을 중심으로 한 개념 예시입니다. 제품마다 키 구조, 정렬, 보조 인덱스와 트랜잭션 범위가 다릅니다.

확인 항목:

```text
파티션이 지나치게 커지지 않는가?
특정 학생·날짜에 쓰기가 집중되는가?
event_id로 중복을 제거할 수 있는가?
늦게 도착한 이벤트를 어떻게 처리하는가?
보존 기간과 분석 전달 경로는 무엇인가?
```

새로운 조회 패턴이 생기면 별도의 파생 테이블이나 파이프라인이 필요할 수 있습니다.

---

## 9. Graph DB: 관계의 존재보다 탐색 깊이가 중요하다

![Graph 관계 탐색](../../images/chapter12/ch12_06_graph_relationship_search.svg)

그림 12-6 Graph 관계 탐색

| 구성 요소 | 예 |
| --- | --- |
| 노드 | Student, Course, Topic |
| 관계 | ENROLLED, INTERESTED_IN, RELATED_TO |
| 속성 | 수강 시각, 관심도, 유사도 |
| 질문 | 주제 X와 연결된 학생에게 추천할 강의는 무엇인가? |

```text
강의별 수강 학생 목록
→ RDBMS FK와 JOIN으로 충분할 가능성이 큼

학생→주제→관련 강의→유사 학생→다른 강의
→ 다단계 관계 탐색이 반복되면 Graph DB 검토
```

추천 그래프가 원본인지 RDBMS·이벤트에서 만든 파생 관계 인덱스인지도 정해야 합니다. 파생 인덱스라면 재구축 방법과 허용 지연을 설계합니다.

---

## 10. 트랜잭션과 일관성은 제품·범위별로 확인한다

“NoSQL은 최종 일관성, RDBMS는 강한 일관성”처럼 단순하게 구분하면 안 됩니다.

```text
한 키·문서·파티션 변경은 원자적인가?
여러 문서·파티션 트랜잭션이 필요한가?
쓰기 직후 최신 읽기가 필요한가?
복제 지연 중 오래된 읽기를 허용하는가?
네트워크 분할 중 읽기·쓰기는 어떻게 동작하는가?
충돌을 어떤 규칙으로 해결하는가?
```

CAP도 “항상 세 가지 중 두 개만 선택한다”는 표어가 아니라 네트워크 분할 상황에서 일관성과 가용성의 동작을 검토하는 관점으로 사용합니다.

잔여 좌석처럼 즉시 일치해야 하는 원본 규칙과 인기 강의 캐시처럼 잠시 오래된 값이 허용되는 데이터를 같은 기준으로 처리하지 않습니다.

---

## 11. 여러 저장소 사이의 동기화가 어려운 이유

```text
RDBMS 수강신청 COMMIT 성공
→ 추천 그래프 갱신 실패

RDBMS 강의 수정 성공
→ 문서 스냅샷 갱신 실패

신청 취소 성공
→ 인기 강의 캐시 무효화 실패
```

애플리케이션이 두 저장소에 순서대로 직접 쓰면 중간 실패 시 불일치를 남길 수 있습니다.

검토 대안:

```text
원본 DB를 하나로 정하고 파생 저장소를 비동기로 갱신
변경 이벤트·메시지 큐·CDC 활용
재시도와 중복에 대비한 멱등성 키
실패 이벤트와 재처리 대기열
주기적 대조·재구축
데이터 버전과 갱신 시각 기록
```

새 저장소를 선택할 때는 조회 성능뿐 아니라 **불일치 탐지와 복구 방법**을 포함합니다.

---

## 12. PostgreSQL JSONB로 문서형 요구를 검증한다

![JSONB 실습 흐름](../../images/chapter12/ch12_07_jsonb_practice_flow.svg)

그림 12-7 JSONB 실습 흐름

Chapter 12는 앞 장을 변경하지 않고 별도 공간을 사용합니다.

```text
nosql_lab.course_documents
nosql_lab.key_value_cache_examples
nosql_lab.storage_choice_cases
```

파일 구성:

```text
01_nosql_lab_schema.sql
02_nosql_lab_seed.sql
03_document_jsonb_queries.sql
04_key_value_cache_queries.sql
05_storage_choice_review.sql
06_jsonb_index_candidates.sql
07_nosql_lab_validation.sql
reset_nosql_lab.sql
```

이 실습은 전용 NoSQL 제품의 분산 처리·성능·TTL·복제·장애 동작을 구현하지 않습니다.

---

## 13. JSONB 조회 연산자와 검증 책임

| 연산자 | 결과 | 예 |
| --- | --- | --- |
| `->` | JSONB 값 | `metadata -> 'options'` |
| `->>` | text 값 | `metadata ->> 'field'` |
| `#>` | 깊은 경로 JSONB | `metadata #> '{options,online}'` |
| `#>>` | 깊은 경로 text | `metadata #>> '{options,online}'` |
| `?` | 최상위 키 존재 | `metadata ? 'instructor_snapshot'` |
| `@>` | JSONB 포함 | `metadata @> '{"tags":["SQL"]}'` |

검증 책임:

| 규칙 | DB 제약조건 | 애플리케이션·검증 SQL |
| --- | --- | --- |
| metadata 객체 | 적용 | 재확인 |
| course_code·title 공백 | 적용 | 보조 |
| level 허용값 | 일반 컬럼 CHECK | 보조 |
| tags 배열 | 선택 | 적용 |
| options 객체 | 선택 | 적용 |
| options.online boolean | 선택 | 적용 |
| instructor_snapshot 원본 대조 | 미적용 | 적용 |
| 문서 스키마 마이그레이션 | 어려움 | 주 책임 |

CHECK 하나로 깊은 JSON 전체를 완전히 검증하려 하기보다 핵심 규칙과 변화가 잦은 규칙을 나눕니다.

---

## 14. document_version으로 낙관적 잠금을 실습한다

단순히 버전을 증가시키기만 하면 동시 변경 충돌을 막을 수 없습니다. 읽은 버전을 조건에 넣습니다.

```sql
UPDATE nosql_lab.course_documents
SET
    metadata = jsonb_set(
        metadata,
        '{options,certificate}',
        'false'::jsonb
    ),
    document_version = document_version + 1,
    updated_at = CURRENT_TIMESTAMP
WHERE course_code = 'COURSE-301'
  AND document_version = 1
  AND jsonb_typeof(metadata -> 'options') = 'object';
```

영향 행 수가 1이면 예상 버전과 경로가 맞았습니다. 0이면 다른 사용자가 먼저 수정했거나 JSON 경로가 다를 수 있습니다.

`jsonb_set`은 중간 경로가 존재해야 기대한 변경이 이루어집니다. 따라서 경로 타입을 먼저 확인하고 변경 결과를 검증합니다.

실습 파일은 변경 후 다음 결과를 확인합니다.

```text
certificate=false
document_version=2
```

그 뒤 `ROLLBACK`해 기준을 유지합니다.

```text
certificate=true
document_version=1
```

`updated_at`은 자동으로 갱신되지 않습니다. 변경 SQL 또는 애플리케이션이 갱신 책임을 집니다.

---

## 15. JSONB 인덱스는 실제 질의 형태로 검토한다

```text
metadata @> ...
→ GIN 후보

metadata #>> '{options,online}' = 'true'
→ 표현식 B-tree 후보
```

```sql
CREATE INDEX idx_nosql_course_documents_metadata_gin
ON nosql_lab.course_documents
USING GIN (metadata);

CREATE INDEX idx_nosql_course_documents_online
ON nosql_lab.course_documents ((metadata #>> '{options,online}'));
```

`CREATE INDEX IF NOT EXISTS`는 같은 이름의 기존 인덱스 정의가 올바른지 보장하지 않습니다. `06_jsonb_index_candidates.sql`은 인덱스 미존재를 확인한 뒤 생성하고 `pg_indexes`와 카탈로그에서 정의를 검증합니다.

기본 `jsonb_ops`는 다양한 연산을 지원합니다. `jsonb_path_ops`는 포함·JSON path 중심 후보지만 키 존재 `?` 연산은 지원하지 않습니다. 실제 질의에 따라 선택합니다.

표본이 3행뿐이므로 인덱스가 있어도 PostgreSQL이 `Seq Scan`을 선택할 수 있습니다. 이 실습의 목적은 성능 향상 증명이 아니라 **질의 형태와 인덱스 구조의 대응**을 확인하는 것입니다.

---

## 16. 저장소 후보와 최종 결정을 구분한다

`storage_choice_cases`는 정답표가 아니라 의사결정 기록입니다.

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

| 사례 | 후보 | 상태 |
| --- | --- | --- |
| 수강신청·신청 당시 금액 | PostgreSQL RDBMS | adopted |
| 로그인 세션 | Key-Value | poc_planned |
| 인기 강의 캐시 | Key-Value | poc_planned |
| 유연 메타데이터 | JSONB 또는 Document | candidate |
| 학습 이벤트 | Column-Family | hold |
| 추천 관계 | Graph | candidate |

후보 저장소가 있다는 사실과 실제 채택은 다릅니다.

---

## 17. 작은 검증 실험부터 시작한다

```text
1. 대표 조회 2~3개를 고정한다.
2. 실제와 비슷한 데이터 분포·크기를 준비한다.
3. 성공·실패 조건을 정한다.
4. 읽기·쓰기·지연·중복·재시도를 측정한다.
5. 장애·복구·백업·권한 절차를 시험한다.
6. 기존 RDBMS·JSONB 방식과 비교한다.
7. 적용·보류·제외 결정을 기록한다.
```

평균 응답 시간만 보는 것은 부족합니다. 데이터 손실, 중복, 재처리, 장애 복구, 운영 인력과 비용도 확인합니다.

---

## 18. AI가 추천한 저장소 선택을 검토한다

![AI 추천 NoSQL 선택 검토 흐름](../../images/chapter12/ch12_08_ai_nosql_choice_review.svg)

그림 12-8 AI 추천 NoSQL 선택 검토 흐름

AI 요청 예:

```text
온라인 강의 서비스의 저장소 후보를 검토해 주세요.

현재 PostgreSQL 원본:
- students, instructors, courses, enrollments
- 신청 당시 기록 금액은 `enrollments.recorded_amount NUMERIC(12,0)`에 저장
- `recorded_amount`는 결제 승인액·환불 반영 순액·회계 매출이 아님
- 별도 결제·환불 원장은 현재 프로젝트 범위 밖

검토 데이터:
- 로그인 세션
- 인기 강의 캐시
- 강의별 가변 메타데이터
- 학생별 날짜·시간순 학습 이벤트
- 학생·강의·주제 추천 관계

각 항목에 대해 작성하세요.
1. 시스템 역할
2. 핵심 읽기·쓰기 패턴
3. RDBMS·JSONB로 충분한지
4. NoSQL 유형 후보와 제외 근거
5. 트랜잭션·일관성 범위
6. 동기화 실패·재시도·멱등성
7. 복구·백업·보안·모니터링 책임
8. PoC 성공 기준과 결정 상태
```

| 검토 항목 | 확인 질문 |
| --- | --- |
| 원본 | 최종 판단 기준 저장소가 명확한가? |
| 조회 패턴 | 키·조건·정렬·관계 깊이가 구체적인가? |
| 일관성 | 오래된 읽기·중복 허용 범위가 있는가? |
| 트랜잭션 | 한 키·문서·파티션·다중 객체 범위가 명확한가? |
| JSONB 비교 | PostgreSQL 안에서 충분한지 먼저 봤는가? |
| 동기화 | 이중 쓰기 실패·재시도·멱등성을 고려했는가? |
| 복구 | 파생 저장소를 다시 만들 수 있는가? |
| 운영 | 배포·모니터링·백업·권한 담당이 있는가? |
| 검증 | 실제 데이터와 실패 조건을 포함한 PoC인가? |
| 결정 | 후보와 채택 상태를 구분했는가? |

잘못된 제안:

```text
트래픽이 많으므로 모든 테이블을 NoSQL로 이동
JSON을 저장하므로 무조건 Document DB
로그라는 이유만으로 조회 패턴 없이 Column-Family
관계가 있다는 이유만으로 단순 JOIN도 Graph DB
캐시를 원본처럼 사용하고 재구축 경로 누락
제품 이름만으로 일관성·트랜잭션 단정
운영·백업·복구 비용 누락
```

---

## 19. 실행 안전성과 최종 검증

`01_nosql_lab_schema.sql`은 다음을 검사합니다.

```text
현재 DB = ai_database_book
course_project = students 3, instructors 2, courses 3, enrollments 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
recorded_amount = NUMERIC(12,0)
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
활성 신청 부분 고유 인덱스 존재
nosql_lab 미존재
```

스키마와 테이블은 하나의 트랜잭션에서 생성합니다.

`02_nosql_lab_seed.sql`은 세 테이블이 비어 있는지 확인하고 문서·캐시·선택 사례를 하나의 트랜잭션에서 입력합니다.

`reset_nosql_lab.sql`은 `ai_database_book`이 아니면 삭제를 중단합니다.

`07_nosql_lab_validation.sql`은 다음을 자동 판정합니다.

```text
Chapter 07 기준 3/2/3/5
Chapter 12 기준 3/4/6
강의 301~303 원본 매핑
강사 스냅샷 원본 대조
JSONB 구조·버전·시각
COURSE-301 ROLLBACK 기준
Seed 캐시 4/3/1
인기 강의 course_ids 301~303
시스템 역할 6종
선택 근거 공백 0건
adopted 사례 1건
GIN·표현식 인덱스 정의
```

통과 메시지:

```text
Chapter 12 nosql_lab validation passed
```

---

## 20. 자주 하는 실수

1. NoSQL을 RDBMS의 완전한 대체재로 설명한다.
2. “스키마가 없다”를 “규칙이 없다”로 이해한다.
3. 캐시의 현재 유효 건수를 고정 정답으로 사용한다.
4. 파생 문서의 원본 식별자를 기록하지 않는다.
5. 안정된 핵심 필드까지 모두 JSONB에 넣는다.
6. 강사 복사본을 원본인지 스냅샷인지 정의하지 않는다.
7. 조회 패턴 없이 Column-Family 키를 설계한다.
8. 관계가 있다는 이유만으로 Graph DB를 선택한다.
9. 두 저장소에 직접 쓰고 중간 실패를 고려하지 않는다.
10. `document_version`을 저장만 하고 UPDATE 조건에 사용하지 않는다.
11. `jsonb_set`의 중간 경로 존재를 확인하지 않는다.
12. `CREATE INDEX IF NOT EXISTS`가 정의까지 검증한다고 생각한다.
13. 후보 저장소를 이미 채택한 것으로 기록한다.
14. 성능만 측정하고 복구·보안·운영 비용을 제외한다.

---

## 21. 스스로 확인하기

1. NoSQL이 RDBMS의 반대말이나 완전한 대체재가 아닌 이유는 무엇인가요?
2. Source of Truth와 Derived Cache는 어떻게 다른가요?
3. Seed 기준 캐시 상태와 현재 시각 기준 상태를 구분해야 하는 이유는 무엇인가요?
4. Key-Value 키에 네임스페이스와 버전을 포함하는 이유는 무엇인가요?
5. 문서 포함과 참조를 판단하는 기준은 무엇인가요?
6. `level`을 JSONB가 아닌 일반 컬럼에 둔 이유는 무엇인가요?
7. `instructor_snapshot`이 원본이 아닌 이유는 무엇인가요?
8. Column-Family 설계가 조회 문장에서 시작해야 하는 이유는 무엇인가요?
9. 단순 JOIN과 다단계 그래프 탐색은 어떻게 다른가요?
10. 여러 저장소에 직접 이중 쓰기할 때 어떤 실패가 남나요?
11. `document_version`은 동시 수정 충돌을 어떻게 탐지하나요?
12. `jsonb_set`에서 중간 경로를 확인해야 하는 이유는 무엇인가요?
13. GIN과 표현식 B-tree 인덱스의 대상 질의는 어떻게 다른가요?
14. 후보 저장소와 `adopted` 상태는 어떻게 다른가요?
15. PoC에서 응답 시간 외에 무엇을 검증해야 하나요?

---

## 22. 권장 해설

### 원본과 파생 데이터

```text
Source of Truth는 최종 판단 기준이다.
캐시·문서 스냅샷·추천 그래프는 원본에서 다시 만들 수 있는 파생 구조일 수 있다.
```

### 캐시 시간 기준

```text
created_at과 expired_at 비교는 Seed 시점 상태를 재현한다.
CURRENT_TIMESTAMP 비교는 실제 현재 상태이며 시간이 지나면 결과가 달라진다.
```

### 혼합 문서 설계

```text
모든 문서에서 중요하고 자주 검증·검색하는 값은 일반 컬럼에 둔다.
문서마다 달라지는 태그·옵션·표시용 스냅샷은 JSONB 후보가 된다.
```

### 문서 버전

```text
UPDATE 조건에 읽은 document_version을 포함한다.
영향 행 수 0은 충돌 또는 경로 불일치 신호다.
```

### 인덱스

```text
@> 포함 검색은 GIN 후보,
특정 JSON 경로의 동등 조건은 표현식 B-tree 후보다.
작은 표본의 Seq Scan은 오류가 아니다.
```

### 저장소 결정

```text
candidate는 검토 대상이고 adopted는 근거와 검증을 거친 현재 결정이다.
PoC는 성능뿐 아니라 중복·장애·복구·보안·비용을 포함한다.
```

---

## 23. 핵심 정리

```text
1. NoSQL은 여러 비관계형 저장 모델의 계열이며 RDBMS의 완전한 대체재가 아니다.
2. 저장소 선택은 데이터의 시스템 역할과 대표 조회에서 시작한다.
3. Key-Value는 정확한 키·TTL·미스·재생성 경로가 중요하다.
4. Document는 함께 읽고 쓰는 경계와 스키마·버전 책임이 중요하다.
5. Column-Family는 대표 조회에서 파티션·정렬 키를 역으로 설계한다.
6. Graph는 관계 존재보다 다단계 탐색이 핵심일 때 검토한다.
7. 여러 저장소에는 동기화·재시도·멱등성·재구축 책임이 생긴다.
8. 안정된 핵심 필드는 일반 컬럼, 가변 부가는 JSONB로 분리할 수 있다.
9. 문서 버전과 영향 행 수로 낙관적 충돌을 탐지한다.
10. 캐시 Seed 기준과 실제 현재 상태를 구분한다.
11. 후보 저장소와 최종 채택 상태를 분리한다.
12. 새 저장소는 실패·복구·운영까지 작은 PoC에서 검증한다.
```

이 장에서 기억할 문장은 다음과 같습니다.

```text
저장소는 데이터 모양이 아니라,
원본의 책임과 반복되는 조회·실패·복구 패턴으로 선택한다.
```

---

## 24. 다음 장에서는

Chapter 13에서는 ChatGPT와 Codex를 사용해 요구사항, 테이블, 제약조건, SQL과 검증 결과를 체계적으로 리뷰하는 방법을 다룹니다.

```text
AI에 제공할 설계 문맥
요구사항에서 누락된 규칙 찾기
DDL·DML·조회 SQL 검토
샘플 데이터와 반례 생성
파괴적 SQL·과도한 권한·성능 제안 검토
검토 결과를 변경 이력으로 남기기
```

저장소 선택도 AI에게 맡길 수 있는 정답 문제가 아닙니다. 사람이 업무 규칙과 실패 비용을 정의하고 AI 결과를 검증해야 합니다.
