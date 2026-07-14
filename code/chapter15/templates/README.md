# AI 튜터링 질문 관리 서비스

## 프로젝트 목표

학생 질문, 튜터 답변과 학습 자료 연결을 PostgreSQL로 관리하고, SQL과 Python 분석 결과까지 다른 사람이 같은 순서로 재현할 수 있는 프로젝트를 완성합니다.

```text
요구사항
→ ERD
→ DDL
→ 기준 데이터
→ 검증 SQL
→ 분석 VIEW
→ Python·pandas 분석
→ SQL·Python 교차 검증
→ 운영 계획·AI 검토·완료 게이트
```

## 현재 범위

```text
학생·튜터·질문·답변·학습 자료 관리
정상·경계·오류·트랜잭션 검증
인덱스·운영·백업·복구 검토
질문 1건 단위 분석 데이터셋
SQL·Python 핵심 집계 검증
최종 완료 상태 판정
```

제외 범위:

```text
실제 인증·개인정보
웹·API
NoSQL 연동
실제 LLM API 호출
클라우드 배포
자동 Role 생성
자동 백업·복원
```

## 실행 파일

```text
01_schema.sql
02_seed.sql
03_metadata_validation.sql
04_requirement_queries.sql
05_transaction_checks.sql
06_negative_tests.sql
07_performance_checks.sql
08_operations_checks.sql
09_analysis_dataset.sql
10_completion_gate.sql
```

필수 실행은 `01~10`입니다.

Python:

```text
python/requirements.txt
python/.env.example
python/01_load_postgresql.py
python/02_pandas_analysis.py
python/03_result_validation.py
```

문서:

```text
requirements.md
erd.md
OPERATIONS_RUNBOOK.md
ai_review_report.md
analysis_report.md
final_report.md
```

## 실행 예시

```bash
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 01_schema.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 02_seed.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 03_metadata_validation.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 04_requirement_queries.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 05_transaction_checks.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 06_negative_tests.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 07_performance_checks.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 08_operations_checks.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 09_analysis_dataset.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 10_completion_gate.sql
```

운영 DB가 아닌 개발·테스트 환경에서 실행합니다.

## 기대 결과

| 항목 | 기대 |
| --- | ---: |
| students | 4 |
| tutors | 3 |
| questions | 5 |
| answers | 5 |
| learning_materials | 6 |
| question_materials | 7 |
| FK | 5 |
| 업무 인덱스 | 3 |
| CASCADE FK | 0 |
| 질문 없는 학생 | 1 |
| 연결되지 않은 자료 | 1 |
| 답변 없는 open 질문 | 1 |
| 자동 반례 unexpected | 0 |
| 분석 VIEW 행 수 | 5 |
| 분석 VIEW question_id 중복 | 0 |
| answer_count 합계 | 5 |
| material_count 합계 | 7 |
| `required_completion_gate_passed` | true |

## Python 분석 절차

1. `.env.example`을 복사해 `.env`를 만들고 개발·테스트 DB 정보를 입력합니다.
2. `python/01_load_postgresql.py`로 분석 VIEW를 읽습니다.
3. `python/02_pandas_analysis.py`로 상태별·월별·학생별 집계를 만듭니다.
4. `python/03_result_validation.py`로 SQL 기준값과 pandas 결과를 비교합니다.
5. 결과와 해석·한계를 `analysis_report.md`에 기록합니다.

## 안전 주의

```text
- 생성 파일은 자동 DROP을 실행하지 않습니다.
- 실제 이름·이메일·비밀번호·API 키를 넣지 않습니다.
- .env·백업·실제 CSV를 저장소에 커밋하지 않습니다.
- Python 분석에서 원본 변경 SQL을 실행하지 않습니다.
- 중복·NULL을 임의 제거해 오류를 숨기지 않습니다.
- 검증하지 않은 항목을 통과로 기록하지 않습니다.
```
