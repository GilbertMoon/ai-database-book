# Chapter 11. 데이터베이스 보안과 백업 기초

---

## 이 장에서 살펴볼 내용

Chapter 10에서는 인덱스와 실행 계획으로 조회 성능을 점검했습니다. 빠른 조회만큼 중요한 것은 데이터베이스를 안전하게 보호하고, 장애나 실수 발생 시 복구할 수 있도록 준비하는 일입니다.

이번 장에서는 PostgreSQL을 기준으로 계정, 역할, 권한, SQL Injection 방어, 백업과 복구 검증의 기본 흐름을 배웁니다. 실제 운영 환경에서 실행할 명령을 그대로 따라 하는 장이 아니라, 어떤 권한을 왜 부여하고 어떤 복구 절차를 어떻게 검증해야 하는지 판단하는 장입니다.

이 장에서 다루는 내용은 다음과 같습니다.

- 보호해야 할 데이터와 위협 파악
- 인증과 권한 부여의 차이
- PostgreSQL Role, LOGIN 역할, NOLOGIN 권한 역할
- 최소 권한 원칙
- GRANT, REVOKE와 유효 권한 확인
- 개발·운영 환경과 계정 분리
- 비밀번호와 접속 정보 보호
- SQL Injection과 파라미터 바인딩
- 개인정보, 로그, 백업 파일 보호
- 논리 백업과 복구 검증
- RPO와 RTO
- AI가 만든 보안·백업 명령 검토

---

## 1. 보안 통제와 복구 준비

보안은 하나의 기능이 아니라 여러 통제 장치의 조합입니다. 접속 계정만 만들었다고 안전해지는 것도 아니고, 백업 파일만 있다고 복구 가능한 것도 아닙니다.

![보안 통제와 복구 준비](../../images/chapter11/ch11_01_security_backup_overview.svg)

그림 11-1 보안 통제와 복구 준비

| 영역 | 핵심 질문 | 예시 |
| --- | --- | --- |
| 인증 | 누구인가? | 계정, 비밀번호, 인증서 |
| 권한 부여 | 무엇을 할 수 있는가? | SELECT, INSERT, UPDATE |
| 감사·기록 | 누가 무엇을 했는가? | 접속 로그, 관리자 작업 기록 |
| 복구 | 문제가 생기면 되돌릴 수 있는가? | 백업과 복구 테스트 |

인증에 성공했다고 모든 데이터에 접근할 수 있는 것은 아닙니다. 인증 이후에도 역할과 객체 권한을 확인해야 합니다.

---

## 2. Chapter 11 실습 테이블과 SQL 파일

실습 파일은 다음 하나입니다.

```text
code/chapter11/security_backup_check.sql
```

Chapter 11은 이전 장의 테이블과 충돌하지 않도록 `security_` 접두사가 붙은 별도 실습 테이블을 사용합니다.

```text
public.security_students
public.security_courses
public.security_enrollments
```

본문에서 일반 개념을 설명할 때는 학생, 강의, 수강신청 같은 용어를 쓰지만, 실행 가능한 SQL 예시는 `security_` 테이블명을 사용합니다.

> **실습 환경 확인**
>
> `security_backup_check.sql`은 `security_` 실습 테이블을 삭제하고 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하고, 먼저 현재 사용자와 데이터베이스를 확인합니다. 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.

---

## 3. PostgreSQL 역할과 계정 구조

PostgreSQL에서는 사용자와 그룹을 모두 Role로 관리합니다. `LOGIN` 속성이 있는 Role은 일반적으로 계정처럼 접속에 사용하고, `NOLOGIN` Role은 권한 묶음이나 그룹 역할로 사용할 수 있습니다.

![PostgreSQL 역할과 객체 권한 구조](../../images/chapter11/ch11_02_account_permission_model.svg)

그림 11-2 PostgreSQL 역할과 객체 권한 구조

| 구분 | 예시 | 설명 |
| --- | --- | --- |
| 로그인 역할 | `readonly_user` | 실제 접속 계정으로 사용 가능 |
| 로그인 역할 | `app_enrollment_user` | 애플리케이션 접속 계정 예시 |
| 권한 역할 | `role_report_reader` | 읽기 권한 묶음 |
| 권한 역할 | `role_enrollment_app` | 수강신청 서비스 권한 묶음 |

권한 역할을 만든 뒤 로그인 역할에 멤버십을 부여할 수 있습니다.

```sql
-- CREATE ROLE role_report_reader NOLOGIN;
-- CREATE ROLE readonly_user LOGIN;
-- GRANT role_report_reader TO readonly_user;
```

실제 비밀번호 설정은 조직의 비밀 정보 관리 절차를 통해 별도로 수행합니다. 예제 SQL 파일이나 저장소에 실제 비밀번호를 기록하지 않습니다.

---

## 4. 권한 범위 계층

PostgreSQL 권한은 여러 범위로 나뉩니다.

| 범위 | 예시 권한 | 의미 |
| --- | --- | --- |
| 데이터베이스 | CONNECT | 해당 DB에 접속 |
| 스키마 | USAGE | 스키마 안 객체 이름 사용 |
| 테이블 | SELECT, INSERT, UPDATE, DELETE | 테이블 데이터 작업 |
| 시퀀스 | USAGE, SELECT | SERIAL 번호 생성·확인 |
| 역할 멤버십 | GRANT role TO user | 권한 역할 상속 |

`CONNECT`만 있어도 테이블을 읽을 수 있는 것은 아닙니다. `USAGE`만 있어도 `SELECT`가 가능한 것은 아닙니다. `SERIAL` 컬럼에 INSERT하려면 테이블 INSERT 권한뿐 아니라 관련 시퀀스 권한도 필요할 수 있습니다.

---

## 5. 최소 권한 원칙

최소 권한은 필요한 작업에 필요한 권한만 부여하는 원칙입니다.

![최소 권한 설계 절차](../../images/chapter11/ch11_03_least_privilege_principle.svg)

그림 11-3 최소 권한 설계 절차

읽기 전용 보고 계정에는 SELECT만 부여합니다.

```sql
-- GRANT CONNECT ON DATABASE ai_database_book TO role_report_reader;
-- GRANT USAGE ON SCHEMA public TO role_report_reader;
-- GRANT SELECT ON TABLE
--     public.security_students,
--     public.security_courses,
--     public.security_enrollments
-- TO role_report_reader;
```

수강신청 애플리케이션 역할은 필요한 테이블과 작업만 허용합니다.

```sql
-- GRANT SELECT ON TABLE
--     public.security_students,
--     public.security_courses
-- TO role_enrollment_app;
--
-- GRANT SELECT, INSERT, UPDATE
-- ON TABLE public.security_enrollments
-- TO role_enrollment_app;
--
-- GRANT USAGE, SELECT
-- ON SEQUENCE public.security_enrollments_id_seq
-- TO role_enrollment_app;
```

기본 예시에서는 DELETE, CREATE DATABASE, CREATE ROLE, SUPERUSER, 불필요한 전체 테이블 쓰기 권한을 부여하지 않습니다.

---

## 6. GRANT, REVOKE와 유효 권한 확인

`GRANT`는 특정 경로로 권한을 부여하고, `REVOKE`는 특정 경로로 부여된 권한을 회수합니다. 하지만 REVOKE 한 번으로 사용자의 모든 유효 권한이 사라진다고 단정하면 안 됩니다.

![GRANT·REVOKE와 유효 권한 확인](../../images/chapter11/ch11_04_grant_revoke_flow.svg)

그림 11-4 GRANT·REVOKE와 유효 권한 확인

같은 권한이 다른 역할 멤버십이나 PUBLIC을 통해 남아 있다면 사용자는 여전히 접근할 수 있습니다. 따라서 권한 변경 뒤에는 유효 권한을 다시 확인해야 합니다.

```sql
SELECT
    has_database_privilege('readonly_user', 'ai_database_book', 'CONNECT') AS can_connect,
    has_schema_privilege('readonly_user', 'public', 'USAGE') AS can_use_schema,
    has_table_privilege('readonly_user', 'public.security_courses', 'SELECT') AS can_select_courses;
```

역할 멤버십은 다음처럼 확인할 수 있습니다.

```sql
SELECT pg_has_role('readonly_user', 'role_report_reader', 'MEMBER');
```

`information_schema.role_table_grants`는 명시적으로 부여된 테이블 권한을 살펴볼 때 유용하고, `has_table_privilege`는 실제 유효 권한을 확인할 때 유용합니다.

---

## 7. 현재 객체와 미래 객체 권한

현재 존재하는 테이블에 `GRANT SELECT`를 실행해도 이후 새로 만들어지는 테이블에 자동으로 같은 권한이 적용되지는 않습니다. 미래 객체까지 고려하려면 Default Privileges를 별도로 검토해야 합니다.

```sql
-- ALTER DEFAULT PRIVILEGES
-- FOR ROLE <object_owner_role>
-- IN SCHEMA public
-- GRANT SELECT ON TABLES
-- TO role_report_reader;
```

Default Privileges는 앞으로 특정 소유자가 만들 객체에 적용됩니다. 이미 존재하는 객체 권한을 바꾸지 않는다는 점을 분명히 구분해야 합니다.

---

## 8. 개발·운영 환경과 계정 분리

개발 환경과 운영 환경은 계정, 권한, 데이터, 백업 파일을 분리해야 합니다.

![개발·운영 환경과 계정 분리](../../images/chapter11/ch11_05_dev_prod_account_separation.svg)

그림 11-5 개발·운영 환경과 계정 분리

개발 DB에서 사용하는 계정과 운영 DB 계정이 같으면 실수로 운영 데이터에 영향을 줄 수 있습니다. 또한 백업 파일, 로그, `.env` 파일도 환경별로 분리해야 합니다.

실제 접속 정보는 저장소에 커밋하지 않습니다. `.env.example`은 필요한 변수 이름만 보여 주고 실제 값은 비워 둡니다.

```text
DATABASE_URL=
DB_USER=
DB_PASSWORD=
```

비밀번호가 노출되면 파일을 삭제하는 것보다 먼저 자격 증명을 회전해야 합니다. 이미 커밋된 비밀 정보는 기록에 남아 있을 수 있기 때문입니다.

---

## 9. SQL Injection과 안전한 입력 처리

SQL Injection은 사용자 입력값이 SQL 문장의 구조에 영향을 주면서 의도하지 않은 조회나 변경이 발생할 수 있는 취약점입니다.

![문자열 결합과 파라미터 바인딩](../../images/chapter11/ch11_06_sql_injection_safe_query.svg)

그림 11-6 문자열 결합과 파라미터 바인딩

위험한 방향은 사용자 입력을 SQL 문자열에 직접 결합하는 방식입니다.

```text
위험: "SELECT * FROM users WHERE email = '" + user_input + "'"
```

더 안전한 방향은 SQL 구조와 입력값을 분리하는 파라미터 바인딩입니다.

```text
권장: SELECT * FROM users WHERE email = $1
값: user_input
```

입력값 검증만으로 SQL Injection 방어가 끝나는 것은 아닙니다. 파라미터 바인딩, 최소 권한 DB 계정, 동적 테이블명·컬럼명의 허용 목록 검증을 함께 사용해야 합니다.

동적으로 테이블명이나 컬럼명을 선택해야 하는 경우에는 사용자 입력을 그대로 식별자로 쓰지 말고 허용 목록에서만 선택하도록 제한합니다.

---

## 10. 개인정보, 로그, 백업 파일 보호

백업 파일은 원본 데이터와 같은 수준으로 보호해야 합니다. 백업에는 개인정보, 이메일, 결제 금액, 내부 업무 데이터가 그대로 포함될 수 있습니다.

- 백업 파일을 공개 저장소에 커밋하지 않습니다.
- 백업 파일은 자동으로 암호화된다고 가정하지 않습니다.
- 전송, 저장, 접근 권한을 별도로 관리합니다.
- 로그에는 비밀번호, 토큰, 전체 접속 URL이 남지 않도록 합니다.
- 노출이 확인되면 삭제보다 자격 증명 회전을 우선합니다.

---

## 11. 백업과 복제는 다르다

백업은 특정 시점의 데이터를 복구하기 위해 보관하는 사본입니다. 복제는 서비스 가용성이나 읽기 확장을 위해 다른 서버에 데이터를 지속적으로 반영하는 구조입니다.

| 구분 | 목적 | 주의 |
| --- | --- | --- |
| 백업 | 실수·장애 후 특정 시점 복구 | 복구 테스트가 필요 |
| 복제 | 가용성·읽기 분산 | 백업을 대체하지 않음 |

복제가 있어도 잘못 삭제된 데이터가 복제본에도 반영될 수 있습니다. 그래서 복구 가능한 백업은 별도로 필요합니다.

---

## 12. pg_dump와 역할 백업

`pg_dump`는 하나의 데이터베이스를 논리적으로 백업하는 도구입니다. 역할과 같은 클러스터 전역 객체는 별도로 관리해야 할 수 있습니다.

```bash
pg_dump -U postgres -d ai_database_book -f ai_database_book_backup.sql
```

사용자 정의 형식 백업은 `pg_restore`로 복구할 수 있습니다.

```bash
pg_dump -U postgres -d ai_database_book -Fc -f ai_database_book.backup
```

역할 같은 전역 객체는 운영 정책에 따라 별도 관리가 필요합니다.

```bash
pg_dumpall --globals-only -U postgres -f globals.sql
```

이 명령들은 DBeaver SQL Editor가 아니라 터미널에서 실행합니다. 예제 파일명은 구조 설명용이며, 실제 백업 파일은 공개 저장소에 커밋하지 않습니다.

---

## 13. 별도 DB에서 복구 검증

백업 파일이 존재한다고 복구가 가능한 것은 아닙니다. 복구는 원본 운영 DB가 아니라 별도 검증 DB에서 확인해야 합니다.

![백업 생성에서 복구 검증까지](../../images/chapter11/ch11_07_backup_restore_flow.svg)

그림 11-7 백업 생성에서 복구 검증까지

SQL 텍스트 백업을 복구할 때는 오류 발생 시 즉시 중단하도록 옵션을 사용합니다.

```bash
createdb -U postgres ai_database_book_restore
psql -U postgres -d ai_database_book_restore -v ON_ERROR_STOP=1 -f ai_database_book_backup.sql
```

사용자 정의 형식 백업은 다음처럼 복구할 수 있습니다.

```bash
createdb -U postgres ai_database_book_restore
pg_restore -U postgres -d ai_database_book_restore --exit-on-error ai_database_book.backup
```

복구 뒤에는 구조, 데이터, 제약조건, 권한, 시퀀스를 확인합니다.

```sql
SELECT COUNT(*) FROM public.security_students;
SELECT COUNT(*) FROM public.security_courses;
SELECT COUNT(*) FROM public.security_enrollments;
```

예상 기준은 다음과 같습니다.

| 검증 대상 | 예상 결과 |
| --- | ---: |
| `security_students` | 3 |
| `security_courses` | 3 |
| `security_enrollments` | 3 |
| JOIN 결과 | 3 |

---

## 14. RPO와 RTO

RPO는 얼마나 많은 데이터 손실을 감수할 수 있는지에 대한 기준입니다. RTO는 장애 후 얼마나 빨리 복구해야 하는지에 대한 기준입니다.

| 기준 | 질문 | 예시 |
| --- | --- | --- |
| RPO | 어느 시점까지의 데이터가 필요할까? | 최대 1시간 손실 허용 |
| RTO | 몇 분 또는 몇 시간 안에 복구해야 할까? | 2시간 안에 서비스 재개 |

RPO와 RTO는 기술 결정이기도 하지만 비용과 서비스 특성의 결정이기도 합니다.

---

## 15. AI 보안·백업 명령 검토

AI는 GRANT, REVOKE, pg_dump, pg_restore 명령 초안을 빠르게 만들 수 있습니다. 하지만 AI가 만든 명령을 운영 환경에 바로 적용하면 위험합니다.

![AI 보안·백업 명령 검토 흐름](../../images/chapter11/ch11_08_ai_security_review_flow.svg)

그림 11-8 AI 보안·백업 명령 검토 흐름

검토 기준은 다음과 같습니다.

| 검토 항목 | 확인 질문 |
| --- | --- |
| 대상 환경 | 개발, 테스트, 운영 중 어디인가? |
| 대상 객체 | DB, 스키마, 테이블, 시퀀스가 정확한가? |
| 권한 범위 | 필요한 권한보다 넓지 않은가? |
| 유효 권한 | 역할 멤버십과 PUBLIC 권한까지 확인했는가? |
| 비밀 정보 | 실제 비밀번호나 접속 URL이 포함되지 않았는가? |
| 백업 파일 | 공개 저장소에 남지 않도록 관리되는가? |
| 복구 검증 | 별도 DB에서 검증했는가? |
| 실패 처리 | 오류 발생 시 중단하는 옵션이 있는가? |

AI 제안은 초안입니다. 최종 적용 전에는 테스트 환경에서 실행하고 결과를 확인해야 합니다.

---

## 16. 핵심 정리

- 인증은 누구인지 확인하는 것이고, 권한 부여는 무엇을 할 수 있는지 정하는 것입니다.
- PostgreSQL의 사용자는 LOGIN 가능한 Role입니다.
- 권한 역할은 NOLOGIN Role로 묶어 관리할 수 있습니다.
- 최소 권한 원칙은 필요한 범위만 부여하는 것입니다.
- REVOKE 뒤에도 다른 경로의 유효 권한이 남을 수 있습니다.
- SERIAL INSERT에는 테이블 INSERT와 시퀀스 권한이 함께 필요할 수 있습니다.
- 파라미터 바인딩은 SQL 구조와 값을 분리합니다.
- 백업 파일은 원본 데이터와 같은 수준으로 보호해야 합니다.
- pg_dump는 DB 단위 논리 백업이며, 역할 같은 전역 객체는 별도 관리가 필요할 수 있습니다.
- 복구 가능성은 별도 DB에서 직접 검증해야 합니다.
- AI가 만든 보안·백업 명령은 테스트 환경에서 검증한 뒤 적용합니다.

---

## 17. 다음 장에서는

Chapter 12에서는 지금까지 배운 SQL, 설계, 성능, 보안 관점을 종합해 데이터베이스 프로젝트를 점검하고 정리하는 흐름으로 이어갑니다.
