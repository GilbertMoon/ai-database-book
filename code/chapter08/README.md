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

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `00_check_course_project.sql` | 스키마·행 수·상태와 기본 합계 확인 |
| `01_join_queries.sql` | INNER·다중·LEFT JOIN, ON/WHERE, NOT EXISTS |
| `02_aggregation_queries.sql` | COUNT·SUM·AVG·GROUP BY·FILTER·HAVING |
| `03_join_aggregation_validation.sql` | 상세·집계 결과의 건수와 금액 검산 |
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

---

## 핵심 기준값

| 항목 | 기대값 |
| --- | ---: |
| 전체 신청 수 | 5 |
| 전체 저장 결제금액 합계 | 590000 |
| 전체 평균 결제금액 | 118000 |
| 취소 제외 신청 수 | 4 |
| 취소 제외 결제금액 합계 | 440000 |

상태별 건수:

```text
신청 2
수강중 1
완료 1
취소 1
```

---

## 중요한 구분

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

## ON과 WHERE

모든 부모 행을 유지하면서 오른쪽 대상만 제한하려면 조건을 `ON`에 둘 필요가 있습니다.

```sql
LEFT JOIN course_project.enrollments AS e
    ON c.id = e.course_id
   AND e.status <> '취소'
```

같은 조건을 `WHERE`에 두면 오른쪽 행이 없는 부모가 결과에서 제거될 수 있습니다.

---

## 금액 표현

```text
SUM(paid_amount)
→ 저장된 결제금액의 합

status <> '취소' 조건 합계
→ 이 장에서 사용하는 취소 제외 기준

실제 매출
→ 결제 성공·환불·매출 인식 정책이 추가로 필요
```

저장 금액 합계를 실제 회계 매출로 단정하지 않습니다.

---

## 검산 원칙

```text
상태별 건수 합 = 전체 5
상태별 금액 합 = 전체 590000
강의별 취소 제외 건수 합 = 4
강의별 취소 제외 금액 합 = 440000
INNER JOIN 결과 행 수 = enrollments 5
```

결과가 다르면 JOIN 경로, ON/WHERE 조건, COUNT 대상, DISTINCT와 상태 기준을 확인합니다.
