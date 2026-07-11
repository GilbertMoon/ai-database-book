# Chapter 07 프로젝트 코드

## 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계

이 폴더는 Chapter 07에서 사용하는 실행 가능한 PostgreSQL 프로젝트 SQL을 관리합니다.

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `online_course_project.sql` | 테이블 생성, 샘플 데이터, CRUD, JOIN과 정규화 검토를 포함한 온라인 강의 데이터베이스 프로젝트 |

## 실행 순서

1. DBeaver에서 작업용 PostgreSQL 데이터베이스에 연결합니다.
2. SQL Editor에서 `online_course_project.sql`을 엽니다.
3. 파일을 위에서 아래 순서대로 실행합니다.
4. `students`, `instructors`, `courses`, `enrollments` 테이블을 확인합니다.
5. 샘플 데이터와 JOIN 결과가 요구사항을 표현하는지 확인합니다.
6. UPDATE와 DELETE 예제는 대상 행을 SELECT로 먼저 확인한 뒤 실행합니다.
7. 정규화, 제약조건과 재실행 가능성을 검토합니다.

## 주의 사항

```text
- 테스트용 데이터베이스에서 실행합니다.
- DROP TABLE IF EXISTS가 포함되어 있으므로 운영 데이터베이스에서 실행하지 않습니다.
- 실제 개인정보나 접속 비밀번호를 예제에 사용하지 않습니다.
- AI가 생성한 SQL은 PostgreSQL에서 직접 실행하고 결과를 검증합니다.
```
