# Chapter 04. 관계형 데이터베이스와 SQL 기초

> 상태: 초안

## 이 장에서 배울 내용

이 장에서는 PostgreSQL에서 가장 기본이 되는 SQL을 실습합니다.

- 관계형 데이터베이스의 기본 구조
- SELECT, INSERT, UPDATE, DELETE
- WHERE, ORDER BY
- 기본 CRUD 흐름
- AI가 만든 SQL 검토

## 왜 이 내용을 배우는가

SQL은 데이터베이스와 대화하는 언어입니다. AI가 SQL을 생성해 주더라도, 학습자는 그 SQL이 어떤 데이터를 조회하고 수정하는지 이해할 수 있어야 합니다.

## 핵심 개념

### SQL

SQL은 데이터베이스에 명령을 내리는 언어입니다.

### CRUD

CRUD는 생성(Create), 조회(Read), 수정(Update), 삭제(Delete)를 의미합니다.

## 기본 예제

```sql
SELECT *
FROM students;
```

이 SQL은 students 테이블의 모든 데이터를 조회합니다.

## AI 활용 실습

```text
students 테이블을 대상으로 SELECT, INSERT, UPDATE, DELETE 예제 SQL을 만들어 주세요.
PostgreSQL 문법 기준으로 작성해 주세요.
```

## 검토 질문

- WHERE 조건 없이 UPDATE나 DELETE를 실행하지 않았는가?
- 문자열 값에 따옴표가 제대로 사용되었는가?
- PostgreSQL 문법에 맞게 작성되었는가?

## 자주 하는 실수

- WHERE 없이 UPDATE를 실행한다.
- WHERE 없이 DELETE를 실행한다.
- SELECT 결과를 확인하지 않고 데이터를 수정한다.

## 정리

이 장에서는 기본 SQL과 CRUD 흐름을 학습했습니다. 이후 장에서는 여러 테이블을 어떻게 설계하고 연결할지 배웁니다.

## 연습 문제

1. [기초] SELECT와 INSERT의 차이를 설명해 보세요.
2. [기초] WHERE가 필요한 이유를 설명해 보세요.
3. [응용] students 테이블에서 이름이 '홍길동'인 학생을 조회하는 SQL을 작성해 보세요.
4. [심화] AI가 만든 DELETE 문에서 위험한 부분을 찾아 보세요.

## 다음 장에서는

다음 장에서는 데이터 모델링과 ERD를 학습합니다.
