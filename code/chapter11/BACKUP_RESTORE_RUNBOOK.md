# Chapter 11 백업·복원 실행 기록

## 목적

`security_lab` 또는 `ai_database_book`의 논리 백업을 생성하고, 원본 DB가 아닌 별도 복원 DB에서 구조·데이터·제약조건과 권한을 검증합니다.

> 실제 비밀번호, 전체 접속 URL, 백업 파일과 복원 결과 데이터는 이 저장소에 기록하지 않습니다.

---

## 1. 기본 정보

| 항목 | 기록 |
| --- | --- |
| 실행 날짜 |  |
| 담당자 |  |
| PostgreSQL 서버 버전 |  |
| pg_dump 버전 |  |
| pg_restore 버전 |  |
| 원본 DB | ai_database_book |
| 복원 DB | ai_database_book_restore |
| 백업 범위 | security_lab / 전체 DB |
| 백업 형식 | custom / plain / directory |
| RPO |  |
| RTO |  |

---

## 2. 저장 위치와 보호 정책

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

백업 경로는 프로젝트 저장소 밖의 보호된 디렉터리를 사용합니다.

---

## 3. security_lab 사용자 정의 형식 백업

다음 명령에서 `<backup_user>`와 `<backup-dir>`은 실제 환경에 맞게 바꿉니다. 비밀번호를 명령줄에 직접 작성하지 않습니다.

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

실행 결과:

| 항목 | 기록 |
| --- | --- |
| 종료 코드 |  |
| 경고·오류 |  |
| 파일 크기 |  |
| 생성 시각 |  |
| 수행 시간 |  |

---

## 4. 전체 DB 백업 선택안

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

## 5. 전역 역할 백업 선택안

데이터베이스 덤프에는 클러스터 전역 역할이 포함되지 않습니다. 운영 정책에 따라 별도 파일을 생성할 수 있습니다.

```bash
pg_dumpall \
  --globals-only \
  -U <admin_user> \
  -f <secure-backup-dir>/globals.sql
```

주의:

```text
- 역할 파일은 더 엄격한 경로에서 보호한다.
- 같은 클러스터에서는 기존 역할과 충돌할 수 있다.
- 실제 비밀번호·역할 설정 노출 가능성을 검토한다.
- 테스트 클러스터에서 내용을 검토한 뒤 적용한다.
```

전역 역할 백업 여부와 이유:

```text
_______________________________________________________________
```

---

## 6. 아카이브 목록 확인

```bash
pg_restore --list <backup-dir>/security_lab.backup
```

| 확인 항목 | 결과 |
| --- | --- |
| security_lab 스키마 포함 |  |
| students 포함 |  |
| courses 포함 |  |
| enrollments 포함 |  |
| 제약조건 포함 |  |
| 시퀀스 포함 |  |
| 예상하지 않은 객체 |  |

---

## 7. SHA-256 기록

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

---

## 8. 별도 복원 DB 생성

기존 `ai_database_book_restore`가 있다면 보존 필요 여부를 먼저 확인합니다. 자동으로 삭제하지 않습니다.

```bash
createdb -U <admin_user> ai_database_book_restore
```

| 항목 | 기록 |
| --- | --- |
| 생성 성공 |  |
| 기존 DB 충돌 |  |
| 소유자 |  |
| 인코딩 |  |

---

## 9. 사용자 정의 형식 복원

```bash
pg_restore \
  -U <restore_user> \
  -d ai_database_book_restore \
  --exit-on-error \
  --no-owner \
  --no-privileges \
  <backup-dir>/security_lab.backup
```

| 항목 | 기록 |
| --- | --- |
| 시작 시각 |  |
| 완료 시각 |  |
| 종료 코드 |  |
| 경고·오류 |  |
| owner 제외 확인 |  |
| ACL 제외 확인 |  |

---

## 10. Plain SQL 복원 선택안

Plain SQL 백업을 사용하는 경우 오류 발생 시 즉시 중단합니다.

```bash
psql \
  -U <restore_user> \
  -d ai_database_book_restore \
  -v ON_ERROR_STOP=1 \
  -f <backup-dir>/security_lab.sql
```

---

## 11. 복원 검증 SQL 실행

```bash
psql \
  -U <restore_user> \
  -d ai_database_book_restore \
  -v ON_ERROR_STOP=1 \
  -f code/chapter11/05_restore_validation.sql
```

| 검증 항목 | 기대 | 실제 | 통과 |
| --- | ---: | ---: | --- |
| students | 3 |  |  |
| courses | 3 |  |  |
| enrollments | 3 |  |  |
| JOIN | 3 |  |  |
| 고아 student FK | 0 |  |  |
| 고아 course FK | 0 |  |  |
| PK·FK·UNIQUE·CHECK | 유지 |  |  |
| IDENTITY 시퀀스 | 3개 |  |  |

---

## 12. 역할·권한 재적용과 검증

`--no-owner --no-privileges`를 사용했다면 역할과 ACL은 별도로 적용합니다.

```text
1. 03_role_permission_plan.sql 검토
2. 필요한 역할·GRANT만 테스트 환경에서 실행
3. 04_permission_checks.sql 실행
4. 읽기·앱 계정의 허용·차단 결과 기록
```

| 역할 | SELECT | INSERT | status UPDATE | DELETE | schema CREATE |
| --- | --- | --- | --- | --- | --- |
| lab_readonly_user |  |  |  |  |  |
| lab_enrollment_user |  |  |  |  |  |

---

## 13. 오류와 해결 기록

| 단계 | 오류 | 원인 | 해결 | 재검증 |
| --- | --- | --- | --- | --- |
| 백업 |  |  |  |  |
| 목록 확인 |  |  |  |  |
| 복원 |  |  |  |  |
| 데이터 검증 |  |  |  |  |
| 권한 검증 |  |  |  |  |

---

## 14. RPO·RTO 결과

| 기준 | 목표 | 실제 | 충족 | 개선안 |
| --- | --- | --- | --- | --- |
| RPO |  |  |  |  |
| RTO |  |  |  |  |

---

## 15. 정리와 다음 시험

| 항목 | 기록 |
| --- | --- |
| 복원 DB 정리 승인 |  |
| 임시 파일 삭제 |  |
| 보존 백업 이동 |  |
| 접근 권한 재확인 |  |
| 다음 복원 시험 날짜 |  |
| 담당자 인수인계 |  |

최종 판정:

```text
백업 성공 / 복원 성공 / 검증 성공 / 권한 검증 성공
```
