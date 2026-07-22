# Chapter 03 구성안

## 제목

PostgreSQL과 DBeaver로 실습 환경 만들기

## 권장 분량

18~22페이지

## 이 장의 역할

관계형 데이터베이스를 직접 다룰 수 있도록 PostgreSQL과 DBeaver를 설치·연결하고, 현재 데이터베이스와 스키마를 확인하며, 이후 장의 SQL을 안전하게 실행할 수 있는 환경을 완성한다.

이 장의 필수 실습은 로컬 PostgreSQL에서 `ai_database_book` 데이터베이스를 생성하는 경로를 기준으로 한다. Supabase는 관리형 PostgreSQL의 대표 사례를 이해하기 위한 선택 읽기로 다루며, 로컬 필수 경로의 완료 기준을 대체하지 않는다.

이 장에서는 테이블 생성, 데이터 입력과 제약조건 실습을 미리 진행하지 않는다. Chapter 03은 환경 준비와 실행 검증에 집중하고, CRUD는 Chapter 04, 제약조건 오류 실습은 Chapter 06으로 연결한다.

이 장의 핵심 질문은 다음과 같다.

```text
PostgreSQL과 DBeaver는 각각 어떤 역할을 하는가?
로컬 필수 경로와 관리형 PostgreSQL 선택 경로는 어떻게 다른가?
Supabase는 PostgreSQL과 어떤 관계인가?
DBeaver 연결에 필요한 값은 무엇을 의미하는가?
현재 어떤 데이터베이스, 스키마와 검색 경로에 연결되어 있는가?
SQL 한 문장, 선택 영역과 전체 스크립트 실행은 어떻게 다른가?
CREATE DATABASE를 실행할 때 어떤 권한과 트랜잭션 조건이 필요한가?
오류가 발생했을 때 무엇부터 확인해야 하는가?
비밀번호, 접속 URL과 API 키는 어떻게 안전하게 관리해야 하는가?
```

## 독자가 얻게 될 것

- PostgreSQL이 DBMS이고 DBeaver가 클라이언트임을 설명할 수 있다.
- Windows를 기준으로 로컬 PostgreSQL을 설치하고 서버 상태를 확인할 수 있다.
- macOS와 Ubuntu 계열 Linux의 대표 설치 경로를 설명할 수 있다.
- 로컬 PostgreSQL을 필수 경로로 사용하고 관리형 PostgreSQL을 별도 대안으로 판단할 수 있다.
- Supabase의 PostgreSQL, Storage, Auth, Realtime과 객체 저장소의 역할을 구분할 수 있다.
- Supabase의 Direct, Session pooler와 Transaction pooler를 용도별로 구분할 수 있다.
- publishable key와 secret key, 레거시 anon과 service_role 키를 구분할 수 있다.
- Host, Port, Database, Username과 Password의 의미를 설명할 수 있다.
- `postgres` 사용자와 `postgres` 데이터베이스를 구분할 수 있다.
- `ai_database_book` 데이터베이스를 트랜잭션 블록 밖에서 만들고 새 연결로 전환할 수 있다.
- `current_database()`, `current_schema()`와 `SHOW search_path`로 현재 위치를 확인할 수 있다.
- DBeaver에서 `Show all databases`, 필터와 보기 모드를 점검할 수 있다.
- DBeaver에서 `Schemas → public → Tables` 구조를 찾을 수 있다.
- SQL 편집기의 현재 문장, 선택 영역과 전체 스크립트 실행을 구분할 수 있다.
- 전체 스크립트와 자동 커밋의 위험을 설명할 수 있다.
- 환경 확인 SQL 7개를 `setup_check.sql`로 저장하고 반복 실행할 수 있다.
- 연결 오류를 서버·네트워크·인증·권한·데이터베이스·스키마·트랜잭션·SQL 범주로 구분할 수 있다.
- 비밀번호, 접속 URL, secret key와 실제 `.env` 값을 공개 파일에서 분리할 수 있다.
- AI에게 오류 상황을 재현 가능한 형식으로 질문할 수 있다.

## 원고 검증 기준

```text
검증 시점: 2026년 7월
운영체제: Windows 11
PostgreSQL: 18.4
DBeaver Community: 26.1.3
호환 목표: PostgreSQL 15 이상
```

버전과 운영체제에 따라 메뉴, 서비스 이름과 화면 배치가 달라질 수 있음을 명시한다.

## 핵심 개념

- PostgreSQL / Postgres
- DBeaver Community
- 서버와 클라이언트
- 로컬 필수 경로
- 관리형 PostgreSQL
- 공동 책임 모델
- Supabase
- PostgreSQL과 객체 저장소
- Direct connection
- Session pooler
- Transaction pooler
- IPv4 / IPv6
- RLS
- publishable key / secret key
- legacy anon / service_role
- Host
- Port
- Database
- Username
- Password
- `postgres` 사용자와 데이터베이스
- `ai_database_book`
- `CREATE DATABASE`
- `CREATEDB` 권한
- 트랜잭션 블록
- 스키마
- `public`
- `search_path`
- `Show all databases`
- SQL 편집기
- 현재 문장 실행
- 선택 영역 실행
- 전체 스크립트 실행
- 자동 커밋
- 환경 검증 SQL
- `CURRENT_TIMESTAMP`
- `setup_check.sql`
- 비밀정보 관리
- 재현 가능한 오류 질문

## 본문 구성

1. 이 장에서 완성할 실습 환경과 원고 검증 기준
2. PostgreSQL과 DBeaver의 역할 복습
3. 로컬과 클라우드 중 실습 환경 선택
   - 로컬 필수 경로
   - 관리형 PostgreSQL의 공동 책임
   - Supabase 선택 읽기
   - Storage와 객체 저장소
   - 연결 방식과 API 키
4. 설치 전에 확인할 사항
5. PostgreSQL 설치와 서버 실행 확인
   - Windows
   - macOS
   - Ubuntu 계열 Linux
   - `psql` 선택 확인
6. DBeaver 설치와 드라이버 준비
7. DBeaver에서 PostgreSQL 연결 만들기
8. 작업용 데이터베이스 만들기
   - 권한
   - 트랜잭션 블록 밖 실행
   - 중복 데이터베이스 오류
9. 새 데이터베이스로 다시 연결하기
   - 새로고침
   - `Show all databases`
   - 데이터베이스 전용 연결
10. 현재 데이터베이스와 스키마 확인하기
11. DBeaver에서 데이터베이스 구조 탐색하기
12. SQL 편집기에서 문장 실행하기
   - 현재 문장
   - 선택 영역
   - 전체 스크립트
   - 자동 커밋과 오류 처리
13. 환경 검증 SQL 실행하기
14. 환경 확인 SQL 파일 저장하기
15. 접속 정보와 비밀정보 보호하기
16. 연결 오류를 유형별로 해결하기
   - 로컬 오류
   - SSL·DNS·IPv4/IPv6·연결 수 오류
17. AI에게 오류를 정확하게 질문하기
18. 실습 환경 완료 점검
   - 로컬 필수 경로
   - Supabase 선택 확인
   - 독자 워크북 연결
19. 자주 하는 실수
20. 핵심 정리
21. 다음 장 연결

## 로컬 필수 실습 흐름

```text
PostgreSQL 서버 준비
→ DBeaver Test Connection
→ postgres 데이터베이스 접속
→ CREATE DATABASE 권한과 자동 커밋 확인
→ ai_database_book 생성
→ ai_database_book으로 다시 연결
→ current_database() 확인
→ current_schema()와 SHOW search_path 확인
→ public 스키마 탐색
→ 환경 확인 SQL 7개 실행
→ setup_check.sql 저장
```

## Supabase 선택 흐름

```text
Supabase 프로젝트 구조 이해
→ 기본 postgres 데이터베이스 확인
→ Direct / Session / Transaction 연결 구분
→ PostgreSQL 메타데이터와 객체 저장소 구분
→ publishable / secret key 구분
→ RLS와 비밀정보 관리 확인
```

Supabase 선택 흐름은 로컬 필수 실습의 `ai_database_book` 생성과 완료 기준을 대체하지 않는다.

## 환경 검증 SQL

```sql
SELECT version();
SELECT current_database();
SELECT current_schema();
SHOW search_path;
SELECT current_user;
SELECT CURRENT_TIMESTAMP AS checked_at;
SELECT 1 + 1 AS result;
```

환경 검증 SQL은 데이터를 변경하지 않는 조회문만 사용한다. 여러 번 실행해도 테이블이나 데이터가 추가되지 않도록 구성한다. `CURRENT_TIMESTAMP`는 현재 트랜잭션의 시작 시각을 반환한다는 점을 정확하게 설명한다.

## 독자 참여 요소

- 자신의 운영체제와 PostgreSQL 버전 기록
- PostgreSQL과 DBeaver의 역할 구분
- Host, Port, Database, Username의 의미 작성
- 관리자 계정과 실제 애플리케이션 계정의 역할 구분
- `CREATE DATABASE` 권한·트랜잭션 조건 확인
- `ai_database_book` 생성과 새 연결 전환
- `Show all databases`와 연결 방식 확인
- 현재 데이터베이스, 스키마와 검색 경로 결과 기록
- DBeaver에서 `public` 스키마 위치 확인
- SQL 실행 범위와 자동 커밋 비교
- `setup_check.sql` 저장과 재실행
- 로컬과 관리형 PostgreSQL의 책임 범위 비교
- Supabase Storage·연결 방식·키·RLS 선택 활동
- 연결 오류 유형 분류
- 비밀정보 공개 가능 여부 판단
- 오류 메시지를 재현 가능한 AI 질문으로 변환

## AI 활용 포인트

- 오류 질문에는 운영체제, PostgreSQL 방식·버전, DBeaver 버전, 연결 방식, 마스킹한 연결값, 실행 작업, 자동 커밋 상태, 오류 원문과 이미 확인한 내용을 포함한다.
- 비밀번호, 전체 접속 URL, API 키와 Access Token은 AI 대화에 포함하지 않는다.
- Codex에는 `setup_check.sql`이 7개의 조회문만 포함해야 한다는 범위를 명확히 지정한다.
- AI가 제안한 삭제·초기화·권한 변경 명령은 목적과 대상을 이해하기 전에는 실행하지 않는다.
- Supabase의 Direct·Session·Transaction 연결 정보가 섞이지 않았는지 검토한다.
- AI 답변의 정확성은 실제 DBeaver 재실행 결과로 검증한다.

## 후속 장으로 이동하는 내용

| 내용 | 이동 장 |
| --- | --- |
| `CREATE TABLE students` | Chapter 04 |
| `INSERT`와 `SELECT` 데이터 실습 | Chapter 04 |
| `CREATE TABLE IF NOT EXISTS`와 재실행 전략 | Chapter 04 |
| 중복 이메일 `UNIQUE` 오류 | Chapter 06 |
| 제약조건 상세 검증 | Chapter 06 |
| 트랜잭션 제어와 커밋·롤백 | Chapter 09 |
| 사용자·역할·권한과 백업 | Chapter 11 |
| AI 생성 SQL의 구조·결과 검증 | Chapter 13 |

## 편집 원칙

- 설치 화면의 버튼 이름뿐 아니라 각 단계의 목적과 완료 기준을 설명한다.
- Windows를 검증 기준으로 사용하고 macOS와 Ubuntu 계열 Linux에 대표 경로를 제공한다.
- 공식 PostgreSQL·DBeaver 다운로드 주소를 안내한다.
- 특정 프로그램 버전과 서비스 이름은 검증 기준임을 명확히 한다.
- Supabase는 필수 경로가 아닌 선택 읽기로 분리한다.
- 관리형 서비스에서도 설계, 권한, RLS, 비밀정보, 비용과 복구 책임이 남는다는 점을 설명한다.
- 설치 완료보다 연결, 현재 위치 확인, SQL 실행과 재현 가능성을 완료 기준으로 사용한다.
- Chapter 02의 서버·클라이언트 개념을 짧게 복습하고 중복 설명을 줄인다.
- Chapter 04와 Chapter 06의 SQL 학습을 미리 과도하게 다루지 않는다.
- 전체 스크립트가 자동으로 원자적 실행이 되지 않는다는 안전 경고를 포함한다.
- 본문, 워크북과 실제 `setup_check.sql`의 문장 목록과 설명을 동기화한다.

## 다음 장 연결

다음 장에서는 로컬 필수 경로의 `ai_database_book` 데이터베이스의 `public` 스키마에서 첫 번째 테이블을 만들고, `INSERT`, `SELECT`, `WHERE`, `ORDER BY`, `UPDATE`, `DELETE`의 기본 흐름을 실습한다.
