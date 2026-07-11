# Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계

---

## 이 장에서 완성할 프로젝트

지금까지 데이터베이스의 기본 구조, PostgreSQL과 DBeaver, SQL, 데이터 모델링, ERD, 정규화를 차례로 살펴보았습니다. 이제 각각의 개념을 하나의 작은 서비스에 연결해 볼 차례입니다.

이 장에서는 **온라인 강의 수강신청 시스템**의 데이터베이스를 처음부터 끝까지 설계합니다.

```text
서비스 요구사항을 읽는다.
→ 엔터티와 속성을 찾는다.
→ 테이블 사이의 관계를 정한다.
→ ERD를 작성한다.
→ PostgreSQL 테이블로 구현한다.
→ 샘플 데이터를 입력한다.
→ JOIN과 CRUD로 구조를 검증한다.
→ 정규화와 데이터 정합성을 다시 확인한다.
→ AI가 만든 초안과 최종 설계를 비교한다.
```

![프로젝트 진행 흐름](../../images/chapter07/ch07_01_project_flow.svg)

그림 7-1 온라인 강의 데이터베이스 프로젝트 진행 흐름

이 프로젝트의 핵심은 SQL을 많이 작성하는 데 있지 않습니다. 서비스 설명을 데이터 구조로 바꾸고, 그 구조가 실제로 동작하는지 증명하는 데 있습니다.

---

## 1. 프로젝트를 시작하기 전에 정할 것

같은 요구사항을 읽어도 데이터베이스 구조는 조금씩 달라질 수 있습니다. 설계를 시작하기 전에 이번 버전의 범위를 먼저 정해야 합니다.

이 장에서는 다음 네 테이블을 중심으로 한 기본 버전을 만듭니다.

```text
students
instructors
courses
enrollments
```

결제 이력, 환불, 진도율, 강의 영상, 수료증, 수강평은 기본 범위에서 제외합니다. 다만 이후 확장 가능성을 고려해 현재 설계가 어떤 기능까지 수용할 수 있는지는 계속 확인합니다.

### 기본 설계 선택

| 항목 | 이 장의 선택 | 다른 선택 가능성 |
| --- | --- | --- |
| 학생과 강사 | 별도 테이블 | 공통 users 테이블과 역할 테이블 사용 |
| 결제 금액 | enrollments에 저장 | payments 테이블로 분리 |
| 수강 상태 | 문자열 열로 저장 | CHECK, ENUM, 상태 코드 테이블 사용 |
| 취소 처리 | 상태 변경 우선 | 행 삭제 또는 별도 이력 테이블 사용 |
| 같은 강의 재신청 | 기본 버전에서는 별도 제한 없음 | `(student_id, course_id)` UNIQUE 추가 |

초기 프로젝트에서는 단순한 구조가 유리합니다. 하지만 단순함과 부정확함은 다릅니다. 생략한 기능과 선택한 범위를 의식적으로 구분해야 합니다.

---

## 2. 서비스 시나리오

온라인 강의 서비스는 학생이 강의를 찾아 신청하고, 강사가 자신이 담당하는 강의를 운영하는 시스템입니다.

기본 요구사항은 다음과 같습니다.

```text
1. 학생은 이름, 이메일, 가입일을 가진다.
2. 강사는 이름, 이메일, 전문 분야를 가진다.
3. 강의는 제목, 설명, 난이도, 수강료, 개설일을 가진다.
4. 하나의 강의는 한 명의 강사가 담당한다.
5. 한 명의 강사는 여러 강의를 개설할 수 있다.
6. 학생은 여러 강의를 수강신청할 수 있다.
7. 하나의 강의에는 여러 학생이 수강신청할 수 있다.
8. 수강신청에는 신청일, 수강 상태, 결제 금액을 저장한다.
9. 수강 상태는 신청, 수강중, 완료, 취소 중 하나로 관리한다.
10. 학생 이메일과 강사 이메일은 각각 중복될 수 없다.
```

요구사항에는 데이터뿐 아니라 업무 규칙도 포함되어 있습니다.

| 요구사항 표현 | 데이터베이스 관점 |
| --- | --- |
| 학생은 이름과 이메일을 가진다 | students 테이블과 열 후보 |
| 강사는 여러 강의를 개설한다 | instructors와 courses의 1:N 관계 |
| 학생은 여러 강의를 신청한다 | students와 courses의 N:M 관계 |
| 이메일은 중복될 수 없다 | UNIQUE 제약조건 |
| 상태는 정해진 값 중 하나다 | CHECK 또는 도메인 규칙 후보 |

요구사항을 읽을 때 명사만 찾으면 테이블 후보를 얻을 수 있지만, 동사를 함께 살펴봐야 관계와 업무 규칙을 발견할 수 있습니다.

---

## 3. 요구사항에서 엔터티와 속성 찾기

먼저 중요한 명사를 표시합니다.

```text
학생, 이름, 이메일, 가입일,
강사, 전문 분야,
강의, 제목, 설명, 난이도, 수강료, 개설일,
수강신청, 신청일, 수강 상태, 결제 금액
```

![요구사항에서 엔터티 도출](../../images/chapter07/ch07_02_requirement_to_entities.svg)

그림 7-2 요구사항을 엔터티와 속성으로 바꾸는 과정

모든 명사가 테이블이 되는 것은 아닙니다.

| 후보 | 분류 | 이유 |
| --- | --- | --- |
| 학생 | 엔터티 | 여러 학생을 독립적으로 관리해야 함 |
| 강사 | 엔터티 | 강의를 담당하는 독립 대상 |
| 강의 | 엔터티 | 여러 학생과 강사가 관계를 맺는 핵심 대상 |
| 수강신청 | 엔터티 또는 관계 엔터티 | 학생과 강의의 연결 자체에 상태와 날짜가 있음 |
| 이름 | 속성 | 학생 또는 강사의 특징 |
| 이메일 | 속성 | 학생 또는 강사의 식별 가능한 연락 정보 |
| 수강 상태 | 속성 | 수강신청마다 달라지는 값 |
| 결제 금액 | 속성 | 수강신청 시점과 조건에 따라 달라질 수 있는 값 |

여기서 `enrollments`가 중요한 이유는 단순히 두 테이블을 연결하기 때문만이 아닙니다. 수강신청에는 신청일, 상태, 결제 금액처럼 **관계 자체의 정보**가 있기 때문입니다.

---

## 4. 테이블과 열 구성하기

기본 테이블 구조를 정리하면 다음과 같습니다.

| 테이블 | 역할 | 주요 열 |
| --- | --- | --- |
| students | 학생 정보 | id, name, email, joined_at |
| instructors | 강사 정보 | id, name, email, specialty |
| courses | 강의 정보 | id, instructor_id, title, description, level, price, opened_at |
| enrollments | 수강신청 정보 | id, student_id, course_id, enrolled_at, status, paid_amount |

### 4.1 students

학생 한 명을 안정적으로 구분하기 위해 `id`를 기본키로 사용합니다. 이메일은 중복을 허용하지 않지만, 변경될 가능성이 있으므로 기본키 대신 UNIQUE 열로 둡니다.

### 4.2 instructors

강사 역시 별도 기본키를 사용합니다. 강사 정보를 `courses`에 직접 반복 저장하지 않고 `instructor_id`로 연결합니다.

### 4.3 courses

강의에는 담당 강사를 가리키는 외래키가 필요합니다. 한 강사는 여러 강의를 담당할 수 있지만 한 강의에는 한 명의 강사만 연결된다는 기본 요구사항을 반영합니다.

### 4.4 enrollments

수강신청은 학생과 강의를 연결합니다. 동시에 신청일, 상태, 결제 금액을 보관합니다.

```text
students.id      ← enrollments.student_id
courses.id       ← enrollments.course_id
instructors.id   ← courses.instructor_id
```

---

## 5. 관계 분석하기

테이블 사이의 관계는 다음과 같습니다.

| 관계 | 유형 | 설명 |
| --- | --- | --- |
| instructors - courses | 1:N | 한 강사는 여러 강의를 담당할 수 있음 |
| students - enrollments | 1:N | 한 학생은 여러 수강신청을 가질 수 있음 |
| courses - enrollments | 1:N | 한 강의는 여러 수강신청을 가질 수 있음 |
| students - courses | N:M | 학생은 여러 강의를 신청하고 강의에는 여러 학생이 등록됨 |

학생과 강의를 직접 연결하려고 하면 한쪽 테이블에 여러 값을 넣어야 하는 문제가 생깁니다.

```text
잘못된 예
students.course_ids = '1,3,5'
```

이런 값은 검색, 외래키 검증, 수정, 집계가 어렵습니다. 따라서 N:M 관계를 두 개의 1:N 관계로 바꿉니다.

```text
students 1:N enrollments N:1 courses
```

![학생-강의 N:M 관계 해소](../../images/chapter07/ch07_04_many_to_many_enrollments.svg)

그림 7-3 연결 테이블로 학생과 강의의 N:M 관계를 표현하는 방식

---

## 6. ERD로 구조 확인하기

ERD를 텍스트로 표현하면 다음과 같습니다.

```text
students
- id PK
- name
- email UNIQUE
- joined_at

instructors
- id PK
- name
- email UNIQUE
- specialty

courses
- id PK
- instructor_id FK -> instructors.id
- title
- description
- level
- price
- opened_at

enrollments
- id PK
- student_id FK -> students.id
- course_id FK -> courses.id
- enrolled_at
- status
- paid_amount
```

![온라인 강의 수강신청 ERD](../../images/chapter07/ch07_03_online_course_erd.svg)

그림 7-4 온라인 강의 수강신청 데이터베이스 ERD

ERD를 확인할 때는 선의 모양보다 다음 질문이 더 중요합니다.

```text
모든 테이블에 기본키가 있는가?
외래키가 올바른 테이블을 참조하는가?
N:M 관계가 연결 테이블로 해소되었는가?
관계 자체의 속성이 연결 테이블에 있는가?
같은 정보가 여러 테이블에 반복 저장되지 않는가?
```

---

## 7. PostgreSQL 테이블로 구현하기

프로젝트 전체 SQL은 다음 파일에서 확인할 수 있습니다.

```text
code/chapter07/online_course_project.sql
```

핵심 DDL은 다음과 같습니다.

```sql
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE instructors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    specialty VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    instructor_id INT NOT NULL REFERENCES instructors(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    level VARCHAR(20) NOT NULL,
    price INT NOT NULL CHECK (price >= 0),
    opened_at DATE NOT NULL
);

CREATE TABLE enrollments (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    course_id INT NOT NULL REFERENCES courses(id),
    enrolled_at DATE NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('신청', '수강중', '완료', '취소')),
    paid_amount INT NOT NULL CHECK (paid_amount >= 0)
);
```

### 테이블 삭제 순서가 중요한 이유

`enrollments`는 `students`와 `courses`를 참조합니다. `courses`는 `instructors`를 참조합니다. 따라서 참조하는 테이블부터 먼저 삭제해야 합니다.

```text
enrollments
→ courses
→ instructors
→ students
```

생성할 때는 반대 순서로 진행합니다. 외래키가 참조할 대상 테이블이 먼저 존재해야 하기 때문입니다.

### 제약조건으로 표현한 규칙

| 규칙 | 구현 |
| --- | --- |
| 이메일 중복 금지 | UNIQUE |
| 필수값 누락 방지 | NOT NULL |
| 존재하지 않는 강사·학생·강의 참조 금지 | FOREIGN KEY |
| 음수 가격 금지 | CHECK |
| 허용되지 않은 수강 상태 금지 | CHECK |

문서에만 적힌 규칙은 애플리케이션이 실수하면 깨질 수 있습니다. 데이터베이스가 직접 검증할 수 있는 규칙은 제약조건으로 표현하는 편이 안전합니다.

---

## 8. 샘플 데이터로 관계 검증하기

테이블이 만들어졌다고 설계가 검증된 것은 아닙니다. 관계가 실제로 표현되는지 확인할 샘플 데이터가 필요합니다.

```sql
INSERT INTO students (name, email, joined_at)
VALUES
    ('김민지', 'minji@example.com', '2026-03-01'),
    ('이준호', 'junho@example.com', '2026-03-03'),
    ('박서연', 'seoyeon@example.com', '2026-03-05');

INSERT INTO instructors (name, email, specialty)
VALUES
    ('문길래', 'gilbert@example.com', 'Database'),
    ('홍길동', 'hong@example.com', 'Python');
```

강의와 수강신청 데이터는 외래키가 참조하는 행이 먼저 존재한 뒤 입력합니다.

```sql
INSERT INTO courses
    (instructor_id, title, description, level, price, opened_at)
VALUES
    (1, '데이터베이스 입문', '관계형 데이터베이스와 SQL 기초', 'basic', 100000, '2026-04-01'),
    (1, '정규화 실습', '좋은 테이블 설계와 정규화', 'basic', 120000, '2026-04-05'),
    (2, '파이썬 데이터 분석', 'Pandas 기반 데이터 분석 입문', 'basic', 150000, '2026-04-10');

INSERT INTO enrollments
    (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (1, 1, '2026-04-02', '수강중', 100000),
    (1, 2, '2026-04-06', '신청', 120000),
    (2, 1, '2026-04-03', '수강중', 100000),
    (3, 3, '2026-04-11', '신청', 150000);
```

이 데이터는 다음 상황을 확인할 수 있도록 구성되어 있습니다.

```text
한 학생이 여러 강의를 신청한다.
한 강의에 여러 학생이 등록한다.
한 강사가 여러 강의를 담당한다.
수강신청별로 상태와 결제 금액이 다르다.
```

샘플 데이터는 단순히 행 수를 채우는 값이 아니라 요구사항을 검증하는 테스트 데이터입니다.

---

## 9. JOIN으로 사용 가능한 정보 만들기

분리된 테이블은 중복을 줄이는 데 유리하지만, 실제 화면이나 보고서에서는 여러 테이블의 정보가 함께 필요합니다.

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
JOIN instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;
```

이 조회는 다음 연결이 모두 정상인지 확인합니다.

```text
enrollments.student_id → students.id
enrollments.course_id → courses.id
courses.instructor_id → instructors.id
```

![SQL 기반 설계 검증 흐름](../../images/chapter07/ch07_05_sql_validation_flow.svg)

그림 7-5 샘플 데이터와 JOIN으로 설계를 검증하는 흐름

JOIN 결과가 예상과 다르다면 SQL 문법만 보지 말고 다음 항목도 확인해야 합니다.

- 외래키 값이 올바른 행을 가리키는가?
- 필요한 샘플 데이터가 모두 입력되었는가?
- JOIN 조건에서 서로 다른 열을 연결하지 않았는가?
- 중복 수강신청 때문에 같은 정보가 반복되지 않는가?

---

## 10. CRUD와 안전한 변경

데이터베이스 구조는 조회뿐 아니라 추가, 수정, 삭제에서도 자연스럽게 동작해야 합니다.

### 특정 학생의 수강 목록 조회

```sql
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
WHERE s.email = 'minji@example.com';
```

### 새로운 수강신청 추가

```sql
INSERT INTO enrollments
    (student_id, course_id, enrolled_at, status, paid_amount)
VALUES
    (2, 2, '2026-04-07', '신청', 120000);
```

### 상태 변경 전 대상 확인

```sql
SELECT *
FROM enrollments
WHERE id = 1;
```

확인한 뒤 수정합니다.

```sql
UPDATE enrollments
SET status = '완료'
WHERE id = 1;
```

### 삭제보다 상태 변경을 먼저 검토하기

취소된 수강신청을 바로 삭제하면 이력이 사라집니다.

```sql
UPDATE enrollments
SET status = '취소'
WHERE id = 4;
```

행을 실제로 삭제해야 한다면 같은 조건의 `SELECT`로 대상을 먼저 확인합니다.

```sql
SELECT *
FROM enrollments
WHERE id = 4;

DELETE FROM enrollments
WHERE id = 4;
```

`UPDATE`와 `DELETE`에서 가장 중요한 습관은 실행 전에 대상 행을 확인하는 것입니다.

---

## 11. 정규화와 데이터 정합성 검토

현재 구조를 정규화 관점에서 살펴보겠습니다.

![프로젝트 정규화 검토](../../images/chapter07/ch07_06_normalization_review_flow.svg)

그림 7-6 데이터 중복과 이상 현상을 확인하는 흐름

| 검토 항목 | 현재 구조 | 효과 |
| --- | --- | --- |
| 학생 정보 분리 | students | 학생 이메일을 한 곳에서 관리 |
| 강사 정보 분리 | instructors | 여러 강의에 강사 정보가 반복되지 않음 |
| 강의 정보 분리 | courses | 수강신청마다 제목과 가격을 반복 저장하지 않음 |
| N:M 관계 해소 | enrollments | 학생과 강의를 여러 건 연결 가능 |
| 참조 무결성 | 외래키 | 존재하지 않는 학생·강의·강사 참조 방지 |
| 도메인 검증 | CHECK | 음수 금액과 잘못된 상태 방지 |

### 수정 이상 확인

학생 이메일이 바뀌면 `students`의 한 행만 수정하면 됩니다. 수강신청 행마다 이메일을 저장했다면 여러 행을 찾아 수정해야 합니다.

### 삭제 이상 확인

수강신청 한 건을 삭제해도 학생과 강의 정보는 유지됩니다. 모든 정보를 하나의 테이블에 저장했다면 마지막 수강신청을 지우면서 강의 정보까지 사라질 수 있습니다.

### 추가로 검토할 규칙

현재 설계에서는 같은 학생이 같은 강의를 여러 번 신청할 수 있습니다. 이를 막으려면 다음 제약조건을 고려할 수 있습니다.

```sql
ALTER TABLE enrollments
ADD CONSTRAINT uq_enrollments_student_course
UNIQUE (student_id, course_id);
```

하지만 취소 후 재신청 이력을 별도로 남겨야 한다면 단순 UNIQUE가 요구사항과 맞지 않을 수 있습니다. 제약조건은 강할수록 좋은 것이 아니라 실제 업무 규칙과 맞아야 합니다.

---

## 12. AI를 설계 조수로 활용하기

AI는 요구사항 정리, 테이블 후보 제안, DDL 초안, JOIN 작성, 오류 해석을 빠르게 도와줄 수 있습니다.

```text
다음 요구사항을 바탕으로 PostgreSQL 데이터베이스 구조를 제안해 주세요.
학생, 강사, 강의, 수강신청을 관리해야 합니다.
각 테이블의 열, 기본키, 외래키, 관계를 설명하고
실행 가능한 CREATE TABLE SQL을 작성해 주세요.
N:M 관계, 중복 데이터, 삽입·수정·삭제 이상 가능성도 검토해 주세요.
```

![AI 활용 및 검토 흐름](../../images/chapter07/ch07_07_ai_review_flow.svg)

그림 7-7 AI 제안을 실행 가능한 설계로 검증하는 흐름

AI가 만든 결과는 다음 기준으로 확인합니다.

| 검토 영역 | 확인 질문 |
| --- | --- |
| 요구사항 | 빠진 데이터와 규칙이 없는가? |
| 엔터티 | 테이블을 지나치게 합치거나 나누지 않았는가? |
| 관계 | N:M 관계를 연결 테이블로 처리했는가? |
| 키 | PK와 FK의 방향이 정확한가? |
| 제약조건 | NOT NULL, UNIQUE, CHECK가 요구사항과 맞는가? |
| 문법 | PostgreSQL에서 처음부터 끝까지 실행되는가? |
| 검증 | 샘플 데이터와 JOIN이 포함되어 있는가? |
| 안전성 | UPDATE와 DELETE 전에 대상을 확인하는가? |

특히 AI는 존재하지 않는 요구사항을 자연스럽게 추가하거나, 반대로 중요한 업무 규칙을 생략할 수 있습니다. SQL이 실행된다는 이유만으로 설계가 적절하다고 판단해서는 안 됩니다.

---

## 13. 프로젝트 완성도 점검

이 프로젝트의 결과는 다음 항목으로 스스로 점검할 수 있습니다.

| 영역 | 확인 기준 |
| --- | --- |
| 요구사항 분석 | 핵심 명사와 동사를 데이터 구조로 연결했는가? |
| 엔터티 | 테이블과 열을 구분한 이유를 설명할 수 있는가? |
| 관계 | 1:N과 N:M 관계가 ERD에 드러나는가? |
| 키 | 각 PK와 FK의 역할이 명확한가? |
| DDL | 빈 데이터베이스에서 순서대로 실행되는가? |
| 제약조건 | 잘못된 데이터가 실제로 차단되는가? |
| 샘플 데이터 | 관계와 업무 규칙을 검증할 만큼 다양하게 구성했는가? |
| JOIN | 서비스에서 사용할 수 있는 형태로 정보를 조회하는가? |
| CRUD | 추가·수정·취소 흐름이 자연스러운가? |
| 정규화 | 중복과 이상 현상이 줄어드는가? |
| AI 검토 | AI 제안과 직접 수정한 내용을 구분할 수 있는가? |
| 재현성 | 다른 사람이 SQL 파일을 실행해 같은 결과를 얻을 수 있는가? |

점수보다 중요한 것은 설계를 다시 설명하고 재현할 수 있는지입니다.

---

## 14. 프로젝트 확장 아이디어

기본 구조가 정상적으로 동작하면 다음 기능을 하나씩 추가할 수 있습니다.

### 14.1 강의 정원

`courses.capacity`와 현재 신청 인원을 비교해 신청 또는 대기 상태를 결정합니다.

### 14.2 결제 분리

결제 시도, 성공, 실패, 환불 이력을 관리하려면 `payments` 테이블을 별도로 둡니다.

### 14.3 강의 구성

강의를 여러 섹션과 영상으로 나누려면 `course_sections`, `lessons` 테이블을 추가합니다.

### 14.4 진도와 수료

회원별 진행률과 완료 상태는 콘텐츠 자체의 속성이 아니라 회원과 콘텐츠 관계에 속하므로 별도 `progress` 또는 `content_progress` 테이블이 적합합니다.

### 14.5 이용 후기

회원이 이용한 콘텐츠에 별점과 후기 내용을 남기도록 `reviews` 테이블을 추가할 수 있습니다.

기능을 추가할 때는 바로 열을 늘리기보다 새로운 데이터가 어느 엔터티나 관계에 속하는지 먼저 판단합니다.

---

## 15. 자주 발생하는 설계 오류

### 오류 1. students에 course_id 하나만 둔다

학생이 여러 강의를 신청할 수 있으므로 하나의 `course_id`로는 요구사항을 표현할 수 없습니다.

### 오류 2. courses에 강사 이름과 이메일을 반복 저장한다

한 강사가 여러 강의를 담당하면 같은 정보가 반복됩니다. 강사를 분리하고 외래키로 연결해야 합니다.

### 오류 3. enrollments에 학생 이름과 강의 제목을 저장한다

이름과 제목이 바뀔 때 여러 행을 수정해야 합니다. 식별자를 외래키로 저장하고 JOIN으로 필요한 이름을 조회합니다.

### 오류 4. 관계에 속하는 값을 잘못된 테이블에 둔다

수강 상태와 실제 결제 금액은 학생 전체나 강의 전체의 속성이 아니라 특정 학생의 특정 강의 신청에 속합니다.

### 오류 5. 샘플 데이터가 너무 단순하다

학생 한 명, 강의 한 개, 수강신청 한 건만 있으면 1:N과 N:M 관계를 충분히 검증할 수 없습니다.

### 오류 6. AI가 만든 SQL을 한 번도 실행하지 않는다

문법 오류뿐 아니라 생성 순서, 외래키 값, 중복 데이터, 재실행 문제는 실제 DBMS에서 확인해야 합니다.

### 오류 7. 수정과 삭제를 바로 실행한다

변경 전에 같은 `WHERE` 조건으로 `SELECT`를 실행해 대상 행을 확인해야 합니다.

---

## 16. 핵심 정리

```text
1. 서비스 요구사항은 엔터티, 속성, 관계, 업무 규칙으로 분해한다.
2. 모든 명사가 테이블이 되는 것은 아니다.
3. 기본키는 행을 구분하고 외래키는 테이블을 연결한다.
4. 학생과 강의의 N:M 관계는 enrollments로 해소한다.
5. 관계 자체의 정보는 연결 테이블에 저장한다.
6. 제약조건은 문서에 적힌 규칙을 데이터베이스가 직접 지키게 한다.
7. 샘플 데이터와 JOIN은 설계가 실제로 동작하는지 검증한다.
8. 정규화는 중복과 삽입·수정·삭제 이상을 줄이는 과정이다.
9. AI는 설계 초안을 빠르게 만들지만 요구사항과 실행 결과는 사람이 확인해야 한다.
```

이 프로젝트에서 기억할 문장은 다음과 같습니다.

```text
좋은 데이터베이스 설계는 ERD가 보기 좋은 설계가 아니라,
요구사항을 정확히 표현하고 실제 데이터로 검증할 수 있는 설계이다.
```

---

## 17. 다음 장에서는

다음 장에서는 이 프로젝트에서 만든 `students`, `instructors`, `courses`, `enrollments`를 활용해 여러 테이블을 더 깊게 조회합니다.

```text
INNER JOIN과 OUTER JOIN
여러 테이블 JOIN
GROUP BY
COUNT, SUM, AVG
HAVING
강의별 수강생 수
상태별 신청 건수
강사별 강의 수
강의별 매출
```

이번 장에서 구조를 제대로 설계했다면 다음 장의 JOIN과 집계는 단순한 SQL 문법이 아니라 서비스의 질문에 답하는 도구로 보이기 시작합니다.
