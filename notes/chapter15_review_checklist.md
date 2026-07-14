# Chapter 15 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 15. 데이터베이스 종합 프로젝트
```

## 리뷰 목적

Chapter 15가 `tutor_project`에서 요구사항·설계·PostgreSQL 실행·SQL 분석·Python 분석·운영·AI 검토를 통합하고, 다른 사람이 같은 순서와 기준값으로 재현할 수 있도록 구성되었는지 점검합니다.

---

## 1. 범위와 재현성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 필수·선택 확장 구분 | 코드 반영 | SQL·Python 필수, 웹·NoSQL·배포 선택 |
| 프로젝트 사용자·문제 | 코드 반영 | 학생·튜터·운영자·분석 담당자 |
| 전용 스키마 | 통과 | tutor_project 사용 |
| 앞 장 스키마 보호 | 통과 | analysis_lab 포함 변경 금지 |
| 자동 DROP 제거 | 통과 | reset 파일 분리 |
| IDENTITY·명시적 ID | 통과 | 재현 가능한 기준 데이터 |
| 고정 시각·가상 데이터 | 통과 | 실행 시점·개인정보 의존 제거 |

---

## 2. 요구사항·정책 추적

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| REQ-01~11 | 코드 반영 | DB 구조·조회·반례·운영 검증 |
| REQ-12 | 코드 반영 | 질문 1건 단위 분석 VIEW |
| REQ-13 | 코드 반영 | SQL·Python 핵심 집계 일치 |
| 미확정 정책 분리 | 통과 | 복수 답변·상태·삭제·보관·분석 시각 |
| AI 임의 정책 방지 | 통과 | 제약·트리거·전처리 임의 확정 금지 |
| requirements·erd 동기화 | 코드 반영 | 분석 구조 포함 |

---

## 3. DDL·ERD

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| 테이블 | 6 | 코드 반영 |
| FK | 5 | 코드 반영 |
| IDENTITY PK | 5 | 코드 반영 |
| 연결 테이블 복합 PK | 1 | 코드 반영 |
| 업무 인덱스 | 3 | 코드 반영 |
| CASCADE FK | 0 | 코드 반영 |
| 분석 VIEW | 1 | 코드 반영 |
| 분석 VIEW 한 행 | 질문 1건 | 코드 반영 |

---

## 4. 기준 데이터·정합성

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students·tutors·questions | 4·3·5 | 코드 반영 |
| answers·materials·links | 5·6·7 | 코드 반영 |
| 질문 없는 학생 | 1 | 코드 반영 |
| 연결되지 않은 자료 | 1 | 코드 반영 |
| 답변 없는 open 질문 | 1 | 코드 반영 |
| 답변 2개 질문 | 1 | 코드 반영 |
| 고아·상태·표시 순서 이상 | 0 | 실제 실행 필요 |

---

## 5. 트랜잭션·반례·성능

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 답변 INSERT·상태 UPDATE | 코드 반영 | 한 트랜잭션 예제 |
| ROLLBACK 복구 | 코드 반영 | answers 5·질문 303 open 기대 |
| 반례 unexpected | 실제 실행 필요 | 기대 0 |
| 기준 데이터 유지 | 코드 반영 | 하위 트랜잭션 사용 |
| 업무 인덱스 3개 | 코드 반영 | 실제 조회 패턴 근거 |
| 대표 EXPLAIN | 코드 반영 | 작은 데이터 Seq Scan 허용 |

---

## 6. 분석 데이터셋·Python

| 점검 항목 | 기대 | 상태 |
| --- | ---: | --- |
| `09_analysis_dataset.sql` 존재 | 1 | 통과 |
| VIEW 행 수 | 5 | 실제 실행 필요 |
| distinct question_id | 5 | 실제 실행 필요 |
| question_id 중복 | 0 | 실제 실행 필요 |
| answer_count 합계 | 5 | 실제 실행 필요 |
| material_count 합계 | 7 | 실제 실행 필요 |
| 답변 없는 질문 | 1 | 실제 실행 필요 |
| Python 로더 | 존재 | 통과 |
| pandas 분석 스크립트 | 존재 | 통과 |
| 결과 검증 스크립트 | 존재 | 통과 |
| SQL·pandas 상태별 집계 | 일치 | 실제 실행 필요 |
| SQL·pandas 월별 집계 | 일치 | 실제 실행 필요 |
| 임의 dropna·drop_duplicates | 없음 | 코드 검토 필요 |

---

## 7. 보안·운영·복구

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 실제 개인정보 미사용 | 코드 반영 | example.test·가상 이름 |
| 비밀 컬럼·값 검사 | 코드 반영 | 08_operations_checks.sql |
| 읽기 전용 분석 역할 | 문서 반영 | report 계정 계획 |
| `.env.example` | 통과 | 실제 `.env` 제외 필요 |
| 백업 명령 | 문서 반영 | custom-format 스키마 백업 |
| 별도 DB 복원 | 문서 반영 | 03·04·08·09·10 재검증 |
| RPO·RTO | 문서 반영 | 기록 템플릿 제공 |
| 실제 CSV·백업 파일 제외 | 확인 필요 | `.gitignore` 수동 검수 |

---

## 8. 파일 구조

| 파일 | 상태 |
| --- | --- |
| `01_schema.sql`~`08_operations_checks.sql` | 반영 |
| `09_analysis_dataset.sql` | 신규 반영 |
| `10_completion_gate.sql` | 분석 기준 추가 |
| `python/01_load_postgresql.py` | 신규 반영 |
| `python/02_pandas_analysis.py` | 신규 반영 |
| `python/03_result_validation.py` | 신규 반영 |
| `analysis_report.md` | 신규 반영 |
| `OPERATIONS_RUNBOOK.md` | 분석 운영 내용 반영 |
| `ai_review_report.md` | SQL·Python 검토 반영 |
| `final_report.md` | 분석·교차 검증 반영 |
| `09_optional_rag_extension.sql` | 삭제 |

---

## 9. 도식

| 그림 | 검수 기준 | 상태 |
| --- | --- | --- |
| 15-1 | SQL·Python 분석 필수 흐름, RAG 제거 | 코드 반영 |
| 15-2 | Python 필수, 웹·NoSQL·배포 선택 | 코드 반영 |
| 15-3 | 09 분석 SQL·Python·analysis_report | 코드 반영 |
| 15-4 | 설계→VIEW→Python→교차 검증 | 코드 반영 |
| 15-5 | AI 생성 Python·DataFrame 검증 | 코드 반영 |
| 15-6 | 데이터·SQL·Python 및 분석 증거 | 코드 반영 |
| 15-7 | SQL 분석·Python 분석·한계 | 코드 반영 |
| 15-8 | 분석 VIEW·SQL/pandas 일치 기준 | 코드 반영 |
| 접근성·출판 렌더링 | GitHub·Word·PDF·eBook | 수동 확인 필요 |

---

## 10. 남은 확인

```text
- 실제 PostgreSQL에서 01→10 실행
- 메타데이터 boolean과 기준 행 수 확인
- 트랜잭션 ROLLBACK 복구 확인
- 반례 unexpected 0 확인
- 분석 VIEW 5행·중복 0 확인
- Python DataFrame 5행 확인
- SQL·pandas 집계 일치 확인
- 읽기 전용 분석 계정 검토
- 스키마 백업·별도 DB 복원 시험
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 최종 판정

```text
Chapter 15는 데이터베이스 설계·SQL 검증·Python 분석을 통합한 종합 프로젝트로 전환했습니다.
코드와 문서 구조는 반영되었으며, 실제 PostgreSQL·Python 실행과 출판 렌더링은 별도 확인이 필요합니다.
```
