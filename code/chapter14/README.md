# Chapter 14 실습 코드

## SQL 데이터 분석과 Python 확장

이 폴더는 `analysis_lab` 전용 스키마에서 SQL 데이터 분석을 수행하고, 분석용 VIEW를 CSV 또는 PostgreSQL 연결로 Python과 pandas에 전달한 뒤 결과를 교차 검증하는 파일을 관리합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: 변경하지 않음
nosql_lab: 변경하지 않음
ai_review_lab: 변경하지 않음
analysis_lab: Chapter 14 실습 대상
```

생성 파일에서는 기존 객체를 자동으로 삭제하지 않습니다. 처음부터 다시 시작할 때만 `reset_analysis_lab.sql`을 검토한 후 선택 실행합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_analysis_lab_schema.sql` | 학생·강사·강의·수강신청 분석 스키마 생성 |
| `02_analysis_lab_seed.sql` | 2026년 1~6월 기준 샘플 데이터 입력 |
| `03_data_quality_checks.sql` | 행 수·중복·고아 FK·상태·날짜·금액 점검 |
| `04_summary_analysis.sql` | 상태·강의·지역별 기본 집계 |
| `05_period_category_analysis.sql` | 월별·범주별 분석, LAG와 완료 기간 확인 |
| `06_analysis_dataset.sql` | 수강신청 1건 단위 분석 VIEW 생성 |
| `07_analysis_validation.sql` | 기대값과 실제 결과 최종 검산 |
| `reset_analysis_lab.sql` | `analysis_lab`만 선택적으로 초기화 |
| `python/requirements.txt` | Python 분석 패키지 목록 |
| `python/.env.example` | `DATABASE_URL` 예시 |
| `python/01_load_csv.py` | DBeaver CSV를 pandas로 읽고 구조 확인 |
| `python/02_load_postgresql.py` | PostgreSQL 분석 VIEW를 pandas로 읽기 |
| `python/03_pandas_analysis.py` | 상태·월·강의 분석과 피벗·그래프 |
| `python/04_result_validation.py` | SQL 기준값과 pandas 결과 자동 비교 |

---

## 실행 순서

```text
01_analysis_lab_schema.sql
→ 02_analysis_lab_seed.sql
→ 03_data_quality_checks.sql
→ 04_summary_analysis.sql
→ 05_period_category_analysis.sql
→ 06_analysis_dataset.sql
→ 07_analysis_validation.sql
```

그다음 두 경로 중 하나를 선택합니다.

```text
기본 경로
DBeaver 조회 결과를 CSV로 저장
→ python/01_load_csv.py
→ python/03_pandas_analysis.py
→ python/04_result_validation.py

확장 경로
.env에 개발·테스트 DB의 DATABASE_URL 설정
→ python/02_load_postgresql.py
→ python/03_pandas_analysis.py
→ python/04_result_validation.py
```

---

## 기준 데이터

| 항목 | 기대값 |
| --- | ---: |
| `students` | 8 |
| `instructors` | 3 |
| `courses` | 5 |
| `enrollments` | 24 |
| `enrollment_analysis_dataset` | 24 |
| 데이터셋 PK 중복 | 0 |

상태별 기준:

| status | 기대 건수 |
| --- | ---: |
| 완료 | 12 |
| 수강중 | 5 |
| 신청 | 4 |
| 취소 | 3 |

월별 기준:

| 월 | 신청 건수 | 결제금액 |
| --- | ---: | ---: |
| 2026-01 | 3 | 200000 |
| 2026-02 | 4 | 520000 |
| 2026-03 | 5 | 540000 |
| 2026-04 | 4 | 550000 |
| 2026-05 | 4 | 390000 |
| 2026-06 | 4 | 570000 |

추가 기준:

```text
전체 수강신청 24
결제금액 합계 2,770,000
완료 건수 12
평균 완료 기간 25일
최소 완료 기간 18일
최대 완료 기간 36일
고아 FK 0
상태·완료일 이상 0
```

---

## 분석 데이터셋

VIEW:

```text
analysis_lab.enrollment_analysis_dataset
```

행 단위:

```text
수강신청 1건 = enrollment_id 1개
```

주요 컬럼:

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

Python 분석 전 다음을 확인합니다.

```text
행 수 24
중복 enrollment_id 0
날짜 컬럼 형식
paid_amount 숫자형
completed_at NULL 허용
```

---

## CSV 경로

DBeaver에서 다음 조회를 실행합니다.

```sql
SELECT *
FROM analysis_lab.enrollment_analysis_dataset
ORDER BY enrollment_id;
```

결과를 UTF-8 CSV로 저장합니다.

권장 경로:

```text
code/chapter14/data/enrollment_analysis_dataset.csv
```

`data/` 폴더와 CSV는 실행 과정에서 생성될 수 있습니다. 실제 개인정보가 포함된 파일은 저장소에 커밋하지 않습니다.

---

## Python 환경

가상환경 생성:

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

---

## PostgreSQL 연결

`python/.env.example`을 참고해 `.env`를 만듭니다.

```text
DATABASE_URL=postgresql+psycopg://db_user:db_password@localhost:5432/db_name
```

안전 원칙:

```text
- 운영 DB가 아닌 개발·테스트 DB를 사용합니다.
- 실제 비밀번호를 코드나 노트북에 적지 않습니다.
- .env를 GitHub에 커밋하지 않습니다.
- SELECT 중심의 읽기 전용 계정을 우선 검토합니다.
- Python 분석 코드에서 UPDATE·DELETE·DROP을 자동 실행하지 않습니다.
```

---

## Python 실행 예

CSV 경로:

```bash
python code/chapter14/python/01_load_csv.py
python code/chapter14/python/03_pandas_analysis.py
python code/chapter14/python/04_result_validation.py
```

PostgreSQL 연결 경로:

```bash
python code/chapter14/python/02_load_postgresql.py
python code/chapter14/python/03_pandas_analysis.py --source postgresql
python code/chapter14/python/04_result_validation.py --source postgresql
```

각 스크립트는 파일 또는 환경변수가 없을 때 명확한 오류 메시지를 출력하도록 구성합니다.

---

## 결과 검증 원칙

```text
- SQL과 pandas의 전체 행 수를 비교합니다.
- 상태별·월별 건수의 합이 24인지 확인합니다.
- 결제금액 합계가 2,770,000인지 확인합니다.
- 완료 건수와 완료 기간 통계를 비교합니다.
- 불일치할 때 기대값을 실제값으로 바꾸지 않습니다.
- 날짜 범위, JOIN, NULL, 중복, 자료형과 실행 시점을 확인합니다.
```

---

## AI 활용 원칙

```text
- 분석 질문·기간·행 단위·기대값을 함께 제공합니다.
- PK·FK와 JOIN 경로를 명시합니다.
- SQL과 Python 수정 범위를 구분합니다.
- 파괴적 SQL과 접속 정보 노출을 확인합니다.
- dropna·drop_duplicates가 오류를 숨기지 않는지 확인합니다.
- 별도의 SQL 기준값으로 Python 결과를 검산합니다.
- diff와 실행 결과를 확인한 후 사람이 승인합니다.
```
