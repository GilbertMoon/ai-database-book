# Chapter 11 백업·복원 실행 기록

## 목적

`security_lab` 또는 `ai_database_book`의 논리 백업을 생성하고, 원본 DB가 아닌 별도 복원 DB에서 구조·데이터·제약조건·소유권과 권한을 검증합니다.

> 실제 비밀번호, 전체 접속 URL, libpq password file, 백업 파일과 복원 결과 데이터는 이 저장소에 기록하지 않습니다.

---

## 1. 기본 정보와 버전 호환성

| 항목 | 기록 |
| --- | --- |
| 실행 날짜 |  |
| 담당자 |  |
| 원본 PostgreSQL 서버 버전 |  |
| 복원 PostgreSQL 서버 버전 |  |
| `pg_dump` 버전 |  |
| `pg_restore` 버전 |  |
| `psql` 버전 |  |
| 원본 DB | `ai_database_book` |
| 복원 DB | `ai_database_book_restore` |
| 백업 범위 | `security_lab` / 전체 DB |
| 백업 형식 | custom / plain / directory |
| RPO |  |
| RTO |  |

터미널에서 도구 버전을 확인합니다.

```bash
pg_dump --version
pg_restore --version
psql --version
```

원본 서버에서 확인합니다.

```sql
SHOW server_version;
```

판정 기준:

```text
- pg_dump 주요 버전이 원본 서버보다 오래되면 실행을 중단하고 호환 도구를 준비한다.
- 복원 서버가 원본 서버보다 오래된 주요 버전이면 호환성을 별도로 검토한다.
- 운영 복구에서는 확장 기능과 외부 모듈 버전도 함께 확인한다.
```

---

## 2. 저장 위치와 자격 증명 보호

| 항목 | 기록 |
| --- | --- |
| 백업 저장 위치 |  |
| 저장소 밖 경로인가 |  |
| 저장 암호화 |  |
| 전송 암호화 |  |
| 접근 가능 역할 |  |
| 보관 기간 |  |
| 삭제 절차 |  |
| 복원 임시 DB 삭제 시점 |  |
| password file 위치 |  |

백업 경로는 프로젝트 저장소 밖의 보호된 디렉터리를 사용합니다.

```text
- 비밀번호를 명령줄에 직접 입력하지 않는다.
- PGPASSWORD를 저장소 예제에 기록하지 않는다.
- 필요하면 저장소 밖의 libpq password file과 PGPASSFILE을 사용한다.
- password file의 OS 접근 권한을 제한한다.
```

---

## 3. 백업 계정의 최소 권한

`<backup_user>`가 특별히 모든 데이터를 우회해서 읽는다고 가정하지 않습니다.

| 권한·조건 | 필요 여부 | 확인 결과 |
| --- | --- | --- |
| DB `CONNECT` | 필요 |  |
| `security_lab` `USAGE` | 스키마 백업 시 필요 |  |
| 대상 테이블 `SELECT` | 필요 |  |
| 필요한 시퀀스 접근 | 범위에 따라 확인 |  |
| RLS 적용 여부 | 반드시 확인 |  |
| 백업 후 권한 회수·보존 | 정책 결정 |  |

실습 스키마만 백업할 때는 전체 데이터베이스 읽기 역할보다 객체별 최소 권한을 우선합니다. 운영 환경에서 RLS가 적용되었다면 백업 역할과 정책에 따라 덤프 결과가 달라질 수 있습니다.

---

## 4. 특정 스키마 백업의 외부 의존성 확인

`--schema=security_lab`은 선택한 스키마 내부 객체를 대상으로 하지만 외부 의존 객체를 자동으로 모두 포함한다고 가정하면 안 됩니다.

| 의존성 | 존재 여부 | 처리 계획 |
| --- | --- | --- |
| 다른 스키마를 참조하는 FK |  |  |
| 사용자 정의 타입 |  |  |
| 함수·트리거 |  |  |
| 확장 기능 |  |  |
| Large Object |  |  |
| 외부 테이블 |  |  |

현재 교재의 `security_lab`은 외부 스키마 FK·사용자 정의 타입·트리거 의존성이 없으므로 깨끗한 복원 DB에 단독 복원할 수 있도록 설계했습니다.

---

## 5. security_lab 사용자 정의 형식 백업

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

`--no-owner --no-privileges`는 테스트 복원 이동성을 높이지만 원본 owner와 ACL을 제외합니다. 복원 뒤 소유권과 권한 정책을 별도로 적용하고 검증합니다.

| 항목 | 기록 |
| --- | --- |
| 종료 코드 |  |
| 경고·오류 |  |
| 파일 크기 |  |
| 생성 시각 |  |
| 수행 시간 |  |

---

## 6. 전체 데이터베이스 백업 선택안

전체 데이터베이스 복구가 목적이라면 다음 형식을 검토합니다.

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  -f <backup-dir>/ai_database_book.backup
```

전체 DB를 선택한 이유:

```text
_______________________________________________________________
```

---

## 7. 전역 객체 백업 선택안

데이터베이스 덤프에는 Role과 Tablespace 같은 클러스터 전역 객체가 포함되지 않습니다.

역할 암호 정보를 제외하는 선택안:

```bash
pg_dumpall \
  --globals-only \
  --no-role-passwords \
  -U <admin_user> \
  -f <secure-backup-dir>/globals.sql
```

인증 정보까지 복구해야 한다면 `--no-role-passwords`를 사용하지 않을 수 있지만 파일 보호 수준을 더 높여야 합니다.

```text
- 같은 클러스터에서는 기존 역할·테이블스페이스와 충돌할 수 있다.
- 내용을 테스트 환경에서 검토한 뒤 적용한다.
- Role 파일은 일반 데이터 덤프보다 더 엄격하게 보호한다.
```

전역 객체 백업 여부와 이유:

```text
_______________________________________________________________
```

---

## 8. 아카이브 목록과 파일 해시

```bash
pg_restore --list <backup-dir>/security_lab.backup
```

| 확인 항목 | 결과 |
| --- | --- |
| `security_lab` 스키마 포함 |  |
| students 포함 |  |
| courses 포함 |  |
| enrollments 포함 |  |
| 제약조건 포함 |  |
| 부분 고유 인덱스 포함 |  |
| IDENTITY 시퀀스 포함 |  |
| 예상하지 않은 객체 |  |

Windows PowerShell:

```powershell
Get-FileHash <backup-dir>\security_lab.backup -Algorithm SHA256
```

Linux·macOS:

```bash
sha256sum <backup-dir>/security_lab.backup
```

| 항목 | 기록 |
| --- | --- |
| 해시 알고리즘 | SHA-256 |
| 해시 값 |  |
| 측정 시각 |  |
| 재전송 후 해시 일치 |  |

해시는 파일 변경 여부를 확인하는 근거이며 실제 복원 가능성의 증거는 아닙니다.

---

## 9. 별도 복원 DB 생성

기존 `ai_database_book_restore`가 있다면 보존 필요 여부를 먼저 확인합니다. 자동으로 삭제하지 않습니다.

복원 역할을 DB owner로 지정하고 `template0`에서 깨끗한 DB를 만듭니다.

```bash
createdb \
  -U <admin_user> \
  -O <restore_user> \
  -T template0 \
  ai_database_book_restore
```

| 항목 | 기록 |
| --- | --- |
| 생성 성공 |  |
| 기존 DB 충돌 |  |
| DB owner |  |
| 인코딩 |  |
| template | `template0` |

---

## 10. 사용자 정의 형식 원자적 복원

작은 `security_lab` 실습은 전체 복원을 하나의 트랜잭션으로 묶습니다.

```bash
pg_restore \
  -U <restore_user> \
  -d ai_database_book_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  <backup-dir>/security_lab.backup
```

`--single-transaction`은 오류 시 부분 복원 객체가 남는 위험을 줄입니다. 대규모 운영 복원에서는 긴 트랜잭션, 잠금과 자원 사용을 별도로 검토합니다.

| 항목 | 기록 |
| --- | --- |
| 시작 시각 |  |
| 완료 시각 |  |
| 종료 코드 |  |
| 경고·오류 |  |
| 부분 객체 잔존 여부 |  |
| owner 제외 확인 |  |
| ACL 제외 확인 |  |

---

## 11. Plain SQL 원자적 복원 선택안

```bash
psql \
  -X \
  -1 \
  -U <restore_user> \
  -d ai_database_book_restore \
  -v ON_ERROR_STOP=1 \
  -f <backup-dir>/security_lab.sql
```

```text
-X               → 사용자의 psqlrc 설정을 읽지 않음
-1               → 파일 전체를 하나의 트랜잭션으로 실행
ON_ERROR_STOP=1  → 첫 오류에서 중단
```

덤프 출처를 신뢰할 수 있는지도 확인합니다. 복원은 대상 서버에서 SQL과 객체 정의를 실행하는 작업입니다.

---

## 12. 복원 검증 1단계: 구조·데이터·소유권

```bash
psql \
  -X \
  -U <restore_user> \
  -d ai_database_book_restore \
  -v ON_ERROR_STOP=1 \
  -f code/chapter11/06_restore_validation.sql
```

`06_restore_validation.sql`은 원본 DB에서 실행하면 예외를 발생시킵니다.

| 검증 항목 | 기대 | 실제 | 통과 |
| --- | ---: | ---: | --- |
| students | 3 |  |  |
| courses | 3 |  |  |
| enrollments | 3 |  |  |
| JOIN | 3 |  |  |
| 고아 student FK | 0 |  |  |
| 고아 course FK | 0 |  |  |
| 활성 신청 중복 | 0 |  |  |
| PK·FK·UNIQUE·CHECK | 13개 유지 |  |  |
| 활성 신청 부분 고유 인덱스 | 존재 |  |  |
| IDENTITY 시퀀스 | 3개 |  |  |
| 다음 자동값 | 현재 최대 ID보다 큼 |  |  |
| schema·table·sequence owner | `<restore_user>` |  |  |

`--no-privileges`를 사용했더라도 복원 역할의 Default Privileges가 생성 시 적용될 수 있으므로 실제 ACL을 조회합니다.

---

## 13. 복원 검증 2단계: 역할·권한 재적용

```text
1. 03_role_permission_plan.sql 검토
2. 필요한 Role·GRANT만 복원 테스트 환경에서 적용
3. 04_permission_checks.sql 실행
4. 05_permission_behavior_tests.sql 실행
5. 허용·차단 결과 기록
```

| 역할 | SELECT | INSERT | status UPDATE | paid_amount UPDATE | DELETE | schema CREATE |
| --- | --- | --- | --- | --- | --- | --- |
| `lab_readonly_user` | 성공 | 실패 | 실패 | 실패 | 실패 | 실패 |
| `lab_enrollment_user` | 성공 | 성공 | 성공 | 실패 | 실패 | 실패 |

PUBLIC·직접 GRANT·역할 멤버십·소유권을 포함한 권한 경로를 함께 확인합니다.

---

## 14. 오류와 해결 기록

| 단계 | 오류 | 원인 | 해결 | 재검증 |
| --- | --- | --- | --- | --- |
| 버전 확인 |  |  |  |  |
| 백업 권한 |  |  |  |  |
| 스키마 의존성 |  |  |  |  |
| 백업 |  |  |  |  |
| 목록·해시 |  |  |  |  |
| 복원 |  |  |  |  |
| 구조·데이터 검증 |  |  |  |  |
| 권한 검증 |  |  |  |  |

---

## 15. RPO·RTO 결과

| 기준 | 목표 | 실제 | 충족 | 개선안 |
| --- | --- | --- | --- | --- |
| RPO |  |  |  |  |
| RTO |  |  |  |  |

RPO는 허용 가능한 데이터 손실 시점이고, RTO는 서비스 재개까지 허용되는 시간입니다. 백업 주기와 실제 복원 시간이 두 목표를 모두 충족해야 합니다.

---

## 16. 정리와 다음 시험

| 항목 | 기록 |
| --- | --- |
| 복원 DB 정리 승인 |  |
| 임시 파일 삭제 |  |
| 보존 백업 이동 |  |
| 접근 권한 재확인 |  |
| 백업 역할 권한 회수·유지 |  |
| 다음 복원 시험 날짜 |  |
| 담당자 인수인계 |  |

최종 판정:

```text
백업 성공 / 복원 성공 / 구조·데이터 검증 성공 / 권한 검증 성공
```
