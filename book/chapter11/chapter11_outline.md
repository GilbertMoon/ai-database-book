# Chapter 11 구성안

## 제목

데이터베이스를 안전하게 지키고 복구하는 방법

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 11은 접근 통제, 비밀 정보 보호, SQL Injection 방어, 논리 백업과 별도 DB 복원 검증을 하나의 운영 흐름으로 연결한다.

```text
보호 대상·위험
→ 역할·소유권 분리
→ 최소 권한 작업 행렬
→ GRANT·REVOKE
→ PUBLIC·ACL·멤버십·유효 권한 확인
→ 실제 허용·차단 동작 검증
→ 비밀·입력 보호
→ 백업 계정·범위·형식·의존성·버전 확인
→ 별도 DB 원자적 복원
→ 구조·데이터·소유권·권한 2단계 검증
→ RPO·RTO·실행 기록
```

## 핵심 질문

```text
누가 접속하고 어떤 역할의 권한을 사용하는가?
앱 계정이 실제로 필요한 작업은 무엇인가?
객체 소유권과 실행 권한이 분리되어 있는가?
유효 권한은 직접 GRANT·멤버십·PUBLIC·소유권 중 어디서 왔는가?
MEMBER와 즉시 사용할 수 있는 권한은 구분되는가?
비밀번호·password file·접속 URL·백업 파일이 저장소 밖에 있는가?
백업 계정은 대상 데이터를 읽을 수 있고 RLS 영향을 확인했는가?
특정 스키마의 외부 의존성을 확인했는가?
도구·서버 버전이 호환되는가?
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

앞 장 스키마:

```text
course_project: 변경 금지
transaction_lab: 변경 금지
performance_lab: 변경 금지
public: 변경 금지
```

## 역할 예시

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_role_backup_reader NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
```

## 기준 데이터와 IDENTITY

| 테이블 | 행 수 | 명시적 ID | 다음 자동값 |
| --- | ---: | --- | ---: |
| students | 3 | 101~103 | 104 이상 |
| courses | 3 | 201~203 | 204 이상 |
| enrollments | 3 | 1001~1003 | 1004 이상 |
| JOIN | 3 | - | - |

권한 동작 테스트의 ROLLBACK 이후 자동 번호 공백은 허용한다.

## 핵심 무결성 규칙

```text
학생 이름·이메일 공백 금지
정확히 같은 이메일 문자열 중복 금지
존재하는 학생·강의만 참조
금액 0 이상
상태 허용값 제한
신청·수강중 활성 신청은 학생·강의당 한 건
완료·취소 이력은 여러 건 허용
```

## 핵심 개념

- 인증
- 권한 부여
- 객체 소유권
- 감사
- Role
- `LOGIN`, `NOLOGIN`
- 역할 멤버십
- `MEMBER`, `USAGE`
- 최소 권한
- `CONNECT`, schema `USAGE`, `SELECT`, `INSERT`, column `UPDATE`
- 시퀀스 `USAGE`
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
- 스키마 외부 의존성
- `pg_dump`, `pg_restore`, `psql`
- 도구·서버 버전
- owner·ACL
- `template0`
- `--single-transaction`
- `psql -X -1 ON_ERROR_STOP`
- 복원 검증
- RPO·RTO
- 복구 Runbook
- AI 명령 검토

## 본문 구성

1. 보안 통제와 복구 준비
2. 기존 프로젝트 보호와 실습 구조
3. 보호 자산과 위험
4. 인증·권한·소유권
5. 로그인·권한·소유 역할
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
18. 백업 범위와 형식
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
| `01_security_lab_schema.sql` | DB·Chapter 07 상태 검사 후 트랜잭션으로 구조 생성 |
| `02_security_lab_seed.sql` | 샘플·IDENTITY 조정·자동 검증 |
| `03_role_permission_plan.sql` | 역할·GRANT·REVOKE·Default Privileges·소유권·정리 계획 |
| `04_permission_checks.sql` | PUBLIC·DB/스키마/객체 ACL·유효 권한·멤버십 확인 |
| `05_permission_behavior_tests.sql` | 실제 허용·차단 동작 선택 실습 |
| `05_restore_validation.sql` | 기존 링크 안내 |
| `06_restore_validation.sql` | 복원 DB 보호 구문과 구조·데이터·소유권 자동 검증 |
| `BACKUP_RESTORE_RUNBOOK.md` | 버전·권한·의존성·백업·원자적 복원·2단계 검증 기록 |
| `reset_security_lab.sql` | DB 보호 구문 안에서 security_lab만 초기화 |
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
paid_amount UPDATE·DELETE·TRUNCATE·schema CREATE 불허
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
→ 멤버십 존재와 권한 사용 가능성 구분
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
백업 계정 CONNECT·USAGE·SELECT
RLS 적용 여부
외부 FK·사용자 타입·함수·트리거·확장·Large Object 의존성
저장 위치·암호화·보관 정책
```

## 백업·복원 기준

```text
security_lab custom format
--no-owner --no-privileges
pg_restore --list
SHA-256
createdb -O <restore_user> -T template0
pg_restore --single-transaction
plain SQL: psql -X -1 -v ON_ERROR_STOP=1
```

전역 객체 선택안은 `pg_dumpall --globals-only --no-role-passwords`를 검토한다. Role뿐 아니라 Tablespace 같은 전역 객체가 포함될 수 있음을 설명한다.

## 복원 검증 1단계

```text
DB = ai_database_book_restore
3/3/3/JOIN 3
고아 FK·활성 중복 0
13개 명시 제약조건
부분 고유 인덱스
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
```

## 안전성 원칙

- 기존 스키마와 데이터를 삭제·변경하지 않는다.
- 생성·초기화·복원 검증 파일은 현재 DB를 실제 검사한다.
- 생성 구조는 하나의 트랜잭션으로 처리한다.
- Role과 권한 변경은 기본 주석 상태로 제공한다.
- PUBLIC 권한과 유효 권한을 구분한다.
- 시퀀스 권한은 `USAGE`로 최소화한다.
- 실제 비밀번호·password file·접속 URL을 예제에 넣지 않는다.
- 백업 파일을 저장소 밖에 생성한다.
- 원본 DB가 아닌 별도 DB에서 원자적으로 복원한다.
- 구조·데이터와 역할·권한을 두 단계로 검증한다.
- 소유 역할 정리는 `REASSIGN OWNED`와 의존성을 먼저 검토한다.

## 다음 장 연결

Chapter 12에서는 관계형 DB와 NoSQL을 조회 패턴, 일관성, 확장성과 운영 책임 관점에서 비교한다. 저장소가 달라져도 접근 통제, 비밀 보호와 복구 검증은 함께 설계한다.
