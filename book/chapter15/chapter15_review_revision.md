# Chapter 15 방향 전환 반영 기록

## 대상 Chapter

```text
기존: 실전 프로젝트 2: 재현 가능한 AI 데이터베이스 서비스 완성하기
변경: 데이터베이스 종합 프로젝트
```

## 변경 목적

도서 전체 방향을 PostgreSQL·SQL·데이터 설계·분석 중심으로 조정했습니다. Chapter 15는 요구사항, ERD, DDL, 검증, 운영과 AI 활용뿐 아니라 Chapter 14의 SQL·Python 데이터 분석까지 하나의 프로젝트로 통합합니다.

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

---

## 1. 제목과 중심 메시지 변경

기존에는 AI 데이터베이스 서비스와 선택 RAG 확장이 강조되었습니다. 변경 후에는 데이터베이스 설계·분석·검증의 통합과 재현성을 중심에 둡니다.

> 프로젝트는 SQL이 실행되거나 그래프가 생성되는 것으로 끝나지 않는다. 설계와 데이터가 요구사항에 맞고, SQL과 Python 결과가 일치하며, 다른 사람이 같은 절차로 재현할 수 있어야 한다.

---

## 2. 필수·선택 범위 변경

필수:

```text
요구사항·ERD·DDL
샘플 데이터·업무 조회
정상·경계·오류·트랜잭션 검증
인덱스·권한·백업·복구 계획
분석용 데이터셋
SQL 분석
Python·pandas 분석
SQL·Python 결과 검증
AI diff 검토
```

선택:

```text
웹 CRUD·API
NoSQL
배포
```

Vector DB·RAG는 Chapter 15 범위에서 제거했습니다.

---

## 3. 단계별 실행 구조 변경

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

`09_optional_rag_extension.sql`을 제거하고 `09_analysis_dataset.sql`로 교체합니다. `01~10`은 모두 필수 실행 파일입니다.

---

## 4. 분석 확장

`09_analysis_dataset.sql`은 질문 1건을 한 행으로 정의한 `tutor_project.question_analysis_dataset` VIEW를 생성합니다.

```text
VIEW 행 수 5
question_id 중복 0
answer_count 합계 5
material_count 합계 7
답변 없는 질문 1건
```

Python 실습:

```text
python/01_load_postgresql.py
python/02_pandas_analysis.py
python/03_result_validation.py
```

분석 결과는 `analysis_report.md`에 기록합니다.

---

## 5. 요구사항 확장

기존 DB 요구사항에 다음을 추가합니다.

```text
REQ-12 질문 1건 단위 분석 데이터셋 제공
REQ-13 SQL과 Python의 핵심 집계 일치
```

분석 기준 시각과 갱신 주기는 미확정 정책으로 남깁니다.

---

## 6. 문서 변경

```text
chapter15.md
- Chapter 14 SQL·Python 분석과 연결
- RAG 설명 제거
- 분석 데이터셋과 pandas 검증 추가

chapter15_activity.md
- RAG 선택 항목 제거
- 분석 질문·VIEW·DataFrame·교차 검증 기록 추가

chapter15_outline.md
- SQL·Python 분석을 필수 흐름으로 반영

chapter15_project_guide.md
- 01→10 실행과 Python 분석 절차 반영

requirements.md·erd.md
- 분석 VIEW와 결과 검증 요구사항 반영

analysis_report.md
- 분석 질문·SQL 결과·Python 결과·해석·한계 기록

final_report.md
- SQL·Python 교차 검증과 분석 한계 추가
```

---

## 7. 완료 게이트 변경

기존 DB 구조와 기준 데이터 검증에 다음을 추가합니다.

```text
question_analysis_dataset VIEW 존재
VIEW 행 수 5
question_id 중복 0
answer_count 합계 5
material_count 합계 7
답변 없는 질문 1건
SQL·Python 핵심 집계 일치 기록
```

`required_completion_gate_passed`는 DB 구조와 SQL 분석 데이터셋의 필수 기준을 판정합니다. Python 실행 증거는 `analysis_report.md`와 최종 보고서에서 별도로 확인합니다.

---

## 8. 안전성 강화

```text
- Python은 개발·테스트 DB의 읽기 전용 연결을 우선한다.
- 접속 정보는 .env로 관리하고 저장소에는 .env.example만 둔다.
- 실제 개인정보·백업·운영 CSV를 커밋하지 않는다.
- drop_duplicates·dropna로 오류를 임의로 숨기지 않는다.
- SQL과 Python 결과가 다르면 기대값을 바꾸기 전에 원인을 확인한다.
- 분석 코드에서 UPDATE·DELETE·DROP을 자동 실행하지 않는다.
```

---

## 9. 이미지 변경 기준

```text
그림 15-1: 필수 흐름에 SQL·Python 분석 추가, RAG 제거
그림 15-2: Python 분석을 필수로 이동, 선택 확장은 웹·NoSQL·배포
그림 15-3: 09_analysis_dataset.sql·python·analysis_report 반영
그림 15-4: 요구사항→설계→SQL 분석→Python 검증 연결
그림 15-5: AI 생성 Python 코드와 DataFrame 검증 추가
그림 15-6: 재현 가능한 데이터·SQL·Python으로 문구 조정
그림 15-7: SQL 분석·Python 분석·한계 기록 추가
그림 15-8: 분석 VIEW와 SQL·Python 일치 기준 추가
```

---

## 10. 남은 확인

```text
- 실제 PostgreSQL에서 01→10 순서 실행
- 메타데이터와 기준 행 수 확인
- ROLLBACK 복구 확인
- 반례 unexpected 0 확인
- 분석 VIEW 5행·중복 0 확인
- Python DataFrame 5행 확인
- SQL·pandas 집계 일치 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 최종 상태

```text
Chapter 15 본문, 워크북, 구성안과 프로젝트 가이드를 데이터베이스 종합 프로젝트 방향으로 전환했습니다.
Vector DB·RAG를 제거하고 SQL 분석·Python 분석·교차 검증을 필수 경로에 포함했습니다.
```
