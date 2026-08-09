# Chapter 13 전체 점검·반영 기록

## Chapter

```text
Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기
```

## 전체 점검 범위

Chapter 13을 본문 설명만이 아니라 다음 전체 흐름으로 다시 점검하고 실제 PostgreSQL 16에서 검증했습니다.

```text
Chapter 07·08 canonical source
→ Chapter 12 nosql_lab handoff
→ ai_review_lab 격리
→ 나쁜 설계 기준선
→ 좋은 구조·Seed
→ 실제 PostgreSQL 메타데이터
→ 업무 정합성
→ 예상 실패 24 + 정상 경계값 6
→ 30/30 실행 증거
→ 최종 08 완료 게이트
→ protected schema fingerprint 불변
→ reset 원자성·격리
→ 사람 승인용 diff·보고서
```

점검 대상:

```text
book/chapter13
code/chapter13
images/chapter13
presentation/chapter13
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js
notes/chapter13_review_checklist.md
.github/workflows/validate-chapter13-navigation.yml
.github/workflows/validate-chapter13.yml
```

---

## 1. 장의 핵심 메시지

Chapter 13의 기준 문장을 다음처럼 유지했습니다.

```text
AI 결과는 정답이 아니라 변경 후보다.
요구사항 추적, 실제 생성 구조, 정상·경계값·실패 테스트와 diff가 확인되어야 승인할 수 있다.
```

따라서 “AI가 자연스러운 SQL을 만들었다”를 완료 기준으로 두지 않고 다음 연결을 확인합니다.

```text
확인된 요구사항
→ 설계 반영 위치
→ 실제 PostgreSQL 객체
→ 정상·경계·실패 실행 결과
→ 업무 정합성
→ 변경 diff
→ 사람 승인
```

---

## 2. ChatGPT·Work·Codex·사람 역할 최신화

역할을 제품의 영구적인 기능 경계가 아니라 안전한 작업 흐름으로 설명했습니다.

현재 공식 안내의 큰 흐름:

```text
Chat  → 빠른 질문·검색·대화형 지원
Work  → 더 길고 여러 단계인 작업과 완성된 산출물
Codex → 코드 작성·디버깅·테스트·명령 실행·저장소 작업
사람  → 정책·데이터·권한·위험·운영 반영의 최종 승인
```

제품 기능과 제공 범위는 바뀔 수 있으므로 교재에서도 최신 공식 안내를 다시 확인하도록 명시했습니다.

---

## 3. Chapter 07·08 canonical source를 강한 시작 게이트로 사용

기존 01은 원본 존재 여부 또는 단순 행 수에 의존할 수 있었습니다. 최종 `01_ai_review_lab_schema.sql`은 다음 상태 전체가 맞을 때만 `ai_review_lab`을 생성합니다.

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

전용 GitHub Actions에서는 `1005.recorded_amount`를 `120001`로 의도적으로 변경한 뒤 01이 실패하는지 확인하고, `120000`으로 복원한 뒤 Chapter 08 prerequisite gate가 다시 통과하는지 실제 검증했습니다.

---

## 4. `recorded_amount` 의미를 Chapter 07·08·12와 통일

Chapter 13 격리 실습에서 사용하던 별도 금액 이름을 제거하고 다음으로 통일했습니다.

```text
course_project.enrollments.recorded_amount
ai_review_lab.enrollments.recorded_amount
타입 = NUMERIC(12,0)
의미 = 신청 시점에 신청 행에 기록한 금액
```

이 금액은 다음과 구분합니다.

```text
courses.price   = 현재 기본 가격
recorded_amount = 신청 시점 기록 금액
payments.amount = ai_review_lab 가상 결제 상태에 기록한 금액
```

1002는 이 차이를 보여 주는 정보용 기준입니다.

```text
현재 강의 가격 = 180000
신청 시점 기록 금액 = 150000
```

가격 차이는 할인·가격 변경일 수 있으므로 자동 오류로 취급하지 않고 정확히 한 행인지 검증합니다.

---

## 5. `payments`는 기존 프로젝트 확장이 아니라 격리 리뷰 시나리오

Chapter 12에서는 현재 `course_project`에 별도 결제·환불 원장이 없다고 확정했습니다. 이 의미가 Chapter 13에서 바뀐 것처럼 읽히지 않도록 경계를 명확히 했습니다.

```text
course_project
→ 기존 원본 유지
→ 결제·환불 원장 추가 안 함

ai_review_lab.payments
→ AI 설계 검토 방법을 연습하기 위한 가상 격리 테이블
→ Chapter 13 실습 범위에서만 사용
```

`payment_reference`도 “참조값이므로 자동으로 비민감”이라고 단정하지 않습니다.

```text
실습에서는 원시 카드번호·CVV 대신 가상 외부 참조값만 사용한다.
실제 시스템의 payment_reference도 조직의 보안·보관 정책에 따라 보호 대상이 될 수 있다.
```

---

## 6. 추적 ID와 확인된 정책

```text
P13-R01~P13-R09  확인된 요구사항
P13-D01~P13-D08  결정·단순화·미확정 정책
P13-T01~P13-T30  예상 실패·정상 경계값
P13-V01~P13-V08  실행·검증 단계
```

핵심 정책:

```text
P13-R01 학생 email 공백 금지·정확 문자열 UNIQUE
P13-R02 강사 email 공백 금지·정확 문자열 UNIQUE
P13-R03 강의→강사 FK
P13-R04 학생·강의 N:M 해소
P13-R05 수강 상태 CHECK
P13-R06 금액 0 이상
P13-R07 격리 결제→수강신청 FK
P13-R08 원시 카드번호·CVV 미저장
P13-R09 신청·수강중 활성 신청 학생·강의당 한 건
```

결정·범위:

```text
P13-D01 완료·취소 뒤 재신청 허용
P13-D02 현재 결제 상태 한 건 단순 모델
P13-D03 삭제 RESTRICT
P13-D04 개인정보 보관 기간은 조직 정책
P13-D05 상태 전이 순서는 별도 정책
P13-D06 전액 결제·전액 환불 샘플, 부분 환불 원장은 범위 밖
P13-D07 이메일은 현재 정확 문자열 비교, 대소문자 정규화는 별도 결정
P13-D08 결제 없는 신청 허용
```

---

## 7. 나쁜 설계 기준선을 실행 가능한 반례로 강화

`02_bad_design_seed.sql`은 단순 샘플 입력을 넘어 나쁜 설계의 문제가 실제로 재현되는지 COMMIT 전에 확인합니다.

```text
행 수 = 3
같은 학생 이메일 반복 = 2행
숫자가 아닌 가격 문자열 = 1행
created_at='yesterday' = 1행
통제되지 않은 payment_status='done' = 1행
통제되지 않은 enrollment_status='finished' = 1행
평문 민감값 형태 반복
```

실제 개인정보·카드번호는 사용하지 않고 `TEST-SENSITIVE-PLAINTEXT-*` 가상값만 사용합니다.

---

## 8. 좋은 구조를 COMMIT 전에 판정

`03_good_design_schema.sql`은 다섯 개 좋은 설계 테이블을 한 트랜잭션에서 생성하고 COMMIT 전에 실제 구조를 검사합니다.

```text
students
instructors
courses
enrollments
payments
```

나쁜 설계 테이블까지 포함한 `ai_review_lab` 전체 기대 테이블은 6개입니다.

좋은 구조 기준:

```text
좋은 설계 제약조건 = 29
좋은 테이블 IDENTITY = 5
FK = 4
price / recorded_amount / payments.amount = NUMERIC(12,0)
활성 신청 부분 고유 인덱스 존재
```

`05`와 최종 `08`에서는 나쁜 설계 IDENTITY까지 포함해 전체 IDENTITY 6개를 확인합니다.

---

## 9. Seed 기준 상태를 금액·상태 분포까지 고정

`04_good_design_seed.sql` 최종 기준:

```text
bad_enrollments = 3
students = 3
instructors = 2
courses = 3
enrollments = 4
payments = 4
정상 JOIN = 4

recorded_amount 합계 = 470000
payment amount 합계 = 470000

수강 상태 = 완료 2 / 신청 1 / 취소 1 / 수강중 0
결제 상태 = 결제완료 2 / 결제대기 1 / 환불 1 / 결제실패 0
```

결제 참조값은 `PAY-REVIEW-TEST-*` 가상값만 허용합니다.

명시적 ID 입력 뒤 다음 IDENTITY 시작값도 조정합니다.

```text
bad_enrollments → 4 이상
students → 104 이상
instructors → 203 이상
courses → 304 이상
enrollments → 1005 이상
payments → 9005 이상
```

---

## 10. 메타데이터를 개수가 아니라 정확한 서명으로 검증

`05_metadata_validation.sql` 기준:

```text
정확한 테이블 집합 6
좋은 설계 제약조건 29
정확한 FK 이름·출발 컬럼·대상 컬럼 4
FK 삭제 규칙 RESTRICT/NO ACTION
IDENTITY id 6
금액 컬럼 3개 NUMERIC(12,0) NOT NULL
활성 신청 부분 고유 인덱스 정의
원시 카드정보·비밀 전용 컬럼명 0
```

신청 시점 금액 컬럼은 `recorded_amount` 하나만 있어야 하며 이전 격리 실습의 오래된 컬럼 이름이 존재하면 실패합니다.

---

## 11. NULL 안전 업무 정합성 검증

`06_business_validation.sql`은 다음 이상이 모두 0행인지 자동 판정합니다.

```text
학생·강사 이메일 중복
필수 문자열 공백
신청 시점 기록 금액·결제 상태 기록 금액 불일치
결제·환불 시각 조합 위반
고아 관계
활성 신청 중복
샘플 수강·결제 상태 조합 위반
```

`LEFT JOIN` 결과의 NULL을 놓치지 않도록 `IS DISTINCT FROM`을 사용합니다.

샘플 상태 조합:

```text
완료 → 결제완료 필수
취소 → 환불 필수
신청 → 결제 없음 허용, 있으면 결제대기
수강중 → 결제 없음 허용, 있으면 결제완료
```

전용 workflow에서는 9001을 제약조건 자체는 만족하는 `결제대기 / paid_at NULL`로 의도적으로 바꾸고 `06`이 업무 상태 불일치를 탐지하는지 실제 확인한 뒤 원상 복구했습니다.

---

## 12. 반례·정상 경계값을 30개로 확대

최종 `07_negative_tests.sql`:

```text
P13-T01~P13-T24 = expected_failure 24개
P13-T25~P13-T30 = expected_success 6개
전체 = 30
passed = 30
unexpected = 0
```

각 실패 테스트는 가능한 경우 다음 실제 진단을 기록합니다.

```text
SQLSTATE
constraint name
table name
column name
오류 detail
```

추가한 경계:

```text
P13-T23 참조 중인 instructor 201 삭제 → FK 실패
P13-T24 참조 중인 enrollment 1001 삭제 → FK 실패
P13-T30 'Kim.review@example.com' → 현재 정확 문자열 정책에서는 성공
```

정상 경계에는 가격 0, 한 글자 문자열, NULL description, 결제 없는 신청, 완료·취소 이력 뒤 재신청, 결제실패 0원·시각 NULL도 포함합니다.

모든 테스트는 하위 트랜잭션에서 자동 롤백되어 기준 행 수를 보존합니다.

---

## 13. 08을 실제 완료 게이트로 강화

`08_ai_review_lab_validation.sql`은 단순 상태 조회가 아니라 다음을 모두 만족해야 최종 통과합니다.

```text
Chapter 07·08 canonical source 유지
Chapter 13 기준 행 수 3/3/2/3/4/4
recorded_amount = 470000
payment amount = 470000
정상 JOIN = 4
정확한 테이블 집합
제약조건 29 / FK 4 / IDENTITY 6
금액 타입 3개
활성 신청 부분 고유 인덱스
필수 문자열·고아·활성 중복 = 0
금액·시각·상태 위반 = 0
1002 가격 차이 정확히 1행
모든 IDENTITY 다음 값 > 현재 최대 ID
07의 임시 테스트 증거 존재
30/30 / failure24 / success6 / unexpected0
```

따라서 `07`과 `08`은 같은 PostgreSQL 세션에서 연속 실행해야 합니다.

통과 메시지:

```text
Chapter 13 AI review lab validation passed: tests 30/30
```

---

## 14. reset을 원자적·비파괴적으로 변경

`reset_ai_review_lab.sql`은 `CASCADE`를 사용하지 않습니다.

```text
DB·읽기 전용 보호
BEGIN
payments
→ enrollments
→ courses
→ instructors
→ students
→ bad_enrollments
→ DROP SCHEMA ai_review_lab
COMMIT
```

예상하지 못한 `ai_review_lab.keep_me`가 있으면 마지막 `DROP SCHEMA`가 실패하고 앞선 DROP도 전체 ROLLBACK됩니다.

전용 workflow에서 실제로 확인했습니다.

```text
keep_me 생성
→ reset 실패
→ keep_me·bad_enrollments·students·payments 모두 그대로 존재
→ keep_me만 수동 삭제
→ 정상 reset
→ ai_review_lab 미존재
```

---

## 15. 앞 장 스키마 격리를 실제 fingerprint로 확인

전용 PostgreSQL 16 검증은 Chapter 07·08뿐 아니라 Chapter 12 `nosql_lab`까지 실제 생성합니다.

그 뒤 다음을 보호합니다.

```text
course_project 데이터 fingerprint
nosql_lab 핵심 데이터 fingerprint
transaction_lab sentinel
performance_lab sentinel
security_lab sentinel
nosql_lab sentinel
```

Chapter 13 전체 실행과 reset 후에도 모두 동일함을 확인했습니다.

---

## 16. 프롬프트·보고서·워크북 동기화

다음 문서를 같은 P13 기준과 30개 테스트 기준으로 맞췄습니다.

```text
PROMPT_TEMPLATES.md
AI_REVIEW_REPORT_TEMPLATE.md
chapter13_activity.md
chapter13_outline.md
code/chapter13/README.md
notes/chapter13_review_checklist.md
```

AI 수정 요청에는 다음을 포함하도록 유지합니다.

```text
확인 요구사항
결정·미확정 정책
수정 대상
수정 금지 범위
예상 diff
실행할 검증
미실행 항목
남은 가정
승인 상태
```

---

## 17. 이미지 8쌍 전체 정합성

Chapter 13 이미지:

```text
ch13_01 AI 기반 DB 설계 검증 전체 흐름
ch13_02 ChatGPT·Codex·사람 협업
ch13_03 좋은 프롬프트 구조
ch13_04 ERD 검토 체크포인트
ch13_05 나쁜 설계와 좋은 설계 비교
ch13_06 제약조건 검토
ch13_07 예상 설계와 실제 메타데이터 비교
ch13_08 Codex 오류 수정·재검증 루프
```

자동 정적 검증:

```text
Mermaid = 8
SVG = 8
stem 1:1 일치
SVG XML parse
role="img"
width="100%"
viewBox
title
desc
본문에서 SVG 8개 모두 참조
```

`ch13_05`의 금액 필드도 `recorded_amount` 기준으로 동기화했습니다.

---

## 18. 이론·실습 발표자료와 런타임

발표자료:

```text
이론 = 20장
실습 = 20장
```

각 장표에 `화면 구성`과 `발표 스크립트`가 모두 있으며 `chapter13_navigation.js` 제목과 1:1 대응합니다.

런타임 기준:

```text
chapter13_slides.js → Markdown fetch cache=no-store
chapter13_script.js → shared PresentationTTS.normalize 사용
chapter13_script.html → tts_pronunciation.js + script_content_enhancer.js
player/script asset version = 20260809a
```

공통 TTS에는 P13 추적 ID, `recorded_amount`, `payment_reference`, `IS DISTINCT FROM`, `NO ACTION` 등 Chapter 13 핵심 용어가 포함되어 있습니다.

---

## 19. 자동 검증 체계

### 정적 내비게이션 검증

```text
.github/workflows/validate-chapter13-navigation.yml
```

확인:

```text
JavaScript 문법
이론 20 / 실습 20
강의안 제목 ↔ navigation 제목
화면 구성·스크립트 존재
공통 TTS·스크립트 enhancer
제약조건 29 / FK 4 / IDENTITY 6
24 expected failures / 6 expected successes
30/30
삭제 RESTRICT 경계
이메일 대소문자 경계
최종 통과 메시지
```

### PostgreSQL 16 전체 검증

```text
.github/workflows/validate-chapter13.yml
```

실제 흐름:

```text
정적 정합성
→ PostgreSQL 16
→ 잘못된 DB 보호
→ Chapter 07 생성·검증
→ Chapter 08 baseline
→ Chapter 12 01→07 실제 실행
→ protected fingerprint·sentinel
→ upstream recorded_amount drift 실패 확인·복원
→ Chapter 13 01→08 전체 실행
→ exact final state
→ business-state drift 실패 확인·복원
→ protected fingerprint 불변
→ keep_me reset 원자성
→ 정상 reset
```

---

## 20. 실제 PostgreSQL 16 검증 결과

성공 실행:

```text
Workflow: Validate Chapter 13
Run: 2
Run ID: 31291233314
Commit: 5fd926149d87f6f941b7015fedbdf1361beb0b20
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

통과한 주요 단계:

```text
wrong database guard
Chapter 07·08 canonical build
Chapter 12 handoff build
protected fingerprints
upstream drift detection
Chapter 13 01→08
30/30 tests
exact final state
business drift detection
protected schemas unchanged
reset atomicity and isolation
```

Chapter 13 exact final state:

```text
bad_enrollments = 3
students = 3
instructors = 2
courses = 3
enrollments = 4
payments = 4
recorded_amount = 470000
payment amount = 470000
enrollment states = 완료2 / 신청1 / 취소1 / 수강중0
payment states = 결제완료2 / 결제대기1 / 환불1 / 결제실패0
```

---

## 최종 상태

| 영역 | 상태 |
| --- | --- |
| Chapter 07·08 시작 게이트 | PostgreSQL 16 통과 |
| `recorded_amount` 의미 통일 | 완료 |
| payments 격리 시나리오 경계 | 완료 |
| Chat·Work·Codex 역할 최신화 | 완료 |
| 나쁜 설계 반례 기준선 | PostgreSQL 16 통과 |
| 좋은 구조 29 constraints | PostgreSQL 16 통과 |
| Seed 3/3/2/3/4/4 | PostgreSQL 16 통과 |
| 금액 470000/470000 | PostgreSQL 16 통과 |
| 메타데이터 검증 | PostgreSQL 16 통과 |
| 업무 정합성 검증 | PostgreSQL 16 통과 |
| expected failure 24 | PostgreSQL 16 통과 |
| expected success 6 | PostgreSQL 16 통과 |
| 전체 테스트 30/30 | PostgreSQL 16 통과 |
| 08 최종 완료 게이트 | PostgreSQL 16 통과 |
| protected schema fingerprint | PostgreSQL 16 통과 |
| reset 전체 ROLLBACK | PostgreSQL 16 통과 |
| 프롬프트·보고서·워크북 | 동기화 완료 |
| Mermaid/SVG 8쌍 | 정적 검증 통과 |
| 이론 발표 20장 | 정적 검증 통과 |
| 실습 발표 20장 | 정적 검증 통과 |
| navigation 1:1 | 정적 검증 통과 |
| asset version 20260809a | 정적 검증 통과 |
| 공통 TTS·script enhancer 연결 | 정적 검증 통과 |

## 남은 수동 확인

다음은 자동 검증으로 통과했다고 처리하지 않습니다.

```text
1. 이론 발표 20장 브라우저 최종 시각 확인
2. 실습 발표 20장 브라우저 최종 시각 확인
3. semantic/step highlight 실제 동작
4. 발표자 스크립트 창 ↔ 장표 실제 동기화
5. TTS 실제 청취·발음 확인
6. 모바일·프로젝터 가독성
7. Mermaid CLI 재생성 여부 확인
8. GitHub SVG 실제 시각 렌더링
9. Word·PDF·eBook 코드·표·SVG 최종 렌더링
10. 최종 페이지 수
11. 실제 조직의 개인정보·결제 참조값 보호 정책 확인
12. 운영 DB 마이그레이션·락·백업·롤백 계획
```

실제로 실행하거나 렌더링하지 않은 항목은 “통과”로 표시하지 않습니다.
