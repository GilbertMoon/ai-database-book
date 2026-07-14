# Chapter 15 프로젝트 가이드

## 목적

이 가이드는 최종 프로젝트를 제출 가능한 형태로 정리하기 위한 안내입니다. 기본 목표는 PostgreSQL 기반 데이터베이스 설계와 검증입니다. 웹 CRUD, API, NoSQL, RAG와 배포는 선택 확장입니다.

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
| `final_report.md` | 필수 | 최종 결과, 한계와 다음 버전 계획 |

## 필수 SQL 실행 순서

```text
01_schema.sql
→ 02_seed.sql
→ 03_metadata_validation.sql
→ 04_requirement_queries.sql
→ 05_transaction_checks.sql
→ 06_negative_tests.sql
→ 07_performance_checks.sql
→ 08_operations_checks.sql
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
| `10_completion_gate.sql` | 필수 DB 구조와 기준 데이터의 읽기 전용 최종 판정 |

`09_optional_rag_extension.sql`은 학습 자료 의미 검색 요구사항이 있을 때만 실행합니다. `10_completion_gate.sql`은 선택 RAG 실행 여부와 관계없이 필수입니다.

## 초기화와 호환 파일

`reset_tutor_project.sql`은 처음부터 다시 시작할 때만 검토·선택 실행합니다. 필수 실행 순서나 자동 `DROP` 과정에 포함하지 않습니다.

다음 파일은 기존 링크 호환용 안전한 안내 파일이며, 번호가 붙은 실제 실행 파일을 대신하지 않습니다.

```text
schema.sql
seed.sql
queries.sql
```

## 실행 방법

1. 운영 DB가 아닌 별도 개발·테스트 환경을 준비합니다.
2. 현재 데이터베이스와 계정을 확인합니다.
3. `01`부터 `08`까지 번호 순서대로 실행합니다.
4. 각 파일의 기대 결과와 실제 결과를 비교합니다.
5. RAG 요구사항이 있을 때만 `09_optional_rag_extension.sql`을 실행합니다.
6. `10_completion_gate.sql`로 필수 프로젝트 상태를 판정합니다.
7. 실행 결과를 `OPERATIONS_RUNBOOK.md`, `ai_review_report.md`, `final_report.md`에 기록합니다.

## 완료 기준

- 요구사항 ID가 SQL 검증과 연결된다.
- ERD와 실제 DDL 메타데이터가 일치한다.
- 행 수와 경계 사례가 기대 결과와 일치한다.
- FK 5개, IDENTITY PK 5개, 업무 인덱스 3개와 CASCADE 0개가 확인된다.
- 트랜잭션 ROLLBACK 후 기준 데이터가 복구된다.
- 자동 반례가 실패해야 할 곳에서 실패하고 `unexpected` 결과가 0이다.
- `required_completion_gate_passed = true`이다.
- 운영·백업·복구 계획과 AI 변경 검토 결과가 기록되어 있다.

완료 게이트가 `true`여도 실제 Role 권한 시험, 백업·복원 시험, API·RAG·배포가 자동으로 완료된 것은 아닙니다. 미실행 항목은 통과로 기록하지 않습니다.

## 선택 확장 기준

| 확장 | 진행 조건 |
|---|---|
| 웹 CRUD/API | DB 입력과 조회를 화면 또는 API로 검증할 필요가 있을 때 |
| NoSQL | 관계형 테이블 밖의 캐시, 문서, 이벤트 저장 요구가 있을 때 |
| Vector DB/RAG | 학습 자료 의미 검색과 근거 기반 답변이 필요할 때 |
| 배포 | 다른 사람이 접근해 검증해야 할 때 |