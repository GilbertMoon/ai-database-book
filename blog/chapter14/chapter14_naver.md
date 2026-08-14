# [AI 시대의 데이터베이스 입문 14] PostgreSQL SQL 분석을 Python pandas로 확장하기

안녕하세요. 아토믹데브입니다.

지난 Chapter 13에서는 AI가 만든 데이터베이스 설계와 SQL을 요구사항, 테스트, 메타데이터와 실제 실행 결과로 검증하는 방법을 배웠습니다.

이번 시간에는 그 검증 원칙을 **데이터 분석**으로 확장합니다.

데이터 분석을 시작하면 흔히 이런 고민을 합니다.

```text
SQL로 어디까지 해야 할까?
Python으로 전부 가져와서 분석하면 안 될까?
pandas 결과가 SQL 결과와 같은지 어떻게 확인할까?
그래프가 나왔으면 분석이 끝난 것일까?
```

핵심은 SQL과 Python 중 하나를 선택하는 것이 아닙니다.

```text
SQL로 분석 기준과 데이터셋을 정확하게 만든다.
→ Python으로 가공·피벗·시각화를 확장한다.
→ SQL과 pandas 결과를 다시 비교한다.
```

이번 Chapter에서는 PostgreSQL과 Python을 연결해 **검증 가능한 데이터 분석 흐름**을 만들어 보겠습니다.

---

## 오늘 배울 내용

이번 글을 끝까지 따라오면 다음 내용을 이해할 수 있습니다.

- 분석 질문을 SQL보다 먼저 정의하는 이유
- 분석 기간과 한 행의 단위(Grain) 정하기
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT ...)` 차이
- JOIN 후 과대 집계를 확인하는 방법
- 월별·상태별·강의별·지역별 SQL 집계
- 데이터가 없는 월도 유지하는 방법
- 분석용 VIEW 만들기
- PostgreSQL 결과를 CSV 또는 Python으로 가져오기
- pandas에서 자료형과 업무 규칙 검증하기
- 피벗과 matplotlib 시각화
- SQL 결과와 pandas 결과 교차 검증하기
- AI가 만든 분석 코드를 검토하는 방법

---

## STEP 1. 분석 질문부터 정의합니다

SQL을 먼저 작성하지 않습니다.

온라인 강의 서비스에서 다음 질문에 답한다고 가정해 보겠습니다.

```text
Q1. 상태별 수강신청 건수는 얼마인가?
Q2. 월별 신청 건수와 신청 시점 기록 금액은 얼마인가?
Q3. 강의별 신청 건수는 얼마인가?
Q4. 지역별 학생 수와 신청 건수는 어떻게 다른가?
Q5. 완료된 신청의 완료 기간은 얼마인가?
```

질문마다 다음 내용을 먼저 결정합니다.

| 항목 | 확인 내용 |
| --- | --- |
| 분석 대상 | 학생, 강의, 수강신청 중 무엇인가? |
| 분석 기간 | 전체인가, 특정 기간인가? |
| 날짜 기준 | 가입일, 신청일, 완료일 중 무엇인가? |
| 행 단위 | 학생 1명인가, 신청 1건인가? |
| 비교 기준 | 상태, 지역, 강의, 월 중 무엇인가? |
| 지표 | 건수, 금액, 평균, 비율 중 무엇인가? |
| 검산 기준 | 전체 행 수와 합계는 얼마여야 하는가? |

좋은 분석은 SQL 문법보다 **질문의 의미를 정확하게 정의하는 것**에서 시작합니다.

---

## STEP 2. 분석 기간을 정확하게 정합니다

이번 실습의 분석 기간을 다음처럼 정해 보겠습니다.

```text
2026-01-01 이상
2026-07-01 미만
```

SQL에서는 다음처럼 표현합니다.

```sql
WHERE enrolled_at >= DATE '2026-01-01'
  AND enrolled_at <  DATE '2026-07-01'
```

이 방식을 반개방 구간이라고 합니다.

```text
[2026-01-01, 2026-07-01)
```

시작은 포함하고 끝은 제외합니다.

날짜뿐 아니라 timestamp로 확장해도 경계가 명확하기 때문에 분석에서 많이 사용하는 방식입니다.

---

## STEP 3. 컬럼 이름보다 업무 의미를 먼저 확인합니다

이번 데이터에는 다음 컬럼이 있습니다.

```text
recorded_amount
```

이 값은 **신청 시점에 기록한 금액**입니다.

다음과 같은 의미로 해석하면 안 됩니다.

```text
결제 완료 금액 X
실제 매출 X
환불 반영 순매출 X
```

따라서 집계할 때도 의미가 드러나도록 이름을 사용합니다.

```sql
SUM(recorded_amount) AS recorded_amount_sum
```

분석에서 가장 위험한 오류 중 하나는 계산이 아니라 **지표의 의미를 잘못 해석하는 것**입니다.

---

## STEP 4. 한 행의 단위, Grain을 확인합니다

이번 분석의 기본 행 단위는 다음과 같습니다.

```text
enrollments 한 행
= 수강신청 1건
```

분석 전에 반드시 질문합니다.

```text
이 데이터셋의 한 행은 무엇을 의미하는가?
```

JOIN을 추가하면 한 행이 여러 행으로 늘어날 수 있습니다.

이 상태에서 바로 `SUM()`이나 `COUNT()`를 실행하면 과대 집계가 발생할 수 있습니다.

---

## STEP 5. COUNT 세 가지를 구분합니다

### 전체 행 수

```sql
SELECT COUNT(*)
FROM analysis_lab.enrollments;
```

`COUNT(*)`는 행 자체를 셉니다.

### NULL이 아닌 값의 수

```sql
SELECT COUNT(completed_at)
FROM analysis_lab.enrollments;
```

`COUNT(column)`은 해당 컬럼이 `NULL`이 아닌 행만 셉니다.

### 중복을 제거한 값의 수

```sql
SELECT COUNT(DISTINCT student_id)
FROM analysis_lab.enrollments;
```

학생 한 명이 여러 강의를 신청했다면 신청 건수와 고유 학생 수는 다릅니다.

```text
COUNT(*)
→ 신청 건수

COUNT(DISTINCT student_id)
→ 신청한 학생 수
```

분석 질문에 맞는 COUNT를 선택해야 합니다.

---

## STEP 6. 상태별 신청 건수를 집계합니다

```sql
SELECT
    status,
    COUNT(*) AS enrollment_count
FROM analysis_lab.enrollments
WHERE enrolled_at >= DATE '2026-01-01'
  AND enrolled_at <  DATE '2026-07-01'
GROUP BY status
ORDER BY status;
```

여기에서 중요한 것은 결과 숫자만 보는 것이 아닙니다.

상태별 건수의 합이 전체 기간 신청 건수와 같은지 확인합니다.

```text
상태별 건수 합계
= 전체 신청 건수
```

이런 작은 검산이 분석 오류를 빠르게 찾는 데 도움이 됩니다.

---

## STEP 7. 월별 신청 건수와 기록 금액을 계산합니다

PostgreSQL의 `date_trunc()`를 사용할 수 있습니다.

```sql
SELECT
    date_trunc('month', enrolled_at)::date AS month,
    COUNT(*) AS enrollment_count,
    SUM(recorded_amount) AS recorded_amount_sum
FROM analysis_lab.enrollments
WHERE enrolled_at >= DATE '2026-01-01'
  AND enrolled_at <  DATE '2026-07-01'
GROUP BY 1
ORDER BY 1;
```

이 결과로 월별 추이를 확인할 수 있습니다.

하지만 한 가지 문제가 있습니다.

**신청이 0건인 달은 결과에서 사라질 수 있습니다.**

---

## STEP 8. 데이터가 없는 월도 표시합니다

분석 보고서에서는 0건인 달도 중요한 정보입니다.

PostgreSQL의 `generate_series()`로 월 목록을 만들 수 있습니다.

```sql
WITH months AS (
    SELECT generate_series(
        DATE '2026-01-01',
        DATE '2026-06-01',
        INTERVAL '1 month'
    )::date AS month
), monthly AS (
    SELECT
        date_trunc('month', enrolled_at)::date AS month,
        COUNT(*) AS enrollment_count
    FROM analysis_lab.enrollments
    WHERE enrolled_at >= DATE '2026-01-01'
      AND enrolled_at <  DATE '2026-07-01'
    GROUP BY 1
)
SELECT
    m.month,
    COALESCE(a.enrollment_count, 0) AS enrollment_count
FROM months AS m
LEFT JOIN monthly AS a
    ON a.month = m.month
ORDER BY m.month;
```

이런 기준 날짜 목록을 흔히 **date spine**이라고 부릅니다.

```text
데이터가 없음
≠ 기간 자체가 없음
```

0건도 분석 결과에 명시적으로 보여주는 것이 좋습니다.

---

## STEP 9. 강의별 신청 건수를 분석합니다

```sql
SELECT
    c.id AS course_id,
    c.title,
    COUNT(e.id) AS enrollment_count
FROM analysis_lab.courses AS c
LEFT JOIN analysis_lab.enrollments AS e
    ON e.course_id = c.id
   AND e.enrolled_at >= DATE '2026-01-01'
   AND e.enrolled_at <  DATE '2026-07-01'
GROUP BY c.id, c.title
ORDER BY enrollment_count DESC, c.id;
```

여기서는 `LEFT JOIN`을 사용했습니다.

신청이 없는 강의도 결과에 남겨야 하기 때문입니다.

또한 기간 조건을 `WHERE`가 아니라 `ON`에 둔 이유도 중요합니다.

잘못 배치하면 신청이 없는 강의가 결과에서 사라질 수 있습니다.

---

## STEP 10. 지역별 학생 수와 신청 건수는 다른 지표입니다

예를 들어 지역별로 다음 두 값을 비교한다고 가정합니다.

```text
학생 수
신청 건수
```

학생 한 명이 여러 번 신청할 수 있으므로 두 숫자는 같지 않습니다.

```sql
SELECT
    s.region,
    COUNT(DISTINCT s.id) AS student_count,
    COUNT(e.id) AS enrollment_count
FROM analysis_lab.students AS s
LEFT JOIN analysis_lab.enrollments AS e
    ON e.student_id = s.id
   AND e.enrolled_at >= DATE '2026-01-01'
   AND e.enrolled_at <  DATE '2026-07-01'
GROUP BY s.region
ORDER BY s.region;
```

여기서도 질문을 분리해야 합니다.

```text
지역에 등록된 전체 학생 수인가?
분석 기간에 신청한 학생 수인가?
신청 건수인가?
```

비슷해 보이지만 서로 다른 지표입니다.

---

## STEP 11. JOIN 후 과대 집계를 확인합니다

다음 구조를 생각해 보겠습니다.

```text
enrollments
→ payments
→ refund_items
```

수강신청 1건에 여러 환불 행이 연결되면 JOIN 결과에서 신청 한 건이 여러 행으로 늘어날 수 있습니다.

이 상태에서 신청 금액을 `SUM()`하면 중복 합산될 수 있습니다.

JOIN 후에는 다음을 확인합니다.

```text
JOIN 전 행 수는 몇 개인가?
JOIN 후 행 수는 몇 개인가?
기본키가 중복됐는가?
집계 대상 값이 반복됐는가?
```

예를 들어 다음처럼 확인할 수 있습니다.

```sql
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT enrollment_id) AS enrollment_count
FROM analysis_lab.enrollment_analysis_dataset;
```

두 값이 달라지는 이유를 설명할 수 있어야 합니다.

---

## STEP 12. 데이터 품질을 분석 전에 검사합니다

그래프를 그리기 전에 데이터가 분석 가능한 상태인지 확인합니다.

예를 들어 다음과 같은 질문이 필요합니다.

```text
학생 가입일보다 신청일이 빠른 데이터가 있는가?
강의 개설일보다 신청일이 빠른가?
완료일이 신청일보다 빠른가?
허용되지 않은 상태값이 있는가?
금액이 음수인 데이터가 있는가?
```

예를 들어 완료일 검사는 다음처럼 작성할 수 있습니다.

```sql
SELECT *
FROM analysis_lab.enrollments
WHERE completed_at IS NOT NULL
  AND completed_at < enrolled_at;
```

정상 데이터라면 결과가 **0행**이어야 합니다.

분석에서도 `0행`은 중요한 검증 증거입니다.

---

## STEP 13. 분석용 VIEW를 만듭니다

Python에서 매번 복잡한 JOIN을 다시 작성하지 않도록 분석용 데이터셋을 VIEW로 만들 수 있습니다.

개념적인 형태는 다음과 같습니다.

```sql
CREATE VIEW analysis_lab.enrollment_analysis_dataset AS
SELECT
    e.id AS enrollment_id,
    e.student_id,
    s.region,
    e.course_id,
    c.title AS course_title,
    e.status,
    e.recorded_amount,
    e.enrolled_at,
    e.completed_at
FROM analysis_lab.enrollments AS e
JOIN analysis_lab.students AS s
    ON s.id = e.student_id
JOIN analysis_lab.courses AS c
    ON c.id = e.course_id
WHERE e.enrolled_at >= DATE '2026-01-01'
  AND e.enrolled_at <  DATE '2026-07-01';
```

VIEW의 장점은 분석 기준을 데이터베이스 쪽에서 명확하게 유지할 수 있다는 것입니다.

```text
기간
JOIN 관계
컬럼 의미
한 행의 단위
```

이 기준을 Python 코드마다 다시 구현하지 않아도 됩니다.

---

## STEP 14. SQL과 Python의 역할을 나눕니다

권장 역할은 다음과 같습니다.

### SQL에서 처리하기 좋은 작업

```text
필요한 행과 열 선택
기간 필터
PK/FK JOIN
대규모 집계
분석용 VIEW 생성
기준값 계산
```

### Python에서 처리하기 좋은 작업

```text
추가 데이터 검증
피벗
재구조화
시각화
통계 분석
SQL 결과와 자동 비교
```

따라서 다음 흐름을 권장합니다.

```text
PostgreSQL 원본
→ SQL로 분석 범위 축소
→ 분석 VIEW
→ Python pandas
→ 시각화
→ SQL 결과와 교차 검증
```

---

## STEP 15. 가장 쉬운 방법은 CSV로 가져오는 것입니다

DBeaver에서 분석 VIEW 결과를 CSV로 내보낸 뒤 pandas에서 읽을 수 있습니다.

```python
import pandas as pd

file_path = "enrollment_analysis_dataset.csv"

df = pd.read_csv(file_path)

print(df.head())
print(df.shape)
print(df.dtypes)
```

파일을 읽었다고 바로 분석하지 않습니다.

최소한 다음을 확인합니다.

```python
print(df.columns.tolist())
print(df.isna().sum())
print(df.duplicated().sum())
```

그리고 데이터 출처도 기록해 두는 것이 좋습니다.

```text
어느 DB에서 추출했는가?
어느 VIEW인가?
언제 추출했는가?
분석 기간은 무엇인가?
행 수는 몇 개인가?
```

---

## STEP 16. Python에서 PostgreSQL에 직접 연결할 수도 있습니다

환경에 따라 `psycopg`와 pandas를 사용할 수 있습니다.

```python
import pandas as pd
import psycopg

conn = psycopg.connect(
    host="localhost",
    port=5432,
    dbname="ai_database_book",
    user="analysis_reader"
)

query = """
SELECT *
FROM analysis_lab.enrollment_analysis_dataset
ORDER BY enrollment_id;
"""

df = pd.read_sql_query(query, conn)
conn.close()

print(df.head())
```

실제 비밀번호를 Python 파일에 직접 작성하거나 GitHub에 커밋하지 않습니다.

가능하면 **읽기 전용 계정**을 사용합니다.

```text
분석용 Python
→ SELECT 권한만 가진 사용자
→ 필요한 VIEW만 조회
```

Chapter 11에서 배운 최소 권한 원칙이 여기에서도 이어집니다.

---

## STEP 17. pandas에서도 데이터 품질을 다시 확인합니다

```python
required_columns = {
    "enrollment_id",
    "student_id",
    "region",
    "course_id",
    "course_title",
    "status",
    "recorded_amount",
    "enrolled_at",
    "completed_at",
}

missing_columns = required_columns - set(df.columns)

if missing_columns:
    raise ValueError(f"필수 컬럼 누락: {missing_columns}")
```

날짜 자료형도 명시적으로 변환합니다.

```python
df["enrolled_at"] = pd.to_datetime(df["enrolled_at"])
df["completed_at"] = pd.to_datetime(df["completed_at"])
```

중복 기본키도 확인합니다.

```python
if df["enrollment_id"].duplicated().any():
    raise ValueError("enrollment_id 중복 발견")
```

Python에서도 **조용히 잘못된 결과를 만드는 것보다 명시적으로 실패시키는 것**이 안전합니다.

---

## STEP 18. pandas로 상태별 건수를 계산합니다

```python
status_summary = (
    df.groupby("status")
      .size()
      .reset_index(name="enrollment_count")
      .sort_values("status")
)

print(status_summary)
```

SQL에서 계산했던 결과와 같은 의미입니다.

SQL:

```sql
SELECT status, COUNT(*)
FROM ...
GROUP BY status;
```

pandas:

```python
df.groupby("status").size()
```

두 결과가 같은지 확인할 수 있습니다.

---

## STEP 19. 월별 분석으로 확장합니다

```python
df["month"] = df["enrolled_at"].dt.to_period("M").astype(str)

monthly_summary = (
    df.groupby("month")
      .agg(
          enrollment_count=("enrollment_id", "count"),
          recorded_amount_sum=("recorded_amount", "sum")
      )
      .reset_index()
)

print(monthly_summary)
```

이때도 SQL과 같은 분석 기간의 **같은 데이터 스냅샷**을 사용해야 합니다.

그렇지 않으면 SQL 실행 후 새 데이터가 추가되어 숫자가 달라질 수 있습니다.

---

## STEP 20. 피벗 테이블을 만들어 봅니다

예를 들어 월별 상태 건수를 보고 싶다면 다음처럼 만들 수 있습니다.

```python
pivot = pd.pivot_table(
    df,
    index="month",
    columns="status",
    values="enrollment_id",
    aggfunc="count",
    fill_value=0,
)

print(pivot)
```

pandas는 이런 재구조화 작업에서 매우 편리합니다.

하지만 피벗 결과의 전체 합계가 원본 행 수와 맞는지도 확인해야 합니다.

```python
assert pivot.to_numpy().sum() == len(df)
```

---

## STEP 21. matplotlib으로 간단한 그래프를 그립니다

```python
import matplotlib.pyplot as plt

monthly_summary.plot(
    x="month",
    y="enrollment_count",
    kind="bar",
    legend=False,
)

plt.title("월별 수강신청 건수")
plt.xlabel("월")
plt.ylabel("신청 건수")
plt.tight_layout()
plt.show()
```

그래프가 정상적으로 보인다고 분석이 검증된 것은 아닙니다.

그래프는 **이미 검증한 숫자를 사람이 이해하기 쉽게 표현하는 단계**입니다.

```text
숫자 검증
→ 그래프 생성
```

순서를 바꾸지 않는 것이 좋습니다.

---

## STEP 22. SQL과 pandas 결과를 교차 검증합니다

이번 Chapter에서 가장 중요한 부분입니다.

예를 들어 SQL에서 계산한 전체 신청 건수를 기준값으로 저장했다고 가정합니다.

```python
sql_enrollment_count = 24
python_enrollment_count = len(df)

assert python_enrollment_count == sql_enrollment_count
```

금액도 비교할 수 있습니다.

```python
sql_amount_sum = 2400000
python_amount_sum = df["recorded_amount"].sum()

assert python_amount_sum == sql_amount_sum
```

실제 기준값은 실습 SQL 실행 결과에서 가져와야 합니다.

중요한 원칙은 다음입니다.

```text
SQL 결과와 Python 결과가 같아야 한다.
```

다르면 어느 쪽이 맞다고 바로 결론 내리지 않습니다.

```text
분석 기간이 같은가?
필터가 같은가?
JOIN 결과가 같은가?
NULL 처리 방식이 같은가?
중복 행이 있는가?
같은 데이터 시점인가?
```

부터 확인합니다.

---

## STEP 23. 완료 상태 비중과 완료율을 구분합니다

예를 들어 현재 상태가 `완료`인 신청의 비중을 계산했다고 가정합니다.

```text
현재 완료 상태 건수 / 전체 신청 건수
```

이 값을 곧바로 교육 서비스의 **완료율**이라고 부르면 위험할 수 있습니다.

진짜 완료율을 계산하려면 다음과 같은 추가 정의가 필요할 수 있습니다.

```text
어떤 신청을 분모에 포함하는가?
취소는 제외하는가?
아직 학습 기간이 끝나지 않은 신청은 어떻게 하는가?
관찰 기간은 충분한가?
```

따라서 분석 결과에는 이름을 정확하게 붙입니다.

```text
현재 완료 상태 비중
```

과

```text
완료율
```

은 같은 개념이 아닐 수 있습니다.

---

## STEP 24. 분석 결과는 관찰과 해석을 분리합니다

예를 들어 다음 결과가 나왔다고 가정합니다.

```text
3월 신청 건수가 가장 많다.
```

이것은 **관찰**입니다.

하지만 다음 문장은 해석입니다.

```text
3월 마케팅 캠페인이 성공했기 때문이다.
```

현재 데이터에 캠페인 정보가 없다면 근거가 부족합니다.

따라서 보고서는 다음처럼 작성합니다.

```text
관찰
→ 3월 신청 건수가 분석 기간 중 가장 많았다.

해석 후보
→ 프로모션, 강의 개설 시점, 계절성 등이 영향을 주었을 수 있다.

한계
→ 현재 데이터만으로 원인을 확정할 수 없다.
```

AI에게 분석 결과를 설명하게 할 때도 이 구분이 중요합니다.

---

## STEP 25. AI가 만든 분석 SQL과 Python을 검증합니다

ChatGPT나 Codex는 분석 코드를 빠르게 만들어 줍니다.

하지만 다음과 같은 오류가 있을 수 있습니다.

```text
분석 기간이 다름
COUNT(*)와 COUNT(DISTINCT)를 혼동
LEFT JOIN이 INNER JOIN처럼 변함
JOIN 중복으로 금액이 과대 집계됨
NULL을 0으로 처리해야 하는데 누락
신청 시점 기록 금액을 매출이라고 표현
SQL과 pandas가 서로 다른 데이터 범위를 사용
```

따라서 AI에게 코드만 요청하지 말고 **검증 SQL과 예상 위험까지 함께 요청**하는 것이 좋습니다.

---

## AI 활용 실습 1. 분석 SQL을 만들고 검증해 봅시다

ChatGPT에 다음 프롬프트를 입력해 보세요.

```text
나는 PostgreSQL 데이터 분석을 처음 배우는 초보자입니다.

수강신청 테이블 enrollments에 다음 컬럼이 있습니다.
- id
- student_id
- course_id
- status
- recorded_amount
- enrolled_at
- completed_at

2026-01-01 이상, 2026-07-01 미만 데이터를 기준으로
월별 신청 건수와 recorded_amount 합계를 계산하는 SQL을 작성해 주세요.

조건:
1. recorded_amount는 매출이 아니라 신청 시점 기록 금액이라고 설명
2. 데이터가 없는 월도 0건으로 표시
3. 전체 건수와 월별 합계를 비교하는 검증 SQL도 작성
4. 초보자가 이해할 수 있게 설명
```

결과를 받은 뒤 다음을 확인합니다.

```text
기간 경계가 정확한가?
0건인 월이 유지되는가?
금액 의미를 과장하지 않는가?
검산 SQL이 포함됐는가?
```

---

## AI 활용 실습 2. SQL 결과를 pandas로 교차 검증합니다

다음 프롬프트를 사용해 보세요.

```text
PostgreSQL 분석 VIEW를 pandas DataFrame으로 읽었습니다.

컬럼은 다음과 같습니다.
- enrollment_id
- student_id
- region
- course_id
- course_title
- status
- recorded_amount
- enrolled_at
- completed_at

다음 Python 코드를 작성해 주세요.

1. 필수 컬럼 존재 여부 검사
2. enrollment_id 중복 검사
3. 날짜 자료형 변환
4. 상태별 건수 계산
5. 월별 건수와 recorded_amount 합계 계산
6. SQL 기준값과 pandas 결과를 assert로 비교
7. 월별 신청 건수 막대그래프 생성

코드 실행 성공만 확인하지 말고 어떤 항목을 검증해야 하는지도 설명해 주세요.
```

AI가 만든 코드를 실행한 뒤 SQL 결과와 실제로 비교합니다.

---

## 오늘의 핵심 정리

이번 Chapter에서 꼭 기억할 내용입니다.

```text
분석 질문
→ SQL보다 먼저 정의

분석 기간
→ 시작과 종료 경계를 명확하게 정의

Grain
→ 한 행이 무엇을 의미하는지 확인

COUNT(*)
→ 행 수

COUNT(column)
→ NULL이 아닌 값 수

COUNT(DISTINCT column)
→ 중복 제거한 값 수

SQL
→ 필터·JOIN·집계·분석 기준 확정

Python pandas
→ 추가 가공·피벗·시각화·검증

교차 검증
→ 같은 데이터에서 SQL과 pandas 결과 비교
```

가장 중요한 분석 흐름은 다음입니다.

```text
질문 정의
→ 기간·행 단위·지표 의미 확정
→ SQL 분석
→ 데이터 품질 검사
→ 분석 VIEW
→ pandas 분석
→ 시각화
→ SQL과 pandas 교차 검증
→ 관찰·해석·한계 기록
```

AI 시대에도 분석의 핵심은 코드 생성 속도가 아닙니다.

```text
AI가 SQL과 Python을 만들 수 있다.
하지만 숫자의 의미와 분석 범위를 결정하고
결과가 실제 데이터와 맞는지 검증하는 것은 사람의 역할이다.
```

---

## 다음 시간에는

다음 Chapter 15에서는 지금까지 배운 내용을 하나로 연결합니다.

**요구사항 → 데이터 모델 → PostgreSQL 구현 → SQL → 트랜잭션 → 성능 → 보안·복구 → AI 검증 → Python 분석**까지 전체 프로젝트를 다시 점검하고, AI 시대에 데이터베이스를 어떻게 학습하고 활용해야 하는지 정리합니다.

---

## 관련 글

- Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기
- Chapter 15. AI 시대 데이터베이스 프로젝트 종합 실습

---

#PostgreSQL #SQL #Python #pandas #데이터분석 #DBeaver #ChatGPT #Codex #데이터베이스 #데이터베이스강의