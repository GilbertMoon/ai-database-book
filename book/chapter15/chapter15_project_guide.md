# Chapter 15 프로젝트 가이드

## 목적

이 가이드는 최종 프로젝트를 제출 가능한 형태로 정리하기 위한 안내입니다. 기본 목표는 PostgreSQL 기반 데이터베이스 설계와 검증입니다. 웹 CRUD, API, NoSQL, RAG는 선택 확장입니다.

## 기준 예제

AI 튜터링 질문 관리 서비스

| 테이블 | 역할 |
|---|---|
| `students` | 질문 등록 학생 |
| `tutors` | 답변 작성 튜터 |
| `questions` | 질문과 상태 |
| `answers` | 튜터 답변 |
| `learning_materials` | 학습 자료 |
| `question_materials` | 질문과 자료 연결 |

## 제출 파일

| 파일 | 필수 | 설명 |
|---|---|---|
| `README.md` | 필수 | 실행 방법과 프로젝트 개요 |
| `requirements.md` | 필수 | 요구사항과 미확정 규칙 |
| `erd.md` | 필수 | 관계 설명과 FK 목록 |
| `schema.sql` | 필수 | 반복 실행 가능한 DDL |
| `seed.sql` | 필수 | 검증 시나리오 데이터 |
| `queries.sql` | 필수 | 요구사항 검증 SQL |
| `ai_review_report.md` | 필수 | AI 제안과 사람의 검토 기록 |
| `final_report.md` | 필수 | 최종 결과와 다음 버전 계획 |
| `screenshots/` | 선택 | 실행 결과 캡처 |

## 실행 순서

1. 별도 실습 DB를 준비한다.
2. `schema.sql`을 실행한다.
3. `seed.sql`을 실행한다.
4. `queries.sql`을 실행한다.
5. 예상 결과와 실제 결과를 비교한다.
6. 오류 테스트는 별도 트랜잭션에서 선택적으로 실행한다.
7. AI 검토 보고서와 최종 보고서를 갱신한다.

## 완료 기준

- 요구사항 ID가 SQL 검증과 연결된다.
- ERD와 DDL이 일치한다.
- expected/actual 결과가 기록된다.
- 정합성 이상 조회가 0행이다.
- FK 5개가 확인된다.
- 오류 테스트가 실패해야 할 곳에서 실패한다.
- `ai_review_report.md`와 `final_report.md`가 존재한다.

## 선택 확장 기준

| 확장 | 진행 조건 |
|---|---|
| 웹 CRUD/API | DB 입력과 조회를 화면 또는 API로 검증할 필요가 있을 때 |
| NoSQL | 관계형 테이블 밖의 캐시, 문서, 이벤트 저장 요구가 있을 때 |
| Vector DB/RAG | 학습 자료 의미 검색과 근거 기반 답변이 필요할 때 |
| 배포 | 다른 사람이 접근해 검증해야 할 때 |
