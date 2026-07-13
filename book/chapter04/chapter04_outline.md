# Chapter 04 구성안

## 제목

관계형 데이터베이스와 SQL 시작하기

## 권장 분량

18~22페이지

## 이 장의 역할

PostgreSQL에서 첫 테이블을 만들고 데이터를 입력·조회·수정·삭제하면서, SQL 실행 전 예상 결과와 실행 후 실제 변화를 비교하는 습관을 익히도록 한다.

Chapter 03에서 환경 확인만 완료했으므로 Chapter 04에서 실제 테이블 생성과 CRUD 실습을 처음 시작한다. 제약조건 오류와 참조 무결성은 Chapter 06, JOIN과 집계는 Chapter 08, AI SQL 상세 검증은 Chapter 13으로 연결한다.

이 장의 핵심 질문은 다음과 같다.

```text
현재 어떤 데이터베이스와 스키마에서 SQL을 실행하는가?
CREATE TABLE의 각 열과 제약조건은 무엇을 의미하는가?
INSERT 후 자동 생성되는 값은 무엇인가?
SELECT 결과의 열, 행과 순서를 실행 전에 예상할 수 있는가?
NULL은 어떻게 조회하는가?
UPDATE와 DELETE의 영향 범위를 어떻게 확인하는가?
AI가 만든 SQL의 예상 결과와 실제 결과를 어떻게 비교하는가?
```

## 독자가 얻게 될 것

- `current_database()`와 `current_schema()`로 실행 위치를 확인할 수 있다.
- `CREATE TABLE` 문을 읽고 첫 테이블을 만들 수 있다.
- 문자열, 정수와 날짜시간 데이터 타입을 구분할 수 있다.
- `IDENTITY`, `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `DEFAULT`의 기본 의미를 읽을 수 있다.
- 단일 행과 여러 행을 `INSERT`할 수 있다.
- `RETURNING`으로 자동 생성값을 확인할 수 있다.
- 전체 열과 필요한 열만 `SELECT`할 수 있다.
- `WHERE`, 비교 연산자, `AND`, `OR`, `IN`, `LIKE`를 사용할 수 있다.
- `NULL`, `IS NULL`, `IS NOT NULL`을 구분할 수 있다.
- `ORDER BY`, `LIMIT`, `NULLS LAST`를 사용할 수 있다.
- `UPDATE`와 `DELETE` 전에 같은 조건으로 `SELECT`할 수 있다.
- DBeaver에서 영향받은 행 수를 확인할 수 있다.
- SQL 실행 전 예상 결과와 실행 후 실제 결과를 비교할 수 있다.
- 초기화 SQL을 기본 실습 파일과 분리해야 하는 이유를 설명할 수 있다.

## 핵심 개념

- `CREATE TABLE`
- 데이터 타입
- `IDENTITY`
- `PRIMARY KEY`
- `NOT NULL`
- `UNIQUE`
- `DEFAULT`
- `INSERT`
- `RETURNING`
- `SELECT`
- 열 별칭 `AS`
- `WHERE`
- 비교 연산자
- `AND`, `OR`, `IN`
- `LIKE`, `ILIKE`
- `NULL`, `IS NULL`, `IS NOT NULL`
- `ORDER BY`
- `LIMIT`
- `UPDATE`
- `DELETE`
- CRUD
- 영향받은 행 수
- 예상 결과와 실제 결과

## 본문 구성

1. 첫 번째 테이블과 기본 SQL
2. 실습 위치부터 확인하기
3. SQL을 실행하고 검증하는 기본 순서
4. `CREATE TABLE`로 첫 테이블 만들기
5. 열, 데이터 타입과 제약조건 읽기
6. `INSERT`로 단일 행 입력하기
7. 여러 행 입력과 자동값 확인
8. `SELECT`로 전체 데이터 조회하기
9. `WHERE`와 비교 연산자
10. `AND`, `OR`, `IN`과 괄호
11. `LIKE`로 문자열 검색하기
12. `NULL`, `IS NULL`, `IS NOT NULL`
13. `ORDER BY`와 `LIMIT`
14. `UPDATE`를 안전하게 실행하기
15. `DELETE`를 안전하게 실행하기
16. CRUD와 서비스 기능 연결하기
17. AI가 만든 SQL 검토하기
18. 종합 실습
19. 자주 하는 실수
20. 스스로 확인하기
21. 핵심 정리
22. 다음 장에서는

## 실습 데이터

`students` 테이블에 다음 6명을 사용한다.

| 이름 | 이메일 | 전공 | 학년 |
| --- | --- | --- | ---: |
| 김민지 | minji@example.com | 컴퓨터공학 | 2 |
| 이준호 | junho@example.com | 데이터사이언스 | 3 |
| 박서연 | seoyeon@example.com | 경영학 | 1 |
| 최현우 | hyunwoo@example.com | 컴퓨터공학 | 4 |
| 정하늘 | haneul@example.com | AI데이터공학 | 2 |
| 윤서진 | seojin@example.com | NULL | NULL |

## 코드 구조

```text
code/chapter04/
├── basic_crud.sql
├── reset_students.sql
└── README.md
```

- `basic_crud.sql`: 위치 확인, 테이블 생성, 입력, 조회, 조건, NULL, 정렬, 수정과 삭제 실습
- `reset_students.sql`: 실습을 처음부터 다시 시작할 때만 사용하는 테이블 삭제 파일

## 편집 원칙

- 관계형 데이터베이스 기본 개념은 Chapter 02와 중복하지 않고 실제 SQL 코드에 연결한다.
- DDL·DML·DCL·TCL 분류는 참고 수준으로만 다룬다.
- `DROP TABLE`을 기본 실습 파일에서 자동 실행하지 않는다.
- SQL 파일은 구간별 선택 실행을 기본으로 안내한다.
- UPDATE와 DELETE는 `SELECT → 변경 → 영향 행 수 → SELECT` 흐름으로 설명한다.
- NULL을 일반 값처럼 비교하지 않도록 반복해서 확인한다.
- AI가 만든 SQL은 구조, 타입, 조건, NULL, 영향 범위와 실행 결과로 검증한다.
- 제약조건 오류 실습은 Chapter 06으로 넘긴다.

## 다음 장 연결

다음 장에서는 학생, 강의와 수강신청처럼 여러 종류의 데이터를 요구사항에서 찾아 테이블과 관계로 표현하고 ERD를 작성한다.
