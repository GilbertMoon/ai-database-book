# Chapter 15. 실전 프로젝트 2: 재현 가능한 AI 데이터베이스 서비스 완성하기

---

## 이 장에서 완성할 것

Chapter 14에서는 권한과 최신성을 적용한 벡터 검색, 검색 품질 평가와 근거 기반 답변 검토를 살펴봤습니다. 마지막 Chapter에서는 지금까지 배운 내용을 **다른 사람이 다시 실행하고 같은 결과를 확인할 수 있는 작은 데이터베이스 서비스 프로젝트**로 묶습니다.

기준 예제는 **AI 튜터링 질문 관리 서비스**입니다.

```text
학생이 질문을 등록한다.
→ 튜터가 답변을 작성한다.
→ 질문에 학습 자료를 연결한다.
→ 운영자가 상태와 정합성을 확인한다.
→ 필요하면 학습 자료를 RAG 원문으로 확장한다.
```

완성 흐름:

```text
문제·사용자·범위 정의
→ 확인 요구사항과 미확정 정책 분리
→ ERD와 DDL 작성
→ tutor_project 격리 스키마 생성
→ 검증 목적 샘플 데이터 입력
→ 메타데이터·업무 조회·트랜잭션·반례 검증
→ 실제 조회 패턴과 인덱스 검토
→ 최소 권한·비밀·백업·복구 계획
→ AI 변경 diff와 실행 증거 검토
→ 선택적 API·NoSQL·RAG 확장 판단
→ 완료 게이트와 최종 보고서
```

![통합 데이터베이스 서비스 완성 흐름](../../images/chapter15/ch15_01_service_project_flow.svg)

그림 15-1 통합 데이터베이스 서비스 완성 흐름

> **핵심 원칙**
>
> 완성된 프로젝트는 기능이 많은 프로젝트가 아닙니다. 요구사항, 데이터 모델, SQL, 실행 결과, 운영 계획과 남은 한계가 서로 추적되는 프로젝트입니다.

---

## 1. 필수 경로와 선택 확장을 분리한다

처음부터 웹·NoSQL·RAG·배포를 모두 넣으면 핵심 데이터베이스 검증이 흐려질 수 있습니다.

![필수 범위와 선택 확장 결정하기](../../images/chapter15/ch15_02_scope_selection_guide.svg)

그림 15-2 필수 범위와 선택 확장 결정하기

### 필수 경로

```text
요구사항
ERD
PostgreSQL DDL
샘플 데이터
업무 조회
정상·경계·오류 검증
트랜잭션
인덱스 검토
보안·백업·복구 계획
AI 검토 기록
재현 가능한 README
```

### 선택 확장

| 확장 | 선택 기준 |
| --- | --- |
| 웹 CRUD·API | 화면이나 API로 입력·조회 흐름을 검증해야 할 때 |
| NoSQL | 캐시·이벤트·가변 문서라는 별도 조회 패턴이 있을 때 |
| Vector DB·RAG | 학습 자료 의미 검색과 근거 기반 답변이 필요할 때 |
| 배포 | 다른 사용자가 실제 환경에서 검증해야 할 때 |

AI 기능 수나 사용 기술 수로 완성도를 판단하지 않습니다.

---

## 2. 프로젝트 파일 구조가 실행 순서를 설명해야 한다

![재현 가능한 프로젝트 파일 구조](../../images/chapter15/ch15_03_project_structure.svg)

그림 15-3 재현 가능한 프로젝트 파일 구조

이 장의 템플릿 구조:

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
├── 10_completion_gate.sql
├── OPERATIONS_RUNBOOK.md
├── ai_review_report.md
├── final_report.md
└── reset_tutor_project.sql
```

파일명에는 실행 순서를 포함하고, 생성 파일에서는 자동 `DROP`을 실행하지 않습니다.
필수 실행은 01~08과 10이며, 09는 실제 RAG 요구사항이 있을 때만 선택 실행합니다.

---

## 3. 프로젝트 범위와 사용자를 먼저 정의한다

### 해결하려는 문제

학생 질문, 튜터 답변과 관련 학습 자료의 연결을 데이터베이스로 관리합니다. 운영자는 질문 상태, 답변 현황, 연결되지 않은 자료와 정합성 문제를 조회합니다.

### 주요 사용자

| 사용자 | 필요한 작업 |
| --- | --- |
| 학생 | 질문 등록·자신의 질문 조회 |
| 튜터 | 질문 조회·답변 작성 |
| 운영자 | 상태·답변·자료 연결·정합성 확인 |
| 검색 서비스 | 허용된 활성 학습 자료를 RAG 원문 후보로 읽기 |

### 현재 버전에서 제외하는 범위

```text
실제 로그인·인증
개인정보 수집
알림·결제
실제 LLM API 호출
운영 배포
자동 Role 생성
자동 백업·복원 실행
```

---

## 4. 확인된 요구사항과 미확정 정책을 분리한다

| ID | 확인 요구사항 | DB 반영 | 검증 증거 |
| --- | --- | --- | --- |
| REQ-01 | 학생은 질문을 등록한다 | `questions.student_id` FK | 학생·질문 JOIN |
| REQ-02 | 학생 이메일은 중복되지 않는다 | `students.email UNIQUE` | 중복 반례 |
| REQ-03 | 튜터 이메일은 중복되지 않는다 | `tutors.email UNIQUE` | 중복 반례 |
| REQ-04 | 질문 상태는 허용값만 사용한다 | `questions.status CHECK` | 잘못된 상태 반례 |
| REQ-05 | 질문에는 여러 답변이 가능하다 | `questions 1:N answers` | 질문별 답변 집계 |
| REQ-06 | 답변은 튜터를 참조한다 | `answers.tutor_id` FK | 답변·튜터 JOIN |
| REQ-07 | 질문과 자료는 N:M이다 | `question_materials` | N:M 조회 |
| REQ-08 | 질문 없는 학생을 찾는다 | LEFT JOIN | 기대 1명 |
| REQ-09 | 연결되지 않은 자료를 찾는다 | LEFT JOIN | 기대 1건 |
| REQ-10 | 한 질문의 표시 순서는 중복되지 않는다 | 복합 UNIQUE | 중복 순서 반례 |
| REQ-11 | 자료 유형·접근 범위는 허용값만 사용한다 | CHECK | 잘못된 값 반례 |
| REQ-12 | 실제 개인정보와 비밀을 사용하지 않는다 | 가상 데이터·컬럼 검토 | 메타데이터·샘플 검토 |

미확정 정책:

```text
같은 튜터가 한 질문에 여러 답변을 작성할 수 있는가?
답변 등록 시 질문 상태를 자동 변경하는가?
closed 질문에 답변을 허용하는가?
학생·질문 삭제 정책은 무엇인가?
질문·답변 보관 기간은 얼마인가?
```

미확정 정책은 근거 없는 `UNIQUE`, `CASCADE`, 트리거로 고정하지 않습니다.

---

## 5. ERD와 DDL의 관계를 추적한다

기준 관계:

```text
students 1 → 0..N questions
questions 1 → 0..N answers
tutors 1 → 0..N answers
questions 1 → 0..N question_materials
learning_materials 1 → 0..N question_materials
```

![요구사항부터 실행 결과까지 검증하기](../../images/chapter15/ch15_04_db_design_validation.svg)

그림 15-4 요구사항부터 실행 결과까지 검증하기

DDL 검토 항목:

```text
테이블 역할이 하나의 주요 변경 이유를 가지는가?
FK 5개가 ERD 방향과 일치하는가?
PK는 IDENTITY, 연결 테이블은 복합 PK인가?
이메일·업무 코드는 UNIQUE인가?
상태·유형·접근 범위·표시 순서는 CHECK로 보호되는가?
CASCADE가 요구사항 없이 추가되지 않았는가?
```

---

## 6. 전용 스키마와 명시적 객체명을 사용한다

필수 실습은 `tutor_project` 스키마에 격리합니다.

```text
tutor_project.students
tutor_project.tutors
tutor_project.questions
tutor_project.answers
tutor_project.learning_materials
tutor_project.question_materials
```

앞 장의 스키마는 변경하지 않습니다.

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

`01_schema.sql`은 `IDENTITY`, 명시적 제약조건 이름과 `ON DELETE RESTRICT`를 사용합니다. `updated_at` 자동 갱신은 현재 범위에 포함하지 않으며 애플리케이션 또는 별도 정책으로 남깁니다.

---

## 7. 샘플 데이터는 검증 시나리오를 포함한다

명시적 ID를 사용해 이전 실행의 시퀀스 상태에 의존하지 않습니다.

```text
students 101~104
tutors 201~203
questions 301~305
answers 401~405
learning_materials 501~506
```

기대 행 수:

| 테이블 | 기대 |
| --- | ---: |
| students | 4 |
| tutors | 3 |
| questions | 5 |
| answers | 5 |
| learning_materials | 6 |
| question_materials | 7 |

경계 사례:

```text
질문이 없는 학생 1명
연결되지 않은 자료 1건
답변이 없는 open 질문 1건
답변이 두 개 있는 질문 1건
internal 자료 1건
inactive 자료 1건
```

---

## 8. 실제 PostgreSQL 메타데이터를 검증한다

`03_metadata_validation.sql`은 다음을 확인합니다.

```text
테이블 6개
FK 5개
IDENTITY PK 5개
연결 테이블 복합 PK 1개
CASCADE FK 0개
민감정보 형태 컬럼 0개
업무 인덱스 3개
```

DDL 문서가 아니라 `information_schema`, `pg_constraint`, `pg_indexes`에서 실제 생성 결과를 조회합니다.

---

## 9. 요구사항별 업무 조회가 증거가 된다

`04_requirement_queries.sql`은 요구사항 ID와 연결됩니다.

```text
REQ-01 학생과 질문 JOIN
REQ-05 질문별 답변 수
REQ-06 답변과 튜터 JOIN
REQ-07 질문·자료 N:M
REQ-08 질문 없는 학생 1명
REQ-09 연결되지 않은 자료 1건
REQ-10 질문별 표시 순서
REQ-11 활성·접근 범위별 자료 조회
```

정합성 이상 조회는 모두 0행이어야 합니다.

```text
고아 질문
고아 답변·튜터
고아 질문·자료 연결
answered인데 답변이 없는 질문
중복 표시 순서
```

---

## 10. 트랜잭션은 서비스 작업 단위로 검증한다

답변 등록과 질문 상태 변경은 함께 성공하거나 함께 실패해야 할 수 있습니다.

`05_transaction_checks.sql`의 기본 예제:

```text
open 질문에 답변 INSERT
→ 질문 상태를 answered로 UPDATE
→ 트랜잭션 내부 결과 확인
→ ROLLBACK
→ 답변 수와 상태가 원래 값으로 복구되었는지 확인
```

이 파일은 기준 데이터를 영구 변경하지 않습니다.

---

## 11. 반례 테스트는 자동화하고 기준 데이터를 유지한다

`06_negative_tests.sql`은 임시 결과 테이블과 PostgreSQL 예외 블록을 사용합니다.

검증 예:

```text
중복 학생·튜터 이메일
없는 학생·질문·튜터·자료 FK
잘못된 질문 상태
빈 제목·답변
잘못된 자료 유형·접근 범위
표시 순서 0
중복 질문·자료 연결
중복 표시 순서
```

예상 오류는 `unique_violation`, `foreign_key_violation`, `check_violation`으로 구분합니다. 각 하위 트랜잭션은 실패 시 자동 취소되어 기준 행 수를 유지합니다.

---

## 12. 인덱스는 조회 패턴과 실행 계획으로 검토한다

기준 인덱스:

| 인덱스 | 근거 |
| --- | --- |
| `questions(student_id, status, created_at DESC)` | 학생별 상태별 질문 목록 |
| `answers(question_id, created_at)` | 질문별 답변 시간순 조회 |
| `question_materials(material_id)` | 자료별 연결 질문 조회 |

`07_performance_checks.sql`은 인덱스 존재와 대표 `EXPLAIN`을 확인합니다. 데이터가 작으면 PostgreSQL이 `Seq Scan`을 선택할 수 있으므로 인덱스 미사용을 오류로 단정하지 않습니다. 운영 적용 전에는 실제 데이터 크기와 `EXPLAIN (ANALYZE, BUFFERS)`를 비교합니다.

---

## 13. 최소 권한·비밀·백업·복구를 완료 조건에 포함한다

`08_operations_checks.sql`과 `OPERATIONS_RUNBOOK.md`에서 확인합니다.

```text
실제 개인정보·비밀번호·토큰 컬럼이나 값이 없는가?
앱·보고·소유 역할의 작업 행렬이 있는가?
Role 변경은 테스트 환경에서 선택 실행하도록 분리했는가?
.env와 백업 파일이 저장소에서 제외되는가?
백업 범위·형식·저장 위치가 정해졌는가?
별도 DB 복원과 구조·행 수 검증 절차가 있는가?
RPO·RTO와 다음 복원 시험 날짜가 기록되었는가?
```

프로젝트가 작아도 복원할 수 없다면 운영 가능한 결과물이라고 보기 어렵습니다.

---

## 14. 선택적 RAG 확장은 원본과 파생 데이터를 분리한다

학습 자료 의미 검색이 실제 요구사항이면 `09_optional_rag_extension.sql`을 검토합니다.

```text
Source of Truth
→ tutor_project.learning_materials

RAG 원문 후보 뷰
→ 활성 자료의 코드·제목·요약·접근 범위

파생 데이터
→ 청크·임베딩·벡터 인덱스·검색 로그
```

RAG 확장에서도 다음을 유지합니다.

```text
access_scope를 검색 전에 적용
비활성 자료 제외
원문 버전·해시 추적
근거 없는 질문은 보류
검색 품질과 답변 근거성 분리 평가
```

기본 프로젝트는 RAG 없이도 완성될 수 있습니다.

---

## 15. AI 제안은 diff와 실행 증거로 검토한다

![AI 제안 검토·수정·재실행 루프](../../images/chapter15/ch15_05_ai_review_loop.svg)

그림 15-5 AI 제안 검토·수정·재실행 루프

AI에 요청할 때 다음을 명시합니다.

```text
확인 요구사항과 미확정 정책
현재 tutor_project 구조
수정할 파일과 수정 금지 범위
기대 행 수와 FK·인덱스 수
정상·반례·트랜잭션·정합성 검증
완료 보고 형식
```

사람은 다음을 확인합니다.

```text
요청하지 않은 테이블·파일이 바뀌지 않았는가?
근거 없는 UNIQUE·CASCADE·Role 변경이 없는가?
실제 개인정보와 비밀이 추가되지 않았는가?
코드와 README·requirements·erd·보고서가 함께 바뀌었는가?
검증하지 않은 항목을 통과로 표시하지 않았는가?
```

---

## 16. 프로젝트 완성도의 일곱 축

![프로젝트 완성도의 일곱 축](../../images/chapter15/ch15_06_completion_dimensions.svg)

그림 15-6 프로젝트 완성도의 일곱 축

```text
1. 문제와 범위
2. 요구사항과 설계 일관성
3. 재현 가능한 데이터셋 SQL
4. 정상·경계·오류·트랜잭션 증거
5. 성능·보안·백업·복구 계획
6. AI 변경 검토와 문서화
7. 남은 한계와 다음 버전
```

기능 수가 아니라 빈틈없는 추적과 검증으로 판단합니다.

---

## 17. 최종 보고서는 설계 결정을 설명한다

![설계 결정과 검증 근거를 설명하는 흐름](../../images/chapter15/ch15_07_project_story_flow.svg)

그림 15-7 설계 결정과 검증 근거를 설명하는 흐름

`final_report.md`에는 다음을 기록합니다.

```text
문제와 사용자
필수·제외·선택 범위
요구사항 추적 결과
ERD·DDL 주요 결정
기준 데이터와 실행 결과
정상·경계·반례·트랜잭션 결과
인덱스 판단
보안·백업·복구 상태
AI 제안과 사람의 수정
미실행 항목·남은 위험
다음 버전 계획
```

---

## 18. 완료 게이트를 통과한다

![최종 완료 판단 게이트](../../images/chapter15/ch15_08_completion_checklist.svg)

그림 15-8 최종 완료 판단 게이트

필수 통과 기준:

```text
requirements.md와 erd.md가 DDL과 일치한다.
01→08 파일을 순서대로 실행할 수 있다.
행 수 4·3·5·5·6·7이 일치한다.
FK 5, 업무 인덱스 3, CASCADE 0을 확인한다.
질문 없는 학생과 연결되지 않은 자료가 각각 1건이다.
정합성 이상 조회가 0행이다.
트랜잭션 ROLLBACK 후 기준 데이터가 복구된다.
자동 반례 테스트에 unexpected 결과가 없다.
비밀·개인정보·백업 파일이 저장소에 없다.
미실행 항목과 미확정 정책을 명시한다.
```

선택 확장은 필수 게이트 통과 후 진행합니다.

---

## 19. 자주 하는 실수

### 실수 1. 기술 목록을 프로젝트 목표로 삼는다

문제와 요구사항을 먼저 정의합니다.

### 실수 2. 생성 SQL에서 자동 DROP을 실행한다

초기화 파일을 분리하고 대상 스키마를 확인합니다.

### 실수 3. 자동 증가 ID가 항상 1부터 연속이라고 가정한다

명시적 ID 또는 안정된 자연키를 사용합니다.

### 실수 4. 정상 조회만 실행한다

경계·반례·트랜잭션·업무 정합성 검증을 포함합니다.

### 실수 5. 작은 샘플에서 인덱스 사용 여부만 본다

실제 조회 패턴과 데이터 규모, 쓰기 비용을 함께 검토합니다.

### 실수 6. 백업 파일 존재만 확인한다

별도 DB 복원과 구조·데이터 검증까지 수행합니다.

### 실수 7. RAG를 원본 저장소처럼 사용한다

업무 원본과 벡터 파생 데이터를 분리합니다.

### 실수 8. AI가 수정한 diff를 자동 승인한다

범위·정책·보안·실행 증거를 사람이 검토합니다.

---

## 20. 책 전체의 개념을 다시 연결한다

```text
요구사항·ERD              Chapter 5
정규화·무결성             Chapter 6
프로젝트 스키마            Chapter 7
JOIN·집계                  Chapter 8
트랜잭션                   Chapter 9
인덱스·실행 계획           Chapter 10
권한·백업·복구             Chapter 11
NoSQL 선택                 Chapter 12
AI 설계 검토               Chapter 13
벡터 검색·RAG 평가         Chapter 14
통합·재현·완료 판단        Chapter 15
```

각 기술은 프로젝트 안에서 필요한 문제를 해결하기 위해 연결됩니다.

---

## 21. 이후 학습 방향

다음 단계에서는 다음 영역으로 확장할 수 있습니다.

```text
FastAPI·Django·Spring 기반 API
ORM과 데이터베이스 마이그레이션
자동화 테스트와 CI
컨테이너·클라우드 배포
관측성·장애 대응·성능 튜닝
CDC·메시지 큐·데이터 파이프라인
실제 임베딩 모델과 RAG 평가 자동화
```

이 책의 마지막 문장은 다음과 같습니다.

```text
데이터베이스 프로젝트의 완성은 SQL 파일을 만드는 순간이 아니라,
다른 사람이 같은 절차로 실행하고 같은 근거를 확인할 수 있을 때 시작된다.
```
