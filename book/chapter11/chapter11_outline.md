# Chapter 11 구성안

## 제목

데이터베이스를 안전하게 지키고 복구하는 방법

## 권장 분량

26~30페이지

## 이 장의 역할

Chapter 11은 접근 통제, 비밀 정보 보호, SQL Injection 방어, 논리 백업과 별도 DB 복원 검증을 하나의 운영 흐름으로 연결한다.

```text
보호 대상·위험
→ 역할·소유권 분리
→ 최소 권한 작업 행렬
→ GRANT·REVOKE
→ 유효 권한 확인
→ 비밀·입력 보호
→ 백업 범위·형식
→ 별도 DB 복원
→ 구조·데이터·권한 검증
→ RPO·RTO·실행 기록
```

## 핵심 질문

```text
누가 접속하고 어떤 역할의 권한을 사용하는가?
앱 계정이 실제로 필요한 작업은 무엇인가?
객체 소유권과 실행 권한이 분리되어 있는가?
REVOKE 후 다른 경로의 권한이 남아 있는가?
실제 비밀번호·접속 URL·백업 파일이 저장소에 없는가?
백업 범위와 owner·ACL 처리 방식이 명확한가?
별도 DB에서 실제 복원하고 검증했는가?
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
```

역할 예시:

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
```

## 기준 데이터

```text
students 3
courses 3
enrollments 3
JOIN 3
```

명시적 ID:

```text
students 101~103
courses 201~203
enrollments 1001~1003
```

## 핵심 개념

- 인증
- 권한 부여
- 객체 소유권
- Role
- LOGIN·NOLOGIN
- 역할 멤버십
- 최소 권한
- CONNECT·USAGE·SELECT·INSERT·UPDATE
- 컬럼 권한
- 시퀀스 권한
- PUBLIC
- 유효 권한
- Default Privileges
- 환경 분리
- 비밀 정보 회전
- SQL Injection
- 파라미터 바인딩
- 허용 목록
- 논리 백업
- pg_dump·pg_restore·psql
- owner·ACL
- 복원 검증
- RPO·RTO
- 복구 실행 문서
- AI 명령 검토

## 본문 구성

1. 보안 통제와 복구 준비
2. 기존 프로젝트를 보호하는 실습 구조
3. 보호 자산과 위험
4. 인증·권한·소유권
5. 로그인 역할과 권한 역할
6. 권한 범위
7. security_lab 구조와 데이터
8. 최소 권한 작업 행렬
9. 유효 권한 확인
10. 현재·미래 객체 권한
11. PUBLIC과 소유권
12. 환경 분리
13. SQL Injection 방어
14. 로그·백업 파일 보호
15. 백업·복제·스냅샷 구분
16. 백업 범위와 형식
17. 백업 파일 검증
18. 별도 DB 복원
19. 복원 후 검증
20. RPO·RTO와 실행 기록
21. AI 명령 검토
22. 자주 하는 실수
23. 스스로 확인하기
24. 핵심 정리
25. 다음 장 연결

## 코드 파일

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

| 파일 | 역할 |
| --- | --- |
| `01_security_lab_schema.sql` | 전용 스키마와 IDENTITY 테이블 생성 |
| `02_security_lab_seed.sql` | 명시적 ID 정상 샘플 입력 |
| `03_role_permission_plan.sql` | 역할·GRANT·REVOKE·Default Privileges 계획 |
| `04_permission_checks.sql` | 역할·멤버십·객체·컬럼·시퀀스 권한 확인 |
| `05_restore_validation.sql` | 복원 DB의 구조·데이터·제약조건 검증 |
| `BACKUP_RESTORE_RUNBOOK.md` | 백업·복원 명령과 실행 기록 |
| `reset_security_lab.sql` | security_lab만 초기화 |
| `security_backup_check.sql` | 안전한 호환 진입점 |

## 안전성 원칙

- 기존 스키마와 데이터를 삭제·변경하지 않는다.
- 생성 파일에 자동 DROP을 넣지 않는다.
- SERIAL 대신 IDENTITY를 사용한다.
- 역할 생성·GRANT·REVOKE는 기본 주석 상태로 제공한다.
- 실제 비밀번호·접속 URL을 예제에 넣지 않는다.
- 백업 파일을 저장소 밖에 생성한다.
- 원본 DB가 아닌 별도 복원 DB에서 검증한다.
- 역할·owner·ACL 포함 여부를 명시한다.
- 복원 오류 중단 옵션을 사용한다.
- 역할 정리는 자동 실행하지 않는다.

## AI 활용 원칙

- 실제 환경과 대상 객체를 명시한다.
- 과도한 권한과 비밀번호 포함을 금지한다.
- 적용 후 유효 권한 검증 SQL을 요구한다.
- 백업 범위·형식·owner·ACL 처리 근거를 요구한다.
- 별도 DB 복원과 검증 기준을 함께 요구한다.
- 원본 DB에 파괴적 복원을 수행하는 제안을 거부한다.

## 다음 장 연결

Chapter 12에서는 관계형 DB와 다른 데이터 모델인 NoSQL을 조회 패턴, 일관성, 확장성과 운영 책임 관점에서 비교한다.
