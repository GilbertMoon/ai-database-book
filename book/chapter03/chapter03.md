# Chapter 03. PostgreSQL과 DBeaver로 데이터베이스 환경 만들기

---

## 이 장에서 살펴볼 내용

데이터베이스는 설명만 읽는 것보다 직접 연결하고 실행해 볼 때 훨씬 분명하게 이해됩니다. 테이블을 만들고 데이터를 입력하며 오류 메시지를 확인하는 과정에서 DBMS가 어떤 일을 하는지 비로소 눈에 보이기 시작합니다.

이 장에서는 이후의 예제를 직접 실행할 수 있도록 PostgreSQL과 DBeaver를 중심으로 데이터베이스 환경을 구성합니다.

- PostgreSQL과 DBeaver가 맡는 역할
- 로컬 환경과 클라우드 환경의 차이
- PostgreSQL 설치와 실행 상태 확인
- DBeaver에서 PostgreSQL 연결하기
- 작업용 데이터베이스 생성
- 기본 SQL로 연결 상태 검증
- 첫 번째 테이블과 샘플 데이터 만들기
- 제약조건 오류를 이용한 정상 동작 확인
- SQL 파일과 작업 이력 관리
- 접속 정보와 비밀번호를 안전하게 관리하는 방법
- ChatGPT와 Codex를 활용한 오류 해결 흐름

이 장의 목적은 복잡한 서버 운영 기술을 익히는 것이 아닙니다. 다음 장부터 SQL과 데이터 모델링을 직접 다룰 수 있도록 **연결하고, 실행하고, 확인할 수 있는 환경**을 만드는 것입니다.

```text
설치가 끝났는가?
보다 더 중요한 질문은
실제로 연결되고 실행되며 결과를 확인할 수 있는가?이다.
```

---

## 1. 데이터베이스 환경을 직접 만들어야 하는 이유

SQL 문법은 책이나 AI 답변만으로도 읽을 수 있습니다. 하지만 데이터베이스는 실행 결과와 오류를 직접 확인하지 않으면 이해하기 어려운 부분이 많습니다.

예를 들어 외래키를 다음과 같이 설명할 수 있습니다.

> 외래키는 다른 테이블의 기본키를 참조해 테이블 사이의 관계를 유지하는 값이다.

정의만 읽으면 다소 추상적으로 느껴질 수 있습니다. 반면 실제 데이터베이스에서 다음 과정을 실행하면 외래키의 역할이 분명해집니다.

```text
students 테이블을 만든다.
courses 테이블을 만든다.
enrollments 테이블을 만든다.
존재하지 않는 student_id를 입력한다.
DBMS가 외래키 오류를 발생시키는지 확인한다.
```

이 과정에서 데이터베이스는 단순히 값을 보관하는 공간이 아니라, 정해진 규칙을 지키도록 데이터를 통제하는 시스템이라는 점을 확인할 수 있습니다.

이 책에서는 다음 환경을 기본으로 사용합니다.

```text
PostgreSQL + DBeaver + GitHub
```

각 도구는 서로 다른 역할을 맡습니다.

| 도구 | 역할 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 실행하는 관계형 DBMS |
| DBeaver | PostgreSQL에 연결해 구조와 실행 결과를 확인하는 GUI 도구 |
| GitHub | SQL과 코드의 변경 이력을 관리하는 저장소 |
| ChatGPT | 개념 설명, 오류 메시지 해석, 검토 질문 작성 보조 |
| Codex | SQL 파일과 코드 초안 생성, 수정, 테스트 보조 |

![전체 실습 환경 구조](../../images/chapter03/ch03_01_practice_environment_flow.svg)

그림 3-1 전체 데이터베이스 작업 환경

중요한 것은 도구를 많이 사용하는 것이 아닙니다. 각 도구가 어떤 문제를 해결하는지 구분하는 것입니다.

---

## 2. PostgreSQL이란 무엇인가

PostgreSQL은 대표적인 오픈소스 관계형 데이터베이스 관리 시스템입니다. SQL 기초부터 JOIN, 트랜잭션, 인덱스, 권한 관리까지 관계형 데이터베이스의 주요 기능을 폭넓게 다룰 수 있습니다.

PostgreSQL은 줄여서 **Postgres**라고도 부릅니다.

```text
PostgreSQL = Postgres
```

한글로는 보통 ‘포스트그레스큐엘’ 또는 ‘포스트그레스’라고 읽습니다.

이 책에서 PostgreSQL을 사용하는 이유는 다음과 같습니다.

| 이유 | 설명 |
| --- | --- |
| 표준적인 관계형 DB 기능 | 테이블, 관계, SQL, 트랜잭션, 인덱스를 폭넓게 다룰 수 있음 |
| 오픈소스 | 별도의 상용 라이선스 없이 사용할 수 있음 |
| 다양한 개발 환경과 연동 | Python, JavaScript, Java 등 여러 언어와 연결 가능 |
| 확장 기능 | 필요하면 `pgvector` 같은 확장 기능을 추가할 수 있음 |
| 로컬과 클라우드 모두 지원 | 자신의 컴퓨터나 관리형 서비스에서 사용할 수 있음 |

PostgreSQL은 실제 데이터를 관리하는 서버입니다. DBeaver를 종료해도 PostgreSQL 서버가 실행 중이라면 데이터는 그대로 남아 있습니다.

---

## 3. DBeaver란 무엇인가

DBeaver는 여러 종류의 데이터베이스에 접속할 수 있는 GUI 기반 클라이언트 도구입니다.

PostgreSQL은 터미널과 `psql` 명령으로도 사용할 수 있습니다. 그러나 처음 데이터베이스를 다룰 때는 테이블 목록, 열 구조, 실행 결과를 화면으로 확인할 수 있는 도구가 편리합니다.

DBeaver에서는 다음 작업을 수행할 수 있습니다.

```text
데이터베이스 서버에 연결한다.
데이터베이스와 스키마 목록을 확인한다.
테이블 구조를 확인한다.
SQL 편집기에서 쿼리를 실행한다.
조회 결과를 표로 확인한다.
오류 메시지를 확인한다.
```

PostgreSQL과 DBeaver의 관계는 다음과 같이 구분하면 됩니다.

| 구분 | PostgreSQL | DBeaver |
| --- | --- | --- |
| 종류 | DBMS | 데이터베이스 클라이언트 |
| 주요 역할 | 데이터 저장, 규칙 적용, SQL 처리 | 연결, SQL 작성, 결과 확인 |
| 데이터 보관 | 실제 데이터를 보관함 | 데이터를 직접 보관하는 도구가 아님 |
| 종료했을 때 | 서버가 중지되면 접속할 수 없음 | 프로그램만 닫히며 DB 데이터는 유지됨 |

DBeaver는 PostgreSQL 외에도 MySQL, MariaDB, SQLite 등 다양한 DBMS에 연결할 수 있습니다. 이 장에서는 PostgreSQL 연결만 사용합니다.

---

## 4. 로컬 환경과 클라우드 환경 선택하기

PostgreSQL을 사용하는 방법은 크게 두 가지입니다.

| 방식 | 설명 | 장점 | 고려할 점 |
| --- | --- | --- | --- |
| 로컬 PostgreSQL | 자신의 컴퓨터에 직접 설치 | 인터넷 없이 사용 가능, 서버 구조 이해에 유리 | 설치 권한과 환경 설정이 필요함 |
| 클라우드 PostgreSQL | 외부 서비스가 제공하는 PostgreSQL 사용 | 설치 부담이 적고 여러 기기에서 접속 가능 | 인터넷과 계정이 필요하며 접속 정보 관리가 중요함 |

![로컬 PostgreSQL과 클라우드 PostgreSQL 비교](../../images/chapter03/ch03_02_local_vs_cloud_db.svg)

그림 3-2 로컬 환경과 클라우드 환경 비교

이 책의 기본 설명은 로컬 PostgreSQL을 기준으로 합니다. 자신의 컴퓨터에서 서버가 실행되고 DBeaver가 그 서버에 연결되는 구조를 이해하기 좋기 때문입니다.

다음과 같은 경우에는 관리형 클라우드 PostgreSQL을 고려할 수 있습니다.

- 회사나 공용 컴퓨터라 프로그램 설치 권한이 없는 경우
- 운영체제별 설치 문제를 피하고 싶은 경우
- 여러 기기에서 같은 데이터베이스에 접속해야 하는 경우
- 웹 서비스와 연결되는 원격 데이터베이스가 필요한 경우

Neon이나 Supabase 같은 서비스는 PostgreSQL 기반 환경의 대표적인 예입니다. 서비스의 요금제, 제공 기능, 사용 조건은 바뀔 수 있으므로 실제 사용 시점의 안내를 확인해야 합니다.

어느 방식을 사용하더라도 SQL과 테이블의 핵심 개념은 같습니다.

---

## 5. 설치 전에 확인할 사항

프로그램을 설치하기 전에는 다음 항목을 확인합니다.

| 항목 | 확인 내용 |
| --- | --- |
| 운영체제 | Windows, macOS, Linux 중 현재 환경 확인 |
| 설치 권한 | 프로그램과 서비스를 설치할 권한이 있는지 확인 |
| 인터넷 연결 | 설치 파일과 드라이버를 내려받을 수 있는지 확인 |
| 포트 | PostgreSQL 기본 포트인 `5432`를 사용할 수 있는지 확인 |
| 비밀번호 관리 | `postgres` 사용자 비밀번호를 안전하게 기록 |
| 보안 정책 | 회사나 공용 컴퓨터에서 외부 접속이 제한되는지 확인 |

PostgreSQL 설치 과정에서 설정한 비밀번호는 DBeaver 연결에 필요합니다. 비밀번호를 잊으면 연결 과정에서 계속 인증 오류가 발생할 수 있습니다.

```text
비밀번호는 기억에만 의존하지 말고 안전한 비밀번호 관리 도구에 보관한다.
```

다만 비밀번호를 다음 위치에 그대로 기록해서는 안 됩니다.

- 공개 GitHub 저장소
- SQL 파일
- README 문서
- 화면 캡처
- AI 질문에 첨부하는 전체 접속 문자열

---

## 6. PostgreSQL 설치 개요

설치 화면과 세부 옵션은 운영체제와 버전에 따라 달라질 수 있습니다. 버튼의 위치를 외우기보다 설치 과정에서 무엇을 설정하는지 이해하는 편이 중요합니다.

### 6.1 Windows에서 설치할 때

일반적인 설치 흐름은 다음과 같습니다.

```text
1. PostgreSQL 공식 설치 프로그램을 내려받는다.
2. 설치 프로그램을 실행한다.
3. PostgreSQL 서버 구성 요소를 선택한다.
4. postgres 사용자 비밀번호를 설정한다.
5. 기본 포트 5432를 확인한다.
6. 설치를 완료한다.
7. PostgreSQL 서비스가 실행 중인지 확인한다.
```

처음 사용하는 경우 대부분의 옵션은 기본값을 사용해도 됩니다. 특히 기억해야 할 값은 다음과 같습니다.

| 항목 | 일반적인 값 |
| --- | --- |
| 관리자 사용자 | `postgres` |
| 기본 포트 | `5432` |
| 초기 데이터베이스 | `postgres` |
| 비밀번호 | 설치 과정에서 직접 설정한 값 |

Windows에서는 PostgreSQL이 백그라운드 서비스로 실행됩니다. DBeaver 연결이 되지 않을 때는 Windows의 서비스 관리 화면에서 PostgreSQL 서비스가 실행 중인지 확인합니다.

서비스 이름은 설치 버전에 따라 다음과 비슷하게 표시될 수 있습니다.

```text
postgresql-x64-16
postgresql-x64-17
```

정확한 이름보다 상태가 ‘실행 중’인지가 중요합니다.

### 6.2 macOS에서 설치할 때

macOS에서는 여러 방식으로 PostgreSQL을 설치할 수 있습니다.

```text
공식 설치 프로그램
Homebrew
Postgres.app
```

Homebrew를 사용한다면 다음과 같은 명령을 사용할 수 있습니다.

```bash
brew install postgresql
brew services start postgresql
```

설치 방식에 따라 초기 사용자와 데이터베이스 이름이 달라질 수 있습니다. 최종적으로는 DBeaver에서 연결에 성공하고 SQL을 실행할 수 있는지를 기준으로 확인합니다.

---

## 7. PostgreSQL 실행 상태 확인하기

설치가 끝난 뒤에는 서버와 명령 도구가 정상인지 확인합니다.

### 7.1 버전 확인

터미널이나 명령 프롬프트에서 다음 명령을 실행합니다.

```bash
psql --version
```

정상적으로 인식되면 다음과 비슷한 결과가 표시됩니다.

```text
psql (PostgreSQL) 16.x
```

버전 번호는 환경에 따라 다를 수 있습니다.

`psql` 명령이 인식되지 않는다고 해서 PostgreSQL 서버 설치가 반드시 실패한 것은 아닙니다. 실행 파일 경로가 PATH 환경변수에 등록되지 않았을 수 있습니다. 이 경우 DBeaver 연결이 가능한지 먼저 확인해도 됩니다.

### 7.2 서버 실행 여부 확인

DBeaver에서 `localhost:5432` 연결이 거부된다면 다음 순서로 점검합니다.

```text
PostgreSQL 서비스가 실행 중인가?
포트가 5432가 맞는가?
다른 PostgreSQL 버전이 같은 포트를 사용하고 있지 않은가?
방화벽이나 보안 프로그램이 연결을 막고 있지 않은가?
```

---

## 8. DBeaver 설치와 첫 실행

DBeaver는 Community Edition을 사용할 수 있습니다. 설치 후 처음 실행하면 데이터베이스 연결을 새로 만들 수 있습니다.

PostgreSQL 연결에 필요한 기본 정보는 다음과 같습니다.

| 항목 | 로컬 환경의 일반적인 값 |
| --- | --- |
| Host | `localhost` |
| Port | `5432` |
| Database | `postgres` 또는 새로 만든 데이터베이스 |
| Username | `postgres` |
| Password | PostgreSQL 설치 시 설정한 비밀번호 |

처음 PostgreSQL 연결을 만들 때 DBeaver가 JDBC 드라이버를 내려받도록 요청할 수 있습니다. 드라이버는 DBeaver가 PostgreSQL과 통신하는 데 필요한 구성 요소입니다.

---

## 9. DBeaver에서 PostgreSQL에 연결하기

DBeaver에서 새 연결을 만드는 일반적인 흐름은 다음과 같습니다.

```text
1. DBeaver를 실행한다.
2. New Database Connection을 선택한다.
3. PostgreSQL을 선택한다.
4. Host, Port, Database, Username, Password를 입력한다.
5. Test Connection을 실행한다.
6. 성공 메시지를 확인한다.
7. 연결 설정을 저장한다.
```

![DBeaver에서 PostgreSQL 연결 흐름](../../images/chapter03/ch03_03_dbeaver_connection_flow.svg)

그림 3-3 DBeaver에서 PostgreSQL에 연결하는 흐름

처음 연결할 때는 `Database` 항목에 `postgres`를 사용할 수 있습니다. `postgres`는 설치 과정에서 기본으로 만들어지는 관리용 데이터베이스입니다.

### 연결 정보의 의미

| 항목 | 의미 |
| --- | --- |
| Host | PostgreSQL 서버가 실행되는 컴퓨터의 주소 |
| Port | PostgreSQL이 연결을 기다리는 통신 번호 |
| Database | 연결할 데이터베이스 이름 |
| Username | 접속 권한을 가진 사용자 |
| Password | 해당 사용자의 인증 정보 |

연결 테스트가 성공하면 DBeaver의 Database Navigator에 PostgreSQL 연결이 표시됩니다.

---

## 10. 작업용 데이터베이스 만들기

이 책에서는 예제 실행을 위한 데이터베이스 이름으로 다음 값을 사용합니다.

```text
ai_database_book
```

`postgres` 데이터베이스에 연결한 상태에서 SQL 편집기를 열고 다음 SQL을 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

실행 후 데이터베이스 목록을 새로고침하면 `ai_database_book`이 표시됩니다.

같은 SQL을 다시 실행하면 다음과 같은 오류가 발생할 수 있습니다.

```text
database "ai_database_book" already exists
```

이 메시지는 생성에 실패했다기보다 같은 이름의 데이터베이스가 이미 존재한다는 뜻입니다. 기존 데이터베이스를 계속 사용한다면 추가 작업이 필요하지 않습니다.

### 데이터베이스 이름을 정할 때

데이터베이스 이름은 다음 기준을 따르는 편이 좋습니다.

```text
영문 소문자를 사용한다.
공백 대신 언더스코어를 사용한다.
내용이나 목적이 드러나는 이름을 사용한다.
불필요한 특수문자를 사용하지 않는다.
```

좋은 예시는 다음과 같습니다.

```text
ai_database_book
school_db
shop_db
library_db
```

---

## 11. 새 데이터베이스에 다시 연결하기

데이터베이스를 만들었다고 해서 기존 SQL 편집기의 연결 대상이 자동으로 바뀌는 것은 아닙니다.

`ai_database_book`을 만든 뒤에는 다음 중 한 가지 방법으로 새 데이터베이스에 연결합니다.

- 기존 연결 설정의 Database 값을 `ai_database_book`으로 변경한다.
- `ai_database_book`을 대상으로 하는 새 연결을 만든다.
- DBeaver에서 데이터베이스 전환 기능을 사용한다.

현재 어떤 데이터베이스에 연결되어 있는지는 다음 SQL로 확인할 수 있습니다.

```sql
SELECT current_database();
```

이 확인을 생략하면 `students` 테이블을 만들었는데 예상한 데이터베이스에서 보이지 않는 문제가 생길 수 있습니다.

---

## 12. 기본 SQL로 연결 상태 검증하기

데이터베이스 연결이 끝났다면 간단한 SQL을 실행해 환경이 정상인지 확인합니다.

![기본 SQL 실행 확인 흐름](../../images/chapter03/ch03_04_sql_execution_check_flow.svg)

그림 3-4 기본 SQL 실행 확인 흐름

### 12.1 PostgreSQL 버전 확인

```sql
SELECT version();
```

현재 연결된 PostgreSQL 서버의 버전과 환경 정보가 표시됩니다.

### 12.2 현재 데이터베이스 확인

```sql
SELECT current_database();
```

결과가 `ai_database_book`인지 확인합니다.

### 12.3 간단한 계산 실행

```sql
SELECT 1 + 1 AS result;
```

결과가 `2`로 표시되면 SQL 편집기에서 쿼리가 정상적으로 실행된 것입니다.

다음 세 가지가 확인되면 기본 환경이 준비된 것입니다.

```text
PostgreSQL 서버에 연결되었다.
현재 데이터베이스를 확인했다.
SQL 실행 결과를 볼 수 있다.
```

---

## 13. 첫 번째 테이블 만들기

이제 `students` 테이블을 만듭니다.

```sql
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

각 열의 역할은 다음과 같습니다.

| 열 | 역할 |
| --- | --- |
| `id` | 학생을 구분하는 기본키 |
| `name` | 학생 이름, 빈 값 허용 안 함 |
| `email` | 이메일, 중복과 빈 값 허용 안 함 |
| `created_at` | 행이 등록된 시각, 입력하지 않으면 현재 시각 사용 |

이 SQL에는 앞 장에서 살펴본 여러 제약조건이 포함되어 있습니다.

```text
PRIMARY KEY
NOT NULL
UNIQUE
DEFAULT
```

DBeaver에서 테이블 목록을 새로고침하고 `students` 테이블이 생성되었는지 확인합니다.

### 같은 SQL을 다시 실행할 때

이미 테이블이 존재하면 다음과 비슷한 오류가 발생합니다.

```text
relation "students" already exists
```

이 오류는 같은 테이블을 두 번 만들려고 했기 때문에 발생합니다. 처음부터 다시 실행해야 한다면 기존 테이블을 삭제하거나 `CREATE TABLE IF NOT EXISTS`를 사용하는 방법을 검토할 수 있습니다.

```sql
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

다만 `IF NOT EXISTS`는 기존 테이블의 구조가 원하는 형태인지까지 확인해 주지는 않습니다. 이미 존재하는 테이블의 열과 제약조건은 별도로 점검해야 합니다.

---

## 14. 샘플 데이터 입력하고 조회하기

다음 SQL로 학생 데이터 세 건을 입력합니다.

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

정상적으로 실행되면 세 개의 행이 표시됩니다. `id`와 `created_at`은 직접 입력하지 않았지만 자동으로 값이 생성됩니다.

여기서 다음 내용을 확인할 수 있습니다.

```text
SERIAL이 id 값을 자동으로 만든다.
DEFAULT가 created_at 값을 자동으로 만든다.
INSERT가 새 행을 추가한다.
SELECT가 저장된 행을 조회한다.
```

---

## 15. 의도적으로 제약조건 오류 만들기

이번에는 이미 존재하는 이메일을 다시 입력합니다.

```sql
INSERT INTO students (name, email)
VALUES ('중복학생', 'minji@example.com');
```

`minji@example.com`은 이미 저장되어 있으므로 `UNIQUE` 제약조건 위반 오류가 발생해야 합니다.

오류가 발생했다면 데이터베이스가 정상적으로 작동한 것입니다. DBMS가 중복 이메일이라는 잘못된 데이터를 거부했기 때문입니다.

```text
오류가 발생했다 = 작업 환경이 실패했다
가 아니라
오류가 예상대로 발생했다 = 데이터 규칙이 정상적으로 적용되었다
```

오류 메시지에서는 다음 내용을 찾아봅니다.

- 어떤 테이블에서 발생했는가?
- 어떤 제약조건을 위반했는가?
- 어떤 값이 중복되었는가?
- 실행한 SQL 중 어느 부분과 관련이 있는가?

오류 메시지를 읽는 습관은 이후 외래키, 트랜잭션, 데이터 타입 문제를 해결할 때도 중요합니다.

---

## 16. 실행한 SQL을 파일로 저장하기

화면에서 SQL을 실행하고 끝내면 나중에 같은 환경을 다시 만들기 어렵습니다. 실행한 SQL은 파일로 남기는 편이 좋습니다.

이 장의 SQL은 다음 위치에 저장할 수 있습니다.

```text
code/chapter03/setup_check.sql
```

![setup_check.sql 실행 흐름](../../images/chapter03/ch03_05_setup_check_sql_flow.svg)

그림 3-5 환경 확인 SQL 파일의 실행 흐름

파일 내용은 다음과 같이 구성할 수 있습니다.

```sql
-- Chapter 03. PostgreSQL 환경 확인

-- 서버와 연결 대상 확인
SELECT version();
SELECT current_database();
SELECT 1 + 1 AS result;

-- 학생 테이블 생성
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 샘플 데이터 입력
INSERT INTO students (name, email)
VALUES
    ('김민지', 'minji@example.com'),
    ('이준호', 'junho@example.com'),
    ('박서연', 'seoyeon@example.com');

-- 데이터 조회
SELECT *
FROM students;

-- UNIQUE 제약조건 확인용 SQL
-- 이미 실행된 데이터가 있다면 오류가 발생할 수 있다.
-- INSERT INTO students (name, email)
-- VALUES ('중복학생', 'minji@example.com');
```

파일을 다시 실행할 때는 기존 데이터베이스 상태를 확인해야 합니다. 테이블과 샘플 데이터가 이미 있다면 생성 오류나 중복 오류가 발생할 수 있습니다.

---

## 17. GitHub에서 SQL과 작업 이력 관리하기

SQL 파일은 장이나 기능별 폴더로 구분하면 찾기 쉽습니다.

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

그림 3-6 장별 SQL 파일 관리 구조

GitHub에 파일을 보관하면 다음과 같은 장점이 있습니다.

- SQL 변경 이력을 확인할 수 있다.
- 오류가 발생하기 전 상태와 비교할 수 있다.
- AI가 수정한 내용을 사람이 다시 검토할 수 있다.
- 다른 컴퓨터에서도 같은 파일을 사용할 수 있다.
- 프로젝트의 데이터베이스 구조를 코드와 함께 관리할 수 있다.

단, SQL 파일과 저장소에는 비밀번호나 실제 접속 URL을 넣지 않습니다.

---

## 18. 비밀번호와 접속 정보 보호하기

클라우드 데이터베이스를 사용하면 다음과 같은 접속 문자열을 제공받을 수 있습니다.

```text
postgresql://username:password@host:5432/database
```

이 문자열에는 사용자 이름, 비밀번호, 서버 주소가 모두 포함될 수 있습니다. 그대로 GitHub에 올리면 다른 사람이 데이터베이스에 접속할 위험이 있습니다.

공개하면 안 되는 정보는 다음과 같습니다.

- 데이터베이스 비밀번호
- 전체 접속 URL
- API Key
- Access Token
- 서비스 계정 키
- 실제 값이 들어 있는 `.env` 파일

비밀정보는 환경변수나 비밀번호 관리 도구에 보관합니다. 저장소에는 변수 이름만 보여 주는 예시 파일을 둘 수 있습니다.

```text
# .env.example
DATABASE_URL=your_database_connection_url
DB_HOST=your_database_host
DB_PORT=5432
DB_NAME=your_database_name
DB_USER=your_database_user
DB_PASSWORD=your_database_password
```

실제 값이 들어 있는 `.env` 파일은 `.gitignore`에 추가합니다.

```gitignore
.env
.env.local
```

> 이미 비밀번호를 공개 저장소에 올렸다면 파일만 삭제하는 것으로 충분하지 않을 수 있습니다. 해당 비밀번호나 키를 즉시 변경하고, 필요하면 저장소 기록에서도 제거해야 합니다.

---

## 19. 로컬 설치가 어려울 때의 대안

로컬 PostgreSQL 설치가 어렵다면 관리형 PostgreSQL 서비스를 사용할 수 있습니다.

대표적인 예는 다음과 같습니다.

| 서비스 유형 | 특징 |
| --- | --- |
| Neon 같은 관리형 PostgreSQL | PostgreSQL 데이터베이스와 원격 접속 정보 제공 |
| Supabase 같은 백엔드 플랫폼 | PostgreSQL과 함께 인증, API 등 추가 기능 제공 |
| 클라우드 호스팅의 PostgreSQL | 애플리케이션 배포 환경과 함께 사용 가능 |

서비스 이름보다 중요한 것은 DBeaver 연결에 필요한 다음 정보를 확인하는 것입니다.

```text
Host
Port
Database
Username
Password
SSL 사용 여부
```

클라우드 환경에서는 `localhost`가 아니라 서비스에서 제공한 Host를 입력합니다. SSL 설정이 필요한 서비스도 있으므로 연결 안내를 확인합니다.

---

## 20. 자주 발생하는 연결 오류

설치와 연결 과정에서 발생하는 오류는 대부분 몇 가지 범주로 나눌 수 있습니다.

![오류 메시지 해결 흐름](../../images/chapter03/ch03_06_error_troubleshooting_flow.svg)

그림 3-7 오류 메시지 점검 흐름

### 20.1 연결이 거부되는 경우

다음 항목을 확인합니다.

| 확인 대상 | 점검 내용 |
| --- | --- |
| 서버 상태 | PostgreSQL 서비스가 실행 중인가? |
| Host | 로컬이면 `localhost`가 맞는가? |
| Port | 기본값 또는 설치 시 지정한 포트와 일치하는가? |
| 방화벽 | 해당 포트의 접속을 막고 있지 않은가? |
| 클라우드 설정 | 외부 접속과 IP 접근이 허용되어 있는가? |

### 20.2 비밀번호 인증이 실패하는 경우

```text
password authentication failed
```

다음 내용을 확인합니다.

- Username이 실제 PostgreSQL 사용자와 일치하는가?
- 설치 과정에서 설정한 비밀번호를 입력했는가?
- 키보드의 한/영 상태나 Caps Lock 때문에 값이 달라지지 않았는가?
- 클라우드 서비스의 비밀번호가 변경되지 않았는가?

### 20.3 데이터베이스가 없다는 오류

```text
database "ai_database_book" does not exist
```

연결하려는 데이터베이스가 아직 만들어지지 않았거나 이름을 잘못 입력한 경우입니다. 우선 `postgres` 데이터베이스로 연결한 뒤 `ai_database_book`을 생성합니다.

### 20.4 `psql` 명령이 인식되지 않는 경우

```text
'psql' is not recognized
command not found: psql
```

PostgreSQL의 명령 도구가 PATH에 등록되지 않았을 수 있습니다. PostgreSQL 설치 폴더의 `bin` 경로를 확인하거나 DBeaver 연결을 통해 서버 상태를 먼저 검증합니다.

### 20.5 테이블이 보이지 않는 경우

- Database Navigator를 새로고침했는가?
- 현재 `ai_database_book`에 연결되어 있는가?
- 다른 스키마에 테이블을 만들지 않았는가?
- SQL 실행이 실제로 성공했는가?

다음 SQL은 현재 데이터베이스 확인에 도움이 됩니다.

```sql
SELECT current_database();
```

---

## 21. 오류를 해결하는 기본 순서

오류가 발생하면 무작정 설정을 바꾸기보다 다음 순서로 확인합니다.

```text
1. 실행한 작업을 한 문장으로 정리한다.
2. 오류 메시지를 생략하지 않고 확인한다.
3. 현재 연결값과 데이터베이스 이름을 확인한다.
4. 서버, 인증, 포트, SQL 문법 중 어느 범주인지 분류한다.
5. 한 번에 하나의 설정만 바꾸고 다시 실행한다.
6. 해결된 방법을 기록한다.
```

이 순서를 따르면 같은 설정을 반복해서 바꾸거나 새로운 문제를 만드는 일을 줄일 수 있습니다.

---

## 22. ChatGPT에 오류를 질문하는 방법

AI는 오류 메시지를 해석하는 데 유용하지만, 충분한 정보가 없으면 일반적인 답변만 제시할 가능성이 높습니다.

정보가 부족한 질문은 다음과 같습니다.

```text
DBeaver가 안 됩니다. 해결해 주세요.
```

더 나은 질문은 실행 환경과 오류를 함께 제공합니다.

```text
Windows에서 로컬 PostgreSQL과 DBeaver를 사용하고 있습니다.
PostgreSQL 서비스는 실행 중입니다.

DBeaver 연결값은 다음과 같습니다.
- Host: localhost
- Port: 5432
- Database: postgres
- Username: postgres

Test Connection을 실행하면 다음 오류가 발생합니다.
[오류 메시지]

이미 확인한 내용은 다음과 같습니다.
[확인한 내용]

가능한 원인을 우선순위대로 설명하고,
각 원인을 확인할 방법을 단계별로 알려 주세요.
```

비밀번호와 전체 클라우드 접속 URL은 질문에 포함하지 않습니다.

AI가 해결 방법을 제안하면 다음을 검토합니다.

- 현재 운영체제와 PostgreSQL 버전에 맞는가?
- 데이터나 설정을 삭제하는 명령이 포함되어 있지 않은가?
- 명령의 목적을 이해할 수 있는가?
- 한 번에 하나씩 검증할 수 있는가?

---

## 23. Codex로 SQL 파일 초안 만들기

Codex에는 파일 위치와 요구사항을 구체적으로 전달하는 편이 좋습니다.

```text
현재 저장소는 ai-database-book입니다.
code/chapter03/setup_check.sql 파일을 작성해 주세요.

PostgreSQL 기준으로 다음 내용을 포함해 주세요.
- SELECT version();
- SELECT current_database();
- SELECT 1 + 1 AS result;
- students 테이블 생성
- 샘플 학생 데이터 3건 입력
- SELECT * FROM students;
- UNIQUE 제약조건 확인용 INSERT는 주석 처리

각 SQL의 목적을 설명하는 주석을 포함하고,
파일을 여러 번 실행할 때 발생할 수 있는 오류도 주석으로 안내해 주세요.
비밀번호나 접속 정보는 포함하지 마세요.
```

![ChatGPT와 Codex를 활용한 실습 보조 흐름](../../images/chapter03/ch03_08_ai_help_prompt_flow.svg)

그림 3-8 AI를 활용한 오류 분석과 SQL 파일 작성 흐름

Codex가 파일을 만들었다면 반드시 직접 실행하고 확인합니다.

| 검토 항목 | 확인 내용 |
| --- | --- |
| SQL 종류 | PostgreSQL 문법을 사용했는가? |
| 실행 순서 | 테이블 생성 후 데이터를 입력하는가? |
| 제약조건 | 기본키, NOT NULL, UNIQUE가 적절한가? |
| 재실행 | 이미 테이블이나 데이터가 있을 때의 문제가 설명되어 있는가? |
| 보안 | 비밀번호나 접속 문자열이 포함되지 않았는가? |
| 실제 결과 | DBeaver에서 실행되는가? |

---

## 24. 직접 점검해 보기

다음 순서로 환경을 확인합니다.

```text
1. PostgreSQL 서버 또는 클라우드 데이터베이스를 준비한다.
2. DBeaver에서 연결을 만든다.
3. Test Connection이 성공하는지 확인한다.
4. ai_database_book 데이터베이스를 만든다.
5. 새 데이터베이스로 연결한다.
6. SELECT version();을 실행한다.
7. SELECT current_database();를 실행한다.
8. students 테이블을 만든다.
9. 샘플 데이터 세 건을 입력한다.
10. SELECT * FROM students;로 조회한다.
11. 중복 이메일을 입력해 UNIQUE 오류를 확인한다.
12. 실행한 SQL을 setup_check.sql로 저장한다.
13. 파일에 비밀정보가 없는지 확인한다.
```

결과를 다음과 같이 간단히 기록할 수 있습니다.

```markdown
## 데이터베이스 환경 확인 기록

- 운영체제:
- PostgreSQL 사용 방식: 로컬 / 클라우드
- PostgreSQL 버전:
- DBeaver 연결 성공 여부:
- 현재 데이터베이스:
- 생성한 테이블:
- 입력한 샘플 데이터 수:
- 확인한 제약조건 오류:
- 발생한 문제와 해결 방법:
```

---

## 25. 자주 하는 실수

### 실수 1. PostgreSQL과 DBeaver를 같은 프로그램으로 생각한다

PostgreSQL은 데이터를 관리하는 DBMS이고, DBeaver는 그 DBMS에 접속하는 클라이언트입니다. DBeaver만 설치했다고 PostgreSQL 서버가 생기는 것은 아닙니다.

### 실수 2. 비밀번호를 기억에만 의존한다

설치 시 설정한 비밀번호를 잊으면 연결할 수 없습니다. 안전한 비밀번호 관리 도구에 보관합니다.

### 실수 3. 현재 데이터베이스를 확인하지 않는다

SQL 편집기가 어느 데이터베이스에 연결되어 있는지 확인하지 않으면 예상하지 않은 위치에 테이블을 만들 수 있습니다.

```sql
SELECT current_database();
```

### 실수 4. 오류 메시지를 읽지 않고 설정을 반복해서 바꾼다

오류 메시지는 서버 연결, 인증, 데이터베이스 이름, SQL 문법 중 어느 부분에 문제가 있는지 알려 주는 핵심 단서입니다.

### 실수 5. SQL을 파일로 남기지 않는다

작업 과정을 파일로 남기지 않으면 같은 환경을 다시 만들거나 문제 발생 전 상태와 비교하기 어렵습니다.

### 실수 6. 접속 정보를 공개 저장소에 올린다

비밀번호와 접속 URL은 코드와 분리해야 합니다. 공개한 사실을 발견했다면 해당 정보부터 변경합니다.

---

## 26. 스스로 확인하기

### 개념 확인

1. PostgreSQL과 DBeaver의 역할은 어떻게 다른가?
2. 로컬 데이터베이스와 클라우드 데이터베이스는 어떤 상황에 각각 적합한가?
3. DBeaver 연결에 필요한 다섯 가지 기본 정보는 무엇인가?
4. `SELECT current_database();`를 실행해야 하는 이유는 무엇인가?
5. `UNIQUE` 제약조건 오류가 정상 동작을 의미할 수 있는 이유는 무엇인가?

### 실행 확인

1. `ai_database_book` 데이터베이스를 만들고 목록에서 확인해 본다.
2. `students` 테이블을 생성한다.
3. 샘플 데이터 세 건을 입력하고 조회한다.
4. 중복 이메일을 입력해 오류 메시지를 확인한다.
5. 실행한 SQL을 파일로 저장한다.

### AI 검토

다음 문장을 재현 가능한 질문으로 바꿔 봅니다.

```text
PostgreSQL 연결이 안 된다.
```

질문에는 다음 정보가 포함되어야 합니다.

```text
운영체제
로컬 또는 클라우드 환경
PostgreSQL과 DBeaver 버전
Host, Port, Database, Username
오류 메시지
이미 확인한 내용
```

비밀번호는 포함하지 않습니다.

---

## 27. 핵심 정리

| 개념 | 핵심 내용 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 처리하는 관계형 DBMS |
| DBeaver | 데이터베이스에 연결해 SQL과 결과를 확인하는 GUI 도구 |
| 로컬 DB | 자신의 컴퓨터에서 실행하는 데이터베이스 |
| 클라우드 DB | 외부 서비스에서 제공하는 원격 데이터베이스 |
| 연결 정보 | Host, Port, Database, Username, Password |
| 환경 검증 | 버전, 현재 데이터베이스, 간단한 SQL 실행 확인 |
| 제약조건 오류 | 잘못된 데이터가 차단되고 있음을 보여 줄 수 있음 |
| SQL 파일 | 실행 과정을 재현하고 변경 이력을 관리하는 자료 |
| 비밀정보 | 코드와 공개 저장소에서 분리해야 하는 값 |

이 장의 핵심을 한 문장으로 정리하면 다음과 같습니다.

```text
데이터베이스 사용은 설치에서 끝나는 것이 아니라,
직접 연결하고 실행하고 결과와 오류를 확인하는 데서 시작된다.
```

---

## 28. 다음 장에서는

다음 장에서는 준비한 PostgreSQL 환경에서 관계형 데이터베이스와 SQL의 기본 흐름을 살펴봅니다.

```text
테이블 생성
데이터 추가
데이터 조회
데이터 수정
데이터 삭제
조건 검색
정렬
AI가 만든 SQL 검토
```

이 장에서 만든 `ai_database_book` 데이터베이스와 DBeaver 연결은 이후 예제를 실행하는 기본 환경으로 계속 사용합니다.
