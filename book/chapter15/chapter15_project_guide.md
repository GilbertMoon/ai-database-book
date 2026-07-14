# Chapter 15 프로젝트 가이드

## 목적

이 가이드는 PostgreSQL 기반 데이터베이스 설계·검증·분석 프로젝트를 다른 사람이 다시 실행할 수 있는 형태로 정리하기 위한 안내입니다. SQL과 Python 분석은 필수이며, 웹 CRUD·API, NoSQL과 배포는 선택 확장입니다.

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
| `requirements.md` | 필수 | 확인 요구사항과 미확정 정책 |
| `erd.md` | 필수 | 관계, 테이블 역할, FK와 제약조건 |
| `OPERATIONS_RUNBOOK.md` | 필수 | 역할·비밀·백업·복원·RPO·RTO 계획 |
| `ai_review_report.md` | 필수 | AI 제안, diff, 실행 증거와 사람 승인 기록 |
| `analysis_report.md` | 필수 | 분석 질문, SQL·Python 결과, 해석과 한계 |
| `final_report.md` | 필수 | 최종 결과, 한계와 다음 버전 계획 |

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
→ Python 분석·검증
→ 10_completion_gate.sql
```

| 파일 | 역할 |
|---|---|
| `01_schema.sql` | `tutor_project` 스키마와 테이블·제약조건 생성 |
| `02_seed.sql` | 재현 가능한 기준 샘플 데이터 입력 |
| `03_metadata_validation.sql` | 테이블·PK·FK·IDENTITY·인덱스 확인 |
| `04_requirement_queries.sql` | 요구사항·경계 사례·정합성 조회 |
| `05_transaction_checks.sql` | 변경 시나리오와 ROLLBACK 검증 |
| `06_negative_tests.sql` | 실패해야 정상인 자동 반례 검증 |
| `07_performance_checks.sql` | 인덱스 존재와 대표 EXPLAIN 검토 |
| `08_operations_checks.sql` | 권한·비밀·백업·복구 계획 점검 |
| `09_analysis_dataset.sql` | 질문 1건 단위 분석 VIEW와 SQL 기준값 생성 |
| `10_completion_gate.sql` | DB 구조·기준 데이터·분석 VIEW 최종 판정 |

## Python 분석

```text
python/01_load_postgresql.py
→ 분석 VIEW를 DataFrame으로 읽기

python/02_pandas_analysis.py
→ 상태별·월별·학생별 집계

python/03_result_validation.py
→ SQL 기준값과 pandas 결과 비교
```

접속 정보는 `.env`로 관리하고 저장소에는 `.env.example`만 포함합니다. 분석 코드는 SELECT 중심의 읽기 전용 작업으로 구성합니다.

## 실행 방법

1. 운영 DB가 아닌 별도 개발·테스트 환경을 준비합니다.
2. 현재 데이터베이스와 계정을 확인합니다.
3. `01`부터 `09`까지 번호 순서대로 실행합니다.
4. 각 파일의 기대 결과와 실제 결과를 비교합니다.
5. Python으로 분석 VIEW를 읽고 SQL 기준값과 비교합니다.
6. `10_completion_gate.sql`로 프로젝트 상태를 판정합니다.
7. 실행 결과를 운영·AI·분석·최종 보고서에 기록합니다.

## 완료 기준

- 요구사항 ID가 ERD·DDL·검증 SQL과 연결된다.
- 행 수와 경계 사례가 기대 결과와 일치한다.
- FK 5개, IDENTITY PK 5개, 업무 인덱스 3개와 CASCADE 0개가 확인된다.
- 트랜잭션 ROLLBACK 후 기준 데이터가 복구된다.
- 자동 반례의 `unexpected` 결과가 0이다.
- 분석 VIEW가 5행이고 `question_id` 중복이 없다.
- `answer_count` 합계 5, `material_count` 합계 7이다.
- SQL과 pandas의 상태별·월별 핵심 집계가 일치한다.
- 운영·백업·복구 계획과 AI 변경 검토 결과가 기록되어 있다.
- `required_completion_gate_passed = true`이다.

완료 게이트가 `true`여도 실제 Role 권한 시험, 백업·복원 시험, 웹 API, NoSQL과 배포가 자동으로 완료된 것은 아닙니다.

## 선택 확장 기준

| 확장 | 진행 조건 |
|---|---|
| 웹 CRUD·API | DB 입력과 조회를 화면 또는 API로 검증할 필요가 있을 때 |
| NoSQL | 관계형 테이블 밖의 캐시, 문서, 이벤트 저장 요구가 있을 때 |
| 배포 | 다른 사람이 실제 환경에서 접근해 검증해야 할 때 |
