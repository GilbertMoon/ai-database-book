# Chapter 06 실습 자료

## 정규화와 좋은 테이블 설계

> 용도: 자기주도 실습 / Chapter 06 보조 자료

---

## 1. 실습 개요

이 실습은 데이터 중복과 이상 현상을 찾고, 테이블의 행 의미와 컬럼 소유자를 기준으로 구조를 개선하는 과정입니다.

> 1NF, 2NF, 3NF 예제는 각 정규형의 핵심을 설명하기 위한 독립적인 예제입니다. 하나의 도서 대여 테이블을 연속해서 세 단계로 변환하는 실습은 아닙니다.

---

## 2. 이 자료에서 확인할 내용

```text
1. 중복과 삽입·수정·삭제 이상을 구분한다.
2. 1NF의 다중값 셀 문제를 설명한다.
3. 2NF의 복합키 일부 의존을 설명한다.
4. 3NF의 비키 컬럼 간 의존을 설명한다.
5. library_records를 members, books, loans로 분리한다.
6. PostgreSQL과 JOIN으로 결과를 검증한다.
7. AI 생성 구조를 정규화 기준으로 검토한다.
```

---

## 3. 실습 준비

필요한 파일:

```text
code/chapter06/normalization_practice.sql
```

> **실습 DB 확인**
>
> 이 SQL 파일은 `loans`, `books`, `members`, `library_records`를 삭제한 후 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 먼저 `SELECT current_database();`로 연결 대상을 확인합니다. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

---

## 4. 실습 1: 정규화 전 테이블 문제 찾기

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

| 문제 항목 | 발견한 내용 | 왜 문제인가? |
| --- | --- | --- |
| 회원 정보 중복 |  |  |
| 책 정보 중복 |  |  |
| 서로 다른 사실 혼합 |  |  |
| 수정 이상 가능성 |  |  |
| 삭제 이상 가능성 |  |  |

---

## 5. 실습 2: 이상 현상 분석

| 상황 | 이상 현상 종류 | 설명 |
| --- | --- | --- |
| 대여되지 않은 새 책을 등록하기 어렵다 |  |  |
| 김민지 이메일 일부 행만 수정되어 불일치한다 |  |  |
| 마지막 대여 행 삭제 시 책 정보도 사라진다 |  |  |

---

## 6. 실습 3: 1정규형 확인

1NF에서는 한 셀에 업무상 독립적으로 다룰 여러 값을 넣지 않습니다.

| member_id | member_name | borrowed_books |
| ---: | --- | --- |
| 1 | 김민지 | 데이터베이스 입문, SQL 기초 |
| 2 | 이준호 | 데이터베이스 입문 |

### 1NF 구조로 바꾸기

| member_id | member_name | book_title |
| ---: | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |

생각해 보기:

```text
쉼표 목록과 book1, book2 같은 반복 컬럼은 왜 피해야 하나요?
1NF 적용 후에도 어떤 중복이 남을 수 있나요?
```

---

## 7. 실습 4: 2정규형 이해

2NF는 먼저 1NF를 만족한다고 가정합니다. 이 예제의 복합키는 `(student_id, course_id)`입니다.

| student_id | course_id | student_name | course_name | grade |
| ---: | ---: | --- | --- | --- |
| 1 | 101 | 김민지 | 데이터베이스 | A |
| 1 | 102 | 김민지 | 알고리즘 | B |
| 2 | 101 | 이준호 | 데이터베이스 | A |

| 컬럼 | 어떤 키에 의존하는가? | 최종 테이블 |
| --- | --- | --- |
| student_name |  |  |
| course_name |  |  |
| grade |  |  |

```text
students(...)
courses(...)
enrollments(...)
```

---

## 8. 실습 5: 3정규형 이해

3NF는 먼저 2NF를 만족한다고 가정합니다.

> 이 예제에서는 하나의 `zip_code`가 하나의 `city`를 결정한다고 단순화합니다. 실제 주소 시스템에서는 업무 범위와 데이터 기준을 별도로 확인해야 합니다.

| member_id | member_name | zip_code | city |
| ---: | --- | --- | --- |
| 1 | 김민지 | 04524 | 서울 |
| 2 | 이준호 | 04524 | 서울 |
| 3 | 박서연 | 48058 | 부산 |

```text
member_id → zip_code → city
```

개선 구조를 작성합니다.

```text
members(...)
zip_codes(...)
```

단순히 값이 반복된다는 이유만으로 분리하지 않고, `zip_code → city`라는 업무 규칙을 확인했는지 설명합니다.

---

## 9. 실습 6: 컬럼 소유자 정리

| 정규화 전 컬럼 | 표현하는 사실 | 최종 테이블 |
| --- | --- | --- |
| member_name, member_email |  |  |
| book_title, author |  |  |
| loan_id, borrowed_at, due_at, returned_at |  |  |
| 새로 추가하는 식별자 |  |  |
| 새로 추가하는 관계 키 |  |  |

`joined_at`, `published_year`, `isbn`은 정규화 전 테이블에서 자동 생성되는 값이 아니라 Chapter 05의 추가 요구사항 속성임을 기록합니다.

---

## 10. 실습 7: normalization_practice.sql 실행

먼저 현재 데이터베이스를 확인합니다.

```sql
SELECT current_database();
```

그다음 `code/chapter06/normalization_practice.sql`을 실행합니다.

| 항목 | 작성 |
| --- | --- |
| 현재 데이터베이스 |  |
| SQL 파일 실행 성공 여부 |  |
| library_records 데이터 수 |  |
| members 데이터 수 |  |
| books 데이터 수 |  |
| loans 데이터 수 |  |
| 오류 메시지 |  |

예상 행 수는 `library_records` 3행, `members` 2행, `books` 2행, `loans` 3행입니다.

---

## 11. 실습 8: 정규화 전 데이터 확인

```sql
SELECT *
FROM library_records
ORDER BY loan_id;
```

| loan_id | member_name | member_email | book_title | author | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |

---

## 12. 실습 9: 정규화 후 테이블 확인

```sql
SELECT * FROM members ORDER BY id;
SELECT * FROM books ORDER BY id;
SELECT * FROM loans ORDER BY id;
```

### members: 2행

| id | name | email | joined_at |
| ---: | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |

### books: 2행

| id | title | author | published_year | isbn |
| ---: | --- | --- | ---: | --- |
|  |  |  |  |  |
|  |  |  |  |  |

### loans: 3행

| id | member_id | book_id | borrowed_at | due_at | returned_at |
| ---: | ---: | ---: | --- | --- | --- |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

---

## 13. 실습 10: JOIN으로 원래 업무 결과 복원

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

| loan_id | member_name | member_email | book_title | author | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |

JOIN은 데이터를 다시 중복 저장하지 않고 조회 시점에 필요한 결과 집합을 만듭니다.

---

## 14. 실습 11: 수정 이상 감소 확인

```sql
UPDATE members
SET email = 'kimminji@example.com'
WHERE id = 1;
```

| 확인 항목 | 작성 |
| --- | --- |
| 수정 전 이메일 |  |
| 수정 후 이메일 |  |
| 수정한 테이블 |  |
| 수정한 행 수 |  |

수정 후 JOIN 결과에서도 김민지의 모든 대여 행에 같은 최신 이메일이 표시되는지 확인합니다.

---

## 15. 실습 12: 삭제 이상 비교

다음 DELETE는 **직접 실행하지 않아도 됩니다.** SQL 파일에서도 주석 상태를 유지합니다.

```sql
-- DELETE FROM loans WHERE id = 1;
-- SELECT * FROM books ORDER BY id;
```

| 질문 | 답변 |
| --- | --- |
| 대여 행 삭제 후에도 책 정보가 남는가? |  |
| 정규화 전 구조에서는 어떤 정보가 함께 사라질 수 있는가? |  |

---

## 16. 실습 13: AI 생성 구조 검토

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

| 검토 항목 | 확인 내용 |
| --- | --- |
| 한 행의 의미 |  |
| 회원·책·대여 컬럼의 주인 |  |
| 독립 INSERT 가능 여부 |  |
| 한 곳 UPDATE 가능 여부 |  |
| 안전한 DELETE 가능 여부 |  |
| 1NF·2NF·3NF 검토 |  |
| 과도한 분리 여부 |  |
| PostgreSQL·샘플·JOIN 검증 |  |

AI 제안은 초안입니다. 실패하면 설계나 요청을 수정하고 다시 검증합니다.

---

## 17. 실습 14: 쇼핑몰 테이블 정규화

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

다음 구조로 분리할 근거를 작성합니다.

```text
customers(...)
products(...)
orders(...)
order_items(...)
```

---

## 18. 실습 기록 양식

```markdown
# Chapter 06 실습 기록

## 1. 정규화 전 문제 분석
## 2. 이상 현상 분석
## 3. 1NF / 2NF / 3NF 독립 예제
## 4. 컬럼 소유자 정리
## 5. SQL 실행과 행 수 확인
## 6. JOIN 결과 검증
## 7. 수정·삭제 이상 비교
## 8. AI 구조 검토
## 9. 느낀 점
```

---

## 19. 완성도 점검 기준

| 점검 항목 | 확인 기준 |
| --- | --- |
| 중복과 이상 현상 | 세 이상 현상을 실제 상황과 연결했는가? |
| 정규형 이해 | 각 예제의 전제와 의존 관계를 설명했는가? |
| SQL 실행 | 현재 DB와 테이블별 행 수를 확인했는가? |
| JOIN 검증 | `returned_at`을 포함한 원래 업무 결과를 복원했는가? |
| AI 구조 검토 | 행 의미와 컬럼 소유자를 먼저 확인했는가? |

---

## 20. 핵심 정리

```text
정규화는 테이블 수를 늘리는 작업이 아니라 한 사실을 적절한 주인에게 배치하는 작업이다.
중복의 핵심 문제는 저장 공간보다 불일치 위험이다.
정규화와 기존 운영 데이터 마이그레이션은 별도 작업이다.
AI 구조도 PostgreSQL과 샘플 데이터로 검증해야 한다.
```
