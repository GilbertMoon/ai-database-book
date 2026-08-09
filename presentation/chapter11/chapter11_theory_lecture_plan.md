# Chapter 11 이론 발표 강의안

## 데이터베이스를 안전하게 지키고 복구하는 방법

> 목적: PostgreSQL 16을 기준으로 보안을 인증·권한·소유권·비밀 보호·백업·복원 검증까지 이어지는 운영 절차로 설명한다.  
> 기준: 초보자가 “권한을 줬다”가 아니라 “필요한 작업만 허용하고, 실제 차단 결과와 복원 가능성을 검증했다”라고 말할 수 있어야 한다.

---

## 1. Chapter 11은 빠른 DB보다 안전한 DB를 다룹니다

**화면 구성**

```text
PostgreSQL 16
보호 대상 식별
→ 최소 권한
→ 허용·차단 검증
→ 비밀 보호
→ custom archive
→ 별도 DB 복원
→ 자동 검증
```

**발표 스크립트**

챕터 10에서는 실행 계획과 인덱스로 조회 성능을 검증했습니다. 이번 장에서는 데이터베이스가 빠른지보다 안전하게 운영할 수 있는지를 봅니다.

안전한 데이터베이스는 세 가지를 증명해야 합니다. 필요한 작업은 허용되고, 불필요한 작업은 실제로 차단되며, 장애가 나면 백업에서 별도 환경으로 복원할 수 있어야 합니다. 그래서 권한과 백업을 서로 다른 주제가 아니라 하나의 운영 흐름으로 연결합니다.

---

## 2. 보안은 여러 통제가 함께 작동해야 합니다

**화면 구성**

| 영역 | 핵심 질문 |
|---|---|
| 인증 | 누가 접속했는가? |
| 권한 | 무엇을 할 수 있는가? |
| 소유권 | 누가 객체를 관리하는가? |
| 입력 보호 | 값이 SQL 구조를 바꾸는가? |
| 비밀 보호 | 접속 정보가 노출되는가? |
| 감사 | 누가 무엇을 했는가? |
| 복구 | 실제 복원이 가능한가? |

**발표 스크립트**

비밀번호만 잘 관리하면 보안이 끝나는 것은 아닙니다. 접속한 주체가 누구인지 확인하는 인증, 어떤 테이블에서 어떤 작업을 할 수 있는지 정하는 권한, 객체 정의와 권한을 관리하는 소유권이 따로 있습니다.

또 사용자 입력이 SQL 구조로 들어가지 않도록 막아야 하고, 로그와 백업 파일도 보호해야 합니다. 마지막으로 장애나 실수 후 실제 복원이 가능해야 합니다. 한 통제가 실패해도 다른 통제가 피해 범위를 줄이는 다층 방어가 핵심입니다.

---

## 3. Chapter 11은 별도 `security_lab`에서 진행합니다

**화면 구성**

```text
필수 시작 기준: course_project 3 / 2 / 3 / 5
recorded_amount NUMERIC(12,0)
전체 590000 / 활성 340000 / 취소 제외 440000

변경 금지: course_project / public
존재하면 변경 금지: transaction_lab / performance_lab
실습: security_lab
```

- Role은 클러스터 전역이므로 자동 생성·삭제하지 않음
- 권한 변경 문장은 테스트 환경에서 선택 실행

**발표 스크립트**

이번 장은 권한과 복원을 다루기 때문에 실수의 영향이 큽니다. 그래서 `security_lab`을 별도로 만들고 앞 장의 프로젝트는 변경하지 않습니다.

시작할 때는 단순히 신청 행이 5개인지뿐 아니라 Chapter 7과 8에서 확정한 상태와 금액까지 확인합니다. `course_project.enrollments.recorded_amount`는 `NUMERIC(12,0)`이고 전체 기록 금액은 59만 원입니다.

Role은 데이터베이스 하나가 아니라 클러스터 전역에 영향을 줄 수 있으므로 생성·삭제 문장을 무조건 실행하지 않습니다.

---

## 4. 먼저 보호할 자산과 위험을 정합니다

**화면 구성**

| 보호 자산 | 대표 위험 |
|---|---|
| 개인정보 | 과도한 조회·유출 |
| 업무 데이터 | 무단 변경·삭제 |
| 비밀 정보 | 계정 탈취 |
| 데이터 구조 | 잘못된 ALTER·DROP |
| 로그 | 비밀번호·URL 기록 |
| 백업 파일 | 전체 사본 노출 |
| 복구 절차 | 장애 시 지연 |

**발표 스크립트**

보안 설계는 무엇을 지켜야 하는지부터 정합니다. 이름과 이메일은 개인정보이고, 수강 상태와 `recorded_amount`는 업무 데이터입니다. 여기서 `recorded_amount`는 신청 시점에 기록한 금액이지 결제 승인액이나 회계 매출이 아닙니다.

위험은 외부 공격만이 아닙니다. 개발 계정으로 운영 DB에 접속하거나 공개 저장소에 `.env`나 백업 파일을 올리는 일, RLS로 일부 행만 보이는 계정으로 전체 백업을 시도하는 일도 운영 위험입니다.

---

## 5. 인증·권한·소유권을 구분합니다

**화면 구성**

```text
인증       → 누가 접속했는가?
권한       → 무엇을 할 수 있는가?
소유권     → 객체를 변경·삭제·권한 부여할 수 있는가?
membership → 다른 역할 권한을 사용할 수 있는가?
감사       → 누가 무엇을 했는가?
```

**발표 스크립트**

초보자가 자주 헷갈리는 것은 인증과 권한입니다. 로그인에 성공했다는 것은 접속 주체가 확인됐다는 뜻이지 모든 테이블을 읽을 수 있다는 뜻이 아닙니다.

소유권은 일반 권한보다 더 강한 관리 범위와 연결됩니다. 그래서 애플리케이션 로그인 계정을 테이블 소유자로 두지 않고, 소유 역할과 실행 역할을 분리하는 편이 안전합니다.

---

## 6. LOGIN 역할과 NOLOGIN 권한 역할을 분리합니다

**화면 구성**

| 역할 | LOGIN | 목적 |
|---|---|---|
| `lab_role_security_owner` | NOLOGIN | 객체 소유 |
| `lab_role_report_reader` | NOLOGIN | 조회 권한 묶음 |
| `lab_role_enrollment_app` | NOLOGIN | 앱 권한 묶음 |
| `lab_role_backup_reader` | NOLOGIN | 백업 권한 묶음 |
| `lab_readonly_user` | LOGIN | 보고 접속 |
| `lab_enrollment_user` | LOGIN | 앱 접속 |
| `lab_backup_user` | LOGIN | 백업 실행 |

```text
PostgreSQL 16 membership
MEMBER / USAGE / inherit_option / set_option / admin_option
```

**발표 스크립트**

실제 접속 계정과 권한 묶음을 분리하면 여러 계정에 같은 권한을 반복해서 부여하지 않아도 됩니다. 보고 사용자는 읽기 권한 역할의 멤버가 되고, 앱 사용자는 앱 권한 역할의 멤버가 됩니다. 백업도 로그인 역할과 권한 역할을 분리합니다.

PostgreSQL 16에서는 membership마다 `INHERIT`, `SET`, `ADMIN` 옵션을 확인할 수 있습니다. 교재는 `INHERIT TRUE`, `SET TRUE`를 명시하고 `pg_auth_members`에서 실제 설정을 확인합니다. `MEMBER`는 membership 존재 여부, `USAGE`는 현재 설정에서 권한을 바로 사용할 수 있는지 확인하는 기준입니다.

---

## 7. 권한은 객체 범위별로 다릅니다

**화면 구성**

| 범위 | 대표 권한 | 의미 |
|---|---|---|
| DB | CONNECT | 접속 |
| schema | USAGE | 내부 객체 이름 사용 |
| schema | CREATE | 객체 생성 |
| table | SELECT·INSERT·UPDATE·DELETE | 행 작업 |
| column | UPDATE 등 | 특정 열 작업 |
| sequence | USAGE·SELECT·UPDATE | 번호 생성·조회·설정 |

**발표 스크립트**

권한은 한 단계가 아닙니다. 데이터베이스 CONNECT가 있어도 스키마 USAGE가 없으면 객체를 사용할 수 없고, 스키마 USAGE가 있어도 테이블 SELECT가 없으면 데이터를 읽을 수 없습니다.

IDENTITY 자동 번호를 사용하는 앱 INSERT에는 sequence `USAGE`가 필요합니다. 반면 백업 역할은 시퀀스의 현재 상태까지 백업하기 위해 `SELECT`를 별도로 부여합니다. 같은 시퀀스라도 업무 목적에 따라 필요한 권한이 달라집니다.

---

## 8. 최소 권한은 작업 행렬로 설계합니다

**화면 구성**

| 작업 | 읽기 | 앱 | 백업 |
|---|---|---|---|
| 세 테이블 SELECT | 허용 | 허용 | 허용 |
| enrollments INSERT | 불허 | 허용 | 불허 |
| status UPDATE | 불허 | 허용 | 불허 |
| recorded_amount UPDATE | 불허 | 불허 | 불허 |
| app sequence USAGE | 불필요 | 허용 | 불필요 |
| 세 sequence SELECT | 불허 | 불허 | 허용 |
| DELETE·schema CREATE | 불허 | 불허 | 불허 |

**발표 스크립트**

최소 권한은 명령을 외우기 전에 역할별 작업 표를 만드는 것에서 시작합니다. 읽기 역할은 조회만, 앱 역할은 조회와 신청 추가, 상태 변경만 허용합니다. `recorded_amount` 수정과 삭제는 허용하지 않습니다.

백업 역할은 테이블 읽기와 IDENTITY 시퀀스 상태 읽기만 필요합니다. 이 표가 이후 GRANT와 실제 허용·차단 테스트의 기준이 됩니다.

---

## 9. GRANT·REVOKE 후에는 유효 권한과 경로를 모두 봅니다

**화면 구성**

```text
has_*_privilege
→ 최종적으로 작업 가능한가?

ACL / PUBLIC / membership / owner
→ 그 권한이 어떤 경로로 생겼는가?
```

**발표 스크립트**

GRANT를 했는지, REVOKE를 했는지만 보면 충분하지 않습니다. 같은 권한이 다른 역할 membership, PUBLIC, 객체 소유권을 통해 남아 있을 수 있습니다.

따라서 `has_table_privilege` 같은 함수로 최종 결과를 보고, 동시에 데이터베이스·스키마·테이블 ACL, PUBLIC과 membership을 확인합니다. 특히 기본 `PUBLIC CONNECT`가 있을 수 있으므로 CONNECT가 true라고 해서 직접 GRANT 때문이라고 단정하면 안 됩니다.

---

## 10. 현재 객체 권한과 미래 객체 권한은 다릅니다

**화면 구성**

```text
GRANT ON TABLE
→ 현재 존재하는 객체

ALTER DEFAULT PRIVILEGES
→ 특정 역할이 앞으로 만들 객체
```

**발표 스크립트**

현재 테이블에 SELECT를 GRANT해도 앞으로 만들어질 테이블에 자동으로 적용되는 것은 아닙니다. 미래 객체의 기본 권한은 `ALTER DEFAULT PRIVILEGES`로 관리합니다.

여기서 핵심은 `FOR ROLE`입니다. 실제로 미래 객체를 생성하는 역할의 기본 권한을 설정해야 합니다. 복원에서도 `--no-privileges`로 원본 ACL을 제외하더라도 복원 역할의 Default Privileges가 새 객체에 적용될 수 있으므로 실제 ACL을 확인합니다.

---

## 11. 권한은 실제 허용·차단 동작으로 검증합니다

**화면 구성**

```text
읽기 계정
SELECT 성공
INSERT·UPDATE·DELETE 실패

앱 계정
SELECT·INSERT·status UPDATE 성공
recorded_amount UPDATE·DELETE·schema CREATE 실패
```

**발표 스크립트**

권한 함수만 확인하고 끝내지 않습니다. 실제 역할로 전환해 허용해야 하는 SQL이 성공하는지, 막아야 하는 SQL이 권한 오류로 실패하는지 확인합니다.

성공 테스트는 마지막에 ROLLBACK해 기준 데이터 3·3·3과 총 `recorded_amount` 31만 원을 보존합니다. 단, sequence `nextval()`은 ROLLBACK으로 번호가 회수되지 않을 수 있으므로 번호 공백은 오류로 판단하지 않습니다.

---

## 12. PUBLIC과 소유권은 과소평가하면 안 됩니다

**화면 구성**

```text
PUBLIC 권한
→ table_privileges / column_privileges

객체 owner
→ 일반 GRANT 외의 강한 관리 범위

Role 정리
→ REASSIGN OWNED → 의존성 확인 → DROP OWNED 검토 → DROP ROLE
```

**발표 스크립트**

`role_table_grants`만 보고 PUBLIC 권한까지 모두 확인했다고 생각하면 안 됩니다. PUBLIC은 `table_privileges`, `column_privileges`와 ACL을 함께 봅니다.

또 객체 owner는 일반 권한과 다른 관리 범위를 갖습니다. 소유 역할을 삭제할 때는 객체 소유권을 먼저 이전해야 합니다. `DROP OWNED ... CASCADE`는 다른 객체에 영향을 줄 수 있으므로 기본 정리 명령으로 사용하지 않습니다.

---

## 13. 비밀 정보는 저장소와 로그에 남기지 않습니다

**화면 구성**

```text
.env.example
PGHOST=
PGPORT=
PGDATABASE=
PGUSER=
PGPASSFILE=

저장소 밖
실제 password file
백업 파일
실제 접속 URL
```

**발표 스크립트**

저장소에는 변수 이름만 두고 실제 비밀번호나 전체 접속 URL은 넣지 않습니다. libpq password file은 저장소 밖에서 OS 접근 권한을 제한해 관리합니다.

비밀이 노출됐을 때는 Git에서 파일만 삭제하는 것으로 끝나지 않습니다. 먼저 자격 증명을 폐기하거나 회전하고 로그, 캐시, 복제본, 배포 환경까지 노출 범위를 확인합니다.

---

## 14. SQL Injection은 값과 SQL 구조를 분리해 막습니다

**화면 구성**

```text
위험: SQL 문자열 + 사용자 입력 연결
안전: WHERE email = $1 + 값 바인딩

값 → 파라미터
식별자·정렬 방향 → 허용 목록
```

**발표 스크립트**

사용자 입력을 SQL 문자열에 직접 이어 붙이면 입력이 SQL 구조를 바꿀 수 있습니다. 값은 파라미터로 바인딩합니다.

테이블명, 컬럼명, 정렬 방향 같은 식별자는 일반 값 파라미터로 처리할 수 없으므로 서버 코드의 허용 목록에서만 선택합니다. 최소 권한은 Injection 자체를 막지는 않지만 성공했을 때 가능한 피해 범위를 줄이는 추가 방어선입니다.

---

## 15. 백업·복제·고가용성은 같은 말이 아닙니다

**화면 구성**

| 방식 | 목적 | 실수 삭제 대응 |
|---|---|---|
| 논리 백업 | 복원·이관 | 백업 시점 복원 |
| 물리 백업·PITR | 특정 시점 복구 | 설정에 따라 가능 |
| 복제 | 가용성·읽기 분산 | 삭제도 복제될 수 있음 |
| 스냅샷 | 스토리지 시점 사본 | 일관성 확인 필요 |

**발표 스크립트**

복제본이 있다고 백업이 있는 것은 아닙니다. 잘못된 삭제가 즉시 복제되면 복제본에도 같은 문제가 생길 수 있습니다.

이번 장은 입문 수준의 논리 백업에 집중합니다. 하지만 목표가 장애 복구인지, 시점 복구인지, 가용성인지에 따라 필요한 기술이 달라진다는 점을 구분해야 합니다.

---

## 16. 백업 전에는 버전·계정·의존성을 확인합니다

**화면 구성**

```text
pg_dump / pg_restore / psql 버전
원본·복원 서버 버전
백업 로그인 역할 + 권한 역할
테이블 SELECT + IDENTITY sequence SELECT
RLS
외부 FK·타입·함수·트리거·확장·Large Object
```

**발표 스크립트**

백업 명령을 실행하기 전에 도구와 서버 버전을 확인합니다. 교재의 자동 검증 기준은 PostgreSQL 16입니다.

백업 로그인 역할은 `lab_backup_user`, 권한 묶음은 `lab_role_backup_reader`입니다. 백업 역할은 세 테이블과 세 IDENTITY 시퀀스 상태를 읽을 수 있어야 합니다.

RLS도 중요합니다. 일반적인 전체 백업에서 pg_dump는 RLS를 끄고 모든 행을 읽으려 하며, 이를 우회하지 못하면 오류가 날 수 있습니다. `--enable-row-security`는 역할에게 보이는 행만 의도적으로 덤프하려는 선택이지 전체 백업의 기본 대체 옵션이 아닙니다.

---

## 17. 백업 파일은 생성 후 바로 검증합니다

**화면 구성**

```bash
pg_dump -Fc --schema=security_lab ...
pg_restore --list security_lab.backup
sha256sum security_lab.backup
```

```text
custom archive
→ owner·ACL 메타데이터 보존 가능
→ 복원에서 적용 여부 결정
```

**발표 스크립트**

custom format 백업을 만든 뒤 파일 존재만 확인하지 않습니다. 종료 코드와 오류, 파일 크기, `pg_restore --list`, SHA-256을 기록합니다.

여기서 중요한 수정이 있습니다. archive 형식에서 `pg_dump --no-owner`가 owner 메타데이터를 없앤다고 설명하면 안 됩니다. custom archive의 원본 owner 적용 여부는 복원 단계의 `pg_restore --no-owner`에서 제어합니다. ACL도 검증 복원에서는 `--no-privileges`로 적용을 생략합니다.

---

## 18. 복원은 원본이 아니라 별도 DB에서 검증합니다

**화면 구성**

```bash
createdb -O <restore_user> -T template0 ai_database_book_restore

pg_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  ...
```

```text
1단계: 06 구조·데이터·소유권
2단계: Role·GRANT 재적용 후 04·05 권한
```

**발표 스크립트**

복원 검증은 원본 DB에 덮어쓰지 않고 별도 데이터베이스에서 진행합니다. 복원 역할을 DB owner로 지정하고 `template0`에서 깨끗한 DB를 만듭니다.

작은 실습은 `--single-transaction`으로 묶어 오류 시 부분 객체가 남는 위험을 줄입니다. `--no-owner`와 `--no-privileges`로 원본 owner와 ACL의 적용을 생략한 뒤, 1단계에서 구조·데이터·소유권을 검증하고 2단계에서 역할·권한을 다시 적용해 실제 동작을 확인합니다.

---

## 19. RPO·RTO는 백업 전략의 목표입니다

**화면 구성**

| 기준 | 질문 | 예시 |
|---|---|---|
| RPO | 얼마나 최근 시점까지 복구해야 하는가? | 최대 1시간 손실 |
| RTO | 얼마 안에 서비스를 재개해야 하는가? | 2시간 |

**발표 스크립트**

백업을 얼마나 자주 하는지는 기술 취향이 아니라 RPO와 연결됩니다. RPO가 1시간인데 하루 한 번만 백업하면 목표를 충족할 수 없습니다.

RTO는 실제 복원 시간과 연결됩니다. 백업 파일이 있어도 복원에 반나절이 걸리면 2시간 RTO를 만족하지 못합니다. 그래서 Runbook에는 백업뿐 아니라 실제 복원 시작·완료 시각과 검증 결과를 기록합니다.

---

## 20. 핵심 정리: 보안은 허용·차단·복원으로 증명합니다

**화면 구성**

```text
PostgreSQL 16
Role 분리 + membership 검증
최소 권한 + 실제 차단
recorded_amount 의미·타입 통일
비밀·Injection 보호
RLS·의존성·버전 확인
custom archive owner/ACL 이해
별도 DB 원자적 복원
2단계 자동 검증
RPO·RTO Runbook
```

**발표 스크립트**

이번 장의 핵심은 설정했다는 사실보다 검증 결과입니다. 로그인 역할과 권한 역할을 분리하고 PostgreSQL 16의 membership 경로를 확인합니다. 필요한 작업만 허용하고, `recorded_amount` 수정과 삭제 같은 불필요한 작업이 실제로 실패하는지 확인합니다.

백업은 custom archive를 만드는 데서 끝내지 않습니다. RLS와 의존성, 버전을 확인하고 별도 DB에 원자적으로 복원한 뒤 구조·데이터·소유권과 권한을 두 단계로 검증합니다.

기억할 문장은 하나입니다. **허용할 작업은 최소화하고, 복구 가능성은 실제 복원으로 증명합니다.**
