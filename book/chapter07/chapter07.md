# Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

---

## 이 장에서 완성할 프로젝트

Chapter 01~06에서는 데이터베이스를 배우는 이유, DBMS와 PostgreSQL 환경, 기본 SQL, 요구사항 분석, ERD, 정규화와 데이터 무결성을 차례로 살펴보았습니다. 이번 장에서는 이 내용을 하나의 작은 서비스에 통합합니다.

프로젝트 주제는 **온라인 강의 수강신청 시스템**입니다.

```text
서비스 범위 결정
→ 요구사항과 미확정 규칙 정리
→ 엔터티·속성·관계 도출
→ 관계 문장과 ERD 작성
→ 정규화·무결성 검토
→ PostgreSQL 전용 스키마 구현
→ 정상 샘플 데이터 입력
→ 변경 시나리오 실행
→ 조회·오류 데이터로 검증
→ AI 제안과 사람의 수정 기록
```

![프로젝트 진행 흐름](../../images/chapter07/ch07_01_project_flow.svg)

그림 7-1 온라인 강의 데이터베이스 프로젝트 핵심 흐름

이 프로젝트의 핵심은 SQL의 양이 아닙니다. 다음 내용을 서로 연결해 설명할 수 있어야 합니다.

```text
요구사항 문장
→ 설계 결정
→ ERD 구조
→ 제약조건
→ 샘플 데이터
→ 검증 결과
```

> **완료 기준**
>
> 다른 사람이 프로젝트 파일을 순서대로 실행했을 때 같은 구조와 데이터를 만들 수 있고, 각 테이블과 제약조건의 요구사항 근거를 설명할 수 있어야 합니다.

---

## 1. 프로젝트 산출물과 실행 구조

이 장에서는 다음 산출물을 완성합니다.

| 산출물 | 확인 내용 |
| --- | --- |
| 프로젝트 범위 | 포함·제외 기능과 가정 |
| 요구사항 목록 | 데이터와 업무 규칙 |
| 미확정 질문 | 아직 결정되지 않은 정책 |
| 요구사항 추적표 | 요구사항과 테이블·열·제약조건 연결 |
| 관계 문장 | 카디널리티와 필수·선택 관계 |
| ERD | 네 테이블과 PK·FK |
| PostgreSQL DDL | 전용 스키마와 무결성 제약조건 |
| 정상 샘플 데이터 | 관계와 규칙을 검증하는 데이터 |
| 변경 시나리오 | 안전한 INSERT·UPDATE·취소 처리 |
| 검증 SQL | 행 수·관계·업무 질문 확인 |
| 오류 테스트 | 실패해야 하는 잘못된 데이터 |
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

`online_course_project.sql`은 기존 링크 호환을 위한 프로젝트 안내·최종 확인 파일입니다. 실제 생성과 데이터 변경은 번호가 붙은 파일을 순서대로 실행합니다.

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
앞 장의 students 같은 동명 테이블과 충돌하지 않는다.
프로젝트 객체의 범위가 분명하다.
초기화할 대상을 정확하게 구분할 수 있다.
Chapter 08 이후에도 같은 프로젝트 데이터를 명확하게 참조할 수 있다.
```

SQL에서는 테이블 이름을 완전하게 작성합니다.

```sql
SELECT *
FROM course_project.students;
```

이 방식은 현재 `search_path`에 따라 다른 테이블을 조회하는 실수를 줄여 줍니다.

---

## 3. 프로젝트 범위와 설계 결정

이번 기본 버전은 다음 네 테이블에 집중합니다.

```text
students
instructors
courses
enrollments
```

기본 범위에서 제외하는 기능은 다음과 같습니다.

```text
결제 시도·실패·환불 이력
강의 정원과 대기 순번
진도율과 수료증
강의 영상과 섹션
수강평과 별점
쿠폰과 할인 정책
취소 사유와 상태 변경 이력
```

### 이번 프로젝트의 설계 선택

| 항목 | 선택 | 근거 |
| --- | --- | --- |
| 학생과 강사 | 별도 테이블 | 현재 요구사항의 속성과 업무 역할이 다름 |
| 프로젝트 위치 | `course_project` 스키마 | 앞 장 테이블과 충돌 방지 |
| ID | `IDENTITY` 숫자 기본키 | 안정적인 내부 식별자 사용 |
| 금액 | 원 단위 `INTEGER` | 소수점·다중 통화를 다루지 않는 범위 |
| 강의 기본 가격 | `courses.price` | 현재 강의의 기준 가격 |
| 실제 결제 금액 | `enrollments.paid_amount` | 신청 당시 가격·할인 결과 보존 |
| 수강 상태 | `VARCHAR` + `CHECK` | 네 가지 허용값을 입문 수준에서 명시 |
| 취소 | 행 삭제 대신 `status='취소'` | 신청 이력 보존 |
| 부모 삭제 | `ON DELETE RESTRICT` | 강의·학생·강사와 과거 신청 관계 보호 |
| 재신청 | 이번 버전에서 별도 제한 없음 | 취소 후 재신청 정책이 미확정 |

`courses.price`와 `enrollments.paid_amount`는 값이 같을 수 있지만 의미와 시점이 다릅니다.

```text
courses.price
→ 현재 강의 기본 가격

enrollments.paid_amount
→ 특정 신청 당시 실제 결제 금액
```

신청 당시 가격은 과거 사건의 사실이므로 단순한 중복으로 제거하지 않습니다.

---

## 4. 서비스 요구사항과 미확정 질문

### 확정된 요구사항

```text
1. 학생은 이름, 이메일과 가입일을 가진다.
2. 강사는 이름, 이메일과 전문 분야를 가진다.
3. 강의는 제목, 설명, 난이도, 수강료와 개설일을 가진다.
4. 하나의 강의는 정확히 한 명의 강사가 담당한다.
5. 한 명의 강사는 강의가 없거나 여러 강의를 담당할 수 있다.
6. 학생은 강의가 없거나 여러 강의를 신청할 수 있다.
7. 하나의 강의에는 학생이 없거나 여러 학생이 신청할 수 있다.
8. 수강신청에는 신청일, 상태와 실제 결제 금액을 저장한다.
9. 수강 상태는 신청, 수강중, 완료, 취소 중 하나다.
10. 학생 이메일과 강사 이메일은 각각 중복될 수 없다.
11. 강의 가격과 실제 결제 금액은 음수일 수 없다.
12. 존재하지 않는 학생·강사·강의를 참조할 수 없다.
```

### 미확정 질문

```text
같은 학생이 같은 강의를 여러 번 신청할 수 있는가?
취소 후 재신청은 새 행인가, 기존 행의 상태 변경인가?
무료 강의의 paid_amount는 0인가, NULL인가?
강의가 개설된 뒤 강사를 변경할 수 있는가?
회원 탈퇴 후 수강 이력을 어떻게 보존하는가?
강의 폐강과 삭제는 어떻게 구분하는가?
상태 변경 이력을 별도 기록해야 하는가?
```

미확정 규칙은 설계자가 임의로 확정하지 않습니다. 이번 버전의 선택을 기록하되, 정책이 확정되면 구조와 제약조건을 다시 검토합니다.

---

## 5. 요구사항 추적표 만들기

요구사항 추적표는 문장으로 적힌 규칙이 실제 구조에 반영되었는지 확인합니다.

| 요구사항 | 반영 구조 | 검증 방법 |
| --- | --- | --- |
| 학생을 관리한다 | `course_project.students` | 학생 행 입력·조회 |
| 학생 이메일은 중복 불가 | `students.email UNIQUE` | 중복 이메일 실패 테스트 |
| 강사가 강의를 담당한다 | `courses.instructor_id` FK | 강사 201의 여러 강의 조회 |
| 학생이 여러 강의를 신청한다 | `enrollments.student_id` | 학생 101의 여러 신청 조회 |
| 강의에 여러 학생이 신청한다 | `enrollments.course_id` | 강의 301의 여러 신청 조회 |
| 신청 상태는 네 값 중 하나 | `enrollments.status CHECK` | 잘못된 상태 실패 테스트 |
| 가격은 음수 불가 | 가격 열의 `CHECK` | 음수 가격 실패 테스트 |
| 취소 이력을 남긴다 | `status='취소'` | 변경 후 상태 조회 |
| 존재하는 부모만 참조 | 세 외래키 | 존재하지 않는 ID 실패 테스트 |

추적표를 작성하면 다음 문제를 찾을 수 있습니다.

```text
요구사항은 있는데 대응하는 열이나 제약조건이 없음
열이나 제약조건은 있는데 요구사항 근거가 없음
하나의 요구사항이 잘못된 테이블에 반영됨
테스트하지 않은 업무 규칙이 남아 있음
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
| 수강신청 | 사건·관계 엔터티 | 학생과 강의 관계에 날짜·상태·금액이 존재 |
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
| `students` | id, name, email, joined_at | 이름 필수, 이메일 고유 |
| `instructors` | id, name, email, specialty | 이름·전문분야 필수, 이메일 고유 |
| `courses` | id, instructor_id, title, description, level, price, opened_at | 강사 필수, 난이도·가격 검증 |
| `enrollments` | id, student_id, course_id, enrolled_at, status, paid_amount | 학생·강의 필수, 상태·금액 검증 |

### 학생과 강사의 이메일

이메일은 업무상 고유값이지만 변경될 수 있으므로 기본키 대신 `UNIQUE` 열로 사용합니다.

### 강의 난이도

이번 버전은 다음 세 값을 사용합니다.

```text
basic
intermediate
advanced
```

허용값은 `CHECK`로 제한합니다.

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

학생과 강의를 직접 보면 N:M 관계입니다.

```text
students N : M courses
```

이를 `enrollments`가 두 개의 1:N 관계로 바꿉니다.

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
- description
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
```

![온라인 강의 수강신청 ERD](../../images/chapter07/ch07_03_online_course_erd.svg)

그림 7-4 온라인 강의 수강신청 핵심 ERD

ERD를 다음 기준으로 검토합니다.

```text
모든 테이블에 기본키가 있는가?
외래키가 부모 기본키를 정확하게 참조하는가?
관계의 최소·최대 개수가 요구사항과 맞는가?
N:M 관계가 사건 테이블로 해소되었는가?
관계 자체의 속성이 enrollments에 있는가?
삭제 정책이 과거 이력 보존 요구와 맞는가?
```

---

## 10. 정규화와 데이터 무결성 검토

현재 구조는 서로 다른 사실을 다음 테이블로 분리합니다.

![프로젝트 정규화 검토](../../images/chapter07/ch07_06_normalization_review_flow.svg)

그림 7-5 온라인 강의 프로젝트 정규화 점검

| 사실 | 관리 위치 | 효과 |
| --- | --- | --- |
| 학생의 현재 정보 | `students` | 신청마다 이름·이메일 반복 방지 |
| 강사의 현재 정보 | `instructors` | 강의마다 강사 정보 반복 방지 |
| 강의의 현재 정보 | `courses` | 신청마다 제목·기본 가격 반복 방지 |
| 신청 당시 사실 | `enrollments` | 상태·신청일·실제 금액 보존 |

무결성 제약조건은 잘못된 값과 관계를 차단합니다.

| 규칙 | 구현 |
| --- | --- |
| 행 식별 | `PRIMARY KEY` |
| 자동 ID | `IDENTITY` |
| 필수값 | `NOT NULL` |
| 이메일 중복 방지 | `UNIQUE` |
| 공백 이름·제목 방지 | `CHECK` |
| 난이도·상태 허용값 | `CHECK` |
| 음수 금액 방지 | `CHECK` |
| 존재하는 부모 참조 | `FOREIGN KEY` |
| 참조 중인 부모 삭제 방지 | `ON DELETE RESTRICT` |

같은 학생의 같은 강의 중복 신청을 막는 `UNIQUE(student_id, course_id)`는 이번 버전에서 적용하지 않습니다. 취소 후 재신청 정책이 확정되지 않았기 때문입니다.

제약조건은 강할수록 좋은 것이 아니라 요구사항과 정확히 일치해야 합니다.

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
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL,
    CHECK (char_length(trim(name)) > 0)
);

CREATE TABLE course_project.instructors (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    CHECK (char_length(trim(name)) > 0),
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
```

생성 파일은 기존 객체를 자동으로 삭제하지 않습니다. 처음부터 다시 시작해야 할 때만 `reset_course_project.sql`을 사용합니다.

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

명시적인 ID를 사용하면 이전 자동 증가 상태를 가정하지 않고 같은 관계를 재현할 수 있습니다.

### 기본 데이터가 검증하는 관계

```text
학생 101은 강의 301과 302를 신청한다.
강의 301에는 학생 101과 102가 신청한다.
강사 201은 강의 301과 302를 담당한다.
각 신청은 서로 다른 상태와 결제 금액을 가질 수 있다.
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
2. 신청 1001의 상태를 완료로 변경한다.
3. 신청 1004의 상태를 취소로 변경한다.
```

### 참조 대상 확인

```sql
SELECT *
FROM course_project.students
WHERE id = 102;

SELECT *
FROM course_project.courses
WHERE id = 302;
```

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

### 상태 변경 전 확인

```sql
SELECT *
FROM course_project.enrollments
WHERE id IN (1001, 1004)
ORDER BY id;
```

### 상태 변경

```sql
UPDATE course_project.enrollments
SET status = '완료'
WHERE id = 1001
RETURNING *;

UPDATE course_project.enrollments
SET status = '취소'
WHERE id = 1004
RETURNING *;
```

취소된 신청은 삭제하지 않고 이력으로 남깁니다. 실제 삭제는 별도의 보존 정책이 확정된 뒤 검토합니다.

변경 파일을 두 번 실행하면 ID 중복 오류가 발생할 수 있습니다. 프로젝트는 다음 순서로 한 번씩 실행합니다.

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

### 관계 검증 질문

```text
학생 101은 여러 강의를 신청했는가?
학생 102의 신규 신청이 추가되었는가?
강의 301에는 여러 학생이 신청했는가?
강사 201은 여러 강의를 담당하는가?
신청 1001은 완료 상태인가?
신청 1004는 취소 상태인가?
부모가 없는 고아 관계가 존재하지 않는가?
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

JOIN 문법과 다양한 결합 방식은 Chapter 08에서 자세히 학습합니다. 이 장에서는 관계가 실제 결과로 연결되는지만 확인합니다.

---

## 15. 실패해야 하는 오류 데이터 테스트

정상 데이터만 입력하면 제약조건이 실제로 작동하는지 충분히 알 수 없습니다.

`05_course_project_integrity_tests.sql`에는 다음 오류 SQL이 모두 주석 상태로 들어 있습니다.

| 테스트 | 기대 결과 |
| --- | --- |
| 학생 이름 NULL | `NOT NULL` 오류 |
| 학생 이메일 중복 | `UNIQUE` 오류 |
| 강의 제목이 공백 | `CHECK` 오류 |
| 허용되지 않은 난이도 | `CHECK` 오류 |
| 음수 강의 가격 | `CHECK` 오류 |
| 존재하지 않는 강사 참조 | `FOREIGN KEY` 오류 |
| 존재하지 않는 학생 참조 | `FOREIGN KEY` 오류 |
| 허용되지 않은 수강 상태 | `CHECK` 오류 |
| 음수 결제 금액 | `CHECK` 오류 |
| 참조 중인 학생·강사·강의 삭제 | `RESTRICT` 또는 FK 오류 |

오류 SQL은 한 번에 하나만 주석 해제해 실행합니다.

```text
오류가 발생해야 정상인 테스트다.
오류 메시지에서 어떤 제약조건이 차단했는지 확인한다.
오류 후 정상 데이터의 행 수가 변하지 않았는지 확인한다.
```

오류를 없애기 위해 제약조건을 바로 제거하지 않습니다. 입력이 잘못된 것인지, 제약조건이 요구사항과 다른지 먼저 구분합니다.

---

## 16. AI 제안과 사람의 수정 기록하기

AI는 요구사항 정리, ERD와 DDL 초안, 샘플 데이터와 오류 테스트 제안에 활용할 수 있습니다.

```text
온라인 강의 수강신청 서비스의 PostgreSQL 데이터베이스 초안을 작성해 주세요.

요구사항:
[확정 요구사항]

요청:
1. 엔터티·속성·관계를 구분해 주세요.
2. 관계를 양방향 문장과 카디널리티로 설명해 주세요.
3. 요구사항 추적표를 작성해 주세요.
4. PostgreSQL DDL을 작성해 주세요.
5. PK, FK, NOT NULL, UNIQUE, CHECK와 삭제 정책의 근거를 설명해 주세요.
6. 요구사항에 없는 정책은 임의로 확정하지 마세요.
7. 가정과 미확정 질문을 별도로 표시해 주세요.
8. 정상 샘플과 실패해야 하는 오류 테스트를 제안해 주세요.
```

![AI 활용 및 검토 흐름](../../images/chapter07/ch07_07_ai_review_flow.svg)

그림 7-7 AI 제안을 검토된 프로젝트 설계로 바꾸기

AI 결과는 다음 형식으로 기록합니다.

| AI 제안 | 요구사항 근거 | 문제·누락 | 사람의 최종 결정 |
| --- | --- | --- | --- |
| 학생·강사를 users로 통합 | 미확정 | 기본 범위를 복잡하게 함 | 현재 버전은 분리 |
| 모든 FK에 CASCADE | 근거 없음 | 과거 신청 이력 손실 가능 | RESTRICT 사용 |
| 학생·강의 복합 UNIQUE | 재신청 정책 미확정 | 취소 후 재신청 제한 가능 | 적용 보류 |
| paid_amount 제거 | 요구사항과 불일치 | 신청 당시 금액 소실 | 유지 |

`PROJECT_DECISIONS.md`에는 다음을 남깁니다.

```text
선택한 구조
검토한 대안
채택·보류 이유
미확정 질문
AI 제안과 수정 내용
검증한 SQL과 결과
```

AI가 만든 SQL이 실행된다는 사실만으로 설계가 승인되는 것은 아닙니다.

---

## 17. 프로젝트 완성도 점검

![온라인 강의 DB 프로젝트 완성도 점검](../../images/chapter07/ch07_08_project_completion_checklist.svg)

그림 7-8 온라인 강의 데이터베이스 프로젝트 완성도 점검

| 영역 | 완료 기준 |
| --- | --- |
| 범위 | 포함·제외 기능과 가정이 기록됨 |
| 요구사항 | 확정 규칙과 미확정 질문이 구분됨 |
| 추적성 | 요구사항과 구조·테스트가 연결됨 |
| 엔터티 | 한 행의 의미와 컬럼 주인을 설명 가능 |
| 관계 | 양방향 문장·카디널리티·선택성이 일치 |
| ERD | PK·FK와 N:M 해소가 표현됨 |
| 정규화 | 현재 사실과 신청 당시 사실이 구분됨 |
| 무결성 | 정상·오류 데이터로 제약조건을 검증함 |
| SQL 안전성 | 자동 DROP 없이 단계별 실행 가능 |
| 재현성 | 명시적 ID와 기대 행 수가 문서화됨 |
| 변경 | INSERT·UPDATE 전후 결과가 확인됨 |
| AI 검토 | AI 제안과 사람의 수정 근거가 구분됨 |
| 다음 장 인계 | 최종 신청 5건 상태가 확인됨 |

프로젝트가 완성되었다는 의미는 ERD 그림이 존재한다는 뜻이 아닙니다.

```text
요구사항을 설명하고
구조를 재현하며
잘못된 데이터를 차단하고
검증 결과를 제시할 수 있어야 한다.
```

---

## 18. 확장 백로그 만들기

기본 프로젝트를 검증한 뒤 기능을 하나씩 확장할 수 있습니다.

| 확장 기능 | 새 데이터·규칙 후보 |
| --- | --- |
| 강의 정원 | capacity, 대기 상태, 동시 신청 제어 |
| 결제 이력 | payments, 결제 상태, 환불과 거래 ID |
| 상태 이력 | enrollment_status_history |
| 강의 구성 | course_sections, lessons |
| 진도 관리 | progress 또는 lesson_progress |
| 수강평 | reviews, rating, review_text |
| 할인 | coupons, promotions, 적용 이력 |

확장할 때는 바로 열을 추가하지 않고 다음 순서로 검토합니다.

```text
새 요구사항
→ 새 사실과 규칙
→ 기존 엔터티의 속성인지 새 엔터티인지 판단
→ 관계와 이력 요구 검토
→ ERD·제약조건·테스트 갱신
```

---

## 19. 자주 발생하는 프로젝트 오류

### 오류 1. 앞 장의 테이블을 자동 삭제한다

프로젝트 전용 `course_project` 스키마를 사용하고 초기화는 별도 파일로 제한합니다.

### 오류 2. 자동 증가 ID가 1부터 시작한다고 가정한다

관계 검증용 데이터에는 명시적 ID를 사용합니다.

### 오류 3. 명사만 보고 테이블을 만든다

동사, 수량 표현과 상태 변화를 함께 확인해야 관계·사건 테이블을 찾을 수 있습니다.

### 오류 4. `students`에 `course_ids` 문자열을 저장한다

N:M 관계는 `enrollments`로 표현합니다.

### 오류 5. 강사 정보와 학생 정보를 관계 테이블에 반복 저장한다

현재 정보의 주인 테이블을 정하고 외래키로 연결합니다.

### 오류 6. 신청 당시 결제 금액을 현재 강의 가격으로 대체한다

현재 가격과 사건 당시 가격은 서로 다른 사실입니다.

### 오류 7. 미확정 정책을 제약조건으로 먼저 고정한다

재신청 정책이 없는데 복합 `UNIQUE`를 적용하면 정상 업무를 막을 수 있습니다.

### 오류 8. 정상 데이터만 테스트한다

실패해야 하는 데이터로 `NOT NULL`, `UNIQUE`, `CHECK`, FK와 삭제 정책을 확인해야 합니다.

### 오류 9. 취소 신청을 바로 삭제한다

이력 보존이 필요하면 상태 변경을 우선합니다.

### 오류 10. AI가 제안한 `CASCADE`를 그대로 적용한다

삭제의 업무 의미와 영향 범위를 먼저 확인합니다.

---

## 20. 핵심 정리

```text
1. 프로젝트 범위와 미확정 정책을 설계 전에 구분한다.
2. 요구사항 추적표로 문장, 구조와 테스트를 연결한다.
3. 한 행의 의미와 컬럼의 주인을 기준으로 엔터티를 설계한다.
4. 관계는 양방향 문장과 카디널리티로 검토한다.
5. 학생과 강의의 N:M 관계는 enrollments로 해소한다.
6. 신청 상태와 실제 결제 금액은 신청 사건에 속한다.
7. 전용 스키마로 프로젝트 객체와 앞 장 실습을 분리한다.
8. IDENTITY와 명시적 테스트 ID를 함께 사용해 재현성을 높인다.
9. 정상·변경·오류 데이터로 구조와 무결성을 검증한다.
10. AI 제안은 근거와 실행 결과를 사람이 검토한 뒤 채택한다.
```

이 프로젝트에서 기억할 문장은 다음과 같습니다.

```text
좋은 프로젝트 데이터베이스는 요구사항을 구조로 바꾸는 데서 끝나지 않고,
정상 데이터와 실패해야 하는 데이터로 그 구조를 증명할 수 있어야 한다.
```

---

## 21. 다음 장에서는

Chapter 08에서는 최종 상태의 `course_project` 데이터를 사용해 서비스 질문에 답합니다.

```text
INNER JOIN과 LEFT JOIN
여러 테이블 JOIN
GROUP BY
COUNT, SUM, AVG
HAVING
학생별 수강 목록
강의별 신청자 수
상태별 신청 건수
강사별 강의 수
강의별 신청 금액
신청이 없는 학생·강의 찾기
```

Chapter 07의 최종 기준 데이터는 다음과 같습니다.

```text
students 3행
instructors 2행
courses 3행
enrollments 5행
신청 1001: 완료
신청 1004: 취소
신청 1005: 신규 신청
```

다음 장에서는 SQL 문법 자체보다, 이 데이터로 어떤 업무 질문에 답할 수 있는지에 집중합니다.
