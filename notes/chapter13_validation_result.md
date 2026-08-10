# Chapter 13 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 13
Run: 4
Run ID: 31291382770
Commit: c0d1ab67e050464ea436a30ddb4802dcea920123
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

이 Run은 Chapter 13의 최종 리뷰 기록과 체크리스트까지 포함된 상태를 다시 검증한 definitive run입니다.

---

## 1. 검증 범위

```text
book/chapter13
code/chapter13
images/chapter13
presentation/chapter13
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js
notes/chapter13_review_checklist.md
.github/workflows/validate-chapter13.yml
```

자동 검증 흐름:

```text
정적 source alignment
→ PostgreSQL 16
→ 잘못된 DB 보호
→ Chapter 07 canonical state 생성
→ Chapter 08 prerequisite/final gate
→ Chapter 12 nosql_lab 01→07 실제 실행
→ protected fingerprint·sentinel 저장
→ upstream recorded_amount drift 실패 확인·복원
→ Chapter 13 01→08 전체 실행
→ exact final state
→ business-state drift 실패 확인·복원
→ protected schema fingerprint 불변 확인
→ reset 예상 밖 객체 경계
→ 정상 reset
→ protected state 최종 재확인
```

---

## 2. 정적 정합성

다음이 모두 통과했습니다.

```text
본문 번호 절 = 28
이론 발표 = 20
실습 발표 = 20
각 발표 절 화면 구성·발표 스크립트 존재
navigation 제목 1:1 일치
recorded_amount 최신 기준
NUMERIC(12,0)
Chapter 07·08 canonical 590000 / 340000 / 440000
Chapter 13 lab 470000 / 470000
P13-T01~P13-T30
expected_failure 24 / expected_success 6
asset version = 20260809a
JavaScript 문법
shared PresentationTTS normalization
script_content_enhancer 연결
Markdown fetch cache=no-store
Mermaid 8 / SVG 8
Mermaid/SVG stem 일치
SVG role=img / width=100% / viewBox / title / desc
본문에서 SVG 8개 모두 참조
reset CASCADE 미사용
Chapter 13 SQL이 protected schema를 변경하지 않음
```

이전 격리 실습 금액 컬럼 이름은 학습·출판 자료에서 제거했고, `05`·`08`의 **이전 컬럼 존재 차단 negative schema check**에만 남겨 두었습니다.

---

## 3. Chapter 07·08 시작 기준

실제 확인:

```text
students = 3
instructors = 2
courses = 3
enrollments = 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
recorded_amount = NUMERIC(12,0)
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
활성 신청 부분 고유 인덱스 존재
활성 신청 중복 = 0
```

의도적 drift:

```text
1005.recorded_amount 120000 → 120001
→ Chapter 13 01 실패 확인
→ 120000 복원
→ Chapter 08 prerequisite gate 재통과
```

---

## 4. Chapter 12 handoff와 격리

Chapter 13 검증 전에 Chapter 12의 다음 실제 경로를 실행했습니다.

```text
01_nosql_lab_schema.sql
→ 02_nosql_lab_seed.sql
→ 03_document_jsonb_queries.sql
→ 04_key_value_cache_queries.sql
→ 05_storage_choice_review.sql
→ 06_jsonb_index_candidates.sql
→ 07_nosql_lab_validation.sql
```

그 뒤 `course_project`와 `nosql_lab` 데이터 fingerprint를 저장하고, `transaction_lab`, `performance_lab`, `security_lab`, `nosql_lab`에 sentinel을 배치했습니다.

Chapter 13 전체 실행과 reset 뒤에도 모두 동일했습니다.

---

## 5. Chapter 13 canonical state

최종 정확 상태:

```text
bad_enrollments = 3
students = 3
instructors = 2
courses = 3
enrollments = 4
payments = 4
recorded_amount 합계 = 470000
payment amount 합계 = 470000

수강 상태
완료 = 2
신청 = 1
취소 = 1
수강중 = 0

결제 상태
결제완료 = 2
결제대기 = 1
환불 = 1
결제실패 = 0
```

workflow exact-state 문자열:

```text
3:3:2:3:4:4:470000:470000:2:1:1:0:2:1:1:0
```

---

## 6. 구조·메타데이터

실제 통과:

```text
ai_review_lab 정확한 테이블 = 6
좋은 설계 constraints = 29
FK = 4
IDENTITY = 6
money columns = 3
price / recorded_amount / payment amount = NUMERIC(12,0) NOT NULL
활성 신청 부분 고유 인덱스 존재·정의 확인
원시 카드정보·비밀 전용 컬럼명 = 0
```

`payments`는 `course_project` 확장이 아니라 `ai_review_lab`의 가상 설계 리뷰 시나리오입니다.

---

## 7. 업무 정합성

실제 통과:

```text
정상 JOIN = 4
이메일 중복 = 0
필수 문자열 공백 = 0
recorded/payment amount 불일치 = 0
결제·환불 시각 위반 = 0
고아 관계 = 0
활성 신청 중복 = 0
샘플 상태 조합 위반 = 0
현재 가격과 recorded_amount 차이 = 1002 한 행
```

의도적 business drift:

```text
payment 9001
결제완료 / paid_at 존재
→ 결제대기 / paid_at NULL
```

이 값은 테이블 CHECK 자체는 만족하지만 수강 상태와의 업무 규칙이 어긋납니다. `06_business_validation.sql`이 이를 실패로 탐지하는지 확인하고 원상 복구한 뒤 재통과했습니다.

---

## 8. 반례·경계값

`07_negative_tests.sql` 실제 결과:

```text
expected_failure = 24
expected_success = 6
total = 30
passed = 30
unexpected = 0
```

추가 경계:

```text
P13-T23 참조 중인 instructor 삭제 → FK 실패
P13-T24 참조 중인 enrollment 삭제 → FK 실패
P13-T30 대소문자 변형 student email → 현재 정확 문자열 정책에서 성공
```

최종 `08`은 같은 PostgreSQL 세션의 `pg_temp.negative_test_results`를 요구하고 30/30 증거를 다시 판정했습니다.

통과 메시지:

```text
Chapter 13 AI review lab validation passed: tests 30/30
```

---

## 9. IDENTITY

다음 모든 시퀀스의 다음 값이 현재 최대 ID보다 큰지 실제 확인했습니다.

```text
bad_enrollments
students
instructors
courses
enrollments
payments
```

---

## 10. reset 원자성·격리

실제 테스트:

```text
CREATE TABLE ai_review_lab.keep_me(...)
→ reset_ai_review_lab.sql 실행
→ DROP SCHEMA 실패
→ 전체 트랜잭션 ROLLBACK
→ keep_me 존재
→ bad_enrollments 존재
→ students 존재
→ payments 존재

keep_me 삭제
→ reset 재실행
→ 성공
→ ai_review_lab 미존재
```

reset은 `CASCADE`를 사용하지 않습니다.

reset 후에도 `course_project`, `nosql_lab`, `transaction_lab`, `performance_lab`, `security_lab` 보호 상태는 변하지 않았습니다.

---

## 11. 발표·이미지 검증

정적 자동 검증 통과:

```text
이론 20장
실습 20장
screen + script 전 장표 존재
navigation 제목 1:1
asset version 20260809a
shared TTS
script enhancer
Mermaid/SVG 8쌍
SVG accessibility·responsive attributes
본문 SVG 8개 참조
```

---

## 12. 남은 수동 확인

자동 검증으로 통과했다고 처리하지 않는 항목:

```text
1. 이론 발표 20장 브라우저 최종 시각 확인
2. 실습 발표 20장 브라우저 최종 시각 확인
3. semantic/step highlight 실제 동작
4. 발표자 스크립트 창 ↔ 장표 실제 동기화
5. TTS 실제 청취·발음 확인
6. 모바일·프로젝터 가독성
7. Mermaid CLI 재생성 여부
8. GitHub SVG 실제 시각 렌더링
9. Word·PDF·eBook 최종 렌더링
10. 최종 페이지 수
11. 실제 조직의 개인정보·payment_reference 보호 정책
12. 운영 DB migration·lock·backup·rollback 검토
```

---

## 결론

```text
Chapter 13은 AI가 만든 설계를 설명으로 신뢰하는 장이 아니라,
요구사항 추적 → 격리 변경 → 실제 PostgreSQL 구조 → 정상·실패·경계 실행 →
업무 drift → diff → protected state → reset까지 실행 증거로 확인하고
사람이 승인하는 장으로 최종 보완되었다.
```


---

## 13. 2026-08-10 최종 출판 재검증

최종 출판 보완 뒤 PostgreSQL 16에서 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 13 definitive final validation once
Run: 1
Run ID: 31393533155
Validation workflow commit: acb30219313559cd45d71dad07e584518d691bdb
Content commit: 114c681775fffc583848c28b65d026a8cf14e485
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 13 본문 번호 절 = 28
워크북 expected_failure 24 / expected_success 6 / total 30 정합성
이론 발표·이미지 README의 이전 22·17 기준 제거
ChatGPT Chat / Work / Codex 역할 설명 최신화
작성된 발표자 스크립트 generic enhancer 비활성화
잘못된 데이터베이스에서 01 실행 차단
Chapter 07 canonical source와 Chapter 08 gate 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
CREATE 권한 없는 역할에서 01이 DDL 전에 실패
권한 실패 뒤 ai_review_lab 미생성 확인
Chapter 12 handoff 상태 생성과 보호 fingerprint 저장
1005 recorded_amount drift 주입 시 01 실패 확인·복원
Chapter 13 01→08 전체 실행 성공
negative/boundary tests = 30/30
expected failure = 24 / expected success = 6 / unexpected = 0
exact state = 3/3/2/3/4/4, recorded/payment amount = 470000/470000
좋은 설계 constraints = 29 / FK = 4
payment business drift 탐지·복원
course_project·nosql_lab fingerprint 실행 전후 동일
transaction_lab·performance_lab·security_lab·nosql_lab sentinel 유지
예상 밖 ai_review_lab.keep_me 존재 시 reset 전체 ROLLBACK
정상 reset 성공 후 ai_review_lab만 제거
reset 뒤 course_project·nosql_lab fingerprint 동일
reset 뒤 Chapter 08 prerequisite/final gate 재통과
```

최종 통과 메시지:

```text
Chapter 13 AI review lab validation passed: tests 30/30
Chapter 13 ai_review_lab reset passed
Chapter 13 definitive PostgreSQL 16 validation passed
```

별도 실제 운영 DB 변경, 실제 조직의 개인정보·결제 참조값 분류, 브라우저·TTS·PDF/eBook 시각 렌더링은 이번 자동 검증의 통과 범위로 주장하지 않습니다.
