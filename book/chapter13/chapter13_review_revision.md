# Chapter 13 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter13/chapter13.md
book/chapter13/chapter13_activity.md
book/chapter13/chapter13_outline.md
code/chapter13/01_ai_review_lab_schema.sql
code/chapter13/02_bad_design_seed.sql
code/chapter13/03_good_design_schema.sql
code/chapter13/04_good_design_seed.sql
code/chapter13/05_metadata_validation.sql
code/chapter13/06_business_validation.sql
code/chapter13/07_negative_tests.sql
code/chapter13/AI_REVIEW_REPORT_TEMPLATE.md
code/chapter13/PROMPT_TEMPLATES.md
code/chapter13/reset_ai_review_lab.sql
code/chapter13/ai_db_design_review_practice.sql
code/chapter13/README.md
images/chapter13/README.md
notes/chapter13_review_checklist.md
README.md
```

## 목적

Chapter 13을 `public`의 `ai_bad_·ai_good_` 테이블을 자동 삭제하는 단일 SQL 실습에서 **격리된 스키마에서 요구사항·메타데이터·정상·반례·업무 정합성·diff를 추적해 AI 변경을 승인하는 장**으로 재구성한다.

```text
확인 요구사항·미확정 정책
→ AI 문맥 묶음과 프롬프트 계약
→ ERD·DDL·SQL 초안
→ ai_review_lab 생성
→ 정상·반례·메타데이터·업무 검증
→ 파괴적 SQL·권한·성능 검토
→ 파일별 diff
→ 승인·조건부 승인·보류·거절
```

---

## 1. 제목 변경

```text
기존: ChatGPT와 Codex로 DB 설계 검증하기
변경: AI와 실행 증거로 데이터베이스 설계 검증하기
```

ChatGPT와 Codex는 본문에서 계속 사용하되 제품 기능 자체보다 검토 절차와 사람의 승인 책임을 중심에 둔다.

---

## 2. 실습 스키마 격리

기존:

```text
public.ai_bad_enrollments
public.ai_good_students
public.ai_good_instructors
public.ai_good_courses
public.ai_good_enrollments
public.ai_good_payments
자동 DROP 후 재생성
```

변경:

```text
ai_review_lab.bad_enrollments
ai_review_lab.students
ai_review_lab.instructors
ai_review_lab.courses
ai_review_lab.enrollments
ai_review_lab.payments
```

앞 장 스키마는 변경하지 않는다.

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
public
```

---

## 3. SQL 구조 변경

### 기존

```text
ai_db_design_review_practice.sql
- 500줄 단일 파일
- 자동 DROP
- SERIAL
- 1·2·3 자동 ID 가정
- 생성·입력·오류·메타데이터·정합성 혼합
```

### 변경

```text
01_ai_review_lab_schema.sql
- 격리 스키마와 나쁜 설계 테이블 생성

02_bad_design_seed.sql
- 반복·약한 타입·FK 부재·민감정보 문제 입력

03_good_design_schema.sql
- IDENTITY·명시적 제약조건 좋은 설계

04_good_design_seed.sql
- 명시적 ID 정상 데이터

05_metadata_validation.sql
- 실제 컬럼·제약조건·FK·인덱스 검증

06_business_validation.sql
- 기준 행·JOIN·업무 이상 0행 검증

07_negative_tests.sql
- 하위 트랜잭션 기반 17개 반례 자동 검증

reset_ai_review_lab.sql
- 전용 스키마만 초기화

ai_db_design_review_practice.sql
- 스키마 생성 전에도 안전한 호환 진입점
```

---

## 4. 기준 데이터와 재현성

```text
bad_enrollments 3
students 3
instructors 2
courses 3
enrollments 4
payments 4
JOIN 4
FK 4
```

명시적 ID:

```text
students 101~103
instructors 201~202
courses 301~303
enrollments 1001~1004
payments 9001~9004
```

AUTO_INCREMENT·IDENTITY 값이 항상 1부터 연속이라는 가정을 제거했다.

---

## 5. 요구사항·정책 추적 강화

확인 요구사항 R1~R8:

```text
학생·강사 email UNIQUE
강의→강사 FK
학생·강의 N:M 해소
수강 상태 CHECK
금액 0 이상
결제→신청 FK
실제 카드번호 미저장
```

미확정 정책:

```text
재신청
결제 시도 이력
삭제 정책
개인정보 보관
상태 전이
```

미확정 정책은 제약조건으로 임의 고정하지 않고 결정 기록과 최종 보고서에 남긴다.

---

## 6. 메타데이터 검증 강화

```text
information_schema.tables
information_schema.columns
information_schema.table_constraints
information_schema.referential_constraints
pg_constraint
pg_indexes
```

검증 기준:

```text
전체 테이블 6
좋은 설계 테이블 5
FK 4
IDENTITY PK 5
민감정보 형태 컬럼 0
재신청 복합 UNIQUE 0
```

DDL 텍스트가 아니라 실제 생성된 카탈로그를 검증한다.

---

## 7. 안전한 반례 자동화

기존에는 오류 SQL을 한 문장씩 주석 해제해야 했다.

변경 후 `07_negative_tests.sql`은 PostgreSQL 예외 블록을 사용한다.

```text
1~16 expected_failure
17 reenrollment_policy_not_forced expected_success
unexpected 0
```

각 반례는 독립 하위 트랜잭션에서 실행되어 예상 오류 시 변경이 자동 취소된다. 테스트 후 기준 행 수가 유지된다.

---

## 8. 업무 정합성·시점 데이터

```text
courses.price = 현재 강의 가격
enrollments.agreed_amount = 신청 시점 합의 금액
payments.amount = 결제 기록 금액
```

현재 가격과 합의 금액 차이는 정보용 1행으로 유지하고 자동 오류로 판단하지 않는다. 합의 금액과 결제금액 불일치는 0행이어야 한다.

추가 0행 검증:

```text
이메일 중복
paid_at 조합 위반
고아 FK
샘플 수강·결제 상태 조합 위반
```

---

## 9. 검토 산출물 추가

### `AI_REVIEW_REPORT_TEMPLATE.md`

```text
검토 commit
요구사항 추적
AI 가정
변경 파일·diff
메타데이터·정상·반례·업무 검증
보안·권한·성능·복구 위험
미실행 항목
승인·조건부 승인·보류·거절
```

### `PROMPT_TEMPLATES.md`

```text
ERD·DDL 검토
Codex 저장소 수정
SQL 오류 분석
파괴적 마이그레이션 검토
인덱스 검토
최종 승인 검토
```

---

## 10. 범위 확장

기존 ERD·DDL 검토에 다음을 추가했다.

```text
파괴적 DROP·ALTER·UPDATE·DELETE
최소 권한과 비밀정보
SQL Injection
기존 인덱스와 성능 증거
백업·롤백·복구
검증 상태와 승인 상태
```

Chapter 10~12의 성능·보안·복구·다중 저장소 원칙을 AI 변경 검토에 연결했다.

---

## 11. 도식 처리

기존 Mermaid·SVG 8종은 요구사항, 협업 역할, 프롬프트, ERD, 나쁜·좋은 설계, 제약조건, 메타데이터와 Codex 루프라는 일반 메시지가 새 본문과 호환되어 유지한다.

이미지 문서에는 새 제목과 `ai_review_lab`, 검증 증거·승인 상태 기준을 반영한다.

---

## 12. 남은 확인 항목

```text
- 실제 PostgreSQL에서 01→07 실행
- 메타데이터 boolean 모두 true 확인
- 반례 17/17과 unexpected 0 확인
- 기준 행 수 유지 확인
- 업무 이상 조회 0행과 가격 차이 정보용 1행 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 13. 최종 상태

```text
Chapter 13 본문, 워크북, 구성안, 단계별 SQL, 프롬프트와 검토 보고서를 2차 재구성했다.
AI 결과를 설명하는 수준에서 요구사항·실행 증거·diff로 승인 여부를 판단하는 흐름으로 강화했다.
원격 main에 모든 변경을 직접 반영했다.
```
