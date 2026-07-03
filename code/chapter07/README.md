# Chapter 07 실습 코드

## 중간 프로젝트 또는 중간 평가

이 폴더는 Chapter 07의 중간 프로젝트 SQL 템플릿을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `midterm_project_template.sql` | 온라인 강의 수강신청 시스템의 테이블 생성, 샘플 데이터, CRUD, JOIN, 정규화 검토 SQL 템플릿 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `midterm_project_template.sql`을 실행합니다.
4. `students`, `instructors`, `courses`, `enrollments` 테이블이 생성되었는지 확인합니다.
5. 샘플 데이터가 입력되었는지 확인합니다.
6. JOIN으로 수강신청 현황을 조회합니다.
7. SELECT, INSERT, UPDATE, DELETE 실습을 실행합니다.
8. 정규화 관점에서 테이블 구조를 검토합니다.

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
- 실제 서비스 데이터베이스에서는 DROP TABLE을 함부로 실행하면 안 됩니다.
- UPDATE와 DELETE 전에는 반드시 같은 WHERE 조건으로 SELECT를 먼저 실행합니다.
- 실제 서비스에서는 수강신청 삭제보다 status='취소' 업데이트를 우선 검토할 수 있습니다.
- AI가 생성한 SQL을 사용할 경우 반드시 DBeaver에서 실행하고 결과를 확인해야 합니다.
```
