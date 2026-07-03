# Chapter 08 실습 코드

## JOIN과 집계 쿼리

이 폴더는 Chapter 08의 JOIN과 집계 쿼리 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `join_aggregation_practice.sql` | 온라인 강의 수강신청 시스템을 활용한 INNER JOIN, LEFT JOIN, GROUP BY, COUNT, SUM, AVG, HAVING 실습 |

---

## 실행 순서

1. DBeaver에서 `ai_database_book` 데이터베이스에 연결합니다.
2. SQL Editor를 엽니다.
3. `join_aggregation_practice.sql`을 실행합니다.
4. `students`, `instructors`, `courses`, `enrollments` 테이블이 생성되었는지 확인합니다.
5. INNER JOIN과 LEFT JOIN 결과 차이를 확인합니다.
6. GROUP BY와 집계 함수 결과를 확인합니다.
7. HAVING으로 집계 결과를 필터링하는 예제를 확인합니다.

---

## 확인할 핵심 결과

```text
- 학생별 수강 강의 목록
- 수강신청 현황 전체 조회
- 수강신청이 없는 학생 조회
- 전체 수강신청 수
- 전체 결제금액 합계와 평균
- 수강상태별 수강신청 수
- 강의별 수강생 수
- 강의별 매출
- 강사별 개설 강의 수
- 수강생이 2명 이상인 강의
```

---

## 주의 사항

```text
- 이 파일은 반복 실습을 위해 DROP TABLE IF EXISTS 구문을 포함합니다.
- 실제 서비스 데이터베이스에서는 DROP TABLE을 함부로 실행하면 안 됩니다.
- JOIN 조건이 빠지면 결과 행이 비정상적으로 많아질 수 있습니다.
- LEFT JOIN에서 수강신청이 없는 강의를 세려면 COUNT(*)보다 COUNT(e.id)를 사용하는 것이 안전합니다.
- AI가 만든 JOIN/집계 SQL은 반드시 실행 결과를 확인해야 합니다.
```
