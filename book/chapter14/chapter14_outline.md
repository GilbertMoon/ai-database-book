# Chapter 14 구성안

## 제목

SQL 데이터 분석과 Python 확장

## 권장 분량

28~34페이지

## 이 장의 역할

Chapter 14는 앞 장까지 학습한 PostgreSQL·SQL·JOIN·집계·검증 능력을 데이터 분석으로 연결하고, SQL에서 만든 분석 데이터셋을 Python과 pandas로 확장하는 장입니다.

```text
분석 질문 정의
→ 데이터 범위와 행 단위 확정
→ SQL 필터·JOIN·집계
→ 데이터 품질 점검
→ 분석용 VIEW 생성
→ CSV 또는 PostgreSQL 연결
→ pandas 가공·피벗·시각화
→ SQL·Python 결과 교차 검증
```

## 핵심 메시지

> SQL은 데이터베이스에서 분석 범위와 관계를 정확하게 확정하고, Python은 그 결과를 추가 가공·시각화·분석하는 도구다. 두 결과가 같은 기준값을 만드는지 검증해야 한다.

## 핵심 질문

```text
분석 질문과 기간·단위·기대 결과가 정의되었는가?
JOIN 경로와 집계 단위가 요구사항에 맞는가?
NULL·중복·고아·업무 규칙을 집계 전에 확인했는가?
분석용 데이터셋에서 한 행의 의미가 명확한가?
SQL에서 처리할 작업과 Python에서 처리할 작업을 구분했는가?
CSV 또는 DB 연결 후 DataFrame 행 수와 자료형을 확인했는가?
SQL과 pandas의 건수·합계·평균이 일치하는가?
그래프의 축·단위·기간이 해석을 왜곡하지 않는가?
AI가 만든 SQL·Python 코드와 diff를 사람이 검토했는가?
```

## 실습 스키마

```text
analysis_lab.students
analysis_lab.instructors
analysis_lab.courses
analysis_lab.enrollments
analysis_lab.enrollment_analysis_dataset VIEW
```

보호 대상:

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
public
```

## 기준 데이터

```text
students 8
instructors 3
courses 5
enrollments 24
분석 데이터셋 24행
```

상태별 기준:

```text
완료 12
수강중 5
신청 4
취소 3
```

월별 신청 건수:

```text
2026-01 3
2026-02 4
2026-03 5
2026-04 4
2026-05 4
2026-06 4
```

검산 기준:

```text
전체 수강신청 24
결제금액 합계 2,770,000
완료 수강 12
평균 완료 기간 25일
PK 중복 0
고아 FK 0
상태·완료일 이상 0
```

## 핵심 개념

- 분석 질문
- 분석 대상과 기간
- 분석 단위와 행 단위
- SQL 필터·JOIN·집계
- `COUNT(*)`와 `COUNT(column)`
- `COUNT(DISTINCT ...)`
- `GROUP BY`, `HAVING`
- `DATE_TRUNC`
- 윈도 함수 `LAG`
- NULL과 업무 의미
- 중복·고아·정합성 점검
- 분석용 VIEW
- 원본 데이터와 파생 데이터셋
- CSV 내보내기
- PostgreSQL·Python 연결
- 환경변수와 `.env`
- pandas DataFrame
- `groupby`, `agg`, `pivot_table`
- matplotlib 시각화
- SQL·Python 교차 검증
- 분석 결과의 관찰·해석·한계
- AI 생성 분석 코드 검토

## 본문 구성

1. 분석 질문을 먼저 정의한다
2. SQL과 Python의 역할을 구분한다
3. Chapter 14 실습 구조
4. 분석 실습 데이터 이해하기
5. 분석 전에 데이터 품질을 확인한다
6. JOIN·필터·집계로 분석한다
7. 기간별 분석을 수행한다
8. 분석용 데이터셋을 만든다
9. DBeaver에서 CSV로 내보낸다
10. Python 분석 환경을 준비한다
11. CSV를 pandas로 읽는다
12. PostgreSQL과 Python을 연결한다
13. pandas로 집계한다
14. 간단한 시각화로 확장한다
15. SQL 결과와 Python 결과를 교차 검증한다
16. 분석 결과를 해석한다
17. AI가 만든 분석 코드를 검토한다
18. 자주 하는 실수
19. 스스로 확인하기
20. 핵심 정리
21. 다음 장 연결

## 코드·문서 파일

```text
code/chapter14/
├── 01_analysis_lab_schema.sql
├── 02_analysis_lab_seed.sql
├── 03_data_quality_checks.sql
├── 04_summary_analysis.sql
├── 05_period_category_analysis.sql
├── 06_analysis_dataset.sql
├── 07_analysis_validation.sql
├── reset_analysis_lab.sql
├── python/
│   ├── requirements.txt
│   ├── .env.example
│   ├── 01_load_csv.py
│   ├── 02_load_postgresql.py
│   ├── 03_pandas_analysis.py
│   └── 04_result_validation.py
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_analysis_lab_schema.sql` | 전용 분석 스키마와 네 테이블 생성 |
| `02_analysis_lab_seed.sql` | 기간·상태·지역·강의 분석용 기준 데이터 입력 |
| `03_data_quality_checks.sql` | 행 수·중복·고아 FK·상태·날짜·금액 점검 |
| `04_summary_analysis.sql` | 상태·강의·지역별 기본 집계 |
| `05_period_category_analysis.sql` | 월별·범주별 분석과 이전 기간 비교 |
| `06_analysis_dataset.sql` | 수강신청 1건 단위 분석 VIEW 생성 |
| `07_analysis_validation.sql` | SQL 기준값과 완료 게이트용 검산 |
| `01_load_csv.py` | DBeaver에서 내보낸 CSV 읽기·구조 확인 |
| `02_load_postgresql.py` | 환경변수로 PostgreSQL VIEW 읽기 |
| `03_pandas_analysis.py` | 상태·월·강의 분석과 피벗·그래프 |
| `04_result_validation.py` | SQL 기준값과 pandas 결과 자동 비교 |
| `reset_analysis_lab.sql` | analysis_lab만 선택적으로 초기화 |

## 이미지 구성

```text
ch14_01_analysis_workflow.svg
ch14_02_sql_python_role_split.svg
ch14_03_sql_aggregation_flow.svg
ch14_04_data_quality_checks.svg
ch14_05_analysis_dataset_pipeline.svg
ch14_06_postgresql_python_connection.svg
ch14_07_pandas_analysis_flow.svg
ch14_08_analysis_result_validation.svg
```

## 안전성 원칙

- 앞 장의 스키마와 데이터를 변경하지 않는다.
- 생성 SQL에서 자동 `DROP`을 실행하지 않는다.
- 운영 DB가 아닌 개발·테스트 DB를 사용한다.
- 분석 코드에서 원본 테이블 변경 SQL을 자동 실행하지 않는다.
- 비밀번호와 접속 URL을 코드·노트북·화면 캡처에 남기지 않는다.
- `.env`와 실제 분석 데이터 파일을 저장소에 무조건 커밋하지 않는다.
- Python에서 중복·NULL을 임의 제거해 오류를 숨기지 않는다.
- SQL과 Python 결과가 다르면 기대값을 바꾸기 전에 원인을 확인한다.
- 검증하지 않은 분석 결과를 통과로 기록하지 않는다.

## AI 활용 원칙

- 분석 질문·기간·행 단위·기대값을 AI에 제공한다.
- PK·FK와 JOIN 경로를 함께 제공한다.
- SQL과 Python의 수정 대상과 금지 범위를 명시한다.
- 파괴적인 SQL과 접속 정보 노출을 확인한다.
- `dropna`, `drop_duplicates`가 오류를 숨기지 않는지 확인한다.
- SQL 기준값과 별도 검산 쿼리로 결과를 비교한다.
- 그래프보다 행 수·건수·합계·평균 검증을 우선한다.
- AI 결과는 diff와 실행 증거를 확인한 후 사람이 승인한다.

## 다음 장 연결

Chapter 15에서는 요구사항, ERD, SQL 구현, 트랜잭션, 성능, 운영, AI 검토와 SQL·Python 데이터 분석을 하나의 재현 가능한 데이터베이스 종합 프로젝트로 통합합니다.
