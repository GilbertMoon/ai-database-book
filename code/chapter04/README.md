# Chapter 04 실습 코드

## 관계형 데이터베이스와 SQL 시작하기

이 폴더는 Chapter 04의 기본 SQL 실습 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `basic_crud.sql` | 위치 확인, 테이블 생성, INSERT, SELECT, 조건, NULL, 정렬, UPDATE와 DELETE 실습 |
| `reset_students.sql` | `students` 테이블과 데이터를 삭제하고 실습을 처음부터 다시 시작할 때만 사용하는 초기화 파일 |

---

## 기본 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. `SELECT current_database();`와 `SELECT current_schema();`를 실행합니다.
3. `basic_crud.sql`을 엽니다.
4. 파일 전체가 아니라 현재 학습 중인 구간만 선택해 실행합니다.
5. `CREATE TABLE` 구간은 테이블이 없을 때 한 번만 실행합니다.
6. 샘플 데이터 입력 후 전체 행 수가 6인지 확인합니다.
7. 조회 SQL은 실행 전 반환 열, 예상 행과 정렬 순서를 먼저 적어 봅니다.
8. `UPDATE`와 `DELETE`는 반드시 앞뒤의 `SELECT`와 함께 실행합니다.
9. DBeaver에서 영향받은 행 수와 `RETURNING` 결과를 확인합니다.

---

## 반복 실습 방법

`basic_crud.sql`은 기존 테이블을 자동으로 삭제하지 않습니다.

실습을 처음부터 다시 시작해야 할 때만 다음 순서를 따릅니다.

```text
현재 데이터베이스와 스키마 확인
→ reset_students.sql의 DROP TABLE 실행
→ basic_crud.sql의 CREATE TABLE 구간 실행
→ INSERT 구간 실행
```

`reset_students.sql`을 실행하면 `students` 테이블과 저장된 데이터가 모두 삭제됩니다. 보존해야 할 데이터가 없는지 확인한 뒤 실행합니다.

---

## 샘플 데이터 기준

| 이름 | 이메일 | 전공 | 학년 |
| --- | --- | --- | ---: |
| 김민지 | minji@example.com | 컴퓨터공학 | 2 |
| 이준호 | junho@example.com | 데이터사이언스 | 3 |
| 박서연 | seoyeon@example.com | 경영학 | 1 |
| 최현우 | hyunwoo@example.com | 컴퓨터공학 | 4 |
| 정하늘 | haneul@example.com | AI데이터공학 | 2 |
| 윤서진 | seojin@example.com | NULL | NULL |

---

## 주의 사항

```text
- 현재 데이터베이스와 스키마를 확인하지 않고 CREATE 또는 DROP을 실행하지 않습니다.
- basic_crud.sql 전체를 반복 실행하지 않습니다.
- 문자열은 작은따옴표로 감쌉니다.
- NULL은 = NULL이 아니라 IS NULL로 확인합니다.
- UPDATE와 DELETE는 WHERE 조건 없이 실행하지 않습니다.
- 수정·삭제 전 같은 WHERE 조건으로 SELECT를 실행합니다.
- 실행 후 영향받은 행 수를 확인합니다.
- 위험한 SQL 예시는 주석을 해제하지 않습니다.
```
