# Chapter 13 전체 검토·수정 반영 기록

## 기준

이 문서는 Chapter 13의 본문만이 아니라 구성안, 독자 워크북, SQL 실습, 프롬프트·보고서 템플릿, README, SVG, 발표자료, 발표 스크립트, 의미 단위 내비게이션, 공통 TTS와 자동 검증까지 한 기준으로 추적하기 위한 최종 반영 기록입니다.

기존 검토 이력을 지우지 않고 실제 보정 내용을 누적하며, 코드에만 반영된 상태와 실제 실행·렌더링까지 확인된 상태를 구분합니다.

---

## 대상 파일

### 본문·구성·워크북·검토 문서

```text
book/chapter13/chapter13.md
book/chapter13/chapter13_activity.md
book/chapter13/chapter13_outline.md
book/chapter13/chapter13_review_revision.md
notes/chapter13_review_checklist.md
README.md
```

### SQL·프롬프트·보고서

```text
code/chapter13/01_ai_review_lab_schema.sql
code/chapter13/02_bad_design_seed.sql
code/chapter13/03_good_design_schema.sql
code/chapter13/04_good_design_seed.sql
code/chapter13/05_metadata_validation.sql
code/chapter13/06_business_validation.sql
code/chapter13/07_negative_tests.sql
code/chapter13/08_ai_review_lab_validation.sql
code/chapter13/AI_REVIEW_REPORT_TEMPLATE.md
code/chapter13/PROMPT_TEMPLATES.md
code/chapter13/reset_ai_review_lab.sql
code/chapter13/ai_db_design_review_practice.sql
code/chapter13/README.md
```

### 이미지·다이어그램

```text
images/chapter13/ch13_01_ai_db_design_review_flow.*
images/chapter13/ch13_02_chatgpt_codex_roles.*
images/chapter13/ch13_03_good_prompt_structure.*
images/chapter13/ch13_04_erd_review_checkpoints.*
images/chapter13/ch13_05_bad_vs_good_design.*
images/chapter13/ch13_06_constraints_review.*
images/chapter13/ch13_07_information_schema_review.*
images/chapter13/ch13_08_codex_error_fix_loop.*
images/chapter13/README.md
```

### 발표·스크립트·내비게이션

```text
presentation/chapter13/chapter13_theory_lecture_plan.md
presentation/chapter13/chapter13_practice_lecture_plan.md
presentation/chapter13/chapter13_theory_presentation.html
presentation/chapter13/chapter13_practice_presentation.html
presentation/chapter13/chapter13_slides.js
presentation/chapter13/chapter13_navigation.js
presentation/chapter13/chapter13_player.js
presentation/chapter13/chapter13_player.css
presentation/chapter13/chapter13_script.html
presentation/chapter13/chapter13_script.js
presentation/chapter13/index.html
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js
.github/workflows/validate-chapter13-navigation.yml
```

---

## 최종 목표

Chapter 13을 단순한 “AI가 DB 설계를 도와준다”는 설명 장이 아니라 다음 증거를 사용해 변경을 검토하고 사람이 승인하는 운영형 장으로 정리했습니다.

```text
확인된 요구사항·결정·미확정 정책
→ AI 문맥 묶음·프롬프트 계약
→ ERD·DDL·SQL 변경 후보
→ 수정 범위·금지 범위 확인
→ DB·스키마 보호
→ 원자적 생성·Seed
→ IDENTITY 조정
→ 정확한 메타데이터
→ 정상·경계값·반례
→ NULL 안전 업무 정합성
→ 민감정보·파괴적 변경·diff 검토
→ 최종 자동 판정
→ 사람 승인
```

---

## 1. 장의 역할과 핵심 메시지

본문 제목은 다음으로 통일했습니다.

```text
Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기
```

핵심 메시지:

```text
AI 결과는 정답이 아니라 변경 후보다.
설명의 자연스러움이 아니라 요구사항과 실행 증거를 추적할 수 있는지가 품질 기준이다.
```

본문·구성안·워크북에서 같은 흐름과 같은 용어를 사용하도록 동기화했습니다.

---

## 2. ChatGPT·Codex·사람의 역할 구분

역할을 제품의 절대 기능 구분이 아니라 안전한 작업 흐름으로 설명했습니다.

| 참여자 | 활용하기 좋은 작업 | 최종 책임에서 제외할 작업 |
| --- | --- | --- |
| ChatGPT | 요구사항 구조화, 대안 비교, 검토 질문·프롬프트 초안 | 미확정 업무 정책 확정 |
| Codex | 저장소 탐색, 대상 파일 수정, SQL·테스트 작성, diff·실행 지원 | 변경 자동 승인 |
| 사람 | 요구사항·데이터·권한·운영 범위 확인, diff·실행 결과 검토 | 최종 책임을 AI에 이전 |

```text
정책 확인 → AI 초안 → 격리 실행 → 증거 수집 → 사람 승인
```

이 역할표를 본문과 `ch13_02_chatgpt_codex_roles.svg`에 연결했습니다.

---

## 3. AI 문맥 묶음과 프롬프트 계약

한 줄 질문 대신 다음 문맥을 제공하도록 정리했습니다.

```text
업무 목표
확인 요구사항
결정·단순화
미확정 정책
DB 환경
현재 구조·대표 데이터
수정 대상
수정 금지 범위
정상·경계값·반례 기준
메타데이터·업무 검증 기준
완료 보고 형식
```

프롬프트에는 실제 개인정보, 비밀번호, API 키, 전체 접속 URL, 실제 카드번호 형태를 넣지 않도록 명시했습니다.

`PROMPT_TEMPLATES.md`, 본문, 워크북의 표현을 같은 기준으로 맞추고 `ch13_03_good_prompt_structure.svg`로 시각화했습니다.

---

## 4. 추적 ID 통일

```text
P13-R01~P13-R09  확인된 요구사항
P13-D01~P13-D08  결정·단순화·미확정 정책
P13-T01~P13-T27  반례·정상 경계값 테스트
P13-V01~P13-V08  실행·검증 단계
```

기존 R1·D1처럼 Chapter 범위가 보이지 않는 표기는 P13 기준으로 통일했습니다.

앞 장에서 이미 확정한 정책은 Chapter 13에서 다시 미확정으로 되돌리지 않습니다.

---

## 5. 요구사항·정책 기준선

핵심 요구사항은 다음을 유지합니다.

```text
P13-R01 학생 이메일 공백 금지·정확 문자열 중복 금지
P13-R02 강사 이메일 공백 금지·정확 문자열 중복 금지
P13-R03 강의→강사 FK
P13-R04 학생·강의 N:M 해소
P13-R05 수강 상태 허용값 제한
P13-R06 가격·금액 0 이상
P13-R07 결제→수강신청 FK
P13-R08 실제 카드번호 미저장
P13-R09 활성 신청 학생·강의당 한 건
```

결정·범위:

```text
P13-D01 완료·취소 이력 뒤 재신청 허용
P13-D02 현재 결제 상태 한 건 모델
P13-D03 삭제 정책 RESTRICT
P13-D04 개인정보 보관 기간은 조직 정책
P13-D05 상태 전이 순서는 별도 정책
P13-D06 전액 결제·전액 환불 샘플, 부분 환불 원장은 범위 밖
P13-D07 이메일 대소문자는 정확 문자열 비교, 정규화 별도 결정
P13-D08 결제 없는 신청 허용
```

---

## 6. ERD·테이블 역할·카디널리티 검토

ERD는 “그럴듯한 그림”이 아니라 요구사항 기준으로 검토하도록 수정했습니다.

```text
instructors 1 → 0..N courses
students 1 → 0..N enrollments
courses 1 → 0..N enrollments
enrollments 1 → 0..1 payments
```

현재 `payments` 관계는 P13-D02의 단순 모델입니다. 결제 시도·재결제·부분 환불 전체 이력이 필요하면 1:N 원장 구조로 다시 설계해야 함을 명시했습니다.

좋은 설계의 역할:

| 테이블 | 주요 역할 |
| --- | --- |
| students | 학생 기본 정보 |
| instructors | 강사 기본 정보 |
| courses | 강의 현재 정보와 기본 가격 |
| enrollments | 학생·강의 관계와 신청 시점 합의 금액 |
| payments | 현재 결제 상태와 외부 비민감 참조값 |

`bad_enrollments`의 역할 혼합 문제와 좋은 설계의 분리를 `ch13_04`, `ch13_05` 다이어그램과 본문에 동기화했습니다.

---

## 7. DB·스키마 보호와 원자적 생성

- 현재 DB가 `ai_database_book`이 아니면 생성·초기화 중단
- Chapter 07 `course_project.enrollments = 5` 기준 확인
- 기존 `ai_review_lab` 존재 시 생성 중단
- `course_project`, `transaction_lab`, `performance_lab`, `security_lab`, `nosql_lab` 변경 금지
- 스키마와 테이블을 한 트랜잭션에서 생성
- reset은 자식→부모 순서로 `ai_review_lab`만 삭제
- 각 SQL에서 `SHOW search_path` 확인
- 자동 DROP을 기본 실행 경로에 넣지 않음

이 기준을 본문, 워크북, 01, reset, README에 맞췄습니다.

---

## 8. Seed 재실행·부분 입력 방지와 IDENTITY

- 나쁜 설계 Seed는 대상 테이블 0행 확인
- 좋은 설계 Seed는 다섯 테이블 존재·0행 확인
- 각 Seed를 트랜잭션으로 실행
- COMMIT 전 기준 행 수와 금액 관계 판정
- 명시적 ID 입력 뒤 `RESTART WITH` 적용

```text
bad_enrollments → 4 이상
students → 104 이상
instructors → 203 이상
courses → 304 이상
enrollments → 1005 이상
payments → 9005 이상
```

ROLLBACK 후 자동 번호 공백은 정합성 오류가 아니라는 설명까지 본문·워크북·README에 반영했습니다.

---

## 9. 활성 신청 정책과 문자열 무결성

Chapter 07에서 확정한 정책을 유지합니다.

```sql
CREATE UNIQUE INDEX uq_ai_review_enrollments_active
ON ai_review_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

전체 `(student_id, course_id) UNIQUE`는 사용하지 않습니다. 신청·수강중 중복만 차단하고 완료·취소 이력 뒤 재신청은 허용합니다.

공백 방지 CHECK 적용 범위:

```text
students.name·email
instructors.name·email·specialty
courses.course_code·title
payments.payment_reference
```

학생·강사 이메일은 정확히 같은 문자열만 중복 차단합니다. 대소문자 정규화 여부는 P13-D07로 남겼습니다.

---

## 10. 가격·합의 금액·결제 금액과 결제·환불 시각

세 금액의 시점을 분리했습니다.

```text
courses.price              현재 기본 가격
enrollments.agreed_amount  신청 시점 합의 금액
payments.amount             현재 결제 상태의 금액
```

현재 가격과 합의 금액 차이는 할인·가격 변경일 수 있으므로 정보용으로 다룹니다.

결제 시각은 기존 단일 의미를 다음처럼 분리했습니다.

```text
paid_at      결제 완료 시각
refunded_at  환불 완료 시각
```

```text
결제대기·결제실패 → 두 시각 NULL
결제완료 → paid_at만 존재
환불 → paid_at·refunded_at 존재, refunded_at > paid_at
```

샘플은 전액 결제·전액 환불이며 부분 환불 원장은 범위 밖입니다.

---

## 11. 정확한 메타데이터 자동 검증

`05_metadata_validation.sql`은 단순 개수가 아니라 정확한 객체 구성을 판정하도록 보강했습니다.

```text
정확한 테이블 집합 6개
좋은 설계 제약조건 29개
정확한 FK 이름·출발 컬럼·대상 컬럼 4개
삭제 규칙 RESTRICT/NO ACTION
IDENTITY id 6개
활성 신청 부분 고유 인덱스 존재
민감정보 전용 컬럼 이름 0개
```

DDL 텍스트가 아니라 실제 PostgreSQL 메타데이터를 검증 근거로 사용합니다.

---

## 12. LEFT JOIN NULL과 업무 정합성

결제 누락을 놓칠 수 있는 다음 비교를 제거했습니다.

```sql
p.payment_status <> '결제완료'
```

필수 결제 누락까지 확인하도록 `IS DISTINCT FROM`을 사용합니다.

```text
완료 → 결제완료 필수
취소 → 환불 필수
신청 → 결제 없음 허용, 있으면 결제대기
수강중 → 결제 없음 허용, 있으면 결제완료
```

`06_business_validation.sql`의 최종 판정 범위:

```text
기준 행·JOIN
학생·강사 이메일 중복
필수 문자열 공백
합의·결제 금액
결제·환불 시각
고아 관계
활성 신청 중복
샘플 상태 조합
현재 가격·합의 금액 차이 정보용 1행
```

---

## 13. 반례·정상 경계값 27개

`07_negative_tests.sql`은 헬퍼 프로시저 기반으로 구성했습니다.

```text
P13-T01~P13-T22 expected_failure
P13-T23~P13-T27 expected_success
전체 27 / 통과 27 / unexpected 0
```

`GET STACKED DIAGNOSTICS`로 다음 증거를 기록합니다.

```text
SQLSTATE
constraint name
table name
column name
오류 상세
```

정상 경계값은 가격 0, 한 글자 이름·제목, NULL description, 결제 없는 신청, 완료·취소 이력 뒤 재신청, 결제실패·금액 0·시각 NULL을 포함합니다.

오류 테스트만 수행해 제약조건이 정상 데이터를 과도하게 막는 문제를 놓치지 않도록 수정했습니다.

---

## 14. 최종 자동 검증 08

`08_ai_review_lab_validation.sql`을 최종 영구 상태 판정 파일로 추가했습니다.

검증 범위:

```text
Chapter 07 신청 5행 유지
기준 행 3/3/2/3/4/4
정상 JOIN 4
정확한 테이블·제약·FK·IDENTITY
필수 문자열·고아 관계·활성 중복 0
금액·시각·상태 조합 위반 0
가격 차이 정보용 1행
모든 IDENTITY 다음 값 > 현재 최대 ID
같은 세션이면 07의 27/27 결과 재확인
```

코드에 정의된 최종 통과 메시지:

```text
Chapter 13 AI review lab validation passed
```

실제 PostgreSQL 실행 전에는 이 메시지가 코드에 존재한다는 사실과 실제 실행 통과를 구분합니다.

---

## 15. 민감정보 검증 증거 강화

컬럼명 검사만으로 카드번호 미저장을 증명하지 않도록 수정했습니다.

```text
카드번호·CVV·비밀번호 전용 컬럼 없음
payment_reference는 외부 비민감 참조값으로 문서화
PAY-REVIEW-TEST-* 형태의 가상 Seed 사용
로그·프롬프트 민감 패턴 검토
애플리케이션이 카드정보를 DB로 전달하지 않는 흐름 검토
```

가상 나쁜 설계 예제도 실제 카드번호 형태를 사용하지 않습니다.

---

## 16. 파괴적 변경과 Codex diff·재실행 루프

별도 검토 대상으로 다음을 명시했습니다.

```text
DROP TABLE / DROP SCHEMA
TRUNCATE
조건 없는 UPDATE / DELETE
ALTER COLUMN TYPE
SET NOT NULL
UNIQUE 추가
ON DELETE CASCADE
인덱스 삭제
GRANT·REVOKE
```

Codex 작업 흐름:

```text
1. 오류와 기대 결과 재현
2. 개인정보·접속 정보 제거
3. 수정 대상·금지 범위 지정
4. 최소 변경 요청
5. 파일별 diff 사람 검토
6. 관련 없는 변경 제거
7. 격리 스키마 재생성
8. 01→08 재실행
9. 실패 원인·프롬프트 수정
10. 증거·남은 가정·승인 상태 기록
```

이 흐름을 본문과 `ch13_08_codex_error_fix_loop.svg`에 연결했습니다.

---

## 17. 보고서·프롬프트·워크북·README 동기화

다음 항목을 공통 기준으로 맞췄습니다.

```text
P13 ID
ChatGPT·Codex·사람 역할
프롬프트 문맥 묶음
ERD·카디널리티
IDENTITY 다음 값
활성 부분 고유 인덱스
SQLSTATE·constraint name
정상 경계값과 반례
paid_at·refunded_at
부분 환불 범위
LEFT JOIN NULL
08 최종 자동 검증
민감정보 다중 증거
미실행 항목
승인·조건부 승인·보류·거절
Chapter 14 연결
```

문서 내부에서 “추가 보강 불필요”처럼 실제 변경 이력과 충돌할 수 있는 상태 표현보다, 무엇이 보정되었고 무엇이 아직 실행 전인지 추적하도록 정리합니다.

---

## 18. SVG·시각 자료 반영

본문의 핵심 개념을 다음 8개 시각 자료와 연결했습니다.

```text
ch13_01 AI 기반 DB 설계 검증 전체 흐름
ch13_02 ChatGPT·Codex·사람 역할
ch13_03 좋은 프롬프트 구조
ch13_04 ERD 검토 체크포인트
ch13_05 나쁜 설계와 좋은 설계 비교
ch13_06 제약조건 검토
ch13_07 예상 설계와 실제 메타데이터 비교
ch13_08 Codex 오류 수정·재검증 루프
```

본문 표와 SVG가 같은 내용을 중복 설명하기보다, 표는 상세 기준·SVG는 흐름과 구조를 담당하도록 역할을 구분합니다.

---

## 19. 이론·실습 발표자료 전체 반영

Chapter 13 발표자료는 이론과 실습을 각각 20장으로 구성합니다.

```text
이론 20장
실습 20장
총 40장
```

`chapter13_theory_lecture_plan.md`와 `chapter13_practice_lecture_plan.md`의 모든 장표에 화면 구성과 발표 스크립트가 존재하도록 기준을 맞췄습니다.

`chapter13_navigation.js`는 장표 제목을 기준으로 이론·실습 각각 20장의 의미 단위 내비게이션 계획을 관리합니다.

```text
장표 제목 중복 금지
강의안 제목과 navigation plan 제목 일치
화면 구성과 발표 스크립트 동시 존재
장표 내부 의미 단위에 맞춰 포커스 이동
이론·실습 동일한 내비게이션 구조 사용
```

발표 화면과 스크립트 화면이 같은 장표·단계를 기준으로 움직이도록 `chapter13_player.js`, `chapter13_script.js`, `chapter13_navigation.js`를 공통 기준으로 사용합니다.

---

## 20. 공통 TTS·발표 스크립트 보강

Chapter 13에서 로컬 TTS 규칙을 중복 관리하지 않고 공통 `presentation/common/tts_pronunciation.js`의 `PresentationTTS.normalize`를 사용하도록 통일했습니다.

공통 발음 규칙에 Chapter 13 핵심 용어를 포함했습니다.

```text
ALTER COLUMN TYPE
SET NOT NULL
IS DISTINCT FROM
NO ACTION
P13-R / P13-D / P13-T / P13-V
ai_review_lab
bad_enrollments
agreed_amount
payment_reference
payment_status
paid_at
refunded_at
```

최신 스크립트 화면에는 `script_content_enhancer.js`를 로드해 짧은 단계 설명을 보강하고, 기존 긴 설명은 유지하는 방향을 적용했습니다.

자산 캐시는 Chapter 13 주요 파일 `20260808a`, 스크립트 콘텐츠 보강 파일 `20260808e` 기준이 반영되어 있습니다.

---

## 21. 자동 정적 검증·CI 기준

`.github/workflows/validate-chapter13-navigation.yml`에 다음 검증을 정의했습니다.

```text
Chapter 13 JavaScript 문법 검사
이론 20장 / 실습 20장 확인
장표 제목 중복 확인
강의안 제목과 navigation plan 제목 일치 확인
각 장표의 화면 구성·발표 스크립트 존재 확인
로컬 중복 TTS 규칙 제거 확인
공통 PresentationTTS 사용 확인
Chapter 13 핵심 TTS 용어 존재 확인
presentation HTML 자산 로드 순서 확인
SQL 01~08 필수 파일 존재 확인
제약조건 29·FK 4·IDENTITY 6 기준 확인
P13-T01~T22 / T23~T27 존재 확인
27/27 판정 로직 확인
Chapter 07 기준 데이터 보존 로직 확인
최종 통과 메시지 존재 확인
```

이 검증은 코드·문서·내비게이션의 정적 일관성을 확인하는 장치입니다. 실제 PostgreSQL에서 SQL을 실행해 결과를 확인하는 검증과 브라우저·Word·PDF·eBook 렌더링 검증은 별도입니다.

---

## 22. Chapter 14 연결

기존 Vector DB·RAG 중심 안내를 현재 목차 흐름에 맞게 수정했습니다.

```text
SQL 분석 질문과 기준 행
집계·윈도우 함수
분석 결과 검산
PostgreSQL·Python 연결
pandas 기반 후속 분석
SQL·Python 결과 교차 검증
AI가 만든 분석 코드 검토
```

Chapter 13의 “AI 결과를 실행 증거로 검증한다”는 원칙이 Chapter 14의 SQL·Python 분석 결과 교차 검증으로 이어지도록 연결했습니다.

---

## 최종 상태

| 영역 | 상태 |
| --- | --- |
| 장의 역할·핵심 메시지 | 완료 |
| ChatGPT·Codex·사람 역할 | 완료 |
| 문맥 묶음·프롬프트 계약 | 완료 |
| P13 추적 ID | 완료 |
| 요구사항·정책 기준선 | 완료 |
| ERD·카디널리티·역할표 | 완료 |
| DB·스키마 보호 | 완료 |
| Seed 재실행·원자성 | 완료 |
| IDENTITY 조정 | 완료 |
| 활성 신청 정책 | 완료 |
| 문자열·이메일 범위 | 완료 |
| 가격·결제·환불 의미 | 완료 |
| 정확한 메타데이터 검증 코드 | 완료 |
| LEFT JOIN NULL 보정 | 완료 |
| 업무 정합성 검증 코드 | 완료 |
| 반례·경계값 27개 | 완료 |
| SQLSTATE·constraint name 증거 | 완료 |
| 최종 08 검증 코드 | 완료 |
| 민감정보 다중 증거 | 완료 |
| 파괴적 변경·Codex 루프 | 완료 |
| 보고서·프롬프트·워크북·README 동기화 | 완료 |
| SVG ch13_01~08 연결 | 완료 |
| 이론 발표자료 20장 | 완료 |
| 실습 발표자료 20장 | 완료 |
| 의미 단위 내비게이션 | 완료 |
| 발표/스크립트 동기화 구조 | 완료 |
| 공통 TTS | 완료 |
| 스크립트 콘텐츠 보강 | 완료 |
| Chapter 13 자동 정적 검증 정의 | 완료 |
| Chapter 14 연결 | 완료 |

## 남은 실제 확인

다음 항목은 코드 반영과 실제 실행·출판 결과를 구분하기 위해 완료로 표시하지 않습니다.

```text
1. PostgreSQL에서 reset 후 01→08 순차 실행
2. 05 metadata validation 실제 통과 확인
3. 06 business validation 실제 통과 확인
4. 07 반례·경계값 27/27, unexpected 0 실제 확인
5. 08 'Chapter 13 AI review lab validation passed' 실제 확인
6. 기준 행 수와 모든 IDENTITY 다음 값 실제 확인
7. Chapter 13 GitHub Actions 실행 결과 확인
8. 이론·실습 발표 HTML 브라우저 렌더링과 단계 이동 확인
9. 스크립트 창·TTS·포커스 동기화 수동 확인
10. SVG 8개 가독성·본문 참조 확인
11. Word·PDF·eBook 최종 렌더링 확인
```

실제로 실행하거나 렌더링하지 않은 항목은 “통과”로 표시하지 않습니다.
