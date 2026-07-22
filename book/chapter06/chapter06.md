# Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기

---

## 이 장에서 살펴볼 내용

Chapter 05에서는 요구사항을 엔터티, 속성, 관계와 업무 규칙으로 바꾸고 ERD를 작성했습니다. 또한 이메일과 ISBN의 고유성, 동일 도서의 동시 대여, 날짜 규칙처럼 아직 확정되지 않은 정책을 별도로 기록했습니다.

이 장에서는 미확정 정책 가운데 실습에 필요한 규칙을 확정하고, 그 규칙을 정규화된 PostgreSQL 구조와 제약조건으로 구현합니다.

```text
한 행의 의미 확인
→ 반복되는 사실과 컬럼의 주인 찾기
→ 삽입·수정·삭제 이상 분석
→ 1NF·2NF·3NF 기준으로 구조 개선
→ 업무 정책 확정
→ PK·FK·NOT NULL·UNIQUE·CHECK 적용
→ 도서별 활성 대여 중복 차단
→ 정상·경계·오류 데이터로 검증
→ 삭제 정책과 과도한 분리 검토
→ AI 설계의 구조와 제약조건 검증
```

이 장에서는 다음 내용을 살펴봅니다.

- 같은 사실이 여러 곳에 저장될 때 발생하는 문제
- 삽입·수정·삭제 이상 현상
- 함수적 종속의 기초
- 제1정규형, 제2정규형, 제3정규형
- 도서 대여 테이블의 정규화
- 미확정 정책을 확정 규칙으로 바꾸는 방법
- 기본키와 외래키
- `NOT NULL`, `UNIQUE`, `CHECK`
- 부분 고유 인덱스를 이용한 활성 대여 중복 차단
- 참조 무결성과 외래키 오류
- 삭제 정책과 `CASCADE` 사용 시 주의점
- 정상·경계·오류 데이터 검증
- 정규화와 과도한 테이블 분리의 차이
- AI가 만든 테이블 구조와 제약조건 검토

이 장의 목표는 정규형 이름을 외우는 것이 아닙니다. 다음 질문에 답할 수 있는 구조를 만드는 것입니다.

```text
각 사실은 어느 테이블에서 한 번만 관리되는가?
어떤 업무 규칙이 확정되었는가?
잘못된 값과 잘못된 관계를 DBMS가 차단할 수 있는가?
정상값과 경계값은 허용되고 오류값은 거부되는가?
```

> **핵심 원칙**
>
> 정규화는 사실의 주인을 정하고, 무결성 제약조건은 확정된 업무 규칙에 따라 저장할 수 있는 값과 관계의 경계를 정합니다.

---

## 1. 좋은 테이블은 데이터가 변할 때 드러난다

처음 데이터를 입력할 때는 하나의 큰 테이블이 편해 보일 수 있습니다.

| loan_id | member_name | member_email | book_title | author | borrowed_at | due_at | returned_at |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1001 | 김민지 | minji@example.com | 데이터베이스 입문 | 문길래 | 2026-04-01 | 2026-04-15 | 2026-04-02 |
| 1002 | 김민지 | minji@example.com | SQL 기초 | 홍길동 | 2026-04-02 | 2026-04-16 | 2026-04-10 |
| 1003 | 이준호 | junho@example.com | 데이터베이스 입문 | 문길래 | 2026-04-03 | 2026-04-17 | NULL |

한 행에 회원, 도서와 대여 사건이 모두 들어 있습니다. 조회 결과처럼 보이지만 저장 구조로 사용하면 다음 문제가 생깁니다.

```text
김민지의 이름과 이메일이 대여 기록마다 반복된다.
같은 책의 제목과 저자가 여러 행에 반복된다.
회원 이메일을 바꿀 때 여러 행을 수정해야 한다.
대여되지 않은 새 책을 독립적으로 등록하기 어렵다.
마지막 대여 행을 삭제하면 책 정보까지 사라질 수 있다.
```

![중복 저장이 만드는 정규화 문제](../../images/chapter06/ch06_01_normalization_problem_overview.svg)

그림 6-1 중복 저장이 만드는 정규화 문제

좋은 테이블은 처음 입력하기 쉬운 구조가 아니라, 데이터가 변할 때 사실의 의미와 일관성을 지킬 수 있는 구조입니다.

---

## 2. 중복의 핵심 문제는 불일치다

중복 데이터가 항상 잘못된 것은 아닙니다. 외래키 값이나 업무 이력처럼 의미 있는 반복도 있습니다.

```text
public.loans_nf.member_id에 101이 여러 번 저장됨
→ 회원 101이 여러 대여 기록을 가진다는 정상적인 1:N 관계
```

문제가 되는 중복은 **같은 사실의 복사본을 여러 곳에서 따로 관리하는 경우**입니다.

| 반복되는 사실 | 반복되는 위치 | 위험 |
| --- | --- | --- |
| 회원 이름과 이메일 | 여러 대여 행 | 일부 행만 수정되어 회원 정보 불일치 |
| 책 제목과 저자 | 여러 대여 행 | 책 정보 변경 시 여러 행 수정 필요 |
| 현재 가격이나 현재 상태 | 여러 이력 행 | 현재값과 과거값의 의미가 섞임 |

다음 질문으로 정상적인 반복과 위험한 중복을 구분합니다.

```text
이 값은 같은 사실의 복사본인가?
각 행마다 독립적인 의미를 가진 값인가?
값이 바뀔 때 한 곳만 수정하면 되는가?
과거 시점의 값을 보존하기 위해 의도적으로 저장한 것인가?
```

정규화의 목적은 단순히 저장 공간을 줄이는 것이 아니라, 같은 사실의 복사본이 서로 다른 값이 되는 위험을 줄이는 것입니다.

---

## 3. 삽입·수정·삭제 이상

잘못된 테이블 경계는 데이터 변경 과정에서 이상 현상을 만듭니다.

| 이상 현상 | 의미 | 도서 대여 예 |
| --- | --- | --- |
| 삽입 이상 | 독립적인 정보를 자연스럽게 추가하기 어려움 | 아직 대여되지 않은 책을 등록하기 어려움 |
| 수정 이상 | 같은 사실을 여러 곳에서 수정해야 함 | 회원 이메일을 여러 대여 행에서 변경해야 함 |
| 삭제 이상 | 한 행을 지울 때 보존할 정보까지 사라짐 | 마지막 대여 행 삭제 시 책 정보도 사라짐 |

![삽입·수정·삭제 이상 현상](../../images/chapter06/ch06_02_anomaly_types.svg)

그림 6-2 삽입·수정·삭제 이상 현상

이상 현상은 SQL 문법 오류가 아닙니다. SQL은 정상적으로 실행되지만 데이터의 의미가 손상되는 **구조 문제**입니다.

### 삽입 이상

새 책은 아직 대여되지 않았더라도 등록할 수 있어야 합니다.

```sql
INSERT INTO public.books_nf (id, title, author, published_year, isbn)
VALUES (203, '정규화 입문', '문길래', 2026, 'ISBN-003');
```

회원이나 대여 정보 없이 책만 입력할 수 있어야 합니다.

### 수정 이상

김민지 회원의 이메일은 회원 테이블 한 행에서 수정되어야 합니다.

```sql
UPDATE public.members_nf
SET email = 'kimminji@example.com'
WHERE id = 101;
```

대여 기록마다 이메일을 따로 수정하지 않습니다.

### 삭제 이상

대여 기록을 삭제하더라도 책 자체의 정보는 남아야 합니다.

```text
public.loans_nf의 행 삭제
≠ public.books_nf의 도서 정보 삭제
```

실제 삭제 SQL은 영향 범위와 이력 보존 정책을 확인한 뒤 실행해야 합니다.

---

## 4. 한 행의 의미와 컬럼의 주인

정규화를 시작할 때 가장 먼저 확인할 것은 **한 행의 의미**입니다.

```text
library_records_raw 한 행
→ 회원 한 명인가?
→ 도서 한 권인가?
→ 대여 사건 한 건인가?
```

회원 정보, 도서 정보와 대여 사건이 한 행에 섞여 있다면 행의 의미가 불명확합니다.

| 컬럼 | 표현하는 사실 | 적절한 주인 |
| --- | --- | --- |
| `member_name`, `member_email` | 회원 정보 | `members_nf` |
| `book_title`, `author` | 도서 정보 | `books_nf` |
| `borrowed_at`, `due_at`, `returned_at` | 대여 사건 | `loans_nf` |
| `member_id`, `book_id` | 대여와 부모 행의 관계 | `loans_nf` |

다음 질문을 반복합니다.

```text
이 값은 누구를 설명하는가?
그 대상이 없어도 이 값이 존재할 수 있는가?
값이 바뀌는 이유와 시점이 같은가?
한 곳에서만 관리해야 하는 현재 사실인가?
사건 당시 값을 보존해야 하는 이력인가?
```

Chapter 05에서 작성한 요구사항 추적표도 컬럼의 주인을 판단하는 근거가 됩니다.

---

## 5. 함수적 종속의 기초

정규화를 이해하려면 “어떤 값이 다른 값을 결정한다”는 관계를 살펴봐야 합니다.

```text
X → Y
```

이는 정의된 업무 범위에서 **같은 X 값이면 Y도 항상 같아야 한다**는 뜻입니다.

```text
member_id → member_name, member_email
book_id   → book_title, author
loan_id   → borrowed_at, due_at, returned_at
```

값이 우연히 반복된다고 함수적 종속이 되는 것은 아닙니다. 업무 규칙상 같은 결정자 값이 항상 같은 결과 값을 가져야 합니다.

정규화는 이러한 결정 관계를 기준으로 각 컬럼의 주인을 찾는 과정으로 이해할 수 있습니다.

---

## 6. 제1정규형: 한 셀에 여러 독립 값을 넣지 않는다

> 제1·제2·제3정규형 예제는 각 개념을 쉽게 설명하기 위한 독립적인 예제입니다. 하나의 테이블을 세 단계에 걸쳐 그대로 변환하는 연속 실습은 아닙니다.

제1정규형은 한 셀에 업무상 독립적으로 다뤄야 할 여러 값을 넣지 않는 단계입니다.

| member_id | member_name | borrowed_books |
| ---: | --- | --- |
| 101 | 김민지 | 데이터베이스 입문, SQL 기초 |

`borrowed_books`를 검색하거나 책별 관계로 연결하기 어렵습니다. 다음처럼 한 대여당 한 행으로 표현할 수 있습니다.

| member_id | member_name | book_title |
| ---: | --- | --- |
| 101 | 김민지 | 데이터베이스 입문 |
| 101 | 김민지 | SQL 기초 |

![제1정규형: 한 셀에 하나의 값](../../images/chapter06/ch06_03_first_normal_form.svg)

그림 6-3 제1정규형: 한 셀에 하나의 값

다음 구조도 피합니다.

```text
book1, book2, book3
phone1, phone2, phone3
```

반복되는 개수만큼 열을 계속 추가해야 하기 때문입니다. 제1정규형을 만족했다고 모든 중복 문제가 해결되는 것은 아닙니다. 회원 이름과 책 제목은 여전히 여러 행에 반복될 수 있습니다.

---

## 7. 제2정규형: 복합키 일부에만 의존하는 컬럼을 분리한다

제2정규형은 먼저 제1정규형을 만족한다고 가정합니다. 복합 후보키가 있을 때 일반 컬럼이 키 전체가 아니라 일부에만 의존하는지 확인합니다.

| student_id | course_id | student_name | course_name | grade |
| ---: | ---: | --- | --- | --- |
| 1 | 101 | 김민지 | 데이터베이스 | A |
| 1 | 102 | 김민지 | 알고리즘 | B |
| 2 | 101 | 이준호 | 데이터베이스 | A |

이 예제에서는 한 학생이 같은 강의를 한 번만 수강한다고 가정하고 복합키를 `(student_id, course_id)`로 봅니다. 재수강, 학기 또는 분반을 관리한다면 `term_id`, `section_id` 같은 식별 요소가 추가되어야 합니다.

```text
student_id → student_name
course_id → course_name
student_id + course_id → grade
```

`student_name`은 `student_id`만으로 결정되고, `course_name`은 `course_id`만으로 결정됩니다. 따라서 각 컬럼의 주인 테이블로 옮깁니다.

```text
students(id, name)
courses(id, name)
enrollments(student_id, course_id, grade)
```

![제2정규형: 복합키 일부 의존 분리](../../images/chapter06/ch06_04_second_normal_form.svg)

그림 6-4 제2정규형: 복합키 일부 의존 분리

단일 컬럼 후보키에서는 부분 종속이 발생하지 않습니다. 제2정규형의 핵심은 **복합키 전체가 필요한 값과 일부 키만으로 결정되는 값을 구분하는 것**입니다.

---

## 8. 제3정규형: 일반 컬럼이 다른 일반 컬럼을 결정하는지 확인한다

제3정규형은 먼저 제2정규형을 만족한다고 가정합니다. 기본키가 아닌 컬럼이 다른 일반 컬럼을 결정하는 업무 규칙이 있는지 확인합니다.

> 다음 예제에서는 설명을 단순화하기 위해 하나의 `zip_code`가 하나의 `city`를 결정한다고 가정합니다. 실제 주소 체계에서는 업무 범위와 기준 데이터를 별도로 확인해야 합니다.

| member_id | member_name | zip_code | city |
| ---: | --- | --- | --- |
| 1 | 김민지 | 04524 | 서울 |
| 2 | 이준호 | 04524 | 서울 |
| 3 | 박서연 | 48058 | 부산 |

```text
member_id → zip_code
zip_code → city
```

`city`는 회원 ID보다 우편번호에 직접 의존합니다. 다음처럼 분리할 수 있습니다.

```text
members(id, name, zip_code)
zip_codes(zip_code, city)
```

![제3정규형: 일반 컬럼 간 의존 분리](../../images/chapter06/ch06_05_third_normal_form.svg)

그림 6-5 제3정규형: 일반 컬럼 간 의존 분리

값이 반복된다는 이유만으로 테이블을 분리하지 않습니다. `zip_code → city`처럼 일관된 업무 규칙이 있는지 먼저 확인해야 합니다.

---

## 9. 도서 대여 테이블 정규화하기

정규화 전 구조는 다음과 같습니다.

```text
library_records_raw(
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

한 행이 대여 사건을 나타내지만 회원과 책의 현재 정보까지 함께 저장합니다.

| 정규화 전 컬럼 | 표현하는 사실 | 정규화 후 주인 |
| --- | --- | --- |
| `member_name`, `member_email` | 회원 | `members_nf` |
| `book_title`, `author` | 도서 | `books_nf` |
| `loan_id`, 날짜 열 | 대여 사건 | `loans_nf` |
| `member_id`, `book_id` | 부모 행과의 관계 | `loans_nf` |

![도서 대여 테이블 정규화 흐름](../../images/chapter06/ch06_06_library_normalization_flow.svg)

그림 6-6 도서 대여 테이블 정규화 흐름

정규화 후 구조는 다음과 같습니다.

```text
members_nf(id, name, email, joined_at)
books_nf(id, title, author, published_year, isbn)
loans_nf(id, member_id, book_id, borrowed_at, due_at, returned_at)
```

`joined_at`, `published_year`, `isbn`은 `library_records_raw`를 분리해서 자동으로 생긴 값이 아닙니다. Chapter 05의 전체 요구사항에서 가져온 속성입니다.

정규화는 존재하지 않던 업무 데이터를 만들어 내는 작업이 아닙니다. 원본에 없는 값을 채우려면 별도의 요구사항 확인과 데이터 수집이 필요합니다.

실습에서는 Chapter 05의 기존 테이블과 충돌하지 않도록 `_nf` 접미사를 사용합니다.

---

## 10. 미확정 정책을 확정 규칙으로 바꾸기

Chapter 05에서는 이메일과 ISBN의 고유성, 공백 문자열, 날짜 순서, 삭제 정책과 동시 대여를 미확정 질문으로 남겼습니다. 제약조건을 만들기 전에 이 실습에서 사용할 정책을 다음과 같이 확정합니다.

| ID | 확정 규칙 | PostgreSQL 구현 | 검증 방법 |
| --- | --- | --- | --- |
| C-01 | 정확히 같은 이메일 문자열의 중복을 허용하지 않는다 | `UNIQUE (email)` | 중복 이메일 입력 실패 |
| C-02 | 같은 ISBN 문자열의 도서를 중복 등록하지 않는다 | `UNIQUE (isbn)` | 중복 ISBN 입력 실패 |
| C-03 | 회원 이름과 도서 제목은 공백 문자열일 수 없다 | `CHECK` | 공백 값 입력 실패 |
| C-04 | 반납예정일은 대여일과 같거나 이후여야 한다 | `CHECK` | 이전 날짜 입력 실패 |
| C-05 | 실제반납일은 `NULL`이거나 대여일과 같거나 이후여야 한다 | `CHECK` | 이전 날짜 입력 실패 |
| C-06 | 대여는 존재하는 회원과 도서만 참조한다 | `FOREIGN KEY` | 없는 부모 참조 실패 |
| C-07 | 대여 이력이 있는 회원과 도서는 바로 삭제하지 않는다 | `ON DELETE RESTRICT` | 참조 중 부모 삭제 실패 |
| C-08 | 한 도서에는 미반납 대여가 최대 한 건만 존재한다 | 부분 고유 인덱스 | 두 번째 활성 대여 실패 |

다음 항목은 이 장의 단순화 범위입니다.

```text
이메일 대소문자와 별칭 정규화는 다루지 않는다.
동일 ISBN 복본을 별도 도서 사본으로 관리하는 모델은 다루지 않는다.
한 도서에 여러 저자를 연결하는 모델은 다루지 않는다.
과거 날짜 구간 전체의 중첩 검사는 다루지 않는다.
현재 미반납 대여의 중복만 차단한다.
```

제약조건은 좋은 아이디어를 임의로 추가하는 기능이 아닙니다. 요구사항이나 확정된 가정을 DBMS가 검사할 수 있는 형태로 바꾸는 기능입니다.

---

## 11. 정규화와 무결성 제약조건은 함께 필요하다

정규화된 테이블만 만들었다고 잘못된 데이터가 자동으로 차단되는 것은 아닙니다.

```text
정규화
→ 사실을 적절한 테이블에 배치

무결성 제약조건
→ 확정된 규칙에 따라 허용할 값과 관계를 DBMS에 선언
```

예를 들어 잘 분리된 테이블에도 다음 데이터가 저장되면 문제가 됩니다.

```text
이름이 NULL인 회원
같은 이메일을 가진 회원 두 명
존재하지 않는 회원을 참조하는 대여 기록
대여일보다 빠른 반납예정일
같은 도서의 미반납 대여 두 건
```

이 문제를 `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`와 부분 고유 인덱스로 차단합니다.

---

## 12. 기본키: 각 행을 안정적으로 식별한다

기본키는 테이블 안의 각 행을 고유하게 식별합니다.

```sql
id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
```

기본키에는 다음 특성이 필요합니다.

```text
행마다 값이 다르다.
NULL일 수 없다.
다른 테이블에서 안정적으로 참조할 수 있다.
가능하면 자주 바뀌지 않는다.
```

이메일과 ISBN은 이번 실습에서 고유성이 확정되었지만 정책이나 형식이 바뀔 수 있습니다. 따라서 숫자 ID를 기본키로 사용하고 이메일과 ISBN은 별도의 `UNIQUE` 규칙으로 관리합니다.

Chapter 04·05와 동일하게 PostgreSQL의 `IDENTITY` 방식을 사용합니다.

---

## 13. NOT NULL, UNIQUE와 CHECK

### NOT NULL

반드시 있어야 하는 값을 생략하지 못하게 합니다.

```sql
name VARCHAR(50) NOT NULL
```

`NOT NULL`은 빈 문자열까지 자동으로 막지는 않습니다. 공백 문자열을 허용하지 않으려면 별도 `CHECK`가 필요합니다.

```sql
CHECK (char_length(trim(name)) > 0)
```

### UNIQUE

업무상 중복되면 안 된다고 확정한 값을 제한합니다.

```sql
CONSTRAINT uq_members_nf_email UNIQUE (email)
CONSTRAINT uq_books_nf_isbn UNIQUE (isbn)
```

이 실습의 `UNIQUE`는 정확히 같은 문자열의 중복을 막습니다. 이메일 대소문자나 형식 정규화는 별도 정책이 필요합니다. 동명이인의 이름에는 일반적으로 `UNIQUE`를 적용하지 않습니다.

### CHECK

한 행 안에서 값이 만족해야 할 조건을 선언합니다.

```sql
CHECK (due_at >= borrowed_at)

CHECK (
    returned_at IS NULL
    OR returned_at >= borrowed_at
)
```

`CHECK`는 대여일보다 빠른 반납예정일이나 실제반납일을 차단합니다. `due_at = borrowed_at`과 `returned_at = borrowed_at`은 경계값으로 허용됩니다.

다른 여러 행의 상태나 외부 정책이 필요한 규칙은 일반 `CHECK` 하나로 해결할 수 없습니다.

---

## 14. 외래키와 참조 무결성

외래키는 자식 테이블의 값이 실제 부모 행을 참조하도록 보장합니다.

```sql
member_id INTEGER NOT NULL
    REFERENCES public.members_nf(id)

book_id INTEGER NOT NULL
    REFERENCES public.books_nf(id)
```

다음 대여 기록은 저장할 수 없습니다.

```sql
INSERT INTO public.loans_nf (
    id, member_id, book_id,
    borrowed_at, due_at, returned_at
)
VALUES (
    1999, 999, 201,
    '2026-04-10', '2026-04-24', NULL
);
```

`public.members_nf.id = 999`인 회원이 존재하지 않기 때문입니다.

```text
자식 행은 존재하는 부모 행만 참조한다.
부모 행을 삭제하거나 키를 바꿀 때 자식 관계를 고려한다.
외래키 열의 데이터 타입은 참조하는 키와 호환되어야 한다.
```

Chapter 05에서는 외래키의 위치를 설계했고, 이 장에서는 오류 입력으로 DBMS가 잘못된 관계를 차단하는지 확인합니다.

---

## 15. 한 도서의 활성 대여를 한 건으로 제한하기

C-08 규칙은 같은 `book_id`의 미반납 행이 두 건 이상 존재하지 못하게 합니다. 이 규칙은 모든 행에 적용되는 일반 `UNIQUE`가 아니라 `returned_at IS NULL`인 행에만 적용되어야 합니다.

PostgreSQL에서는 부분 고유 인덱스로 표현할 수 있습니다.

```sql
CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;
```

```text
반납된 과거 대여 여러 건
→ 허용

같은 도서의 미반납 대여 두 건
→ 두 번째 입력 차단
```

이 인덱스는 현재 미반납 상태의 중복을 막습니다. 이미 반납된 두 대여의 날짜 구간이 과거에 겹쳤는지까지 검사하지는 않습니다. 전체 기간 중첩 검사는 더 고급 모델과 트랜잭션 설계가 필요합니다.

---

## 16. 삭제 정책과 CASCADE 주의점

부모 행을 다른 테이블이 참조하고 있을 때 어떤 삭제를 허용할지 결정해야 합니다.

| 정책 | 의미 | 주의점 |
| --- | --- | --- |
| `RESTRICT` | 참조하는 자식 행이 있으면 즉시 부모 삭제 거부 | 이력 삭제를 막기 쉬움 |
| `NO ACTION` | 제약조건 검사 시점에 위반이면 거부 | 기본 즉시 검사에서는 `RESTRICT`와 비슷하게 보일 수 있음 |
| `CASCADE` | 부모 삭제 시 자식 행도 함께 삭제 | 예상보다 많은 데이터가 삭제될 수 있음 |
| `SET NULL` | 부모 삭제 시 외래키를 `NULL`로 변경 | 외래키가 `NULL`을 허용하고 의미가 맞아야 함 |

`NO ACTION`은 지연 가능한 외래키에서 검사 시점을 늦출 수 있지만 `RESTRICT`는 삭제를 즉시 거부합니다. 이 장의 실습에서는 대여 이력 보호를 위해 명시적으로 `ON DELETE RESTRICT`를 사용합니다.

```sql
member_id INTEGER NOT NULL
    REFERENCES public.members_nf(id)
    ON DELETE RESTRICT
```

> `ON DELETE CASCADE`는 편리한 정리 옵션이 아니라, 부모 삭제가 자식 삭제를 의미한다는 업무 규칙을 데이터베이스에 선언하는 기능입니다.

요구사항 근거 없이 AI가 `CASCADE`를 추가했다면 그대로 적용하지 않습니다.

---

## 17. PostgreSQL 실습 구조 만들기

Chapter 06 실습은 다음 파일로 나눕니다.

```text
code/chapter06/
├── normalization_schema.sql
├── normalization_seed.sql
├── normalization_practice.sql
├── integrity_tests.sql
├── reset_normalization.sql
└── README.md
```

실행 순서는 다음과 같습니다.

```text
normalization_schema.sql
→ normalization_seed.sql
→ normalization_practice.sql
→ integrity_tests.sql에서 한 테스트씩 선택 실행
```

실행 전에 현재 위치를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

핵심 구조는 다음과 같습니다.

```sql
CREATE TABLE public.members_nf (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    joined_at DATE NOT NULL,
    CONSTRAINT uq_members_nf_email UNIQUE (email),
    CONSTRAINT chk_members_nf_name_not_blank
        CHECK (char_length(trim(name)) > 0)
);

CREATE TABLE public.books_nf (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INTEGER,
    isbn VARCHAR(20) NOT NULL,
    CONSTRAINT uq_books_nf_isbn UNIQUE (isbn),
    CONSTRAINT chk_books_nf_title_not_blank
        CHECK (char_length(trim(title)) > 0)
);

CREATE TABLE public.loans_nf (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    member_id INTEGER NOT NULL
        REFERENCES public.members_nf(id)
        ON DELETE RESTRICT,
    book_id INTEGER NOT NULL
        REFERENCES public.books_nf(id)
        ON DELETE RESTRICT,
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE,
    CONSTRAINT chk_loans_nf_due_date
        CHECK (due_at >= borrowed_at),
    CONSTRAINT chk_loans_nf_returned_date
        CHECK (returned_at IS NULL OR returned_at >= borrowed_at)
);

CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;
```

요구사항 근거가 없던 `published_year >= 1000` 제약조건은 사용하지 않습니다. 출판연도의 허용 범위가 필요하면 정책을 먼저 확정한 뒤 추가합니다.

`normalization_schema.sql`은 기존 테이블을 자동으로 삭제하지 않습니다. 처음부터 다시 시작할 때만 보호 구문이 있는 `reset_normalization.sql`을 사용합니다.

> **자동 커밋 주의**
>
> 자동 커밋 상태에서는 일부 테이블이나 일부 샘플 데이터만 반영된 뒤 뒤 문장에서 오류가 날 수 있습니다. 실행 후 `normalization_practice.sql`로 행 수와 관계를 검증합니다.

---

## 18. 정상 샘플과 IDENTITY 시작값 맞추기

정상 샘플은 다음 상태를 만듭니다.

```text
회원 101, 102
도서 201, 202
대여 1001~1003
미반납 2건
도서 201의 첫 대여는 4월 2일 반납 후 4월 3일 다시 시작
```

```sql
INSERT INTO public.loans_nf (
    id, member_id, book_id,
    borrowed_at, due_at, returned_at
)
VALUES
    (1001, 101, 201, '2026-04-01', '2026-04-15', '2026-04-02'),
    (1002, 101, 202, '2026-04-02', '2026-04-16', NULL),
    (1003, 102, 201, '2026-04-03', '2026-04-17', NULL);
```

명시적인 ID는 관계를 재현하기 쉽지만 IDENTITY의 다음 값을 자동으로 변경하지 않습니다. 샘플 입력 뒤 다음 자동값을 조정합니다.

```sql
ALTER TABLE public.library_records_raw
    ALTER COLUMN loan_id RESTART WITH 1004;

ALTER TABLE public.members_nf
    ALTER COLUMN id RESTART WITH 103;

ALTER TABLE public.books_nf
    ALTER COLUMN id RESTART WITH 203;

ALTER TABLE public.loans_nf
    ALTER COLUMN id RESTART WITH 1004;
```

---

## 19. 정상·경계·오류 데이터로 검증하기

제약조건은 선언만 읽는 것보다 실제 데이터를 넣어 보는 것이 중요합니다.

### 정상 데이터

```text
정상 회원·도서·대여가 저장된다.
회원 101과 도서 201의 1:N 이력이 표현된다.
반납된 도서 201을 다음 날 다시 대여할 수 있다.
```

### 허용되어야 하는 경계값

```text
due_at = borrowed_at
returned_at = borrowed_at
returned_at = NULL
published_year = NULL
공백이 아닌 한 글자 이름
```

### 실패해야 하는 오류값

| 테스트 | 기대 결과 |
| --- | --- |
| 이름에 `NULL` 입력 | `NOT NULL` 오류 |
| 중복 이메일 입력 | `UNIQUE` 오류 |
| 공백뿐인 이름 입력 | `CHECK` 오류 |
| 존재하지 않는 회원 참조 | `FOREIGN KEY` 오류 |
| 대여일보다 빠른 반납예정일 | `CHECK` 오류 |
| 대여일보다 빠른 실제반납일 | `CHECK` 오류 |
| 같은 도서의 두 번째 미반납 대여 | 부분 고유 인덱스 오류 |
| 참조 중인 회원 삭제 | `RESTRICT` 또는 외래키 오류 |

`integrity_tests.sql`의 실패 SQL은 모두 주석 처리합니다. 한 테스트씩 주석을 해제해 실행합니다.

> **오류 후 트랜잭션 상태**
>
> 오류 테스트는 자동 커밋 상태에서 한 문장씩 실행하는 것이 가장 단순합니다. 수동 커밋 상태나 명시적 트랜잭션 안에서 오류 후 `current transaction is aborted` 메시지가 나타나면 다음 문장을 실행하기 전에 `ROLLBACK;`으로 실패한 트랜잭션을 종료합니다. 트랜잭션의 상세 원리는 Chapter 09에서 다룹니다.

검증할 때는 다음을 기록합니다.

```text
어떤 규칙 ID를 위반했는가?
어떤 제약조건이나 인덱스가 차단했는가?
오류 후 기존 데이터는 그대로인가?
허용되어야 하는 경계값은 성공했는가?
요구사항과 구현이 일치하는가?
```

오류 메시지를 없애기 위해 제약조건을 무조건 제거해서는 안 됩니다. 먼저 입력 데이터가 잘못된 것인지, 제약조건이 요구사항을 잘못 표현한 것인지 구분합니다.

---

## 20. 정규화 전후의 저장과 조회

정규화 전에는 하나의 테이블만 조회하면 되므로 단순해 보일 수 있습니다. 하지만 회원과 도서 정보가 반복됩니다.

정규화 후에는 사실을 각 주인 테이블에 저장하고 필요한 결과는 관계를 따라 조회합니다.

![정규화된 저장과 JOIN 조회](../../images/chapter06/ch06_07_before_after_join_tradeoff.svg)

그림 6-7 정규화된 저장과 JOIN 조회

```text
저장
public.members_nf + public.books_nf + public.loans_nf

조회 결과
회원 이름 + 책 제목 + 대여일
```

`normalization_practice.sql`에는 구조 연결을 확인하기 위한 최소 JOIN이 포함됩니다. JOIN 문법과 다양한 결합 방식은 Chapter 08에서 자세히 다룹니다.

JOIN은 분리된 데이터를 다시 영구적으로 중복 저장하는 작업이 아닙니다. 조회 시점에 PK·FK 관계를 따라 필요한 결과 집합을 만듭니다.

---

## 21. 정규화와 과도한 분리 구분하기

정규화는 테이블 수를 최대한 늘리는 작업이 아닙니다.

```text
member_names(id, name)
member_emails(id, email)
member_join_dates(id, joined_at)
```

이름, 이메일과 가입일은 모두 회원을 설명하고 함께 생성·변경·관리되는 기본 속성입니다. 분리할 독립적인 수명, 권한, 반복 관계나 업무 규칙이 없다면 `members_nf`에 함께 둘 수 있습니다.

```text
서로 다른 사실을 표현하는가?
값의 수명과 변경 이유가 다른가?
독립적으로 여러 건이 발생하는가?
별도 보안·보존·책임 경계가 필요한가?
분리 후 무결성과 업무 의미가 더 분명해지는가?
```

정규화된 구조에 JOIN이 있다는 이유만으로 다시 합치지 않습니다. 성능 문제는 실제 데이터, 조회 패턴과 실행 계획을 측정한 뒤 Chapter 10에서 검토합니다.

---

## 22. AI가 만든 구조와 제약조건 검토하기

AI는 빠르게 테이블과 SQL 초안을 만들 수 있지만 다음과 같은 오류를 만들 수 있습니다.

```text
회원·책·대여 정보를 한 테이블에 혼합
기본키 누락
미확정 정책을 UNIQUE로 임의 확정
필수값에 NOT NULL 누락
날짜 순서를 검증하는 CHECK 누락
존재하지 않는 부모를 허용하는 FK 누락
동일 도서의 활성 대여 중복 차단 누락
근거 없는 ON DELETE CASCADE 추가
모든 속성을 불필요하게 별도 테이블로 분리
```

![AI 생성 테이블 구조 정규화 검토](../../images/chapter06/ch06_08_ai_normalization_review_flow.svg)

그림 6-8 AI 생성 테이블 구조와 무결성 검토 흐름

| 검토 항목 | 확인 질문 |
| --- | --- |
| 요구사항 근거 | 확정 규칙 ID와 연결되는가? |
| 행의 의미 | 한 행이 하나의 분명한 사실을 나타내는가? |
| 컬럼의 주인 | 각 컬럼이 적절한 테이블에 있는가? |
| 중복과 이상 | 독립 INSERT, 한 곳 UPDATE, 안전한 DELETE가 가능한가? |
| 함수적 종속 | 결정 관계가 업무 규칙과 일치하는가? |
| 정규형 | 1NF·2NF·3NF 위반이 있는가? |
| 기본키 | 각 행을 안정적으로 식별하는가? |
| 필수·고유값 | `NOT NULL`, `UNIQUE`가 확정 정책과 일치하는가? |
| 값 범위 | 필요한 `CHECK`가 있는가? |
| 여러 행 규칙 | 제약조건이나 부분 고유 인덱스가 필요한가? |
| 참조 무결성 | 외래키와 참조 대상이 정확한가? |
| 삭제 정책 | `CASCADE`, `RESTRICT`, `SET NULL`에 업무 근거가 있는가? |
| 실행 검증 | 정상·경계·오류 데이터로 실제 동작을 확인했는가? |

AI에게 다음처럼 요청할 수 있습니다.

```text
테이블 구조를 정규화와 데이터 무결성 관점에서 검토해 주세요.
각 수정 제안에 요구사항 또는 확정 규칙 ID를 적어 주세요.
PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, 부분 고유 인덱스와 삭제 정책을 구분해 주세요.
요구사항에 없는 CASCADE나 제약조건을 임의로 추가하지 마세요.
정상 데이터, 허용되어야 하는 경계 데이터와 실패해야 하는 오류 테스트를 제안해 주세요.
```

AI 결과는 실제 PostgreSQL 실행과 오류 메시지로 다시 검증합니다.

---

## 23. 직접 해보기: 주문 테이블 개선하기

```text
orders_raw(
    order_id,
    customer_name,
    customer_email,
    product_name,
    current_product_price,
    order_date,
    quantity
)
```

먼저 컬럼의 주인을 찾습니다.

```text
고객 정보
상품의 현재 정보
주문 정보
주문 상품 정보
```

가능한 구조는 다음과 같습니다.

```text
customers(id, name, email)
products(id, name, current_price)
orders(id, customer_id, order_date)
order_items(id, order_id, product_id, quantity, unit_price)
```

`order_items.unit_price`는 단순한 중복이 아닐 수 있습니다. 주문 당시 가격을 보존하는 이력 값이라면 현재 상품 가격과 의미가 다릅니다.

제약조건은 정책이 확정된 뒤 적용합니다.

```text
customers.email
- NOT NULL 후보
- UNIQUE 후보
- 중복과 대소문자 처리 정책 확인 필요

order_items.quantity
- 수량은 1 이상이라고 확정되면 CHECK (quantity > 0)

order_items.unit_price
- 가격은 음수가 될 수 없다고 확정되면 CHECK (unit_price >= 0)

orders.customer_id
- FOREIGN KEY + NOT NULL 후보
```

정규화는 반복되는 값을 무조건 제거하는 것이 아니라 **현재 사실과 사건 당시 사실을 구분하는 작업**이기도 합니다.

---

## 24. 자주 하는 실수

1. 컬럼 수가 많으면 무조건 테이블을 나눈다. 컬럼 개수보다 한 행의 의미와 컬럼의 주인을 확인합니다.
2. 값이 반복되면 모두 제거해야 한다고 생각한다. 외래키와 이력 값처럼 의미 있는 반복이 있습니다.
3. 제1정규형만 만족하면 좋은 설계라고 생각한다. 부분 종속과 일반 컬럼 간 종속이 남을 수 있습니다.
4. 샘플 데이터의 우연한 반복을 함수적 종속으로 단정한다. 업무 규칙이 근거여야 합니다.
5. 정규화하면 제약조건이 필요 없다고 생각한다. 정규화와 무결성은 역할이 다릅니다.
6. 후보 정책을 확인하지 않고 `UNIQUE`나 `CASCADE`를 추가한다. 확정 규칙이 먼저입니다.
7. 오류가 발생하면 제약조건부터 제거한다. 데이터 오류인지 규칙 오류인지 먼저 구분합니다.
8. 명시적 ID를 넣고 IDENTITY의 다음 값도 자동으로 바뀐다고 생각한다. 시작값을 별도로 조정해야 합니다.
9. 오류 후 실패한 트랜잭션 상태를 그대로 둔다. 필요하면 `ROLLBACK` 후 다음 테스트를 실행합니다.
10. AI가 만든 DDL을 실행 성공만으로 승인한다. 정상·경계·오류 결과를 함께 확인합니다.

---

## 25. 스스로 확인하기

1. 같은 값이 반복되는 것과 같은 사실의 복사본이 반복되는 것은 어떻게 다른가요?
2. 삽입·수정·삭제 이상을 도서 대여 사례로 설명해 보세요.
3. `X → Y`는 어떤 의미인가요?
4. 제1정규형에서 쉼표 목록과 반복 열을 피하는 이유는 무엇인가요?
5. 제2정규형이 복합키에서 특히 중요한 이유는 무엇인가요?
6. 제3정규형에서 업무 규칙을 먼저 확인해야 하는 이유는 무엇인가요?
7. 정규화와 무결성 제약조건의 역할은 어떻게 다른가요?
8. `NOT NULL`, `UNIQUE`, `CHECK`는 각각 어떤 오류를 차단하나요?
9. 외래키가 참조 무결성을 지키는 방법을 설명해 보세요.
10. 부분 고유 인덱스가 일반 `UNIQUE`와 다른 점은 무엇인가요?
11. `ON DELETE CASCADE`를 요구사항 근거 없이 사용하면 안 되는 이유는 무엇인가요?
12. 정상 데이터뿐 아니라 경계값과 실패해야 하는 오류값을 테스트해야 하는 이유는 무엇인가요?
13. 명시적 ID 입력 뒤 IDENTITY 시작값을 조정하는 이유는 무엇인가요?
14. 오류 후 `current transaction is aborted`가 나타날 때 무엇을 해야 하나요?
15. 주문 당시 가격이 현재 상품 가격과 별도로 저장될 수 있는 이유는 무엇인가요?

실행 결과와 오류 메시지를 표로 기록하려면 `book/chapter06/chapter06_activity.md`의 독자 워크북을 사용합니다.

---

## 26. 권장 해설

### 정규화와 이상 현상

- 위험한 중복은 같은 현재 사실의 복사본을 여러 위치에서 따로 관리하는 것입니다.
- 삽입 이상은 독립 정보를 따로 저장할 수 없는 문제입니다.
- 수정 이상은 같은 사실을 여러 행에서 바꾸어야 하는 문제입니다.
- 삭제 이상은 사건 행을 지울 때 보존해야 할 대상 정보까지 사라지는 문제입니다.

### 정규형

- 1NF는 한 셀에 여러 독립 값을 넣거나 반복 열을 만드는 구조를 피합니다.
- 2NF는 복합키 일부에만 의존하는 컬럼을 주인 테이블로 옮깁니다.
- 3NF는 일반 컬럼이 다른 일반 컬럼을 결정하는 업무 규칙을 확인합니다.

### 제약조건

| 문제 | 구현 후보 |
| --- | --- |
| 행 중복 | `PRIMARY KEY` |
| 필수값 누락 | `NOT NULL` |
| 확정된 고유값 중복 | `UNIQUE` |
| 한 행 안의 값 범위·순서 | `CHECK` |
| 존재하지 않는 부모 참조 | `FOREIGN KEY` |
| 미반납 도서 중복 | 부분 고유 인덱스 |
| 참조 중 부모 삭제 | `RESTRICT` |

### 동시 활성 대여

```sql
CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;
```

같은 책의 반납된 과거 이력은 여러 건 허용하지만 미반납 행은 한 건만 허용합니다.

### 오류 후 상태

자동 커밋에서는 실패한 문장만 거부되는 것이 일반적입니다. 수동 커밋이나 트랜잭션 안에서 오류 후 트랜잭션이 실패 상태가 되면 `ROLLBACK;`으로 종료한 뒤 다음 테스트를 실행합니다.

### 주문 당시 가격

`products.current_price`는 현재 판매 가격이고 `order_items.unit_price`는 주문이 성립한 시점의 가격입니다. 의미와 변경 시점이 다르므로 둘 다 저장할 수 있습니다.

---

## 27. 핵심 정리

### 정규화 검토

| 검토 항목 | 핵심 질문 |
| --- | --- |
| 행의 의미 | 한 행은 하나의 분명한 사실을 나타내는가? |
| 컬럼의 주인 | 각 값은 어느 대상이나 사건에 속하는가? |
| 삽입 이상 | 독립적인 정보를 따로 추가할 수 있는가? |
| 수정 이상 | 같은 사실을 한 곳에서 수정할 수 있는가? |
| 삭제 이상 | 한 사건을 지워도 다른 정보가 보존되는가? |
| 제1정규형 | 한 셀에 여러 독립 값이 있는가? |
| 제2정규형 | 복합키 일부가 결정하는 컬럼이 있는가? |
| 제3정규형 | 일반 컬럼이 다른 일반 컬럼을 결정하는가? |
| 과도한 분리 | 분리할 업무 근거가 있는가? |

### 무결성 검토

| 구현 | 보호하는 내용 |
| --- | --- |
| `PRIMARY KEY` | 행 식별과 중복 방지 |
| `FOREIGN KEY` | 존재하는 부모 행과의 관계 |
| `NOT NULL` | 필수값 누락 방지 |
| `UNIQUE` | 확정된 업무상 고유값 중복 방지 |
| `CHECK` | 한 행 내부의 값 범위와 순서 |
| 부분 고유 인덱스 | 조건을 만족하는 행만 고유성 적용 |
| 삭제 정책 | 부모 삭제 시 자식 관계 처리 |

이 장에서 가장 중요한 문장은 다음입니다.

```text
좋은 테이블 설계는 한 사실을 가능한 한 한 곳에서 관리하고,
확정된 업무 규칙을 제약조건과 검증 데이터로 확인하는 것이다.
```

---

## 28. 다음 장에서는

Chapter 07에서는 Chapter 01~06에서 배운 내용을 하나의 온라인 강의 수강신청 프로젝트에 적용합니다.

```text
요구사항 작성
→ 확정·미확정 규칙 구분
→ 엔터티·관계와 ERD 설계
→ 정규화 검토
→ PK·FK·NOT NULL·UNIQUE·CHECK 적용
→ 정상·경계·오류 데이터 검증
→ AI 제안과 사람의 수정 내용 기록
```

Chapter 06의 규칙 ID, 정상·경계·오류 데이터 검증 방식은 프로젝트 데이터베이스의 품질을 확인하는 기준으로 사용합니다.
