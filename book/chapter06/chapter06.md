# Chapter 06. 정규화와 좋은 테이블 설계

> 상태: 원고 1차 확장 완료 / 도식 삽입 완료

---

## 이 장에서 배울 내용

이 장에서는 데이터 중복을 줄이고 안정적인 테이블 구조를 만드는 **정규화**를 학습합니다.

Chapter 05에서는 요구사항에서 엔터티, 속성, 관계를 찾고 ERD를 설계했습니다. Chapter 06에서는 그 설계가 좋은 구조인지 점검하는 기준을 배웁니다. 특히 한 테이블에 너무 많은 정보를 넣었을 때 생기는 문제와, 이를 여러 테이블로 나누는 방법을 다룹니다.

이 장에서 다룰 내용은 다음과 같습니다.

- 데이터 중복 문제
- 삽입 이상, 수정 이상, 삭제 이상
- 정규화가 필요한 이유
- 1정규형, 2정규형, 3정규형
- 나쁜 설계와 좋은 설계 비교
- 도서 대여 시스템 테이블 개선
- 정규화된 테이블을 PostgreSQL로 구현하기
- 과도한 정규화의 문제
- AI가 만든 테이블 구조 검토하기

이 장의 목표는 정규형 이름을 외우는 것이 아닙니다. 테이블을 보고 “이 구조가 나중에 문제를 만들 수 있는가?”를 판단하는 능력을 기르는 것입니다.

---

## 1. 왜 정규화를 배워야 하는가

처음 데이터베이스를 설계할 때는 하나의 큰 테이블에 모든 정보를 넣는 방식이 쉬워 보입니다.

예를 들어 도서 대여 정보를 다음처럼 저장한다고 가정해 보겠습니다.

| loan_id | member_name | member_email | book_title | author | borrowed_at | due_at |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | 김민지 | minji@example.com | 데이터베이스 입문 | 문길래 | 2026-04-01 | 2026-04-15 |
| 2 | 김민지 | minji@example.com | SQL 기초 | 홍길동 | 2026-04-02 | 2026-04-16 |
| 3 | 이준호 | junho@example.com | 데이터베이스 입문 | 문길래 | 2026-04-03 | 2026-04-17 |

이 테이블은 한눈에 보기에는 편합니다. 회원 이름, 이메일, 책 제목, 저자, 대여일이 모두 한 줄에 있기 때문입니다.

하지만 데이터가 늘어나면 문제가 생깁니다.

```text
- 김민지의 이메일이 여러 행에 반복된다.
- 데이터베이스 입문이라는 책 제목과 저자가 여러 행에 반복된다.
- 이메일이 바뀌면 여러 행을 모두 수정해야 한다.
- 책 정보만 등록하고 싶은데 대여 기록이 없으면 넣기 어렵다.
- 마지막 대여 기록을 삭제하면 책 정보까지 사라질 수 있다.
```

![정규화가 필요한 이유](../../images/chapter06/ch06_01_normalization_problem_overview.svg)

그림 6-1 정규화가 필요한 이유

정규화는 이런 문제를 줄이기 위한 테이블 설계 방법입니다.

```text
정규화는 데이터 중복을 줄이고, 삽입·수정·삭제 시 발생할 수 있는 이상 현상을 줄이기 위해 테이블을 적절히 나누는 과정이다.
```

---

## 2. 데이터 중복이 만드는 문제

데이터 중복은 같은 정보가 여러 곳에 반복해서 저장되는 것을 의미합니다.

예를 들어 다음 정보가 여러 행에 반복되고 있습니다.

| 반복되는 정보 | 반복 위치 | 문제 |
| --- | --- | --- |
| 김민지 | 여러 대여 행 | 이름이 바뀌면 여러 행 수정 필요 |
| minji@example.com | 여러 대여 행 | 이메일 변경 시 누락 가능 |
| 데이터베이스 입문 | 여러 대여 행 | 책 제목 변경 시 여러 행 수정 필요 |
| 문길래 | 여러 대여 행 | 저자명 수정 시 불일치 가능 |

중복은 단순히 저장 공간을 많이 쓰는 문제가 아닙니다. 더 큰 문제는 **불일치**입니다.

예를 들어 김민지의 이메일이 일부 행에서는 `minji@example.com`, 다른 행에서는 `kimminji@example.com`으로 저장되면 어느 값이 최신인지 알기 어렵습니다.

따라서 좋은 설계는 같은 정보를 가능한 한 한 곳에서 관리하도록 만듭니다.

---

## 3. 이상 현상 이해하기

잘못 설계된 테이블에서는 데이터를 추가, 수정, 삭제할 때 예기치 않은 문제가 생깁니다. 이를 이상 현상이라고 합니다.

대표적인 이상 현상은 세 가지입니다.

| 이상 현상 | 의미 |
| --- | --- |
| 삽입 이상 | 필요한 데이터를 자연스럽게 추가하기 어려움 |
| 수정 이상 | 같은 정보를 여러 곳에서 수정해야 해서 불일치가 생김 |
| 삭제 이상 | 삭제하면 보존해야 할 정보까지 함께 사라짐 |

![삽입·수정·삭제 이상](../../images/chapter06/ch06_02_anomaly_types.svg)

그림 6-2 삽입·수정·삭제 이상

---

## 4. 삽입 이상

삽입 이상은 데이터를 추가하려고 할 때 불필요한 정보까지 함께 입력해야 하는 문제입니다.

예를 들어 다음과 같은 하나의 큰 테이블이 있다고 가정합니다.

```text
library_records(
    loan_id,
    member_name,
    member_email,
    book_title,
    author,
    borrowed_at,
    due_at
)
```

새 책을 도서관에 등록하고 싶은데 아직 아무도 대여하지 않았습니다. 이 경우 `borrowed_at`, `due_at`, `member_name` 같은 값이 없습니다.

하지만 한 테이블에 책 정보와 대여 정보가 섞여 있으면 책 정보만 따로 등록하기 어렵습니다.

이것이 삽입 이상입니다.

좋은 설계에서는 책 정보는 `books` 테이블에 따로 넣을 수 있어야 합니다.

```sql
INSERT INTO books (title, author, published_year, isbn)
VALUES ('정규화 입문', '문길래', 2026, 'ISBN-010');
```

대여 기록이 없어도 책 정보는 등록할 수 있어야 합니다.

---

## 5. 수정 이상

수정 이상은 같은 정보가 여러 행에 반복되어 있어 하나만 수정하면 데이터가 서로 달라지는 문제입니다.

예를 들어 김민지의 이메일이 여러 행에 반복되어 있다고 가정합니다.

| loan_id | member_name | member_email | book_title |
| ---: | --- | --- | --- |
| 1 | 김민지 | minji@example.com | 데이터베이스 입문 |
| 2 | 김민지 | minji@example.com | SQL 기초 |

김민지의 이메일이 바뀌면 두 행을 모두 수정해야 합니다.

```sql
UPDATE library_records
SET member_email = 'kimminji@example.com'
WHERE member_name = '김민지';
```

문제는 일부 행만 수정되는 경우입니다.

| loan_id | member_name | member_email | book_title |
| ---: | --- | --- | --- |
| 1 | 김민지 | kimminji@example.com | 데이터베이스 입문 |
| 2 | 김민지 | minji@example.com | SQL 기초 |

이제 같은 사람의 이메일이 두 개가 되었습니다.

정규화된 설계에서는 회원 이메일은 `members` 테이블에 한 번만 저장합니다.

```sql
UPDATE members
SET email = 'kimminji@example.com'
WHERE id = 1;
```

이렇게 하면 회원 정보의 일관성을 유지하기 쉽습니다.

---

## 6. 삭제 이상

삭제 이상은 어떤 행을 삭제했을 때 보존해야 할 정보까지 함께 사라지는 문제입니다.

예를 들어 한 권의 책이 단 한 번만 대여되었고, 그 대여 기록이 하나의 큰 테이블에 저장되어 있다고 가정합니다.

| loan_id | member_name | book_title | author |
| ---: | --- | --- | --- |
| 1 | 김민지 | 정규화 입문 | 문길래 |

이 대여 기록을 삭제하면 어떻게 될까요?

```sql
DELETE FROM library_records
WHERE loan_id = 1;
```

대여 기록만 삭제하고 싶었지만, 이 책의 제목과 저자 정보까지 함께 사라질 수 있습니다.

정규화된 설계에서는 대여 기록은 `loans`에 있고 책 정보는 `books`에 있습니다. 따라서 대여 기록을 삭제해도 책 정보는 남습니다.

```sql
DELETE FROM loans
WHERE id = 1;
```

`books` 테이블의 책 정보는 그대로 유지됩니다.

---

## 7. 정규화의 기본 생각

정규화는 어려운 공식이 아니라 다음 질문에서 출발합니다.

```text
- 이 테이블에 서로 다른 주제가 섞여 있는가?
- 같은 정보가 여러 번 반복되는가?
- 어떤 값을 수정할 때 여러 행을 고쳐야 하는가?
- 어떤 정보를 독립적으로 등록할 수 없는가?
- 어떤 행을 삭제하면 보존해야 할 정보까지 사라지는가?
```

이 질문에 하나라도 “예”라고 답한다면 테이블 분리를 검토해야 합니다.

도서 대여 예제에서는 다음처럼 나누는 것이 좋습니다.

```text
members: 회원 정보
books: 책 정보
loans: 대여 기록
```

이 구조는 Chapter 05에서 만든 ERD와 연결됩니다.

---

## 8. 1정규형: 반복되는 값을 나누기

1정규형은 한 칸에 여러 값을 넣지 않고, 각 컬럼이 하나의 값만 가지도록 만드는 단계입니다.

나쁜 예를 보겠습니다.

| member_id | member_name | borrowed_books |
| ---: | --- | --- |
| 1 | 김민지 | 데이터베이스 입문, SQL 기초 |
| 2 | 이준호 | 데이터베이스 입문 |

`borrowed_books` 컬럼에 여러 책 제목이 쉼표로 들어 있습니다.

이 구조는 문제가 많습니다.

```text
- 특정 책을 빌린 회원을 검색하기 어렵다.
- 책 제목 일부가 바뀌면 문자열을 직접 수정해야 한다.
- 책마다 대여일이나 반납예정일을 따로 저장하기 어렵다.
```

1정규형으로 바꾸면 한 칸에 하나의 값만 들어가게 합니다.

| member_id | member_name | book_title |
| ---: | --- | --- |
| 1 | 김민지 | 데이터베이스 입문 |
| 1 | 김민지 | SQL 기초 |
| 2 | 이준호 | 데이터베이스 입문 |

![1정규형: 반복값 분리](../../images/chapter06/ch06_03_first_normal_form.svg)

그림 6-3 1정규형: 반복값 분리

하지만 아직 회원 이름과 책 제목이 반복됩니다. 1정규형은 시작일 뿐입니다.

---

## 9. 2정규형: 부분 종속 줄이기

2정규형은 기본키의 일부에만 의존하는 컬럼을 분리하는 단계입니다.

초급 단계에서는 다음처럼 이해하면 됩니다.

```text
복합키를 사용하는 테이블에서, 어떤 컬럼이 전체 키가 아니라 일부 키에만 의존하면 분리해야 한다.
```

예를 들어 학생과 과목의 수강 정보를 생각해 보겠습니다.

| student_id | course_id | student_name | course_name | grade |
| ---: | ---: | --- | --- | --- |
| 1 | 101 | 김민지 | 데이터베이스 | A |
| 1 | 102 | 김민지 | 알고리즘 | B |
| 2 | 101 | 이준호 | 데이터베이스 | A |

이 테이블의 핵심은 `(student_id, course_id)` 조합입니다. 그런데 `student_name`은 `student_id`에만 의존하고, `course_name`은 `course_id`에만 의존합니다.

따라서 다음처럼 나누는 것이 좋습니다.

```text
students(id, name)
courses(id, name)
enrollments(student_id, course_id, grade)
```

![2정규형: 일부 키 의존 분리](../../images/chapter06/ch06_04_second_normal_form.svg)

그림 6-4 2정규형: 일부 키 의존 분리

2정규형의 핵심은 “수강 정보 테이블에는 수강과 직접 관련된 정보만 남긴다”입니다.

---

## 10. 3정규형: 다른 속성에 의존하는 컬럼 분리하기

3정규형은 기본키가 아닌 다른 컬럼에 의존하는 컬럼을 분리하는 단계입니다.

예를 들어 다음 회원 테이블을 보겠습니다.

| member_id | member_name | zip_code | city |
| ---: | --- | --- | --- |
| 1 | 김민지 | 04524 | 서울 |
| 2 | 이준호 | 04524 | 서울 |
| 3 | 박서연 | 48058 | 부산 |

여기서 `city`는 `member_id`에 직접 의존한다기보다 `zip_code`에 의존합니다.

```text
zip_code가 04524이면 city는 서울이다.
zip_code가 48058이면 city는 부산이다.
```

이 경우 우편번호와 도시 정보를 별도 테이블로 분리할 수 있습니다.

```text
members(id, name, zip_code)
zip_codes(zip_code, city)
```

![3정규형: 일반 컬럼 의존 분리](../../images/chapter06/ch06_05_third_normal_form.svg)

그림 6-5 3정규형: 일반 컬럼 의존 분리

초급 과정에서는 3정규형을 다음 문장으로 기억하면 됩니다.

```text
기본키가 아닌 컬럼이 다른 일반 컬럼을 설명하고 있다면 분리를 검토한다.
```

---

## 11. 도서 대여 시스템 정규화하기

처음의 나쁜 테이블은 다음과 같았습니다.

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

이 구조는 회원, 책, 대여 기록이 섞여 있습니다.

정규화하면 다음처럼 나눌 수 있습니다.

```text
members(id, name, email, joined_at)
books(id, title, author, published_year, isbn)
loans(id, member_id, book_id, borrowed_at, due_at, returned_at)
```

![도서 대여 테이블 정규화](../../images/chapter06/ch06_06_library_normalization_flow.svg)

그림 6-6 도서 대여 테이블 정규화

각 테이블의 역할은 명확합니다.

| 테이블 | 역할 |
| --- | --- |
| members | 회원 정보 관리 |
| books | 도서 정보 관리 |
| loans | 회원이 책을 대여한 기록 관리 |

이제 회원 이메일은 `members`에 한 번만 저장됩니다. 책 제목과 저자는 `books`에 한 번만 저장됩니다. 대여 기록은 `loans`에서 관리합니다.

---

## 12. PostgreSQL로 정규화된 구조 만들기

정규화된 도서 대여 구조를 PostgreSQL로 만들면 다음과 같습니다.

```sql
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;

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

Chapter 05의 `library_schema.sql`과 같은 구조입니다. Chapter 06에서는 이 구조가 왜 좋은지 정규화 관점에서 설명합니다.

---

## 13. 정규화 전후 비교

정규화 전에는 한 테이블에 모든 정보가 들어 있습니다.

| 설계 | 장점 | 단점 |
| --- | --- | --- |
| 한 테이블 설계 | 처음 보기 쉽다 | 중복, 수정 오류, 삽입/삭제 이상 발생 |
| 정규화 설계 | 중복이 줄고 안정적이다 | JOIN이 필요해진다 |

정규화된 구조에서는 조회할 때 JOIN이 필요할 수 있습니다.

```sql
SELECT
    loans.id,
    members.name AS member_name,
    books.title AS book_title,
    loans.borrowed_at,
    loans.due_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id;
```

![정규화 전후 비교와 JOIN](../../images/chapter06/ch06_07_before_after_join_tradeoff.svg)

그림 6-7 정규화 전후 비교와 JOIN

JOIN이 필요하다는 점은 단점처럼 보일 수 있습니다. 하지만 데이터의 일관성과 안정성을 얻기 위한 자연스러운 비용입니다.

---

## 14. 과도한 정규화도 조심하기

정규화는 좋은 설계를 만드는 중요한 방법이지만, 무조건 많이 나누는 것이 항상 좋은 것은 아닙니다.

예를 들어 다음처럼 너무 잘게 나누면 오히려 사용하기 어려울 수 있습니다.

```text
member_names(id, name)
member_emails(id, email)
member_join_dates(id, joined_at)
```

회원의 기본 정보는 보통 `members` 테이블 하나에 함께 두는 것이 자연스럽습니다.

좋은 설계는 다음 균형을 잡아야 합니다.

```text
- 중복은 줄인다.
- 의미가 같은 정보는 함께 둔다.
- 의미가 다른 정보는 분리한다.
- 너무 많은 JOIN이 필요한 구조는 피한다.
- 실제 조회와 수정 요구사항을 함께 고려한다.
```

---

## 15. AI가 만든 테이블 구조 검토하기

AI에게 요구사항을 주면 테이블 구조를 빠르게 제안받을 수 있습니다.

예를 들어 다음처럼 요청할 수 있습니다.

```text
도서관 대여 시스템을 위한 PostgreSQL 테이블 구조를 제안해 주세요.
회원, 책, 대여 기록을 관리해야 합니다.
정규화 관점에서 중복을 줄인 구조로 설명해 주세요.
```

AI가 다음과 같은 구조를 제안했다고 가정해 보겠습니다.

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

이 구조는 초안으로는 이해하기 쉽지만 정규화 관점에서는 문제가 있습니다.

![AI 생성 테이블 구조 검토](../../images/chapter06/ch06_08_ai_normalization_review_flow.svg)

그림 6-8 AI 생성 테이블 구조 검토

검토 질문은 다음과 같습니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 중복 | 회원 정보와 책 정보가 반복되는가? |
| 삽입 이상 | 대여 없이 책만 등록할 수 있는가? |
| 수정 이상 | 이메일이나 책 제목 변경 시 여러 행을 수정해야 하는가? |
| 삭제 이상 | 대여 기록 삭제 시 책 정보도 사라지는가? |
| 테이블 분리 | members, books, loans로 나눌 수 있는가? |
| 외래키 | 관계를 외래키로 표현했는가? |

AI가 만든 테이블은 반드시 사람이 정규화 기준으로 검토해야 합니다.

---

## 16. 작은 실습: 나쁜 테이블 개선하기

다음 나쁜 테이블을 정규화해 보세요.

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

질문은 다음과 같습니다.

```text
1. 어떤 정보가 반복될 수 있는가?
2. 삽입 이상이 발생할 수 있는가?
3. 수정 이상이 발생할 수 있는가?
4. 삭제 이상이 발생할 수 있는가?
5. 어떤 테이블로 분리할 수 있는가?
```

가능한 개선 구조는 다음과 같습니다.

```text
customers(id, name, email)
products(id, name, price)
orders(id, customer_id, order_date)
order_items(id, order_id, product_id, quantity, unit_price)
```

여기서 `order_items`는 주문과 상품의 N:M 관계를 풀어 주는 중간 테이블입니다.

---

## 17. 자주 하는 실수

### 실수 1. 정규화를 테이블을 무조건 많이 나누는 것으로 이해한다

정규화는 무조건 분리하는 것이 아니라 중복과 이상 현상을 줄이기 위한 설계 방법입니다.

### 실수 2. 1정규형만 만족하면 좋은 설계라고 생각한다

한 칸에 하나의 값만 있어도 중복과 수정 이상은 여전히 남을 수 있습니다.

### 실수 3. N:M 관계를 중간 테이블 없이 표현한다

한 회원이 여러 책을 대여하거나, 한 주문에 여러 상품이 포함되는 구조는 중간 테이블이 필요합니다.

### 실수 4. AI가 만든 구조를 그대로 사용한다

AI는 그럴듯한 테이블을 만들 수 있지만, 정규화 기준을 항상 정확히 지키지는 않습니다.

### 실수 5. 정규화 후 조회 흐름을 확인하지 않는다

테이블을 나눈 뒤에는 샘플 데이터와 JOIN으로 실제 요구사항을 조회할 수 있는지 확인해야 합니다.

---

## 18. 연습 문제

### 18.1 개념 확인

1. [기초] 정규화가 필요한 이유를 설명하세요.
2. [기초] 데이터 중복이 왜 문제가 되는지 설명하세요.
3. [기초] 삽입 이상, 수정 이상, 삭제 이상을 각각 설명하세요.
4. [기초] 1정규형의 핵심을 설명하세요.
5. [기초] N:M 관계에서 중간 테이블이 필요한 이유를 설명하세요.

### 18.2 정규화 실습 문제

다음 테이블을 정규화해 보세요.

```text
course_records(
    student_id,
    student_name,
    course_id,
    course_name,
    professor_name,
    grade
)
```

질문:

```text
1. 어떤 정보가 반복되는가?
2. 어떤 수정 이상이 발생할 수 있는가?
3. 어떤 테이블들로 나누면 좋은가?
4. 각 테이블의 기본키와 외래키는 무엇인가?
```

### 18.3 AI 검토 문제

AI가 다음 테이블을 제안했습니다.

```text
orders(id, customer_name, customer_email, product_name, product_price, quantity, order_date)
```

이 설계의 문제점을 정규화 관점에서 설명하세요.

---

## 19. 정리

이번 장에서는 정규화와 좋은 테이블 설계의 기초를 학습했습니다.

핵심 내용을 정리하면 다음과 같습니다.

```text
1. 정규화는 데이터 중복과 이상 현상을 줄이기 위한 설계 방법이다.
2. 데이터 중복은 저장 공간보다 데이터 불일치 문제를 만든다는 점이 더 중요하다.
3. 삽입 이상은 필요한 데이터를 자연스럽게 추가하기 어려운 문제이다.
4. 수정 이상은 같은 정보를 여러 곳에서 수정해야 하는 문제이다.
5. 삭제 이상은 삭제하면 보존해야 할 정보까지 사라지는 문제이다.
6. 1정규형은 한 칸에 여러 값을 넣지 않는 것이다.
7. 2정규형은 일부 키에만 의존하는 컬럼을 분리하는 것이다.
8. 3정규형은 기본키가 아닌 컬럼에 의존하는 컬럼을 분리하는 것이다.
9. 정규화된 구조는 JOIN이 필요하지만 데이터 일관성을 높인다.
10. AI가 만든 테이블 구조도 정규화 기준으로 사람이 검토해야 한다.
```

### 정규화 검토 원칙

| 검토 항목 | 확인 질문 |
| --- | --- |
| 반복 값 | 한 칸에 여러 값이 들어가는가? |
| 중복 | 같은 정보가 여러 행에 반복되는가? |
| 삽입 이상 | 독립적인 정보를 따로 등록할 수 있는가? |
| 수정 이상 | 같은 정보를 여러 행에서 수정해야 하는가? |
| 삭제 이상 | 삭제 시 보존해야 할 정보가 함께 사라지는가? |
| 관계 | N:M 관계를 중간 테이블로 풀었는가? |
| 검증 | 샘플 데이터와 JOIN으로 확인했는가? |
| AI 구조 | AI가 만든 설계를 그대로 쓰지 않고 검토했는가? |

이 장에서 가장 중요한 문장은 다음입니다.

```text
좋은 테이블 설계는 중복을 줄이고, 데이터가 변할 때 오류가 생기지 않도록 만드는 것이다.
```

---

## 20. 다음 장에서는

다음 장에서는 중간 프로젝트 또는 중간 평가를 진행합니다.

Chapter 07에서는 지금까지 배운 내용을 바탕으로 다음 역량을 확인합니다.

```text
- 요구사항 분석
- 테이블 후보 도출
- ERD 초안 작성
- CREATE TABLE SQL 작성
- 기본 SELECT/INSERT/UPDATE/DELETE 작성
- 정규화 관점의 설계 검토
- AI 생성 결과 검토
```

Chapter 06에서 배운 정규화는 중간 프로젝트의 설계 품질을 평가하는 중요한 기준이 됩니다.
