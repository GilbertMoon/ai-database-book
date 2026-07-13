# Chapter 03 실습 코드

## PostgreSQL과 DBeaver 실습 환경 확인

이 폴더는 Chapter 03의 환경 확인 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `setup_check.sql` | PostgreSQL 서버, 현재 데이터베이스, 스키마, 사용자와 SQL 실행 상태를 확인하는 읽기 전용 스크립트 |

---

## 실행 전 확인

DBeaver에서 다음 연결 대상을 확인합니다.

```text
Database: ai_database_book
Schema: public
```

현재 데이터베이스와 스키마가 확실하지 않다면 `setup_check.sql`을 실행해 확인합니다.

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 연결을 선택합니다.
2. SQL Editor를 엽니다.
3. `setup_check.sql` 파일을 열거나 내용을 복사합니다.
4. 한 문장, 선택 영역 또는 전체 스크립트 중 원하는 범위로 실행합니다.
5. 다음 결과를 확인합니다.

```text
PostgreSQL 버전
현재 데이터베이스
현재 스키마
search_path
현재 사용자
서버 시각
계산 결과 2
```

---

## 예상 결과

| 확인 항목 | 일반적인 기대 결과 |
| --- | --- |
| `current_database()` | `ai_database_book` |
| `current_schema()` | `public` |
| `SHOW search_path` | `"$user", public`과 유사한 값 |
| `current_user` | 연결에 사용한 PostgreSQL 사용자 |
| `CURRENT_TIMESTAMP` | PostgreSQL 서버의 현재 시각 |
| `1 + 1` | `2` |

환경에 따라 PostgreSQL 버전 문자열, 사용자와 `search_path` 값은 다를 수 있습니다.

---

## 재실행 가능성

`setup_check.sql`은 다음 명령을 포함하지 않습니다.

```text
CREATE TABLE
INSERT
UPDATE
DELETE
DROP
```

따라서 여러 번 실행해도 테이블이나 데이터가 추가·수정·삭제되지 않습니다.

테이블 생성과 CRUD 실습은 Chapter 04의 별도 SQL 파일에서 진행합니다. 제약조건 오류 실습은 Chapter 06에서 다룹니다.

---

## 보안 주의

```text
- 데이터베이스 비밀번호를 SQL 파일에 작성하지 않습니다.
- 전체 클라우드 접속 URL을 저장하지 않습니다.
- 실제 값이 들어 있는 .env 파일을 커밋하지 않습니다.
- 화면 캡처와 AI 질문에도 비밀정보를 포함하지 않습니다.
```
