# Chapter 03. PostgreSQL과 DBeaver 실습 환경 구축

> 상태: 원고 1차 리뷰 및 보완 완료

---

## 이 장에서 배울 내용

이 장에서는 이후 데이터베이스 실습을 진행하기 위한 기본 환경을 구축합니다.

Chapter 01과 Chapter 02에서는 데이터베이스가 왜 필요한지, DBMS·테이블·기본키·외래키가 무엇인지 개념 중심으로 학습했습니다. 이제부터는 실제 도구를 설치하고, 직접 데이터베이스를 만들고, SQL을 실행해 보면서 개념을 실습으로 연결합니다.

이 장에서 다룰 내용은 다음과 같습니다.

- PostgreSQL의 역할
- DBeaver의 역할
- 로컬 실습 환경 구성 방식
- PostgreSQL 설치 확인
- DBeaver에서 PostgreSQL 연결하기
- 실습용 데이터베이스 생성
- 기본 SQL 실행 테스트
- GitHub 저장소에서 실습 파일 관리하기
- 설치가 어려울 때 사용할 수 있는 클라우드 DB 대안
- ChatGPT와 Codex를 활용한 설치 오류 해결 흐름

이 장의 목표는 복잡한 서버 운영을 배우는 것이 아닙니다. 이후 Chapter에서 SQL과 DB 설계를 안정적으로 실습할 수 있는 공통 환경을 만드는 것입니다.

---

## 1. 왜 실습 환경 구축이 중요한가

데이터베이스는 눈으로만 읽어서는 잘 이해되지 않습니다. 테이블을 만들고, 데이터를 넣고, 조회하고, 잘못된 SQL을 실행해 보고, 오류를 고치면서 익숙해집니다.

예를 들어 기본키와 외래키는 설명만 들으면 추상적으로 느껴질 수 있습니다. 하지만 PostgreSQL에서 직접 다음 작업을 해 보면 의미가 분명해집니다.

```text
1. students 테이블을 만든다.
2. courses 테이블을 만든다.
3. enrollments 테이블을 만든다.
4. 존재하지 않는 student_id로 수강신청을 넣어 본다.
5. 외래키 오류가 발생하는지 확인한다.
```

이 과정에서 DBMS가 단순 저장소가 아니라 데이터의 규칙을 지키는 역할을 한다는 점을 체감할 수 있습니다.

실습 환경을 통일하면 다음 장점이 있습니다.

| 장점 | 설명 |
| --- | --- |
| 오류 원인 파악이 쉬움 | 모두 같은 DBMS를 사용하면 오류 비교가 쉬움 |
| 실습 코드 공유가 쉬움 | 같은 PostgreSQL 기준으로 SQL 파일 작성 가능 |
| DBeaver 화면 설명이 쉬움 | 강의와 교재의 화면 흐름을 맞출 수 있음 |
| GitHub 관리가 쉬움 | SQL 파일, 실습 결과, 프로젝트 파일을 함께 관리 가능 |
| AI 도구 활용이 쉬움 | ChatGPT와 Codex에게 환경을 명확히 설명할 수 있음 |

이 책에서는 기본 실습 환경을 다음처럼 통일합니다.

```text
PostgreSQL + DBeaver + GitHub
```

---

## 2. 전체 실습 환경 구조

이 책의 기본 실습 흐름은 다음과 같습니다.

```text
원고와 실습 설명을 읽는다.
→ ChatGPT로 개념이나 오류 원인을 질문한다.
→ Codex로 SQL 또는 코드 초안을 만든다.
→ PostgreSQL에서 SQL을 실행한다.
→ DBeaver로 테이블과 데이터를 확인한다.
→ GitHub에 실습 파일과 결과를 기록한다.
```

각 도구의 역할은 다음과 같습니다.

| 도구 | 역할 |
| --- | --- |
| PostgreSQL | 실제 데이터를 저장하고 SQL을 실행하는 DBMS |
| DBeaver | PostgreSQL에 접속해 테이블과 데이터를 확인하는 GUI 도구 |
| GitHub | 실습 SQL, 원고, 프로젝트 파일을 버전 관리하는 저장소 |
| ChatGPT | 개념 설명, 오류 메시지 해석, SQL 검토 보조 |
| Codex | SQL 파일 생성, 코드 작성, 프로젝트 구조 생성 보조 |

![전체 실습 환경 구조](../../images/chapter03/ch03_01_practice_environment_flow.svg)

그림 3-1 전체 실습 환경 구조

초급 학습자는 모든 도구를 완벽하게 이해할 필요는 없습니다. 이 장에서는 최소한 다음을 할 수 있으면 됩니다.

```text
1. PostgreSQL이 설치되어 있는지 확인한다.
2. DBeaver에서 PostgreSQL에 접속한다.
3. 실습용 데이터베이스를 만든다.
4. 간단한 SQL을 실행한다.
5. 실습 SQL 파일을 GitHub 저장소 구조에 맞게 보관한다.
```

---

## 3. PostgreSQL이란 무엇인가

PostgreSQL은 대표적인 오픈소스 관계형 DBMS입니다. 이 책에서는 PostgreSQL을 기본 실습 DBMS로 사용합니다.

PostgreSQL을 선택한 이유는 다음과 같습니다.

| 이유 | 설명 |
| --- | --- |
| 표준 SQL 학습에 적합 | 기본 SQL, JOIN, 트랜잭션, 인덱스 학습에 적합 |
| 실무 활용도 높음 | 웹 서비스, 데이터 분석, 백엔드 개발에서 널리 사용 |
| 오픈소스 | 무료로 설치해 실습 가능 |
| 확장성 | pgvector 같은 확장 기능으로 Vector DB 실습 가능 |
| 클라우드 연계 용이 | Neon, Supabase 등 무료 또는 저비용 대안이 많음 |

PostgreSQL은 보통 줄여서 Postgres라고도 부릅니다. 이 책에서는 두 표현이 모두 같은 의미로 사용될 수 있습니다.

```text
PostgreSQL = Postgres
```

한글로는 보통 “포스트그레스큐엘” 또는 “포스트그레스”라고 읽습니다. 강의에서는 “포스트그레스큐엘”이라고 읽으면 무난합니다.

---

## 4. DBeaver란 무엇인가

DBeaver는 데이터베이스에 접속해서 테이블, 데이터, SQL 실행 결과를 확인할 수 있는 GUI 도구입니다.

PostgreSQL은 명령어로도 사용할 수 있지만, 초급 학습자는 DBeaver 같은 화면 기반 도구를 함께 사용하는 것이 좋습니다.

DBeaver를 사용하면 다음 작업을 쉽게 할 수 있습니다.

```text
- PostgreSQL 서버에 접속한다.
- 데이터베이스 목록을 확인한다.
- 테이블 목록을 확인한다.
- SQL 편집기에서 쿼리를 실행한다.
- SELECT 결과를 표 형태로 확인한다.
- 테이블 구조를 시각적으로 확인한다.
```

DBeaver는 여러 DBMS를 지원합니다. PostgreSQL뿐 아니라 MySQL, SQLite, MariaDB 등에도 접속할 수 있습니다. 하지만 이 책에서는 PostgreSQL 연결만 사용합니다.

---

## 5. 로컬 환경과 클라우드 환경

데이터베이스 실습 환경은 크게 두 가지 방식으로 구성할 수 있습니다.

| 방식 | 설명 | 장점 | 단점 |
| --- | --- | --- | --- |
| 로컬 PostgreSQL | 내 컴퓨터에 직접 설치 | 인터넷 없이 실습 가능, 구조 이해에 좋음 | 설치 오류가 생길 수 있음 |
| 클라우드 PostgreSQL | Neon, Supabase 같은 서비스 사용 | 설치 없이 바로 사용 가능 | 인터넷 필요, 계정 생성 필요 |

![로컬 PostgreSQL과 클라우드 PostgreSQL 비교](../../images/chapter03/ch03_02_local_vs_cloud_db.svg)

그림 3-2 로컬 PostgreSQL과 클라우드 PostgreSQL 비교

이 책의 기본 흐름은 로컬 PostgreSQL입니다. 이유는 DBMS가 내 컴퓨터에서 실제로 어떻게 실행되는지 이해하기 좋기 때문입니다.

다만 설치가 어렵거나 학교/회사 PC에서 설치 권한이 없는 경우에는 클라우드 PostgreSQL을 사용할 수 있습니다. 이 경우에도 DBeaver로 접속해 SQL을 실행할 수 있습니다.

---

## 6. 설치 전 확인 사항

실습을 시작하기 전에 다음을 확인합니다.

| 항목 | 확인 내용 |
| --- | --- |
| 운영체제 | Windows, macOS, Linux 중 무엇인지 확인 |
| 설치 권한 | 프로그램 설치 권한이 있는지 확인 |
| 인터넷 연결 | 설치 파일 다운로드 가능 여부 확인 |
| 포트 충돌 | PostgreSQL 기본 포트 5432 사용 가능 여부 확인 |
| 비밀번호 기록 | postgres 사용자 비밀번호를 잊지 않도록 기록 |

초급자가 가장 많이 겪는 문제는 PostgreSQL 설치 중 설정한 비밀번호를 잊어버리는 것입니다. 설치 중 입력한 비밀번호는 DBeaver 연결에 필요합니다.

```text
PostgreSQL 설치 비밀번호는 반드시 기록해 둔다.
```

### 실습 준비 체크리스트

| 확인 항목 | 완료 여부 |
| --- | --- |
| 내 운영체제를 확인했다. |  |
| PostgreSQL 설치 권한이 있는지 확인했다. |  |
| PostgreSQL 비밀번호를 별도로 기록했다. |  |
| 기본 포트가 5432인지 확인했다. |  |
| DBeaver를 설치했다. |  |
| 로컬 설치가 어려울 경우 클라우드 DB 대안을 확인했다. |  |
| GitHub에 비밀번호나 접속 URL을 올리지 않아야 한다는 점을 확인했다. |  |

---

## 7. PostgreSQL 설치 개요

PostgreSQL 설치 과정은 운영체제에 따라 조금 다릅니다. 이 책에서는 Windows 기준을 기본으로 설명하고, macOS 사용자는 별도 안내를 참고합니다.

### 7.1 Windows 설치 흐름

Windows에서는 보통 다음 순서로 설치합니다.

```text
1. PostgreSQL 공식 설치 파일을 다운로드한다.
2. 설치 프로그램을 실행한다.
3. 설치 경로를 선택한다.
4. PostgreSQL 서버와 pgAdmin 설치 여부를 선택한다.
5. postgres 사용자 비밀번호를 설정한다.
6. 기본 포트 5432를 확인한다.
7. 설치를 완료한다.
```

초급자는 설치 옵션을 대부분 기본값으로 두어도 됩니다. 중요한 것은 비밀번호와 포트입니다.

| 항목 | 권장값 |
| --- | --- |
| 사용자 | postgres |
| 포트 | 5432 |
| Locale | 기본값 또는 Korean/Korea |
| 비밀번호 | 본인이 기억할 수 있는 실습용 비밀번호 |

### 7.2 macOS 설치 흐름

macOS에서는 다음 방법 중 하나를 사용할 수 있습니다.

```text
- PostgreSQL 공식 설치 파일 사용
- Homebrew 사용
- Postgres.app 사용
```

초급자에게는 Postgres.app이 비교적 간단할 수 있습니다. 개발 경험이 있는 학습자는 Homebrew를 사용할 수 있습니다.

Homebrew를 사용하는 경우 예시는 다음과 같습니다.

```bash
brew install postgresql
brew services start postgresql
```

단, macOS 설치 방식은 환경에 따라 차이가 있으므로, 이 책에서는 DBeaver 연결이 성공하는 것을 최종 기준으로 삼습니다.

---

## 8. PostgreSQL 설치 확인

PostgreSQL 설치 후에는 제대로 설치되었는지 확인해야 합니다.

### 8.1 명령어로 확인하기

터미널 또는 명령 프롬프트에서 다음 명령어를 실행합니다.

```bash
psql --version
```

정상적으로 설치되어 있다면 다음과 비슷한 결과가 나옵니다.

```text
psql (PostgreSQL) 16.x
```

버전 번호는 설치 시점에 따라 다를 수 있습니다. 중요한 것은 `psql` 명령어가 실행되는지입니다.

### 8.2 서비스 실행 확인

Windows에서는 서비스 앱에서 PostgreSQL 서비스가 실행 중인지 확인할 수 있습니다.

```text
서비스 이름 예시:
postgresql-x64-16
```

DBeaver에서 연결이 되지 않는다면 PostgreSQL 서비스가 실행 중인지 먼저 확인합니다.

---

## 9. DBeaver 설치와 실행

DBeaver는 공식 사이트에서 Community Edition을 설치하면 됩니다. 이 책에서는 무료 버전인 DBeaver Community Edition을 사용합니다.

설치 후 DBeaver를 실행하면 처음에 데이터베이스 연결을 만들 수 있습니다.

DBeaver에서 PostgreSQL에 연결할 때 필요한 정보는 다음과 같습니다.

| 항목 | 값 |
| --- | --- |
| Host | localhost |
| Port | 5432 |
| Database | postgres 또는 생성한 DB 이름 |
| Username | postgres |
| Password | 설치 시 입력한 비밀번호 |

처음 연결할 때 PostgreSQL 드라이버 다운로드가 필요할 수 있습니다. DBeaver가 자동으로 다운로드하겠다고 안내하면 그대로 진행하면 됩니다.

---

## 10. DBeaver에서 PostgreSQL 연결하기

DBeaver에서 PostgreSQL 연결을 만드는 기본 흐름은 다음과 같습니다.

```text
1. DBeaver 실행
2. Database → New Database Connection 선택
3. PostgreSQL 선택
4. Host, Port, Database, Username, Password 입력
5. Test Connection 클릭
6. 성공 메시지 확인
7. Finish 클릭
```

![DBeaver에서 PostgreSQL 연결 흐름](../../images/chapter03/ch03_03_dbeaver_connection_flow.svg)

그림 3-3 DBeaver에서 PostgreSQL 연결 흐름

처음에는 Database 항목에 `postgres`를 입력해도 됩니다. `postgres`는 기본 관리용 데이터베이스입니다.

연결 테스트에 성공하면 DBeaver 왼쪽 Database Navigator에 PostgreSQL 연결이 표시됩니다.

---

## 11. 실습용 데이터베이스 만들기

이 책에서는 실습용 데이터베이스 이름을 다음처럼 사용합니다.

```text
ai_database_book
```

DBeaver의 SQL 편집기에서 다음 SQL을 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

데이터베이스를 만든 뒤에는 새로고침을 해서 목록에 표시되는지 확인합니다.

이후 실습은 `ai_database_book` 데이터베이스에 연결해서 진행합니다.

### 11.1 데이터베이스 이름 규칙

실습용 데이터베이스 이름은 다음 기준을 따르는 것이 좋습니다.

```text
- 영문 소문자 사용
- 공백 대신 언더스코어 사용
- 의미가 드러나게 작성
- 특수문자 사용하지 않기
```

좋은 예시는 다음과 같습니다.

```text
ai_database_book
school_db
shop_db
library_db
```

피해야 할 예시는 다음과 같습니다.

```text
AI Database Book
내 데이터베이스
test!!!
```

---

## 12. 기본 SQL 실행 테스트

데이터베이스 연결이 끝났다면 간단한 SQL을 실행해 봅니다.

![기본 SQL 실행 확인 흐름](../../images/chapter03/ch03_04_sql_execution_check_flow.svg)

그림 3-4 기본 SQL 실행 확인 흐름

### 12.1 버전 확인

```sql
SELECT version();
```

이 SQL은 현재 연결된 PostgreSQL 버전을 보여 줍니다.

### 12.2 현재 데이터베이스 확인

```sql
SELECT current_database();
```

결과가 `ai_database_book`이면 실습용 데이터베이스에 잘 연결된 것입니다.

### 12.3 간단한 계산 테스트

```sql
SELECT 1 + 1 AS result;
```

결과가 `2`로 나오면 SQL 실행이 정상적으로 되는 것입니다.

이 세 가지 SQL이 모두 실행되면 기본 실습 환경은 준비된 것입니다.

---

## 13. 첫 번째 테이블 만들어 보기

이제 간단한 students 테이블을 만들어 봅니다.

```sql
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

이 SQL은 Chapter 02에서 배운 기본키와 제약조건을 실제로 사용합니다.

| 컬럼 | 의미 |
| --- | --- |
| id | 학생을 구분하는 기본키 |
| name | 학생 이름, 비어 있을 수 없음 |
| email | 이메일, 중복될 수 없음 |
| created_at | 등록 시각, 기본값은 현재 시각 |

DBeaver에서 테이블 목록을 새로고침하면 `students` 테이블이 보입니다.

---

## 14. 샘플 데이터 입력하기

테이블을 만들었다면 데이터를 입력해 봅니다.

```sql
INSERT INTO students (name, email)
VALUES
    ('김민지', 'minji@example.com'),
    ('이준호', 'junho@example.com'),
    ('박서연', 'seoyeon@example.com');
```

입력한 데이터를 조회합니다.

```sql
SELECT *
FROM students;
```

정상적으로 실행되면 세 명의 학생 데이터가 표시됩니다.

---

## 15. 제약조건 오류 확인하기

이번에는 일부러 오류를 만들어 봅니다.

```sql
INSERT INTO students (name, email)
VALUES ('중복학생', 'minji@example.com');
```

이미 `minji@example.com`이 존재하기 때문에 UNIQUE 제약조건 오류가 발생해야 합니다.

이 실습은 매우 중요합니다. 데이터베이스는 단순히 데이터를 저장하는 것이 아니라, 잘못된 데이터가 들어오지 않도록 막을 수 있습니다.

오류 메시지가 나오면 실패가 아닙니다. 오히려 제약조건이 정상적으로 작동한다는 뜻입니다.

---

## 16. 실습 SQL 파일로 저장하기

실습한 SQL은 GitHub 저장소에 파일로 관리하는 것이 좋습니다.

Chapter 03 실습 파일은 다음 위치에 저장할 수 있습니다.

```text
code/chapter03/setup_check.sql
```

![setup_check.sql 실행 흐름](../../images/chapter03/ch03_05_setup_check_sql_flow.svg)

그림 3-5 setup_check.sql 실행 흐름

파일 내용 예시는 다음과 같습니다.

```sql
-- Chapter 03. PostgreSQL 환경 확인

SELECT version();
SELECT current_database();
SELECT 1 + 1 AS result;

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students (name, email)
VALUES
    ('김민지', 'minji@example.com'),
    ('이준호', 'junho@example.com'),
    ('박서연', 'seoyeon@example.com');

SELECT *
FROM students;
```

실습 코드를 파일로 남기면 나중에 다시 실행하거나 오류를 비교하기 쉽습니다.

---

## 17. GitHub 저장소에서 실습 관리하기

이 책의 실습 파일은 Chapter별로 관리합니다.

권장 구조는 다음과 같습니다.

```text
code/
├── chapter03/
│   ├── setup_check.sql
│   └── README.md
├── chapter04/
│   └── basic_crud.sql
└── chapter05/
    └── erd_schema.sql
```

![GitHub 실습 파일 관리 구조](../../images/chapter03/ch03_07_github_practice_file_structure.svg)

그림 3-7 GitHub 실습 파일 관리 구조

GitHub를 사용하는 이유는 다음과 같습니다.

```text
- 실습 파일의 변경 이력을 남길 수 있다.
- AI 도구와 함께 코드 수정 흐름을 관리할 수 있다.
- 최종 프로젝트 산출물을 체계적으로 제출할 수 있다.
- 오류가 생겼을 때 이전 상태와 비교할 수 있다.
```

초급자는 처음부터 Git 명령어를 완벽하게 알 필요는 없습니다. 이 책에서는 GitHub 저장소 구조를 기준으로 파일을 정리하고, 필요할 때 Codex나 VS Code를 활용해 관리하는 방식으로 진행합니다.

---

## 18. 설치가 어려운 경우: 클라우드 PostgreSQL 대안

로컬 설치가 어렵다면 클라우드 PostgreSQL을 사용할 수 있습니다.

대표적인 대안은 다음과 같습니다.

| 서비스 | 특징 |
| --- | --- |
| Neon | PostgreSQL 기반 클라우드 DB, 실습용으로 사용하기 쉬움 |
| Supabase | PostgreSQL 기반 백엔드 플랫폼, 웹 프로젝트와 연결하기 좋음 |
| Render PostgreSQL | 간단한 배포 실습에 활용 가능 |

클라우드 DB를 사용할 때도 핵심은 같습니다.

```text
1. PostgreSQL 데이터베이스를 만든다.
2. 연결 정보를 확인한다.
3. DBeaver에서 Host, Port, Database, Username, Password를 입력한다.
4. Test Connection으로 연결을 확인한다.
5. SQL을 실행한다.
```

클라우드 DB는 편리하지만, 연결 정보 관리에 주의해야 합니다. 비밀번호와 접속 URL을 GitHub에 그대로 올리면 안 됩니다.

```text
DB 비밀번호, 접속 URL, API Key는 GitHub에 공개하지 않는다.
```

> 보안 주의
>
> GitHub에 올리면 안 되는 정보는 다음과 같습니다.
>
> - DB 비밀번호
> - 클라우드 DB 접속 URL
> - API Key
> - Access Token
> - `.env` 파일
>
> 실습 파일에는 접속 정보 대신 `.env.example`처럼 예시 형식만 남기는 것이 안전합니다.

---

## 19. 자주 발생하는 오류와 해결 방향

설치와 연결 과정에서 오류가 발생할 수 있습니다. 이때 중요한 것은 오류 메시지를 복사하고, 원인을 분류하고, 확인 순서대로 점검하는 것입니다.

![오류 메시지 해결 흐름](../../images/chapter03/ch03_06_error_troubleshooting_flow.svg)

그림 3-6 오류 메시지 해결 흐름

### 19.1 DBeaver 연결 실패

가능한 원인은 다음과 같습니다.

| 원인 | 확인 방법 |
| --- | --- |
| PostgreSQL 서비스가 꺼져 있음 | Windows 서비스 또는 macOS 서비스 확인 |
| 비밀번호가 틀림 | 설치 시 입력한 postgres 비밀번호 확인 |
| 포트가 다름 | 기본 포트 5432인지 확인 |
| Database 이름이 잘못됨 | 처음에는 postgres로 연결해 보기 |
| 방화벽 또는 보안 설정 | 회사/학교 PC 보안 정책 확인 |

### 19.2 psql 명령어가 인식되지 않음

`psql --version`이 실행되지 않는다고 해서 반드시 PostgreSQL 설치가 실패한 것은 아닙니다. PATH 환경변수에 등록되지 않았을 수 있습니다.

초급자는 이 경우 DBeaver 연결 성공 여부를 우선 기준으로 삼아도 됩니다.

### 19.3 CREATE DATABASE 오류

이미 같은 이름의 데이터베이스가 있으면 오류가 발생할 수 있습니다.

```text
database "ai_database_book" already exists
```

이 경우 이미 생성된 것이므로 새로 만들 필요가 없습니다.

---

## 20. ChatGPT로 오류 메시지 질문하기

설치나 연결 과정에서 오류가 발생하면 ChatGPT에게 질문할 수 있습니다. 단, 오류 메시지를 정확히 전달해야 합니다.

좋은 질문 예시는 다음과 같습니다.

```text
Windows에서 PostgreSQL을 설치했고 DBeaver로 연결하려고 합니다.
Host는 localhost, Port는 5432, Username은 postgres로 입력했습니다.
Test Connection을 누르면 다음 오류가 발생합니다.

[오류 메시지 붙여넣기]

가능한 원인과 확인 순서를 초급자 기준으로 설명해 주세요.
```

좋지 않은 질문 예시는 다음과 같습니다.

```text
DBeaver가 안 됩니다. 해결해 주세요.
```

AI에게 질문할 때는 환경, 입력값, 오류 메시지를 함께 제공해야 답변 품질이 좋아집니다.

---

## 21. Codex로 실습 SQL 파일 만들기

Codex를 사용할 경우 다음처럼 요청할 수 있습니다.

```text
현재 저장소는 ai-database-book입니다.
code/chapter03/setup_check.sql 파일을 만들고 싶습니다.
PostgreSQL 환경 확인용 SQL을 작성해 주세요.
포함할 내용은 SELECT version(), SELECT current_database(), students 테이블 생성, 샘플 INSERT, SELECT 조회입니다.
초급자가 이해할 수 있도록 주석을 포함해 주세요.
```

![ChatGPT와 Codex를 활용한 실습 보조 흐름](../../images/chapter03/ch03_08_ai_help_prompt_flow.svg)

그림 3-8 ChatGPT와 Codex를 활용한 실습 보조 흐름

Codex가 파일을 만들면 반드시 직접 확인해야 합니다.

검토 기준은 다음과 같습니다.

| 검토 항목 | 확인 내용 |
| --- | --- |
| PostgreSQL 문법 | SERIAL, TIMESTAMP 등 PostgreSQL 기준인지 확인 |
| 테이블 이름 | students처럼 일관된 이름인지 확인 |
| 제약조건 | PRIMARY KEY, NOT NULL, UNIQUE가 적절한지 확인 |
| 샘플 데이터 | 중복 이메일이 없는지 확인 |
| 실행 가능성 | DBeaver에서 실제로 실행되는지 확인 |

---

## 22. 미니 실습

다음 순서대로 직접 실습해 보세요.

```text
1. DBeaver에서 PostgreSQL 연결을 연다.
2. ai_database_book 데이터베이스에 연결한다.
3. SQL 편집기를 연다.
4. SELECT version();을 실행한다.
5. SELECT current_database();를 실행한다.
6. students 테이블을 만든다.
7. 학생 데이터 3건을 입력한다.
8. SELECT * FROM students;로 조회한다.
9. 중복 이메일을 입력해 UNIQUE 오류를 확인한다.
10. 실습 SQL을 code/chapter03/setup_check.sql로 저장한다.
```

실습 결과를 다음 형식으로 정리합니다.

```markdown
## Chapter 03 실습 결과

- PostgreSQL 연결 성공 여부:
- DBeaver 연결 성공 여부:
- 생성한 데이터베이스 이름:
- 생성한 테이블 이름:
- 입력한 샘플 데이터 수:
- 발생한 오류 메시지:
- 오류 해결 방법:
- 느낀 점:
```

---

## 23. 자주 하는 실수

### 실수 1. postgres 비밀번호를 잊어버린다

설치 중 입력한 비밀번호는 DBeaver 연결에 필요합니다. 반드시 기록해 둡니다.

### 실수 2. 데이터베이스와 테이블을 혼동한다

`ai_database_book`은 데이터베이스이고, `students`는 그 안에 만드는 테이블입니다.

### 실수 3. 잘못된 데이터베이스에 SQL을 실행한다

DBeaver에서 현재 연결된 데이터베이스를 확인하지 않고 SQL을 실행하면 원하는 위치에 테이블이 만들어지지 않을 수 있습니다.

### 실수 4. 오류 메시지를 읽지 않는다

오류 메시지는 문제 해결의 출발점입니다. 오류가 발생하면 메시지를 복사해 원인을 확인합니다.

### 실수 5. 실습 SQL을 파일로 남기지 않는다

화면에서 실행만 하고 파일로 저장하지 않으면 나중에 다시 확인하기 어렵습니다.

---

## 24. 연습 문제

### 24.1 개념 확인

1. [기초] PostgreSQL의 역할을 설명해 보세요.
2. [기초] DBeaver의 역할을 설명해 보세요.
3. [기초] 로컬 PostgreSQL과 클라우드 PostgreSQL의 차이를 설명해 보세요.
4. [기초] DBeaver 연결에 필요한 정보 5가지를 적어 보세요.
5. [기초] `SELECT version();`은 무엇을 확인하는 SQL인가요?

### 24.2 실습 확인

1. [실습] `ai_database_book` 데이터베이스를 생성해 보세요.
2. [실습] `SELECT current_database();` 결과를 확인해 보세요.
3. [실습] students 테이블을 생성해 보세요.
4. [실습] 학생 데이터 3건을 입력해 보세요.
5. [실습] 중복 이메일을 입력했을 때 어떤 오류가 발생하는지 기록해 보세요.

### 24.3 AI 활용 문제

다음 상황을 ChatGPT에게 질문할 수 있는 좋은 프롬프트로 바꿔 보세요.

```text
DBeaver에서 PostgreSQL 연결이 안 됨.
```

좋은 프롬프트에는 다음 정보가 포함되어야 합니다.

```text
- 운영체제
- PostgreSQL 설치 여부
- DBeaver 입력값
- 오류 메시지
- 이미 시도한 해결 방법
```

---

## 25. 정리

이번 장에서는 PostgreSQL과 DBeaver 실습 환경을 구축하는 흐름을 학습했습니다.

핵심 내용을 정리하면 다음과 같습니다.

```text
1. PostgreSQL은 이 책의 기본 실습 DBMS이다.
2. DBeaver는 PostgreSQL에 접속해 SQL을 실행하고 결과를 확인하는 GUI 도구이다.
3. 로컬 PostgreSQL은 실습 구조를 이해하기 좋다.
4. 설치가 어렵다면 Neon이나 Supabase 같은 클라우드 PostgreSQL을 사용할 수 있다.
5. DBeaver 연결에는 Host, Port, Database, Username, Password가 필요하다.
6. 실습용 데이터베이스 이름은 ai_database_book을 사용한다.
7. SELECT version();과 SELECT current_database();로 연결 상태를 확인할 수 있다.
8. students 테이블을 만들어 Chapter 02의 기본키와 제약조건 개념을 실습할 수 있다.
9. 오류 메시지는 문제 해결의 핵심 단서이다.
10. 실습 SQL은 GitHub 저장소의 code/chapter03 폴더에 파일로 관리한다.
```

이 장에서 가장 중요한 문장은 다음입니다.

```text
데이터베이스 학습은 설치가 끝이 아니라, 직접 연결하고 실행하고 오류를 확인하는 것에서 시작된다.
```

---

## 26. 다음 장에서는

다음 장에서는 관계형 데이터베이스와 SQL 기초를 본격적으로 학습합니다.

Chapter 04에서 다룰 내용은 다음과 같습니다.

```text
- 관계형 데이터베이스의 기본 구조
- SELECT 기초
- INSERT로 데이터 추가
- UPDATE로 데이터 수정
- DELETE로 데이터 삭제
- WHERE 조건 사용
- ORDER BY 정렬
- AI가 만든 SQL을 검토하는 방법
```

Chapter 03에서 만든 PostgreSQL과 DBeaver 환경은 Chapter 04부터 계속 사용됩니다.
