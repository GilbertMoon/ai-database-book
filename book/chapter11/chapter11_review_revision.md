# Chapter 11 전체 점검·반영 기록

## Chapter

```text
Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법
```

## 전체 점검 범위

Chapter 11을 다음 흐름으로 다시 대조하고 실제 PostgreSQL 16에서 실행 검증했습니다.

```text
Chapter 07·08 기준 상태
→ security_lab 격리
→ 구조·샘플 데이터 생성
→ LOGIN·NOLOGIN Role 분리
→ PostgreSQL 16 membership 옵션 확인
→ 최소 권한 GRANT
→ 실제 허용·차단 SQL
→ 최소 권한 backup role로 custom archive 생성
→ archive 목록·해시 확인
→ 별도 DB 원자적 복원
→ 구조·데이터·소유권 자동 판정
→ 보호 대상 불변 확인
→ reset 격리·원자성 확인
```

점검 대상은 본문·구성안·워크북, Chapter 11 SQL 전체, 백업/복원 Runbook, 이미지 8쌍, 이론/실습 발표자료, 발표자 스크립트·내비게이션·TTS, 저장소 비밀정보 예제, 전용 GitHub Actions입니다.

---

## 1. Chapter 07·08 연속성 강화

Chapter 11은 다음 기준에서만 시작하도록 수정했습니다.

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
course_project.enrollments.recorded_amount = NUMERIC(12,0)
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 이력 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
uq_course_enrollments_active 존재
```

Chapter 11 SQL은 `course_project`를 변경하지 않습니다. 자동 검증은 실행 전후 전체 프로젝트 데이터를 정렬 JSON으로 직렬화한 fingerprint가 동일한지도 비교합니다.

`transaction_lab`과 `performance_lab`은 존재를 필수 전제로 하지 않으며 존재하더라도 Chapter 11에서 변경하지 않습니다.

---

## 2. 금액 열 의미·타입 통일

Chapter 11에 남아 있던 이전 금액 열 이름과 `INTEGER` 타입을 제거하고 앞 장과 동일하게 다음으로 통일했습니다.

```text
security_lab.enrollments.recorded_amount NUMERIC(12,0)
```

의미도 다음으로 고정했습니다.

```text
recorded_amount
→ 신청 시점에 신청 행에 기록한 금액
→ 결제 승인액이 아님
→ 환불 반영 순매출이 아님
→ 회계 매출이 아님
```

`security_lab` 기준 데이터는 다음과 같습니다.

```text
students / courses / enrollments = 3 / 3 / 3
JOIN = 3
상태 = 신청1 / 수강중1 / 완료1 / 취소0
recorded_amount 합계 = 310000
활성 신청 = 2
활성 중복 = 0
recorded_amount와 course.price 불일치 = 0
```

---

## 3. 구조 생성과 seed를 COMMIT 전 자동 판정

`01_security_lab_schema.sql`은 잘못된 DB·읽기 전용 연결·앞 장 기준 불일치·기존 `security_lab` 존재를 차단합니다.

구조 생성은 하나의 트랜잭션으로 처리하며 COMMIT 전에 다음을 판정합니다.

```text
테이블 = 3
명시 제약조건 = 13
NOT NULL = 14
recorded_amount = NUMERIC(12,0)
활성 부분 고유 인덱스 = unique / valid / ready
초기 행 수 = 0 / 0 / 0
```

`02_security_lab_seed.sql`도 하나의 트랜잭션에서 다음을 판정해야 COMMIT합니다.

```text
3 / 3 / 3 / JOIN 3
상태 1 / 1 / 1 / 0
총 recorded_amount 310000
활성 중복 0
금액-course.price 불일치 0
IDENTITY 다음 값 104 / 204 / 1004
```

---

## 4. Chapter 07 활성 신청 정책 유지

```sql
CREATE UNIQUE INDEX uq_security_enrollments_active
ON security_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

완료·취소 이력은 여러 건 허용하지만 진행 중 신청은 학생·강의 조합당 한 건으로 유지했습니다.

---

## 5. PostgreSQL 16 역할 모델 보완

권한 묶음과 실제 접속 주체를 분리했습니다.

```text
NOLOGIN
lab_role_security_owner
lab_role_report_reader
lab_role_enrollment_app
lab_role_backup_reader

LOGIN
lab_readonly_user
lab_enrollment_user
lab_backup_user
```

기존에는 백업 권한 역할만 있고 실제 백업 로그인 역할이 없어 이를 추가했습니다.

PostgreSQL 16의 membership은 다음을 구분합니다.

```text
pg_has_role(..., 'MEMBER')
→ membership 경로 존재

pg_has_role(..., 'USAGE')
→ 현재 설정에서 권한을 즉시 사용할 수 있음

pg_auth_members
→ inherit_option / set_option / admin_option
```

실습 membership은 `INHERIT TRUE`, `SET TRUE`, `ADMIN false`를 기준으로 실제 PostgreSQL 16에서 검증했습니다.

---

## 6. 앱·백업 시퀀스 권한을 목적별로 분리

앱 역할은 자동 ID 생성에 필요한 최소 권한만 받습니다.

```text
enrollments INSERT
status 컬럼 UPDATE
enrollments_id_seq USAGE
```

백업 역할은 쓰기 권한 없이 다음을 읽습니다.

```text
students / courses / enrollments SELECT
students_id_seq / courses_id_seq / enrollments_id_seq SELECT
```

앱에 sequence `SELECT`를 관성적으로 부여하지 않고, 백업 역할에는 IDENTITY 상태 보존이라는 별도 목적 때문에 `SELECT`를 부여하도록 구분했습니다.

---

## 7. PUBLIC 데이터베이스 권한 검사 오류 수정

실제 PostgreSQL 실행 중 중요한 오류를 발견했습니다.

`PUBLIC`은 일반 Role 이름이 아니라 모든 역할을 뜻하는 특수 그룹이므로 다음 형태로 검사할 수 없습니다.

```text
has_database_privilege('PUBLIC', ...)
```

최종 코드는 `pg_database.datacl`을 `aclexplode()`로 풀고 `grantee OID = 0`을 PUBLIC 경로로 판정합니다.

```text
has_*_privilege
→ 실제 Role의 최종 유효 권한

ACL + grantee OID 0
→ PUBLIC 권한 경로
```

테이블·컬럼 PUBLIC 권한은 `information_schema.table_privileges`와 `column_privileges`를 사용합니다.

---

## 8. 실제 허용·차단 권한 검증

자동 검증에서 다음 허용 동작이 실제로 성공했습니다.

```text
readonly
- 세 테이블 SELECT

app
- 세 테이블 SELECT
- ID 생략 enrollments INSERT
- status 컬럼 UPDATE
```

성공 테스트는 마지막에 `ROLLBACK`해 기준 행 데이터를 보존합니다.

다음 차단 동작은 자동 검증에서 실제 `permission denied`가 발생해야 성공으로 판정합니다.

```text
readonly
- INSERT
- UPDATE
- DELETE

app
- recorded_amount UPDATE
- DELETE
- security_lab 안의 CREATE TABLE
```

테스트 뒤 기준 데이터는 계속 `3 / 3 / 3`, 총 `310000`, 활성 중복 `0`입니다.

---

## 9. ROLLBACK과 IDENTITY 번호 공백 설명 보완

권한 테스트에서 ID를 생략한 INSERT가 성공하면 `nextval()`이 호출됩니다. 이후 트랜잭션을 `ROLLBACK`해도 사용된 시퀀스 번호는 회수되지 않을 수 있습니다.

따라서 복원 판정은 “다음 값이 정확히 1004인가?”가 아니라 다음 조건을 사용합니다.

```text
다음 IDENTITY 값 > 현재 최대 ID
```

---

## 10. PostgreSQL 16 IDENTITY 메타데이터 검증 오류 수정

실제 custom archive 복원 과정에서 두 번째 중요한 차이를 발견했습니다.

`security_lab`의 IDENTITY용 시퀀스 관계 세 개는 실제로 존재하고 정상 복원됐지만 해당 환경의 `information_schema.sequences` 결과만으로는 이를 신뢰성 있게 판정할 수 없었습니다.

최종 검증은 다음을 함께 사용합니다.

```text
pg_class(relkind='S') + pg_sequence
→ 실제 sequence relation 3개 확인

information_schema.columns
is_identity = YES
identity_generation = BY DEFAULT
→ IDENTITY id 컬럼 3개 확인
```

복원 후 다음 값도 현재 최대 ID보다 큰지 직접 확인합니다.

---

## 11. 비밀 정보와 저장소 보호

`.env.example`은 다음 변수 이름만 제공합니다.

```text
PGHOST=
PGPORT=
PGDATABASE=
PGUSER=
PGPASSFILE=
```

저장소 예제에서 실제 비밀번호 값을 제거하고 `PGPASSWORD` 값 저장을 권장하지 않습니다.

`.gitignore`에는 `.env`, backup/dump, password file 패턴이 포함되어 있는지 자동 검증합니다.

---

## 12. RLS 설명 수정

일반적인 전체 논리 백업에서는 `pg_dump`가 row security를 끄고 전체 행을 읽으려 하며, 백업 역할이 정책을 우회할 수 없으면 오류가 발생할 수 있다는 점을 반영했습니다.

```text
--enable-row-security
→ 역할에게 보이는 행만 의도적으로 dump할 때 검토
→ 운영 전체 백업과 같은 의미가 아님
```

`security_lab`은 RLS를 사용하지 않으며 자동 검증에서 세 테이블의 RLS/FORCE RLS가 모두 꺼져 있는지 확인합니다.

---

## 13. custom archive owner·ACL 설명 수정

custom format(`-Fc`) 백업에서 소유권을 제거하는 위치에 대한 설명을 바로잡았습니다.

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  --schema=security_lab \
  -f <backup-dir>/security_lab.backup
```

archive에는 원본 owner·ACL 메타데이터를 보존할 수 있습니다.

검증 복원에서 적용 여부를 제어합니다.

```bash
pg_restore \
  -U <restore_user> \
  -d ai_database_book_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  <backup-dir>/security_lab.backup
```

즉 custom archive의 owner 정보 보존과 복원 시 owner 적용 여부를 분리했습니다.

---

## 14. 최소 권한 backup role로 실제 pg_dump 성공

전용 Actions에서 관리자 역할로 데이터를 읽어 dump한 것이 아니라, 실제 백업 권한 역할을 상속한 `lab_backup_user`로 권한을 전환해 custom archive를 만들었습니다.

archive 생성 후 다음을 실제 검사했습니다.

```text
security_lab schema
3 tables
3 IDENTITY sequence relations
3 sequence set entries
uq_security_enrollments_active
ACL entries
SHA-256 계산
```

---

## 15. 별도 DB 원자적 복원 실제 성공

검증 DB는 다음 원칙으로 생성·복원했습니다.

```text
DB = ai_database_book_restore
owner = lab_restore_user
template = template0
```

복원은 작은 실습 전체를 하나의 트랜잭션으로 묶었습니다.

```text
--single-transaction
--no-owner
--no-privileges
```

복원 후 원본 `course_project`가 복원 DB에 섞여 들어오지 않았는지도 확인했습니다.

---

## 16. 06 복원 자동 판정 실제 성공

`06_restore_validation.sql`은 복원 DB에서 다음을 자동 판정합니다.

```text
DB = ai_database_book_restore
students / courses / enrollments = 3 / 3 / 3
JOIN = 3
상태 = 1 / 1 / 1 / 0
총 recorded_amount = 310000
recorded_amount = NUMERIC(12,0)
금액-course.price 불일치 = 0
고아 FK = 0
활성 중복 = 0
NOT NULL = 14
명시 제약조건 = 13
부분 고유 인덱스 unique / valid / ready
sequence relation = 3
IDENTITY id 컬럼 = 3
다음 자동값 > 현재 최대 ID
schema·table·sequence owner = lab_restore_user
```

성공 메시지:

```text
Chapter 11 restore structure and data validation passed
```

원본 `ai_database_book`에서 이 파일을 실행하면 중단되는 보호 경로도 실제 검증했습니다.

---

## 17. reset을 원자적으로 강화

`reset_security_lab.sql`은 `CASCADE`를 사용하지 않고 전체 reset을 하나의 트랜잭션으로 묶었습니다.

정상 상태:

```text
known tables 삭제
→ security_lab 삭제
→ course_project 유지
→ Role 유지
```

예상하지 못한 객체 `security_lab.keep_me`가 있을 때:

```text
DROP SCHEMA 실패
→ 앞에서 수행한 known table DROP도 전체 ROLLBACK
→ students/courses/enrollments/keep_me 모두 유지
```

이 경계 경로를 PostgreSQL 16에서 실제 검증한 뒤 `keep_me`를 명시적으로 제거하고 reset이 성공하는 것까지 확인했습니다.

---

## 18. 본문·워크북·발표자료·TTS 동기화

다음을 같은 기준으로 맞췄습니다.

```text
본문 28개 절
이론 발표 20개 절
실습 발표 20개 절
각 절 화면 구성 + 발표 스크립트
navigation 제목 일치
shared TTS normalization
script content enhancer
Markdown fetch cache=no-store
recorded_amount / PostgreSQL 16
Role·membership·backup·restore 용어
```

이미지 8개 Mermaid/SVG 쌍은 기존 일반 메시지와 호환되며, 정적 검증에서 XML·접근성 속성·본문 참조까지 확인했습니다.

---

## 19. 전용 자동 검증

신규 workflow:

```text
.github/workflows/validate-chapter11.yml
Workflow: Validate Chapter 11
```

최종 핵심 실행 검증:

```text
Run: 4
Run ID: 31289390315
Commit: 710dbfd2f6f05e89cb385bacbcf1cbf23f36f0ac
Status: completed
Conclusion: success
PostgreSQL: 16
```

Run 4에서 정적 정합성부터 실제 권한·백업·복원·reset 경계까지 모든 단계가 성공했습니다.

---

## 남은 수동 제작 검수

자동 검증으로 통과했다고 주장하지 않는 항목입니다.

```text
브라우저 이론 발표자료 최종 렌더링
브라우저 실습 발표자료 최종 렌더링
semantic highlight 전환 시각 확인
발표자 스크립트 창 ↔ 장표 실제 동기화
TTS 실제 청취·발음 확인
Mermaid CLI 재생성
GitHub SVG 최종 육안 확인
Word/PDF/eBook SVG 가독성
최종 편집 페이지 수 28~32페이지 확인
```

## 결론

```text
Chapter 11은 단순한 GRANT와 pg_dump 명령 소개가 아니라,
PostgreSQL 16에서 최소 권한의 실제 허용·차단 결과와
custom archive의 별도 DB 복원 가능성을 증명하는 운영 장으로 보완되었다.
```


---

## 2026-08-10 최종 출판 보완

- Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 11 시작 게이트에 추가
- `security_lab` 생성 전 현재 역할의 `ai_database_book` CREATE 권한 검사 추가
- `PGPASSWORD` 장기 사용을 피하고 `PGPASSFILE` 기반 password file 사용 원칙을 구체화
- Unix password file `chmod 0600` 및 Windows 보호 경로 차이를 명시
- 작성된 Chapter 11 발표 스크립트의 일반 자동 확장 비활성화
- PostgreSQL 16 실제 권한·백업·별도 DB 복원 경로를 재검증 대상으로 지정
