# Chapter 11 실습 발표 강의안

## 권한을 검증하고 백업을 복원해 확인하기

> 목적: `security_lab`에서 최소 권한을 설계·검증하고, 논리 백업 파일을 별도 DB에 복원해 구조·데이터·소유권·권한을 확인한다.  
> 기준: 초보자가 “권한을 줬다”가 아니라 “허용되어야 할 작업은 성공하고 차단되어야 할 작업은 실패했으며, 백업도 복원 검증을 통과했다”라고 말할 수 있어야 한다.

---

## 1. 이번 실습은 허용·차단·복원을 확인합니다

**화면 구성**

```text
01 schema
→ 02 seed
→ 03 role / permission plan
→ 04 permission checks
→ 05 behavior tests
→ backup / restore
→ 06 restore validation
→ runbook 기록
```

**발표 스크립트**

이번 실습은 데이터를 빠르게 조회하는 실습이 아닙니다. 누가 어떤 작업을 할 수 있어야 하는지 정하고, 실제 권한과 동작을 확인하는 실습입니다.

또 백업 파일을 만든 뒤 별도 데이터베이스에 복원해 봅니다. 백업은 파일이 생긴 순간 끝나는 것이 아니라, 복원 검증을 통과해야 의미가 있습니다.

---

## 2. 실행 위치와 보호 범위를 먼저 확인합니다

**화면 구성**

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

```text
원본 DB: ai_database_book
복원 검증 DB: ai_database_book_restore
실습 대상: security_lab
변경 금지: course_project, transaction_lab, performance_lab
```

**발표 스크립트**

보안 실습은 역할과 권한을 다루기 때문에 실행 위치가 특히 중요합니다.

원본 실습은 `ai_database_book`에서 하고, 복원 검증은 `ai_database_book_restore`에서 합니다. 두 데이터베이스를 헷갈리면 원본에 복원하거나 검증 파일을 잘못 실행할 수 있습니다.

또 Chapter 11의 변경 대상은 `security_lab`입니다. 앞 장의 `course_project`, `transaction_lab`, `performance_lab`은 보존해야 합니다.

---

## 3. 보호 자산과 위험을 워크북에 기록합니다

**화면 구성**

| 보호 자산 | 예 | 위험 |
|---|---|---|
| 개인정보 | 이름·이메일 | 과도한 조회 |
| 접속 정보 | URL·비밀번호 | 계정 탈취 |
| 업무 데이터 | 신청 상태·금액 | 무단 변경 |
| 백업 파일 | 데이터 사본 | 외부 유출 |

**발표 스크립트**

실습을 시작하기 전에 무엇을 보호하는지 적습니다. 이 단계가 있어야 권한 설계와 백업 정책이 근거를 가집니다.

예를 들어 보고 계정은 개인정보를 읽을 수 있지만 변경은 못 하게 해야 합니다. 앱 계정은 신청을 만들 수 있지만 금액을 마음대로 바꾸면 안 됩니다.

보호 자산을 정리하면 뒤에서 허용할 작업과 차단할 작업을 더 분명히 판단할 수 있습니다.

---

## 4. `security_lab` 기준 데이터를 만듭니다

**화면 구성**

```text
students = 3
courses = 3
enrollments = 3
JOIN 결과 = 3
IDENTITY 다음 값:
students 104, courses 204, enrollments 1004
```

**발표 스크립트**

`01` 파일은 스키마와 테이블을 만들고, `02` 파일은 샘플 데이터를 입력합니다.

기준 행 수는 학생 3명, 강의 3개, 신청 3건입니다. JOIN 결과도 3행이어야 합니다.

명시적 ID를 사용했기 때문에 IDENTITY 다음 값도 확인합니다. 이 값을 맞추지 않으면 이후 ID를 생략한 INSERT에서 기존 ID와 충돌할 수 있습니다.

---

## 5. 권한 실습 전 무결성 규칙을 확인합니다

**화면 구성**

- 이름·이메일 공백 금지
- 정확히 같은 이메일 중복 금지
- 존재하는 학생·강의만 참조
- 음수 금액 금지
- 진행 중 활성 신청 중복 금지

**발표 스크립트**

보안 실습에서도 데이터 무결성은 기본입니다. 권한이 있어도 잘못된 데이터를 넣으면 안 됩니다.

`security_lab`에는 Chapter 07과 비슷하게 진행 중 활성 신청 중복을 막는 부분 고유 인덱스가 있습니다.

즉 완료와 취소 이력은 남길 수 있지만, 같은 학생과 강의에 대해 신청 또는 수강중 상태가 동시에 두 건 존재하면 안 됩니다.

---

## 6. 역할 설계는 로그인과 권한 묶음을 분리합니다

**화면 구성**

```text
NOLOGIN 역할:
owner, report_reader, enrollment_app, backup_reader

LOGIN 역할:
readonly_user, enrollment_user
```

**발표 스크립트**

`03_role_permission_plan.sql`은 역할 생성과 권한 부여 문장을 제공합니다. 다만 역할은 클러스터 전역에 영향을 줄 수 있으므로 관리자 권한이 있는 테스트 환경에서 필요한 문장만 선택 실행합니다.

로그인 역할은 실제 접속 계정이고, NOLOGIN 역할은 권한 묶음입니다.

이 구조를 사용하면 실제 사용자 계정이 바뀌어도 권한 묶음을 일관되게 관리할 수 있습니다.

---

## 7. 역할별 작업 행렬을 기준으로 GRANT합니다

**화면 구성**

| 작업 | 읽기 계정 | 앱 계정 |
|---|---|---|
| SELECT | 성공 | 성공 |
| INSERT | 실패 | 성공 |
| status UPDATE | 실패 | 성공 |
| paid_amount UPDATE | 실패 | 실패 |
| DELETE | 실패 | 실패 |
| schema CREATE | 실패 | 실패 |

**발표 스크립트**

권한을 줄 때는 먼저 작업 행렬을 봅니다. 역할별로 허용할 작업과 차단할 작업을 미리 정해야 합니다.

읽기 계정은 SELECT만 성공해야 합니다. 앱 계정은 신청 INSERT와 status UPDATE는 성공해야 하지만, 금액 변경과 삭제, 스키마 생성은 실패해야 합니다.

이 표가 뒤에서 권한 검증과 동작 테스트의 기준표가 됩니다.

---

## 8. 시퀀스 권한을 별도로 확인합니다

**화면 구성**

```text
INSERT 권한
+ enrollments_id_seq USAGE
→ ID 생략 INSERT 가능

sequence SELECT
→ 기본 부여하지 않음
```

**발표 스크립트**

IDENTITY 컬럼에 값을 생략하고 INSERT하려면 연결된 시퀀스에서 다음 번호를 받아야 합니다.

그래서 앱 역할에는 `enrollments_id_seq`에 대한 USAGE가 필요합니다.

하지만 시퀀스 값을 직접 조회하는 SELECT는 업무상 필요하지 않을 수 있습니다. 최소 권한 원칙에서는 필요한 USAGE만 부여하고 SELECT는 기본적으로 주지 않습니다.

---

## 9. 유효 권한 함수로 최종 가능 여부를 확인합니다

**화면 구성**

```text
has_database_privilege
has_schema_privilege
has_table_privilege
has_column_privilege
has_sequence_privilege
```

**발표 스크립트**

`04_permission_checks.sql`은 로그인 역할이 최종적으로 어떤 작업을 할 수 있는지 확인합니다.

예를 들어 읽기 계정의 SELECT는 true, INSERT는 false여야 합니다. 앱 계정은 INSERT true, 전체 UPDATE false, status 컬럼 UPDATE true, paid_amount UPDATE false여야 합니다.

권한 함수 결과가 기대와 다르면 바로 다음 단계로 넘어가지 말고 GRANT, 멤버십, PUBLIC, 소유권 경로를 다시 확인합니다.

---

## 10. 권한 경로를 ACL·PUBLIC·멤버십으로 확인합니다

**화면 구성**

```text
role_table_grants
role_column_grants
table_privileges / column_privileges
pg_database.datacl
pg_namespace.nspacl
pg_has_role
pg_class.relowner
```

**발표 스크립트**

유효 권한이 true라고 해서 반드시 우리가 방금 직접 GRANT했기 때문이라고 단정하면 안 됩니다.

PUBLIC 권한, 다른 역할 멤버십, 객체 소유권 때문에 가능할 수도 있습니다.

특히 `has_database_privilege(..., 'CONNECT')`가 true인 것은 PUBLIC CONNECT 때문일 수 있습니다. 그래서 권한이 가능한지와 어떤 경로로 가능한지를 따로 확인합니다.

---

## 11. 실제 허용·차단 동작을 테스트합니다

**화면 구성**

```text
읽기 계정:
SELECT 성공
INSERT·UPDATE·DELETE 실패

앱 계정:
SELECT·INSERT·status UPDATE 성공
paid_amount UPDATE·DELETE·CREATE 실패
```

**발표 스크립트**

권한 함수 확인 후에는 실제 SQL 동작을 확인합니다.

성공해야 하는 작업은 성공해야 하고, 실패해야 하는 작업은 실제로 실패해야 합니다. 실패는 실습 오류가 아니라 기대한 보안 결과일 수 있습니다.

성공 테스트는 마지막에 ROLLBACK해 기준 데이터를 유지합니다. 실패 테스트는 한 문장씩 실행하고, 오류 상태가 되면 SAVEPOINT나 ROLLBACK으로 복구합니다.

---

## 12. 현재 객체와 미래 객체 권한을 구분합니다

**화면 구성**

```text
GRANT ON TABLE
→ 현재 테이블

ALTER DEFAULT PRIVILEGES
→ 앞으로 생성될 테이블
```

**발표 스크립트**

실습 중 새 테이블이 생긴다면 기존 GRANT만으로는 권한이 자동 적용되지 않을 수 있습니다.

Default Privileges는 앞으로 특정 역할이 만드는 객체에 적용됩니다. 이미 있는 객체에는 적용되지 않습니다.

따라서 운영에서는 현재 객체 권한과 미래 객체 권한을 모두 설계해야 합니다.

---

## 13. PUBLIC과 소유권은 변경 전 영향 범위를 봅니다

**화면 구성**

- PUBLIC 권한 확인
- schema owner 확인
- table·sequence owner 확인
- 무조건 REVOKE 금지
- DROP OWNED CASCADE 기본 금지

**발표 스크립트**

PUBLIC은 모든 역할에 영향을 줄 수 있는 경로입니다. 따라서 보인다고 무조건 지우거나, 필요해 보인다고 무조건 유지하지 않습니다.

먼저 어떤 객체에 어떤 PUBLIC 권한이 있는지 확인하고, 해당 권한을 사용하는 계정이나 애플리케이션이 있는지 봅니다.

소유 역할도 삭제하기 전에 소유 객체와 권한 의존성을 확인해야 합니다. 잘못 정리하면 필요한 객체까지 삭제될 수 있습니다.

---

## 14. 비밀 정보와 저장소 상태를 점검합니다

**화면 구성**

- 실제 `.env` 없음
- `.env.example`에는 변수 이름만
- `PGPASSWORD` 문서·코드에 없음
- password file은 저장소 밖
- 백업 파일 커밋 금지

**발표 스크립트**

보안 실습은 DB 안의 권한만 보는 것이 아닙니다. 저장소에 실제 접속 정보가 없는지도 확인해야 합니다.

`.env.example`은 변수 이름을 안내하는 파일이고 실제 값이 들어가면 안 됩니다.

실제 비밀번호나 토큰이 노출되었다면 파일 삭제보다 먼저 비밀번호를 회전해야 합니다.

---

## 15. SQL Injection 방어 원칙을 확인합니다

**화면 구성**

```text
위험: 문자열 결합 SQL
안전: 파라미터 바인딩

값: 바인딩
컬럼·정렬 방향: 허용 목록
```

**발표 스크립트**

사용자 입력을 SQL 문자열에 직접 붙이면 입력값이 SQL 구조를 바꿀 수 있습니다.

값은 파라미터 바인딩으로 처리합니다. 반면 컬럼명이나 정렬 방향처럼 구조에 해당하는 부분은 허용 목록에서만 선택해야 합니다.

최소 권한 계정까지 함께 사용하면 혹시 취약점이 생겨도 피해 범위를 줄일 수 있습니다.

---

## 16. 백업 전 도구·권한·의존성을 확인합니다

**화면 구성**

```text
pg_dump --version
pg_restore --version
psql --version
SHOW server_version;

backup_user 권한
RLS 여부
외부 의존성
```

**발표 스크립트**

백업은 터미널에서 `pg_dump`를 실행하기 전에 준비 확인이 필요합니다.

도구 버전과 서버 버전을 확인하고, 백업 계정이 대상 스키마와 테이블을 읽을 수 있는지 확인합니다.

특정 스키마만 백업한다면 외부 FK, 함수, 확장 같은 의존성이 빠지지 않는지도 확인합니다.

---

## 17. 백업 파일을 만들고 파일 자체를 검증합니다

**화면 구성**

```bash
pg_dump -Fc --schema=security_lab --no-owner --no-privileges
pg_restore --list security_lab.backup
sha256sum 또는 Get-FileHash
```

**발표 스크립트**

`security_lab` 백업은 사용자 정의 형식 `-Fc`로 만들 수 있습니다.

`--no-owner --no-privileges`는 다른 복원 환경으로 옮기기 쉽게 하지만, 원본 소유권과 권한은 포함하지 않는다는 뜻입니다. 그래서 복원 후 권한을 별도로 적용해야 합니다.

백업 후에는 종료 코드, 오류 메시지, 파일 크기, 아카이브 목록, 해시를 기록합니다.

---

## 18. 원본이 아니라 별도 DB에 복원합니다

**화면 구성**

```text
createdb ai_database_book_restore
→ pg_restore --single-transaction
→ 원본 덮어쓰기 금지
```

**발표 스크립트**

복원 시험은 원본 DB에 하지 않습니다. 깨끗한 별도 데이터베이스를 만들고 거기에 복원합니다.

작은 실습 백업은 `--single-transaction`으로 복원해 오류가 발생했을 때 부분 복원 위험을 줄입니다.

대규모 운영 복원에서는 긴 트랜잭션과 자원 사용을 별도 검토해야 하지만, 입문 실습에서는 원자적 복원 흐름을 이해하는 것이 중요합니다.

---

## 19. 복원 DB에서 구조·데이터·소유권을 검증합니다

**화면 구성**

```text
06_restore_validation.sql
실행 DB = ai_database_book_restore
students/courses/enrollments = 3/3/3
JOIN = 3
고아 FK = 0
활성 중복 = 0
제약조건·인덱스·IDENTITY 유지
owner 확인
```

**발표 스크립트**

`06_restore_validation.sql`은 복원 DB에서 실행해야 합니다. 원본 DB에서 실행하면 안 됩니다.

이 파일은 행 수뿐 아니라 JOIN 결과, 고아 FK, 활성 중복, 제약조건, 부분 고유 인덱스, IDENTITY 다음 값, 소유권을 확인합니다.

이 검증이 실패하면 백업 파일을 성공으로 표시하지 않습니다. 원인을 수정한 뒤 다시 백업·복원·검증해야 합니다.

---

## 20. Runbook에는 복구 가능성을 남깁니다

**화면 구성**

```text
백업 시각
파일 경로·해시
원본·복원 DB
사용 명령
검증 결과
권한 재적용 결과
RPO·RTO
문제와 수정 내용
```

**발표 스크립트**

마지막으로 `BACKUP_RESTORE_RUNBOOK.md`에 결과를 기록합니다.

Runbook은 나중에 장애가 났을 때 그대로 따라 할 수 있는 복구 절차서입니다. 백업 파일 경로, 해시, 복원 명령, 검증 결과, 권한 재적용 결과를 남겨야 합니다.

Chapter 11 실습의 완료 기준은 명확합니다. 허용·차단 권한이 기대와 맞고, 백업 파일이 별도 DB에서 구조·데이터·소유권·권한 검증까지 통과해야 합니다.
