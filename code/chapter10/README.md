# Chapter 10 실습 코드

## 인덱스와 성능 기초

이 폴더는 Chapter 10의 인덱스와 성능 기초 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `index_performance_practice.sql` | 인덱스 생성 전후 EXPLAIN 비교, WHERE/ORDER BY/JOIN 조건 인덱스, 복합 인덱스 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `index_performance_practice.sql`을 실행합니다.
4. `students`, `instructors`, `courses`, `enrollments` 테이블이 생성되었는지 확인합니다.
5. 인덱스 생성 전 `EXPLAIN` 결과를 확인합니다.
6. 인덱스를 생성한 뒤 같은 SQL의 `EXPLAIN` 결과를 다시 확인합니다.
7. `Seq Scan`, `Index Scan`, `Bitmap Index Scan` 등의 표현을 비교합니다.
8. 마지막에 `pg_indexes` 조회 결과로 생성된 인덱스 목록을 확인합니다.

---

## 주요 실습 항목

```text
- students.email 인덱스
- courses.title 인덱스
- enrollments.student_id 인덱스
- enrollments.course_id 인덱스
- enrollments(course_id, status) 복합 인덱스
- EXPLAIN 실행 계획 비교
- AI 추천 인덱스 검토 질문
```

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
- 실제 운영 데이터베이스에서는 DROP TABLE과 CREATE INDEX를 신중하게 실행해야 합니다.
- 샘플 데이터가 적으면 인덱스가 있어도 PostgreSQL이 Seq Scan을 선택할 수 있습니다.
- 인덱스는 검색 성능을 높일 수 있지만 저장 공간과 쓰기 비용이 증가합니다.
- AI가 추천한 인덱스도 실제 쿼리 패턴과 EXPLAIN 결과를 기준으로 검토해야 합니다.
```

---

## 학습 포인트

초급 단계에서는 실행 계획의 모든 세부 항목을 외울 필요는 없습니다.

다만 다음 흐름을 익히는 것이 중요합니다.

```text
1. 자주 실행되는 SQL을 확인한다.
2. WHERE, JOIN, ORDER BY에 사용되는 컬럼을 찾는다.
3. 인덱스를 만들기 전 EXPLAIN을 확인한다.
4. 인덱스를 만든 뒤 같은 SQL의 EXPLAIN을 다시 확인한다.
5. 인덱스가 실제로 도움이 되는지 판단한다.
```
