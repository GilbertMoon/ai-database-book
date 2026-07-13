# Chapter 07 프로젝트 코드

## 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

이 폴더는 Chapter 07 프로젝트를 전용 PostgreSQL 스키마에서 단계별로 재현하고 검증하는 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_course_project_schema.sql` | `course_project` 스키마와 네 테이블·제약조건 생성 |
| `02_course_project_seed.sql` | 기본 정상 데이터 3/2/3/4행 입력 |
| `03_course_project_changes.sql` | 신규 신청과 완료·취소 상태 변경 |
| `04_course_project_validation.sql` | 최종 3/2/3/5행과 관계·도메인 규칙 검증 |
| `05_course_project_integrity_tests.sql` | 실패해야 하는 무결성 오류 SQL 모음 |
| `reset_course_project.sql` | 필요할 때만 프로젝트 스키마 초기화 |
| `PROJECT_DECISIONS.md` | 범위·가정·대안·AI 제안과 검증 결과 기록 |
| `online_course_project.sql` | 기존 링크 호환용 안내와 최종 상태 확인 |

---

## 프로젝트 객체

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

전용 스키마를 사용하므로 Chapter 04의 `public.students` 같은 앞 장 테이블과 충돌하지 않습니다.

---

## 기본 실행 순서

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
→ 05_course_project_integrity_tests.sql에서 한 문장씩 선택 실행
```

1. DBeaver에서 `ai_database_book`에 연결합니다.
2. 현재 데이터베이스를 확인합니다.
3. `01` 파일로 전용 스키마와 테이블을 생성합니다.
4. `02` 파일로 기본 샘플을 입력합니다.
5. `03` 파일로 변경 시나리오를 한 번 실행합니다.
6. `04` 파일로 최종 상태를 확인합니다.
7. `05` 파일의 오류 SQL을 하나씩 실행합니다.
8. 실행 결과를 `PROJECT_DECISIONS.md`에 기록합니다.

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
1001 완료
1004 취소
1005 신청
```

이 최종 상태가 Chapter 08의 JOIN과 집계 실습 기준입니다.

---

## 샘플 ID

```text
students: 101, 102, 103
instructors: 201, 202
courses: 301, 302, 303
enrollments: 1001~1005
```

`IDENTITY`를 사용하지만 관계 실습의 재현성을 위해 샘플 ID를 명시적으로 입력합니다.

---

## 적용한 규칙

```text
학생·강사 이메일 UNIQUE
이름·전문분야·제목 공백 CHECK
강의 level 허용값 CHECK
강의 가격·실제 결제 금액 0 이상 CHECK
수강 상태 허용값 CHECK
학생·강사·강의 FK
참조 중인 부모 삭제 RESTRICT
```

같은 학생의 같은 강의 중복 신청 제한은 재신청 정책이 확정되지 않아 적용하지 않습니다.

---

## 오류 테스트 방법

`05_course_project_integrity_tests.sql`의 오류 SQL은 모두 주석 처리되어 있습니다.

```text
1. 하나의 SQL만 주석 해제한다.
2. 해당 문장만 선택 실행한다.
3. 오류 메시지와 제약조건을 확인한다.
4. 정상 데이터 행 수가 유지되는지 확인한다.
5. 다시 주석 처리한 뒤 다음 테스트로 이동한다.
```

오류가 발생해야 정상인 테스트입니다.

---

## 초기화가 필요한 경우

생성·샘플·변경 파일은 기존 객체를 자동 삭제하지 않습니다.

처음부터 다시 시작해야 할 때만 다음 파일을 사용합니다.

```text
reset_course_project.sql
```

이 파일은 `course_project` 스키마의 네 테이블과 스키마를 삭제합니다. 현재 데이터베이스가 `ai_database_book`인지 확인한 뒤 DROP 구간만 선택 실행합니다.

---

## 안전 원칙

```text
- 파일을 임의 순서로 반복 실행하지 않습니다.
- 03 변경 파일은 한 번만 실행합니다.
- 취소 신청은 기본적으로 삭제하지 않고 상태로 보존합니다.
- 요구사항 근거 없는 CASCADE와 복합 UNIQUE를 추가하지 않습니다.
- 실제 개인정보, 비밀번호와 내부 URL을 저장하지 않습니다.
- AI가 만든 SQL은 PostgreSQL 실행과 오류 테스트로 검증합니다.
```
