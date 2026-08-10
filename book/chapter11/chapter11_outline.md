# Chapter 11 구성안

## 제목

데이터베이스를 안전하게 지키고 복구하는 방법

## 권장 분량

28~32페이지

## 기준 환경

```text
PostgreSQL 16
원본 DB: ai_database_book
복원 검증 DB: ai_database_book_restore
```

## 이 장의 역할

Chapter 11은 접근 통제, 비밀 정보 보호, SQL Injection 방어, 논리 백업과 별도 DB 복원 검증을 하나의 운영 흐름으로 연결한다.

```text
보호 대상·위험
→ 로그인 역할·권한 역할·소유 역할 분리
→ PostgreSQL 16 membership 옵션 확인
→ 최소 권한 작업 행렬
→ GRANT·REVOKE
→ PUBLIC·ACL·멤버십·유효 권한 확인
→ 실제 허용·차단 동작 검증
→ 비밀·입력 보호
→ 백업 로그인 역할·권한 역할 분리
→ RLS·외부 의존성·버전 확인
→ custom archive 생성
→ 별도 DB 원자적 복원
→ 구조·데이터·소유권·권한 2단계 검증
→ RPO·RTO·실행 기록
```

## Chapter 07·08 시작 기준

```text
course_project.students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
course_project.enrollments.recorded_amount = NUMERIC(12,0)
전체 recorded_amount = 590000
활성 신청 = 3 / 340000
취소 제외 이력 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
uq_course_enrollments_active
Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개 유지
현재 역할의 ai_database_book CREATE 권한 확인 존재
```

`transaction_lab`·`performance_lab`은 존재 여부를 Chapter 11의 필수 전제로 삼지 않으며, 존재하면 변경하지 않는다.

## 핵심 질문

```text
누가 접속하고 어떤 역할의 권한을 사용하는가?
로그인 역할과 NOLOGIN 권한 역할을 분리했는가?
PostgreSQL 16 membership의 INHERIT·SET 경로는 의도한 상태인가?
앱 계정이 실제로 필요한 작업은 무엇인가?
객체 소유권과 실행 권한이 분리되어 있는가?
유효 권한은 직접 GRANT·멤버십·PUBLIC·소유권 중 어디서 왔는가?
비밀번호·password file·접속 URL·백업 파일이 저장소 밖에 있는가?
백업 로그인 역할과 백업 권한 역할을 분리했는가?
백업 계정이 테이블과 IDENTITY 시퀀스 상태를 읽을 수 있는가?
RLS 전체 백업과 역할 가시 행 백업을 구분했는가?
특정 스키마의 외부 의존성을 확인했는가?
도구·서버 버전이 호환되는가?
custom archive의 owner·ACL 메타데이터와 복원 옵션을 구분했는가?
복원 DB owner와 restore user가 일치하는가?
별도 DB에 원자적으로 복원하고 자동 검증했는가?
현재 백업 주기와 복원 시간이 RPO·RTO를 충족하는가?
```

## 실습 구조

```text
security_lab.students
security_lab.courses
security_lab.enrollments
```

### security_lab 기준 데이터

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
| students | 101~103 | 104 이상 |
| courses | 201~203 | 204 이상 |
| enrollments | 1001~1003 | 1004 이상 |

권한 동작 테스트에서 `nextval()`이 실행되면 `ROLLBACK` 후에도 자동 번호 공백은 허용한다.

## 금액 의미

```text
recorded_amount
→ 신청 시점에 신청 행에 기록한 금액
→ 결제 승인액·환불 반영 순매출·회계 매출이 아님
```

타입은 `NUMERIC(12,0)`으로 통일한다.

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

PostgreSQL 16 membership은 다음 의도로 고정한다.

```text
report_reader  → readonly_user     : INHERIT TRUE / SET TRUE
app role       → enrollment_user   : INHERIT TRUE / SET TRUE
backup_reader  → backup_user       : INHERIT TRUE / SET TRUE
ADMIN은 기본적으로 필요 없음
```

검증에는 `pg_has_role(..., 'MEMBER')`, `pg_has_role(..., 'USAGE')`, `pg_auth_members.inherit_option`, `set_option`, `admin_option`을 함께 사용한다.

## 핵심 무결성 규칙

```text
학생 이름·이메일 공백 금지
정확히 같은 이메일 문자열 중복 금지
존재하는 학생·강의만 참조
recorded_amount 0 이상
상태 허용값 제한
신청·수강중 활성 신청은 학생·강의당 한 건
완료·취소 이력은 여러 건 허용
```

## 핵심 개념

- 인증
- 권한 부여
- 객체 소유권
- 감사
- PostgreSQL Role
- `LOGIN`, `NOLOGIN`
- PostgreSQL 16 role membership
- `MEMBER`, `USAGE`, `INHERIT`, `SET`, `ADMIN`
- 최소 권한
- `CONNECT`, schema `USAGE`, `SELECT`, `INSERT`, column `UPDATE`
- 앱 시퀀스 `USAGE`
- 백업 시퀀스 `SELECT`
- `PUBLIC`
- 유효 권한과 ACL
- Default Privileges
- `REASSIGN OWNED`, `DROP OWNED`
- 환경 분리
- password file, `PGPASSFILE`
- SQL Injection
- 파라미터 바인딩
- 식별자 허용 목록
- 논리 백업
- 백업 계정과 RLS
- `--enable-row-security`
- 스키마 외부 의존성
- `pg_dump`, `pg_restore`, `psql`
- custom archive owner·ACL 메타데이터
- 도구·서버 버전
- `template0`
- `pg_restore --no-owner --no-privileges`
- `--single-transaction`
- `psql -X -1 -v ON_ERROR_STOP=1`
- 복원 검증
- RPO·RTO
- 복구 Runbook
- AI 명령 검토

## 본문 구성

1. 보안 통제와 복구 준비
2. 기존 프로젝트 보호와 실습 구조
3. 보호 자산과 위험
4. 인증·권한·소유권
5. 로그인·권한·소유 역할과 PostgreSQL 16 membership
6. 객체 범위별 권한
7. security_lab 구조·무결성·IDENTITY
8. 최소 권한 작업 행렬
9. GRANT·REVOKE와 유효 권한·PUBLIC·ACL
10. 현재·미래 객체 권한
11. 실제 허용·차단 동작 검증
12. 소유 역할 안전 정리
13. 환경·비밀·password file 분리
14. SQL Injection 방어
15. 로그·백업 파일 보호
16. 백업·복제·고가용성 구분
17. 버전·백업 계정·RLS·외부 의존성
18. 백업 범위와 custom archive
19. 백업 파일 검증
20. 별도 DB 원자적 복원
21. 구조·데이터·권한 2단계 복원 검증
22. RPO·RTO와 Runbook
23. AI 명령 검토
24. 자주 하는 실수
25. 스스로 확인하기
26. 권장 해설
27. 핵심 정리
28. 다음 장 연결

## 코드 파일

```text
code/chapter11/
├── 01_security_lab_schema.sql
├── 02_security_lab_seed.sql
├── 03_role_permission_plan.sql
├── 04_permission_checks.sql
├── 05_permission_behavior_tests.sql
├── 05_restore_validation.sql
├── 06_restore_validation.sql
├── BACKUP_RESTORE_RUNBOOK.md
├── reset_security_lab.sql
├── security_backup_check.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_security_lab_schema.sql` | Chapter 07·08 전체 기준 검사 후 트랜잭션으로 구조 생성·메타데이터 검증 |
| `02_security_lab_seed.sql` | 3/3/3 샘플·310000·분포·IDENTITY 자동 검증 |
| `03_role_permission_plan.sql` | PostgreSQL 16 membership·Role·GRANT·REVOKE·Default Privileges·백업 권한 계획 |
| `04_permission_checks.sql` | PUBLIC·DB/스키마/객체 ACL·membership 옵션·RLS·유효 권한 확인 |
| `05_permission_behavior_tests.sql` | 실제 허용 동작과 기준 데이터 보존, 차단 동작 선택 실습 |
| `05_restore_validation.sql` | 기존 링크 안내 |
| `06_restore_validation.sql` | 복원 DB 보호와 구조·데이터·금액·IDENTITY·소유권 자동 검증 |
| `BACKUP_RESTORE_RUNBOOK.md` | 버전·권한·RLS·의존성·archive·원자적 복원·2단계 검증 기록 |
| `reset_security_lab.sql` | CASCADE 없이 transaction 단위로 security_lab만 초기화 |
| `security_backup_check.sql` | 안전한 읽기 전용 호환 진입점 |

## 최소 권한 행렬

### 보고 역할

```text
DB CONNECT
security_lab USAGE
세 테이블 SELECT
INSERT·UPDATE·DELETE·schema CREATE 불허
```

### 앱 역할

```text
DB CONNECT
security_lab USAGE
세 테이블 SELECT
enrollments INSERT
enrollments.status 컬럼 UPDATE
enrollments_id_seq USAGE
recorded_amount UPDATE·DELETE·TRUNCATE·schema CREATE 불허
```

### 백업 역할

```text
DB CONNECT
security_lab USAGE
세 테이블 SELECT
세 IDENTITY 시퀀스 SELECT
INSERT·UPDATE·DELETE·schema CREATE 불허
```

## PUBLIC·유효 권한 검증 원칙

```text
has_*_privilege
→ 최종 유효 권한

pg_database.datacl·pg_namespace.nspacl·객체 ACL
→ 직접 GRANT·PUBLIC 권한 경로

information_schema.table_privileges·column_privileges
→ PUBLIC 테이블·컬럼 권한

pg_has_role MEMBER·USAGE
→ 멤버십 존재와 즉시 사용 가능성 구분

pg_auth_members
→ PostgreSQL 16 membership의 INHERIT·SET·ADMIN 옵션
```

## 비밀 정보 원칙

```text
.env.example에는 변수명만 제공
PGPASSWORD 예제 제거
PGPASSFILE 이름만 제공
실제 password file은 저장소 밖
백업·덤프·password file은 .gitignore 대상
노출 시 파일 삭제보다 자격 증명 회전 우선
```

## 백업 전 검사

```text
pg_dump·pg_restore·psql 버전
원본·복원 서버 버전
백업 계정 CONNECT·USAGE·테이블 SELECT·시퀀스 SELECT
RLS 적용 여부
전체 백업과 --enable-row-security 가시 행 백업 구분
외부 FK·사용자 타입·함수·트리거·확장·Large Object·외부 테이블 의존성
저장 위치·암호화·보관 정책
```

## 백업·복원 기준

custom archive에는 원본 owner·ACL 메타데이터를 보존하고 검증 복원에서 적용 여부를 결정한다.

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  --schema=security_lab \
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

Plain SQL은 `psql -X -1 -v ON_ERROR_STOP=1`로 실행한다.

전역 객체 선택안은 `pg_dumpall --globals-only --no-role-passwords`를 검토한다. Role뿐 아니라 Tablespace 같은 전역 객체가 포함될 수 있음을 설명한다.

## 복원 검증 1단계

```text
DB = ai_database_book_restore
3/3/3/JOIN 3
상태 1/1/1/0
총 recorded_amount 310000
recorded_amount NUMERIC(12,0)
금액-course.price 불일치 0
고아 FK·활성 중복 0
NOT NULL 14
13개 명시 제약조건
부분 고유 인덱스 valid/ready
IDENTITY 시퀀스 3개
다음 자동값 > 최대 ID
owner = restore user
```

## 복원 검증 2단계

```text
역할·GRANT 재적용
PUBLIC·직접 권한·멤버십·소유권 확인
읽기 계정 허용·차단
앱 계정 허용·차단
백업 계정 읽기·시퀀스 권한 확인
```

## 자동 검증 목표

전용 GitHub Actions는 PostgreSQL 16에서 다음을 실제 실행한다.

```text
Chapter 07·08 기준 생성
→ 01→02 security_lab
→ 7개 실습 Role 생성
→ membership INHERIT/SET 검증
→ 보고/앱/백업 권한 적용
→ 04 권한 검사
→ 05 허용 동작
→ 차단 동작 실제 실패 확인
→ 최소 권한 역할로 pg_dump custom archive 생성
→ pg_restore --list 확인
→ 별도 DB 원자적 복원
→ 06 자동 검증
→ source fingerprint 불변 확인
→ reset 예상 객체만 삭제
→ 예상 밖 객체가 있으면 reset 전체 ROLLBACK 확인
```

## 안전성 원칙

- 기존 스키마와 데이터를 삭제·변경하지 않는다.
- 생성·초기화·복원 검증 파일은 현재 DB를 실제 검사한다.
- 생성 구조와 reset은 트랜잭션으로 처리한다.
- reset은 `CASCADE`를 사용하지 않는다.
- Role과 권한 변경은 기본 주석 상태로 제공한다.
- PUBLIC 권한과 유효 권한을 구분한다.
- PostgreSQL 16 membership 옵션을 명시적으로 확인한다.
- 앱 시퀀스 권한은 `USAGE`로 최소화한다.
- 백업 역할은 시퀀스 상태 보존이라는 목적 때문에 `SELECT`를 별도 부여한다.
- 실제 비밀번호·password file·접속 URL을 예제에 넣지 않는다.
- 백업 파일을 저장소 밖에 생성한다.
- custom archive의 owner·ACL 보존과 restore 적용 옵션을 구분한다.
- 원본 DB가 아닌 별도 DB에서 원자적으로 복원한다.
- 구조·데이터와 역할·권한을 두 단계로 검증한다.
- 소유 역할 정리는 `REASSIGN OWNED`와 의존성을 먼저 검토한다.

## 다음 장 연결

Chapter 12에서는 관계형 DB와 NoSQL을 조회 패턴, 일관성, 확장성과 운영 책임 관점에서 비교한다. 저장소가 달라져도 접근 통제, 비밀 보호와 복구 검증은 함께 설계한다.


## 최종 출판 보안 보완

- `PGPASSWORD` 장기 사용을 피하고 `PGPASSFILE` 기반 password file을 사용한다.
- Unix 계열 password file은 `chmod 0600` 수준으로 제한하고, Windows는 접근이 제한된 보호 경로를 사용한다.
- Chapter 07 구조 계약 15/20과 DB CREATE 권한을 `security_lab` 생성 전에 확인한다.
