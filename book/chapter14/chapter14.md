# Chapter 14. SQL 데이터 분석과 Python 확장

---

## 이 장에서 살펴볼 내용

Chapter 13에서는 AI가 만든 데이터베이스 설계와 SQL을 요구사항, 메타데이터, 정상·반례 테스트와 실행 결과로 검증했습니다. 이번 장에서는 그 검증 원칙을 데이터 분석으로 확장합니다.

```text
분석 질문 정의
→ 기간·행 단위·지표 의미 확정
→ SQL로 필터·JOIN·집계
→ 데이터 품질 확인
→ 분석용 VIEW 생성
→ CSV 또는 읽기 전용 PostgreSQL 연결
→ pandas 가공·피벗·시각화
→ 실제 SQL 결과와 pandas 결과 교차 검증
→ 관찰·해석·한계 기록
```

SQL과 Python은 경쟁 관계가 아닙니다.

```text
SQL
- 데이터가 저장된 위치에서 필요한 범위를 줄인다.
- PK·FK 관계를 따라 JOIN한다.
- 분석 기간과 한 행의 단위를 확정한다.
- 대규모 필터·집계와 기준값 계산을 수행한다.

Python
- SQL이 만든 분석 데이터셋을 추가 가공한다.
- 피벗·시각화·통계 분석으로 확장한다.
- SQL 결과와 pandas 결과를 자동 비교한다.
```

이 장에서는 다음을 다룹니다.

- 분석 질문·기간·행 단위·지표 정의
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT ...)`
- JOIN 후 중복과 과대 집계 점검
- 반개방 날짜 구간과 데이터가 없는 월을 유지하는 date spine
- 상태·강의·지역·월별 집계
- 현재 완료 상태 비중과 완료율의 차이
- 가입일·강의 개설일·신청일·완료일 품질 검사
- 분석 기간이 적용된 VIEW
- DBeaver CSV와 출처 manifest
- libpq password file 기반 읽기 전용 PostgreSQL 연결
- pandas의 엄격한 컬럼·자료형·업무 규칙 검증
- matplotlib 헤드리스 시각화
- 같은 데이터 스냅샷의 실제 SQL·pandas 교차 검증
- AI가 만든 분석 SQL·Python 코드 검토

> **핵심 원칙**
>
> 분석 결과는 코드가 오류 없이 실행되거나 그래프가 보기 좋다는 이유만으로 신뢰하지 않습니다. 질문, 기간, 행 단위, 지표 의미와 검산 결과가 서로 일치해야 합니다.

![SQL에서 Python으로 확장되는 데이터 분석 흐름](../../images/chapter14/ch14_01_analysis_workflow.svg)

그림 14-1 SQL에서 Python으로 확장되는 데이터 분석 흐름

---

## 1. 분석 질문을 SQL보다 먼저 정의한다

온라인 강의 서비스 데이터를 분석한다고 가정하겠습니다.

```text
P14-Q01 상태별 수강신청 건수는 얼마인가?
P14-Q02 월별 신청 건수와 신청 시점 기록 금액은 얼마인가?
P14-Q03 강의별 신청 건수는 얼마인가?
P14-Q04 지역별 학생 수와 신청 건수는 어떻게 다른가?
P14-Q05 완료된 신청의 완료 기간은 얼마인가?
```

분석 질문에는 다음 항목이 필요합니다.

| 항목 | 확인 내용 |
| --- | --- |
| 분석 대상 | 학생·강의·수강신청 중 무엇인가? |
| 분석 기간 | 전체 기간인가, 특정 기간인가? |
| 날짜 기준 | 신청일·결제일·완료일 중 무엇인가? |
| 행 단위 | 학생 1명·강의 1개·신청 1건 중 무엇인가? |
| 비교 기준 | 상태·지역·강의·월 중 무엇인가? |
| 지표 의미 | 건수·기록 금액·매출·완료 비중 중 무엇인가? |
| 기대 결과 | 행 수·합계·평균 등 검산 기준이 있는가? |

이 장의 분석 범위는 다음과 같습니다.

```text
기간: [2026-01-01, 2026-07-01)
날짜 기준: enrollments.enrolled_at
행 단위: 수강신청 1건
금액 의미: 신청 시점 기록 금액
취소: 신청 시점 기록 금액을 그대로 유지
```

`[2026-01-01, 2026-07-01)`은 시작일은 포함하고 종료일은 제외하는 반개방 구간입니다.

> **금액 보존 원칙**
> `recorded_amount`는 신청 시점의 기록이므로 이후 상태가 `취소`로 바뀌어도 0으로 덮어쓰지 않습니다. 환불·순매출은 별도 결제·환불 원장이 있을 때 계산해야 합니다.

```sql
WHERE enrolled_at >= DATE '2026-01-01'
  AND enrolled_at <  DATE '2026-07-01'
```

`BETWEEN '2026-01-01' AND '2026-06-30'`보다 날짜·시간 자료형으로 확장하기 쉽고 경계가 명확합니다.

---

## 2. `recorded_amount`의 의미를 먼저 확정한다

이 장의 물리 컬럼 이름은 `recorded_amount`이지만 별도 결제 상태·환불 원장이 없습니다. `신청`과 `수강중` 상태에도 양수 금액이 존재합니다.

따라서 이 값을 실제 결제 완료 금액이나 회계 매출로 해석하면 안 됩니다.

```text
recorded_amount
→ 신청 시점 기록 금액
→ 결제 성공 여부를 의미하지 않음
→ 환불 완료 여부를 의미하지 않음
→ 회계 매출을 의미하지 않음
```

SQL 집계 별칭은 의미가 드러나도록 사용합니다.

```sql
SUM(recorded_amount) AS recorded_amount_sum
```

분석 VIEW와 Python에서는 `recorded_amount`라는 이름으로 제공합니다.

실제 결제 분석에는 다음과 같은 별도 모델이 필요합니다.

```text
payments
payment_status
paid_at
refunded_at
transaction_reference
```

---

## 3. SQL과 Python의 역할을 구분한다

![SQL과 Python의 분석 역할 구분](../../images/chapter14/ch14_02_sql_python_role_split.svg)

그림 14-2 SQL과 Python의 분석 역할 구분

| 작업 | SQL | Python |
| --- | --- | --- |
| 필요한 행·열 선택 | 적합 | 원본 전체를 가져오면 비효율적 |
| PK·FK JOIN | 적합 | 가능하지만 관계를 다시 관리해야 함 |
| 대규모 필터·집계 | 적합 | 전송 후 처리하면 비용 증가 |
| 데이터 품질 점검 | 적합 | 추가 검증에 적합 |
| 피벗·재구조화 | 가능 | 편리 |
| 시각화 | 제한적 | 적합 |
| 통계·머신러닝 | 제한적 | 적합 |
| 결과 자동 비교 | 가능 | 적합 |

권장 흐름:

```text
PostgreSQL
→ 기간과 관계를 SQL로 확정
→ 분석 VIEW 생성
→ 필요한 24행만 Python으로 읽기
→ pandas 가공·시각화
→ SQL 기준 결과와 비교
```

원본 테이블 전체를 Python으로 가져온 뒤 JOIN과 필터를 다시 구현하면 데이터 전송량이 늘고, DB의 관계와 업무 규칙을 분석 코드에 중복 구현할 수 있습니다.

---

## 4. Chapter 14 실습 구조

앞 장의 스키마는 변경하지 않습니다.

```text
course_project: 변경 금지
transaction_lab: 변경 금지
performance_lab: 변경 금지
security_lab: 변경 금지
nosql_lab: 변경 금지
ai_review_lab: 변경 금지
analysis_lab: Chapter 14 실습 대상
```

> **격리 분석 시나리오 주의**
> `analysis_lab`의 8명·3명·5개·24건 데이터는 SQL·Python 분석을 학습하기 위해 만든 합성 기준 데이터입니다. `course_project`의 행을 확장하거나 복제한 운영 데이터가 아니며, 기존 `course_project.enrollments.recorded_amount NUMERIC(12,0)`의 의미를 그대로 이어 받아 신청 시점 기록 금액으로 사용합니다.

실습 객체:

```text
analysis_lab.students
analysis_lab.instructors
analysis_lab.courses
analysis_lab.enrollments
analysis_lab.analysis_parameters VIEW
analysis_lab.enrollment_analysis_dataset VIEW
```

관계:

```text
students 1 → N enrollments
instructors 1 → N courses
courses 1 → N enrollments
```

파일:

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

실행 순서:

```text
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08
→ CSV 또는 읽기 전용 PostgreSQL 연결
→ pandas 분석
→ 실제 SQL·pandas 교차 검증
```

---

## 5. 생성·Seed·초기화의 안전성

모든 SQL은 다음 정보를 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

`01_analysis_lab_schema.sql`은 다음 조건을 실제로 검사합니다.

```text
현재 DB = ai_database_book
analysis_lab 미존재
```

스키마·테이블·기간 VIEW는 하나의 트랜잭션에서 생성됩니다. 중간 오류가 발생하면 일부 객체만 남는 위험을 줄입니다.

Seed도 다음 순서로 실행됩니다.

```text
현재 DB 검사
→ 필요한 객체 존재 확인
→ 네 테이블이 모두 비어 있는지 확인
→ BEGIN
→ 기준 데이터 입력
→ IDENTITY 다음 값 조정
→ 행 수·금액·완료·활성 중복 판정
→ COMMIT
```

명시적 ID 뒤의 다음 자동값:

```text
students 109
instructors 204
courses 306
enrollments 1025
```

`reset_analysis_lab.sql`은 `ai_database_book`에서만 분석 VIEW와 자식 테이블부터 삭제합니다.

---

## 6. 활성 신청 규칙과 중복 적재 규칙

Chapter 07에서 확정한 규칙을 유지합니다.

```sql
CREATE UNIQUE INDEX uq_analysis_enrollments_active
ON analysis_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

```text
신청·수강중
→ 학생·강의 조합당 최대 한 건

완료·취소
→ 이력 보존과 이후 재신청 허용
```

별도의 다음 UNIQUE는 같은 날짜의 동일 원천 행 중복 적재를 막습니다.

```sql
UNIQUE (student_id, course_id, enrolled_at)
```

두 제약은 목적이 다릅니다.

---

## 7. 분석 기간을 한 곳에서 관리한다

`analysis_parameters` VIEW는 분석 기간을 한 행으로 제공합니다.

```sql
CREATE VIEW analysis_lab.analysis_parameters AS
SELECT
    DATE '2026-01-01' AS start_date,
    DATE '2026-07-01' AS end_date_exclusive;
```

SQL·분석 VIEW·Python 기준 파일에서 같은 값을 사용합니다.

```text
start_date = 2026-01-01
end_date_exclusive = 2026-07-01
```

Seed에 현재 1~6월 데이터만 있다는 이유로 기간 조건을 생략하면, 7월 데이터가 추가되는 순간 같은 질문의 결과가 달라집니다.

---

## 8. 기준 데이터 이해하기

| 테이블 | 기대 행 수 |
| --- | ---: |
| students | 8 |
| instructors | 3 |
| courses | 5 |
| enrollments | 24 |

상태:

```text
신청 4
수강중 5
완료 12
취소 3
```

월별 기준:

| 월 | 신청 건수 | 신청 시점 기록 금액 |
| --- | ---: | ---: |
| 2026-01 | 3 | 350000 |
| 2026-02 | 4 | 520000 |
| 2026-03 | 5 | 680000 |
| 2026-04 | 4 | 550000 |
| 2026-05 | 4 | 540000 |
| 2026-06 | 4 | 570000 |

전체 기록 금액 합계는 3,210,000입니다.

`completed_at`은 상태와 함께 해석합니다.

```text
완료 → completed_at 필요
신청·수강중·취소 → completed_at NULL
```

NULL은 무조건 오류가 아닙니다. 업무 상태에 따라 자연스러운 값일 수 있습니다.

---

## 9. 분석 전에 데이터 품질을 확인한다

![분석 전 데이터 품질 점검](../../images/chapter14/ch14_04_data_quality_checks.svg)

그림 14-3 분석 전 데이터 품질 점검

P14-V02 검증 범위:

```text
행 수
PK 중복
고아 학생·강의·강사
완료 상태와 완료일
완료일 >= 신청일
신청일 >= 학생 가입일
신청일 >= 강의 개설일
음수 기록 금액
취소 상태의 기록 금액 0
허용 상태
분석 기간 밖 행
활성 신청 중복
```

학생 가입일보다 이른 신청:

```sql
SELECT e.id, s.joined_at, e.enrolled_at
FROM analysis_lab.enrollments AS e
JOIN analysis_lab.students AS s
    ON s.id = e.student_id
WHERE e.enrolled_at < s.joined_at;
```

강의 개설일보다 이른 신청:

```sql
SELECT e.id, c.opened_at, e.enrolled_at
FROM analysis_lab.enrollments AS e
JOIN analysis_lab.courses AS c
    ON c.id = e.course_id
WHERE e.enrolled_at < c.opened_at;
```

두 결과 모두 0행이어야 합니다.

---

## 10. JOIN·필터·집계의 기본 흐름

![JOIN과 집계로 분석 결과 만들기](../../images/chapter14/ch14_03_sql_aggregation_flow.svg)

그림 14-4 JOIN과 집계로 분석 결과 만들기

```text
질문
→ 기간 제한
→ 테이블과 JOIN 경로
→ 결과의 한 행 단위
→ GROUP BY
→ 집계 함수
→ 정렬
→ 전체 합계 검산
```

P14-Q01 상태별 신청 건수:

```sql
WITH filtered_enrollments AS (
    SELECT e.*
    FROM analysis_lab.enrollments AS e
    CROSS JOIN analysis_lab.analysis_parameters AS p
    WHERE e.enrolled_at >= p.start_date
      AND e.enrolled_at < p.end_date_exclusive
)
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM filtered_enrollments
GROUP BY status;
```

상태별 건수 합계는 24여야 합니다.

---

## 11. `COUNT(*)`, `COUNT(child.id)`, `COUNT(DISTINCT ...)`

강의가 1행 있고 신청이 없더라도 `LEFT JOIN` 결과에는 강의 행이 남습니다.

```sql
COUNT(*)
```

은 그 행을 1건으로 셀 수 있습니다. 신청 건수를 세려면 자식 PK를 사용합니다.

```sql
COUNT(e.id)
```

지역별 학생 수와 신청 수는 단위가 다릅니다.

```sql
COUNT(DISTINCT s.id) AS student_count,
COUNT(e.id) AS enrollment_count
```

학생 수를 `COUNT(*)`로 세면 신청이 많은 학생이 여러 번 계산될 수 있습니다.

---

## 12. 강의·강사·지역별 분석

강의별 집계:

```sql
SELECT
    c.id AS course_id,
    c.title,
    COUNT(e.id) AS enrollment_count,
    COALESCE(SUM(e.recorded_amount), 0) AS recorded_amount_sum
FROM analysis_lab.courses AS c
LEFT JOIN filtered_enrollments AS e
    ON e.course_id = c.id
GROUP BY c.id, c.title;
```

지역별 집계:

```sql
SELECT
    s.region,
    COUNT(DISTINCT s.id) AS student_count,
    COUNT(e.id) AS enrollment_count
FROM analysis_lab.students AS s
LEFT JOIN filtered_enrollments AS e
    ON e.student_id = s.id
GROUP BY s.region;
```

JOIN한 뒤 무엇을 세는지 이름으로 드러내야 합니다.

---

## 13. 데이터가 없는 월도 유지하는 date spine

실제 데이터만 월별로 GROUP BY하면 행이 없는 월은 사라집니다. 4월 데이터가 없다면 `LAG`에서 5월의 이전 행이 3월이 될 수 있습니다.

월 기준표를 먼저 만듭니다.

```sql
WITH months AS (
    SELECT generate_series(
        DATE '2026-01-01',
        DATE '2026-06-01',
        INTERVAL '1 month'
    )::date AS enrollment_month
)
```

실제 집계와 `LEFT JOIN`합니다.

```sql
SELECT
    m.enrollment_month,
    COALESCE(a.enrollment_count, 0) AS enrollment_count,
    COALESCE(a.recorded_amount_sum, 0) AS recorded_amount_sum
FROM months AS m
LEFT JOIN monthly_actual AS a
    ON a.enrollment_month = m.enrollment_month;
```

이렇게 하면 데이터가 없는 월도 0건으로 유지됩니다.

---

## 14. 이전 달과 비교한다

`LAG`는 정렬된 이전 행의 값을 가져옵니다.

```sql
LAG(enrollment_count) OVER (
    ORDER BY enrollment_month
) AS previous_enrollment_count
```

첫 달은 이전 달이 없으므로 NULL입니다. 오류가 아니라 분석상 자연스러운 값입니다.

중간 월을 date spine으로 유지해야 `LAG`의 이전 행이 실제 이전 달을 의미합니다.

---

## 15. 현재 완료 상태 비중과 완료율을 구분한다

다음 계산은 전체 신청 중 현재 `완료` 상태의 비중입니다.

```sql
COUNT(*) FILTER (WHERE status = '완료')
* 100.0 / COUNT(*)
```

이 지표는 `completed_share_pct`라고 부릅니다.

```text
현재 완료 상태 비중
→ 전체 신청 중 현재 완료 상태가 차지하는 비율

완료율
→ 완료할 충분한 시간이 지난 코호트와 분모 정책이 필요
```

최근 신청과 수강중인 행까지 분모에 넣으면 실제 완료 성과를 과소평가할 수 있습니다. 취소를 분모에 포함할지도 정해야 합니다.

---

## 16. 완료 기간 분석의 범위

```sql
SELECT
    COUNT(*) AS completed_count,
    ROUND(AVG(completed_at - enrolled_at), 2) AS avg_completion_days,
    MIN(completed_at - enrolled_at) AS min_completion_days,
    MAX(completed_at - enrolled_at) AS max_completion_days
FROM filtered_enrollments
WHERE status = '완료';
```

기대값:

```text
완료 12건
평균 25일
최소 18일
최대 36일
```

이 값은 **완료된 신청만의 완료 기간**입니다. 아직 완료하지 않은 신청을 제외하므로 전체 수강생이 평균적으로 25일 만에 완료한다고 일반화할 수 없습니다.

---

## 17. 분석용 데이터셋을 만든다

![업무 테이블에서 분석용 데이터셋 만들기](../../images/chapter14/ch14_05_analysis_dataset_pipeline.svg)

그림 14-5 업무 테이블에서 분석용 데이터셋 만들기

한 행의 단위:

```text
수강신청 1건 = enrollment_id 1개
```

VIEW의 정확한 컬럼:

```text
enrollment_id
student_id
student_name
region
course_id
course_title
category
level
instructor_id
instructor_name
enrolled_at
enrollment_month
status
recorded_amount
completed_at
completion_days
is_completed
```

VIEW는 분석 기간을 실제로 적용합니다.

```sql
CROSS JOIN analysis_lab.analysis_parameters AS p
WHERE e.enrolled_at >= p.start_date
  AND e.enrolled_at < p.end_date_exclusive
```

검산:

```text
VIEW 행 수 24
고유 enrollment_id 24
중복 0
recorded_amount 합계 3,210,000
```

---

## 18. SQL 최종 완료 게이트

`07_analysis_validation.sql`은 상태·월별·기간·품질의 상세 결과를 보여 줍니다.

`08_analysis_lab_validation.sql`은 다음 항목을 자동 판정합니다.

```text
현재 DB = ai_database_book
정확한 테이블 4개와 VIEW 2개
분석 기간 한 행
행 수 8·3·5·24·24
분석 데이터셋 정확한 17개 컬럼
제약조건 20개와 IDENTITY 4개
활성 신청 부분 고유 인덱스
상태별 12·5·4·3
월별 건수·기록 금액
완료 기간 12·25·18·36
품질 이상 0
IDENTITY 다음 값 > 기존 최대 ID
```

통과 메시지:

```text
Chapter 14 analysis_lab validation passed
```

단순 boolean 조회와 달리 하나라도 다르면 예외를 발생시킵니다.

---

## 19. CSV를 내보내고 출처를 기록한다

DBeaver에서 다음 조회를 UTF-8·헤더 포함 CSV로 내보낼 수 있습니다.

```sql
SELECT *
FROM analysis_lab.enrollment_analysis_dataset
ORDER BY enrollment_id;
```

권장 경로:

```text
code/chapter14/data/enrollment_analysis_dataset.csv
```

CSV만으로는 다음을 알기 어렵습니다.

```text
어느 DB에서 생성했는가?
어느 VIEW를 사용했는가?
분석 기간은 무엇인가?
언제 생성했는가?
파일이 변경되었는가?
```

manifest에는 다음 정보를 기록합니다.

```json
{
  "source_database": "ai_database_book",
  "source_view": "analysis_lab.enrollment_analysis_dataset",
  "analysis_start_date": "2026-01-01",
  "analysis_end_date_exclusive": "2026-07-01",
  "row_count": 24,
  "generated_at_utc": "...",
  "sha256": "..."
}
```

`02_load_postgresql.py --export-csv`는 CSV와 manifest를 함께 생성합니다. DBeaver에서 직접 내보냈다면 `analysis_manifest.example.json`을 참고해 출처와 SHA-256을 기록합니다.

실제 개인정보가 있는 CSV를 저장소에 커밋하면 안 됩니다. `code/chapter14/data/`는 `.gitignore` 대상입니다.

---

## 20. Python 환경을 준비한다

패키지:

```text
pandas
matplotlib
SQLAlchemy
psycopg[binary]
python-dotenv
```

가상환경:

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

Python과 패키지 버전은 재현성 기록에 포함합니다.

---

## 21. 접속 정보는 URL 문자열 대신 libpq 변수를 사용한다

`python/.env.example`:

```text
PGHOST=localhost
PGPORT=5432
PGDATABASE=ai_database_book
PGUSER=
PGPASSFILE=
```

실제 password file은 저장소 밖의 보호된 경로에 둡니다.

Python 연결은 다음을 검사합니다.

```text
PGDATABASE = ai_database_book
analysis_lab.enrollment_analysis_dataset 존재
transaction_read_only = on
```

SQLAlchemy의 `URL.create()`를 사용해 사용자·호스트·DB를 구성하고, 비밀번호는 libpq password file에 맡깁니다. 코드·노트북·화면 캡처에 전체 접속 URL과 비밀번호를 남기지 않습니다.

![PostgreSQL 데이터를 Python과 pandas로 읽기](../../images/chapter14/ch14_06_postgresql_python_connection.svg)

그림 14-6 PostgreSQL 데이터를 Python과 pandas로 읽기

---

## 22. Python 공통 검증을 한 파일로 통일한다

`validation_utils.py`는 모든 Python 경로에 같은 기준을 적용합니다.

```text
정확한 17개 컬럼
행 수 24
중복 enrollment_id 0
날짜형 strict 변환
recorded_amount 숫자형
completion_days 숫자 또는 NULL
is_completed boolean
status와 is_completed 일치
완료 상태와 완료일·완료 기간 일치
분석 기간 안의 행
```

잘못된 문자열을 NULL로 숨기지 않습니다.

```python
pd.to_numeric(
    df["completion_days"],
    errors="raise",
)
```

CSV의 빈 완료 기간은 정상적인 `NaN`으로 유지되지만, 잘못된 문자열은 오류로 중단됩니다.

---

## 23. pandas로 집계한다

![pandas 데이터 분석 확장 흐름](../../images/chapter14/ch14_07_pandas_analysis_flow.svg)

그림 14-7 pandas 데이터 분석 확장 흐름

상태별:

```python
status_summary = (
    df.groupby("status", as_index=False)
      .agg(enrollment_count=("enrollment_id", "count"))
)
```

월별:

```python
monthly_summary = (
    df.groupby("enrollment_month", as_index=False)
      .agg(
          enrollment_count=("enrollment_id", "count"),
          recorded_amount_sum=("recorded_amount", "sum"),
      )
)
```

Python에서도 1~6월 기준표를 만들어 데이터가 없는 월을 0건으로 유지합니다.

피벗:

```python
pd.pivot_table(
    df,
    index="course_title",
    columns="status",
    values="enrollment_id",
    aggfunc="count",
    fill_value=0,
)
```

---

## 24. 시각화는 검증 뒤에 수행한다

그래프는 GUI가 없는 환경에서도 저장되도록 `Agg` 백엔드를 사용합니다.

```python
import matplotlib
matplotlib.use("Agg")
```

설치된 한글 글꼴을 탐색하고 찾지 못하면 경고를 출력합니다. 저장소에 글꼴 파일을 포함하지 않습니다.

```python
ax.set_ylim(bottom=0)
```

Y축을 0부터 시작해 작은 차이를 과장하지 않습니다.

확인 항목:

```text
제목과 축 단위
월 정렬
데이터 점 6개
Y축 0 시작
SQL·pandas 표와 합계 일치
한글 글꼴 경고
```

시각화는 분석 증거를 대신하지 않습니다.

---

## 25. 실제 SQL과 pandas 결과를 교차 검증한다

![SQL 결과와 Python 결과 교차 검증](../../images/chapter14/ch14_08_analysis_result_validation.svg)

그림 14-8 SQL 결과와 Python 결과 교차 검증

Python 코드에 기대값을 다시 하드코딩한 뒤 비교하는 것만으로는 실제 SQL·Python 교차 검증이라고 보기 어렵습니다.

PostgreSQL 경로에서는 같은 연결의 읽기 전용 `REPEATABLE READ` 스냅샷에서 다음을 모두 읽습니다.

```text
분석 데이터셋
SQL 상태별 집계
SQL 월별 date spine 집계
SQL 완료 기간 집계
```

pandas가 같은 데이터셋으로 만든 결과와 `assert_frame_equal()`로 비교합니다.

```text
실제 SQL DataFrame ↔ pandas DataFrame
```

CSV 경로는 다음 세 파일을 사용합니다.

```text
CSV 데이터셋
manifest: 출처·기간·시점·SHA-256
reference_metrics.json: 버전 관리된 SQL 기준 결과
```

검증 실패 시 기대값을 실제값으로 바꿔 통과시키지 않습니다.

---

## 26. 결과가 다를 때 확인할 순서

```text
1. 같은 DB와 같은 분석 VIEW인가?
2. 같은 기간 [2026-01-01, 2026-07-01)인가?
3. 같은 데이터 스냅샷인가?
4. JOIN 종류와 행 단위가 같은가?
5. 데이터가 없는 월을 같은 방식으로 유지했는가?
6. NULL과 취소 처리 기준이 같은가?
7. recorded_amount와 실제 결제금액을 혼동하지 않았는가?
8. 숫자·날짜·boolean 자료형이 같은가?
9. Python에서 행을 임의 제거하지 않았는가?
10. CSV SHA-256이 manifest와 일치하는가?
```

---

## 27. 분석 결과를 해석한다

관찰:

```text
3월 신청 건수가 5건으로 가장 많다.
6월 신청 시점 기록 금액 합계가 570,000으로 가장 크다.
완료 상태가 12건으로 전체 24건의 절반이다.
```

해석 가능:

```text
기준 데이터에서 3월의 신청 활동이 가장 많았다.
강의별 기록 금액 차이 때문에 건수와 금액 순위는 다를 수 있다.
```

해석 제한:

```text
실제 서비스 성장 추세로 일반화할 수 없다.
기록 금액을 결제 완료 매출로 해석할 수 없다.
완료된 행만의 평균 기간을 전체 수강생에 적용할 수 없다.
상관관계만으로 원인을 확정할 수 없다.
```

최종 기록:

```text
분석 질문과 P14 ID
기간과 실행 시점
데이터 출처·VIEW·manifest
행 단위
SQL 결과
pandas 결과
교차 검증
관찰
해석
한계
다음 질문
```

---

## 28. AI가 만든 분석 코드를 검토한다

AI 요청에 다음 정보를 제공합니다.

```text
P14 분석 질문
테이블·컬럼·PK·FK
분석 기간
한 행의 단위
recorded_amount 의미
NULL·취소 기준
date spine 필요 여부
기대 행 수와 기준 집계
수정 파일과 금지 범위
실제 SQL·pandas 비교 방법
```

SQL 검토:

```text
존재하는 객체를 사용하는가?
기간 조건이 모든 집계에 적용되었는가?
PK·FK JOIN 경로가 맞는가?
LEFT JOIN 후 COUNT(child.id)를 사용하는가?
학생 수와 신청 수의 단위가 구분되는가?
없는 월을 누락하지 않는가?
recorded_amount를 매출로 표현하지 않는가?
UPDATE·DELETE·DROP이 없는가?
```

Python 검토:

```text
읽기 전용 연결인가?
올바른 DB와 VIEW를 확인하는가?
정확한 컬럼과 자료형을 검사하는가?
errors='coerce', dropna, drop_duplicates로 오류를 숨기지 않는가?
SQL 상수를 복사하는 데서 끝나지 않고 실제 SQL 결과와 비교하는가?
manifest와 파일 해시를 확인하는가?
그래프 축이 해석을 왜곡하지 않는가?
```

---

## 29. 자주 하는 실수

1. 분석 질문 없이 SQL부터 작성한다.
2. `recorded_amount`를 실제 결제 완료 매출로 해석한다.
3. Seed가 1~6월뿐이라는 이유로 기간 조건을 생략한다.
4. 데이터가 없는 월을 결과에서 없앤다.
5. `LEFT JOIN` 뒤 신청 수에 `COUNT(*)`를 사용한다.
6. 학생 수와 신청 수를 같은 단위로 센다.
7. 현재 완료 상태 비중을 완료율이라고 부른다.
8. 가입일·개설일보다 이른 신청을 확인하지 않는다.
9. Python에서 중복을 발견하고 원인 확인 없이 제거한다.
10. `errors="coerce"`로 잘못된 문자열을 NULL로 바꾼다.
11. 코드에 전체 DB URL과 비밀번호를 기록한다.
12. CSV의 출처·생성 시점·해시를 기록하지 않는다.
13. Python의 하드코딩 상수만으로 SQL 결과를 검증했다고 말한다.
14. 그래프만 보고 분석을 완료한다.
15. 완료된 행의 평균을 전체 대상의 평균으로 일반화한다.

---

## 30. 스스로 확인하기

1. 분석 질문에 기간과 행 단위가 필요한 이유는 무엇인가요?
2. `recorded_amount`를 실제 매출로 볼 수 없는 이유는 무엇인가요?
3. 반개방 날짜 구간을 사용하는 이유는 무엇인가요?
4. 데이터가 없는 월을 date spine으로 유지해야 하는 이유는 무엇인가요?
5. `COUNT(*)`, `COUNT(e.id)`, `COUNT(DISTINCT s.id)`의 차이는 무엇인가요?
6. 현재 완료 상태 비중과 완료율은 어떻게 다른가요?
7. 학생 가입일과 강의 개설일을 신청일과 비교해야 하는 이유는 무엇인가요?
8. 분석 VIEW의 한 행 단위를 먼저 정의하는 이유는 무엇인가요?
9. `errors="coerce"`가 데이터 오류를 숨길 수 있는 이유는 무엇인가요?
10. CSV manifest에는 어떤 정보가 필요한가요?
11. 실제 SQL 결과와 pandas 결과를 같은 스냅샷에서 비교하는 이유는 무엇인가요?
12. 완료된 신청의 평균 완료 기간을 전체 수강생에게 일반화할 수 없는 이유는 무엇인가요?

---

## 31. 권장 해설

```text
분석 질문은 어떤 데이터를 어떤 기준으로 셀지 결정한다.
SQL은 기간·관계·행 단위를 확정하고 Python은 그 결과를 확장한다.
```

```text
COUNT(*)는 JOIN 결과 행을 세고,
COUNT(child.id)는 실제 자식 행을 세며,
COUNT(DISTINCT parent.id)는 중복된 부모를 한 번만 센다.
```

```text
반개방 구간은 시작은 포함하고 끝은 제외해 날짜·시간 경계를 명확하게 한다.
date spine은 데이터가 없는 기간도 0건으로 유지한다.
```

```text
recorded_amount는 신청 시점 기록 금액이다.
결제 성공·환불·매출 분석에는 별도 결제 원장이 필요하다.
```

```text
현재 완료 상태 비중은 전체 신청 중 완료 상태의 몫이다.
완료율은 관찰 기간과 코호트·분모 정책을 추가로 정의해야 한다.
```

```text
Python의 기대 상수 비교는 회귀 검증에는 유용하지만,
실제 SQL 결과와 pandas 결과를 직접 비교해야 교차 검증이 된다.
```

```text
manifest는 CSV의 출처·기간·생성 시점·행 수·해시를 기록해
같은 데이터 스냅샷을 사용했는지 설명하게 한다.
```

---

## 32. 핵심 정리

```text
1. 분석은 질문·기간·행 단위·지표 정의에서 시작한다.
2. recorded_amount는 신청 시점 기록 금액이며 실제 매출이 아니다.
3. SQL·VIEW·Python은 같은 반개방 기간을 사용한다.
4. date spine으로 데이터가 없는 월을 유지한다.
5. COUNT 계열 함수는 세는 대상의 단위에 맞게 선택한다.
6. 집계 전에 중복·고아·상태·시간 관계·기간을 점검한다.
7. 현재 완료 상태 비중과 완료율을 구분한다.
8. 분석 VIEW는 수강신청 1건을 한 행으로 제공한다.
9. Python은 정확한 컬럼·자료형·업무 규칙을 공통 검증한다.
10. DB 연결은 올바른 DB·VIEW와 읽기 전용 상태를 확인한다.
11. CSV는 출처 manifest와 SHA-256을 함께 관리한다.
12. 실제 SQL과 pandas 결과를 같은 스냅샷에서 교차 검증한다.
13. 시각화는 검증 뒤 해석을 돕는 용도로 사용한다.
14. 관찰·해석·한계를 분리하고 AI 코드는 사람이 승인한다.
```

이 장에서 기억할 문장은 다음과 같습니다.

```text
SQL로 분석의 경계를 확정하고,
Python으로 확장한 결과를 같은 증거로 다시 검증한다.
```

---

## 다음 장 연결

Chapter 15에서는 요구사항, ERD, 정규화, SQL 구현, 트랜잭션, 인덱스, 보안·복구, AI 검토와 Chapter 14의 SQL·Python 분석을 하나의 재현 가능한 데이터베이스 종합 프로젝트로 통합합니다.
