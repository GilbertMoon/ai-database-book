# Chapter 05 실습 코드

## 데이터 모델링과 ERD

이 폴더는 Chapter 05의 데이터 모델링과 ERD 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `library_schema.sql` | 도서 대여 시스템의 members, books, loans 테이블 생성 및 샘플 데이터 검증 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `library_schema.sql`을 실행합니다.
4. `members`, `books`, `loans` 테이블이 생성되었는지 확인합니다.
5. 샘플 데이터가 입력되었는지 확인합니다.
6. JOIN 조회 결과를 확인합니다.
7. `returned_at IS NULL` 조건으로 미반납 도서를 조회합니다.
8. 외래키 오류 실습은 주석을 해제한 뒤 별도로 실행합니다.

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
- 외래키 관계가 있으므로 loans 테이블을 먼저 삭제합니다.
- 실제 서비스 데이터베이스에서는 DROP TABLE을 함부로 실행하면 안 됩니다.
- 외래키 오류 실습은 오류가 발생해야 정상입니다.
```
