# Chapter 03 자율 학습형 개편 반영 기록

## 대상 파일

```text
book/chapter03/chapter03.md
book/chapter03/chapter03_outline.md
book/chapter03/chapter03_activity.md
book/chapter03/chapter03_review_revision.md
notes/chapter03_review_checklist.md
code/chapter03/setup_check.sql
code/chapter03/setup_validate_local.sql
```

## 개편 목적

Chapter 03을 특정 수업 환경을 강제하는 설치 안내가 아니라, 일반 독자가 자신의 환경에 맞는 경로를 선택하고 동일한 완료 상태를 확인하는 자율 학습형 장으로 정리했다.

```text
화면 위치보다 성공 상태를 설명한다.
권장 기본 경로와 대안 경로를 구분한다.
빠르게 변하는 서비스별 상세를 본문에서 줄인다.
설치·서버·연결·SQL 실행 문제를 구분한다.
환경 조회와 자동 확인을 구분한다.
운영 보안 상세는 후속 장으로 이동한다.
```

---

## 1. 대상 독자와 선수 지식

다음 내용을 장 시작 부분에 추가했다.

- PostgreSQL을 처음 설치하고 사용하는 독자를 대상으로 함
- Chapter 02의 기본 용어 외 별도 선수 지식 없음
- 운영체제와 버전에 따라 화면이 다를 수 있음을 명시
- 버튼 위치보다 기본 완료 기준을 확인하도록 안내
- PostgreSQL 15 이상을 SQL 호환 기준으로 사용

정확한 최신 패치 버전과 확인일은 본문에서 제거하고 README·정오표·설치 업데이트 문서에서 관리하도록 원칙을 변경했다.

---

## 2. 필수 경로를 권장 기본 경로로 변경

기존의 강제적인 로컬 필수 경로 표현을 다음처럼 수정했다.

```text
권장 기본 경로
→ 로컬 PostgreSQL + DBeaver Community

대안 경로
→ 기존 PostgreSQL
→ macOS·Linux 로컬 환경
→ Docker
→ 관리형 PostgreSQL
```

환경이 달라도 현재 연결 대상과 실행 권한을 알고 다음 장의 테이블 생성이 가능하면 진행할 수 있도록 설명했다.

`setup_validate_local.sql`은 관리형 환경까지 강제하는 완료 게이트가 아니라 권장 로컬 환경 자동 확인 파일로 정의했다.

---

## 3. 완료 기준 단순화

기존의 세부 점검 항목을 다음 핵심 상태로 정리했다.

```text
PostgreSQL 서버 실행
DBeaver 연결 테스트 성공
작업 데이터베이스 연결
현재 데이터베이스와 사용자 확인
SQL 실행 범위 구분
환경 확인 SQL 재실행
비밀정보 비공개
```

`current_schema`, `TimeZone`, `public USAGE`와 읽기 전용 상태는 환경 확인 결과의 참고 또는 자동 확인 항목으로 유지한다.

---

## 4. 본문 구조 19절에서 15절로 정리

최종 본문은 다음 15개 절로 구성한다.

```text
1. 이 장에서 준비할 환경
2. PostgreSQL과 DBeaver 역할 복습
3. 나에게 맞는 설치 경로 선택하기
4. PostgreSQL 설치와 서버 상태 확인
5. DBeaver 설치하기
6. PostgreSQL 연결 만들기
7. 연결 정보 이해하기
8. 작업용 데이터베이스 준비하기
9. ai_database_book으로 다시 연결하기
10. 현재 데이터베이스와 스키마 확인하기
11. SQL을 안전하게 실행하기
12. 환경 확인 파일 실행하기
13. 자주 발생하는 연결 오류 해결하기
14. 비밀번호와 접속 정보 보호하기
15. 완료 점검과 다음 장
```

AI 질문 작성, 완료 점검과 자주 하는 실수는 관련 절과 워크북에 통합했다.

---

## 5. 설치 경로 선택 안내 추가

독자의 상황에 따라 진행 경로를 선택할 수 있도록 판단표를 추가했다.

```text
Windows 처음 설치
PostgreSQL 기존 설치
macOS
Ubuntu 계열 Linux
설치 권한 없음
Docker 경험 있음
관리형 PostgreSQL 보유
```

Docker는 핵심 경로가 아니라 경험이 있는 독자를 위한 선택 학습으로 추가했다.

---

## 6. 설치 성공과 연결 성공 구분

다음 네 단계를 명확히 분리했다.

```text
설치 성공
서버 실행 성공
연결 성공
SQL 실행 성공
```

문제 해결도 설치·서버·연결·SQL 단계로 먼저 분류하도록 변경했다.

---

## 7. 연결 정보와 연결 이름 보완

Host, Port, Database, Username과 Password의 의미를 별도로 설명했다.

연결이 여러 개일 때 혼동을 줄이기 위한 이름 예시도 추가했다.

```text
local-postgres-admin
local-ai-database-book
```

연결 이름에 비밀번호와 민감정보를 포함하지 않도록 안내했다.

---

## 8. 데이터베이스 생성 안전 기준 유지

다음 원칙을 유지했다.

```text
존재 여부와 소유자를 먼저 조회한다.
기존 데이터베이스를 자동으로 삭제하지 않는다.
CREATE DATABASE는 열린 트랜잭션 밖에서 실행한다.
생성 후 새 데이터베이스로 다시 연결한다.
관리자 역할은 개인 로컬 초기 설정에 한정한다.
```

권한과 운영 역할 설계는 Chapter 11로 이동했다.

---

## 9. SQL 실행 안전 기준 단순화

실행 전 다음 세 가지를 확인하도록 압축했다.

```text
현재 연결
선택한 SQL
Auto-commit 상태
```

트랜잭션 원리는 Chapter 09로 이동하고, 이 장에서는 의도하지 않은 전체 스크립트 실행을 막는 데 집중한다.

---

## 10. 환경 조회와 자동 확인 구분

두 파일의 역할을 다음처럼 통일했다.

```text
setup_check.sql
→ 환경 정보를 사람이 확인

setup_validate_local.sql
→ 권장 로컬 환경의 주요 조건을 자동 확인
```

자동 확인을 통과시키기 위해 관리형 환경의 권한을 무리하게 변경하지 않도록 경고를 추가했다.

---

## 11. Supabase 상세 축소

본문에는 다음 개념만 남겼다.

```text
실제 PostgreSQL을 제공한다.
Auth·Storage·Realtime 같은 기능이 연결된다.
로컬과 연결 방식·권한 구조가 다를 수 있다.
```

다음 내용은 온라인 업데이트 문서 또는 별도 심화 자료로 이동했다.

```text
Pooler 종류와 포트
IPv4·IPv6
prepared statement 제한
API 키 종류와 중단 일정
RLS 우회
Storage 메타데이터 조작 규칙
```

서비스 정책이 빠르게 변경될 수 있어 일반 eBook 본문에 고정하지 않는 방향이다.

---

## 12. 비밀정보 범위 단순화

Chapter 03에서는 다음 네 가지 원칙만 핵심으로 유지한다.

```text
비밀번호를 SQL 파일에 작성하지 않는다.
전체 접속 URL을 공개하지 않는다.
화면 캡처 전에 연결 정보를 확인한다.
공용 PC에서는 비밀번호 저장에 주의한다.
```

`PGPASSFILE`, 운영체제별 password file 위치와 파일 권한은 Chapter 11로 이동했다.

비밀번호나 키가 노출되면 파일 삭제뿐 아니라 즉시 변경·폐기해야 한다는 내용은 유지했다.

---

## 13. 워크북 재구성

워크북을 다음 세 범위로 분리했다.

```text
핵심 활동
→ 서버 상태, DBeaver 연결, 작업 DB, 실행 범위, 환경 확인, 오류 기록

선택 활동
→ macOS·Linux, Docker, 관리형 PostgreSQL, Supabase, AI 오류 질문

심화 활동
→ search_path, 읽기 전용 상태, 접속 변수, 최소 권한과 password file 연결
```

본문과 워크북의 통과 메시지와 용어를 동일하게 맞췄다.

---

## 14. 장 간 범위 정리

| 내용 | 이동 위치 |
| --- | --- |
| 테이블과 CRUD | Chapter 04 |
| 관계와 외래키 설계 | Chapter 05 |
| 제약조건 오류 | Chapter 06 |
| 트랜잭션 상세 | Chapter 09 |
| 사용자·역할·최소 권한 | Chapter 11 |
| password file과 `PGPASSFILE` | Chapter 11 |
| AI 설계·SQL 검증 | Chapter 13 |

---

## 최종 상태

Chapter 03은 다음 질문에 답하는 장으로 정리되었다.

```text
PostgreSQL 서버를 준비하고 DBeaver로 작업용 데이터베이스에 연결한 뒤,
현재 환경을 확인하고 안전하게 SQL을 실행할 수 있는가?
```

---

## 최종 출판 검수 추가 반영

최종 PDF 제작 전 Chapter 04의 실제 테이블 생성 조건과 다시 교차 검토해 다음을 보완했다.

```text
DBeaver Test Connection 성공과 실제 객체 생성 권한을 구분
current_schema()를 search_path의 첫 사용 가능 스키마로 정확히 표현
transaction_read_only = off와 실제 쓰기 권한을 구분
public USAGE뿐 아니라 CREATE 권한도 로컬 자동 확인에 추가
setup_check.sql 한 행 요약에 public CREATE 상태 추가
permission denied for schema public 오류 점검 추가
본문의 Chapter 03 SQL 파일 경로를 독자용 링크로 변경
code/chapter03/README.md의 통과 메시지를 실제 SQL과 일치시킴
```

`setup_validate_local.sql`은 이제 Chapter 04에서 `CREATE TABLE public.students`를 실행할 권장 로컬 환경인지 판단할 때 `public`의 `USAGE`와 `CREATE`를 모두 확인한다. `transaction_read_only = off`만으로 실제 변경 권한이 보장되는 것은 아니라는 점도 본문에 명시했다.

