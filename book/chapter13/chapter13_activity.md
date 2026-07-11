# Chapter 13 실습 자료

## ChatGPT와 Codex로 DB 설계 검증하기

> 용도: 자기주도 실습 / Chapter 13 보조 자료

---

## 1. 실습 개요

이 실습 자료는 ChatGPT와 Codex가 생성한 데이터베이스 설계와 SQL을 사람이 검토하고 보완하는 연습을 위한 자료입니다.

핵심은 AI가 만든 결과를 그대로 믿는 것이 아니라, **요구사항, ERD, 테이블 역할, 기본키, 외래키, 제약조건, 데이터 타입, 정규화, 보안** 관점에서 검토하는 것입니다.

```text
AI가 만든 설계는 정답이 아니라 초안이다.
사람은 요구사항과 데이터 정합성 기준으로 설계를 검토해야 한다.
```

---

## 2. 이 자료에서 확인할 내용

이 자료를 따라가면 다음 내용을 직접 확인할 수 있습니다.

```text
1. AI가 만든 DB 설계 초안을 검토할 수 있다.
2. 나쁜 테이블 설계의 문제점을 찾을 수 있다.
3. 정규화된 좋은 설계와 비교할 수 있다.
4. PK, FK, UNIQUE, CHECK, NOT NULL의 필요성을 설명할 수 있다.
5. information_schema 조회 결과를 해석할 수 있다.
6. AI 생성 SQL 실행 전 안전 검토를 수행할 수 있다.
7. Codex 오류 수정 루프를 설명할 수 있다.
8. AI에게 DB 설계를 검토시키는 프롬프트를 작성할 수 있다.
```

---

## 3. 실습 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 실습 데이터베이스
- code/chapter13/ai_db_design_review_practice.sql
- ChatGPT 또는 Codex
```

### 주의 사항

```text
- 운영 데이터베이스에서 실행하지 않습니다.
- 실습용 DB에서만 실행합니다.
- DROP TABLE 구문은 실습 테이블 초기화를 위한 것입니다.
- 실제 개인정보, 실제 카드번호, 실제 결제정보를 사용하지 않습니다.
- AI가 만든 SQL은 실행 전 반드시 사람이 읽고 검토합니다.
```

### 실습 기록 파일명 예시

```text
chapter13_ai_db_review_practice.md
```

예시:

```text
chapter13_ai_db_review_practice_hong.md
```

---

## 4. 실습 1: AI 설계 초안 검토 기준 정리

AI가 데이터베이스 설계를 생성했을 때 확인해야 할 항목을 정리합니다.

| 검토 항목 | 확인 질문 | 중요한 이유 |
| --- | --- | --- |
| 요구사항 반영 |  |  |
| 테이블 역할 |  |  |
| 기본키 |  |  |
| 외래키 |  |  |
| 데이터 타입 |  |  |
| NOT NULL |  |  |
| UNIQUE |  |  |
| CHECK |  |  |
| 정규화 |  |  |
| 보안/개인정보 |  |  |

### 생각해 보기

```text
AI가 만든 SQL이 실행된다고 해서 좋은 설계라고 볼 수 없는 이유를 설명해 봅니다.
```

---

## 5. 실습 2: 실습 SQL 실행 전 안전 검토

다음 파일을 실행하기 전에 안전 검토표를 작성합니다.

```text
code/chapter13/ai_db_design_review_practice.sql
```

| 확인 항목 | 확인 결과 |
| --- | --- |
| 운영 DB가 아닌 실습 DB인가? |  |
| DROP TABLE 구문의 대상이 실습 테이블인가? |  |
| 실제 개인정보가 포함되어 있지 않은가? |  |
| 실제 결제정보나 카드번호가 포함되어 있지 않은가? |  |
| 실행 후 생성되는 테이블 이름을 확인했는가? |  |
| 오류 확인용 INSERT가 주석 처리되어 있는가? |  |

### 질문

```text
AI가 생성한 SQL을 운영 DB에서 바로 실행하면 어떤 위험이 있을까요?
```

---

## 6. 실습 3: AI가 만든 나쁜 설계 분석

실습 SQL의 `ai_bad_enrollments` 테이블을 확인합니다.

```sql
SELECT *
FROM ai_bad_enrollments
ORDER BY id;
```

다음 표를 완성해 봅니다.

| 컬럼 | 문제 여부 | 문제 설명 | 수정 방향 |
| --- | --- | --- | --- |
| student_name |  |  |  |
| student_email |  |  |  |
| course_title |  |  |  |
| course_price |  |  |  |
| instructor_name |  |  |  |
| payment_status |  |  |  |
| card_number |  |  |  |
| enrollment_status |  |  |  |
| created_at |  |  |  |

### 생각해 보기

```text
ai_bad_enrollments 테이블은 왜 하나의 테이블에 너무 많은 역할이 섞여 있다고 볼 수 있나요?
```

---

## 7. 실습 4: 나쁜 설계의 중복 데이터 확인

다음 SQL을 실행하고 결과를 기록합니다.

```sql
SELECT
    student_email,
    COUNT(*) AS duplicated_rows
FROM ai_bad_enrollments
GROUP BY student_email
HAVING COUNT(*) > 1;
```

| student_email | duplicated_rows | 해석 |
| --- | ---: | --- |
|  |  |  |

### 생각해 보기

```text
학생 정보가 여러 행에 반복 저장되면 어떤 문제가 생길 수 있나요?
```

---

## 8. 실습 5: 상태값과 데이터 타입 문제 확인

다음 SQL을 실행하고 결과를 기록합니다.

```sql
SELECT DISTINCT payment_status
FROM ai_bad_enrollments;
```

```sql
SELECT DISTINCT enrollment_status
FROM ai_bad_enrollments;
```

| 구분 | 조회 결과 | 문제점 |
| --- | --- | --- |
| payment_status |  |  |
| enrollment_status |  |  |

다음 항목도 확인합니다.

| 항목 | 문제 설명 |
| --- | --- |
| course_price가 TEXT인 문제 |  |
| created_at이 TEXT인 문제 |  |
| card_number를 평문 저장하는 문제 |  |

---

## 9. 실습 6: 좋은 설계의 테이블 역할 비교

좋은 설계에서는 테이블이 다음처럼 분리됩니다.

```text
ai_good_students
ai_good_instructors
ai_good_courses
ai_good_enrollments
ai_good_payments
```

각 테이블의 역할을 작성해 봅니다.

| 테이블 | 역할 | 주요 PK | 주요 FK |
| --- | --- | --- | --- |
| ai_good_students |  |  |  |
| ai_good_instructors |  |  |  |
| ai_good_courses |  |  |  |
| ai_good_enrollments |  |  |  |
| ai_good_payments |  |  |  |

### 생각해 보기

```text
수강신청과 결제 정보를 분리하면 어떤 장점이 있나요?
```

---

## 10. 실습 7: 좋은 설계 조회 결과 확인

다음 SQL을 실행하고 결과 일부를 기록합니다.

```sql
SELECT
    e.id AS enrollment_id,
    s.name AS student_name,
    s.email AS student_email,
    c.title AS course_title,
    c.level AS course_level,
    c.price AS course_price,
    i.name AS instructor_name,
    e.status AS enrollment_status,
    p.payment_status,
    p.amount
FROM ai_good_enrollments e
JOIN ai_good_students s ON e.student_id = s.id
JOIN ai_good_courses c ON e.course_id = c.id
JOIN ai_good_instructors i ON c.instructor_id = i.id
LEFT JOIN ai_good_payments p ON p.enrollment_id = e.id
ORDER BY e.id;
```

| enrollment_id | student_name | course_title | enrollment_status | payment_status | amount |
| ---: | --- | --- | --- | --- | ---: |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

### 생각해 보기

```text
좋은 설계에서는 JOIN이 필요합니다. 그럼에도 테이블을 분리하는 이유는 무엇인가요?
```

---

## 11. 실습 8: 제약조건 오류 확인

실습 SQL에는 오류를 확인하기 위한 INSERT 예시가 주석으로 포함되어 있습니다.

다음 중 2개 이상을 선택해 하나씩 주석 해제하고 오류 메시지를 확인합니다.

```text
1. 이메일 중복 오류
2. 존재하지 않는 학생으로 수강신청
3. 잘못된 상태값 입력
4. 음수 가격 입력
5. 결제 금액 음수 입력
```

오류 확인 결과를 기록합니다.

| 시도한 오류 | 발생한 오류 메시지 요약 | 막아 준 제약조건 | 의미 |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |

### 생각해 보기

```text
제약조건은 애플리케이션 코드 검증과 별도로 왜 데이터베이스에도 필요할까요?
```

---

## 12. 실습 9: information_schema로 메타데이터 확인

다음 SQL을 실행해 테이블, 컬럼, 제약조건, 외래키 정보를 확인합니다.

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'ai_%'
ORDER BY table_name;
```

```sql
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name LIKE 'ai_good_%'
ORDER BY table_name, ordinal_position;
```

```sql
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.table_name LIKE 'ai_good_%'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;
```

확인한 내용을 요약합니다.

| 확인 항목 | 확인 결과 요약 |
| --- | --- |
| 생성된 테이블 목록 |  |
| NOT NULL 컬럼 예시 |  |
| UNIQUE 제약조건 예시 |  |
| CHECK 제약조건 예시 |  |
| FOREIGN KEY 제약조건 예시 |  |

---

## 13. 실습 10: 외래키 관계 해석

다음 SQL을 실행하고 외래키 관계를 기록합니다.

```sql
SELECT
    tc.table_name AS source_table,
    kcu.column_name AS source_column,
    ccu.table_name AS target_table,
    ccu.column_name AS target_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name LIKE 'ai_good_%'
ORDER BY source_table, source_column;
```

| source_table | source_column | target_table | target_column | 관계 설명 |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

### 생각해 보기

```text
외래키가 없으면 어떤 잘못된 데이터가 들어갈 수 있나요?
```

---

## 14. 실습 11: AI 설계 검토 체크 쿼리 해석

다음 점검 쿼리의 목적을 설명해 봅니다.

| 점검 쿼리 | 목적 | 문제가 발견되면 수정 방향 |
| --- | --- | --- |
| 학생 이메일 중복 여부 확인 |  |  |
| 같은 학생이 같은 강의를 중복 신청했는지 확인 |  |  |
| 결제 금액과 강의 가격이 다른 경우 확인 |  |  |
| paid 상태인데 paid_at이 없는 경우 확인 |  |  |
| 수강신청 상태와 결제 상태 함께 확인 |  |  |

---

## 15. 실습 12: SQL Anti-pattern 찾기

다음 Anti-pattern의 문제와 수정 방향을 작성해 봅니다.

| Anti-pattern | 문제 | 수정 방향 |
| --- | --- | --- |
| 모든 컬럼을 TEXT로 저장 |  |  |
| 하나의 테이블에 모든 정보 저장 |  |  |
| FK 없이 id만 저장 |  |  |
| 상태값 제한 없음 |  |  |
| SELECT * 남용 |  |  |
| 민감 정보 평문 저장 |  |  |

---

## 16. 실습 13: Codex 오류 수정 루프 작성

다음 상황을 가정하세요.

```text
Codex가 생성한 schema.sql을 실행했더니 다음 오류가 발생했다.
ERROR: relation "ai_good_students" does not exist
```

Codex에게 수정 요청하는 프롬프트를 작성해 봅니다.

```text
[여기에 작성]
```

프롬프트에는 다음을 포함해야 합니다.

```text
- 오류 메시지
- 수정 대상 파일명
- 유지해야 할 요구사항
- 수정 방향
- 수정 이유를 주석으로 남기라는 요청
```

---

## 17. 실습 14: AI 검토 프롬프트 작성

ChatGPT에게 AI가 만든 DDL을 검토시키는 프롬프트를 작성해 봅니다.

프롬프트에는 다음 기준을 포함해야 합니다.

```text
1. 기본키가 모든 테이블에 있는가?
2. 필요한 외래키가 누락되지 않았는가?
3. N:M 관계가 중간 테이블로 표현되었는가?
4. NOT NULL, UNIQUE, CHECK 제약조건이 적절한가?
5. 데이터 타입이 적절한가?
6. 정규화 관점에서 중복이 과도하지 않은가?
7. 개인정보나 보안 위험이 있는 컬럼이 있는가?
8. PostgreSQL에서 실행 가능한 문법인가?
```

작성한 프롬프트:

```text
[여기에 작성]
```

---

## 18. 실습 15: AI 답변 비판적으로 검토하기

AI가 다음처럼 답했다고 가정합니다.

```text
수강신청과 결제는 한 테이블에 넣는 것이 간단하므로 가장 좋습니다.
```

다음 기준으로 검토해 봅니다.

| 검토 기준 | 문제 여부 | 설명 | 더 나은 방향 |
| --- | --- | --- | --- |
| 테이블 역할 분리 |  |  |  |
| 결제 이력 관리 |  |  |  |
| 정규화 |  |  |  |
| 변경 가능성 |  |  |  |
| 조회 편의성과 데이터 정합성 균형 |  |  |  |

---

## 19. 실습 기록 양식

아래 형식을 활용하면 실행 결과와 검토 내용을 한곳에 정리할 수 있습니다.

```markdown
# Chapter 13 실습 기록

## 1. 기본 정보

- 이름:
- 실습일:

## 2. AI 설계 초안 검토 기준

[실습 1 작성]

## 3. 실행 전 안전 검토

[실습 2 작성]

## 4. 나쁜 설계 분석

[실습 3~5 작성]

## 5. 좋은 설계 비교

[실습 6~8 작성]

## 6. information_schema 결과 해석

[실습 9~10 작성]

## 7. AI 설계 검토 체크 쿼리

[실습 11 작성]

## 8. SQL Anti-pattern 정리

[실습 12 작성]

## 9. Codex 오류 수정 루프

[실습 13 작성]

## 10. AI 검토 프롬프트

[실습 14 작성]

## 11. AI 답변 비판적 검토

[실습 15 작성]

## 12. 느낀 점

AI가 만든 DB 설계와 SQL을 검토하면서 알게 된 점을 3~5문장으로 정리해 봅니다.
```

---

## 20. 완성도 점검 기준

실습을 마친 뒤 다음 기준으로 완성도를 점검해 보세요.

| 점검 항목 | 중요도 | 확인 기준 |
| --- | --- | --- |
| AI 설계 검토 기준 이해 | 20 | PK/FK/제약조건/정규화/보안 검토 기준을 설명했는가 |
| 나쁜 설계 문제 분석 | 25 | 중복, 타입, 상태값, 민감정보, 테이블 역할 혼합 문제를 찾았는가 |
| 좋은 설계 비교와 제약조건 이해 | 25 | 좋은 설계의 테이블 역할, PK/FK/UNIQUE/CHECK를 해석했는가 |
| 메타데이터 및 검증 쿼리 해석 | 15 | information_schema와 점검 쿼리 결과를 해석했는가 |
| AI/Codex 프롬프트와 기록 형식 | 15 | 오류 수정 루프와 AI 검토 프롬프트를 구체적으로 정리했는가 |

---

## 21. 피드백 코멘트 예시

### 우수한 경우

```text
AI가 만든 나쁜 설계의 문제를 단순히 틀렸다고 하지 않고, 중복 데이터, 잘못된 타입, 상태값 제약 부족, 민감 정보 저장 문제로 구체적으로 설명했습니다.
좋은 설계에서 PK/FK/UNIQUE/CHECK가 어떤 문제를 막는지 잘 해석했고, AI 검토 프롬프트도 실무적으로 작성했습니다.
```

### 보완이 필요한 경우

```text
나쁜 설계의 문제는 일부 찾았지만 왜 문제가 되는지 설명이 부족합니다.
좋은 설계의 제약조건을 단순히 나열하기보다 어떤 잘못된 데이터를 막는지 함께 설명해 주세요.
AI 검토 프롬프트에는 기본키, 외래키, 제약조건, 정규화, 보안 기준을 더 구체적으로 포함하면 좋겠습니다.
```

---

## 22. 추천 진행 흐름

이 실습은 다음 흐름으로 진행하면 AI 생성 결과를 검토하는 과정을 자연스럽게 확인할 수 있습니다.

```text
1. AI 생성 설계는 초안이라는 관점 확인
2. 나쁜 설계 테이블 분석
3. 좋은 설계 SQL 실행 및 비교
4. 제약조건 오류 확인
5. information_schema 결과 해석
6. SQL Anti-pattern 정리
7. Codex 오류 수정 루프 작성
8. AI 검토 프롬프트 작성과 실습 기록 정리
```

SQL 작성 자체보다 **AI 결과를 읽고 검토하는 사고 과정**에 초점을 둡니다.

---

## 23. 핵심 정리

이 실습의 핵심은 AI 생성 결과를 검토하는 능력입니다.

```text
AI가 만든 DB 설계는 정답이 아니라 초안이다.
SQL이 실행된다고 해서 좋은 설계는 아니다.
좋은 설계는 테이블 역할, PK, FK, 제약조건, 데이터 타입, 정규화, 보안을 함께 고려한다.
Codex는 오류 수정에 유용하지만 오류 원인과 수정 방향은 사람이 이해해야 한다.
AI 시대에는 SQL 작성 능력만큼 SQL 검토 능력이 중요하다.
```
