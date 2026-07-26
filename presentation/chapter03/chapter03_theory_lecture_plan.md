# Chapter 03 이론 발표 강의안

## PostgreSQL과 DBeaver로 실습 환경 만들기

> 목적: 초보자가 PostgreSQL 서버, DBeaver 클라이언트, 데이터베이스, 연결 정보, 스키마, 실행 범위와 검증 파일의 역할을 혼동하지 않도록 설명한다.  
> 기준: 학생이 “설치했다”가 아니라 “올바른 데이터베이스에 연결했고, 이후 실습을 실행할 준비가 되었는지 검증했다”라고 말할 수 있어야 한다.

---

## 1. Chapter 03은 설치 수업이 아니라 연결 검증 수업입니다

**화면 구성**

- 큰 제목: 설치 완료 ≠ 실습 준비 완료
- 흐름:

```text
PostgreSQL 서버 실행
→ DBeaver 연결
→ ai_database_book 확인·생성
→ 새 DB로 다시 연결
→ 현재 DB·스키마·search_path 확인
→ setup_check.sql 실행
→ setup_validate_local.sql 통과
```

**스크립트**

Chapter 03에서는 PostgreSQL과 DBeaver를 준비합니다. 그런데 이 장의 목표는 단순히 설치 프로그램을 실행하는 것이 아닙니다.

설치가 끝나도 실제로 서버가 실행 중인지, DBeaver가 올바른 데이터베이스에 연결되어 있는지, 이후 장에서 테이블을 만들 수 있는 쓰기 가능한 연결인지 확인해야 합니다.

그래서 이 장의 핵심 문장은 “설치했다”가 아니라 “검증했다”입니다. 마지막에는 `setup_validate_local.sql`이 통과해야 Chapter 04 이후의 실습을 안정적으로 진행할 수 있습니다.

---

## 2. 먼저 역할을 나눕니다: PostgreSQL, DBeaver, SQL 파일

**화면 구성**

| 구성 요소 | 역할 |
| --- | --- |
| PostgreSQL | 데이터를 저장하고 SQL을 실행하는 DBMS |
| DBeaver | PostgreSQL에 접속해 SQL을 보내고 결과를 보여 주는 클라이언트 |
| SQL 파일 | 같은 확인 절차를 다시 실행할 수 있게 남기는 실행 기록 |
| 사용자 | 연결 대상과 실행 결과가 맞는지 판단 |

**스크립트**

PostgreSQL과 DBeaver는 같은 프로그램이 아닙니다. PostgreSQL은 데이터를 저장하고 SQL을 실제로 실행하는 DBMS입니다.

DBeaver는 그 PostgreSQL에 접속해 SQL을 보내고 결과를 화면에 보여 주는 클라이언트입니다. DBeaver를 닫아도 데이터가 사라지는 것은 아니고, 반대로 DBeaver만 설치했다고 데이터베이스 서버가 생기는 것도 아닙니다.

SQL 파일은 실습 과정을 다시 실행할 수 있게 남기는 기록입니다. 이번 장에서는 특히 환경을 조회하는 파일과 통과·실패를 판정하는 파일을 구분합니다.

---

## 3. 로컬 필수 경로와 Supabase 선택 경로를 섞지 않습니다

**화면 구성**

- 왼쪽: 로컬 필수 경로
- 오른쪽: Supabase 선택 읽기

```text
로컬 필수 경로
- 내 컴퓨터의 PostgreSQL
- ai_database_book 사용
- Chapter 04 이후 실습 기준

Supabase 선택 경로
- 관리형 PostgreSQL 이해
- 기본 DB 이름과 연결 방식이 다를 수 있음
- 필수 실습 대체 경로로 사용하지 않음
```

**스크립트**

이 장에는 로컬 PostgreSQL과 Supabase 설명이 함께 나옵니다. 초보자가 가장 많이 헷갈리는 부분은 두 경로를 섞는 것입니다.

이 책의 필수 실습 경로는 로컬 PostgreSQL입니다. 이후 장의 SQL은 `ai_database_book`이라는 로컬 작업용 데이터베이스를 기준으로 진행됩니다.

Supabase는 관리형 PostgreSQL의 구조를 이해하기 위한 선택 읽기입니다. Supabase 프로젝트의 기본 데이터베이스 이름이나 연결 방식은 로컬 필수 경로와 다를 수 있으므로, 필수 실습을 그대로 대체한다고 생각하면 안 됩니다.

---

## 4. 연결 정보는 “어디에, 누구로, 어떤 DB에” 접속하는지 설명합니다

**화면 구성**

| 항목 | 의미 | 로컬 예시 |
| --- | --- | --- |
| Host | 서버 위치 | `localhost` |
| Port | 접속 통로 | `5432` |
| Database | 접속할 데이터베이스 | 처음에는 `postgres`, 이후 `ai_database_book` |
| Username | 접속 역할 | 보통 초기에는 `postgres` |
| Password | 인증 정보 | 공개 문서에 기록하지 않음 |

**스크립트**

DBeaver 연결 화면에서 Host, Port, Database, Username, Password를 입력합니다. 이 값들은 단순 설정값이 아니라 “어디에, 누구로, 어떤 데이터베이스에 접속하는가”를 설명합니다.

처음에는 기본 데이터베이스인 `postgres`에 접속해 작업용 데이터베이스가 있는지 확인할 수 있습니다. 이후 `ai_database_book`을 만들었다면 반드시 새 데이터베이스로 다시 연결해야 합니다.

비밀번호는 인증 정보이므로 화면 캡처, README, GitHub, AI 질문에 그대로 넣지 않습니다.

---

## 5. `postgres` 사용자는 데이터베이스가 아닙니다

**화면 구성**

```text
postgres 사용자
→ 로그인 역할, 권한을 가진 계정

postgres 데이터베이스
→ 처음 접속용으로 자주 사용하는 기본 데이터베이스

ai_database_book
→ 이 책의 로컬 필수 실습 데이터베이스
```

**스크립트**

초보자가 자주 하는 실수 중 하나가 `postgres`라는 이름을 하나로만 이해하는 것입니다.

`postgres` 사용자는 접속 계정입니다. 반면 `postgres` 데이터베이스는 처음 접속할 때 자주 사용하는 기본 데이터베이스입니다. 둘은 이름이 같을 수 있지만 역할이 다릅니다.

이 책의 실제 작업 데이터베이스는 `ai_database_book`입니다. 따라서 이후 실습에서는 현재 데이터베이스가 `ai_database_book`인지 계속 확인해야 합니다.

---

## 6. 데이터베이스를 만들었다고 연결 대상이 자동으로 바뀌지 않습니다

**화면 구성**

```text
postgres DB에 연결
→ CREATE DATABASE ai_database_book 실행
→ DBeaver 새로고침
→ ai_database_book 연결 생성 또는 수정
→ 새 SQL 편집기 열기
→ SELECT current_database(); 확인
```

**스크립트**

`CREATE DATABASE ai_database_book;`가 성공해도 기존 SQL 편집기의 연결 대상이 자동으로 바뀌지는 않습니다.

예를 들어 `postgres` 데이터베이스에 연결된 상태에서 새 데이터베이스를 만들면, 현재 편집기는 여전히 `postgres`에 연결되어 있을 수 있습니다.

따라서 데이터베이스를 만든 다음에는 DBeaver에서 새로고침하고, `ai_database_book` 전용 연결을 만들거나 연결 설정을 수정한 뒤 새 SQL 편집기를 열어야 합니다. 그리고 반드시 `SELECT current_database();`로 확인합니다.

---

## 7. 현재 위치는 SQL로 확인합니다

**화면 구성**

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

- `current_database()` = 현재 연결된 데이터베이스
- `current_schema()` = 현재 검색 경로에서 실제로 사용할 첫 스키마
- `search_path` = 스키마 이름을 생략했을 때 찾는 순서

**스크립트**

DBeaver 화면에서 어떤 연결을 선택했는지 보는 것도 중요하지만, 최종 확인은 SQL로 해야 합니다.

`current_database()`는 지금 어느 데이터베이스에 연결되어 있는지 알려 줍니다. 이 책의 필수 경로에서는 `ai_database_book`이어야 합니다.

`current_schema()`는 항상 `public`이라고 가정하면 안 됩니다. 검색 경로와 실제 존재하는 스키마에 따라 달라질 수 있습니다. 그래서 Chapter 04 이후에는 `public.students`처럼 스키마 이름을 명시해 대상을 분명히 합니다.

---

## 8. `current_schema() = public`만 완료 기준으로 삼지 않습니다

**화면 구성**

```text
확인해야 할 것
1. current_database() = ai_database_book
2. public 스키마가 존재함
3. 현재 사용자가 public에 USAGE 권한이 있음
4. search_path 결과를 설명할 수 있음
```

**스크립트**

Chapter 03의 중요한 보완점은 `current_schema()` 결과만 보고 판단하지 않는 것입니다.

일부 환경에서는 사용자 이름과 같은 스키마가 먼저 존재해서 `current_schema()`가 `public`이 아닐 수 있습니다. 이것이 곧 실패는 아닙니다.

중요한 것은 `ai_database_book`에 연결되어 있고, `public` 스키마가 존재하며, 현재 사용자가 그 스키마를 사용할 권한이 있다는 점입니다. 그리고 `search_path`가 어떤 순서로 객체를 찾는지 설명할 수 있어야 합니다.

---

## 9. SQL 실행 범위는 반드시 확인합니다

**화면 구성**

| 실행 방식 | 의미 | 주의점 |
| --- | --- | --- |
| Statement 실행 | 현재 SQL 문장 실행 | 커서 위치 확인 |
| 선택 영역 실행 | 선택한 SQL만 실행 | 선택 범위 확인 |
| Script 실행 | 여러 문장 실행 | 의도하지 않은 변경 위험 |

**스크립트**

DBeaver에서 SQL을 실행할 때는 무엇을 실행하는지 확인해야 합니다.

Statement 실행은 커서가 있는 현재 문장을 실행합니다. 선택 영역 실행은 마우스로 선택한 SQL만 실행합니다. Script 실행은 파일이나 편집기의 여러 문장을 실행할 수 있습니다.

초보자는 실수로 전체 Script를 실행해 의도하지 않은 변경 SQL까지 실행할 수 있습니다. Chapter 09에서 트랜잭션을 배우기 전까지는 변경 SQL을 한 문장 또는 확인한 선택 영역 단위로 실행하는 습관이 중요합니다.

---

## 10. Auto-commit은 “성공한 변경이 언제 확정되는가”의 문제입니다

**화면 구성**

```text
Auto-commit
→ 변경 SQL이 성공하면 즉시 확정될 수 있음

Manual commit
→ Commit 전까지 확정되지 않을 수 있음
→ 필요하면 Rollback 가능
```

**스크립트**

Auto-commit은 SQL 실행 결과가 언제 확정되는지와 관련된 설정입니다.

Auto-commit 상태에서는 변경 SQL이 성공하면 즉시 확정될 수 있습니다. Manual commit 상태에서는 명시적으로 Commit해야 확정되고, 그 전에는 Rollback할 수 있습니다.

이번 장에서는 트랜잭션을 깊게 다루지 않습니다. 다만 변경 SQL을 실행하기 전에 현재 연결, 실행 범위, 커밋 모드를 확인해야 한다는 원칙만 잡고 넘어갑니다.

---

## 11. `setup_check.sql`과 `setup_validate_local.sql`은 역할이 다릅니다

**화면 구성**

| 파일 | 역할 | 결과 해석 |
| --- | --- | --- |
| `setup_check.sql` | 환경 정보를 조회하고 기록 | 사람이 읽고 판단 |
| `setup_validate_local.sql` | 필수 조건을 예외 기반으로 자동 판정 | 통과 또는 중단 |

**스크립트**

Chapter 03에는 두 개의 중요한 SQL 파일이 있습니다.

`setup_check.sql`은 PostgreSQL 버전, 현재 데이터베이스, 현재 스키마, 검색 경로, 사용자, 읽기 전용 상태, 시간대 같은 정보를 보여 줍니다. 이 파일은 정보를 확인하고 기록하기 위한 파일입니다.

반면 `setup_validate_local.sql`은 필수 조건이 맞지 않으면 예외를 발생시켜 중단합니다. 따라서 이 파일이 통과해야 로컬 필수 실습 환경이 준비되었다고 판단할 수 있습니다.

---

## 12. Test Connection 성공은 쓰기 가능까지 보장하지 않습니다

**화면 구성**

```text
Test Connection 성공
→ 서버 도달
→ 사용자 인증
→ 지정 DB 접속 가능

추가 확인 필요
→ current_database()
→ transaction_read_only
→ public 스키마와 권한
→ setup_validate_local.sql
```

**스크립트**

DBeaver의 Test Connection이 성공하면 서버에 도달했고, 사용자 인증이 되었고, 지정한 데이터베이스에 접속할 수 있다는 뜻입니다.

하지만 이것만으로 이후 실습이 모두 가능한 것은 아닙니다. 잘못된 데이터베이스에 연결되어 있을 수도 있고, 읽기 전용 연결일 수도 있습니다.

그래서 `current_database()`, `transaction_read_only`, `public` 스키마 존재와 권한을 확인하고, 마지막에는 자동 검증 파일을 실행해야 합니다.

---

## 13. 비밀정보는 학습 기록과 분리합니다

**화면 구성**

```text
공개 가능
- 변수 이름
- 포트 번호처럼 일반적인 값
- 일부 마스킹한 오류 정보

공개 금지
- 실제 비밀번호
- 전체 접속 URL
- API key
- Access Token
- 실제 .env와 password file
```

**스크립트**

실습 환경을 기록할 때도 비밀정보를 그대로 남기면 안 됩니다.

Host나 Username도 환경에 따라 민감할 수 있으므로 공개 자료에는 일부만 마스킹하는 것이 좋습니다. 비밀번호, 전체 클라우드 접속 문자열, API 키와 Access Token은 절대 공개 저장소나 AI 질문에 넣지 않습니다.

후속 장에서는 `PGPASSFILE`처럼 비밀번호를 코드와 환경 변수에서 분리하는 방식을 사용합니다.

---

## 14. 오류 해결은 한 번에 하나씩 확인합니다

**화면 구성**

```text
오류 원문 읽기
→ Host·Port·Database·Username 확인
→ 서버·네트워크·인증·권한·DB·스키마·트랜잭션·SQL로 분류
→ 하나만 수정
→ 다시 실행
→ 결과 기록
```

**스크립트**

연결 오류가 나면 여러 설정을 한꺼번에 바꾸고 싶어집니다. 하지만 그렇게 하면 무엇이 원인이었는지 알기 어렵습니다.

먼저 오류 메시지를 생략하지 않고 읽습니다. 그다음 Host, Port, Database, Username을 확인합니다. 오류를 서버 문제, 네트워크 문제, 인증 문제, 권한 문제, 데이터베이스나 스키마 문제, 트랜잭션 문제, SQL 문제 중 어디에 가까운지 분류합니다.

그리고 한 번에 하나의 설정만 바꾼 뒤 같은 작업을 다시 실행합니다. 해결 과정은 반드시 기록합니다.

---

## 15. AI에게 질문할 때는 재현 가능한 정보만 제공합니다

**화면 구성**

```text
좋지 않은 질문
DBeaver가 안 됩니다. 해결해 주세요.

좋은 질문
- 운영체제
- PostgreSQL 사용 방식
- DBeaver 버전
- 연결 방식
- 마스킹한 Host·Port·Database·Username
- 실행한 작업
- 오류 메시지 원문
- 이미 확인한 내용
- 비밀정보 제외
```

**스크립트**

AI에게 오류를 물어볼 때도 좋은 질문과 좋지 않은 질문이 있습니다.

“DBeaver가 안 됩니다”만으로는 원인을 찾기 어렵습니다. 운영체제, 로컬인지 관리형인지, 버전, 연결 방식, 실행한 작업, 오류 메시지 원문이 필요합니다.

다만 비밀번호, 전체 접속 URL, API 키와 Access Token은 제외해야 합니다. AI 답변은 참고 자료이고, 최종 판단은 실제 DBeaver에서 다시 실행한 결과로 합니다.

---

## 16. Chapter 03의 완료 기준을 한 문장으로 정리합니다

**화면 구성**

```text
PostgreSQL에 연결되고,
ai_database_book에서 SQL을 실행하며,
public 스키마를 사용할 수 있고,
읽기·쓰기 가능한 연결임을 확인하고,
같은 환경 점검을 다시 재현할 수 있다.
```

**스크립트**

Chapter 03의 완료 기준은 설치 파일을 실행했다는 사실이 아닙니다.

PostgreSQL에 연결되어야 하고, `ai_database_book`에서 SQL을 실행해야 하며, `public` 스키마를 사용할 수 있어야 합니다. 또한 읽기·쓰기 가능한 연결인지 확인하고, 같은 환경 점검을 다시 재현할 수 있어야 합니다.

이 기준이 충족되면 다음 장에서 첫 번째 테이블을 만들고 데이터를 직접 다룰 준비가 된 것입니다.
