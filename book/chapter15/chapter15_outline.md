# Chapter 15 구성안

## 제목

데이터베이스 종합 프로젝트

## 권장 분량

30~36페이지

## 이 장의 역할

Chapter 15는 책 전체에서 학습한 요구사항 분석, ERD, PostgreSQL 구현, SQL 검증, 운영 계획, AI 검토와 SQL·Python 분석을 `tutor_project` 예제로 통합하는 장입니다.

```text
문제·범위
→ 요구사항·미확정 정책
→ ERD·DDL
→ 기준 데이터
→ 메타데이터·업무 조회
→ 트랜잭션·반례
→ 인덱스·운영·복구
→ 분석용 데이터셋
→ SQL·Python 분석
→ AI diff 검토
→ 완료 게이트
```

## 핵심 메시지

> 데이터베이스 프로젝트는 SQL이 실행되는 것으로 끝나지 않는다. 설계와 데이터가 요구사항에 맞고, SQL과 Python 분석 결과가 일치하며, 다른 사람이 같은 절차로 재현할 수 있어야 한다.

## 핵심 질문

```text
필수 범위와 선택 확장이 구분되어 있는가?
요구사항 ID가 ERD·DDL·검증 SQL과 연결되는가?
전용 스키마와 명시적 ID로 재현할 수 있는가?
정상·경계·반례·트랜잭션을 모두 검증하는가?
실제 메타데이터와 업무 정합성이 기대와 일치하는가?
인덱스가 실제 조회 패턴을 근거로 하는가?
비밀·권한·백업·복원 계획이 있는가?
분석 데이터셋의 한 행 단위가 명확한가?
SQL과 pandas의 핵심 집계가 일치하는가?
AI 변경을 diff와 실행 증거로 검토하는가?
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
tutor_project.question_analysis_dataset VIEW
```

보호 대상:

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
analysis_lab
public
```

## 기준 데이터와 분석 기준

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
분석 VIEW 5행
answer_count 합계 5
material_count 합계 7
question_id 중복 0
```

## 핵심 개념

- 필수 경로와 선택 확장
- 요구사항 추적과 미확정 정책
- 전용 스키마와 명시적 ID
- ERD·DDL·메타데이터 정합성
- 정상·경계·오류 데이터
- 트랜잭션·ROLLBACK
- 자동 반례 테스트
- 인덱스·EXPLAIN
- 최소 권한·비밀 관리
- 백업·복원·RPO·RTO
- 분석 질문과 행 단위
- 분석용 VIEW
- PostgreSQL·Python 연결
- pandas `groupby`와 결과 검증
- AI 생성 SQL·Python 코드 검토
- 완료·조건부 완료·보류·미완료

## 본문 구성

1. 필수 경로와 선택 확장
2. 재현 가능한 파일 구조
3. 문제·사용자·범위
4. 요구사항·미확정 정책
5. ERD·DDL 추적
6. 전용 스키마
7. 검증·분석 시나리오 데이터
8. 실제 메타데이터
9. 요구사항 조회와 분석 질문
10. 트랜잭션·반례
11. 인덱스·운영 안전성
12. 분석용 데이터셋
13. AI diff와 실행 증거 검토
14. 프로젝트 완성도의 일곱 축
15. 최종 보고서와 완료 게이트
16. 자주 하는 실수
17. 책 전체 연결

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

| 파일 | 역할 |
| --- | --- |
| `01_schema.sql` | 전용 스키마·테이블·제약·업무 인덱스 생성 |
| `02_seed.sql` | 명시적 ID와 고정 시각 기준 데이터 입력 |
| `03_metadata_validation.sql` | 테이블·FK·PK·CHECK·인덱스·CASCADE 검증 |
| `04_requirement_queries.sql` | REQ별 JOIN·집계·경계·정합성 조회 |
| `05_transaction_checks.sql` | 답변 등록·상태 변경·ROLLBACK 검증 |
| `06_negative_tests.sql` | 자동 반례와 기준 행 유지 확인 |
| `07_performance_checks.sql` | 인덱스 존재와 대표 EXPLAIN |
| `08_operations_checks.sql` | 권한·비밀·백업·복구 계획 점검 |
| `09_analysis_dataset.sql` | 질문 1건 단위 분석 VIEW와 SQL 기준값 생성 |
| `10_completion_gate.sql` | DB 구조·기준 데이터·분석 VIEW 최종 판정 |
| `python/01_load_postgresql.py` | 환경변수로 분석 VIEW 읽기 |
| `python/02_pandas_analysis.py` | 상태·월·학생별 분석 |
| `python/03_result_validation.py` | SQL 기준값과 pandas 결과 비교 |
| `analysis_report.md` | 분석 질문·결과·해석·한계 기록 |

## 안전성 원칙

- 생성 파일에서 자동 `DROP`을 실행하지 않는다.
- 모든 객체에 `tutor_project` 스키마를 명시한다.
- 샘플은 명시적 ID와 고정 시각을 사용한다.
- CASCADE와 Role 변경을 자동 적용하지 않는다.
- 반례는 기준 데이터를 유지하도록 실행한다.
- 실제 개인정보·비밀·접속 URL·백업·운영 CSV를 커밋하지 않는다.
- Python에서 중복·NULL을 임의 제거해 오류를 숨기지 않는다.
- SQL과 Python 결과가 다르면 기대값을 바꾸기 전에 원인을 확인한다.

## AI 활용 원칙

- 요구사항·분석 질문·행 단위·기대값을 제공한다.
- PK·FK와 JOIN 경로를 함께 제공한다.
- SQL과 Python의 수정·금지 범위를 명시한다.
- 파괴적인 SQL과 접속 정보 노출을 확인한다.
- 파일별 diff와 실제 실행 결과를 사람이 검토한다.

## 책의 마무리

재현 가능한 실행 절차, SQL·Python 분석 증거와 남은 한계를 남기는 것을 프로젝트의 최종 완료 기준으로 삼습니다.
