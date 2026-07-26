# Chapter 03 실습 발표 강의안

## 로컬 PostgreSQL 실습 환경을 검증 파일로 확인하기

> 목적: DBeaver에서 로컬 PostgreSQL에 연결하고, `ai_database_book` 데이터베이스를 준비한 뒤 `setup_check.sql`과 `setup_validate_local.sql`로 실습 환경을 검증한다.  
> 기준: 초보자가 “무엇을 클릭하고, 어떤 SQL을 실행하고, 어떤 결과가 나오면 다음 단계로 가도 되는지”를 직관적으로 이해할 수 있어야 한다.

---

## 1. 이번 실습의 목표는 설치가 아니라 검증입니다

**화면 구성**

- 큰 제목: Chapter 03 실습 완료 기준
- 체크리스트:

```text
□ PostgreSQL 서버 실행
□ DBeaver Test Connection 성공
□ ai_database_book 연결
□ current_database() 확인
□ setup_check.sql 실행
□ setup_validate_local.sql 통과
□ 비밀정보 미기록
```

**스크립트**

이번 실습에서는 PostgreSQL과 DBeaver를 사용해 앞으로의 SQL 실습 환경을 준비합니다.

중요한 점은 설치 프로그램을 실행했다고 끝나는 것이 아니라는 점입니다. 실제로 PostgreSQL 서버가 실행 중인지, DBeaver가 연결되는지, 우리가 작업할 `ai_database_book` 데이터베이스에 연결되어 있는지 확인해야 합니다.

마지막에는 `setup_validate_local.sql`이 통과해야 합니다. 이 통과 메시지가 Chapter 03의 가장 중요한 완료 증거입니다.

---

## 2. 먼저 나의 환경을 기록합니다

**화면 구성**

| 항목 | 기록 |
| --- | --- |
| 운영체제 |  |
| PostgreSQL 사용 방식 | 로컬 / 관리형 |
| PostgreSQL 버전 |  |
| DBeaver 버전 |  |
| SQL 파일 위치 |  |
| 비밀번호 기록 여부 | 기록하지 않음 |

**스크립트**

실습을 시작하기 전에 자신의 환경을 기록합니다.

운영체제가 Windows인지, macOS인지, Linux인지에 따라 설치 방법과 서비스 이름이 달라질 수 있습니다. PostgreSQL 버전과 DBeaver 버전도 오류를 해결할 때 중요한 정보가 됩니다.

다만 비밀번호와 전체 접속 URL은 기록하지 않습니다. 공개 문서나 화면 캡처에 들어가면 안 되는 정보입니다.

---

## 3. PostgreSQL 서버가 실행 중인지 확인합니다

**화면 구성**

```text
Windows
→ 서비스 앱
→ postgresql 관련 서비스
→ 실행 중 확인

macOS·Linux
→ 설치 방식에 따라 서버 시작 방법 확인
```

**스크립트**

DBeaver 연결 전에 PostgreSQL 서버가 실행 중인지 확인합니다.

Windows에서는 서비스 앱에서 PostgreSQL 관련 서비스가 실행 중인지 확인할 수 있습니다. macOS나 Linux는 설치 방식에 따라 확인 방법이 달라질 수 있습니다.

`psql --version`이 인식되지 않아도 서버 설치가 반드시 실패한 것은 아닙니다. PATH 설정 문제일 수 있습니다. 이번 책의 기본 진행은 DBeaver 연결을 중심으로 확인합니다.

---

## 4. DBeaver에서 PostgreSQL 연결을 만듭니다

**화면 구성**

```text
New Database Connection
→ PostgreSQL 선택
→ JDBC 드라이버 다운로드
→ Host / Port / Database / Username / Password 입력
→ Test Connection
```

**스크립트**

DBeaver에서 새 데이터베이스 연결을 만듭니다. PostgreSQL을 선택하고, 드라이버 다운로드 안내가 나오면 내려받습니다.

로컬 Windows 기준으로는 Host가 `localhost`, Port가 `5432`, 처음 Database는 보통 `postgres`, Username은 초기 설정에 따라 `postgres`일 수 있습니다.

연결 정보를 넣은 뒤 Test Connection을 실행합니다. 성공하면 서버 도달과 인증, 지정 데이터베이스 접속이 가능하다는 뜻입니다.

---

## 5. Test Connection 성공 후에도 현재 DB를 확인합니다

**화면 구성**

```sql
SELECT current_database();
```

- 기대: 처음에는 `postgres`일 수 있음
- 최종 실습 DB: `ai_database_book`

**스크립트**

Test Connection이 성공했다고 해서 우리가 최종 실습 데이터베이스에 들어온 것은 아닙니다.

처음 연결은 `postgres` 데이터베이스일 수 있습니다. 이 데이터베이스는 작업용 데이터베이스를 확인하거나 생성하기 위한 출발점으로 사용할 수 있습니다.

SQL 편집기를 열고 `SELECT current_database();`를 실행해 현재 연결 대상이 어디인지 확인합니다.

---

## 6. `ai_database_book` 존재 여부를 먼저 조회합니다

**화면 구성**

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS database_owner
FROM pg_database
WHERE datname = 'ai_database_book';
```

**스크립트**

작업용 데이터베이스를 만들기 전에 이미 존재하는지 먼저 확인합니다.

결과가 0행이면 아직 없는 상태입니다. 결과가 1행이면 이미 존재하는 데이터베이스가 있다는 뜻입니다. 이 경우에는 소유자와 기존 객체 상태를 확인하고 계속 사용할지 결정합니다.

이 장에서는 자동으로 데이터베이스를 삭제하는 절차를 안내하지 않습니다. 기존 데이터베이스가 있다면 먼저 상태를 확인해야 합니다.

---

## 7. 필요한 경우 데이터베이스를 한 문장만 선택해 생성합니다

**화면 구성**

```sql
CREATE DATABASE ai_database_book;
```

체크:

```text
□ CREATE DATABASE 권한 있음
□ 같은 이름 DB 없음
□ 트랜잭션 블록 밖
□ 문장 하나만 선택
□ 개인 로컬 학습 환경
```

**스크립트**

데이터베이스가 없다면 `CREATE DATABASE ai_database_book;` 문장을 실행합니다.

이때 전체 스크립트를 실행하지 말고 이 한 문장만 선택해서 실행합니다. `CREATE DATABASE`는 트랜잭션 블록 안에서 실행할 수 없기 때문에 Auto-commit 상태와 실행 범위를 확인해야 합니다.

운영 서버나 공동 데이터베이스에서 관리자 계정으로 이 문장을 그대로 실행하면 안 됩니다. 이 예제는 개인 로컬 학습 환경을 기준으로 합니다.

---

## 8. 데이터베이스를 만든 뒤 새 DB로 다시 연결합니다

**화면 구성**

```text
CREATE DATABASE 성공
→ DBeaver Navigator 새로고침
→ ai_database_book 전용 연결 만들기 또는 연결 설정 수정
→ 새 SQL 편집기 열기
→ current_database() 확인
```

**스크립트**

데이터베이스 생성이 성공해도 기존 SQL 편집기의 연결 대상은 자동으로 바뀌지 않습니다.

DBeaver에서 연결을 새로고침하고, `ai_database_book`으로 접속하는 새 연결을 만들거나 기존 연결 설정의 Database 값을 바꿉니다.

그리고 새 SQL 편집기를 열어 다시 `SELECT current_database();`를 실행합니다. 결과가 `ai_database_book`이어야 다음 단계로 갈 수 있습니다.

---

## 9. 현재 데이터베이스·스키마·검색 경로를 확인합니다

**화면 구성**

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

기대:

```text
current_database = ai_database_book
public 스키마 존재
public USAGE 권한 있음
search_path 의미 설명 가능
```

**스크립트**

이번에는 세 가지 SQL을 실행합니다. 현재 데이터베이스, 현재 스키마, 검색 경로입니다.

`current_database()`는 반드시 `ai_database_book`이어야 합니다. `current_schema()`는 환경에 따라 `public`이 아닐 수 있습니다. 그래서 `public` 스키마가 존재하고 사용할 수 있는지 별도로 확인합니다.

`search_path`는 스키마 이름을 생략했을 때 PostgreSQL이 객체를 찾는 순서입니다. 이후 장에서는 혼동을 줄이기 위해 `public.students`처럼 스키마를 명시합니다.

---

## 10. Chapter 04 전에는 Tables가 비어 있어도 정상입니다

**화면 구성**

```text
DBeaver Navigator
→ ai_database_book
→ Schemas
→ public
→ Tables
```

- 현재 단계: Tables가 비어 있어도 정상
- Chapter 04: 첫 테이블 생성

**스크립트**

DBeaver 왼쪽 탐색기에서 `ai_database_book`, `Schemas`, `public`, `Tables`를 찾아봅니다.

지금은 Chapter 04 전이므로 Tables 아래에 아무것도 없어도 정상입니다. 아직 테이블을 만들지 않았기 때문입니다.

초보자는 테이블 목록이 비어 있으면 설치가 잘못되었다고 생각할 수 있습니다. 하지만 현재 단계에서는 연결과 스키마 확인이 목표입니다.

---

## 11. SQL 실행 범위와 커밋 모드를 확인합니다

**화면 구성**

```text
실행 전 확인
- 현재 연결
- 실행 범위
- Auto-commit / Manual commit
- 변경 SQL 포함 여부
- 오류 시 중지·계속 설정
```

**스크립트**

SQL을 실행하기 전에 항상 현재 연결과 실행 범위를 확인합니다.

특히 DBeaver에서는 현재 문장 실행, 선택 영역 실행, 전체 Script 실행이 다릅니다. 실수로 전체 Script를 실행하면 원하지 않는 SQL까지 실행될 수 있습니다.

또 Auto-commit인지 Manual commit인지도 확인합니다. Chapter 09 전까지는 변경 SQL을 작은 단위로 실행하고 결과를 확인하는 습관을 들입니다.

---

## 12. `setup_check.sql`을 실행해 환경 정보를 기록합니다

**화면 구성**

파일:

```text
code/chapter03/setup_check.sql
```

확인 항목:

```text
version()
current_database()
current_schema()
search_path
current_user
transaction_read_only
TimeZone
CURRENT_TIMESTAMP
1 + 1
한 행 요약
```

**스크립트**

이제 `setup_check.sql`을 실행합니다. 이 파일은 데이터를 만들거나 수정하지 않고 환경 정보를 조회합니다.

PostgreSQL 버전, 현재 데이터베이스, 현재 스키마, 검색 경로, 사용자, 읽기 전용 여부, 시간대, 간단한 계산 결과를 확인합니다.

이 파일의 목적은 정보를 보여 주는 것입니다. 잘못된 데이터베이스에서 실행해도 SQL 자체는 성공할 수 있으므로, 결과를 사람이 읽고 판단해야 합니다.

---

## 13. `setup_validate_local.sql`로 통과·실패를 판정합니다

**화면 구성**

파일:

```text
code/chapter03/setup_validate_local.sql
```

통과 메시지:

```text
Chapter 03 local environment validation passed
```

**스크립트**

다음으로 `setup_validate_local.sql`을 실행합니다. 이 파일은 로컬 필수 실습 환경을 자동으로 판정합니다.

PostgreSQL 15 이상인지, 현재 데이터베이스가 `ai_database_book`인지, `public` 스키마가 있고 사용할 수 있는지, 읽기 전용 연결이 아닌지 확인합니다.

모든 조건이 맞으면 `Chapter 03 local environment validation passed`라는 메시지가 나옵니다. 이 메시지가 나오면 Chapter 04로 넘어갈 수 있는 중요한 증거가 됩니다.

---

## 14. 검증 실패는 실패 원인을 알려 주는 신호입니다

**화면 구성**

예상 실패 유형:

```text
현재 데이터베이스가 ai_database_book이 아님
public 스키마가 없음
public USAGE 권한 없음
읽기 전용 연결임
PostgreSQL 버전이 낮음
```

**스크립트**

검증 파일이 실패했다고 해서 당황할 필요는 없습니다. 오히려 실패 메시지는 무엇을 고쳐야 하는지 알려 주는 신호입니다.

예를 들어 현재 데이터베이스가 `postgres`라고 나오면 `ai_database_book` 연결을 선택해야 합니다. 읽기 전용이라고 나오면 쓰기 가능한 로컬 연결인지 확인해야 합니다.

중요한 것은 실패 메시지를 복사해 두고, 한 번에 하나씩 수정한 뒤 다시 실행하는 것입니다.

---

## 15. 비밀정보가 기록되지 않았는지 확인합니다

**화면 구성**

```text
확인 대상
- SQL 파일
- README
- 워크북
- GitHub
- 화면 캡처
- AI 질문
```

금지:

```text
비밀번호
전체 접속 URL
API key
Access Token
실제 .env
password file
```

**스크립트**

환경 검증이 끝나면 비밀정보가 기록되지 않았는지 확인합니다.

SQL 파일, README, 워크북, GitHub, 화면 캡처, AI 질문에 비밀번호나 전체 접속 URL이 들어가면 안 됩니다.

오류 질문을 작성할 때도 Host와 Username은 필요하면 일부만 보여 주고, Password와 API key는 제외합니다.

---

## 16. 오류가 발생하면 재현 가능한 질문으로 정리합니다

**화면 구성**

```text
운영체제:
PostgreSQL 사용 방식:
PostgreSQL 버전:
DBeaver 버전:
연결 방식:
실행한 작업:
오류 메시지 원문:
이미 확인한 내용:
Auto-commit / Manual commit:
비밀정보 제외:
```

**스크립트**

오류가 발생하면 “DBeaver가 안 됩니다”라고만 질문하지 않습니다.

운영체제, PostgreSQL 사용 방식, 버전, 연결 방식, 실행한 작업, 오류 메시지 원문, 이미 확인한 내용을 정리합니다.

이렇게 정리하면 교수자, 동료, AI 모두 문제를 더 정확하게 도와줄 수 있습니다. 단, 비밀번호와 전체 접속 URL은 반드시 제외합니다.

---

## 17. 최종 완료 기록을 남깁니다

**화면 구성**

```markdown
## PostgreSQL 실습 환경 확인 기록
- 운영체제:
- PostgreSQL 버전:
- DBeaver 버전:
- 현재 데이터베이스:
- 현재 스키마:
- search_path:
- transaction_read_only:
- TimeZone:
- setup_check.sql 결과:
- setup_validate_local.sql 결과:
- 발생한 문제와 해결 방법:
```

**스크립트**

마지막으로 자신의 환경 확인 기록을 남깁니다.

이 기록은 나중에 오류가 발생했을 때 매우 중요합니다. 어떤 버전에서 어떤 데이터베이스에 연결했고, 어떤 검증 파일이 통과했는지 알 수 있기 때문입니다.

설치 환경은 시간이 지나면 바뀔 수 있습니다. 따라서 “한 번 연결됐다”에서 끝내지 말고 다시 확인 가능한 기록을 남기는 것이 좋습니다.

---

## 18. 다음 장으로 넘어가기 전 마지막 질문입니다

**화면 구성**

```text
나는 지금 어느 데이터베이스에 연결되어 있는가?
public 스키마를 사용할 수 있는가?
읽기·쓰기 가능한 연결인가?
setup_validate_local.sql이 통과했는가?
비밀정보를 공개하지 않았는가?
```

**스크립트**

Chapter 04에서는 처음으로 테이블을 만들고 데이터를 입력합니다. 그러기 전에 이 다섯 가지 질문에 답할 수 있어야 합니다.

현재 데이터베이스가 `ai_database_book`인지, `public` 스키마를 사용할 수 있는지, 읽기·쓰기 가능한 연결인지, 자동 검증이 통과했는지, 비밀정보를 공개하지 않았는지 확인합니다.

이 확인이 끝났다면 이제 데이터베이스 실습 환경은 준비된 것입니다.
