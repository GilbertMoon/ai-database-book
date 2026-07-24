# Chapter 03 독자 워크북

## PostgreSQL과 DBeaver로 실습 환경 만들기

> 이 워크북은 Chapter 03을 읽은 뒤 자신의 PostgreSQL 환경과 실행 결과를 기록하기 위한 선택형 보조 자료입니다. 테이블 생성보다 연결 대상, 데이터베이스, 스키마, 읽기·쓰기 상태와 자동 검증에 집중합니다.

이 책의 필수 실습 경로는 다음과 같습니다.

```text
로컬 PostgreSQL
→ DBeaver 연결
→ ai_database_book 확인·생성
→ 새 데이터베이스로 다시 연결
→ setup_check.sql 실행
→ setup_validate_local.sql 통과
```

Supabase는 관리형 PostgreSQL을 이해하기 위한 선택 활동입니다. 비밀번호, 전체 접속 URL, 실제 `.env`, password file, API Key와 Access Token은 이 워크북이나 공개 저장소에 기록하지 않습니다.

---

## 1. 워크북 활용 방법

활동은 핵심과 선택으로 나눕니다.

```text
핵심 활동
1. 환경 기록
2. PostgreSQL과 DBeaver 역할 구분
3. 로컬 연결
4. 작업용 DB 확인·생성
5. 현재 DB·스키마·search_path 확인
6. setup_check.sql 실행
7. setup_validate_local.sql 실행
8. 오류 기록과 보안 점검

선택 활동
9. macOS·Linux 설치 경로
10. 관리형 PostgreSQL과 Supabase
11. AI 오류 질문 작성
```

처음 읽는 독자는 핵심 활동만 먼저 진행해도 충분합니다.

---

# 핵심 활동

## 2. 나의 환경 기록하기

출판 기준 환경:

```text
기준 버전 확인일: 2026-07-24
운영체제 기준: Windows 11
PostgreSQL 기준: 18.4
DBeaver Community 기준: 26.1.3
호환 목표: PostgreSQL 15 이상
```

| 항목 | 나의 환경 |
| --- | --- |
| 운영체제 |  |
| PostgreSQL 사용 방식 | 로컬 / 관리형 |
| PostgreSQL 버전 |  |
| DBeaver 버전 |  |
| Host | 공개 문서에는 전체 값을 적지 않음 |
| Port |  |
| 처음 연결한 데이터베이스 |  |
| 작업용 데이터베이스 |  |
| 현재 스키마 |  |
| `search_path` |  |
| `transaction_read_only` |  |
| `TimeZone` |  |
| Auto-commit / Manual commit |  |
| SQL 파일 보관 위치 |  |

```text
나는 이 책의 필수 실습을 로컬 PostgreSQL로 진행한다.
그 이유는 ____________________________________________________________ 이다.
```

---

## 3. PostgreSQL과 DBeaver 역할 구분하기

| 작업 | PostgreSQL / DBeaver / 사용자 | 이유 |
| --- | --- | --- |
| 해결할 질문을 정한다 |  |  |
| SQL을 작성한다 |  |  |
| 데이터를 실제로 저장한다 |  |  |
| 사용자 인증과 권한을 확인한다 |  |  |
| SQL을 실행한다 |  |  |
| 결과를 화면에 표시한다 |  |  |
| 데이터베이스·스키마 목록을 탐색한다 |  |  |
| 비밀번호를 안전하게 관리한다 |  |  |
| 결과가 요구사항과 맞는지 판단한다 |  |  |

```text
PostgreSQL은 __________________________________________________________ 이고,
DBeaver는 _____________________________________________________________ 이다.
```

---

## 4. 설치와 서버 상태 확인하기

### Windows 핵심 점검

| 확인 항목 | 결과 |
| --- | --- |
| PostgreSQL Server 설치 |  |
| 명령행 도구 설치 |  |
| 관리자 사용자 확인 |  |
| 포트 확인 |  |
| Windows 서비스가 실행 중 |  |
| Stack Builder가 필수는 아님을 확인 |  |

`psql --version`이 인식되지 않아도 PATH 문제일 수 있습니다. DBeaver Test Connection과 서버 상태를 별도로 확인합니다.

### 관리자 계정 범위

```text
postgres 같은 관리자 계정은 개인 로컬 환경의 초기 구성에 사용할 수 있다.
실제 애플리케이션·공용 서버에서는
________________________________________________________________________
```

---

## 5. DBeaver 연결 확인하기

| 항목 | 일반적인 로컬 값 | 나의 값 | 의미 |
| --- | --- | --- | --- |
| DBMS | PostgreSQL |  | 연결할 데이터베이스 시스템 |
| Host | `localhost` |  | 서버 주소 |
| Port | `5432` |  | 접속 통로 |
| Database | `postgres` |  | 초기 연결 대상 |
| Username | Windows 일반 설치는 `postgres` |  | 접속 역할 |
| Password | 기록하지 않음 | 기록하지 않음 | 인증 정보 |
| Test Connection | 성공 |  | 서버·인증·DB 접속 가능 |

```text
postgres 사용자:
________________________________________________________________________

postgres 데이터베이스:
________________________________________________________________________
```

### 연결 실패 기록

| 항목 | 기록 |
| --- | --- |
| 오류 원문 |  |
| 서버 상태 |  |
| Host·Port |  |
| Database·Username |  |
| SSL·네트워크 |  |
| 적용한 해결 방법 |  |
| 재실행 결과 |  |

---

## 6. 작업용 데이터베이스 확인·생성하기

### 6.1 존재 여부 조회

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS database_owner
FROM pg_database
WHERE datname = 'ai_database_book';
```

| 결과 | 나의 판단 |
| --- | --- |
| 0행 |  |
| 1행 | 소유자와 기존 객체 상태 확인 |

기존 데이터베이스가 있을 때 확인할 내용을 적어 보세요.

```text
소유자:
public 스키마:
course_project 스키마:
기존 테이블:
계속 사용할지 여부:
```

### 6.2 필요한 경우 생성

```sql
CREATE DATABASE ai_database_book;
```

| 조건 | 확인 |
| --- | --- |
| `CREATEDB` 권한 또는 관리자 역할 |  |
| 문장 하나만 선택 |  |
| Auto-commit 상태 확인 |  |
| 열린 트랜잭션 없음 |  |
| 같은 이름의 DB가 없음 |  |
| 운영·공용 서버가 아닌 개인 로컬 학습 환경 |  |

대표 오류의 의미:

```text
CREATE DATABASE cannot run inside a transaction block
→ ______________________________________________________________________

permission denied to create database
→ ______________________________________________________________________

database "ai_database_book" already exists
→ ______________________________________________________________________
```

---

## 7. 새 데이터베이스와 스키마 확인하기

`ai_database_book` 전용 연결에서 실행합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

| 항목 | 필수 판정 | 실제 결과 |
| --- | --- | --- |
| 현재 DB | `ai_database_book` |  |
| 현재 스키마 | 환경에 따라 다를 수 있음 |  |
| `search_path` | 결과와 검색 순서 확인 |  |
| `public` 존재 | 있어야 함 |  |
| `public` 사용 권한 | 있어야 함 |  |

```text
current_schema()가 반드시 public이 아닐 수 있는 이유:
________________________________________________________________________

Chapter 04에서 public.students처럼 스키마를 명시하는 이유:
________________________________________________________________________
```

DBeaver에서 다음 위치를 찾습니다.

```text
PostgreSQL 연결
→ ai_database_book
→ Schemas
→ public
→ Tables
```

Chapter 04 전에는 `Tables`가 비어 있어도 정상입니다.

---

## 8. 실행 범위와 커밋 모드 확인하기

| 실행 방식 | 내가 선택한 범위 | 실행 문장 수 | 결과 |
| --- | --- | ---: | --- |
| Statement 실행 |  |  |  |
| 선택 영역 실행 |  |  |  |
| Script 실행 |  |  |  |

```text
현재 커밋 모드:
________________________________________________________________________

Auto-commit에서 변경 SQL이 성공하면:
________________________________________________________________________

Manual commit에서 Commit하지 않은 변경은:
________________________________________________________________________
```

Script 실행 전 확인:

```text
현재 연결:
실행 범위:
커밋 모드:
변경 SQL 포함 여부:
오류 시 중지·계속 설정:
```

---

## 9. `setup_check.sql` 실행하기

파일:

```text
code/chapter03/setup_check.sql
```

| 확인 항목 | 기대 내용 | 실제 결과 |
| --- | --- | --- |
| PostgreSQL 버전 | 버전 문자열 |  |
| 현재 DB | `ai_database_book` |  |
| 현재 스키마 | 참고 정보 |  |
| `search_path` | 검색 순서 |  |
| 현재 사용자 | 접속 역할 |  |
| `transaction_read_only` | `off` |  |
| `TimeZone` | 현재 시간대 |  |
| `CURRENT_TIMESTAMP` | 날짜·시간 값 |  |
| `1 + 1` | `2` |  |
| 한 행 요약 | DB·public·USAGE 상태 |  |

```text
정보 조회 파일이 잘못된 환경에서도 실행 자체는 성공할 수 있는 이유:
________________________________________________________________________
```

---

## 10. `setup_validate_local.sql` 실행하기

파일:

```text
code/chapter03/setup_validate_local.sql
```

| 자동 판정 항목 | 결과 |
| --- | --- |
| PostgreSQL 15 이상 |  |
| `current_database() = ai_database_book` |  |
| 현재 사용자 CONNECT 권한 |  |
| `public` 스키마 존재 |  |
| `public` USAGE 권한 |  |
| `transaction_read_only = off` |  |
| SQL 계산 정상 |  |

통과 메시지:

```text
Chapter 03 local environment validation passed
```

```text
실제 실행 결과:
________________________________________________________________________

실패했다면 예외 메시지:
________________________________________________________________________

수정 후 재실행 결과:
________________________________________________________________________
```

---

## 11. 비밀정보 점검하기

후속 장에서 사용할 변수 이름:

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
```

| 항목 | 공개 가능 / 금지 | 이유 |
| --- | --- | --- |
| `PGPORT=5432` |  |  |
| 실제 DB 비밀번호 |  |  |
| 전체 클라우드 접속 URL |  |  |
| 변수 이름만 있는 `.env.example` |  |  |
| 실제 값이 있는 `.env` |  |  |
| `.pgpass` 또는 `pgpass.conf` |  |  |
| 일부 마스킹한 오류 환경 정보 |  |  |
| DBeaver 연결 설정 내보내기 파일 |  |  |

```text
공용 PC에서 DBeaver 비밀번호 저장 기능을 사용하면 안 되는 이유:
________________________________________________________________________
```

---

## 12. 오류 기록하기

| 오류 또는 증상 | 유형 | 우선 확인할 내용 |
| --- | --- | --- |
| Connection refused |  |  |
| Password authentication failed |  |  |
| Database does not exist |  |  |
| Permission denied to create database |  |  |
| Cannot run inside a transaction block |  |  |
| 테이블·DB가 보이지 않음 |  |  |
| SSL·Host 오류 |  |  |
| 직접 연결 시간 초과 |  |  |

문제 해결 기록:

```markdown
## 실행하려던 작업

## 오류 원문

## 환경과 연결 방식

## 분류

## 확인한 순서

## 변경한 설정

## 재실행 결과
```

---

# 선택 활동

## 13. macOS·Linux 설치 경로 기록하기

| 항목 | 기록 |
| --- | --- |
| 설치 방식 | 공식 설치 프로그램 / Homebrew / Postgres.app / apt |
| PostgreSQL 사용자 |  |
| 서버 시작 방법 |  |
| 서버 상태 확인 |  |
| 실제 버전 |  |
| Windows 기준과 다른 점 |  |

Ubuntu에서 `postgresql-contrib`는 기본 연결 실습의 필수가 아니라 추가 확장 모음입니다.

---

## 14. 관리형 PostgreSQL과 Supabase

### 연결 방식

| 방식 | 포트 | 적합한 상황 | 주의점 |
| --- | ---: | --- | --- |
| Direct | `5432` | GUI·마이그레이션·백업 | 기본 IPv6 |
| Session pooler | `5432` | IPv4 지속 연결 | Direct 대안 |
| Transaction pooler | `6543` | 서버리스·짧은 연결 | prepared statement 미지원 |

### Storage

```text
Storage 파일 메타데이터 → PostgreSQL
실제 파일 객체 → 객체 저장소
파일 수정·삭제 → Storage API
storage 스키마 레코드 → SQL에서는 읽기 전용으로 취급
```

### API 키

| 키 | 사용 위치 | RLS | 공개 코드 |
| --- | --- | --- | --- |
| publishable | 브라우저·모바일 | 적용 필요 | 가능 |
| secret | 신뢰할 수 있는 서버 | 우회 | 금지 |
| legacy anon | 기존 클라이언트 | 적용 필요 | 전환 대상 |
| legacy service_role | 기존 서버 | 우회 | 전환 대상·공개 금지 |

레거시 키는 2026년 말 사용 중단 예정입니다.

```text
Supabase 기본 데이터베이스:
________________________________________________________________________

로컬 필수 데이터베이스:
________________________________________________________________________

두 경로의 current_database() 결과가 같아야 하는가?
________________________________________________________________________
```

---

## 15. AI 오류 질문 작성하기

```text
운영체제:
PostgreSQL 사용 방식: 로컬 / 관리형
PostgreSQL 버전:
DBeaver 버전:

연결 방식:
- Host: 일부 마스킹
- Port:
- Database:
- Username: 필요하면 일부 마스킹

실행한 작업:
오류 메시지 원문:
이미 확인한 내용:
Auto-commit / Manual commit:

비밀번호, 전체 접속 URL, API key와 Access Token은 제외했습니다.
가능한 원인을 우선순위대로 설명하고,
각 원인을 안전하게 확인하는 방법을 알려 주세요.
```

AI 답변 검토:

| 항목 | 결과 |
| --- | --- |
| 현재 운영체제와 환경에 맞는가? |  |
| 로컬과 관리형 경로를 혼동하지 않았는가? |  |
| 삭제·초기화·권한 변경 명령이 있는가? |  |
| 각 명령의 목적과 대상을 이해하는가? |  |
| 비밀정보 입력을 요구하지 않는가? |  |
| 실제 재실행으로 해결을 확인했는가? |  |

---

## 16. 최종 완료 점검

| 점검 항목 | 완료 |
| --- | --- |
| 로컬 PostgreSQL 서비스 실행 |  |
| DBeaver Test Connection 성공 |  |
| `ai_database_book` 연결 |  |
| `public` 스키마 존재·USAGE 권한 |  |
| `search_path` 의미 확인 |  |
| `transaction_read_only = off` |  |
| `TimeZone` 확인 |  |
| `setup_check.sql` 실행 |  |
| `setup_validate_local.sql` 통과 |  |
| 실제 비밀정보 미기록 |  |
| 오류 해결 결과 기록 |  |

---

## 17. 권장 해설

- DBeaver는 클라이언트이고 PostgreSQL이 SQL을 실행하고 데이터를 저장합니다.
- `CREATE DATABASE` 전에 기존 데이터베이스의 존재와 소유자를 확인합니다.
- 새 데이터베이스를 만들어도 기존 편집기의 연결 대상은 자동으로 바뀌지 않습니다.
- `current_schema()`는 `search_path`에서 실제로 사용할 수 있는 첫 번째 스키마이므로 항상 `public`인 것은 아닙니다.
- Test Connection 성공은 쓰기 가능 여부까지 보장하지 않으므로 `transaction_read_only`를 확인합니다.
- `setup_check.sql`은 환경 정보를 보여 주고 `setup_validate_local.sql`은 필수 조건을 통과·실패로 판정합니다.
- 관리자 계정은 개인 로컬 학습 초기 구성에만 사용하고 실제 애플리케이션은 최소 권한 역할을 사용합니다.
- 비밀번호는 SQL·README·공개 환경 변수에 넣지 않고 password file로 분리합니다.
- Supabase의 publishable key가 공개 가능하다는 사실은 데이터가 자동으로 공개되어도 된다는 의미가 아니며 인증과 RLS가 필요합니다.
- AI 답변의 정답 여부는 실제 재실행 결과로 검증합니다.

---

## 18. 한 문장으로 정리하기

```text
데이터베이스 실습 환경이 준비되었다는 것은
________________________________________________________________________
________________________________________________________________________
상태라는 뜻이다.
```