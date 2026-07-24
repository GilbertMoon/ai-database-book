# Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기

---

## 이 장에서 살펴볼 내용

Chapter 02에서는 사용자, DBeaver, PostgreSQL, 데이터베이스, 스키마와 테이블이 어떤 구조로 연결되는지 살펴보았습니다. 이제 그 구조를 실제 환경에서 확인합니다.

이 장의 목적은 여러 SQL 기능을 미리 배우는 것이 아닙니다. 다음 장부터 사용할 PostgreSQL 환경에 정확하게 연결하고, 현재 데이터베이스와 검색 경로를 확인하며, SQL을 안전하게 실행할 수 있도록 준비하는 것입니다.

이 책의 **필수 실습 경로**는 다음과 같습니다.

```text
로컬 PostgreSQL 서버 실행
→ DBeaver 연결
→ ai_database_book 존재 여부 확인
→ 필요한 경우 데이터베이스 생성
→ 새 데이터베이스로 다시 연결
→ 데이터베이스·스키마·search_path·읽기 전용·시간대 확인
→ setup_check.sql 실행
→ setup_validate_local.sql 통과
```

Supabase는 관리형 PostgreSQL의 구조를 이해하기 위한 **선택 읽기**입니다. Supabase 프로젝트의 기본 데이터베이스와 서비스 통합 구조는 이 책의 로컬 필수 경로와 다르므로 Chapter 04 이후의 필수 실습을 그대로 대체하는 환경으로 사용하지 않습니다.

이 장을 마치면 다음 작업을 수행할 수 있어야 합니다.

- PostgreSQL 서버와 DBeaver의 역할을 구분한다.
- Windows를 기준으로 로컬 PostgreSQL을 설치하고 실행 상태를 확인한다.
- macOS와 Ubuntu 계열 Linux의 대표 설치 경로를 설명한다.
- DBeaver에서 PostgreSQL 연결을 만든다.
- `ai_database_book`의 존재 여부를 확인한 뒤 필요한 경우 생성한다.
- 현재 데이터베이스, 스키마, 검색 경로, 읽기 전용 상태와 시간대를 확인한다.
- `public` 스키마의 존재와 사용 권한을 확인한다.
- SQL 한 문장, 선택 영역과 전체 스크립트의 실행 차이를 이해한다.
- 환경 정보를 조회하는 파일과 환경을 통과·실패로 판정하는 파일을 구분한다.
- 비밀번호와 접속 정보를 공개 파일에서 분리한다.
- 연결 오류를 유형별로 점검하고 재현 가능한 질문을 작성한다.

이 장의 완료 기준은 단순히 설치 파일을 실행한 것이 아닙니다.

```text
PostgreSQL에 연결되고,
ai_database_book에서 SQL을 실행하며,
public 스키마를 사용할 수 있고,
읽기·쓰기 가능한 연결임을 확인하고,
같은 환경 점검을 다시 재현할 수 있다.
```

---

## 1. 이 장에서 완성할 실습 환경

이 책의 기본 실습 환경은 다음과 같습니다.

```text
로컬 PostgreSQL + DBeaver Community + SQL 파일
```

GitHub와 AI 도구는 필수 설치 프로그램은 아니지만 SQL 파일의 변경 이력을 남기고 오류를 분석하는 보조 도구로 활용할 수 있습니다.

| 구성 요소 | 역할 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 처리하는 관계형 DBMS |
| DBeaver | PostgreSQL에 연결해 SQL을 작성하고 결과를 확인하는 클라이언트 |
| SQL 파일 | 실행 과정과 검증 기준을 다시 실행할 수 있게 저장하는 파일 |
| GitHub | SQL과 문서의 변경 이력을 관리하는 저장소 |
| ChatGPT·Codex | 오류 해석과 SQL·문서 초안 작성을 돕는 보조 도구 |

![전체 데이터베이스 작업 환경](../../images/chapter03/ch03_01_practice_environment_flow.svg)

그림 3-1 전체 데이터베이스 작업 환경

> **출판 기준 환경**
>
> - 기준 버전 확인일: 2026년 7월 24일
> - 운영체제 기준: Windows 11
> - PostgreSQL 기준: 18.4
> - DBeaver Community 기준: 26.1.3
> - 이 책의 SQL 호환 목표: PostgreSQL 15 이상
> - macOS·Linux와 다른 버전에서는 메뉴, 서비스 이름과 화면 배치가 달라질 수 있습니다.
>
> 공식 문서의 버전과 기능을 확인한 것과 실제 독자 환경에서 설치·연결·출판 화면을 검증한 것은 서로 다른 작업입니다.

공식 다운로드 위치는 다음과 같습니다.

- PostgreSQL: <https://www.postgresql.org/download/>
- DBeaver Community: <https://dbeaver.io/download/>

로컬 필수 경로의 통과 기준은 다음과 같습니다.

| 단계 | 통과 기준 |
| --- | --- |
| PostgreSQL 준비 | 접속 가능한 로컬 PostgreSQL 서버가 있음 |
| 서버 상태 | PostgreSQL 서비스가 실행 중임 |
| DBeaver 연결 | Test Connection이 성공함 |
| 작업 DB | `ai_database_book`에 연결함 |
| 스키마 | `public`이 존재하고 현재 사용자가 `USAGE` 권한을 가짐 |
| 읽기·쓰기 | `transaction_read_only`가 `off`임 |
| 시간대 | 현재 `TimeZone` 값을 확인함 |
| SQL 실행 | 환경 확인 SQL 결과가 표시됨 |
| 자동 판정 | `setup_validate_local.sql`이 통과함 |
| 보안 | 비밀번호와 전체 접속 URL이 공개 파일에 없음 |

---

## 2. PostgreSQL과 DBeaver의 역할 복습

PostgreSQL과 DBeaver는 같은 종류의 프로그램이 아닙니다.

| 구분 | PostgreSQL | DBeaver |
| --- | --- | --- |
| 종류 | DBMS·데이터베이스 서버 | 데이터베이스 클라이언트 |
| 주요 역할 | 데이터 저장, SQL 처리, 권한과 규칙 적용 | 서버 연결, SQL 작성, 결과 표시 |
| 데이터 보관 | 실제 데이터를 보관함 | 데이터를 직접 보관하지 않음 |
| 종료했을 때 | 서버가 중지되면 접속할 수 없음 | 프로그램만 닫히며 DB 데이터는 유지됨 |

```text
사용자
→ DBeaver에서 SQL 작성
→ PostgreSQL에 SQL 전달
→ PostgreSQL이 실행
→ DBeaver가 결과 또는 오류 표시
```

DBeaver만 설치했다고 PostgreSQL 서버가 만들어지는 것은 아닙니다. 반대로 PostgreSQL만 설치해도 `psql` 같은 명령행 클라이언트로 사용할 수 있지만, 이 책에서는 구조와 결과를 화면에서 확인하기 쉬운 DBeaver를 함께 사용합니다.

---

## 3. 로컬과 관리형 PostgreSQL

이 책의 필수 경로는 자신의 컴퓨터에 PostgreSQL을 설치하는 로컬 환경입니다.

| 방식 | 장점 | 고려할 점 |
| --- | --- | --- |
| 로컬 PostgreSQL | 인터넷 없이 사용할 수 있고 서버 구조를 이해하기 쉬움 | 설치 권한과 서비스 설정 필요 |
| 관리형 PostgreSQL | 설치 부담이 적고 여러 기기에서 접근 가능 | 인터넷, 계정, SSL, 비용과 접속 정보 관리 필요 |

![로컬 PostgreSQL과 클라우드 PostgreSQL 연결 구조](../../images/chapter03/ch03_02_local_vs_cloud_db.svg)

그림 3-2 로컬과 클라우드 PostgreSQL 연결 구조

관리형 서비스가 서버 운영의 일부를 담당하더라도 사용자의 책임이 사라지는 것은 아닙니다.

```text
플랫폼이 주로 담당
- 서버 인프라와 기본 운영 환경
- 서비스별 백업·가용성 기능
- 관리 화면과 연결 기능

사용자가 계속 담당
- 테이블과 관계 설계
- 데이터 정확성과 제약조건
- 사용자 권한과 RLS 정책
- 비밀정보와 API 키 관리
- 비용·보존 정책·실제 복구 가능성 확인
```

### 3.1 선택 읽기: Supabase에서 달라지는 점

Supabase 프로젝트에는 PostgreSQL을 단순화한 별도 DBMS가 아니라 실제 PostgreSQL 데이터베이스가 제공됩니다. Auth, Storage, Realtime과 Edge Functions 같은 기능이 PostgreSQL을 중심으로 연결됩니다.

```text
Supabase 프로젝트
├── PostgreSQL
│   ├── 업무 테이블과 SQL
│   ├── Auth 관련 정보
│   ├── Realtime 연동 정보
│   └── Storage 파일 메타데이터와 RLS 정책
└── 객체 저장소
    └── 실제 이미지·문서·영상 객체
```

Storage 메타데이터는 SQL로 조회할 수 있지만 `storage` 스키마의 레코드는 읽기 전용으로 취급합니다. 파일 업로드·복사·이동·삭제는 Storage API를 사용해야 하며, 메타데이터 행만 직접 삭제하면 실제 객체가 남을 수 있습니다.

Supabase의 대표 연결 방식은 다음과 같습니다.

| 연결 방식 | 일반 포트 | 적합한 용도 |
| --- | ---: | --- |
| Direct connection | `5432` | GUI, 마이그레이션, `pg_dump`, 장기 백엔드 연결 |
| Shared Session pooler | `5432` | IPv4 전용 네트워크의 지속 연결 |
| Shared Transaction pooler | `6543` | 서버리스·Edge 같은 짧은 연결 |

Direct endpoint는 기본적으로 IPv6이며 IPv4 add-on이 있는 프로젝트는 IPv4를 사용할 수 있습니다. IPv4 전용 네트워크에서는 Session pooler를 확인합니다. Transaction pooler는 prepared statement를 지원하지 않으므로 일반적인 DBeaver 편집 세션보다 서버리스·단기 애플리케이션 연결에 적합합니다.

API 키는 다음처럼 구분합니다.

```text
publishable key
→ 브라우저·모바일·배포되는 클라이언트에서 사용 가능
→ 사용자 인증과 RLS 정책이 함께 필요

secret key
→ 신뢰할 수 있는 서버에서만 사용
→ 전체 데이터 접근 권한을 가지며 RLS를 우회

anon / service_role
→ 레거시 JWT 기반 키
→ 2026년 말 사용 중단 예정이므로 새 키로 전환
```

`secret key`, `service_role`, 전체 PostgreSQL 접속 문자열은 브라우저, 공개 저장소, 화면 캡처와 AI 질문에 포함하지 않습니다.

Supabase는 선택 읽기입니다. 로컬 필수 경로에서는 `ai_database_book`을 사용하지만 Supabase 프로젝트의 기본 데이터베이스는 일반적으로 `postgres`이므로 `current_database()` 결과가 같을 필요는 없습니다. 연결·키·RLS 활동은 워크북에서 별도로 확인합니다.

---

## 4. 설치 전에 확인할 사항

| 항목 | 확인 내용 |
| --- | --- |
| 운영체제 | Windows, macOS, Linux 중 현재 환경 확인 |
| 설치 권한 | 프로그램과 서비스를 설치할 수 있는지 확인 |
| 인터넷 연결 | 설치 파일과 DBeaver 드라이버 다운로드 가능 여부 |
| 기본 포트 | 일반적으로 PostgreSQL은 `5432` 사용 |
| 관리자 사용자 | Windows 일반 설치 프로그램에서는 `postgres` 사용 |
| 비밀번호 | 안전한 비밀번호 관리 도구에 보관 |
| 보안 정책 | 회사·학교 네트워크의 접속 제한 여부 확인 |

`postgres`라는 이름은 사용자와 데이터베이스에 모두 나타날 수 있습니다.

```text
postgres 사용자
→ PostgreSQL에 로그인하는 관리자 역할

postgres 데이터베이스
→ 설치 시 일반적으로 생성되는 기본 데이터베이스
```

> **관리자 계정 사용 범위**
>
> 이 책에서는 개인 컴퓨터의 가상 데이터로 로컬 학습 환경을 구성하기 위해 `postgres` 관리자 계정을 사용할 수 있습니다. 실제 애플리케이션·공용 서버·운영 데이터베이스에서는 관리자 계정을 애플리케이션 연결에 사용하지 않고 최소 권한 전용 역할을 사용합니다. 역할과 권한은 Chapter 11에서 다룹니다.

> **보안 주의**
>
> 비밀번호, 전체 접속 URL, 실제 password file, API Key와 Access Token은 SQL 파일, README, 공개 GitHub, 화면 캡처와 AI 질문에 넣지 않습니다.

---

## 5. PostgreSQL 설치와 서버 실행 확인

설치 화면과 세부 옵션은 운영체제와 버전에 따라 달라질 수 있습니다. 버튼 위치를 외우기보다 무엇을 설정하고 어떤 결과를 확인하는지 이해하는 것이 중요합니다.

### 5.1 Windows

```text
1. 공식 PostgreSQL 다운로드 페이지에서 Windows를 선택한다.
2. 안내되는 설치 프로그램을 내려받아 실행한다.
3. PostgreSQL Server와 명령행 도구를 설치한다.
4. postgres 사용자 비밀번호를 설정한다.
5. 특별한 충돌이 없으면 포트 5432를 사용한다.
6. 설치를 완료한다.
7. Windows 서비스에서 PostgreSQL 서비스가 실행 중인지 확인한다.
```

| 항목 | 일반적인 값 |
| --- | --- |
| 관리자 사용자 | `postgres` |
| 포트 | `5432` |
| 초기 데이터베이스 | `postgres` |
| 비밀번호 | 설치 과정에서 사용자가 직접 설정 |

설치 마지막에 Stack Builder 실행을 제안할 수 있습니다. 이 책의 기본 실습에는 추가 패키지 설치가 필요하지 않으므로 PostgreSQL Server와 명령행 도구가 설치되고 서비스가 실행되면 기본 준비가 완료됩니다.

### 5.2 macOS

공식 설치 프로그램, Homebrew 또는 Postgres.app을 사용할 수 있습니다. 설치 방식에 따라 초기 사용자, 서버 시작 방법과 파일 위치가 다르므로 실제 설치 도구의 안내를 기준으로 Host, Port, Database와 Username을 확인합니다.

### 5.3 Ubuntu 계열 Linux

기본 서버 설치는 다음처럼 진행할 수 있습니다.

```bash
sudo apt update
sudo apt install postgresql
sudo systemctl status postgresql
```

추가 확장이 필요하면 `postgresql-contrib`를 함께 설치할 수 있지만 Chapter 03의 연결과 기본 SQL 실행에는 필수가 아닙니다. Ubuntu 기본 저장소의 PostgreSQL 버전은 운영체제 버전에 따라 달라질 수 있습니다.

서비스가 중지되어 있다면 다음 명령으로 시작할 수 있습니다.

```bash
sudo systemctl start postgresql
```

Linux 패키지는 운영체제 사용자와 PostgreSQL 역할의 초기 구성이 Windows 설치 프로그램과 다를 수 있으므로 DBeaver 연결 전에 실제 사용자와 인증 방식을 확인합니다.

### 5.4 `psql` 버전 확인은 선택 사항

```bash
psql --version
```

명령이 인식되지 않아도 서버 설치가 반드시 실패한 것은 아닙니다. 실행 파일 경로가 환경변수에 등록되지 않았을 수 있으며 이 책의 기본 실습은 DBeaver 연결로 진행할 수 있습니다.

운영체제와 설치 방식이 달라도 완료 기준은 같습니다.

```text
PostgreSQL 서버가 실행된다.
DBeaver Test Connection이 성공한다.
SQL을 실행할 수 있다.
```

---

## 6. DBeaver 설치와 연결 만들기

DBeaver Community Edition으로 이 책의 실습을 진행할 수 있습니다.

```text
1. 공식 DBeaver 다운로드 페이지에서 운영체제용 Community 설치 파일을 받는다.
2. 설치 프로그램을 실행한다.
3. DBeaver를 시작한다.
4. 새 데이터베이스 연결에서 PostgreSQL을 선택한다.
5. JDBC 드라이버 다운로드 안내가 나타나면 내려받는다.
6. 연결 정보를 입력하고 Test Connection을 실행한다.
```

로컬 Windows 환경의 일반적인 연결값은 다음과 같습니다.

| 연결 항목 | 일반적인 값 | 의미 |
| --- | --- | --- |
| Host | `localhost` | PostgreSQL 서버가 실행되는 컴퓨터 |
| Port | `5432` | PostgreSQL이 연결을 기다리는 통신 번호 |
| Database | `postgres` | 처음 접속할 데이터베이스 |
| Username | `postgres` | 초기 환경 구성에 사용하는 접속 사용자 |
| Password | 설치 시 설정한 값 | 사용자 인증 정보 |

![DBeaver에서 PostgreSQL 연결하기](../../images/chapter03/ch03_03_dbeaver_connection_flow.svg)

그림 3-3 DBeaver에서 PostgreSQL 연결하기

Test Connection 성공은 서버 도달, 사용자 인증과 지정 데이터베이스 접속 가능 여부를 확인합니다. 이후 SQL이 올바른 데이터베이스에서 실행된다는 보장은 아니므로 SQL 편집기를 열 때마다 현재 연결 대상을 확인합니다.

공용 PC에서는 비밀번호 저장 기능을 사용하지 않습니다. DBeaver 연결 설정을 내보낸 파일이나 화면 캡처에도 실제 Host·Username·Password가 노출될 수 있으므로 공개 저장소에 넣지 않습니다.

---

## 7. 작업용 데이터베이스 만들기

이 책의 로컬 필수 경로에서 사용할 데이터베이스 이름은 `ai_database_book`입니다.

### 7.1 먼저 존재 여부 확인하기

기본 `postgres` 데이터베이스에 연결된 SQL 편집기에서 다음 조회문을 실행합니다.

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS database_owner
FROM pg_database
WHERE datname = 'ai_database_book';
```

결과가 0행이면 아직 데이터베이스가 없습니다. 한 행이 나오면 기존 데이터베이스의 소유자와 사용 목적을 확인합니다.

```text
기존 DB를 계속 사용
→ 소유자·스키마·객체 상태 확인

새 학습 환경 사용
→ 다른 이름의 새 데이터베이스 생성

초기화 필요
→ 백업 여부와 삭제 대상을 확인한 뒤 별도 초기화 절차 사용
```

이 장에서는 자동 `DROP DATABASE`를 안내하지 않습니다.

### 7.2 필요한 경우 생성하기

다음 문장만 선택해 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

필요 조건:

```text
CREATE DATABASE 권한이 있는 사용자
트랜잭션 블록 밖
같은 이름의 데이터베이스가 없음
```

DBeaver에서 현재 연결의 Auto-commit 상태를 확인하고 해당 문장만 Statement 실행합니다. SQL 편집기 상단의 트랜잭션·자동 커밋 표시나 연결 속성의 Commit mode를 확인합니다. 화면 위치는 버전에 따라 다를 수 있습니다.

> 이 예제는 개인 컴퓨터의 로컬 학습 환경을 위한 것입니다. 운영 서버나 공동 데이터베이스에서 관리자 계정으로 그대로 실행하지 않습니다.

대표 오류:

```text
CREATE DATABASE cannot run inside a transaction block
permission denied to create database
database "ai_database_book" already exists
```

오류가 나타나면 트랜잭션 상태, 권한과 기존 객체를 먼저 확인합니다.

---

## 8. 새 데이터베이스로 다시 연결하기

`CREATE DATABASE`가 성공해도 기존 SQL 편집기의 연결 대상이 자동으로 바뀌지는 않습니다.

```text
ai_database_book 생성
→ DBeaver 연결 새로고침
→ ai_database_book 전용 연결 생성 또는 연결 설정 수정
→ 새 SQL 편집기 열기
→ current_database() 확인
```

목록에 보이지 않으면 연결 새로고침, Host 방식 연결의 `Show all databases`, Navigator 필터와 데이터베이스 전용 연결을 확인합니다. URL 방식 연결에서는 `Show all databases`가 동작하지 않을 수 있습니다.

---

## 9. 현재 데이터베이스·스키마·검색 경로 확인하기

새 SQL 편집기에서 다음 SQL을 실행합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

로컬 필수 경로의 일반적인 결과는 다음과 같습니다.

```text
current_database = ai_database_book
current_schema   = public일 수 있음
search_path      = "$user", public과 유사한 값
```

`current_schema()`는 `search_path`에서 실제로 사용할 수 있는 첫 번째 스키마를 반환합니다. 사용자 이름과 같은 스키마가 존재하면 `public`이 아닐 수 있습니다.

따라서 이 책의 완료 기준은 다음과 같습니다.

```text
current_database() = ai_database_book
public 스키마가 존재함
현재 사용자가 public에 USAGE 권한을 가짐
search_path 결과의 의미를 설명할 수 있음
```

Chapter 04에서는 대상이 분명하도록 `public.students`처럼 스키마를 명시한 이름을 사용합니다.

DBeaver의 Database Navigator에서는 일반적으로 다음 위치를 찾습니다.

```text
PostgreSQL 연결
→ ai_database_book
→ Schemas
→ public
→ Tables
```

Chapter 04 전에는 `Tables` 아래가 비어 있어도 정상입니다.

---

## 10. SQL 실행 범위와 자동 커밋

DBeaver에서는 실행 범위를 구분해야 합니다.

```text
Statement 실행
→ 커서가 있는 현재 SQL 문장

선택 영역 실행
→ 선택한 SQL만 실행

Script 실행
→ 편집기 또는 파일의 여러 문장 실행
```

단축키는 운영체제와 설정에 따라 달라질 수 있으므로 기능 이름과 실제 선택 범위를 확인합니다.

전체 Script 실행이 자동으로 하나의 트랜잭션이 되는 것은 아닙니다. Auto-commit 모드에서는 각 변경 문장이 즉시 확정될 수 있고, Manual commit 모드에서는 명시적으로 Commit 또는 Rollback해야 할 수 있습니다.

Chapter 09에서 트랜잭션을 배우기 전까지 변경 SQL은 한 문장 또는 확인한 선택 영역 단위로 실행합니다. 실행 전에는 다음을 확인합니다.

```text
현재 연결
실행 범위
Auto-commit 또는 Manual commit
변경 SQL 포함 여부
오류 발생 시 중지·계속 실행 설정
```

---

## 11. 환경 정보 조회 파일 실행하기

`code/chapter03/setup_check.sql`은 환경 정보를 사람이 읽고 기록하기 위한 조회 파일입니다. 다음 정보를 확인합니다.

```sql
SELECT version();
SELECT current_database();
SELECT current_schema();
SHOW search_path;
SELECT current_user;
SHOW transaction_read_only;
SHOW TimeZone;
SELECT CURRENT_TIMESTAMP AS checked_at;
SELECT 1 + 1 AS result;
```

마지막에는 핵심 정보를 한 행으로 요약합니다.

```sql
SELECT
    current_database() AS database_name,
    current_schema() AS current_schema_name,
    current_user AS user_name,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('TimeZone') AS timezone,
    current_database() = 'ai_database_book' AS database_ok,
    to_regnamespace('public') IS NOT NULL AS public_schema_exists,
    has_schema_privilege(current_user, 'public', 'USAGE')
        AS public_schema_usage_ok;
```

![SQL로 실습 환경 확인하기](../../images/chapter03/ch03_04_sql_execution_check_flow.svg)

그림 3-4 SQL로 실습 환경 확인하기

판정 수준은 다음처럼 구분합니다.

| 항목 | 필수 판정 | 참고 정보 |
| --- | --- | --- |
| 현재 DB | `ai_database_book` | 없음 |
| `public` | 존재하고 사용 가능 | 현재 스키마는 다를 수 있음 |
| 읽기 전용 | `off` | 관리형 복제본은 다를 수 있음 |
| `search_path` | 결과를 읽고 설명 | 환경별 차이 가능 |
| 현재 사용자 | 예상한 계정 | 이름은 환경별 다름 |
| 시간대 | 값 확인 | 지역과 설정에 따라 다름 |
| 계산 | `2` | SQL 실행 확인 |

`CURRENT_TIMESTAMP`는 같은 트랜잭션 안에서 트랜잭션 시작 시각을 반환합니다. 이 장에서는 날짜·시간 값이 정상적으로 반환되는지 확인하는 보조 정보로 사용합니다.

---

## 12. 로컬 환경 자동 검증 파일 실행하기

`setup_check.sql`은 정보를 보여 주지만 잘못된 환경을 자동으로 중단하지 않습니다. 다음 파일은 로컬 필수 경로를 통과·실패로 판정합니다.

```text
code/chapter03/setup_validate_local.sql
```

이 파일은 다음을 검사합니다.

```text
PostgreSQL 15 이상
current_database() = ai_database_book
현재 사용자의 CONNECT 권한
public 스키마 존재
public 스키마 USAGE 권한
transaction_read_only = off
계산 결과 = 2
```

모두 통과하면 다음 메시지를 출력합니다.

```text
Chapter 03 local environment validation passed
```

하나라도 다르면 예외를 발생시키므로 다음 장으로 이동하기 전에 연결과 권한을 다시 확인할 수 있습니다.

![setup_check.sql 실행과 재실행 흐름](../../images/chapter03/ch03_05_setup_check_sql_flow.svg)

그림 3-5 환경 조회와 자동 판정 흐름

두 파일은 테이블이나 데이터를 생성·수정·삭제하지 않으므로 여러 번 실행할 수 있습니다.

---

## 13. 접속 정보와 비밀정보 보호하기

PostgreSQL 명령행 도구와 Python 실습의 접속 정보는 책 전체에서 libpq 표준 변수 형식을 사용합니다.

```text
PGHOST=localhost
PGPORT=5432
PGDATABASE=ai_database_book
PGUSER=your_database_user
PGPASSFILE=path_to_password_file
```

실제 비밀번호는 `.env`에 직접 넣는 방식보다 password file에 보관하는 것을 기본으로 합니다. password file 자체와 실제 `.env`는 저장소에 포함하지 않습니다.

```gitignore
.env
.env.local
*.pgpass
pgpass.conf
```

Windows에서는 libpq password file을 일반적으로 `%APPDATA%\postgresql\pgpass.conf`, macOS·Linux에서는 `~/.pgpass`에 둘 수 있습니다. 파일 형식과 권한은 Chapter 11에서 자세히 다룹니다.

공개된 비밀정보는 파일에서 지우는 것만으로 충분하지 않습니다. 해당 비밀번호·키를 즉시 폐기하거나 변경하고 필요한 경우 저장소 기록에서도 제거합니다.

---

## 14. 연결 오류를 유형별로 해결하기

| 증상 또는 메시지 | 우선 확인할 내용 |
| --- | --- |
| Connection refused | PostgreSQL 서비스, Host, Port, 방화벽 |
| Password authentication failed | Username과 Password |
| Database does not exist | 데이터베이스 이름과 생성 여부 |
| Permission denied to create database | 접속 사용자와 `CREATEDB` 권한 |
| Cannot run inside a transaction block | Auto-commit, 열린 트랜잭션과 실행 범위 |
| 테이블·DB가 보이지 않음 | Database, Schema, 필터, 새로고침 |
| SSL·Host 오류 | SSL 설정, DNS와 네트워크 |
| 클라우드 직접 연결 시간 초과 | IPv4·IPv6와 Session pooler |

![데이터베이스 오류 해결 기본 흐름](../../images/chapter03/ch03_06_error_troubleshooting_flow.svg)

그림 3-6 데이터베이스 오류 해결 기본 흐름

공통 해결 순서:

```text
1. 실행하려던 작업을 한 문장으로 정리한다.
2. 오류 메시지를 생략하지 않고 읽는다.
3. Host·Port·Database·Username과 연결 방식을 확인한다.
4. 서버·네트워크·인증·권한·DB·스키마·트랜잭션·SQL로 분류한다.
5. 한 번에 하나의 설정만 바꾼다.
6. 같은 작업을 다시 실행한다.
7. 해결 방법과 실제 결과를 기록한다.
```

Chapter 04 이후 테이블이 보이지 않으면 먼저 다음 SQL을 실행합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

---

## 15. AI에게 오류를 재현 가능한 형태로 질문하기

다음 질문은 정보가 부족합니다.

```text
DBeaver가 안 됩니다. 해결해 주세요.
```

다음 형식을 사용합니다.

```text
운영체제:
PostgreSQL 사용 방식: 로컬 / 관리형
PostgreSQL 버전:
DBeaver 버전:

연결 방식: Host / URL / Direct / Session pooler / Transaction pooler
연결값:
- Host: 일부 마스킹
- Port:
- Database:
- Username: 필요하면 일부 마스킹

실행한 작업:
발생한 오류 메시지:
이미 확인한 내용:
Auto-commit 또는 Manual commit 상태:

비밀번호, 전체 접속 URL, API key와 Access Token은 제외했습니다.
가능한 원인을 우선순위대로 설명하고,
각 원인을 안전하게 확인하는 방법을 알려 주세요.
```

AI 답변은 다음 기준으로 검토합니다.

```text
현재 운영체제와 설치 방식에 맞는가?
로컬과 관리형 연결 방식을 섞지 않았는가?
삭제·초기화·권한 변경 명령이 포함되어 있는가?
각 명령의 목적과 대상을 이해할 수 있는가?
한 번에 하나씩 실행하고 결과를 확인할 수 있는가?
비밀정보를 다시 입력하라고 요구하지 않는가?
```

최종 판단은 AI 설명이 아니라 실제 DBeaver 재실행 결과로 내립니다.

---

## 16. 실습 환경 완료 점검

| 점검 항목 | 완료 기준 |
| --- | --- |
| PostgreSQL 서버 | 로컬 PostgreSQL 서비스가 실행 중임 |
| DBeaver | Test Connection 성공 |
| 작업 DB | `ai_database_book` 연결 완료 |
| 현재 데이터베이스 | `current_database()` 결과가 `ai_database_book` |
| `public` | 스키마 존재 및 현재 사용자 `USAGE` 권한 |
| 검색 경로 | `SHOW search_path` 결과를 확인하고 의미를 설명함 |
| 읽기·쓰기 | `transaction_read_only = off` |
| 시간대 | `TimeZone` 값을 확인함 |
| 조회 파일 | `setup_check.sql` 저장·재실행 완료 |
| 자동 검증 | `setup_validate_local.sql` 통과 |
| 비밀정보 | SQL·README·GitHub·화면 캡처에 없음 |
| 오류 기록 | 발생한 문제와 해결 결과 기록 |

환경 확인 기록 예시:

```markdown
## PostgreSQL 실습 환경 확인 기록

- 운영체제:
- PostgreSQL 버전:
- DBeaver 버전:
- 연결 테스트 결과:
- 현재 데이터베이스:
- 현재 스키마:
- search_path:
- transaction_read_only:
- TimeZone:
- 현재 사용자:
- setup_check.sql 결과:
- setup_validate_local.sql 결과:
- Auto-commit 상태:
- 발생한 문제:
- 해결 방법:
```

---

## 17. 자주 하는 실수

### 실수 1. DBeaver만 설치하면 데이터베이스가 준비됐다고 생각한다

DBeaver는 클라이언트입니다. 연결할 PostgreSQL 서버가 별도로 필요합니다.

### 실수 2. `postgres` 사용자와 데이터베이스를 같은 것으로 생각한다

하나는 로그인 역할이고 다른 하나는 데이터베이스입니다.

### 실수 3. 데이터베이스를 만든 뒤 기존 편집기에서 계속 실행한다

새 데이터베이스를 만들어도 연결 대상은 자동으로 바뀌지 않습니다.

### 실수 4. `current_schema() = public`을 모든 환경의 절대 조건으로 생각한다

현재 스키마는 검색 경로와 존재하는 스키마에 따라 달라질 수 있습니다. `public`의 존재와 사용 권한을 별도로 확인합니다.

### 실수 5. Test Connection 성공을 쓰기 권한까지 확인한 것으로 생각한다

읽기 전용 연결일 수 있으므로 `transaction_read_only`를 확인합니다.

### 실수 6. 여러 변경 SQL을 의도하지 않게 Script 실행한다

현재 문장, 선택 영역, Script와 Auto-commit 상태를 구분합니다.

### 실수 7. 기존 데이터베이스가 있으면 상태를 보지 않고 사용한다

소유자와 기존 스키마·객체를 먼저 확인합니다.

### 실수 8. 관리자 계정을 실제 애플리케이션에 사용한다

관리자 계정은 로컬 학습 초기 구성에 한정하고 운영에서는 최소 권한 역할을 사용합니다.

### 실수 9. 비밀번호와 접속 URL을 파일이나 AI 질문에 넣는다

password file과 비밀 관리 도구를 사용하고 공개 자료에서는 실제 값을 제거합니다.

### 실수 10. 환경 조회 파일을 자동 완료 게이트로 생각한다

`setup_check.sql`은 정보를 보여 주고 `setup_validate_local.sql`은 필수 조건을 자동 판정합니다.

---

## 18. 핵심 정리

| 개념 | 핵심 내용 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 처리하는 관계형 DBMS |
| DBeaver | PostgreSQL에 연결해 SQL과 결과를 확인하는 클라이언트 |
| 로컬 필수 경로 | `ai_database_book`을 생성해 진행하는 기본 실습 환경 |
| 관리형 PostgreSQL | 서버 운영 부담의 일부를 플랫폼이 담당하는 원격 PostgreSQL |
| Supabase | PostgreSQL과 Auth·Storage·Realtime 등을 연결한 선택형 플랫폼 |
| Host·Port·Database·Username | PostgreSQL 연결 대상을 구성하는 값 |
| `search_path` | 스키마 이름을 생략했을 때 객체를 찾는 순서 |
| `current_schema()` | 검색 경로에서 실제로 사용할 수 있는 첫 스키마 |
| `transaction_read_only` | 현재 트랜잭션의 읽기 전용 여부 |
| `TimeZone` | 날짜·시간 해석에 사용하는 세션 시간대 |
| Auto-commit | 변경 문장을 실행 후 언제 확정하는지 결정하는 모드 |
| `setup_check.sql` | 환경 정보를 조회하고 기록하는 재실행 가능한 파일 |
| `setup_validate_local.sql` | 로컬 필수 조건을 예외 기반으로 판정하는 파일 |
| `PGPASSFILE` | 비밀번호를 SQL과 공개 환경 변수에서 분리하는 password file 위치 |

```text
데이터베이스 실습은 설치에서 끝나는 것이 아니라,
올바른 데이터베이스와 스키마에 연결하고
읽기·쓰기 가능 여부와 실행 결과를 검증해
같은 상태를 다시 재현할 수 있을 때 시작된다.
```

---

## 19. 다음 장에서는

다음 장에서는 로컬 필수 경로로 준비한 `ai_database_book`의 `public` 스키마에서 첫 번째 테이블을 만들고 데이터를 직접 다룹니다.

```text
CREATE TABLE로 테이블 만들기
INSERT로 데이터 추가하기
SELECT로 데이터 조회하기
WHERE로 조건 검색하기
ORDER BY로 정렬하기
UPDATE로 값 수정하기
DELETE와 상태 기반 삭제 구분하기
AI가 만든 기본 SQL 검토하기
```

Chapter 03의 두 SQL 파일은 환경 확인 전용으로 유지하고 Chapter 04의 테이블과 CRUD 실습은 별도 파일에서 진행합니다.