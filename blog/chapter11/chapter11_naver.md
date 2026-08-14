# [AI 시대의 데이터베이스 입문 11] PostgreSQL 보안과 백업·복구를 한 번에 이해하기

안녕하세요. 아토믹데브입니다.

지난 Chapter 10에서는 인덱스와 실행 계획을 사용해 SQL 성능을 검증하는 방법을 살펴봤습니다.

이번 시간에는 데이터베이스 운영에서 매우 중요한 두 가지 주제인 **보안**과 **백업·복구**를 함께 다룹니다.

데이터베이스가 아무리 빠르게 동작해도 모든 사용자가 모든 데이터를 조회·수정할 수 있다면 안전한 시스템이 아닙니다. 반대로 권한을 잘 제한했더라도 장애가 발생했을 때 백업을 복원할 수 없다면 역시 운영 가능한 시스템이라고 보기 어렵습니다.

이번 Chapter의 핵심은 다음 한 문장입니다.

```text
필요한 권한만 허용하고,
백업은 실제 복원까지 성공해야 한다.
```

---

## 오늘 배울 내용

이번 글을 끝까지 따라오면 다음 내용을 이해할 수 있습니다.

- 인증, 권한, 소유권의 차이
- PostgreSQL Role의 기본 구조
- `LOGIN`, `NOLOGIN`
- 최소 권한 원칙
- `GRANT`, `REVOKE`
- `PUBLIC` 권한 확인
- 데이터베이스·스키마·테이블 권한의 차이
- SQL Injection과 파라미터 바인딩
- 비밀번호와 접속 URL 관리
- `pg_dump`, `pg_restore`를 이용한 백업·복원
- 백업 파일을 실제 복원해서 검증하는 방법
- RPO와 RTO
- AI가 만든 보안·복구 명령을 검토하는 방법

---

## STEP 1. 보안은 무엇을 막는 것보다 무엇을 허용할지 정하는 일입니다

데이터베이스 보안이라고 하면 해킹이나 외부 공격부터 떠올리기 쉽습니다.

하지만 실제 운영에서는 다음과 같은 문제도 자주 발생합니다.

```text
개발자가 실수로 운영 DB에서 DELETE 실행
앱 계정이 DROP TABLE 권한까지 보유
보고서 계정이 개인정보 전체 조회 가능
공개 Git 저장소에 비밀번호 포함
백업 파일이 공유 폴더에 그대로 노출
```

따라서 보안 설계는 다음 질문에서 시작합니다.

```text
이 사용자는 실제로 어떤 작업을 해야 하는가?
```

예를 들어 보고서 사용자는 데이터를 읽기만 하면 됩니다.

```text
필요 권한
→ SELECT

불필요 권한
→ INSERT
→ UPDATE
→ DELETE
→ DROP
→ ALTER
```

이것이 **최소 권한 원칙(Least Privilege)** 입니다.

---

## STEP 2. 인증, 권한, 소유권을 구분해 봅시다

세 개념을 혼동하면 권한 설계가 어려워집니다.

| 개념 | 핵심 질문 | 예 |
| --- | --- | --- |
| 인증 | 누가 접속했는가? | 사용자 계정, 비밀번호 |
| 권한 | 무엇을 할 수 있는가? | SELECT, INSERT, UPDATE |
| 소유권 | 누가 객체를 관리하는가? | 테이블 owner |

예를 들어 어떤 사용자가 PostgreSQL 로그인에 성공했다고 해서 모든 테이블을 읽을 수 있는 것은 아닙니다.

```text
로그인 성공
≠ 모든 데이터 접근 가능
```

또한 테이블의 소유자는 일반 사용자보다 훨씬 강한 권한을 가질 수 있습니다.

따라서 애플리케이션 계정을 테이블 소유자로 사용하는 것은 피하는 것이 좋습니다.

---

## STEP 3. PostgreSQL의 Role을 이해해 봅시다

PostgreSQL은 사용자와 권한 묶음을 모두 **Role**이라는 개념으로 관리합니다.

Role은 크게 두 가지 방식으로 생각할 수 있습니다.

```text
LOGIN Role
→ 실제 접속 가능

NOLOGIN Role
→ 권한 묶음으로 사용
```

예를 들어 다음과 같이 역할을 나눌 수 있습니다.

| 역할 | LOGIN 여부 | 목적 |
| --- | --- | --- |
| owner_role | NOLOGIN | 객체 소유 |
| report_reader | NOLOGIN | 조회 권한 묶음 |
| app_role | NOLOGIN | 앱 실행 권한 묶음 |
| backup_reader | NOLOGIN | 백업 권한 묶음 |
| report_user | LOGIN | 보고서 사용자 |
| app_user | LOGIN | 앱 접속 계정 |
| backup_user | LOGIN | 백업 실행 계정 |

권한 역할과 로그인 역할을 분리하면 운영이 훨씬 깔끔해집니다.

---

## STEP 4. Role을 생성하는 기본 문법

관리자 권한이 있는 테스트 환경에서는 다음과 같은 SQL을 사용할 수 있습니다.

```sql
CREATE ROLE report_reader NOLOGIN;
CREATE ROLE app_role NOLOGIN;
CREATE ROLE backup_reader NOLOGIN;

CREATE ROLE report_user LOGIN;
CREATE ROLE app_user LOGIN;
CREATE ROLE backup_user LOGIN;
```

실제 비밀번호를 SQL 파일에 직접 넣는 것은 피해야 합니다.

예를 들어 다음과 같은 파일을 공개 저장소에 올리면 안 됩니다.

```text
password.sql
.env
connection.txt
backup_commands.txt
```

특히 다음 정보는 공개 자료에서 분리해야 합니다.

```text
비밀번호
전체 접속 URL
API Key
토큰
개인정보가 포함된 백업 파일
```

---

## STEP 5. 권한 역할을 로그인 사용자에게 부여합니다

예를 들어 `report_reader` 역할에 조회 권한을 모아두고 `report_user`에게 부여할 수 있습니다.

```sql
GRANT report_reader TO report_user;
```

이제 `report_user`는 직접 테이블 권한을 하나씩 받는 대신 `report_reader` 역할을 통해 권한을 사용할 수 있습니다.

이 구조의 장점은 다음과 같습니다.

```text
권한 관리 단순화
여러 사용자에게 동일 권한 재사용
역할 변경 시 사용자별 반복 수정 감소
```

---

## STEP 6. 데이터베이스 권한과 테이블 권한은 다릅니다

PostgreSQL에서는 권한이 여러 계층으로 나뉩니다.

```text
데이터베이스
→ 스키마
→ 테이블
→ 컬럼
→ 시퀀스
```

예를 들어 어떤 사용자가 데이터베이스에 접속할 수 있더라도 스키마 사용 권한이 없으면 테이블에 접근하지 못할 수 있습니다.

대표 권한을 정리하면 다음과 같습니다.

| 대상 | 대표 권한 |
| --- | --- |
| DATABASE | CONNECT, CREATE |
| SCHEMA | USAGE, CREATE |
| TABLE | SELECT, INSERT, UPDATE, DELETE |
| SEQUENCE | USAGE, SELECT, UPDATE |

---

## STEP 7. 읽기 전용 역할을 만들어 봅시다

예를 들어 `security_lab` 스키마의 데이터를 읽기만 허용한다고 가정해 보겠습니다.

```sql
GRANT USAGE
ON SCHEMA security_lab
TO report_reader;
```

그리고 테이블 조회 권한을 부여합니다.

```sql
GRANT SELECT
ON ALL TABLES IN SCHEMA security_lab
TO report_reader;
```

이제 `report_reader`는 해당 스키마의 기존 테이블을 조회할 수 있습니다.

하지만 새로 만들어지는 테이블에도 자동 적용될지는 별도로 확인해야 합니다.

---

## STEP 8. 미래에 만들어질 테이블 권한도 생각해야 합니다

현재 존재하는 테이블에만 권한을 부여하면 이후 새 테이블이 추가될 때 권한이 빠질 수 있습니다.

PostgreSQL에서는 Default Privileges를 사용할 수 있습니다.

```sql
ALTER DEFAULT PRIVILEGES
IN SCHEMA security_lab
GRANT SELECT ON TABLES TO report_reader;
```

이 기능은 **누가 새 객체를 생성하는지**에 따라 적용 범위가 달라질 수 있으므로 실제 owner 역할 기준으로 검토해야 합니다.

---

## STEP 9. PUBLIC 권한도 반드시 확인합니다

PostgreSQL에는 `PUBLIC`이라는 특수한 개념이 있습니다.

`PUBLIC`은 특정 사용자 한 명이 아니라 모든 Role을 대상으로 하는 기본 권한 집합처럼 이해할 수 있습니다.

예를 들어 특정 권한을 직접 제거했는데도 사용자가 여전히 접근할 수 있다면 다음 경로를 확인해야 합니다.

```text
직접 GRANT
역할 멤버십
PUBLIC
객체 소유권
상위 역할 권한
```

단순히 한 줄의 `REVOKE`만 보고 권한이 제거됐다고 판단하면 안 됩니다.

---

## STEP 10. GRANT와 REVOKE를 사용해 봅시다

권한 부여는 `GRANT`입니다.

```sql
GRANT SELECT
ON security_lab.students
TO report_reader;
```

권한 제거는 `REVOKE`입니다.

```sql
REVOKE SELECT
ON security_lab.students
FROM report_reader;
```

하지만 앞에서 설명했듯이 사용자가 다른 역할이나 `PUBLIC`을 통해 같은 권한을 가지고 있다면 여전히 조회가 가능할 수 있습니다.

따라서 **유효 권한을 실제로 확인**해야 합니다.

---

## STEP 11. 실제 허용·차단 동작을 확인해야 합니다

권한 설정은 SQL 문장이 실행됐다고 끝난 것이 아닙니다.

예를 들어 읽기 전용 사용자는 다음 작업이 성공해야 합니다.

```sql
SELECT *
FROM security_lab.students;
```

하지만 다음 작업은 실패해야 합니다.

```sql
DELETE FROM security_lab.students;
```

즉 권한 테스트는 두 가지를 모두 확인해야 합니다.

```text
허용해야 할 작업 → 실제 성공
차단해야 할 작업 → 실제 실패
```

이것이 중요합니다.

---

## STEP 12. ALL PRIVILEGES를 습관적으로 사용하지 않습니다

초보자가 권한 오류를 만나면 다음과 같이 해결하고 싶을 수 있습니다.

```sql
GRANT ALL PRIVILEGES ...
```

테스트에서는 빠르게 해결되는 것처럼 보일 수 있습니다.

하지만 운영에서는 불필요한 권한까지 함께 부여될 수 있습니다.

따라서 다음 질문을 먼저 합니다.

```text
이 계정이 실제로 필요한 작업은 무엇인가?
```

그 작업에 필요한 권한만 부여합니다.

---

## STEP 13. SQL Injection도 데이터베이스 보안의 일부입니다

다음과 같이 문자열을 직접 연결해서 SQL을 만드는 방식은 위험할 수 있습니다.

```python
sql = "SELECT * FROM users WHERE email = '" + email + "'"
```

외부 입력이 SQL 구조를 바꿀 수 있기 때문입니다.

대신 사용하는 것이 **파라미터 바인딩**입니다.

개념적으로 다음과 같습니다.

```text
SQL 구조
+
사용자 입력값
→ 서로 분리해서 전달
```

AI에게 SQL이나 Python 코드를 만들어 달라고 요청할 때도 문자열 연결 방식인지 반드시 확인해야 합니다.

---

## STEP 14. 백업은 파일 생성으로 끝나지 않습니다

PostgreSQL 논리 백업에는 `pg_dump`를 사용할 수 있습니다.

예를 들어 custom format으로 백업하면 다음과 같습니다.

```bash
pg_dump -Fc -d ai_database_book -f ai_database_book.backup
```

`-Fc`는 custom format을 의미합니다.

이 형식은 `pg_restore`로 복원할 수 있습니다.

하지만 다음 명령이 성공했다고 해서 백업이 완전히 검증된 것은 아닙니다.

```text
pg_dump 성공
→ 백업 파일 생성 성공

복구 가능 확인
→ 별도 DB에 실제 복원 성공
```

---

## STEP 15. 백업 파일은 매우 민감한 데이터입니다

백업 파일에는 실제 데이터가 그대로 포함될 수 있습니다.

따라서 다음 위치에 함부로 저장하면 안 됩니다.

```text
공개 GitHub 저장소
공개 Google Drive 링크
Slack 공개 채널
개인정보 보호가 없는 공유 폴더
```

백업 파일도 데이터베이스와 동일한 수준으로 보호해야 합니다.

---

## STEP 16. custom archive의 내용을 확인해 봅시다

백업 파일을 복원하기 전에 목록을 확인할 수 있습니다.

```bash
pg_restore -l ai_database_book.backup
```

이 명령을 통해 어떤 객체가 포함되어 있는지 확인할 수 있습니다.

예를 들어 다음 항목을 살펴봅니다.

```text
스키마
테이블
시퀀스
제약조건
데이터
권한 관련 정보
```

---

## STEP 17. 반드시 별도 데이터베이스에 복원해 봅니다

운영 또는 원본 데이터베이스에 바로 복원 테스트를 하면 위험합니다.

별도의 복원용 데이터베이스를 준비하는 것이 좋습니다.

예를 들어 다음과 같이 생성할 수 있습니다.

```sql
CREATE DATABASE ai_database_book_restore_test;
```

그 뒤 터미널에서 복원합니다.

```bash
pg_restore \
  -d ai_database_book_restore_test \
  ai_database_book.backup
```

환경에 따라 사용자, 호스트, 포트 옵션이 추가될 수 있습니다.

핵심은 다음입니다.

```text
원본 DB
→ 백업
→ 별도 복원 DB
→ 실제 검증
```

---

## STEP 18. 복원 후에는 데이터와 구조를 모두 확인합니다

복원 명령이 종료됐다고 끝난 것이 아닙니다.

다음과 같은 항목을 확인해야 합니다.

```text
필요한 스키마가 존재하는가?
필요한 테이블이 존재하는가?
행 수가 예상과 같은가?
PK와 FK가 존재하는가?
UNIQUE와 CHECK 제약조건이 살아 있는가?
인덱스가 존재하는가?
IDENTITY와 시퀀스가 정상인가?
```

예를 들어 다음처럼 행 수를 확인할 수 있습니다.

```sql
SELECT COUNT(*)
FROM course_project.students;
```

```sql
SELECT COUNT(*)
FROM course_project.enrollments;
```

원본 기준값과 비교합니다.

---

## STEP 19. 권한은 복원 후 다시 검증해야 합니다

복원 시 `--no-owner`, `--no-acl` 같은 옵션을 사용했는지에 따라 소유권과 권한 상태가 달라질 수 있습니다.

또한 복원 대상 서버에 원본 Role이 존재하지 않을 수도 있습니다.

따라서 복원 후 다음 순서가 안전합니다.

```text
1. 구조와 데이터 복원 확인
2. 필요한 Role과 권한 재적용
3. 허용 작업 테스트
4. 차단 작업 테스트
```

백업 검증은 단순 행 수 확인만으로 끝나지 않습니다.

---

## STEP 20. 백업 파일의 해시도 기록할 수 있습니다

백업 파일이 전송 과정에서 바뀌지 않았는지 확인하려면 해시를 사용할 수 있습니다.

Windows PowerShell에서는 다음과 같이 확인할 수 있습니다.

```powershell
Get-FileHash .\ai_database_book.backup -Algorithm SHA256
```

Linux 또는 macOS에서는 환경에 따라 다음 명령을 사용할 수 있습니다.

```bash
sha256sum ai_database_book.backup
```

복구 기록에 파일명과 해시를 함께 남기면 어떤 파일을 사용했는지 추적하기 쉬워집니다.

---

## STEP 21. RPO와 RTO를 이해해 봅시다

백업 정책을 이야기할 때 RPO와 RTO라는 용어가 자주 등장합니다.

### RPO

Recovery Point Objective

```text
얼마나 많은 데이터 손실까지 허용할 것인가?
```

예를 들어 RPO가 1시간이라면 장애 발생 시 최대 1시간 정도의 데이터 손실을 허용한다는 의미로 이해할 수 있습니다.

### RTO

Recovery Time Objective

```text
얼마 안에 서비스를 복구해야 하는가?
```

예를 들어 RTO가 2시간이라면 장애 이후 2시간 안에 서비스를 복구하는 것을 목표로 합니다.

백업 주기는 단순히 "매일 한 번"이라고 정하는 것이 아니라 업무 요구사항에 따라 결정해야 합니다.

---

## STEP 22. 복구 Runbook을 만들어 두는 것이 좋습니다

장애가 발생한 뒤 처음 복구 절차를 생각하면 늦습니다.

다음 내용을 미리 기록해 둘 수 있습니다.

```text
백업 파일 위치
백업 생성 시각
백업 도구 버전
PostgreSQL 서버 버전
복원 대상 DB 생성 방법
pg_restore 명령
Role 재적용 방법
검증 SQL
담당자
RPO / RTO
```

그리고 실제 복원 테스트 결과를 기록합니다.

```text
복원 성공 여부
복원 시간
오류 내용
행 수 검증 결과
권한 테스트 결과
```

---

## STEP 23. PostgreSQL 버전도 확인해야 합니다

백업·복원에서는 서버 버전과 클라이언트 도구 버전을 함께 확인하는 것이 좋습니다.

```bash
pg_dump --version
pg_restore --version
psql --version
```

서버 버전은 SQL로 확인할 수 있습니다.

```sql
SELECT version();
```

운영 환경에서는 사용하는 PostgreSQL 버전과 도구의 호환성을 공식 문서 기준으로 확인해야 합니다.

---

## AI 활용 실습 1. 최소 권한 Role 설계를 검토해 보세요

ChatGPT 또는 Codex에 다음 프롬프트를 입력해 보세요.

```text
PostgreSQL에서 다음 세 사용자 유형을 만들려고 합니다.

1. 보고서 사용자: SELECT만 가능
2. 애플리케이션 사용자: SELECT, INSERT, UPDATE 가능
3. 백업 사용자: 백업에 필요한 읽기 권한만 사용

LOGIN Role과 NOLOGIN 권한 Role을 분리해서
최소 권한 원칙으로 설계해 주세요.

GRANT 예제를 작성하고,
각 역할에 불필요한 권한이 무엇인지도 설명해 주세요.
```

AI의 결과를 받은 뒤 다음을 확인합니다.

```text
ALL PRIVILEGES를 무조건 사용하지 않았는가?
객체 소유 역할과 앱 로그인 역할을 구분했는가?
스키마 USAGE 권한을 고려했는가?
미래 객체의 Default Privileges를 고려했는가?
PUBLIC 권한을 확인하도록 안내하는가?
```

---

## AI 활용 실습 2. 백업·복원 절차를 검토해 보세요

다음 프롬프트도 사용해 보세요.

```text
PostgreSQL 데이터베이스를 custom format으로 백업하고
별도의 테스트 데이터베이스에 복원해서 검증하려고 합니다.

pg_dump와 pg_restore를 사용해서

1. 백업
2. 백업 목록 확인
3. 별도 DB 복원
4. 테이블/행 수/제약조건 검증
5. 권한 재검증

순서로 초보자가 따라 할 수 있는 절차를 작성해 주세요.

원본 DB를 실수로 덮어쓰지 않도록 주의사항도 포함해 주세요.
```

AI가 만든 명령은 바로 실행하지 말고 다음 항목을 반드시 확인합니다.

```text
대상 DB 이름이 맞는가?
원본 DB를 삭제하거나 덮어쓰는 명령이 없는가?
--clean 옵션 사용 여부와 영향은 무엇인가?
--no-owner / --no-acl의 의미를 이해했는가?
실제 복원 검증 단계가 포함됐는가?
```

---

## 오늘의 핵심 정리

이번 Chapter에서 꼭 기억할 내용입니다.

```text
인증
→ 누가 접속했는가

권한
→ 무엇을 할 수 있는가

소유권
→ 누가 객체를 관리하는가

최소 권한
→ 필요한 작업만 허용

GRANT
→ 권한 부여

REVOKE
→ 권한 제거

pg_dump
→ 논리 백업 생성

pg_restore
→ custom archive 복원
```

그리고 가장 중요한 운영 원칙은 다음입니다.

```text
권한 설정
→ 실제 허용 작업 성공 확인
→ 실제 금지 작업 실패 확인

백업 생성
→ 별도 DB 복원
→ 구조·데이터 검증
→ 권한 재검증
```

AI 시대에도 다음 판단은 사람이 해야 합니다.

```text
AI가 GRANT와 pg_restore 명령을 만들 수 있다.
하지만 어떤 권한이 정말 필요한지,
어떤 DB에 복원해야 안전한지,
복원 결과가 정상인지 판단하는 책임은 사람에게 있다.
```

---

## 다음 시간에는

다음 Chapter에서는 데이터 특성과 조회 패턴에 따라 **관계형 데이터베이스와 NoSQL을 어떻게 선택할지** 살펴봅니다.

PostgreSQL만으로 모든 문제를 해결하려고 하기보다, 데이터 구조와 사용 패턴을 기준으로 적절한 저장 방식을 선택하는 방법을 배웁니다.

---

## 관련 글

- Chapter 10. 실행 계획으로 인덱스 효과 검증하기
- Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기

---

#PostgreSQL #데이터베이스보안 #백업복구 #pg_dump #pg_restore #GRANT #REVOKE #SQL보안 #ChatGPT #데이터베이스강의