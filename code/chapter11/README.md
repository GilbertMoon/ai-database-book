# Chapter 11 실습 코드

## 데이터베이스를 안전하게 지키고 복구하는 방법

이 폴더는 기존 프로젝트를 변경하지 않고 `security_lab`에서 최소 권한을 설계하고, 백업을 별도 데이터베이스에 복원해 구조·데이터·소유권과 권한을 검증하는 파일을 관리합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: Chapter 11 실습 대상
Role: 클러스터 전역 객체이므로 자동 생성·삭제하지 않음
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
| `01_security_lab_schema.sql` | DB·Chapter 07 상태를 검사하고 스키마·테이블·부분 고유 인덱스를 한 트랜잭션에서 생성 |
| `02_security_lab_seed.sql` | 명시적 ID 샘플 입력, IDENTITY 시작값 조정과 자동 검증 |
| `03_role_permission_plan.sql` | Role·GRANT·REVOKE·Default Privileges·소유권·정리 계획 |
| `04_permission_checks.sql` | 유효 권한, PUBLIC, DB·스키마 ACL, 멤버십과 시퀀스 권한 확인 |
| `05_permission_behavior_tests.sql` | 읽기·앱 계정의 허용·차단 동작을 ROLLBACK 기반으로 검증 |
| `05_restore_validation.sql` | 기존 링크 호환용 안내 |
| `06_restore_validation.sql` | 별도 복원 DB의 구조·데이터·제약조건·IDENTITY·소유권 자동 검증 |
| `BACKUP_RESTORE_RUNBOOK.md` | 버전·권한·의존성·백업·원자적 복원·2단계 검증 실행 기록 |
| `reset_security_lab.sql` | DB 보호 구문 안에서 `security_lab`만 초기화 |
| `security_backup_check.sql` | 읽기 전용 안내·상태 확인 진입점 |

---

## 실행 순서

```text
01_security_lab_schema.sql
→ 02_security_lab_seed.sql
→ 03_role_permission_plan.sql에서 필요한 문장만 선택 실행
→ 04_permission_checks.sql
→ 05_permission_behavior_tests.sql 선택 실습
→ 터미널에서 백업·별도 DB 복원
→ 복원 DB에서 06_restore_validation.sql
→ BACKUP_RESTORE_RUNBOOK.md 기록
```

역할 생성과 권한 변경은 관리자 권한이 있는 테스트 환경에서만 수행합니다.

---

## 기준 데이터와 무결성

| 테이블 | 기대 행 수 | 명시적 ID | IDENTITY 다음 값 |
| --- | ---: | --- | ---: |
| `security_lab.students` | 3 | 101~103 | 104 이상 |
| `security_lab.courses` | 3 | 201~203 | 204 이상 |
| `security_lab.enrollments` | 3 | 1001~1003 | 1004 이상 |
| JOIN 결과 | 3 | - | - |

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
```

실제 비밀번호나 password file은 SQL과 저장소에 기록하지 않습니다.

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
paid_amount UPDATE·DELETE·TRUNCATE·schema CREATE 불허
```

IDENTITY의 `nextval()` 사용에는 시퀀스 `USAGE`면 충분합니다. 시퀀스 상태를 직접 조회할 업무 요구가 없다면 `SELECT`는 부여하지 않습니다.

---

## PUBLIC과 유효 권한

```text
has_*_privilege
→ 로그인 역할이 최종적으로 사용할 수 있는 유효 권한

pg_database.datacl·pg_namespace.nspacl·객체 ACL
→ 직접 GRANT와 PUBLIC 같은 권한 경로

pg_has_role(..., 'MEMBER')
→ 멤버십 존재

pg_has_role(..., 'USAGE')
→ 권한을 즉시 사용할 수 있는지 확인
```

PUBLIC 테이블 권한은 `information_schema.table_privileges`, 컬럼 권한은 `column_privileges`에서 확인합니다. `role_table_grants`는 PUBLIC 경로를 제외할 수 있습니다.

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
- paid_amount UPDATE·DELETE·schema CREATE 실패
```

허용 테스트는 마지막에 `ROLLBACK`합니다. 실패 문장은 기본 주석 상태이며 한 문장씩 선택합니다. IDENTITY 번호는 실패·ROLLBACK 후에도 공백이 생길 수 있으므로 연속 번호를 정합성 기준으로 사용하지 않습니다.

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

---

## 백업 전 확인

```text
- pg_dump·pg_restore·psql 버전
- 원본·복원 서버 버전
- 백업 계정의 CONNECT·USAGE·SELECT
- RLS 적용 여부
- security_lab의 외부 FK·타입·함수·트리거·확장 의존성
- 출력 경로와 암호화·보관 정책
```

현재 `security_lab`은 외부 스키마 의존성 없이 단독 복원할 수 있도록 구성했습니다.

---

## 백업과 원자적 복원

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

Plain SQL은 `psql -X -1 -v ON_ERROR_STOP=1`로 실행합니다. 작은 실습에서는 오류 시 부분 복원 객체가 남지 않도록 전체를 하나의 트랜잭션으로 처리합니다.

---

## 복원 검증 2단계

### 1단계: `06_restore_validation.sql`

```text
DB = ai_database_book_restore
students·courses·enrollments = 3/3/3
JOIN = 3
고아 FK·활성 신청 중복 = 0
13개 명시 제약조건 유지
부분 고유 인덱스 유지
IDENTITY 시퀀스 3개
다음 자동값 > 최대 ID
schema·table·sequence owner = 복원 역할
```

### 2단계: 권한 재적용 후

```text
03 역할 계획 검토
→ 04 유효 권한
→ 05 실제 허용·차단 동작
→ PUBLIC·멤버십·소유권 경로 확인
```

---

## 전역 객체와 역할 정리

`pg_dumpall --globals-only`에는 Role뿐 아니라 Tablespace 같은 전역 객체가 포함될 수 있습니다. 역할 암호 정보가 필요하지 않다면 `--no-role-passwords`를 검토합니다.

소유 역할은 객체를 소유한 상태에서 바로 삭제할 수 없습니다.

```text
REASSIGN OWNED
→ DROP OWNED 검토
→ 관련된 각 데이터베이스에서 의존성 확인
→ DROP ROLE
```

`DROP OWNED ... CASCADE`는 기본 정리 명령으로 사용하지 않습니다.

---

## 안전 원칙

```text
- 생성·초기화·복원 검증 파일은 현재 DB를 실제로 검사합니다.
- Role과 권한 변경은 기본 주석 상태로 제공합니다.
- PUBLIC 권한과 직접 GRANT를 구분합니다.
- 실제 비밀번호·접속 URL·백업·password file을 저장소에 기록하지 않습니다.
- 백업 파일 목록·해시만으로 복구 가능하다고 판단하지 않습니다.
- 원본 DB가 아닌 별도 DB에서 원자적으로 복원합니다.
- 구조·데이터 검증과 권한 재적용 검증을 분리합니다.
- 복구 결과와 RPO·RTO를 Runbook에 기록합니다.
```
