# Chapter 06. 정규화와 좋은 테이블 설계

---

## 이 장에서 살펴볼 내용

이 장에서는 데이터 중복을 줄이고 안정적인 테이블 구조를 만드는 **정규화**를 살펴봅니다.

Chapter 05에서는 요구사항에서 엔터티, 속성, 관계를 찾고 ERD를 설계했습니다. Chapter 06에서는 그 설계가 데이터 변경에도 안정적인지 점검합니다.

이 장에서 다룰 내용은 다음과 같습니다.

- 데이터 중복과 삽입·수정·삭제 이상
- 1정규형, 2정규형, 3정규형
- 도서 대여 시스템의 테이블 분리
- 정규화된 구조의 PostgreSQL 구현과 JOIN 검증
- 과도한 정규화를 피하는 기준
- AI가 만든 테이블 구조 검토

이 장의 목표는 정규형 이름을 외우는 것이 아닙니다. 테이블을 보고 “한 행이 무엇을 의미하는가?”, “각 컬럼의 주인은 누구인가?”, “데이터를 바꿀 때 문제가 생기지 않는가?”를 판단하는 능력을 기르는 것입니다.

---

## 1. 왜 정규화를 배워야 하는가

처음에는 회원, 책, 대여 정보를 하나의 큰 테이블에 저장하는 방식이 쉬워 보입니다.

| loan_id | member_name | member_email | book_title | author | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1 | 김민지 | minji@example.com | 데이터베이스 입문 | 문길래 | 2026-04-01 | 2026-04-15 | NULL |
| 2 | 김민지 | minji@example.com | SQL 기초 | 홍길동 | 2026-04-02 | 2026-04-16 | 2026-04-10 |
| 3 | 이준호 | junho@example.com | 데이터베이스 입문 | 문길래 | 2026-04-03 | 2026-04-17 | NULL |

하지만 이 구조에는 회원 정보, 도서 정보, 대여 사건이라는 서로 다른 사실이 섞여 있습니다. 같은 회원과 도서 정보가 여러 행에 반복되면 저장 공간보다 더 중요한 **불일치 위험**이 생깁니다.

![중복 저장이 만드는 정규화 문제](../../images/chapter06/ch06_01_normalization_problem_overview.svg)

그림 6-1 중복 저장이 만드는 정규화 문제

정규화는 한 사실을 가능한 한 한 곳에서 관리하도록 테이블 경계를 다시 정하는 과정입니다.

---

## 2. 데이터 중복이 만드는 문제

| 반복되는 정보 | 반복 위치 | 위험 |
| --- | --- | --- |
| 김민지, minji@example.com | 여러 대여 행 | 일부 행만 수정되면 회원 정보 불일치 |
| 데이터베이스 입문, 문길래 | 여러 대여 행 | 책 정보 변경 시 여러 행 수정 필요 |

중복 자체보다 더 큰 문제는 같은 사실의 복사본이 서로 다른 값으로 바뀌는 것입니다. 좋은 설계는 값이 왜 반복되는지, 그 값의 주인이 누구인지 먼저 확인합니다.

---

## 3. 이상 현상 이해하기

| 이상 현상 | 의미 |
| --- | --- |
| 삽입 이상 | 독립적으로 등록할 정보를 자연스럽게 추가하기 어려움 |
| 수정 이상 | 같은 사실을 여러 곳에서 수정해야 해 불일치가 생김 |
| 삭제 이상 | 한 행을 삭제할 때 보존해야 할 다른 정보까지 사라짐 |

![삽입·수정·삭제 이상 현상](../../images/chapter06/ch06_02_anomaly_types.svg)

그림 6-2 삽입·수정·삭제 이상 현상

이상 현상은 SQL 문법 오류가 아니라 테이블 설계 문제입니다.

---

## 4. 삽입 이상

아직 대여되지 않은 새 책을 등록하고 싶지만 `library_records` 한 행에 회원과 대여일도 함께 넣어야 한다면 책 정보를 독립적으로 등록하기 어렵습니다.

정규화된 구조에서는 다음처럼 `books`에 독립적으로 등록합니다.

```sql
INSERT INTO books (title, author, published_year, isbn)
VALUES ('정규화 입문', '문길래', 2026, 'ISBN-010');
```

---

## 5. 수정 이상

김민지의 이메일이 여러 대여 행에 반복되면 모든 행을 수정해야 합니다. 일부만 바뀌면 같은 회원에게 서로 다른 이메일이 생깁니다.

정규화된 구조에서는 회원 이메일을 `members` 한 행에서 관리합니다.

```sql
UPDATE members
SET email = 'kimminji@example.com'
WHERE id = 1;
```

---

## 6. 삭제 이상

한 책의 마지막 대여 행을 삭제하면서 제목과 저자 정보까지 함께 사라진다면 삭제 이상입니다.

정규화된 구조에서는 대여 사건은 `loans`, 책 정보는 `books`에 있으므로 대여 행만 삭제해도 책 정보가 남습니다.

```sql
DELETE FROM loans
WHERE id = 1;
```

실습 SQL에서는 위험한 DELETE를 자동 실행하지 않고 주석으로만 제공합니다.

---

## 7. 정규화의 기본 생각

정규화는 단순히 컬럼 수가 많아서 테이블을 나누는 작업이 아닙니다. 다음 질문으로 판단합니다.

```text
- 한 행은 무엇을 의미하는가?
- 각 컬럼은 어떤 사실의 주인에게 속하는가?
- 같은 사실이 여러 행에 반복되는가?
- 정보를 독립적으로 INSERT할 수 있는가?
- 한 곳만 UPDATE하면 되는가?
- DELETE할 때 다른 정보가 보존되는가?
```

---

## 8. 1정규형: 반복되는 값을 나누기

> 다음의 1NF, 2NF, 3NF 예제는 각 정규형의 핵심을 쉽게 설명하기 위한 독립적인 예제입니다. 하나의 도서 대여 테이블을 세 단계에 걸쳐 그대로 변환하는 연속 실습은 아닙니다.

1정규형은 한 셀에 업무상 독립적으로 다뤄야 할 여러 값을 넣지 않는 단계입니다.

| member_id | member_name | borrowed_books |
| ---: | --- | --- |
| 1 | 김민지 | 데이터베이스 입문, SQL 기초 |

쉼표로 묶은 여러 책 제목이나 `book1`, `book2`, `book3` 같은 반복 컬럼은 피합니다. 한 대여당 한 행으로 바꾸면 다음과 같습니다.

| member_id | member_name | book_title |
| ---: | --- | --- |
| 1 | 김민지 | 데이터베이스 입문 |
| 1 | 김민지 | SQL 기초 |

![1정규형: 한 셀에 하나의 값](../../images/chapter06/ch06_03_first_normal_form.svg)

그림 6-3 1정규형: 한 셀에 하나의 값

1NF를 만족해도 회원 이름과 책 제목의 다른 중복은 남을 수 있습니다. 1NF는 정규화의 출발점입니다.

---

## 9. 2정규형: 부분 종속 줄이기

2정규형은 먼저 1NF를 만족해야 합니다. 복합 후보키가 있을 때 일부 키에만 의존하는 일반 컬럼이 있는지 확인합니다.

| student_id | course_id | student_name | course_name | grade |
| ---: | ---: | --- | --- | --- |
| 1 | 101 | 김민지 | 데이터베이스 | A |
| 1 | 102 | 김민지 | 알고리즘 | B |
| 2 | 101 | 이준호 | 데이터베이스 | A |

복합키는 `(student_id, course_id)`입니다.

```text
student_id → student_name
course_id → course_name
student_id + course_id → grade
```

`student_name`과 `course_name`은 복합키의 일부에만 의존하므로 각각의 주인 테이블로 옮깁니다.

```text
students(id, name)
courses(id, name)
enrollments(student_id, course_id, grade)
```

![2정규형: 복합키 일부 의존 분리](../../images/chapter06/ch06_04_second_normal_form.svg)

그림 6-4 2정규형: 복합키 일부 의존 분리

단일 컬럼 후보키에는 부분 종속이 발생하지 않습니다. 2NF의 핵심은 복합키 일부가 결정하는 컬럼의 주인을 찾는 것입니다.

---

## 10. 3정규형: 다른 속성에 의존하는 컬럼 분리하기

3정규형은 먼저 2NF를 만족한다고 가정합니다. 비키 컬럼이 다른 비키 컬럼을 결정하는 업무 규칙이 있는지 확인합니다.

> 이 예제에서는 설명을 단순화하기 위해 하나의 `zip_code`가 하나의 `city`를 결정한다고 가정합니다. 실제 주소 시스템에서는 업무 범위와 데이터 기준을 별도로 확인해야 합니다.

| member_id | member_name | zip_code | city |
| ---: | --- | --- | --- |
| 1 | 김민지 | 04524 | 서울 |
| 2 | 이준호 | 04524 | 서울 |
| 3 | 박서연 | 48058 | 부산 |

이 예제의 업무 규칙은 다음과 같습니다.

```text
member_id → zip_code → city
```

`city`는 `member_id`보다 `zip_code`에 직접 의존하므로 다음처럼 분리할 수 있습니다.

```text
members(id, name, zip_code)
zip_codes(zip_code, city)
```

![3정규형: 비키 컬럼 간 의존 분리](../../images/chapter06/ch06_05_third_normal_form.svg)

그림 6-5 3정규형: 비키 컬럼 간 의존 분리

값이 우연히 반복된다는 이유만으로 분리하지 않습니다. 특정 컬럼이 다른 컬럼을 일관되게 결정한다는 업무 규칙을 먼저 확인해야 합니다.

---

## 11. 도서 대여 시스템 정규화하기

정규화 전 테이블은 다음과 같습니다.

```text
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
```

각 컬럼이 표현하는 사실과 최종 주인을 정리하면 다음과 같습니다.

| 정규화 전 컬럼 | 표현하는 사실 | 최종 테이블 |
| --- | --- | --- |
| member_name, member_email | 회원 정보 | members |
| book_title, author | 도서 정보 | books |
| loan_id, borrowed_at, due_at, returned_at | 대여 기록 | loans |
| 새로 추가하는 식별자 | 각 테이블의 행 식별 | 각 테이블의 id |
| 새로 추가하는 관계 키 | 회원·도서와 대여 연결 | loans.member_id, loans.book_id |

`joined_at`, `published_year`, `isbn`은 정규화 전 예시 테이블에 없던 값입니다. 이 값들은 Chapter 05의 전체 요구사항에서 가져온 속성이며, 단순히 `library_records`를 분리해서 얻은 값은 아닙니다. 정규화는 존재하지 않던 업무 데이터를 자동 생성하는 작업이 아닙니다.

![도서 대여 테이블 정규화 흐름](../../images/chapter06/ch06_06_library_normalization_flow.svg)

그림 6-6 도서 대여 테이블 정규화 흐름

정규화 후 구조는 다음과 같습니다.

```text
members(id, name, email, joined_at)
books(id, title, author, published_year, isbn)
loans(id, member_id, book_id, borrowed_at, due_at, returned_at)
```

이 그림은 구조 개선 개념을 설명합니다. 기존 운영 데이터의 정제, 중복 병합, 스테이징, 실제 이관 절차는 이 장의 범위가 아닙니다.

---

## 12. PostgreSQL로 정규화된 구조 만들기

> **실습 DB 확인**
>
> `normalization_practice.sql`은 `loans`, `books`, `members`, `library_records` 테이블을 삭제한 후 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 실행 전에 `SELECT current_database();`로 현재 연결 대상을 확인합니다. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

```sql
SELECT current_database();

DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS library_records;
```

정규화 후 테이블 생성 순서는 부모 테이블인 `members`, `books`를 먼저 만들고 자식 테이블인 `loans`를 만드는 순서입니다.

```sql
CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INT,
    isbn VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE loans (
    id SERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(id),
    book_id INT NOT NULL REFERENCES books(id),
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE
);
```

`returned_at`은 아직 반납되지 않은 상태를 표현하기 위해 NULL을 허용합니다.

---

## 13. 정규화 전후 비교

| 설계 | 장점 | 단점 |
| --- | --- | --- |
| 한 테이블 설계 | 조회가 단순해 보임 | 중복과 이상 현상 위험 |
| 정규화 설계 | 중복 감소, 변경 안정성 향상 | 조회 시 JOIN 필요 |

정규화된 저장 구조에서도 JOIN으로 원래 업무 화면을 만들 수 있습니다.

```sql
SELECT
    loans.id AS loan_id,
    members.name AS member_name,
    members.email AS member_email,
    books.title AS book_title,
    books.author,
    loans.borrowed_at,
    loans.due_at,
    loans.returned_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
ORDER BY loans.id;
```

![정규화된 저장과 JOIN 조회](../../images/chapter06/ch06_07_before_after_join_tradeoff.svg)

그림 6-7 정규화된 저장과 JOIN 조회

JOIN은 분리된 데이터를 다시 영구 저장하는 작업이 아닙니다. 조회 시점에 PK·FK 관계를 따라 필요한 결과 집합을 만듭니다.

---

## 14. 과도한 정규화도 조심하기

정규화는 테이블을 무조건 많이 나누는 작업이 아닙니다.

```text
member_names(id, name)
member_emails(id, email)
member_join_dates(id, joined_at)
```

같은 수명과 변경 이유를 가진 회원의 기본 속성은 `members` 한 테이블에 함께 둘 수 있습니다. 분리 근거가 없다면 테이블을 늘리지 않습니다.

먼저 데이터의 의미와 무결성에 맞게 설계한 뒤, 실제 조회 패턴과 측정 결과를 근거로 구조를 검토합니다. 단순히 JOIN이 있다는 이유만으로 정규화된 구조를 다시 합치지는 않습니다. Chapter 06에서는 반정규화 구현을 다루지 않습니다.

---

## 15. AI가 만든 테이블 구조 검토하기

AI가 제안한 구조는 최종 설계가 아니라 검증되지 않은 초안입니다.

```text
library_records(
    id,
    member_name,
    member_email,
    book_title,
    book_author,
    borrowed_at,
    due_at
)
```

![AI 생성 테이블 구조 정규화 검토](../../images/chapter06/ch06_08_ai_normalization_review_flow.svg)

그림 6-8 AI 생성 테이블 구조 정규화 검토

| 검토 항목 | 확인 질문 |
| --- | --- |
| 행의 의미 | 한 행은 회원, 책, 대여 중 무엇을 표현하는가? |
| 컬럼 소유자 | 각 컬럼은 어느 사실의 주인에게 속하는가? |
| 중복과 이상 | 독립 INSERT, 한 곳 UPDATE, 안전한 DELETE가 가능한가? |
| 1NF | 한 셀에 여러 독립 값이나 반복 컬럼이 있는가? |
| 2NF | 복합키 일부에만 의존하는 컬럼이 있는가? |
| 3NF | 비키 컬럼이 다른 비키 컬럼을 결정하는가? |
| 과도한 분리 | 같은 수명과 변경 이유의 속성을 근거 없이 나누었는가? |
| 실행 검증 | PostgreSQL과 샘플 데이터, JOIN으로 요구사항을 확인했는가? |

검증에 실패하면 AI 요청이나 설계를 수정하고 다시 확인합니다. 최종 판단과 채택 근거 기록은 사람이 수행합니다.

---

## 16. 직접 해보기: 나쁜 테이블 개선하기

다음 테이블을 정규화해 보세요.

```text
orders_raw(
    order_id,
    customer_name,
    customer_email,
    product_name,
    product_price,
    order_date,
    quantity
)
```

가능한 개선 구조는 다음과 같습니다.

```text
customers(id, name, email)
products(id, name, price)
orders(id, customer_id, order_date)
order_items(id, order_id, product_id, quantity, unit_price)
```

`order_items`는 주문과 상품의 N:M 관계를 풀어 주는 연결 테이블입니다.

---

## 17. 자주 하는 실수

### 실수 1. 컬럼 수가 많으면 무조건 나눈다

컬럼의 개수가 아니라 한 행의 의미와 컬럼의 주인을 확인합니다.

### 실수 2. 1NF만 만족하면 좋은 설계라고 생각한다

다중값 셀을 제거해도 다른 중복과 이상 현상은 남을 수 있습니다.

### 실수 3. 값이 반복되면 함수 종속이라고 단정한다

반복은 단서일 뿐입니다. 업무 규칙상 어떤 컬럼이 다른 컬럼을 일관되게 결정하는지 확인합니다.

### 실수 4. AI가 만든 구조를 그대로 사용한다

AI 제안은 실제 SQL과 샘플 데이터로 검증해야 합니다.

### 실수 5. 정규화와 데이터 마이그레이션을 같은 작업으로 본다

정규화는 목표 구조를 설계하는 일이고, 기존 운영 데이터를 정제하고 옮기는 작업은 별도의 계획이 필요합니다.

---

## 18. 스스로 확인하기

1. 중복의 핵심 문제가 저장 공간보다 불일치인 이유는 무엇인가요?
2. 삽입·수정·삭제 이상은 어떻게 다른가요?
3. 1NF 예제에서 다중값 셀을 행으로 바꾸는 이유는 무엇인가요?
4. 2NF 예제에서 `grade`만 `enrollments`에 남는 이유는 무엇인가요?
5. 3NF 예제에서 `zip_code → city`가 업무 가정인 이유는 무엇인가요?
6. 정규화 후 JOIN으로 원래 업무 조회 결과를 만들 수 있는 이유는 무엇인가요?
7. AI가 제안한 테이블 구조를 어떤 순서로 검토해야 하나요?

---

## 19. 정리

### 정규화 검토 원칙

| 검토 항목 | 확인 질문 |
| --- | --- |
| 반복 값 | 한 셀에 여러 독립 값이 들어가는가? |
| 중복 | 같은 사실이 여러 행에 반복되는가? |
| 삽입 이상 | 독립 정보를 따로 등록할 수 있는가? |
| 수정 이상 | 같은 사실을 여러 행에서 수정해야 하는가? |
| 삭제 이상 | 삭제 시 보존해야 할 정보가 함께 사라지는가? |
| 관계 | N:M 관계를 연결 테이블로 풀었는가? |
| 검증 | 샘플 데이터와 JOIN으로 확인했는가? |
| AI 구조 | AI 결과를 그대로 쓰지 않고 검토했는가? |

### 정규화 단계별 판단표

| 단계 | 핵심 질문 | 문제가 보이면 할 일 |
| --- | --- | --- |
| 1NF | 한 셀에 여러 독립 값이나 반복 그룹이 있는가? | 값을 여러 행 또는 적절한 테이블로 분리한다. |
| 2NF | 복합 후보키 일부에만 의존하는 컬럼이 있는가? | 해당 일부 키가 주인인 테이블로 옮긴다. |
| 3NF | 비키 컬럼이 다른 비키 컬럼을 결정하는가? | 업무 규칙을 확인하고 결정 관계를 별도 테이블로 분리한다. |
| 실무 검토 | 분리 근거 없이 테이블을 늘렸는가? | 데이터 의미, 조회 패턴, 측정 결과를 함께 확인한다. |
| AI 검토 | 요구사항·ERD·SQL·실행 결과가 일치하는가? | 사람이 다시 검토하고 실패 원인을 수정한다. |

이 장에서 가장 중요한 문장은 다음입니다.

```text
좋은 테이블 설계는 한 사실을 가능한 한 한 곳에서 관리하고, 데이터가 변할 때 의미와 일관성을 지키도록 만드는 것이다.
```

---

## 20. 다음 장에서는

Chapter 07에서는 지금까지 다룬 요구사항 분석, ERD, SQL, 정규화 기준을 활용해 첫 번째 실전 프로젝트를 진행합니다.
