# Chapter 14 방향 전환 반영 기록

## 대상 Chapter

```text
기존: 벡터 검색과 RAG로 근거 있는 답변 만들기
변경: SQL 데이터 분석과 Python 확장
```

## 변경 목적

도서 전체 방향을 데이터베이스 입문, PostgreSQL·SQL 실습, 데이터 설계와 검증, SQL 분석과 Python 확장 중심으로 조정했습니다.

Chapter 14는 Vector DB·임베딩·RAG 설명과 실습을 제거하고, 앞 장에서 학습한 SQL을 실제 데이터 분석에 적용한 뒤 Python과 pandas로 확장하는 장으로 전면 재구성합니다.

```text
분석 질문 정의
→ SQL 필터·JOIN·집계
→ 데이터 품질 확인
→ 분석용 데이터셋 생성
→ CSV 또는 PostgreSQL 연결
→ pandas 가공·피벗·시각화
→ SQL·Python 결과 교차 검증
```

---

## 1. 본문 변경

### 기존 중심 내용

```text
벡터 검색
임베딩
Top-k와 거리
pgvector
RAG 검색·답변 평가
청킹과 문서 수명주기
```

### 변경 중심 내용

```text
분석 질문과 기간·행 단위
SQL 조건별·범주별 집계
기간별 분석과 LAG
NULL·중복·고아·정합성 점검
분석용 VIEW
DBeaver CSV 내보내기
PostgreSQL·Python 연결
pandas groupby·agg·pivot_table
matplotlib 시각화
SQL·Python 교차 검증
AI 생성 분석 코드 검토
```

---

## 2. 실습 스키마 변경

### 기존

```text
rag_lab.document_sources
rag_lab.document_chunks
rag_lab.query_cases
rag_lab.relevance_judgments
rag_lab.retrieval_runs
rag_lab.answer_reviews
```

### 변경

```text
analysis_lab.students
analysis_lab.instructors
analysis_lab.courses
analysis_lab.enrollments
analysis_lab.enrollment_analysis_dataset VIEW
```

앞 장 스키마는 변경하지 않습니다.

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
public
```

---

## 3. 기준 데이터

```text
students 8
instructors 3
courses 5
enrollments 24
분석 데이터셋 24행
```

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

추가 검산 기준:

```text
결제금액 합계 2,770,000
완료 건수 12
평균 완료 기간 25일
분석 VIEW 중복 enrollment_id 0
고아 FK 0
상태·완료일 이상 0
```

---

## 4. SQL 실습 구조

```text
01_analysis_lab_schema.sql
- analysis_lab과 학생·강사·강의·수강신청 테이블 생성

02_analysis_lab_seed.sql
- 2026년 1~6월 분석 기준 데이터 입력

03_data_quality_checks.sql
- 행 수·PK 중복·고아 FK·상태·날짜·금액 점검

04_summary_analysis.sql
- 상태·강의·지역별 집계

05_period_category_analysis.sql
- 월별 신청·결제금액·증감·완료 기간 분석

06_analysis_dataset.sql
- 수강신청 1건 단위 분석 VIEW 생성

07_analysis_validation.sql
- 기대값과 실제 결과를 비교하는 최종 검산

reset_analysis_lab.sql
- analysis_lab만 선택적으로 초기화
```

---

## 5. Python 실습 구조

```text
python/requirements.txt
- pandas·matplotlib·SQLAlchemy·psycopg·python-dotenv

python/.env.example
- DATABASE_URL 예시

python/01_load_csv.py
- DBeaver에서 내보낸 CSV 읽기·행 수·중복 확인

python/02_load_postgresql.py
- 환경변수 기반 PostgreSQL VIEW 읽기

python/03_pandas_analysis.py
- 상태·월·강의 집계와 피벗·그래프

python/04_result_validation.py
- SQL 기준값과 pandas 결과 자동 비교
```

Python 실습은 다음 두 경로를 제공합니다.

```text
기본 경로
DBeaver SQL 결과 → CSV → pandas

확장 경로
PostgreSQL VIEW → SQLAlchemy·psycopg → pandas
```

---

## 6. 데이터 품질 검증 강화

집계 전에 다음을 확인하도록 구성했습니다.

```text
테이블별 행 수
PK 중복
고아 student_id
고아 course_id
완료인데 completed_at NULL
미완료인데 completed_at 존재
음수 결제금액
취소인데 결제금액이 0이 아님
분석 VIEW의 행 수와 PK 중복
```

NULL을 무조건 오류로 처리하지 않고 업무 상태와 함께 해석합니다.

---

## 7. SQL 분석 강화

```text
상태별 수강신청 건수
강의별 신청 수와 결제금액
지역별 학생 수와 신청 수
월별 신청 수와 결제금액
LAG를 이용한 이전 달 비교
완료 수강의 평균 완료 기간
```

`COUNT(*)`, `COUNT(child.id)`, `COUNT(DISTINCT ...)`의 차이를 실제 분석 질문에 연결합니다.

---

## 8. 분석 데이터셋 추가

```text
analysis_lab.enrollment_analysis_dataset
```

행 단위:

```text
수강신청 1건 = enrollment_id 1개
```

주요 파생 컬럼:

```text
enrollment_month
completion_days
is_completed
```

분석 데이터셋이 24행이고 `enrollment_id` 중복이 0인지 검증합니다.

---

## 9. SQL과 Python의 역할 구분

```text
SQL
- 데이터베이스 안에서 필터·JOIN·집계
- 분석 범위와 행 단위 확정
- 분석용 VIEW 생성

Python
- 결과 추가 가공
- 피벗·시각화
- 자동 비교와 후속 분석
```

원본 전체를 Python으로 가져온 뒤 관계와 집계를 다시 구현하는 흐름은 기본 경로로 사용하지 않습니다.

---

## 10. SQL·Python 교차 검증

다음 기준을 SQL과 pandas에서 모두 확인합니다.

```text
전체 행 수 24
상태별 합계 24
월별 합계 24
결제금액 합계 2,770,000
완료 건수 12
평균 완료 기간 25일
```

결과가 다를 때 기대값을 실제값으로 바꾸지 않고 날짜 범위, JOIN, NULL, 중복, 자료형과 실행 시점을 확인합니다.

---

## 11. 보안과 운영 원칙

```text
운영 DB가 아닌 개발·테스트 DB 사용
비밀번호·접속 URL 코드 직접 입력 금지
.env GitHub 커밋 금지
SELECT 중심의 읽기 전용 연결 우선 검토
Python 분석 코드에서 원본 변경 SQL 자동 실행 금지
실제 개인정보가 포함된 CSV 저장소 커밋 금지
```

---

## 12. AI 검토 범위 확장

AI가 생성한 다음 항목을 함께 검토합니다.

```text
분석 SQL
분석 VIEW
Python 데이터 로딩 코드
pandas 집계 코드
시각화 코드
결과 검증 코드
```

검토 기준:

```text
PK·FK JOIN 경로
집계 단위
날짜 범위
NULL·취소 처리
파괴적 SQL
비밀번호 노출
임의 dropna·drop_duplicates
SQL 기준값과 Python 결과 일치
요청 범위 밖 파일 변경
```

---

## 13. 워크북 변경

기존 벡터·RAG 기록지를 다음 실습 기록지로 교체했습니다.

```text
분석 질문
데이터 모델과 JOIN 경로
기준 행 수
데이터 품질
상태·강의·지역·월별 집계
분석 데이터셋
CSV 내보내기
Python 환경
PostgreSQL 연결
pandas 분석
시각화
SQL·Python 결과 비교
해석과 한계
AI 생성 코드 검토
```

---

## 14. 이미지 변경 방향

기존 임베딩·RAG 이미지 8종을 다음 도식으로 교체합니다.

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

모든 SVG는 같은 이름의 Mermaid 원본과 동기화합니다.

---

## 15. 남은 실행 확인

```text
- 실제 PostgreSQL에서 01→07 순서 실행
- 테이블 행 수 8·3·5·24 확인
- 상태별 12·5·4·3 확인
- 월별 3·4·5·4·4·4 확인
- 결제금액 2,770,000 확인
- 분석 VIEW 24행·중복 0 확인
- CSV UTF-8·헤더·행 수 확인
- Python 패키지 설치 및 스크립트 실행
- SQL·pandas 결과 일치 확인
- 그래프 한글 글꼴과 출판 렌더링 확인
- GitHub·Word·PDF·eBook 이미지 렌더링 확인
```

## 최종 상태

```text
Chapter 14의 본문, 구성안과 독자 워크북을 SQL 데이터 분석과 Python 확장 방향으로 전면 교체했습니다.
Vector DB·임베딩·RAG는 현재 도서의 기본 설명과 실습 범위에서 제외합니다.
실제 PostgreSQL·Python 실행과 출판 렌더링 결과는 별도 검증 후 통과로 기록합니다.
```
