# Chapter 10 실습 자료

## 인덱스와 성능 기초

이 활동지는 Chapter 10의 인덱스 실습 결과를 기록하기 위한 자료입니다. 목표는 인덱스를 많이 만드는 것이 아니라 실제 쿼리 패턴과 실행 계획을 기준으로 필요한 인덱스를 판단하는 것입니다.

---

## 1. 실습 DB 안전 확인

실습 파일:

```text
code/chapter10/index_performance_practice.sql
```

> **실습 DB 확인**
>
> `index_performance_practice.sql`은 기존 실습 테이블을 삭제하고 성능 비교용 데이터를 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 먼저 `SELECT current_database();`로 연결 대상을 확인합니다. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

| 항목 | 예상값 | 실제 결과 |
| --- | --- | --- |
| students | 10,005 |  |
| instructors | 3 |  |
| courses | 2,005 |  |
| enrollments | 100,007 |  |
| 자동 UNIQUE 인덱스 확인 | 존재 |  |
| 오류 메시지 | 없음 |  |

대량 데이터 생성에 시간이 오래 걸리면 SQL 파일의 `enrollments` 자동 생성 건수를 100,000에서 50,000으로 줄여 실습할 수 있습니다.

---

## 2. 자동 인덱스와 수동 인덱스 확인

| 구조 | 자동 생성 여부 | 확인 결과 |
| --- | --- | --- |
| PRIMARY KEY | 자동 생성 |  |
| UNIQUE | 자동 생성 |  |
| FOREIGN KEY 자식 컬럼 | 자동 생성 안 됨 |  |
| 일반 컬럼 | 자동 생성 안 됨 |  |

`students.email`은 UNIQUE 제약조건이 있으므로 수동으로 `idx_students_email`을 만들지 않습니다.

### 생각해 보기

- `students.email`에 별도 인덱스를 만들지 않아야 하는 이유는 무엇인가?
- FK 컬럼에 인덱스가 자동 생성되지 않는다는 점이 JOIN 성능 판단에 어떤 영향을 주는가?

---

## 3. EXPLAIN과 EXPLAIN ANALYZE 구분

| 명령 | 의미 | 주의 |
| --- | --- | --- |
| EXPLAIN | 실행하지 않고 예상 계획 확인 | 실제 시간은 알 수 없음 |
| EXPLAIN ANALYZE | SQL을 실제 실행하고 실제 통계 확인 | 변경 SQL에 사용하면 실제 변경됨 |
| EXPLAIN (ANALYZE, BUFFERS) | 실제 실행과 버퍼 사용량 확인 | SELECT 실습에만 사용 |

### 기록 질문

- `ANALYZE students;`와 `EXPLAIN ANALYZE SELECT ...`는 어떻게 다른가?
- `cost`가 실행 시간이 아닌 이유는 무엇인가?

---

## 4. WHERE 검색 인덱스 비교

### courses.title

```sql
SELECT id, title, level, price
FROM courses
WHERE title = '데이터베이스 입문';
```

| 구분 | 계획 노드 | 예상 rows | actual rows | Buffers | 실행 시간 | 해석 |
| --- | --- | ---: | ---: | --- | --- | --- |
| 인덱스 생성 전 |  |  |  |  |  |  |
| 인덱스 생성 후 |  |  |  |  |  |  |

---

## 5. ORDER BY와 LIMIT 비교

| SQL | Sort 노드 | Index Scan | Buffers | 실행 시간 | 해석 |
| --- | --- | --- | --- | --- | --- |
| 전체 정렬 |  |  |  |  |  |
| `LIMIT 20` 정렬 |  |  |  |  |  |

### 생각해 보기

- `ORDER BY` 컬럼에 인덱스가 있어도 항상 Index Scan이 나오지 않는 이유는 무엇인가?
- `LIMIT`이 실행 계획에 영향을 줄 수 있는 이유는 무엇인가?

---

## 6. JOIN 조건과 FK 인덱스

### enrollments.student_id

```sql
SELECT
    e.id,
    s.name AS student_name,
    c.title AS course_title,
    e.status,
    e.paid_amount
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id
WHERE e.student_id = 1;
```

| 구분 | 계획 노드 | actual rows | Buffers | 실행 시간 | 해석 |
| --- | --- | ---: | --- | --- | --- |
| 인덱스 생성 전 |  |  |  |  |  |
| 인덱스 생성 후 |  |  |  |  |  |

### 생각해 보기

- `students.id`는 자동 인덱스가 있는데 `enrollments.student_id`는 왜 별도 검토가 필요한가?

---

## 7. 단일 course_id 인덱스와 복합 인덱스 중복 검토

`idx_enrollments_course_id`를 만든 뒤 실행 계획을 비교하고, 복합 인덱스 실습 전 제거합니다.

| 인덱스 | 역할 | 최종 유지 여부 | 이유 |
| --- | --- | --- | --- |
| `idx_enrollments_course_id` | course_id 단독 조회 비교 | 제거 |  |
| `idx_enrollments_course_status` | course_id + status 복합 조건 | 유지 |  |

---

## 8. 복합 인덱스와 선두 컬럼

복합 인덱스:

```sql
CREATE INDEX idx_enrollments_course_status
ON enrollments(course_id, status);
```

| 조건 | 계획 노드 | Index Cond | actual rows | Buffers | 해석 |
| --- | --- | --- | ---: | --- | --- |
| `course_id = 5` |  |  |  |  |  |
| `course_id = 5 AND status = '수강중'` |  |  |  |  |  |
| `status = '수강중'` |  |  |  |  |  |

### 생각해 보기

- `(course_id, status)`와 `(status, course_id)`는 왜 같은 인덱스가 아닌가?
- 선두 컬럼만 사용하는 조건에는 어떤 차이가 있는가?

---

## 9. 최종 인덱스 목록

`pg_indexes` 조회 결과를 보고 자동 인덱스와 수동 인덱스를 구분합니다.

| indexname | tablename | 자동/수동 | 역할 |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

최종 수동 인덱스 기준:

- `idx_courses_title`
- `idx_enrollments_student_id`
- `idx_enrollments_course_status`

---

## 10. AI 추천 인덱스 검토

| AI 추천 인덱스 | 기존 인덱스와 중복? | 실행 계획 확인? | 적용/보류/제거 | 이유 |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

### 반드시 확인할 질문

- AI가 UNIQUE 자동 인덱스를 모르고 중복 인덱스를 추천하지 않았는가?
- 자주 실행되는 쿼리와 관련 있는가?
- 데이터가 충분히 많고 선택도가 있는가?
- 쓰기 비용 증가를 감수할 만한가?
- EXPLAIN ANALYZE 결과가 실제로 개선을 보여 주는가?

---

## 11. 핵심 정리

- 인덱스는 조회를 빠르게 할 수 있지만 저장 공간과 쓰기 비용을 늘린다.
- PRIMARY KEY와 UNIQUE는 자동 인덱스를 만든다.
- FOREIGN KEY 자식 컬럼은 자동 인덱스가 생기지 않는다.
- 인덱스가 있어도 Seq Scan이 나올 수 있으며, 이것만으로 오류라고 판단하지 않는다.
- 복합 인덱스는 선두 컬럼과 실제 조건 조합이 중요하다.
- AI 추천 인덱스는 기존 인덱스와 실행 계획으로 검증해야 한다.
