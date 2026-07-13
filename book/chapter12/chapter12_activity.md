# Chapter 12 활동지

## NoSQL 이해와 선택 기준

이 활동지는 온라인 강의 서비스 데이터를 기준으로 NoSQL 유형과 PostgreSQL JSONB 실습 결과를 점검하기 위한 자료입니다.

## 1. 실습 목표

- RDBMS와 NoSQL의 역할 차이를 설명한다.
- Key-Value, Document, Column-Family, Graph DB의 적합한 사용 상황을 구분한다.
- `course_documents`의 JSONB 조회 결과를 해석한다.
- Key-Value 시뮬레이션 테이블의 한계를 설명한다.
- AI가 추천한 저장 방식이 타당한지 검토한다.

## 2. 실행 파일

```bash
psql -U postgres -d ai_database_book -f code/chapter12/nosql_jsonb_practice.sql
```

이 실습은 별도 NoSQL 서버를 설치하지 않습니다. PostgreSQL JSONB로 문서형 데이터 개념을 맛보고, 일반 테이블로 Key-Value 캐시 개념을 단순 시뮬레이션합니다.

## 3. 실행 전 자기 점검

- [ ] PostgreSQL 접속 데이터베이스를 확인했다.
- [ ] JSONB가 실제 Document DB 자체는 아니라는 점을 이해했다.
- [ ] `key_value_cache_examples`가 실제 Key-Value DB가 아니라 개념 시뮬레이션임을 이해했다.
- [ ] `expired_at`이 자동 삭제를 수행하지 않는다는 점을 이해했다.

## 4. 생성 테이블 확인

실습 후 다음 행 수가 나오는지 확인합니다.

| 테이블 | 기대 행 수 |
|---|---:|
| `course_documents` | 3 |
| `key_value_cache_examples` | 4 |
| `storage_choice_cases` | 5 |

확인 결과를 기록합니다.

| 테이블 | 실제 행 수 | 확인 |
|---|---:|---|
| `course_documents` |  |  |
| `key_value_cache_examples` |  |  |
| `storage_choice_cases` |  |  |

## 5. JSONB 조회 결과 확인

다음 결과가 나오는지 확인합니다.

| course_code | title | level | online |
|---|---|---|---|
| DB-101 | 데이터베이스 입문 | basic | true |
| AI-201 | AI 데이터 분석 | intermediate | true |
| GRAPH-301 | 그래프 데이터 이해 | advanced | false |

질문에 답해 봅니다.

- `metadata ->> 'level'`은 왜 문자열로 비교하기 쉬운가?
- `metadata -> 'options' ->> 'online'`은 어떤 경로를 따라 값을 읽는가?
- `?` 연산자와 `@>` 연산자는 각각 어떤 상황에서 사용할 수 있는가?

## 6. JSONB와 Document DB 구분하기

다음 문장을 완성합니다.

- PostgreSQL JSONB는 JSON 형태 데이터를 저장하고 조회할 수 있지만, PostgreSQL 자체가 별도 Document DB가 되는 것은 아니다.
- 실제 Document DB를 검토하려면 문서 크기, 갱신 단위, 인덱스, 복제, 샤딩, 운영 경험을 함께 확인해야 한다.
- 강의 메타데이터처럼 구조가 조금씩 다른 데이터는 JSONB로 시작할 수 있지만, 자주 조회하는 필드는 별도 컬럼이나 인덱스를 검토해야 한다.

## 7. Key-Value 캐시 개념 확인

`key_value_cache_examples`에는 4개 행이 있습니다.

| 구분 | 기대 결과 |
|---|---:|
| 전체 캐시 행 | 4 |
| 유효 캐시 | 3 |
| 만료 캐시 | 1 |

질문에 답해 봅니다.

- `student:1001:session` 같은 키는 어떤 조회에 적합한가?
- 캐시는 원본 데이터인가, 원본에서 만든 파생 데이터인가?
- 캐시 미스가 발생하면 어떤 순서로 처리해야 하는가?
- `expired_at`이 지난 행은 왜 자동으로 삭제되지 않는가?
- 이 실습 테이블이 실제 Key-Value DB의 메모리 저장, 분산, 자동 TTL 삭제, 복제를 구현하지 않는 이유는 무엇인가?

## 8. Column-Family 설계 점검

목표 조회가 “학생 한 명의 특정 날짜 학습 이벤트를 시간순으로 읽기”라고 가정합니다.

| 항목 | 설계 예시 | 내 설명 |
|---|---|---|
| partition key | `student_id + event_date` |  |
| sort key | `event_time` |  |
| target query | 특정 학생의 특정 날짜 이벤트 |  |

질문에 답해 봅니다.

- Column-Family DB 설계가 조회 패턴에서 출발해야 하는 이유는 무엇인가?
- 이 구조가 아무 조건이나 자유롭게 검색하는 구조가 아닌 이유는 무엇인가?
- 비정규화가 필요한 경우 어떤 장점과 부담이 생기는가?

## 9. Graph DB와 RDBMS JOIN 비교

다음 사례를 보고 Graph DB가 필요한지 판단합니다.

| 사례 | RDBMS JOIN으로 충분한가? | Graph DB 검토가 필요한가? | 이유 |
|---|---|---|---|
| 강의별 수강 학생 목록 |  |  |  |
| 학생이 수강한 강의 목록 |  |  |  |
| Topic X와 연결된 학생에게 2단계 이상 관계를 따라 추천 강의 찾기 |  |  |  |
| 학생-강의-주제 관계를 반복 확장하며 유사 집단 찾기 |  |  |  |

## 10. 저장 방식 선택 활동

다음 데이터를 어떤 저장 방식으로 둘지 판단합니다.

| 데이터 | 후보 저장 방식 | 원본/파생 | 정합성 요구 | 판단 근거 |
|---|---|---|---|---|
| `students` | RDBMS | 원본 | 강함 |  |
| `enrollments` | RDBMS | 원본 | 강함 |  |
| 학생 로그인 세션 | Key-Value DB | 파생/상태 | 상황 의존 |  |
| 인기 강의 캐시 | Key-Value DB | 파생 | 최종 일관성 허용 |  |
| 강의 유연 메타데이터 | Document DB 또는 JSONB | 원본 또는 보조 | 상황 의존 |  |
| 학습 행동 이벤트 | Column-Family DB | 이벤트 로그 | 최종 일관성 허용 가능 |  |
| 학생-강의-주제 추천 관계 | Graph DB | 관계 인덱스 | 상황 의존 |  |

## 11. AI 추천 검토 질문

AI가 “온라인 강의 서비스는 NoSQL을 쓰면 좋다”고 답했다고 가정합니다. 다음 질문으로 검토합니다.

- [ ] 어떤 데이터를 NoSQL에 둔다고 했는가?
- [ ] 원본 데이터와 캐시 데이터를 구분했는가?
- [ ] 조회 패턴을 구체적으로 제시했는가?
- [ ] 정합성과 트랜잭션 요구사항을 확인했는가?
- [ ] PostgreSQL JSONB로 충분한 문제인지 비교했는가?
- [ ] 별도 NoSQL 서버 운영 비용과 백업, 복구를 고려했는가?
- [ ] 작은 샘플로 먼저 검증할 방법을 제시했는가?

## 12. 최종 자기 점검

- [ ] NoSQL을 관계형 DB의 완전한 대체재로 설명하지 않을 수 있다.
- [ ] Key-Value 캐시가 원본 데이터와 다르다는 점을 설명할 수 있다.
- [ ] Document DB에도 설계 규칙이 필요하다는 점을 설명할 수 있다.
- [ ] Column-Family DB의 partition key와 sort key를 조회 패턴과 연결할 수 있다.
- [ ] Graph DB가 필요한 상황과 RDBMS JOIN으로 충분한 상황을 구분할 수 있다.
- [ ] JSONB GIN 인덱스와 표현식 인덱스의 차이를 설명할 수 있다.
- [ ] AI 추천을 그대로 믿지 않고 검증 질문을 만들 수 있다.
