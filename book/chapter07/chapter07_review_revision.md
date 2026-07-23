# Chapter 07 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter07/chapter07.md
book/chapter07/chapter07_activity.md
book/chapter07/chapter07_outline.md
code/chapter07/01_course_project_schema.sql
code/chapter07/02_course_project_seed.sql
code/chapter07/03_course_project_changes.sql
code/chapter07/04_course_project_validation.sql
code/chapter07/05_course_project_integrity_tests.sql
code/chapter07/reset_course_project.sql
code/chapter07/PROJECT_DECISIONS.md
code/chapter07/online_course_project.sql
code/chapter07/README.md
notes/chapter07_review_checklist.md
README.md
```

## 검수 목적

Chapter 07을 요구사항에서 DDL을 만드는 예제에 머물지 않고, 정책 ID·IDENTITY·상태 전이·경계값·오류 복구와 Chapter 08 인계값까지 재현 가능한 프로젝트로 완성했습니다.

```text
범위
→ 요구사항·결정·질문 ID
→ ERD·DDL
→ 샘플·IDENTITY
→ 상태 기반 변경
→ 최종 검증
→ 경계·오류 테스트
→ AI 결정 기록
```

---

## 1. 요구사항 추적 체계 보완

프로젝트 정보를 다음 네 범주로 구분했습니다.

```text
P07-R: 확정 요구사항
P07-D: 프로젝트 결정
P07-Q: 미확정 질문
P07-O: 범위 제외
```

추적표는 `ID | 요구사항·결정 | 상태 | 반영 구조 | 검증` 형식으로 변경했습니다.

---

## 2. 무료 강의 정책 통일

기존에는 무료 강의의 `paid_amount`가 0인지 `NULL`인지 문서마다 달랐습니다.

다음 정책으로 통일했습니다.

```text
P07-D01
무료 강의의 courses.price와 enrollments.paid_amount는 0으로 저장한다.
0은 확정된 금액이고 NULL은 미확정·알 수 없는 상태와 구분한다.
```

가격 0인 강의와 `paid_amount = 0` 신청을 성공해야 하는 경계 테스트로 추가했습니다.

---

## 3. 선택 설명 요구사항 정합성

강의 `description`은 선택 속성으로 확정했습니다.

```sql
description TEXT
```

요구사항 문장을 “제목·선택 설명·난이도·가격·개설일”로 수정하고 `description = NULL` 경계 테스트를 추가했습니다.

---

## 4. 이메일 무결성 보완

학생·강사 이메일에 다음 규칙을 적용했습니다.

```text
NOT NULL
공백 문자열 CHECK
각 테이블에서 정확히 같은 문자열 UNIQUE
```

대소문자와 별칭 정규화는 범위 밖으로 명시했습니다.

오류 테스트에 학생·강사 이메일 공백과 강사 이메일 중복을 추가했습니다.

---

## 5. 진행 중 중복 신청 차단

전체 이력에 `UNIQUE(student_id, course_id)`를 적용하면 완료·취소 뒤 재신청까지 막을 수 있습니다.

다음 부분 고유 인덱스로 진행 중 신청만 제한했습니다.

```sql
CREATE UNIQUE INDEX uq_course_enrollments_active
ON course_project.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

```text
신청·수강중 중복 → 실패
완료·취소 이력 뒤 재신청 → 허용
```

---

## 6. 취소와 결제 금액 의미 보완

신청 1004가 취소되어도 `paid_amount = 150000`은 신청 당시 기록으로 남깁니다.

```text
취소 신청 행 삭제 안 함
paid_amount를 0으로 변경하지 않음
환불 금액·상태는 P07-O01 범위 제외
```

Chapter 08의 전체 저장 금액과 취소 제외 금액 차이를 Chapter 07에서 미리 설명했습니다.

---

## 7. IDENTITY 시작값 조정

명시적 ID 입력 뒤 다음 자동값을 조정했습니다.

```text
students      → 104
instructors   → 203
courses       → 304
enrollments   → seed 후 1005, changes 후 1006
```

`02_course_project_seed.sql`과 `03_course_project_changes.sql`에 `ALTER COLUMN ... RESTART WITH`를 추가했습니다.

---

## 8. 변경 시나리오 안전성 보완

상태 변경 SQL에 예상 이전 상태를 추가했습니다.

```sql
UPDATE course_project.enrollments
SET status = '완료'
WHERE id = 1001
  AND status = '수강중'
RETURNING *;
```

```sql
UPDATE course_project.enrollments
SET status = '취소'
WHERE id = 1004
  AND status = '신청'
RETURNING *;
```

`RETURNING`이 0행이면 예상 상태와 실제 상태가 다르므로 다음 단계로 넘어가지 않도록 안내했습니다.

자동 커밋에서는 변경 시나리오 일부만 반영될 수 있다는 경고도 추가했습니다.

---

## 9. 상태 CHECK의 범위 명확화

상태 `CHECK`는 허용값만 제한하며 상태 전이 순서를 보장하지 않는다는 설명을 추가했습니다.

```text
허용값: 신청·수강중·완료·취소
전이 순서: 변경 SQL의 이전 상태 조건으로 기본 확인
상태 이력·복잡한 전이: 확장 범위
```

---

## 10. 위치 확인 기준 통일

모든 SQL 파일에 다음 확인을 반영했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

프로젝트 객체에는 모두 `course_project`를 명시하므로 현재 스키마가 `course_project`일 필요는 없음을 설명했습니다.

---

## 11. 초기화 파일 안전성 강화

`reset_course_project.sql`은 하나의 보호 구문 안에서 현재 데이터베이스가 `ai_database_book`인지 확인합니다.

조건이 맞을 때만 알려진 프로젝트 테이블과 스키마를 삭제합니다.

`DROP SCHEMA ... CASCADE`는 사용하지 않습니다. 예상하지 않은 객체가 남아 있으면 스키마 삭제가 실패해 추가 확인을 요구합니다.

---

## 12. 경계·오류 테스트 확대

### 성공해야 하는 경계

```text
무료 강의 가격 0
무료 신청 paid_amount 0
description NULL
한 글자 학생 이름
완료 이력 뒤 재신청
참조되지 않는 학생 삭제
```

### 실패해야 하는 오류

```text
학생·강사 이름 공백
학생·강사 이메일 공백·중복
강사 전문분야 공백
강의 제목 공백
잘못된 난이도·음수 가격
없는 부모 참조
잘못된 상태·음수 결제 금액
두 번째 활성 신청
참조 중 부모 삭제
```

수동 커밋 상태에서 오류 후 `current transaction is aborted`가 나타나면 `ROLLBACK;`을 실행하도록 안내했습니다.

---

## 13. 최종 검증과 Chapter 08 인계

`04_course_project_validation.sql`에 다음 검증을 추가했습니다.

```text
이메일·공백 도메인 위반 0행
고아 관계 0행
활성 중복 신청 0행
전체 저장 금액 590000
취소 제외 금액 440000
```

Chapter 08 인계 기준은 다음과 같습니다.

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료 / 100000
1004 취소 / 150000
1005 신청 / 120000
```

---

## 14. 자기주도 학습 보완

본문과 워크북에 다음 내용을 추가했습니다.

```text
요구사항 ID 작성
무료 강의 0 정책
이메일 공백과 정확 문자열 고유성
IDENTITY 시작값
부분 고유 인덱스
상태 전이 조건
자동 커밋 부분 실행
경계·오류 테스트
ROLLBACK
금액 검산
권장 해설
```

---

## 15. 도식 처리

기존 SVG 8종은 프로젝트 흐름, 엔터티, ERD, N:M 해소, 정규화, 검증, AI 검토와 완료 점검의 핵심 의미와 호환됩니다.

부분 고유 인덱스, IDENTITY 시작값과 세부 테스트는 본문·SQL·표가 더 적합하므로 이미지에 과도하게 추가하지 않았습니다.

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 요구사항·결정·질문 ID | 완료 |
| 무료 금액 정책 통일 | 완료 |
| description 선택성 일치 | 완료 |
| 이메일 공백·중복 규칙 | 완료 |
| 활성 신청 부분 고유 인덱스 | 완료 |
| 취소 금액 의미 | 완료 |
| IDENTITY 시작값 조정 | 완료 |
| 이전 상태 조건 UPDATE | 완료 |
| 자동 커밋 경고 | 완료 |
| 위치 확인 통일 | 완료 |
| 초기화 보호 구문 | 완료 |
| 경계·오류 테스트 | 완료 |
| `ROLLBACK` 안내 | 완료 |
| Chapter 08 인계 검산 | 완료 |
| 권장 해설 | 완료 |

## 결론

```text
Chapter 07은 요구사항과 ERD를 만드는 프로젝트에서 확장되어,
정책 ID·재현 가능한 IDENTITY·상태 기반 변경·경계와 오류 증거를
Chapter 08의 분석 기준까지 연결하는 완성형 입문 프로젝트가 되었다.
```

실제 PostgreSQL 전체 순차 실행과 출판 렌더링은 별도 제작 단계에서 확인합니다.
