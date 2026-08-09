# Chapter 11 실습 발표 강의안

## 권한을 검증하고 백업을 복원해 확인하기

> 목적: PostgreSQL 16의 `security_lab`에서 최소 권한을 설계·검증하고, custom archive를 별도 DB에 복원해 구조·데이터·소유권·권한을 확인한다.  
> 기준: 초보자가 “명령을 실행했다”가 아니라 “허용·차단 동작과 복원 가능성을 실제 결과로 확인했다”라고 말할 수 있어야 한다.

---

## 1. 이번 실습은 허용·차단·복원을 확인합니다

**화면 구성**

```text
Chapter 07·08 기준
→ security_lab 생성
→ Role·GRANT
→ 허용·차단
→ custom archive
→ 별도 DB restore
→ 06 자동 검증
→ 권한 2단계 검증
```

**발표 스크립트**

이번 실습은 권한 명령을 많이 입력하는 것이 목표가 아닙니다. 세 가지를 확인합니다. 필요한 SQL은 성공하고, 허용하지 않은 SQL은 실제로 실패하며, 백업은 별도 데이터베이스에서 정상 복원되어야 합니다.

기준 환경은 PostgreSQL 16입니다. Role은 클러스터 전역 객체이므로 역할 생성과 삭제는 테스트 환경에서 필요한 문장만 선택합니다.

---

## 2. 실행 위치와 보호 범위를 먼저 확인합니다

**화면 구성**

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

```text
ai_database_book
course_project = 3 / 2 / 3 / 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
recorded_amount NUMERIC(12,0)
590000 / 340000 / 440000
```

**발표 스크립트**

먼저 현재 데이터베이스가 `ai_database_book`인지 확인합니다. 01 파일은 Chapter 7과 8의 기준 상태가 맞지 않으면 바로 중단됩니다.

`transaction_lab`과 `performance_lab`은 이전 장에서 이미 초기화되어 없을 수도 있습니다. Chapter 11은 두 스키마의 존재를 필수 전제로 삼지 않지만 존재한다면 변경하지 않습니다.

---

## 3. `security_lab` 스키마와 기본 데이터를 만듭니다

**화면 구성**

```text
01
3 tables / 13 constraints / NOT NULL 14
recorded_amount NUMERIC(12,0)
rows 0 / 0 / 0

02
rows 3 / 3 / 3 / JOIN 3
status 1 / 1 / 1 / 0
recorded_amount total 310000
```

**발표 스크립트**

01은 스키마와 테이블을 한 트랜잭션에서 생성하고 COMMIT 전에 구조를 검증합니다. 금액 열은 Chapter 7과 8과 같은 `recorded_amount NUMERIC(12,0)`입니다.

02는 학생·강의·신청 세 건씩을 만들고 상태 분포와 총 기록 금액 31만 원을 확인합니다. `recorded_amount`는 결제 매출이 아니라 신청 시점에 신청 행에 기록한 금액입니다.

---

## 4. 구조와 무결성 규칙을 확인합니다

**화면 구성**

- 학생 이름·이메일 공백 금지
- 정확 문자열 이메일 중복 금지
- FK로 존재 학생·강의만 참조
- 상태 허용값 제한
- recorded_amount 0 이상
- 활성 신청 중복 0

```sql
CREATE UNIQUE INDEX uq_security_enrollments_active
ON security_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

**발표 스크립트**

권한 실습 전에 데이터 구조 자체가 안정적인지 확인합니다. 권한은 잘못된 데이터를 허용하는 구조를 대신 고쳐 주지 않습니다.

부분 고유 인덱스는 완료나 취소 이력을 여러 건 남길 수 있게 하면서 진행 중인 신청만 학생·강의당 한 건으로 제한합니다.

---

## 5. 역할 생성·권한 부여는 선택 실행합니다

**화면 구성**

```text
NOLOGIN
owner / report / app / backup

LOGIN
readonly / enrollment / backup_user

PostgreSQL 16 membership
INHERIT TRUE / SET TRUE
```

**발표 스크립트**

03 파일의 Role 생성 문장은 기본 주석 상태입니다. 테스트 클러스터에서 기존 역할 이름과 충돌하지 않는지 확인하고 필요한 문장만 실행합니다.

읽기·앱·백업의 로그인 역할과 권한 역할을 분리합니다. PostgreSQL 16에서는 membership별 `INHERIT`, `SET`, `ADMIN` 옵션을 볼 수 있으므로 `INHERIT TRUE`, `SET TRUE`를 명시하고 나중에 `pg_auth_members`에서 확인합니다.

---

## 6. 최소 권한 작업 행렬을 기준으로 GRANT합니다

**화면 구성**

| 작업 | readonly | app | backup |
|---|---|---|---|
| table SELECT | O | O | O |
| enrollment INSERT | X | O | X |
| status UPDATE | X | O | X |
| recorded_amount UPDATE | X | X | X |
| enrollment seq USAGE | X | O | X |
| 3 seq SELECT | X | X | O |
| DELETE / CREATE | X | X | X |

**발표 스크립트**

GRANT를 실행하기 전에 역할별 작업 행렬을 기준으로 합니다. 앱은 신청을 만들기 위한 테이블 INSERT와 IDENTITY sequence `USAGE`, 상태 변경을 위한 컬럼 UPDATE만 추가로 받습니다.

백업 역할은 쓰기 권한이 필요하지 않습니다. 대신 세 테이블 데이터와 세 IDENTITY 시퀀스 상태를 읽기 위해 SELECT를 부여합니다.

---

## 7. 유효 권한과 권한 경로를 확인합니다

**화면 구성**

```text
has_*_privilege
→ 최종 결과

ACL / PUBLIC / membership / owner
→ 권한 경로
```

**발표 스크립트**

04를 실행하면 현재 사용자와 실습 역할의 권한을 볼 수 있습니다. `has_*_privilege`는 최종적으로 작업이 가능한지를 보여 주고 ACL은 직접 GRANT나 PUBLIC 같은 경로를 설명합니다.

최종 결과와 권한 경로를 모두 봐야 REVOKE 이후에도 왜 권한이 남아 있는지 설명할 수 있습니다.

---

## 8. PUBLIC 권한과 멤버십을 분리해서 봅니다

**화면 구성**

```text
PUBLIC
→ table_privileges / column_privileges / datacl / nspacl

membership
→ MEMBER / USAGE
→ pg_auth_members
   inherit_option
   set_option
   admin_option
```

**발표 스크립트**

`role_table_grants`만 보고 PUBLIC까지 확인했다고 생각하면 안 됩니다. PUBLIC 경로는 `table_privileges`, `column_privileges`와 ACL을 함께 봅니다.

PostgreSQL 16의 역할 membership도 `MEMBER`만 확인하지 않습니다. `USAGE`와 `pg_auth_members`의 `inherit_option`, `set_option`, `admin_option`을 함께 기록합니다.

---

## 9. 허용·차단 동작 테스트를 실행합니다

**화면 구성**

```text
readonly
SELECT 성공
INSERT·UPDATE·DELETE 실패

app
SELECT·INSERT·status UPDATE 성공
recorded_amount UPDATE·DELETE·schema CREATE 실패
```

**발표 스크립트**

권한 표가 실제 행동과 같은지 확인합니다. 05 파일의 허용 테스트는 그대로 실행할 수 있고 마지막에 ROLLBACK합니다.

차단 테스트는 기본 주석 상태입니다. 하나씩 선택해 실제 permission denied를 확인합니다. 자동 검증 환경에서는 이 실패 경로도 실제로 실행해 정상적인 실패인지 확인합니다.

---

## 10. 오류 후에는 트랜잭션을 복구합니다

**화면 구성**

```text
BEGIN
→ SET LOCAL ROLE
→ SAVEPOINT
→ 실패 SQL
→ ROLLBACK TO SAVEPOINT
→ ROLLBACK
```

```text
nextval 번호는 ROLLBACK으로 회수되지 않을 수 있음
```

**발표 스크립트**

권한 오류가 발생하면 현재 트랜잭션은 오류 상태가 될 수 있습니다. 여러 실패 테스트를 한 트랜잭션에서 이어서 하려면 SAVEPOINT로 복구하거나 트랜잭션 전체를 ROLLBACK합니다.

IDENTITY sequence의 `nextval()`이 이미 호출됐다면 데이터 INSERT가 롤백되어도 번호가 비어 있을 수 있습니다. 연속 번호를 데이터 정합성으로 판단하지 않습니다.

---

## 11. 현재 객체 권한과 미래 객체 권한을 기록합니다

**화면 구성**

```text
GRANT ON TABLE
→ 현재 객체

ALTER DEFAULT PRIVILEGES
FOR ROLE <future_object_creator>
→ 미래 객체
```

**발표 스크립트**

현재 테이블의 GRANT와 미래 객체의 Default Privileges를 분리합니다. `FOR ROLE`은 실제로 새 객체를 생성할 역할이어야 합니다.

복원 역할에 Default Privileges가 있다면 `pg_restore --no-privileges`로 원본 ACL을 적용하지 않더라도 새 객체에 다른 권한이 생길 수 있으므로 복원 후 실제 ACL을 확인합니다.

---

## 12. 비밀 정보와 저장소 보호를 점검합니다

**화면 구성**

```text
저장소
.env.example 변수명만
PGPASSFILE 이름만

저장소 밖
실제 password file
백업 archive
실제 접속 URL
```

**발표 스크립트**

실제 비밀번호와 전체 접속 URL은 SQL, 문서, 로그에 넣지 않습니다. `.env.example`은 빈 변수 이름만 제공합니다.

비밀이 노출됐을 때는 파일 삭제보다 자격 증명 회전이 먼저입니다. 백업 archive도 원본 데이터의 사본이므로 운영 DB와 같은 수준으로 보호합니다.

---

## 13. SQL Injection 방어 기준을 정리합니다

**화면 구성**

```text
값
→ parameter binding

컬럼명·테이블명·정렬 방향
→ allowlist

추가 방어
→ 최소 권한 / 오류 제한 / 테스트
```

**발표 스크립트**

사용자 값은 문자열 연결이 아니라 파라미터 바인딩으로 전달합니다. 식별자는 일반 값 파라미터로 바인딩하지 못하므로 허용 목록에서만 선택합니다.

최소 권한은 Injection을 직접 막는 기능은 아니지만 공격이 성공했을 때 UPDATE, DELETE, CREATE 같은 작업을 제한해 피해 범위를 줄입니다.

---

## 14. 백업 전 도구·서버·계정을 확인합니다

**화면 구성**

```bash
pg_dump --version
pg_restore --version
psql --version
```

```text
PostgreSQL 16
backup user + backup reader role
3 table SELECT
3 sequence SELECT
RLS false
외부 의존성 확인
```

**발표 스크립트**

백업 전에 도구와 서버 버전을 기록합니다. pg_dump가 원본 서버보다 오래된 주요 버전이면 중단하고 맞는 도구를 사용합니다.

백업 계정의 테이블·시퀀스 권한과 RLS 상태를 확인합니다. 전체 백업이 목적이라면 `--enable-row-security`로 역할에게 보이는 일부 행만 덤프하는 방식을 자동 선택하지 않습니다.

---

## 15. 백업 파일을 만들고 파일 자체를 검증합니다

**화면 구성**

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  --schema=security_lab \
  -f security_lab.backup

pg_restore --list security_lab.backup
sha256sum security_lab.backup
```

**발표 스크립트**

custom archive를 만듭니다. archive에는 원본 owner와 ACL 메타데이터가 들어 있을 수 있습니다. `pg_dump --no-owner`로 archive에서 owner가 제거된다고 설명하지 않습니다.

파일을 만든 뒤 `pg_restore --list`로 스키마, 세 테이블, 세 시퀀스, sequence set, 제약조건과 부분 고유 인덱스를 확인합니다. SHA-256도 기록하지만 해시는 복원 성공을 대신하지 않습니다.

---

## 16. 별도 DB에 원자적으로 복원합니다

**화면 구성**

```bash
createdb \
  -O <restore_user> \
  -T template0 \
  ai_database_book_restore

pg_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  ...
```

**발표 스크립트**

원본 DB에 복원하지 않습니다. 복원 역할이 소유하는 `ai_database_book_restore`를 `template0`에서 새로 만듭니다.

작은 실습은 `--single-transaction`으로 묶습니다. `--no-owner`는 archive의 원본 owner 적용을 생략하고, `--no-privileges`는 원본 ACL 적용을 생략합니다. 권한은 2단계에서 다시 적용해 검증합니다.

---

## 17. 복원 검증 1단계: 구조·데이터·소유권

**화면 구성**

```text
06_restore_validation.sql
DB = ai_database_book_restore
3 / 3 / 3 / JOIN 3
status 1 / 1 / 1 / 0
recorded_amount 310000 / NUMERIC(12,0)
NOT NULL 14 / constraints 13
active index valid/ready
sequences 3 / next > max
owner = restore user
```

**발표 스크립트**

06은 잘못된 DB에서 실행하면 즉시 중단됩니다. 복원 데이터의 행 수만 보지 않고 상태 분포와 총 기록 금액, 금액 타입, FK, 활성 중복, NOT NULL, 제약조건, 시퀀스와 owner를 자동 판정합니다.

성공 메시지 `Chapter 11 restore structure and data validation passed`가 나와야 1단계 복원을 통과한 것으로 기록합니다.

---

## 18. 복원 검증 2단계: 권한 재적용과 동작 확인

**화면 구성**

```text
03 Role·GRANT 재검토
→ 04 PUBLIC·ACL·membership·RLS
→ 05 허용·차단

backup
3 table SELECT 성공
3 sequence SELECT 성공
쓰기 실패
```

**발표 스크립트**

구조와 데이터가 맞아도 권한이 운영 의도와 다르면 복구 완료가 아닙니다. 그래서 2단계에서 역할과 GRANT를 재적용하고 04와 05를 다시 실행합니다.

읽기 계정과 앱 계정의 허용·차단뿐 아니라 백업 역할이 테이블과 IDENTITY 시퀀스를 읽을 수 있고 쓰기는 할 수 없는지도 확인합니다.

---

## 19. RPO·RTO와 Runbook을 기록합니다

**화면 구성**

| 기록 | 내용 |
|---|---|
| 버전 | 서버·도구 |
| 권한 | login / NOLOGIN / membership |
| RLS·의존성 | 확인 결과 |
| archive | 경로·크기·목록·SHA-256 |
| restore | 시작·완료·옵션 |
| validation | 구조·데이터·권한 |
| 목표 | RPO·RTO |
| 다음 시험 | 날짜 |

**발표 스크립트**

복구 절차는 담당자의 기억이 아니라 반복 가능한 문서로 남겨야 합니다. Runbook에는 성공한 명령만 아니라 버전, 권한, RLS, 의존성, archive 목록과 해시, 실제 복원 시간과 실패 원인도 기록합니다.

RPO와 RTO를 실제 백업 주기와 복원 시간에 연결하고 다음 복원 시험 날짜를 정합니다.

---

## 20. 최종 완료 기준은 허용·차단·복원 검증입니다

**화면 구성**

```text
[✓] Chapter 07·08 baseline 보호
[✓] security_lab 3 / 3 / 3 / 310000
[✓] PostgreSQL 16 membership 확인
[✓] 허용 SQL 성공
[✓] 차단 SQL 실패
[✓] backup table/sequence 최소 권한
[✓] custom archive 목록·해시
[✓] 별도 DB 원자적 restore
[✓] 06 자동 검증
[✓] reset 격리·원자성
[✓] RPO·RTO Runbook
```

**발표 스크립트**

이번 실습은 GRANT를 입력했거나 백업 파일이 생겼다는 것으로 끝나지 않습니다. 앞 장 데이터가 보존되고, `security_lab` 기준 데이터가 정확하며, PostgreSQL 16 membership과 실제 허용·차단 결과가 맞아야 합니다.

마지막으로 최소 권한으로 custom archive를 만들고 별도 DB에 복원해 06 자동 검증까지 통과해야 합니다. reset도 예상 범위만 삭제하고 예상 밖 객체가 있으면 전체가 롤백되어야 합니다.

최종 완료 기준은 **허용할 것은 성공하고, 막을 것은 실패하며, 백업은 실제 복원되어야 한다**는 것입니다.
