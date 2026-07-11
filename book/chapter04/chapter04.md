# Chapter 04. 관계형 데이터베이스와 SQL 기초

> 상태: 출간용 문체 1차 정리 완료

---

## 이 장에서 다룰 내용

이 장에서는 PostgreSQL에서 가장 기본이 되는 SQL을 직접 실행하며 확인합니다.

Chapter 02에서는 테이블, 행, 열, 기본키, 외래키, 제약조건을 살펴보았고, Chapter 03에서는 PostgreSQL과 DBeaver 실습 환경을 구축했습니다. 이제부터는 실제 SQL을 작성해 데이터를 생성하고, 조회하고, 수정하고, 삭제하는 기본 흐름을 익혀 봅니다.

이 장에서 다룰 내용은 다음과 같습니다.

- 관계형 데이터베이스의 기본 구조
- SQL의 기본 역할
- `SELECT`로 데이터 조회하기
- `WHERE`로 조건 지정하기
- `ORDER BY`로 정렬하기
- `INSERT`로 데이터 추가하기
- `UPDATE`로 데이터 수정하기
- `DELETE`로 데이터 삭제하기
- CRUD 흐름 이해하기
- AI가 만든 SQL을 검토하는 방법

이 장의 목표는 SQL 문법을 많이 외우는 것이 아닙니다. SQL이 테이블의 데이터를 어떻게 읽고 바꾸는지 직접 확인하고, AI가 만든 SQL을 사람이 검토할 수 있는 기준을 갖추는 것입니다.

---

## 1. 왜 SQL 기초를 배워야 하는가

SQL은 데이터베이스와 대화하는 언어입니다.

데이터베이스 안에는 테이블이 있고, 테이블 안에는 행과 열이 있습니다. SQL은 이 테이블에 명령을 내립니다.

예를 들어 다음 SQL은 students 테이블의 모든 데이터를 조회합니다.

```sql
SELECT *
FROM students;
```

이 문장은 짧지만 다음 의미를 담고 있습니다.

```text
students 테이블에서 모든 컬럼과 모든 행을 조회하라.
```

AI 시대에는 ChatGPT나 Codex가 SQL을 대신 작성해 줄 수 있습니다. 하지만 다음을 이해하지 못하면 위험합니다.

```text
- 어떤 테이블을 조회하는가?
- 어떤 행만 가져오는가?
- 어떤 컬럼이 수정되는가?
- 삭제되는 데이터는 무엇인가?
- 조건이 빠져 전체 데이터가 바뀌지는 않는가?
```

특히 `UPDATE`와 `DELETE`는 조심해야 합니다. 조건 없이 실행하면 많은 데이터가 한 번에 바뀌거나 삭제될 수 있습니다.

따라서 SQL 기초의 핵심은 다음입니다.

```text
SQL을 실행하기 전에, 어떤 데이터가 영향을 받는지 설명할 수 있어야 한다.
```

---

## 2. 관계형 데이터베이스 다시 보기

관계형 데이터베이스는 데이터를 테이블 형태로 저장합니다.

테이블은 행과 열로 구성됩니다.

| id | name | email | major |
| ---: | --- | --- | --- |
| 1 | 김민지 | minji@example.com | 컴퓨터공학 |
| 2 | 이준호 | junho@example.com | 데이터사이언스 |
| 3 | 박서연 | seoyeon@example.com | 경영학 |

이 예제에서 개념을 다시 정리하면 다음과 같습니다.

| 개념 | 예시 |
| --- | --- |
| 테이블 | students |
| 행 | 김민지 학생 정보 한 줄 |
| 열 | id, name, email, major |
| 기본키 | id |
| 데이터 타입 | VARCHAR, INT, TIMESTAMP 등 |
| 제약조건 | PRIMARY KEY, NOT NULL, UNIQUE 등 |

SQL은 이 테이블을 대상으로 동작합니다.

---

## 3. 이 장의 실습 준비

이 장의 실습은 Chapter 03에서 만든 PostgreSQL 환경을 기준으로 진행합니다.

필요한 준비는 다음과 같습니다.

```text
1. PostgreSQL이 실행 중이다.
2. DBeaver에서 ai_database_book 데이터베이스에 연결했다.
3. SQL Editor를 열 수 있다.
4. code/chapter04/basic_crud.sql 파일을 사용할 수 있다.
```

이번 장에서는 students 테이블을 중심으로 SQL을 연습합니다.

먼저 기존 테이블이 있다면 삭제하고 다시 만들 수 있습니다. 반복 실습을 위해 다음 SQL을 사용합니다.

```sql
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    major VARCHAR(100),
    grade INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

`DROP TABLE IF EXISTS students;`는 students 테이블이 이미 있으면 삭제하고, 없으면 그냥 넘어갑니다. 실습을 처음부터 다시 시작할 때 유용합니다.

다만 실제 서비스에서는 함부로 테이블을 삭제하면 안 됩니다. 이 SQL은 실습용으로만 사용합니다.

---

## 4. SQL의 기본 분류

SQL은 역할에 따라 여러 종류로 나눌 수 있습니다.

| 분류 | 의미 | 대표 명령어 |
| --- | --- | --- |
| DDL | 테이블과 구조를 정의 | `CREATE`, `ALTER`, `DROP` |
| DML | 데이터를 추가, 조회, 수정, 삭제 | `INSERT`, `SELECT`, `UPDATE`, `DELETE` |
| DCL | 권한을 제어 | `GRANT`, `REVOKE` |
| TCL | 트랜잭션을 제어 | `COMMIT`, `ROLLBACK` |

이 장에서는 주로 DML을 다룹니다. 즉 데이터를 직접 다루는 명령어입니다.

```text
INSERT → 데이터 추가
SELECT → 데이터 조회
UPDATE → 데이터 수정
DELETE → 데이터 삭제
```

이 네 가지를 합쳐 CRUD라고 부릅니다.

![SQL 명령어와 CRUD 흐름](../../images/chapter04/ch04_01_sql_crud_overview.svg)

그림 4-1 SQL 명령어와 CRUD 흐름

---

## 5. SELECT: 데이터 조회하기

`SELECT`는 테이블에서 데이터를 조회하는 명령어입니다.

가장 기본 형태는 다음과 같습니다.

```sql
SELECT 컬럼명
FROM 테이블명;
```

모든 컬럼을 조회하려면 `*`를 사용할 수 있습니다.

```sql
SELECT *
FROM students;
```

`*`는 모든 컬럼을 의미합니다. 초급 실습에서는 편리하지만, 실무에서는 필요한 컬럼만 명시하는 것이 좋습니다.

예를 들어 이름과 전공만 조회하려면 다음처럼 작성합니다.

```sql
SELECT name, major
FROM students;
```

이 SQL은 students 테이블에서 `name`과 `major` 컬럼만 가져옵니다.

![SELECT와 컬럼 선택 흐름](../../images/chapter04/ch04_02_select_projection_flow.svg)

그림 4-2 SELECT와 컬럼 선택 흐름

### SELECT 결과 읽기

다음 데이터가 있다고 가정해 보겠습니다.

| id | name | email | major | grade |
| ---: | --- | --- | --- | ---: |
| 1 | 김민지 | minji@example.com | 컴퓨터공학 | 2 |
| 2 | 이준호 | junho@example.com | 데이터사이언스 | 3 |
| 3 | 박서연 | seoyeon@example.com | 경영학 | 1 |

다음 SQL을 실행하면:

```sql
SELECT name, major
FROM students;
```

결과는 다음처럼 나옵니다.

| name | major |
| --- | --- |
| 김민지 | 컴퓨터공학 |
| 이준호 | 데이터사이언스 |
| 박서연 | 경영학 |

즉 `SELECT`는 테이블에서 원하는 열을 선택하는 명령입니다.

---

## 6. INSERT: 데이터 추가하기

`INSERT`는 테이블에 새 행을 추가하는 명령어입니다.

기본 형태는 다음과 같습니다.

```sql
INSERT INTO 테이블명 (컬럼1, 컬럼2, 컬럼3)
VALUES (값1, 값2, 값3);
```

students 테이블에 학생 한 명을 추가해 보겠습니다.

```sql
INSERT INTO students (name, email, major, grade)
VALUES ('김민지', 'minji@example.com', '컴퓨터공학', 2);
```

여러 행을 한 번에 추가할 수도 있습니다.

```sql
INSERT INTO students (name, email, major, grade)
VALUES
    ('이준호', 'junho@example.com', '데이터사이언스', 3),
    ('박서연', 'seoyeon@example.com', '경영학', 1),
    ('최현우', 'hyunwoo@example.com', '컴퓨터공학', 4);
```

입력 후에는 반드시 조회해서 확인합니다.

```sql
SELECT *
FROM students;
```

![INSERT로 새 행 추가하기](../../images/chapter04/ch04_03_insert_row_flow.svg)

그림 4-3 INSERT로 새 행 추가하기

### INSERT에서 자주 하는 실수

첫 번째 실수는 컬럼 수와 값의 수가 맞지 않는 경우입니다.

```sql
INSERT INTO students (name, email, major)
VALUES ('홍길동', 'hong@example.com');
```

컬럼은 3개인데 값은 2개입니다. 이 경우 오류가 발생합니다.

두 번째 실수는 문자열에 작은따옴표를 사용하지 않는 경우입니다.

```sql
INSERT INTO students (name, email)
VALUES (홍길동, hong@example.com);
```

문자열 값은 작은따옴표로 감싸야 합니다.

```sql
INSERT INTO students (name, email)
VALUES ('홍길동', 'hong@example.com');
```

---

## 7. WHERE: 조건 지정하기

`WHERE`는 특정 조건을 만족하는 행만 선택할 때 사용합니다.

기본 형태는 다음과 같습니다.

```sql
SELECT 컬럼명
FROM 테이블명
WHERE 조건;
```

예를 들어 전공이 컴퓨터공학인 학생만 조회하려면 다음처럼 작성합니다.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학';
```

![WHERE 조건으로 행 필터링](../../images/chapter04/ch04_04_where_filter_flow.svg)

그림 4-4 WHERE 조건으로 행 필터링

학년이 3학년 이상인 학생을 조회할 수도 있습니다.

```sql
SELECT *
FROM students
WHERE grade >= 3;
```

조건에는 비교 연산자를 사용할 수 있습니다.

| 연산자 | 의미 | 예시 |
| --- | --- | --- |
| `=` | 같다 | `major = '컴퓨터공학'` |
| `<>` | 같지 않다 | `major <> '경영학'` |
| `>` | 크다 | `grade > 2` |
| `>=` | 크거나 같다 | `grade >= 3` |
| `<` | 작다 | `grade < 3` |
| `<=` | 작거나 같다 | `grade <= 2` |

### AND와 OR

조건을 여러 개 연결할 수 있습니다.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학'
  AND grade >= 3;
```

이 SQL은 전공이 컴퓨터공학이고 학년이 3학년 이상인 학생만 조회합니다.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학'
   OR major = '데이터사이언스';
```

이 SQL은 전공이 컴퓨터공학이거나 데이터사이언스인 학생을 조회합니다.

---

## 8. ORDER BY: 정렬하기

`ORDER BY`는 조회 결과를 정렬할 때 사용합니다.

기본 형태는 다음과 같습니다.

```sql
SELECT 컬럼명
FROM 테이블명
ORDER BY 정렬기준;
```

학년 오름차순으로 정렬하려면 다음처럼 작성합니다.

```sql
SELECT *
FROM students
ORDER BY grade ASC;
```

`ASC`는 오름차순입니다. 작은 값에서 큰 값으로 정렬됩니다.

내림차순은 `DESC`를 사용합니다.

```sql
SELECT *
FROM students
ORDER BY grade DESC;
```

![ORDER BY 정렬 흐름](../../images/chapter04/ch04_05_order_by_sort_flow.svg)

그림 4-5 ORDER BY 정렬 흐름

이름순으로 정렬할 수도 있습니다.

```sql
SELECT *
FROM students
ORDER BY name ASC;
```

### WHERE와 ORDER BY 함께 사용하기

조건으로 먼저 행을 고르고, 그 결과를 정렬할 수 있습니다.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학'
ORDER BY grade DESC;
```

이 SQL은 전공이 컴퓨터공학인 학생만 조회한 뒤, 학년이 높은 순서로 정렬합니다.

---

## 9. UPDATE: 데이터 수정하기

`UPDATE`는 기존 데이터를 수정하는 명령어입니다.

기본 형태는 다음과 같습니다.

```sql
UPDATE 테이블명
SET 컬럼명 = 새값
WHERE 조건;
```

예를 들어 김민지 학생의 학년을 3으로 수정하려면 다음처럼 작성합니다.

```sql
UPDATE students
SET grade = 3
WHERE email = 'minji@example.com';
```

수정 후에는 반드시 조회해서 확인합니다.

```sql
SELECT *
FROM students
WHERE email = 'minji@example.com';
```

![안전한 UPDATE 실행 절차](../../images/chapter04/ch04_06_update_safe_flow.svg)

그림 4-6 안전한 UPDATE 실행 절차

### UPDATE에서 가장 중요한 점

`UPDATE`에서는 `WHERE`가 매우 중요합니다.

다음 SQL은 위험합니다.

```sql
UPDATE students
SET grade = 1;
```

이 SQL은 students 테이블의 모든 학생 학년을 1로 바꿉니다. 실습에서는 되돌릴 수 있지만, 실제 서비스에서는 큰 사고가 될 수 있습니다.

따라서 `UPDATE`를 실행하기 전에는 먼저 같은 조건으로 `SELECT`를 실행해 확인하는 습관이 필요합니다.

```sql
SELECT *
FROM students
WHERE email = 'minji@example.com';
```

조회 결과가 맞다면 그 다음 `UPDATE`를 실행합니다.

---

## 10. DELETE: 데이터 삭제하기

`DELETE`는 테이블에서 행을 삭제하는 명령어입니다.

기본 형태는 다음과 같습니다.

```sql
DELETE FROM 테이블명
WHERE 조건;
```

예를 들어 특정 이메일을 가진 학생을 삭제하려면 다음처럼 작성합니다.

```sql
DELETE FROM students
WHERE email = 'hyunwoo@example.com';
```

삭제 후에는 다시 조회합니다.

```sql
SELECT *
FROM students;
```

![안전한 DELETE 실행 절차](../../images/chapter04/ch04_07_delete_safe_flow.svg)

그림 4-7 안전한 DELETE 실행 절차

### DELETE에서 가장 중요한 점

`DELETE`도 `WHERE`가 매우 중요합니다.

다음 SQL은 매우 위험합니다.

```sql
DELETE FROM students;
```

이 SQL은 students 테이블의 모든 행을 삭제합니다.

따라서 삭제 전에는 반드시 다음처럼 삭제 대상부터 확인합니다.

```sql
SELECT *
FROM students
WHERE email = 'hyunwoo@example.com';
```

확인한 결과가 맞을 때만 `DELETE`를 실행합니다.

---

## 11. CRUD 흐름으로 이해하기

지금까지 배운 SQL은 CRUD 흐름으로 정리할 수 있습니다.

| CRUD | SQL | 역할 | 예시 |
| --- | --- | --- | --- |
| Create | `INSERT` | 새 데이터 추가 | 학생 등록 |
| Read | `SELECT` | 데이터 조회 | 학생 목록 확인 |
| Update | `UPDATE` | 기존 데이터 수정 | 이메일 변경 |
| Delete | `DELETE` | 데이터 삭제 | 학생 삭제 |

웹 서비스의 대부분 기능은 CRUD로 설명할 수 있습니다.

예를 들어 학생 관리 시스템은 다음과 같습니다.

| 화면 기능 | SQL |
| --- | --- |
| 학생 등록 버튼 | `INSERT` |
| 학생 목록 화면 | `SELECT` |
| 학생 정보 수정 | `UPDATE` |
| 학생 삭제 | `DELETE` |

즉 SQL 기초를 배우는 것은 웹 서비스와 데이터 분석의 공통 기반을 배우는 것입니다.

---

## 12. SELECT를 먼저 실행하는 습관

초급자에게 가장 중요한 습관 중 하나는 수정이나 삭제 전에 먼저 조회하는 것입니다.

다음 순서를 기억하세요.

```text
1. SELECT로 대상 확인
2. UPDATE 또는 DELETE 실행
3. 다시 SELECT로 결과 확인
```

예를 들어 학년을 수정하려면 다음 순서가 좋습니다.

```sql
SELECT *
FROM students
WHERE email = 'junho@example.com';

UPDATE students
SET grade = 4
WHERE email = 'junho@example.com';

SELECT *
FROM students
WHERE email = 'junho@example.com';
```

삭제도 마찬가지입니다.

```sql
SELECT *
FROM students
WHERE email = 'seoyeon@example.com';

DELETE FROM students
WHERE email = 'seoyeon@example.com';

SELECT *
FROM students
WHERE email = 'seoyeon@example.com';
```

이 습관은 이후 트랜잭션과 백업을 배울 때도 중요합니다.

---

## 13. AI가 만든 SQL 검토하기

ChatGPT나 Codex에게 SQL을 요청하면 빠르게 답을 얻을 수 있습니다.

예를 들어 다음처럼 요청할 수 있습니다.

```text
students 테이블에서 전공이 컴퓨터공학인 학생만 조회하는 PostgreSQL SQL을 작성해 주세요.
```

AI는 다음과 비슷한 SQL을 만들 수 있습니다.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학';
```

이 SQL은 비교적 안전합니다. 조회만 하기 때문입니다.

하지만 다음 요청은 조심해야 합니다.

```text
students 테이블에서 1학년 학생을 삭제하는 SQL을 작성해 주세요.
```

AI는 다음과 같이 답할 수 있습니다.

```sql
DELETE FROM students
WHERE grade = 1;
```

이 SQL은 문법상 맞을 수 있지만, 실제로 실행해도 되는지는 별개의 문제입니다. 삭제 대상이 정확한지 먼저 확인해야 합니다.

```sql
SELECT *
FROM students
WHERE grade = 1;
```

![AI 생성 SQL 검토 흐름](../../images/chapter04/ch04_08_ai_sql_review_flow.svg)

그림 4-8 AI 생성 SQL 검토 흐름

AI가 만든 SQL을 검토할 때는 다음을 확인합니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 대상 테이블 | 올바른 테이블을 사용했는가? |
| 대상 컬럼 | 올바른 컬럼을 사용했는가? |
| 조건 | `WHERE` 조건이 있는가? 조건이 정확한가? |
| 영향 범위 | 몇 개의 행이 영향을 받을 수 있는가? |
| 실행 전 조회 | 수정/삭제 전 `SELECT`로 확인했는가? |
| PostgreSQL 문법 | PostgreSQL에서 실행 가능한 문법인가? |

---

## 14. 작은 실습: 안전한 수정과 삭제

다음 순서대로 실습해 보세요.

### 14.1 데이터 확인

```sql
SELECT *
FROM students;
```

### 14.2 수정 대상 확인

```sql
SELECT *
FROM students
WHERE email = 'junho@example.com';
```

### 14.3 데이터 수정

```sql
UPDATE students
SET major = 'AI데이터공학'
WHERE email = 'junho@example.com';
```

### 14.4 수정 결과 확인

```sql
SELECT *
FROM students
WHERE email = 'junho@example.com';
```

### 14.5 삭제 대상 확인

```sql
SELECT *
FROM students
WHERE email = 'seoyeon@example.com';
```

### 14.6 데이터 삭제

```sql
DELETE FROM students
WHERE email = 'seoyeon@example.com';
```

### 14.7 삭제 결과 확인

```sql
SELECT *
FROM students;
```

이 실습의 핵심은 `UPDATE`와 `DELETE` 자체가 아니라, 실행 전후에 `SELECT`로 확인하는 습관입니다.

---

## 15. 자주 하는 실수

### 실수 1. 문자열에 작은따옴표를 쓰지 않는다

문자열 값은 작은따옴표로 감싸야 합니다.

```sql
WHERE major = '컴퓨터공학'
```

### 실수 2. WHERE 없이 UPDATE를 실행한다

```sql
UPDATE students
SET grade = 1;
```

이 SQL은 모든 학생의 학년을 1로 바꿉니다.

### 실수 3. WHERE 없이 DELETE를 실행한다

```sql
DELETE FROM students;
```

이 SQL은 모든 학생 데이터를 삭제합니다.

### 실수 4. SELECT 결과를 확인하지 않고 수정한다

수정 전에는 반드시 같은 조건으로 조회해야 합니다.

### 실수 5. AI가 만든 SQL을 그대로 실행한다

AI가 만든 SQL은 초안입니다. 특히 `UPDATE`, `DELETE`는 실행 전 영향 범위를 반드시 확인해야 합니다.

---

## 16. 직접 해보기

다음 요구사항을 SQL로 작성해 보세요.

```text
1. students 테이블을 새로 만든다.
2. 학생 데이터 5건을 입력한다.
3. 전체 학생을 조회한다.
4. 전공이 컴퓨터공학인 학생만 조회한다.
5. 학년이 높은 순서로 학생을 정렬한다.
6. 특정 학생의 전공을 수정한다.
7. 수정 전후를 SELECT로 확인한다.
8. 특정 학생을 삭제한다.
9. 삭제 전후를 SELECT로 확인한다.
10. AI가 만든 SQL 하나를 검토하고, 수정한 내용을 설명한다.
```

실습 결과는 다음 형식으로 정리해 볼 수 있습니다.

```markdown
# Chapter 04 직접 해보기

## 1. 작성한 SQL

## 2. 실행 결과 요약

## 3. UPDATE 실행 전 확인한 SELECT

## 4. DELETE 실행 전 확인한 SELECT

## 5. AI가 만든 SQL 검토 결과

## 6. 느낀 점
```

---

## 17. 스스로 확인하기

### 17.1 개념 확인

1. [기초] `SELECT`의 역할을 설명해 보세요.
2. [기초] `INSERT`의 역할을 설명해 보세요.
3. [기초] `WHERE`가 필요한 이유를 설명해 보세요.
4. [기초] `ORDER BY ASC`와 `ORDER BY DESC`의 차이를 설명해 보세요.
5. [기초] CRUD와 SQL 명령어를 연결해 보세요.

### 17.2 SQL 작성 문제

1. [SQL] students 테이블의 모든 데이터를 조회하는 SQL을 작성해 보세요.
2. [SQL] students 테이블에서 name과 email만 조회하는 SQL을 작성해 보세요.
3. [SQL] 전공이 데이터사이언스인 학생만 조회하는 SQL을 작성해 보세요.
4. [SQL] 학년이 2 이상인 학생을 조회하는 SQL을 작성해 보세요.
5. [SQL] 학생을 학년 내림차순으로 정렬하는 SQL을 작성해 보세요.

### 17.3 위험 SQL 검토 문제

다음 SQL의 문제점을 설명하세요.

```sql
UPDATE students
SET major = '컴퓨터공학';
```

다음 SQL의 문제점을 설명하세요.

```sql
DELETE FROM students;
```

### 17.4 AI 검토 문제

AI가 다음 SQL을 생성했습니다.

```sql
DELETE FROM students
WHERE major = '경영학';
```

실행 전에 어떤 SQL을 먼저 실행해야 할까요? 그 이유도 함께 설명하세요.

---

## 18. 정리

이번 장에서는 관계형 데이터베이스에서 가장 기본이 되는 SQL을 살펴보았습니다.

핵심 내용을 정리하면 다음과 같습니다.

```text
1. SQL은 데이터베이스와 대화하는 언어이다.
2. SELECT는 데이터를 조회한다.
3. INSERT는 새 데이터를 추가한다.
4. WHERE는 조건을 지정한다.
5. ORDER BY는 조회 결과를 정렬한다.
6. UPDATE는 기존 데이터를 수정한다.
7. DELETE는 데이터를 삭제한다.
8. INSERT, SELECT, UPDATE, DELETE는 CRUD 흐름과 연결된다.
9. UPDATE와 DELETE를 실행하기 전에는 반드시 SELECT로 대상을 확인해야 한다.
10. AI가 만든 SQL은 실행 전 사람이 검토해야 한다.
```

### SQL 안전 실행 원칙

| 상황 | 먼저 확인할 것 | 이유 |
| --- | --- | --- |
| SELECT 실행 | 필요한 컬럼과 조건 | 불필요한 데이터 조회를 줄이기 위해 |
| INSERT 실행 | 컬럼 수와 값 수 | 입력 오류를 막기 위해 |
| UPDATE 실행 | 같은 WHERE 조건으로 SELECT | 잘못된 행 수정을 막기 위해 |
| DELETE 실행 | 같은 WHERE 조건으로 SELECT | 잘못된 행 삭제를 막기 위해 |
| AI 생성 SQL 실행 | 대상 테이블, 조건, 영향 범위 | AI 초안을 그대로 실행하는 위험을 줄이기 위해 |

이 장에서 가장 중요한 문장은 다음입니다.

```text
SQL은 실행하는 것보다, 실행 전에 어떤 데이터가 영향을 받는지 이해하는 것이 더 중요하다.
```

---

## 19. 다음 장에서는

다음 장에서는 데이터 모델링과 ERD를 살펴봅니다.

Chapter 05에서 다룰 내용은 다음과 같습니다.

```text
- 요구사항에서 테이블 후보 찾기
- 엔터티와 속성 이해
- 테이블 간 관계 찾기
- ERD 기본 기호 이해
- ChatGPT로 ERD 초안 만들기
- AI가 만든 ERD 검토하기
```

Chapter 04에서 배운 SQL은 이후 모든 장에서 반복해서 사용됩니다.
