# Chapter 08 실습 코드

## JOIN과 집계로 서비스 질문에 답하기

이 폴더는 Chapter 07에서 완성한 `course_project` 데이터를 변경하지 않고 JOIN과 집계 결과를 조회·검산하는 SQL 파일을 관리합니다.

---

## 실행 전 조건

Chapter 07의 다음 파일을 순서대로 실행한 최종 상태가 필요합니다.

```text
code/chapter07/01_course_project_schema.sql
code/chapter07/02_course_project_seed.sql
code/chapter07/03_course_project_changes.sql
code/chapter07/04_course_project_validation.sql
```

기대 상태:

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료
1004 취소
1005 신청
```

Chapter 07의 무결성 테스트에서 임시 행을 입력했다면 삭제 구문까지 실행했는지 확인합니다. 기준값이 다르면 Chapter 08을 계속 실행하지 않습니다.

보존할 프로젝트 데이터가 없는 실습 환경에서는 다음 순서로 기준 상태를 복원합니다.

```text
reset_course_project.sql
→ 01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

초기화 파일은 사용자가 직접 현재 데이터베이스와 삭제 대상을 확인한 뒤 실행합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `00_check_course_project.sql` | DB·테이블·행 수·상태·금액 기준을 검사하고 불일치 시 실행 중단 |
| `01_join_queries.sql` | INNER·다중·LEFT JOIN, ON/WHERE, NOT EXISTS |
| `02_aggregation_queries.sql` | COUNT·SUM·AVG·GROUP BY·FILTER·HAVING과 과대 집계 사례 |
| `03_join_aggregation_validation.sql` | 상세·집계 결과의 건수와 기록 금액 검산 |
| `join_aggregation_practice.sql` | 기존 링크 호환용 읽기 전용 핵심 쿼리 |

---

## 실행 순서

```text
00_check_course_project.sql
→ 01_join_queries.sql
→ 02_aggregation_queries.sql
→ 03_join_aggregation_validation.sql
```

모든 파일은 조회 전용입니다.

```text
CREATE 없음
INSERT 없음
UPDATE 없음
DELETE 없음
DROP 없음
```

`00_check_course_project.sql`의 `DO` 블록은 데이터를 변경하지 않으며 잘못된 데이터베이스, 누락된 테이블 또는 다른 기준 데이터를 발견하면 예외로 실행을 중단합니다.

모든 파일은 다음 위치 확인을 사용합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

모든 객체에 `course_project` 스키마를 명시하므로 `current_schema()`가 `course_project`일 필요는 없습니다.

---

## 분석 범위 정의

| 분석 범위 | 포함 상태 | 건수 | 기록 금액 |
| --- | --- | ---: | ---: |
| 전체 신청 이력 | 모든 상태 | 5 | 590000 |
| 활성 신청 | 신청, 수강중 | 3 | 340000 |
| 취소 제외 신청 이력 | 신청, 수강중, 완료 | 4 | 440000 |
| 취소 신청 | 취소 | 1 | 150000 |

`status`는 Chapter 07에서 `NOT NULL`이므로 `status <> '취소'`는 현재 구조에서 NULL 상태를 별도로 고려하지 않습니다.

`paid_amount`는 신청 당시 기록 금액입니다. 결제 성공, 환불과 매출 인식 정보가 없으므로 실제 회계 매출로 단정하지 않습니다.

---

## 핵심 기준값

| 항목 | 기대값 |
| --- | ---: |
| 전체 신청 수 | 5 |
| 전체 기록 금액 합계 | 590000 |
| 전체 평균 기록 금액 | 118000.00 |
| 활성 신청 수 | 3 |
| 활성 신청 기록 금액 | 340000 |
| 취소 제외 신청 이력 수 | 4 |
| 취소 제외 기록 금액 | 440000 |

PostgreSQL의 `AVG(INTEGER)`는 `numeric`을 반환합니다. SQL 파일에서는 `ROUND(AVG(paid_amount), 2)`로 표시 형식을 맞춥니다.

상태별 건수:

```text
신청 2
수강중 1
완료 1
취소 1
```

상태는 문자열 정렬에 맡기지 않고 `CASE`로 위 업무 순서를 명시합니다.

---

## 중요한 COUNT 구분

```text
COUNT(*)
- JOIN 결과 행 전체 수

COUNT(e.id)
- NULL이 아닌 실제 신청 행 수

COUNT(DISTINCT e.student_id)
- 고유 학생 수
```

LEFT JOIN에서 자식 사건 수를 계산할 때 `COUNT(*)`를 사용하면 자식이 없는 부모도 1건처럼 보일 수 있습니다.

---

## 집계 함수와 NULL

| 함수 | NULL 처리 | 입력 대상이 없을 때 |
| --- | --- | --- |
| `COUNT(*)` | 결과 행을 셈 | 0 |
| `COUNT(column)` | NULL 제외 | 0 |
| `SUM(column)` | NULL 제외 | NULL |
| `AVG(column)` | NULL 제외 | NULL |
| `MIN(column)` | NULL 제외 | NULL |
| `MAX(column)` | NULL 제외 | NULL |

`COALESCE(..., 0)`는 업무적으로 데이터 없음과 숫자 0을 같은 표시로 처리해도 될 때만 사용합니다. 평균·최솟값이 없다는 사실을 무조건 0으로 바꾸면 의미가 달라질 수 있습니다.

---

## ON과 WHERE

모든 부모 행을 유지하면서 오른쪽 대상만 제한하려면 조건을 `ON`에 둘 필요가 있습니다.

```sql
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
```

같은 조건을 `WHERE`에 두면 오른쪽 행이 없는 부모가 결과에서 제거될 수 있습니다.

---

## 과대 집계 주의

강의와 신청을 JOIN하면 강의 한 행이 신청 수만큼 반복됩니다. 이 결과에서 `SUM(c.price)`를 계산하면 강의 가격이 과대 합산될 수 있습니다.

`SUM(DISTINCT c.price)`도 서로 다른 강의의 가격이 같을 때 한 번만 합산되므로 일반적인 해결책이 아닙니다. 강의 가격 합계가 질문이라면 신청 테이블을 JOIN하지 않고 강의 수준에서 먼저 계산합니다.

---

## JOIN 범위

이 장에서는 서비스 조회에서 자주 사용하는 `INNER JOIN`과 `LEFT JOIN`에 집중합니다.

```text
RIGHT JOIN
FULL OUTER JOIN
CROSS JOIN
```

위 JOIN은 입문 프로젝트 범위에서 제외합니다. `RIGHT JOIN`의 많은 사례는 테이블 순서를 바꾸어 `LEFT JOIN`으로 표현할 수 있습니다.

---

## 검산 원칙

```text
상태별 건수 합 = 전체 5
상태별 기록 금액 합 = 전체 590000
활성 상태별 건수 합 = 3
활성 상태별 기록 금액 합 = 340000
강의별 취소 제외 건수 합 = 4
강의별 취소 제외 기록 금액 합 = 440000
INNER JOIN 결과 행 수 = enrollments 5
```

결과가 다르면 JOIN 경로, `ON`·`WHERE` 조건, `COUNT` 대상, `DISTINCT`, 상태 범위, NULL 처리와 Chapter 07 임시 행 잔존 여부를 확인합니다.
