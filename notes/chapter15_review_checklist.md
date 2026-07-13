# Chapter 15 검수 체크리스트

## 대상

Chapter 15. 실전 프로젝트 2: AI 기반 데이터베이스 서비스 완성하기

## 1. 본문과 범위

| 항목 | 상태 | 메모 |
|---|---|---|
| AI 기반의 의미가 명확한가 | 통과 | AI는 기본적으로 설계·SQL 검토 보조 도구이며 RAG는 선택 확장으로 설명됨 |
| CRUD가 선택 확장인가 | 통과 | 기본 DB 완성 후 필요할 때 선택한다고 정리됨 |
| NoSQL/RAG가 선택 확장인가 | 통과 | 요구사항이 있을 때만 다음 버전으로 검토 |
| 최종 프로젝트 완료 기준 | 통과 | 기능 수가 아니라 설계와 검증 근거로 판단 |
| Chapter 14 수정 여부 | 미확인 | diff로 확인 필요 |

## 2. 파일명과 템플릿

| 항목 | 상태 | 메모 |
|---|---|---|
| 이전 임시 파일명 제거 | 통과 | 실제 템플릿은 `ai_review_report.md`, `final_report.md`를 사용 |
| `code/chapter15/README.md` 존재 | 통과 | 템플릿 패키지 안내 추가 |
| 템플릿 파일 목록 일치 | 통과 | README, requirements, erd, schema, seed, queries, ai_review_report, final_report |

## 3. SQL 설계

| 항목 | 상태 | 메모 |
|---|---|---|
| 기준 예제 도메인 | 통과 | AI 튜터링 질문 관리 서비스로 통일 |
| 예전 `example_*` 테이블 제거 | 통과 | students/tutors/questions/answers/learning_materials/question_materials 사용 |
| FK 개수 | 통과 | 5개로 문서화 |
| CASCADE 미사용 | 통과 | 요구사항 없으므로 사용하지 않음 |
| answers UNIQUE 미사용 | 통과 | 미확정 업무 규칙으로 분리 |
| seed 고정 PK 의존 제거 | 통과 | `RETURNING`과 자연키 조회 사용 |
| 오류 테스트 분리 | 통과 | 주석 처리된 선택 테스트와 ROLLBACK 안내 포함 |
| 실제 PostgreSQL 실행 | 미확인 | 현재 환경에서 `psql` 실행 확인 필요 |

## 4. 기대 결과

| 항목 | 기대값 | 상태 |
|---|---:|---|
| students | 4 | 문서화 완료 |
| tutors | 3 | 문서화 완료 |
| questions | 5 | 문서화 완료 |
| answers | 5 | 문서화 완료 |
| learning_materials | 6 | 문서화 완료 |
| question_materials | 7 | 문서화 완료 |
| FK | 5 | 문서화 완료 |
| 정합성 이상 | 0 | 문서화 완료 |

## 5. 그림과 SVG

| 항목 | 상태 | 메모 |
|---|---|---|
| 그림 15-1~15-8 본문 삽입 | 통과 | 모든 SVG 본문에 삽입됨 |
| 그림 번호 정리 | 통과 | 모든 그림이 정식 번호를 가짐 |
| SVG 접근성 구조 | 확인 필요 | XML 검사 필요 |
| SVG 높이 800px 이하 | 확인 필요 | viewBox 검사 필요 |
| 실제 렌더링 | 미확인 | 브라우저/GitHub/Word 변환 수동 확인 필요 |

## 6. 남은 확인 사항

- PostgreSQL에서 `schema.sql`, `seed.sql`, `queries.sql`을 실제 실행한다.
- SVG를 브라우저와 GitHub 미리보기에서 확인한다.
- Word/PDF/eBook 변환 후 가독성을 확인한다.
- Chapter 14, README.md, notes/todo.md가 이번 작업에서 수정되지 않았는지 diff로 확인한다.
