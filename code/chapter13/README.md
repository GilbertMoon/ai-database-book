# Chapter 13 실습 코드

## AI와 실행 증거로 데이터베이스 설계 검증하기

이 폴더는 AI가 만든 데이터베이스 설계와 SQL을 `ai_review_lab`에서 격리하고, 요구사항·메타데이터·정상 경로·반례·업무 정합성·IDENTITY·diff를 근거로 검토하는 파일을 관리합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: 변경하지 않음
nosql_lab: 변경하지 않음
ai_review_lab: Chapter 13 실습 대상
```

모든 SQL은 다음 위치 확인 형식을 사용합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

생성·초기화 파일은 `ai_database_book`이 아니면 예외를 발생시킵니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_ai_review_lab_schema.sql` | DB·Chapter 07 기준 상태를 확인하고 스키마와 나쁜 설계 테이블을 한 트랜잭션에서 생성 |
| `02_bad_design_seed.sql` | 재실행을 차단하고 나쁜 데이터 3행 입력·IDENTITY 4 조정 |
| `03_good_design_schema.sql` | P13 요구사항, 활성 신청 부분 고유 인덱스와 결제·환불 시각 규칙을 반영한 좋은 설계 |
| `04_good_design_seed.sql` | 명시적 ID 정상 데이터 입력·IDENTITY 시작값 조정·COMMIT 전 판정 |
| `05_metadata_validation.sql` | 정확한 테이블 집합·FK 서명·제약조건 29개·IDENTITY 6개·인덱스 자동 검증 |
| `06_business_validation.sql` | NULL 안전 상태 조합, 고아 관계, 금액·시간·활성 중복과 가격 차이 검증 |
| `07_negative_tests.sql` | SQLSTATE·constraint name을 기록하는 반례 22개와 정상 경계값 5개 자동 테스트 |
| `08_ai_review_lab_validation.sql` | 기준 행·메타데이터·업무 정합성·IDENTITY·07 결과를 종합 판정 |
| `AI_REVIEW_REPORT_TEMPLATE.md` | 요구사항·정책·diff·증거·승인 상태 기록 |
| `PROMPT_TEMPLATES.md` | ERD·DDL·Codex 수정·마이그레이션·승인 검토 프롬프트 |
| `reset_ai_review_lab.sql` | DB 보호 구문 안에서 `ai_review_lab`만 초기화 |
| `ai_db_design_review_practice.sql` | 읽기 전용 호환 안내·상태 확인 |

---

## 실행 순서

```text
01_ai_review_lab_schema.sql
→ 02_bad_design_seed.sql
→ 03_good_design_schema.sql
→ 04_good_design_seed.sql
→ 05_metadata_validation.sql
→ 06_business_validation.sql
→ 07_negative_tests.sql
→ 08_ai_review_lab_validation.sql
→ AI_REVIEW_REPORT_TEMPLATE.md 기록
```

처음부터 다시 시작할 때만 `reset_ai_review_lab.sql`을 사용합니다.

---

## 추적 ID

```text
P13-R01~P13-R09  확인된 요구사항
P13-D01~P13-D08  결정·단순화·미확정 정책
P13-T01~P13-T27  반례·정상 경계값 테스트
P13-V01~P13-V08  실행·검증 단계
```

### 확인된 요구사항

```text
P13-R01 학생 email: 공백 금지, 정확히 같은 문자열 UNIQUE
P13-R02 강사 email: 공백 금지, 정확히 같은 문자열 UNIQUE
P13-R03 강의는 강사 한 명을 FK로 참조
P13-R04 학생·강의 N:M은 enrollments로 해소
P13-R05 수강 상태 허용값 CHECK
P13-R06 가격·합의 금액·결제 금액 0 이상
P13-R07 결제는 수강신청을 FK로 참조
P13-R08 실제 카드번호를 저장하지 않고 외부 비민감 payment_reference만 저장
P13-R09 신청·수강중 활성 신청은 학생·강의당 한 건
```

### 결정·범위

```text
P13-D01 완료·취소 이력 후 재신청 허용
P13-D02 한 신청에 현재 결제 상태 한 건만 저장하는 단순 모델
P13-D03 삭제는 RESTRICT
P13-D04 개인정보 보관 기간은 조직 정책
P13-D05 상태 전이는 별도 정책·서비스 로직
P13-D06 샘플은 전액 결제·전액 환불, 부분 환불 원장은 범위 밖
P13-D07 이메일 대소문자 정규화는 별도 결정, 현재는 정확 문자열 비교
P13-D08 신청 상태는 결제 행 없이 존재할 수 있음
```

---

## 기준 데이터와 IDENTITY

| 항목 | 기대 행 수 | 명시적 ID | 다음 자동값 |
| --- | ---: | --- | ---: |
| `bad_enrollments` | 3 | 1~3 | 4 이상 |
| `students` | 3 | 101~103 | 104 이상 |
| `instructors` | 2 | 201~202 | 203 이상 |
| `courses` | 3 | 301~303 | 304 이상 |
| `enrollments` | 4 | 1001~1004 | 1005 이상 |
| `payments` | 4 | 9001~9004 | 9005 이상 |
| 정상 JOIN | 4 | - | - |
| FK | 4 | - | - |

명시적 ID 입력은 IDENTITY 내부 시퀀스를 자동으로 이동시키지 않으므로 Seed 파일에서 `RESTART WITH`를 적용합니다. 반례 테스트는 명시적 테스트 ID를 사용하며 모두 하위 트랜잭션에서 자동 취소됩니다.

---

## 좋은 설계 핵심

```text
students.email·instructors.email
→ 공백 방지 + 정확 문자열 UNIQUE

courses.course_code
→ 공백 방지 + UNIQUE

students·courses N:M
→ enrollments

진행 중 활성 신청
→ 부분 고유 인덱스

courses.price
→ 현재 기본 가격

enrollments.agreed_amount
→ 신청 시점 합의 금액

payments.amount
→ 현재 결제 상태의 기록 금액

paid_at / refunded_at
→ 결제 시각과 환불 시각을 분리
```

결제 상태별 시각:

```text
결제대기·결제실패 → paid_at NULL, refunded_at NULL
결제완료           → paid_at NOT NULL, refunded_at NULL
환불               → paid_at·refunded_at NOT NULL, refunded_at >= paid_at
```

`payment_reference`는 카드번호가 아니라 외부 결제 시스템이 발급한 비민감 가상 참조값입니다. 컬럼명 검사만으로 민감정보 부재를 완전히 증명하지 않으며 Seed·로그·애플리케이션 흐름도 함께 검토합니다.

---

## 메타데이터 검증

`05_metadata_validation.sql`은 단순 개수뿐 아니라 정확한 객체를 판정합니다.

```text
정확한 테이블 집합 6개
좋은 설계 제약조건 29개
정확한 FK 이름·출발 컬럼·대상 컬럼 4개
ON DELETE RESTRICT 또는 NO ACTION
IDENTITY id 컬럼 6개
활성 신청 부분 고유 인덱스
민감정보 전용 컬럼 이름 0개
```

---

## 업무 정합성 검증

`06_business_validation.sql`의 이상 조회는 모두 0행이어야 합니다.

```text
학생·강사 이메일 중복
필수 문자열 공백
합의 금액·결제 금액 불일치
결제·환불 시각 조합 위반
고아 학생·강의·결제 참조
활성 신청 중복
샘플 수강·결제 상태 조합 위반
```

상태 조합 검증은 `LEFT JOIN`의 NULL을 놓치지 않도록 `IS DISTINCT FROM`을 사용합니다.

```text
완료 → 결제완료 필수
취소 → 환불 필수
신청 → 결제 없음 허용, 있으면 결제대기
수강중 → 결제 없음 허용, 있으면 결제완료
```

현재 가격과 신청 시점 합의 금액 차이는 정보용 1행이며 자동 오류가 아닙니다.

---

## 반례와 정상 경계값

`07_negative_tests.sql`은 다음 정보를 기록합니다.

```text
test_id
expected_sqlstate / actual_sqlstate
expected_constraint / actual_constraint
actual_table / actual_column
actual_result / detail
```

기준:

```text
P13-T01~P13-T22 expected_failure
P13-T23~P13-T27 expected_success
전체 27
통과 27
unexpected 0
기준 행 수 유지
```

정상 경계값에는 다음이 포함됩니다.

```text
가격 0
한 글자 이름·제목
NULL description
결제 없는 신청
완료·취소 이력 후 재신청
결제실패 + 금액 0 + 시각 NULL
```

오류만 테스트하면 지나치게 강한 제약조건이 정상 데이터를 막는 문제를 발견하기 어렵습니다.

---

## 최종 자동 검증

`08_ai_review_lab_validation.sql`은 다음을 다시 판정합니다.

```text
Chapter 07 신청 5행 유지
기준 행 수 3/3/2/3/4/4
정상 JOIN 4
정확한 테이블 집합
제약조건 29·FK 4·IDENTITY 6
활성 신청 부분 고유 인덱스
필수 문자열·고아 관계·활성 중복 0
금액·시간·상태 조합 위반 0
정보용 가격 차이 1행
모든 IDENTITY 다음 값 > 현재 최대 ID
같은 세션이면 07의 27/27 결과 재확인
```

통과 메시지:

```text
Chapter 13 AI review lab validation passed
```

---

## AI 변경 검토 기준

```text
- 확인 요구사항과 미확정 정책을 분리합니다.
- 수정 대상과 금지 범위를 명시합니다.
- 실제 개인정보·비밀번호·토큰·접속 URL을 전달하지 않습니다.
- DROP·ALTER·UPDATE·DELETE·Role 변경은 별도 위험으로 검토합니다.
- 정상·경계값·반례·메타데이터·업무 정합성 검증을 모두 실행합니다.
- Codex 변경은 파일별 diff를 사람이 검토합니다.
- SQLSTATE뿐 아니라 실제 constraint name을 확인합니다.
- 검증하지 않은 항목은 통과로 표시하지 않습니다.
- 승인·조건부 승인·보류·거절 중 하나로 기록합니다.
```
