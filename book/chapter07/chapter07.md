# Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

---

## 이 장에서 완성할 프로젝트

Chapter 01~06에서는 데이터베이스를 배우는 이유, PostgreSQL 환경, 기본 SQL, 요구사항 분석, ERD, 정규화와 데이터 무결성을 차례로 살펴보았습니다. 이번 장에서는 이 내용을 하나의 작은 서비스에 통합합니다.

프로젝트 주제는 **온라인 강의 수강신청 시스템**입니다.

```text
서비스 범위 결정
→ 요구사항·결정·미확정 질문 구분
→ 엔터티·속성·관계 도출
→ 관계 문장과 ERD 작성
→ 정규화·무결성 검토
→ PostgreSQL 전용 스키마 구현
→ 정상 샘플과 IDENTITY 조정
→ 상태를 확인하며 변경 시나리오 실행
→ 조회·경계·오류 데이터로 검증
→ AI 제안과 사람의 수정 기록
```

![프로젝트 진행 흐름](../../images/chapter07/ch07_01_project_flow.svg)

그림 7-1 온라인 강의 데이터베이스 프로젝트 핵심 흐름

이 프로젝트의 핵심은 SQL의 양이 아닙니다. 다음 내용을 서로 연결해 설명할 수 있어야 합니다.

```text
요구사항·결정 ID
→ 설계 결정
→ ERD 구조
→ 제약조건과 인덱스
→ 샘플·변경 데이터
→ 검증 결과
```

> **완료 기준**
>
> 다른 사람이 프로젝트 파일을 순서대로 실행했을 때 같은 구조와 데이터를 만들 수 있고, 각 테이블·제약조건·인덱스가 어떤 요구사항이나 결정에 근거하는지 설명할 수 있어야 합니다.

---

## 1. 프로젝트 산출물과 실행 구조

이 장에서는 다음 산출물을 완성합니다.

| 산출물 | 확인 내용 |
| --- | --- |
| 프로젝트 범위 | 포함·제외 기능과 단순화 가정 |
| 확정 요구사항 | 서비스가 반드시 지켜야 할 데이터와 관계 |
| 프로젝트 결정 | 이번 버전에서 명시적으로 선택한 정책 |
| 미확정 질문 | 운영 전에 추가 확인할 정책 |
| 요구사항 추적표 | ID와 테이블·열·제약조건·테스트 연결 |
| 관계 문장 | 카디널리티와 필수·선택 관계 |
| ERD | 네 테이블과 PK·FK |
| PostgreSQL DDL | 전용 스키마, 제약조건과 부분 고유 인덱스 |
| 정상 샘플 데이터 | 관계와 규칙을 검증하는 기준 데이터 |
| 변경 시나리오 | 안전한 INSERT와 상태 전이 조건을 포함한 UPDATE |
| 검증 SQL | 행 수·관계·도메인·검산값 확인 |
| 경계·오류 테스트 | 허용해야 할 경계와 거부해야 할 오류 |
| 설계 결정 기록 | AI 초안과 사람의 최종 수정 근거 |

실행 파일은 다음처럼 역할별로 분리합니다.

```text
code/chapter07/
├── 01_course_project_schema.sql
├── 02_course_project_seed.sql
├── 03_course_project_changes.sql
├── 04_course_project_validation.sql
├── 05_course_project_integrity_tests.sql
├── reset_course_project.sql
├── PROJECT_DECISIONS.md
├── online_course_project.sql
└── README.md
```

`online_course_project.sql`은 기존 링크 호환을 위한 읽기 전용 안내 파일입니다. 프로젝트 생성 파일이 아니며 `01~03` 파일을 실행한 상태에서만 최종 확인용으로 사용합니다.

---

## 2. 전용 스키마를 사용하는 이유

앞 장에서는 `public` 스키마에 여러 실습 테이블을 만들었습니다. Chapter 07 프로젝트는 다음 전용 스키마 안에 구성합니다.

```text
course_project
├── students
├── instructors
├── courses
└── enrollments
```

전용 스키마를 사용하면 다음 장점이 있습니다.

```text
앞 장의 public.students 같은 동명 테이블과 충돌하지 않는다.
프로젝트 객체의 범위가 분명하다.
초기화할 대상을 정확하게 구분할 수 있다.
Chapter 08 이후에도 같은 프로젝트 데이터를 명확하게 참조할 수 있다.
```

SQL에서는 테이블 이름을 완전하게 작성합니다.

```sql
SELECT *
FROM course_project.students;
```

이 방식은 `search_path`에 따라 다른 테이블을 조회하는 실수를 줄입니다. 실행 전에는 다음 세 문장으로 현재 위치를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

모든 객체에 `course_project`를 명시하므로 `current_schema()`가 `course_project`일 필요는 없습니다. 현재 데이터베이스가 `ai_database_book`인지 확인하는 것이 핵심입니다.

---

## 3. 프로젝트 범위와 설계 선택

이번 기본 버전은 다음 네 테이블에 집중합니다.

```text
students
instructors
courses
enrollments
```

기본 범위에서 제외하는 기능은 다음과 같습니다.

| ID | 제외 기능 |
| --- | --- |
| `P07-O01` | 결제 시도·실패·환불 이력 |
| `P07-O02` | 강의 정원과 대기 순번 |
| `P07-O03` | 상태 변경 이력 |
| `P07-O04` | 진도율과 수료증 |
| `P07-O05` | 강의 영상·섹션·레슨 |
| `P07-O06` | 수강평과 별점 |
| `P07-O07` | 쿠폰과 할인 적용 이력 |

### 이번 프로젝트의 주요 선택

| ID | 항목 | 선택 | 근거 |
| --- | --- | --- | --- |
| `P07-D05` | 학생과 강사 | 별도 테이블 | 현재 속성과 업무 역할이 다름 |
|  | 프로젝트 위치 | `course_project` 스키마 | 앞 장 객체와 충돌 방지 |
|  | ID | `IDENTITY` 숫자 기본키 | 안정적인 내부 식별자 |
| `P07-D06` | 금액 | 원 단위 `INTEGER` | 소수점·다중 통화 제외 |
|  | 강의 기본 가격 | `courses.price` | 현재 강의의 기준 가격 |
|  | 실제 결제 금액 | `enrollments.paid_amount` | 신청 당시 기록된 금액 |
| `P07-D01` | 무료 강의 | 가격과 실제 금액을 0으로 저장 | 0은 확정 금액, `NULL`은 미확정값과 구분 |
|  | 강의 설명 | 선택 속성 | 설명이 없어도 강의를 등록할 수 있음 |
| `P07-D02` | 취소 | 행 삭제 없이 상태로 보존 | 신청 이력 유지 |
| `P07-D03` | 중복 활성 신청 | 학생·강의당 최대 한 건 | 진행 중 중복 차단, 완료·취소 이력 보존 |
| `P07-D07` | 부모 삭제 | `ON DELETE RESTRICT` | 과거 신청 관계 보호 |

`courses.price`와 `enrollments.paid_amount`는 값이 같을 수 있지만 의미와 시점이 다릅니다.

```text
courses.price
→ 현재 강의의 기본 가격

enrollments.paid_amount
→ 특정 신청 당시 기록된 실제 금액
```

취소된 신청에서도 `paid_amount`는 신청 당시 사실로 남습니다. 취소했다고 자동으로 0으로 바꾸지 않습니다. 환불 금액과 환불 상태는 `P07-O01`의 범위 밖입니다.

---

## 4. 확정 요구사항과 미확정 질문

### 확정 요구사항

| ID | 요구사항 |
| --- | --- |
| `P07-R01` | 학생은 이름, 이메일과 가입일을 가진다. |
| `P07-R02` | 강사는 이름, 이메일과 전문 분야를 가진다. |
| `P07-R03` | 강의는 제목, 선택 설명, 난이도, 수강료와 개설일을 가진다. |
| `P07-R04` | 하나의 강의는 정확히 한 명의 강사가 담당한다. |
| `P07-R05` | 한 명의 강사는 강의가 없거나 여러 강의를 담당할 수 있다. |
| `P07-R06` | 학생은 수강신청이 없거나 여러 건을 가질 수 있다. |
| `P07-R07` | 하나의 강의에는 수강신청이 없거나 여러 건이 존재할 수 있다. |
| `P07-R08` | 수강신청에는 신청일, 상태와 실제 결제 금액을 저장한다. |
| `P07-R09` | 수강 상태는 신청, 수강중, 완료, 취소 중 하나다. |
| `P07-R10` | 학생·강사 이메일은 공백일 수 없고 각 테이블에서 정확히 같은 문자열이 중복될 수 없다. |
| `P07-R11` | 강의 가격과 실제 결제 금액은 음수일 수 없다. |
| `P07-R12` | 존재하지 않는 학생·강사·강의를 참조할 수 없다. |

이메일 고유성은 정확히 같은 문자열을 기준으로 합니다. 다음 값의 대소문자를 같은 이메일로 처리할지는 별도 정책입니다.

```text
User@example.com
user@example.com
```

### 미확정 질문

| ID | 질문 | 현재 처리 |
| --- | --- | --- |
| `P07-Q01` | 강의 개설 후 강사 변경을 허용하는가? | 별도 제한 없음 |
| `P07-Q02` | 회원 탈퇴 후 개인정보와 신청 이력을 어떻게 보존하는가? | 부모 삭제 제한 |
| `P07-Q03` | 강의 폐강과 삭제를 어떻게 구분하는가? | 삭제 제한, 상태 열은 범위 제외 |
| `P07-Q04` | 상태 변경 이력을 별도 저장해야 하는가? | 현재 상태만 저장 |
| `P07-Q05` | 완료 후 재수강 횟수나 기간을 제한하는가? | 완료·취소 뒤 새 신청 허용 |

미확정 규칙은 설계자가 임의로 확정하지 않습니다. 현재 버전의 선택은 결정 ID로 기록하고, 정책이 달라지면 구조와 테스트를 다시 검토합니다.

---

## 5. 요구사항 추적표 만들기

추적표는 문장으로 적힌 규칙이 실제 구조와 테스트에 반영되었는지 확인합니다.

| ID | 요구사항·결정 | 상태 | 반영 구조 | 검증 방법 |
| --- | --- | --- | --- | --- |
| `P07-R01` | 학생 관리 | 확정 | `course_project.students` | 정상 입력·조회 |
| `P07-R10` | 학생 이메일 공백·중복 금지 | 확정 | 이메일 `CHECK`, `UNIQUE` | 공백·중복 실패 |
| `P07-R04` | 강의는 강사를 참조 | 확정 | `courses.instructor_id` FK | 없는 강사 실패 |
| `P07-R06` | 학생은 여러 신청 가능 | 확정 | `enrollments.student_id` | 학생 101의 2건 조회 |
| `P07-R07` | 강의는 여러 신청 가능 | 확정 | `enrollments.course_id` | 강의 301의 2건 조회 |
| `P07-R09` | 상태 허용값 | 확정 | 상태 `CHECK` | 잘못된 상태 실패 |
| `P07-R11` | 금액은 0 이상 | 확정 | 금액 `CHECK` | 0 성공·음수 실패 |
| `P07-D02` | 취소 이력과 당시 금액 보존 | 프로젝트 결정 | `status='취소'`, 금액 유지 | 신청 1004 확인 |
| `P07-D03` | 진행 중 중복 신청 금지 | 프로젝트 결정 | 부분 고유 인덱스 | 두 번째 활성 신청 실패 |
| `P07-Q04` | 상태 변경 이력 | 미확정 | 미반영 | 확장 전 확인 |
| `P07-O01` | 결제·환불 이력 | 범위 제외 | 미반영 | 확장 백로그 |

추적표를 작성하면 다음 문제를 찾을 수 있습니다.

```text
요구사항은 있는데 대응하는 열이나 제약조건이 없음
열·제약조건은 있는데 요구사항이나 결정 근거가 없음
하나의 요구사항이 잘못된 테이블에 반영됨
테스트하지 않은 규칙이 남아 있음
미확정 질문을 확정 규칙처럼 구현함
```

---

## 6. 엔터티와 속성 도출하기

요구사항에서 중요한 관리 대상과 사건을 찾습니다.

![요구사항에서 엔터티 도출](../../images/chapter07/ch07_02_requirement_to_entities.svg)

그림 7-2 요구사항을 데이터 구조로 바꾸기

| 후보 | 분류 | 판단 근거 |
| --- | --- | --- |
| 학생 | 일반 엔터티 | 독립적으로 식별·관리 |
| 강사 | 일반 엔터티 | 강의를 담당하는 독립 대상 |
| 강의 | 일반 엔터티 | 강사가 개설하고 학생이 신청하는 대상 |
| 수강신청 | 사건·관계 엔터티 | 학생·강의 관계에 날짜·상태·금액이 존재 |
| 이름 | 속성 | 학생이나 강사를 설명 |
| 난이도 | 속성 | 강의를 설명 |
| 결제 금액 | 사건 속성 | 특정 신청 시점에 결정 |

### 테이블별 한 행의 의미

| 테이블 | 한 행의 의미 |
| --- | --- |
| `students` | 학생 한 명 |
| `instructors` | 강사 한 명 |
| `courses` | 개설된 강의 한 개 |
| `enrollments` | 특정 학생의 특정 강의 신청 사건 한 건 |

한 행의 의미가 분명해야 컬럼의 주인과 제약조건을 결정할 수 있습니다.

---

## 7. 테이블과 열 구성하기

| 테이블 | 주요 열 | 핵심 규칙 |
| --- | --- | --- |
| `students` | id, name, email, joined_at | 이름·이메일 필수, 이메일 공백·중복 금지 |
| `instructors` | id, name, email, specialty | 이름·이메일·전문분야 필수·공백 금지 |
| `courses` | id, instructor_id, title, description, level, price, opened_at | 설명 선택, 난이도·가격 검증 |
| `enrollments` | id, student_id, course_id, enrolled_at, status, paid_amount | 상태·금액 검증, 활성 중복 제한 |

### 학생과 강사의 이메일

이메일은 업무상 고유값이지만 변경될 수 있으므로 기본키 대신 `UNIQUE` 열로 사용합니다. `NOT NULL`만으로 빈 문자열을 막을 수 없으므로 별도 `CHECK`를 사용합니다.

### 강의 난이도

이번 버전은 다음 세 값을 사용합니다.

```text
basic
intermediate
advanced
```

### 수강신청

`enrollments`는 단순 연결 테이블이 아니라 신청 사건을 저장하는 업무 테이블입니다.

```text
enrolled_at
status
paid_amount
```

이 값들은 학생 전체나 강의 전체가 아니라 특정 신청에 속합니다.

---

## 8. 관계 문장과 카디널리티

ERD를 그리기 전에 관계를 양방향 문장으로 작성합니다.

```text
한 강사는 0개 이상의 강의를 담당할 수 있다.
한 강의는 정확히 한 명의 강사를 참조한다.

한 학생은 0개 이상의 수강신청을 가질 수 있다.
한 수강신청은 정확히 한 명의 학생을 참조한다.

한 강의는 0개 이상의 수강신청을 가질 수 있다.
한 수강신청은 정확히 한 개의 강의를 참조한다.
```

관계를 요약하면 다음과 같습니다.

```text
instructors 1 ─── 0..N courses
students    1 ─── 0..N enrollments
courses     1 ─── 0..N enrollments
```

학생과 강의를 직접 보면 N:M 관계이며 `enrollments`가 두 개의 1:N 관계로 바꿉니다.

![학생-강의 N:M 관계 해소](../../images/chapter07/ch07_04_many_to_many_enrollments.svg)

그림 7-3 `enrollments`로 학생-강의 N:M 관계 해소

`students.course_ids = '301,302'`처럼 여러 ID를 한 셀에 저장하면 외래키 검증, 검색과 수정이 어려워집니다.

---

## 9. ERD로 구조 확인하기

텍스트 ERD는 다음과 같습니다.

```text
course_project.students
- id PK
- name
- email UNIQUE
- joined_at

course_project.instructors
- id PK
- name
- email UNIQUE
- specialty

course_project.courses
- id PK
- instructor_id FK -> instructors.id
- title
- description NULL 허용
- level
- price
- opened_at

course_project.enrollments
- id PK
- student_id FK -> students.id
- course_id FK -> courses.id
- enrolled_at
- status
- paid_amount
- active(student_id, course_id) 부분 고유 인덱스
```

![온라인 강의 수강신청 ERD](../../images/chapter07/ch07_03_online_course_erd.svg)

그림 7-4 온라인 강의 수강신청 핵심 ERD

ERD는 다음 기준으로 검토합니다.

```text
모든 테이블에 기본키가 있는가?
외래키가 부모 기본키를 정확하게 참조하는가?
관계의 최소·최대 개수가 요구사항과 맞는가?
N:M 관계가 사건 테이블로 해소되었는가?
관계 자체의 속성이 enrollments에 있는가?
삭제 정책이 과거 이력 보존 요구와 맞는가?
진행 중 중복 신청 정책이 별도 인덱스로 표현되었는가?
```

부분 고유 인덱스는 ERD의 기본 PK·FK 관계를 바꾸지 않으므로 본문과 DDL에서 별도로 확인합니다.

---

## 10. 정규화와 데이터 무결성 검토

현재 구조는 서로 다른 사실을 다음 테이블로 분리합니다.

![프로젝트 정규화 검토](../../images/chapter07/ch07_06_normalization_review_flow.svg)

그림 7-5 온라인 강의 프로젝트 정규화 점검

| 사실 | 관리 위치 | 효과 |
| --- | --- | --- |
| 학생의 현재 정보 | `students` | 신청마다 이름·이메일 반복 방지 |
| 강사의 현재 정보 | `instructors` | 강의마다 강사 정보 반복 방지 |
| 강의의 현재 정보 | `courses` | 신청마다 제목·현재 가격 반복 방지 |
| 신청 당시 사실 | `enrollments` | 상태·신청일·실제 금액 보존 |

무결성 규칙은 잘못된 값과 관계를 차단합니다.

| 규칙 | 구현 |
| --- | --- |
| 행 식별 | `PRIMARY KEY` |
| 자동 ID | `IDENTITY` |
| 필수값 | `NOT NULL` |
| 이메일 중복 방지 | `UNIQUE` |
| 공백 이름·이메일·제목·전문분야 방지 | `CHECK` |
| 난이도·상태 허용값 | `CHECK` |
| 음수 금액 방지 | `CHECK` |
| 존재하는 부모 참조 | `FOREIGN KEY` |
| 참조 중인 부모 삭제 방지 | `ON DELETE RESTRICT` |
| 진행 중 신청 중복 방지 | 부분 고유 인덱스 |

```sql
CREATE UNIQUE INDEX uq_course_enrollments_active
ON course_project.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

이 인덱스는 완료·취소 이력을 보존하면서 동시에 진행 중인 중복 신청만 차단합니다.

---

## 11. PostgreSQL 스키마 구현하기

프로젝트 스키마는 다음 파일에서 만듭니다.

```text
code/chapter07/01_course_project_schema.sql
```

핵심 구조는 다음과 같습니다.

```sql
CREATE SCHEMA course_project;

CREATE TABLE course_project.students (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    joined_at DATE NOT NULL,
    CONSTRAINT uq_course_students_email UNIQUE (email),
    CONSTRAINT chk_course_students_name_not_blank
        CHECK (char_length(trim(name)) > 0),
    CONSTRAINT chk_course_students_email_not_blank
        CHECK (char_length(trim(email)) > 0)
);

CREATE TABLE course_project.instructors (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    CONSTRAINT uq_course_instructors_email UNIQUE (email),
    CONSTRAINT chk_course_instructors_name_not_blank
        CHECK (char_length(trim(name)) > 0),
    CONSTRAINT chk_course_instructors_email_not_blank
        CHECK (char_length(trim(email)) > 0),
    CONSTRAINT chk_course_instructors_specialty_not_blank
        CHECK (char_length(trim(specialty)) > 0)
);

CREATE TABLE course_project.courses (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    instructor_id INTEGER NOT NULL
        REFERENCES course_project.instructors(id)
        ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL,
    price INTEGER NOT NULL,
    opened_at DATE NOT NULL,
    CHECK (char_length(trim(title)) > 0),
    CHECK (level IN ('basic', 'intermediate', 'advanced')),
    CHECK (price >= 0)
);

CREATE TABLE course_project.enrollments (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    student_id INTEGER NOT NULL
        REFERENCES course_project.students(id)
        ON DELETE RESTRICT,
    course_id INTEGER NOT NULL
        REFERENCES course_project.courses(id)
        ON DELETE RESTRICT,
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    paid_amount INTEGER NOT NULL,
    CHECK (status IN ('신청', '수강중', '완료', '취소')),
    CHECK (paid_amount >= 0)
);
```

생성 순서는 부모에서 자식 순서입니다.

```text
스키마
→ students·instructors
→ courses
→ enrollments
→ 부분 고유 인덱스
```

생성 파일은 기존 객체를 자동으로 삭제하지 않습니다. 처음부터 다시 시작해야 할 때만 보호 구문이 있는 `reset_course_project.sql`을 사용합니다.

---

## 12. 샘플 데이터를 테스트 데이터로 설계하기

샘플 데이터는 행 수를 채우기 위한 값이 아니라 요구사항을 검증하기 위한 사례입니다.

```text
학생 ID: 101, 102, 103
강사 ID: 201, 202
강의 ID: 301, 302, 303
기본 신청 ID: 1001~1004
변경 시나리오 신청 ID: 1005
```

명시적 ID는 관계를 재현하기 쉽지만 IDENTITY의 다음 값을 자동으로 바꾸지 않습니다. `02` 파일은 샘플 입력 뒤 다음 값으로 조정합니다.

```text
students 다음 값     = 104
instructors 다음 값  = 203
courses 다음 값      = 304
enrollments 다음 값  = 1005
```

### 기본 데이터가 검증하는 관계

```text
학생 101은 강의 301과 302를 신청한다.
강의 301에는 학생 101과 102가 신청한다.
강사 201은 강의 301과 302를 담당한다.
각 신청은 서로 다른 상태와 결제 금액을 가질 수 있다.
같은 학생·강의의 활성 신청은 중복되지 않는다.
```

기본 샘플 입력 직후 기대 행 수는 다음과 같습니다.

| 테이블 | 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 4 |

---

## 13. 안전한 변경 시나리오 실행하기

`03_course_project_changes.sql`은 기본 데이터에 다음 변화를 적용합니다.

```text
1. 학생 102가 강의 302를 새로 신청한다.
2. 신청 1001을 수강중에서 완료로 변경한다.
3. 신청 1004를 신청에서 취소로 변경한다.
4. enrollments IDENTITY 다음 값을 1006으로 조정한다.
```

### 신규 신청 전 확인

```sql
SELECT *
FROM course_project.enrollments
WHERE student_id = 102
  AND course_id = 302
  AND status IN ('신청', '수강중');
```

기대 결과는 0행입니다.

### 신규 신청 입력

```sql
INSERT INTO course_project.enrollments (
    id, student_id, course_id,
    enrolled_at, status, paid_amount
)
VALUES (
    1005, 102, 302,
    '2026-04-07', '신청', 120000
)
RETURNING *;
```

### 예상 이전 상태를 포함한 변경

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

`RETURNING`이 0행이면 예상 이전 상태와 실제 데이터가 다르다는 뜻입니다. 다음 단계로 넘어가기 전에 원인을 확인합니다.

상태 `CHECK`는 허용되는 네 값만 제한합니다. `완료 → 신청`, `취소 → 수강중` 같은 전체 전이 순서를 자동으로 막지는 않습니다. 이번 프로젝트는 변경 SQL의 이전 상태 조건으로 기본 전이를 확인하고 상태 이력·복잡한 전이는 확장 범위로 남깁니다.

> **부분 실행 주의**
>
> 자동 커밋 상태에서는 신규 신청만 저장되고 뒤의 UPDATE가 실패하는 등 일부 변경만 반영될 수 있습니다. 각 문장을 순서대로 실행하고 결과를 확인합니다. 여러 변경을 하나의 작업으로 묶는 트랜잭션은 Chapter 09에서 다룹니다.

취소된 신청 1004는 삭제하지 않으며 `paid_amount = 150000`도 유지합니다. 이 값은 환불 후 순수 매출이 아니라 신청 당시 기록된 금액입니다.

---

## 14. 검증 SQL로 완료 조건 확인하기

`04_course_project_validation.sql`은 최종 상태를 검증합니다.

### 최종 기대 행 수

| 테이블 | 최종 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 5 |

### 관계와 상태 검증 질문

```text
학생 101은 여러 강의를 신청했는가?
학생 102의 신규 신청이 추가되었는가?
강의 301에는 여러 학생이 신청했는가?
강사 201은 여러 강의를 담당하는가?
신청 1001은 완료 상태인가?
신청 1004는 취소 상태이며 당시 금액이 남아 있는가?
부모가 없는 고아 관계가 존재하지 않는가?
진행 중 중복 신청이 존재하지 않는가?
```

분리된 테이블이 서비스에서 사용할 수 있는 정보로 연결되는지 최소 JOIN으로 확인합니다.

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM course_project.enrollments AS e
JOIN course_project.students AS s
    ON e.student_id = s.id
JOIN course_project.courses AS c
    ON e.course_id = c.id
JOIN course_project.instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;
```

![SQL 기반 설계 검증 흐름](../../images/chapter07/ch07_05_sql_validation_flow.svg)

그림 7-6 샘플 데이터와 조회로 설계를 검증하는 흐름

JOIN 문법과 다양한 결합 방식은 Chapter 08에서 자세히 다룹니다.

### 최종 검산값

```text
전체 신청 행 수 = 5
전체 저장 결제금액 합계 = 590000
취소 제외 신청 행 수 = 4
취소 제외 결제금액 합계 = 440000
```

전체 저장 금액은 취소 신청 1004의 신청 당시 금액을 포함합니다. 환불과 회계 매출을 계산하는 기준이 아닙니다.

---

## 15. 경계값과 실패해야 하는 오류 데이터 테스트

정상 데이터만 입력하면 제약조건이 너무 약한지 또는 너무 강한지 충분히 알 수 없습니다.

### 성공해야 하는 경계값

| 테스트 | 기대 결과 |
| --- | --- |
| 가격 0인 무료 강의 | 성공 |
| `paid_amount = 0`인 무료 신청 | 성공 |
| `description = NULL` | 성공 |
| 한 글자 학생 이름 | 성공 |
| 완료 이력 뒤 동일 학생·강의 재신청 | 성공 |
| 참조되지 않는 학생 삭제 | 성공 |

### 실패해야 하는 오류값

| 테스트 | 기대 결과 |
| --- | --- |
| 학생 이름 `NULL` 또는 공백 | `NOT NULL`·`CHECK` 오류 |
| 학생·강사 이메일 공백 | `CHECK` 오류 |
| 학생·강사 이메일 중복 | `UNIQUE` 오류 |
| 강사 이름·전문분야 공백 | `CHECK` 오류 |
| 강의 제목 공백 | `CHECK` 오류 |
| 허용되지 않은 난이도 | `CHECK` 오류 |
| 음수 강의 가격 | `CHECK` 오류 |
| 존재하지 않는 부모 참조 | `FOREIGN KEY` 오류 |
| 허용되지 않은 수강 상태 | `CHECK` 오류 |
| 음수 결제 금액 | `CHECK` 오류 |
| 두 번째 활성 신청 | 부분 고유 인덱스 오류 |
| 참조 중인 부모 삭제 | `RESTRICT` 또는 FK 오류 |

`05_course_project_integrity_tests.sql`의 변경 SQL은 모두 주석 상태입니다. 한 구간씩 주석을 해제해 실행합니다.

```text
성공해야 하는 경계인지 실패해야 하는 오류인지 먼저 확인한다.
오류 메시지에서 어떤 제약조건이나 인덱스가 차단했는지 확인한다.
임시 행을 삭제하고 정상 데이터의 행 수가 유지되는지 확인한다.
```

수동 커밋 상태나 명시적 트랜잭션 안에서 오류 후 다음 메시지가 나타날 수 있습니다.

```text
current transaction is aborted
```

이때는 다음 명령으로 실패한 트랜잭션을 종료한 뒤 다음 테스트를 실행합니다.

```sql
ROLLBACK;
```

---

## 16. 초기화 파일의 안전장치

처음부터 다시 시작할 때만 `reset_course_project.sql`을 사용합니다.

파일은 하나의 보호 구문 안에서 현재 데이터베이스가 `ai_database_book`인지 확인합니다. 조건이 맞을 때만 다음 순서로 알려진 프로젝트 객체를 삭제합니다.

```text
course_project.enrollments
→ course_project.courses
→ course_project.instructors
→ course_project.students
→ course_project 스키마
```

`DROP SCHEMA ... CASCADE`는 사용하지 않습니다. 프로젝트 스키마에 예상하지 않은 객체가 남아 있으면 스키마 삭제가 실패하며 추가 확인을 요구합니다.

---

## 17. AI 제안과 사람의 수정 기록하기

AI는 요구사항 정리, ERD와 DDL 초안, 샘플 데이터와 테스트 제안에 활용할 수 있습니다.

```text
온라인 강의 수강신청 서비스의 PostgreSQL 데이터베이스 초안을 작성해 주세요.

요청:
1. 요구사항·프로젝트 결정·미확정 질문·범위 제외에 ID를 붙여 주세요.
2. 엔터티·속성·관계를 구분해 주세요.
3. 관계를 양방향 문장과 카디널리티로 설명해 주세요.
4. 요구사항 추적표를 작성해 주세요.
5. PK, FK, NOT NULL, UNIQUE, CHECK, 부분 고유 인덱스와 삭제 정책의 근거를 설명해 주세요.
6. 요구사항에 없는 정책을 임의로 확정하지 마세요.
7. 정상 샘플, 성공해야 하는 경계값과 실패해야 하는 오류값을 제안해 주세요.
8. 명시적 ID를 사용할 경우 IDENTITY 다음 값 조정도 포함해 주세요.
```

![AI 활용 및 검토 흐름](../../images/chapter07/ch07_07_ai_review_flow.svg)

그림 7-7 AI 제안을 검토된 프로젝트 설계로 바꾸기

AI 결과는 다음 형식으로 기록합니다.

| AI 제안 | 요구사항 근거 | 문제·누락 | 사람의 최종 결정 |
| --- | --- | --- | --- |
| 학생·강사를 users로 통합 | 미확정 | 기본 범위를 복잡하게 함 | 현재 버전은 분리 |
| 모든 FK에 CASCADE | 근거 없음 | 과거 신청 이력 손실 가능 | RESTRICT 사용 |
| 전체 이력에 복합 UNIQUE | 진행 중 중복만 막으면 됨 | 완료·취소 후 재신청까지 차단 | 부분 고유 인덱스 |
| paid_amount 제거 | `P07-R08`과 불일치 | 신청 당시 가격 소실 | 유지 |
| 취소 시 paid_amount를 0으로 변경 | 환불 요구 없음 | 당시 금액과 환불 의미 혼합 | 원래 값 유지 |

`PROJECT_DECISIONS.md`에는 선택한 구조, 검토한 대안, 결정 ID, AI 제안, 실행 결과와 남은 질문을 남깁니다.

---

## 18. 프로젝트 완성도 점검

![온라인 강의 DB 프로젝트 완성도 점검](../../images/chapter07/ch07_08_project_completion_checklist.svg)

그림 7-8 온라인 강의 데이터베이스 프로젝트 완성도 점검

| 영역 | 완료 기준 |
| --- | --- |
| 범위 | 포함·제외 기능과 가정이 ID로 기록됨 |
| 요구사항 | 확정 규칙·프로젝트 결정·미확정 질문이 구분됨 |
| 추적성 | ID와 구조·테스트가 연결됨 |
| 엔터티 | 한 행의 의미와 컬럼 주인을 설명 가능 |
| 관계 | 양방향 문장·카디널리티·선택성이 일치 |
| ERD | PK·FK와 N:M 해소가 표현됨 |
| 정규화 | 현재 사실과 신청 당시 사실이 구분됨 |
| 무결성 | 경계·오류 데이터로 제약조건과 인덱스를 검증함 |
| SQL 안전성 | 자동 DROP 없이 단계별 실행 가능 |
| 재현성 | 명시적 ID와 IDENTITY 다음 값이 문서화됨 |
| 변경 | INSERT·UPDATE 전후와 예상 이전 상태가 확인됨 |
| AI 검토 | AI 제안과 사람의 수정 근거가 구분됨 |
| 다음 장 인계 | 최종 신청 5건과 검산값이 확인됨 |

프로젝트가 완성되었다는 의미는 ERD 그림이 존재한다는 뜻이 아닙니다.

```text
요구사항을 설명하고
구조를 재현하며
정상 경계를 허용하고 잘못된 데이터를 차단하며
검증 결과를 제시할 수 있어야 한다.
```

---

## 19. 확장 백로그 만들기

| 확장 기능 | 새 데이터·규칙 후보 |
| --- | --- |
| 강의 정원 | capacity, 대기 상태, 동시 신청 제어 |
| 결제 이력 | payments, 결제 상태, 환불과 거래 ID |
| 상태 이력 | enrollment_status_history |
| 강의 구성 | course_sections, lessons |
| 진도 관리 | progress 또는 lesson_progress |
| 수강평 | reviews, rating, review_text |
| 할인 | coupons, promotions, 적용 이력 |
| 폐강·비활성화 | course status, 노출·신청 가능 여부 |

확장할 때는 바로 열을 추가하지 않고 다음 순서로 검토합니다.

```text
새 요구사항
→ 새 사실과 규칙
→ 기존 엔터티의 속성인지 새 엔터티인지 판단
→ 관계와 이력 요구 검토
→ ERD·제약조건·테스트 갱신
```

---

## 20. 자주 발생하는 프로젝트 오류

1. 앞 장의 테이블을 자동 삭제한다. 전용 스키마를 사용하고 초기화는 보호 파일로 제한합니다.
2. 명시적 ID만 넣고 IDENTITY 다음 값도 자동으로 바뀐다고 생각한다. `RESTART WITH`로 조정합니다.
3. 명사만 보고 테이블을 만든다. 동사, 수량 표현과 상태 변화를 함께 확인합니다.
4. `students`에 `course_ids` 문자열을 저장한다. N:M 관계는 `enrollments`로 표현합니다.
5. 강사와 학생의 현재 정보를 관계 테이블에 반복 저장한다. 현재 정보의 주인 테이블을 정합니다.
6. 신청 당시 결제 금액을 현재 강의 가격으로 대체한다. 현재 가격과 사건 당시 가격은 다른 사실입니다.
7. 무료 금액에 0과 `NULL`을 혼용한다. 이번 프로젝트는 확정 금액 0을 사용합니다.
8. 미확정 정책을 제약조건으로 먼저 고정한다. 정책·결정 ID가 먼저입니다.
9. 모든 이력에 복합 `UNIQUE`를 적용한다. 진행 중 중복만 부분 고유 인덱스로 제한합니다.
10. 상태값 `CHECK`가 상태 전이 순서도 보장한다고 생각한다. 이전 상태 조건과 별도 이력 정책이 필요합니다.
11. 취소 신청을 삭제하거나 금액을 0으로 바꾼다. 신청 당시 사실과 환불 사실을 구분합니다.
12. 정상 데이터만 테스트한다. 성공해야 하는 경계와 실패해야 하는 오류를 모두 확인합니다.
13. 오류 후 실패한 트랜잭션 상태를 그대로 둔다. 필요하면 `ROLLBACK`합니다.
14. AI가 제안한 `CASCADE`를 그대로 적용한다. 삭제의 업무 의미와 영향 범위를 먼저 확인합니다.

---

## 21. 스스로 확인하기

1. 전용 스키마를 사용하는 이유를 설명해 보세요.
2. `courses.price`와 `enrollments.paid_amount`는 어떻게 다른가요?
3. 무료 강의의 금액을 0으로 저장하고 `NULL`을 사용하지 않는 이유는 무엇인가요?
4. 취소된 신청의 `paid_amount`가 남아 있는 이유는 무엇인가요?
5. 설명 `description`을 선택 속성으로 둔 근거는 무엇인가요?
6. 이메일 `NOT NULL`만으로 공백 문자열을 막을 수 없는 이유는 무엇인가요?
7. `enrollments`가 단순 연결 테이블이 아닌 사건 테이블인 이유는 무엇인가요?
8. 부분 고유 인덱스는 어떤 신청을 차단하고 어떤 이력을 허용하나요?
9. 명시적 ID 입력 뒤 IDENTITY 시작값을 조정하는 이유는 무엇인가요?
10. 상태 변경 SQL에 이전 상태 조건을 넣는 이유는 무엇인가요?
11. 상태 `CHECK`가 전체 상태 전이를 보장하지 못하는 이유는 무엇인가요?
12. 자동 커밋 상태에서 변경 시나리오가 부분 반영될 수 있는 이유는 무엇인가요?
13. 경계 테스트와 오류 테스트가 모두 필요한 이유는 무엇인가요?
14. 초기화 파일에서 `DROP SCHEMA ... CASCADE`를 사용하지 않은 이유는 무엇인가요?
15. Chapter 08로 전달할 최종 행 수와 금액 검산값을 적어 보세요.

프로젝트 과정과 테스트 결과를 기록하려면 `book/chapter07/chapter07_activity.md`의 독자 워크북을 사용합니다.

---

## 22. 권장 해설

- 전용 스키마는 앞 장 객체와 충돌을 막고 프로젝트 범위와 초기화 대상을 분명하게 합니다.
- `courses.price`는 현재 기준 가격이고 `paid_amount`는 신청 사건 당시 기록된 금액입니다.
- 무료 강의의 0은 확정된 금액이며 `NULL`은 알 수 없거나 미확정인 상태와 구분됩니다.
- 취소는 신청 이력을 없애지 않으며 환불은 별도 업무 사실입니다.
- `description`은 요구사항에서 선택 속성으로 확정했으므로 `NULL`을 허용합니다.
- `NOT NULL`은 빈 문자열을 막지 않으므로 `char_length(trim(email)) > 0`이 필요합니다.
- 부분 고유 인덱스는 `신청`·`수강중` 상태의 중복만 막고 `완료`·`취소` 이력 뒤 재신청은 허용합니다.
- 명시적 ID는 IDENTITY 시퀀스를 소비하지 않으므로 다음 자동값을 조정해야 합니다.
- 이전 상태 조건은 예상하지 않은 상태를 덮어쓰는 위험을 줄입니다.
- 상태 `CHECK`는 값의 목록만 제한하며 상태 변경 순서는 별도 로직과 이력 모델이 필요합니다.
- 자동 커밋에서는 각 문장이 개별 확정될 수 있어 일부만 반영될 수 있습니다.
- 경계 테스트는 정상값을 과도하게 막지 않는지, 오류 테스트는 잘못된 값을 차단하는지 확인합니다.
- `CASCADE` 없는 스키마 삭제는 예상하지 않은 객체를 조용히 지우지 않고 검토를 요구합니다.

Chapter 08 인계 기준:

```text
students 3
instructors 2
courses 3
enrollments 5
전체 저장 결제금액 590000
취소 제외 결제금액 440000
활성 중복 신청 0건
```

---

## 23. 핵심 정리

```text
1. 프로젝트 범위와 제외 기능을 설계 전에 구분한다.
2. 요구사항·결정·미확정 질문에 ID를 붙인다.
3. 추적표로 ID, 구조와 테스트를 연결한다.
4. 한 행의 의미와 컬럼의 주인을 기준으로 엔터티를 설계한다.
5. 학생과 강의의 N:M 관계는 enrollments로 해소한다.
6. 현재 가격과 신청 당시 금액을 구분한다.
7. 전용 스키마로 프로젝트 객체와 앞 장 실습을 분리한다.
8. 명시적 테스트 ID 뒤 IDENTITY 다음 값을 조정한다.
9. 진행 중 중복 신청은 부분 고유 인덱스로 차단한다.
10. 상태 변경은 예상 이전 상태를 확인한다.
11. 정상·경계·오류 데이터로 구조와 무결성을 검증한다.
12. AI 제안은 근거와 실행 결과를 사람이 검토한 뒤 채택한다.
```

이 프로젝트에서 기억할 문장은 다음과 같습니다.

```text
좋은 프로젝트 데이터베이스는 요구사항을 구조로 바꾸는 데서 끝나지 않고,
정상 경계와 실패해야 하는 데이터로 그 구조를 증명할 수 있어야 한다.
```

---

## 24. 다음 장에서는

Chapter 08에서는 `course_project` 스키마의 최종 신청 5건을 그대로 사용해 JOIN과 집계로 서비스 질문에 답합니다.

```text
학생·강의·강사·신청을 연결한다.
전체 신청과 취소 제외 신청을 구분한다.
상세 결과와 집계 결과를 대조한다.
전체 저장 금액과 취소 제외 금액을 검산한다.
```

Chapter 08은 다음 파일을 순서대로 실행한 상태를 전제로 합니다.

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```
