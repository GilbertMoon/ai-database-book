# Chapter 11 활동 자료

## 데이터베이스 보안과 백업

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 11 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 11의 데이터베이스 보안과 백업을 실습하기 위한 자료입니다.

학습자는 실습용 데이터베이스에서 사용자, 권한, GRANT, REVOKE, 권한 확인, SQL Injection 위험 검토, 백업/복구 점검 흐름을 학습합니다.

이 활동의 핵심은 보안 명령을 많이 외우는 것이 아니라, **누구에게 어떤 권한을 왜 부여해야 하는지 설명하고, 백업이 실제로 복구 가능한지 점검하는 것**입니다.

```text
- 누가 데이터베이스에 접속할 수 있는가?
- 어떤 사용자가 어떤 테이블을 읽을 수 있는가?
- 어떤 사용자가 데이터를 수정할 수 있는가?
- 권한이 최소 권한 원칙에 맞는가?
- SQL Injection 위험이 있는 코드 패턴은 무엇인가?
- 백업 파일은 실제로 복구 가능한가?
- AI가 만든 보안/백업 명령을 그대로 실행해도 되는가?
```

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. 최소 권한 원칙을 설명할 수 있다.
2. 읽기 전용 계정과 서비스 계정을 구분할 수 있다.
3. GRANT와 REVOKE의 차이를 설명할 수 있다.
4. has_table_privilege 결과를 해석할 수 있다.
5. SQL Injection 위험 패턴을 식별할 수 있다.
6. 백업 명령과 복구 명령의 구조를 설명할 수 있다.
7. 백업 후 복구 테스트가 필요한 이유를 설명할 수 있다.
8. AI가 제안한 보안 설정과 백업 명령을 검토할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 실습 데이터베이스
- code/chapter11/security_backup_practice.sql
- ChatGPT 또는 Codex
```

### 주의 사항

```text
- 운영 데이터베이스에서 실습하지 않습니다.
- 실습용 로컬 DB 또는 교육용 DB에서만 진행합니다.
- 예시 비밀번호를 실제 환경에서 사용하지 않습니다.
- CREATE ROLE, GRANT, REVOKE는 관리자 권한이 필요할 수 있습니다.
- 백업/복구 명령은 SQL Editor가 아니라 터미널에서 실행하는 명령입니다.
```

### 제출 파일명 권장

```text
학번_이름_chapter11_activity.md
```

예시:

```text
20260001_홍길동_chapter11_activity.md
```

---

## 4. 활동 1: 실습 SQL 실행 준비

다음 파일을 확인합니다.

```text
code/chapter11/security_backup_practice.sql
```

실행 전 다음 내용을 기록하세요.

| 항목 | 작성 |
| --- | --- |
| 실습 DB 이름 |  |
| 운영 DB가 아닌지 확인했는가? |  |
| 현재 접속 사용자 |  |
| CREATE ROLE 실행 권한이 있는가? |  |
| 백업/복구 명령을 터미널 명령으로 구분했는가? |  |
| 주석 처리된 명령과 실제 실행 명령을 구분했는가? |  |

---

## 5. 활동 2: 실습용 테이블 확인

실습 SQL에서 생성되는 테이블을 확인합니다.

```text
security_students
security_courses
security_enrollments
```

다음 조회 결과를 기록하세요.

| 테이블 | 데이터 수 | 비고 |
| --- | ---: | --- |
| security_students |  |  |
| security_courses |  |  |
| security_enrollments |  |  |

### 질문

```text
보안 실습에서 실제 개인정보가 아니라 가상 데이터를 사용해야 하는 이유를 설명하세요.
```

---

## 6. 활동 3: 현재 사용자와 역할 확인

다음 SQL의 결과를 기록합니다.

```sql
SELECT current_user AS current_user_name;
SELECT current_database() AS current_database_name;
```

| 항목 | 결과 |
| --- | --- |
| current_user |  |
| current_database |  |

역할 목록 조회 결과에서 다음 항목의 의미를 정리하세요.

| 컬럼 | 의미 |
| --- | --- |
| rolname |  |
| rolsuper |  |
| rolcreatedb |  |
| rolcreaterole |  |
| rolcanlogin |  |

---

## 7. 활동 4: 읽기 전용 역할 설계

다음 역할을 설계한다고 가정합니다.

```text
역할 이름: readonly_user
목적: 리포트 조회 및 학습용 조회
허용 권한: SELECT
금지 권한: INSERT, UPDATE, DELETE
```

권한 설계표를 작성하세요.

| 대상 테이블 | SELECT | INSERT | UPDATE | DELETE | 이유 |
| --- | --- | --- | --- | --- | --- |
| security_students |  |  |  |  |  |
| security_courses |  |  |  |  |  |
| security_enrollments |  |  |  |  |  |

### 질문

```text
readonly_user에게 INSERT, UPDATE, DELETE 권한을 주지 않는 이유를 설명하세요.
```

---

## 8. 활동 5: GRANT 명령 해석

다음 SQL의 의미를 설명하세요.

```sql
GRANT CONNECT ON DATABASE ai_database_book TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON security_students TO readonly_user;
GRANT SELECT ON security_courses TO readonly_user;
GRANT SELECT ON security_enrollments TO readonly_user;
```

| SQL | 의미 |
| --- | --- |
| GRANT CONNECT ON DATABASE ... |  |
| GRANT USAGE ON SCHEMA ... |  |
| GRANT SELECT ON security_students ... |  |
| GRANT SELECT ON security_courses ... |  |
| GRANT SELECT ON security_enrollments ... |  |

---

## 9. 활동 6: 권한 확인 결과 해석

다음 권한 확인 결과를 기록하세요.

```sql
has_table_privilege('readonly_user', 'security_students', 'SELECT')
has_table_privilege('readonly_user', 'security_students', 'INSERT')
has_table_privilege('readonly_user', 'security_students', 'UPDATE')
has_table_privilege('readonly_user', 'security_students', 'DELETE')
```

| 권한 | 결과 | 해석 |
| --- | --- | --- |
| SELECT |  |  |
| INSERT |  |  |
| UPDATE |  |  |
| DELETE |  |  |

### 질문

```text
SELECT만 true이고 INSERT/UPDATE/DELETE가 false라면, 최소 권한 원칙에 맞는 상태라고 볼 수 있나요?
이유를 설명하세요.
```

---

## 10. 활동 7: REVOKE 명령 해석

다음 SQL의 의미를 설명하세요.

```sql
REVOKE SELECT ON security_courses FROM readonly_user;
```

| 항목 | 작성 |
| --- | --- |
| 어떤 권한을 회수하는가? |  |
| 어떤 테이블에 대한 권한인가? |  |
| 어떤 역할에서 회수하는가? |  |
| 회수 후 예상 결과는 무엇인가? |  |

### 질문

```text
권한을 부여하는 것만큼 권한을 회수하는 절차가 중요한 이유를 설명하세요.
```

---

## 11. 활동 8: 서비스 계정 권한 설계

다음 역할을 설계한다고 가정합니다.

```text
역할 이름: app_enrollment_user
목적: 수강신청 서비스에서 사용하는 DB 접속 계정
필요 기능: 학생 조회, 강의 조회, 수강신청 등록 및 상태 변경
```

권한 설계표를 작성하세요.

| 대상 테이블 | SELECT | INSERT | UPDATE | DELETE | 이유 |
| --- | --- | --- | --- | --- | --- |
| security_students |  |  |  |  |  |
| security_courses |  |  |  |  |  |
| security_enrollments |  |  |  |  |  |

### 질문

```text
app_enrollment_user에게 DELETE 권한을 기본적으로 주지 않는 것이 왜 안전할 수 있나요?
```

---

## 12. 활동 9: SQL Injection 위험 검토

다음은 위험한 방식의 개념 예시입니다.

```text
SQL 문자열 + 사용자 입력값 + SQL 문자열
```

다음 질문에 답하세요.

| 질문 | 답변 |
| --- | --- |
| 사용자 입력값을 SQL 문자열에 직접 이어 붙이면 왜 위험한가? |  |
| 파라미터 바인딩은 어떤 점에서 더 안전한가? |  |
| AI가 만든 로그인 SQL에서 어떤 부분을 확인해야 하는가? |  |
| SQL Injection을 막기 위해 개발자가 지켜야 할 원칙은 무엇인가? |  |

안전한 방향을 한 문장으로 정리하세요.

```text
작성:
```

---

## 13. 활동 10: 개인정보 보호 점검

온라인 강의 시스템에서 개인정보 또는 민감정보가 될 수 있는 항목을 분류하세요.

| 데이터 항목 | 개인정보 가능성 | 주의할 점 |
| --- | --- | --- |
| 이름 |  |  |
| 이메일 |  |  |
| 전화번호 |  |  |
| 결제 관련 정보 |  |  |
| 수강 이력 |  |  |
| 강의 제목 |  |  |

### 질문

```text
수업 실습에서 실제 개인정보를 사용하지 말아야 하는 이유를 설명하세요.
```

---

## 14. 활동 11: 백업 명령 구조 해석

다음 명령의 의미를 해석하세요.

```bash
pg_dump -U postgres -d ai_database_book -f ai_database_book_backup.sql
```

| 구성 | 의미 |
| --- | --- |
| pg_dump |  |
| -U postgres |  |
| -d ai_database_book |  |
| -f ai_database_book_backup.sql |  |

### 질문

```text
백업 파일을 만들었다고 해서 백업이 완성되었다고 볼 수 없는 이유는 무엇인가요?
```

---

## 15. 활동 12: 복구 명령 구조 해석

다음 명령의 의미를 해석하세요.

```bash
psql -U postgres -d ai_database_book_restore -f ai_database_book_backup.sql
```

| 구성 | 의미 |
| --- | --- |
| psql |  |
| -U postgres |  |
| -d ai_database_book_restore |  |
| -f ai_database_book_backup.sql |  |

### 질문

```text
복구 테스트를 운영 DB가 아니라 별도 테스트 DB에서 수행해야 하는 이유를 설명하세요.
```

---

## 16. 활동 13: 복구 후 검증 SQL 설계

복구 테스트용 DB에서 다음 항목을 확인한다고 가정합니다.

| 확인 항목 | 검증 SQL 또는 방법 |
| --- | --- |
| 학생 수가 맞는가? |  |
| 강의 수가 맞는가? |  |
| 수강신청 수가 맞는가? |  |
| JOIN 조회가 정상 동작하는가? |  |
| 주요 테이블 구조가 유지되었는가? |  |

### 질문

```text
복구 후 단순히 테이블이 보이는 것만 확인하면 부족한 이유를 설명하세요.
```

---

## 17. 활동 14: 백업 운영 체크리스트

다음 항목을 기준으로 백업 운영 계획을 작성하세요.

| 항목 | 계획 |
| --- | --- |
| 백업 주기 |  |
| 백업 시간 |  |
| 백업 파일 저장 위치 |  |
| 백업 파일 접근 권한 |  |
| 백업 파일 암호화 필요 여부 |  |
| 백업 보관 기간 |  |
| 복구 테스트 주기 |  |
| 장애 발생 시 담당자 |  |
| 복구 절차 문서 위치 |  |

---

## 18. 활동 15: AI 생성 보안/백업 명령 검토

AI가 다음과 같은 명령을 제안했다고 가정합니다.

```text
- 관리자 권한 계정을 새로 만든다.
- 모든 테이블에 모든 권한을 부여한다.
- 예시 비밀번호를 그대로 사용한다.
- 운영 DB에서 바로 백업과 복구를 실행한다.
```

다음 기준으로 검토하세요.

| 검토 항목 | 문제 여부 | 수정 방향 |
| --- | --- | --- |
| 관리자 권한을 과도하게 부여하는가? |  |  |
| 최소 권한 원칙을 지키는가? |  |  |
| 예시 비밀번호를 그대로 사용하는가? |  |  |
| 운영 DB와 실습 DB를 구분하는가? |  |  |
| 위험한 삭제/덮어쓰기 명령이 있는가? |  |  |
| 백업 파일 저장 위치가 안전한가? |  |  |
| 별도 복구 테스트 절차가 있는가? |  |  |

### 최종 판단

```text
AI가 제안한 명령을 그대로 실행할 수 있는가?
그렇지 않다면 어떤 부분을 수정해야 하는가?
```

---

## 19. 제출 양식

아래 형식을 그대로 복사해서 제출 파일에 사용할 수 있습니다.

```markdown
# Chapter 11 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. 실습 SQL 실행 준비

[활동 1 작성]

## 3. 실습용 테이블 확인

[활동 2 작성]

## 4. 사용자와 역할 확인

[활동 3 작성]

## 5. 읽기 전용 역할 설계

[활동 4 작성]

## 6. GRANT/REVOKE 해석

[활동 5~7 작성]

## 7. 서비스 계정 권한 설계

[활동 8 작성]

## 8. SQL Injection 위험 검토

[활동 9 작성]

## 9. 개인정보 보호 점검

[활동 10 작성]

## 10. 백업/복구 명령 구조 해석

[활동 11~13 작성]

## 11. 백업 운영 체크리스트

[활동 14 작성]

## 12. AI 생성 보안/백업 명령 검토

[활동 15 작성]

## 13. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 20. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| 보안 기본 개념 이해 | 20 | 최소 권한, 계정 분리, 비밀번호 관리 원칙을 설명했는가 |
| 권한 설계와 해석 | 25 | GRANT/REVOKE, 읽기 전용 계정, 서비스 계정 권한을 적절히 설계했는가 |
| SQL Injection 및 개인정보 보호 | 20 | 위험 패턴과 보호 원칙을 설명했는가 |
| 백업/복구 이해 | 20 | 백업 명령, 복구 명령, 복구 테스트 필요성을 설명했는가 |
| AI 명령 검토 및 제출 형식 | 15 | AI 제안 명령을 비판적으로 검토하고 형식에 맞게 제출했는가 |

---

## 21. 피드백 코멘트 예시

### 우수한 경우

```text
최소 권한 원칙을 기준으로 readonly_user와 app_enrollment_user의 권한을 적절히 구분했습니다.
GRANT/REVOKE의 의미를 정확히 해석했고, 백업 후 복구 테스트가 필요한 이유도 명확히 설명했습니다.
AI가 제안한 보안 명령을 그대로 실행하지 않고 위험 요소를 검토한 점이 우수합니다.
```

### 보완이 필요한 경우

```text
권한 설계표는 작성했지만 각 권한을 부여하거나 제외한 이유가 부족합니다.
백업 명령의 구조는 설명했지만 복구 테스트가 필요한 이유를 더 구체적으로 작성해야 합니다.
AI가 제안한 명령의 위험 요소를 최소 권한 원칙과 운영 DB 보호 관점에서 다시 검토해 주세요.
```

---

## 22. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. 데이터베이스 보안 개념 설명: 20분
2. 계정과 권한 설계 토론: 20분
3. GRANT/REVOKE SQL 해석: 25분
4. 권한 확인 결과 기록: 20분
5. SQL Injection 위험 패턴 설명: 20분
6. 백업/복구 명령 구조 설명: 25분
7. AI 생성 명령 검토 활동: 25분
8. 제출 양식 작성 및 공유: 25분
```

초급자에게는 실제 권한 명령을 많이 실행하게 하기보다, 각 명령이 어떤 위험과 책임을 갖는지 해석하게 하는 데 초점을 둡니다.

---

## 23. 핵심 정리

이 활동의 핵심은 데이터베이스를 안전하게 사용하고, 문제가 생겼을 때 복구할 수 있는 기본 태도를 익히는 것입니다.

```text
데이터베이스 보안은 접근과 권한을 통제하는 것이다.
최소 권한 원칙에 따라 필요한 권한만 부여해야 한다.
GRANT는 권한 부여, REVOKE는 권한 회수에 사용한다.
사용자 입력값은 SQL 문자열에 직접 결합하지 않는다.
백업은 데이터 손실에 대비한 안전망이다.
백업은 복구 테스트까지 해야 의미가 있다.
AI가 만든 보안 설정과 백업 명령도 사람이 검토해야 한다.
```
