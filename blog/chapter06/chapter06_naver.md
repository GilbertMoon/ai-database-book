# [AI 시대의 데이터베이스 입문 06] 정규화와 데이터 무결성 쉽게 이해하기

안녕하세요. 아토믹데브입니다.

지난 Chapter 05에서는 요구사항을 읽고 엔터티, 속성, 관계를 찾아 ERD로 표현하는 방법을 살펴봤습니다.

이번 시간에는 만든 테이블 구조가 실제 데이터 변화에도 안전한지 확인하는 방법을 배웁니다.

핵심 주제는 두 가지입니다.

```text
정규화(Normalization)
→ 같은 사실을 여러 곳에 중복 저장하지 않도록 테이블 구조를 정리하는 과정

데이터 무결성(Data Integrity)
→ 잘못된 값과 잘못된 관계가 저장되지 않도록 규칙을 적용하는 것
```

이번 글에서는 어려운 이론 암기보다 **왜 테이블을 나누는지, 어떤 규칙을 DB에 적용해야 하는지**를 예제로 이해해 보겠습니다.

---

## 오늘 배울 내용

이번 글을 끝까지 따라오면 다음 내용을 설명할 수 있습니다.

- 위험한 중복과 정상적인 반복의 차이
- 삽입·수정·삭제 이상
- 함수적 종속의 기본 개념
- 제1정규형, 제2정규형, 제3정규형
- 각 열의 주인 테이블을 찾는 방법
- `NOT NULL`, `UNIQUE`, `CHECK`, `PRIMARY KEY`, `FOREIGN KEY`
- 정규화와 무결성 제약조건의 차이
- AI가 만든 테이블 구조를 검증하는 방법

---

## STEP 1. 하나의 큰 테이블이 왜 문제가 될까요?

도서 대여 시스템을 하나의 테이블로 만든다고 가정해 보겠습니다.

| loan_id | member_name | member_email | book_title | author | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1001 | 김민지 | minji@example.com | 데이터베이스 입문 | 문길래 | 2026-04-01 | 2026-04-15 | 2026-04-02 |
| 1002 | 김민지 | minji@example.com | SQL 기초 | 홍길동 | 2026-04-02 | 2026-04-16 | NULL |
| 1003 | 이준호 | junho@example.com | 데이터베이스 입문 | 문길래 | 2026-04-03 | 2026-04-17 | NULL |

처음 보면 한눈에 모든 정보가 보여서 편해 보입니다.

하지만 다음 문제가 생깁니다.

```text
김민지의 이름과 이메일이 여러 행에 반복된다.
같은 책 제목과 저자가 여러 번 반복된다.
회원 이메일이 바뀌면 여러 행을 수정해야 한다.
아직 한 번도 대여되지 않은 책을 등록하기 어렵다.
마지막 대여 행을 삭제하면 책 정보까지 사라질 수 있다.
```

즉, 처음 데이터를 넣을 때 편한 구조가 반드시 좋은 구조는 아닙니다.

좋은 구조는 **데이터가 추가·수정·삭제될 때도 의미가 깨지지 않는 구조**입니다.

---

## STEP 2. 모든 중복이 나쁜 것은 아닙니다

정규화를 처음 배우면 "중복은 무조건 제거해야 한다"고 오해하기 쉽습니다.

하지만 반복에도 종류가 있습니다.

### 위험한 중복

```text
여러 대여 기록에 같은 회원 이메일을 복사해 저장
```

이메일이 변경되면 모든 대여 행을 함께 수정해야 합니다.

### 정상적인 반복

```text
loans 테이블에서 member_id = 101이 여러 번 등장
```

회원 101번이 여러 번 책을 빌렸다는 정상적인 업무 사실입니다.

### 의미 있는 이력

```text
주문 당시 가격
신청 당시 수강료
계약 당시 주소
```

현재 값과 달라도 과거 시점의 사실을 보존하기 위해 일부러 저장하는 값입니다.

따라서 다음 질문을 사용하면 좋습니다.

```text
이 값은 같은 사실을 여러 번 복사한 것인가?
각 행마다 독립적인 업무 의미가 있는가?
값이 바뀌면 한 곳만 수정하면 되는가?
과거 시점의 사실을 보존하기 위한 값인가?
```

---

## STEP 3. 삽입·수정·삭제 이상을 이해해 봅시다

잘못된 테이블 구조는 데이터 변경 과정에서 문제가 드러납니다.

### 삽입 이상 Insert Anomaly

아직 한 번도 대여되지 않은 새 책을 등록하고 싶은데 대여 정보까지 함께 넣어야 한다면 문제가 됩니다.

```text
책 정보만 추가하고 싶은데
대여 행을 만들어야 한다.
```

### 수정 이상 Update Anomaly

회원 이메일이 여러 행에 반복되면 모든 행을 수정해야 합니다.

```text
minji@example.com
→ minji.new@example.com
```

한 행이라도 빠뜨리면 같은 회원의 이메일이 서로 달라집니다.

### 삭제 이상 Delete Anomaly

마지막 대여 기록을 삭제했는데 책 정보까지 함께 사라질 수 있습니다.

```text
대여 기록 삭제
→ 도서 정보도 함께 삭제
```

이 세 가지를 합쳐 **이상 현상(Anomaly)** 이라고 합니다.

---

## STEP 4. 한 행의 의미와 열의 주인을 정합니다

정규화에서 가장 먼저 해야 할 질문은 다음입니다.

```text
이 테이블의 한 행은 무엇을 의미하는가?
```

도서 대여 시스템을 나누면 다음과 같습니다.

```text
members 한 행
→ 회원 한 명

books 한 행
→ 도서 한 건

loans 한 행
→ 특정 회원이 특정 도서를 빌린 대여 사건 한 건
```

그리고 각 열의 주인을 찾습니다.

| 열 | 실제 의미 | 적절한 테이블 |
| --- | --- | --- |
| `member_name` | 회원의 이름 | `members` |
| `member_email` | 회원의 이메일 | `members` |
| `book_title` | 책 제목 | `books` |
| `author` | 저자 | `books` |
| `borrowed_at` | 대여일 | `loans` |
| `due_at` | 반납 예정일 | `loans` |
| `returned_at` | 실제 반납일 | `loans` |

다음 질문을 반복해 보세요.

```text
이 값은 누구를 설명하는가?
이 값이 변경되는 이유는 무엇인가?
현재 사실인가?
사건 당시의 이력인가?
```

---

## STEP 5. 함수적 종속을 아주 쉽게 이해해 봅시다

함수적 종속은 어렵게 느껴지지만 기본 개념은 단순합니다.

```text
X → Y
```

X를 알면 Y가 결정된다는 의미입니다.

예를 들어 다음과 같습니다.

```text
member_id → member_name, member_email
book_id   → book_title, author
loan_id   → borrowed_at, due_at, returned_at
```

회원 ID가 101이면 그 회원의 이름과 이메일이 결정됩니다.

다만 샘플 데이터에서 우연히 같은 값이 반복된다고 함수적 종속이 되는 것은 아닙니다.

**업무 규칙상 항상 그래야 하는 관계인지**를 확인해야 합니다.

---

## STEP 6. 제1정규형 1NF

제1정규형에서는 한 칸에 여러 독립적인 값을 묶어 넣거나 반복 열을 만드는 구조를 피합니다.

잘못된 예를 보겠습니다.

| member_id | member_name | borrowed_books |
| ---: | --- | --- |
| 101 | 김민지 | 데이터베이스 입문, SQL 기초 |

`borrowed_books` 한 칸에 여러 책이 들어 있습니다.

이렇게 저장하면 책 하나만 검색하거나 다른 테이블과 연결하기 어렵습니다.

다음처럼 한 대여를 한 행으로 분리하는 편이 낫습니다.

| member_id | book_title |
| ---: | --- |
| 101 | 데이터베이스 입문 |
| 101 | SQL 기초 |

또 다음과 같은 반복 열도 피합니다.

```text
book1
book2
book3
```

핵심 질문은 이것입니다.

```text
독립적으로 검색·수정·연결해야 할 값을
한 셀이나 반복 열에 묶어 두지는 않았는가?
```

---

## STEP 7. 제2정규형 2NF

제2정규형은 **복합키의 일부에만 의존하는 열이 있는지** 확인합니다.

다음 테이블을 보겠습니다.

| student_id | course_id | student_name | course_name | grade |
| ---: | ---: | --- | --- | --- |
| 1 | 101 | 김민지 | 데이터베이스 | A |
| 1 | 102 | 김민지 | 알고리즘 | B |
| 2 | 101 | 이준호 | 데이터베이스 | A |

한 학생이 같은 강의를 한 번만 수강한다고 가정하면 `(student_id, course_id)`가 복합키가 될 수 있습니다.

그런데 의존 관계를 보면 다음과 같습니다.

```text
student_id → student_name
course_id → course_name
student_id + course_id → grade
```

`student_name`은 전체 복합키가 아니라 `student_id`에만 의존합니다.

`course_name`도 `course_id`에만 의존합니다.

따라서 다음처럼 분리할 수 있습니다.

```text
students(id, name)
courses(id, name)
enrollments(student_id, course_id, grade)
```

제2정규형의 핵심 질문은 다음입니다.

```text
복합키가 있을 때,
일부 키에만 의존하는 열이 섞여 있지 않은가?
```

---

## STEP 8. 제3정규형 3NF

제3정규형에서는 기본키가 아닌 열이 또 다른 일반 열을 결정하는 구조를 확인합니다.

예를 들어 다음 테이블을 생각해 보겠습니다.

| student_id | student_name | department_id | department_name |
| ---: | --- | ---: | --- |
| 1 | 김민지 | 10 | 컴퓨터공학과 |
| 2 | 이준호 | 20 | 데이터사이언스학과 |

다음 관계가 있습니다.

```text
student_id → department_id
department_id → department_name
```

학생 ID가 학과명을 직접 결정하는 것이 아니라 `department_id`를 거쳐 학과명이 결정됩니다.

이런 경우 학과 정보를 별도 테이블로 분리할 수 있습니다.

```text
students
- id
- name
- department_id

departments
- id
- name
```

핵심 질문은 다음입니다.

```text
이 열은 정말 이 테이블의 기본키에 직접 의존하는가?
아니면 다른 일반 열을 통해 결정되는가?
```

---

## STEP 9. 정규화된 도서 대여 구조를 만들어 봅시다

지금까지의 내용을 반영하면 다음처럼 나눌 수 있습니다.

```text
members
- id
- name
- email
- joined_at

books
- id
- title
- author
- published_year
- isbn

loans
- id
- member_id
- book_id
- borrowed_at
- due_at
- returned_at
```

관계는 다음과 같습니다.

```text
members 1 : N loans
books   1 : N loans
```

`loans`는 회원과 도서 사이의 관계를 기록하면서 대여일, 반납 예정일, 실제 반납일 같은 **사건 자체의 속성**도 저장합니다.

---

## STEP 10. 정규화만으로는 데이터가 안전하지 않습니다

테이블을 잘 나눴다고 모든 문제가 해결되는 것은 아닙니다.

예를 들어 다음과 같은 잘못된 데이터가 들어갈 수 있습니다.

```text
회원 이메일이 NULL
같은 이메일이 두 번 등록
반납 예정일이 대여일보다 이전
존재하지 않는 회원 ID로 대여 등록
```

따라서 데이터베이스에 업무 규칙을 적용해야 합니다.

이때 사용하는 것이 **무결성 제약조건**입니다.

---

## STEP 11. PRIMARY KEY

기본키는 각 행을 고유하게 구분합니다.

```sql
id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
```

기본키는 다음 특성을 가집니다.

```text
중복 불가
NULL 불가
한 행을 안정적으로 식별
```

---

## STEP 12. NOT NULL과 UNIQUE

### NOT NULL

필수값이 비어 있지 않도록 합니다.

```sql
name VARCHAR(100) NOT NULL
```

### UNIQUE

중복을 제한합니다.

```sql
email VARCHAR(255) UNIQUE NOT NULL
```

하지만 `UNIQUE`를 추가하기 전에 먼저 업무 정책을 확인해야 합니다.

```text
회원 이메일은 반드시 고유한가?
대소문자를 같은 이메일로 볼 것인가?
탈퇴 회원 이메일을 재사용할 수 있는가?
```

AI가 "이메일이니까 UNIQUE"라고 자동 판단하더라도 실제 업무 규칙을 먼저 확인해야 합니다.

---

## STEP 13. FOREIGN KEY

외래키는 존재하지 않는 부모 행을 참조하지 못하도록 관계를 보호합니다.

예를 들어 `loans` 테이블은 회원과 도서를 참조합니다.

```sql
member_id INTEGER NOT NULL
    REFERENCES members(id),

book_id INTEGER NOT NULL
    REFERENCES books(id)
```

이제 존재하지 않는 회원 번호로 대여 기록을 만들려고 하면 PostgreSQL이 오류를 발생시킵니다.

```text
FOREIGN KEY
→ 관계의 무결성을 보호
```

---

## STEP 14. CHECK 제약조건

`CHECK`는 값이 특정 조건을 만족하는지 확인합니다.

예를 들어 반납 예정일은 대여일보다 빠르면 안 된다고 가정해 보겠습니다.

```sql
CHECK (due_at >= borrowed_at)
```

실제 반납일도 대여일보다 이전이면 안 된다고 정책을 정했다면 다음과 같이 작성할 수 있습니다.

```sql
CHECK (
    returned_at IS NULL
    OR returned_at >= borrowed_at
)
```

여기서 중요한 점은 **업무 규칙이 먼저이고 SQL은 그다음**이라는 것입니다.

```text
요구사항 확정
→ 규칙 정의
→ 적절한 제약조건 선택
→ 정상/오류 데이터로 검증
```

---

## STEP 15. 정규화와 무결성은 역할이 다릅니다

둘은 함께 사용하지만 같은 개념은 아닙니다.

| 구분 | 핵심 역할 |
| --- | --- |
| 정규화 | 사실을 적절한 테이블에 나누어 중복과 이상 현상을 줄임 |
| 무결성 제약조건 | 잘못된 값과 관계가 저장되지 않도록 제한 |

쉽게 정리하면 다음과 같습니다.

```text
정규화
→ 어디에 저장할 것인가?

무결성
→ 어떤 값과 관계를 허용할 것인가?
```

---

## STEP 16. PostgreSQL DDL 예제를 만들어 봅시다

다음은 학습용으로 단순화한 예입니다.

```sql
CREATE TABLE members (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    joined_at DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE books (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INTEGER,
    isbn VARCHAR(20)
);

CREATE TABLE loans (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES members(id),
    book_id INTEGER NOT NULL REFERENCES books(id),
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE,
    CHECK (due_at >= borrowed_at),
    CHECK (returned_at IS NULL OR returned_at >= borrowed_at)
);
```

이 구조가 완벽한 실무 도서관 시스템은 아닙니다.

ISBN의 고유성, 동일 도서의 복본 관리, 여러 저자, 동시 대여 제한 등은 추가 요구사항에 따라 확장해야 합니다.

---

## STEP 17. 정상 데이터와 오류 데이터를 모두 테스트합니다

제약조건은 만들어 놓는 것만으로 끝나지 않습니다.

### 정상 데이터

```text
borrowed_at = 2026-04-01
due_at      = 2026-04-15
returned_at = NULL
```

정상적으로 저장되어야 합니다.

### 오류 데이터

```text
borrowed_at = 2026-04-15
due_at      = 2026-04-01
```

`CHECK` 제약조건 때문에 저장되지 않아야 합니다.

또 존재하지 않는 회원 ID를 입력하면 외래키 오류가 발생해야 합니다.

```text
정상 데이터 통과
경계 데이터 확인
오류 데이터 차단
```

이 세 가지를 모두 확인해야 규칙이 제대로 적용되었다고 볼 수 있습니다.

---

## AI 활용 실습 1. 정규화 문제 찾기

ChatGPT나 Codex에 다음 프롬프트를 입력해 보세요.

```text
나는 PostgreSQL과 데이터베이스 정규화를 처음 배우는 초보자입니다.

다음 테이블을 검토해 주세요.

library_records(
  loan_id,
  member_name,
  member_email,
  book_title,
  author,
  borrowed_at,
  due_at,
  returned_at
)

1. 어떤 데이터가 위험하게 중복되는지
2. 삽입·수정·삭제 이상이 어떤 상황에서 생기는지
3. 어떤 테이블로 분리하면 좋은지
4. 각 테이블의 한 행은 무엇을 의미하는지

초보자가 이해할 수 있게 설명해 주세요.
```

AI 답변을 받은 뒤 다음을 직접 확인합니다.

```text
왜 그 테이블을 분리했는가?
각 열의 주인은 누구인가?
의미 있는 이력까지 제거하지 않았는가?
```

---

## AI 활용 실습 2. 제약조건 검토하기

다음 프롬프트를 사용해 보세요.

```text
다음 업무 규칙을 PostgreSQL 제약조건으로 구현하려고 합니다.

- 회원 이름은 필수
- 회원 이메일은 중복 불가
- 대여 기록은 실제 존재하는 회원과 도서를 참조
- 반납 예정일은 대여일보다 빠를 수 없음
- 실제 반납일은 NULL일 수 있음
- 실제 반납일이 있으면 대여일보다 빠를 수 없음

각 규칙에 PRIMARY KEY, FOREIGN KEY, NOT NULL,
UNIQUE, CHECK 중 어떤 제약조건을 사용하면 좋은지 설명하고
DDL 예제를 작성해 주세요.

마지막에는 DB 제약조건만으로 처리하기 어려운 업무 규칙도 구분해 주세요.
```

AI가 제안한 SQL을 바로 사용하지 말고 **실제 요구사항과 PostgreSQL 동작을 다시 확인**하세요.

---

## 오늘의 핵심 정리

이번 Chapter에서 꼭 기억할 내용은 다음과 같습니다.

```text
정규화
→ 같은 사실의 위험한 중복을 줄인다.

1NF
→ 독립적인 반복값을 한 셀이나 반복 열에 묶지 않는다.

2NF
→ 복합키 일부에만 의존하는 열을 분리한다.

3NF
→ 일반 열을 통해 간접적으로 결정되는 속성을 분리한다.

PRIMARY KEY
→ 행을 구분한다.

FOREIGN KEY
→ 관계를 보호한다.

NOT NULL
→ 필수값을 보호한다.

UNIQUE
→ 중복을 제한한다.

CHECK
→ 값의 업무 규칙을 제한한다.
```

가장 중요한 질문은 다음입니다.

```text
이 사실의 주인은 어떤 테이블인가?
같은 사실을 여러 곳에 복사하고 있지는 않은가?
이 규칙은 요구사항에서 확정된 것인가?
DB가 직접 막아야 할 잘못된 값은 무엇인가?
```

---

## 다음 시간에는

다음 Chapter에서는 지금까지 배운 **요구사항 분석, ERD, 정규화, 제약조건과 기본 SQL**을 하나로 연결하여 실제 온라인 강의 수강신청 데이터베이스를 완성합니다.

학생, 강사, 강의, 수강신청 테이블을 직접 만들고 관계와 데이터를 검증하는 첫 번째 실전 프로젝트를 진행합니다.

---

## 관련 글

- Chapter 05. 요구사항에서 데이터 모델과 ERD 만들기
- Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

---

#데이터베이스 #정규화 #데이터무결성 #PostgreSQL #SQL #ERD #DB설계 #ChatGPT #Codex #데이터베이스강의