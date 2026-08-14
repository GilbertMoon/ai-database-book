# [AI 시대의 데이터베이스 입문 10] PostgreSQL 인덱스와 EXPLAIN으로 SQL 성능 이해하기

안녕하세요. 아토믹데브입니다.

지난 Chapter 09에서는 트랜잭션으로 여러 데이터 변경을 안전하게 묶는 방법을 배웠습니다.

이번 시간에는 데이터가 많아졌을 때 SQL이 왜 느려지는지, PostgreSQL이 어떤 방식으로 데이터를 찾는지, 그리고 **인덱스(Index)가 실제로 도움이 되는지 실행 계획으로 검증하는 방법**을 배웁니다.

중요한 점은 인덱스를 무조건 만드는 것이 아닙니다.

```text
조회 질문 확인
→ 실행 계획 측정
→ 인덱스 후보 생성
→ 같은 SQL 다시 측정
→ 실제 효과 비교
```

이 순서가 핵심입니다.

---

## 오늘 배울 내용

이번 글을 끝까지 따라오면 다음 내용을 이해할 수 있습니다.

- 인덱스가 필요한 이유
- PostgreSQL B-tree 인덱스의 기본 개념
- `PRIMARY KEY`, `UNIQUE`와 자동 인덱스
- 외래키 컬럼에는 인덱스가 자동 생성되지 않는 이유
- `Seq Scan`, `Index Scan`, `Bitmap Heap Scan`
- `EXPLAIN`, `EXPLAIN ANALYZE`, `BUFFERS`
- 선택도와 반환 행 수
- 단일 인덱스와 복합 인덱스
- 인덱스 컬럼 순서
- 인덱스 전후 성능 비교 방법
- AI가 추천한 인덱스를 검증하는 방법

---

## STEP 1. 데이터가 적을 때는 인덱스 효과가 잘 보이지 않습니다

예를 들어 학생이 3명뿐인 테이블이 있다고 가정해 보겠습니다.

```sql
SELECT *
FROM students
WHERE email = 'minji@example.com';
```

3행 정도라면 PostgreSQL이 테이블 전체를 읽어도 매우 빠릅니다.

이런 작은 데이터에서는 인덱스를 만들어도 성능 차이가 거의 보이지 않을 수 있습니다.

그래서 이번 Chapter에서는 별도의 성능 실험용 스키마를 사용합니다.

```text
performance_lab
├── students
├── instructors
├── courses
└── enrollments
```

실험 데이터는 대략 다음 규모입니다.

| 테이블 | 예상 행 수 |
| --- | ---: |
| students | 10,003 |
| instructors | 2 |
| courses | 2,003 |
| enrollments | 100,005 |

이 정도가 되면 인덱스 전후의 실행 계획 차이를 확인하기 훨씬 쉬워집니다.

---

## STEP 2. 인덱스는 무엇일까요?

인덱스는 데이터를 더 빠르게 찾기 위한 **보조 자료구조**입니다.

쉽게 비유하면 책 뒤의 찾아보기와 비슷합니다.

```text
책 전체 페이지를 처음부터 읽기
→ Seq Scan과 비슷한 개념

찾아보기에서 단어를 찾고 해당 페이지로 이동
→ Index Scan과 비슷한 개념
```

PostgreSQL에서 기본적으로 생성하는 인덱스 방식은 B-tree입니다.

```sql
CREATE INDEX idx_students_email
ON performance_lab.students(email);
```

이제 `email` 조건으로 특정 학생을 찾을 때 PostgreSQL이 이 인덱스를 사용할 가능성이 생깁니다.

---

## STEP 3. 인덱스를 만들었다고 항상 사용하는 것은 아닙니다

이 부분이 매우 중요합니다.

```text
인덱스 존재 ≠ 인덱스 사용
```

PostgreSQL의 옵티마이저는 여러 실행 방법의 비용을 비교해 가장 유리하다고 판단한 계획을 선택합니다.

예를 들어 다음 SQL을 생각해 보겠습니다.

```sql
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';
```

이메일이 한 명만 반환된다면 인덱스가 유리할 가능성이 높습니다.

반대로 다음 조건처럼 테이블의 많은 행을 반환한다면 전체 테이블을 읽는 것이 더 효율적일 수 있습니다.

```sql
SELECT *
FROM performance_lab.enrollments
WHERE status = '수강중';
```

만약 전체 100,005행 중 약 30%가 `수강중`이라면 PostgreSQL은 인덱스보다 `Seq Scan`을 선택할 수 있습니다.

---

## STEP 4. 선택도(Selectivity)를 이해해 봅시다

선택도는 조건이 전체 행 중 얼마나 적은 행을 선택하는지 판단하는 데 도움이 됩니다.

예를 들어 다음과 같습니다.

| 조건 | 반환 행 | 전체 대비 |
| --- | ---: | ---: |
| `student_id = 5000` | 10 | 약 0.01% |
| `course_id = 1500` | 50 | 약 0.05% |
| `course_id = 1500 AND status = '수강중'` | 15 | 약 0.015% |
| `status = '수강중'` | 30,001 | 약 30% |

보통 아주 적은 행을 찾는 조건은 인덱스 후보가 되기 쉽습니다.

하지만 선택도만 보고 결정하면 안 됩니다.

PostgreSQL은 다음 요소도 함께 고려합니다.

```text
테이블 크기
필요한 컬럼 수
정렬 여부
통계 정보
캐시 상태
디스크 읽기 비용
```

---

## STEP 5. 실행 계획은 EXPLAIN으로 확인합니다

다음처럼 SQL 앞에 `EXPLAIN`을 붙입니다.

```sql
EXPLAIN
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';
```

`EXPLAIN`은 SQL을 실제로 실행하지 않고 PostgreSQL이 어떤 방식으로 실행하려고 하는지 보여 줍니다.

대표적으로 다음과 같은 항목을 볼 수 있습니다.

```text
Seq Scan
Index Scan
Bitmap Heap Scan
Nested Loop
Hash Join
Sort
Aggregate
```

처음에는 모든 항목을 외우지 않아도 됩니다.

먼저 다음 질문을 합니다.

```text
전체 테이블을 읽는가?
인덱스를 사용하는가?
예상 행 수는 얼마인가?
비용(cost)은 얼마나 되는가?
```

---

## STEP 6. 실제 실행 결과는 EXPLAIN ANALYZE로 확인합니다

실제 실행 결과까지 보고 싶다면 다음을 사용합니다.

```sql
EXPLAIN ANALYZE
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';
```

`EXPLAIN ANALYZE`는 SQL을 실제로 실행합니다.

따라서 `SELECT`는 비교적 안전하지만, `UPDATE`, `DELETE`, `INSERT`에 사용할 때는 매우 주의해야 합니다.

실행 계획에서 다음 항목을 비교합니다.

```text
estimated rows
actual rows
planning time
execution time
```

예상 행 수와 실제 행 수가 크게 다르면 통계 정보가 오래되었거나 데이터 분포가 예상과 다를 수 있습니다.

---

## STEP 7. BUFFERS로 읽은 페이지도 확인할 수 있습니다

조금 더 자세히 보고 싶다면 다음처럼 작성할 수 있습니다.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';
```

`BUFFERS`를 사용하면 메모리나 디스크에서 얼마나 많은 페이지를 읽었는지 확인하는 데 도움이 됩니다.

성능 비교 시 실행 시간만 보는 것보다 다음을 함께 보는 것이 좋습니다.

```text
실행 계획
실제 행 수
버퍼 읽기
실행 시간
```

---

## STEP 8. Seq Scan은 나쁜 것이 아닙니다

초보자가 흔히 하는 오해입니다.

```text
Seq Scan = 느림 = 잘못된 실행 계획
```

이렇게 생각하면 안 됩니다.

테이블이 작거나 많은 행을 반환해야 한다면 순차 스캔이 더 효율적일 수 있습니다.

예를 들어 전체 행의 30%를 읽어야 하는데 인덱스로 한 행씩 테이블을 다시 찾아가면 오히려 비용이 더 커질 수 있습니다.

따라서 목표는 다음이 아닙니다.

```text
Seq Scan을 무조건 없앤다.
```

목표는 다음입니다.

```text
현재 조회에서 가장 합리적인 실행 계획인지 확인한다.
```

---

## STEP 9. PRIMARY KEY와 UNIQUE는 인덱스를 자동 생성합니다

PostgreSQL에서는 기본키와 고유 제약조건을 만들면 이를 지원하는 고유 인덱스가 자동으로 생성됩니다.

예를 들어 다음과 같습니다.

```sql
CREATE TABLE sample_students (
    id INTEGER PRIMARY KEY,
    email VARCHAR(100) UNIQUE
);
```

일반적으로 다음 컬럼에는 별도의 같은 인덱스를 중복해서 만들 필요가 없습니다.

```text
PRIMARY KEY 컬럼
UNIQUE 제약조건 컬럼
```

인덱스를 추가하기 전에 이미 존재하는 인덱스를 먼저 확인해야 합니다.

---

## STEP 10. 외래키 컬럼에는 인덱스가 자동 생성되지 않습니다

이 부분도 중요합니다.

PostgreSQL에서 외래키를 생성했다고 해서 자식 테이블의 외래키 컬럼에 인덱스가 자동으로 생성되는 것은 아닙니다.

예를 들어 다음과 같습니다.

```text
enrollments.student_id
→ students.id 참조

enrollments.course_id
→ courses.id 참조
```

`students.id`, `courses.id`는 기본키이므로 인덱스가 있습니다.

하지만 `enrollments.student_id`, `enrollments.course_id`는 별도로 인덱스를 검토해야 합니다.

다음 조회가 자주 사용된다면 후보가 될 수 있습니다.

```sql
SELECT *
FROM performance_lab.enrollments
WHERE student_id = 5000;
```

후보 인덱스:

```sql
CREATE INDEX idx_enrollments_student_id
ON performance_lab.enrollments(student_id);
```

---

## STEP 11. 인덱스 후보는 실제 조회 패턴에서 찾습니다

다음 조건을 중심으로 후보를 찾습니다.

```text
WHERE
JOIN
ORDER BY
LIMIT
```

예를 들어 자주 사용하는 SQL이 다음과 같다고 가정합니다.

```sql
SELECT id, student_id, course_id, status
FROM performance_lab.enrollments
WHERE student_id = 5000;
```

`student_id`는 좋은 후보입니다.

하지만 컬럼이 테이블에 있다는 이유만으로 인덱스를 만들면 안 됩니다.

```text
사용되지 않는 컬럼
자주 조회하지 않는 컬럼
값의 종류가 너무 적은 컬럼
```

이런 경우 인덱스가 도움이 되지 않거나 오히려 비용만 늘릴 수 있습니다.

---

## STEP 12. 인덱스 생성 전 기준 계획을 먼저 기록합니다

인덱스를 만들기 전에 반드시 기준 계획을 저장합니다.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status
FROM performance_lab.enrollments
WHERE student_id = 5000;
```

이 결과에서 다음을 기록합니다.

```text
Scan 방식
actual rows
Buffers
Execution Time
```

그 다음 인덱스를 만듭니다.

```sql
CREATE INDEX idx_performance_enrollments_student_id
ON performance_lab.enrollments(student_id);
```

그리고 같은 SQL을 다시 실행합니다.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, student_id, course_id, status
FROM performance_lab.enrollments
WHERE student_id = 5000;
```

이제 전후를 비교합니다.

---

## STEP 13. 같은 조건으로 비교해야 합니다

정확한 성능 비교를 위해 다음 조건을 가능한 한 동일하게 유지해야 합니다.

```text
같은 데이터
같은 SQL
같은 통계 상태
같은 컬럼
같은 조건
```

인덱스 전에는 10만 행, 인덱스 후에는 100만 행을 사용한다면 공정한 비교가 아닙니다.

실험 데이터가 바뀌었다면 다시 기준 계획부터 측정해야 합니다.

---

## STEP 14. ANALYZE로 통계 정보를 갱신합니다

PostgreSQL 옵티마이저는 테이블 통계를 사용해 실행 계획을 결정합니다.

대량 데이터를 새로 입력했다면 다음을 실행합니다.

```sql
ANALYZE performance_lab.students;
ANALYZE performance_lab.courses;
ANALYZE performance_lab.enrollments;
```

통계가 오래되면 예상 행 수와 실제 행 수가 크게 다를 수 있고 잘못된 계획이 선택될 가능성도 높아집니다.

---

## STEP 15. 복합 인덱스를 이해해 봅시다

두 컬럼을 함께 자주 조회한다면 복합 인덱스를 검토할 수 있습니다.

```sql
CREATE INDEX idx_enrollments_course_status
ON performance_lab.enrollments(course_id, status);
```

예를 들어 다음 조회가 자주 사용될 수 있습니다.

```sql
SELECT *
FROM performance_lab.enrollments
WHERE course_id = 1500
  AND status = '수강중';
```

이 경우 `(course_id, status)` 복합 인덱스가 후보가 됩니다.

---

## STEP 16. 복합 인덱스는 컬럼 순서가 중요합니다

다음 두 인덱스는 동일하지 않습니다.

```sql
(course_id, status)
```

```sql
(status, course_id)
```

B-tree 복합 인덱스에서는 선두 컬럼이 중요한 역할을 합니다.

PostgreSQL 16 기준으로 다음 인덱스를 생각해 보겠습니다.

```sql
CREATE INDEX idx_course_status
ON performance_lab.enrollments(course_id, status);
```

다음 조건은 잘 활용할 가능성이 높습니다.

```sql
WHERE course_id = 1500
```

```sql
WHERE course_id = 1500
  AND status = '수강중'
```

반면 다음처럼 후행 컬럼인 `status`만 조건에 사용하면 같은 방식으로 탐색 범위를 줄이기 어렵습니다.

```sql
WHERE status = '수강중'
```

> 참고: PostgreSQL 18부터 B-tree Skip Scan이 추가되어 일부 계획은 PostgreSQL 16과 달라질 수 있습니다. 실습 결과에는 서버 버전을 함께 기록하는 것이 좋습니다.

---

## STEP 17. Bitmap Heap Scan도 정상적인 계획입니다

PostgreSQL은 인덱스를 사용하면서도 바로 한 행씩 읽는 대신, 먼저 필요한 위치를 모은 뒤 테이블 페이지를 읽는 방식을 사용할 수 있습니다.

이때 다음과 같은 실행 계획이 나타날 수 있습니다.

```text
Bitmap Index Scan
→ Bitmap Heap Scan
```

이 역시 정상적인 인덱스 사용 방식입니다.

따라서 실행 계획에 `Index Scan`이라는 글자가 없다고 해서 인덱스를 사용하지 않았다고 단정하면 안 됩니다.

---

## STEP 18. 인덱스는 쓰기 비용도 만듭니다

인덱스는 조회 성능을 높일 수 있지만 공짜가 아닙니다.

데이터가 변경될 때 인덱스도 함께 관리해야 합니다.

```text
INSERT
UPDATE
DELETE
```

그리고 추가 저장 공간도 필요합니다.

따라서 인덱스를 많이 만든다고 좋은 데이터베이스가 되는 것은 아닙니다.

```text
조회 성능 이점
vs
쓰기 비용 + 저장 공간 + 관리 비용
```

이 균형을 고려해야 합니다.

---

## STEP 19. 운영 환경에서는 CREATE INDEX도 주의해야 합니다

일반적인 인덱스 생성은 다음과 같습니다.

```sql
CREATE INDEX idx_example
ON some_table(some_column);
```

하지만 큰 운영 테이블에서 인덱스를 생성하면 다른 작업에 영향을 줄 수 있습니다.

PostgreSQL은 운영 상황에서 다음 방식도 제공합니다.

```sql
CREATE INDEX CONCURRENTLY idx_example
ON some_table(some_column);
```

`CONCURRENTLY`는 쓰기 작업에 대한 영향을 줄이는 데 도움이 될 수 있지만 더 오래 걸릴 수 있고 일반 `CREATE INDEX`와 다른 제약이 있습니다.

입문 실습에서는 일반 `CREATE INDEX`를 사용하고, 운영 환경에서는 반드시 공식 문서와 현재 서비스 조건을 함께 확인합니다.

---

## STEP 20. 인덱스를 만든 뒤 유지할지 결정합니다

실험이 끝나면 다음 내용을 기록합니다.

```text
어떤 SQL을 개선하려고 만들었는가?
인덱스 전 실행 계획은 무엇이었는가?
인덱스 후 실행 계획은 무엇이었는가?
Buffers와 실행 시간은 어떻게 바뀌었는가?
실제 반환 행 수는 같은가?
쓰기 비용을 감수할 만큼 이점이 있는가?
```

효과가 없다면 인덱스를 제거하는 것도 정상적인 결정입니다.

```sql
DROP INDEX performance_lab.idx_example;
```

인덱스를 만들었다는 사실 자체가 성공이 아닙니다.

**실제 조회 비용이 개선되고 그 이점이 유지 비용보다 큰지**가 중요합니다.

---

## AI 활용 실습 1. 인덱스 후보를 추천받아 봅시다

ChatGPT 또는 Codex에 다음과 같이 요청해 보세요.

```text
PostgreSQL에서 다음 SQL을 자주 실행합니다.

SELECT id, student_id, course_id, status
FROM performance_lab.enrollments
WHERE student_id = 5000;

테이블에는 약 100,000행이 있습니다.

어떤 인덱스를 후보로 검토할 수 있는지 설명하고,
CREATE INDEX SQL을 작성해 주세요.

단, 인덱스가 실제로 도움이 되는지는
EXPLAIN ANALYZE로 검증해야 한다는 점도 설명해 주세요.
```

AI의 답을 받은 뒤 바로 적용하지 말고 다음을 확인합니다.

```text
실제 WHERE 조건을 기준으로 했는가?
이미 같은 인덱스가 존재하지 않는가?
반환 행 수는 얼마나 되는가?
인덱스 전후 실행 계획을 비교했는가?
```

---

## AI 활용 실습 2. 실행 계획을 해석하게 해 봅시다

다음 프롬프트를 활용해 보세요.

```text
나는 PostgreSQL을 처음 배우는 학생입니다.

EXPLAIN ANALYZE 결과에
Seq Scan, Index Scan, Bitmap Heap Scan,
actual rows, cost, execution time이 나옵니다.

각 항목을 초보자가 이해할 수 있게 설명하고,
인덱스 전후 성능을 비교할 때 어떤 값을 봐야 하는지
체크리스트로 정리해 주세요.
```

AI의 설명이 실제 실행 결과와 맞는지 직접 비교하세요.

---

## 오늘의 핵심 정리

이번 Chapter에서 꼭 기억할 내용입니다.

```text
인덱스
→ 데이터를 더 빠르게 찾기 위한 보조 구조

B-tree
→ PostgreSQL 기본 인덱스 방식

EXPLAIN
→ 예상 실행 계획 확인

EXPLAIN ANALYZE
→ 실제 실행 결과까지 확인

BUFFERS
→ 읽은 페이지 확인

Seq Scan
→ 전체 테이블 순차 읽기

Index Scan
→ 인덱스를 이용한 행 탐색

복합 인덱스
→ 여러 컬럼을 함께 사용
```

그리고 가장 중요한 실무 흐름은 다음입니다.

```text
느린 SQL 확인
→ 실제 조회 패턴 분석
→ 기준 실행 계획 기록
→ 인덱스 후보 생성
→ 같은 SQL 다시 측정
→ 결과와 실행 계획 비교
→ 유지 또는 제거 결정
```

AI 시대에는 다음 원칙이 특히 중요합니다.

```text
AI가 인덱스를 추천할 수 있다.
하지만 실제 데이터 분포와 실행 계획을 모른 채
추천만 보고 적용하면 안 된다.

추천 → EXPLAIN → 측정 → 검증 → 결정
```

---

## 다음 시간에는

다음 Chapter에서는 데이터베이스를 안전하게 운영하기 위한 **사용자·역할·권한, 최소 권한 원칙, 백업과 복구**를 배웁니다.

SQL이 잘 실행되는 것만큼 중요한 것이 누가 어떤 데이터에 접근할 수 있는지, 문제가 생겼을 때 어떻게 복구할 수 있는지입니다.

---

## 관련 글

- Chapter 09. 트랜잭션으로 데이터 정합성 지키기
- Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법

---

#PostgreSQL #인덱스 #EXPLAIN #EXPLAINANALYZE #SQL성능 #데이터베이스 #DBeaver #BTree #ChatGPT #데이터베이스강의