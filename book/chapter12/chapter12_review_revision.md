# Chapter 12 전체 점검·반영 기록

## Chapter

```text
Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기
```

## 전체 점검 범위

Chapter 12를 다음 흐름으로 다시 대조하고 실제 PostgreSQL 16에서 실행 검증했습니다.

```text
Chapter 07·08 canonical source
→ nosql_lab 격리
→ 문서·캐시·저장소 선택 구조 생성
→ 원본 연계 Seed
→ JSONB 조회·낙관적 잠금
→ Seed TTL·현재 TTL 구분
→ 저장소 후보·결정 상태 검토
→ JSONB 인덱스 후보 생성
→ 07 전체 자동 판정
→ 파생 데이터 drift 탐지
→ protected project fingerprint 불변 확인
→ reset 격리·원자성 확인
```

점검 대상은 본문·구성안·워크북, Chapter 12 SQL 전체, 코드 README, Mermaid/SVG 8쌍, 이론·실습 발표자료 각 20개 절, 발표자 스크립트·내비게이션·TTS, 전용 GitHub Actions입니다.

---

## 1. Chapter 07·08 시작 기준 강화

기존 `01_nosql_lab_schema.sql`은 `course_project`의 행 수 `3/2/3/5`만 확인했습니다. 최종판은 다음 canonical state 전체를 확인한 뒤에만 `nosql_lab`을 만듭니다.

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
recorded_amount = NUMERIC(12,0)
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
uq_course_enrollments_active 존재
활성 신청 중복 = 0
```

잘못된 DB와 읽기 전용 연결도 생성 전에 차단합니다.

자동 검증에서는 `1005.recorded_amount`를 `120001`로 의도적으로 바꾼 뒤 01이 실패하는지 확인하고, `120000`으로 복원한 뒤 Chapter 08 prerequisite gate가 다시 통과하는지 검증했습니다.

---

## 2. 기록 금액 의미 통일

본문 AI 프롬프트와 Seed 의사결정 근거에 남아 있던 이전 금액 열 이름을 제거했습니다.

최종 의미:

```text
course_project.enrollments.recorded_amount
타입 = NUMERIC(12,0)
의미 = 신청 시점에 신청 행에 기록한 금액
결제 승인액 아님
환불 반영 순액 아님
회계 매출 아님
별도 결제·환불 원장은 현재 범위 밖
```

본문·구성안·워크북·실습 발표자료·코드 README·이미지 README까지 같은 기준으로 맞췄습니다.

---

## 3. `nosql_lab` 구조 자동 판정

`01_nosql_lab_schema.sql`은 하나의 트랜잭션에서 세 테이블을 만들고 COMMIT 전에 구조를 자동 판정합니다.

```text
course_documents
key_value_cache_examples
storage_choice_cases

테이블 = 3
명시 제약조건 = 25
NOT NULL = 26
```

성공 메시지:

```text
Chapter 12 nosql lab schema validation passed
```

---

## 4. Seed 검증 강화

`02_nosql_lab_seed.sql`은 다음을 하나의 트랜잭션에서 입력합니다.

```text
course_documents = 3
key_value_cache_examples = 4
storage_choice_cases = 6
```

COMMIT 전 자동 판정 범위:

```text
301~303 원본 강의 제목·level 일치
instructor_snapshot ID·name·specialty·copied_at 대조
metadata/tags/options/boolean 구조
문서 버전 = 1
Seed 캐시 = 4 / 유효 3 / 만료 1 / 무만료 1
cache_key 정확한 4종
인기 강의 course_ids = 301/302/303
system_role 6종
결정 상태 = adopted 1 / poc_planned 2 / candidate 2 / hold 1 / rejected 0
필수 의사결정 근거 공백 = 0
PostgreSQL Source of Truth 사례에 recorded_amount 의미 포함
```

성공 메시지:

```text
Chapter 12 nosql lab seed validation passed
```

---

## 5. 문서형 데이터 경계 유지

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

모든 문서에서 안정적으로 중요하고 자주 검색·검증하는 `level`은 일반 컬럼에 두고, 문서마다 달라질 수 있는 태그·옵션·표시용 스냅샷만 JSONB에 둡니다.

`source_course_id`는 원본 대조용 논리적 식별자입니다. `nosql_lab`의 단독 이동성을 유지하기 위해 `course_project`로 물리적 FK를 만들지 않고 07 검증에서 원본과 대조합니다.

---

## 6. instructor_snapshot NULL 누락 검증 보완

기존 검증은 `<>` 비교에 의존해 JSON 경로가 누락되어 `NULL`이 되면 불일치를 놓칠 수 있었습니다.

최종 `07_nosql_lab_validation.sql`은 다음을 `IS DISTINCT FROM`으로 비교합니다.

```text
source_instructor_id
name
specialty
copied_at 존재
```

따라서 값이 다른 경우뿐 아니라 필드 자체가 누락된 경우도 실패합니다.

---

## 7. JSONB 낙관적 잠금 실검증

`03_document_jsonb_queries.sql`은 COURSE-301 기준을 먼저 확인합니다.

```text
certificate = true
document_version = 1
```

트랜잭션 내부 변경:

```text
WHERE course_code = COURSE-301
  AND document_version = 1
  AND options가 object

변경 후
certificate = false
document_version = 2
```

영향 행 수가 1인지와 변경 결과를 자동 판정한 뒤 `ROLLBACK`합니다.

ROLLBACK 후 자동 판정:

```text
certificate = true
document_version = 1
course_documents = 3
```

전용 Actions에서는 `document_version = 999`인 stale update가 0행이어야 하고 기준 상태를 변경하지 않는지도 별도로 확인했습니다.

---

## 8. 재현 가능한 TTL 기준

시간에 따라 달라지는 현재 상태를 고정 정답으로 사용하지 않습니다.

```text
Seed 기준
expired_at IS NULL OR expired_at > created_at
→ 전체 4 / 유효 3 / 만료 1 / 무만료 1

현재 기준
expired_at IS NULL OR expired_at > CURRENT_TIMESTAMP
→ 실행 시각에 따라 변함
```

PostgreSQL 테이블은 실제 Key-Value 제품의 자동 TTL 삭제, eviction, 메모리 저장, 복제·샤딩을 구현하지 않는다고 계속 명시합니다.

---

## 9. 저장소 선택 기록을 의사결정 자료로 유지

`storage_choice_cases`는 제품 추천 정답표가 아닙니다.

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

현재 결정 분포:

```text
adopted = 1
poc_planned = 2
candidate = 2
hold = 1
rejected = 0
```

PostgreSQL RDBMS Source of Truth만 `adopted`이고, Key-Value·Document/JSONB·Column-Family·Graph는 요구와 PoC 상태에 따라 후보·계획·보류로 남깁니다.

---

## 10. Column-Family·Graph·CAP 설명 범위

- partition key와 clustering key는 Cassandra 계열 중심의 개념 예시로 한정했습니다.
- 제품마다 키 구조·정렬·트랜잭션·인덱스 범위가 다르므로 공식 문서와 PoC 확인을 요구합니다.
- 관계가 있다는 이유만으로 Graph DB를 선택하지 않고 반복되는 다단계 탐색이 핵심인지 확인합니다.
- CAP를 모든 정상 상황에서 단순히 세 속성 중 두 개를 고르는 공식처럼 설명하지 않습니다.

---

## 11. JSONB 인덱스 생성 원자성 강화

`06_jsonb_index_candidates.sql`은 다음 두 인덱스를 하나의 트랜잭션에서 생성합니다.

```text
metadata @> ...
→ 기본 jsonb_ops GIN

metadata #>> '{options,online}' = 'true'
→ 표현식 B-tree
```

두 번째 생성 또는 정의 검증이 실패하면 첫 번째 인덱스까지 함께 취소됩니다.

COMMIT 전 확인:

```text
access method = gin / btree
표현식·정의 일치
indisvalid = true
indisready = true
```

`CREATE INDEX IF NOT EXISTS`는 같은 이름의 기존 인덱스 정의가 올바르다는 증거가 아니므로 사용하지 않습니다.

표본이 3행뿐이므로 `Seq Scan`이 선택되어도 오류로 판단하지 않습니다.

---

## 12. 07 최종 완료 게이트 강화

`07_nosql_lab_validation.sql`은 다음을 자동 판정합니다.

```text
Chapter 07·08 canonical state 전체
nosql_lab = 3 / 4 / 6
제약조건 25 / NOT NULL 26
301~303 원본 강의 매핑
instructor_snapshot 원본 대조
JSONB 핵심 구조·버전·시간
COURSE-301 옵션과 version 1
Seed 캐시 4/3/1 + 무만료 1
정확한 cache_key 4종
인기 강의 course_ids 301/302/303
system_role 6종
결정 상태 분포 1/2/2/1/0
필수 선택 근거 공백 0
GIN·표현식 인덱스 method/definition/valid/ready
```

성공 메시지:

```text
Chapter 12 nosql_lab validation passed
```

전용 Actions에서는 `COURSE-301.title`을 의도적으로 `DRIFT`로 바꾼 후 07이 실패하고, 원래 제목으로 복원하면 다시 통과하는 것도 확인했습니다.

---

## 13. reset 격리·원자성 실검증

`reset_nosql_lab.sql`은 명시적 `BEGIN/COMMIT`을 사용하고 `CASCADE`를 사용하지 않습니다.

자동 경계 테스트:

```text
nosql_lab.keep_me 생성
→ reset 실행
→ DROP SCHEMA 단계 실패
→ 앞에서 DROP한 known table도 모두 ROLLBACK
→ keep_me도 유지
→ keep_me 제거
→ 정상 reset
→ nosql_lab만 제거
```

성공 메시지:

```text
Chapter 12 nosql lab reset passed
```

`course_project` 전체 데이터 fingerprint는 Chapter 12 실행 전·후·reset 후 모두 동일했습니다.

---

## 14. 본문·워크북·발표자료·이미지 동기화

최종 정적 검증:

```text
본문 번호 절 = 24
이론 발표 = 20
실습 발표 = 20
모든 발표 절에 화면 구성·발표 스크립트 존재
navigation 제목 일치
Chapter 12 asset version = 20260809a
shared TTS normalization 사용
script_content_enhancer 연결
Markdown fetch cache = no-store
Mermaid = 8
SVG = 8
stem 1:1 일치
SVG role=img / width=100% / viewBox / title / desc
본문에서 SVG 8개 모두 참조
```

이미지의 실제 시각 렌더링은 수동 검수 대상으로 남깁니다.

---

## 15. 실제 PostgreSQL 16 자동 검증

전용 workflow:

```text
.github/workflows/validate-chapter12.yml
```

성공 실행:

```text
Workflow: Validate Chapter 12
Run: 2
Run ID: 31290291765
Commit: 1cdcaf3543cf36cff31c539ba96d7e2baa09e2e7
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09
```

실제 검증 경로:

```text
wrong DB guard
→ Chapter 07 생성
→ Chapter 08 prerequisite/final gate
→ course_project fingerprint 저장
→ upstream amount drift 실패 확인·복원
→ Chapter 12 01→07
→ compatibility entrypoint
→ exact final state
→ stale document version boundary
→ derived document drift 실패 확인·복원
→ source fingerprint 불변
→ reset unexpected-object rollback
→ 정상 reset
→ source fingerprint 재확인
```

---

## 16. 최종 기준 상태

```text
course_project
3 / 2 / 3 / 5
상태 2 / 1 / 1 / 1
recorded_amount NUMERIC(12,0)
전체 590000
활성 3 / 340000
취소 제외 4 / 440000

nosql_lab
course_documents = 3
key_value_cache_examples = 4
storage_choice_cases = 6
Seed TTL = 4 / 3 / 1
무만료 = 1
COURSE-301 = certificate true / version 1
JSONB 실험 인덱스 = 2, valid/ready
```

---

## 수동 확인으로 남긴 항목

자동 검증이 성공했다고 다음 항목까지 통과했다고 주장하지 않습니다.

1. 브라우저 이론 20장 최종 시각 렌더링
2. 브라우저 실습 20장 최종 시각 렌더링
3. semantic highlight 실제 시각 동작
4. 발표자 스크립트 창 ↔ 장표 실제 동기화 조작
5. TTS 실제 청취·발음
6. 모바일·프로젝터 가독성
7. Mermaid CLI 재생성
8. GitHub SVG 실제 시각 검수
9. Word·PDF·eBook 표·코드·SVG 가독성
10. 최종 28~32페이지 분량 확인
11. MongoDB·Redis·Cassandra·Graph DB 등 별도 제품의 실제 PoC

## 결론

```text
Chapter 12는 NoSQL 제품을 나열하는 장이 아니라,
원본·파생·캐시·문서·이벤트·관계 인덱스를 분리하고
조회·일관성·동기화·복구·PoC 근거로 저장소를 선택하는 장으로 정리되었다.

PostgreSQL 16 실습 경로는 실제 자동 실행으로 검증되었고,
별도 NoSQL 제품 성능·분산 특성은 이 장에서 추측하지 않는다.
```

---

## 17. 2026-08-10 최종 출판 정밀 검수 추가 반영

최종 출판 직전 Chapter 11에서 강화한 실행 안전성 기준과 PostgreSQL·MongoDB·Redis·Cassandra 공식 문서를 다시 대조했습니다.

추가 반영:

```text
Chapter 07 구조 계약 = 명명 제약조건 15 / NOT NULL 열 20
nosql_lab 생성 전 현재 역할 DB CREATE 권한 확인
Key-Value의 핵심을 정확 키 조회로 설명하고 TTL을 선택 정책으로 구분
TTL expiration과 메모리 압박 eviction 구분
Document DB의 원자성·트랜잭션 보장을 제품·배포 구성별 확인으로 명시
MongoDB 단일 문서 원자성 / 다중 문서 트랜잭션 사례를 제품 예시로 한정
Cassandra partition key / clustering column 설명을 CQL 의미에 맞게 정밀화
PostgreSQL jsonb_ops / jsonb_path_ops 지원 연산자 범위 정밀화
PostgreSQL 16 자동 검증 기준 명시
Chapter 11 security_lab 존재를 Chapter 12 시작 조건으로 만들지 않음
작성된 발표자 스크립트의 generic content enhancer 비활성화
```

별도 NoSQL 제품의 성능·분산·장애 특성은 여전히 이 장의 PostgreSQL 실습만으로 검증되었다고 주장하지 않습니다.
