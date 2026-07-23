# Chapter 15 최종 출판 검수 반영 기록

## 대상

```text
book/chapter15/chapter15.md
book/chapter15/chapter15_activity.md
book/chapter15/chapter15_outline.md
code/chapter15/templates/ 전체
code/chapter15/README.md
notes/chapter15_review_checklist.md
images/chapter15/ch15_03_project_structure.mmd·svg
README.md
```

## 검수 목적

Chapter 15를 단순 종합 예제에서 다음 증거를 분리해 판정하는 최종 프로젝트로 완성했습니다.

```text
요구사항·정책
→ 실제 PostgreSQL 구조
→ 정상·실패·경계·시간 검증
→ 고정 기간 SQL 분석
→ 같은 스냅샷의 pandas 비교
→ 별도 DB 복원
→ AI diff와 사람 승인
```

## 1. 생성·Seed·초기화 보호

- `ai_database_book`이 아니면 생성·Seed·reset을 중단합니다.
- 기존 `tutor_project`를 자동 덮어쓰지 않습니다.
- 구조와 Seed는 각각 하나의 트랜잭션에서 처리합니다.
- 모든 SQL에 `current_database`, `current_schema`, `SHOW search_path`를 통일했습니다.

## 2. 명시적 ID와 IDENTITY

```text
students 101~104 → next 105
tutors 201~203 → next 204
questions 301~305 → next 306
answers 401~405 → next 406
learning_materials 501~506 → next 507
```

Seed와 DB·복원 게이트에서 다음 값이 최대 ID보다 큰지 확인합니다.

## 3. 무결성과 정확한 메타데이터

다음을 보완했습니다.

```text
이메일·코드·버전·URL 공백 CHECK
questions.updated_at >= created_at
정확한 테이블 집합 6개
정확한 제약조건 36개
FK 이름·출발·대상 컬럼·삭제 규칙 5개
IDENTITY PK 5개와 연결 테이블 복합 PK
업무 인덱스 컬럼·정렬 정의 3개
```

단순 개수가 맞다는 이유로 통과시키지 않습니다.

## 4. P15 추적 ID

```text
P15-R01~R13 요구사항
P15-D01~D08 결정·미확정 정책
P15-Q01~Q06 분석 질문
P15-T01~T25 트랜잭션·반례·경계값
P15-V01~V09 검증 단계
```

본문·워크북·requirements·erd·SQL·보고서에 같은 ID 체계를 반영했습니다.

## 5. 업무·시간 정합성

```text
질문 작성일 >= 학생 가입일
답변 작성 시각 >= 질문 작성 시각
답변 작성 시각 >= 튜터 생성 시각
자료 연결 시각 >= 질문 작성 시각
answered 질문에는 답변 존재
고아 관계·표시 순서 중복 0
```

비활성 사용자 작업, closed 질문 추가 답변과 같은 미확정 정책은 DB 제약으로 임의 확정하지 않았습니다.

## 6. 트랜잭션과 테스트

`05_transaction_checks.sql`은 다음을 검증합니다.

```text
정상 경로: 답변 INSERT + open→answered 조건부 UPDATE
영향 행 수 1 확인
ROLLBACK 후 기준 복구
실패 경로: 잘못된 tutor INSERT 실패 후 상태 무변경
```

`06_negative_tests.sql`은 공통 함수로 다음을 기록합니다.

```text
expected·actual SQLSTATE
expected·actual constraint name
table·column·detail
```

실패 반례 18개와 정상 경계값 5개, 총 23개를 실행하며 unexpected 0과 기준 데이터 보존을 자동 판정합니다.

## 7. 인덱스 범위 정리

작은 Seed에서 실행 계획을 보는 작업을 **인덱스 후보·정의 검토**로 명확히 했습니다. 실제 효과는 대용량 통제 데이터의 인덱스 전·후 `EXPLAIN (ANALYZE, BUFFERS)`와 쓰기 비용을 함께 측정하도록 구분했습니다.

## 8. PUBLIC·소유권·보안

기존 PUBLIC 조회 오류를 수정했습니다.

```text
직접 권한: role_table_grants·role_column_grants
PUBLIC: table_privileges·column_privileges
권한 경로: DB ACL·schema ACL·객체 ACL·owner
최종 권한: has_*_privilege
```

`access_scope`는 분류 값이며 실제 접근 통제가 아님을 명시했습니다. 이메일·URL은 `example.test`, 해시는 `demo-sha256-*` 가상값을 사용합니다.

## 9. 백업·복원 강화

```text
도구·서버 버전 확인
백업 계정 권한·RLS·외부 의존성
custom format·목록·SHA-256
createdb -O <restore_user> -T template0
pg_restore --single-transaction
```

신규 `11_restore_validation.sql`은 `tutor_project_restore`에서만 실행되며 구조·데이터·제약·인덱스·시간·IDENTITY·owner·분석 VIEW를 자동 판정합니다.

## 10. 분석 범위와 행 단위

분석 기간을 고정했습니다.

```text
[2026-01-01 00:00+09, 2026-06-01 00:00+09)
```

VIEW를 역할별로 분리했습니다.

```text
question_analysis_dataset = 질문 1건
student_question_summary = 학생 1명, 질문 0건 포함
tutor_answer_summary = 튜터 1명, 답변 0건 포함
```

월별 집계는 date spine으로 빈 월을 유지합니다.

## 11. 실제 SQL·pandas 직접 비교

`DATABASE_URL`과 코드 내 기대 상수를 제거했습니다.

```text
PGHOST·PGPORT·PGDATABASE·PGUSER·PGPASSFILE
REPEATABLE READ, READ ONLY
정확한 13개 컬럼·날짜·숫자·boolean 검증
```

같은 스냅샷에서 SQL 상태·월·학생·튜터·첫 답변 결과와 pandas 결과를 `assert_frame_equal()`로 비교합니다.

## 12. 완료 게이트 분리

`10_completion_gate.sql`은 boolean 출력이 아니라 실패 시 예외를 발생시킵니다. 통과 메시지는 다음과 같습니다.

```text
Chapter 15 database completion gate passed
```

전체 프로젝트 완료는 다음을 별도 증거로 확인합니다.

```text
DB 완료
Python 교차 검증
백업·복원
Role 허용·차단
문서·AI diff 사람 승인
```

미실행 항목은 통과로 표시하지 않습니다.

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| DB 보호·원자성 | 완료 |
| IDENTITY 조정 | 완료 |
| 정확한 메타데이터 | 완료 |
| 업무·시간 검증 | 완료 |
| 트랜잭션 정상·실패 | 완료 |
| 23개 테스트·constraint name | 완료 |
| PUBLIC 권한 조회 | 완료 |
| 고정 기간·0건 차원 VIEW | 완료 |
| 실제 SQL·pandas 비교 | 완료 |
| 예외 기반 DB 게이트 | 완료 |
| 별도 DB 복원 검증 | 완료 |
| 본문·워크북·보고서 동기화 | 완료 |

실제 PostgreSQL `01→11`, Python 패키지 설치·교차 검증, Role 시험, custom-format 백업·복원과 Word·PDF·eBook 렌더링은 별도 제작 단계에서 확인합니다.
