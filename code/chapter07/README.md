# Chapter 07 프로젝트 코드

## 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

이 폴더는 Chapter 07 프로젝트를 전용 PostgreSQL 스키마에서 단계별로 재현하고 검증하는 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_course_project_schema.sql` | `course_project` 스키마, 네 테이블, 제약조건과 활성 신청 부분 고유 인덱스 생성 |
| `02_course_project_seed.sql` | 기본 정상 데이터 3/2/3/4행 입력과 IDENTITY 시작값 조정 |
| `03_course_project_changes.sql` | 신규 신청, 상태 전이 조건을 포함한 완료·취소 변경과 IDENTITY 재조정 |
| `04_course_project_validation.sql` | 최종 3/2/3/5행, 관계·도메인·활성 중복·검산값 확인 |
| `05_course_project_integrity_tests.sql` | 성공해야 하는 경계값과 실패해야 하는 오류값 테스트 |
| `reset_course_project.sql` | 데이터베이스 보호 구문 안에서 프로젝트 스키마 초기화 |
| `PROJECT_DECISIONS.md` | 요구사항·결정·미확정 질문·AI 제안과 검증 결과 기록 |
| `online_course_project.sql` | 기존 링크 호환용 읽기 전용 안내와 최종 상태 확인 |

---

## 프로젝트 객체

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

전용 스키마를 사용하므로 Chapter 04의 `public.students` 같은 앞 장 테이블과 충돌하지 않습니다. 모든 SQL은 스키마 한정 이름을 사용하므로 `current_schema()`가 `course_project`일 필요는 없습니다.

---

## 기본 실행 순서

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
→ 05_course_project_integrity_tests.sql에서 한 구간씩 선택 실행
```

1. DBeaver에서 `ai_database_book`에 연결합니다.
2. 다음 SQL로 현재 위치를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

3. 자동 커밋 상태를 확인합니다.
4. `01` 파일로 전용 스키마와 테이블을 생성합니다.
5. `02` 파일로 기본 샘플을 입력하고 IDENTITY 다음 값을 조정합니다.
6. `03` 파일을 한 번 실행하며 각 `RETURNING` 결과를 확인합니다.
7. `04` 파일로 최종 상태와 검산값을 확인합니다.
8. `05` 파일의 경계·오류 SQL을 한 구간씩 실행합니다.
9. 결과를 `PROJECT_DECISIONS.md`에 기록합니다.

> 자동 커밋 상태에서는 `03` 변경 시나리오의 일부만 반영될 수 있습니다. 문장을 순서대로 실행하고 각 결과를 확인합니다. 여러 변경을 하나의 작업으로 묶는 방법은 Chapter 09에서 다룹니다.

---

## 데이터 상태 기준

### 기본 샘플 입력 직후

| 테이블 | 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 4 |

### 변경 시나리오 이후

| 테이블 | 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 5 |

```text
1001 완료 / paid_amount 100000
1004 취소 / paid_amount 150000
1005 신청 / paid_amount 120000
```

취소된 신청의 `paid_amount`는 신청 당시 기록된 금액입니다. 환불 금액과 환불 상태는 현재 프로젝트 범위에 포함되지 않습니다.

이 최종 상태가 Chapter 08의 JOIN과 집계 실습 기준입니다.

---

## 샘플 ID와 IDENTITY

```text
students: 101, 102, 103        → 다음 자동값 104
instructors: 201, 202           → 다음 자동값 203
courses: 301, 302, 303          → 다음 자동값 304
enrollments seed: 1001~1004     → seed 다음 값 1005
enrollments changes: 1005       → 최종 다음 자동값 1006
```

`IDENTITY`를 사용하지만 관계 실습의 재현성을 위해 샘플 ID를 명시적으로 입력합니다. 명시적 ID는 IDENTITY 시퀀스의 다음 값을 자동으로 변경하지 않으므로 `RESTART WITH`를 사용합니다.

---

## 핵심 정책

| ID | 정책 | 구현 |
| --- | --- | --- |
| P07-D01 | 무료 강의와 무료 신청 금액은 0 | 금액 `NOT NULL`, `CHECK >= 0` |
| P07-D02 | 취소 신청과 신청 당시 금액 보존 | 상태 변경, 행 삭제·금액 0 처리 안 함 |
| P07-D03 | 같은 학생·강의의 진행 중 신청은 한 건 | 부분 고유 인덱스 |
| P07-D04 | 상태 변경 시 이전 상태 확인 | `WHERE id ... AND status ...` |
| P07-D07 | 참조 중 부모 삭제 금지 | `ON DELETE RESTRICT` |

```sql
CREATE UNIQUE INDEX uq_course_enrollments_active
ON course_project.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

`완료`나 `취소` 이력 뒤에는 새 신청을 만들 수 있지만 `신청` 또는 `수강중` 상태의 중복 행은 차단합니다.

---

## 이메일 범위

학생과 강사 이메일은 다음 규칙을 사용합니다.

```text
NOT NULL
공백 문자열 금지
각 테이블 안에서 정확히 같은 문자열 중복 금지
```

대소문자, 별칭과 형식 정규화는 현재 프로젝트 범위가 아닙니다.

---

## 경계·오류 테스트 방법

`05_course_project_integrity_tests.sql`의 변경 SQL은 모두 주석 처리되어 있습니다.

```text
1. 하나의 테스트 구간만 주석 해제한다.
2. 해당 문장들을 안내된 순서로 실행한다.
3. 성공해야 하는 경계값인지 실패해야 하는 오류값인지 확인한다.
4. 오류 메시지와 제약조건·인덱스 이름을 확인한다.
5. 임시 행을 삭제하고 기준 행 수가 유지되는지 확인한다.
6. 다시 주석 처리한 뒤 다음 테스트로 이동한다.
```

성공해야 하는 경계값:

```text
가격 0인 무료 강의
paid_amount 0인 무료 신청
description NULL
한 글자 학생 이름
완료 이력 뒤 같은 강의 재신청
참조되지 않는 학생 삭제
```

실패해야 하는 오류값:

```text
학생·강사 이름 공백
학생·강사 이메일 공백·중복
강사 전문분야 공백
강의 제목 공백
잘못된 난이도·음수 가격
없는 학생·강사·강의 참조
잘못된 상태·음수 결제 금액
두 번째 활성 신청
참조 중인 부모 삭제
```

수동 커밋이나 명시적 트랜잭션에서 오류 후 다음 메시지가 나타나면:

```text
current transaction is aborted
```

다음 명령으로 실패한 트랜잭션을 종료합니다.

```sql
ROLLBACK;
```

---

## 초기화가 필요한 경우

처음부터 다시 시작해야 할 때만 다음 파일을 사용합니다.

```text
reset_course_project.sql
```

이 파일은 하나의 보호 구문 안에서 `current_database() = 'ai_database_book'`를 확인한 뒤 알려진 프로젝트 테이블을 자식에서 부모 순서로 삭제합니다. `DROP SCHEMA ... CASCADE`를 사용하지 않으므로 예상하지 않은 객체가 남아 있으면 스키마 삭제가 실패해 추가 검토를 요구합니다.

---

## 안전 원칙

```text
- 파일을 임의 순서로 반복 실행하지 않습니다.
- 03 변경 파일은 한 번만 실행합니다.
- UPDATE의 RETURNING이 0행이면 예상 이전 상태와 실제 상태를 확인합니다.
- 취소 신청은 삭제하지 않고 상태로 보존합니다.
- 취소 시 paid_amount를 자동으로 0으로 바꾸지 않습니다.
- 요구사항 근거 없는 CASCADE와 전체 이력 복합 UNIQUE를 추가하지 않습니다.
- 실제 개인정보, 비밀번호와 내부 URL을 저장하지 않습니다.
- AI가 만든 SQL은 PostgreSQL 실행, 경계값과 오류 테스트로 검증합니다.
```
