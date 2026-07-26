# Chapter 11 실습 발표 강의안

## 권한을 검증하고 백업을 복원해 확인하기

> 목적: `security_lab`에서 최소 권한을 설계·검증하고, 논리 백업 파일을 별도 DB에 복원해 구조·데이터·소유권·권한을 확인한다.  
> 기준: 초보자가 “명령을 실행했다”가 아니라 “허용·차단 동작과 복원 가능성을 실제 결과로 확인했다”라고 말할 수 있어야 한다.

---

## 1. 이번 실습은 허용·차단·복원을 확인합니다

**화면 구성**

```text
01 schema
→ 02 seed
→ 03 role / permission plan
→ 04 permission checks
→ 05 behavior tests
→ terminal backup / restore
→ 06 restore validation
→ runbook 기록
```

**발표 스크립트**

이번 실습은 보안 설정을 “적었다”에서 끝내지 않습니다. 허용해야 하는 작업은 실제로 성공해야 하고, 차단해야 하는 작업은 실제로 실패해야 합니다.

또 백업 파일을 만든 뒤 별도 데이터베이스에 복원하고, 구조와 데이터, 소유권, 권한이 모두 맞는지 확인합니다.

기존 `course_project`, `transaction_lab`, `performance_lab`는 변경하지 않고, 이번 장은 `security_lab`만 대상으로 진행합니다.

---

## 2. 실행 위치와 보호 범위를 먼저 확인합니다

**화면 구성**

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

```text
원본 실습 DB: ai_database_book
복원 검증 DB: ai_database_book_restore
변경 대상: security_lab
변경 금지: course_project / transaction_lab / performance_lab
```

**발표 스크립트**

보안과 백업 실습에서는 현재 위치 확인이 매우 중요합니다. 원본 실습은 `ai_database_book`에서 진행하고, 복원 검증은 별도 DB인 `ai_database_book_restore`에서 진행합니다.

현재 스키마가 `security_lab`일 필요는 없습니다. 모든 객체는 `security_lab.students`처럼 스키마 이름을 명시해서 사용합니다.

실습 전에는 Chapter 07의 `course_project.enrollments`가 5행으로 유지되는지도 확인합니다.

---

## 3. `security_lab` 스키마와 기본 데이터를 만듭니다

**화면 구성**

| 테이블 | 기대 행 수 | 다음 IDENTITY 값 |
|---|---:|---:|
| students | 3 | 104 이상 |
| courses | 3 | 204 이상 |
| enrollments | 3 | 1004 이상 |

**발표 스크립트**

`01_security_lab_schema.sql`은 학생, 강의, 수강신청 테이블을 만듭니다. `02_security_lab_seed.sql`은 샘플 데이터를 입력합니다.

관계를 쉽게 확인하기 위해 학생 101~103, 강의 201~203, 신청 1001~1003처럼 명시적 ID를 사용합니다.

명시적 ID는 IDENTITY 다음 값을 자동으로 이동시키지 않으므로, 파일 마지막에서 다음 자동값을 조정합니다. 권한 테스트 중 ROLLBACK을 해도 자동 번호는 회수되지 않을 수 있습니다.

---

## 4. 구조와 무결성 규칙을 확인합니다

**화면 구성**

- PK, FK, NOT NULL, CHECK, UNIQUE
- 부분 고유 인덱스

```sql
CREATE UNIQUE INDEX uq_security_enrollments_active
ON security_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

**발표 스크립트**

권한을 검증하기 전에 실습 데이터 구조가 정상인지 확인합니다. 학생 이메일은 공백일 수 없고, 같은 문자열은 중복될 수 없습니다.

수강신청은 존재하는 학생과 강의를 참조해야 하고, 상태와 금액도 제약조건을 만족해야 합니다.

부분 고유 인덱스는 완료·취소 이력은 보존하면서, 진행 중인 신청만 학생·강의 조합당 한 건으로 제한합니다.

---

## 5. 역할 생성·권한 부여는 선택 실행합니다

**화면 구성**

```text
NOLOGIN 권한 역할:
- lab_role_report_reader
- lab_role_enrollment_app
- lab_role_backup_reader

LOGIN 역할:
- lab_readonly_user
- lab_enrollment_user
```

- 역할 명령은 기본 주석 상태
- 관리자 권한이 있는 테스트 환경에서만 선택 실행

**발표 스크립트**

`03_role_permission_plan.sql`은 역할과 권한 계획을 담고 있습니다. 하지만 역할은 PostgreSQL 클러스터 전체에 영향을 줄 수 있으므로 전체 파일을 그대로 실행하지 않습니다.

테스트 환경인지, 관리자 권한이 있는지, 기존에 같은 이름의 Role이 없는지 확인한 뒤 필요한 문장만 선택 실행합니다.

이 장의 목적은 무작정 권한을 많이 주는 것이 아니라, 역할별로 필요한 작업만 허용하는 것입니다.

---

## 6. 최소 권한 작업 행렬을 기준으로 GRANT합니다

**화면 구성**

| 작업 | 읽기 역할 | 앱 역할 |
|---|---|---|
| SELECT | 허용 | 허용 |
| enrollments INSERT | 불허 | 허용 |
| status UPDATE | 불허 | 허용 |
| paid_amount UPDATE | 불허 | 불허 |
| DELETE | 불허 | 불허 |
| schema CREATE | 불허 | 불허 |
| sequence USAGE | 불필요 | 허용 |

**발표 스크립트**

권한 부여의 기준은 작업 행렬입니다. 읽기 역할은 조회만 허용합니다.

앱 역할은 신청을 추가하고 상태를 바꿀 수 있어야 하지만, 결제 금액 수정이나 삭제는 허용하지 않습니다.

또 ID를 생략하고 신청을 INSERT하려면 시퀀스 `USAGE`가 필요할 수 있습니다. 하지만 시퀀스 번호를 직접 조회할 필요는 없으므로 기본적으로 `SELECT` 권한은 주지 않습니다.

---

## 7. 유효 권한과 권한 경로를 확인합니다

**화면 구성**

```text
04_permission_checks.sql

확인:
- has_database_privilege
- has_schema_privilege
- has_table_privilege
- has_column_privilege
- has_sequence_privilege
- PUBLIC 권한
- 역할 멤버십
- 객체 소유권
```

**발표 스크립트**

권한 확인은 두 층으로 봅니다. 첫째, 로그인 역할이 최종적으로 작업할 수 있는지 유효 권한을 확인합니다.

둘째, 그 권한이 어디서 왔는지 확인합니다. 직접 GRANT일 수도 있고, PUBLIC 권한일 수도 있고, 다른 역할 멤버십이나 객체 소유권 때문일 수도 있습니다.

`has_*_privilege`가 true라고 해서 직접 부여된 권한이라고 단정하지 않습니다. 권한의 결과와 경로를 함께 기록합니다.

---

## 8. PUBLIC 권한과 멤버십을 분리해서 봅니다

**화면 구성**

```text
PUBLIC 권한 확인:
information_schema.table_privileges
information_schema.column_privileges

멤버십 확인:
pg_has_role(..., 'MEMBER')
pg_has_role(..., 'USAGE')
```

**발표 스크립트**

PUBLIC 권한은 모든 Role에 영향을 줄 수 있습니다. 일부 권한 조회 뷰에서는 PUBLIC 경로가 기대와 다르게 보일 수 있으므로 별도로 확인합니다.

역할 멤버십도 단순히 “멤버인가”와 “현재 그 권한을 사용할 수 있는가”를 구분합니다. `MEMBER`와 `USAGE` 결과를 함께 기록합니다.

무조건적인 `REVOKE ALL FROM PUBLIC`은 다른 계정에 영향을 줄 수 있으므로 테스트 환경에서 의존성을 먼저 확인합니다.

---

## 9. 허용·차단 동작 테스트를 실행합니다

**화면 구성**

| 역할 | 기대 성공 | 기대 실패 |
|---|---|---|
| 읽기 계정 | SELECT | INSERT, UPDATE, DELETE |
| 앱 계정 | SELECT, INSERT, status UPDATE | paid_amount UPDATE, DELETE, schema CREATE |

**발표 스크립트**

`05_permission_behavior_tests.sql`은 실제 SQL 실행으로 권한을 확인합니다.

읽기 계정은 SELECT가 성공해야 하고, INSERT, UPDATE, DELETE는 실패해야 합니다. 앱 계정은 SELECT, INSERT, status UPDATE는 성공해야 하지만, paid_amount UPDATE, DELETE, schema CREATE는 실패해야 합니다.

성공 테스트는 마지막에 ROLLBACK해서 기준 데이터를 보존합니다. 실패 테스트는 오류가 기대 결과일 수 있으므로 한 문장씩 실행합니다.

---

## 10. 오류 후에는 트랜잭션을 복구합니다

**화면 구성**

```text
실패 테스트 한 문장 실행
→ 오류 메시지 확인
→ ROLLBACK TO SAVEPOINT 또는 ROLLBACK
→ 기준 데이터 재조회
```

**발표 스크립트**

권한 차단 테스트에서는 오류가 정상 결과입니다. 하지만 PostgreSQL에서는 오류 후 트랜잭션이 중단 상태가 될 수 있습니다.

그래서 실패 테스트를 한꺼번에 실행하지 않고, 필요한 경우 SAVEPOINT를 사용해 오류 전 상태로 되돌립니다.

중요한 것은 오류가 났다는 사실만 보는 것이 아니라, 기존 정상 데이터가 유지되었는지 다시 확인하는 것입니다.

---

## 11. 현재 객체 권한과 미래 객체 권한을 기록합니다

**화면 구성**

| 구분 | 적용 대상 | 확인 포인트 |
|---|---|---|
| GRANT ON TABLE | 현재 객체 | 지금 있는 테이블 권한 |
| ALTER DEFAULT PRIVILEGES | 미래 객체 | 특정 생성 역할 기준 |

**발표 스크립트**

현재 있는 테이블 권한을 부여했다고 해서 앞으로 새로 만들어질 테이블에 같은 권한이 자동 적용되지는 않습니다.

미래 객체 권한은 `ALTER DEFAULT PRIVILEGES`로 설정합니다. 이때 `FOR ROLE`은 앞으로 객체를 만들 역할을 뜻하므로 매우 중요합니다.

워크북에는 현재 객체 권한과 미래 객체 권한을 따로 기록합니다.

---

## 12. 비밀 정보와 저장소 보호를 점검합니다

**화면 구성**

체크리스트:

- 실제 `.env`가 저장소에 없는가
- `.env.example`에는 실제 값이 없는가
- 실제 password file은 저장소 밖에 있는가
- SQL·로그에 비밀번호·토큰이 없는가
- 백업 파일은 프로젝트 밖에 있는가
- `.backup`, `.dump`, 압축 SQL은 ignore 대상인가

**발표 스크립트**

보안 실습에서 권한만큼 중요한 것이 비밀 정보 보호입니다. 실제 비밀번호나 접속 URL이 저장소, SQL 파일, 로그에 남아 있으면 권한 설계가 좋아도 위험합니다.

`.env.example`에는 변수 이름만 두고 실제 값은 넣지 않습니다. 실제 password file과 백업 파일은 저장소 밖의 보호된 위치에 둡니다.

노출이 발생하면 파일 삭제보다 먼저 비밀번호와 토큰을 폐기하고 회전해야 합니다.

---

## 13. SQL Injection 방어 기준을 정리합니다

**화면 구성**

| 입력 종류 | 안전한 처리 |
|---|---|
| email, id 값 | 파라미터 바인딩 |
| 정렬 컬럼 | 허용 목록 |
| 정렬 방향 | 허용 목록 |
| 테이블명 | 허용 목록 또는 고정 |

**발표 스크립트**

사용자 입력값은 SQL 문자열에 직접 붙이지 않습니다. 이메일이나 ID처럼 값으로 들어가는 것은 파라미터로 바인딩합니다.

하지만 컬럼명, 테이블명, 정렬 방향은 값 파라미터로 처리하기 어렵습니다. 이런 항목은 허용 목록에서 선택하게 해야 합니다.

최소 권한 계정은 Injection이 발생했을 때 피해 범위를 줄이는 추가 방어선입니다.

---

## 14. 백업 전 도구·서버·계정을 확인합니다

**화면 구성**

```bash
pg_dump --version
pg_restore --version
psql --version
```

```sql
SHOW server_version;
```

- 백업 계정 권한
- RLS 적용 여부
- 스키마 외부 의존성

**발표 스크립트**

백업 전에는 도구 버전과 서버 버전을 확인합니다. 오래된 `pg_dump`로 더 새로운 서버를 백업하려 하면 문제가 될 수 있습니다.

백업 계정도 확인합니다. `pg_dump`가 모든 권한을 자동으로 우회한다고 생각하면 안 됩니다. 필요한 테이블을 읽을 권한이 있어야 하며, Row-Level Security가 있으면 결과가 달라질 수 있습니다.

특정 스키마만 백업할 때는 외부 FK, 타입, 함수, 확장 기능 같은 의존성도 확인합니다.

---

## 15. 백업 파일을 만들고 파일 자체를 검증합니다

**화면 구성**

```bash
pg_dump -Fc --schema=security_lab --no-owner --no-privileges
pg_restore --list security_lab.backup
Get-FileHash ... -Algorithm SHA256
```

확인:

- 종료 코드와 경고
- 파일 크기와 생성 시각
- 아카이브 목록
- 해시
- 저장 위치 접근 권한

**발표 스크립트**

백업 명령을 실행한 뒤에는 파일이 실제로 만들어졌는지 확인합니다. 파일 크기가 비정상적으로 작거나 경고가 있으면 그대로 성공 처리하지 않습니다.

사용자 정의 형식 백업은 `pg_restore --list`로 안에 어떤 객체가 들어 있는지 확인합니다. SHA-256 해시도 기록합니다.

다만 해시는 파일이 변하지 않았다는 근거이지 복원이 성공한다는 증거는 아닙니다. 그래서 다음 단계에서 별도 DB 복원이 필요합니다.

---

## 16. 별도 DB에 원자적으로 복원합니다

**화면 구성**

```bash
createdb -O <restore_user> -T template0 ai_database_book_restore

pg_restore \
  -d ai_database_book_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  security_lab.backup
```

**발표 스크립트**

복원 검증은 원본 DB가 아니라 깨끗한 별도 DB에서 진행합니다. 원본에 덮어쓰면 실습 데이터가 손상될 수 있습니다.

작은 실습에서는 `--single-transaction`을 사용해 복원 중 오류가 발생했을 때 부분 객체가 남을 위험을 줄입니다.

Plain SQL 파일을 복원할 때는 `psql -X -1 -v ON_ERROR_STOP=1`처럼 사용자 설정 제외, 전체 트랜잭션, 오류 시 중단 옵션을 함께 고려합니다.

---

## 17. 복원 검증 1단계: 구조·데이터·소유권

**화면 구성**

```text
06_restore_validation.sql

현재 DB = ai_database_book_restore
students / courses / enrollments = 3 / 3 / 3
JOIN = 3
고아 FK = 0
활성 신청 중복 = 0
제약조건 13개
부분 고유 인덱스 존재
IDENTITY 시퀀스 3개
owner = 복원 역할
```

**발표 스크립트**

복원 DB에서 `06_restore_validation.sql`을 실행합니다. 이 파일은 원본 DB에서 실행하면 중단되어야 합니다. 복원 검증은 반드시 `ai_database_book_restore`에서 합니다.

검증은 행 수만 보는 것이 아닙니다. JOIN 결과, 고아 관계, 활성 신청 중복, 제약조건, 부분 고유 인덱스, IDENTITY 시퀀스, 소유권까지 확인합니다.

이 중 하나라도 실패하면 백업을 성공으로 표시하지 않습니다.

---

## 18. 복원 검증 2단계: 권한 재적용과 동작 확인

**화면 구성**

```text
복원 완료
→ 역할·GRANT 재적용
→ 04 권한 확인
→ 05 허용·차단 동작 재검증
```

| 역할 | SELECT | INSERT | status UPDATE | paid_amount UPDATE | DELETE |
|---|---|---|---|---|---|
| 읽기 계정 | 성공 | 실패 | 실패 | 실패 | 실패 |
| 앱 계정 | 성공 | 성공 | 성공 | 실패 | 실패 |

**발표 스크립트**

`--no-owner --no-privileges`로 백업했다면 원본 권한과 소유권을 그대로 복원하지 않을 수 있습니다. 그래서 복원 뒤 역할과 권한을 다시 적용하고 검증합니다.

읽기 계정과 앱 계정이 원본에서 기대했던 허용·차단 결과를 복원 DB에서도 보이는지 확인합니다.

권한까지 재검증해야 백업이 운영 복구 절차로 의미가 있습니다.

---

## 19. RPO·RTO와 Runbook을 기록합니다

**화면 구성**

Runbook 기록 항목:

```text
도구·서버 버전
백업 계정과 권한
백업 범위와 의존성
파일 경로·크기·해시
복원 DB와 owner
복원 시작·완료 시각
구조·데이터·권한 검증 결과
오류와 해결 방법
RPO·RTO 충족 여부
다음 복원 시험 날짜
```

**발표 스크립트**

복구 절차는 기억에 의존하면 안 됩니다. 누가 실행해도 같은 순서로 따라 할 수 있어야 합니다.

RPO는 허용 가능한 데이터 손실 시간이고, RTO는 서비스 재개 목표 시간입니다. 백업 주기와 복원 시간은 이 두 목표를 만족해야 합니다.

Runbook에는 성공 결과뿐 아니라 오류와 해결 방법도 기록합니다. 그래야 다음 복구 시험이나 실제 장애 대응 때 시간이 줄어듭니다.

---

## 20. 최종 완료 기준은 허용·차단·복원 검증입니다

**화면 구성**

최종 체크:

- `security_lab`만 변경
- 역할과 작업 행렬 작성
- 유효 권한과 PUBLIC·소유권 경로 확인
- 허용 작업 성공
- 차단 작업 실패
- 비밀 정보 저장소·로그 노출 없음
- 백업 파일 목록·해시 확인
- 별도 DB 복원 성공
- 구조·데이터·소유권·권한 재검증
- RPO·RTO와 Runbook 기록

**발표 스크립트**

Chapter 11 실습의 완료 기준은 권한 SQL을 작성했다는 것이 아닙니다.

허용해야 하는 작업이 성공하고, 차단해야 하는 작업이 실패하며, 백업 파일이 별도 DB에서 복원되어야 합니다.

마지막으로 복원된 DB에서 구조, 데이터, 소유권, 권한까지 다시 검증하고 Runbook에 기록하면 보안과 복구 실습이 완료된 것입니다.
