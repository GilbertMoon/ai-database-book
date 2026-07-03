# Chapter 03 활동 자료

## PostgreSQL과 DBeaver 실습 환경 구축

> 용도: 수업 활동지 / 자기주도 실습 과제 / Chapter 03 보조 자료

---

## 1. 활동 개요

이 활동 자료는 Chapter 03의 내용을 바탕으로, 학습자가 PostgreSQL과 DBeaver 실습 환경을 직접 점검하고 기록할 수 있도록 구성한 실습지입니다.

Chapter 03의 핵심은 단순히 설치를 끝내는 것이 아닙니다. 실제로 PostgreSQL에 연결하고, SQL을 실행하고, 테이블을 만들고, 오류 메시지를 확인하는 데 있습니다.

---

## 2. 학습 목표

이 활동을 마치면 학습자는 다음을 할 수 있어야 합니다.

```text
1. PostgreSQL과 DBeaver의 역할을 설명할 수 있다.
2. DBeaver에서 PostgreSQL 연결 정보를 입력할 수 있다.
3. 실습용 데이터베이스 ai_database_book을 생성할 수 있다.
4. 기본 SQL을 실행해 연결 상태를 확인할 수 있다.
5. setup_check.sql을 실행하고 결과를 기록할 수 있다.
6. UNIQUE 제약조건 오류를 확인하고 의미를 설명할 수 있다.
7. 오류 메시지를 ChatGPT에 질문할 수 있는 형태로 정리할 수 있다.
```

---

## 3. 활동 준비

### 필요한 도구

```text
- PostgreSQL
- DBeaver Community Edition
- GitHub 저장소
- code/chapter03/setup_check.sql
- ChatGPT 또는 Codex
```

### 제출 파일명 권장

```text
학번_이름_chapter03_activity.md
```

예시:

```text
20260001_홍길동_chapter03_activity.md
```

---

## 4. 활동 1: 실습 환경 기본 정보 기록

본인의 실습 환경을 기록하세요.

| 항목 | 작성 |
| --- | --- |
| 운영체제 |  |
| PostgreSQL 설치 여부 |  |
| PostgreSQL 버전 |  |
| DBeaver 설치 여부 |  |
| DBeaver 버전 |  |
| 로컬 DB 사용 여부 |  |
| 클라우드 DB 사용 여부 |  |
| 사용한 클라우드 DB 서비스 |  |

### 작성 예시

| 항목 | 작성 |
| --- | --- |
| 운영체제 | Windows 11 |
| PostgreSQL 설치 여부 | 설치 완료 |
| PostgreSQL 버전 | PostgreSQL 16.x |
| DBeaver 설치 여부 | 설치 완료 |
| 로컬 DB 사용 여부 | 예 |
| 클라우드 DB 사용 여부 | 아니오 |

---

## 5. 활동 2: PostgreSQL 설치 확인

터미널 또는 명령 프롬프트에서 다음 명령어를 실행합니다.

```bash
psql --version
```

실행 결과를 기록하세요.

| 항목 | 작성 |
| --- | --- |
| 실행 명령어 | `psql --version` |
| 실행 결과 |  |
| 정상 실행 여부 |  |
| 오류가 있었다면 오류 메시지 |  |
| 해결 방법 |  |

### 참고

`psql --version`이 실행되지 않아도 DBeaver 연결이 성공하면 실습은 진행할 수 있습니다. 이 경우 PATH 환경변수 문제일 수 있습니다.

---

## 6. 활동 3: DBeaver 연결 정보 작성

DBeaver에서 PostgreSQL 연결을 만들 때 사용한 정보를 기록하세요.

| 항목 | 값 |
| --- | --- |
| DB 종류 | PostgreSQL |
| Host |  |
| Port |  |
| Database |  |
| Username |  |
| Password 기록 여부 | 기록하지 않음 / 별도 보관 |
| Test Connection 성공 여부 |  |

주의:

```text
비밀번호는 제출 파일에 직접 쓰지 않습니다.
제출 파일에는 “별도 보관” 또는 “기록하지 않음”이라고 작성합니다.
```

---

## 7. 활동 4: 실습용 데이터베이스 생성

DBeaver SQL Editor에서 다음 SQL을 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

실행 결과를 기록하세요.

| 항목 | 작성 |
| --- | --- |
| 생성한 데이터베이스 이름 |  |
| SQL 실행 성공 여부 |  |
| 이미 존재한다는 오류 발생 여부 |  |
| DBeaver에서 목록 확인 여부 |  |
| 새 데이터베이스로 재연결 여부 |  |

이미 같은 이름의 데이터베이스가 있다면 다음과 같은 오류가 나올 수 있습니다.

```text
database "ai_database_book" already exists
```

이 경우 이미 만들어진 것이므로 실패로 보지 않습니다.

---

## 8. 활동 5: 기본 SQL 실행 테스트

`ai_database_book` 데이터베이스에 연결한 뒤 다음 SQL을 실행합니다.

```sql
SELECT version();
SELECT current_database();
SELECT 1 + 1 AS result;
```

실행 결과를 기록하세요.

| SQL | 기대 결과 | 실제 결과 |
| --- | --- | --- |
| `SELECT version();` | PostgreSQL 버전 표시 |  |
| `SELECT current_database();` | `ai_database_book` |  |
| `SELECT 1 + 1 AS result;` | `2` |  |

---

## 9. 활동 6: setup_check.sql 실행

GitHub 저장소의 다음 파일을 사용합니다.

```text
code/chapter03/setup_check.sql
```

DBeaver에서 해당 SQL을 실행하고 결과를 기록하세요.

| 항목 | 작성 |
| --- | --- |
| 파일 위치 | `code/chapter03/setup_check.sql` |
| 실행 성공 여부 |  |
| 생성된 테이블 이름 |  |
| 입력된 샘플 데이터 수 |  |
| SELECT 조회 결과 확인 여부 |  |
| 오류 발생 여부 |  |
| 오류 메시지 |  |

---

## 10. 활동 7: students 테이블 구조 확인

DBeaver에서 `students` 테이블 구조를 확인하고 아래 표를 작성하세요.

| 컬럼명 | 데이터 타입 | 제약조건 | 설명 |
| --- | --- | --- | --- |
| id |  |  |  |
| name |  |  |  |
| email |  |  |  |
| created_at |  |  |  |

### 확인할 내용

```text
- id가 기본키인지 확인한다.
- name이 NOT NULL인지 확인한다.
- email이 UNIQUE인지 확인한다.
- created_at에 기본값이 있는지 확인한다.
```

---

## 11. 활동 8: 샘플 데이터 조회 결과 기록

다음 SQL을 실행합니다.

```sql
SELECT *
FROM students;
```

조회 결과를 기록하세요.

| id | name | email | created_at |
| ---: | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

---

## 12. 활동 9: UNIQUE 제약조건 오류 확인

다음 SQL의 주석을 해제하고 실행해 보세요.

```sql
INSERT INTO students (name, email)
VALUES ('중복학생', 'minji@example.com');
```

이미 같은 이메일이 존재하므로 오류가 발생해야 정상입니다.

| 항목 | 작성 |
| --- | --- |
| 오류 발생 여부 |  |
| 오류 메시지 일부 |  |
| 어떤 제약조건 때문에 발생했는가? |  |
| 이 오류가 의미하는 것은 무엇인가? |  |

### 해설 작성 예시

```text
이미 minji@example.com 이메일이 students 테이블에 존재하기 때문에 UNIQUE 제약조건 위반 오류가 발생했다.
이 오류는 같은 이메일을 가진 학생이 중복 저장되지 않도록 DBMS가 막아 준다는 의미이다.
```

---

## 13. 활동 10: 오류 메시지를 ChatGPT 질문으로 바꾸기

실습 중 발생한 오류 메시지 하나를 선택해 ChatGPT에게 질문할 수 있는 형태로 정리하세요.

### 나쁜 질문 예시

```text
DBeaver가 안 됩니다. 해결해 주세요.
```

### 좋은 질문 양식

```text
Windows에서 PostgreSQL과 DBeaver를 사용하고 있습니다.
DBeaver에서 PostgreSQL에 연결하려고 했고,
Host는 localhost, Port는 5432, Username은 postgres로 입력했습니다.
Database는 postgres로 입력했습니다.
Test Connection을 누르면 아래 오류가 발생합니다.

[오류 메시지]

제가 확인해야 할 순서를 초급자 기준으로 알려 주세요.
```

### 내 질문 작성

```text
[여기에 본인의 질문 작성]
```

---

## 14. 활동 11: Codex에게 SQL 파일 생성 요청하기

Codex를 사용한다고 가정하고, `setup_check.sql` 파일을 만들기 위한 요청문을 작성해 보세요.

### 요청문 작성 양식

```text
현재 저장소는 ai-database-book입니다.
code/chapter03/setup_check.sql 파일을 만들고 싶습니다.
다음 내용을 포함한 PostgreSQL 실습 SQL을 작성해 주세요.

- SELECT version();
- SELECT current_database();
- SELECT 1 + 1 AS result;
- students 테이블 생성
- 샘플 학생 데이터 3건 입력
- SELECT * FROM students;
- UNIQUE 제약조건 오류 확인용 SQL은 주석으로 포함

초급자가 이해할 수 있도록 주석을 포함해 주세요.
```

### 내가 작성한 Codex 요청문

```text
[여기에 본인의 요청문 작성]
```

---

## 15. 활동 12: 로컬 DB와 클라우드 DB 비교

로컬 PostgreSQL과 클라우드 PostgreSQL을 비교해 보세요.

| 항목 | 로컬 PostgreSQL | 클라우드 PostgreSQL |
| --- | --- | --- |
| 설치 필요 여부 |  |  |
| 인터넷 필요 여부 |  |  |
| 학교/회사 PC에서 사용 편의성 |  |  |
| 접속 정보 관리 |  |  |
| 실습 적합성 |  |  |
| 대표 서비스 |  |  |

### 나의 선택

```text
나는 이번 실습에서 [로컬 / 클라우드] PostgreSQL을 선택했다.
그 이유는 __________________________________________ 이다.
```

---

## 16. 제출 양식

아래 형식을 그대로 복사하여 제출 파일에 사용해도 됩니다.

```markdown
# Chapter 03 활동 과제

## 1. 기본 정보

- 이름:
- 학번:
- 제출일:

## 2. 실습 환경 정보

- 운영체제:
- PostgreSQL 설치 여부:
- PostgreSQL 버전:
- DBeaver 설치 여부:
- 로컬/클라우드 DB 사용 여부:

## 3. DBeaver 연결 정보

- Host:
- Port:
- Database:
- Username:
- Password: 제출 파일에 작성하지 않음
- Test Connection 성공 여부:

## 4. 실습용 데이터베이스 생성 결과

- 생성한 DB 이름:
- 생성 성공 여부:
- DBeaver에서 확인 여부:

## 5. 기본 SQL 실행 결과

| SQL | 실제 결과 |
| --- | --- |
| SELECT version(); |  |
| SELECT current_database(); |  |
| SELECT 1 + 1 AS result; |  |

## 6. setup_check.sql 실행 결과

- 실행 성공 여부:
- 생성된 테이블:
- 입력된 데이터 수:
- 조회 결과 확인 여부:

## 7. 제약조건 오류 확인

- 실행한 SQL:
- 오류 메시지:
- 발생 원인:
- 알게 된 점:

## 8. ChatGPT 오류 질문 작성

[작성한 질문]

## 9. Codex 요청문 작성

[작성한 요청문]

## 10. 로컬 DB와 클라우드 DB 비교

[비교 내용 및 선택 이유]

## 11. 느낀 점

이번 실습을 통해 알게 된 점을 3~5문장으로 작성하세요.
```

---

## 17. 평가 기준

총점 100점 기준 예시는 다음과 같습니다.

| 평가 항목 | 배점 | 평가 기준 |
| --- | ---: | --- |
| 실습 환경 확인 | 20 | PostgreSQL, DBeaver, 연결 정보를 정확히 확인했는가 |
| SQL 실행 결과 | 25 | 기본 SQL, 테이블 생성, 샘플 데이터 입력 및 조회 결과를 기록했는가 |
| 제약조건 오류 분석 | 20 | UNIQUE 오류 발생 원인과 의미를 정확히 설명했는가 |
| AI 활용 질문 작성 | 20 | ChatGPT 오류 질문과 Codex 요청문이 구체적이고 재현 가능하게 작성되었는가 |
| 제출 형식 | 15 | 지정된 형식에 맞게 명확히 작성했는가 |

---

## 18. 피드백 코멘트 예시

### 우수한 경우

```text
PostgreSQL과 DBeaver 연결 정보를 명확히 기록했고, setup_check.sql 실행 결과도 구체적으로 작성했습니다.
특히 UNIQUE 제약조건 오류를 실패가 아니라 데이터 중복을 막는 정상 동작으로 해석한 점이 좋습니다.
ChatGPT 오류 질문도 운영체제, 입력값, 오류 메시지를 포함해 재현 가능하게 작성했습니다.
```

### 보완이 필요한 경우

```text
DBeaver 연결 성공 여부는 작성되어 있지만, 실제 실행한 SQL 결과 기록이 부족합니다.
`SELECT current_database();` 결과가 `ai_database_book`인지 반드시 확인해야 합니다.
또한 오류 메시지는 “안 됨”으로 적기보다 실제 메시지 일부를 복사해 원인을 분석하는 것이 좋습니다.
```

---

## 19. 교수자 운영 팁

수업에서 이 활동을 사용할 경우 다음 흐름을 권장합니다.

```text
1. Chapter 03 핵심 개념 설명: 20분
2. PostgreSQL/DBeaver 연결 점검: 20분
3. ai_database_book DB 생성 및 기본 SQL 실행: 20분
4. setup_check.sql 실행: 20분
5. UNIQUE 오류 실습 및 해석: 15분
6. ChatGPT 오류 질문 작성: 10분
7. 전체 공유 및 정리: 15분
```

온라인 수업에서는 설치 문제로 시간이 오래 걸릴 수 있으므로, 로컬 설치가 어려운 학습자에게 클라우드 PostgreSQL 대안을 허용하는 것이 좋습니다.

---

## 20. 핵심 정리

이 활동의 핵심은 설치 자체가 아니라 **연결, 실행, 확인, 기록**입니다.

```text
PostgreSQL은 데이터를 저장하고 SQL을 실행하는 DBMS이고,
DBeaver는 그 DBMS에 접속해 결과를 확인하는 도구입니다.
실습 결과와 오류 메시지를 기록해야 이후 SQL, ERD, 정규화, 프로젝트 실습으로 안정적으로 이어질 수 있습니다.
```
