# Chapter 15. 데이터베이스 종합 프로젝트

---

## 이 장에서 완성할 것

Chapter 14에서는 SQL 분석 결과를 Python·pandas로 확장하고 같은 스냅샷의 실제 결과를 교차 검증했습니다. 마지막 Chapter에서는 지금까지 학습한 요구사항 분석, ERD, PostgreSQL 구현, SQL 검증, 트랜잭션, 인덱스, 보안, 백업·복구, 분석과 AI 검토를 하나의 재현 가능한 프로젝트로 통합합니다.

기준 예제는 **AI 튜터링 질문 관리 서비스**입니다.

```text
학생이 질문을 등록한다.
→ 튜터가 답변을 작성한다.
→ 질문에 학습 자료를 연결한다.
→ 운영자가 상태·관계·시간 정합성을 확인한다.
→ SQL과 pandas로 질문·답변 현황을 분석한다.
→ 별도 DB 복원과 최종 완료 근거를 기록한다.
```

![통합 데이터베이스 프로젝트 완성 흐름](../../images/chapter15/ch15_01_service_project_flow.svg)

그림 15-1 통합 데이터베이스 프로젝트 완성 흐름

> **핵심 원칙**
>
> 프로젝트의 완성도는 사용 기술의 수가 아니라 요구사항, 실제 DB 구조, 검증 SQL, 분석 결과와 복구 절차가 서로 추적되고 다시 실행되는지로 판단합니다.

---

## 1. 필수 경로와 선택 확장을 구분한다

![필수 범위와 선택 확장 결정하기](../../images/chapter15/ch15_02_scope_selection_guide.svg)

그림 15-2 필수 범위와 선택 확장 결정하기

### 필수 경로

```text
요구사항·미확정 정책
ERD·DDL·전용 스키마
기준 데이터·IDENTITY 조정
정확한 메타데이터·업무·시간 검증
트랜잭션·반례·정상 경계값
인덱스 후보·권한·보안 점검
백업·별도 DB 복원 계획
고정 기간 분석 VIEW
예외 기반 DB 완료 게이트
실제 SQL·pandas 결과 비교
AI diff·보고서·미실행 항목
```

### 선택 확장

| 확장 | 선택 기준 |
| --- | --- |
| 웹 CRUD·API | 외부 입력과 화면·API 흐름을 검증해야 할 때 |
| NoSQL | 캐시·이벤트·가변 문서라는 별도 조회 패턴이 있을 때 |
| 배포 | 다른 사용자가 실제 환경에서 접근해 검증해야 할 때 |

Python 분석은 이 장의 필수 경로입니다.

---

## 2. 파일 구조가 실행 순서와 증거를 설명해야 한다

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
├── 11_restore_validation.sql
├── python/
│   ├── requirements.txt
│   ├── .env.example
│   ├── validation_utils.py
│   ├── 01_load_postgresql.py
│   ├── 02_pandas_analysis.py
│   └── 03_result_validation.py
├── OPERATIONS_RUNBOOK.md
├── ai_review_report.md
├── analysis_report.md
├── final_report.md
└── reset_tutor_project.sql
```

권장 순서:

```text
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10
→ Python 01 → 02 → 03
→ 백업·별도 DB 복원 → 복원 DB에서 11
→ 보고서·AI diff·최종 판단
```

`10_completion_gate.sql` 통과는 DB 구조·데이터·SQL 검증 완료를 뜻합니다. Python 교차 검증, Role 시험과 복원 시험은 별도 증거가 필요합니다.

---

## 3. 문제·사용자·범위를 정의한다

| 사용자 | 필요한 작업 |
| --- | --- |
| 학생 | 질문 등록·자신의 질문 조회 |
| 튜터 | 질문 조회·답변 작성 |
| 운영자 | 상태·답변·자료 연결·정합성 확인 |
| 분석 담당자 | 질문·답변·자료 현황 분석 |

현재 범위에서 제외하는 항목:

```text
실제 로그인·인증
실제 개인정보 수집
알림·결제
실제 LLM API 호출
웹·API 구현
NoSQL 연동
클라우드 배포
자동 Role 생성
자동 백업·복원 스케줄
```

---

## 4. P15 추적 ID로 요구사항과 정책을 구분한다

| ID | 확정 요구사항 | 구현·검증 |
| --- | --- | --- |
| P15-R01 | 학생은 질문을 등록한다 | student FK·JOIN |
| P15-R02 | 학생 이메일은 공백이 아니며 정확히 같은 문자열은 중복되지 않는다 | CHECK·UNIQUE·반례 |
| P15-R03 | 튜터 이메일도 같은 규칙을 적용한다 | CHECK·UNIQUE·반례 |
| P15-R04 | 질문 상태는 허용값만 사용한다 | CHECK·반례 |
| P15-R05 | 질문에는 여러 답변이 가능하다 | 1:N·경계값 |
| P15-R06 | 답변은 존재하는 질문과 튜터를 참조한다 | FK·반례 |
| P15-R07 | 질문과 학습 자료는 N:M이다 | 연결 테이블 |
| P15-R08 | 질문이 없는 학생도 0건으로 조회한다 | 학생 요약 VIEW |
| P15-R09 | 연결되지 않은 자료를 찾는다 | LEFT JOIN |
| P15-R10 | 한 질문의 자료 표시 순서는 중복되지 않는다 | 복합 UNIQUE |
| P15-R11 | 실제 개인정보·비밀·운영 파일을 사용하지 않는다 | 가상 Seed·운영 점검 |
| P15-R12 | 질문 1건 단위 분석 데이터를 제공한다 | 질문 분석 VIEW |
| P15-R13 | 같은 스냅샷의 실제 SQL·pandas 집계가 일치한다 | Python 자동 비교 |

미확정 또는 후속 정책:

```text
P15-D02 같은 튜터가 한 질문에 여러 답변을 작성할 수 있는가?
P15-D03 답변 등록 시 상태를 앱·트리거·수동 중 어디에서 바꾸는가?
P15-D04 closed 질문에 추가 답변을 허용하는가?
P15-D05 비활성 학생·튜터가 신규 작업을 할 수 있는가?
P15-D07 삭제·보관 정책은 무엇인가?
P15-D08 access_scope를 실제 권한 통제로 어떻게 연결하는가?
```

이메일 대소문자를 같은 주소로 처리할지도 별도 정책입니다. 현재 UNIQUE는 정확히 같은 문자열만 차단합니다.

---

## 5. ERD·DDL·메타데이터를 추적한다

```text
students 1 → 0..N questions
questions 1 → 0..N answers
tutors 1 → 0..N answers
questions 1 → 0..N question_materials
learning_materials 1 → 0..N question_materials
```

![요구사항부터 분석 결과까지 검증하기](../../images/chapter15/ch15_04_db_design_validation.svg)

그림 15-4 요구사항부터 분석 결과까지 검증하기

전용 스키마:

```text
tutor_project.students
tutor_project.tutors
tutor_project.questions
tutor_project.answers
tutor_project.learning_materials
tutor_project.question_materials
```

앞 장 스키마와 `public`은 변경하지 않습니다.

### 실행 안전성

`01_schema.sql`은 다음을 실제로 검사합니다.

```text
현재 DB = ai_database_book
tutor_project 미존재
```

스키마, 6개 테이블, 업무 인덱스 3개와 분석 기준 VIEW는 하나의 트랜잭션에서 생성합니다. 생성 파일은 자동 DROP을 하지 않습니다.

### 무결성 규칙

```text
필수 이름·이메일·코드·본문·버전은 공백 금지
질문 상태: open·answered·closed
questions.updated_at >= questions.created_at
자료 유형·접근 범위 허용값
question_materials 복합 PK
질문 안에서 display_order UNIQUE·양수
FK 삭제 규칙 RESTRICT
```

`03_metadata_validation.sql`은 단순 개수뿐 아니라 정확한 테이블 집합, 제약조건 이름, FK 출발·대상 컬럼, 복합 PK 컬럼 순서와 인덱스 정의를 PostgreSQL 카탈로그에서 검증합니다.

기준:

```text
base tables 6
constraints 36
FK 5
IDENTITY PK 5
업무 인덱스 3
CASCADE 0
```

---

## 6. 기준 데이터와 IDENTITY를 함께 관리한다

| 테이블 | 기준 행 수 | 명시적 ID | 다음 자동값 |
| --- | ---: | --- | ---: |
| students | 4 | 101~104 | 105 |
| tutors | 3 | 201~203 | 204 |
| questions | 5 | 301~305 | 306 |
| answers | 5 | 401~405 | 406 |
| learning_materials | 6 | 501~506 | 507 |
| question_materials | 7 | 복합 PK | - |

명시적 ID 입력은 IDENTITY 내부 시퀀스를 자동 이동시키지 않습니다. `02_seed.sql`은 입력 후 `RESTART WITH`로 다음 값을 조정합니다.

Seed는 다음 경계 사례를 포함합니다.

```text
질문 없는 학생 1명
연결되지 않은 자료 1건
답변 없는 open 질문 1건
답변이 2개인 질문 1건
2026년 1~5월에 분산된 질문
```

`content_hash`의 `demo-sha256-*` 값은 실제 SHA-256 계산값이 아니라 가상 예시입니다.

---

## 7. 관계와 시간 정합성을 검증한다

`04_requirement_queries.sql`은 정상 JOIN과 다음 이상을 확인합니다.

```text
고아 질문·답변·튜터·자료 연결
answered인데 답변 없음
표시 순서 중복
질문 작성일 < 학생 가입일
답변 작성 시각 < 질문 작성 시각
답변 작성 시각 < 튜터 생성 시각
자료 연결 시각 < 질문 작성 시각
```

테이블 내부 시간 관계는 CHECK로, 여러 테이블이 필요한 관계는 검증 SQL로 확인합니다.

`is_active`와 상태 조합은 현재 모든 상황을 DB 제약으로 고정하지 않습니다. 비활성 사용자의 신규 작업과 closed 질문 답변은 후속 업무 정책입니다.

---

## 8. 트랜잭션은 정상·실패·ROLLBACK을 모두 증명한다

`05_transaction_checks.sql`은 질문 303의 답변 등록과 상태 변경을 한 트랜잭션으로 실행합니다.

```text
실행 전: answers 5, question 303 open
트랜잭션 내부: answers 6, question 303 answered
ROLLBACK 후: answers 5, question 303 open
```

상태 UPDATE는 다음처럼 기존 상태를 조건으로 사용합니다.

```sql
UPDATE tutor_project.questions
SET status = 'answered', updated_at = ...
WHERE id = 303
  AND status = 'open'
RETURNING id;
```

영향 행 수가 1이 아니면 성공으로 판단하지 않습니다. 잘못된 tutor 때문에 답변 INSERT가 실패하는 경로에서는 상태 변경도 남지 않아야 합니다.

---

## 9. 반례는 오류 종류와 제약조건 이름까지 확인한다

`06_negative_tests.sql`은 공통 실행 함수를 사용해 다음 증거를 기록합니다.

```text
expected_sqlstate / actual_sqlstate
expected_constraint / actual_constraint
actual_table / actual_column
actual_result / detail
```

실패 반례 18개와 정상 경계값 5개를 실행합니다.

```text
중복 이메일
없는 부모 FK
잘못된 상태·자료 유형·접근 범위
빈 이메일·코드·제목·답변·URL
잘못된 시간 순서
중복 자료 연결·표시 순서
한 글자 이름
NULL source_url·note
질문별 복수 답변
같은 튜터 복수 답변 정책 관찰
```

기대 결과:

```text
전체 23
통과 23
unexpected 0
기준 행 수 유지
```

오류만 시험하면 제약조건이 정상값까지 과도하게 막는 문제를 발견하기 어렵습니다. 정상 경계값도 반드시 포함합니다.

---

## 10. 인덱스는 후보 검토와 실제 효과 검증을 구분한다

| 인덱스 | 조회 패턴 |
| --- | --- |
| `questions(student_id, status, created_at DESC)` | 학생별 상태별 질문 |
| `answers(question_id, created_at)` | 질문별 답변 시간순 조회 |
| `question_materials(material_id)` | 자료별 질문 조회 |

`07_performance_checks.sql`은 인덱스 정의와 대표 EXPLAIN을 검토합니다. 작은 Seed에서 Seq Scan이 선택되어도 자동 오류가 아닙니다.

실제 효과 검증에는 다음이 추가로 필요합니다.

```text
운영과 유사한 데이터 크기·분포
인덱스 전·후 동일 SQL
EXPLAIN (ANALYZE, BUFFERS)
실행 시간·버퍼와 쓰기 비용
락·배포 방식과 최종 유지 결정
```

---

## 11. PUBLIC·소유권·데이터 분류를 구분한다

`08_operations_checks.sql`은 다음을 확인합니다.

```text
DB CONNECT와 pg_database.datacl
schema owner·nspacl
테이블·VIEW·시퀀스 owner와 ACL
직접 테이블·컬럼 GRANT
PUBLIC table_privileges·column_privileges
현재 사용자의 최종 has_*_privilege
가상 이메일·URL·해시 규칙
```

`information_schema.role_table_grants`만으로 PUBLIC 권한을 확인하지 않습니다.

`learning_materials.access_scope`의 `public·internal·restricted`는 업무 분류 값입니다. 이 값만으로 SELECT를 차단하지 않으며 Role·VIEW·RLS 같은 실제 접근 통제가 필요합니다.

Python 연결 정보는 다음 변수로 관리합니다.

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
```

실제 password file은 저장소 밖에 둡니다.

---

## 12. 백업은 별도 DB 복원으로 증명한다

Runbook은 도구·서버 버전, 백업 계정 권한, RLS와 스키마 외부 의존성을 먼저 확인합니다.

```bash
pg_dump \
  -U <backup_user> \
  -d ai_database_book \
  -Fc \
  --schema=tutor_project \
  --no-owner \
  --no-privileges \
  -f <backup-dir>/tutor_project.backup
```

복원 역할이 소유하는 깨끗한 DB를 만듭니다.

```bash
createdb \
  -U <admin_user> \
  -O <restore_user> \
  -T template0 \
  tutor_project_restore
```

```bash
pg_restore \
  -U <restore_user> \
  -d tutor_project_restore \
  --single-transaction \
  --no-owner \
  --no-privileges \
  <backup-dir>/tutor_project.backup
```

복원 DB에서만 `11_restore_validation.sql`을 실행합니다.

검증 범위:

```text
6개 테이블·5개 시퀀스·4개 VIEW
행 수·제약조건·인덱스·시간 정합성
IDENTITY 다음 값
복원 객체 owner
질문·학생·튜터 분석 VIEW
```

원본 DB에서 `11`을 실행하면 중단됩니다.

---

## 13. 분석 기간과 행 단위를 고정한다

분석 기간은 다음 반개방 구간입니다.

```text
[2026-01-01 00:00+09, 2026-06-01 00:00+09)
```

`09_analysis_dataset.sql`은 네 VIEW를 사용합니다.

```text
analysis_parameters
question_analysis_dataset       한 행 = 질문 1건
student_question_summary        한 행 = 학생 1명, 질문 0건 포함
tutor_answer_summary            한 행 = 튜터 1명, 답변 0건 포함
```

질문 VIEW만으로 학생별 집계를 만들면 질문이 없는 학생이 사라집니다. 튜터 차원도 질문 VIEW에 없으므로 별도 요약 VIEW 또는 원본 LEFT JOIN이 필요합니다.

분석 질문:

```text
P15-Q01 상태별 질문 수
P15-Q02 학생별 질문 수, 0건 포함
P15-Q03 튜터별 답변 수, 0건 포함
P15-Q04 월별 질문·답변·자료 수
P15-Q05 질문별 답변·자료 수
P15-Q06 첫 답변 시간
```

월별 집계는 date spine을 사용해 데이터가 없는 월도 0건으로 유지합니다.

기준 결과:

```text
상태: answered 3, closed 1, open 1
학생 질문 수: 2, 1, 2, 0
튜터 답변 수: 2, 1, 2
2026년 1~5월 질문 각 1건
첫 답변: 4건, 평균 2.00시간, 최소 0.50, 최대 3.50
```

---

## 14. 실제 SQL과 pandas 결과를 같은 스냅샷에서 비교한다

Python 공통 모듈은 다음을 확인합니다.

```text
DB = ai_database_book
transaction_read_only = on
분석 VIEW 존재
정확한 13개 컬럼
날짜·숫자·boolean 엄격 변환
question_id 중복 없음
has_answer·has_material과 건수 일치
답변 없음 → 첫 답변 시각·시간 NULL
첫 답변 시간 음수 없음
```

하나의 `REPEATABLE READ, READ ONLY` 연결에서 다음을 함께 읽습니다.

```text
원본 students·questions·tutors·answers
질문 분석 VIEW
실제 SQL 상태·월·학생·튜터·첫 답변 요약
```

pandas가 만든 결과와 `pandas.testing.assert_frame_equal()`로 직접 비교합니다. Python 코드에 복사한 기대 상수만 비교하는 방식이 아닙니다.

---

## 15. 완료 게이트와 전체 프로젝트 완료를 분리한다

![최종 완료 판단 게이트](../../images/chapter15/ch15_08_completion_checklist.svg)

그림 15-8 최종 완료 판단 게이트

`10_completion_gate.sql`은 하나라도 다르면 예외를 발생시킵니다.

```text
정확한 테이블·VIEW·제약조건·FK·인덱스
기준 행 수와 IDENTITY 다음 값
트랜잭션 ROLLBACK
핵심 반례 14개
업무·시간 정합성
상태·월별·첫 답변 분석 기준
가상 데이터·CASCADE 기준
```

통과 메시지:

```text
Chapter 15 database completion gate passed
```

전체 완료는 다음 증거를 따로 확인합니다.

| 단계 | 증거 |
| --- | --- |
| DB 완료 | `10` 통과 |
| Python 완료 | 실제 SQL·pandas 요약 5종 일치 |
| 복구 완료 | 백업·별도 DB 복원·`11` 통과 |
| 권한 완료 | 실제 Role 허용·차단 시험 |
| 문서 완료 | 요구사항·ERD·보고서·AI diff 사람 승인 |

미실행 항목은 통과로 표시하지 않습니다.

---

## 16. AI 변경은 diff와 실행 증거로 검토한다

![AI 제안 검토·수정·재실행 루프](../../images/chapter15/ch15_05_ai_review_loop.svg)

그림 15-5 AI 제안 검토·수정·재실행 루프

```text
요구사항·수정 범위 제공
→ AI가 SQL·Python·문서 초안 제안
→ 파일별 diff 확인
→ 격리 환경 실행
→ PostgreSQL 카탈로그·반례·게이트 검증
→ DataFrame 자료형·행 단위·SQL 결과 비교
→ 별도 DB 복원 검증
→ 사람이 최종 승인
```

검토 항목:

```text
요청하지 않은 파일 변경
근거 없는 UNIQUE·CASCADE·트리거·RLS
파괴적인 SQL과 잘못된 DB
접속 정보·password file 노출
임의 dropna·drop_duplicates·errors=coerce
분석 기간·행 단위 변경
미실행 항목을 통과로 표시하는 표현
```

---

## 17. 프로젝트 완성도의 일곱 축

![프로젝트 완성도의 일곱 축](../../images/chapter15/ch15_06_completion_dimensions.svg)

그림 15-6 프로젝트 완성도의 일곱 축

```text
1. 문제와 범위
2. 요구사항·정책과 설계 일관성
3. 재현 가능한 데이터·SQL·Python
4. 정상·경계·오류·시간·트랜잭션 증거
5. 성능·권한·보안·백업·복구 계획
6. AI diff·실행 결과·사람 승인
7. 남은 한계와 다음 버전
```

![설계 결정과 검증 근거를 설명하는 흐름](../../images/chapter15/ch15_07_project_story_flow.svg)

그림 15-7 설계 결정과 검증 근거를 설명하는 흐름

---

## 18. 자주 하는 실수

```text
기술 목록을 프로젝트 목표로 삼는다.
생성·초기화 파일에서 현재 DB를 확인하지 않는다.
명시적 ID 뒤 IDENTITY를 조정하지 않는다.
테이블·FK 개수만 보고 정확한 구조라고 판단한다.
정상 조회만 실행하고 실패·경계값을 생략한다.
SQLSTATE만 보고 의도한 제약조건이라고 단정한다.
access_scope 값을 실제 접근 권한으로 오해한다.
작은 Seed의 실행 계획만으로 인덱스 효과를 단정한다.
질문 VIEW만으로 질문 0건 학생을 분석한다.
Python 상수와 비교하면서 실제 SQL 교차 검증이라고 부른다.
DB 게이트 통과를 복원·권한·Python 완료로 확대 해석한다.
AI가 수정한 diff를 자동 승인한다.
```

---

## 19. 책 전체의 개념을 연결한다

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

이후에는 웹 API, ORM·마이그레이션, 실제 인증·권한, NoSQL 연동, 자동화 테스트, 클라우드 배포와 대규모 분석으로 확장할 수 있습니다.

```text
데이터베이스 프로젝트의 완성은 SQL이나 그래프를 만드는 순간이 아니라,
다른 사람이 같은 절차로 실행하고 같은 근거를 확인할 수 있을 때 시작된다.
```
