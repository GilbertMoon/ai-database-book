# Chapter 06 실습 코드

## 정규화와 좋은 테이블 설계

이 폴더는 Chapter 06의 정규화 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `normalization_practice.sql` | 정규화 전 `library_records` 테이블과 정규화 후 `members`, `books`, `loans` 구조를 비교하는 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `normalization_practice.sql`을 실행합니다.
4. 정규화 전 `library_records` 테이블의 중복 데이터를 확인합니다.
5. 정규화 후 `members`, `books`, `loans` 테이블 구조를 확인합니다.
6. JOIN 결과가 정규화 전 조회 결과와 어떻게 연결되는지 확인합니다.
7. 회원 이메일 수정 예시를 통해 수정 이상이 줄어드는지 확인합니다.

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
- 실제 서비스 데이터베이스에서는 DROP TABLE을 함부로 실행하면 안 됩니다.
- 정규화 전 테이블은 의도적으로 중복과 이상 현상을 보여 주기 위한 나쁜 예시입니다.
- 정규화 후 구조에서는 JOIN을 통해 필요한 조회 결과를 만든다는 점을 확인합니다.
```
