# Chapter 04 활동 자료

## 관계형 데이터베이스와 SQL 기초

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 04 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 04의 내용을 바탕으로, 학습자가 PostgreSQL에서 기본 SQL을 직접 실행하고 결과를 기록할 수 있도록 구성한 실습지입니다.

Chapter 04의 핵심은 `SELECT`, `INSERT`, `UPDATE`, `DELETE` 문법을 외우는 것이 아니라, **SQL 실행 전후에 어떤 데이터가 영향을 받는지 확인하는 습관**을 기르는 것입니다.

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. SELECT, INSERT, UPDATE, DELETE의 역할을 설명할 수 있다.
2. WHERE 조건을 사용해 원하는 행만 조회할 수 있다.
3. ORDER BY를 사용해 조회 결과를 정렬할 수 있다.
4. UPDATE 실행 전 SELECT로 수정 대상을 확인할 수 있다.
5. DELETE 실행 전 SELECT로 삭제 대상을 확인할 수 있다.
6. AI가 만든 SQL의 위험 요소를 검토할 수 있다.
7. 기본 CRUD 흐름을 실제 서비스 기능과 연결해 설명할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 데이터베이스
- code/chapter04/basic_crud.sql
- ChatGPT 또는 Codex
```

### 제출 파일명 권장

```text
학번_이름_chapter04_activity.md
```

예시:

```text
20260001_홍길동_chapter04_activity.md
```

---

## 4. 활동 1: SQL 명령어 역할 정리

다음 SQL 명령어의 역할을 작성하세요.

| SQL 명령어 | 역할 | CRUD 분류 | 예시 기능 |
| --- | --- | --- | --- |
| SELECT |  |  |  |
| INSERT |  |  |  |
| UPDATE |  |  |  |
| DELETE |  |  |  |
| WHERE |  |  |  |
| ORDER BY |  |  |  |

### 작성 예시

| SQL 명령어 | 역할 | CRUD 분류 | 예시 기능 |
| --- | --- | --- | --- |
| SELECT | 데이터를 조회한다 | Read | 학생 목록 조회 |

---

## 5. 활동 2: students 테이블 생성 결과 확인

`code/chapter04/basic_crud.sql`의 테이블 생성 SQL을 실행한 뒤, students 테이블 구조를 기록하세요.

| 컬럼명 | 데이터 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| id |  |  |  |
| name |  |  |  |
| email |  |  |  |
| major |  |  |  |
| grade |  |  |  |
| created_at |  |  |  |

### 확인할 내용

```text
- id가 기본키인지 확인한다.
- name과 email이 NOT NULL인지 확인한다.
- email이 UNIQUE인지 확인한다.
- created_at에 기본값이 있는지 확인한다.
```

---

## 6. 활동 3: INSERT 실행 결과 기록

다음 SQL을 실행한 뒤 결과를 기록하세요.

```sql
INSERT INTO students (name, email, major, grade)
VALUES
    ('김민지', 'minji@example.com', '컴퓨터공학', 2),
    ('이준호', 'junho@example.com', '데이터사이언스', 3),
    ('박서연', 'seoyeon@example.com', '경영학', 1),
    ('최현우', 'hyunwoo@example.com', '컴퓨터공학', 4),
    ('정하늘', 'haneul@example.com', 'AI데이터공학', 2);
```

| 항목 | 작성 |
| --- | --- |
| 입력한 행 수 |  |
| 입력한 컬럼 |  |
| INSERT 실행 성공 여부 |  |
| 오류가 있었다면 오류 메시지 |  |

---

## 7. 활동 4: SELECT 실행 결과 기록

다음 SQL을 실행하고 결과를 기록하세요.

```sql
SELECT *
FROM students;
```

| id | name | email | major | grade |
| ---: | --- | --- | --- | ---: |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

다음 SQL도 실행해 보세요.

```sql
SELECT name, email, major
FROM students;
```

| 질문 | 답변 |
| --- | --- |
| 두 SELECT 결과의 차이는 무엇인가? |  |
| `SELECT *`의 의미는 무엇인가? |  |
| 실무에서 필요한 컬럼만 선택하는 것이 좋은 이유는 무엇인가? |  |

---

## 8. 활동 5: WHERE 조건 조회

다음 SQL을 실행하고 결과를 기록하세요.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학';
```

| 항목 | 작성 |
| --- | --- |
| 조회 조건 |  |
| 조회된 학생 수 |  |
| 조회된 학생 이름 |  |

다음 SQL도 실행합니다.

```sql
SELECT *
FROM students
WHERE grade >= 3;
```

| 항목 | 작성 |
| --- | --- |
| 조회 조건 |  |
| 조회된 학생 수 |  |
| 조회된 학생 이름 |  |

---

## 9. 활동 6: AND, OR 조건 비교

다음 두 SQL의 결과 차이를 기록하세요.

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학'
  AND grade >= 3;
```

```sql
SELECT *
FROM students
WHERE major = '컴퓨터공학'
   OR major = '데이터사이언스';
```

| SQL | 조건 의미 | 결과 요약 |
| --- | --- | --- |
| AND 조건 |  |  |
| OR 조건 |  |  |

### 질문

```text
AND와 OR의 차이를 본인의 말로 설명하세요.
```

---

## 10. 활동 7: ORDER BY 정렬 결과 비교

다음 SQL을 실행하고 결과를 비교하세요.

```sql
SELECT *
FROM students
ORDER BY grade ASC;
```

```sql
SELECT *
FROM students
ORDER BY grade DESC;
```

| 정렬 방식 | 의미 | 첫 번째로 조회된 학생 | 마지막으로 조회된 학생 |
| --- | --- | --- | --- |
| ASC |  |  |  |
| DESC |  |  |  |

---

## 11. 활동 8: UPDATE 전후 확인

UPDATE를 실행하기 전에 반드시 수정 대상을 SELECT로 확인합니다.

### 1단계: 수정 대상 확인

```sql
SELECT *
FROM students
WHERE email = 'junho@example.com';
```

| 확인 항목 | 작성 |
| --- | --- |
| 수정 대상 학생 이름 |  |
| 수정 전 grade |  |

### 2단계: UPDATE 실행

```sql
UPDATE students
SET grade = 4
WHERE email = 'junho@example.com';
```

| 확인 항목 | 작성 |
| --- | --- |
| UPDATE 실행 성공 여부 |  |
| 사용한 WHERE 조건 |  |

### 3단계: 수정 결과 확인

```sql
SELECT *
FROM students
WHERE email = 'junho@example.com';
```

| 확인 항목 | 작성 |
| --- | --- |
| 수정 후 grade |  |
| 수정이 의도대로 되었는가? |  |

---

## 12. 활동 9: DELETE 전후 확인

DELETE를 실행하기 전에 반드시 삭제 대상을 SELECT로 확인합니다.

### 1단계: 삭제 대상 확인

```sql
SELECT *
FROM students
WHERE email = 'seoyeon@example.com';
```

| 확인 항목 | 작성 |
| --- | --- |
| 삭제 대상 학생 이름 |  |
| 삭제 전 조회 여부 |  |

### 2단계: DELETE 실행

```sql
DELETE FROM students
WHERE email = 'seoyeon@example.com';
```

| 확인 항목 | 작성 |
| --- | --- |
| DELETE 실행 성공 여부 |  |
| 사용한 WHERE 조건 |  |

### 3단계: 삭제 결과 확인

```sql
SELECT *
FROM students;
```

| 확인 항목 | 작성 |
| --- | --- |
| 삭제 후 남은 학생 수 |  |
| 삭제 대상이 사라졌는가? |  |

---

## 13. 활동 10: 위험한 SQL 검토

다음 SQL은 위험할 수 있습니다. 왜 위험한지 설명하세요.

```sql
UPDATE students
SET grade = 1;
```

| 검토 항목 | 작성 |
| --- | --- |
| WHERE 조건이 있는가? |  |
| 영향을 받는 행의 범위 |  |
| 위험한 이유 |  |
| 실행 전 먼저 해야 할 SELECT |  |

다음 SQL도 검토하세요.

```sql
DELETE FROM students;
```

| 검토 항목 | 작성 |
| --- | --- |
| WHERE 조건이 있는가? |  |
| 영향을 받는 행의 범위 |  |
| 위험한 이유 |  |
| 실행 전 먼저 해야 할 SELECT |  |

---

## 14. 활동 11: AI 생성 SQL 검토하기

ChatGPT 또는 Codex가 다음 SQL을 생성했다고 가정합니다.

```sql
DELETE FROM students
WHERE major = '경영학';
```

이 SQL을 바로 실행하지 말고 검토하세요.

| 검토 항목 | 작성 |
| --- | --- |
| 대상 테이블은 적절한가? |  |
| 대상 컬럼은 적절한가? |  |
| WHERE 조건은 있는가? |  |
| 삭제 대상은 몇 명인가? |  |
| 실행 전 먼저 해야 할 SQL은 무엇인가? |  |
| 이 SQL을 실행해도 되는 상황은 무엇인가? |  |
| 실행하면 안 되는 상황은 무엇인가? |  |

### 먼저 실행해야 할 SQL

```sql
[여기에 작성]
```

---

## 15. 활동 12: 나만의 CRUD SQL 작성

다음 요구사항을 만족하는 SQL을 직접 작성하세요.

### 요구사항

```text
1. 학생 1명을 새로 추가한다.
2. 전체 학생을 조회한다.
3. 새로 추가한 학생의 전공을 수정한다.
4. 수정 전후를 SELECT로 확인한다.
5. 새로 추가한 학생을 삭제한다.
6. 삭제 전후를 SELECT로 확인한다.
```

### 작성 공간

```sql
-- 1. INSERT

-- 2. SELECT 전체 조회

-- 3. UPDATE 전 대상 확인

-- 4. UPDATE 실행

-- 5. UPDATE 후 결과 확인

-- 6. DELETE 전 대상 확인

-- 7. DELETE 실행

-- 8. DELETE 후 결과 확인
```

---

## 16. 제출 양식

아래 형식을 그대로 복사하여 제출 파일에 사용해도 됩니다.

```markdown
# Chapter 04 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. SQL 명령어 역할 정리

[활동 1 표 작성]

## 3. students 테이블 구조 확인

[활동 2 표 작성]

## 4. INSERT 실행 결과

- 입력한 행 수:
- 실행 성공 여부:
- 오류 메시지:

## 5. SELECT 실행 결과

[전체 조회 결과 및 컬럼 선택 결과 차이 작성]

## 6. WHERE 조건 조회 결과

[조건별 조회 결과 작성]

## 7. ORDER BY 정렬 결과

[ASC/DESC 비교 작성]

## 8. UPDATE 전후 확인

- UPDATE 전 SELECT 결과:
- 실행한 UPDATE:
- UPDATE 후 SELECT 결과:

## 9. DELETE 전후 확인

- DELETE 전 SELECT 결과:
- 실행한 DELETE:
- DELETE 후 SELECT 결과:

## 10. 위험 SQL 검토

[위험한 UPDATE/DELETE 문제점 작성]

## 11. AI 생성 SQL 검토

- AI가 만든 SQL:
- 먼저 실행해야 할 SELECT:
- 실행 가능 여부 판단:
- 수정한 SQL:

## 12. 나만의 CRUD SQL

[직접 작성한 SQL]

## 13. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 17. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| SQL 기본 개념 이해 | 20 | SELECT, INSERT, UPDATE, DELETE, WHERE, ORDER BY의 역할을 정확히 설명했는가 |
| SQL 실행 결과 기록 | 25 | basic_crud.sql 실행 결과를 구체적으로 기록했는가 |
| UPDATE/DELETE 안전 절차 | 25 | 수정/삭제 전후 SELECT 확인 과정을 정확히 수행했는가 |
| AI 생성 SQL 검토 | 20 | AI가 만든 SQL의 위험 요소와 실행 전 확인 절차를 설명했는가 |
| 제출 형식 | 10 | 지정된 형식에 맞게 명확히 작성했는가 |

---

## 18. 피드백 코멘트 예시

### 우수한 경우

```text
SELECT, INSERT, UPDATE, DELETE의 역할을 CRUD 흐름과 잘 연결했습니다.
특히 UPDATE와 DELETE를 실행하기 전에 SELECT로 대상 데이터를 확인한 점이 좋습니다.
AI가 생성한 DELETE SQL도 바로 실행하지 않고 영향 범위를 먼저 확인해야 한다고 설명해 안전한 SQL 실행 습관을 잘 보여 주었습니다.
```

### 보완이 필요한 경우

```text
기본 SQL 실행 결과는 작성되어 있지만 UPDATE와 DELETE 실행 전 SELECT 확인 과정이 부족합니다.
수정이나 삭제 SQL은 문법이 맞는 것보다 어떤 행이 영향을 받는지 먼저 확인하는 것이 중요합니다.
다음 실습에서는 UPDATE/DELETE 전후 SELECT 결과를 반드시 함께 기록해 주세요.
```

---

## 19. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. Chapter 04 핵심 개념 설명: 20분
2. basic_crud.sql 실행 및 SELECT/INSERT 확인: 20분
3. WHERE/ORDER BY 결과 비교: 15분
4. UPDATE 전후 확인 실습: 15분
5. DELETE 전후 확인 실습: 15분
6. 위험 SQL 및 AI 생성 SQL 검토 토론: 20분
7. 전체 공유 및 정리: 15분
```

온라인 수업에서는 학생들이 화면 캡처 또는 실행 결과 표를 함께 제출하도록 하면 실습 여부를 확인하기 쉽습니다.

---

## 20. 핵심 정리

이 활동의 핵심은 SQL을 실행하는 것이 아니라, **실행 전후의 데이터 변화를 설명하는 것**입니다.

```text
SELECT는 확인하고,
INSERT는 추가하고,
UPDATE는 조건에 맞는 데이터를 수정하고,
DELETE는 조건에 맞는 데이터를 삭제한다.

특히 UPDATE와 DELETE는 실행 전 SELECT로 대상을 확인해야 한다.
AI가 만든 SQL도 사람이 영향 범위를 검토한 뒤 실행해야 한다.
```
