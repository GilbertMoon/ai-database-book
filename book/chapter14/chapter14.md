# Chapter 14. SQL 데이터 분석과 Python 확장

---

## 이 장에서 살펴볼 내용

Chapter 13에서는 ChatGPT와 Codex가 만든 데이터베이스 설계와 SQL을 격리된 환경에서 실행하고, 실제 메타데이터와 결과를 기준으로 검증하는 방법을 살펴봤습니다.

이번 장에서는 데이터베이스에 저장된 데이터를 **분석 질문에 맞게 SQL로 추출·집계하고, 그 결과를 Python과 pandas로 확장하는 과정**을 학습합니다.

```text
분석 질문 정의
→ 필요한 테이블과 관계 확인
→ SQL로 필터·JOIN·집계
→ 데이터 품질 확인
→ 분석용 데이터셋 생성
→ CSV 또는 PostgreSQL에서 Python으로 읽기
→ pandas로 가공·비교·시각화
→ SQL 결과와 Python 결과 교차 검증
```

SQL과 Python은 경쟁 관계가 아닙니다.

```text
SQL
- 데이터베이스 안에서 필요한 행과 열을 선택한다.
- JOIN과 집계를 서버에서 수행한다.
- 분석 데이터셋의 범위와 행 단위를 확정한다.

Python
- SQL 결과를 추가 가공한다.
- 피벗·시각화·통계 분석으로 확장한다.
- 여러 분석 결과를 자동으로 비교하고 검증한다.
```

이 장에서는 다음 내용을 다룹니다.

- 분석 질문과 분석 단위 정의
- SQL을 이용한 조건별·범주별 집계
- 기간별 분석과 증감 비교
- NULL·중복·누락·업무 규칙 점검
- 분석용 데이터셋과 VIEW 생성
- DBeaver에서 CSV로 내보내기
- PostgreSQL과 Python 연결
- pandas DataFrame의 행·열·자료형 확인
- `groupby`, `agg`, `pivot_table`을 이용한 분석
- matplotlib을 이용한 간단한 시각화
- SQL 결과와 Python 결과의 교차 검증
- AI가 작성한 분석 SQL과 Python 코드 검토

> **핵심 원칙**
>
> 분석 결과는 그래프가 보기 좋거나 코드가 오류 없이 실행된다는 이유만으로 신뢰하지 않습니다. 분석 질문, 데이터 범위, 행 단위, 집계 기준과 검산 결과가 서로 일치해야 합니다.

![SQL에서 Python으로 확장되는 데이터 분석 흐름](../../images/chapter14/ch14_01_analysis_workflow.svg)

그림 14-1 SQL에서 Python으로 확장되는 데이터 분석 흐름

---

## 1. 분석 질문을 먼저 정의한다

분석은 SQL 작성부터 시작하지 않습니다. 먼저 무엇을 확인하려는지 질문을 분명하게 정의해야 합니다.

온라인 강의 서비스의 수강 데이터를 분석한다고 가정하겠습니다.

```text
상태별 수강신청 건수는 얼마인가?
월별 수강신청은 어떻게 변했는가?
강의별 신청 건수와 결제금액은 얼마인가?
지역별 학생 수와 신청 건수는 어떻게 다른가?
완료된 수강의 평균 완료 기간은 얼마인가?
```

분석 질문을 정의할 때는 다음 항목을 함께 적습니다.

| 항목 | 확인 내용 |
| --- | --- |
| 분석 대상 | 학생, 강의, 수강신청 중 무엇을 분석하는가? |
| 분석 기간 | 전체 기간인가, 특정 월이나 연도인가? |
| 분석 단위 | 학생 1명, 강의 1개, 신청 1건 중 무엇이 한 행인가? |
| 비교 기준 | 상태, 지역, 강의, 월 중 어떤 기준으로 나누는가? |
| 기대 결과 | 행 수, 합계, 평균과 같은 검산 기준이 있는가? |

예를 들어 “월별 결제금액을 분석한다”라는 문장만으로는 충분하지 않습니다.

```text
기간: 2026년 1월부터 6월
분석 단위: 수강신청 1건
날짜 기준: enrolled_at
금액 기준: paid_amount
취소 건: paid_amount가 0인 기준 데이터로 포함
출력: 월별 신청 건수와 결제금액 합계
```

이 기준이 있어야 SQL과 Python에서 같은 결과를 만들 수 있습니다.

---

## 2. SQL과 Python의 역할을 구분한다

![SQL과 Python의 분석 역할 구분](../../images/chapter14/ch14_02_sql_python_role_split.svg)

그림 14-2 SQL과 Python의 분석 역할 구분

SQL은 데이터가 저장된 위치에서 필요한 범위를 줄이고 관계를 연결하는 데 강합니다. Python은 추출된 결과를 재구조화하고 시각화하거나 후속 분석으로 확장하는 데 강합니다.

| 작업 | SQL | Python |
| --- | --- | --- |
| 필요한 행과 열 선택 | 적합 | 가능하지만 원본 전체를 가져오면 비효율적 |
| 테이블 JOIN | 적합 | 가능하지만 관계와 중복을 별도로 관리해야 함 |
| 대규모 필터와 집계 | 적합 | 데이터 전송 후 처리하면 비용 증가 가능 |
| 데이터 품질 점검 | 적합 | 추가 검증에 적합 |
| 피벗과 재구조화 | 가능 | 편리 |
| 시각화 | 제한적 | 적합 |
| 통계·머신러닝 확장 | 제한적 | 적합 |
| 결과 자동 비교 | 가능 | 적합 |

권장 흐름은 다음과 같습니다.

```text
데이터베이스
→ SQL로 필요한 범위와 분석 단위 확정
→ 분석용 데이터셋 생성
→ Python으로 읽기
→ pandas 분석·시각화
→ SQL 기준값과 비교
```

원본 테이블 전체를 Python으로 가져온 뒤 모든 JOIN과 필터를 처리하는 방식은 입문 단계에서도 피하는 것이 좋습니다. 데이터가 커지면 전송량과 메모리 사용량이 늘고, 데이터베이스의 제약조건과 관계 정보를 분석 코드에서 다시 구현해야 할 수 있습니다.

---

## 3. Chapter 14 실습 구조

이 장은 앞 장의 스키마를 변경하지 않고 `analysis_lab` 전용 스키마를 사용합니다.

```text
course_project: 변경 금지
transaction_lab: 변경 금지
performance_lab: 변경 금지
security_lab: 변경 금지
nosql_lab: 변경 금지
ai_review_lab: 변경 금지
analysis_lab: Chapter 14 실습 대상
```

실습 테이블은 다음과 같습니다.

```text
analysis_lab.students
analysis_lab.instructors
analysis_lab.courses
analysis_lab.enrollments
```

관계:

```text
students 1 → N enrollments
courses 1 → N enrollments
instructors 1 → N courses
```

실습 파일:

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

권장 실행 순서:

```text
01 → 02 → 03 → 04 → 05 → 06 → 07
→ DBeaver CSV 내보내기 또는 Python PostgreSQL 연결
→ pandas 분석
→ SQL·Python 결과 비교
```

생성 파일에서는 자동 `DROP`을 실행하지 않습니다. 처음부터 다시 시작할 때만 `reset_analysis_lab.sql`의 내용을 확인한 후 선택적으로 실행합니다.

---

## 4. 분석 실습 데이터 이해하기

`analysis_lab`은 온라인 강의 서비스의 학생, 강사, 강의와 수강신청 데이터를 사용합니다.

기준 행 수:

| 테이블 | 기대 행 수 |
| --- | ---: |
| students | 8 |
| instructors | 3 |
| courses | 5 |
| enrollments | 24 |

수강신청 상태:

```text
신청
수강중
완료
취소
```

기준 데이터에는 다음 분석 상황이 포함됩니다.

```text
2026년 1월부터 6월까지의 수강신청
여러 지역의 학생
여러 분야와 난이도의 강의
완료·수강중·신청·취소 상태
완료일이 있는 신청과 없는 신청
취소 건의 결제금액 0
```

`enrollments`의 주요 컬럼은 다음과 같습니다.

| 컬럼 | 의미 |
| --- | --- |
| id | 수강신청 식별자 |
| student_id | 학생 FK |
| course_id | 강의 FK |
| enrolled_at | 신청일 |
| status | 신청 상태 |
| paid_amount | 결제금액 |
| completed_at | 완료일, 미완료 상태는 NULL 가능 |

NULL은 무조건 오류가 아닙니다. `신청`, `수강중`, `취소` 상태에서 `completed_at`이 NULL인 것은 자연스러울 수 있습니다. 반대로 `완료` 상태인데 `completed_at`이 NULL이면 정합성 문제입니다.

---

## 5. 분석 전에 데이터 품질을 확인한다

![분석 전 데이터 품질 점검](../../images/chapter14/ch14_04_data_quality_checks.svg)

그림 14-3 분석 전 데이터 품질 점검

집계 전에 원본 데이터가 분석 기준을 만족하는지 확인합니다.

### 행 수 확인

```sql
SELECT 'students' AS table_name, COUNT(*) AS row_count
FROM analysis_lab.students
UNION ALL
SELECT 'instructors', COUNT(*)
FROM analysis_lab.instructors
UNION ALL
SELECT 'courses', COUNT(*)
FROM analysis_lab.courses
UNION ALL
SELECT 'enrollments', COUNT(*)
FROM analysis_lab.enrollments;
```

### 기본키 중복 확인

기본키 제약조건이 있더라도 실제 조회로 중복이 없는지 확인하는 연습이 필요합니다.

```sql
SELECT id, COUNT(*) AS duplicate_count
FROM analysis_lab.enrollments
GROUP BY id
HAVING COUNT(*) > 1;
```

기대 결과는 0행입니다.

### 고아 FK 확인

```sql
SELECT e.*
FROM analysis_lab.enrollments e
LEFT JOIN analysis_lab.students s
    ON s.id = e.student_id
WHERE s.id IS NULL;
```

```sql
SELECT e.*
FROM analysis_lab.enrollments e
LEFT JOIN analysis_lab.courses c
    ON c.id = e.course_id
WHERE c.id IS NULL;
```

두 조회 모두 기대 결과는 0행입니다.

### 상태와 완료일의 정합성 확인

```sql
SELECT id, status, completed_at
FROM analysis_lab.enrollments
WHERE status = '완료'
  AND completed_at IS NULL;
```

```sql
SELECT id, status, completed_at
FROM analysis_lab.enrollments
WHERE completed_at IS NOT NULL
  AND status <> '완료';
```

### 결제금액 확인

```sql
SELECT id, status, paid_amount
FROM analysis_lab.enrollments
WHERE paid_amount < 0
   OR (status = '취소' AND paid_amount <> 0);
```

이 장의 기준 데이터에서는 위 정합성 이상 조회가 모두 0행이어야 합니다.

---

## 6. JOIN·필터·집계로 분석한다

![JOIN과 집계로 분석 결과 만들기](../../images/chapter14/ch14_03_sql_aggregation_flow.svg)

그림 14-4 JOIN과 집계로 분석 결과 만들기

분석 SQL의 기본 구조는 다음과 같습니다.

```text
분석 질문
→ 필요한 테이블 선택
→ JOIN 경로 확인
→ WHERE로 범위 제한
→ GROUP BY로 분석 단위 구성
→ 집계 함수 적용
→ ORDER BY로 결과 정렬
→ 기준값으로 검산
```

### 상태별 수강신청 건수

```sql
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM analysis_lab.enrollments
GROUP BY status
ORDER BY enrollment_count DESC, status;
```

기대 결과:

| status | enrollment_count |
| --- | ---: |
| 완료 | 12 |
| 수강중 | 5 |
| 신청 | 4 |
| 취소 | 3 |

상태별 건수 합계는 전체 수강신청 24건과 같아야 합니다.

### 강의별 신청 건수와 결제금액

```sql
SELECT
    c.id AS course_id,
    c.title,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.paid_amount), 0) AS paid_amount_sum
FROM analysis_lab.courses c
LEFT JOIN analysis_lab.enrollments e
    ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY enrollment_count DESC, c.id;
```

`LEFT JOIN`을 사용하면 신청이 없는 강의도 결과에 포함할 수 있습니다. `COUNT(*)`를 사용하면 강의만 존재하는 행도 1로 계산될 수 있으므로, 자식 테이블의 PK인 `COUNT(e.id)`를 사용합니다.

### 지역별 학생 수와 신청 건수

학생 수와 신청 수는 서로 다른 단위입니다. JOIN 이후 `COUNT(*)`만 사용하면 신청이 많은 학생 때문에 학생 수가 중복 계산될 수 있습니다.

```sql
SELECT
    s.region,
    COUNT(DISTINCT s.id) AS student_count,
    COUNT(e.id) AS enrollment_count
FROM analysis_lab.students s
LEFT JOIN analysis_lab.enrollments e
    ON e.student_id = s.id
GROUP BY s.region
ORDER BY enrollment_count DESC, s.region;
```

`COUNT(DISTINCT s.id)`와 `COUNT(e.id)`의 의미를 구분해야 합니다.

---

## 7. 기간별 분석을 수행한다

PostgreSQL의 `DATE_TRUNC`를 사용하면 날짜를 월 단위로 묶을 수 있습니다.

```sql
SELECT
    DATE_TRUNC('month', enrolled_at)::date AS enrollment_month,
    COUNT(*) AS enrollment_count,
    SUM(paid_amount) AS paid_amount_sum
FROM analysis_lab.enrollments
GROUP BY DATE_TRUNC('month', enrolled_at)
ORDER BY enrollment_month;
```

기대 결과:

| 월 | 신청 건수 | 결제금액 합계 |
| --- | ---: | ---: |
| 2026-01 | 3 | 200000 |
| 2026-02 | 4 | 520000 |
| 2026-03 | 5 | 540000 |
| 2026-04 | 4 | 550000 |
| 2026-05 | 4 | 390000 |
| 2026-06 | 4 | 570000 |

월별 신청 건수 합계는 24, 결제금액 합계는 2,770,000이어야 합니다.

### 이전 달과 비교하기

윈도 함수 `LAG`를 사용하면 이전 행의 값을 가져올 수 있습니다.

```sql
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', enrolled_at)::date AS enrollment_month,
        COUNT(*) AS enrollment_count
    FROM analysis_lab.enrollments
    GROUP BY DATE_TRUNC('month', enrolled_at)
)
SELECT
    enrollment_month,
    enrollment_count,
    LAG(enrollment_count) OVER (ORDER BY enrollment_month) AS previous_count,
    enrollment_count
        - LAG(enrollment_count) OVER (ORDER BY enrollment_month) AS count_change
FROM monthly
ORDER BY enrollment_month;
```

첫 달은 비교할 이전 달이 없으므로 `previous_count`와 `count_change`가 NULL입니다. 이 NULL은 오류가 아니라 분석상 자연스러운 값입니다.

### 완료 기간 분석

```sql
SELECT
    COUNT(*) AS completed_count,
    ROUND(AVG(completed_at - enrolled_at), 2) AS avg_completion_days,
    MIN(completed_at - enrolled_at) AS min_completion_days,
    MAX(completed_at - enrolled_at) AS max_completion_days
FROM analysis_lab.enrollments
WHERE status = '완료';
```

기준 데이터에서는 완료 12건, 평균 완료 기간 25일을 기대합니다.

---

## 8. 분석용 데이터셋을 만든다

![업무 테이블에서 분석용 데이터셋 만들기](../../images/chapter14/ch14_05_analysis_dataset_pipeline.svg)

그림 14-5 업무 테이블에서 분석용 데이터셋 만들기

Python에서 사용할 데이터는 행 단위와 컬럼 의미가 명확해야 합니다.

이 장의 분석 데이터셋은 **수강신청 1건을 한 행**으로 정의합니다.

```text
한 행 = enrollments.id 한 건
```

분석 데이터셋에 포함할 컬럼:

```text
enrollment_id
student_id
student_name
region
course_id
course_title
category
level
enrolled_at
enrollment_month
status
paid_amount
completed_at
completion_days
is_completed
```

`06_analysis_dataset.sql`은 다음 VIEW를 생성합니다.

```sql
CREATE VIEW analysis_lab.enrollment_analysis_dataset AS
SELECT
    e.id AS enrollment_id,
    s.id AS student_id,
    s.name AS student_name,
    s.region,
    c.id AS course_id,
    c.title AS course_title,
    c.category,
    c.level,
    e.enrolled_at,
    DATE_TRUNC('month', e.enrolled_at)::date AS enrollment_month,
    e.status,
    e.paid_amount,
    e.completed_at,
    CASE
        WHEN e.completed_at IS NOT NULL
        THEN e.completed_at - e.enrolled_at
        ELSE NULL
    END AS completion_days,
    (e.status = '완료') AS is_completed
FROM analysis_lab.enrollments e
JOIN analysis_lab.students s
    ON s.id = e.student_id
JOIN analysis_lab.courses c
    ON c.id = e.course_id;
```

VIEW는 원본 데이터를 복제하지 않고 SELECT 문을 저장합니다. 원본 테이블이 바뀌면 다음 조회부터 결과도 달라집니다.

분석 데이터셋 검증:

```sql
SELECT COUNT(*) AS dataset_row_count
FROM analysis_lab.enrollment_analysis_dataset;
```

기대 결과는 24행입니다.

```sql
SELECT enrollment_id, COUNT(*)
FROM analysis_lab.enrollment_analysis_dataset
GROUP BY enrollment_id
HAVING COUNT(*) > 1;
```

기대 결과는 0행입니다. JOIN 때문에 한 신청이 여러 행으로 늘어나지 않았는지 확인하는 검산입니다.

---

## 9. DBeaver에서 CSV로 내보낸다

Python과 데이터베이스를 바로 연결하기 전에 CSV를 이용해 분석 흐름을 먼저 확인할 수 있습니다.

DBeaver에서 다음 조회를 실행합니다.

```sql
SELECT *
FROM analysis_lab.enrollment_analysis_dataset
ORDER BY enrollment_id;
```

결과 그리드에서 다음 순서로 내보냅니다.

```text
결과 그리드 우클릭
→ Export Data
→ CSV
→ UTF-8 인코딩 확인
→ 헤더 포함
→ code/chapter14/data/enrollment_analysis_dataset.csv로 저장
```

실제 저장 경로는 사용자의 프로젝트 위치에 맞게 지정합니다. CSV에는 비밀번호나 접속 정보가 포함되지 않지만, 실제 개인정보가 있는 운영 데이터를 그대로 내보내면 안 됩니다.

CSV 경로에서는 다음 사항을 확인합니다.

```text
헤더가 포함되었는가?
한글이 깨지지 않는가?
행 수가 24인가?
날짜 컬럼 형식이 일관적인가?
중복 enrollment_id가 없는가?
```

---

## 10. Python 분석 환경을 준비한다

Python 실습에 사용하는 패키지:

```text
pandas
matplotlib
SQLAlchemy
psycopg[binary]
python-dotenv
```

가상환경 예:

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
pip install -r code/chapter14/python/requirements.txt
```

macOS·Linux:

```bash
source .venv/bin/activate
pip install -r code/chapter14/python/requirements.txt
```

설치 확인:

```bash
python -c "import pandas, sqlalchemy, psycopg, matplotlib; print('OK')"
```

Python 버전과 패키지 버전은 실행 결과 재현에 영향을 줄 수 있습니다. 최종 보고서에는 실제 사용한 버전을 기록하는 것이 좋습니다.

---

## 11. CSV를 pandas로 읽는다

```python
from pathlib import Path

import pandas as pd

csv_path = Path("code/chapter14/data/enrollment_analysis_dataset.csv")

if not csv_path.exists():
    raise FileNotFoundError(
        f"CSV 파일을 찾을 수 없습니다: {csv_path.resolve()}"
    )

df = pd.read_csv(
    csv_path,
    parse_dates=["enrolled_at", "enrollment_month", "completed_at"],
)

print(df.head())
print(df.info())
print(f"행 수: {len(df)}")
```

읽은 직후 다음을 확인합니다.

```python
expected_rows = 24

if len(df) != expected_rows:
    raise ValueError(
        f"기대 행 수는 {expected_rows}이지만 실제는 {len(df)}입니다."
    )

if df["enrollment_id"].duplicated().any():
    duplicated_ids = df.loc[
        df["enrollment_id"].duplicated(keep=False),
        "enrollment_id",
    ].tolist()
    raise ValueError(f"중복 enrollment_id: {duplicated_ids}")
```

오류를 발견했을 때 Python에서 임의로 중복 행을 제거한 뒤 계속 진행하지 않습니다. 먼저 SQL의 JOIN과 VIEW 정의를 확인해야 합니다.

---

## 12. PostgreSQL과 Python을 연결한다

![PostgreSQL 데이터를 Python과 pandas로 읽기](../../images/chapter14/ch14_06_postgresql_python_connection.svg)

그림 14-6 PostgreSQL 데이터를 Python과 pandas로 읽기

접속 정보는 코드에 직접 적지 않습니다.

`.env.example`:

```text
DATABASE_URL=postgresql+psycopg://db_user:db_password@localhost:5432/db_name
```

사용자는 `.env.example`을 복사해 `.env`를 만들고 자신의 개발·테스트 DB 정보를 입력합니다. `.env`는 GitHub에 커밋하지 않습니다.

Python 연결 예:

```python
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

database_url = os.getenv("DATABASE_URL")
if not database_url:
    raise RuntimeError("DATABASE_URL 환경변수가 설정되지 않았습니다.")

engine = create_engine(database_url, pool_pre_ping=True)

query = text("""
    SELECT *
    FROM analysis_lab.enrollment_analysis_dataset
    ORDER BY enrollment_id
""")

with engine.connect() as connection:
    df = pd.read_sql_query(query, connection)

print(df.head())
print(f"행 수: {len(df)}")
```

안전 원칙:

```text
운영 DB가 아닌 개발·테스트 DB를 사용한다.
비밀번호를 코드·노트북·화면 캡처에 남기지 않는다.
SELECT 중심의 읽기 전용 계정을 우선 검토한다.
.env를 저장소에 커밋하지 않는다.
원본 테이블을 변경하는 SQL을 분석 코드에서 자동 실행하지 않는다.
```

---

## 13. pandas로 집계한다

![pandas 데이터 분석 확장 흐름](../../images/chapter14/ch14_07_pandas_analysis_flow.svg)

그림 14-7 pandas 데이터 분석 확장 흐름

### 상태별 건수

```python
status_summary = (
    df.groupby("status", dropna=False)
      .agg(enrollment_count=("enrollment_id", "count"))
      .sort_values("enrollment_count", ascending=False)
      .reset_index()
)

print(status_summary)
```

### 월별 신청 건수와 결제금액

```python
monthly_summary = (
    df.groupby("enrollment_month", as_index=False)
      .agg(
          enrollment_count=("enrollment_id", "count"),
          paid_amount_sum=("paid_amount", "sum"),
      )
      .sort_values("enrollment_month")
)

print(monthly_summary)
```

### 강의별 상태 피벗

```python
course_status_pivot = pd.pivot_table(
    df,
    index="course_title",
    columns="status",
    values="enrollment_id",
    aggfunc="count",
    fill_value=0,
    margins=True,
)

print(course_status_pivot)
```

### 완료 기간

```python
completed = df.loc[df["status"] == "완료"].copy()
completed["completion_days"] = pd.to_numeric(
    completed["completion_days"],
    errors="coerce",
)

print(completed["completion_days"].describe())
```

Python 결과도 항상 전체 건수와 합계를 검산합니다.

```python
assert int(status_summary["enrollment_count"].sum()) == 24
assert int(monthly_summary["enrollment_count"].sum()) == 24
assert int(monthly_summary["paid_amount_sum"].sum()) == 2_770_000
```

---

## 14. 간단한 시각화로 확장한다

matplotlib을 사용해 월별 신청 건수를 표시할 수 있습니다.

```python
import matplotlib.pyplot as plt

ax = monthly_summary.plot(
    x="enrollment_month",
    y="enrollment_count",
    kind="line",
    marker="o",
    legend=False,
)
ax.set_title("월별 수강신청 건수")
ax.set_xlabel("월")
ax.set_ylabel("신청 건수")
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
```

그래프를 만들기 전에 다음을 확인합니다.

```text
축의 단위가 무엇인가?
기간이 빠짐없이 정렬되었는가?
NULL이나 문자열이 숫자로 잘못 처리되지 않았는가?
합계와 그래프의 점 개수가 SQL 결과와 일치하는가?
0에서 시작하지 않는 축이 해석을 왜곡하지 않는가?
```

시각화는 분석의 증거를 대신하지 않습니다. SQL 결과표와 pandas 집계값을 먼저 확인한 뒤 해석을 돕는 용도로 사용합니다.

---

## 15. SQL 결과와 Python 결과를 교차 검증한다

![SQL 결과와 Python 결과 교차 검증](../../images/chapter14/ch14_08_analysis_result_validation.svg)

그림 14-8 SQL 결과와 Python 결과 교차 검증

SQL과 Python이 같은 데이터를 사용하더라도 다음 이유로 결과가 달라질 수 있습니다.

```text
날짜 범위가 다름
JOIN 종류가 다름
NULL 처리 방식이 다름
중복 행이 발생함
취소 건 포함 기준이 다름
문자열과 날짜 자료형이 다름
Python에서 임의로 행을 제거함
SQL과 Python 실행 시점이 다름
```

### SQL 기준값 준비

`07_analysis_validation.sql`에서 상태별·월별 기준값을 조회합니다.

상태별 기대값:

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

### Python에서 비교

```python
expected_status_counts = {
    "완료": 12,
    "수강중": 5,
    "신청": 4,
    "취소": 3,
}

actual_status_counts = (
    df.groupby("status")["enrollment_id"]
      .count()
      .astype(int)
      .to_dict()
)

if actual_status_counts != expected_status_counts:
    raise AssertionError(
        "상태별 건수가 일치하지 않습니다. "
        f"expected={expected_status_counts}, "
        f"actual={actual_status_counts}"
    )
```

검증 실패 시 기대값을 실제값으로 바꿔 통과시키지 않습니다. 먼저 데이터, SQL, Python 처리 순서를 확인합니다.

---

## 16. 분석 결과를 해석한다

분석은 숫자를 출력하는 데서 끝나지 않습니다. 결과가 무엇을 의미하는지, 무엇까지 말할 수 있는지 구분해야 합니다.

예:

```text
관찰
- 3월 신청 건수가 5건으로 가장 많다.
- 6월 결제금액 합계가 570,000으로 가장 크다.
- 완료 상태가 12건으로 전체 24건의 절반이다.

해석 가능
- 기준 데이터에서 3월의 신청 활동이 가장 많았다.
- 강의 가격 차이 때문에 신청 건수와 결제금액 순위는 다를 수 있다.

해석 제한
- 실제 서비스 성장 추세라고 일반화할 수 없다.
- 샘플 데이터이므로 계절성과 마케팅 효과를 판단할 수 없다.
- 상관관계만으로 원인을 확정할 수 없다.
```

최종 분석 기록에는 다음을 포함합니다.

```text
분석 질문
데이터 범위와 실행 시점
사용한 SQL 또는 VIEW
분석 데이터셋의 행 단위
SQL 결과
Python 결과
교차 검증 결과
해석
한계
다음 분석 질문
```

---

## 17. AI가 만든 분석 코드를 검토한다

ChatGPT나 Codex에 분석을 요청할 때는 다음 정보를 함께 제공합니다.

```text
분석 질문
테이블과 컬럼 구조
PK·FK 관계
분석 기간
한 행의 단위
NULL·취소 처리 기준
기대 행 수와 기준 집계값
수정할 파일과 수정 금지 범위
출력 형식
검증 방법
```

검토 흐름:

```text
요구사항 확인
→ AI가 SQL·Python 초안 생성
→ 격리된 개발·테스트 환경에서 실행
→ SQL 결과 검산
→ Python DataFrame 행 수·자료형 확인
→ SQL·Python 집계 비교
→ diff 확인
→ 사람이 최종 승인
```

AI 생성 SQL 검토:

```text
존재하지 않는 테이블·컬럼을 사용하지 않았는가?
PK·FK 경로에 맞는 JOIN인가?
INNER JOIN과 LEFT JOIN 선택이 분석 질문과 맞는가?
COUNT(*)와 COUNT(child.id)를 구분했는가?
GROUP BY 때문에 중복 집계되지 않았는가?
날짜 범위와 시간대가 일치하는가?
NULL과 취소 건 처리 기준이 명시되었는가?
원본을 변경하는 UPDATE·DELETE·DROP이 포함되지 않았는가?
```

AI 생성 Python 검토:

```text
실제 비밀번호나 접속 URL이 코드에 포함되지 않았는가?
원본 전체를 불필요하게 가져오지 않는가?
날짜와 숫자 자료형을 확인했는가?
오류를 숨기기 위해 drop_duplicates나 dropna를 임의 적용하지 않았는가?
SQL 기준값과 자동 비교하는가?
그래프의 축과 단위가 명확한가?
검증하지 않은 결과를 성공으로 표시하지 않았는가?
```

---

## 18. 자주 하는 실수

### 실수 1. 질문 없이 SQL부터 작성한다

먼저 분석 대상, 기간, 단위와 기대 결과를 정의합니다.

### 실수 2. JOIN 후 행 수 증가를 확인하지 않는다

JOIN 전후 행 수와 PK 중복을 반드시 확인합니다.

### 실수 3. 학생 수와 신청 수를 같은 COUNT로 계산한다

학생 수는 `COUNT(DISTINCT student_id)`, 신청 수는 `COUNT(enrollment_id)`처럼 단위를 구분합니다.

### 실수 4. NULL을 모두 0이나 빈 문자열로 바꾼다

NULL이 의미하는 업무 상태를 먼저 확인합니다.

### 실수 5. SQL에서 충분히 줄일 수 있는 데이터를 모두 Python으로 가져온다

필터·JOIN·대규모 집계는 데이터베이스에서 먼저 수행합니다.

### 실수 6. Python에서 중복을 발견하자 바로 제거한다

중복의 원인이 원본인지 JOIN인지 확인한 뒤 수정합니다.

### 실수 7. SQL과 Python 결과가 달라도 그래프만 제출한다

행 수, 건수, 합계와 평균을 교차 검증합니다.

### 실수 8. 접속 정보를 코드나 노트북에 기록한다

환경변수와 `.env`를 사용하고 저장소에 커밋하지 않습니다.

### 실수 9. 샘플 데이터 결과를 실제 서비스의 원인 분석으로 일반화한다

관찰, 해석과 한계를 분리합니다.

### 실수 10. AI가 생성한 기대값으로 같은 AI 코드만 검증한다

사람이 확인한 SQL 기준값이나 별도의 검산 쿼리를 사용합니다.

---

## 19. 스스로 확인하기

### 확인 1

SQL과 Python을 함께 사용하는 이유를 설명해 보세요.

### 확인 2

분석 데이터셋에서 한 행의 단위를 먼저 정의해야 하는 이유는 무엇인가요?

### 확인 3

`LEFT JOIN` 후 `COUNT(*)`와 `COUNT(child.id)`의 결과가 달라질 수 있는 이유를 설명해 보세요.

### 확인 4

월별 분석에서 날짜 범위와 날짜 기준 컬럼을 명시해야 하는 이유는 무엇인가요?

### 확인 5

Python에서 중복 행을 발견했을 때 바로 `drop_duplicates()`를 사용하면 안 되는 이유는 무엇인가요?

### 확인 6

SQL 결과와 pandas 결과를 교차 검증할 때 확인할 항목을 세 가지 이상 적어 보세요.

### 확인 7

완료 상태가 아닌 행의 `completed_at`이 NULL인 것이 반드시 오류가 아닌 이유를 설명해 보세요.

### 확인 8

AI가 만든 분석 코드에서 파괴적인 SQL과 접속 정보 노출을 어떻게 확인할 수 있나요?

---

## 20. 핵심 정리

```text
1. 분석은 SQL 작성이 아니라 분석 질문 정의에서 시작한다.
2. 분석 대상·기간·행 단위·집계 기준을 먼저 확정한다.
3. SQL은 필터·JOIN·집계와 분석 데이터셋 생성에 사용한다.
4. 집계 전에 NULL·중복·고아·업무 규칙을 점검한다.
5. JOIN 후 행 수와 PK 중복을 검산한다.
6. Python은 SQL 결과를 가공·피벗·시각화·추가 분석으로 확장한다.
7. 접속 정보는 환경변수로 관리하고 운영 데이터를 직접 사용하지 않는다.
8. SQL과 Python 결과의 건수·합계·평균을 교차 검증한다.
9. 분석 결과의 관찰·해석·한계를 구분한다.
10. AI가 만든 SQL과 Python 코드는 실행 증거와 diff를 사람이 검토한다.
```

---

## 다음 장 연결

Chapter 15에서는 지금까지 학습한 요구사항 분석, ERD, 정규화, SQL, JOIN·집계, 트랜잭션, 인덱스, 운영 안전성, AI 검토와 SQL·Python 분석을 하나의 재현 가능한 데이터베이스 종합 프로젝트로 통합합니다.
