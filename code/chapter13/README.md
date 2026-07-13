# Chapter 13 실습 코드

## AI와 실행 증거로 데이터베이스 설계 검증하기

이 폴더는 AI가 만든 데이터베이스 설계와 SQL을 `ai_review_lab`에서 격리하고, 요구사항·메타데이터·정상·반례·업무 정합성·diff를 근거로 검토하는 파일을 관리합니다.

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

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_ai_review_lab_schema.sql` | 전용 스키마와 역할이 섞인 나쁜 설계 테이블 생성 |
| `02_bad_design_seed.sql` | 반복·약한 타입·FK 부재·평문 민감정보 형태의 가상 데이터 입력 |
| `03_good_design_schema.sql` | IDENTITY·명시적 PK·FK·UNIQUE·CHECK 기반 좋은 설계 |
| `04_good_design_seed.sql` | 명시적 ID 정상 데이터 입력 |
| `05_metadata_validation.sql` | 실제 테이블·컬럼·제약조건·FK·인덱스 검증 |
| `06_business_validation.sql` | 행 수·정상 JOIN·업무 이상 0행 검증 |
| `07_negative_tests.sql` | 예외 블록 기반 17개 안전한 반례 테스트 |
| `AI_REVIEW_REPORT_TEMPLATE.md` | 요구사항·diff·증거·승인 상태 기록 |
| `PROMPT_TEMPLATES.md` | ERD·DDL·Codex 수정·마이그레이션 검토 프롬프트 |
| `reset_ai_review_lab.sql` | ai_review_lab만 초기화 |
| `ai_db_design_review_practice.sql` | 기존 링크 호환용 안내·상태 확인 |

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
→ AI_REVIEW_REPORT_TEMPLATE.md 기록
```

처음부터 다시 시작할 때만 `reset_ai_review_lab.sql`을 사용합니다.

---

## 확인된 요구사항

```text
R1 학생 email UNIQUE
R2 강사 email UNIQUE
R3 강의는 강사 한 명을 FK로 참조
R4 학생과 강의 N:M을 enrollments로 해소
R5 수강 상태 CHECK
R6 가격·금액 0 이상
R7 결제는 수강신청을 FK로 참조
R8 실제 카드번호를 저장하지 않음
```

미확정 정책:

```text
취소 후 재신청
결제 시도 이력
삭제 정책
개인정보 보관 기간
상태 전이 규칙
```

미확정 정책은 UNIQUE·CASCADE·NOT NULL로 임의 고정하지 않습니다.

---

## 기준 데이터

| 항목 | 기대값 |
| --- | ---: |
| `ai_review_lab.bad_enrollments` | 3 |
| `ai_review_lab.students` | 3 |
| `ai_review_lab.instructors` | 2 |
| `ai_review_lab.courses` | 3 |
| `ai_review_lab.enrollments` | 4 |
| `ai_review_lab.payments` | 4 |
| 정상 JOIN | 4 |
| 외래키 | 4 |

명시적 ID:

```text
students 101~103
instructors 201~202
courses 301~303
enrollments 1001~1004
payments 9001~9004
```

자동 증가값이 1부터 연속이라는 가정에 의존하지 않습니다.

---

## 좋은 설계 핵심

```text
students.email UNIQUE
instructors.email UNIQUE
courses.course_code UNIQUE
courses.instructor_id FK
students·courses N:M은 enrollments로 해소
enrollments.agreed_amount는 신청 시점 금액
payments.amount는 결제 기록 금액
payments.enrollment_id UNIQUE는 현재 결제 상태 1건이라는 단순화 가정
실제 카드번호 컬럼 없음
```

재신청 정책이 미확정이므로 `UNIQUE(student_id, course_id)`는 적용하지 않습니다.

---

## 메타데이터 검증

`05_metadata_validation.sql`은 다음을 확인합니다.

```text
테이블 6개
좋은 설계 테이블 5개
FK 4개
IDENTITY PK 5개
민감정보 형태 컬럼 0개
재신청 복합 UNIQUE 0개
PK·FK·UNIQUE·CHECK 실제 정의
자동·수동 인덱스
DELETE·UPDATE 규칙
```

DDL 파일만 읽지 않고 실제 PostgreSQL 카탈로그를 확인합니다.

---

## 업무 정합성 검증

`06_business_validation.sql`의 이상 조회 기대 결과는 모두 0행입니다.

```text
학생·강사 이메일 중복
합의 금액·결제금액 불일치
결제 상태·paid_at 조합 위반
고아 학생·강의·결제 참조
샘플 수강·결제 상태 조합 위반
```

현재 강의 가격과 신청 시점 금액 차이는 정보용으로 1행이 예상됩니다. 할인·가격 변경이므로 자동 오류가 아닙니다.

---

## 안전한 반례 테스트

`07_negative_tests.sql`은 임시 결과 테이블과 PostgreSQL 예외 블록을 사용합니다.

```text
테스트 1~16: expected_failure
테스트 17: expected_success
unexpected 결과: 0
```

예상 오류가 발생하면 해당 하위 트랜잭션의 변경이 자동 취소됩니다. 따라서 테스트 후 기준 행 수는 그대로 유지됩니다.

반례 유형:

```text
unique_violation
foreign_key_violation
check_violation
재신청 정책을 복합 UNIQUE로 강제하지 않았는지 확인
```

---

## AI 변경 검토 기준

```text
- 확인 요구사항과 미확정 정책을 분리합니다.
- 수정 대상과 금지 범위를 명시합니다.
- 실제 개인정보·비밀번호·토큰·접속 URL을 전달하지 않습니다.
- DROP·ALTER·UPDATE·DELETE·Role 변경은 별도 위험으로 검토합니다.
- 정상·반례·메타데이터·업무 정합성 검증을 모두 실행합니다.
- Codex 변경은 파일별 diff를 사람이 검토합니다.
- 검증하지 않은 항목은 통과로 표시하지 않습니다.
- 승인·조건부 승인·보류·거절 중 하나로 기록합니다.
```
