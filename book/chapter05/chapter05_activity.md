# Chapter 05 활동 자료

## 데이터 모델링과 ERD

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 05 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 05의 내용을 바탕으로, 학습자가 요구사항을 읽고 테이블 후보, 속성, 관계를 직접 도출할 수 있도록 구성한 실습지입니다.

Chapter 05의 핵심은 ERD를 예쁘게 그리는 것이 아니라, **요구사항을 데이터베이스 구조로 바꾸는 사고 과정**을 익히는 것입니다.

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. 요구사항에서 엔터티 후보를 찾을 수 있다.
2. 엔터티와 속성을 구분할 수 있다.
3. 기본키와 외래키를 정할 수 있다.
4. 1:N 관계와 N:M 관계를 구분할 수 있다.
5. N:M 관계를 중간 테이블로 풀어낼 수 있다.
6. ERD 초안을 PostgreSQL CREATE TABLE SQL로 바꿀 수 있다.
7. 샘플 데이터와 JOIN으로 설계가 맞는지 검증할 수 있다.
8. AI가 만든 ERD 초안을 검토할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 데이터베이스
- code/chapter05/library_schema.sql
- ChatGPT 또는 Codex
```

### 제출 파일명 권장

```text
학번_이름_chapter05_activity.md
```

예시:

```text
20260001_홍길동_chapter05_activity.md
```

---

## 4. 활동 1: 요구사항에서 명사 찾기

다음 요구사항을 읽고 중요한 명사를 표시하세요.

```text
도서관은 회원을 관리한다.
회원은 여러 권의 책을 대여할 수 있다.
책은 제목, 저자, 출판연도, ISBN을 가진다.
회원은 이름, 이메일, 가입일을 가진다.
대여 기록에는 대여일, 반납예정일, 실제반납일을 저장한다.
아직 반납되지 않은 책은 실제반납일이 비어 있을 수 있다.
```

### 명사 후보 작성

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

## 5. 활동 2: 엔터티와 속성 구분

활동 1에서 찾은 명사 중 테이블 후보가 될 엔터티와 컬럼이 될 속성을 구분하세요.

| 명사 후보 | 엔터티 / 속성 | 이유 |
| --- | --- | --- |
| 회원 |  |  |
| 책 |  |  |
| 대여 기록 |  |  |
| 제목 |  |  |
| 저자 |  |  |
| 이메일 |  |  |
| 가입일 |  |  |
| 반납예정일 |  |  |

### 질문

```text
엔터티와 속성을 구분할 때 가장 헷갈렸던 항목은 무엇인가요?
그 이유는 무엇인가요?
```

---

## 6. 활동 3: 테이블 후보 정리

도서 대여 시스템에 필요한 테이블 후보를 정리하세요.

| 테이블 후보 | 저장할 데이터 | 필요한 이유 |
| --- | --- | --- |
| members |  |  |
| books |  |  |
| loans |  |  |

### 추가 테이블 후보가 있다면 작성

| 추가 후보 | 필요한 이유 | 실제로 테이블로 만들 것인가? |
| --- | --- | --- |
|  |  |  |

---

## 7. 활동 4: 속성 정리

각 테이블에 필요한 컬럼을 작성하세요.

### members 테이블

| 컬럼명 | 의미 | 데이터 타입 후보 | 제약조건 후보 |
| --- | --- | --- | --- |
| id |  |  |  |
| name |  |  |  |
| email |  |  |  |
| joined_at |  |  |  |

### books 테이블

| 컬럼명 | 의미 | 데이터 타입 후보 | 제약조건 후보 |
| --- | --- | --- | --- |
| id |  |  |  |
| title |  |  |  |
| author |  |  |  |
| published_year |  |  |  |
| isbn |  |  |  |

### loans 테이블

| 컬럼명 | 의미 | 데이터 타입 후보 | 제약조건 후보 |
| --- | --- | --- | --- |
| id |  |  |  |
| member_id |  |  |  |
| book_id |  |  |  |
| borrowed_at |  |  |  |
| due_at |  |  |  |
| returned_at |  |  |  |

---

## 8. 활동 5: 기본키와 외래키 정하기

각 테이블의 기본키와 외래키를 정리하세요.

| 테이블 | 기본키 | 외래키 | 참조 대상 |
| --- | --- | --- | --- |
| members |  |  |  |
| books |  |  |  |
| loans |  |  |  |

### 질문

```text
loans 테이블에 member_id와 book_id가 필요한 이유를 설명하세요.
```

---

## 9. 활동 6: 관계 분석

테이블 사이의 관계를 작성하세요.

| 관계 | 관계 유형 | 설명 |
| --- | --- | --- |
| members - loans |  |  |
| books - loans |  |  |
| members - books |  |  |

### N:M 관계 설명

```text
members와 books는 직접 보면 N:M 관계입니다.
이 관계를 loans 테이블로 어떻게 풀어냈는지 설명하세요.
```

---

## 10. 활동 7: ERD 초안 텍스트로 작성

그림 도구를 사용하지 않아도 됩니다. 먼저 텍스트로 ERD 초안을 작성하세요.

```text
members
- id PK
- name
- email
- joined_at

books
- id PK
- title
- author
- published_year
- isbn

loans
- id PK
- member_id FK -> members.id
- book_id FK -> books.id
- borrowed_at
- due_at
- returned_at

관계:
members 1:N loans
books 1:N loans
```

### 내 ERD 초안

```text
[여기에 작성]
```

---

## 11. 활동 8: library_schema.sql 실행 결과 기록

다음 파일을 실행합니다.

```text
code/chapter05/library_schema.sql
```

실행 결과를 기록하세요.

| 항목 | 작성 |
| --- | --- |
| SQL 파일 실행 성공 여부 |  |
| 생성된 테이블 목록 |  |
| members 입력 데이터 수 |  |
| books 입력 데이터 수 |  |
| loans 입력 데이터 수 |  |
| 오류가 있었다면 오류 메시지 |  |

---

## 12. 활동 9: 테이블 데이터 확인

다음 SQL 실행 결과를 요약하세요.

```sql
SELECT * FROM members;
SELECT * FROM books;
SELECT * FROM loans;
```

### members 결과 요약

| id | name | email | joined_at |
| ---: | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

### books 결과 요약

| id | title | author | published_year | isbn |
| ---: | --- | --- | ---: | --- |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

### loans 결과 요약

| id | member_id | book_id | borrowed_at | due_at | returned_at |
| ---: | ---: | ---: | --- | --- | --- |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

---

## 13. 활동 10: JOIN으로 설계 검증

다음 SQL을 실행합니다.

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

실행 결과를 기록하세요.

| id | member_name | book_title | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

### 질문

```text
JOIN 결과를 보면 member_id와 book_id 대신 어떤 정보가 표시되나요?
이것이 ERD 설계 검증에 어떤 도움이 되나요?
```

---

## 14. 활동 11: 미반납 도서 조회

다음 SQL을 실행합니다.

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

실행 결과를 기록하세요.

| member_name | book_title | borrowed_at | due_at |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

### 질문

```text
returned_at이 NULL이라는 것은 무엇을 의미하나요?
```

---

## 15. 활동 12: 외래키 오류 확인

다음 SQL의 주석을 해제하고 별도로 실행해 보세요.

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

### 해설 작성 예시

```text
members 테이블에 id가 999인 회원이 없기 때문에 loans.member_id가 members.id를 참조할 수 없다.
따라서 외래키 제약조건 오류가 발생한다.
```

---

## 16. 활동 13: 나쁜 모델링 검토

다음 테이블 설계의 문제점을 찾아보세요.

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
| 확장성 문제 |  |

### 개선 방향

```text
위 구조를 어떤 테이블들로 나누면 좋을까요?
```

---

## 17. 활동 14: ChatGPT로 ERD 초안 만들기

아래 요구사항을 ChatGPT에게 입력할 프롬프트로 바꿔 보세요.

```text
도서관은 회원을 관리한다.
회원은 여러 권의 책을 대여할 수 있다.
책은 제목, 저자, 출판연도, ISBN을 가진다.
대여 기록에는 대여일, 반납예정일, 실제반납일을 저장한다.
```

### 좋은 프롬프트 조건

```text
- PostgreSQL 기준이라고 명시한다.
- 테이블 후보를 요청한다.
- 컬럼, 기본키, 외래키를 요청한다.
- 1:N, N:M 관계 설명을 요청한다.
- 설계 검토 포인트도 함께 요청한다.
```

### 내가 작성한 프롬프트

```text
[여기에 작성]
```

---

## 18. 활동 15: AI 생성 ERD 검토

AI가 다음 설계를 제안했다고 가정합니다.

```text
members(id, name, email, book_id, borrowed_at)
books(id, title, author, isbn)
```

이 설계를 검토하세요.

| 검토 항목 | 문제 여부 | 설명 |
| --- | --- | --- |
| 회원이 여러 권을 대여할 수 있는가? |  |  |
| 대여 기록을 독립적으로 관리할 수 있는가? |  |  |
| 반납예정일과 실제반납일을 저장할 수 있는가? |  |  |
| N:M 관계가 적절히 풀렸는가? |  |  |
| 중복이나 확장성 문제가 있는가? |  |  |

### 수정 설계안

```text
[여기에 수정한 테이블 구조 작성]
```

---

## 19. 제출 양식

아래 형식을 그대로 복사하여 제출 파일에 사용해도 됩니다.

```markdown
# Chapter 05 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. 요구사항에서 찾은 명사

[활동 1 작성]

## 3. 엔터티와 속성 구분

[활동 2 작성]

## 4. 테이블 후보와 속성

[활동 3~4 작성]

## 5. 기본키와 외래키

[활동 5 작성]

## 6. 관계 분석

[활동 6 작성]

## 7. ERD 초안

[활동 7 작성]

## 8. library_schema.sql 실행 결과

[활동 8~12 작성]

## 9. 나쁜 모델링 검토

[활동 13 작성]

## 10. ChatGPT 프롬프트

[활동 14 작성]

## 11. AI 생성 ERD 검토

[활동 15 작성]

## 12. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 20. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| 요구사항 분석 | 20 | 명사 후보, 엔터티, 속성을 적절히 구분했는가 |
| 테이블/관계 설계 | 25 | 기본키, 외래키, 1:N, N:M 관계를 정확히 설명했는가 |
| SQL 실행 및 검증 | 25 | library_schema.sql 실행 결과와 JOIN 검증을 구체적으로 기록했는가 |
| AI 생성 ERD 검토 | 20 | AI 설계의 문제점과 수정 방향을 설명했는가 |
| 제출 형식 | 10 | 지정된 형식에 맞게 명확히 작성했는가 |

---

## 21. 피드백 코멘트 예시

### 우수한 경우

```text
요구사항에서 members, books, loans 엔터티를 정확히 도출했고,
loans 테이블이 members와 books의 N:M 관계를 풀어 주는 중간 테이블이라는 점을 잘 설명했습니다.
또한 JOIN 결과로 설계가 실제 조회 요구사항을 만족하는지 검증한 점이 좋습니다.
```

### 보완이 필요한 경우

```text
회원과 책 엔터티는 잘 찾았지만 대여 기록을 별도 테이블로 분리하지 않아 여러 권의 대여를 표현하기 어렵습니다.
N:M 관계는 직접 연결하기보다 loans 같은 중간 테이블로 풀어야 합니다.
AI가 만든 ERD도 그대로 사용하지 말고 관계와 중복 여부를 검토해 주세요.
```

---

## 22. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. 요구사항 읽기 및 명사 찾기: 15분
2. 엔터티/속성 구분: 20분
3. 관계 분석 및 ERD 초안 작성: 25분
4. library_schema.sql 실행: 20분
5. JOIN과 외래키 오류 검증: 20분
6. AI 생성 ERD 검토 토론: 20분
```

온라인 수업에서는 학생들이 ERD를 그림으로 제출하지 못해도, 텍스트 ERD와 SQL 실행 결과를 제출하도록 허용하면 좋습니다.

---

## 23. 핵심 정리

이 활동의 핵심은 요구사항을 테이블 구조로 바꾸는 것입니다.

```text
엔터티는 테이블이 되고,
속성은 컬럼이 되고,
관계는 외래키가 된다.

N:M 관계는 중간 테이블로 풀어야 하며,
AI가 만든 ERD는 반드시 요구사항, 관계, 중복, 확장성 기준으로 검토해야 한다.
```
