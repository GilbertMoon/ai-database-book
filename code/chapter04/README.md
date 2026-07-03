# Chapter 04 실습 코드

## 관계형 데이터베이스와 SQL 기초

이 폴더는 Chapter 04의 SQL 기초 실습 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `basic_crud.sql` | students 테이블을 사용한 SELECT, INSERT, UPDATE, DELETE, WHERE, ORDER BY 기본 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `basic_crud.sql`을 실행합니다.
4. `students` 테이블 생성 여부를 확인합니다.
5. 샘플 데이터 5건이 입력되었는지 확인합니다.
6. `SELECT`, `WHERE`, `ORDER BY` 결과를 확인합니다.
7. `UPDATE`와 `DELETE`는 실행 전후 `SELECT` 결과를 반드시 비교합니다.

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS students;를 포함합니다.
- 실제 서비스 데이터베이스에서는 DROP TABLE을 함부로 실행하면 안 됩니다.
- UPDATE와 DELETE는 WHERE 조건 없이 실행하지 않습니다.
- 위험한 SQL 예시는 주석 처리되어 있으므로 해제하지 않습니다.
```
