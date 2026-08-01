# Chapter 03 구성안

## 제목

PostgreSQL과 DBeaver로 실습 환경 만들기

## 권장 분량

18~20페이지

## 대상 독자

- PostgreSQL을 처음 설치하고 사용하는 독자
- 데이터베이스 서버와 클라이언트의 연결을 직접 확인하려는 독자
- 자신의 운영체제와 환경에 맞는 실습 경로를 선택하려는 독자
- 연결 오류와 비밀정보 노출을 스스로 점검하려는 독자

## 선수 지식

Chapter 02의 데이터베이스, DBMS, 클라이언트, 스키마와 테이블 개념을 이해했다면 별도의 선수 지식은 필요하지 않다.

## 이 장의 역할

Chapter 03은 여러 클라우드 서비스와 보안 운영 기술을 자세히 설명하는 장이 아니다. 독자가 다음 상태를 직접 만들도록 안내하는 환경 구성 장이다.

```text
PostgreSQL 서버를 준비한다.
DBeaver로 PostgreSQL에 연결한다.
작업용 데이터베이스를 준비한다.
현재 연결 대상을 확인한다.
SQL을 안전하게 실행한다.
환경을 다시 검증할 수 있다.
```

## 핵심 메시지

```text
설치가 끝났다는 사실보다
어느 서버와 데이터베이스에 연결되어 있으며
어떤 SQL을 실행하는지 확인하는 습관이 중요하다.
```

## 권장 기본 경로와 대안 경로

```text
권장 기본 경로
→ 로컬 PostgreSQL + DBeaver Community

대안 경로
→ 이미 설치된 PostgreSQL
→ macOS·Linux 로컬 PostgreSQL
→ Docker 기반 PostgreSQL
→ 관리형 PostgreSQL
```

환경이 달라도 기본 완료 기준을 만족하면 다음 장으로 진행할 수 있다. `setup_validate_local.sql`은 권장 로컬 환경을 확인하는 파일이며 관리형 환경의 절대 기준으로 사용하지 않는다.

## 이 장을 마치면

독자는 다음 작업을 수행할 수 있다.

- PostgreSQL과 DBeaver의 역할을 구분한다.
- 자신의 환경에 맞는 설치 경로를 선택한다.
- PostgreSQL 서버 상태를 확인한다.
- DBeaver에서 PostgreSQL 연결을 만든다.
- Host, Port, Database와 Username의 의미를 설명한다.
- `ai_database_book`의 존재 여부를 확인하고 필요한 경우 생성한다.
- 새 데이터베이스로 연결을 전환한다.
- 현재 데이터베이스, 사용자, 스키마와 `search_path`를 확인한다.
- SQL 한 문장, 선택 영역과 전체 스크립트 실행을 구분한다.
- `setup_check.sql`과 `setup_validate_local.sql`의 역할을 구분한다.
- 오류를 설치·서버·연결·SQL 문제로 나누어 확인한다.
- 비밀번호와 전체 접속 URL을 공개 자료에서 분리한다.

## 학습 표시

```text
핵심 학습
→ 권장 기본 환경을 준비하는 데 필요한 내용

선택 학습
→ macOS·Linux, Docker와 관리형 PostgreSQL을 사용하는 경우 참고할 내용

심화 학습
→ 권한, 비밀정보 파일과 운영 환경으로 확장되는 내용
```

## 핵심 질문

```text
PostgreSQL과 DBeaver는 각각 어떤 역할을 하는가?
나의 환경에 적합한 설치 경로는 무엇인가?
설치 성공과 서버 실행·연결·SQL 실행 성공은 어떻게 다른가?
Host·Port·Database·Username은 무엇을 의미하는가?
ai_database_book을 어떻게 확인하고 준비하는가?
데이터베이스를 만든 뒤 왜 다시 연결해야 하는가?
현재 데이터베이스와 사용자를 어떻게 확인하는가?
한 문장·선택 영역·전체 스크립트 실행은 어떻게 다른가?
환경 조회와 자동 확인 파일은 어떻게 다른가?
오류가 발생했을 때 무엇부터 확인하는가?
비밀번호와 접속 정보는 어떻게 보호하는가?
```

## 주요 개념

### 핵심 학습

- PostgreSQL 서버
- DBeaver 클라이언트
- 로컬 PostgreSQL
- Host / Port / Database / Username / Password
- `postgres` 사용자와 `postgres` 데이터베이스
- `ai_database_book`
- `CREATE DATABASE`
- 현재 연결 대상
- `current_database()`
- `current_user`
- `current_schema()`
- `search_path`
- 현재 문장·선택 영역·전체 스크립트 실행
- Auto-commit / Manual commit 미리보기
- `setup_check.sql`
- `setup_validate_local.sql`
- 오류 분류와 재실행
- 최소 비밀정보 보호 원칙

### 선택 학습

- macOS 설치 경로
- Ubuntu 계열 Linux 설치 경로
- Docker 기반 PostgreSQL
- 관리형 PostgreSQL
- Supabase 개요
- AI 오류 질문 템플릿

### 후속 장으로 이동

- 트랜잭션 상세: Chapter 09
- 사용자·역할·최소 권한: Chapter 11
- `PGPASSFILE`과 password file 운영: Chapter 11
- AI 설계·SQL 검증 절차: Chapter 13

## 본문 구성

1. 이 장에서 준비할 환경
2. PostgreSQL과 DBeaver 역할 복습
3. 나에게 맞는 설치 경로 선택하기
4. PostgreSQL 설치와 서버 상태 확인
5. DBeaver 설치하기
6. PostgreSQL 연결 만들기
7. 연결 정보 이해하기
8. 작업용 데이터베이스 준비하기
9. `ai_database_book`으로 다시 연결하기
10. 현재 데이터베이스와 스키마 확인하기
11. SQL을 안전하게 실행하기
12. 환경 확인 파일 실행하기
13. 자주 발생하는 연결 오류 해결하기
14. 비밀번호와 접속 정보 보호하기
15. 완료 점검과 다음 장

## 기본 완료 기준

```text
PostgreSQL 서버가 실행된다.
DBeaver Test Connection이 성공한다.
ai_database_book에 연결된다.
현재 데이터베이스와 사용자를 SQL로 확인한다.
한 문장과 전체 스크립트 실행을 구분한다.
setup_check.sql 결과를 읽을 수 있다.
권장 로컬 환경에서는 setup_validate_local.sql이 통과한다.
공개 파일에 비밀번호와 전체 접속 URL이 없다.
```

## 설치 경로 선택 기준

| 현재 상황 | 권장 진행 |
| --- | --- |
| Windows에서 처음 설치 | 본문 기본 경로 |
| PostgreSQL이 이미 설치됨 | 서버 상태와 버전 확인 후 연결부터 진행 |
| macOS 사용 | 선택 학습의 macOS 경로 |
| Ubuntu 계열 사용 | 선택 학습의 Ubuntu 경로 |
| 설치 권한 없음 | 관리형 또는 제공된 원격 PostgreSQL 검토 |
| Docker 경험 있음 | 컨테이너 방식 선택 가능 |

## 설치·실행 단계 구분

```text
설치 문제
→ 프로그램이나 서비스가 준비되지 않음

서버 실행 문제
→ 설치됐지만 PostgreSQL 서비스가 중지됨

연결 문제
→ 서버는 실행되지만 연결값이나 인증이 잘못됨

SQL 문제
→ 연결은 성공했지만 SQL 실행에 문제가 있음
```

## 환경 조회와 자동 확인 분리

### `setup_check.sql`

```text
환경 정보를 사람이 읽고 확인한다.
데이터를 변경하지 않는다.
여러 번 실행할 수 있다.
```

### `setup_validate_local.sql`

```text
권장 로컬 환경의 주요 조건을 자동 확인한다.
관리형 환경을 통과시키기 위해 권한을 억지로 변경하지 않는다.
실패 메시지의 항목을 확인하고 다시 실행한다.
```

## 비밀정보 원칙

Chapter 03에서는 다음 네 가지를 핵심으로 다룬다.

```text
비밀번호를 SQL 파일에 작성하지 않는다.
전체 접속 URL을 공개하지 않는다.
화면 캡처 전에 연결 정보를 확인한다.
공용 PC에서는 비밀번호 저장에 주의한다.
```

`PGPASSFILE`, 운영체제별 password file 위치, 파일 형식과 권한은 Chapter 11로 이동한다.

## Supabase 선택 학습 범위

본문에는 다음만 남긴다.

```text
Supabase는 실제 PostgreSQL을 제공한다.
Auth·Storage·Realtime 같은 기능이 연결된다.
로컬 환경과 연결 방식·권한 구조가 다를 수 있다.
```

다음 내용은 온라인 업데이트 문서 또는 별도 심화 자료로 이동한다.

```text
Direct·Session·Transaction Pooler 상세
IPv4·IPv6 차이
prepared statement 제한
API 키 종류와 중단 일정
RLS 우회
Storage 메타데이터 조작 규칙
```

## 버전 표기 원칙

본문에는 정확한 최신 패치 버전을 고정하지 않는다.

```text
이 책의 SQL은 PostgreSQL 15 이상을 기준으로 작성했다.
화면 예시는 집필 당시 버전이며 최신 버전에서는 달라질 수 있다.
```

정확한 최신 버전과 확인일은 README, 정오표 또는 설치 업데이트 문서에서 관리한다.

## 독자 참여 요소

### 핵심 활동

- 자신의 환경과 설치 방식 기록
- PostgreSQL 서버 상태 확인
- DBeaver 연결값 작성
- `ai_database_book` 존재·소유자 확인
- 새 데이터베이스 연결 전환
- 현재 데이터베이스와 사용자 확인
- 실행 범위와 Auto-commit 확인
- 환경 확인 SQL 실행
- 오류와 해결 결과 기록
- 비밀정보 노출 점검

### 선택 활동

- macOS·Linux 설치 차이
- Docker 환경 기록
- 관리형 PostgreSQL과 Supabase 개념
- AI 오류 질문 작성

### 심화 활동

- `search_path` 상세 해석
- 읽기 전용 연결
- 접속 정보 환경 변수
- 관리자와 최소 권한
- password file 개념

## 도식

본문 도식은 다음 6종을 유지한다.

```text
그림 3-1 전체 환경
그림 3-2 로컬·관리형 연결
그림 3-3 DBeaver 연결
그림 3-4 환경 정보 조회
그림 3-5 조회와 자동 확인
그림 3-6 오류 해결
```

## 편집 원칙

- 특정 화면과 버튼 위치보다 성공 상태와 확인 방법을 설명한다.
- Windows를 권장 기본 경로로 사용한다.
- 다른 운영체제와 Docker는 선택 학습으로 분리한다.
- 관리형 서비스의 빠르게 변하는 상세는 본문에서 최소화한다.
- 설치 성공, 서버 실행, 연결 성공과 SQL 실행 성공을 구분한다.
- 환경 조회와 자동 확인을 구분한다.
- 운영 보안 상세는 Chapter 11로 이동한다.
- 수업 일정·과제·평가와 연결되는 표현을 사용하지 않는다.

## 다음 장 연결

Chapter 04에서는 준비한 연결에서 `public.students` 테이블을 만들고 데이터를 입력·조회·수정·삭제한다.
