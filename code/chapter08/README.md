# Chapter 08 실습 코드

## JOIN과 집계로 서비스 질문에 답하기

이 폴더는 Chapter 07에서 완성한 `course_project` 데이터를 변경하지 않고 JOIN과 집계 결과를 조회·검산하는 SQL 파일을 관리합니다.

## 실행 전 조건

Chapter 07의 다음 파일을 순서대로 실행합니다.

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

Chapter 07 검증 통과 메시지:

```text
Chapter 07 course project validation passed
```

최종 기준:

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료
1004 취소
1005 신청
```

## 파일 목록과 실행 순서

```text
00_check_course_project.sql
→ 01_join_queries.sql
→ 02_aggregation_queries.sql
→ 03_join_aggregation_validation.sql
```

| 파일 | 설명 |
| --- | --- |
| `00_check_course_project.sql` | Chapter 07 객체·행 수·상태·기록 금액 검사 |
| `01_join_queries.sql` | INNER·다중·LEFT JOIN과 ON/WHERE 비교 |
| `02_aggregation_queries.sql` | COUNT·SUM·AVG·GROUP BY·FILTER·HAVING |
| `03_join_aggregation_validation.sql` | 상세·그룹별 결과 검산 |
| `join_aggregation_practice.sql` | 기존 링크 호환용 읽기 전용 진입점 |

모든 파일은 조회 전용이며 `course_project.table_name` 형식을 사용합니다.

## 금액 열

```text
courses.price
→ 현재 강의 기준 가격

enrollments.recorded_amount
→ 신청 시 기록 금액
```

`recorded_amount`는 실제 결제 승인액·환불액·회계 매출이 아닙니다. Chapter 08에서는 신청 행에 기록된 값을 집계합니다.

## 분석 범위와 기준값

| 범위 | 포함 상태 | 건수 | recorded_amount 합계 |
| --- | --- | ---: | ---: |
| 전체 신청 이력 | 모든 상태 | 5 | 590000 |
| 활성 신청 | 신청, 수강중 | 3 | 340000 |
| 취소 제외 이력 | 신청, 수강중, 완료 | 4 | 440000 |
| 취소 신청 | 취소 | 1 | 150000 |

```text
전체 평균 recorded_amount = 118000.00
```

`recorded_amount`는 `NUMERIC(12,0)`이며 `AVG(recorded_amount)`는 `numeric` 결과를 반환합니다.

## COUNT 구분

```text
COUNT(*)
→ JOIN 결과 행 전체 수

COUNT(e.id)
→ 실제 신청 행 수

COUNT(DISTINCT e.student_id)
→ 고유 학생 수
```

LEFT JOIN에서 자식 사건 수를 계산할 때 `COUNT(*)`를 사용하면 자식이 없는 부모도 한 행처럼 보일 수 있습니다.

## ON과 WHERE

모든 부모를 유지하면서 연결 대상을 제한하려면 조건을 `ON`에 둡니다.

```sql
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
```

같은 조건을 `WHERE`에 두면 연결 행이 없는 부모가 제거될 수 있습니다.

## 집계와 NULL

```text
COUNT(*)·COUNT(column)
→ 대상이 없으면 0

SUM·AVG·MIN·MAX
→ 대상이 없으면 NULL 가능
```

`COALESCE(..., 0)`는 데이터 없음과 0을 같은 의미로 표시해도 될 때만 사용합니다.

## 과대 집계 주의

강의와 신청을 JOIN하면 강의 한 행이 신청 수만큼 반복됩니다. 이 상태에서 `SUM(c.price)`를 계산하면 강의 가격이 과대 합산될 수 있습니다. 강의 가격 합계가 질문이면 신청 테이블을 JOIN하지 않고 강의 수준에서 계산합니다.

## 검산 원칙

```text
상태별 건수 합 = 전체 5
상태별 기록 금액 합 = 전체 590000
활성 건수 합 = 3
활성 기록 금액 합 = 340000
강의별 취소 제외 건수 합 = 4
강의별 취소 제외 기록 금액 합 = 440000
INNER JOIN 결과 행 수 = enrollments 5
```
