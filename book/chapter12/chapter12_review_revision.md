# Chapter 12 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter12/chapter12.md
book/chapter12/chapter12_activity.md
book/chapter12/chapter12_outline.md
book/chapter12/chapter12_review_revision.md
code/chapter12/01_nosql_lab_schema.sql
code/chapter12/02_nosql_lab_seed.sql
code/chapter12/03_document_jsonb_queries.sql
code/chapter12/04_key_value_cache_queries.sql
code/chapter12/05_storage_choice_review.sql
code/chapter12/06_jsonb_index_candidates.sql
code/chapter12/07_nosql_lab_validation.sql
code/chapter12/reset_nosql_lab.sql
code/chapter12/nosql_jsonb_practice.sql
code/chapter12/README.md
notes/chapter12_review_checklist.md
README.md
```

## 검수 목적

Chapter 12를 NoSQL 유형 소개에 머물지 않고 다음 판단·검증 흐름으로 완성했습니다.

```text
시스템 역할
→ 원본·파생·캐시·이벤트·관계 인덱스 구분
→ 반복 조회·쓰기와 일관성 범위
→ RDBMS·JSONB·NoSQL 후보
→ 동기화·복구·PoC 근거
→ 후보·채택 상태 기록
→ PostgreSQL 실습 전체 자동 판정
```

---

## 1. 시간이 지나면 달라지는 TTL 기준 해결

기존 샘플은 `CURRENT_TIMESTAMP`와 비교해 Seed 직후에만 `4/3/1`을 재현할 수 있었습니다.

최종 기준:

```text
Seed 기준
→ expired_at IS NULL OR expired_at > created_at
→ 전체 4 / 유효 3 / 만료 1

실제 현재 기준
→ expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP
→ 실행 시각에 따라 달라짐
```

고정 기대값과 현재 운영 상태를 분리했습니다.

---

## 2. Chapter 07 원본 식별자와 동기화

문서와 인기 강의 캐시를 다음 원본과 맞췄습니다.

```text
301 → COURSE-301 → 데이터베이스 입문
302 → COURSE-302 → 정규화 실습
303 → COURSE-303 → 파이썬 데이터 분석
```

만료 세션도 존재하지 않는 학생 9999 대신 실제 학생 103을 사용합니다.

`source_course_id`를 논리적 참조로 저장하고 최종 검증 SQL에서 원본 제목·난이도와 대조합니다. `nosql_lab` 단독 이동성을 유지하기 위해 물리적 외부 FK는 만들지 않았습니다.

---

## 3. 존재하지 않는 결제 원본 표현 수정

AI 요청과 선택 사례에서 현재 원본을 다음처럼 수정했습니다.

```text
students
instructors
courses
enrollments
```

`enrollments.paid_amount`는 신청 당시 기록 금액이며 별도 결제·환불 원장은 현재 프로젝트 범위 밖임을 명시했습니다.

---

## 4. 안정된 level을 일반 컬럼으로 이동

기존 구조는 모든 문서에서 필수이고 자주 검증·검색하는 `level`을 JSONB에 두어 본문의 설계 원칙과 충돌했습니다.

최종 구조:

```text
일반 컬럼
- source_course_id
- course_code
- title
- level
- document_version
- created_at
- updated_at

JSONB
- tags
- options
- instructor_snapshot
```

`level`에는 허용값 CHECK를 적용했습니다.

---

## 5. 강사 복사본을 명시적 스냅샷으로 전환

```text
instructor
→ instructor_snapshot
```

포함 정보:

```text
source_instructor_id
name
specialty
copied_at
```

최종 원본은 `course_project.instructors`이며, 변경 이벤트가 누락되면 원본 ID로 대조·재구축해야 함을 본문·워크북·코드에 반영했습니다.

---

## 6. 생성·Seed·초기화 안전성 강화

`01_nosql_lab_schema.sql` 보호 조건:

```text
현재 DB = ai_database_book
course_project = 3/2/3/5
nosql_lab 미존재
```

스키마와 테이블은 하나의 트랜잭션에서 생성합니다.

`02_nosql_lab_seed.sql`은 세 테이블 존재·빈 상태와 Chapter 07 원본 ID를 검사한 뒤 문서·캐시·선택 사례를 하나의 트랜잭션에서 입력하고 COMMIT 전 자동 판정합니다.

`reset_nosql_lab.sql`은 잘못된 DB에서 삭제를 차단합니다.

모든 SQL에 다음 형식을 통일했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

---

## 7. Key-Value 실습 범위 보완

```text
cache_value
→ JSONB 전체 값 허용

expired_at NULL
→ 만료 정책 없음
```

자동 TTL 삭제, 메모리 저장, eviction, 복제, 샤딩과 실제 장애 동작은 구현하지 않는다고 명시했습니다.

---

## 8. document_version을 낙관적 잠금에 사용

기존 수정 SQL은 버전을 증가시키기만 했습니다.

최종 조건:

```sql
WHERE course_code = 'COURSE-301'
  AND document_version = 1
  AND jsonb_typeof(metadata -> 'options') = 'object'
```

영향 행 수가 1이 아니면 예외를 발생시킵니다. `jsonb_set`의 중간 경로 전제조건과 변경 결과 검증을 포함하고 마지막에 ROLLBACK해 기준값을 유지합니다.

```text
certificate=true
document_version=1
```

---

## 9. JSONB 검증 책임 분리

| 규칙 | DB | 애플리케이션·검증 SQL |
| --- | --- | --- |
| metadata 객체 | CHECK | 재확인 |
| course_code·title·level | 컬럼·CHECK | 보조 |
| tags 배열 | 선택 | 주 검증 |
| options 객체·boolean | 선택 | 주 검증 |
| instructor_snapshot 원본 대조 | 미적용 | 주 검증 |
| 버전 충돌 | 조건부 UPDATE | 재시도 |
| 문서 마이그레이션 | 제한적 | 주 책임 |

---

## 10. 인덱스 파일 분리와 정의 검증

신규 파일:

```text
code/chapter12/06_jsonb_index_candidates.sql
```

생성 후보:

```text
metadata @> ...
→ 기본 jsonb_ops GIN

metadata #>> '{options,online}' = 'true'
→ 표현식 B-tree
```

`CREATE INDEX IF NOT EXISTS`는 기존 정의의 동일성을 보장하지 않으므로 제거했습니다. 파일은 후보 인덱스 미존재를 확인한 뒤 생성하고 실제 정의를 조회합니다.

`jsonb_ops`와 `jsonb_path_ops`의 연산 범위 차이도 본문·README에 반영했습니다.

---

## 11. 저장소 후보와 결정 상태 구분

`storage_choice_cases`에 다음을 추가했습니다.

```text
recovery_strategy
poc_success_criteria
decision_status
reviewed_at
```

결정 상태:

```text
candidate
poc_planned
hold
adopted
rejected
```

현재 PostgreSQL 원본 사례만 `adopted`이며 나머지는 후보·PoC·보류 상태입니다.

의사결정 근거 필드 전체에 공백 문자열 방지 CHECK를 적용했습니다.

---

## 12. Column-Family 용어 범위 명확화

partition key와 clustering key 설명은 Cassandra 계열 중심의 개념 예시임을 명시했습니다. 제품마다 키 구조·정렬·보조 인덱스·트랜잭션 범위가 다르므로 공식 문서와 PoC로 확인합니다.

---

## 13. 전체 자동 검증 파일 추가

신규 파일:

```text
code/chapter12/07_nosql_lab_validation.sql
```

자동 판정:

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
필수 선택 근거 공백 0건
adopted 사례 1건
GIN·표현식 인덱스 정의
```

통과 메시지:

```text
Chapter 12 nosql_lab validation passed
```

---

## 14. 본문·워크북·코드 동기화

다음을 모두 같은 기준으로 맞췄습니다.

```text
파일 순서 01→07
원본 테이블·ID·제목
Seed TTL과 현재 TTL
안정 컬럼·JSONB 경계
강사 스냅샷 의미
낙관적 잠금
인덱스 후보와 정의 검증
후보·채택 상태
최종 자동 판정
권장 해설
```

기존 SVG 8종은 일반 RDBMS·NoSQL 역할, 네 유형, JSONB와 AI 검토 메시지와 호환되어 유지했습니다.

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| TTL 재현성 | 완료 |
| Chapter 07 원본 매핑 | 완료 |
| 결제 원본 표현 수정 | 완료 |
| level 일반 컬럼 | 완료 |
| instructor_snapshot | 완료 |
| 생성·Seed·초기화 보호 | 완료 |
| Key-Value NULL TTL·값 범위 | 완료 |
| document_version 낙관적 잠금 | 완료 |
| jsonb_set 경로 검증 | 완료 |
| 인덱스 파일·정의 검증 | 완료 |
| 선택 근거 공백 CHECK | 완료 |
| decision_status | 완료 |
| Cassandra 계열 범위 | 완료 |
| 전체 자동 검증 | 완료 |
| 워크북 권장 해설 | 완료 |

## 결론

```text
Chapter 12는 NoSQL 유형을 소개하는 장에서,
원본·조회·시간 기준·동기화·복구·결정 상태를 실행 증거로 검증하는
저장소 선택 장으로 최종 보완되었다.
```

실제 PostgreSQL에서 `01→07` 전체 순차 실행과 별도 NoSQL 제품 PoC, GitHub·Word·PDF·eBook 렌더링은 별도 제작 단계에서 확인합니다.
