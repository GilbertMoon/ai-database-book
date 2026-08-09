# Chapter 11 자동 검증 결과

## 최종 핵심 실행

```text
Workflow: Validate Chapter 11
Run: 4
Run ID: 31289390315
Commit: 710dbfd2f6f05e89cb385bacbcf1cbf23f36f0ac
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

## 검증 범위

Chapter 11의 본문·구성안·워크북·SQL·백업/복원 Runbook·이미지·이론/실습 발표자료·스크립트/TTS와 실제 PostgreSQL 16 권한·백업·복원 경로를 함께 검증했습니다.

```text
Chapter 07·08 기준 생성
→ course_project fingerprint 저장
→ security_lab 01→02
→ 7개 실습 Role 생성
→ PostgreSQL 16 membership 적용
→ 최소 권한 GRANT
→ 유효 권한 판정
→ 허용 SQL 실제 실행
→ 차단 SQL 실제 permission denied 확인
→ 최소 권한 backup role로 custom archive 생성
→ archive 목록·SHA-256 확인
→ 별도 DB 원자적 복원
→ 06 구조·데이터·소유권 자동 검증
→ 원본 project fingerprint 재확인
→ reset 원자성·격리 검증
```

---

## 1. 정적 정합성

다음 항목을 자동 검사했습니다.

```text
- Chapter 11 본문 번호 절 = 28개
- 이론 발표 = 20개 절
- 실습 발표 = 20개 절
- 모든 발표 절에 화면 구성·발표 스크립트 존재
- navigation 제목 일치
- recorded_amount / NUMERIC(12,0) 통일
- PostgreSQL 16 기준 명시
- JavaScript 문법
- shared TTS normalization 사용
- script_content_enhancer 연결
- Markdown source cache=no-store
- .env.example에 실제 비밀번호 값 없음
- PGPASSFILE 예시 사용
- .gitignore에 env/backup/dump/password file 패턴 존재
- custom archive pg_dump 단계에서 owner 제거를 잘못 설명하지 않음
- pg_restore 단계에 --single-transaction / --no-owner / --no-privileges 존재
- Mermaid 8개 / SVG 8개 쌍
- SVG role=img / width=100% / viewBox / title / desc
- Chapter 11 SQL이 course_project·transaction_lab·performance_lab을 변경하지 않음
```

---

## 2. Chapter 07·08 시작 기준

실제 PostgreSQL 16에서 Chapter 07의 기준 상태를 다시 만들고 Chapter 08 검증을 실행했습니다.

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
recorded_amount = NUMERIC(12,0)
전체 = 590000
활성 = 3 / 340000
취소 제외 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

Chapter 11 실행 전 `course_project` 전체 fingerprint를 저장하고, 권한·백업·복원 실습 후와 reset 후 동일한지 비교했습니다. 모두 일치했습니다.

---

## 3. 01 스키마 생성

실제 PostgreSQL 16에서 다음을 확인했습니다.

```text
현재 DB = ai_database_book
잘못된 DB 실행 차단
security_lab 사전 미존재
3 tables
13 named constraints
14 NOT NULL columns
recorded_amount NUMERIC(12,0)
uq_security_enrollments_active unique / valid / ready
초기 rows = 0 / 0 / 0
```

성공 메시지:

```text
Chapter 11 security lab schema validation passed
```

---

## 4. 02 샘플 데이터

실제 결과:

```text
students / courses / enrollments = 3 / 3 / 3
JOIN = 3
상태 = 신청1 / 수강중1 / 완료1 / 취소0
총 recorded_amount = 310000
활성 신청 = 2
활성 중복 = 0
recorded_amount-course.price 불일치 = 0

1001 = 101 / 201 / 수강중 / 100000
1002 = 102 / 202 / 신청 / 120000
1003 = 103 / 203 / 완료 / 90000

seed 직후 IDENTITY 다음 값
students = 104
courses = 204
enrollments = 1004
```

성공 메시지:

```text
Chapter 11 security lab seed validation passed
```

---

## 5. PostgreSQL 16 Role·membership

실제 생성 Role:

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_role_backup_reader NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
lab_backup_user LOGIN
```

다음 세 membership은 실제 PostgreSQL 16에서 생성·검증했습니다.

```text
report_reader → readonly_user
app role → enrollment_user
backup_reader → backup_user

MEMBER = true
USAGE = true
inherit_option = true
set_option = true
admin_option = false
```

실습 Role에 SUPERUSER·CREATEDB·CREATEROLE이 없는 것도 확인했습니다.

---

## 6. PUBLIC ACL 실제 오류 발견·수정

첫 실행에서 `PUBLIC`을 일반 Role 이름처럼 privilege 함수에 전달하던 문제가 실제 오류로 확인됐습니다.

최종 방식:

```text
pg_database.datacl
→ aclexplode()
→ grantee OID 0 = PUBLIC
```

테이블·컬럼 PUBLIC 권한은 `table_privileges`, `column_privileges`를 사용합니다.

수정 후 유효 권한 검증 단계가 실제 PostgreSQL 16에서 통과했습니다.

---

## 7. 최소 권한 실제 결과

### 읽기 로그인 역할

```text
SELECT = 허용
INSERT = 불허
UPDATE = 불허
DELETE = 불허
```

### 앱 로그인 역할

```text
SELECT = 허용
INSERT = 허용
테이블 전체 UPDATE = 불허
status 컬럼 UPDATE = 허용
recorded_amount UPDATE = 불허
DELETE = 불허
enrollments_id_seq USAGE = 허용
sequence SELECT = 불허
schema CREATE = 불허
```

### 백업 로그인 역할

```text
세 테이블 SELECT = 허용
세 IDENTITY sequence SELECT = 허용
INSERT = 불허
쓰기 권한 = 미부여
schema CREATE = 불허
```

---

## 8. 허용·차단 SQL 실제 실행

허용 동작은 실제로 성공했습니다.

```text
readonly SELECT
app SELECT
app ID 생략 INSERT
app status UPDATE
```

성공 테스트는 마지막에 ROLLBACK했고 기준 데이터가 유지됐습니다.

```text
3 / 3 / 3
총 recorded_amount = 310000
활성 중복 = 0
```

다음 동작은 자동 검증에서 실제 오류가 발생해야 성공으로 판정했습니다.

```text
readonly INSERT → permission denied
readonly UPDATE → permission denied
readonly DELETE → permission denied
app recorded_amount UPDATE → permission denied
app DELETE → permission denied
app security_lab CREATE TABLE → permission denied
```

성공 메시지:

```text
Chapter 11 permission behavior baseline preserved
```

---

## 9. 최소 권한 custom archive

`lab_backup_user`가 상속한 최소 권한으로 실제 custom archive를 생성했습니다.

```text
format = custom (-Fc)
scope = security_lab
archive file = non-empty
```

`pg_restore --list`에서 실제 확인:

```text
security_lab schema
students / courses / enrollments
students_id_seq / courses_id_seq / enrollments_id_seq
3 sequence set entries
uq_security_enrollments_active
ACL entries
```

SHA-256도 실제 계산했습니다.

---

## 10. 별도 DB 원자적 복원

복원 테스트 DB:

```text
DB = ai_database_book_restore
owner = lab_restore_user
template = template0
```

실제 복원 옵션:

```text
--single-transaction
--no-owner
--no-privileges
```

복원은 성공했고 `course_project`가 복원 DB에 섞여 들어오지 않은 것도 확인했습니다.

---

## 11. PostgreSQL 16 IDENTITY 메타데이터 실제 차이

실복원에서 IDENTITY 시퀀스 관계는 정상 존재하고 sequence set도 복원됐지만, 해당 환경에서 `information_schema.sequences`만으로 IDENTITY 내부 시퀀스 존재를 안정적으로 판정할 수 없었습니다.

최종 검증은 다음으로 강화했습니다.

```text
pg_class(relkind='S') + pg_sequence
→ 실제 sequence relation 3개

information_schema.columns
is_identity = YES
identity_generation = BY DEFAULT
→ IDENTITY id 컬럼 3개
```

권한 동작 테스트의 `nextval()` 호출 때문에 enrollments 시퀀스가 증가할 수 있으므로 다음 자동값은 정확한 연속 번호가 아니라 `max(id)`보다 큰지 판정합니다.

---

## 12. 06 복원 구조·데이터·소유권 자동 검증

실제 통과한 조건:

```text
DB = ai_database_book_restore
3 / 3 / 3 / JOIN 3
status = 1 / 1 / 1 / 0
total recorded_amount = 310000
recorded_amount NUMERIC(12,0)
amount-course.price mismatch = 0
orphan FK = 0
active duplicate = 0
NOT NULL = 14
named constraints = 13
active partial unique index = unique / valid / ready
sequence relations = 3
IDENTITY columns = 3
next identity value > max(id)
schema/table/sequence owner = lab_restore_user
```

성공 메시지:

```text
Chapter 11 restore structure and data validation passed
```

원본 `ai_database_book`에서 06을 실행하면 차단되는 경로도 실제 확인했습니다.

---

## 13. reset 격리·원자성

예상하지 못한 객체를 실제 생성했습니다.

```text
security_lab.keep_me
```

그 상태에서 `reset_security_lab.sql`을 실행한 결과:

```text
DROP SCHEMA 실패
students 유지
courses 유지
enrollments 유지
keep_me 유지
```

즉 앞에서 실행된 known table DROP도 함께 ROLLBACK됐습니다.

`keep_me`를 명시적으로 제거한 뒤 reset을 다시 실행하면 성공했고 `security_lab`만 사라졌습니다.

성공 메시지:

```text
Chapter 11 security lab reset passed
```

`course_project` fingerprint는 reset 후에도 동일했고 실습 Role 7개는 자동 삭제되지 않았습니다.

---

## 14. 최종 핵심 판정

```text
Validate Chapter 11 / Run 4
Run ID 31289390315
Commit 710dbfd2f6f05e89cb385bacbcf1cbf23f36f0ac
completed / success
```

자동화 가능한 Chapter 11 핵심 기술 검증은 모두 통과했습니다.

---

## 15. 자동 검증으로 주장하지 않는 수동 항목

```text
브라우저 이론 발표자료 최종 렌더링
브라우저 실습 발표자료 최종 렌더링
semantic highlight 실제 전환
발표자 스크립트 창 ↔ 장표 실제 동기화
TTS 실제 청취·발음
Mermaid CLI 재생성
GitHub SVG 최종 육안 확인
Word/PDF/eBook SVG 가독성
최종 편집 페이지 수 28~32페이지
```
