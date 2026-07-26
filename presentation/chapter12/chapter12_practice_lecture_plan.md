# Chapter 12 실습 발표 강의안

## PostgreSQL JSONB로 NoSQL 선택 기준을 검증하기

> 목적: `nosql_lab`에서 PostgreSQL JSONB와 일반 테이블을 사용해 Key-Value, Document, 저장소 선택 기록의 핵심 개념을 실습하고 검증한다.  
> 기준: 초보자가 “NoSQL 서버를 설치했다”가 아니라 “원본·캐시·문서·이벤트·관계 인덱스를 구분하고, 저장소 후보의 근거와 검증값을 확인했다”라고 말할 수 있어야 한다.

---

## 1. 이번 실습은 NoSQL 제품 실습이 아니라 선택 기준 검증입니다

**화면 구성**

```text
01 schema
→ 02 seed
→ 03 JSONB document queries
→ 04 key-value cache queries
→ 05 storage choice review
→ 06 JSONB index candidates
→ 07 validation
```

**발표 스크립트**

이번 실습은 MongoDB, Redis, Cassandra, Graph DB를 실제로 설치하는 실습이 아닙니다.

PostgreSQL 안의 `nosql_lab` 스키마를 사용해 저장 모델을 판단하는 기준을 연습합니다. 핵심은 “어떤 제품을 쓸 것인가”가 아니라 “이 데이터의 역할과 반복 조회 패턴이 무엇인가”입니다.

실습은 `nosql_lab`만 생성하고 사용합니다. 앞 장의 `course_project`, `transaction_lab`, `performance_lab`, `security_lab`은 변경하지 않습니다.

---

## 2. 실습 전 실행 위치와 보호 범위를 확인합니다

**화면 구성**

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

확인:

```text
현재 DB = ai_database_book
course_project = 3 / 2 / 3 / 5
nosql_lab = 생성 전 미존재
```

**발표 스크립트**

실습을 시작하기 전에 내가 어느 데이터베이스에서 실행 중인지 확인합니다.

기대 데이터베이스는 `ai_database_book`입니다. 현재 스키마가 `nosql_lab`일 필요는 없습니다. SQL 파일은 `nosql_lab.course_documents`처럼 스키마 이름을 명시합니다.

또 Chapter 07의 원본 기준값이 맞는지 확인합니다. 원본이 달라지면 문서 매핑과 검증 결과도 달라질 수 있습니다.

---

## 3. 세 테이블의 역할을 먼저 이해합니다

**화면 구성**

| 테이블 | 역할 |
|---|---|
| `course_documents` | 강의 문서형 메타데이터 |
| `key_value_cache_examples` | 캐시·세션·기능 플래그 예시 |
| `storage_choice_cases` | 저장소 후보와 결정 기록 |

**발표 스크립트**

이번 실습의 테이블은 실제 NoSQL 제품을 그대로 구현한 것이 아닙니다. 개념을 비교하기 위한 PostgreSQL 모델입니다.

`course_documents`는 Document 모델과 JSONB를 이해하기 위한 테이블입니다. `key_value_cache_examples`는 Key-Value 캐시의 키, 값, 만료 시각을 기록합니다.

`storage_choice_cases`는 저장소 선택 판단을 기록합니다. 정답표가 아니라 후보, 근거, PoC 상태를 남기는 의사결정 표입니다.

---

## 4. 시스템 역할을 분류합니다

**화면 구성**

| 데이터 | 시스템 역할 |
|---|---|
| 수강신청·신청 당시 금액 | Source of Truth |
| 로그인 세션 | Ephemeral State |
| 인기 강의 목록 | Derived Cache |
| 강의 태그·옵션·스냅샷 | Flexible Metadata |
| 학습 행동 | Event Log |
| 추천 관계 | Relationship Index |

**발표 스크립트**

워크북의 첫 번째 판단은 시스템 역할 분류입니다. 같은 온라인 강의 서비스 데이터라도 역할이 다릅니다.

수강신청과 신청 당시 금액은 최종 판단 기준이 되는 원본입니다. 인기 강의 목록은 원본에서 다시 계산할 수 있는 파생 캐시입니다.

이 분류를 먼저 해야 장애 상황에서 무엇을 믿고, 무엇을 다시 만들 수 있는지 판단할 수 있습니다.

---

## 5. Key-Value 캐시 키를 읽습니다

**화면 구성**

예시 키:

```text
student:101:session
course:popular:v1:top3
feature:recommendation:v1
```

확인:

```text
네임스페이스 / 식별자 / 버전 / 목적
```

**발표 스크립트**

04 파일에서는 Key-Value 캐시 예시를 조회합니다. 먼저 키 이름을 봅니다.

좋은 키는 무엇을 나타내는지 드러나야 합니다. `course:popular:v1:top3`은 강의 인기 목록이고, 버전 1이며, 상위 3개라는 뜻을 담고 있습니다.

키가 모호하면 운영 중 충돌이나 해석 오류가 생깁니다. 캐시 키는 짧은 문자열이지만 설계 문서의 역할도 합니다.

---

## 6. Seed 기준 캐시와 현재 기준 캐시를 구분합니다

**화면 구성**

| 기준 | 조건 | 결과 성격 |
|---|---|---|
| Seed 기준 | `expired_at IS NULL OR expired_at > created_at` | 재현 가능 |
| 현재 기준 | `expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP` | 시간 의존 |

**발표 스크립트**

캐시 실습에서는 같은 데이터도 기준 시각에 따라 결과가 달라질 수 있습니다.

Seed 기준은 행이 만들어진 시점에서 유효했는지를 봅니다. 그래서 교재에서 전체 4개, Seed 시점 유효 3개, Seed 시점 만료 1개처럼 기대값을 고정할 수 있습니다.

현재 기준은 지금 이 순간 만료되었는지 봅니다. 시간이 지나면 결과가 바뀔 수 있으므로, 자동 검증 기준과 운영 판단 기준을 구분해야 합니다.

---

## 7. Document 테이블에서 일반 컬럼과 JSONB를 구분합니다

**화면 구성**

| 일반 컬럼 | JSONB |
|---|---|
| source_course_id | tags |
| course_code | options |
| title | instructor_snapshot |
| level |  |
| document_version |  |

**발표 스크립트**

03 파일에서는 `course_documents`를 조회합니다. 여기서 중요한 것은 어떤 속성을 일반 컬럼으로 두고, 어떤 속성을 JSONB로 두었는지 보는 것입니다.

`level`은 모든 강의에서 중요하고 자주 검색할 수 있으므로 일반 컬럼입니다. 반면 태그나 옵션은 문서마다 달라질 수 있으므로 JSONB에 둡니다.

모든 것을 JSONB에 넣으면 구조가 유연해 보이지만, 제약조건과 검색, 통계, JOIN이 어려워질 수 있습니다.

---

## 8. Chapter 07 원본과 문서 매핑을 확인합니다

**화면 구성**

| source_course_id | course_code | title | level |
|---:|---|---|---|
| 301 | COURSE-301 | 데이터베이스 입문 | basic |
| 302 | COURSE-302 | 정규화 실습 | basic |
| 303 | COURSE-303 | 파이썬 데이터 분석 | basic |

**발표 스크립트**

문서 데이터가 원본과 연결되는지 확인합니다. `source_course_id`는 Chapter 07의 강의 ID와 대응합니다.

이 값이 있어야 문서 스냅샷이 오래되었을 때 원본과 다시 대조할 수 있습니다.

전용 Document DB로 분리하더라도 원본 식별자를 잃으면 재구축과 동기화가 어려워집니다.

---

## 9. instructor_snapshot을 원본과 대조합니다

**화면 구성**

```text
metadata -> 'instructor_snapshot'
```

확인 항목:

```text
source_instructor_id
name
specialty
copied_at
```

**발표 스크립트**

강의 문서 안에는 강사 스냅샷이 들어 있습니다. 화면 표시에는 편리하지만 원본은 아닙니다.

원본 강사 정보가 바뀌면 스냅샷도 갱신되어야 합니다. 갱신 이벤트가 누락되면 오래된 강사 이름이나 전문 분야가 남을 수 있습니다.

그래서 검증 SQL은 스냅샷의 `source_instructor_id`를 기준으로 원본과 대조합니다.

---

## 10. JSONB 연산자를 실행해 봅니다

**화면 구성**

| 연산자 | 실습 질문 |
|---|---|
| `->` | JSONB 값 꺼내기 |
| `->>` | text 값 꺼내기 |
| `#>` | 깊은 경로 JSONB |
| `#>>` | 깊은 경로 text |
| `?` | 키 존재 여부 |
| `@>` | 포함 여부 |

**발표 스크립트**

JSONB를 사용할 때는 연산자 차이를 이해해야 합니다. `->`는 JSONB 값을 반환하고, `->>`는 text 값을 반환합니다.

깊은 경로를 조회할 때는 `#>` 또는 `#>>`를 사용합니다. 키 존재 여부는 `?`, 특정 구조를 포함하는지는 `@>`로 확인할 수 있습니다.

실습에서는 PostgreSQL 태그를 포함한 문서, online 옵션이 true인 문서 등을 조회하며 연산자의 의미를 확인합니다.

---

## 11. JSONB 구조 검증 책임을 기록합니다

**화면 구성**

| 규칙 | DB 제약조건 | 애플리케이션·검증 SQL |
|---|---|---|
| metadata 객체 | 적용 | 재확인 |
| level 허용값 | 일반 컬럼 CHECK | 보조 |
| tags 배열 | 선택 | 적용 |
| online boolean | 선택 | 적용 |
| 스냅샷 원본 대조 | 미적용 | 적용 |

**발표 스크립트**

JSONB는 유연하지만 책임이 사라지는 것은 아닙니다. 데이터 구조 규칙을 어디에서 검증할지 정해야 합니다.

핵심 규칙은 DB 제약조건으로 두는 것이 좋습니다. 예를 들어 `level`은 일반 컬럼 CHECK로 검증합니다.

반면 JSON 내부의 깊은 구조는 애플리케이션과 검증 SQL이 담당할 수 있습니다. 중요한 것은 검증 책임을 명확히 기록하는 것입니다.

---

## 12. document_version으로 낙관적 잠금을 확인합니다

**화면 구성**

| 단계 | certificate | document_version |
|---|---|---:|
| 변경 전 | true | 1 |
| 트랜잭션 내부 | false | 2 |
| ROLLBACK 후 | true | 1 |

**발표 스크립트**

03 파일의 변경 실습은 문서 버전을 사용한 낙관적 잠금을 보여 줍니다. UPDATE 조건에 `document_version = 1`이 들어갑니다.

영향 행 수가 1이면 내가 읽은 버전이 아직 유효하다는 뜻입니다. 영향 행 수가 0이면 다른 사용자가 먼저 수정했거나, JSON 경로가 예상과 다를 수 있습니다.

실습은 변경 결과를 확인한 뒤 ROLLBACK합니다. 그래서 기준 데이터는 다시 `certificate=true`, `document_version=1`로 돌아와야 합니다.

---

## 13. `jsonb_set`은 경로 확인이 필요합니다

**화면 구성**

```text
변경 대상: {options,certificate}
사전 확인: metadata -> 'options'가 object인가?
결과 확인: certificate 값과 document_version
```

**발표 스크립트**

`jsonb_set`은 JSONB 문서 일부를 바꿀 때 사용합니다. 하지만 중간 경로가 예상과 다르면 원하는 위치가 바뀌지 않을 수 있습니다.

그래서 변경 전에 `options`가 객체인지 확인하고, 변경 후에도 실제 값이 바뀌었는지 조회해야 합니다.

문서형 데이터는 유연하지만, 유연한 만큼 변경 전후 검증이 더 중요합니다.

---

## 14. Column-Family는 조회 패턴을 워크북에 적습니다

**화면 구성**

```text
학생 ___의 날짜 ___ 이벤트를 시간순으로 읽는다
```

설계 요소:

```text
partition key / clustering key / event_id / 보존 기간 / 늦은 이벤트 처리
```

**발표 스크립트**

Column-Family는 실제 서버를 설치하지 않고 설계 판단만 기록합니다. 먼저 목표 조회를 문장으로 씁니다.

예를 들어 학생 101의 2026년 7월 13일 이벤트를 시간순으로 읽는다면, 학생과 날짜가 파티션 기준이 될 수 있고, 이벤트 시간이 정렬 기준이 됩니다.

이 용어는 Cassandra 계열을 중심으로 한 예시입니다. 제품마다 구현이 다르므로 이름만 보고 보장을 단정하지 않습니다.

---

## 15. Graph DB 후보는 관계 탐색 깊이로 판단합니다

**화면 구성**

| 질문 | 우선 후보 |
|---|---|
| 강의별 수강 학생 | RDBMS JOIN |
| 학생별 수강 강의 | RDBMS JOIN |
| 학생→주제→강의 탐색 | Graph 후보 |
| 유사 학생 관계 반복 확장 | Graph 후보 |

**발표 스크립트**

Graph DB를 검토할 때는 관계가 존재한다는 사실만 보지 않습니다. RDBMS도 관계를 다룹니다.

단순한 학생별 수강 강의, 강의별 수강 학생은 JOIN으로 충분할 수 있습니다.

Graph DB는 여러 단계 관계를 반복적으로 탐색하는 것이 핵심일 때 후보가 됩니다. 워크북에는 어떤 질문이 JOIN 우선이고, 어떤 질문이 Graph 후보인지 구분해서 적습니다.

---

## 16. 저장소 후보와 결정 상태를 검토합니다

**화면 구성**

| 상태 | 의미 |
|---|---|
| candidate | 후보 |
| poc_planned | PoC 예정 |
| hold | 보류 |
| adopted | 채택 |
| rejected | 제외 |

**발표 스크립트**

05 파일은 저장소 선택 사례를 조회합니다. 여기서 중요한 것은 후보와 채택을 구분하는 것입니다.

수강신청 원본은 PostgreSQL RDBMS가 채택된 상태입니다. 하지만 로그인 세션이나 인기 강의 캐시는 Key-Value 후보이며, 아직 PoC가 필요할 수 있습니다.

결정 상태를 기록하면 “좋아 보인다”와 “운영에 채택한다”를 분리할 수 있습니다.

---

## 17. 여러 저장소 동기화 실패를 검토합니다

**화면 구성**

| 실패 | 남은 불일치 | 복구 방향 |
|---|---|---|
| RDBMS COMMIT 후 캐시 갱신 실패 | 캐시가 오래됨 | 무효화·재생성 |
| 강의 수정 후 문서 갱신 실패 | 스냅샷 오래됨 | 원본 대조·재구축 |
| 이벤트 중복 발행 | 중복 이벤트 | event_id·멱등성 |

**발표 스크립트**

여러 저장소를 쓰면 동기화 실패를 반드시 생각해야 합니다.

RDBMS 변경은 성공했지만 캐시 갱신이 실패할 수 있습니다. 강의 원본은 바뀌었는데 문서 스냅샷이 오래된 상태로 남을 수도 있습니다.

그래서 원본, 변경 이벤트, 재시도, 멱등성 키, 실패 대기열, 주기적 대조, 재구축 방법을 함께 기록해야 합니다.

---

## 18. JSONB 인덱스 후보를 생성하고 정의를 확인합니다

**화면 구성**

```sql
CREATE INDEX idx_nosql_course_documents_metadata_gin
ON nosql_lab.course_documents
USING GIN (metadata);

CREATE INDEX idx_nosql_course_documents_online
ON nosql_lab.course_documents ((metadata #>> '{options,online}'));
```

**발표 스크립트**

06 파일에서는 JSONB 인덱스 후보를 만듭니다. GIN 인덱스는 JSONB 포함 검색 같은 질의에 대응할 수 있습니다.

표현식 B-tree 인덱스는 특정 JSON 경로를 꺼내 비교하는 질의에 대응할 수 있습니다.

이번 데이터는 3행뿐입니다. 실행 계획에서 큰 성능 향상을 기대하기보다, 질의 형태와 인덱스 정의가 맞는지를 확인하는 것이 목표입니다.

---

## 19. 최종 검증 SQL로 기준 상태를 확인합니다

**화면 구성**

기대값:

```text
Chapter 07 기준: 3 / 2 / 3 / 5
Chapter 12 기준: 3 / 4 / 6
Seed 캐시: 4 / 3 / 1
adopted 사례: 1
GIN·표현식 인덱스 정의 확인
```

통과 메시지:

```text
Chapter 12 nosql_lab validation passed
```

**발표 스크립트**

마지막으로 07 검증 파일을 실행합니다. 이 파일은 단순히 테이블이 있는지만 보지 않습니다.

원본 매핑, 강사 스냅샷 대조, JSONB 구조, 문서 버전, 캐시 기준값, 저장소 선택 근거, 인덱스 정의까지 확인합니다.

검증을 통과하면 `Chapter 12 nosql_lab validation passed` 메시지가 나옵니다. 이 메시지가 나오면 Chapter 12 실습의 기준 상태가 유지된 것입니다.

---

## 20. AI 저장소 추천과 최종 완료 기준을 정리합니다

**화면 구성**

AI 검토 기준:

```text
원본 명확성
조회 패턴
일관성·트랜잭션 범위
동기화 실패
복구·백업·보안
PoC 성공 기준
후보와 채택 구분
```

**발표 스크립트**

AI에게 저장소 추천을 받을 때는 제품 이름만 받아들이면 안 됩니다. 현재 원본이 무엇인지, 어떤 조회가 반복되는지, 오래된 값을 허용할 수 있는지까지 함께 검토해야 합니다.

“트래픽이 많으니 모든 테이블을 NoSQL로 옮기자”는 제안은 너무 거칩니다. 수강신청 원본, 캐시, 이벤트, 추천 그래프는 서로 역할이 다릅니다.

최종 완료 기준은 명확합니다. `nosql_lab`만 변경했고, 원본 매핑이 맞고, Seed 기준 캐시와 JSONB 문서 검증이 맞고, 후보 저장소의 근거와 결정 상태를 설명할 수 있어야 합니다.