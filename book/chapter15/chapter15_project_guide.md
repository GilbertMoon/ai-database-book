# Chapter 15 프로젝트 가이드

## 목적

이 가이드는 PostgreSQL 기반 데이터베이스 설계·검증·분석 프로젝트를 다른 사람이 **같은 순서와 같은 기준으로 다시 실행하고 결과를 검증할 수 있는 형태**로 정리하기 위한 안내입니다. SQL과 Python 분석은 필수이며, 웹 CRUD·API, NoSQL과 배포는 선택 확장입니다.

## 기준 예제

AI 튜터링 질문 관리 서비스

| 테이블 | 역할 |
|---|---|
| `students` | 질문 등록 학생 |
| `tutors` | 답변 작성 튜터 |
| `questions` | 질문과 상태 |
| `answers` | 튜터 답변 |
| `learning_materials` | 학습 자료 |
| `question_materials` | 질문과 자료 연결 |

## 프로젝트 문서

| 파일 | 필수 | 설명 |
|---|---|---|
| `README.md` | 필수 | 프로젝트 개요, 실행 순서와 기대 결과 |
| `requirements.md` | 필수 | 확정 요구사항과 미확정 정책 |
| `erd.md` | 필수 | 관계, 테이블 역할, FK와 제약조건 |
| `OPERATIONS_RUNBOOK.md` | 필수 | 역할·비밀·백업·복원·RPO·RTO 계획 |
| `ai_review_report.md` | 필수 | AI 제안, diff, 실행 증거와 사람 승인 기록 |
| `analysis_report.md` | 필수 | 분석 질문, SQL·Python 결과, 해석과 한계 |
| `final_report.md` | 필수 | 최종 결과, 한계와 다음 버전 계획 |

## P15 검증 단계

| 단계 | 역할 |
|---|---|
| `P15-V01` | 현재 DB와 기존 스키마를 확인하고 구조 생성 |
| `P15-V02` | 기준 Seed와 IDENTITY·시간 관계 검증 |
| `P15-V03` | 실제 PostgreSQL 메타데이터 검증 |
| `P15-V04` | 요구사항·관계·시간 정합성 검증 |
| `P15-V05` | 트랜잭션·반례·경계값 검증 |
| `P15-V06` | 인덱스·권한·보안·운영 준비 점검 |
| `P15-V07` | 고정 기간 분석 VIEW와 SQL 기준 결과 검증 |
| `P15-V08` | DB 구조·데이터·SQL 예외 기반 완료 게이트 |
| `P15-V09` | custom-format 백업을 별도 DB에 복원한 뒤 구조·데이터·owner 검증 |

## 필수 실행 순서

```text
01_schema.sql
→ 02_seed.sql
→ 03_metadata_validation.sql
→ 04_requirement_queries.sql
→ 05_transaction_checks.sql
→ 06_negative_tests.sql
→ 07_performance_checks.sql
→ 08_operations_checks.sql
→ 09_analysis_dataset.sql
→ 10_completion_gate.sql
→ Python 01 → 02 → 03
→ custom-format 백업
→ template0 기반 별도 DB 복원
→ 복원 DB에서 11_restore_validation.sql
→ Role 허용·차단 증거와 보고서·AI diff 사람 승인
```

`10_completion_gate.sql` 통과는 **DB 구조·기준 데이터·트랜잭션·반례·분석 VIEW가 기대 상태라는 뜻**입니다. Python 교차 검증, 실제 Role 허용·차단, 백업·복원과 문서 승인은 별도 증거로 확인합니다.

| 파일 | 역할 |
|---|---|
| `01_schema.sql` | `tutor_project` 스키마와 테이블·제약조건 생성 |
| `02_seed.sql` | 재현 가능한 기준 데이터 입력과 IDENTITY 조정 |
| `03_metadata_validation.sql` | 테이블·PK·FK·IDENTITY·인덱스의 실제 정의 확인 |
| `04_requirement_queries.sql` | 요구사항·경계 사례·업무·시간 정합성 조회 |
| `05_transaction_checks.sql` | 정상 변경·실패 경로와 ROLLBACK 검증 |
| `06_negative_tests.sql` | 실패해야 정상인 반례와 정상 경계값 자동 검증 |
| `07_performance_checks.sql` | 인덱스 후보·정의와 대표 EXPLAIN 검토 |
| `08_operations_checks.sql` | PUBLIC·직접 권한·소유권·민감정보·운영 준비 점검 |
| `09_analysis_dataset.sql` | 질문 1건 단위 분석 VIEW와 SQL 기준 결과 생성 |
| `10_completion_gate.sql` | DB 구조·기준 데이터·트랜잭션·분석 최종 예외 기반 판정 |
| `11_restore_validation.sql` | `tutor_project_restore`에서 복원 구조·데이터·owner·IDENTITY 판정 |

## Python 분석

```text
python/01_load_postgresql.py
→ 읽기 전용 PostgreSQL 스냅샷과 분석 VIEW 검증

python/02_pandas_analysis.py
→ 상태별·월별·학생별·튜터별·첫 답변 집계

python/03_result_validation.py
→ 같은 REPEATABLE READ, READ ONLY 스냅샷에서
  실제 SQL 결과와 pandas 결과 5종을 직접 비교
```

접속 정보는 `.env`로 관리하고 저장소에는 `.env.example`만 포함합니다. Python은 `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSFILE`을 사용하며 전체 접속 URL이나 실제 password file을 저장소에 기록하지 않습니다.

## 실행 방법

1. 운영 DB가 아닌 별도 개발·테스트 환경을 준비합니다.
2. 현재 데이터베이스와 계정을 확인합니다.
3. `01`부터 `10`까지 번호 순서대로 실행합니다.
4. 각 파일의 기대 결과와 실제 결과를 비교하고 `Chapter 15 database completion gate passed`를 확인합니다.
5. Python 01→03을 실행해 실제 SQL과 pandas의 상태·월·학생·튜터·첫 답변 결과가 일치하는지 확인합니다.
6. Runbook에 따라 custom-format 백업을 만들고 목록·해시를 기록합니다.
7. `template0` 기반의 별도 `tutor_project_restore` DB에 복원합니다.
8. 복원 DB에서 `11_restore_validation.sql`을 실행해 `Chapter 15 restore validation passed`를 확인합니다.
9. 관리자 테스트 환경에서 Role 허용·차단을 실제 동작으로 확인합니다.
10. 실행 증거를 운영·AI·분석·최종 보고서에 기록하고 사람이 최종 승인합니다.

## 완료 기준

- 요구사항 ID가 ERD·DDL·검증 SQL과 연결된다.
- base table 6개, 분석 VIEW 4개, IDENTITY sequence 5개가 확인된다.
- 제약조건 36개, FK 5개, 업무 인덱스 3개, CASCADE FK 0개가 확인된다.
- 행 수가 `4 / 3 / 5 / 5 / 6 / 7`이고 IDENTITY 다음 값이 최대 ID보다 크다.
- 질문 없는 학생 1명, 연결되지 않은 자료 1건, 답변 없는 open 질문 1건, 답변 2개 질문 1건이 재현된다.
- 업무·관계·시간 정합성 이상이 0건이다.
- 트랜잭션 ROLLBACK 후 기준 데이터가 복구된다.
- 반례·경계값 23/23이 기대 SQLSTATE·constraint name과 일치하고 `unexpected`가 0이다.
- 분석 VIEW가 질문 5행·학생 4행·튜터 3행이고 질문 ID 중복이 없다.
- `answer_count` 합계 5, `material_count` 합계 7, 첫 답변 4건·평균 2시간·음수 0이 확인된다.
- `10_completion_gate.sql`이 예외 없이 통과한다.
- Python의 SQL·pandas 5종 직접 비교가 모두 통과한다.
- Role 시험에서 허용 작업은 성공하고 금지 작업은 실제로 실패한다.
- custom-format 백업이 별도 DB에 복원되고 `11_restore_validation.sql`이 통과한다.
- 문서·AI diff의 미실행 항목과 한계가 사람 검토로 승인된다.

어느 한 단계가 통과했다고 전체 프로젝트가 자동 완료되는 것은 아닙니다. **DB 완료, Python 교차 검증, Role 시험, 백업·복원, 문서·AI 승인**을 각각 별도 증거로 남깁니다.

## 선택 확장 기준

| 확장 | 진행 조건 |
|---|---|
| 웹 CRUD·API | DB 입력과 조회를 화면 또는 API로 검증할 필요가 있을 때 |
| NoSQL | 관계형 테이블 밖의 캐시, 문서, 이벤트 저장 요구가 있을 때 |
| 배포 | 다른 사람이 실제 환경에서 접근해 검증해야 할 때 |
