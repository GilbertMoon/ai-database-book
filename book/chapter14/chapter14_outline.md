# Chapter 14 구성안

## 제목

SQL 데이터 분석과 Python 확장

## 권장 분량

30~36페이지

## 이 장의 역할

Chapter 14는 앞 장까지 학습한 PostgreSQL·SQL·JOIN·집계·검증 능력을 데이터 분석으로 연결하고, SQL에서 확정한 분석 데이터셋을 Python과 pandas로 확장한 뒤 실제 SQL 결과와 교차 검증하는 장입니다.

```text
분석 질문·P14 ID
→ 기간·행 단위·지표 의미 확정
→ SQL 필터·JOIN·집계
→ 데이터 품질 점검
→ 기간 제한 분석 VIEW
→ CSV manifest 또는 읽기 전용 DB 연결
→ pandas 가공·date spine·피벗·시각화
→ 실제 SQL·pandas 교차 검증
→ 관찰·해석·한계 기록
```

## 핵심 메시지

> SQL은 분석 범위·관계·행 단위를 확정하고, Python은 그 결과를 확장한다. 같은 기간과 데이터 스냅샷의 실제 SQL 결과와 pandas 결과가 일치해야 한다.

## P14 분석 질문

```text
P14-Q01 상태별 수강신청 건수
P14-Q02 월별 신청 수와 신청 시점 기록 금액
P14-Q03 강의별 신청 건수
P14-Q04 지역별 학생·신청 건수
P14-Q05 완료된 신청의 완료 기간
```

## 핵심 결정

```text
분석 기간 = [2026-01-01, 2026-07-01)
날짜 기준 = enrolled_at
행 단위 = 수강신청 1건
recorded_amount 의미 = 신청 시점 기록 금액
분석 VIEW 금액 컬럼 = recorded_amount
취소 후에도 신청 시점 기록 금액 유지
월별 분석 = date spine으로 1~6월 유지
현재 완료 상태 비중 ≠ 코호트 완료율
```

## 실습 객체

```text
analysis_lab.students
analysis_lab.instructors
analysis_lab.courses
analysis_lab.enrollments
analysis_lab.analysis_parameters VIEW
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

## 격리 분석 시나리오

`analysis_lab`은 분석 연습을 위한 합성 기준 데이터이며 `course_project`를 변경·복제한 운영 데이터가 아니다. 금액 의미는 `recorded_amount NUMERIC(12,0)` = 신청 시점 기록 금액으로 이어 간다.

## 기준 데이터

```text
students 8
instructors 3
courses 5
enrollments 24
분석 데이터셋 24
기록 금액 합계 3,210,000
```

상태:

```text
신청 4
수강중 5
완료 12
취소 3
```

월별:

```text
2026-01 3 / 350000
2026-02 4 / 520000
2026-03 5 / 680000
2026-04 4 / 550000
2026-05 4 / 540000
2026-06 4 / 570000
```

완료된 신청:

```text
12건
평균 25일
최소 18일
최대 36일
```

## 무결성·품질 규칙

```text
PK·FK·상태·금액·완료일 CHECK
같은 날짜 동일 원천 행 UNIQUE
신청·수강중 활성 신청 부분 고유 인덱스
신청일 >= 학생 가입일
신청일 >= 강의 개설일
완료일 >= 신청일
분석 기간 밖 기준 행 0
```

## 핵심 개념

- 분석 질문과 지표 정의
- 반개방 날짜 구간
- 분석 행 단위
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT ...)`
- JOIN 후 중복과 과대 집계
- `DATE_TRUNC`
- date spine과 `generate_series`
- `LAG`
- NULL의 업무 의미
- 현재 완료 상태 비중과 완료율
- 완료된 행만의 기간 통계 한계
- 분석 VIEW
- CSV manifest와 SHA-256
- libpq password file·`PGPASSFILE`
- SQLAlchemy `URL.create()`
- 읽기 전용 연결
- pandas strict 자료형 검증
- `errors="raise"`
- matplotlib `Agg`와 한글 글꼴 경고
- 실제 SQL DataFrame·pandas DataFrame 비교
- `REPEATABLE READ`
- `assert_frame_equal`
- AI 분석 코드 검토

## 본문 구성

1. 분석 질문 정의
2. 금액 지표 의미
3. SQL·Python 역할
4. 실습 구조
5. 생성·Seed·reset 안전성
6. 활성 신청과 중복 적재
7. 분석 기간 관리
8. 기준 데이터
9. 데이터 품질
10. JOIN·집계 기본 흐름
11. COUNT 계열 함수
12. 강의·강사·지역 분석
13. date spine
14. LAG 이전 달 비교
15. 완료 상태 비중과 완료율
16. 완료 기간과 해석 한계
17. 분석 데이터셋
18. SQL 최종 게이트
19. CSV와 manifest
20. Python 환경
21. libpq 변수와 읽기 전용 연결
22. 공통 DataFrame 검증
23. pandas 분석
24. 헤드리스 시각화
25. 실제 SQL·pandas 교차 검증
26. 불일치 원인 확인
27. 관찰·해석·한계
28. AI 코드 검토
29. 자주 하는 실수
30. 스스로 확인하기
31. 권장 해설
32. 핵심 정리와 다음 장

## 코드 파일

```text
code/chapter14/
├── 01_analysis_lab_schema.sql
├── 02_analysis_lab_seed.sql
├── 03_data_quality_checks.sql
├── 04_summary_analysis.sql
├── 05_period_category_analysis.sql
├── 06_analysis_dataset.sql
├── 07_analysis_validation.sql
├── 08_analysis_lab_validation.sql
├── reset_analysis_lab.sql
├── python/
│   ├── requirements.txt
│   ├── .env.example
│   ├── validation_utils.py
│   ├── 01_load_csv.py
│   ├── 02_load_postgresql.py
│   ├── 03_pandas_analysis.py
│   ├── 04_result_validation.py
│   ├── reference_metrics.json
│   └── analysis_manifest.example.json
└── README.md
```

## 파일 역할

| 파일 | 역할 |
| --- | --- |
| 01 | DB 보호·원자적 구조·기간 VIEW·활성 인덱스 |
| 02 | 빈 상태 검사·원자적 Seed·IDENTITY·기준 판정 |
| 03 | 중복·고아·상태·시간 관계·기간 품질 |
| 04 | 기간 제한 상태·강의·강사·지역 집계 |
| 05 | date spine·LAG·범주·완료 비중·완료 기간 |
| 06 | 기간 제한 수강신청 1건 단위 VIEW |
| 07 | 상세 SQL 증거 조회 |
| 08 | 예외 기반 최종 SQL 게이트 |
| validation_utils.py | 컬럼·자료형·기간·연결·manifest 공통 검증 |
| 01_load_csv.py | CSV와 선택적 manifest 확인 |
| 02_load_postgresql.py | 읽기 전용 DB 적재와 CSV·manifest 생성 |
| 03_pandas_analysis.py | pandas 분석과 헤드리스 그래프 |
| 04_result_validation.py | 실제 SQL·pandas 직접 비교 |
| reference_metrics.json | CSV 경로 SQL 기준값 |

## Python 검증 기준

```text
정확한 17개 컬럼
24행·고유 enrollment_id
strict 날짜·숫자·boolean
status·is_completed 일치
완료일·completion_days 일치
분석 기간 안의 행
errors='coerce'·임의 dropna·drop_duplicates 금지
```

## SQL·Python 교차 검증

```text
PostgreSQL 경로
→ 같은 읽기 전용 REPEATABLE READ 스냅샷
→ 실제 SQL 상태·월별·완료 기간 DataFrame
→ pandas DataFrame
→ assert_frame_equal

CSV 경로
→ CSV + 출처 manifest·SHA-256
→ reference_metrics.json
→ pandas 결과 비교
```

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

기존 8종의 개념 역할은 최종 내용과 호환되므로 파일명과 배치를 유지합니다.

## 안전 원칙

- 현재 DB와 대상 스키마를 실제 검사한다.
- 생성·Seed는 트랜잭션으로 처리한다.
- reset은 올바른 DB에서 명시적 객체만 삭제한다.
- 분석 기간을 SQL·VIEW·Python에 동일 적용한다.
- 원본 변경 SQL을 Python에서 실행하지 않는다.
- PostgreSQL 연결은 읽기 전용으로 설정한다.
- 비밀번호·전체 접속 URL·password file을 저장소에 기록하지 않는다.
- CSV·manifest·그래프 생성물은 저장소에서 제외한다.
- 잘못된 데이터는 coerce·drop으로 숨기지 않는다.
- SQL·Python 불일치 시 기대값을 변경하기 전에 원인을 찾는다.

## 다음 장 연결

Chapter 15에서는 요구사항·ERD·정규화·SQL·트랜잭션·성능·운영·AI 검토와 Chapter 14의 재현 가능한 SQL·Python 분석을 하나의 종합 프로젝트로 통합합니다.
