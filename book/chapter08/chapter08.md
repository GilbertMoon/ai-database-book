# Chapter 08. JOIN과 집계 쿼리

---

## 이 장에서 살펴볼 내용

이 장에서는 여러 테이블의 데이터를 함께 조회하는 JOIN과 데이터를 요약하는 집계 쿼리를 다룹니다.

Chapter 07에서는 온라인 강의 수강신청 시스템의 `students`, `instructors`, `courses`, `enrollments` 테이블을 만들었습니다. 하지만 실제 업무 질문에 답하려면 한 테이블만 보는 것으로는 충분하지 않습니다.

예를 들어 수강신청 현황 한 행에는 다음 정보가 함께 필요합니다.

```text
- 학생 이름: students
- 강의 제목: courses
- 강사 이름: instructors
- 수강 상태와 결제금액: enrollments
```

이처럼 정규화되어 나뉘어 저장된 사실을 조회 시점에 연결하는 방법이 JOIN입니다. 그리고 여러 행을 묶어 건수, 합계, 평균처럼 요약하는 방법이 집계 쿼리입니다.

이 장에서 다룰 내용은 다음과 같습니다.

- INNER JOIN
- LEFT JOIN
- 다중 JOIN
- 테이블 별칭
- COUNT, SUM, AVG
- GROUP BY
- HAVING
- COALESCE
- COUNT DISTINCT
- AI SQL 검토

---

## 1. 왜 JOIN과 집계 쿼리를 배워야 하는가

정규화된 데이터베이스는 같은 사실을 여러 번 저장하지 않도록 데이터를 나누어 보관합니다. 이 구조는 입력과 수정에는 유리하지만, 조회 시에는 필요한 값을 다시 조립해야 합니다.

![정규화된 테이블에 JOIN이 필요한 이유](../../images/chapter08/ch08_01_join_why_needed.svg)

그림 8-1 정규화된 테이블에 JOIN이 필요한 이유

수강신청 한 건을 보면 `student_id`, `course_id`, `status`, `paid_amount`는 알 수 있어도 학생 이름, 강의 제목, 강사 이름은 바로 알 수 없습니다. 이때 JOIN은 컬럼 이름이 비슷한 테이블을 아무렇게나 붙이는 기능이 아니라, 실제 PK와 FK 관계를 따라 필요한 값을 찾아오는 방법입니다.

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
JOIN instructors AS i ON c.instructor_id = i.id;
```

중요한 점은 JOIN이 테이블을 실제로 합쳐 저장하는 것이 아니라는 점입니다. 원본 값은 각 테이블에 그대로 유지되고, 조회 결과만 필요에 맞게 만들어집니다.

집계 쿼리는 이런 질문에 답할 때 사용합니다.

```text
- 전체 수강신청 수는 몇 건인가?
- 상태별 수강신청 수는 몇 건인가?
- 강의별 수강신청 건수와 고유 학생 수는 어떻게 다른가?
- 강의별 결제금액 합계는 얼마인가?
```

---

## 2. 실습에 사용할 테이블 구조

이 장은 Chapter 07과 같은 네 테이블 구조를 사용합니다.

```text
students(id, name, email, joined_at)
instructors(id, name, email, specialty)
courses(id, instructor_id, title, description, level, price, opened_at)
enrollments(id, student_id, course_id, enrolled_at, status, paid_amount)
```

관계는 다음과 같습니다.

```text
instructors 1:N courses
students 1:N enrollments
courses 1:N enrollments
students N:M courses는 enrollments로 해소
```

Chapter 08은 Chapter 07과 같은 테이블 구조를 사용하지만, JOIN과 집계 차이를 분명히 확인하기 위해 전용 샘플 데이터를 다시 입력합니다. 따라서 Chapter 07의 마지막 데이터 상태를 그대로 이어 쓰는 것이 아니라 Chapter 08 실습 파일이 테이블을 초기화하고 확장된 테스트 데이터를 구성합니다.

이 장의 실습은 다음 파일을 기준으로 진행합니다.

```text
code/chapter08/join_aggregation_practice.sql
```

Chapter 07의 프로젝트 SQL을 비교 참고할 때는 실제 파일 경로인 `code/chapter07/online_course_project.sql`만 사용합니다. 하지만 Chapter 08 실행 기준은 `join_aggregation_practice.sql`로 통일합니다.

### Chapter 08 샘플 데이터 기준

| 테이블 | 행 수 | JOIN·집계 실습에서의 역할 |
| --- | ---: | --- |
| `students` | 4 | 최현우는 수강신청이 없어 LEFT JOIN 검증에 사용 |
| `instructors` | 3 | 강사별 개설 강의 수 집계 |
| `courses` | 4 | `집계 쿼리 실습`은 수강신청이 없는 강의 |
| `enrollments` | 5 | JOIN 결과의 기본 기준 행 |

### 주요 예상 결과

| 검증 항목 | 예상 결과 |
| --- | --- |
| INNER JOIN 수강신청 결과 | 5행 |
| 학생 기준 LEFT JOIN 결과 | 6행 |
| 수강신청이 없는 학생 | 최현우 1명 |
| 전체 수강신청 수 | 5 |
| 전체 결제금액 합계 | 620000 |
| 평균 결제금액 | 124000 |
| 신청 상태 건수 | 2 |
| 수강중 상태 건수 | 2 |
| 완료 상태 건수 | 1 |
| 수강신청이 없는 강의 | 집계 쿼리 실습 |
| 수강신청 2건 이상 강의 | 데이터베이스 입문, 파이썬 데이터 분석 |

---

## 3. 실습 파일 안내와 안전 확인

`join_aggregation_practice.sql`은 네 테이블을 삭제하고 다시 생성합니다.

> **실습 DB 확인**
>
> `join_aggregation_practice.sql`은 `enrollments`, `courses`, `instructors`, `students` 테이블을 삭제하고 다시 생성합니다.
>
> 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 실행 전에 `SELECT current_database();`로 현재 연결 대상을 확인합니다.
>
> 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

Chapter 08 SQL 파일의 맨 위에는 현재 데이터베이스 확인과 DROP TABLE 경고가 포함되어 있습니다.

---

## 4. INNER JOIN 이해하기

`INNER JOIN`은 양쪽 테이블에서 조건이 일치하는 행만 결과에 포함합니다.

![INNER JOIN은 일치하는 행만 포함한다](../../images/chapter08/ch08_02_inner_join_concept.svg)

그림 8-2 INNER JOIN은 일치하는 행만 포함한다

```sql
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM students AS s
JOIN enrollments AS e ON s.id = e.student_id
JOIN courses AS c ON e.course_id = c.id
ORDER BY s.id, c.id;
```

이 SQL의 기준 행은 학생이 아니라 수강신청과 일치한 결과 행입니다. 한 학생에 일치하는 수강신청이 여러 개면 결과도 여러 행이 됩니다.

Chapter 08 샘플 데이터에서 실제 결과는 5행입니다.

| student_name | course_title | status |
| --- | --- | --- |
| 김민지 | 데이터베이스 입문 | 수강중 |
| 김민지 | 정규화 실습 | 신청 |
| 이준호 | 데이터베이스 입문 | 수강중 |
| 이준호 | 파이썬 데이터 분석 | 완료 |
| 박서연 | 파이썬 데이터 분석 | 신청 |

최현우는 수강신청이 없으므로 INNER JOIN 결과에 포함되지 않습니다.

---

## 5. 테이블 별칭과 다중 JOIN

JOIN이 많아질수록 테이블 이름을 짧게 줄여 쓰는 편이 읽기 쉽습니다.

| 테이블 | 권장 별칭 |
| --- | --- |
| students | s |
| instructors | i |
| courses | c |
| enrollments | e |

수강신청 현황 한 행을 만들려면 `enrollments`에서 시작해 학생, 강의, 강사 정보를 순서대로 연결합니다.

![수강신청 현황을 만드는 다중 JOIN 경로](../../images/chapter08/ch08_03_multi_table_join_path.svg)

그림 8-3 수강신청 현황을 만드는 다중 JOIN 경로

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.paid_amount,
    e.enrolled_at
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id
JOIN instructors AS i ON c.instructor_id = i.id
ORDER BY e.id;
```

정확한 FK 경로는 다음과 같습니다.

```text
enrollments.student_id -> students.id
enrollments.course_id -> courses.id
courses.instructor_id -> instructors.id
```

강사는 `enrollments`에서 직접 연결하지 않습니다. 반드시 `courses`를 거쳐 `instructors`로 이동해야 합니다.

---

## 6. LEFT JOIN 이해하기

`LEFT JOIN`은 왼쪽 테이블의 행을 모두 유지합니다. 다만 결과 행 수가 항상 왼쪽 테이블의 행 수와 같은 것은 아닙니다.

![LEFT JOIN은 왼쪽 행을 모두 유지한다](../../images/chapter08/ch08_04_left_join_null_rows.svg)

그림 8-4 LEFT JOIN은 왼쪽 행을 모두 유지한다

```sql
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM students AS s
LEFT JOIN enrollments AS e ON s.id = e.student_id
LEFT JOIN courses AS c ON e.course_id = c.id
ORDER BY s.id, c.id;
```

Chapter 08 데이터 기준으로 학생별 일치 행 수는 다음과 같습니다.

```text
김민지: 2건
이준호: 2건
박서연: 1건
최현우: 0건
```

따라서 학생 기준 LEFT JOIN 결과는 `2 + 2 + 1 + 1`로 총 6행입니다.

> LEFT JOIN은 왼쪽 테이블의 행 수만큼만 결과가 나온다는 뜻이 아닙니다.
>
> 왼쪽 행에 오른쪽 일치 행이 여러 개 있으면 결과도 여러 행이 되며,
>
> 일치 행이 하나도 없을 때는 오른쪽 컬럼이 NULL인 행 하나가 생성됩니다.

최현우의 결과는 다음처럼 나타납니다.

```text
student_name = 최현우
course_title = NULL
status = NULL
```

이 NULL은 `students` 원본에 저장된 값이 아니라, JOIN 과정에서 대응하는 오른쪽 행이 없어 생성된 결과값입니다.

수강신청이 없는 학생만 찾고 싶다면 다음처럼 작성합니다.

```sql
SELECT
    s.id,
    s.name,
    s.email
FROM students AS s
LEFT JOIN enrollments AS e ON s.id = e.student_id
WHERE e.id IS NULL;
```

---

## 7. 집계 함수와 기본 검산

집계 함수는 여러 행을 하나의 요약값으로 계산합니다.

| 함수 | 의미 | 이 장의 예 |
| --- | --- | --- |
| COUNT | 행 수 계산 | 수강신청 건수 |
| SUM | 합계 계산 | 결제금액 합계 |
| AVG | 평균 계산 | 평균 결제금액 |

전체 수강신청과 결제금액은 다음처럼 먼저 검산할 수 있습니다.

```sql
SELECT
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS total_paid_amount,
    AVG(paid_amount) AS avg_paid_amount
FROM enrollments;
```

이 장의 예상값은 다음과 같습니다.

| 항목 | 값 |
| --- | ---: |
| enrollment_count | 5 |
| total_paid_amount | 620000 |
| avg_paid_amount | 124000 |

이런 기본 검산은 이후 JOIN과 집계 결과를 AI가 제안했을 때도 기준선으로 활용됩니다.

---

## 8. GROUP BY 이해하기

`GROUP BY`는 같은 값을 가진 행을 그룹으로 묶고 그룹별 결과 한 행을 만듭니다.

![GROUP BY로 상태별 행 묶기](../../images/chapter08/ch08_05_group_by_aggregation_flow.svg)

그림 8-5 GROUP BY로 상태별 행 묶기

```sql
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY status
ORDER BY status;
```

Chapter 08 샘플 데이터의 상태별 결과는 다음과 같습니다.

| status | enrollment_count |
| --- | ---: |
| 신청 | 2 |
| 수강중 | 2 |
| 완료 | 1 |

실제 출력 순서는 데이터베이스의 정렬 규칙에 따라 달라질 수 있으므로, 위 표는 논리적 결과 예시로 이해하면 됩니다.

`GROUP BY`에서 기억할 규칙은 다음 한 문장입니다.

```text
SELECT의 일반 컬럼은 GROUP BY 기준에 포함되어야 한다.
```

---

## 9. 강의별 수강신청 건수와 고유 학생 수 구하기

강의별 집계를 할 때는 `COUNT(*)`, `COUNT(e.id)`, `COUNT(DISTINCT e.student_id)`를 구분해야 합니다.

```text
COUNT(*)
결과 행 전체 수

COUNT(e.id)
NULL이 아닌 실제 수강신청 행 수

COUNT(DISTINCT e.student_id)
중복을 제거한 고유 학생 수
```

현재 데이터베이스는 같은 학생의 같은 강의 중복 신청을 기본적으로 금지하지 않습니다. 따라서 `COUNT(e.id)`를 항상 수강생 수라고 부르면 의미가 흐려질 수 있습니다.

```sql
SELECT
    c.id AS course_id,
    c.title AS course_title,
    COUNT(e.id) AS enrollment_count,
    COUNT(DISTINCT e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
ORDER BY c.id;
```

| course_id | course_title | enrollment_count | student_count |
| ---: | --- | ---: | ---: |
| 1 | 데이터베이스 입문 | 2 | 2 |
| 2 | 정규화 실습 | 1 | 1 |
| 3 | 파이썬 데이터 분석 | 2 | 2 |
| 4 | 집계 쿼리 실습 | 0 | 0 |

설명은 다음처럼 구분하는 편이 정확합니다.

```text
- enrollment_count: 수강신청 행 수
- student_count: 고유 학생 수
- 현재 샘플에서는 값이 같을 수 있다.
- 재신청 데이터가 생기면 두 값은 달라질 수 있다.
- 수강신청이 없는 강의는 두 값 모두 0이다.
```

---

## 10. 강의별 결제금액 합계 구하기

이 장에서는 `SUM(paid_amount)`를 강의별 결제금액 합계로 설명합니다.

![강의별 신청 건수와 결제금액 집계](../../images/chapter08/ch08_06_course_revenue_summary.svg)

그림 8-6 강의별 신청 건수와 결제금액 집계

```sql
SELECT
    c.id AS course_id,
    c.title AS course_title,
    COALESCE(SUM(e.paid_amount), 0) AS total_paid_amount
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
ORDER BY c.id;
```

`COALESCE`를 사용하는 이유는 수강신청이 없는 강의의 `SUM` 결과가 `NULL`이기 때문입니다. 이를 0으로 바꾸면 비교와 해석이 쉬워집니다.

> 이 예제의 `SUM(paid_amount)`는 저장된 결제금액의 단순 합계입니다.
>
> 실제 매출을 계산하려면 취소, 환불, 결제 성공 여부와 매출 인식 기준을 별도로 반영해야 합니다.

따라서 이 장에서는 가능하면 `결제금액 합계`, `total_paid_amount`라는 표현을 우선 사용합니다.

---

## 11. 강사별 개설 강의 수 구하기

강사별 개설 강의 수는 다음처럼 구할 수 있습니다.

```sql
SELECT
    i.name AS instructor_name,
    COUNT(c.id) AS course_count
FROM instructors AS i
LEFT JOIN courses AS c ON i.id = c.instructor_id
GROUP BY i.id, i.name
ORDER BY i.id;
```

이 예제에서는 세 강사 모두 강의를 하나 이상 가지고 있으므로 결과는 3행입니다. 아직 강의를 개설하지 않은 강사도 포함하려면 LEFT JOIN이 적절합니다.

---

## 12. HAVING과 WHERE의 차이

`WHERE`는 그룹화 전에 개별 행을 필터링하고, `HAVING`은 그룹화 후 집계 결과를 필터링합니다.

![집계 쿼리의 논리적 처리 흐름](../../images/chapter08/ch08_07_where_group_having_order.svg)

그림 8-7 집계 쿼리의 논리적 처리 흐름

```sql
SELECT
    c.title AS course_title,
    COUNT(e.id) AS enrollment_count
FROM courses AS c
JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
HAVING COUNT(e.id) >= 2
ORDER BY c.id;
```

이 결과는 `데이터베이스 입문`, `파이썬 데이터 분석` 두 강의입니다.

논리적 처리 흐름은 다음처럼 이해할 수 있습니다.

```text
FROM / JOIN
-> WHERE
-> GROUP BY + 집계 계산
-> HAVING
-> SELECT
-> ORDER BY
```

> 이 순서는 초급 학습을 위한 논리적 처리 흐름입니다.
>
> SQL을 작성하는 문법 순서와 데이터베이스 내부의 물리적 실행 계획을 완전히 동일하게 표현한 것은 아닙니다.

수강중 상태만 대상으로 강의별 수강신청 건수를 구하면 다음과 같습니다.

```sql
SELECT
    c.title AS course_title,
    COUNT(e.id) AS enrollment_count
FROM courses AS c
JOIN enrollments AS e ON c.id = e.course_id
WHERE e.status = '수강중'
GROUP BY c.id, c.title
ORDER BY c.id;
```

이 장의 샘플에서는 `데이터베이스 입문` 2건만 남습니다.

---

## 13. AI가 만든 JOIN·집계 SQL 검토하기

AI에게 SQL 초안을 요청할 수는 있지만, JOIN과 집계 쿼리는 작은 조건 차이만으로도 결과가 크게 달라집니다.

![AI 생성 JOIN·집계 SQL 검토 흐름](../../images/chapter08/ch08_08_ai_join_sql_review_flow.svg)

그림 8-8 AI 생성 JOIN·집계 SQL 검토 흐름

검토할 핵심 기준은 다음과 같습니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 실제 FK 경로 | JOIN이 실제 PK·FK 관계를 따라 연결되는가? |
| JOIN 종류 | INNER JOIN과 LEFT JOIN 중 요구사항에 맞는가? |
| 기준 행 | 결과 한 행의 기준이 enrollments인지 students인지 분명한가? |
| GROUP BY | 일반 컬럼이 GROUP BY에 맞게 작성되었는가? |
| COUNT 대상 | COUNT(*)인지 COUNT(e.id)인지 의도가 분명한가? |
| DISTINCT 필요 여부 | 고유 학생 수라면 COUNT(DISTINCT e.student_id)가 필요한가? |
| NULL 처리 | 수강신청이 없는 강의의 합계를 0으로 보여야 하는가? |
| 검산 | 원본 행 수와 수동 계산으로 결과를 다시 확인했는가? |

AI SQL은 정답이 아니라 초안입니다. 문법만 맞는지 보는 것으로는 충분하지 않습니다. JOIN으로 행이 중복되면 SUM이 커질 수 있고, LEFT JOIN에서 COUNT(*)를 쓰면 없는 신청도 1건처럼 보일 수 있습니다. 따라서 기본 건수, 합계, 개별 원본 행을 별도 SQL로 반드시 다시 검산해야 합니다.

---

## 14. 자주 하는 실수

### 실수 1. 컬럼 이름이 비슷하다는 이유로 JOIN한다

JOIN은 이름이 비슷한 컬럼을 대충 연결하는 기능이 아니라 실제 FK와 PK 관계를 따라 연결하는 작업입니다.

### 실수 2. 기준 행을 먼저 정하지 않는다

수강신청 현황을 본다면 기준 행은 `enrollments` 한 건입니다. 기준 행을 정하지 않으면 결과 행 수 해석이 흔들립니다.

### 실수 3. LEFT JOIN 결과를 왼쪽 테이블 행 수와 항상 같다고 생각한다

왼쪽 한 행에 오른쪽 일치 행이 여러 개면 결과도 여러 행입니다.

### 실수 4. COUNT(*)와 COUNT(e.id)를 같은 의미로 설명한다

LEFT JOIN에서는 두 표현이 다른 결과를 만들 수 있습니다.

### 실수 5. 결제금액 합계를 최종 매출로 단정한다

`SUM(paid_amount)`는 저장된 값의 합계일 뿐이며, 실제 매출 정책은 별도로 검토해야 합니다.

---

## 15. 스스로 확인하기

### 15.1 개념 확인

1. INNER JOIN과 LEFT JOIN의 포함 범위 차이를 설명해 보세요.
2. Chapter 08에서 기준 행이 `enrollments`라고 말하는 이유를 설명해 보세요.
3. `COUNT(*)`, `COUNT(e.id)`, `COUNT(DISTINCT e.student_id)`의 차이를 설명해 보세요.
4. `COALESCE(SUM(e.paid_amount), 0)`이 필요한 이유를 설명해 보세요.
5. AI가 만든 JOIN·집계 SQL을 검토할 때 기본 건수와 합계를 왜 다시 확인해야 하는지 설명해 보세요.

### 15.2 SQL 작성 문제

```text
1. 학생별 수강신청 수를 조회한다.
2. 강의별 결제금액 합계를 조회한다.
3. 수강상태별 수강신청 수를 조회한다.
4. 강사별 개설 강의 수를 조회한다.
5. 수강신청 2건 이상인 강의만 조회한다.
```

---

## 16. 정리

이번 장의 핵심은 다음과 같습니다.

```text
1. JOIN은 정규화로 나뉜 사실을 조회 시점에 관계를 따라 연결하는 기술이다.
2. INNER JOIN은 일치하는 행만 포함하고, LEFT JOIN은 왼쪽 행을 모두 유지한다.
3. 결과 한 행의 기준을 먼저 정해야 행 수와 중복을 정확히 해석할 수 있다.
4. GROUP BY는 행을 그룹으로 묶고 그룹별 결과 한 행을 만든다.
5. COUNT(*)와 COUNT(e.id), COUNT(DISTINCT e.student_id)는 서로 다른 질문에 답한다.
6. 결제금액 합계는 실제 회계 매출과 같다고 단정할 수 없다.
7. AI SQL은 원본 행 수와 수동 계산으로 반드시 검증해야 한다.
```

### JOIN·집계 SQL 실행 전 확인표

| 확인 항목 | 확인 질문 |
| --- | --- |
| JOIN 대상 | 어떤 테이블을 연결해야 하는가? |
| JOIN 조건 | ON 조건이 실제 FK 관계와 맞는가? |
| JOIN 종류 | INNER JOIN과 LEFT JOIN 중 어느 것이 요구사항에 맞는가? |
| 기준 행 | 결과 한 행의 기준이 무엇인가? |
| 집계 함수 | COUNT, SUM, AVG 중 어떤 계산이 필요한가? |
| COUNT 대상 | COUNT(*)와 COUNT(오른쪽 테이블 컬럼)을 구분했는가? |
| GROUP BY | 일반 컬럼이 GROUP BY에 포함되었는가? |
| NULL 처리 | COALESCE가 필요한가? |
| 결과 검증 | 예상 행 수와 합계를 실제로 다시 확인했는가? |

---

## 17. 다음 장에서는

다음 장에서는 트랜잭션과 데이터 정합성을 다룹니다.

Chapter 09에서는 Chapter 08에서 조회와 집계로 확인한 데이터를 바탕으로, 여러 변경 작업이 함께 성공하거나 함께 실패해야 하는 이유를 살펴봅니다.
