# Chapter 11 실습 코드

## 데이터베이스를 안전하게 지키고 복구하는 방법

이 폴더는 기존 프로젝트 데이터를 변경하지 않고 `security_lab`에서 최소 권한을 설계하고, 별도 데이터베이스에서 백업·복원 가능성을 검증하는 파일을 관리합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: Chapter 11 실습 대상
```

Role은 클러스터 전역 객체이므로 자동으로 생성·삭제하지 않습니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_security_lab_schema.sql` | 전용 스키마와 IDENTITY 테이블 생성 |
| `02_security_lab_seed.sql` | 명시적 ID 정상 샘플 3/3/3행 입력 |
| `03_role_permission_plan.sql` | 역할·GRANT·REVOKE·Default Privileges 계획 |
| `04_permission_checks.sql` | 역할·멤버십·객체·컬럼·시퀀스 유효 권한 확인 |
| `05_restore_validation.sql` | 별도 복원 DB의 구조·데이터·제약조건 검증 |
| `BACKUP_RESTORE_RUNBOOK.md` | 백업·복원 명령과 실행 결과 기록 |
| `reset_security_lab.sql` | security_lab만 초기화 |
| `security_backup_check.sql` | 기존 링크 호환용 안내·상태 확인 |

---

## 실행 순서

```text
01_security_lab_schema.sql
→ 02_security_lab_seed.sql
→ 03_role_permission_plan.sql에서 필요한 문장만 검토·선택 실행
→ 04_permission_checks.sql
→ 터미널에서 백업·별도 DB 복원
→ 복원 DB에서 05_restore_validation.sql
→ BACKUP_RESTORE_RUNBOOK.md 기록
```

역할 생성과 권한 변경은 관리자 권한이 있는 테스트 환경에서만 수행합니다.

---

## 기준 데이터

| 테이블 | 기대 행 수 |
| --- | ---: |
| `security_lab.students` | 3 |
| `security_lab.courses` | 3 |
| `security_lab.enrollments` | 3 |
| JOIN 결과 | 3 |

명시적 ID:

```text
students: 101, 102, 103
courses: 201, 202, 203
enrollments: 1001, 1002, 1003
```

---

## 역할 예시

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
```

실제 비밀번호는 SQL 파일이나 저장소에 기록하지 않습니다.

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
enrollments_id_seq USAGE·SELECT
DELETE·TRUNCATE·schema CREATE 불허
```

---

## 백업 예시

백업 파일은 저장소 밖의 보호된 디렉터리에 생성합니다.

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

아카이브 목록:

```bash
pg_restore --list <backup-dir>/security_lab.backup
```

---

## 별도 DB 복원

```bash
createdb -U <admin_user> ai_database_book_restore

pg_restore \
  -U <restore_user> \
  -d ai_database_book_restore \
  --exit-on-error \
  --no-owner \
  --no-privileges \
  <backup-dir>/security_lab.backup
```

복원 DB에서 다음 파일을 실행합니다.

```text
05_restore_validation.sql
```

---

## 복원 검증 기준

```text
students 3
courses 3
enrollments 3
JOIN 3
고아 FK 0
PK·FK·UNIQUE·CHECK 유지
IDENTITY 시퀀스 3개
```

`--no-owner --no-privileges`를 사용했다면 원본 owner와 ACL이 없는 것이 정상입니다. 역할·권한 계획을 별도로 적용한 뒤 `04_permission_checks.sql`을 실행합니다.

---

## 저장소 보호

루트 `.gitignore`는 다음 로컬 파일을 제외합니다.

```text
.env, .env.*
backups/
*.backup
*.dump
*.pgdump
*.sql.gz
*.sql.zst
```

`.env.example`에는 변수 이름만 있고 실제 값은 없습니다.

---

## 안전 원칙

```text
- 생성 파일에서 자동 DROP을 실행하지 않습니다.
- Role과 GRANT·REVOKE는 기본 주석 상태로 제공합니다.
- 실제 비밀번호·토큰·전체 접속 URL을 기록하지 않습니다.
- 백업 파일을 저장소에 커밋하지 않습니다.
- 원본 DB에 복원하지 않고 별도 DB에서 먼저 검증합니다.
- 복원 명령에 오류 중단 옵션을 사용합니다.
- 파일 목록·해시뿐 아니라 실제 복원 결과를 확인합니다.
- Role 정리는 다른 DB와 객체 의존성을 조사한 뒤 수행합니다.
```
