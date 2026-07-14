# Chapter 15. 데이터베이스 종합 프로젝트

---

## 이 장에서 완성할 것

Chapter 14에서는 SQL로 분석 데이터를 만들고 Python·pandas로 확장한 뒤 두 결과를 교차 검증했습니다. 마지막 Chapter에서는 지금까지 학습한 **요구사항 분석, 데이터 설계, PostgreSQL 구현, SQL 분석, Python 분석, 운영 계획과 AI 검토**를 하나의 재현 가능한 프로젝트로 통합합니다.

기준 예제는 **AI 튜터링 질문 관리 서비스**입니다.

```text
학생이 질문을 등록한다.
→ 튜터가 답변을 작성한다.
→ 질문에 학습 자료를 연결한다.
→ 운영자가 상태와 정합성을 확인한다.
→ SQL과 Python으로 질문·답변 현황을 분석한다.
```

전체 흐름:

```text
문제·사용자·범위 정의
→ 요구사항과 미확정 정책 분리
→ ERD와 DDL 작성
→ tutor_project 스키마 구현
→ 검증용 샘플 데이터 입력
→ 업무 조회·트랜잭션·반례 검증
→ 인덱스·권한·백업·복구 검토
→ 분석용 데이터셋 생성
→ SQL·Python 분석과 교차 검증
→ AI 변경 diff 검토
→ 완료 게이트와 최종 보고서
```

![통합 데이터베이스 프로젝트 완성 흐름](../../images/chapter15/ch15_01_service_project_flow.svg)

그림 15-1 통합 데이터베이스 프로젝트 완성 흐름

> **핵심 원칙**
>
> 프로젝트의 완성도는 사용 기술의 수가 아니라 요구사항, 데이터 모델, SQL, 분석 결과와 운영 계획이 서로 추적되고 다시 실행되는지로 판단합니다.

---

## 1. 필수 경로와 선택 확장을 구분한다

![필수 범위와 선택 확장 결정하기](../../images/chapter15/ch15_02_scope_selection_guide.svg)

그림 15-2 필수 범위와 선택 확장 결정하기

### 필수 경로

```text
요구사항·ERD·DDL
샘플 데이터와 업무 조회
정상·경계·오류 검증
트랜잭션과 정합성
인덱스와 실행 계획
권한·보안·백업·복구 계획
분석용 데이터셋
SQL 분석과 Python·pandas 분석
SQL·Python 결과 검증
AI 변경 검토와 문서화
```

### 선택 확장

| 확장 | 선택 기준 |
| --- | --- |
| 웹 CRUD·API | 화면이나 API로 입력·조회 흐름을 검증해야 할 때 |
| NoSQL | 캐시·이벤트·가변 문서라는 별도 조회 패턴이 있을 때 |
| 배포 | 다른 사용자가 실제 환경에서 접근해 검증해야 할 때 |

Python 분석은 선택 확장이 아니라 Chapter 15의 필수 경로입니다.

---

## 2. 파일 구조가 실행 순서를 설명해야 한다

![재현 가능한 프로젝트 파일 구조](../../images/chapter15/ch15_03_project_structure.svg)

그림 15-3 재현 가능한 프로젝트 파일 구조

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
├── 09_analysis_dataset.sql
├── 10_completion_gate.sql
├── python/
│   ├── requirements.txt
│   ├── .env.example
│   ├── 01_load_postgresql.py
│   ├── 02_pandas_analysis.py
│   └── 03_result_validation.py
├── OPERATIONS_RUNBOOK.md
├── ai_review_report.md
├── analysis_report.md
├── final_report.md
└── reset_tutor_project.sql
```

`01~10`은 모두 필수입니다. 생성 파일은 자동 `DROP`을 실행하지 않으며, 초기화가 필요할 때만 `reset_tutor_project.sql`을 검토해 실행합니다.

---

## 3. 프로젝트 범위와 사용자를 정의한다

### 해결하려는 문제

학생 질문, 튜터 답변과 학습 자료 연결을 데이터베이스로 관리합니다. 운영자는 질문 상태와 정합성을 확인하고, 분석 담당자는 SQL과 Python으로 질문·답변 현황을 분석합니다.

| 사용자 | 필요한 작업 |
| --- | --- |
| 학생 | 질문 등록·자신의 질문 조회 |
| 튜터 | 질문 조회·답변 작성 |
| 운영자 | 상태·답변·자료 연결·정합성 확인 |
| 분석 담당자 | 질문·답변·자료 현황 분석 |

현재 버전에서 제외하는 범위:

```text
실제 로그인·인증
개인정보 수집
알림·결제
실제 LLM API 호출
웹·API 구현
NoSQL 연동
운영 배포
자동 Role 생성
자동 백업·복원 실행
```

---

## 4. 요구사항과 미확정 정책을 분리한다

| ID | 요구사항 | 반영 | 검증 |
| --- | --- | --- | --- |
| REQ-01 | 학생은 질문을 등록한다 | `questions.student_id` FK | 학생·질문 JOIN |
| REQ-02 | 학생 이메일은 중복되지 않는다 | UNIQUE | 중복 반례 |
| REQ-03 | 튜터 이메일은 중복되지 않는다 | UNIQUE | 중복 반례 |
| REQ-04 | 질문 상태는 허용값만 사용한다 | CHECK | 잘못된 상태 반례 |
| REQ-05 | 질문에는 여러 답변이 가능하다 | 1:N 관계 | 질문별 답변 집계 |
| REQ-06 | 답변은 튜터를 참조한다 | FK | 답변·튜터 JOIN |
| REQ-07 | 질문과 자료는 N:M이다 | 연결 테이블 | N:M 조회 |
| REQ-08 | 질문 없는 학생을 찾는다 | LEFT JOIN | 기대 1명 |
| REQ-09 | 연결되지 않은 자료를 찾는다 | LEFT JOIN | 기대 1건 |
| REQ-10 | 표시 순서는 질문 안에서 중복되지 않는다 | 복합 UNIQUE | 반례 |
| REQ-11 | 실제 개인정보와 비밀을 사용하지 않는다 | 가상 데이터 | 운영 점검 |
| REQ-12 | 질문 1건 단위 분석 데이터셋을 제공한다 | 분석 VIEW | 행 수·중복 검증 |
| REQ-13 | SQL과 Python의 핵심 집계가 일치한다 | 기준값 비교 | 자동 검증 |

미확정 정책은 AI가 임의로 제약조건이나 전처리 규칙으로 고정하지 않습니다.

```text
같은 튜터의 복수 답변 허용 여부
답변 등록 시 상태 자동 변경 여부
closed 질문의 답변 허용 여부
삭제와 보관 정책
분석 기준 시각과 갱신 주기
```

---

## 5. ERD와 DDL을 추적한다

```text
students 1 → 0..N questions
questions 1 → 0..N answers
tutors 1 → 0..N answers
questions 1 → 0..N question_materials
learning_materials 1 → 0..N question_materials
```

![요구사항부터 분석 결과까지 검증하기](../../images/chapter15/ch15_04_db_design_validation.svg)

그림 15-4 요구사항부터 분석 결과까지 검증하기

검토 항목:

```text
FK 5개가 ERD 방향과 일치하는가?
PK는 IDENTITY, 연결 테이블은 복합 PK인가?
UNIQUE·CHECK가 확인된 요구사항에 근거하는가?
CASCADE가 근거 없이 추가되지 않았는가?
분석 VIEW가 질문 1건을 여러 행으로 늘리지 않는가?
```

---

## 6. 전용 스키마를 사용한다

```text
tutor_project.students
tutor_project.tutors
tutor_project.questions
tutor_project.answers
tutor_project.learning_materials
tutor_project.question_materials
tutor_project.question_analysis_dataset VIEW
```

앞 장의 `course_project`, `transaction_lab`, `performance_lab`, `security_lab`, `nosql_lab`, `ai_review_lab`, `analysis_lab`, `public`은 변경하지 않습니다.

---

## 7. 샘플 데이터는 검증과 분석 시나리오를 포함한다

명시적 ID와 고정 시각을 사용합니다.

| 테이블 | 기대 행 수 |
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
여러 시점에 생성된 질문과 답변
```

---

## 8. 실제 메타데이터를 검증한다

`03_metadata_validation.sql`에서 다음을 확인합니다.

```text
테이블 6개
FK 5개
IDENTITY PK 5개
복합 PK 1개
업무 인덱스 3개
CASCADE FK 0개
민감정보 형태 컬럼 0개
```

문서가 아니라 PostgreSQL 카탈로그의 실제 생성 결과를 기준으로 판단합니다.

---

## 9. 업무 조회와 분석 질문을 연결한다

`04_requirement_queries.sql`은 학생·질문 JOIN, 질문별 답변 수, 답변·튜터 JOIN, 질문·자료 N:M, 질문 없는 학생과 연결되지 않은 자료를 확인합니다.

정합성 이상 조회는 모두 0행이어야 합니다.

```text
고아 질문·답변·자료 연결
answered인데 답변이 없는 질문
중복 표시 순서
```

분석 질문 예:

```text
질문 상태별 건수는 얼마인가?
학생별 질문 수는 얼마인가?
튜터별 답변 수는 얼마인가?
질문별 답변 수와 자료 연결 수는 얼마인가?
월별 질문 등록 건수는 어떻게 변하는가?
첫 답변까지 걸린 시간은 얼마인가?
```

---

## 10. 트랜잭션과 반례를 검증한다

`05_transaction_checks.sql`은 답변 등록과 질문 상태 변경을 하나의 작업으로 처리하고 `ROLLBACK` 뒤 기준 데이터가 복구되는지 확인합니다.

`06_negative_tests.sql`은 다음 오류를 자동 확인합니다.

```text
중복 이메일
없는 부모를 참조하는 FK
잘못된 질문 상태
빈 제목과 답변
잘못된 자료 유형·접근 범위
중복 자료 연결과 표시 순서
```

예상 오류와 다른 결과는 `unexpected`로 기록합니다.

---

## 11. 인덱스와 운영 안전성을 검토한다

| 인덱스 | 조회 패턴 |
| --- | --- |
| `questions(student_id, status, created_at DESC)` | 학생별 질문 목록 |
| `answers(question_id, created_at)` | 질문별 답변 조회 |
| `question_materials(material_id)` | 자료별 질문 조회 |

작은 데이터에서 `Seq Scan`이 선택되어도 자동 오류로 판단하지 않습니다.

운영 점검에는 다음을 포함합니다.

```text
최소 권한과 읽기 전용 분석 계정
개인정보·비밀번호·토큰 미포함
.env·백업·실제 CSV 저장소 제외
백업 범위와 별도 DB 복원 절차
RPO·RTO와 다음 복원 시험 계획
```

---

## 12. 분석용 데이터셋을 만든다

`09_analysis_dataset.sql`은 **질문 1건을 한 행**으로 정의한 VIEW를 생성합니다.

```text
question_id
question_code
question_created_at
question_month
student_id
student_name
status
answer_count
first_answer_at
first_response_hours
material_count
has_answer
has_material
```

검증 기준:

```text
VIEW 행 수 5
question_id 중복 0
answer_count 합계 5
material_count 합계 7
답변 없는 질문 1건
```

Python은 이 VIEW를 읽어 상태별·월별·학생별 집계를 수행하고 SQL 기준값과 비교합니다. 오류를 숨기기 위해 `drop_duplicates()`나 `dropna()`를 임의 적용하지 않습니다.

---

## 13. AI 제안은 실행 증거와 함께 검토한다

![AI 제안 검토·수정·재실행 루프](../../images/chapter15/ch15_05_ai_review_loop.svg)

그림 15-5 AI 제안 검토·수정·재실행 루프

```text
요구사항과 수정 범위 제공
→ AI가 ERD·SQL·Python 초안 제안
→ 파일별 diff 확인
→ 격리 환경에서 실행
→ DB 구조와 SQL 결과 검증
→ DataFrame 행 수·자료형·집계 검증
→ SQL·Python 결과 비교
→ 사람이 최종 승인
```

요청하지 않은 파일 변경, 근거 없는 제약조건, 파괴적인 SQL, 접속 정보 노출과 임의 데이터 제거를 확인합니다.

---

## 14. 프로젝트 완성도의 일곱 축

![프로젝트 완성도의 일곱 축](../../images/chapter15/ch15_06_completion_dimensions.svg)

그림 15-6 프로젝트 완성도의 일곱 축

```text
1. 문제와 범위
2. 요구사항과 설계 일관성
3. 재현 가능한 데이터·SQL·Python
4. 정상·경계·오류·트랜잭션·분석 증거
5. 성능·보안·백업·복구 계획
6. AI 변경 검토와 문서화
7. 남은 한계와 다음 버전
```

---

## 15. 최종 보고서와 완료 게이트

![설계 결정과 검증 근거를 설명하는 흐름](../../images/chapter15/ch15_07_project_story_flow.svg)

그림 15-7 설계 결정과 검증 근거를 설명하는 흐름

최종 보고서에는 문제와 사용자, 범위, 요구사항 추적, ERD·DDL 결정, 검증 결과, 인덱스 판단, 운영 계획, 분석 질문, SQL·Python 결과, AI 수정, 한계와 다음 버전을 기록합니다.

![최종 완료 판단 게이트](../../images/chapter15/ch15_08_completion_checklist.svg)

그림 15-8 최종 완료 판단 게이트

필수 통과 기준:

```text
requirements.md·erd.md·DDL 일치
01→10 순서 실행 가능
행 수 4·3·5·5·6·7 일치
FK 5·인덱스 3·CASCADE 0
정합성 이상 0행
ROLLBACK 후 기준 데이터 복구
반례 unexpected 0
분석 VIEW 5행·question_id 중복 0
SQL과 pandas 핵심 집계 일치
비밀·개인정보·.env·운영 데이터 파일 미포함
분석 결과와 미실행 항목 기록
```

`required_completion_gate_passed = true`는 필수 DB 구조와 SQL 분석 데이터셋이 기대값과 일치한다는 의미입니다. 실제 Role 시험, 백업·복원, 웹 API, NoSQL과 배포가 완료되었다는 뜻은 아닙니다.

---

## 16. 자주 하는 실수

```text
기술 목록을 프로젝트 목표로 삼는다.
생성 SQL에서 자동 DROP을 실행한다.
자동 증가 ID가 항상 연속이라고 가정한다.
정상 조회만 실행하고 반례를 생략한다.
작은 샘플의 실행 계획만으로 인덱스를 단정한다.
Python에서 중복과 NULL을 임의 제거한다.
SQL과 Python 결과가 다른데 그래프만 채택한다.
접속 정보와 실제 데이터를 저장소에 커밋한다.
AI가 수정한 diff를 자동 승인한다.
```

---

## 17. 책 전체의 개념을 연결한다

```text
요구사항·ERD              Chapter 5
정규화·무결성             Chapter 6
관계형 DB 설계 프로젝트    Chapter 7
JOIN·집계                  Chapter 8
트랜잭션                   Chapter 9
인덱스·실행 계획           Chapter 10
권한·백업·복구             Chapter 11
NoSQL 선택                 Chapter 12
AI 설계·SQL 검토           Chapter 13
SQL·Python 데이터 분석     Chapter 14
설계·분석·검증 통합        Chapter 15
```

이후에는 웹 API, ORM과 마이그레이션, NoSQL 연동, 자동화 테스트, 클라우드 배포와 대규모 데이터 분석으로 확장할 수 있습니다.

```text
데이터베이스 프로젝트의 완성은 SQL 파일이나 그래프를 만드는 순간이 아니라,
다른 사람이 같은 절차로 실행하고 같은 근거를 확인할 수 있을 때 시작된다.
```
