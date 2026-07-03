# Chapter 03 실습 코드

## PostgreSQL과 DBeaver 실습 환경 구축

이 폴더는 Chapter 03의 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `setup_check.sql` | PostgreSQL 연결 확인, students 테이블 생성, 샘플 데이터 입력, 제약조건 확인 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `setup_check.sql` 내용을 복사하거나 파일을 열어 실행합니다.
4. `SELECT version();`, `SELECT current_database();` 결과를 확인합니다.
5. `students` 테이블이 생성되었는지 확인합니다.
6. 샘플 데이터 3건이 입력되었는지 확인합니다.
7. UNIQUE 제약조건 오류 실습은 주석을 해제한 뒤 별도로 실행합니다.

---

## 주의 사항

```text
- 이미 students 테이블이 있으면 CREATE TABLE에서 오류가 발생할 수 있습니다.
- 반복 실습이 필요하면 DROP TABLE IF EXISTS students; 주석을 해제하고 먼저 실행합니다.
- DB 비밀번호나 접속 정보는 이 폴더에 저장하지 않습니다.
```
