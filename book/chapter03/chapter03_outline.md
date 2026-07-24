# Chapter 03 구성안

## 제목

PostgreSQL과 DBeaver로 실습 환경 만들기

## 권장 분량

18~22페이지

## 이 장의 역할

관계형 데이터베이스를 직접 다룰 수 있도록 PostgreSQL과 DBeaver를 설치·연결하고, 현재 데이터베이스·검색 경로·읽기 전용 상태를 확인하며, 이후 장의 SQL을 안전하게 실행할 수 있는 환경을 완성한다.

이 장의 필수 실습은 로컬 PostgreSQL에서 `ai_database_book`을 사용하는 경로를 기준으로 한다. Supabase는 관리형 PostgreSQL의 차이를 이해하기 위한 선택 읽기로 축소하며 로컬 완료 기준을 대체하지 않는다.

이 장에서는 테이블 생성, 데이터 입력과 제약조건 실습을 진행하지 않는다. CRUD는 Chapter 04, 무결성 오류는 Chapter 06, 트랜잭션은 Chapter 09, 사용자·권한·password file은 Chapter 11로 연결한다.

## 핵심 질문

```text
PostgreSQL과 DBeaver는 각각 어떤 역할을 하는가?
로컬 필수 경로와 관리형 PostgreSQL 선택 경로는 어떻게 다른가?
DBeaver 연결값은 무엇을 의미하는가?
ai_database_book이 이미 존재하는지 어떻게 확인하는가?
현재 데이터베이스·스키마·search_path는 무엇인가?
current_schema()가 항상 public은 아닌 이유는 무엇인가?
현재 연결이 읽기 전용인지 어떻게 확인하는가?
Statement·선택 영역·Script 실행은 어떻게 다른가?
setup_check와 setup_validate_local은 역할이 어떻게 다른가?
비밀번호와 접속 정보는 어떻게 분리하는가?
오류가 발생했을 때 무엇부터 확인해야 하는가?
```

## 독자가 얻게 될 것

- PostgreSQL이 DBMS이고 DBeaver가 클라이언트임을 설명할 수 있다.
- Windows에서 로컬 PostgreSQL을 설치하고 서비스 상태를 확인할 수 있다.
- macOS·Ubuntu의 대표 설치 차이를 설명할 수 있다.
- DBeaver에서 PostgreSQL 연결을 만들 수 있다.
- `postgres` 사용자와 `postgres` 데이터베이스를 구분할 수 있다.
- 관리자 계정의 로컬 학습 범위와 운영 환경의 최소 권한 원칙을 구분할 수 있다.
- `ai_database_book`의 존재와 소유자를 조회한 뒤 필요한 경우 생성할 수 있다.
- 새 데이터베이스로 연결을 전환할 수 있다.
- `current_database()`, `current_schema()`와 `SHOW search_path`를 해석할 수 있다.
- `public` 스키마 존재와 `USAGE` 권한을 확인할 수 있다.
- `transaction_read_only`와 `TimeZone`을 확인할 수 있다.
- Statement·선택 영역·Script 실행과 Auto-commit을 구분할 수 있다.
- `setup_check.sql`로 환경 정보를 조회할 수 있다.
- `setup_validate_local.sql`로 로컬 필수 경로를 자동 판정할 수 있다.
- libpq 변수와 `PGPASSFILE` 중심의 비밀정보 정책을 설명할 수 있다.
- 연결 오류를 유형별로 분류하고 실제 재실행으로 검증할 수 있다.

## 출판 기준 환경

```text
기준 버전 확인일: 2026-07-24
운영체제 기준: Windows 11
PostgreSQL 기준: 18.4
DBeaver Community 기준: 26.1.3
호환 목표: PostgreSQL 15 이상
```

공식 문서상 버전 확인과 실제 설치·SQL 실행·출판 렌더링 검증을 구분한다.

## 핵심 개념

- PostgreSQL / Postgres
- DBeaver Community
- 서버와 클라이언트
- 로컬 필수 경로
- 관리형 PostgreSQL
- Supabase 선택 읽기
- Direct / Session / Transaction pooler
- IPv4 / IPv6
- publishable / secret key
- legacy anon / service_role
- RLS
- Storage API와 읽기 전용 메타데이터
- Host / Port / Database / Username
- `postgres` 사용자와 데이터베이스
- `ai_database_book`
- `CREATE DATABASE`
- `CREATEDB`
- Auto-commit / Manual commit
- `current_database()`
- `current_schema()`
- `search_path`
- `public`
- `transaction_read_only`
- `TimeZone`
- `setup_check.sql`
- `setup_validate_local.sql`
- `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSFILE`
- 재현 가능한 오류 질문

## 본문 구성

1. 이 장에서 완성할 실습 환경
2. PostgreSQL과 DBeaver 역할 복습
3. 로컬과 관리형 PostgreSQL
   - Supabase 선택 읽기
   - Storage API와 메타데이터
   - 연결 방식
   - 최신 API 키와 RLS
4. 설치 전 확인
5. PostgreSQL 설치와 서버 상태
   - Windows
   - macOS
   - Ubuntu
   - `psql` 선택 확인
6. DBeaver 설치와 연결
7. 작업용 데이터베이스 확인·생성
   - 존재 여부와 소유자 조회
   - 관리자 계정 경계
   - 트랜잭션 밖 실행
8. 새 데이터베이스로 다시 연결
9. 현재 DB·스키마·검색 경로 확인
10. 실행 범위와 Auto-commit
11. `setup_check.sql`
12. `setup_validate_local.sql`
13. 접속 정보와 비밀정보
14. 오류 해결
15. AI 질문 작성
16. 완료 점검
17. 자주 하는 실수
18. 핵심 정리
19. 다음 장 연결

## 로컬 필수 흐름

```text
PostgreSQL 서버 준비
→ DBeaver Test Connection
→ postgres 데이터베이스 접속
→ ai_database_book 존재·소유자 확인
→ 필요한 경우 CREATE DATABASE
→ ai_database_book으로 다시 연결
→ current_database·current_schema·search_path 확인
→ transaction_read_only·TimeZone 확인
→ setup_check.sql 실행
→ setup_validate_local.sql 통과
```

## 데이터베이스 생성 안전 기준

```text
변경 전에 존재 여부를 조회한다.
기존 DB가 있으면 소유자와 객체 상태를 확인한다.
자동 DROP DATABASE를 안내하지 않는다.
CREATE DATABASE는 트랜잭션 밖에서 실행한다.
관리자 계정 사용은 개인 로컬 학습 초기 구성으로 제한한다.
```

## 환경 조회와 자동 판정 분리

### `setup_check.sql`

```text
version
current_database
current_schema
search_path
current_user
transaction_read_only
TimeZone
CURRENT_TIMESTAMP
1 + 1
한 행 요약 결과
```

### `setup_validate_local.sql`

```text
PostgreSQL 15 이상
DB = ai_database_book
CONNECT 권한
public 존재
public USAGE 권한
transaction_read_only = off
SQL 계산 정상
```

통과 메시지:

```text
Chapter 03 local environment validation passed
```

## `current_schema()` 설명 원칙

```text
current_schema()
→ search_path에서 실제로 사용할 수 있는 첫 번째 스키마
→ 사용자 스키마가 있으면 public이 아닐 수 있음
```

완료 기준은 `current_schema() = public`이 아니라 `public`의 존재와 사용 권한, `search_path` 해석 가능 여부다. Chapter 04에서는 `public.students`처럼 스키마를 명시한다.

## 비밀정보 정책

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
```

실제 비밀번호를 기본 `.env` 예제로 권장하지 않는다. password file과 실제 `.env`는 Git에서 제외한다. 공용 PC의 DBeaver 비밀번호 저장, 연결 설정 내보내기와 화면 캡처 노출도 경고한다.

## Supabase 선택 읽기 범위

본문은 다음 핵심만 유지한다.

```text
실제 PostgreSQL 제공
Storage 메타데이터와 객체 저장소 구분
Storage 수정·삭제는 API 사용
Direct 5432
Session pooler 5432
Transaction pooler 6543
Transaction pooler prepared statement 미지원
publishable은 공개 클라이언트용이지만 인증·RLS 필요
secret은 서버 전용이며 RLS 우회
legacy anon·service_role은 2026년 말 사용 중단 예정
```

세부 비교와 기록 활동은 워크북의 선택 활동으로 이동한다.

## 독자 참여 요소

### 핵심

- 자신의 환경 기록
- PostgreSQL·DBeaver 역할 구분
- 연결값 확인
- DB 존재·소유자 조회
- `CREATE DATABASE` 사전 조건
- 새 연결 전환
- DB·스키마·search_path 확인
- Statement·Script와 커밋 모드 비교
- `setup_check.sql` 결과 기록
- `setup_validate_local.sql` 통과
- 오류와 비밀정보 점검

### 선택

- macOS·Linux 설치 방식
- 관리형 PostgreSQL·Supabase
- AI 오류 질문 작성

## AI 활용 포인트

- 운영체제, 버전, 연결 방식, 마스킹한 연결값, 실행 작업, 오류 원문과 커밋 모드를 제공한다.
- 비밀번호, 전체 접속 URL과 API 키는 제공하지 않는다.
- 삭제·초기화·권한 변경 명령은 목적과 대상을 이해하기 전 실행하지 않는다.
- AI 답변의 정확성은 실제 재실행 결과로 검증한다.

## 후속 장으로 이동하는 내용

| 내용 | 이동 장 |
| --- | --- |
| 첫 테이블과 CRUD | Chapter 04 |
| 관계와 외래키 설계 | Chapter 05 |
| 제약조건 오류 | Chapter 06 |
| 트랜잭션 제어 | Chapter 09 |
| 사용자·역할·password file·백업 | Chapter 11 |
| AI 설계·SQL 검증 | Chapter 13 |

## 도식

본문 사용 도식은 6종을 유지한다.

```text
그림 3-1 전체 환경
그림 3-2 로컬·관리형 연결
그림 3-3 DBeaver 연결
그림 3-4 환경 정보 조회
그림 3-5 조회와 자동 판정
그림 3-6 오류 해결
```

그림 3-4와 3-5는 읽기 전용 상태·시간대·자동 검증 역할을 반영한다.

## 편집 원칙

- 설치 화면을 그대로 복제하지 않고 성공 기준을 설명한다.
- Windows를 본문 기본 경로로 사용한다.
- macOS·Linux와 Supabase 세부 활동은 워크북 선택 영역으로 축소한다.
- 실행 결과와 자동 판정을 분리한다.
- 환경 조회 파일에 데이터 변경 SQL을 포함하지 않는다.
- 실제 통합 실행과 출판 렌더링 미수행 상태를 과장하지 않는다.

## 다음 장 연결

Chapter 04에서는 `setup_validate_local.sql`을 통과한 `ai_database_book` 연결에서 `public.students`를 생성하고 CRUD를 실행한다.