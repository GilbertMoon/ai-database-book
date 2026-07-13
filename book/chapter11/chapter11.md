# Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법

---

## 이 장에서 살펴볼 내용

Chapter 10에서는 `performance_lab`에서 실행 계획을 측정하고 인덱스 효과를 검증했습니다. 빠른 데이터베이스도 접근 권한이 과도하거나, 비밀 정보가 노출되거나, 백업을 복원할 수 없다면 안전한 시스템이라고 할 수 없습니다.

이번 장에서는 PostgreSQL을 기준으로 다음 운영 흐름을 연결합니다.

```text
보호 대상과 위험 식별
→ 로그인 역할과 권한 역할 분리
→ 최소 권한 설계
→ GRANT·REVOKE 후 유효 권한 검증
→ 비밀 정보와 입력값 보호
→ 백업 범위·형식·보관 위치 결정
→ 별도 DB에 복원
→ 구조·데이터·제약조건·권한 검증
→ RPO·RTO와 복구 기록 갱신
```

이 장에서는 다음 내용을 다룹니다.

- 인증, 권한 부여, 객체 소유권과 감사의 차이
- PostgreSQL Role, `LOGIN`, `NOLOGIN`과 역할 멤버십
- 데이터베이스·스키마·테이블·컬럼·시퀀스 권한
- `PUBLIC`과 유효 권한 확인
- 최소 권한과 현재·미래 객체 권한
- 개발·테스트·운영 환경 분리
- 비밀번호·접속 URL·로그·백업 파일 보호
- SQL Injection과 파라미터 바인딩
- `pg_dump`, `pg_restore`, `psql` 기반 논리 백업·복원
- 백업 파일 목록·해시·복원 검증
- RPO, RTO와 복구 실행 기록
- AI가 만든 보안·백업 명령 검토

> **핵심 원칙**
>
> 보안은 권한을 많이 제거하는 일이 아니라 필요한 작업만 허용하고 그 결과를 검증하는 일입니다. 백업은 파일을 만드는 데서 끝나지 않고 별도 환경에서 복원에 성공해야 의미가 있습니다.

---

## 1. 보안 통제와 복구 준비는 함께 설계한다

보안은 하나의 기능이 아니라 여러 통제의 조합입니다.

![보안 통제와 복구 준비](../../images/chapter11/ch11_01_security_backup_overview.svg)

그림 11-1 보안 통제와 복구 준비

| 영역 | 핵심 질문 | 예시 |
| --- | --- | --- |
| 인증 | 접속을 시도하는 주체는 누구인가? | 비밀번호, 인증서, 외부 인증 |
| 권한 부여 | 인증된 주체가 무엇을 할 수 있는가? | SELECT, INSERT, UPDATE |
| 소유권 | 객체를 변경·삭제하고 권한을 부여할 주체는 누구인가? | 테이블 소유 역할 |
| 입력 보호 | 외부 입력이 SQL 구조를 바꿀 수 있는가? | 파라미터 바인딩 |
| 비밀 보호 | 접속 정보와 백업 파일이 노출되지 않는가? | 비밀 저장소, 암호화, 접근 통제 |
| 감사·기록 | 누가 언제 무엇을 실행했는가? | 접속 로그, 변경 기록 |
| 복구 | 장애·실수 후 필요한 시점으로 돌아갈 수 있는가? | 백업, 복원 시험, 복구 절차 |

인증에 성공했다고 모든 테이블을 읽을 수 있는 것은 아닙니다. 객체의 소유자라고 해서 애플리케이션 접속 계정으로 사용하는 것도 바람직하지 않습니다. 하나의 계정에 접속·소유·관리·업무 권한을 모두 집중하면 사고 범위가 커집니다.

---

## 2. 기존 프로젝트를 보호하는 Chapter 11 구조

Chapter 11은 앞 장의 `course_project`, `transaction_lab`, `performance_lab`을 삭제하거나 변경하지 않습니다. 별도의 실습 스키마를 사용합니다.

```text
security_lab.students
security_lab.courses
security_lab.enrollments
```

역할과 권한은 데이터베이스 클러스터 전역에 영향을 줄 수 있으므로 자동 실행하지 않습니다. 역할 생성·삭제와 `GRANT`, `REVOKE` 예시는 별도 파일에서 기본적으로 주석 상태로 제공합니다.

```text
code/chapter11/
├── 01_security_lab_schema.sql
├── 02_security_lab_seed.sql
├── 03_role_permission_plan.sql
├── 04_permission_checks.sql
├── 05_restore_validation.sql
├── BACKUP_RESTORE_RUNBOOK.md
├── reset_security_lab.sql
├── security_backup_check.sql
└── README.md
```

실행 순서는 다음과 같습니다.

```text
01 스키마 생성
→ 02 정상 샘플 입력
→ 03 역할·권한 계획 검토 후 필요한 문장만 테스트 환경에서 실행
→ 04 유효 권한 확인
→ 터미널에서 백업·별도 DB 복원
→ 복원 DB에서 05 검증
→ 실행 결과를 BACKUP_RESTORE_RUNBOOK.md에 기록
```

`security_backup_check.sql`은 기존 링크 호환을 위한 읽기 전용 안내·상태 확인 파일입니다.

---

## 3. 보호할 데이터와 위협을 먼저 정한다

보안 설정을 시작하기 전에 무엇을 보호할지 정합니다.

| 자산 | 예 | 주요 위험 |
| --- | --- | --- |
| 개인정보 | 이름, 이메일 | 과도한 조회, 외부 유출 |
| 인증 정보 | 비밀번호, 토큰, 접속 URL | 계정 탈취 |
| 업무 데이터 | 수강 상태, 결제 금액 | 무단 변경·삭제 |
| 데이터 구조 | 테이블, 제약조건 | 잘못된 ALTER·DROP |
| 로그 | SQL, 오류, 접속 기록 | 비밀 정보 기록 |
| 백업 파일 | 전체 데이터 사본 | 저장소·공유 드라이브 노출 |
| 복구 절차 | 계정, 순서, 검증 기준 | 장애 시 복구 지연 |

위험은 외부 공격만 의미하지 않습니다.

```text
관리자의 잘못된 DELETE
개발 계정으로 운영 DB 접속
공개 저장소에 .env 또는 백업 파일 커밋
ALL PRIVILEGES를 가진 애플리케이션 계정
복원해 본 적 없는 오래된 백업
AI가 만든 DROP·REVOKE·pg_restore 명령의 무검토 실행
```

---

## 4. 인증·권한·소유권을 구분한다

PostgreSQL은 데이터베이스 접근 권한을 Role로 관리합니다.

![PostgreSQL 역할과 객체 권한 구조](../../images/chapter11/ch11_02_account_permission_model.svg)

그림 11-2 PostgreSQL 역할과 객체 권한 구조

| 개념 | 질문 | 예 |
| --- | --- | --- |
| 인증 | 접속 주체가 누구인가? | LOGIN Role, 인증 설정 |
| 권한 부여 | 어떤 객체에서 어떤 작업이 가능한가? | SELECT, INSERT, USAGE |
| 소유권 | 객체 정의 변경과 권한 부여 주체는 누구인가? | 테이블 owner |
| 역할 멤버십 | 다른 역할의 권한을 사용할 수 있는가? | GRANT role TO user |

객체 소유자는 일반 권한과 별도로 객체를 변경·삭제하거나 다른 역할에 권한을 부여할 수 있습니다. 따라서 애플리케이션 계정을 객체 소유자로 두기보다 소유 역할과 실행 역할을 분리하는 구조를 검토합니다.

---

## 5. 로그인 역할과 권한 역할을 분리한다

| 역할 종류 | LOGIN | 목적 | Chapter 11 예시 |
| --- | --- | --- | --- |
| 소유 역할 | 보통 NOLOGIN | 객체 소유와 권한 관리 | `lab_role_security_owner` |
| 읽기 권한 역할 | NOLOGIN | 보고용 SELECT 묶음 | `lab_role_report_reader` |
| 앱 권한 역할 | NOLOGIN | 서비스 실행 권한 묶음 | `lab_role_enrollment_app` |
| 읽기 로그인 역할 | LOGIN | 실제 보고 사용자 접속 | `lab_readonly_user` |
| 앱 로그인 역할 | LOGIN | 애플리케이션 접속 | `lab_enrollment_user` |

기본 관계는 다음과 같습니다.

```sql
-- 관리자 권한이 있는 테스트 환경에서만 선택 실행
-- CREATE ROLE lab_role_report_reader NOLOGIN;
-- CREATE ROLE lab_role_enrollment_app NOLOGIN;
-- CREATE ROLE lab_readonly_user LOGIN;
-- CREATE ROLE lab_enrollment_user LOGIN;
-- GRANT lab_role_report_reader TO lab_readonly_user;
-- GRANT lab_role_enrollment_app TO lab_enrollment_user;
```

예제에는 실제 비밀번호를 넣지 않습니다. 로그인 역할의 비밀번호나 인증서는 조직의 비밀 정보 관리 절차에서 별도로 설정합니다.

역할 이름은 클러스터 전역에서 공유될 수 있으므로 실습용 접두사를 사용하고, 기존 역할과 충돌하지 않는지 먼저 확인합니다.

---

## 6. 권한은 객체 범위별로 나뉜다

| 범위 | 대표 권한 | 의미 |
| --- | --- | --- |
| 데이터베이스 | `CONNECT` | 데이터베이스 접속 허용 |
| 스키마 | `USAGE` | 스키마 내부 객체 이름 사용 |
| 스키마 | `CREATE` | 스키마 안에 새 객체 생성 |
| 테이블 | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | 행 조회·변경 |
| 컬럼 | `SELECT`, `INSERT`, `UPDATE` | 특정 컬럼 작업 |
| 시퀀스 | `USAGE`, `SELECT`, `UPDATE` | 번호 생성·조회·설정 |
| 역할 | 멤버십 | 다른 역할의 권한 사용 |

```text
CONNECT만 있다고 테이블을 읽을 수 없다.
USAGE만 있다고 SELECT할 수 없다.
INSERT 권한만 있다고 자동 ID 생성이 항상 가능한 것은 아니다.
```

Chapter 11은 `IDENTITY` 기본키를 사용합니다. ID를 생략한 INSERT에는 내부 시퀀스 사용 권한이 필요할 수 있으므로 테이블과 시퀀스 권한을 함께 검토합니다.

---

## 7. security_lab 스키마와 테스트 데이터

`01_security_lab_schema.sql`은 자동 삭제 없이 다음 구조를 만듭니다.

```text
security_lab.students
- id IDENTITY PK
- name NOT NULL + 공백 CHECK
- email UNIQUE NOT NULL
- joined_at NOT NULL

security_lab.courses
- id IDENTITY PK
- title NOT NULL + 공백 CHECK
- level CHECK
- price CHECK

security_lab.enrollments
- id IDENTITY PK
- student_id FK
- course_id FK
- status CHECK
- paid_amount CHECK
- enrolled_at NOT NULL
```

`02_security_lab_seed.sql`은 명시적 ID를 사용합니다.

```text
students: 101, 102, 103
courses: 201, 202, 203
enrollments: 1001, 1002, 1003
```

기대 행 수:

| 테이블 | 행 수 |
| --- | ---: |
| students | 3 |
| courses | 3 |
| enrollments | 3 |
| JOIN 결과 | 3 |

같은 학생의 같은 강의 재신청 정책은 확정되지 않았으므로 `UNIQUE(student_id, course_id)`를 임의로 적용하지 않습니다.

---

## 8. 최소 권한을 작업 행렬로 설계한다

![최소 권한 설계 절차](../../images/chapter11/ch11_03_least_privilege_principle.svg)

그림 11-3 최소 권한 설계 절차

먼저 역할별 필요한 작업을 표로 정리합니다.

| 객체 | 보고 역할 | 수강신청 앱 역할 |
| --- | --- | --- |
| students | SELECT | SELECT |
| courses | SELECT | SELECT |
| enrollments | SELECT | SELECT, INSERT, status UPDATE |
| enrollments ID 시퀀스 | 불필요 | USAGE, SELECT |
| DELETE | 불허 | 불허 |
| 스키마 CREATE | 불허 | 불허 |

권한 예시는 다음과 같습니다.

```sql
-- GRANT CONNECT ON DATABASE ai_database_book
-- TO lab_role_report_reader, lab_role_enrollment_app;

-- GRANT USAGE ON SCHEMA security_lab
-- TO lab_role_report_reader, lab_role_enrollment_app;

-- GRANT SELECT ON TABLE
--     security_lab.students,
--     security_lab.courses,
--     security_lab.enrollments
-- TO lab_role_report_reader;

-- GRANT SELECT ON TABLE
--     security_lab.students,
--     security_lab.courses,
--     security_lab.enrollments
-- TO lab_role_enrollment_app;

-- GRANT INSERT ON TABLE security_lab.enrollments
-- TO lab_role_enrollment_app;

-- GRANT UPDATE (status) ON TABLE security_lab.enrollments
-- TO lab_role_enrollment_app;

-- GRANT USAGE, SELECT
-- ON SEQUENCE security_lab.enrollments_id_seq
-- TO lab_role_enrollment_app;
```

기본 예시에서는 `SUPERUSER`, `CREATEDB`, `CREATEROLE`, `ALL PRIVILEGES`, `DELETE`, 스키마 `CREATE`를 부여하지 않습니다.

---

## 9. GRANT·REVOKE 후에는 유효 권한을 확인한다

![GRANT·REVOKE와 유효 권한 확인](../../images/chapter11/ch11_04_grant_revoke_flow.svg)

그림 11-4 GRANT·REVOKE와 유효 권한 확인

`REVOKE`는 특정 경로로 부여된 권한을 회수합니다. 같은 권한이 다음 경로로 남을 수 있습니다.

```text
다른 권한 역할 멤버십
직접 부여된 권한
PUBLIC 권한
객체 소유권
상위 역할에서 상속된 권한
```

역할 존재 여부를 먼저 확인합니다.

```sql
SELECT rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole
FROM pg_roles
WHERE rolname LIKE 'lab_%'
ORDER BY rolname;
```

역할을 만든 테스트 환경에서는 유효 권한을 확인합니다.

```sql
-- SELECT has_database_privilege(
--     'lab_readonly_user',
--     'ai_database_book',
--     'CONNECT'
-- );

-- SELECT has_schema_privilege(
--     'lab_readonly_user',
--     'security_lab',
--     'USAGE'
-- );

-- SELECT has_table_privilege(
--     'lab_readonly_user',
--     'security_lab.enrollments',
--     'SELECT'
-- );

-- SELECT has_table_privilege(
--     'lab_readonly_user',
--     'security_lab.enrollments',
--     'INSERT'
-- );
```

읽기 계정의 기대 결과는 다음과 같습니다.

```text
CONNECT = true
schema USAGE = true
enrollments SELECT = true
enrollments INSERT = false
enrollments DELETE = false
```

명시적 권한 목록과 역할 멤버십도 함께 확인합니다.

```sql
SELECT *
FROM information_schema.role_table_grants
WHERE table_schema = 'security_lab'
ORDER BY grantee, table_name, privilege_type;
```

---

## 10. 현재 객체와 미래 객체 권한을 구분한다

현재 테이블에 실행한 `GRANT SELECT`는 나중에 생성되는 새 테이블에 자동 적용되지 않습니다.

```text
현재 객체 GRANT
→ 지금 존재하는 객체에 적용

ALTER DEFAULT PRIVILEGES
→ 특정 소유 역할이 앞으로 만들 객체의 기본 권한 설정
```

예시:

```sql
-- ALTER DEFAULT PRIVILEGES
-- FOR ROLE lab_role_security_owner
-- IN SCHEMA security_lab
-- GRANT SELECT ON TABLES TO lab_role_report_reader;
```

Default Privileges는 **어떤 역할이 미래 객체를 생성하는가**에 따라 달라집니다. 스키마 이름만 맞는다고 충분하지 않습니다. 기존 객체의 권한을 바꾸지도 않습니다.

---

## 11. PUBLIC과 객체 소유권을 확인한다

`PUBLIC`은 모든 역할을 의미하는 특별한 이름입니다. 권한 설계에서는 다음을 확인합니다.

```text
데이터베이스 CONNECT가 PUBLIC에 열려 있는가?
스키마 CREATE 또는 USAGE가 PUBLIC에 부여되어 있는가?
테이블·함수에 PUBLIC 권한이 있는가?
현재 접속 역할이 객체 소유자인가?
```

무조건적인 `REVOKE ALL ... FROM PUBLIC`도 위험할 수 있습니다. 현재 접속 방식과 다른 애플리케이션의 의존성을 먼저 조사하고 테스트 환경에서 변경합니다.

소유 역할과 실행 역할을 분리하면 앱 계정에서 `DROP TABLE`, `ALTER TABLE`, 권한 재부여 같은 작업을 제한하기 쉽습니다.

---

## 12. 개발·테스트·운영 환경을 분리한다

![개발·운영 환경과 계정 분리](../../images/chapter11/ch11_05_dev_prod_account_separation.svg)

그림 11-5 개발·운영 환경과 계정 분리

| 환경 | 데이터 | 계정 | 권한 | 백업 |
| --- | --- | --- | --- | --- |
| 개발 | 가상·비식별 데이터 | 개발 전용 | 필요한 개발 권한 | 짧은 보존 가능 |
| 테스트 | 검증용 데이터 | 테스트 전용 | 운영과 유사한 제한 | 복원 시험 가능 |
| 운영 | 실제 데이터 | 운영 전용 | 최소 권한 | 암호화·보존·감사 |

개발 도구에서 운영 연결을 함께 관리한다면 연결 이름·색상·읽기 전용 설정과 승인 절차를 구분합니다. 운영 계정을 개발 스크립트에 하드코딩하지 않습니다.

루트 `.env.example`에는 변수명만 두고 실제 값은 비워 둡니다.

```text
PGHOST=
PGPORT=
PGDATABASE=
PGUSER=
PGPASSWORD=
```

실제 `.env`, 백업 파일과 압축 백업은 `.gitignore`에서 제외합니다.

비밀 정보가 노출되면 Git 기록에서 파일을 삭제하는 것만으로 끝내지 않습니다. 먼저 비밀번호·토큰을 폐기하거나 회전하고, 로그·복제본·캐시·배포 환경의 노출 범위를 확인합니다.

---

## 13. SQL Injection은 SQL 구조와 값을 분리해 방어한다

![문자열 결합과 파라미터 바인딩](../../images/chapter11/ch11_06_sql_injection_safe_query.svg)

그림 11-6 문자열 결합과 파라미터 바인딩

위험한 방향:

```text
"SELECT * FROM security_lab.students WHERE email = '"
+ user_input
+ "'"
```

안전한 방향:

```text
SQL: SELECT * FROM security_lab.students WHERE email = $1
값: user_input
```

파라미터 바인딩은 값이 SQL 문법으로 해석되지 않도록 SQL 구조와 데이터를 분리합니다.

테이블명, 컬럼명과 정렬 방향은 일반적으로 값 파라미터로 바인딩할 수 없습니다. 사용자 입력을 그대로 식별자로 연결하지 않고 애플리케이션의 허용 목록에서만 선택합니다.

```text
허용 정렬 컬럼: name, joined_at
허용 정렬 방향: asc, desc
그 밖의 값: 거부
```

입력 검증만으로 방어가 끝나지 않습니다. 파라미터 바인딩, 허용 목록, 최소 권한 계정, 오류 메시지 제한과 보안 테스트를 함께 사용합니다.

---

## 14. 로그와 백업 파일도 민감 데이터다

백업에는 원본 테이블의 개인정보와 업무 데이터가 포함될 수 있습니다. SQL 로그에는 입력값과 접속 정보가 남을 수 있습니다.

```text
백업을 공개 저장소에 커밋하지 않는다.
백업이 자동 암호화된다고 가정하지 않는다.
백업 저장 위치·전송 경로·보관 기간·삭제 정책을 정한다.
백업 접근 권한과 다운로드 기록을 관리한다.
로그에 비밀번호·토큰·전체 접속 URL을 남기지 않는다.
복원용 임시 DB와 임시 파일도 삭제 정책에 포함한다.
```

백업 파일은 운영 DB보다 접근하기 쉬운 경로에 놓이기 쉬우므로 원본 데이터와 같은 수준으로 보호합니다.

---

## 15. 백업·복제·고가용성은 목적이 다르다

| 방식 | 주요 목적 | 실수 삭제 대응 | 주의점 |
| --- | --- | --- | --- |
| 논리 백업 | 구조·데이터 복원·이관 | 백업 시점으로 복원 가능 | 복원 시간·의존 객체 검증 |
| 물리 백업·PITR | 클러스터와 특정 시점 복구 | 설정에 따라 가능 | WAL·보관 정책 필요 |
| 복제 | 가용성·읽기 분산 | 삭제가 복제될 수 있음 | 백업 대체 불가 |
| 스냅샷 | 스토리지 시점 사본 | 일관성·보존 정책에 따라 다름 | DB 일관성과 복원 검증 필요 |

이 장에서는 입문 수준의 논리 백업과 복원 검증에 집중합니다.

---

## 16. 백업 범위와 형식을 결정한다

`pg_dump`는 한 데이터베이스를 논리적으로 내보냅니다. 역할과 같은 클러스터 전역 객체는 데이터베이스 덤프와 별도로 관리해야 할 수 있습니다.

### security_lab만 사용자 정의 형식으로 백업

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  --schema=security_lab \
  --no-owner \
  --no-privileges \
  -f <backup-dir>/security_lab.backup
```

이 예시는 테스트 복원 이동성을 높이기 위해 소유권과 ACL을 제외합니다. 따라서 복원 뒤 역할·권한 계획을 별도로 적용하고 검증해야 합니다.

### 전체 데이터베이스 사용자 정의 형식 백업

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  -f <backup-dir>/ai_database_book.backup
```

### 전역 역할 목록 백업

```bash
pg_dumpall \
  --globals-only \
  -U <admin_user> \
  -f <secure-backup-dir>/globals.sql
```

전역 역할 파일에는 역할 정의와 민감한 운영 정보가 포함될 수 있으므로 접근과 보관을 더 엄격하게 관리합니다. 같은 클러스터에 복원하면 이미 존재하는 역할과 충돌할 수 있으므로 별도 검토 없이 실행하지 않습니다.

백업 명령은 DBeaver SQL Editor가 아니라 PostgreSQL 클라이언트 도구가 설치된 터미널에서 실행합니다. 명령줄에 비밀번호를 직접 쓰지 않습니다.

---

## 17. 백업 파일 자체를 검증한다

파일이 생성되었다는 메시지만으로 백업이 정상이라고 판단하지 않습니다.

```text
명령 종료 코드 확인
표준 오류의 경고 확인
파일 크기 확인
생성 시각과 대상 DB 기록
pg_restore --list로 아카이브 목록 확인
SHA-256 해시 기록
보관 위치와 접근 권한 확인
```

사용자 정의 형식 목록 확인:

```bash
pg_restore --list <backup-dir>/security_lab.backup
```

Windows PowerShell 해시 예:

```powershell
Get-FileHash <backup-dir>\security_lab.backup -Algorithm SHA256
```

Linux·macOS 해시 예:

```bash
sha256sum <backup-dir>/security_lab.backup
```

해시는 파일이 이후 변경되었는지 확인하는 근거이지 백업 내용이 실제로 복원된다는 증거는 아닙니다.

---

## 18. 별도 데이터베이스에서 복원한다

![백업 생성에서 복구 검증까지](../../images/chapter11/ch11_07_backup_restore_flow.svg)

그림 11-7 백업 생성에서 복구 검증까지

원본 DB에 덮어쓰지 않고 별도 검증 DB를 만듭니다.

```bash
createdb -U <admin_user> ai_database_book_restore
```

사용자 정의 형식 복원:

```bash
pg_restore \
  -U <restore_user> \
  -d ai_database_book_restore \
  --exit-on-error \
  --no-owner \
  --no-privileges \
  <backup-dir>/security_lab.backup
```

텍스트 SQL 백업이라면 오류 발생 시 중단하도록 실행합니다.

```bash
psql \
  -U <restore_user> \
  -d ai_database_book_restore \
  -v ON_ERROR_STOP=1 \
  -f <backup-dir>/security_lab.sql
```

백업 출처가 신뢰할 수 있는지도 확인합니다. 복원은 대상 서버에서 SQL과 객체 정의를 실행하는 작업이므로 신뢰할 수 없는 덤프를 검토 없이 실행하지 않습니다.

---

## 19. 복원 후 구조·데이터·권한을 검증한다

복원 DB에서 `05_restore_validation.sql`을 실행합니다.

### 데이터 기준

| 검증 대상 | 기대 결과 |
| --- | ---: |
| students | 3 |
| courses | 3 |
| enrollments | 3 |
| JOIN 결과 | 3 |
| 고아 student FK | 0 |
| 고아 course FK | 0 |

### 구조 기준

```text
security_lab 스키마 존재
세 테이블 존재
PK·FK·UNIQUE·CHECK 유지
IDENTITY 시퀀스 존재
컬럼 타입과 NOT NULL 유지
```

### 권한 기준

`--no-owner --no-privileges`로 복원했다면 원래 ACL이 복원되지 않는 것이 정상입니다. 역할·권한 계획을 적용한 뒤 다음을 확인합니다.

```text
보고 역할: SELECT 가능, INSERT·UPDATE·DELETE 불가
앱 역할: 학생·강의 SELECT 가능
앱 역할: 신청 SELECT·INSERT·status UPDATE 가능
앱 역할: DELETE와 스키마 CREATE 불가
```

복원 검증이 실패하면 백업 파일을 성공으로 표시하지 않습니다. 원인을 수정하고 다시 백업·복원·검증합니다.

---

## 20. RPO·RTO와 복구 실행 기록

| 기준 | 질문 | 예시 |
| --- | --- | --- |
| RPO | 장애 시 어느 시점까지 데이터 손실을 허용하는가? | 최대 1시간 |
| RTO | 장애 후 얼마 안에 서비스를 재개해야 하는가? | 2시간 |

RPO가 1시간이라면 하루 한 번의 백업만으로는 기준을 충족하지 못할 수 있습니다. RTO가 짧다면 백업 파일은 있어도 복원 시간이 너무 길 수 있습니다.

`BACKUP_RESTORE_RUNBOOK.md`에 다음을 기록합니다.

```text
백업 대상과 제외 범위
백업 형식과 저장 위치
담당 역할
RPO·RTO
명령과 도구 버전
파일 크기·해시
복원 DB 이름
복원 시작·완료 시각
검증 SQL과 결과
오류와 해결 방법
다음 복원 시험 날짜
```

복구 절차는 담당자가 기억하는 지식이 아니라 반복 실행할 수 있는 문서여야 합니다.

---

## 21. AI 보안·백업 명령 검토

![AI 보안·백업 명령 검토 흐름](../../images/chapter11/ch11_08_ai_security_review_flow.svg)

그림 11-8 AI 보안·백업 명령 검토 흐름

AI 요청에는 범위와 금지사항을 명시합니다.

```text
PostgreSQL security_lab에 대해 읽기 역할과 수강신청 앱 역할의
최소 권한 초안을 작성해 주세요.

조건:
- 실제 비밀번호 작성 금지
- SUPERUSER, CREATEDB, CREATEROLE, ALL PRIVILEGES 금지
- 앱은 students·courses SELECT
- enrollments는 SELECT, INSERT, status 컬럼 UPDATE만 허용
- DELETE와 스키마 CREATE 금지
- IDENTITY 시퀀스 권한 검토
- 역할 생성과 GRANT는 기본 주석 상태
- 적용 후 has_*_privilege 검증 SQL 포함
```

백업 명령 검토표:

| 검토 영역 | 확인 질문 |
| --- | --- |
| 환경 | 테스트·운영 중 대상이 명확한가? |
| 범위 | 전체 DB와 특정 스키마 중 의도한 범위인가? |
| 출력 위치 | 저장소 밖의 보호된 경로인가? |
| 자격 증명 | 명령·문서에 비밀번호가 없는가? |
| 소유권·ACL | 포함·제외 결정과 복원 후 처리 계획이 있는가? |
| 역할 | DB 덤프에 전역 역할이 자동 포함된다고 오해하지 않는가? |
| 실패 처리 | 종료 코드·경고·exit-on-error를 확인하는가? |
| 검증 | 별도 DB 복원과 검증 SQL이 포함되는가? |
| 정리 | 복원 DB와 임시 파일의 삭제 계획이 있는가? |

대표적인 위험한 AI 제안:

```text
앱 계정에 SUPERUSER 또는 ALL PRIVILEGES 부여
public 스키마 전체에 무제한 CREATE 허용
실제 비밀번호를 CREATE ROLE 문에 포함
원본 DB에 --clean 복원을 바로 실행
백업 파일을 프로젝트 폴더에 생성
역할·소유권·ACL 차이를 설명하지 않음
복원 없이 백업 성공이라고 판단
```

---

## 22. 자주 하는 실수

### 실수 1. 인증 성공을 데이터 접근 허용과 동일하게 생각한다

데이터베이스·스키마·테이블 권한을 모두 확인합니다.

### 실수 2. 앱 계정을 객체 소유자로 사용한다

소유 역할과 실행 역할을 분리합니다.

### 실수 3. REVOKE 한 번으로 모든 권한이 사라졌다고 생각한다

직접 권한, 역할 멤버십, PUBLIC과 소유권을 확인합니다.

### 실수 4. 현재 테이블 GRANT가 미래 테이블에도 적용된다고 생각한다

Default Privileges의 객체 생성 역할과 범위를 별도로 검토합니다.

### 실수 5. 실제 비밀번호·접속 URL을 저장소에 기록한다

빈 `.env.example`만 제공하고 실제 값은 비밀 저장소에서 관리합니다.

### 실수 6. 값 파라미터 바인딩으로 테이블명까지 안전해진다고 생각한다

동적 식별자는 허용 목록으로 제한합니다.

### 실수 7. 백업이 자동으로 암호화된다고 가정한다

형식과 별도로 저장·전송 암호화 정책을 확인합니다.

### 실수 8. 백업 파일이 존재하므로 복구 가능하다고 판단한다

별도 DB에서 실제 복원하고 검증합니다.

### 실수 9. 역할도 pg_dump에 모두 포함된다고 생각한다

클러스터 전역 역할은 별도 관리가 필요합니다.

### 실수 10. 원본 DB에 복원 명령을 먼저 실행한다

별도 복원 DB에서 검증한 뒤 승인된 복구 절차를 따릅니다.

---

## 23. 스스로 확인하기

1. 인증·권한 부여·소유권은 어떻게 다른가요?
2. LOGIN 역할과 NOLOGIN 권한 역할을 분리하는 이유는 무엇인가요?
3. CONNECT, schema USAGE와 table SELECT가 각각 필요한 이유는 무엇인가요?
4. IDENTITY INSERT에서 시퀀스 권한을 확인해야 하는 이유는 무엇인가요?
5. REVOKE 후에도 권한이 남을 수 있는 경로를 설명해 보세요.
6. Default Privileges가 기존 객체 권한을 바꾸지 않는 이유는 무엇인가요?
7. SQL 값과 동적 식별자의 안전 처리 방식은 어떻게 다른가요?
8. 백업과 복제가 서로 대체되지 않는 이유는 무엇인가요?
9. `--no-owner --no-privileges` 백업의 장점과 후속 작업은 무엇인가요?
10. 백업 파일 목록과 해시 검증이 실제 복원을 대신할 수 없는 이유는 무엇인가요?
11. RPO와 RTO는 백업 주기와 복원 절차에 어떤 영향을 주나요?
12. AI가 만든 GRANT·pg_restore 명령에서 가장 먼저 확인할 항목은 무엇인가요?

---

## 24. 핵심 정리

```text
1. 인증·권한·소유권·감사는 서로 다른 통제다.
2. 로그인 역할과 권한 역할을 분리하면 권한을 일관되게 관리하기 쉽다.
3. 최소 권한은 실제 작업 행렬에서 출발한다.
4. GRANT·REVOKE 후에는 멤버십·PUBLIC·소유권을 포함한 유효 권한을 확인한다.
5. 현재 객체 권한과 미래 객체 Default Privileges를 구분한다.
6. 비밀번호·접속 URL·로그·백업은 저장소 밖에서 보호한다.
7. SQL Injection 방어는 파라미터 바인딩·허용 목록·최소 권한을 함께 사용한다.
8. pg_dump의 범위·형식·소유권·ACL 포함 여부를 명시한다.
9. 백업 파일은 목록·해시뿐 아니라 별도 DB 복원으로 검증한다.
10. RPO·RTO와 복원 결과를 실행 가능한 복구 문서로 유지한다.
```

이 장에서 기억할 문장은 다음과 같습니다.

```text
허용할 작업은 최소화하고,
복구 가능성은 실제 복원으로 증명한다.
```

---

## 25. 다음 장에서는

Chapter 12에서는 관계형 데이터베이스와 다른 데이터 모델을 제공하는 NoSQL을 살펴봅니다.

```text
문서·키-값·그래프·와이드 컬럼 모델
스키마 유연성과 데이터 중복
일관성·확장성·조회 패턴
PostgreSQL JSONB와 전용 NoSQL의 차이
관계형 DB와 NoSQL 선택 기준
AI가 제안한 저장소 선택 검토
```

보안과 복구는 특정 DBMS에만 필요한 기능이 아닙니다. 어떤 저장소를 선택하더라도 접근 통제, 비밀 보호, 백업과 복구 검증이 함께 설계되어야 합니다.
