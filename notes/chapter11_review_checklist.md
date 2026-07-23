# Chapter 11 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법
```

## 리뷰 목적

Chapter 11이 기존 프로젝트를 보호하면서 `security_lab`에서 최소 권한을 설계하고, 별도 데이터베이스에 백업을 원자적으로 복원해 구조·데이터·소유권·권한을 검증하도록 구성되었는지 점검합니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| course_project 보호 | 통과 | 생성 전 신청 5행 확인, 변경 없음 |
| transaction_lab 보호 | 통과 | Chapter 11에서 변경 없음 |
| performance_lab 보호 | 통과 | Chapter 11에서 변경 없음 |
| security_lab 전용 | 통과 | 보안·백업·복원 실습 격리 |
| 생성 파일 자동 DROP 없음 | 통과 | 보호 검사 후 새 구조만 생성 |
| 초기화 분리 | 통과 | reset 파일만 사용 |
| Role 자동 생성·삭제 없음 | 통과 | 클러스터 전역 영향 고려 |

---

## 2. 생성·초기화 실행 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 현재 DB 확인 | 통과 | `ai_database_book` 아니면 예외 |
| `SHOW search_path` | 통과 | 모든 SQL 형식 통일 |
| Chapter 07 기준 상태 | 통과 | `course_project.enrollments = 5` 검사 |
| security_lab 중복 생성 차단 | 통과 | 기존 스키마 존재 시 중단 |
| 구조 생성 원자성 | 통과 | 스키마·테이블을 한 트랜잭션에서 생성 |
| reset DB 보호 | 통과 | 잘못된 DB에서 DROP 중단 |
| 삭제 범위 | 통과 | security_lab만 자식→부모 순서 삭제 |

---

## 3. 스키마·데이터 정합성

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 3 | 코드 반영 |
| courses | 3 | 코드 반영 |
| enrollments | 3 | 코드 반영 |
| JOIN | 3 | 코드 반영 |
| 기본키 | IDENTITY | 통과 |
| 명시적 ID | 101/201/1001 체계 | 통과 |
| IDENTITY 다음 값 | 104/204/1004 이상 | 통과 |
| 이메일 공백 방지 | CHECK | 통과 |
| 정확 문자열 이메일 중복 | UNIQUE | 통과 |
| 활성 신청 중복 | 부분 고유 인덱스 | 통과 |
| 고아 관계 | FK로 차단 | 통과 |

---

## 4. Chapter 07 업무 규칙 연속성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 신청·수강중 활성 범위 | 통과 | 학생·강의 조합당 한 건 |
| 완료·취소 이력 | 통과 | 여러 건 허용 |
| 앞 장 확정 규칙 재미확정 방지 | 통과 | Chapter 07 정책 유지 명시 |

---

## 5. 역할·권한 모델

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 인증·권한·소유권 구분 | 통과 | 본문·워크북 표 반영 |
| LOGIN·NOLOGIN 구분 | 통과 | 로그인·권한·소유·백업 역할 분리 |
| 최소 권한 작업 행렬 | 통과 | 보고·앱 역할 비교 |
| DB CONNECT | 통과 | 직접 GRANT와 PUBLIC 경로 구분 |
| schema USAGE | 통과 | CREATE와 구분 |
| 테이블 SELECT·INSERT | 통과 | 객체별 권한 |
| 컬럼 UPDATE | 통과 | enrollments.status만 허용 |
| 시퀀스 권한 | 통과 | USAGE만 기본 부여 |
| DELETE·TRUNCATE 차단 | 통과 | 기본 미부여 |
| 위험 역할 속성 | 통과 | SUPERUSER·CREATEDB·CREATEROLE 금지 |

---

## 6. PUBLIC·ACL·유효 권한

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| PUBLIC 테이블 권한 | 통과 | `table_privileges` 사용 |
| PUBLIC 컬럼 권한 | 통과 | `column_privileges` 사용 |
| 잘못된 role_table_grants PUBLIC 조회 제거 | 통과 | 기술 오류 수정 |
| DB ACL | 통과 | `pg_database.datacl` 조회 |
| 스키마 ACL | 통과 | `pg_namespace.nspacl` 조회 |
| 테이블·시퀀스 ACL | 통과 | pg_class 조회 |
| 유효 권한 | 통과 | has_*_privilege 사용 |
| PUBLIC CONNECT 구분 | 통과 | true 결과의 부여 경로 별도 확인 |
| 객체 owner | 통과 | 소유권 경로 포함 |

---

## 7. 역할 멤버십과 상속

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 역할 멤버십 | 통과 | `pg_has_role(..., 'MEMBER')` |
| 즉시 사용 가능 권한 | 통과 | `pg_has_role(..., 'USAGE')` |
| 두 개념 구분 | 통과 | 멤버십과 권한 상속을 별도 설명 |

---

## 8. 실제 허용·차단 동작

| 테스트 | 기대 | 상태 |
| --- | --- | --- |
| 읽기 계정 SELECT | 성공 | 파일 반영 |
| 읽기 계정 INSERT | 실패 | 선택 테스트 반영 |
| 읽기 계정 UPDATE | 실패 | 선택 테스트 반영 |
| 읽기 계정 DELETE | 실패 | 선택 테스트 반영 |
| 앱 계정 SELECT | 성공 | 파일 반영 |
| 앱 계정 ID 생략 INSERT | 성공 | 파일 반영 |
| 앱 계정 status UPDATE | 성공 | 파일 반영 |
| 앱 계정 paid_amount UPDATE | 실패 | 선택 테스트 반영 |
| 앱 계정 DELETE | 실패 | 선택 테스트 반영 |
| 앱 계정 schema CREATE | 실패 | 선택 테스트 반영 |
| 성공 테스트 데이터 보존 | 통과 | 마지막 ROLLBACK |
| 실패 후 트랜잭션 복구 | 통과 | SAVEPOINT·ROLLBACK 안내 |

---

## 9. 현재·미래 객체 권한

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 현재 테이블 GRANT | 통과 | 기존 객체 적용 |
| Default Privileges | 통과 | 미래 객체 적용 |
| FOR ROLE 의미 | 통과 | 실제 객체 생성 역할 기준 |
| 기존 객체 자동 변경 오해 방지 | 통과 | 본문·SQL 반영 |

---

## 10. 소유 역할 정리

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 소유 역할 즉시 DROP 방지 | 통과 | 객체 소유 상태 설명 |
| REASSIGN OWNED | 통과 | 후속 owner 지정 필요 |
| DROP OWNED | 통과 | 권한·의존성 검토 |
| 데이터베이스별 확인 | 통과 | 클러스터 Role 범위 설명 |
| CASCADE 기본 사용 금지 | 통과 | 파괴적 영향 경고 |

---

## 11. 비밀·입력 보호

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| `.env.example` | 통과 | 실제 값 없음 |
| PGPASSWORD 제거 | 통과 | PGPASSFILE로 변경 |
| password file 저장소 밖 | 통과 | 본문·README 반영 |
| `.gitignore` | 통과 | env·backup·dump·password file 제외 |
| 실제 비밀번호 미포함 | 통과 | 역할 SQL에 PASSWORD 없음 |
| 자격 증명 회전 | 통과 | 파일 삭제보다 우선 |
| SQL 값 바인딩 | 통과 | 구조와 값 분리 |
| 식별자 허용 목록 | 통과 | 테이블·컬럼·정렬 제한 |
| 최소 권한과 Injection | 통과 | 피해 범위 감소 설명 |
| 로그·백업 보호 | 통과 | 원본과 같은 민감도 |

---

## 12. 백업 전 준비

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| pg_dump 버전 | 통과 | 실행 전 기록 |
| pg_restore·psql 버전 | 통과 | 실행 전 기록 |
| 원본·복원 서버 버전 | 통과 | 호환성 판정 기준 포함 |
| 오래된 pg_dump 중단 | 통과 | 서버 주요 버전 비교 |
| 백업 계정 CONNECT | 통과 | 최소 권한 표 포함 |
| 스키마 USAGE·테이블 SELECT | 통과 | 객체별 권한 |
| RLS 확인 | 통과 | 백업 결과 영향 설명 |
| 외부 FK | 통과 | 의존성 체크리스트 |
| 사용자 타입·함수·트리거 | 통과 | 의존성 체크리스트 |
| 확장·Large Object·외부 테이블 | 통과 | 의존성 체크리스트 |

---

## 13. 백업 범위·전역 객체

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| security_lab custom format | 통과 | 명령 제공 |
| 전체 DB 선택안 | 통과 | 별도 명령 제공 |
| owner·ACL 처리 | 통과 | 제외 후 재적용 설명 |
| 특정 스키마 의존성 한계 | 통과 | 외부 객체 자동 포함 오해 방지 |
| globals 범위 | 통과 | Role·Tablespace 등 전역 객체 |
| 역할 암호 제외 선택 | 통과 | `--no-role-passwords` 제공 |
| 저장소 밖 파일 경로 | 통과 | Runbook 기록 |

---

## 14. 복원 DB 생성과 원자성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 별도 DB | 통과 | 원본 복원 금지 |
| DB owner | 통과 | `-O <restore_user>` |
| template0 | 통과 | 깨끗한 복원 기준 |
| pg_restore 원자성 | 통과 | `--single-transaction` |
| plain SQL 원자성 | 통과 | `psql -X -1` |
| 오류 중단 | 통과 | `ON_ERROR_STOP=1` |
| 부분 복원 위험 | 통과 | 작은 실습 기준 설명 |
| 대규모 운영 예외 | 통과 | 긴 트랜잭션·자원 검토 |
| 신뢰할 수 없는 덤프 | 통과 | 검토 없이 복원 금지 |

---

## 15. 복원 검증 1단계

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 현재 DB | ai_database_book_restore | 보호 구문 반영 |
| students | 3 | 자동 판정 |
| courses | 3 | 자동 판정 |
| enrollments | 3 | 자동 판정 |
| JOIN | 3 | 자동 판정 |
| 고아 student FK | 0 | 자동 판정 |
| 고아 course FK | 0 | 자동 판정 |
| 활성 신청 중복 | 0 | 자동 판정 |
| 명시 제약조건 | 13 | 자동 판정 |
| 부분 고유 인덱스 | 존재 | 자동 판정 |
| IDENTITY 시퀀스 | 3 | 자동 판정 |
| 다음 자동값 | 최대 ID보다 큼 | 자동 판정 |
| schema·table·sequence owner | current restore user | 자동 판정 |
| 원본 DB 실행 차단 | 예외 | 코드 반영 |

---

## 16. 복원 검증 2단계

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 역할·GRANT 재적용 | 통과 | 별도 단계 |
| PUBLIC·ACL 재확인 | 통과 | 04 파일 |
| 멤버십·유효 권한 | 통과 | 04 파일 |
| 실제 허용·차단 DML | 통과 | 05 파일 |
| 구조 검증과 권한 검증 분리 | 통과 | owner·ACL 단계 혼동 방지 |

---

## 17. RPO·RTO·Runbook

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| RPO·RTO 정의 | 통과 | 손실 시점·복구 시간 기준 |
| 도구·서버 버전 | 통과 | Runbook 기록 |
| 백업 계정·RLS | 통과 | Runbook 기록 |
| 외부 의존성 | 통과 | Runbook 기록 |
| 종료 코드·경고 | 통과 | Runbook 기록 |
| 파일 크기·해시 | 통과 | Runbook 기록 |
| 복원 owner·template | 통과 | Runbook 기록 |
| 원자적 복원 | 통과 | Runbook 기록 |
| 오류·해결·재검증 | 통과 | 반복 개선 기록 |
| 다음 복원 시험 | 통과 | 날짜·담당자 인계 |

---

## 18. 단계별 파일

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_security_lab_schema.sql` | 보호 검사·원자적 구조 생성 | 완료 |
| `02_security_lab_seed.sql` | 샘플·IDENTITY·자동 판정 | 완료 |
| `03_role_permission_plan.sql` | 최소 권한·소유권·정리 계획 | 완료 |
| `04_permission_checks.sql` | PUBLIC·ACL·유효 권한 | 완료 |
| `05_permission_behavior_tests.sql` | 실제 허용·차단 동작 | 신규 완료 |
| `05_restore_validation.sql` | 호환 안내 | 완료 |
| `06_restore_validation.sql` | 복원 DB 전체 자동 판정 | 신규 완료 |
| `BACKUP_RESTORE_RUNBOOK.md` | 최종 복구 실행 기록 | 완료 |
| `reset_security_lab.sql` | DB 보호 초기화 | 완료 |
| `security_backup_check.sql` | 읽기 전용 진입점 | 완료 |
| `README.md` | 실행 순서·안전 기준 | 완료 |

---

## 19. 본문·워크북·구성안 동기화

| 점검 항목 | 상태 |
| --- | --- |
| 파일 번호와 실행 순서 | 통과 |
| PUBLIC 권한 뷰 | 통과 |
| MEMBER·USAGE | 통과 |
| 시퀀스 USAGE | 통과 |
| PGPASSFILE | 통과 |
| 버전·백업 계정·RLS·의존성 | 통과 |
| restore owner·template0 | 통과 |
| single transaction | 통과 |
| 복원 검증 2단계 | 통과 |
| 권장 해설 | 통과 |

기존 SVG 8종은 일반 보안·최소 권한·환경 분리·Injection·복원 흐름과 호환됩니다. SQL 명령 전체를 이미지에 중복하지 않는 원칙에 따라 변경하지 않았습니다.

---

## 20. 남은 실제 검증

```text
- PostgreSQL 관리자 테스트 환경에서 01→05 실행
- 읽기·앱 역할의 실제 허용·차단 결과 확인
- pg_dump·pg_restore·psql 버전 호환 확인
- custom-format 백업 생성
- template0 복원 DB 생성
- single-transaction 복원
- 06_restore_validation.sql 전체 통과
- 역할 재적용 후 04·05 통과
- Windows·Linux 명령 표현 확인
- GitHub·Word·PDF·eBook 렌더링 확인
- 실제 운영 정책·법적 요구사항 별도 검토
```

---

## 21. 최종 판정

```text
Chapter 11은 PUBLIC 권한 검증 오류, IDENTITY 상태, 복원 DB 보호,
복원 owner와 역할 불일치, 부분 복원 위험, 백업 계정·RLS·의존성,
password file과 소유 역할 정리를 최종 보완했다.

본문·워크북·SQL·Runbook이 같은 최소 권한과 2단계 복원 검증 기준을 사용하므로
최종 출판 전 내용 검수 완료 상태로 판정한다.
```
