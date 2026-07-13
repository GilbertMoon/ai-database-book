# Chapter 15 코드 자료

## 재현 가능한 AI 데이터베이스 서비스 완성하기

이 폴더는 `tutor_project` 전용 스키마에서 AI 튜터링 질문 관리 서비스를 구축하고, 요구사항·메타데이터·업무 조회·트랜잭션·반례·성능·운영·선택 RAG 확장을 검증하는 템플릿 패키지를 제공합니다.

---

## 보호 범위

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 변경하지 않음
security_lab: 변경하지 않음
nosql_lab: 변경하지 않음
ai_review_lab: 변경하지 않음
rag_lab: 변경하지 않음
tutor_project: Chapter 15 프로젝트 대상
```

---

## 폴더 구조

```text
code/chapter15/templates/
├── README.md
├── requirements.md
├── erd.md
├── 01_schema.sql
├── 02_seed.sql
├── 03_metadata_validation.sql
├── 04_requirement_queries.sql
├── 05_transaction_checks.sql
├── 06_negative_tests.sql
├── 07_performance_checks.sql
├── 08_operations_checks.sql
├── 09_optional_rag_extension.sql
├── OPERATIONS_RUNBOOK.md
├── ai_review_report.md
├── final_report.md
├── reset_tutor_project.sql
├── schema.sql
├── seed.sql
└── queries.sql
```

마지막 세 파일은 기존 링크 호환용 안전한 안내 파일입니다.

---

## 필수 실행 순서

```text
01_schema.sql
→ 02_seed.sql
→ 03_metadata_validation.sql
→ 04_requirement_queries.sql
→ 05_transaction_checks.sql
→ 06_negative_tests.sql
→ 07_performance_checks.sql
→ 08_operations_checks.sql
```

학습 자료 의미 검색 요구사항이 있을 때만 `09_optional_rag_extension.sql`을 실행합니다.

처음부터 다시 시작할 때만 `reset_tutor_project.sql`을 검토·선택 실행합니다.

---

## 기준 결과

| 항목 | 기대 |
| --- | ---: |
| students | 4 |
| tutors | 3 |
| questions | 5 |
| answers | 5 |
| learning_materials | 6 |
| question_materials | 7 |
| FK | 5 |
| IDENTITY PK | 5 |
| 업무 인덱스 | 3 |
| CASCADE FK | 0 |
| 질문 없는 학생 | 1 |
| 연결되지 않은 자료 | 1 |
| 자동 반례 | 14 |
| unexpected 반례 | 0 |

---

## 안전 원칙

```text
- 생성 파일에서 자동 DROP을 실행하지 않습니다.
- 모든 객체에 tutor_project 스키마를 명시합니다.
- SERIAL 대신 IDENTITY를 사용합니다.
- 명시적 ID와 고정 시각으로 샘플을 재현합니다.
- 반례는 하위 트랜잭션에서 실행해 기준 데이터를 유지합니다.
- Role·GRANT·백업·복원은 자동 실행하지 않습니다.
- 실제 개인정보·비밀번호·토큰·전체 접속 URL을 기록하지 않습니다.
- 작은 데이터의 Seq Scan을 오류로 판단하지 않습니다.
- 선택 RAG 확장에서 원문과 벡터 파생 데이터를 분리합니다.
```

---

## 완료 기준

```text
requirements·erd·DDL·SQL·보고서가 서로 일치
행 수 4·3·5·5·6·7
FK 5·인덱스 3·CASCADE 0
경계 사례 각각 1건
정합성 이상 0행
ROLLBACK 후 기준 데이터 복구
반례 unexpected 0
운영·백업·복구 계획 기록
AI diff와 미실행 항목 기록
```
