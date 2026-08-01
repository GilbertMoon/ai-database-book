# Chapter 07 프로젝트 코드

## 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

이 폴더는 Chapter 07 프로젝트를 전용 PostgreSQL 스키마에서 단계별로 생성·변경·검증하는 파일을 관리합니다.

## 프로젝트 객체

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

모든 SQL은 스키마 한정 이름을 사용하므로 `current_schema()`가 `course_project`일 필요는 없습니다.

## 파일 목록

| 파일 | 시작 상태 | 완료 상태 | 반복 실행 |
| --- | --- | --- | --- |
| `01_course_project_schema.sql` | course_project 없음 | 스키마·네 테이블·인덱스 | 한 번 |
| `02_course_project_seed.sql` | 네 테이블 비어 있음 | 기본 3/2/3/4행 | 한 번 |
| `03_course_project_changes.sql` | 기본 샘플 상태 | 최종 3/2/3/5행 | 한 번 |
| `04_course_project_validation.sql` | 최종 상태 | 자동 완료 검증 | 가능 |
| `05_course_project_integrity_tests.sql` | 최종 상태 | 핵심 경계·오류 테스트 | 한 구간씩 |
| `06_course_project_optional_tests.sql` | 최종 상태 | 선택 경계·오류 테스트 | 한 구간씩 |
| `reset_course_project.sql` | 어떤 프로젝트 상태 | 프로젝트 객체 삭제 | 필요할 때만 |
| `PROJECT_DECISIONS.md` | 프로젝트 진행 중 | 설계·검증 기록 | 계속 갱신 |
| `online_course_project.sql` | 최종 상태 | 읽기 전용 호환 확인 | 가능 |

## 최소 완료 경로

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

처음부터 다시 시작할 때:

```text
reset_course_project.sql
→ 01
→ 02
→ 03
→ 04
```

## 공통 안전 원칙

```text
1. ai_database_book 연결인지 확인한다.
2. 현재 사용자와 search_path를 확인한다.
3. 쓰기 가능한 연결인지 확인한다.
4. 파일의 시작 상태를 자동 검사한다.
5. 생성·입력·변경 작업은 트랜잭션으로 묶는다.
6. 오류 테스트는 하나의 구간만 실행한다.
7. 완료 후 04 검증 파일을 다시 실행한다.
```

`01`, `02`, `03` 파일은 시작 상태와 완료 상태를 자동으로 검사합니다. 중간 문장에서 오류가 발생하면 `COMMIT`되지 않으며, 필요하면 `ROLLBACK` 후 원인을 확인합니다.

## 금액 열의 의미

```text
course_project.courses.price
→ 현재 강의 기준 가격

course_project.enrollments.recorded_amount
→ 신청 시점에 신청 행에 기록한 금액
```

두 열은 다음 타입을 사용합니다.

```sql
NUMERIC(12, 0)
```

`recorded_amount`는 실제 결제 승인액이나 환불 후 순수 금액이 아닙니다. 실제 결제·환불 이력은 현재 프로젝트 범위 밖입니다.

## 핵심 프로젝트 결정

| ID | 결정 | 구현 |
| --- | --- | --- |
| P07-D01 | 무료 금액은 0 | NOT NULL·CHECK |
| P07-D02 | 신청 시 금액 보존 | recorded_amount |
| P07-D03 | 진행 중 중복 신청 금지 | 부분 고유 인덱스 |
| P07-D04 | 예상 이전 상태 확인 | 사전 검사·조건부 UPDATE |
| P07-D05 | 학생·강사 별도 역할 | 별도 테이블 |
| P07-D06 | 참조 중 부모 삭제 제한 | RESTRICT |

```sql
CREATE UNIQUE INDEX uq_course_enrollments_active
ON course_project.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

## 데이터 상태 기준

### 기본 샘플

```text
students 3
instructors 2
courses 3
enrollments 4
recorded_amount 합계 470000
```

### 최종 상태

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료 / recorded_amount 100000
1004 취소 / recorded_amount 150000
1005 신청 / recorded_amount 120000
활성 중복 0
전체 recorded_amount 590000
취소 제외 recorded_amount 440000
```

## 자동 검증

`04_course_project_validation.sql`은 다음 항목을 자동 판정합니다.

```text
행 수
고아 관계
공백·허용값·금액 범위
활성 중복 신청
1001·1004·1005 상태와 금액
전체·취소 제외 기록 금액
```

통과 메시지:

```text
Chapter 07 course project validation passed
```

## 핵심 테스트

`05_course_project_integrity_tests.sql`:

```text
무료 금액 0 성공
학생 이메일 중복 실패
잘못된 난이도 실패
음수 recorded_amount 실패
없는 부모 참조 실패
두 번째 활성 신청 실패
참조 중 부모 삭제 실패
```

`06_course_project_optional_tests.sql`:

```text
description NULL·한 글자 이름 성공
완료 뒤 재신청 성공
참조되지 않는 학생 삭제 성공
공백 이름·이메일·전문분야 실패
강사 이메일 중복 실패
음수 가격·잘못된 상태 실패
```

## 초기화

`reset_course_project.sql`은 다음을 확인합니다.

```text
current_database = ai_database_book
읽기 전용 연결 아님
course_project 스키마 존재 여부
```

알려진 테이블을 자식→부모 순서로 삭제하고 `DROP SCHEMA ... CASCADE`는 사용하지 않습니다. 예상하지 않은 객체가 남아 있으면 스키마 삭제가 실패하여 추가 검토를 요구합니다.

## Chapter 08 인계

Chapter 08의 JOIN·집계 실습 전에 `04_course_project_validation.sql`을 실행해 통과 메시지를 확인합니다.
