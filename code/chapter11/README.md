# Chapter 11 실습 코드

## 데이터베이스를 안전하게 지키고 복구하는 방법

기준 환경은 **PostgreSQL 16**입니다. 이 폴더는 기존 프로젝트를 변경하지 않고 `security_lab`에서 최소 권한을 설계하고, custom archive를 별도 데이터베이스에 복원해 구조·데이터·소유권과 권한을 검증합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 존재하면 변경하지 않음
performance_lab: 존재하면 변경하지 않음
public: 변경하지 않음
security_lab: Chapter 11 실습 대상
Role: 클러스터 전역 객체이므로 자동 생성·삭제하지 않음
```

Chapter 11의 필수 시작 기준은 Chapter 07·08의 `course_project`입니다.

```text
3 / 2 / 3 / 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
recorded_amount NUMERIC(12,0)
전체 590000
활성 3 / 340000
취소 제외 4 / 440000
1001 완료 / 100000
1004 취소 / 150000
1005 신청 / 120000
```

모든 SQL은 다음 위치 확인 형식을 사용합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_security_lab_schema.sql` | Chapter 07·08 전체 기준을 검사하고 스키마·테이블·부분 고유 인덱스를 한 트랜잭션에서 생성·검증 |
| `02_security_lab_seed.sql` | 3/3/3 샘플, 상태 분포, 총 310000, IDENTITY와 무결성 자동 검증 |
| `03_role_permission_plan.sql` | PostgreSQL 16 membership, Role·GRANT·REVOKE·Default Privileges·백업 역할·소유권·정리 계획 |
| `04_permission_checks.sql` | PUBLIC·ACL·membership 옵션·RLS·시퀀스·유효 권한 확인 |
| `05_permission_behavior_tests.sql` | 읽기·앱 계정 허용 동작과 기준 보존, 차단 동작 선택 실습 |
| `05_restore_validation.sql` | 기존 링크 호환용 안내 |
| `06_restore_validation.sql` | 별도 복원 DB의 구조·데이터·금액·제약조건·IDENTITY·소유권 자동 검증 |
| `BACKUP_RESTORE_RUNBOOK.md` | 버전·권한·RLS·의존성·archive·원자적 복원·2단계 검증 실행 기록 |
| `reset_security_lab.sql` | CASCADE 없이 transaction으로 `security_lab`만 초기화, 예상 밖 객체가 있으면 전체 ROLLBACK |
| `security_backup_check.sql` | 읽기 전용 안내·상태 확인 진입점 |

---

## 실행 순서

```text
01_security_lab_schema.sql
→ 02_security_lab_seed.sql
→ 03_role_permission_plan.sql에서 필요한 문장만 선택 실행
→ 04_permission_checks.sql
→ 05_permission_behavior_tests.sql 선택 실습
→ 터미널에서 custom archive 백업
→ 별도 DB 생성·원자적 복원
→ 복원 DB에서 06_restore_validation.sql
→ 역할 재적용 후 04·05 권한 재검증
→ BACKUP_RESTORE_RUNBOOK.md 기록
```

Role 생성과 권한 변경은 관리자 권한이 있는 테스트 환경에서만 수행합니다.

---

## security_lab 기준 상태

```text
students = 3
courses = 3
enrollments = 3
JOIN = 3
상태 = 신청1 / 수강중1 / 완료1 / 취소0
recorded_amount 합계 = 310000
활성 신청 = 2
활성 중복 = 0
recorded_amount와 course.price 불일치 = 0
```

| 테이블 | 명시적 ID | IDENTITY 다음 값 |
| --- | --- | ---: |
| `security_lab.students` | 101~103 | 104 이상 |
| `security_lab.courses` | 201~203 | 204 이상 |
| `security_lab.enrollments` | 1001~1003 | 1004 이상 |

`recorded_amount`는 **신청 시점에 신청 행에 기록한 금액**이며 `NUMERIC(12,0)`입니다. 실제 결제 승인액·환불 반영 순매출·회계 매출을 의미하지 않습니다.

Chapter 07의 활성 신청 정책을 유지합니다.

```sql
CREATE UNIQUE INDEX uq_security_enrollments_active
ON security_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

완료·취소 이력은 여러 건 허용하지만 진행 중 신청은 학생·강의 조합당 한 건입니다.

학생 이메일은 `NOT NULL`, 정확히 같은 문자열에 대한 `UNIQUE`, 공백 문자열 방지 `CHECK`를 사용합니다. 대소문자 정규화는 이 장의 범위가 아닙니다.

---

## 역할 예시

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_role_backup_reader NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
lab_backup_user LOGIN
```

실제 비밀번호나 password file은 SQL과 저장소에 기록하지 않습니다.

### PostgreSQL 16 membership

교재의 의도:

```text
report_reader → readonly_user   : INHERIT TRUE / SET TRUE
app_role      → enrollment_user : INHERIT TRUE / SET TRUE
backup_reader → backup_user     : INHERIT TRUE / SET TRUE
ADMIN OPTION  : 기본 불필요
```

다음을 함께 확인합니다.

```text
pg_has_role(..., 'MEMBER')
pg_has_role(..., 'USAGE')
pg_auth_members.inherit_option
pg_auth_members.set_option
pg_auth_members.admin_option
```

---

## 최소 권한 기준

### 보고 역할

```text
DB CONNECT
security_lab USAGE
students·courses·enrollments SELECT
INSERT·UPDATE·DELETE·schema CREATE 불허
```

### 수강신청 앱 역할

```text
DB CONNECT
security_lab USAGE
students·courses·enrollments SELECT
enrollments INSERT
enrollments.status 컬럼 UPDATE
enrollments_id_seq USAGE
recorded_amount UPDATE·DELETE·TRUNCATE·schema CREATE 불허
```

`nextval()` 사용에는 시퀀스 `USAGE`면 충분합니다. 시퀀스 상태를 직접 조회할 업무 요구가 없다면 앱 역할에 `SELECT`는 부여하지 않습니다.

### 백업 역할

```text
DB CONNECT
security_lab USAGE
students·courses·enrollments SELECT
students_id_seq·courses_id_seq·enrollments_id_seq SELECT
INSERT·UPDATE·DELETE·schema CREATE 불허
```

앱 역할과 달리 백업 역할은 IDENTITY 시퀀스의 현재 상태 보존이 목적이므로 sequence `SELECT`를 명시적으로 검토합니다.

---

## PUBLIC·membership·유효 권한

```text
has_*_privilege
→ 최종적으로 사용할 수 있는 유효 권한

pg_database.datacl·pg_namespace.nspacl·객체 ACL
→ 직접 GRANT와 PUBLIC 같은 권한 경로

information_schema.table_privileges / column_privileges
→ PUBLIC 테이블·컬럼 권한

pg_has_role MEMBER / USAGE
→ 멤버십 존재 / 즉시 사용할 수 있는 권한

pg_auth_members
→ PostgreSQL 16 membership의 INHERIT·SET·ADMIN 옵션
```

`role_table_grants`만으로 PUBLIC 권한까지 확인했다고 생각하지 않습니다.

---

## 권한 동작 테스트

`05_permission_behavior_tests.sql`은 다음 결과를 목표로 합니다.

```text
읽기 계정
- SELECT 성공
- INSERT·UPDATE·DELETE 실패

앱 계정
- SELECT 성공
- ID 생략 INSERT 성공
- status UPDATE 성공
- recorded_amount UPDATE·DELETE·schema CREATE 실패
```

허용 테스트는 마지막에 `ROLLBACK`합니다. 실패 문장은 기본 주석 상태이며 한 문장씩 선택합니다.

```text
테스트 뒤 students / courses / enrollments = 3 / 3 / 3
총 recorded_amount = 310000
활성 중복 = 0
```

IDENTITY 번호는 실패·ROLLBACK 후에도 공백이 생길 수 있으므로 연속 번호를 정합성 기준으로 사용하지 않습니다.

---

## RLS 확인

`04_permission_checks.sql`은 `security_lab`의 `relrowsecurity`와 `relforcerowsecurity`를 조회합니다. 교재 실습에서는 모두 `false`여야 합니다.

일반적인 전체 논리 백업에서는 `pg_dump`가 RLS를 끄고 모든 행을 읽으려 하며, 백업 역할이 정책을 우회하지 못하면 오류가 날 수 있습니다. `--enable-row-security`는 역할에게 보이는 행만 의도적으로 덤프할 때 별도 검토하며 전체 백업과 같은 의미로 사용하지 않습니다.

---

## 자격 증명과 저장소 보호

루트 `.env.example`에는 다음 변수 이름만 둡니다.

```text
PGHOST=
PGPORT=
PGDATABASE=
PGUSER=
PGPASSFILE=
```

실제 libpq password file은 저장소 밖에 두고 OS 접근 권한을 제한합니다. `.gitignore`는 `.env`, password file, 백업·덤프와 압축 SQL 파일을 제외합니다.

노출이 발생하면 Git 기록에서 파일을 지우는 것보다 먼저 자격 증명을 폐기·회전합니다.

---

## 백업 전 확인

```text
- pg_dump·pg_restore·psql 버전
- 원본·복원 서버 버전
- 백업 로그인 역할과 권한 역할
- membership INHERIT·SET 상태
- DB CONNECT·schema USAGE·테이블 SELECT·시퀀스 SELECT
- RLS 적용 여부
- 전체 백업과 --enable-row-security 가시 행 백업 구분
- security_lab의 외부 FK·타입·함수·트리거·확장·Large Object·외부 테이블 의존성
- 출력 경로와 암호화·보관 정책
```

현재 `security_lab`은 외부 스키마 의존성 없이 단독 복원할 수 있도록 구성했습니다.

---

## custom archive 백업

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  --schema=security_lab \
  -f <backup-dir>/security_lab.backup
```

custom archive에는 원본 owner·ACL 메타데이터를 보존할 수 있습니다. **archive 형식의 `pg_dump --no-owner`로 소유권이 제거된다고 설명하지 않습니다.** 실제 검증 복원에서 원본 owner 적용을 생략하려면 `pg_restore --no-owner`를 사용합니다.

아카이브 목록:

```bash
pg_restore --list <backup-dir>/security_lab.backup
```

확인 대상:

```text
security_lab
3 tables
3 IDENTITY sequences + sequence set
13 named constraints
uq_security_enrollments_active
ACL entries
예상 밖 외부 객체 없음
```

---

## 별도 DB와 원자적 복원

```bash
createdb \
  -U <admin_user> \
  -O <restore_user> \
  -T template0 \
  ai_database_book_restore
```

```bash
pg_restore \
  -U <restore_user> \
  -d ai_database_book_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  <backup-dir>/security_lab.backup
```

```text
--single-transaction → 작은 실습의 부분 복원 위험 감소
--no-owner           → archive 원본 owner 적용 생략
--no-privileges      → archive 원본 ACL 적용 생략
```

Plain SQL은 `psql -X -1 -v ON_ERROR_STOP=1`로 실행합니다.

대규모 운영 복원에서는 긴 트랜잭션, 잠금, WAL, 디스크 공간과 자원 사용을 별도로 검토합니다.

---

## 복원 검증 2단계

### 1단계: `06_restore_validation.sql`

```text
DB = ai_database_book_restore
students·courses·enrollments = 3/3/3
JOIN = 3
상태 = 신청1 / 수강중1 / 완료1 / 취소0
총 recorded_amount = 310000
recorded_amount = NUMERIC(12,0)
amount-course.price 불일치 = 0
고아 FK·활성 중복 = 0
NOT NULL = 14
13개 명시 제약조건 유지
부분 고유 인덱스 valid/ready
IDENTITY 시퀀스 3개
다음 자동값 > 최대 ID
schema·table·sequence owner = 복원 역할
```

### 2단계: 권한 재적용 후

```text
03 역할 계획 검토
→ 04 PUBLIC·ACL·membership·RLS·유효 권한
→ 05 실제 허용·차단 동작
→ 백업 역할의 table/sequence 읽기 권한 확인
```

---

## 전역 객체와 역할 정리

`pg_dumpall --globals-only`에는 Role뿐 아니라 Tablespace 같은 전역 객체가 포함될 수 있습니다. 역할 암호 정보가 필요하지 않다면 `--no-role-passwords`를 검토합니다.

소유 역할은 객체를 소유한 상태에서 바로 삭제할 수 없습니다.

```text
REASSIGN OWNED
→ DROP OWNED 검토
→ 관련된 각 데이터베이스에서 의존성 확인
→ membership 회수
→ DROP ROLE
```

`DROP OWNED ... CASCADE`는 기본 정리 명령으로 사용하지 않습니다.

---

## reset 안전성

`reset_security_lab.sql`은 `BEGIN/COMMIT`으로 전체 초기화를 묶고 `CASCADE`를 사용하지 않습니다.

```text
정상 상태
→ known table 3개 삭제
→ security_lab 삭제
→ course_project 5행 유지

예상하지 못한 security_lab 객체 존재
→ DROP SCHEMA 실패
→ 앞의 table DROP도 전체 ROLLBACK
→ 예상 객체 자동 삭제 안 함
```

Role은 reset이 자동 삭제하지 않습니다.

---

## 안전 원칙

```text
- 생성·초기화·복원 검증 파일은 현재 DB를 실제로 검사합니다.
- 01은 Chapter 07·08 전체 기준을 검사합니다.
- Role과 권한 변경은 기본 주석 상태로 제공합니다.
- PostgreSQL 16 membership 옵션을 확인합니다.
- PUBLIC 권한과 직접 GRANT를 구분합니다.
- 실제 비밀번호·접속 URL·백업·password file을 저장소에 기록하지 않습니다.
- 백업 파일 목록·해시만으로 복구 가능하다고 판단하지 않습니다.
- RLS 전체 백업과 visible-row dump를 구분합니다.
- custom archive owner·ACL 메타데이터와 restore 적용 옵션을 구분합니다.
- 원본 DB가 아닌 별도 DB에서 원자적으로 복원합니다.
- 구조·데이터 검증과 권한 재적용 검증을 분리합니다.
- reset은 CASCADE 없이 예상 범위만 삭제합니다.
- 복구 결과와 RPO·RTO를 Runbook에 기록합니다.
```
