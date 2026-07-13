# Chapter 15 구성안

## 제목

실전 프로젝트 2: 재현 가능한 AI 데이터베이스 서비스 완성하기

## 권장 분량

30~36페이지

## 이 장의 역할

Chapter 15는 책 전체의 개념을 `tutor_project` 예제로 통합하고, 다른 사람이 같은 순서로 실행해 같은 결과를 확인할 수 있는 최종 프로젝트를 완성하는 장이다.

```text
문제·범위
→ 요구사항·미확정 정책
→ ERD·DDL
→ 기준 데이터
→ 메타데이터·업무 조회
→ 트랜잭션·반례
→ 인덱스·운영·복구
→ AI diff 검토
→ 선택 RAG 확장
→ 완료 게이트
```

## 핵심 질문

```text
필수 범위와 선택 확장이 구분되어 있는가?
요구사항 ID가 ERD·DDL·검증 SQL과 연결되는가?
전용 스키마와 명시적 ID로 재현할 수 있는가?
정상·경계·반례·트랜잭션을 모두 검증하는가?
실제 메타데이터와 업무 정합성이 기대와 일치하는가?
인덱스가 실제 조회 패턴을 근거로 하는가?
비밀·권한·백업·복원 계획이 있는가?
AI 변경을 diff와 실행 증거로 검토하는가?
RAG 확장에서 원본과 벡터 파생 데이터를 구분하는가?
미실행 항목과 다음 버전을 명시하는가?
```

## 실습 스키마

```text
tutor_project.students
tutor_project.tutors
tutor_project.questions
tutor_project.answers
tutor_project.learning_materials
tutor_project.question_materials
```

보호 대상:

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
rag_lab
public
```

## 기준 데이터

```text
students 4
tutors 3
questions 5
answers 5
learning_materials 6
question_materials 7
FK 5
업무 인덱스 3
CASCADE 0
```

명시적 ID:

```text
students 101~104
tutors 201~203
questions 301~305
answers 401~405
learning_materials 501~506
```

## 확인 요구사항

```text
REQ-01 학생 질문 등록
REQ-02 학생 email UNIQUE
REQ-03 튜터 email UNIQUE
REQ-04 질문 상태 CHECK
REQ-05 질문 1:N 답변
REQ-06 답변→튜터 FK
REQ-07 질문·자료 N:M
REQ-08 질문 없는 학생 조회
REQ-09 연결되지 않은 자료 조회
REQ-10 질문별 표시 순서 UNIQUE
REQ-11 자료 유형·접근 범위 CHECK
REQ-12 실제 개인정보·비밀 미사용
```

## 핵심 개념

- 필수 경로·선택 확장
- 요구사항 추적
- 미확정 정책
- 전용 스키마
- IDENTITY·명시적 ID
- ERD·DDL 정합성
- 메타데이터 검증
- 정상·경계·오류 데이터
- 업무 정합성
- 트랜잭션·ROLLBACK
- 예외 블록 반례 테스트
- 인덱스·EXPLAIN
- 최소 권한
- 비밀 관리
- 백업·복원·RPO·RTO
- 원본·파생 RAG 데이터
- AI diff 검토
- 완료·조건부 완료·보류·미완료

## 본문 구성

1. 필수 경로와 선택 확장
2. 재현 가능한 파일 구조
3. 문제·사용자·범위
4. 요구사항·미확정 정책
5. ERD·DDL 추적
6. 전용 스키마
7. 검증 시나리오 데이터
8. 실제 메타데이터
9. 요구사항 업무 조회
10. 트랜잭션
11. 자동 반례
12. 인덱스·실행 계획
13. 보안·백업·복구
14. 선택 RAG 확장
15. AI diff 검토
16. 프로젝트 완성도
17. 최종 보고서
18. 완료 게이트
19. 자주 하는 실수
20. 책 전체 연결
21. 이후 학습 방향

## 코드·문서 파일

```text
code/chapter15/templates/
├── README.md
├── requirements.md
├── erd.md
├── 01_schema.sql
├── 02_seed.sql
├── 03_metadata_validation.sql
├── 04_requirement_queries.sql
├── 05_transaction_checks.sql
├── 06_negative_tests.sql
├── 07_performance_checks.sql
├── 08_operations_checks.sql
├── 09_optional_rag_extension.sql
├── OPERATIONS_RUNBOOK.md
├── ai_review_report.md
├── final_report.md
└── reset_tutor_project.sql
```

| 파일 | 역할 |
| --- | --- |
| `01_schema.sql` | 전용 스키마·테이블·제약·업무 인덱스 생성 |
| `02_seed.sql` | 명시적 ID 기준 데이터 입력 |
| `03_metadata_validation.sql` | 테이블·FK·PK·CHECK·인덱스·CASCADE 검증 |
| `04_requirement_queries.sql` | REQ별 JOIN·집계·경계·정합성 조회 |
| `05_transaction_checks.sql` | 답변 등록·상태 변경·ROLLBACK 검증 |
| `06_negative_tests.sql` | 자동 반례와 기준 행 유지 확인 |
| `07_performance_checks.sql` | 인덱스 존재와 대표 EXPLAIN |
| `08_operations_checks.sql` | 소유자·권한·민감 컬럼·기준 행 상태 확인 |
| `09_optional_rag_extension.sql` | 활성 자료를 RAG 원문 후보로 제공하는 선택 뷰 |
| `OPERATIONS_RUNBOOK.md` | 역할·비밀·백업·복원·RPO·RTO 기록 |
| `reset_tutor_project.sql` | tutor_project만 초기화 |

## 안전성 원칙

- 생성 파일에서 자동 DROP을 실행하지 않는다.
- 모든 객체에 `tutor_project` 스키마를 명시한다.
- SERIAL 대신 IDENTITY를 사용한다.
- 샘플은 명시적 ID와 고정 시각을 사용한다.
- CASCADE와 Role 변경을 자동 적용하지 않는다.
- 반례는 하위 트랜잭션에서 실행해 기준 데이터를 유지한다.
- 작은 데이터의 Seq Scan을 오류로 판단하지 않는다.
- 실제 개인정보·비밀·전체 접속 URL·백업 파일을 커밋하지 않는다.
- 검증하지 않은 항목을 통과로 기록하지 않는다.

## AI 활용 원칙

- 확인 요구사항·미확정 정책·현재 구조를 제공한다.
- 수정·금지 파일과 스키마를 명시한다.
- 행 수·FK·인덱스·정합성·반례 기대값을 제공한다.
- 코드뿐 아니라 README·requirements·erd·보고서를 동기화하게 한다.
- 파일별 diff와 실제 실행 결과를 사람이 검토한다.

## 책의 마무리

재현 가능한 실행 절차, 검증 증거와 남은 한계를 남기는 것을 프로젝트의 최종 완료 기준으로 삼는다.
