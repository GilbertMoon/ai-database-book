# Chapter 10. 인덱스와 성능 기초

---

## 이 장에서 살펴볼 내용

Chapter 08에서는 JOIN과 집계 쿼리로 여러 테이블을 조회했고, Chapter 09에서는 트랜잭션으로 데이터 변경을 안전하게 처리하는 방법을 살펴보았습니다. 이번 장에서는 데이터가 많아졌을 때 조회 경로가 왜 중요해지는지, PostgreSQL 인덱스와 실행 계획을 어떻게 읽어야 하는지 배웁니다.

Chapter 10은 이전 장과 같은 온라인 강의 도메인을 사용하지만, Chapter 09의 결제·좌석 트랜잭션 상태를 이어 쓰는 실습은 아닙니다. 인덱스와 실행 계획을 비교하기 위한 별도의 성능 실습 데이터셋을 다시 구성합니다.

> Chapter 10은 이전 장과 같은 온라인 강의 도메인을 사용하지만 인덱스와 실행 계획을 비교하기 위한 별도의 성능 실습 데이터셋을 다시 구성합니다. Chapter 09의 결제·좌석 트랜잭션 상태를 그대로 이어 사용하는 실습은 아닙니다.

이 장에서 다루는 핵심은 다음과 같습니다.

- 데이터가 많아지면 조회 경로가 왜 중요해지는가
- PostgreSQL B-tree 인덱스의 기본 역할
- PRIMARY KEY와 UNIQUE가 자동으로 만드는 인덱스
- FOREIGN KEY 자식 컬럼에는 인덱스가 자동 생성되지 않는다는 점
- Seq Scan, Index Scan, Bitmap Heap Scan의 차이
- WHERE, ORDER BY, JOIN 조건에서 인덱스 후보를 찾는 방법
- 복합 인덱스에서 선두 컬럼 순서가 중요한 이유
- EXPLAIN과 EXPLAIN ANALYZE의 차이
- 인덱스의 읽기 이점과 쓰기 비용
- AI가 추천한 인덱스를 실행 계획으로 검증하는 방법

---

## 1. 인덱스가 필요한 이유

작은 테이블에서는 전체 행을 읽어도 큰 문제가 보이지 않을 수 있습니다. 하지만 같은 SQL도 데이터가 수만 건, 수십만 건으로 늘어나면 느려질 수 있습니다.

```sql
SELECT id, name, email
FROM students
WHERE email = 'performance5000@example.com';
```

인덱스가 없다면 PostgreSQL은 조건에 맞는 행을 찾기 위해 테이블을 처음부터 끝까지 읽을 수 있습니다. 이런 접근을 `Seq Scan`이라고 부릅니다. 반대로 조건 컬럼에 적절한 인덱스가 있으면 인덱스를 먼저 탐색한 뒤 필요한 행으로 이동할 수 있습니다.

![데이터 증가와 인덱스 검토](../../images/chapter10/ch10_01_index_need_overview.svg)

그림 10-1 데이터 증가와 인덱스 검토

인덱스는 검색용 보조 구조입니다. 많이 만들수록 항상 좋아지는 장치가 아니라, 자주 쓰는 조회 패턴을 빠르게 만들기 위해 선택적으로 추가하는 구조입니다.

---

## 2. 실습 데이터셋과 안전 경고

이 장의 실습 파일은 다음 위치에 있습니다.

```text
code/chapter10/index_performance_practice.sql
```

> **실습 DB 확인**
>
> `index_performance_practice.sql`은 기존 실습 테이블을 삭제하고 성능 비교용 데이터를 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 먼저 `SELECT current_database();`로 연결 대상을 확인합니다. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

Chapter 09에서 `payments`가 `enrollments`를 참조했을 수 있으므로 Chapter 10 SQL은 `payments`를 먼저 삭제합니다.

```sql
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;
```

Chapter 10의 기본 테이블은 다음 네 개입니다.

```text
students(id, name, email, joined_at)
instructors(id, name, email, specialty)
courses(id, instructor_id, title, description, level, price, opened_at)
enrollments(id, student_id, course_id, enrolled_at, status, paid_amount)
```

기본 예제 데이터만으로는 성능 차이를 관찰하기 어렵기 때문에 성능 테스트 데이터를 추가로 만듭니다.

| 테이블 | 예제 데이터 | 자동 생성 데이터 | 최종 예상 행 수 |
| --- | ---: | ---: | ---: |
| students | 5 | 10,000 | 10,005 |
| instructors | 3 | 0 | 3 |
| courses | 5 | 2,000 | 2,005 |
| enrollments | 7 | 100,000 | 100,007 |

데이터 생성 뒤에는 통계를 갱신합니다.

```sql
ANALYZE students;
ANALYZE instructors;
ANALYZE courses;
ANALYZE enrollments;
```

`ANALYZE table_name`은 옵티마이저가 사용할 통계를 갱신하는 명령입니다. `EXPLAIN ANALYZE`와 이름이 비슷하지만 의미가 다릅니다.

---

## 3. 자동 생성 인덱스와 수동 인덱스

PostgreSQL은 PRIMARY KEY와 UNIQUE 제약조건을 유지하기 위해 고유 인덱스를 자동으로 만듭니다. 반면 FOREIGN KEY의 자식 컬럼에는 인덱스를 자동으로 만들지 않습니다.

| 구조 | PostgreSQL 인덱스 생성 | Chapter 10 처리 |
| --- | --- | --- |
| PRIMARY KEY | 고유 인덱스 자동 생성 | 별도 생성하지 않음 |
| UNIQUE | 고유 인덱스 자동 생성 | 기존 인덱스를 확인함 |
| FOREIGN KEY 자식 컬럼 | 자동 생성하지 않음 | 쿼리 패턴에 따라 수동 생성 검토 |
| 일반 컬럼 | 자동 생성하지 않음 | 필요할 때 수동 생성 |

`students.email`은 이미 UNIQUE 제약조건이 있으므로 고유 인덱스가 자동으로 존재합니다. 따라서 같은 컬럼에 별도 수동 인덱스를 추가하지 않습니다.

현재 인덱스 목록은 다음 SQL로 확인합니다.

```sql
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('students', 'instructors', 'courses', 'enrollments')
ORDER BY tablename, indexname;
```

자동 인덱스 이름은 제약조건 이름이나 PostgreSQL 환경에 따라 달라질 수 있습니다. 중요한 것은 이름을 외우는 것이 아니라 어떤 제약조건이 어떤 인덱스를 만들었는지 이해하는 것입니다.

---

## 4. Seq Scan과 Index Scan

`Seq Scan`은 테이블을 순차적으로 읽는 접근 방식입니다. 데이터가 적거나 대부분의 행을 읽어야 할 때는 Seq Scan이 합리적일 수 있습니다.

`Index Scan`은 인덱스를 사용해 조건에 맞는 위치를 찾는 방식입니다. 조건이 비교적 적은 행을 골라내고, 인덱스 탐색 비용보다 절약되는 읽기 비용이 클 때 유리합니다.

![Seq Scan과 Index Scan의 검색 경로](../../images/chapter10/ch10_02_table_scan_vs_index_scan.svg)

그림 10-2 Seq Scan과 Index Scan의 검색 경로

인덱스가 있어도 PostgreSQL이 Seq Scan을 선택할 수 있습니다. 이것은 오류가 아닙니다. 테이블 크기, 조건 선택도, 통계, 캐시 상태, 반환 행 수에 따라 전체 테이블을 읽는 편이 더 낫다고 판단할 수 있습니다.

---

## 5. WHERE 조건에서 인덱스 후보 찾기

인덱스 후보를 찾을 때는 단순히 WHERE에 등장하는 모든 컬럼을 고르지 않습니다. 다음 질문을 함께 봅니다.

- 자주 실행되는 쿼리인가?
- 테이블 데이터가 충분히 많은가?
- 조건이 전체 행 중 적은 행을 선택하는가?
- 이미 같은 역할을 하는 인덱스가 있는가?
- 쓰기 비용 증가보다 조회 이점이 큰가?

![WHERE 조건에서 인덱스 후보 판단하기](../../images/chapter10/ch10_03_where_index_candidate.svg)

그림 10-3 WHERE 조건에서 인덱스 후보 판단하기

| 쿼리 컬럼 | 현재 구조 | 판단 |
| --- | --- | --- |
| `students.email` | UNIQUE 인덱스 자동 존재 | 수동 인덱스 생성 불필요 |
| `courses.title` | 일반 컬럼 | 정확 일치 검색이 많으면 후보 |
| `enrollments.student_id` | FK지만 자동 인덱스 없음 | 학생별 조회가 많으면 후보 |
| `enrollments.course_id` | FK지만 자동 인덱스 없음 | 강의별 조회가 많으면 후보 |
| `enrollments.status` | 값 종류가 적음 | 단독 인덱스는 분포 확인 후 판단 |
| `(course_id, status)` | 복합 조건 | 쿼리 패턴과 컬럼 순서 검토 |

선택도는 조건이 전체 행 중 얼마나 적은 행을 선택하는지 판단하는 개념입니다. 이메일처럼 대부분 값이 서로 다른 컬럼은 선택도가 높고, 수강 상태처럼 값 종류가 적은 컬럼은 선택도가 낮을 수 있습니다. 다만 낮은 선택도 컬럼도 다른 조건과 함께 쓰이거나 특정 값의 분포가 치우쳐 있으면 검토 대상이 될 수 있습니다.

---

## 6. ORDER BY와 인덱스

인덱스는 검색뿐 아니라 정렬에도 영향을 줄 수 있습니다.

![ORDER BY에서 인덱스가 사용되는 흐름](../../images/chapter10/ch10_04_order_by_index_flow.svg)

그림 10-4 ORDER BY에서 인덱스가 사용되는 흐름

다음 두 쿼리를 비교합니다.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM courses
ORDER BY title;
```

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, title, level, price
FROM courses
ORDER BY title
LIMIT 20;
```

`ORDER BY title`에 맞는 인덱스가 있어도 항상 Index Scan이 선택되는 것은 아닙니다. 전체 행을 모두 반환해야 하는지, 일부 행만 빠르게 가져오면 되는지, 별도 `Sort` 비용이 얼마나 큰지에 따라 계획이 달라질 수 있습니다. `LIMIT`은 특히 계획 선택에 영향을 줄 수 있습니다.

---

## 7. JOIN과 FOREIGN KEY 인덱스

JOIN에서는 외래키 컬럼이 자주 등장합니다. 그러나 PostgreSQL은 FOREIGN KEY 자식 컬럼에 인덱스를 자동 생성하지 않습니다.

![JOIN 관계와 외래키 인덱스 후보](../../images/chapter10/ch10_05_join_foreign_key_index.svg)

그림 10-5 JOIN 관계와 외래키 인덱스 후보

`students.id`와 `courses.id`는 기본키이므로 자동 인덱스가 있습니다. 하지만 `enrollments.student_id`, `enrollments.course_id`는 자식 FK 컬럼이므로 쿼리 패턴을 보고 수동 인덱스를 검토해야 합니다.

```sql
CREATE INDEX idx_enrollments_student_id
ON enrollments(student_id);
```

`course_id` 단일 인덱스는 복합 인덱스 실습과 겹칠 수 있습니다. 이 장에서는 단일 `course_id` 인덱스를 비교한 뒤 제거하고, 최종 수동 인덱스는 `(course_id, status)` 복합 인덱스로 둡니다.

---

## 8. 복합 인덱스와 선두 컬럼

복합 인덱스는 여러 컬럼을 묶어 만든 인덱스입니다.

```sql
CREATE INDEX idx_enrollments_course_status
ON enrollments(course_id, status);
```

![복합 인덱스의 선두 컬럼과 쿼리 조건](../../images/chapter10/ch10_06_composite_index_order.svg)

그림 10-6 복합 인덱스의 선두 컬럼과 쿼리 조건

`(course_id, status)`는 다음 조건에 잘 맞을 수 있습니다.

```sql
WHERE course_id = 5
  AND status = '수강중'
```

또한 선두 컬럼인 `course_id`만 사용하는 조건에도 활용될 가능성이 있습니다.

```sql
WHERE course_id = 5
```

반면 `status`만 사용하는 조건에는 일반적으로 효율적이지 않을 수 있습니다.

```sql
WHERE status = '수강중'
```

`(course_id, status)`와 `(status, course_id)`는 같은 인덱스가 아닙니다. 복합 인덱스는 실제 쿼리 조건 조합과 선두 컬럼 사용 여부를 함께 검토해야 합니다.

---

## 9. EXPLAIN과 EXPLAIN ANALYZE

`EXPLAIN`은 SQL을 실제로 실행하지 않고 예상 실행 계획을 보여 줍니다. `EXPLAIN ANALYZE`는 SQL을 실제로 실행하고 실제 통계를 함께 보여 줍니다.

| 명령 | 의미 | 주의 |
| --- | --- | --- |
| `EXPLAIN` | 실행하지 않고 예상 실행 계획 표시 | 비용과 예상 행 수 중심 |
| `EXPLAIN ANALYZE` | SQL을 실제 실행하고 실제 통계 표시 | 변경 SQL에 사용하면 실제 변경됨 |
| `EXPLAIN (ANALYZE, BUFFERS)` | 실제 실행 결과와 버퍼 사용량 표시 | 이 장에서는 SELECT 실습에만 사용 |

이 장에서는 SELECT 쿼리에만 다음 형태를 사용합니다.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT ...;
```

`EXPLAIN ANALYZE`의 `ANALYZE`와 `ANALYZE students;`의 `ANALYZE`는 다릅니다. 앞의 것은 쿼리를 실제 실행해 계획을 측정하는 옵션이고, 뒤의 것은 옵티마이저 통계를 갱신하는 명령입니다.

![인덱스 전후 실행 계획 비교](../../images/chapter10/ch10_07_explain_before_after.svg)

그림 10-7 인덱스 전후 실행 계획 비교

실행 계획에서 확인할 항목은 다음과 같습니다.

| 확인 항목 | 의미 |
| --- | --- |
| 계획 노드 | Seq Scan, Index Scan, Bitmap Heap Scan 등 |
| cost | 옵티마이저가 계산한 상대적 예상 비용 |
| rows | 예상 결과 행 수 |
| actual rows | 실제 반환 행 수 |
| actual time | 실제 실행 시간 |
| Buffers | 읽거나 사용한 데이터 블록 |
| Filter | 읽은 뒤 적용한 조건 |
| Index Cond | 인덱스 탐색에 사용한 조건 |
| Sort | 별도 정렬 작업 여부 |

`cost`는 시간이 아닙니다. 실행 시간은 PC 상태, 캐시, PostgreSQL 버전, 데이터 분포에 따라 달라집니다. 한 번의 실행 시간만으로 결론을 내리지 말고, 같은 환경에서 인덱스 생성 전후 계획과 실제 행 수, 버퍼 사용량을 함께 비교합니다.

---

## 10. 인덱스의 이점과 비용

인덱스의 장점은 조회 성능을 높일 수 있다는 점입니다.

- WHERE 조건 검색이 빨라질 수 있습니다.
- JOIN 조건 처리에 도움이 될 수 있습니다.
- ORDER BY 정렬 비용을 줄일 수 있습니다.
- 자주 사용하는 조회 쿼리의 응답 시간을 줄일 수 있습니다.

하지만 인덱스에는 비용도 있습니다.

| 비용 | 설명 |
| --- | --- |
| 저장 공간 증가 | 인덱스 구조를 별도로 저장해야 함 |
| 쓰기 성능 저하 | INSERT, UPDATE, DELETE 때 인덱스도 함께 갱신해야 함 |
| 관리 복잡도 증가 | 어떤 인덱스가 필요한지 판단해야 함 |
| 중복 인덱스 가능성 | 이미 비슷한 인덱스가 있는데 또 만들 수 있음 |

따라서 인덱스는 많이 만드는 것이 아니라 필요한 곳에 신중하게 만드는 것입니다.

---

## 11. AI 추천 인덱스 검토

AI에게 인덱스를 추천해 달라고 하면 그럴듯한 SQL을 빠르게 받을 수 있습니다. 하지만 AI는 실제 데이터 분포와 현재 인덱스 목록, 실행 계획을 모를 수 있습니다.

![AI 추천 인덱스 검토 흐름](../../images/chapter10/ch10_08_ai_index_review_flow.svg)

그림 10-8 AI 추천 인덱스 검토 흐름

AI 추천은 다음 기준으로 검토합니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 쿼리 패턴 | 실제로 자주 실행되는 SQL인가? |
| 기존 인덱스 | PRIMARY KEY, UNIQUE, 기존 수동 인덱스와 겹치지 않는가? |
| WHERE 조건 | 해당 컬럼이 조건에서 반복적으로 쓰이는가? |
| JOIN 조건 | FK 컬럼이 조회 성능에 영향을 주는가? |
| ORDER BY | 정렬과 LIMIT에 도움이 되는가? |
| 선택도 | 조건이 충분히 적은 행을 골라내는가? |
| 쓰기 비용 | INSERT, UPDATE, DELETE 비용 증가를 감수할 가치가 있는가? |
| 실행 계획 | EXPLAIN ANALYZE로 전후 차이를 확인했는가? |

AI가 `students.email` 인덱스를 추천했다면 먼저 UNIQUE 자동 인덱스가 이미 있는지 확인해야 합니다. 이미 같은 역할을 하는 인덱스가 있다면 새로 만들지 않습니다.

---

## 12. 최종 인덱스 기준

이 장의 실습에서 최종 수동 인덱스 기준은 다음과 같습니다.

```text
idx_courses_title
idx_enrollments_student_id
idx_enrollments_course_status
```

`idx_enrollments_course_id`는 단일 인덱스와 복합 인덱스의 역할이 겹치는지 비교한 뒤 제거하는 실습 대상으로 둡니다.

자동 인덱스까지 확인하려면 `indexname LIKE 'idx_%'` 조건만 쓰지 말고 `pg_indexes`에서 네 테이블 전체를 조회합니다. 그래야 PK와 UNIQUE 자동 인덱스도 함께 볼 수 있습니다.

---

## 13. 자주 하는 실수

### 실수 1. UNIQUE 컬럼에 같은 인덱스를 또 만든다

`students.email`은 UNIQUE 제약조건 때문에 자동 인덱스가 있습니다. 같은 컬럼에 `idx_students_email`을 또 만들면 중복 인덱스가 될 수 있습니다.

### 실수 2. 인덱스가 있으면 항상 Index Scan이 나와야 한다고 생각한다

PostgreSQL은 비용을 비교해 Seq Scan을 선택할 수 있습니다. 특히 데이터가 적거나 많은 행을 반환할 때 Seq Scan은 정상적인 선택일 수 있습니다.

### 실수 3. EXPLAIN의 cost를 실행 시간으로 읽는다

cost는 상대적 예상 비용입니다. 실제 시간은 `EXPLAIN ANALYZE`의 `actual time`과 `Execution Time`을 봅니다.

### 실수 4. FOREIGN KEY가 자동 인덱스를 만든다고 생각한다

PostgreSQL은 FK 제약조건 자체를 만들지만 자식 FK 컬럼 인덱스는 자동 생성하지 않습니다.

### 실수 5. 복합 인덱스의 컬럼 순서를 무시한다

`(course_id, status)`와 `(status, course_id)`는 같은 인덱스가 아닙니다.

---

## 14. 핵심 정리

- 인덱스는 검색을 빠르게 하기 위한 보조 구조입니다.
- PRIMARY KEY와 UNIQUE는 자동으로 고유 인덱스를 만듭니다.
- FOREIGN KEY 자식 컬럼은 자동으로 인덱스가 생기지 않습니다.
- WHERE, JOIN, ORDER BY 조건은 인덱스 후보를 찾는 단서입니다.
- 인덱스가 있어도 PostgreSQL은 Seq Scan을 선택할 수 있습니다.
- EXPLAIN은 예상 계획, EXPLAIN ANALYZE는 실제 실행 결과입니다.
- 복합 인덱스는 선두 컬럼과 실제 조건 조합이 중요합니다.
- 인덱스는 읽기 성능과 쓰기 비용 사이의 선택입니다.
- AI 추천 인덱스는 기존 인덱스와 실행 계획으로 검증해야 합니다.

---

## 15. 다음 장에서는

Chapter 11에서는 데이터베이스 보안과 백업의 기본을 다룹니다. 빠른 조회도 중요하지만, 데이터베이스는 안전하게 보호되고 복구 가능해야 합니다.
