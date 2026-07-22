# Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기

---

## 이 장에서 살펴볼 내용

Chapter 02에서는 사용자, DBeaver, PostgreSQL, 데이터베이스, 스키마와 테이블이 어떤 구조로 연결되는지 살펴보았습니다. 이제 그 구조를 실제 환경에서 확인합니다.

이 장의 목적은 여러 SQL 기능을 미리 배우는 것이 아닙니다. 다음 장부터 사용할 PostgreSQL 환경을 정확하게 연결하고, 현재 데이터베이스와 스키마를 확인하며, SQL을 안전하게 실행할 수 있도록 준비하는 것입니다.

이 책의 **필수 실습 경로**는 다음과 같습니다.

```text
로컬 PostgreSQL 서버 실행
→ DBeaver 연결
→ ai_database_book 데이터베이스 생성
→ 새 데이터베이스로 다시 연결
→ 현재 데이터베이스·스키마·search_path 확인
→ SQL 실행 결과 확인
→ setup_check.sql 저장과 재실행
```

Supabase는 관리형 PostgreSQL의 구조를 이해하기 위한 **선택 읽기**입니다. Supabase 프로젝트의 기본 데이터베이스는 이 책의 로컬 필수 경로와 구성이 다르므로, Chapter 04 이후의 필수 실습을 그대로 대체하는 환경으로 사용하지 않습니다.

이 장을 마치면 다음 작업을 수행할 수 있어야 합니다.

- PostgreSQL 서버와 DBeaver의 역할을 구분한다.
- Windows를 기준으로 로컬 PostgreSQL을 설치하고 실행 상태를 확인한다.
- macOS와 Ubuntu 계열 Linux의 대표 설치 경로를 설명한다.
- 로컬 PostgreSQL과 관리형 PostgreSQL의 차이를 설명한다.
- Supabase가 PostgreSQL을 중심으로 제공되는 관리형 백엔드 플랫폼임을 설명한다.
- DBeaver에서 PostgreSQL 연결을 만든다.
- `ai_database_book` 데이터베이스를 생성한다.
- 현재 연결된 데이터베이스, 스키마와 검색 경로를 SQL로 확인한다.
- DBeaver에서 `public` 스키마와 테이블 위치를 찾는다.
- SQL 한 문장, 선택 영역과 전체 스크립트의 실행 차이를 이해한다.
- 비밀번호와 접속 정보를 공개 파일에서 분리한다.
- 연결 오류를 유형별로 점검하고 재현 가능한 질문을 작성한다.

이 장의 완료 기준은 다음과 같습니다.

```text
설치 파일을 실행했다
```

가 아니라,

```text
PostgreSQL에 연결되고,
올바른 데이터베이스와 스키마에서 SQL을 실행하며,
결과와 오류를 직접 확인하고 같은 점검을 다시 재현할 수 있다.
```

---

## 1. 이 장에서 완성할 실습 환경

이 책의 기본 실습 환경은 다음과 같습니다.

```text
로컬 PostgreSQL + DBeaver Community + SQL 파일
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

> **원고 최종 검증 기준(2026년 7월)**
>
> - 운영체제: Windows 11
> - PostgreSQL: 18.4
> - DBeaver Community: 26.1.3
> - 이 책의 SQL은 PostgreSQL 15 이상에서도 사용할 수 있도록 작성합니다.
> - macOS·Linux와 다른 버전에서는 메뉴, 서비스 이름과 화면 배치가 달라질 수 있습니다.

공식 다운로드 위치는 다음과 같습니다.

- PostgreSQL: <https://www.postgresql.org/download/>
- DBeaver Community: <https://dbeaver.io/download/>

이 장의 로컬 필수 경로 체크리스트는 다음과 같습니다.

| 단계 | 통과 기준 |
| --- | --- |
| PostgreSQL 준비 | 접속 가능한 로컬 PostgreSQL 서버가 있음 |
| 서버 상태 | PostgreSQL 서비스가 실행 중임 |
| DBeaver 연결 | Test Connection이 성공함 |
| 작업 DB | `ai_database_book`을 생성하고 그 데이터베이스에 연결함 |
| 스키마 | `current_schema()`와 `SHOW search_path` 결과를 확인함 |
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

이 책의 필수 경로는 자신의 컴퓨터에 PostgreSQL을 설치하는 로컬 환경입니다.

| 방식 | 장점 | 고려할 점 |
| --- | --- | --- |
| 로컬 PostgreSQL | 인터넷 없이 사용 가능하고 서버 구조를 이해하기 쉬움 | 설치 권한과 서비스 설정이 필요함 |
| 관리형 PostgreSQL | 설치 부담이 적고 여러 기기에서 접속 가능 | 인터넷, 계정, SSL, 비용과 접속 정보 관리가 필요함 |

![로컬 PostgreSQL과 클라우드 PostgreSQL 연결 구조](../../images/chapter03/ch03_02_local_vs_cloud_db.svg)

그림 3-2 로컬과 클라우드 PostgreSQL 연결 구조

다음 상황에서는 일반적인 관리형 PostgreSQL을 별도 대안으로 검토할 수 있습니다.

- 회사나 공용 컴퓨터라 설치 권한이 없다.
- 운영체제별 설치 문제를 피하고 싶다.
- 여러 기기에서 같은 데이터베이스를 사용해야 한다.
- 이후 웹 서비스와 연결할 원격 데이터베이스가 필요하다.

PostgreSQL 접속에 필요한 Host, Port, Database, Username과 SQL 문법은 비슷하지만, 데이터베이스 생성 권한과 운영 정책은 서비스마다 다릅니다. 이 책의 필수 실습과 오류 설명은 로컬 PostgreSQL을 기준으로 합니다.

관리형 서비스가 서버 운영의 일부를 담당하더라도 사용자의 책임이 사라지는 것은 아닙니다.

```text
플랫폼이 주로 담당하는 영역
- 서버 인프라와 기본 운영 환경
- 서비스별 백업·가용성 기능
- 관리 화면과 연결 기능

사용자가 계속 담당하는 영역
- 테이블과 관계 설계
- 데이터 정확성과 제약조건
- 사용자 권한과 RLS 정책
- 비밀정보와 API 키 관리
- 비용, 보존 정책과 실제 복구 가능성 점검
```

### 3.1 관리형 PostgreSQL의 예: Supabase

Supabase는 PostgreSQL을 클라우드에서 사용할 수 있도록 제공하면서 인증, 파일 저장소, 실시간 데이터 전달과 서버 측 함수 같은 기능을 함께 제공하는 백엔드 플랫폼입니다. Supabase 프로젝트에는 PostgreSQL을 단순화한 별도 DBMS가 아니라 실제 PostgreSQL 데이터베이스가 제공됩니다.

따라서 이 책에서 배우는 다음 개념은 Supabase의 데이터베이스에도 적용할 수 있습니다.

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
Supabase 프로젝트
├── PostgreSQL
│   ├── 업무 테이블과 SQL
│   ├── Auth 관련 사용자 정보
│   ├── Realtime 연동 정보
│   └── Storage 파일 메타데이터와 RLS 정책
└── 객체 저장소
    └── 실제 이미지·문서·영상 파일
```

Storage의 파일 이름, 경로와 접근 정책 같은 메타데이터는 PostgreSQL과 연결되지만 실제 대용량 파일 객체는 객체 저장소에 보관됩니다. 따라서 Supabase Storage를 PostgreSQL 테이블에 모든 파일 자체를 직접 저장하는 기능으로 이해해서는 안 됩니다.

| 구분 | 로컬 PostgreSQL | Supabase |
| --- | --- | --- |
| 서버 준비 | 사용자가 직접 설치 | 클라우드 프로젝트 생성 |
| 서버 관리 | 사용자가 서비스와 설정 관리 | 플랫폼이 기본 운영 환경 관리 |
| SQL 실행 | DBeaver·psql | DBeaver·SQL Editor 등 |
| 외부 연결 | 직접 접속과 별도 애플리케이션 구성 | PostgreSQL 연결과 Data API 제공 |
| 추가 기능 | 필요한 기능을 별도로 구성 | Auth·Storage·Realtime·Edge Functions 제공 |
| 주요 보안 항목 | DB 사용자와 비밀번호 관리 | 접속 정보·API 키·RLS 정책 관리 |

Supabase 프로젝트의 `Connect` 화면에서는 여러 연결 방식을 제공합니다.

| 연결 방식 | 일반적인 포트 | 주된 용도 |
| --- | ---: | --- |
| Direct connection | `5432` | 데이터베이스 관리 도구, 마이그레이션과 장시간 연결 |
| Session pooler | `5432` | IPv4 전용 네트워크의 지속적인 클라이언트 연결 |
| Transaction pooler | `6543` | 서버리스·Edge Function 같은 짧은 연결 |

DBeaver에는 프로젝트의 `Connect` 화면에 표시되는 Direct connection 정보를 우선 사용할 수 있습니다. Direct connection 주소가 IPv6이고 현재 네트워크가 IPv4만 지원한다면 Session pooler를 확인합니다. Transaction pooler는 일반적인 DBeaver 편집 세션보다 서버리스 애플리케이션에 더 적합합니다.

> **Supabase 보안 주의**
>
> 브라우저나 모바일 앱에서 데이터에 접근하도록 구성할 때는 Row Level Security(RLS) 정책을 함께 검토해야 합니다.
>
> - 클라이언트에는 `publishable key`만 사용합니다.
> - `secret key`는 서버 환경에서만 보관합니다.
> - 기존 프로젝트에서는 레거시 이름인 `anon`, `service_role` 키가 보일 수 있습니다.
> - `secret key`와 `service_role`은 권한이 강하고 RLS를 우회할 수 있으므로 브라우저, 공개 저장소와 AI 질문에 포함하지 않습니다.
> - 전체 PostgreSQL 접속 문자열도 공개하지 않습니다.

Supabase는 이 책의 필수 실습 환경이 아닙니다. 이 책의 필수 경로는 로컬 PostgreSQL에서 `ai_database_book` 데이터베이스를 생성하는 방식입니다. Supabase를 사용할 때는 프로젝트의 기본 `postgres` 데이터베이스와 Supabase 서비스 통합 구조를 따르며, `current_database()` 결과가 로컬 경로와 다를 수 있습니다.

---

## 4. 설치 전에 확인할 사항

설치 전에 다음 내용을 확인합니다.

| 항목 | 확인 내용 |
| --- | --- |
| 운영체제 | Windows, macOS, Linux 중 현재 환경 확인 |
| 설치 권한 | 프로그램과 서비스를 설치할 수 있는지 확인 |
| 인터넷 연결 | 설치 파일과 DBeaver 드라이버를 내려받을 수 있는지 확인 |
| 기본 포트 | 일반적으로 PostgreSQL은 `5432` 사용 |
| 관리자 사용자 | Windows의 일반적인 설치 프로그램에서는 `postgres` 사용 |
| 비밀번호 | 설치 중 설정한 값을 안전한 관리 도구에 보관 |
| 보안 정책 | 회사·학교 네트워크의 접속 제한 여부 확인 |

여기서 `postgres`라는 이름은 두 곳에 등장할 수 있습니다.

```text
postgres 사용자: PostgreSQL에 접속하는 관리자 계정
postgres 데이터베이스: 설치 시 기본으로 만들어지는 데이터베이스
```

같은 이름을 사용하지만 하나는 사용자이고 다른 하나는 데이터베이스입니다.

Windows의 일반적인 설치 프로그램에서는 `postgres` 관리 사용자를 사용합니다. macOS·Linux 패키지나 관리형 PostgreSQL에서는 관리자 사용자 이름이 다를 수 있으므로 설치 방식이나 서비스 제공자의 접속 정보를 따릅니다.

`postgres` 같은 관리자 계정은 초기 로컬 환경 구성에 사용합니다. 실제 애플리케이션에서는 필요한 권한만 가진 별도 사용자를 사용하는 것이 원칙입니다. 사용자와 권한은 Chapter 11에서 다룹니다.

> **보안 주의**
>
> 비밀번호, 전체 접속 URL, 실제 `.env` 값, API Key와 Access Token은 SQL 파일, README, 공개 GitHub, 화면 캡처와 AI 질문에 넣지 않습니다.

---

## 5. PostgreSQL 설치와 서버 실행 확인

설치 화면과 세부 옵션은 운영체제와 버전에 따라 달라질 수 있습니다. 버튼 위치를 외우기보다 무엇을 설정하고 어떤 결과를 확인하는지 이해하는 것이 중요합니다.

### 5.1 Windows에서 설치하기

이 책의 화면과 설명은 Windows 11에서 공식 PostgreSQL 다운로드 페이지를 통해 제공되는 설치 프로그램을 사용한 경로를 기준으로 합니다.

```text
1. https://www.postgresql.org/download/ 에서 Windows를 선택한다.
2. 안내되는 Windows 설치 프로그램을 내려받아 실행한다.
3. PostgreSQL Server와 명령행 도구를 설치한다.
4. postgres 사용자 비밀번호를 설정한다.
5. 포트 번호를 확인한다. 특별한 충돌이 없으면 5432를 사용한다.
6. 설치를 완료한다.
7. Windows 서비스 관리 화면에서 PostgreSQL 서비스가 실행 중인지 확인한다.
```

| 항목 | 일반적인 값 |
| --- | --- |
| 관리자 사용자 | `postgres` |
| 포트 | `5432` |
| 초기 데이터베이스 | `postgres` |
| 비밀번호 | 설치 과정에서 사용자가 직접 설정 |

Windows에서는 PostgreSQL이 백그라운드 서비스로 실행됩니다. 연결이 거부될 때는 서비스 관리 화면에서 PostgreSQL 관련 서비스의 상태가 `실행 중`인지 확인합니다. 서비스 이름에는 설치 버전이 포함될 수 있습니다.

### 5.2 macOS에서 설치하기

macOS에서도 공식 PostgreSQL 다운로드 페이지에서 제공하는 설치 프로그램을 사용할 수 있습니다. 이 경로를 사용하면 Windows와 비슷하게 서버, 관리자 사용자, 포트와 비밀번호를 설정할 수 있습니다.

```text
1. https://www.postgresql.org/download/ 에서 macOS를 선택한다.
2. 설치 프로그램을 내려받아 실행한다.
3. 관리자 사용자, 비밀번호와 포트를 확인한다.
4. 설치가 끝나면 PostgreSQL 서버가 실행되는지 확인한다.
5. DBeaver에서 실제 설치 과정에 표시된 사용자와 포트로 연결한다.
```

Homebrew나 Postgres.app도 사용할 수 있지만 초기 사용자 이름과 서버 시작 방법이 달라질 수 있습니다. 다른 방식을 사용했다면 해당 도구의 안내를 기준으로 Host, Port, Database와 Username을 확인합니다.

### 5.3 Ubuntu 계열 Linux에서 설치하기

Ubuntu 계열에서는 패키지 관리자를 사용할 수 있습니다.

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl status postgresql
```

서비스가 중지되어 있다면 다음 명령으로 시작할 수 있습니다.

```bash
sudo systemctl start postgresql
```

Linux 패키지 설치에서는 운영체제 사용자와 PostgreSQL 역할의 초기 구성이 Windows 설치 프로그램과 다를 수 있습니다. DBeaver 연결 전에 실제 PostgreSQL 사용자와 인증 방식을 확인합니다.

### 5.4 `psql` 버전 확인은 선택 사항이다

터미널에서 다음 명령을 사용할 수 있습니다.

```bash
psql --version
```

`psql` 명령이 인식되지 않더라도 PostgreSQL 서버 설치가 반드시 실패한 것은 아닙니다. 실행 파일 경로가 환경변수에 등록되지 않았을 수 있습니다. 이 책의 기본 실습은 DBeaver 연결을 기준으로 진행할 수 있습니다.

운영체제와 설치 방식이 달라도 완료 기준은 같습니다.

```text
PostgreSQL 서버가 실행된다.
DBeaver에서 연결 테스트가 성공한다.
SQL을 실행할 수 있다.
```

---

## 6. DBeaver 설치와 드라이버 준비

DBeaver는 PostgreSQL을 포함한 여러 DBMS에 연결할 수 있는 GUI 클라이언트입니다. Community Edition으로 이 책의 실습을 진행할 수 있습니다.

```text
1. https://dbeaver.io/download/ 에서 운영체제용 Community 설치 파일을 받는다.
2. 설치 프로그램을 실행한다.
3. DBeaver를 시작한다.
4. PostgreSQL 연결을 처음 만들 때 JDBC 드라이버 다운로드 안내를 확인한다.
5. 드라이버 다운로드가 완료된 뒤 연결 테스트를 실행한다.
```

JDBC 드라이버는 DBeaver가 PostgreSQL과 통신하기 위한 구성 요소입니다. 회사나 학교 네트워크에서는 프록시 또는 방화벽 때문에 드라이버 다운로드가 실패할 수 있습니다.

DBeaver 설치 후에는 다음 작업을 할 수 있습니다.

```text
PostgreSQL 서버 연결
데이터베이스와 스키마 탐색
SQL 편집기 실행
조회 결과와 오류 메시지 확인
```

---

## 7. DBeaver에서 PostgreSQL 연결 만들기

로컬 필수 경로에서는 먼저 기본 `postgres` 데이터베이스에 연결합니다.

| 연결 항목 | Windows 로컬 환경의 일반적인 값 | 의미 |
| --- | --- | --- |
| Host | `localhost` | PostgreSQL 서버가 실행되는 컴퓨터 |
| Port | `5432` | PostgreSQL이 연결을 기다리는 통신 번호 |
| Database | `postgres` | 처음 접속할 데이터베이스 |
| Username | `postgres` | 접속 사용자 |
| Password | 설치 시 설정한 값 | 사용자 인증 정보 |

`localhost`는 현재 사용 중인 자신의 컴퓨터를 의미합니다. macOS·Linux 또는 관리형 환경에서는 Username과 다른 연결값이 달라질 수 있습니다.

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

하지만 연결 성공만으로 이후 SQL이 올바른 데이터베이스에서 실행된다는 보장은 없습니다. SQL 편집기를 열 때마다 현재 연결 대상을 확인합니다.

---

## 8. 작업용 데이터베이스 만들기

이 책의 로컬 필수 경로에서 사용할 작업용 데이터베이스 이름은 다음과 같습니다.

```text
ai_database_book
```

기본 `postgres` 데이터베이스에 연결된 SQL 편집기에서 다음 문장만 선택해 실행합니다.

```sql
CREATE DATABASE ai_database_book;
```

`CREATE DATABASE`에는 다음 조건이 필요합니다.

```text
CREATE DATABASE 권한이 있는 사용자로 접속했다.
트랜잭션 블록 밖에서 실행한다.
같은 이름의 데이터베이스가 없어야 한다.
```

`CREATE DATABASE`는 트랜잭션 블록 안에서 실행할 수 없습니다. DBeaver에서 해당 문장만 선택하고 자동 커밋 상태에서 실행합니다. 다음 오류가 나타나면 열린 트랜잭션을 종료한 뒤 다시 실행합니다.

```text
CREATE DATABASE cannot run inside a transaction block
```

권한이 없는 사용자는 다음과 비슷한 오류를 볼 수 있습니다.

```text
permission denied to create database
```

이 경우 관리자 계정이나 `CREATEDB` 권한이 있는 계정을 사용해야 합니다. 관리형 서비스에서는 데이터베이스 추가 생성이 제한될 수 있으므로 서비스 정책을 확인합니다.

같은 이름의 데이터베이스가 이미 있다면 다음과 비슷한 오류가 나타납니다.

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
→ DBeaver 연결 새로고침
→ ai_database_book을 대상으로 새 연결 생성 또는 기존 연결 수정
→ 새 SQL 편집기 열기
→ current_database()로 확인
```

`ai_database_book`이 Database Navigator에 보이지 않을 때는 다음을 확인합니다.

```text
1. 연결을 새로고침한다.
2. Host 방식 연결이라면 연결 설정의 Show all databases 옵션을 확인한다.
3. 또는 Database 값을 ai_database_book으로 지정한 새 연결을 만든다.
4. 새 SQL 편집기에서 current_database()를 실행한다.
```

`Show all databases` 옵션은 Host 방식 연결에서 사용할 수 있으며 URL 방식 연결에서는 동작하지 않을 수 있습니다. DBeaver 버전과 화면 모드에 따라 메뉴 위치가 다를 수 있습니다.

현재 연결을 확인하지 않으면 나중에 테이블을 만들었지만 예상한 위치에서 보이지 않는 문제가 발생할 수 있습니다.

---

## 10. 현재 데이터베이스와 스키마 확인하기

새 SQL 편집기에서 다음 SQL을 실행합니다.

```sql
SELECT current_database();

SELECT current_schema();

SHOW search_path;
```

로컬 필수 경로의 일반적인 결과는 다음과 같습니다.

```text
current_database = ai_database_book
current_schema   = public
search_path      = "$user", public
```

`search_path`는 테이블 이름에 스키마를 생략했을 때 PostgreSQL이 어떤 스키마부터 찾을지 정한 순서입니다. `"$user", public`은 현재 사용자 이름과 같은 스키마를 먼저 찾고, 없으면 `public`을 찾는다는 의미입니다.

> **기본 실습 원칙**
>
> 이 책에서는 현재 스키마와 `search_path`를 확인한 뒤 `public` 스키마를 사용합니다. 같은 이름의 객체가 앞선 검색 경로에 있으면 스키마를 생략한 이름이 `public`의 객체를 가리키지 않을 수도 있습니다.

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

DBeaver 버전, 연결 설정과 Navigator의 Simple·Advanced 보기 모드에 따라 중간 항목 이름이나 표시 순서가 달라질 수 있습니다.

현재는 아직 Chapter 04의 테이블 생성 실습을 시작하지 않았으므로 `Tables` 아래가 비어 있어도 정상입니다.

구조가 바로 보이지 않으면 다음 내용을 확인합니다.

- 탐색기에서 연결을 새로고침했는가?
- `ai_database_book` 연결을 열었는가?
- 연결 설정에서 Database 값이 올바른가?
- Host 방식 연결의 `Show all databases` 설정이 필요한가?
- `Schemas` 아래에서 `public`을 찾았는가?
- Navigator의 필터나 보기 모드 때문에 객체가 숨겨지지 않았는가?

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
SHOW search_path;
SELECT current_user;
```

### 12.3 전체 스크립트 실행

파일 전체를 실행하면 작성된 여러 문장이 실행됩니다. 그러나 **전체 스크립트 실행이 자동으로 하나의 트랜잭션이 되는 것은 아닙니다.**

DBeaver의 자동 커밋과 스크립트 설정에 따라 다음 동작이 달라질 수 있습니다.

```text
각 문장 실행 후 바로 커밋될 수 있다.
스크립트가 끝난 뒤 한 번에 커밋될 수 있다.
오류에서 실행을 중지하거나 다음 문장을 계속 실행할 수 있다.
오류 전까지 성공한 변경이 이미 저장될 수 있다.
```

Chapter 09에서 트랜잭션을 배우기 전까지 `INSERT`, `UPDATE`, `DELETE` 같은 변경 SQL은 한 문장 또는 확인한 선택 영역 단위로 실행합니다. 전체 실행 전에는 현재 연결, 실행 범위, 자동 커밋 상태와 포함된 변경 SQL을 확인합니다.

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
변경 SQL이라면 이미 커밋되었는가?
```

---

## 13. 환경 검증 SQL 실행하기

환경이 정상인지 확인하기 위해 데이터 변경이 없는 조회 SQL만 실행합니다.

```sql
SELECT version();

SELECT current_database();

SELECT current_schema();

SHOW search_path;

SELECT current_user;

SELECT CURRENT_TIMESTAMP AS checked_at;

SELECT 1 + 1 AS result;
```

각 SQL의 목적은 다음과 같습니다.

| SQL | 확인 목적 |
| --- | --- |
| `version()` | PostgreSQL 서버가 응답하고 버전 정보를 반환하는지 확인 |
| `current_database()` | 올바른 데이터베이스에 연결됐는지 확인 |
| `current_schema()` | 현재 스키마가 무엇인지 확인 |
| `SHOW search_path` | 스키마 이름을 생략했을 때의 검색 순서 확인 |
| `current_user` | 현재 접속 사용자를 확인 |
| `CURRENT_TIMESTAMP` | PostgreSQL이 현재 트랜잭션의 시각 값을 정상적으로 반환하는지 확인 |
| `1 + 1` | 편집기 실행과 결과 표시 확인 |

`CURRENT_TIMESTAMP`는 같은 트랜잭션 안에서 트랜잭션 시작 시각을 반환합니다. 실제 시계처럼 호출 순간마다 달라지는 시각이 필요한 경우에는 `clock_timestamp()`를 사용할 수 있지만, 이 장에서는 SQL이 날짜·시간 값을 정상적으로 반환하는지만 확인합니다.

![SQL로 실습 환경 확인하기](../../images/chapter03/ch03_04_sql_execution_check_flow.svg)

그림 3-4 SQL로 실습 환경 확인하기

로컬 필수 경로에서는 다음 결과를 확인합니다.

```text
PostgreSQL 버전 문자열이 표시된다.
현재 데이터베이스가 ai_database_book이다.
현재 스키마가 public이다.
search_path가 표시된다.
현재 사용자가 예상한 계정이다.
PostgreSQL이 날짜·시간 값을 반환한다.
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
SHOW search_path;
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

다음 원칙을 지킵니다.

```text
1. 비밀번호와 전체 접속 URL을 SQL이나 README에 작성하지 않는다.
2. 실제 값이 들어 있는 .env 파일은 Git에서 제외한다.
3. 클라이언트용 공개 키와 서버 전용 비밀 키를 구분한다.
4. 공개된 비밀정보는 파일만 삭제하지 말고 즉시 폐기하거나 변경한다.
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

공개 저장소에 비밀번호나 secret key를 커밋했다면 이후 파일에서 삭제하는 것만으로 충분하지 않을 수 있습니다. 해당 값을 즉시 변경하고 필요한 경우 저장소 기록에서도 제거합니다.

---

## 16. 연결 오류를 유형별로 해결하기

설치와 연결 오류는 먼저 유형을 구분하면 해결하기 쉽습니다.

| 증상 또는 메시지 | 우선 확인할 내용 |
| --- | --- |
| Connection refused | PostgreSQL 서비스, Host, Port, 방화벽 |
| Password authentication failed | Username과 Password |
| Database does not exist | 데이터베이스 이름과 생성 여부 |
| Permission denied to create database | 접속 사용자와 `CREATEDB` 권한 |
| Cannot run inside a transaction block | 자동 커밋 상태, 열린 트랜잭션과 실행 범위 |
| `psql` not recognized | 실행 파일 PATH 또는 DBeaver 연결 사용 |
| 테이블·데이터베이스가 보이지 않음 | Database, Schema, Show all databases, 필터와 새로고침 |
| SQL syntax error | 실행한 문장, 세미콜론, 오류 위치 |
| SSL 관련 오류 | SSL 설정, 인증서와 서비스 제공자의 연결 안내 |
| Host를 찾을 수 없음 | Host 복사 오류, DNS와 네트워크 연결 |
| 클라우드 직접 연결 시간 초과 | IPv4·IPv6 지원과 Session pooler 사용 여부 |
| Too many connections | 열린 DBeaver 연결, 애플리케이션 연결 수와 풀러 방식 |
| 접근 차단 | 회사·학교 방화벽, IP 허용 목록과 네트워크 정책 |

![데이터베이스 오류 해결 기본 흐름](../../images/chapter03/ch03_06_error_troubleshooting_flow.svg)

그림 3-6 데이터베이스 오류 해결 기본 흐름

공통 해결 순서는 다음과 같습니다.

```text
1. 실행하려던 작업을 한 문장으로 정리한다.
2. 오류 메시지를 생략하지 않고 읽는다.
3. 현재 Host, Port, Database와 Username을 확인한다.
4. 서버·네트워크·인증·권한·데이터베이스·스키마·SQL 중 어느 범주인지 분류한다.
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

먼저 기본 `postgres` 데이터베이스에 연결한 뒤 `ai_database_book`이 실제로 생성되어 있는지 확인합니다. 목록에 보이지 않으면 새로고침, `Show all databases` 또는 데이터베이스를 지정한 새 연결을 확인합니다.

### 16.4 테이블이 보이지 않을 때

Chapter 04 이후 테이블이 보이지 않는다면 다음 SQL부터 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

테이블을 다른 데이터베이스나 스키마에 만든 것은 아닌지 확인합니다.

### 16.5 Supabase 직접 연결이 시간 초과될 때

Supabase Direct connection은 IPv6 주소를 사용할 수 있습니다. 현재 네트워크가 IPv4만 지원하면 프로젝트의 `Connect` 화면에서 Session pooler 정보를 확인합니다. Host, Port와 Username은 직접 연결과 풀러 연결에서 달라질 수 있으므로 값을 서로 섞지 않습니다.

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
PostgreSQL 사용 방식: 로컬 / 관리형
PostgreSQL 버전:
DBeaver 버전:

연결 방식: Host / URL / Direct / Session pooler / Transaction pooler
연결값:
- Host: 실제 값 대신 일부 마스킹
- Port:
- Database:
- Username: 실제 값 대신 일부 마스킹 가능

실행한 작업:
발생한 오류 메시지:
이미 확인한 내용:
자동 커밋 상태:

비밀번호, 전체 접속 URL, API key와 Access Token은 제외했습니다.
가능한 원인을 우선순위대로 설명하고,
각 원인을 안전하게 확인하는 방법을 알려 주세요.
```

AI가 해결 방법을 제안하면 다음을 검토합니다.

- 현재 운영체제와 설치 방식에 맞는가?
- 데이터베이스나 설정을 삭제하는 명령이 포함되어 있지 않은가?
- 명령의 목적을 이해할 수 있는가?
- 한 번에 하나씩 실행하고 결과를 검증할 수 있는가?
- 비밀정보를 다시 입력하라고 요구하지 않는가?
- 클라우드 연결 방식과 포트가 섞이지 않았는가?

Codex에는 다음과 같이 환경 확인 파일을 요청할 수 있습니다.

```text
현재 저장소는 ai-database-book입니다.
code/chapter03/setup_check.sql 파일을 PostgreSQL 기준으로 작성해 주세요.

다음을 포함해 주세요.
- SELECT version();
- SELECT current_database();
- SELECT current_schema();
- SHOW search_path;
- SELECT current_user;
- SELECT CURRENT_TIMESTAMP AS checked_at;
- SELECT 1 + 1 AS result;

테이블 생성, 데이터 입력, 수정과 삭제 SQL은 포함하지 마세요.
각 문장의 목적을 주석으로 설명하고 비밀정보를 포함하지 마세요.
CURRENT_TIMESTAMP는 현재 트랜잭션의 시각 값을 반환한다고 주석에 설명해 주세요.
```

생성 결과는 DBeaver에서 직접 실행하고 실제 저장소의 `setup_check.sql`과 비교합니다.

---

## 18. 실습 환경 완료 점검

### 18.1 로컬 필수 경로

다음 항목을 모두 확인합니다.

| 점검 항목 | 완료 기준 |
| --- | --- |
| PostgreSQL 서버 | 로컬 PostgreSQL 서비스가 실행 중임 |
| DBeaver | PostgreSQL 연결 테스트 성공 |
| 작업용 데이터베이스 | `ai_database_book` 생성·연결 완료 |
| 현재 데이터베이스 | `current_database()` 결과가 `ai_database_book` |
| 현재 스키마 | `current_schema()` 결과가 `public` |
| 검색 경로 | `SHOW search_path` 결과 확인 |
| DBeaver 탐색 | `Schemas → public → Tables` 위치 확인 |
| SQL 실행 | 환경 검증 SQL 7개 결과 확인 |
| SQL 파일 | `setup_check.sql` 저장·재실행 완료 |
| 비밀정보 | SQL, README와 GitHub에 포함되지 않음 |
| 오류 기록 | 발생한 문제와 해결 방법 기록 |

환경 확인 기록은 다음처럼 남길 수 있습니다.

```markdown
## PostgreSQL 실습 환경 확인 기록

- 운영체제:
- PostgreSQL 버전:
- DBeaver 버전:
- 연결 테스트 결과:
- 현재 데이터베이스:
- 현재 스키마:
- search_path:
- 현재 사용자:
- setup_check.sql 실행 결과:
- 자동 커밋 상태:
- 발생한 문제:
- 해결 방법:
```

### 18.2 Supabase 선택 확인

Supabase를 개념 학습이나 별도 프로젝트에서 사용한다면 다음만 선택적으로 확인합니다. 이 항목은 로컬 필수 경로의 완료 기준을 대체하지 않습니다.

| 점검 항목 | 확인 내용 |
| --- | --- |
| 기본 데이터베이스 | Supabase 프로젝트의 기본 `postgres` 사용 |
| DBeaver 연결 | Direct 또는 Session pooler 중 현재 네트워크에 맞는 방식 사용 |
| 키 관리 | publishable key와 secret key의 용도 구분 |
| RLS | 브라우저·모바일 접근 테이블의 정책 검토 |
| Storage | 파일 메타데이터와 실제 객체 저장 위치 구분 |
| 비밀정보 | 전체 접속 URL과 secret key를 공개하지 않음 |

자신의 운영체제, 연결 정보와 오류 해결 과정을 더 자세히 기록하려면 `book/chapter03/chapter03_activity.md`의 독자 워크북을 사용합니다. 비밀번호, 전체 접속 URL과 비밀 키는 워크북에 기록하지 않습니다.

---

## 19. 자주 하는 실수

### 실수 1. DBeaver만 설치하면 데이터베이스가 준비됐다고 생각한다

DBeaver는 클라이언트입니다. 연결할 PostgreSQL 서버가 별도로 필요합니다.

### 실수 2. `postgres` 사용자와 `postgres` 데이터베이스를 같은 것으로 생각한다

하나는 로그인 계정이고 다른 하나는 데이터베이스입니다.

### 실수 3. Supabase를 로컬 필수 실습의 완전한 대체 경로로 생각한다

Supabase 프로젝트는 기본 `postgres` 데이터베이스와 서비스 통합 구조를 사용합니다. 이 책의 필수 실습은 로컬의 `ai_database_book` 데이터베이스를 기준으로 합니다.

### 실수 4. 데이터베이스를 만든 뒤 기존 편집기에서 계속 실행한다

새 데이터베이스를 만들었다고 연결 대상이 자동으로 바뀌지 않습니다. `current_database()`로 확인합니다.

### 실수 5. 스키마와 검색 경로를 확인하지 않는다

테이블이 예상한 위치에 보이지 않으면 `current_schema()`, `SHOW search_path`와 DBeaver의 `Schemas` 항목을 확인합니다.

### 실수 6. 여러 변경 SQL을 의도하지 않게 전체 실행한다

전체 스크립트가 항상 하나의 트랜잭션으로 실행되는 것은 아닙니다. 현재 문장, 선택 영역, 전체 스크립트와 자동 커밋 상태를 구분합니다.

### 실수 7. `CREATE DATABASE`를 트랜잭션 안에서 실행한다

`CREATE DATABASE`는 해당 문장만 선택해 트랜잭션 블록 밖에서 실행합니다.

### 실수 8. 오류 메시지를 읽지 않고 설정을 반복해서 바꾼다

오류를 서버, 네트워크, 인증, 권한, 데이터베이스, 스키마와 SQL 범주로 먼저 분류합니다.

### 실수 9. 비밀번호와 접속 URL을 SQL 파일이나 AI 질문에 넣는다

환경 정보와 비밀정보를 분리하고 실제 값은 안전한 관리 도구에 보관합니다.

### 실수 10. 환경 확인 파일에 테이블 생성과 데이터 입력을 함께 넣는다

환경 확인 파일은 반복 실행할 수 있도록 조회 SQL만 포함합니다. 테이블 생성과 데이터 입력은 Chapter 04에서 별도 파일로 다룹니다.

---

## 20. 핵심 정리

| 개념 | 핵심 내용 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 처리하는 관계형 DBMS |
| DBeaver | PostgreSQL에 연결해 SQL과 결과를 확인하는 클라이언트 |
| 로컬 필수 경로 | 로컬 PostgreSQL에서 `ai_database_book`을 생성해 진행하는 이 책의 기본 실습 환경 |
| 관리형 PostgreSQL | 클라우드에서 서버 운영 부담을 줄여 제공되는 PostgreSQL 환경 |
| Supabase | PostgreSQL을 중심으로 Auth·Storage·Realtime 등의 기능을 함께 제공하는 선택형 관리형 백엔드 플랫폼 |
| RLS | 사용자나 역할에 따라 접근 가능한 행을 제한하는 PostgreSQL 보안 정책 |
| Direct·Session·Transaction 연결 | 클라이언트와 네트워크 환경에 따라 구분하는 Supabase 연결 방식 |
| Host | PostgreSQL 서버가 실행되는 컴퓨터의 주소 |
| Port | PostgreSQL 접속 통로의 번호 |
| Database | 연결할 논리적 데이터베이스 |
| Schema | 데이터베이스 안에서 테이블을 묶는 이름 공간 |
| `search_path` | 스키마 이름을 생략했을 때 객체를 찾는 순서 |
| 자동 커밋 | 실행한 변경을 언제 확정하는지 결정하는 클라이언트 설정 |
| `setup_check.sql` | 서버·DB·스키마·검색 경로·사용자와 실행 상태를 확인하는 재실행 가능한 파일 |
| 비밀정보 | SQL과 공개 저장소에서 분리해야 하는 비밀번호, 전체 접속 URL과 secret key |

이 장의 핵심을 한 문장으로 정리하면 다음과 같습니다.

```text
데이터베이스 실습은 설치에서 끝나는 것이 아니라,
올바른 데이터베이스와 스키마에 연결해
SQL 결과를 직접 확인하고 다시 재현할 수 있을 때 시작된다.
```

---

## 21. 다음 장에서는

다음 장에서는 로컬 필수 경로로 준비한 `ai_database_book` 데이터베이스의 `public` 스키마에서 첫 번째 테이블을 만들고 데이터를 직접 다룹니다.

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
