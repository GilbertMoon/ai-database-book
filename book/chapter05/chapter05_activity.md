# Chapter 05 실습 자료

## 데이터 모델링과 ERD

> 용도: 자기주도 실습 / Chapter 05 보조 자료

---

## 1. 실습 개요

이 실습 자료는 Chapter 05의 내용을 바탕으로, 독자가 요구사항을 읽고 테이블 후보, 속성, 관계를 직접 도출할 수 있도록 구성했습니다.

Chapter 05의 핵심은 ERD를 예쁘게 그리는 것이 아니라, **요구사항을 데이터베이스 구조로 바꾸고 실제 데이터로 검증하는 사고 과정**을 익히는 것입니다.

> 이 실습에서는 `books` 한 행을 하나의 대여 대상 도서 레코드로 취급하며 동일 ISBN의 여러 복본 구분은 다루지 않습니다.

---

## 2. 이 자료에서 확인할 내용

```text
1. 요구사항에서 엔터티 후보를 찾을 수 있다.
2. 엔터티와 속성을 구분할 수 있다.
3. 기본키와 외래키를 정할 수 있다.
4. 1:N 관계와 N:M 관계를 구분할 수 있다.
5. N:M 관계를 loans 테이블로 풀어낼 수 있다.
6. ERD 초안을 PostgreSQL CREATE TABLE SQL로 바꿀 수 있다.
7. 샘플 데이터와 JOIN으로 설계가 맞는지 검증할 수 있다.
8. AI가 만든 ERD 초안을 요구사항과 SQL로 검토할 수 있다.
```

---

## 3. 실습 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 데이터베이스
- code/chapter05/library_schema.sql
- ChatGPT 또는 Codex
```

### 실습 기록 파일명 예시

```text
chapter05_modeling_practice.md
```

---

## 4. 실습 1: 요구사항에서 명사 찾기

다음 요구사항을 읽고 중요한 명사를 표시해 봅니다.

```text
도서관은 회원을 관리한다.
회원은 여러 권의 책을 대여할 수 있다.
책은 제목, 저자, 출판연도, ISBN을 가진다.
회원은 이름, 이메일, 가입일을 가진다.
대여 기록에는 대여일, 반납예정일, 실제반납일을 저장한다.
아직 반납되지 않은 책은 실제반납일이 비어 있을 수 있다.
```

| 번호 | 명사 후보 | 설명 |
| ---: | --- | --- |
| 1 |  |  |
| 2 |  |  |
| 3 |  |  |
| 4 |  |  |
| 5 |  |  |
| 6 |  |  |
| 7 |  |  |
| 8 |  |  |

---

## 5. 실습 2: 엔터티와 속성 구분

| 명사 후보 | 엔터티 / 사건 엔터티 / 속성 | 이유 |
| --- | --- | --- |
| 회원 |  |  |
| 책 |  |  |
| 대여 기록 |  |  |
| 제목 |  |  |
| 저자 |  |  |
| 이메일 |  |  |
| 가입일 |  |  |
| 반납예정일 |  |  |

```text
엔터티와 속성을 구분할 때 가장 헷갈렸던 항목은 무엇인가요?
loans가 회원과 책을 연결하면서도 별도 엔터티인 이유는 무엇인가요?
```

---

## 6. 실습 3: 테이블 후보와 속성 정리

### 테이블 후보

| 테이블 후보 | 저장할 데이터 | 필요한 이유 |
| --- | --- | --- |
| members |  |  |
| books |  |  |
| loans |  |  |

### members

| 컬럼명 | 의미 | 데이터 타입 후보 | 제약조건 후보 |
| --- | --- | --- | --- |
| id |  |  |  |
| name |  |  |  |
| email |  |  |  |
| joined_at |  |  |  |

### books

| 컬럼명 | 의미 | 데이터 타입 후보 | 제약조건 후보 |
| --- | --- | --- | --- |
| id |  |  |  |
| title |  |  |  |
| author |  |  |  |
| published_year |  |  |  |
| isbn |  |  |  |

### loans

| 컬럼명 | 의미 | 데이터 타입 후보 | 제약조건 후보 |
| --- | --- | --- | --- |
| id |  |  |  |
| member_id |  |  |  |
| book_id |  |  |  |
| borrowed_at |  |  |  |
| due_at |  |  |  |
| returned_at |  |  | NULL 허용 |

---

## 7. 실습 4: 기본키·외래키와 관계 정하기

| 테이블 | 기본키 | 외래키 | 참조 대상 |
| --- | --- | --- | --- |
| members |  |  |  |
| books |  |  |  |
| loans |  |  |  |

| 관계 | 관계 유형 | 설명 |
| --- | --- | --- |
| members - loans |  |  |
| books - loans |  |  |
| members - books |  |  |

```text
1:N 관계에서 외래키가 N쪽인 loans에 있어야 하는 이유를 설명해 봅니다.
같은 member_id 또는 book_id가 여러 loans 행에 반복되는 것이 정상인 이유를 설명해 봅니다.
```

---

## 8. 실습 5: ERD 초안 작성

```text
members
- id PK
- name
- email UNIQUE
- joined_at

books
- id PK
- title
- author
- published_year
- isbn UNIQUE

loans
- id PK
- member_id FK -> members.id
- book_id FK -> books.id
- borrowed_at
- due_at
- returned_at NULL 가능

관계:
members 1:0..N loans
books 1:0..N loans
```

### 내 ERD 초안

```text
[여기에 작성]
```

---

## 9. 실습 6: library_schema.sql 실행

다음 파일을 실행합니다.

```text
code/chapter05/library_schema.sql
```

| 항목 | 작성 |
| --- | --- |
| SQL 파일 실행 성공 여부 |  |
| 생성된 테이블 목록 |  |
| members 입력 데이터 수 | 3 |
| books 입력 데이터 수 | 3 |
| loans 입력 데이터 수 | 4 |
| 오류가 있었다면 오류 메시지 |  |

---

## 10. 실습 7: 테이블 데이터 확인

```sql
SELECT * FROM members ORDER BY id;
SELECT * FROM books ORDER BY id;
SELECT * FROM loans ORDER BY id;
```

### members 결과

| id | name | email | joined_at |
| ---: | --- | --- | --- |
| 1 | 김민지 | minji@example.com | 2026-03-01 |
| 2 | 이준호 | junho@example.com | 2026-03-05 |
| 3 | 박서연 | seoyeon@example.com | 2026-03-10 |

### books 결과

| id | title | author | published_year | isbn |
| ---: | --- | --- | ---: | --- |
| 1 | 데이터베이스 입문 | 문길래 | 2026 | ISBN-001 |
| 2 | SQL 기초 | 홍길동 | 2025 | ISBN-002 |
| 3 | ERD 설계 연습 | 이몽룡 | 2024 | ISBN-003 |

### loans 결과

| id | member_id | book_id | borrowed_at | due_at | returned_at |
| ---: | ---: | ---: | --- | --- | --- |
| 1 | 1 | 1 | 2026-04-01 | 2026-04-15 | NULL |
| 2 | 1 | 2 | 2026-04-02 | 2026-04-16 | 2026-04-10 |
| 3 | 2 | 1 | 2026-04-03 | 2026-04-17 | NULL |
| 4 | 3 | 3 | 2026-04-05 | 2026-04-19 | NULL |

---

## 11. 실습 8: JOIN으로 설계 검증

```sql
SELECT
    loans.id,
    members.name AS member_name,
    books.title AS book_title,
    loans.borrowed_at,
    loans.due_at,
    loans.returned_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
ORDER BY loans.id;
```

| id | member_name | book_title | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- |
| 1 | 김민지 | 데이터베이스 입문 | 2026-04-01 | 2026-04-15 | NULL |
| 2 | 김민지 | SQL 기초 | 2026-04-02 | 2026-04-16 | 2026-04-10 |
| 3 | 이준호 | 데이터베이스 입문 | 2026-04-03 | 2026-04-17 | NULL |
| 4 | 박서연 | ERD 설계 연습 | 2026-04-05 | 2026-04-19 | NULL |

```text
JOIN 결과가 회원과 도서의 어떤 관계를 보여 주는지 설명해 봅니다.
```

---

## 12. 실습 9: 미반납 도서 조회

```sql
SELECT
    members.name AS member_name,
    books.title AS book_title,
    loans.borrowed_at,
    loans.due_at
FROM loans
JOIN members ON loans.member_id = members.id
JOIN books ON loans.book_id = books.id
WHERE loans.returned_at IS NULL
ORDER BY loans.due_at;
```

| member_name | book_title | borrowed_at | due_at |
| --- | --- | --- | --- |
| 김민지 | 데이터베이스 입문 | 2026-04-01 | 2026-04-15 |
| 이준호 | 데이터베이스 입문 | 2026-04-03 | 2026-04-17 |
| 박서연 | ERD 설계 연습 | 2026-04-05 | 2026-04-19 |

`returned_at IS NULL`은 실제반납일이 아직 정해지지 않은 미반납 상태를 의미합니다.

---

## 13. 실습 10: 외래키 오류 확인

다음 SQL의 주석을 해제하고 별도로 실행해 봅니다.

```sql
INSERT INTO loans (member_id, book_id, borrowed_at, due_at, returned_at)
VALUES (999, 1, '2026-04-10', '2026-04-24', NULL);
```

| 항목 | 작성 |
| --- | --- |
| 오류 발생 여부 |  |
| 오류 메시지 일부 |  |
| 어떤 제약조건 때문에 발생했는가? |  |
| 이 오류가 의미하는 것은 무엇인가? |  |

---

## 14. 실습 11: 나쁜 모델링 검토

```text
library_records(
    member_name,
    member_email,
    book_title,
    author,
    borrowed_at,
    due_at,
    returned_at
)
```

| 문제점 | 설명 |
| --- | --- |
| 데이터 중복 |  |
| 수정 오류 가능성 |  |
| 회원/책/대여 기록 혼합 |  |
| 관계 표현 문제 |  |

---

## 15. 실습 12: AI 생성 ERD 검토

AI가 다음 설계를 제안했다고 가정합니다.

```text
members(id, name, email, book_id, borrowed_at)
books(id, title, author, isbn)
```

| 검토 항목 | 문제 여부 | 설명 |
| --- | --- | --- |
| 회원이 여러 권을 대여할 수 있는가? |  |  |
| 대여 기록을 독립적으로 관리할 수 있는가? |  |  |
| 반납예정일과 실제반납일을 저장할 수 있는가? |  |  |
| N:M 관계가 적절히 풀렸는가? |  |  |
| 요구사항에 없는 구조가 추가되었는가? |  |  |
| PostgreSQL과 샘플 데이터로 검증 가능한가? |  |  |

### 수정 설계안

```text
[여기에 수정한 테이블 구조 작성]
```

---

## 16. 실습 기록 양식

```markdown
# Chapter 05 실습 기록

## 1. 요구사항에서 찾은 명사
## 2. 엔터티와 속성 구분
## 3. 테이블 후보와 속성
## 4. 기본키와 외래키
## 5. 관계 분석과 ERD 초안
## 6. library_schema.sql 실행 결과
## 7. JOIN 및 미반납 조회 결과
## 8. 외래키 오류 확인
## 9. AI 생성 ERD 검토
## 10. 알게 된 점
```

---

## 17. 완성도 점검 기준

| 점검 항목 | 확인 기준 |
| --- | --- |
| 요구사항 분석 | 명사 후보, 엔터티, 사건 엔터티, 속성을 구분했는가 |
| 테이블/관계 설계 | PK, FK, 1:N, N:M 관계를 정확히 설명했는가 |
| SQL 실행 및 검증 | 3명·3권·4건 데이터와 JOIN 결과를 확인했는가 |
| NULL과 오류 검증 | `returned_at IS NULL`과 외래키 오류를 설명했는가 |
| AI 생성 ERD 검토 | 요구사항 누락·과잉·관계 오류와 수정 방향을 설명했는가 |

---

## 18. 핵심 정리

```text
엔터티는 테이블이 되고,
속성은 컬럼이 되고,
1:N 관계는 N쪽 외래키로 구현된다.

members와 books의 개념상 N:M 관계는 loans로 해소되며,
loans는 두 외래키와 날짜 속성을 가진 대여 사건 테이블이다.

AI가 만든 ERD는 요구사항, 실제 SQL, 샘플 데이터와 JOIN으로 검증한다.
```
