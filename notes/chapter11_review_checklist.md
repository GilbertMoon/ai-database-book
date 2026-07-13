# Chapter 11 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법
```

## 리뷰 목적

Chapter 11이 기존 프로젝트를 보호하면서 `security_lab`에서 최소 권한을 설계하고, 백업 파일을 별도 DB에 복원해 구조·데이터·제약조건·권한을 검증하도록 구성되었는지 점검합니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| course_project 보호 | 통과 | 조회 확인만 수행 |
| transaction_lab 보호 | 통과 | Chapter 11에서 변경 없음 |
| performance_lab 보호 | 통과 | Chapter 11에서 변경 없음 |
| security_lab 전용 | 통과 | 보안·복구 실습 격리 |
| 자동 DROP 제거 | 통과 | 생성 파일에서 삭제 없음 |
| 초기화 분리 | 통과 | reset_security_lab.sql만 사용 |
| Role 자동 삭제 방지 | 통과 | 클러스터 전역 객체 수동 검토 |

---

## 2. 스키마·데이터 정합성

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 3 | 코드 반영 |
| courses | 3 | 코드 반영 |
| enrollments | 3 | 코드 반영 |
| JOIN | 3 | 코드 반영 |
| 기본키 | IDENTITY | 통과 |
| 명시적 ID | 101/201/1001 체계 | 통과 |
| 재신청 복합 UNIQUE | 미적용 | 통과 |
| PK·FK·UNIQUE·CHECK | 적용 | 통과 |

---

## 3. 역할·권한 모델

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 인증·권한·소유권 구분 | 통과 | 표와 설명 반영 |
| LOGIN·NOLOGIN 구분 | 통과 | 로그인·권한·소유 역할 분리 |
| 최소 권한 작업 행렬 | 통과 | 보고·앱 역할 비교 |
| DB CONNECT | 통과 | 역할 계획에 포함 |
| schema USAGE | 통과 | CREATE와 구분 |
| 테이블 권한 | 통과 | 객체별 SELECT·INSERT |
| 컬럼 UPDATE | 통과 | enrollments.status만 허용 |
| IDENTITY 시퀀스 권한 | 통과 | USAGE·SELECT 검토 |
| DELETE·TRUNCATE 차단 | 통과 | 기본 미부여 |
| 위험 역할 속성 | 통과 | SUPERUSER·CREATEDB·CREATEROLE 미부여 |

---

## 4. 유효 권한 확인

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 역할 존재·속성 | 통과 | pg_roles 조회 |
| 역할 멤버십 | 통과 | pg_has_role 예시 |
| DB·스키마 권한 | 통과 | has_database/schema_privilege |
| 테이블 권한 | 통과 | has_table_privilege |
| 컬럼 권한 | 통과 | has_column_privilege |
| 시퀀스 권한 | 통과 | has_sequence_privilege |
| 명시적 ACL | 통과 | role_table/column_grants |
| PUBLIC 권한 | 통과 | 별도 조회 |
| 객체 owner | 통과 | pg_class 소유자 조회 |
| REVOKE 후 재검증 | 통과 | 다른 권한 경로 확인 |

---

## 5. 현재·미래 객체 권한

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 현재 테이블 GRANT | 통과 | 기존 객체 적용 |
| Default Privileges | 통과 | 미래 객체 적용 |
| FOR ROLE 의미 | 통과 | 객체 생성 역할 기준 |
| 기존 객체 자동 변경 오해 방지 | 통과 | 본문·SQL 반영 |

---

## 6. 비밀·입력 보호

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| .gitignore 추가 | 통과 | env·backup·dump 제외 |
| .env.example | 통과 | 변수명만 제공 |
| 실제 비밀번호 미포함 | 통과 | 역할 SQL에 PASSWORD 없음 |
| 자격 증명 회전 | 통과 | 삭제보다 우선 설명 |
| SQL 값 바인딩 | 통과 | SQL 구조와 값 분리 |
| 식별자 허용 목록 | 통과 | 테이블·컬럼·정렬 제한 |
| 최소 권한과 Injection | 통과 | 피해 범위 감소 설명 |
| 로그·백업 보호 | 통과 | 원본과 같은 민감도 적용 |

---

## 7. 백업·복원 정확성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| pg_dump DB 범위 | 통과 | 단일 DB 논리 백업 설명 |
| security_lab 스키마 백업 | 통과 | custom-format 예시 |
| 전체 DB 선택안 | 통과 | 별도 명령 제공 |
| 전역 역할 | 통과 | pg_dumpall globals 선택안 |
| owner·ACL | 통과 | no-owner·no-privileges 후 재적용 설명 |
| 파일 경로 | 통과 | 저장소 밖 보호 경로 |
| 아카이브 목록 | 통과 | pg_restore --list |
| 파일 해시 | 통과 | PowerShell·sha256sum |
| 별도 복원 DB | 통과 | 원본 덮어쓰기 방지 |
| 오류 중단 | 통과 | pg_restore exit-on-error·psql ON_ERROR_STOP |
| 신뢰할 수 없는 덤프 | 통과 | 검토 없이 복원 금지 |

---

## 8. 복원 검증

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| students | 3 | 코드 반영 |
| courses | 3 | 코드 반영 |
| enrollments | 3 | 코드 반영 |
| JOIN | 3 | 코드 반영 |
| 고아 student FK | 0행 | 코드 반영 |
| 고아 course FK | 0행 | 코드 반영 |
| PK·FK·UNIQUE·CHECK | 유지 | 코드 반영 |
| NOT NULL·타입 | 유지 | 코드 반영 |
| IDENTITY 시퀀스 | 3개 | 코드 반영 |
| owner·ACL 확인 | 조회 제공 | 통과 |
| 최종 boolean | 모두 true | 코드 반영 |

---

## 9. RPO·RTO·실행 기록

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| RPO·RTO 정의 | 통과 | 데이터 손실·복구 시간 기준 |
| 백업 주기 연결 | 통과 | RPO 충족 여부 검토 |
| 복원 시간 기록 | 통과 | RTO 측정 가능 |
| 파일 크기·해시 | 통과 | RUNBOOK 기록 |
| 오류·해결·재검증 | 통과 | 반복 개선 기록 |
| 다음 복원 시험 | 통과 | 날짜·담당자 인계 |

---

## 10. 단계별 파일

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_security_lab_schema.sql` | 전용 스키마 생성 | 통과 |
| `02_security_lab_seed.sql` | 정상 샘플 입력 | 통과 |
| `03_role_permission_plan.sql` | 안전한 역할·권한 계획 | 통과 |
| `04_permission_checks.sql` | 유효 권한 확인 | 통과 |
| `05_restore_validation.sql` | 복원 DB 검증 | 통과 |
| `BACKUP_RESTORE_RUNBOOK.md` | 백업·복원 실행 기록 | 통과 |
| `reset_security_lab.sql` | 실습 스키마만 초기화 | 통과 |
| `security_backup_check.sql` | 안전한 호환 진입점 | 통과 |
| `README.md` | 실행 순서·주의사항 | 통과 |

---

## 11. AI 명령 검토

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 대상 환경·범위 | 통과 | 테스트·스키마·DB 구분 |
| 과도한 권한 금지 | 통과 | SUPERUSER·ALL 금지 |
| 비밀번호 금지 | 통과 | 실제 값 미포함 |
| 유효 권한 검증 | 통과 | 적용 후 has_* 요구 |
| 백업 위치·형식 | 통과 | 저장소 밖·custom 검토 |
| owner·ACL | 통과 | 복원 후 처리 요구 |
| 별도 DB 복원 | 통과 | 원본 DB 직접 복원 금지 |
| 실패·정리 절차 | 통과 | 오류 중단·임시 DB 삭제 |

---

## 12. 도식

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 기존 SVG 8종 | 통과 | 일반 보안·복구 흐름과 호환 |
| 새 제목·스키마 기준 | 통과 | 이미지 README 갱신 |
| 권한 검증 분기 | 기존 확인 필요 | 실제 렌더링 수동 검수 |
| 접근성·XML | 기존 검증 유지 | 출판 변환 확인 필요 |

---

## 13. 남은 확인

```text
- 실제 PostgreSQL 테스트 DB에서 01→04 실행
- 선택 역할 생성·권한 허용·차단 결과 확인
- custom-format 백업·별도 DB 복원
- 05_restore_validation.sql 통과 확인
- Windows·Linux 터미널 명령 검증
- GitHub·Word·PDF·eBook 렌더링 확인
- 실제 운영 정책·법적 요구사항 별도 검토
```

---

## 14. 최종 판정

```text
Chapter 11은 기존 프로젝트를 보호하면서 최소 권한, 비밀 정보 보호와 실제 복원 검증을 하나의 운영 흐름으로 연결하도록 2차 재구성했다.
역할 변경과 백업·복원은 테스트 환경에서 수동 검증이 필요하다.
```
