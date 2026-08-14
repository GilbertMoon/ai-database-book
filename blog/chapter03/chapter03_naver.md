# [AI 시대의 데이터베이스 입문 03] PostgreSQL과 DBeaver 설치부터 연결까지 완전 초보자 가이드

안녕하세요. 아토믹데브입니다.

이번 시간부터 드디어 데이터베이스를 직접 실행해 봅니다.

앞에서는 데이터, 데이터베이스, DBMS, 테이블 같은 기본 개념을 배웠다면 이번 Chapter에서는 **PostgreSQL을 설치하고 DBeaver로 연결한 뒤 실제 SQL이 실행되는지 확인하는 것**이 목표입니다.

처음 데이터베이스를 설치하는 분도 그대로 따라 할 수 있도록 Windows 기준으로 설명하겠습니다.

> 이 글의 핵심은 설치 화면을 외우는 것이 아니라, 마지막에 **PostgreSQL 서버가 실행되고 DBeaver에서 연결한 뒤 SQL이 정상 실행되는 상태**를 만드는 것입니다.

---

## 오늘 완성할 환경

이번 글을 끝까지 따라오면 다음 상태를 만들 수 있습니다.

```text
PostgreSQL 설치
↓
PostgreSQL 서버 실행 확인
↓
DBeaver 설치
↓
PostgreSQL 연결 생성
↓
ai_database_book 데이터베이스 생성
↓
현재 접속 위치 확인
↓
간단한 SQL 실행 성공
```

최종 확인 기준은 다음과 같습니다.

| 확인 항목 | 완료 기준 |
| --- | --- |
| PostgreSQL | 서버가 실행 중 |
| DBeaver | PostgreSQL 연결 성공 |
| 데이터베이스 | `ai_database_book` 사용 가능 |
| SQL 실행 | `SELECT 1 + 1;` 결과가 2 |
| 연결 확인 | 현재 DB와 사용자 확인 가능 |

---

## STEP 1. PostgreSQL과 DBeaver 역할 다시 확인하기

두 프로그램은 역할이 다릅니다.

| 프로그램 | 역할 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 실행하는 DBMS |
| DBeaver | PostgreSQL에 접속해 SQL을 작성하고 결과를 보는 클라이언트 |

쉽게 표현하면 다음과 같습니다.

```text
DBeaver
→ SQL을 작성하는 화면

PostgreSQL
→ 실제 데이터를 저장하고 SQL을 실행하는 서버
```

따라서 **DBeaver만 설치해서는 데이터베이스 실습을 할 수 없습니다.** PostgreSQL 서버가 함께 준비되어 있어야 합니다.

---

## STEP 2. PostgreSQL 다운로드하기

PostgreSQL 공식 다운로드 페이지에서 자신의 운영체제에 맞는 설치 프로그램을 내려받습니다.

공식 사이트:

<https://www.postgresql.org/download/>

Windows 사용자는 Windows 항목으로 들어가 설치 프로그램을 다운로드합니다.

설치 버전은 이 글 작성 시점의 화면과 달라질 수 있으므로 특정 버전 번호보다 **지원되는 최신 안정 버전**을 사용하는 것이 좋습니다.

이 수업의 SQL은 PostgreSQL 15 이상을 기준으로 합니다.

---

## STEP 3. PostgreSQL 설치하기

설치 프로그램을 실행합니다.

처음 설치하는 경우 기본 설정을 대부분 그대로 사용해도 됩니다.

설치 과정에서 특히 기억해야 할 항목은 다음입니다.

```text
사용자 이름 : postgres
비밀번호   : 직접 설정
포트       : 기본값 5432
```

### 비밀번호는 꼭 기억하세요

설치 중 `postgres` 관리자 계정의 비밀번호를 설정하게 됩니다.

이 비밀번호는 뒤에서 DBeaver로 연결할 때 필요합니다.

예를 들어 다음처럼 이해하면 됩니다.

```text
Username : postgres
Password : 내가 설치할 때 설정한 비밀번호
```

> 실제 비밀번호를 GitHub, 블로그, 수업 자료 등에 작성하면 안 됩니다.

### Port는 기본값 5432

PostgreSQL의 기본 포트는 일반적으로 다음 값입니다.

```text
5432
```

기존 PostgreSQL이 이미 설치되어 있다면 다른 포트를 사용하고 있을 수도 있습니다.

---

## STEP 4. PostgreSQL 서버가 실행 중인지 확인하기

설치가 끝났다고 해서 항상 서버가 정상 실행 중인 것은 아닙니다.

Windows에서는 서비스 관리 화면에서 확인할 수 있습니다.

### Windows 서비스 열기

키보드에서 다음을 누릅니다.

```text
Windows + R
```

다음을 입력합니다.

```text
services.msc
```

PostgreSQL 관련 서비스를 찾습니다.

예를 들어 다음과 비슷한 이름으로 표시될 수 있습니다.

```text
postgresql-x64-17
postgresql-x64-16
postgresql-x64-15
```

버전에 따라 이름은 달라집니다.

상태가 **실행 중(Running)** 이면 정상입니다.

---

## STEP 5. PostgreSQL 버전 확인하기

PowerShell 또는 명령 프롬프트에서 다음 명령을 실행할 수 있습니다.

```bash
psql --version
```

예시 결과:

```text
psql (PostgreSQL) 17.x
```

만약 다음과 같이 나온다면

```text
'psql'은(는) 내부 또는 외부 명령...
```

PostgreSQL 설치가 반드시 실패했다는 뜻은 아닙니다.

Windows PATH에 PostgreSQL의 `bin` 폴더가 등록되지 않았을 수 있습니다.

이번 수업에서는 DBeaver 연결이 정상이라면 우선 계속 진행해도 됩니다.

---

## STEP 6. DBeaver Community 다운로드하기

DBeaver 공식 다운로드 페이지에 접속합니다.

<https://dbeaver.io/download/>

무료 버전인 **DBeaver Community**를 설치합니다.

설치가 끝나면 DBeaver를 실행합니다.

---

## STEP 7. PostgreSQL 연결 만들기

DBeaver에서 새 데이터베이스 연결을 생성합니다.

보통 다음 순서로 진행합니다.

```text
새 데이터베이스 연결
→ PostgreSQL 선택
→ 연결 정보 입력
```

기본 로컬 설치라면 다음 정보를 사용합니다.

| 항목 | 입력값 |
| --- | --- |
| Host | `localhost` |
| Port | `5432` |
| Database | `postgres` |
| Username | `postgres` |
| Password | 설치할 때 설정한 비밀번호 |

정리하면 다음과 같습니다.

```text
Host     : localhost
Port     : 5432
Database : postgres
Username : postgres
Password : ********
```

### 각 항목의 의미

**Host**

PostgreSQL 서버가 실행되는 컴퓨터입니다.

```text
localhost
```

는 현재 자신의 PC를 의미합니다.

**Port**

PostgreSQL 서버로 연결하는 통신 포트입니다.

기본값은 `5432`입니다.

**Database**

처음 연결할 데이터베이스입니다.

PostgreSQL 설치 직후에는 기본 데이터베이스인 `postgres`를 사용할 수 있습니다.

**Username**

PostgreSQL 사용자입니다.

기본 설치에서는 관리자 계정인 `postgres`를 사용합니다.

---

## STEP 8. Test Connection 실행하기

연결 정보를 입력했다면 **Test Connection**을 실행합니다.

처음 연결할 때 PostgreSQL JDBC 드라이버 다운로드 창이 나타날 수 있습니다.

다운로드를 진행합니다.

다음과 같이 연결 성공 메시지가 표시되면 정상입니다.

```text
Connected
또는
Connection successful
```

연결이 실패한다면 다음 네 가지부터 확인합니다.

```text
1. PostgreSQL 서비스가 실행 중인가?
2. Host가 localhost인가?
3. Port가 실제 PostgreSQL 포트와 같은가?
4. Username과 Password가 올바른가?
```

---

## STEP 9. 첫 SQL 실행하기

연결에 성공했다면 SQL Editor를 엽니다.

다음 SQL을 입력합니다.

```sql
SELECT 1 + 1 AS result;
```

실행 결과가 다음과 같으면 정상입니다.

```text
result
------
2
```

축하합니다.

이제 **DBeaver → PostgreSQL → SQL 실행** 흐름이 정상적으로 연결된 것입니다.

---

## STEP 10. 실습용 데이터베이스 만들기

이번 책에서는 다음 데이터베이스를 사용합니다.

```text
ai_database_book
```

PostgreSQL 기본 `postgres` 데이터베이스에 연결한 상태에서 다음 SQL을 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

실행 후 DBeaver의 데이터베이스 목록을 새로고침합니다.

다음 데이터베이스가 보이는지 확인합니다.

```text
ai_database_book
```

> 이미 같은 이름의 데이터베이스가 있다면 다시 생성할 필요가 없습니다.

---

## STEP 11. ai_database_book 데이터베이스로 연결하기

데이터베이스를 생성한 뒤에는 실제 실습을 `ai_database_book`에서 진행해야 합니다.

DBeaver에서 새 연결을 만들거나 기존 연결의 Database 항목을 다음과 같이 변경합니다.

```text
Database : ai_database_book
```

연결 후 반드시 현재 접속 위치를 확인합니다.

---

## STEP 12. 현재 연결된 데이터베이스 확인하기

다음 SQL을 실행합니다.

```sql
SELECT current_database();
```

결과가 다음과 같아야 합니다.

```text
ai_database_book
```

현재 로그인한 사용자도 확인할 수 있습니다.

```sql
SELECT current_user;
```

예상 결과:

```text
postgres
```

한 번에 확인하려면 다음 SQL을 사용할 수도 있습니다.

```sql
SELECT
    current_database() AS database_name,
    current_user AS user_name;
```

이 습관은 매우 중요합니다.

SQL을 실행하기 전에 다음을 확인해야 하기 때문입니다.

```text
나는 지금 어느 서버의
어느 데이터베이스에서
어떤 사용자로 작업하고 있는가?
```

---

## STEP 13. 현재 스키마와 search_path 확인하기

PostgreSQL에서는 데이터베이스 내부에 여러 스키마를 만들 수 있습니다.

현재 스키마를 확인합니다.

```sql
SELECT current_schema();
```

기본 환경에서는 일반적으로 다음이 표시됩니다.

```text
public
```

검색 경로도 확인해 봅니다.

```sql
SHOW search_path;
```

`search_path`는 테이블 이름 앞에 스키마를 생략했을 때 PostgreSQL이 어느 스키마부터 찾을지 결정하는 설정입니다.

지금은 자세한 원리를 외우지 않아도 됩니다.

다음 정도만 기억하세요.

```text
public.students
```

처럼 스키마 이름을 직접 쓰면 어떤 테이블을 가리키는지 더 명확해집니다.

---

## STEP 14. SQL 한 문장 실행과 전체 실행 구분하기

DBeaver에서 여러 SQL을 작성했다고 가정해 보겠습니다.

```sql
SELECT current_database();

SELECT current_user;

SELECT current_schema();
```

SQL Editor에서는 상황에 따라 다음과 같이 실행 범위가 달라질 수 있습니다.

```text
현재 SQL 한 문장 실행
선택한 SQL 실행
전체 스크립트 실행
```

초보자에게 자주 발생하는 실수가 있습니다.

```text
나는 한 줄만 실행했다고 생각했는데
전체 SQL이 실행됨
```

특히 뒤에서 `INSERT`, `UPDATE`, `DELETE` 같은 데이터 변경 SQL을 사용할 때는 실행 범위를 반드시 확인해야 합니다.

---

## STEP 15. 자주 발생하는 연결 오류 해결하기

### 오류 1. Connection refused

주로 PostgreSQL 서버가 실행되지 않을 때 발생합니다.

확인 순서:

```text
Windows 서비스
→ PostgreSQL 서비스 찾기
→ 실행 중인지 확인
```

### 오류 2. password authentication failed

비밀번호가 맞지 않을 가능성이 높습니다.

```text
Username : postgres
Password : PostgreSQL 설치 때 설정한 비밀번호
```

을 다시 확인합니다.

### 오류 3. 포트 연결 실패

기본 포트는 `5432`이지만 다른 포트를 사용 중일 수 있습니다.

DBeaver 연결 설정의 Port와 실제 PostgreSQL 포트가 같은지 확인합니다.

### 오류 4. database does not exist

입력한 데이터베이스가 존재하지 않을 때 발생합니다.

처음에는 `postgres` 데이터베이스로 접속한 뒤 필요한 데이터베이스를 생성하면 됩니다.

---

## AI 활용 실습 1. 연결 오류를 ChatGPT와 분석하기

연결 오류가 발생하면 오류 메시지를 무작정 수정하지 말고 AI에게 원인을 분류하게 해볼 수 있습니다.

다음 프롬프트를 사용해 보세요.

```text
나는 Windows에서 PostgreSQL과 DBeaver를 처음 설치한 초보자입니다.

DBeaver에서 PostgreSQL 연결 중 다음 오류가 발생했습니다.

[여기에 오류 메시지 붙여넣기]

다음 순서로 설명해 주세요.

1. 오류가 의미하는 것
2. 가장 가능성이 높은 원인
3. Windows에서 확인할 위치
4. 초보자가 따라 할 해결 순서
5. 해결 후 정상 여부를 확인하는 방법
```

중요한 점은 **AI가 제시한 명령을 바로 실행하지 말고 어떤 설정을 변경하는지 먼저 확인하는 것**입니다.

---

## AI 활용 실습 2. 현재 DB 환경 점검 SQL 만들기

ChatGPT 또는 Codex에 다음과 같이 요청해 보세요.

```text
PostgreSQL에서 현재 실습 환경을 확인하고 싶습니다.

다음 항목을 조회하는 초보자용 SQL을 작성해 주세요.

- 현재 데이터베이스
- 현재 사용자
- 현재 스키마
- search_path
- PostgreSQL 버전

각 SQL이 무엇을 확인하는지도 설명해 주세요.
```

AI가 만든 SQL을 실행한 뒤 실제 결과와 설명이 일치하는지 확인합니다.

---

## 보안에서 꼭 기억할 것

다음 정보는 블로그, GitHub, 캡처 이미지, 수업 과제 등에 공개하지 않는 것이 좋습니다.

```text
실제 PostgreSQL 비밀번호
클라우드 DB 비밀번호
전체 DATABASE_URL
접속 토큰
API Key
```

예를 들어 다음처럼 공개하면 안 됩니다.

```text
postgresql://username:real_password@server-address:5432/database
```

예제 자료에서는 실제 값 대신 다음처럼 표현합니다.

```text
postgresql://username:YOUR_PASSWORD@localhost:5432/database
```

---

## 오늘의 최종 점검

아래 항목이 모두 확인되면 Chapter 03 실습은 완료입니다.

- [ ] PostgreSQL을 설치했다.
- [ ] PostgreSQL 서비스가 실행 중이다.
- [ ] DBeaver Community를 설치했다.
- [ ] DBeaver에서 PostgreSQL 연결 테스트에 성공했다.
- [ ] `SELECT 1 + 1;` 결과가 `2`로 나온다.
- [ ] `ai_database_book` 데이터베이스가 존재한다.
- [ ] `SELECT current_database();` 결과가 `ai_database_book`이다.
- [ ] 현재 사용자와 스키마를 확인했다.
- [ ] `SHOW search_path;`를 실행해 보았다.
- [ ] 실제 비밀번호를 공개 파일에 기록하지 않았다.

---

## 오늘의 핵심 정리

이번 시간에 가장 중요한 흐름은 다음입니다.

```text
PostgreSQL
→ 실제 데이터를 저장하고 SQL을 실행

DBeaver
→ PostgreSQL에 연결해 SQL을 작성하고 결과를 확인

Host
→ PostgreSQL 서버의 위치

Port
→ PostgreSQL 서버의 연결 통로

Database
→ 현재 사용할 데이터베이스

Username
→ PostgreSQL에 접속하는 사용자
```

그리고 SQL을 실행하기 전에 다음을 확인하는 습관을 만들어야 합니다.

```text
어느 서버인가?
어느 데이터베이스인가?
어떤 사용자로 접속했는가?
어느 스키마를 사용하고 있는가?
```

---

## 다음 시간에는

Chapter 04에서는 지금 만든 `ai_database_book` 데이터베이스에서 **테이블을 직접 만들고 데이터를 INSERT, SELECT, UPDATE, DELETE하는 기본 SQL 실습**을 시작합니다.

지금까지는 환경을 준비하는 단계였다면 다음 시간부터는 실제 데이터를 직접 다루게 됩니다.

---

## 관련 글

- Chapter 01. AI 시대에 데이터베이스를 왜 배워야 하는가
- Chapter 02. 데이터와 DBMS의 기본 개념
- Chapter 04. 관계형 데이터베이스와 SQL 시작하기

---

#PostgreSQL #DBeaver #데이터베이스설치 #PostgreSQL설치 #SQL #DBMS #데이터베이스기초 #ChatGPT #Codex #AI활용