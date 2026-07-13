# Chapter 11 실습 코드

## 데이터베이스 보안과 백업 기초

이 폴더는 Chapter 11에서 사용하는 보안·권한·백업 점검 SQL을 관리합니다.

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `security_backup_check.sql` | `security_` 실습 테이블 생성, 권한 구조 예시, 유효 권한 확인, SQL Injection 방어 메모, 백업·복구 검증 SQL |

존재하지 않는 다른 SQL 파일명은 사용하지 않습니다.

## 실행 전 주의

`security_backup_check.sql`은 `public.security_students`, `public.security_courses`, `public.security_enrollments`를 삭제하고 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하세요.

역할 생성, GRANT, REVOKE, Default Privileges, pg_dump, pg_restore 명령은 대부분 주석으로 제공됩니다. 실제 실행은 관리자 권한이 있는 테스트 환경에서만 수행합니다.

## 핵심 기준

- 실제 비밀번호와 접속 URL을 저장소에 기록하지 않습니다.
- 로그인 역할과 권한 역할을 구분합니다.
- PostgreSQL의 FK 자식 컬럼처럼 권한도 범위별로 따로 봅니다.
- INSERT에 SERIAL이 있으면 시퀀스 권한을 확인합니다.
- REVOKE 후에도 역할 멤버십이나 PUBLIC을 통한 유효 권한이 남을 수 있습니다.
- SQL Injection 방어는 파라미터 바인딩, 허용 목록, 최소 권한을 함께 봅니다.
- `pg_dump`는 데이터베이스 단위 논리 백업이며 역할 같은 전역 객체는 별도 관리가 필요할 수 있습니다.
- 백업 파일은 자동 암호화된다고 가정하지 않습니다.
- 복구는 별도 DB에서 검증하고 오류 중단 옵션을 사용합니다.

## 예상 데이터

| 테이블 | 예상 행 수 |
| --- | ---: |
| security_students | 3 |
| security_courses | 3 |
| security_enrollments | 3 |
| JOIN 결과 | 3 |

## 터미널 명령 예시

```bash
pg_dump -U postgres -d ai_database_book -f ai_database_book_backup.sql
pg_dump -U postgres -d ai_database_book -Fc -f ai_database_book.backup
pg_dumpall --globals-only -U postgres -f globals.sql
createdb -U postgres ai_database_book_restore
psql -U postgres -d ai_database_book_restore -v ON_ERROR_STOP=1 -f ai_database_book_backup.sql
pg_restore -U postgres -d ai_database_book_restore --exit-on-error ai_database_book.backup
```

위 명령은 구조 설명용입니다. 실제 백업 파일은 공개 저장소에 커밋하지 않습니다.
