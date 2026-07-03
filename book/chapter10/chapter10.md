# Chapter 10. 인덱스와 성능 기초

> 상태: 원고 1차 확장 완료

---

## 이 장에서 배울 내용

이 장에서는 데이터 검색 속도를 높이는 **인덱스(index)**의 기본 개념을 학습합니다.

Chapter 08에서는 JOIN과 집계 쿼리를 사용해 여러 테이블의 데이터를 조회했습니다. Chapter 09에서는 트랜잭션을 사용해 데이터 변경 작업을 안전하게 처리하는 방법을 배웠습니다.

이제 데이터가 많아졌을 때 발생하는 문제를 살펴보겠습니다. 데이터가 수십 건일 때는 대부분의 SQL이 빠르게 실행됩니다. 하지만 데이터가 수만 건, 수십만 건, 수백만 건으로 늘어나면 같은 SQL도 느려질 수 있습니다.

이 장에서는 다음 내용을 다룹니다.

- 인덱스가 필요한 이유
- 인덱스를 책의 색인에 비유해 이해하기
- WHERE 조건과 인덱스
- ORDER BY와 인덱스
- JOIN 조건과 인덱스
- CREATE INDEX 기본 문법
- EXPLAIN 실행 계획 맛보기
- 인덱스의 장점과 단점
- 인덱스를 만들면 안 되는 경우
- AI가 추천한 인덱스를 검토하는 방법

---

## 1. 왜 인덱스를 배워야 하는가

데이터베이스를 처음 배울 때는 테이블에 들어 있는 데이터가 많지 않습니다.

예를 들어 `students` 테이블에 학생이 5명만 있다면 다음 SQL은 매우 빠르게 실행됩니다.

```sql
SELECT id, name, email
FROM students
WHERE email = 'minji@example.com';
```

하지만 학생이 100만 명이라면 이야기가 달라집니다. 데이터베이스가 모든 행을 처음부터 끝까지 확인해야 한다면 검색 시간이 길어질 수 있습니다.

인덱스는 이런 상황에서 원하는 데이터를 더 빠르게 찾기 위한 구조입니다.

```text
인덱스 = 자주 찾는 값을 빠르게 찾기 위해 미리 만들어 둔 검색용 구조
```

책의 뒷부분에 있는 색인을 생각하면 이해하기 쉽습니다. 특정 단어가 어느 페이지에 있는지 찾을 때 책을 처음부터 끝까지 읽지 않고 색인을 먼저 확인합니다.

데이터베이스 인덱스도 비슷합니다. 특정 컬럼으로 자주 검색한다면 그 컬럼에 인덱스를 만들어 검색 속도를 높일 수 있습니다.

---

## 2. 실습에 사용할 테이블 구조

이 장에서도 온라인 강의 수강신청 시스템을 계속 사용합니다.

기본 테이블은 다음과 같습니다.

```text
students(id, name, email, joined_at)
instructors(id, name, email, specialty)
courses(id, instructor_id, title, description, level, price, opened_at)
enrollments(id, student_id, course_id, enrolled_at, status, paid_amount)
```

성능 실습에서는 다음과 같은 조회를 중심으로 생각합니다.

```text
- 이메일로 학생 찾기
- 강의 제목으로 강의 찾기
- 수강상태별 신청 내역 찾기
- 특정 학생의 수강신청 내역 찾기
- 특정 강의의 수강생 목록 찾기
- 강의 제목순으로 정렬하기
```

이런 조회가 자주 실행된다면 인덱스를 검토할 수 있습니다.

---

## 3. 인덱스란 무엇인가

인덱스는 테이블의 특정 컬럼 값을 기준으로 데이터를 빠르게 찾을 수 있도록 도와주는 구조입니다.

예를 들어 `students.email` 컬럼으로 학생을 자주 검색한다고 가정합니다.

```sql
SELECT id, name, email
FROM students
WHERE email = 'minji@example.com';
```

이때 `email` 컬럼에 인덱스가 없다면 데이터베이스는 많은 행을 확인해야 할 수 있습니다. 반대로 `email` 컬럼에 인덱스가 있으면 해당 값을 더 빠르게 찾을 수 있습니다.

인덱스 생성 SQL은 다음과 같습니다.

```sql
CREATE INDEX idx_students_email
ON students(email);
```

이 SQL의 의미는 다음과 같습니다.

| 구성 | 의미 |
| --- | --- |
| CREATE INDEX | 인덱스를 생성한다 |
| idx_students_email | 인덱스 이름 |
| ON students(email) | students 테이블의 email 컬럼에 인덱스를 만든다 |

인덱스 이름은 보통 다음 규칙으로 작성하면 좋습니다.

```text
idx_테이블명_컬럼명
```

예시는 다음과 같습니다.

```text
idx_students_email
idx_courses_title
idx_enrollments_student_id
idx_enrollments_course_id
```

---

## 4. 인덱스가 없는 조회와 있는 조회

인덱스가 없는 상태에서는 데이터베이스가 테이블의 많은 행을 확인해야 할 수 있습니다.

```text
students 테이블 전체 확인 -> email 값 비교 -> 일치하는 행 반환
```

인덱스가 있으면 다음처럼 검색 경로가 달라질 수 있습니다.

```text
email 인덱스 확인 -> 해당 행 위치 찾기 -> 필요한 행 반환
```

인덱스가 항상 모든 상황에서 빠른 것은 아닙니다. 하지만 특정 조건으로 자주 검색하는 컬럼에는 큰 도움이 될 수 있습니다.

초급 단계에서는 다음처럼 이해하면 충분합니다.

```text
데이터가 많고, 특정 컬럼으로 자주 찾는다면 인덱스를 검토한다.
```

---

## 5. WHERE 조건과 인덱스

인덱스는 주로 `WHERE` 조건에서 자주 사용되는 컬럼에 만듭니다.

예를 들어 학생 이메일로 자주 검색한다면 `students.email` 컬럼이 인덱스 후보입니다.

```sql
CREATE INDEX idx_students_email
ON students(email);
```

조회 SQL은 다음과 같습니다.

```sql
SELECT id, name, email
FROM students
WHERE email = 'minji@example.com';
```

강의 제목으로 자주 검색한다면 `courses.title`도 인덱스 후보가 될 수 있습니다.

```sql
CREATE INDEX idx_courses_title
ON courses(title);
```

```sql
SELECT id, title, level, price
FROM courses
WHERE title = '데이터베이스 입문';
```

하지만 모든 WHERE 조건 컬럼에 무조건 인덱스를 만드는 것은 좋지 않습니다. 자주 검색하지 않는 컬럼이나 데이터 종류가 너무 적은 컬럼은 효과가 작을 수 있습니다.

예를 들어 `status` 값이 `신청`, `수강중`, `완료`, `취소` 정도로만 구성되어 있다면 단독 인덱스의 효과가 제한적일 수 있습니다. 실제로 필요한지는 데이터 양과 쿼리 패턴을 보고 판단해야 합니다.

---

## 6. ORDER BY와 인덱스

인덱스는 정렬에도 도움이 될 수 있습니다.

예를 들어 강의 목록을 제목순으로 자주 보여 준다면 다음 SQL이 자주 실행될 수 있습니다.

```sql
SELECT id, title, level, price
FROM courses
ORDER BY title;
```

이 경우 `title` 컬럼에 인덱스가 있으면 정렬 작업에 도움이 될 수 있습니다.

```sql
CREATE INDEX idx_courses_title
ON courses(title);
```

다만 정렬에 항상 인덱스가 사용되는 것은 아닙니다. 데이터 양, 조건, 정렬 방향, DBMS의 판단에 따라 실행 방식이 달라질 수 있습니다.

그래서 인덱스를 만든 뒤에는 실행 계획을 확인하는 습관이 필요합니다.

---

## 7. JOIN 조건과 인덱스

JOIN에서는 외래키 컬럼이 자주 사용됩니다.

Chapter 08에서 다음 JOIN을 사용했습니다.

```sql
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.status
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.id
JOIN courses AS c ON e.course_id = c.id;
```

여기서 JOIN 조건에 사용되는 컬럼은 다음과 같습니다.

```text
enrollments.student_id
enrollments.course_id
students.id
courses.id
```

`students.id`와 `courses.id`는 기본키이므로 보통 자동으로 인덱스가 만들어집니다. 하지만 `enrollments.student_id`, `enrollments.course_id`는 별도로 인덱스를 검토할 수 있습니다.

```sql
CREATE INDEX idx_enrollments_student_id
ON enrollments(student_id);
```

```sql
CREATE INDEX idx_enrollments_course_id
ON enrollments(course_id);
```

특정 학생의 수강신청 내역을 자주 조회한다면 `student_id` 인덱스가 도움이 될 수 있습니다.

```sql
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE student_id = 1;
```

특정 강의의 수강생 목록을 자주 조회한다면 `course_id` 인덱스를 검토할 수 있습니다.

```sql
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 1;
```

---

## 8. 복합 인덱스 맛보기

하나의 컬럼이 아니라 여러 컬럼을 함께 사용하는 인덱스도 있습니다. 이를 복합 인덱스라고 합니다.

예를 들어 특정 강의에서 특정 상태의 수강신청을 자주 조회한다고 가정합니다.

```sql
SELECT id, student_id, course_id, status, paid_amount
FROM enrollments
WHERE course_id = 1 AND status = '수강중';
```

이런 쿼리가 자주 실행된다면 다음과 같은 복합 인덱스를 검토할 수 있습니다.

```sql
CREATE INDEX idx_enrollments_course_status
ON enrollments(course_id, status);
```

복합 인덱스는 컬럼 순서가 중요합니다. `(course_id, status)`와 `(status, course_id)`는 같은 의미가 아닙니다.

초급 단계에서는 다음 정도만 기억하면 됩니다.

```text
복합 인덱스는 자주 함께 사용되는 조건 컬럼을 묶어 만들 수 있다.
다만 컬럼 순서와 실제 쿼리 패턴을 함께 검토해야 한다.
```

---

## 9. EXPLAIN 실행 계획 맛보기

인덱스를 만들었다고 해서 무조건 사용되는 것은 아닙니다. 데이터베이스는 SQL을 실행할 때 여러 방법 중 하나를 선택합니다.

이 선택 과정을 확인할 수 있는 도구가 `EXPLAIN`입니다.

```sql
EXPLAIN
SELECT id, name, email
FROM students
WHERE email = 'minji@example.com';
```

`EXPLAIN`은 SQL을 실제로 어떻게 실행할지 계획을 보여 줍니다.

처음에는 모든 내용을 이해하지 못해도 괜찮습니다. 다음 단어 정도만 눈여겨보면 됩니다.

| 표현 | 대략적 의미 |
| --- | --- |
| Seq Scan | 테이블을 순차적으로 확인하는 방식 |
| Index Scan | 인덱스를 사용해 찾는 방식 |
| Bitmap Index Scan | 인덱스를 활용해 여러 행을 찾는 방식 |

초급 단계에서는 다음 흐름으로 보면 됩니다.

```text
1. 인덱스 생성 전 EXPLAIN을 실행한다.
2. 인덱스를 생성한다.
3. 같은 SELECT에 대해 EXPLAIN을 다시 실행한다.
4. 실행 계획이 어떻게 달라졌는지 비교한다.
```

다만 샘플 데이터가 너무 적으면 인덱스가 있어도 데이터베이스가 `Seq Scan`을 선택할 수 있습니다. 이는 오류가 아니라 데이터가 적을 때는 전체를 읽는 편이 더 싸다고 판단한 결과일 수 있습니다.

---

## 10. 인덱스의 장점

인덱스의 가장 큰 장점은 검색 성능을 높일 수 있다는 점입니다.

대표적인 장점은 다음과 같습니다.

```text
- WHERE 조건 검색이 빨라질 수 있다.
- JOIN 조건 처리에 도움이 될 수 있다.
- ORDER BY 정렬에 도움이 될 수 있다.
- 자주 사용하는 조회 쿼리의 응답 시간을 줄일 수 있다.
```

특히 데이터가 많아지고 조회 요청이 많아질수록 인덱스의 중요성이 커집니다.

하지만 인덱스는 무조건 많이 만들수록 좋은 것은 아닙니다.

---

## 11. 인덱스의 단점

인덱스에는 비용이 있습니다.

첫째, 저장 공간을 사용합니다. 인덱스는 별도의 구조이므로 테이블 데이터 외에 추가 공간이 필요합니다.

둘째, 데이터 변경 작업이 느려질 수 있습니다. `INSERT`, `UPDATE`, `DELETE`가 실행될 때 테이블뿐 아니라 인덱스도 함께 관리해야 하기 때문입니다.

셋째, 너무 많은 인덱스는 관리와 판단을 어렵게 만듭니다.

인덱스의 단점을 정리하면 다음과 같습니다.

| 단점 | 설명 |
| --- | --- |
| 저장 공간 증가 | 인덱스 구조를 따로 저장해야 함 |
| 쓰기 성능 저하 | 데이터 변경 시 인덱스도 함께 갱신됨 |
| 관리 복잡도 증가 | 인덱스가 많으면 어떤 것이 필요한지 판단하기 어려움 |
| 불필요한 인덱스 가능성 | 실제 쿼리에서 사용되지 않는 인덱스가 생길 수 있음 |

따라서 인덱스는 실제 쿼리 패턴과 실행 계획을 보고 신중하게 만들어야 합니다.

---

## 12. 인덱스를 만들면 좋은 경우와 조심해야 할 경우

인덱스를 만들면 좋은 경우는 다음과 같습니다.

```text
- 데이터가 많은 테이블에서 자주 검색하는 컬럼
- WHERE 조건에 자주 등장하는 컬럼
- JOIN 조건에 자주 사용되는 외래키 컬럼
- ORDER BY에 자주 사용되는 컬럼
- 중복이 적고 선택도가 높은 컬럼
```

반대로 조심해야 할 경우는 다음과 같습니다.

```text
- 데이터가 매우 적은 테이블
- 거의 검색하지 않는 컬럼
- 값의 종류가 너무 적은 컬럼
- INSERT/UPDATE/DELETE가 매우 자주 발생하는 테이블
- 이미 비슷한 인덱스가 있는 경우
```

여기서 선택도는 값이 얼마나 잘 구분되는지를 의미합니다. 예를 들어 이메일은 사람마다 대부분 다르므로 선택도가 높습니다. 반면 수강상태는 몇 가지 값만 반복되므로 선택도가 낮을 수 있습니다.

---

## 13. AI가 추천한 인덱스 검토하기

AI에게 다음처럼 요청할 수 있습니다.

```text
PostgreSQL에서 온라인 강의 수강신청 시스템의 성능을 높이기 위한 인덱스를 추천해 주세요.
students, courses, enrollments 테이블을 사용합니다.
자주 실행되는 쿼리는 학생 이메일 검색, 특정 학생의 수강신청 조회, 특정 강의의 수강생 조회입니다.
```

AI는 다음과 같은 인덱스를 추천할 수 있습니다.

```sql
CREATE INDEX idx_students_email
ON students(email);
```

```sql
CREATE INDEX idx_enrollments_student_id
ON enrollments(student_id);
```

```sql
CREATE INDEX idx_enrollments_course_id
ON enrollments(course_id);
```

이 추천이 항상 정답은 아닙니다. 다음 기준으로 검토해야 합니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 쿼리 패턴 | 실제로 자주 실행되는 SQL인가? |
| WHERE 조건 | 해당 컬럼이 WHERE 조건에 자주 등장하는가? |
| JOIN 조건 | 외래키 JOIN에 자주 사용되는가? |
| 정렬 조건 | ORDER BY에 자주 사용되는가? |
| 데이터 양 | 테이블 데이터가 충분히 많은가? |
| 선택도 | 값이 잘 구분되는 컬럼인가? |
| 쓰기 비용 | INSERT/UPDATE/DELETE가 너무 느려지지 않는가? |
| 실행 계획 | EXPLAIN으로 확인했는가? |

AI가 추천한 인덱스는 출발점일 뿐입니다. 실제 적용 여부는 사람이 쿼리 패턴과 실행 계획을 확인하고 결정해야 합니다.

---

## 14. 인덱스 실습 전 확인표

인덱스를 만들기 전 다음 질문을 확인합니다.

| 질문 | 확인 |
| --- | --- |
| 이 쿼리는 자주 실행되는가? |  |
| 이 테이블은 데이터가 충분히 많은가? |  |
| WHERE 조건에 반복적으로 사용되는 컬럼인가? |  |
| JOIN 조건에 사용되는 외래키인가? |  |
| ORDER BY에 자주 사용되는 컬럼인가? |  |
| 이미 비슷한 인덱스가 있는가? |  |
| 인덱스 생성 전후 EXPLAIN을 비교했는가? |  |
| 쓰기 성능 저하 가능성을 검토했는가? |  |

이 표를 사용하면 AI가 추천한 인덱스도 무비판적으로 적용하지 않고 검토할 수 있습니다.

---

## 15. 자주 하는 실수

### 실수 1. 모든 컬럼에 인덱스를 만들려고 한다

인덱스가 많으면 검색은 일부 빨라질 수 있지만 저장 공간과 쓰기 비용이 증가합니다. 모든 컬럼에 인덱스를 만드는 것은 좋은 전략이 아닙니다.

### 실수 2. 데이터가 적은데 성능 차이를 과장한다

샘플 데이터가 적으면 인덱스 효과가 거의 보이지 않을 수 있습니다. 데이터베이스가 인덱스보다 순차 검색을 선택할 수도 있습니다.

### 실수 3. EXPLAIN을 확인하지 않는다

인덱스를 만들었더라도 실제 쿼리에서 사용되는지 확인해야 합니다.

### 실수 4. 값 종류가 적은 컬럼에 무조건 인덱스를 만든다

상태값처럼 값의 종류가 적은 컬럼은 단독 인덱스 효과가 제한적일 수 있습니다.

### 실수 5. AI 추천을 그대로 적용한다

AI가 추천한 인덱스는 실제 데이터 양, 쿼리 빈도, 실행 계획을 모르는 상태에서 만든 초안일 수 있습니다.

---

## 16. 연습 문제

### 16.1 개념 확인

1. 인덱스가 필요한 이유를 설명하세요.
2. 인덱스를 책의 색인에 비유해 설명하세요.
3. 인덱스의 장점과 단점을 각각 2가지 이상 쓰세요.
4. `Seq Scan`과 `Index Scan`의 차이를 간단히 설명하세요.
5. AI가 추천한 인덱스를 검토할 때 확인해야 할 항목을 3가지 이상 쓰세요.

### 16.2 SQL 작성 문제

다음 요구사항에 맞는 SQL을 작성하세요.

```text
1. students 테이블의 email 컬럼에 인덱스를 생성하세요.
2. courses 테이블의 title 컬럼에 인덱스를 생성하세요.
3. enrollments 테이블의 student_id 컬럼에 인덱스를 생성하세요.
4. enrollments 테이블의 course_id 컬럼에 인덱스를 생성하세요.
5. course_id와 status를 함께 사용하는 복합 인덱스를 생성하세요.
```

### 16.3 검토 문제

다음 상황에서 인덱스를 만들지 말아야 할 수도 있는 이유를 설명하세요.

```text
- 테이블에 데이터가 20건뿐이다.
- status 컬럼 값이 신청, 수강중, 완료 세 가지뿐이다.
- INSERT가 매우 자주 발생하는 로그 테이블이다.
- AI가 모든 컬럼에 인덱스를 만들라고 추천했다.
```

---

## 17. 정리

이번 장에서는 인덱스와 성능 기초를 학습했습니다.

핵심 내용을 정리하면 다음과 같습니다.

```text
1. 인덱스는 데이터를 빠르게 찾기 위한 검색용 구조이다.
2. WHERE 조건에 자주 사용되는 컬럼은 인덱스 후보가 될 수 있다.
3. JOIN 조건에 사용되는 외래키 컬럼도 인덱스 후보가 될 수 있다.
4. ORDER BY에 자주 사용되는 컬럼도 인덱스가 도움이 될 수 있다.
5. 인덱스는 검색 성능을 높일 수 있지만 저장 공간과 쓰기 비용이 증가한다.
6. 인덱스 생성 전후에는 EXPLAIN으로 실행 계획을 확인하는 것이 좋다.
7. AI가 추천한 인덱스도 실제 쿼리 패턴과 실행 계획을 기준으로 검토해야 한다.
```

이 장에서 가장 중요한 문장은 다음입니다.

```text
인덱스는 많이 만드는 것이 아니라 필요한 곳에 신중하게 만드는 것이다.
```

---

## 18. 다음 장에서는

다음 장에서는 데이터베이스 보안과 백업을 학습합니다.

Chapter 11에서는 데이터베이스 접근 권한, 비밀번호 관리, 백업과 복구의 기본 개념을 다룹니다. 데이터베이스는 빠르게 조회되는 것도 중요하지만, 안전하게 보호되고 복구 가능해야 합니다.
