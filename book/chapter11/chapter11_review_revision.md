# Chapter 11 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter11/chapter11.md
book/chapter11/chapter11_activity.md
book/chapter11/chapter11_outline.md
book/chapter11/chapter11_review_revision.md
code/chapter11/01_security_lab_schema.sql
code/chapter11/02_security_lab_seed.sql
code/chapter11/03_role_permission_plan.sql
code/chapter11/04_permission_checks.sql
code/chapter11/05_permission_behavior_tests.sql
code/chapter11/05_restore_validation.sql
code/chapter11/06_restore_validation.sql
code/chapter11/BACKUP_RESTORE_RUNBOOK.md
code/chapter11/reset_security_lab.sql
code/chapter11/security_backup_check.sql
code/chapter11/README.md
notes/chapter11_review_checklist.md
.env.example
README.md
```

## 검수 목적

Chapter 11을 단순한 권한·백업 명령 소개가 아니라 다음 결과를 실제로 확인하는 운영 장으로 완성했습니다.

```text
최소 권한 설계
→ PUBLIC·직접 GRANT·멤버십·소유권 경로 확인
→ 허용·차단 DML 검증
→ 비밀·입력 보호
→ 백업 계정·RLS·외부 의존성·버전 확인
→ 별도 DB 원자적 복원
→ 구조·데이터·소유권·권한 2단계 검증
```

---

## 1. 생성·초기화 안전성 강화

`01_security_lab_schema.sql`은 다음 조건을 하나의 보호 구문에서 확인합니다.

```text
현재 DB = ai_database_book
course_project.enrollments = 5행
security_lab 미존재
```

스키마와 세 테이블은 하나의 트랜잭션으로 생성합니다.

`reset_security_lab.sql`은 `ai_database_book`이 아니면 예외를 발생시키며, 조건이 맞을 때만 `security_lab` 객체를 삭제합니다.

모든 SQL에 다음 위치 확인을 통일했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

---

## 2. Chapter 07 업무 규칙 유지

기존 원고는 재신청 정책을 다시 미확정으로 처리했으나 Chapter 07에서 이미 확정한 활성 신청 규칙을 유지하도록 수정했습니다.

```sql
CREATE UNIQUE INDEX uq_security_enrollments_active
ON security_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

완료·취소 이력은 여러 건 허용하지만 진행 중 신청은 학생·강의 조합당 한 건입니다.

---

## 3. 이메일 무결성 보완

학생 이메일에 다음 규칙을 적용했습니다.

```text
NOT NULL
공백 문자열 금지 CHECK
정확히 같은 문자열 중복 금지 UNIQUE
```

대소문자·별칭 정규화는 범위에서 제외했습니다.

---

## 4. IDENTITY 시작값 조정

명시적 샘플 ID 입력 후 다음 값으로 조정했습니다.

```text
students.id → 104
courses.id → 204
enrollments.id → 1004
```

권한 동작 테스트의 자동 ID INSERT가 `ROLLBACK`되어도 번호가 회수되지 않을 수 있으므로 복원 검증은 연속 번호가 아니라 **다음 값이 현재 최대 ID보다 큰지** 판정합니다.

---

## 5. PUBLIC 권한 조회 오류 수정

기존 `information_schema.role_table_grants`의 `grantee = 'PUBLIC'` 조회를 수정했습니다.

```text
table_privileges
→ PUBLIC 테이블 권한

column_privileges
→ PUBLIC 컬럼 권한
```

`role_table_grants`와 `role_column_grants`는 현재 활성화된 역할 기준이며 PUBLIC 경로를 제외할 수 있다는 설명을 추가했습니다.

---

## 6. 유효 권한과 부여 경로 구분

```text
has_*_privilege
→ 최종적으로 가능한 작업

pg_database.datacl
pg_namespace.nspacl
테이블·시퀀스 ACL
→ 직접 GRANT와 PUBLIC 권한 경로
```

데이터베이스의 `CONNECT = true`가 실습 역할에 직접 부여한 GRANT의 결과라고 단정하지 않도록 `PUBLIC CONNECT`와 DB ACL을 함께 확인합니다.

---

## 7. 역할 멤버십 검증 보완

다음을 구분했습니다.

```text
pg_has_role(..., 'MEMBER')
→ 역할 멤버십 존재

pg_has_role(..., 'USAGE')
→ 해당 권한을 즉시 사용할 수 있는지 확인
```

단순 멤버십과 실제 권한 상속을 같은 의미로 설명하지 않도록 수정했습니다.

---

## 8. 시퀀스 권한 최소화

앱 역할의 기본 권한을 다음처럼 수정했습니다.

```sql
GRANT USAGE
ON SEQUENCE security_lab.enrollments_id_seq
TO lab_role_enrollment_app;
```

자동 ID 생성에 필요한 최소 권한만 제공하며, 시퀀스 상태를 직접 조회하는 업무 요구가 없으면 `SELECT`는 부여하지 않습니다.

---

## 9. 허용·차단 DML 실습 추가

신규 파일:

```text
code/chapter11/05_permission_behavior_tests.sql
```

검증 범위:

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

성공 테스트는 `ROLLBACK`해 기준 데이터를 보존하고, 실패 테스트는 한 문장씩 선택 실행하도록 구성했습니다.

---

## 10. 자격 증명 예시 개선

`.env.example`의 `PGPASSWORD`를 제거하고 다음으로 변경했습니다.

```text
PGPASSFILE=
```

실제 libpq password file은 저장소 밖에 두고 OS 접근 권한을 제한하도록 본문·워크북·README에 반영했습니다.

---

## 11. 백업 전 검사 확대

다음 항목을 백업 실행 전 확인하도록 추가했습니다.

```text
pg_dump·pg_restore·psql 버전
원본·복원 PostgreSQL 서버 버전
백업 계정의 CONNECT·USAGE·SELECT
RLS 적용 여부
외부 스키마 FK
사용자 정의 타입
함수·트리거
확장 기능
Large Object
외부 테이블
```

현재 `security_lab`은 외부 스키마 의존성 없이 단독 복원할 수 있도록 구성했습니다.

---

## 12. 전역 객체 설명 보완

`pg_dumpall --globals-only`는 Role뿐 아니라 Tablespace 같은 전역 객체를 포함할 수 있음을 명시했습니다.

역할 암호 정보가 필요하지 않은 경우 다음 선택안을 추가했습니다.

```bash
pg_dumpall \
  --globals-only \
  --no-role-passwords \
  ...
```

---

## 13. 복원 DB 소유자와 역할 일치

기존 생성 명령을 다음처럼 변경했습니다.

```bash
createdb \
  -U <admin_user> \
  -O <restore_user> \
  -T template0 \
  ai_database_book_restore
```

복원 역할이 DB owner가 되어 스키마·객체를 생성할 수 있도록 하고, `template0`를 사용해 불필요한 사용자 객체 영향을 줄였습니다.

---

## 14. 원자적 복원 적용

사용자 정의 형식:

```bash
pg_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  ...
```

Plain SQL:

```bash
psql -X -1 -v ON_ERROR_STOP=1 ...
```

작은 실습에서 오류가 발생할 때 부분 복원 객체가 남는 위험을 줄였습니다. 대규모 운영 복원에서는 긴 트랜잭션과 자원 사용을 별도로 검토하도록 범위를 명시했습니다.

---

## 15. 복원 검증 파일 보호·자동 판정

신규 최종 파일:

```text
code/chapter11/06_restore_validation.sql
```

현재 DB가 `ai_database_book_restore`가 아니면 예외를 발생시킵니다.

자동 검증:

```text
students·courses·enrollments = 3·3·3
JOIN = 3
고아 FK = 0
활성 신청 중복 = 0
13개 명시 제약조건 유지
부분 고유 인덱스 유지
IDENTITY 시퀀스 3개
다음 자동값 > 현재 최대 ID
schema·table·sequence owner = 현재 restore user
```

기존 `05_restore_validation.sql`은 링크 호환 안내 파일로 전환했습니다.

---

## 16. 복원 검증 2단계 분리

```text
1단계
→ --no-owner --no-privileges 직후 구조·데이터·소유권 검증

2단계
→ 역할·GRANT 재적용
→ PUBLIC·ACL·멤버십·유효 권한 확인
→ 실제 허용·차단 DML 검증
```

원본 ACL이 제외된 상태와 역할 재적용 후 상태를 섞지 않도록 했습니다.

---

## 17. 소유 역할 정리 보완

객체 소유 역할은 바로 삭제할 수 없음을 명시했습니다.

```text
REASSIGN OWNED
→ DROP OWNED 검토
→ 관련 데이터베이스별 의존성 확인
→ DROP ROLE
```

`DROP OWNED ... CASCADE`는 기본 정리 명령으로 제공하지 않습니다.

---

## 18. 본문·워크북·코드 동기화

다음을 모두 같은 기준으로 맞췄습니다.

```text
파일 순서
PUBLIC 권한 조회
MEMBER·USAGE 구분
시퀀스 USAGE 최소 권한
PGPASSFILE
버전·백업 계정·RLS·외부 의존성
restore DB owner·template0
single-transaction 복원
2단계 검증
권장 해설
```

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 생성·초기화 DB 보호 구문 | 완료 |
| Chapter 07 활성 신청 정책 | 완료 |
| 이메일 공백 CHECK | 완료 |
| IDENTITY 시작값 | 완료 |
| PUBLIC 조회 오류 | 완료 |
| DB CONNECT 경로 구분 | 완료 |
| MEMBER·USAGE 구분 | 완료 |
| 시퀀스 최소 권한 | 완료 |
| 허용·차단 동작 파일 | 완료 |
| PGPASSWORD 제거 | 완료 |
| 버전·백업 계정·RLS·의존성 | 완료 |
| 전역 객체·역할 암호 범위 | 완료 |
| 복원 DB owner·template0 | 완료 |
| 원자적 복원 | 완료 |
| 원본 DB 복원 검증 차단 | 완료 |
| 전체 자동 복원 판정 | 완료 |
| 소유 역할 정리 절차 | 완료 |
| 워크북 권장 해설 | 완료 |

## 결론

```text
Chapter 11은 권한과 백업 명령을 소개하는 장에서,
최소 권한의 실제 동작과 별도 DB 복구 가능성을 증명하는 운영 장으로 완성되었다.
```

실제 PostgreSQL 관리자 테스트 환경의 Role 생성·권한 동작, custom-format 백업·복원과 Word·PDF·eBook 렌더링은 별도 제작 단계에서 확인합니다.
