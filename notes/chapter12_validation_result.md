# Chapter 12 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 12
Run: 4
Run ID: 31290410522
Commit: 55284d7a8583e3682a15597746ac3d343d7601ee
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

이 Run은 Chapter 12의 최종 리뷰 기록과 체크리스트가 포함된 상태를 다시 검증한 실행입니다.

---

## 1. 검증 범위

```text
book/chapter12
code/chapter12
images/chapter12
presentation/chapter12
shared TTS / script enhancer
notes/chapter12_review_checklist.md
.github/workflows/validate-chapter12.yml
```

자동 검증 흐름:

```text
정적 정합성
→ PostgreSQL 16 시작
→ 잘못된 DB 보호
→ Chapter 07 canonical state 생성
→ Chapter 08 prerequisite/final gate
→ course_project fingerprint 저장
→ upstream recorded_amount drift 실패 확인
→ Chapter 12 01→07 전체 실행
→ compatibility entrypoint
→ Chapter 12 exact final state
→ stale document version 경계
→ 파생 문서 drift 실패 확인·복원
→ course_project fingerprint 재확인
→ reset 예상 밖 객체 경계
→ 정상 reset
→ course_project fingerprint 최종 재확인
```

---

## 2. 정적 정합성

다음 항목이 모두 통과했습니다.

```text
본문 번호 절 = 24
이론 발표 = 20
실습 발표 = 20
각 발표 절의 화면 구성·발표 스크립트 존재
navigation 제목 1:1 일치
recorded_amount / NUMERIC(12,0) 최신 기준
590000 / 340000 / 440000 canonical 값
Chapter 12 asset version = 20260809a
JavaScript 문법
shared PresentationTTS normalization
script_content_enhancer 연결
Markdown fetch cache=no-store
Mermaid 8개 / SVG 8개
Mermaid/SVG stem 일치
SVG role=img / width=100% / viewBox / title / desc
본문에서 SVG 8개 모두 참조
reset CASCADE 미사용
Chapter 12 SQL이 course_project·transaction_lab·performance_lab·security_lab을 변경하지 않음
```

이전 금액 열 이름은 학습·출판 자료에서 제거했고, 01·07의 **이전 열 존재를 차단하는 negative schema check**에만 남겨 두었습니다.

---

## 3. Chapter 07·08 시작 기준

실제 PostgreSQL 16에서 다음 상태를 다시 만들고 확인했습니다.

```text
students = 3
instructors = 2
courses = 3
enrollments = 5

상태:
신청 = 2
수강중 = 1
완료 = 1
취소 = 1

recorded_amount = NUMERIC(12,0)
전체 = 590000
활성 = 3 / 340000
취소 제외 = 4 / 440000

1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

`course_project` 전체를 정렬 JSON으로 직렬화한 fingerprint를 Chapter 12 실행 전에 저장했습니다.

---

## 4. 잘못된 DB 보호

`01_nosql_lab_schema.sql`을 `postgres` 데이터베이스에서 실행해 실패해야 하는 경로를 확인했습니다.

검증 결과:

```text
실패 = 기대대로 발생
오류 메시지에 ai_database_book 포함
postgres DB에 nosql_lab 생성 안 됨
```

---

## 5. upstream drift 탐지

의도적으로 다음 변경을 적용했습니다.

```text
course_project.enrollments
id = 1005
recorded_amount: 120000 → 120001
```

결과:

```text
01_nosql_lab_schema.sql = 실패
nosql_lab = 생성되지 않음
```

다시 `120000`으로 복원한 뒤 Chapter 08 prerequisite gate가 통과했습니다.

따라서 Chapter 12는 단순 행 수가 아니라 앞 장의 canonical 의미 상태에서 시작합니다.

---

## 6. 01 구조 생성

실제 PostgreSQL 16에서 확인:

```text
nosql_lab base table = 3
course_documents 존재
key_value_cache_examples 존재
storage_choice_cases 존재
명시 제약조건 = 25
NOT NULL = 26
```

성공 메시지:

```text
Chapter 12 nosql lab schema validation passed
```

---

## 7. 02 Seed

실제 기준 상태:

```text
course_documents = 3
key_value_cache_examples = 4
storage_choice_cases = 6
```

자동 판정 통과:

```text
301~303 원본 강의 매핑
instructor_snapshot 원본 ID·이름·전문분야·copied_at
JSONB tags/options/boolean 구조
모든 문서 version = 1
Seed TTL = 전체4 / 유효3 / 만료1 / 무만료1
정확한 cache_key 4종
인기 강의 course_ids = 301/302/303
system_role = 6종
결정 상태 = adopted1 / poc_planned2 / candidate2 / hold1 / rejected0
필수 의사결정 근거 공백 = 0
Source of Truth reason에 recorded_amount 의미 포함
```

성공 메시지:

```text
Chapter 12 nosql lab seed validation passed
```

---

## 8. 03 JSONB·낙관적 잠금

COURSE-301 기준:

```text
변경 전 = certificate true / version 1
트랜잭션 내부 = certificate false / version 2
ROLLBACK 후 = certificate true / version 1
```

영향 행 수 1과 내부 변경 상태를 자동 판정하고, ROLLBACK 후 기준 상태도 다시 판정했습니다.

성공 메시지:

```text
Chapter 12 document JSONB practice passed
```

별도 경계 테스트에서는 `document_version = 999` 조건으로 UPDATE했을 때 0행이어야 하고 기준 데이터가 그대로인지 확인했습니다. 통과했습니다.

---

## 9. Key-Value 기준

고정 자동 검증은 현재 시각이 아니라 Seed 시각 기준을 사용합니다.

```text
전체 = 4
Seed 유효 = 3
Seed 만료 = 1
무만료 = 1
```

`CURRENT_TIMESTAMP`와 비교한 실제 현재 유효 수는 시간 의존 값이므로 고정 정답으로 사용하지 않습니다.

---

## 10. 저장소 선택 상태

실제 검증 분포:

```text
전체 사례 = 6
system_role = 6종
source_of_truth = 1
adopted = 1
poc_planned = 2
candidate = 2
hold = 1
rejected = 0
```

PostgreSQL Source of Truth만 채택 상태이고 나머지는 요구사항·PoC 상태에 따라 후보·계획·보류로 유지합니다.

---

## 11. 06 JSONB 인덱스

하나의 트랜잭션에서 생성·검증했습니다.

```text
idx_nosql_course_documents_metadata_gin
→ GIN / metadata

idx_nosql_course_documents_online
→ B-tree / metadata #>> '{options,online}'
```

두 인덱스 모두:

```text
indisvalid = true
indisready = true
```

성공 메시지:

```text
Chapter 12 JSONB index candidate validation passed
```

표본 3행에서 Seq Scan이 선택될 수 있다는 설명을 유지하며 성능 향상을 과장하지 않습니다.

---

## 12. 07 최종 게이트

다음 전체 기준이 실제 PostgreSQL 16에서 통과했습니다.

```text
Chapter 07·08 canonical source
nosql_lab = 3 / 4 / 6
constraints = 25
NOT NULL = 26
강의 원본 매핑
instructor_snapshot 원본 대조
JSONB 구조·버전·시간
COURSE-301 true/version1
cache 4/3/1 + 무만료1
cache_key 정확한 4종
인기 강의 IDs 301/302/303
결정 상태 분포
필수 근거 공백 0
GIN·표현식 index method/definition/valid/ready
```

성공 메시지:

```text
Chapter 12 nosql_lab validation passed
```

---

## 13. 파생 문서 drift 경계

의도적으로:

```text
COURSE-301 title
데이터베이스 입문 → DRIFT
```

으로 변경했습니다.

결과:

```text
07 = 실패
원본 불일치 탐지
```

다시 원래 제목으로 복원한 뒤 07이 재통과했습니다.

---

## 14. 원본 불변성

Chapter 12 canonical path 후 `course_project` fingerprint를 다시 계산해 실행 전 값과 비교했습니다.

```text
차이 없음
```

reset 후에도 다시 비교했습니다.

```text
차이 없음
```

따라서 Chapter 12는 `course_project`를 읽어 파생 실습 데이터를 만들지만 원본을 변경하지 않습니다.

---

## 15. reset 원자성

의도적으로 예상 밖 객체를 만들었습니다.

```text
nosql_lab.keep_me
```

그 상태에서 `reset_nosql_lab.sql` 실행:

```text
DROP SCHEMA 단계 실패
course_documents 유지
key_value_cache_examples 유지
storage_choice_cases 유지
keep_me 유지
```

즉 앞에서 실행된 DROP도 전체 트랜잭션과 함께 ROLLBACK되었습니다.

`keep_me`를 제거한 뒤 정상 reset:

```text
nosql_lab 삭제
course_project 불변
```

성공 메시지:

```text
Chapter 12 nosql lab reset passed
```

---

## 16. 주요 수정 사항

이번 전체 점검에서 확정한 핵심 수정:

1. 오래된 금액 열 이름을 `recorded_amount NUMERIC(12,0)`으로 통일
2. 기록 금액을 결제 승인액·환불 순액·회계 매출로 오해하지 않도록 의미 고정
3. 01 시작 게이트를 행 수에서 전체 canonical state로 강화
4. 01 구조 생성 후 제약조건·NOT NULL 자동 판정
5. 02 Seed에서 스냅샷·캐시 키·결정 상태 분포 자동 판정
6. instructor_snapshot 누락을 놓칠 수 있는 `<>` 비교를 `IS DISTINCT FROM`으로 보완
7. 03 optimistic update 내부 상태와 ROLLBACK 상태 자동 판정
8. stale document version 0행 경계 실검증
9. 06 인덱스 2개 생성·정의를 하나의 트랜잭션으로 묶음
10. 06/07에서 index valid/ready 상태 확인
11. 07 전체 완료 게이트 강화
12. 파생 문서 drift 실패 경로 실검증
13. reset에 명시적 transaction·성공 메시지 추가
14. 예상 밖 객체가 있을 때 reset 전체 ROLLBACK 실검증
15. 본문·구성안·워크북·실습 발표·README에 590000/340000/440000 기준 통일
16. 발표 asset version `20260809a`로 갱신
17. 본문 AI 프롬프트 중복 문장 정리
18. 전용 `.github/workflows/validate-chapter12.yml` 추가

---

## 17. 자동 검증하지 않은 항목

다음은 수동 제작·출판 단계에서 확인합니다.

```text
브라우저 이론 20장 실제 시각 렌더링
브라우저 실습 20장 실제 시각 렌더링
semantic highlight 실제 동작
발표자 스크립트 창 ↔ 장표 실제 조작 동기화
TTS 실제 청취·발음
모바일·프로젝터 가독성
Mermaid CLI 재생성
GitHub SVG 육안 검수
Word·PDF·eBook 표·코드·SVG 가독성
최종 28~32페이지 분량
별도 MongoDB·Redis·Cassandra·Graph DB 실제 PoC
```

## 결론

```text
Chapter 12 최종 문서·코드 상태는 Validate Chapter 12 Run 4에서 success로 확인되었다.
PostgreSQL 16 JSONB 기반 실습은 실제 실행으로 검증했으며,
별도 NoSQL 제품의 분산·성능 특성은 제품별 PoC 없이 단정하지 않는다.
```
