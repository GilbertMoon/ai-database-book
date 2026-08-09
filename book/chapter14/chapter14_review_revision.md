# Chapter 14 최종 출판 검수 반영 기록

## 대상

```text
Chapter 14. SQL 데이터 분석과 Python 확장
```

## 검수 목적

Chapter 14를 단순한 SQL 집계와 pandas 소개가 아니라 다음 흐름을 재현할 수 있는 분석 장으로 완성했습니다.

```text
분석 질문·기간·행 단위·지표 정의
→ SQL 품질 검사·집계
→ 기간 제한 분석 VIEW
→ CSV manifest 또는 읽기 전용 DB 연결
→ pandas strict 검증·시각화
→ 실제 SQL·pandas 결과 교차 검증
```

---

## 1. 금액 의미 수정

기존의 “결제금액” 표현을 다음 기준으로 통일했습니다.

```text
recorded_amount 물리 컬럼
→ 신청 시점 기록 금액
→ 결제 성공·환불·회계 매출을 의미하지 않음
```

SQL 별칭과 분석 VIEW·Python에서는 `recorded_amount`, `recorded_amount_sum`을 사용합니다.

---

## 2. P14 분석 추적 ID

```text
P14-Q01 상태별 신청 건수
P14-Q02 월별 신청 수와 기록 금액
P14-Q03 강의별 신청 건수
P14-Q04 지역별 학생·신청 건수
P14-Q05 완료된 신청의 완료 기간

P14-V01 실행 위치·스키마 보호
P14-V02 데이터 품질
P14-V03 SQL 기준 결과
P14-V04 Python 컬럼·자료형
P14-V05 SQL·pandas 교차 검증
```

본문·SQL·워크북·구성안에 같은 ID를 반영했습니다.

---

## 3. 생성·Seed·초기화 안전성

`01_analysis_lab_schema.sql`:

```text
현재 DB = ai_database_book
analysis_lab 미존재
스키마·테이블·기간 VIEW를 한 트랜잭션에서 생성
```

`02_analysis_lab_seed.sql`:

```text
필요 객체 존재
네 테이블 모두 0행
BEGIN → 입력 → IDENTITY → 자동 판정 → COMMIT
```

`reset_analysis_lab.sql`:

```text
ai_database_book에서만 실행
VIEW → 자식 테이블 → 부모 테이블 → 스키마 순서
```

---

## 4. 분석 기간 중앙화

신규 VIEW:

```text
analysis_lab.analysis_parameters
start_date = 2026-01-01
end_date_exclusive = 2026-07-01
```

모든 주요 SQL과 분석 VIEW에 다음 반개방 기간을 실제 적용했습니다.

```text
[2026-01-01, 2026-07-01)
```

Seed 범위에 의존해 기간 조건을 생략하던 문제를 제거했습니다.

---

## 5. Chapter 07 활성 신청 정책 유지

```sql
CREATE UNIQUE INDEX uq_analysis_enrollments_active
ON analysis_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

완료·취소 이력 뒤 재신청은 허용하고 진행 중 중복만 차단합니다.

같은 날짜의 동일 원천 적재 중복은 별도 복합 UNIQUE로 관리합니다.

---

## 6. Seed 원자성과 IDENTITY

명시적 ID 다음 값:

```text
students 109
instructors 204
courses 306
enrollments 1025
```

COMMIT 전에 다음을 판정합니다.

```text
행 수 8/3/5/24
기록 금액 합계 3,210,000
완료 12건
활성 신청 중복 0
```

---

## 7. 데이터 품질 확대

추가 검증:

```text
고아 강사
신청일 < 학생 가입일
신청일 < 강의 개설일
분석 기간 밖 행
활성 신청 중복
```

기존의 PK·FK·완료일·음수·취소 금액 검사와 함께 최종 게이트에 포함했습니다.

---

## 8. date spine 적용

월별 SQL은 `generate_series`로 2026년 1~6월 기준표를 생성합니다.

```text
데이터 없는 월도 0건 유지
LAG의 이전 행 = 실제 이전 달
그래프 월 간격 유지
```

pandas 월별 분석도 같은 월 기준표를 사용합니다.

---

## 9. 완료 지표 명칭 수정

기존 `completion_rate_pct`를 다음으로 변경했습니다.

```text
completed_share_pct
→ 전체 신청 중 현재 완료 상태의 비중
```

실제 완료율에는 충분한 관찰 기간·코호트·취소 포함 정책이 필요함을 명시했습니다.

완료 기간은 완료된 12행만의 통계이며 전체 수강생으로 일반화하지 않도록 해석 범위를 추가했습니다.

---

## 10. 분석 VIEW 수정

```text
analysis_lab.enrollment_analysis_dataset
```

변경 내용:

```text
분석 기간 실제 적용
recorded_amount → recorded_amount 별칭
instructor_id·instructor_name 포함
정확한 17개 컬럼
한 행 = enrollment_id 1건
```

---

## 11. SQL 최종 자동 게이트 추가

신규 파일:

```text
code/chapter14/08_analysis_lab_validation.sql
```

자동 판정:

```text
정확한 테이블 4개·VIEW 2개
분석 기간 한 행
행 수 8/3/5/24/24
정확한 데이터셋 컬럼 17개
제약조건 20개·IDENTITY 4개
활성 신청 부분 고유 인덱스
상태별 12/5/4/3
월별 건수·기록 금액
완료 기간 12/25/18/36
품질 이상 0
IDENTITY 다음 값 > 최대 ID
```

통과 메시지:

```text
Chapter 14 analysis_lab validation passed
```

---

## 12. 접속 정보 정책 통일

기존 `DATABASE_URL` 예시를 제거하고 Chapter 11과 같은 libpq 변수로 변경했습니다.

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
```

실제 password file은 저장소 밖에 둡니다. SQLAlchemy는 `URL.create()`를 사용하며 비밀번호를 코드에 넣지 않습니다.

---

## 13. 공통 Python 검증 모듈 추가

신규 파일:

```text
code/chapter14/python/validation_utils.py
```

공통 판정:

```text
정확한 17개 컬럼
24행·고유 enrollment_id
strict 날짜·숫자·boolean
status·is_completed 일치
완료일·완료 기간 일치
분석 기간 안의 행
```

`errors="coerce"`를 제거하고 `errors="raise"`를 적용했습니다.

---

## 14. 읽기 전용 PostgreSQL 연결

Python 연결은 다음을 확인합니다.

```text
DB = ai_database_book
분석 VIEW 존재
transaction_read_only = on
```

`default_transaction_read_only=on`으로 분석 세션을 생성합니다.

---

## 15. CSV manifest와 기준값

신규 파일:

```text
python/analysis_manifest.example.json
python/reference_metrics.json
```

manifest 항목:

```text
source_database
source_user
source_view
transaction_read_only
분석 기간
행 수
생성 UTC 시각
CSV SHA-256
```

`02_load_postgresql.py --export-csv`는 CSV와 manifest를 함께 생성합니다.

---

## 16. 실제 SQL·pandas 교차 검증

기존 Python 하드코딩 상수 비교를 수정했습니다.

PostgreSQL 경로:

```text
같은 읽기 전용 REPEATABLE READ 스냅샷
→ 실제 SQL 상태·월별·완료 기간 DataFrame
→ pandas DataFrame
→ assert_frame_equal
```

CSV 경로:

```text
CSV + manifest·SHA-256 + reference_metrics.json
```

---

## 17. 시각화 재현성

```text
Agg 헤드리스 백엔드
설치된 한글 글꼴 탐색
없으면 명확한 경고
Y축 0 시작
그래프 파일은 output/에 저장·Git 제외
```

글꼴 파일은 저장소에 추가하지 않았습니다.

---

## 18. 파일 동기화

수정:

```text
book/chapter14/chapter14.md
book/chapter14/chapter14_activity.md
book/chapter14/chapter14_outline.md
book/chapter14/chapter14_review_revision.md
code/chapter14/01_analysis_lab_schema.sql
code/chapter14/02_analysis_lab_seed.sql
code/chapter14/03_data_quality_checks.sql
code/chapter14/04_summary_analysis.sql
code/chapter14/05_period_category_analysis.sql
code/chapter14/06_analysis_dataset.sql
code/chapter14/07_analysis_validation.sql
code/chapter14/reset_analysis_lab.sql
code/chapter14/python/.env.example
code/chapter14/python/01_load_csv.py
code/chapter14/python/02_load_postgresql.py
code/chapter14/python/03_pandas_analysis.py
code/chapter14/python/04_result_validation.py
code/chapter14/README.md
notes/chapter14_review_checklist.md
README.md
```

신규:

```text
code/chapter14/08_analysis_lab_validation.sql
code/chapter14/python/validation_utils.py
code/chapter14/python/reference_metrics.json
code/chapter14/python/analysis_manifest.example.json
```

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 금액 의미 통일 | 완료 |
| DB 보호·트랜잭션 | 완료 |
| 기간 중앙화 | 완료 |
| date spine | 완료 |
| 활성 신청 정책 | 완료 |
| 시간 관계 품질 검사 | 완료 |
| 완료 비중 명칭 | 완료 |
| 분석 VIEW 기간·컬럼 | 완료 |
| SQL 예외 기반 게이트 | 완료 |
| libpq·password file 정책 | 완료 |
| Python 공통 strict 검증 | 완료 |
| CSV manifest·해시 | 완료 |
| 실제 SQL·pandas 비교 | 완료 |
| 헤드리스·글꼴 경고 | 완료 |
| 워크북 권장 해설 | 완료 |

## 남은 실제 검증

```text
PostgreSQL에서 01→08 순차 실행
Python 가상환경 설치
PostgreSQL 읽기 전용 직접 경로 실행
CSV·manifest 생성과 SHA-256 확인
CSV 경로·DB 경로의 04_result_validation.py 통과
Windows·macOS·Linux 한글 그래프 확인
GitHub·Word·PDF·eBook 렌더링 확인
```

## 결론

```text
Chapter 14는 SQL과 Python을 나열하는 장에서,
같은 기간·행 단위·스냅샷의 실제 결과를 교차 검증하는
재현 가능한 데이터 분석 장으로 완성되었다.
```
