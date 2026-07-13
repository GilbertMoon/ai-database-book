# Chapter 13 실습 코드

## ChatGPT와 Codex로 DB 설계 검증하기

이 폴더는 AI가 만든 데이터베이스 설계 초안과 사람이 요구사항을 기준으로 보완한 PostgreSQL 설계를 비교하는 실습 파일을 관리합니다.

## 파일

| 파일 | 설명 |
| --- | --- |
| `ai_db_design_review_practice.sql` | 나쁜 설계, 좋은 설계, 샘플 데이터, 오류 테스트, 메타데이터와 업무 정합성 검증 |

## 실행 전 주의

```text
- 파일은 ai_bad_ 및 ai_good_ 테이블을 삭제하고 다시 생성합니다.
- 개인 실습용 ai_database_book에서만 실행합니다.
- current_database, current_user, current_schema를 먼저 확인합니다.
- 실제 개인정보, 카드번호, 비밀번호, API 키와 접속 URL을 사용하지 않습니다.
- AI가 만든 SQL을 자동 실행하지 않고 먼저 읽고 검토합니다.
```

## Chapter 13 좋은 설계의 기준

```text
- 좋은 설계 테이블: students, instructors, courses, enrollments, payments
- 학생·강사 이메일: UNIQUE
- 강의 식별자: course_code UNIQUE
- 학생과 강의 N:M: enrollments로 해소
- 재신청 정책 미확정: UNIQUE(student_id, course_id) 미적용
- 신청 시점 금액: enrollments.agreed_amount
- 결제금액: payments.amount
- 결제 참조: payments.enrollment_id → enrollments.id
- 실제 카드번호: 저장하지 않음
```

이 장은 한 수강신청에 현재 결제 상태 한 건만 저장한다고 가정하므로 `payments.enrollment_id`에 `UNIQUE`를 사용합니다. 결제 시도, 실패, 재결제와 환불 이력을 모두 저장하려면 이 제약을 제거하고 결제 이벤트 모델로 확장해야 합니다.

`courses.price`는 현재 기본 가격이고 `enrollments.agreed_amount`는 신청 시점에 확정한 금액입니다. 두 값의 차이는 자동 오류가 아닙니다. 이 단순 샘플에서는 `agreed_amount`와 `payments.amount`가 일치하는지 검증합니다.

## 권장 실행 흐름

1. 현재 DB·사용자·스키마를 확인합니다.
2. SQL 파일의 DROP 대상을 확인합니다.
3. 나쁜 설계와 명확한 가상 데이터를 확인합니다.
4. 좋은 설계의 요구사항과 단순화 가정을 확인합니다.
5. 기본 SQL을 처음부터 실행합니다.
6. 예상 행 수와 정상 JOIN 4행을 확인합니다.
7. `information_schema`와 `pg_indexes` 결과를 확인합니다.
8. 오류 SQL은 하나씩 선택적으로 실행합니다.
9. 업무 정합성 이상 조회가 0행인지 확인합니다.
10. Codex 수정이 있다면 diff를 검토하고 다시 실행합니다.

## 예상 결과

| 항목 | 예상값 |
| --- | ---: |
| `ai_bad_enrollments` | 3 |
| `ai_good_students` | 3 |
| `ai_good_instructors` | 2 |
| `ai_good_courses` | 3 |
| `ai_good_enrollments` | 4 |
| `ai_good_payments` | 4 |
| 정상 JOIN | 4행 |
| FK 관계 | 4개 |

## 오류 테스트

오류 SQL은 기본적으로 주석 상태입니다. 한꺼번에 실행하지 말고 하나씩 확인합니다.

- 중복 학생·강사 이메일
- 존재하지 않는 학생·강의 FK
- 잘못된 수강·결제 상태
- 음수 가격·신청 금액·결제금액
- 결제완료인데 `paid_at`이 NULL
- 중복 `payment_reference`

명시적 트랜잭션에서 오류가 발생해 세션이 aborted 상태가 되면 `ROLLBACK`한 뒤 정상 SELECT를 다시 실행합니다.

## 메타데이터 도구

- `information_schema`: 테이블, 컬럼, 제약조건과 CHECK 정의 확인
- `pg_indexes`: PostgreSQL 인덱스 정의 확인

테이블 생성 성공만으로 설계가 올바르다고 판단하지 않습니다. 예상 설계와 실제 메타데이터, 행 수, 정상 JOIN, 오류 테스트와 업무 정합성 결과를 함께 확인합니다.

## Codex 변경 후 확인

```text
- 요청한 파일만 바뀌었는가?
- 요구사항 없는 UNIQUE·CASCADE가 추가되지 않았는가?
- 실제 비밀정보가 포함되지 않았는가?
- 예상 행 수, JOIN 4행과 FK 4개가 유지되는가?
- 관련 없는 포맷 변경이나 다른 Chapter 수정이 없는가?
```

ChatGPT와 Codex의 기능과 지원 환경은 바뀔 수 있으므로 제품 기능은 작업 시점의 공식 OpenAI 문서를 기준으로 확인합니다.
