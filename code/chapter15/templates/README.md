# AI 튜터링 질문 관리 서비스

## 1. 프로젝트 목표

학생 질문, 튜터 답변과 학습 자료 연결을 PostgreSQL로 관리하고, 다른 사람이 같은 순서로 실행해 같은 검증 결과를 확인할 수 있는 프로젝트를 완성합니다.

기능 수보다 다음 연결을 중요하게 봅니다.

```text
요구사항
→ ERD
→ DDL
→ 기준 데이터
→ 실행 결과
→ 운영 계획
→ AI 변경 검토
```

---

## 2. 현재 범위

```text
학생·튜터 관리
질문과 상태 관리
질문별 여러 답변
질문·학습 자료 N:M 연결
정상·경계·오류·트랜잭션 검증
인덱스·운영·백업·복구 검토
선택적 RAG 원문 뷰
```

제외 범위:

```text
실제 인증·개인정보
웹·API
실제 LLM·임베딩 API 호출
클라우드 배포
자동 Role 생성
자동 백업·복원
```

---

## 3. 데이터베이스 구조

```text
tutor_project.students
tutor_project.tutors
tutor_project.questions
tutor_project.answers
tutor_project.learning_materials
tutor_project.question_materials
```

| 테이블 | 역할 |
| --- | --- |
| students | 질문을 등록하는 학생 |
| tutors | 답변을 작성하는 튜터 |
| questions | 학생 질문과 상태 |
| answers | 질문에 연결된 튜터 답변 |
| learning_materials | 학습 자료 원본 메타데이터 |
| question_materials | 질문과 자료의 N:M 연결 |

---

## 4. 실행 파일

```text
01_schema.sql
02_seed.sql
03_metadata_validation.sql
04_requirement_queries.sql
05_transaction_checks.sql
06_negative_tests.sql
07_performance_checks.sql
08_operations_checks.sql
09_optional_rag_extension.sql
```

필수 실행은 01~08입니다. 09는 실제 RAG 요구사항이 있을 때만 실행합니다.

기존 `schema.sql`, `seed.sql`, `queries.sql`은 안전한 호환 안내 파일입니다.

---

## 5. 실행 예시

```bash
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 01_schema.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 02_seed.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 03_metadata_validation.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 04_requirement_queries.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 05_transaction_checks.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 06_negative_tests.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 07_performance_checks.sql
psql -U <user> -d <database> -v ON_ERROR_STOP=1 -f 08_operations_checks.sql
```

운영 DB가 아닌 별도 개발·테스트 환경에서 실행합니다.

---

## 6. 기대 결과

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
| 자동 반례 | 14 |
| unexpected | 0 |

---

## 7. 문서 파일

| 파일 | 용도 |
| --- | --- |
| `requirements.md` | 확인 요구사항과 미확정 정책 |
| `erd.md` | 관계·테이블 역할·제약조건 설명 |
| `OPERATIONS_RUNBOOK.md` | 역할·비밀·백업·복원·RPO·RTO |
| `ai_review_report.md` | AI 제안·diff·실행 증거 검토 |
| `final_report.md` | 프로젝트 최종 결과·한계·다음 버전 |

---

## 8. 안전 주의

```text
- 생성 파일은 자동 DROP을 실행하지 않습니다.
- 초기화가 필요할 때만 reset_tutor_project.sql을 선택 실행합니다.
- 실제 이름·이메일·전화번호·비밀번호·API 키를 넣지 않습니다.
- .env와 백업 파일을 저장소에 커밋하지 않습니다.
- Role·GRANT와 백업·복원은 실행 전 별도 검토합니다.
- 검증하지 않은 항목을 통과로 기록하지 않습니다.
```
