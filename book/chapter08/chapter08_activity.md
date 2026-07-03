# Chapter 08 활동 자료

## JOIN과 집계 쿼리

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 08 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 08의 JOIN과 집계 쿼리를 실습하기 위한 자료입니다.

학습자는 Chapter 07에서 만든 온라인 강의 수강신청 시스템의 `students`, `instructors`, `courses`, `enrollments` 테이블을 사용해 여러 테이블을 연결하고, 데이터를 요약하는 SQL을 작성합니다.

이 활동의 핵심은 단순히 SQL 문법을 외우는 것이 아니라 다음 질문에 답할 수 있는 능력을 기르는 것입니다.

```text
- 어떤 테이블을 연결해야 하는가?
- 어떤 컬럼을 기준으로 JOIN해야 하는가?
- INNER JOIN과 LEFT JOIN 중 무엇을 써야 하는가?
- 어떤 컬럼을 기준으로 GROUP BY해야 하는가?
- COUNT, SUM, AVG 결과가 요구사항과 맞는가?
- AI가 만든 JOIN/집계 SQL의 결과가 정확한가?
```

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. INNER JOIN과 LEFT JOIN의 차이를 설명할 수 있다.
2. 여러 테이블을 JOIN하여 필요한 결과를 조회할 수 있다.
3. 테이블 별칭을 사용해 SQL을 읽기 쉽게 작성할 수 있다.
4. COUNT, SUM, AVG 집계 함수를 사용할 수 있다.
5. GROUP BY로 그룹별 통계를 계산할 수 있다.
6. HAVING으로 집계 결과를 필터링할 수 있다.
7. LEFT JOIN에서 COUNT 대상 컬럼을 주의해서 선택할 수 있다.
8. AI가 만든 JOIN/집계 SQL을 실행 결과 기준으로 검토할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 데이터베이스
- code/chapter08/join_aggregation_practice.sql
- ChatGPT 또는 Codex
```

### 제출 파일명 권장

```text
학번_이름_chapter08_activity.md
```

예시:

```text
20260001_홍길동_chapter08_activity.md
```

---

## 4. 활동 1: 실습 SQL 실행 준비

다음 파일을 실행합니다.

```text
code/chapter08/join_aggregation_practice.sql
```

실행 결과를 기록하세요.

| 항목 | 작성 |
| --- | --- |
| SQL 파일 실행 성공 여부 |  |
| 생성된 테이블 목록 |  |
| students 데이터 수 |  |
| instructors 데이터 수 |  |
| courses 데이터 수 |  |
| enrollments 데이터 수 |  |
| 오류가 있었다면 오류 메시지 |  |
| 오류를 어떻게 해결했는가? |  |

---

## 5. 활동 2: INNER JOIN 결과 확인

다음 조회가 어떤 결과를 보여 주는지 기록하세요.

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

| student_name | course_title | status |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

### 질문

```text
INNER JOIN 결과에 수강신청이 없는 학생도 나타나나요?
그 이유는 무엇인가요?
```

---

## 6. 활동 3: 여러 테이블 JOIN 결과 확인

수강신청 현황 전체 조회 결과를 기록하세요.

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

| enrollment_id | student_name | course_title | instructor_name | status | paid_amount | enrolled_at |
| ---: | --- | --- | --- | --- | ---: | --- |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |

### JOIN 경로 설명

```text
enrollments.student_id -> [작성]
enrollments.course_id -> [작성]
courses.instructor_id -> [작성]
```

---

## 7. 활동 4: LEFT JOIN 결과 확인

다음 SQL은 수강신청이 없는 학생도 포함합니다.

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

| student_name | course_title | status |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

### 질문

```text
INNER JOIN 결과와 LEFT JOIN 결과의 차이는 무엇인가요?
LEFT JOIN에서 NULL이 나타난다면 그 의미는 무엇인가요?
```

---

## 8. 활동 5: 수강신청이 없는 학생 찾기

다음 SQL 결과를 기록하세요.

```sql
SELECT
    s.id,
    s.name,
    s.email
FROM students AS s
LEFT JOIN enrollments AS e ON s.id = e.student_id
WHERE e.id IS NULL;
```

| id | name | email |
| ---: | --- | --- |
|  |  |  |

### 질문

```text
왜 WHERE e.id IS NULL 조건을 사용하나요?
```

---

## 9. 활동 6: 기본 집계 함수 사용

다음 집계 결과를 기록하세요.

### 전체 수강신청 수

```sql
SELECT COUNT(*) AS enrollment_count
FROM enrollments;
```

| enrollment_count |
| ---: |
|  |

### 전체 결제금액 합계와 평균

```sql
SELECT
    SUM(paid_amount) AS total_paid_amount,
    AVG(paid_amount) AS avg_paid_amount
FROM enrollments;
```

| total_paid_amount | avg_paid_amount |
| ---: | ---: |
|  |  |

### 질문

```text
COUNT, SUM, AVG는 각각 어떤 상황에서 사용하나요?
```

---

## 10. 활동 7: GROUP BY로 상태별 통계 구하기

수강상태별 수강신청 수를 구합니다.

```sql
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY status
ORDER BY status;
```

| status | enrollment_count |
| --- | ---: |
|  |  |
|  |  |
|  |  |

### 질문

```text
SELECT에 status와 COUNT(*)가 함께 있을 때 GROUP BY status가 필요한 이유는 무엇인가요?
```

---

## 11. 활동 8: 강의별 수강생 수 구하기

다음 SQL 결과를 기록하세요.

```sql
SELECT
    c.id AS course_id,
    c.title AS course_title,
    COUNT(e.id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
ORDER BY c.id;
```

| course_id | course_title | student_count |
| ---: | --- | ---: |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

### 질문

```text
LEFT JOIN에서 COUNT(*) 대신 COUNT(e.id)를 사용하는 이유는 무엇인가요?
```

---

## 12. 활동 9: 강의별 매출 구하기

다음 SQL 결과를 기록하세요.

```sql
SELECT
    c.title AS course_title,
    COALESCE(SUM(e.paid_amount), 0) AS total_amount
FROM courses AS c
LEFT JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
ORDER BY total_amount DESC;
```

| course_title | total_amount |
| --- | ---: |
|  |  |
|  |  |
|  |  |
|  |  |

### 질문

```text
COALESCE(SUM(e.paid_amount), 0)는 어떤 역할을 하나요?
```

---

## 13. 활동 10: 강사별 개설 강의 수 구하기

다음 SQL 결과를 기록하세요.

```sql
SELECT
    i.name AS instructor_name,
    COUNT(c.id) AS course_count
FROM instructors AS i
LEFT JOIN courses AS c ON i.id = c.instructor_id
GROUP BY i.id, i.name
ORDER BY course_count DESC;
```

| instructor_name | course_count |
| --- | ---: |
|  |  |
|  |  |
|  |  |

### 질문

```text
이 SQL에서 LEFT JOIN을 사용한 이유는 무엇인가요?
```

---

## 14. 활동 11: HAVING으로 집계 결과 필터링

다음 SQL 결과를 기록하세요.

```sql
SELECT
    c.title AS course_title,
    COUNT(e.id) AS student_count
FROM courses AS c
JOIN enrollments AS e ON c.id = e.course_id
GROUP BY c.id, c.title
HAVING COUNT(e.id) >= 2
ORDER BY student_count DESC;
```

| course_title | student_count |
| --- | ---: |
|  |  |
|  |  |

### 질문

```text
WHERE와 HAVING의 차이를 설명하세요.
```

---

## 15. 활동 12: WHERE + GROUP BY 함께 사용하기

수강상태가 `수강중`인 신청만 대상으로 강의별 수강생 수를 구합니다.

```sql
SELECT
    c.title AS course_title,
    COUNT(e.id) AS active_student_count
FROM courses AS c
JOIN enrollments AS e ON c.id = e.course_id
WHERE e.status = '수강중'
GROUP BY c.id, c.title
ORDER BY active_student_count DESC;
```

| course_title | active_student_count |
| --- | ---: |
|  |  |
|  |  |

### 실행 순서 정리

아래 순서를 본인의 말로 설명하세요.

```text
FROM/JOIN -> WHERE -> GROUP BY -> 집계 함수 -> HAVING -> ORDER BY
```

---

## 16. 활동 13: AI 생성 JOIN/집계 SQL 검토

AI에게 다음 프롬프트를 입력했다고 가정합니다.

```text
students, courses, enrollments, instructors 테이블을 사용해서
강의별 수강생 수와 총 결제금액을 조회하는 PostgreSQL SQL을 작성해 주세요.
```

AI가 만든 SQL을 다음 기준으로 검토하세요.

| 검토 항목 | 확인 결과 | 수정 필요 여부 |
| --- | --- | --- |
| JOIN 조건이 빠지지 않았는가? |  |  |
| enrollments와 courses가 올바르게 연결되었는가? |  |  |
| GROUP BY에 필요한 컬럼이 포함되었는가? |  |  |
| COUNT 대상이 적절한가? |  |  |
| SUM 결과가 중복 계산되지 않는가? |  |  |
| NULL 처리가 필요한가? |  |  |
| DBeaver에서 실행 가능한가? |  |  |

### 사람이 수정한 내용

| AI 제안 | 문제점 | 수정한 내용 |
| --- | --- | --- |
|  |  |  |
|  |  |  |

---

## 17. 활동 14: 직접 SQL 작성하기

다음 요구사항에 맞는 SQL을 직접 작성하세요.

### 문제 1. 학생별 수강신청 수

```sql
-- 여기에 작성
```

### 문제 2. 강의별 평균 결제금액

```sql
-- 여기에 작성
```

### 문제 3. 강사별 총 매출

```sql
-- 여기에 작성
```

### 문제 4. 수강신청이 없는 강의 찾기

```sql
-- 여기에 작성
```

### 문제 5. 수강신청 수가 2명 이상인 강사별 강의 목록

```sql
-- 여기에 작성
```

---

## 18. 제출 양식

아래 형식을 그대로 복사해서 제출 파일에 사용할 수 있습니다.

```markdown
# Chapter 08 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. SQL 실행 준비

[활동 1 작성]

## 3. JOIN 실습 결과

[활동 2~5 작성]

## 4. 집계 쿼리 실습 결과

[활동 6~12 작성]

## 5. AI SQL 검토

[활동 13 작성]

## 6. 직접 작성한 SQL

[활동 14 작성]

## 7. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 19. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| JOIN 이해와 실행 | 25 | INNER JOIN, LEFT JOIN, 여러 테이블 JOIN 결과를 정확히 기록했는가 |
| 집계 쿼리 이해 | 25 | COUNT, SUM, AVG, GROUP BY, HAVING 결과를 정확히 설명했는가 |
| SQL 작성 능력 | 20 | 요구사항에 맞는 JOIN/집계 SQL을 직접 작성했는가 |
| AI SQL 검토 | 20 | AI가 만든 SQL을 실행과 논리 기준으로 검토했는가 |
| 제출 형식 | 10 | 지정된 형식에 맞게 명확히 작성했는가 |

---

## 20. 피드백 코멘트 예시

### 우수한 경우

```text
INNER JOIN과 LEFT JOIN의 차이를 실행 결과로 잘 설명했습니다.
GROUP BY와 HAVING을 사용해 강의별 수강생 수와 매출을 정확히 계산했고,
AI가 생성한 SQL도 JOIN 조건과 GROUP BY 기준으로 검토한 점이 우수합니다.
```

### 보완이 필요한 경우

```text
JOIN 결과는 기록했지만 INNER JOIN과 LEFT JOIN의 차이에 대한 설명이 부족합니다.
또한 GROUP BY를 사용할 때 SELECT에 포함된 일반 컬럼이 GROUP BY에도 포함되어야 한다는 점을 다시 확인해 주세요.
AI SQL 검토는 실행 여부뿐 아니라 결과가 요구사항과 맞는지도 함께 확인해야 합니다.
```

---

## 21. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. Chapter 07 테이블 구조 복습: 10분
2. INNER JOIN과 LEFT JOIN 비교 실습: 25분
3. 여러 테이블 JOIN 실습: 20분
4. GROUP BY와 집계 함수 실습: 30분
5. HAVING과 WHERE 차이 실습: 20분
6. AI SQL 검토 활동: 20분
7. 직접 SQL 작성 및 공유: 25분
```

초급자에게는 JOIN을 “테이블을 붙이는 문법”이 아니라 “외래키 관계를 따라 필요한 정보를 가져오는 과정”으로 설명하는 것이 좋습니다.

---

## 22. 핵심 정리

이 활동의 핵심은 JOIN과 집계 쿼리를 통해 정규화된 테이블을 실제 분석 가능한 정보로 바꾸는 것입니다.

```text
JOIN은 나뉜 테이블을 연결한다.
INNER JOIN은 일치하는 데이터만 보여 준다.
LEFT JOIN은 왼쪽 테이블을 기준으로 결과를 유지한다.
GROUP BY는 같은 값을 가진 행을 묶는다.
COUNT, SUM, AVG는 그룹별 요약값을 만든다.
HAVING은 집계 결과를 기준으로 필터링한다.
AI가 만든 SQL도 반드시 JOIN 조건과 집계 결과를 검토해야 한다.
```
