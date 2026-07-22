# Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기

---

## 이 장에서 살펴볼 내용

Chapter 02에서는 사용자, DBeaver, PostgreSQL, 데이터베이스, 스키마와 테이블이 어떤 구조로 연결되는지 살펴보았습니다. 이제 그 구조를 실제 환경에서 확인합니다.

이 장의 목적은 여러 SQL 기능을 미리 배우는 것이 아닙니다. 다음 장부터 사용할 PostgreSQL 환경을 정확하게 연결하고, 현재 데이터베이스와 스키마를 확인하며, SQL을 안전하게 실행할 수 있도록 준비하는 것입니다.

```text
PostgreSQL 서버 실행
→ DBeaver 연결
→ 작업용 데이터베이스 생성
→ 새 데이터베이스로 다시 연결
→ 현재 데이터베이스와 스키마 확인
→ SQL 실행 결과 확인
→ 환경 확인 파일 저장
```

이 장을 마치면 다음 작업을 수행할 수 있어야 합니다.

- PostgreSQL 서버와 DBeaver의 역할을 구분한다.
- 로컬 PostgreSQL을 준비하고 실행 상태를 확인한다.
- 로컬 PostgreSQL과 관리형 PostgreSQL의 차이를 설명한다.
- Supabase가 PostgreSQL을 중심으로 제공되는 관리형 백엔드 플랫폼임을 설명한다.
- DBeaver에서 PostgreSQL 연결을 만든다.
- `ai_database_book` 데이터베이스를 생성한다.
- 현재 연결된 데이터베이스와 스키마를 SQL로 확인한다.
- DBeaver에서 `public` 스키마와 테이블 위치를 찾는다.
- SQL 문장, 선택 영역과 전체 스크립트의 실행 차이를 이해한다.
- 비밀번호와 접속 정보를 공개 파일에서 분리한다.
- 연결 오류를 유형별로 점검하고 재현 가능한 질문을 작성한다.

이 장의 완료 기준은 다음과 같습니다.

```text
설치 파일이 실행되었다
```

가 아니라,

```text
PostgreSQL에 연결되고,
올바른 데이터베이스와 스키마에서 SQL을 실행하며,
결과와 오류를 직접 확인할 수 있다.
```

---

## 1. 이 장에서 완성할 실습 환경

이 책의 기본 실습 환경은 다음과 같습니다.

```text
로컬 PostgreSQL + DBeaver + SQL 파일
```

GitHub와 AI 도구는 환경을 구성하는 필수 프로그램은 아니지만, SQL 파일의 변경 이력을 남기고 오류를 분석하는 보조 도구로 활용할 수 있습니다.

| 구성 요소 | 역할 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 처리하는 관계형 DBMS |
| DBeaver | PostgreSQL에 연결해 SQL을 작성하고 결과를 확인하는 클라이언트 |
| SQL 파일 | 실행 과정을 재현할 수 있도록 명령을 저장하는 파일 |
| GitHub | SQL과 문서의 변경 이력을 관리하는 저장소 |
| ChatGPT·Codex | 오류 해석과 SQL·문서 초안 작성을 돕는 보조 도구 |

![전체 데이터베이스 작업 환경](../../images/chapter03/ch03_01_practice_environment_flow.svg)

그림 3-1 전체 데이터베이스 작업 환경

이 장의 환경 준비 체크리스트는 다음과 같습니다.

| 단계 | 통과 기준 |
| --- | --- |
| PostgreSQL 준비 | 접속 가능한 PostgreSQL 서버가 있음 |
| 서버 상태 | 로컬 PostgreSQL 서비스가 실행 중임 |
| DBeaver 연결 | Test Connection이 성공함 |
| 작업 DB | `ai_database_book`에 연결됨 |
| 스키마 | 현재 스키마가 `public`인지 확인함 |
| SQL 실행 | 환경 확인 SQL의 결과가 표시됨 |
| 파일 저장 | `setup_check.sql`을 다시 실행할 수 있음 |
| 보안 | 비밀번호와 접속 URL이 공개 파일에 없음 |

---

## 2. PostgreSQL과 DBeaver의 역할 복습

PostgreSQL과 DBeaver는 같은 종류의 프로그램이 아닙니다.

| 구분 | PostgreSQL | DBeaver |
| --- | --- | --- |
| 종류 | DBMS·데이터베이스 서버 | 데이터베이스 클라이언트 |
| 주요 역할 | 데이터 저장, SQL 처리, 권한과 규칙 적용 | 서버 연결, SQL 작성, 결과 표시 |
| 데이터 보관 | 실제 데이터를 보관함 | 데이터를 직접 보관하지 않음 |
| 종료했을 때 | 서버가 중지되면 접속할 수 없음 | 프로그램만 닫히며 DB 데이터는 유지됨 |

연결 흐름은 다음과 같습니다.

```text
사용자
→ DBeaver에서 SQL 작성
→ PostgreSQL에 SQL 전달
→ PostgreSQL이 실행
→ DBeaver가 결과 또는 오류 표시
```

따라서 DBeaver만 설치했다고 PostgreSQL 서버가 만들어지는 것은 아닙니다. 반대로 PostgreSQL만 설치해도 터미널의 `psql`을 통해 사용할 수 있지만, 이 책에서는 구조와 결과를 화면에서 확인하기 쉬운 DBeaver를 함께 사용합니다.

---

## 3. 로컬과 클라우드 중 실습 환경 선택하기

이 책의 기본 경로는 자신의 컴퓨터에 PostgreSQL을 설치하는 로컬 환경입니다.

| 방식 | 장점 | 고려할 점 |
| --- | --- | --- |
| 로컬 PostgreSQL | 인터넷 없이 사용 가능하고 서버 구조를 이해하기 쉬움 | 설치 권한과 서비스 설정이 필요함 |
| 관리형 PostgreSQL | 설치 부담이 적고 여러 기기에서 접속 가능 | 인터넷, 계정, SSL과 접속 정보 관리가 필요함 |

![로컬 PostgreSQL과 클라우드 PostgreSQL 연결 구조](../../images/chapter03/ch03_02_local_vs_cloud_db.svg)

그림 3-2 로컬과 클라우드 PostgreSQL 연결 구조

다음 상황에서는 관리형 PostgreSQL을 대안으로 사용할 수 있습니다.

- 회사나 공용 컴퓨터라 설치 권한이 없다.
- 운영체제별 설치 문제를 피하고 싶다.
- 여러 기기에서 같은 데이터베이스를 사용해야 한다.
- 이후 웹 서비스와 연결할 원격 데이터베이스가 필요하다.

어떤 환경을 선택하더라도 DBeaver 연결에 필요한 기본 정보와 SQL 문법은 거의 같습니다. 다만 이 책의 설치와 오류 설명은 로컬 PostgreSQL을 기본으로 합니다.

### 3.1 관리형 PostgreSQL의 예: Supabase

Supabase는 PostgreSQL을 클라우드에서 사용할 수 있도록 제공하면서 인증, 파일 저장소, 실시간 데이터 전달과 서버 측 함수 같은 기능을 함께 제공하는 백엔드 플랫폼입니다. Supabase 프로젝트를 만들면 PostgreSQL을 단순화한 별도의 데이터베이스가 아니라 실제 PostgreSQL 데이터베이스가 생성됩니다.

따라서 이 책에서 배우는 다음 내용은 Supabase의 데이터베이스에서도 그대로 적용할 수 있습니다.

```text
테이블과 관계
PK·FK와 제약조건
SQL과 CRUD
JOIN과 집계
트랜잭션
인덱스와 실행 계획
권한과 보안
```

Supabase의 구조를 단순화하면 다음과 같습니다.

```text
DBeaver · SQL Editor · 애플리케이션
                 ↓
        PostgreSQL 데이터베이스
     테이블 · 관계 · SQL · 인덱스
          ↑        ↑        ↑
        Auth     Storage   Realtime
```

핵심은 Supabase에서도 데이터의 중심이 PostgreSQL이라는 점입니다. Auth, Storage, Realtime과 Edge Functions는 PostgreSQL을 활용한 웹·모바일 서비스 개발을 돕는 추가 기능입니다.

| 구분 | 로컬 PostgreSQL | Supabase |
| --- | --- | --- |
| 서버 준비 | 사용자가 직접 설치 | 클라우드 프로젝트 생성 |
| 서버 관리 | 사용자가 서비스와 설정 관리 | 플랫폼이 기본 운영 환경 관리 |
| SQL 실행 | DBeaver·psql | DBeaver·SQL Editor 등 |
| 외부 연결 | 직접 접속과 별도 애플리케이션 구성 | PostgreSQL 연결과 데이터 API 제공 |
| 추가 기능 | 필요한 기능을 별도로 구성 | Auth·Storage·Realtime·Edge Functions 제공 |
| 주요 보안 항목 | DB 사용자와 비밀번호 관리 | 접속 정보·API 키·RLS 정책 관리 |

DBeaver에서는 Supabase가 제공하는 PostgreSQL 접속 정보를 사용해 원격 데이터베이스에 연결할 수 있습니다. 다만 연결 방식과 포트는 직접 연결인지, 연결 풀러를 사용하는지에 따라 달라질 수 있으므로 프로젝트의 최신 연결 안내를 확인해야 합니다.

> **Supabase 보안 주의**
>
> 브라우저나 모바일 앱에서 데이터에 접근하도록 구성할 때는 Row Level Security(RLS) 정책을 함께 검토해야 합니다. 공개 가능한 클라이언트용 키와 서버에서만 사용해야 하는 비밀 키를 구분하고, 전체 데이터베이스 접속 문자열과 비밀 키는 공개 저장소나 AI 질문에 포함하지 않습니다.

Supabase는 이 책의 필수 실습 환경이 아닙니다. 본문 실습은 계속 로컬 PostgreSQL과 DBeaver를 기준으로 진행하며, Supabase는 설치 부담을 줄이거나 이후 웹 서비스와 연결할 때 선택할 수 있는 관리형 PostgreSQL의 대표 사례로 이해하면 충분합니다.

---

## 4. 설치 전에 확인할 사항

설치 전에 다음 내용을 확인합니다.

| 항목 | 확인 내용 |
| --- | --- |
| 운영체제 | Windows, macOS, Linux 중 현재 환경 확인 |
| 설치 권한 | 프로그램과 서비스를 설치할 수 있는지 확인 |
| 인터넷 연결 | 설치 파일과 DBeaver 드라이버를 내려받을 수 있는지 확인 |
| 기본 포트 | 일반적으로 PostgreSQL은 `5432` 사용 |
| 관리자 사용자 | 일반적인 설치 환경에서는 `postgres` 사용 |
| 비밀번호 | 설치 중 설정한 값을 안전한 관리 도구에 보관 |
| 보안 정책 | 회사·학교 네트워크의 접속 제한 여부 확인 |

여기서 `postgres`라는 이름은 두 곳에 등장할 수 있습니다.

```text
postgres 사용자: PostgreSQL에 접속하는 관리자 계정
postgres 데이터베이스: 설치 시 기본으로 만들어지는 관리용 데이터베이스
```

같은 이름을 사용하지만 하나는 사용자이고 다른 하나는 데이터베이스입니다.

> **보안 주의**
>
> 비밀번호, 전체 접속 URL, 실제 `.env` 값, API Key와 Access Token은 SQL 파일, README, 공개 GitHub, 화면 캡처와 AI 질문에 넣지 않습니다.

---

## 5. PostgreSQL 설치와 서버 실행 확인

설치 화면과 세부 옵션은 운영체제와 버전에 따라 달라질 수 있습니다. 버튼 위치를 외우기보다 무엇을 설정하는지 이해하는 것이 중요합니다.

### 5.1 Windows에서 설치하기

일반적인 흐름은 다음과 같습니다.

```text
1. PostgreSQL 공식 설치 프로그램을 준비한다.
2. PostgreSQL 서버 구성 요소를 설치한다.
3. postgres 사용자 비밀번호를 설정한다.
4. 포트 번호를 확인한다.
5. 설치를 완료한다.
6. PostgreSQL 서비스가 실행 중인지 확인한다.
```

처음 사용하는 경우 대부분의 옵션은 기본값을 사용할 수 있습니다.

| 항목 | 일반적인 값 |
| --- | --- |
| 관리자 사용자 | `postgres` |
| 포트 | `5432` |
| 초기 데이터베이스 | `postgres` |
| 비밀번호 | 설치 과정에서 사용자가 직접 설정 |

Windows에서는 PostgreSQL이 백그라운드 서비스로 실행됩니다. 연결이 거부될 때는 서비스 관리 화면에서 PostgreSQL 관련 서비스가 실행 중인지 확인합니다. 서비스 이름은 버전에 따라 달라질 수 있으므로 정확한 이름보다 상태가 `실행 중`인지 확인하는 것이 중요합니다.

### 5.2 macOS와 Linux에서 설치하기

macOS와 Linux에는 공식 설치 프로그램, 패키지 관리자와 전용 애플리케이션 등 여러 설치 방식이 있습니다. 설치 방식에 따라 초기 사용자, 서비스 시작 방법과 데이터 저장 위치가 달라질 수 있습니다.

이 책에서는 특정 명령을 암기하기보다 다음 결과를 완료 기준으로 사용합니다.

```text
PostgreSQL 서버가 실행된다.
DBeaver에서 연결 테스트가 성공한다.
SQL을 실행할 수 있다.
```

### 5.3 `psql` 버전 확인은 선택 사항이다

터미널에서 다음 명령을 사용할 수 있습니다.

```bash
psql --version
```

`psql` 명령이 인식되지 않더라도 PostgreSQL 서버 설치가 반드시 실패한 것은 아닙니다. 실행 파일 경로가 환경변수에 등록되지 않았을 수 있습니다. 이 책의 기본 실습은 DBeaver 연결을 기준으로 진행할 수 있습니다.

---

## 6. DBeaver 설치와 드라이버 준비

DBeaver는 PostgreSQL을 포함한 여러 DBMS에 연결할 수 있는 GUI 클라이언트입니다. Community Edition으로 이 책의 실습을 진행할 수 있습니다.

DBeaver를 처음 설치하고 PostgreSQL 연결을 만들 때 JDBC 드라이버 다운로드 안내가 나타날 수 있습니다. JDBC 드라이버는 DBeaver가 PostgreSQL과 통신하기 위한 구성 요소입니다.

DBeaver 설치 후에는 다음 작업을 할 수 있습니다.

```text
PostgreSQL 서버 연결
데이터베이스와 스키마 탐색
SQL 편집기 실행
조회 결과와 오류 메시지 확인
```

---

## 7. DBeaver에서 PostgreSQL 연결 만들기

처음에는 기본 `postgres` 데이터베이스에 연결합니다.

| 연결 항목 | 로컬 환경의 일반적인 값 | 의미 |
| --- | --- | --- |
| Host | `localhost` | PostgreSQL 서버가 실행되는 컴퓨터 |
| Port | `5432` | PostgreSQL이 연결을 기다리는 통신 번호 |
| Database | `postgres` | 처음 접속할 데이터베이스 |
| Username | `postgres` | 접속 사용자 |
| Password | 설치 시 설정한 값 | 사용자 인증 정보 |

`localhost`는 현재 사용 중인 자신의 컴퓨터를 의미합니다.

일반적인 연결 흐름은 다음과 같습니다.

```text
1. DBeaver를 실행한다.
2. 새 데이터베이스 연결을 선택한다.
3. PostgreSQL을 선택한다.
4. Host, Port, Database, Username, Password를 입력한다.
5. Test Connection을 실행한다.
6. 성공 결과를 확인한다.
7. 연결 설정을 저장한다.
```

![DBeaver에서 PostgreSQL 연결하기](../../images/chapter03/ch03_03_dbeaver_connection_flow.svg)

그림 3-3 DBeaver에서 PostgreSQL 연결하기

연결 테스트 성공은 다음을 의미합니다.

```text
DBeaver가 PostgreSQL 서버에 도달했다.
입력한 사용자와 비밀번호로 인증되었다.
지정한 데이터베이스에 접속할 수 있다.
```

하지만 연결 성공만으로 이후 SQL이 올바른 데이터베이스에서 실행된다는 보장은 없습니다. SQL 편집기를 열 때마다 현재 연결 대상을 확인해야 합니다.

---

## 8. 작업용 데이터베이스 만들기

이 책에서 사용할 작업용 데이터베이스 이름은 다음과 같습니다.

```text
ai_database_book
```

기본 `postgres` 데이터베이스에 연결된 SQL 편집기에서 다음 문장을 단독으로 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

DBeaver의 설정에 따라 `CREATE DATABASE`는 다른 SQL과 묶지 않고 한 문장만 별도로 실행하는 것이 안전합니다.

같은 이름의 데이터베이스가 이미 있다면 다음과 비슷한 오류가 나타날 수 있습니다.

```text
database "ai_database_book" already exists
```

기존 데이터베이스를 계속 사용할 예정이라면 다시 만들 필요가 없습니다.

데이터베이스 이름은 일반적으로 다음 기준을 따릅니다.

```text
영문 소문자를 사용한다.
공백 대신 언더스코어를 사용한다.
목적이 드러나는 이름을 사용한다.
불필요한 특수문자를 피한다.
```

---

## 9. 새 데이터베이스로 다시 연결하기

`CREATE DATABASE`가 성공해도 기존 SQL 편집기의 연결 대상이 자동으로 `ai_database_book`으로 바뀌지는 않습니다.

다음 순서로 연결 대상을 변경합니다.

```text
ai_database_book 생성
→ DBeaver 데이터베이스 목록 새로고침
→ ai_database_book을 대상으로 새 연결 생성 또는 기존 연결 수정
→ 새 SQL 편집기 열기
→ current_database()로 확인
```

현재 연결을 확인하지 않으면 나중에 테이블을 만들었지만 예상한 위치에서 보이지 않는 문제가 발생할 수 있습니다.

---

## 10. 현재 데이터베이스와 스키마 확인하기

새 SQL 편집기에서 다음 SQL을 실행합니다.

```sql
SELECT current_database();

SELECT current_schema();

SHOW search_path;
```

일반적인 결과는 다음과 같습니다.

```text
current_database = ai_database_book
current_schema   = public
search_path      = "$user", public
```

`search_path`는 테이블 이름에 스키마를 생략했을 때 PostgreSQL이 어떤 스키마부터 찾을지 정한 순서입니다. 입문 단계에서는 다음만 기억하면 충분합니다.

> 별도의 스키마를 지정하지 않은 기본 실습에서는 일반적으로 `public` 스키마를 사용합니다.

다음 장에서 테이블을 만들면 보통 다음 위치에 나타납니다.

```text
ai_database_book
└── public
    └── Tables
```

---

## 11. DBeaver에서 데이터베이스 구조 탐색하기

DBeaver의 Database Navigator에서 다음 구조를 찾아봅니다.

```text
PostgreSQL 연결
→ ai_database_book
→ Schemas
→ public
→ Tables
```

DBeaver 버전과 연결 설정에 따라 중간 항목 이름이나 표시 순서는 조금 다를 수 있습니다.

현재는 아직 Chapter 04의 테이블 생성 실습을 시작하지 않았으므로 `Tables` 아래가 비어 있어도 정상입니다.

구조가 바로 보이지 않으면 다음 내용을 확인합니다.

- 탐색기에서 새로고침했는가?
- `ai_database_book` 연결을 열었는가?
- `Schemas` 아래에서 `public`을 찾았는가?
- 연결 필터 때문에 일부 데이터베이스나 스키마가 숨겨지지 않았는가?

---

## 12. SQL 편집기에서 문장 실행하기

DBeaver의 SQL 편집기에서는 여러 SQL을 한 파일에 작성할 수 있습니다. 실행하기 전에 현재 편집기가 어떤 연결을 사용하는지 확인합니다.

### 12.1 한 문장 실행

커서를 한 SQL 문장 안에 두고 `Execute SQL Statement` 기능을 사용하면 현재 문장 하나를 실행할 수 있습니다.

```sql
SELECT current_database();
```

### 12.2 선택한 영역만 실행

여러 SQL 중 일부만 실행하려면 원하는 영역을 선택한 뒤 실행합니다.

```sql
SELECT current_schema();
SELECT current_user;
```

### 12.3 전체 스크립트 실행

파일 전체를 실행하면 작성된 여러 문장이 순서대로 실행됩니다. 변경 SQL이 포함된 파일은 전체 실행 전에 대상 데이터베이스와 실행 범위를 다시 확인해야 합니다.

### 12.4 세미콜론의 역할

세미콜론(`;`)은 SQL 문장의 끝을 나타냅니다.

```sql
SELECT 1 + 1 AS result;
```

세미콜론이 빠지면 여러 문장이 하나로 이어진 것처럼 해석되거나 편집기 실행 범위가 예상과 달라질 수 있습니다.

### 12.5 결과와 오류 확인

SQL 실행 후에는 다음을 확인합니다.

```text
결과 탭에 행과 열이 표시되는가?
오류 탭에 메시지가 있는가?
몇 개의 문장이 실행되었는가?
현재 연결 대상은 무엇인가?
```

---

## 13. 환경 검증 SQL 실행하기

환경이 정상인지 확인하기 위해 데이터 변경이 없는 조회 SQL만 실행합니다.

```sql
SELECT version();

SELECT current_database();

SELECT current_schema();

SELECT current_user;

SELECT CURRENT_TIMESTAMP AS checked_at;

SELECT 1 + 1 AS result;
```

각 SQL의 목적은 다음과 같습니다.

| SQL | 확인 목적 |
| --- | --- |
| `version()` | PostgreSQL 서버가 응답하는지 확인 |
| `current_database()` | 올바른 데이터베이스에 연결됐는지 확인 |
| `current_schema()` | 현재 스키마가 무엇인지 확인 |
| `current_user` | 현재 접속 사용자를 확인 |
| `CURRENT_TIMESTAMP` | 서버가 SQL을 정상 처리하고 현재 시각을 반환하는지 확인 |
| `1 + 1` | 편집기 실행과 결과 표시 확인 |

![SQL로 실습 환경 확인하기](../../images/chapter03/ch03_04_sql_execution_check_flow.svg)

그림 3-4 SQL로 실습 환경 확인하기

모든 결과가 다음 조건을 만족하는지 확인합니다.

```text
PostgreSQL 버전 정보가 표시된다.
현재 데이터베이스가 ai_database_book이다.
현재 스키마가 public이다.
현재 사용자가 예상한 계정이다.
서버 시각이 반환된다.
계산 결과가 2이다.
```

---

## 14. 환경 확인 SQL 파일 저장하기

화면에서 실행하고 끝내면 나중에 환경을 다시 확인하기 어렵습니다. 환경 검증 SQL을 다음 파일에 저장합니다.

```text
code/chapter03/setup_check.sql
```

파일은 데이터베이스를 변경하지 않는 조회문만 포함합니다.

```sql
-- Chapter 03. PostgreSQL 실습 환경 확인

SELECT version();
SELECT current_database();
SELECT current_schema();
SELECT current_user;
SELECT CURRENT_TIMESTAMP AS checked_at;
SELECT 1 + 1 AS result;
```

![setup_check.sql 실행과 재실행 흐름](../../images/chapter03/ch03_05_setup_check_sql_flow.svg)

그림 3-5 `setup_check.sql` 실행과 재실행 흐름

이 파일은 여러 번 실행해도 테이블이나 데이터가 추가되지 않습니다. 따라서 다음 상황에서 반복해서 사용할 수 있습니다.

- DBeaver를 다시 실행했을 때
- 다른 연결을 선택했을 때
- 작업용 데이터베이스를 바꿨을 때
- 오류 해결 후 환경을 다시 확인할 때
- 다른 컴퓨터에서 실습 환경을 구성했을 때

---

## 15. 접속 정보와 비밀정보 보호하기

클라우드 PostgreSQL은 다음과 같은 접속 문자열을 제공할 수 있습니다.

```text
postgresql://username:password@host:5432/database
```

이 값에는 사용자 이름, 비밀번호와 서버 주소가 포함될 수 있으므로 공개 파일에 기록하면 안 됩니다.

다음 세 가지 원칙을 지킵니다.

```text
1. 비밀번호와 전체 접속 URL을 SQL이나 README에 작성하지 않는다.
2. 실제 값이 들어 있는 .env 파일은 Git에서 제외한다.
3. 공개된 비밀정보는 파일만 삭제하지 말고 즉시 폐기하거나 변경한다.
```

저장소에는 실제 값 대신 변수 이름만 보여 주는 예시 파일을 둘 수 있습니다.

```text
# .env.example
DB_HOST=your_database_host
DB_PORT=5432
DB_NAME=your_database_name
DB_USER=your_database_user
DB_PASSWORD=your_database_password
```

실제 값이 들어 있는 파일은 `.gitignore`에 추가합니다.

```gitignore
.env
.env.local
```

공개 저장소에 비밀번호를 커밋했다면 이후 파일에서 삭제하는 것만으로는 충분하지 않을 수 있습니다. 해당 비밀번호를 즉시 변경하고 필요한 경우 저장소 기록에서도 제거해야 합니다.

---

## 16. 연결 오류를 유형별로 해결하기

설치와 연결 오류는 먼저 유형을 구분하면 해결하기 쉽습니다.

| 증상 또는 메시지 | 우선 확인할 내용 |
| --- | --- |
| Connection refused | PostgreSQL 서비스, Host, Port, 방화벽 |
| Password authentication failed | Username과 Password |
| Database does not exist | 데이터베이스 이름과 생성 여부 |
| `psql` not recognized | 실행 파일 PATH 또는 DBeaver 연결 사용 |
| 테이블이 보이지 않음 | Database, Schema, Navigator 새로고침 |
| SQL syntax error | 실행한 문장, 세미콜론, 오류 위치 |

![데이터베이스 오류 해결 기본 흐름](../../images/chapter03/ch03_06_error_troubleshooting_flow.svg)

그림 3-6 데이터베이스 오류 해결 기본 흐름

공통 해결 순서는 다음과 같습니다.

```text
1. 실행하려던 작업을 한 문장으로 정리한다.
2. 오류 메시지를 생략하지 않고 읽는다.
3. 현재 Host, Port, Database와 Username을 확인한다.
4. 서버·인증·데이터베이스·스키마·SQL 중 어느 범주인지 분류한다.
5. 한 번에 하나의 설정만 바꾼다.
6. 같은 작업을 다시 실행한다.
7. 해결 방법과 실제 결과를 기록한다.
```

### 16.1 연결이 거부될 때

```text
PostgreSQL 서비스가 실행 중인가?
Host가 로컬 환경에서는 localhost인가?
Port가 실제 설정과 일치하는가?
같은 포트를 다른 프로그램이 사용하고 있지 않은가?
방화벽이나 보안 정책이 연결을 막고 있지 않은가?
```

### 16.2 비밀번호 인증이 실패할 때

- Username이 실제 PostgreSQL 사용자와 일치하는가?
- 설치 과정에서 설정한 비밀번호를 사용했는가?
- Caps Lock과 한·영 입력 상태가 올바른가?
- 저장된 비밀번호가 이전 값은 아닌가?

### 16.3 데이터베이스가 없다고 표시될 때

먼저 기본 `postgres` 데이터베이스에 연결한 뒤 `ai_database_book`이 실제로 생성되어 있는지 확인합니다.

### 16.4 테이블이 보이지 않을 때

Chapter 04 이후 테이블이 보이지 않는다면 다음 SQL부터 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
```

테이블을 다른 데이터베이스나 스키마에 만든 것은 아닌지 확인합니다.

---

## 17. AI에게 오류를 정확하게 질문하기

AI는 오류 메시지를 해석하는 데 유용하지만, 환경 정보가 부족하면 일반적인 답변만 제시할 가능성이 높습니다.

다음 질문은 정보가 부족합니다.

```text
DBeaver가 안 됩니다. 해결해 주세요.
```

다음 형식을 사용하면 원인을 더 정확하게 좁힐 수 있습니다.

```text
운영체제:
PostgreSQL 사용 방식: 로컬 / 클라우드
PostgreSQL 버전:
DBeaver 버전:

연결값:
- Host:
- Port:
- Database:
- Username:

실행한 작업:
발생한 오류 메시지:
이미 확인한 내용:

비밀번호와 전체 접속 URL은 제외했습니다.
가능한 원인을 우선순위대로 설명하고,
각 원인을 안전하게 확인하는 방법을 알려 주세요.
```

AI가 해결 방법을 제안하면 다음을 검토합니다.

- 현재 운영체제와 설치 방식에 맞는가?
- 데이터베이스나 설정을 삭제하는 명령이 포함되어 있지 않은가?
- 명령의 목적을 이해할 수 있는가?
- 한 번에 하나씩 실행하고 결과를 검증할 수 있는가?
- 비밀정보를 다시 입력하라고 요구하지 않는가?

Codex에는 다음과 같이 환경 확인 파일을 요청할 수 있습니다.

```text
현재 저장소는 ai-database-book입니다.
code/chapter03/setup_check.sql 파일을 PostgreSQL 기준으로 작성해 주세요.

다음을 포함해 주세요.
- SELECT version();
- SELECT current_database();
- SELECT current_schema();
- SELECT current_user;
- SELECT CURRENT_TIMESTAMP AS checked_at;
- SELECT 1 + 1 AS result;

테이블 생성, 데이터 입력, 삭제 SQL은 포함하지 마세요.
각 문장의 목적을 주석으로 설명하고 비밀정보를 포함하지 마세요.
```

생성 결과는 DBeaver에서 직접 실행하고 실제 결과를 확인합니다.

---

## 18. 실습 환경 완료 점검

다음 항목을 모두 확인합니다.

| 점검 항목 | 완료 기준 |
| --- | --- |
| PostgreSQL 서버 | 로컬 서비스 또는 관리형 DB에 접속 가능 |
| DBeaver | PostgreSQL 연결 테스트 성공 |
| 작업용 데이터베이스 | `ai_database_book` 생성·연결 완료 |
| 현재 데이터베이스 | `current_database()` 결과가 `ai_database_book` |
| 현재 스키마 | `current_schema()` 결과가 `public` |
| DBeaver 탐색 | `Schemas → public → Tables` 위치 확인 |
| SQL 실행 | 환경 검증 SQL 결과 확인 |
| SQL 파일 | `setup_check.sql` 저장·재실행 완료 |
| 비밀정보 | SQL, README와 GitHub에 포함되지 않음 |
| 오류 기록 | 발생한 문제와 해결 방법 기록 |

환경 확인 기록은 다음처럼 남길 수 있습니다.

```markdown
## PostgreSQL 실습 환경 확인 기록

- 운영체제:
- PostgreSQL 사용 방식: 로컬 / 클라우드
- PostgreSQL 버전:
- DBeaver 버전:
- 연결 테스트 결과:
- 현재 데이터베이스:
- 현재 스키마:
- 현재 사용자:
- setup_check.sql 실행 결과:
- 발생한 문제:
- 해결 방법:
```

---

## 19. 자주 하는 실수

### 실수 1. DBeaver만 설치하면 데이터베이스가 준비됐다고 생각한다

DBeaver는 클라이언트입니다. 연결할 PostgreSQL 서버가 별도로 필요합니다.

### 실수 2. `postgres` 사용자와 `postgres` 데이터베이스를 같은 것으로 생각한다

하나는 로그인 계정이고 다른 하나는 데이터베이스입니다.

### 실수 3. 데이터베이스를 만든 뒤 기존 편집기에서 계속 실행한다

새 데이터베이스를 만들었다고 연결 대상이 자동으로 바뀌지 않습니다. `current_database()`로 확인합니다.

### 실수 4. 스키마를 확인하지 않는다

테이블이 예상한 위치에 보이지 않으면 `current_schema()`와 DBeaver의 `Schemas` 항목을 확인합니다.

### 실수 5. 여러 SQL을 의도하지 않게 전체 실행한다

현재 문장, 선택 영역과 전체 스크립트 실행을 구분합니다.

### 실수 6. 오류 메시지를 읽지 않고 설정을 반복해서 바꾼다

오류를 서버, 인증, 데이터베이스, 스키마와 SQL 범주로 먼저 분류합니다.

### 실수 7. 비밀번호와 접속 URL을 SQL 파일이나 AI 질문에 넣는다

환경 정보와 비밀정보를 분리하고, 실제 값은 안전한 관리 도구에 보관합니다.

### 실수 8. 환경 확인 파일에 테이블 생성과 데이터 입력을 함께 넣는다

환경 확인 파일은 반복 실행할 수 있도록 조회 SQL만 포함합니다. 테이블 생성과 데이터 입력은 Chapter 04에서 별도 파일로 다룹니다.

---

## 20. 핵심 정리

| 개념 | 핵심 내용 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 처리하는 관계형 DBMS |
| DBeaver | PostgreSQL에 연결해 SQL과 결과를 확인하는 클라이언트 |
| 로컬 PostgreSQL | 자신의 컴퓨터에 직접 설치하고 관리하는 PostgreSQL 환경 |
| 관리형 PostgreSQL | 클라우드에서 서버 운영 부담을 줄여 제공되는 PostgreSQL 환경 |
| Supabase | PostgreSQL을 중심으로 Auth·Storage·Realtime 등의 기능을 함께 제공하는 관리형 백엔드 플랫폼 |
| RLS | 사용자나 역할에 따라 접근 가능한 행을 제한하는 PostgreSQL 보안 정책 |
| Host | PostgreSQL 서버가 실행되는 컴퓨터의 주소 |
| Port | PostgreSQL 접속 통로의 번호 |
| Database | 연결할 논리적 데이터베이스 |
| Schema | 데이터베이스 안에서 테이블을 묶는 이름 공간 |
| `public` | 기본 실습에서 사용하는 일반적인 스키마 |
| SQL 편집기 | SQL을 작성하고 실행 결과와 오류를 확인하는 화면 |
| `setup_check.sql` | 서버·DB·스키마·사용자와 실행 상태를 확인하는 재실행 가능한 파일 |
| 비밀정보 | SQL과 공개 저장소에서 분리해야 하는 비밀번호와 접속 URL |

이 장의 핵심을 한 문장으로 정리하면 다음과 같습니다.

```text
데이터베이스 실습은 설치에서 끝나는 것이 아니라,
올바른 데이터베이스와 스키마에 연결해
SQL 결과를 직접 확인하고 다시 재현할 수 있을 때 시작된다.
```

---

## 21. 다음 장에서는

다음 장에서는 준비한 `ai_database_book` 데이터베이스의 `public` 스키마에서 첫 번째 테이블을 만들고 데이터를 직접 다룹니다.

```text
CREATE TABLE로 테이블 만들기
INSERT로 데이터 추가하기
SELECT로 데이터 조회하기
WHERE로 조건 검색하기
ORDER BY로 정렬하기
UPDATE로 값 수정하기
DELETE로 데이터 삭제하기
AI가 만든 기본 SQL 검토하기
```

이 장의 `setup_check.sql`은 환경 확인 전용 파일로 유지하고, Chapter 04의 테이블과 CRUD 실습은 별도의 SQL 파일에서 진행합니다.
