# Chapter 12 활동 자료

## NoSQL 이해와 선택 기준

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 12 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 12의 NoSQL 개념과 데이터베이스 선택 기준을 실습하기 위한 자료입니다.

학습자는 PostgreSQL의 `JSONB`를 사용해 문서형 데이터 구조를 맛보고, Key-Value DB 개념을 단순 시뮬레이션하며, 데이터 유형별로 어떤 저장 방식이 적합한지 판단합니다.

이 활동의 핵심은 특정 NoSQL 제품명을 외우는 것이 아니라, **데이터 구조, 조회 패턴, 정합성 요구사항, 운영 난이도를 기준으로 저장 방식을 선택하는 것**입니다.

```text
- 이 데이터는 테이블형인가, 문서형인가, 관계형인가?
- 키로 바로 조회하는가, 조건 검색이 많은가?
- 정합성과 트랜잭션이 중요한가?
- 데이터가 얼마나 빠르게 쌓이는가?
- 팀이 해당 DB를 운영할 수 있는가?
- AI가 추천한 DB 선택을 그대로 믿어도 되는가?
```

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. 관계형 데이터베이스와 NoSQL의 차이를 설명할 수 있다.
2. Key-Value DB, Document DB, Column-Family DB, Graph DB의 특징을 구분할 수 있다.
3. PostgreSQL JSONB를 사용해 문서형 데이터를 조회할 수 있다.
4. JSONB 중첩 객체와 배열 필드를 조회할 수 있다.
5. Key-Value 방식의 장점과 한계를 설명할 수 있다.
6. 데이터 유형별로 적합한 저장 방식을 선택할 수 있다.
7. AI가 추천한 NoSQL 선택 결과를 비판적으로 검토할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 실습 데이터베이스
- code/chapter12/nosql_jsonb_practice.sql
- ChatGPT 또는 Codex
```

### 주의 사항

```text
- 이 실습은 별도 NoSQL 서버를 설치하지 않습니다.
- PostgreSQL JSONB를 사용해 문서형 데이터 개념을 맛봅니다.
- JSONB가 모든 Document DB를 대체한다는 의미는 아닙니다.
- NoSQL 선택은 데이터 구조와 운영 환경을 함께 고려해야 합니다.
- AI가 추천한 결과는 초안이며 그대로 적용하지 않습니다.
```

### 제출 파일명 권장

```text
학번_이름_chapter12_activity.md
```

예시:

```text
20260001_홍길동_chapter12_activity.md
```

---

## 4. 활동 1: 관계형 DB와 NoSQL 비교

다음 표를 완성하세요.

| 구분 | 관계형 데이터베이스 | NoSQL |
| --- | --- | --- |
| 기본 저장 구조 |  |  |
| 스키마 특징 |  |  |
| 관계 표현 방식 |  |  |
| 적합한 데이터 |  |  |
| 주의할 점 |  |  |

### 질문

```text
NoSQL이 관계형 데이터베이스보다 항상 좋은 것이 아닌 이유를 설명하세요.
```

---

## 5. 활동 2: NoSQL 유형별 특징 정리

다음 NoSQL 유형의 특징과 사용 사례를 정리하세요.

| 유형 | 핵심 구조 | 적합한 사용 사례 | 부적합할 수 있는 경우 |
| --- | --- | --- | --- |
| Key-Value DB |  |  |  |
| Document DB |  |  |  |
| Column-Family DB |  |  |  |
| Graph DB |  |  |  |

### 질문

```text
로그인 세션 저장에는 어떤 NoSQL 유형이 적합할 수 있나요? 이유를 설명하세요.
```

---

## 6. 활동 3: JSONB 문서형 데이터 확인

다음 파일을 실행합니다.

```text
code/chapter12/nosql_jsonb_practice.sql
```

생성되는 테이블을 확인하세요.

```text
course_documents
key_value_cache_examples
storage_choice_cases
```

`course_documents` 테이블의 구조를 기록하세요.

| 컬럼 | 역할 |
| --- | --- |
| id |  |
| title |  |
| metadata |  |
| created_at |  |

### 질문

```text
metadata 컬럼을 JSONB로 둔 이유는 무엇인가요?
```

---

## 7. 활동 4: JSONB 특정 필드 조회

다음 SQL을 실행하고 결과를 기록하세요.

```sql
SELECT
    id,
    title,
    metadata ->> 'level' AS level,
    metadata ->> 'online' AS online
FROM course_documents
ORDER BY id;
```

| id | title | level | online |
| ---: | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

### 질문

```text
metadata ->> 'level'에서 ->> 연산자는 어떤 결과를 반환하나요?
```

---

## 8. 활동 5: JSONB 중첩 객체 조회

다음 SQL을 실행하고 결과를 기록하세요.

```sql
SELECT
    title,
    metadata -> 'instructor' ->> 'name' AS instructor_name,
    metadata -> 'instructor' ->> 'specialty' AS instructor_specialty
FROM course_documents;
```

| title | instructor_name | instructor_specialty |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |

### 질문

```text
중첩 객체를 조회할 때 metadata -> 'instructor' ->> 'name'처럼 단계적으로 접근하는 이유를 설명하세요.
```

---

## 9. 활동 6: JSON 배열 태그 검색

다음 SQL을 실행하고 결과를 기록하세요.

```sql
SELECT id, title, metadata -> 'tags' AS tags
FROM course_documents
WHERE metadata -> 'tags' ? 'SQL';
```

| id | title | tags |
| ---: | --- | --- |
|  |  |  |

### 질문

```text
JSON 배열 안에 특정 태그가 포함되어 있는지 검색하는 방식은 어떤 데이터에 유용할까요?
```

---

## 10. 활동 7: JSONB 포함 조건 조회

다음 SQL을 실행하고 결과를 기록하세요.

```sql
SELECT id, title, metadata
FROM course_documents
WHERE metadata @> '{"online": true}'::jsonb;
```

| id | title | online 여부 |
| ---: | --- | --- |
|  |  |  |
|  |  |  |

### 질문

```text
metadata @> '{"online": true}'::jsonb 조건은 어떤 의미인가요?
```

---

## 11. 활동 8: JSONB 필드 수정

다음 SQL의 의미를 설명하세요.

```sql
UPDATE course_documents
SET metadata = jsonb_set(metadata, '{certificate}', 'true'::jsonb)
WHERE title = '그래프 데이터 이해';
```

| 항목 | 설명 |
| --- | --- |
| jsonb_set |  |
| '{certificate}' |  |
| 'true'::jsonb |  |
| WHERE title = ... |  |

### 질문

```text
문서형 데이터에서 필드를 유연하게 추가하거나 수정할 수 있다는 점은 어떤 장점과 위험을 동시에 갖나요?
```

---

## 12. 활동 9: JSONB 인덱스 맛보기

다음 인덱스의 목적을 설명하세요.

```sql
CREATE INDEX IF NOT EXISTS idx_course_documents_metadata_gin
ON course_documents
USING GIN (metadata);
```

```sql
CREATE INDEX IF NOT EXISTS idx_course_documents_level
ON course_documents ((metadata ->> 'level'));
```

| 인덱스 | 목적 |
| --- | --- |
| idx_course_documents_metadata_gin |  |
| idx_course_documents_level |  |

### 질문

```text
샘플 데이터가 적으면 인덱스가 있어도 Seq Scan이 나올 수 있는 이유를 설명하세요.
```

---

## 13. 활동 10: Key-Value DB 개념 시뮬레이션

`key_value_cache_examples` 테이블을 확인하세요.

| cache_key | cache_value 요약 | expired_at |
| --- | --- | --- |
| course:popular:top3 |  |  |
| user:1001:session |  |  |
| feature:recommendation:v1 |  |  |

### 질문

```text
Key-Value DB가 키를 알고 있을 때 빠른 조회에 적합한 이유를 설명하세요.
```

```text
Key-Value DB가 복잡한 조건 검색이나 JOIN에 적합하지 않을 수 있는 이유를 설명하세요.
```

---

## 14. 활동 11: 데이터 유형별 저장 방식 선택

다음 테이블의 데이터를 확인합니다.

```sql
SELECT
    data_name,
    consistency_required,
    query_pattern,
    suggested_storage,
    review_reason
FROM storage_choice_cases
ORDER BY id;
```

결과를 바탕으로 다음 표를 완성하세요.

| 데이터 | 정합성 요구 | 주요 조회 패턴 | 적합한 저장 방식 | 이유 |
| --- | --- | --- | --- | --- |
| 주문/결제 내역 |  |  |  |  |
| 로그인 세션 |  |  |  |  |
| 강의 상세 옵션 |  |  |  |  |
| 사용자 행동 로그 |  |  |  |  |
| 추천 관계 |  |  |  |  |

---

## 15. 활동 12: 직접 저장 방식 판단하기

다음 데이터에 대해 적합한 저장 방식을 선택하고 이유를 작성하세요.

| 데이터 | 선택한 저장 방식 | 이유 | 주의할 점 |
| --- | --- | --- | --- |
| 실시간 채팅 메시지 |  |  |  |
| 강의 댓글 |  |  |  |
| 결제 실패 로그 |  |  |  |
| 사용자별 최근 본 강의 목록 |  |  |  |
| 강의 간 선수과목 관계 |  |  |  |

선택 가능한 저장 방식 예시는 다음과 같습니다.

```text
Relational DB
Key-Value DB
Document DB
Column-Family DB
Graph DB
PostgreSQL JSONB
Log System
```

---

## 16. 활동 13: AI 추천 결과 검토

AI가 다음과 같이 추천했다고 가정합니다.

```text
모든 데이터를 Document DB에 저장하면 유연하고 빠르므로 가장 좋습니다.
```

다음 기준으로 검토하세요.

| 검토 항목 | 문제 여부 | 수정 방향 |
| --- | --- | --- |
| 정합성이 중요한 데이터가 포함되어 있는가? |  |  |
| 트랜잭션이 필요한 데이터가 포함되어 있는가? |  |  |
| JOIN이나 복잡한 SQL 분석이 필요한가? |  |  |
| 기존 관계형 DB로 충분히 해결 가능한가? |  |  |
| 새 NoSQL 운영 역량이 있는가? |  |  |
| 백업/복구/모니터링 방법이 준비되어 있는가? |  |  |
| 기술 유행만 보고 선택한 것은 아닌가? |  |  |

### 최종 판단

```text
AI 추천을 그대로 따를 수 있는가?
그렇지 않다면 어떤 데이터는 관계형 DB에 두고, 어떤 데이터만 NoSQL을 고려해야 하는가?
```

---

## 17. 활동 14: NoSQL 선택 체크리스트

NoSQL 도입 전 다음 질문에 답하세요.

| 질문 | 답변 |
| --- | --- |
| 데이터 구조는 테이블형, 문서형, 그래프형 중 무엇에 가까운가? |  |
| 가장 자주 실행되는 조회는 무엇인가? |  |
| 강한 정합성과 트랜잭션이 필요한가? |  |
| 데이터가 얼마나 빠르게 증가하는가? |  |
| 쓰기 요청이 많은가, 읽기 요청이 많은가? |  |
| 팀이 해당 DB를 운영할 수 있는가? |  |
| 기존 RDBMS와 JSONB로 충분히 해결 가능한가? |  |
| 장애 시 백업과 복구 전략이 있는가? |  |

---

## 18. 제출 양식

아래 형식을 그대로 복사해서 제출 파일에 사용할 수 있습니다.

```markdown
# Chapter 12 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. 관계형 DB와 NoSQL 비교

[활동 1 작성]

## 3. NoSQL 유형별 특징

[활동 2 작성]

## 4. JSONB 문서형 데이터 실습

[활동 3~9 작성]

## 5. Key-Value 개념 실습

[활동 10 작성]

## 6. 데이터 유형별 저장 방식 선택

[활동 11~12 작성]

## 7. AI 추천 결과 검토

[활동 13 작성]

## 8. NoSQL 선택 체크리스트

[활동 14 작성]

## 9. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 19. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| NoSQL 기본 개념 이해 | 20 | RDBMS와 NoSQL 차이, 유형별 특징을 설명했는가 |
| JSONB 실습 수행 | 25 | JSONB 필드, 중첩 객체, 배열, 포함 조건, 수정, 인덱스 개념을 해석했는가 |
| Key-Value 개념 이해 | 15 | 키 기반 조회의 장점과 한계를 설명했는가 |
| 저장 방식 선택 판단 | 25 | 데이터 구조, 조회 패턴, 정합성, 운영 난이도를 기준으로 선택했는가 |
| AI 추천 검토 및 제출 형식 | 15 | AI 추천을 비판적으로 검토하고 형식에 맞게 제출했는가 |

---

## 20. 피드백 코멘트 예시

### 우수한 경우

```text
관계형 DB와 NoSQL의 차이를 단순 비교가 아니라 데이터 구조와 조회 패턴 중심으로 설명했습니다.
JSONB 실습 결과를 정확히 해석했고, 주문/결제 데이터는 관계형 DB에 두어야 한다는 정합성 관점도 잘 반영했습니다.
AI의 “모든 데이터를 Document DB에 저장하라”는 추천을 비판적으로 검토한 점이 우수합니다.
```

### 보완이 필요한 경우

```text
NoSQL 유형별 특징은 정리했지만 실제 데이터에 어떤 저장 방식이 적합한지 판단 근거가 부족합니다.
JSONB 조회 결과를 단순히 복사하기보다 각 연산자의 의미를 설명해 주세요.
AI 추천 결과 검토에서 정합성, 트랜잭션, 운영 난이도 관점을 추가로 반영하면 좋겠습니다.
```

---

## 21. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. RDBMS와 NoSQL 비교 설명: 20분
2. NoSQL 유형별 사용 사례 토론: 25분
3. JSONB 문서형 데이터 실습: 35분
4. Key-Value 개념 시뮬레이션: 20분
5. 저장 방식 선택표 작성: 30분
6. AI 추천 결과 검토 활동: 30분
7. 제출 양식 작성 및 공유: 20분
```

초급자에게는 NoSQL 제품명을 많이 외우게 하기보다, 어떤 데이터에 어떤 저장 방식이 적합한지 판단하게 하는 데 초점을 둡니다.

---

## 22. 핵심 정리

이 활동의 핵심은 데이터베이스 선택 기준을 익히는 것입니다.

```text
NoSQL은 관계형 DB를 무조건 대체하는 기술이 아니다.
Key-Value DB는 키 기반 빠른 조회에 적합하다.
Document DB는 유연한 문서 구조에 적합하다.
Column-Family DB는 대규모 로그와 이벤트 데이터에 적합할 수 있다.
Graph DB는 관계 탐색과 추천 문제에 적합할 수 있다.
정합성이 중요한 데이터는 관계형 DB가 더 적합할 수 있다.
PostgreSQL JSONB도 문서형 데이터의 일부 요구를 해결할 수 있다.
AI가 추천한 DB 선택 결과도 사람이 검토해야 한다.
```
