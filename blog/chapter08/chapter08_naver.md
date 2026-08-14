# [AI 시대의 데이터베이스 입문 08] JOIN과 GROUP BY로 서비스 질문에 답하기

안녕하세요. 아토믹데브입니다.

지난 Chapter 07에서는 `course_project` 스키마에 온라인 강의 수강신청 데이터베이스를 완성했습니다.

이번 시간에는 이제 저장된 데이터를 서로 연결하고, 실제 서비스에서 자주 나오는 질문에 SQL로 답해 봅니다.

핵심은 두 가지입니다.

```text
JOIN
→ 여러 테이블에 나누어 저장된 데이터를 관계에 따라 연결

집계
→ COUNT, SUM, AVG, GROUP BY 등을 사용해 요약
```

하지만 문법보다 더 중요한 것은 **결과 한 행의 의미와 포함 범위**를 먼저 정하는 것입니다.

---

## 오늘 배울 내용

이번 글을 끝까지 따라오면 다음 내용을 설명하고 직접 실행할 수 있습니다.

- `INNER JOIN`과 `LEFT JOIN`의 차이
- PK/FK 관계를 기준으로 테이블 연결하기
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT ...)`의 차이
- `SUM`, `AVG`, `MIN`, `MAX`
- `GROUP BY`와 `HAVING`
- 신청이 없는 강의도 0으로 표시하는 방법
- `COALESCE`로 `NULL`을 0으로 바꾸는 방법
- 여러 1:N JOIN에서 과대 집계가 생기는 이유
- AI가 만든 JOIN SQL을 검증하는 방법

---

## STEP 1. Chapter 07의 기준 상태를 확인합니다

이번 Chapter는 Chapter 07에서 만든 데이터를 그대로 사용합니다.

기준 테이블은 다음 네 개입니다.

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

기준 행 수는 다음과 같습니다.

| 테이블 | 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 5 |

먼저 현재 연결을 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

현재 데이터베이스가 `ai_database_book`인지 확인합니다.

---

## STEP 2. SQL을 쓰기 전에 질문부터 정확하게 정의합니다

예를 들어 다음 질문을 생각해 보겠습니다.

```text
강의별 수강생 수를 보여 주세요.
```

이 문장은 생각보다 모호합니다.

```text
수강신청 행 수를 의미하는가?
고유 학생 수를 의미하는가?
취소된 신청도 포함하는가?
완료 상태도 포함하는가?
신청이 없는 강의도 0으로 보여야 하는가?
```

따라서 SQL을 쓰기 전에 먼저 아래를 정해야 합니다.

| 항목 | 확인 질문 |
| --- | --- |
| 결과 한 행 | 학생 1명? 강의 1개? 신청 1건? |
| 포함 범위 | 연결된 행만? 연결되지 않은 부모도 포함? |
| 상태 범위 | 신청/수강중/완료/취소 중 무엇을 포함? |
| 집계 기준 | 신청 건수? 고유 학생 수? 금액 합계? |
| 0 처리 | 데이터가 없으면 제외? 0으로 표시? |

이 원칙을 먼저 기억하세요.

```text
SQL 문법보다 먼저
무엇을 세는지와 무엇을 포함하는지 정한다.
```

---

## STEP 3. JOIN 경로는 ERD의 PK/FK 관계를 따라갑니다

수강신청 한 건에 학생 이름과 강의 제목을 붙이려면 다음 경로를 사용합니다.

```text
enrollments.student_id → students.id
enrollments.course_id  → courses.id
courses.instructor_id   → instructors.id
```

즉 이름이 비슷하다고 연결하는 것이 아니라 **실제 외래키 관계를 따라 연결**해야 합니다.

잘못된 생각:

```text
학생 이름이 같으니까 이름으로 JOIN하자
```

올바른 생각:

```text
student_id와 students.id를 연결한다
```

---

## STEP 4. INNER JOIN으로 신청 현황을 조회해 봅시다

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM course_project.enrollments AS e
INNER JOIN course_project.students AS s
    ON e.student_id = s.id
INNER JOIN course_project.courses AS c
    ON e.course_id = c.id
ORDER BY e.id;
```

이 결과의 한 행은 다음을 의미합니다.

```text
수강신청 한 건
```

학생이 여러 번 등장하는 것은 중복 오류가 아닙니다.

한 학생이 여러 강의를 신청했다면 신청 건수만큼 반복되는 것이 정상입니다.

```text
원본 enrollments 5건
→ JOIN 결과 5행
```

JOIN 후 행 수가 늘었다고 바로 `DISTINCT`를 붙이면 안 됩니다.

먼저 **결과 한 행의 기준이 무엇인지** 확인해야 합니다.

---

## STEP 5. 여러 테이블을 JOIN해 봅시다

강사 이름까지 표시하려면 `courses`를 거쳐 `instructors`까지 연결합니다.

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    c.title AS course_title,
    i.name AS instructor_name,
    e.status,
    e.recorded_amount
FROM course_project.enrollments AS e
JOIN course_project.students AS s
    ON e.student_id = s.id
JOIN course_project.courses AS c
    ON e.course_id = c.id
JOIN course_project.instructors AS i
    ON c.instructor_id = i.id
ORDER BY e.id;
```

이렇게 여러 테이블을 연결해도 결과 한 행의 기준은 여전히 `enrollments` 한 건입니다.

---

## STEP 6. LEFT JOIN은 언제 사용할까요?

`INNER JOIN`은 양쪽에 모두 존재하는 연결된 행만 보여 줍니다.

반면 `LEFT JOIN`은 왼쪽 테이블의 행을 모두 유지합니다.

예를 들어 **신청이 없는 학생도 포함해서 학생별 신청 건수**를 보고 싶다면 학생을 왼쪽에 둡니다.

```sql
SELECT
    s.id,
    s.name,
    COUNT(e.id) AS enrollment_count
FROM course_project.students AS s
LEFT JOIN course_project.enrollments AS e
    ON e.student_id = s.id
GROUP BY s.id, s.name
ORDER BY s.id;
```

신청이 없는 학생도 결과에 남고 신청 수는 0이 됩니다.

이때 중요한 점은 `COUNT(*)`가 아니라 `COUNT(e.id)`를 사용하는 것입니다.

왜냐하면 `LEFT JOIN` 결과에서 부모 행은 남기 때문에 `COUNT(*)`는 최소 1행을 셀 수 있기 때문입니다.

---

## STEP 7. COUNT의 세 가지 차이를 알아봅시다

### COUNT(*)

결과 행 자체를 셉니다.

```sql
SELECT COUNT(*)
FROM course_project.enrollments;
```

### COUNT(column)

해당 열이 `NULL`이 아닌 행만 셉니다.

```sql
SELECT COUNT(e.id)
FROM course_project.enrollments AS e;
```

### COUNT(DISTINCT column)

중복을 제거한 고유값 개수를 셉니다.

```sql
SELECT COUNT(DISTINCT student_id)
FROM course_project.enrollments;
```

이 차이를 구분해야 “신청 건수”와 “수강생 수”를 혼동하지 않습니다.

```text
신청 건수
→ COUNT(*)

고유 학생 수
→ COUNT(DISTINCT student_id)
```

---

## STEP 8. 전체 신청 금액을 SUM으로 계산해 봅시다

```sql
SELECT
    SUM(recorded_amount) AS total_recorded_amount
FROM course_project.enrollments;
```

현재 기준 데이터의 전체 신청 이력 금액 합계는 다음과 같습니다.

```text
590000
```

하지만 이 값을 실제 회계 매출이라고 부르면 안 됩니다.

`recorded_amount`는 신청 당시 기록한 금액이고, 결제 성공/실패/환불 정보는 현재 프로젝트 범위에 없기 때문입니다.

따라서 다음처럼 해석해야 합니다.

```text
전체 신청 이력 기준 기록 금액 합계
```

---

## STEP 9. 상태별로 집계해 봅시다

```sql
SELECT
    status,
    COUNT(*) AS enrollment_count,
    SUM(recorded_amount) AS total_amount
FROM course_project.enrollments
GROUP BY status
ORDER BY status;
```

이제 `GROUP BY`의 의미를 생각해 보겠습니다.

```text
같은 status 값을 가진 행들을 하나의 그룹으로 묶고
각 그룹마다 COUNT, SUM을 계산한다.
```

---

## STEP 10. 강의별 신청 건수를 계산해 봅시다

```sql
SELECT
    c.id,
    c.title,
    COUNT(e.id) AS enrollment_count
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY c.id;
```

여기서 `LEFT JOIN`을 사용했기 때문에 신청이 없는 강의도 0으로 표시할 수 있습니다.

---

## STEP 11. 고유 학생 수를 계산해 봅시다

같은 학생이 같은 강의에 여러 이력을 가질 수 있다고 가정하면 신청 건수와 고유 학생 수는 달라질 수 있습니다.

```sql
SELECT
    c.title,
    COUNT(e.id) AS enrollment_count,
    COUNT(DISTINCT e.student_id) AS distinct_student_count
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY c.id;
```

이처럼 무엇을 세는지에 따라 COUNT 식이 달라집니다.

---

## STEP 12. HAVING으로 그룹 결과를 필터링해 봅시다

`WHERE`는 그룹화 전에 개별 행을 필터링합니다.

`HAVING`은 그룹화 후 집계 결과를 필터링합니다.

예를 들어 신청이 2건 이상인 강의만 보고 싶다면 다음처럼 작성합니다.

```sql
SELECT
    c.title,
    COUNT(e.id) AS enrollment_count
FROM course_project.courses AS c
JOIN course_project.enrollments AS e
    ON e.course_id = c.id
GROUP BY c.id, c.title
HAVING COUNT(e.id) >= 2
ORDER BY enrollment_count DESC;
```

기억하기 쉽게 정리하면 다음과 같습니다.

```text
WHERE  → 행을 먼저 걸러냄
HAVING → 그룹 집계 후 결과를 걸러냄
```

---

## STEP 13. AVG, MIN, MAX도 사용해 봅시다

```sql
SELECT
    AVG(recorded_amount) AS avg_amount,
    MIN(recorded_amount) AS min_amount,
    MAX(recorded_amount) AS max_amount
FROM course_project.enrollments;
```

이 함수들은 다음처럼 사용합니다.

| 함수 | 의미 |
| --- | --- |
| `COUNT` | 개수 |
| `SUM` | 합계 |
| `AVG` | 평균 |
| `MIN` | 최솟값 |
| `MAX` | 최댓값 |

---

## STEP 14. COALESCE로 NULL을 0으로 바꿉니다

LEFT JOIN으로 집계할 때 `SUM()` 결과가 `NULL`이 될 수 있습니다.

이를 0으로 표시하려면 `COALESCE`를 사용합니다.

```sql
SELECT
    c.title,
    COALESCE(SUM(e.recorded_amount), 0) AS total_amount
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY c.id;
```

`COALESCE(a, b)`는 `a`가 `NULL`이면 `b`를 반환합니다.

---

## STEP 15. LEFT JOIN에서 ON과 WHERE 위치를 조심합니다

예를 들어 **취소가 아닌 신청 건수**를 강의별로 보고 싶다고 해 보겠습니다.

다음처럼 `WHERE`에 조건을 쓰면 신청이 없는 강의가 사라질 수 있습니다.

```sql
SELECT
    c.title,
    COUNT(e.id)
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON e.course_id = c.id
WHERE e.status <> '취소'
GROUP BY c.id, c.title;
```

`WHERE`가 `NULL`인 외부 JOIN 행을 제거하기 때문입니다.

신청이 없는 강의도 유지하려면 조건을 `ON`에 넣는 방식이 더 적절할 수 있습니다.

```sql
SELECT
    c.title,
    COUNT(e.id) AS non_cancel_count
FROM course_project.courses AS c
LEFT JOIN course_project.enrollments AS e
    ON e.course_id = c.id
   AND e.status <> '취소'
GROUP BY c.id, c.title
ORDER BY c.id;
```

이 차이는 JOIN 실무에서 매우 중요합니다.

---

## STEP 16. 신청이 없는 데이터를 찾는 방법

예를 들어 신청 이력이 없는 학생을 찾고 싶다면 다음처럼 작성할 수 있습니다.

```sql
SELECT
    s.id,
    s.name
FROM course_project.students AS s
LEFT JOIN course_project.enrollments AS e
    ON e.student_id = s.id
WHERE e.id IS NULL;
```

또는 `NOT EXISTS`를 사용할 수도 있습니다.

```sql
SELECT
    s.id,
    s.name
FROM course_project.students AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM course_project.enrollments AS e
    WHERE e.student_id = s.id
);
```

둘 다 “연결된 행이 없는 부모”를 찾는 대표적인 방법입니다.

---

## STEP 17. 상태 범위를 구분해야 합니다

이 프로젝트에서는 상태를 다음처럼 구분합니다.

```text
전체 신청 이력
→ 모든 상태

활성 신청
→ 신청, 수강중

취소 제외 신청 이력
→ 신청, 수강중, 완료

취소 신청
→ 취소
```

예를 들어 활성 신청만 집계하려면 다음과 같이 작성합니다.

```sql
SELECT
    COUNT(*) AS active_count,
    SUM(recorded_amount) AS active_amount
FROM course_project.enrollments
WHERE status IN ('신청', '수강중');
```

기준 데이터에서는 다음 값이 예상됩니다.

```text
active_count = 3
active_amount = 340000
```

---

## STEP 18. 여러 1:N JOIN에서 과대 집계를 조심합니다

실무에서 매우 자주 발생하는 오류입니다.

예를 들어 한 강의에 신청이 여러 건 있고, 강의에 태그도 여러 건 있다고 해 보겠습니다.

```text
courses 1:N enrollments
courses 1:N course_tags
```

이 두 테이블을 동시에 JOIN하면 행 수가 곱처럼 늘어날 수 있습니다.

```text
신청 3건 × 태그 2건
→ JOIN 결과 6행
```

그 상태에서 `SUM(recorded_amount)`를 하면 금액이 두 배로 계산될 수 있습니다.

해결 방법은 질문에 따라 다르지만 보통 다음을 검토합니다.

```text
각 1:N 관계를 먼저 별도 집계
→ 그 집계 결과를 부모 테이블에 JOIN
```

즉 JOIN 후 숫자가 커졌다면 무조건 데이터가 늘어난 것이 아니라 **관계 확장 때문에 행이 증폭된 것인지** 확인해야 합니다.

---

## STEP 19. 상세 결과와 집계 결과를 서로 검산합니다

집계 SQL만 실행하고 숫자를 믿으면 안 됩니다.

예를 들어 전체 신청 금액을 계산했다면 상세 행도 함께 확인합니다.

```sql
SELECT
    id,
    student_id,
    course_id,
    status,
    recorded_amount
FROM course_project.enrollments
ORDER BY id;
```

그리고 합계를 다시 계산합니다.

```text
100000
+ 120000
+ 100000
+ 150000
+ 120000
= 590000
```

집계 결과와 상세 데이터가 일치하는지 확인하는 습관이 중요합니다.

---

## AI 활용 실습 1. JOIN SQL 검토시키기

다음 프롬프트를 ChatGPT나 Codex에 입력해 보세요.

```text
나는 PostgreSQL을 공부하는 초보자입니다.

아래 테이블 관계가 있습니다.

students 1:N enrollments
courses 1:N enrollments
instructors 1:N courses

수강신청 한 건을 기준으로
학생 이름, 강의 제목, 강사 이름, 신청 상태를 조회하는 SQL을 작성해 주세요.

그리고 각 JOIN 조건이 어떤 PK/FK 관계를 사용하는지 설명해 주세요.
```

AI가 만든 SQL을 실행한 뒤 다음을 확인합니다.

```text
결과가 예상한 5행인가?
학생 이름으로 JOIN하지 않았는가?
강사 연결이 courses를 통해 이루어졌는가?
```

---

## AI 활용 실습 2. 집계 SQL의 오류를 찾게 해 보기

다음 프롬프트를 사용해 보세요.

```text
다음 요구사항에 맞는 PostgreSQL을 작성해 주세요.

- 모든 강의를 보여 준다.
- 강의별 활성 신청 수를 계산한다.
- 활성 상태는 '신청', '수강중'이다.
- 신청이 없는 강의도 0으로 표시한다.

SQL을 작성한 뒤
왜 LEFT JOIN이 필요한지,
왜 COUNT(*) 대신 COUNT(enrollment_id)를 사용하는지,
상태 조건을 ON과 WHERE 중 어디에 두는 것이 좋은지 설명해 주세요.
```

AI 답안을 받은 뒤 실제 데이터로 검증하세요.

---

## 오늘의 핵심 정리

이번 Chapter에서 꼭 기억해야 할 내용은 다음과 같습니다.

```text
JOIN
→ 정규화된 테이블을 관계에 따라 다시 연결

INNER JOIN
→ 연결된 행만 반환

LEFT JOIN
→ 왼쪽 부모 행을 모두 유지

COUNT(*)
→ 결과 행 수

COUNT(column)
→ NULL이 아닌 값 수

COUNT(DISTINCT column)
→ 고유값 수

GROUP BY
→ 같은 기준의 행을 그룹으로 묶음

HAVING
→ 그룹 집계 결과를 필터링

COALESCE
→ NULL 값을 원하는 기본값으로 변환
```

그리고 다음 원칙이 가장 중요합니다.

```text
1. 결과 한 행의 의미를 먼저 정한다.
2. 포함할 상태 범위를 먼저 정한다.
3. PK/FK 관계를 따라 JOIN한다.
4. 신청 건수와 고유 학생 수를 구분한다.
5. 상세 결과와 집계 결과를 서로 검산한다.
6. JOIN 후 행이 늘었다면 과대 집계를 의심한다.
```

---

## 다음 시간에는

다음 Chapter에서는 데이터를 여러 단계로 변경할 때 필요한 **트랜잭션(Transaction)** 을 배웁니다.

```text
BEGIN
COMMIT
ROLLBACK
```

을 직접 사용하면서 여러 SQL을 하나의 작업 단위로 묶고, 실패했을 때 안전하게 되돌리는 방법을 실습합니다.

---

## 관련 글

- Chapter 07. 온라인 강의 수강신청 DB 완성하기
- Chapter 09. 트랜잭션으로 데이터 정합성 지키기

---

#PostgreSQL #SQL #JOIN #GROUPBY #데이터베이스 #데이터분석 #ChatGPT #Codex #AI활용 #SQL기초