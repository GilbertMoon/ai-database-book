# Chapter 11 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법
```

## 자동 검증 기준

```text
Workflow: Validate Chapter 11
Run: 4
Run ID: 31289390315
Commit: 710dbfd2f6f05e89cb385bacbcf1cbf23f36f0ac
Conclusion: success
PostgreSQL: 16
```

---

## 1. Chapter 07·08 연속성과 격리

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| `course_project` 행 수 | 통과 | 3 / 2 / 3 / 5 |
| 상태 분포 | 통과 | 신청2 / 수강중1 / 완료1 / 취소1 |
| `recorded_amount` 타입 | 통과 | `NUMERIC(12,0)` |
| 전체 기록 금액 | 통과 | 590000 |
| 활성 신청 | 통과 | 3건 / 340000 |
| 취소 제외 이력 | 통과 | 4건 / 440000 |
| 1001·1004·1005 | 통과 | 상태·금액 일치 |
| 활성 부분 고유 인덱스 | 통과 | 존재 |
| Chapter 11에서 project 변경 없음 | 통과 | 전후 fingerprint 동일 |
| `transaction_lab`·`performance_lab` | 통과 | 존재를 필수 전제로 하지 않고 변경 없음 |

---

## 2. `security_lab` 구조·데이터

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 3 | 실제 PostgreSQL 통과 |
| courses | 3 | 실제 PostgreSQL 통과 |
| enrollments | 3 | 실제 PostgreSQL 통과 |
| JOIN | 3 | 실제 PostgreSQL 통과 |
| 상태 | 1 / 1 / 1 / 0 | 실제 PostgreSQL 통과 |
| 총 recorded_amount | 310000 | 실제 PostgreSQL 통과 |
| recorded_amount | `NUMERIC(12,0)` | 실제 PostgreSQL 통과 |
| 활성 신청 | 2 | 실제 PostgreSQL 통과 |
| 활성 중복 | 0 | 실제 PostgreSQL 통과 |
| 금액-course.price 불일치 | 0 | 실제 PostgreSQL 통과 |
| 명시 제약조건 | 13 | 실제 PostgreSQL 통과 |
| NOT NULL | 14 | 실제 PostgreSQL 통과 |
| 부분 고유 인덱스 | unique / valid / ready | 실제 PostgreSQL 통과 |

---

## 3. 생성·초기화 안전성

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 잘못된 DB에서 01 차단 | 통과 | PostgreSQL 오류 경로 확인 |
| 읽기 전용 연결 보호 | 통과 | 코드 반영 |
| 기존 `security_lab` 차단 | 통과 | 코드 반영 |
| 01 구조 생성 transaction | 통과 | COMMIT 전 구조 판정 |
| 02 seed transaction | 통과 | COMMIT 전 데이터 판정 |
| reset DB 보호 | 통과 | `ai_database_book`만 허용 |
| reset `CASCADE` 미사용 | 통과 | 정적 검사 |
| 예상 밖 객체 존재 시 reset 실패 | 통과 | `keep_me` 경계 실검증 |
| 실패한 reset 전체 ROLLBACK | 통과 | known tables와 keep_me 모두 유지 |
| 정상 reset | 통과 | security_lab만 삭제 |
| Role 자동 삭제 없음 | 통과 | 7개 Role 유지 |

---

## 4. PostgreSQL 16 Role 모델

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 소유 역할 | 통과 | `lab_role_security_owner NOLOGIN` |
| 보고 권한 역할 | 통과 | `lab_role_report_reader NOLOGIN` |
| 앱 권한 역할 | 통과 | `lab_role_enrollment_app NOLOGIN` |
| 백업 권한 역할 | 통과 | `lab_role_backup_reader NOLOGIN` |
| 읽기 로그인 역할 | 통과 | `lab_readonly_user LOGIN` |
| 앱 로그인 역할 | 통과 | `lab_enrollment_user LOGIN` |
| 백업 로그인 역할 | 통과 | `lab_backup_user LOGIN` |
| 위험 속성 없음 | 통과 | SUPERUSER/CREATEDB/CREATEROLE false |

---

## 5. PostgreSQL 16 membership

| membership | MEMBER | USAGE | inherit | set | admin | 상태 |
| --- | --- | --- | --- | --- | --- | --- |
| report → readonly | true | true | true | true | false | 통과 |
| app → enrollment | true | true | true | true | false | 통과 |
| backup → backup_user | true | true | true | true | false | 통과 |

`pg_has_role(..., 'MEMBER')`, `pg_has_role(..., 'USAGE')`, `pg_auth_members`를 실제 PostgreSQL 16에서 함께 검증했습니다.

---

## 6. 최소 권한 유효 결과

| 작업 | readonly | app | backup | 상태 |
| --- | --- | --- | --- | --- |
| 세 테이블 SELECT | 허용 | 허용 | 허용 | 통과 |
| enrollments INSERT | 불허 | 허용 | 불허 | 통과 |
| status UPDATE | 불허 | 허용 | 불허 | 통과 |
| recorded_amount UPDATE | 불허 | 불허 | 불허 | 통과 |
| enrollments DELETE | 불허 | 불허 | 불허 | 통과 |
| schema CREATE | 불허 | 불허 | 불허 | 통과 |
| enrollment sequence USAGE | 불필요 | 허용 | 불필요 | 통과 |
| 세 IDENTITY sequence SELECT | 불허 | 불허 | 허용 | 통과 |

앱의 sequence `USAGE`와 백업의 sequence `SELECT` 목적을 분리했습니다.

---

## 7. 실제 허용·차단 SQL

| 테스트 | 기대 | 실검증 |
| --- | --- | --- |
| readonly SELECT | 성공 | 통과 |
| readonly INSERT | permission denied | 통과 |
| readonly UPDATE | permission denied | 통과 |
| readonly DELETE | permission denied | 통과 |
| app SELECT | 성공 | 통과 |
| app ID 생략 INSERT | 성공 | 통과 |
| app status UPDATE | 성공 | 통과 |
| app recorded_amount UPDATE | permission denied | 통과 |
| app DELETE | permission denied | 통과 |
| app schema CREATE | permission denied | 통과 |
| 성공 테스트 ROLLBACK 후 데이터 | 3 / 3 / 3 / 310000 | 통과 |

---

## 8. PUBLIC·ACL·소유권

| 점검 항목 | 상태 | 최종 방식 |
| --- | --- | --- |
| PUBLIC DB CONNECT | 통과 | `pg_database.datacl` + `aclexplode()` |
| PUBLIC 식별 | 통과 | grantee OID 0 |
| PUBLIC 테이블 권한 | 통과 | `table_privileges` |
| PUBLIC 컬럼 권한 | 통과 | `column_privileges` |
| 직접 테이블/컬럼 GRANT | 통과 | role grant 뷰 |
| 스키마 ACL | 통과 | `pg_namespace.nspacl` |
| 객체 owner | 통과 | `pg_class.relowner` |
| 유효 권한 | 통과 | `has_*_privilege` |

`PUBLIC`을 일반 Role 이름처럼 privilege 함수에 전달하던 오류를 실제 PostgreSQL 실행에서 발견해 수정했습니다.

---

## 9. IDENTITY·시퀀스 검증

| 점검 항목 | 상태 | 실제 방식 |
| --- | --- | --- |
| IDENTITY id 컬럼 | 3개 | `information_schema.columns` |
| sequence relation | 3개 | `pg_class(relkind='S')` |
| sequence 메타데이터 | 통과 | `pg_sequence` |
| 다음 자동값 | max(id)보다 큼 | 실제 복원 DB 통과 |
| ROLLBACK 번호 공백 허용 | 통과 | 연속 번호를 오류로 보지 않음 |

PostgreSQL 16 실복원에서 IDENTITY 시퀀스 존재 판정을 `information_schema.sequences` 하나에 의존할 수 없음을 확인해 시스템 카탈로그 방식으로 보완했습니다.

---

## 10. RLS·비밀·Injection

| 점검 항목 | 상태 |
| --- | --- |
| security_lab RLS false | 통과 |
| FORCE RLS false | 통과 |
| `--enable-row-security`와 전체 백업 구분 | 통과 |
| `.env.example` 실제 값 없음 | 통과 |
| `PGPASSFILE` 사용 예시 | 통과 |
| 백업/dump/password file ignore | 통과 |
| 실제 비밀번호 SQL 미포함 | 통과 |
| 자격 증명 회전 우선 설명 | 통과 |
| 값 parameter binding | 통과 |
| 동적 식별자 allowlist | 통과 |

---

## 11. custom archive 백업

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 최소권한 backup login 사용 | 통과 | `lab_backup_user` 권한으로 dump |
| custom format | 통과 | `-Fc` |
| security_lab 범위 | 통과 | `--schema=security_lab` |
| archive 파일 생성 | 통과 | non-empty |
| schema 항목 | 통과 | list 확인 |
| 테이블 3개 | 통과 | list 확인 |
| sequence 3개 | 통과 | list 확인 |
| sequence set 3개 | 통과 | list 확인 |
| 부분 고유 인덱스 | 통과 | list 확인 |
| ACL 항목 | 통과 | list 확인 |
| SHA-256 | 통과 | 실제 계산 |

custom archive의 owner 메타데이터와 `pg_restore --no-owner`의 적용 제어를 구분했습니다.

---

## 12. 별도 DB 복원

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 원본 DB 복원 금지 | 통과 | 별도 DB 사용 |
| restore DB | 통과 | `ai_database_book_restore` |
| restore owner | 통과 | `lab_restore_user` |
| template0 | 통과 | 사용 |
| `--single-transaction` | 통과 | 실제 복원 |
| `--no-owner` | 통과 | 실제 복원 |
| `--no-privileges` | 통과 | 실제 복원 |
| `course_project` 미복원 | 통과 | 복원 DB에서 미존재 확인 |
| 잘못된 DB에서 06 차단 | 통과 | 실제 오류 경로 확인 |

---

## 13. 복원 검증 1단계

| 검증 | 기대 | 실검증 |
| --- | ---: | --- |
| 3 / 3 / 3 / JOIN | 3 / 3 / 3 / 3 | 통과 |
| status | 1 / 1 / 1 / 0 | 통과 |
| total recorded_amount | 310000 | 통과 |
| recorded_amount 타입 | NUMERIC(12,0) | 통과 |
| amount-course mismatch | 0 | 통과 |
| orphan student/course | 0 / 0 | 통과 |
| active duplicate | 0 | 통과 |
| NOT NULL | 14 | 통과 |
| named constraints | 13 | 통과 |
| active index | unique/valid/ready | 통과 |
| sequence relations | 3 | 통과 |
| identity columns | 3 | 통과 |
| next id | max보다 큼 | 통과 |
| schema/table/sequence owner | restore user | 통과 |

성공 메시지 `Chapter 11 restore structure and data validation passed`를 실제 확인했습니다.

---

## 14. 정적 출판 자료 동기화

| 대상 | 상태 |
| --- | --- |
| 본문 번호 절 28개 | 통과 |
| 구성안 | 통과 |
| 워크북 | 통과 |
| 코드 README | 통과 |
| Backup/Restore Runbook | 통과 |
| 이론 발표 20개 절 | 통과 |
| 실습 발표 20개 절 | 통과 |
| 각 발표 절 화면+스크립트 | 통과 |
| navigation 제목 | 통과 |
| JavaScript 문법 | 통과 |
| shared TTS normalization | 통과 |
| script content enhancer | 통과 |
| Markdown cache=no-store | 통과 |
| Mermaid/SVG 8쌍 | 통과 |
| SVG role/viewBox/title/desc | 통과 |

---

## 15. 남은 수동 검수

```text
[ ] 브라우저 이론 발표자료 최종 렌더링
[ ] 브라우저 실습 발표자료 최종 렌더링
[ ] semantic highlight 실제 전환 확인
[ ] 발표자 스크립트 창 ↔ 장표 동기화 조작
[ ] TTS 실제 청취·발음 확인
[ ] Mermaid CLI 재생성
[ ] GitHub SVG 육안 확인
[ ] Word/PDF/eBook SVG 가독성
[ ] 최종 편집 페이지 수 28~32페이지 확인
```

---

## 최종 판정

```text
Chapter 11의 본문·코드·워크북·발표자료·백업/복원 Runbook은
PostgreSQL 16의 실제 권한·custom archive·별도 DB 복원 검증과 일치한다.
자동화 가능한 핵심 기술 검증은 완료되었고,
남은 항목은 브라우저·TTS·출판 렌더링 중심의 수동 제작 검수다.
```
