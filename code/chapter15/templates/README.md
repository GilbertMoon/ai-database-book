# AI 튜터링 질문 관리 서비스

## 1. 해결하려는 문제

학생 질문, 튜터 답변, 학습 자료 연결 관계를 데이터베이스로 관리합니다. 목표는 화면을 많이 만드는 것이 아니라 요구사항, ERD, DDL, 샘플 데이터, 검증 SQL이 서로 일치한다는 근거를 남기는 것입니다.

## 2. 주요 사용자

- 학생: 질문을 등록하고 답변을 확인합니다.
- 튜터: 질문에 답변하고 관련 학습 자료를 안내합니다.
- 운영자: 질문 상태, 자료 연결, 정합성 문제를 확인합니다.

## 3. 현재 버전의 범위

- 학생과 튜터 정보 관리
- 질문 등록과 상태 관리
- 질문별 여러 답변 관리
- 학습 자료 등록
- 질문과 학습 자료 N:M 연결
- 정상, 경계, 오류 시나리오 검증

## 4. 제외한 기능

- 웹 CRUD와 백엔드 API
- 로그인과 실제 인증
- 결제, 알림, 추천
- NoSQL 저장소
- Vector DB와 RAG
- 클라우드 배포

## 5. 사용 환경

- PostgreSQL 실습 DB
- 실제 개인정보가 아닌 가상 데이터
- 별도 작업용 DB에서 실행

## 6. 프로젝트 파일 구조

```text
project/
├── README.md
├── requirements.md
├── erd.md
├── schema.sql
├── seed.sql
├── queries.sql
├── ai_review_report.md
├── final_report.md
└── screenshots/
```

`screenshots/`는 선택 항목입니다.

## 7. 데이터베이스 구조 요약

| 테이블 | 역할 |
|---|---|
| `students` | 질문을 등록하는 학생 |
| `tutors` | 답변을 작성하는 튜터 |
| `questions` | 학생 질문과 상태 |
| `answers` | 질문에 연결된 튜터 답변 |
| `learning_materials` | 학습 자료 |
| `question_materials` | 질문과 자료의 N:M 연결 |

## 8. 실행 전 확인

- 운영 DB가 아닌지 확인합니다.
- 현재 DB와 사용자를 확인합니다.
- `schema.sql`, `seed.sql`, `queries.sql` 순서로 실행합니다.

## 9. 실행 순서

```bash
psql -U postgres -d ai_tutor_project -f schema.sql
psql -U postgres -d ai_tutor_project -f seed.sql
psql -U postgres -d ai_tutor_project -f queries.sql
```

## 10. 예상 결과

| 항목 | 예상값 |
|---|---:|
| students | 4 |
| tutors | 3 |
| questions | 5 |
| answers | 5 |
| learning_materials | 6 |
| question_materials | 7 |
| FK 개수 | 5 |
| 정합성 이상 | 0 |
| 질문 없는 학생 | 1 |
| 연결되지 않은 학습 자료 | 1 |

## 11. 오류 테스트 방법

`seed.sql` 하단의 오류 테스트 예시는 주석 상태입니다. 별도 트랜잭션에서 하나씩 주석을 해제하고 실패 여부를 확인합니다. 실패 후에는 `ROLLBACK`합니다.

## 12. AI 사용 및 검토 기록

AI가 만든 초안은 `ai_review_report.md`에 기록합니다. AI 제안은 사람이 검토하고, 실행 결과로 확인한 뒤 반영합니다.

## 13. 보안 주의

- 실제 학생 이름, 이메일, 전화번호를 사용하지 않습니다.
- DB 비밀번호와 API 키를 문서에 쓰지 않습니다.
- 접근 권한과 백업·복구 계획은 최종 보고서에 별도 기록합니다.

## 14. 현재 한계와 다음 버전

현재 버전은 데이터베이스 설계와 SQL 검증에 집중합니다. 웹 CRUD, API, NoSQL, Vector DB/RAG, 배포는 요구사항이 명확할 때 다음 버전으로 확장합니다.
