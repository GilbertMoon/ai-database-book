# Chapter 08 실습 코드

## JOIN과 집계 쿼리

이 폴더는 Chapter 08의 JOIN과 집계 쿼리 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `join_aggregation_practice.sql` | Chapter 07과 같은 테이블 구조를 사용하되, Chapter 08 전용 샘플 데이터로 JOIN과 집계를 검증하는 실습 SQL |

---

## 실행 전 확인

1. 개인 실습용 `ai_database_book` 데이터베이스에 연결합니다.
2. `SELECT current_database();`로 현재 연결 대상을 확인합니다.
3. `join_aggregation_practice.sql`이 `enrollments`, `courses`, `instructors`, `students`를 삭제하고 다시 생성한다는 점을 확인합니다.
4. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

---

## Chapter 08 데이터셋 설명

Chapter 08은 Chapter 07과 같은 스키마를 사용하지만, LEFT JOIN과 집계 차이를 분명히 확인하기 위해 전용 샘플 데이터를 다시 입력합니다.

| 테이블 | 예상 건수 |
| --- | ---: |
| students | 4 |
| instructors | 3 |
| courses | 4 |
| enrollments | 5 |

특히 다음 두 행이 실습 핵심입니다.

```text
- 최현우: 수강신청이 없는 학생
- 집계 쿼리 실습: 수강신청이 없는 강의
```

---

## 주요 예상 결과

| 항목 | 예상값 |
| --- | --- |
| students | 4 |
| instructors | 3 |
| courses | 4 |
| enrollments | 5 |
| INNER JOIN 결과 | 5행 |
| 학생 기준 LEFT JOIN 결과 | 6행 |
| 전체 결제금액 | 620000 |
| 평균 결제금액 | 124000 |

상세 기준은 다음과 같습니다.

```text
- 수강신청이 없는 학생: 최현우
- 수강신청이 없는 강의: 집계 쿼리 실습
- 상태별 건수: 신청 2, 수강중 2, 완료 1
- HAVING 결과: 데이터베이스 입문, 파이썬 데이터 분석
```

---

## 이 장에서 특히 구분할 개념

```text
COUNT(*)
- 결과 행 전체 수

COUNT(e.id)
- 실제 수강신청 행 수

COUNT(DISTINCT e.student_id)
- 중복을 제거한 고유 학생 수
```

현재 샘플에서는 `COUNT(e.id)`와 `COUNT(DISTINCT e.student_id)`가 같은 값으로 보일 수 있지만, 재신청 데이터가 생기면 달라질 수 있습니다.

또한 `SUM(paid_amount)`는 저장된 결제금액의 단순 합계입니다. 환불·취소·매출 인식 기준까지 반영한 실제 매출과 같은 의미로 단정하지 않습니다.

---

## 실행 후 확인할 핵심 결과

1. INNER JOIN 결과가 5행인지 확인합니다.
2. 학생 기준 LEFT JOIN 결과가 6행인지 확인합니다.
3. 최현우가 `WHERE e.id IS NULL` 결과에 1행으로 나오는지 확인합니다.
4. `집계 쿼리 실습` 강의의 수강신청 건수와 결제금액 합계가 0인지 확인합니다.
5. AI가 만든 SQL을 사용할 때는 원본 건수와 합계로 다시 검산합니다.
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
