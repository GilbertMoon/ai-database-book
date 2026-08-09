# Chapter 15 전체 점검·수정 반영 기록

## 대상

```text
Chapter 15. 데이터베이스 종합 프로젝트
```

이번 검수는 본문만이 아니라 다음 전체 범위를 대상으로 진행했습니다.

```text
book/chapter15
code/chapter15/templates
code/chapter15/templates/python
images/chapter15
presentation/chapter15
notes/chapter15_review_checklist.md
.github/workflows/validate-chapter15.yml
.github/workflows/validate-chapter15-navigation.yml
```

## 검수 목적

Chapter 15를 단순 종합 예제에서 다음 증거를 분리해 판정하는 최종 프로젝트로 완성했습니다.

```text
요구사항·정책
→ 실제 PostgreSQL 구조
→ 정상·실패·경계·시간 검증
→ 고정 기간 SQL 분석
→ 같은 스냅샷의 pandas 비교
→ Role 허용·차단
→ custom-format 백업
→ 별도 DB 복원
→ AI diff와 사람 승인
```

---

## 1. 생성·Seed·초기화 보호

- `ai_database_book`이 아니면 생성·Seed·reset을 중단합니다.
- 기존 `tutor_project`를 자동 덮어쓰지 않습니다.
- 구조와 Seed는 각각 하나의 트랜잭션에서 처리합니다.
- 모든 핵심 SQL에서 `current_database`, `current_schema`, `SHOW search_path`를 확인합니다.
- `reset_tutor_project.sql`은 `CASCADE`를 사용하지 않습니다.
- reset 대상 외 객체가 있으면 중단하고 기존 프로젝트 데이터를 유지합니다.

실제 자동 검증에서 잘못된 `postgres` DB에 `01_schema.sql`을 실행했을 때 중단되는 것을 확인했습니다.

---

## 2. 명시적 ID와 IDENTITY

기준 데이터:

```text
students 101~104 → next 105
tutors 201~203 → next 204
questions 301~305 → next 306
answers 401~405 → next 406
learning_materials 501~506 → next 507
```

Seed·DB 완료 게이트·복원 게이트에서 다음 IDENTITY 값이 최대 ID보다 큰지 실제 판정합니다.

---

## 3. 구조·무결성과 실제 메타데이터

최종 PostgreSQL 구조:

```text
BASE TABLE = 6
VIEW = 4
IDENTITY sequence = 5
constraints = 36
FK = 5
업무 인덱스 = 3
CASCADE FK = 0
```

보완·검증 범위:

```text
이메일·코드·버전·URL 공백 CHECK
questions.updated_at >= created_at
복합 PK = question_materials(question_id, material_id)
FK 이름·출발·대상 컬럼·ON DELETE 규칙
업무 인덱스의 컬럼과 정렬 순서
IDENTITY PK 5개
```

단순히 객체 개수가 맞다는 이유로 통과시키지 않고 PostgreSQL catalog와 `information_schema`에서 실제 정의를 확인합니다.

---

## 4. P15 추적 ID

```text
P15-R01~R13 요구사항
P15-D01~D08 결정·미확정 정책
P15-Q01~Q06 분석 질문
P15-T01~T25 트랜잭션·반례·경계값
P15-V01~V09 검증 단계
```

`chapter15_project_guide.md`의 과거 실행 순서를 현재 최종 흐름으로 수정했습니다.

```text
01→02→03→04→05→06→07→08→09→10
→ Python 01→02→03
→ custom-format 백업
→ template0 기반 별도 DB 복원
→ 11_restore_validation.sql
→ Role·문서·AI 승인 증거
```

`11_restore_validation.sql`은 이제 명시적으로 **P15-V09**에 연결됩니다.

---

## 5. 업무·시간 정합성

```text
질문 작성일 >= 학생 가입일
답변 작성 시각 >= 질문 작성 시각
답변 작성 시각 >= 튜터 생성 시각
자료 연결 시각 >= 질문 작성 시각
answered 질문에는 답변 존재
고아 관계·표시 순서 중복 0
```

기준 경계 데이터도 실제 확인합니다.

```text
질문 없는 학생 = 1
연결되지 않은 자료 = 1
답변 없는 open 질문 = 1
답변 2개 질문 = 1
```

비활성 사용자 작업, closed 질문 추가 답변과 같은 미확정 정책은 DB 제약으로 임의 확정하지 않았습니다.

---

## 6. 트랜잭션·반례·경계값 실제 실행

`05_transaction_checks.sql`:

```text
정상 경로 = 답변 INSERT + open→answered 조건부 UPDATE
영향 행 수 = 1
ROLLBACK 후 answers = 5
ROLLBACK 후 question 303 = open
실패 경로 뒤 부분 변경 = 0
```

`06_negative_tests.sql`:

```text
실패 반례 = 18
정상 경계값 = 5
전체 = 23/23
unexpected = 0
```

실패 테스트는 단순 실패 여부만 보지 않고 다음을 비교합니다.

```text
expected / actual SQLSTATE
expected / actual constraint name
table / column / detail
```

PostgreSQL 16 실제 실행에서 P15-T03~T25 전체가 기대 결과와 일치했습니다.

---

## 7. 인덱스 실제 계획 확인

작은 Seed이므로 성능 향상을 일반화하지 않고 **후보 인덱스가 대표 조회에 실제로 사용 가능한지**를 확인합니다.

PostgreSQL 16 실제 실행에서:

```text
questions(student_id, status, created_at DESC)
→ idx_tutor_project_questions_student_status_created Index Scan

answers(question_id, created_at)
→ idx_tutor_project_answers_question_created Bitmap Index Scan

question_materials(material_id)
→ idx_tutor_project_qm_material Bitmap Index Scan
```

대용량 성능 판단은 별도의 통제 데이터와 `EXPLAIN (ANALYZE, BUFFERS)` 반복 측정이 필요하다는 구분을 유지합니다.

---

## 8. PUBLIC·소유권·권한 점검 실제 오류 수정

실제 PostgreSQL 실행에서 `PUBLIC` 권한 조회와 관련된 오류를 발견했습니다.

과거 방식은 `PUBLIC`을 일반 Role 이름처럼 `has_database_privilege()`에 전달해 실패했습니다. 이를 DB ACL을 직접 해석하는 방식으로 수정했습니다.

```text
DB PUBLIC CONNECT
→ datacl 또는 기본 ACL
→ aclexplode
→ PUBLIC grantee OID 0 판정
```

또한 08번 운영 점검은 09번 분석 VIEW 생성보다 먼저 실행되므로, `question_analysis_dataset`의 권한을 존재 전에 직접 조회하던 순서 문제도 발견했습니다.

수정 후:

```text
08 시점 analysis_view_exists = false 정상
VIEW가 존재할 때만 SELECT 유효 권한 조회
09에서 분석 VIEW 생성
```

최종 운영 점검에서는 다음을 분리합니다.

```text
직접 권한 = role_table_grants / role_column_grants
PUBLIC = table_privileges / column_privileges
권한 경로 = DB·schema·객체 ACL·owner
최종 권한 = has_*_privilege
```

`access_scope`는 업무 분류 값일 뿐 실제 DB 접근 통제가 아니라는 설명도 유지했습니다.

---

## 9. 실제 Role 허용·차단 시험

자동 검증에서 테스트 Role을 생성해 실제 동작을 확인했습니다.

```text
tutor_project_report
- 분석 VIEW SELECT 허용
- questions INSERT 차단

tutor_project_app
- questions SELECT 허용
- 허용된 questions INSERT 성공 후 ROLLBACK
- questions DELETE 차단
- tutor_project 내 CREATE TABLE 차단
```

따라서 Role 행렬은 문서상 제안만이 아니라 테스트 환경에서 실제 허용·차단 증거를 확보했습니다.

---

## 10. 분석 기간·VIEW·기준값

분석 기간:

```text
[2026-01-01 00:00+09, 2026-06-01 00:00+09)
```

VIEW:

```text
question_analysis_dataset = 질문 1건, 5행
student_question_summary = 학생 1명, 4행, 질문 0건 학생 포함
tutor_answer_summary = 튜터 1명, 3행
analysis_parameters = 분석 기간
```

실제 SQL 기준값:

```text
status = open1 / answered3 / closed1
answer_count 합계 = 5
material_count 합계 = 7
학생 질문 수 = 2 / 1 / 2 / 0
튜터 답변 수 = 2 / 1 / 2
답변 있는 질문 = 4
평균 첫 답변 = 2.00시간
최소 = 0.50시간
최대 = 3.50시간
음수 첫 답변 시간 = 0
월별 질문 = 2026-01~05 각 1건
```

---

## 11. SQL·pandas 직접 비교와 시간대 오류 수정

Python은 다음 연결 기준을 사용합니다.

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
REPEATABLE READ, READ ONLY
```

같은 읽기 전용 스냅샷에서 다음 5종을 실제 SQL과 `assert_frame_equal()`로 비교합니다.

```text
상태별
월별
학생별
튜터별
첫 답변 시간
```

실제 실행 과정에서 pandas 월별 date spine에 다음 오류를 발견했습니다.

```text
2026-01-01 00:00+09
→ 드라이버에서 2025-12-31 15:00+00로 전달
→ UTC 상태에서 월을 자르면 잘못된 2025-12 행 생성
```

검증을 느슨하게 하지 않고, `timestamptz`를 먼저 `Asia/Seoul`로 변환한 뒤 월 시작일을 생성하도록 수정했습니다.

수정 후 Python 월별 결과는 SQL과 동일한 **2026-01~05 5행**이며 5종 교차검증 전체가 통과했습니다.

잘못된 `PGDATABASE=postgres`에서도 Python 로더가 실제로 중단되는 것을 확인했습니다.

---

## 12. custom-format 백업·template0 복원 실제 검증

자동 검증에서 실제로 다음을 수행했습니다.

```text
pg_dump -Fc
--schema=tutor_project
--no-owner
--no-privileges
백업 파일 생성
SHA-256 계산
pg_restore --list 확인
```

별도 DB:

```text
createdb -T template0 tutor_project_restore
pg_restore --single-transaction --no-owner --no-privileges
```

복원 후 P15-V09 `11_restore_validation.sql`에서 다음을 실제 확인했습니다.

```text
BASE TABLE 6
VIEW 4
IDENTITY sequence 5
총 table·sequence·view 객체 15
행 수 4/3/5/5/6/7
constraints 36
FK 5
업무 인덱스 3
시간 관계 이상 0
분석 VIEW 5/4/3
answer_count 합계 5
material_count 합계 7
IDENTITY next > max ID
--no-owner 복원 객체 owner = 현재 복원 역할
```

통과 메시지:

```text
Chapter 15 restore validation passed
```

---

## 13. reset 원자성·격리 실제 검증

`tutor_project.keep_me`라는 예상 밖 객체를 추가한 상태에서 reset을 실행해 실패하는 것을 확인했습니다.

```text
reset 실패
→ 기존 questions 5행 유지
→ keep_me 유지
```

그 뒤 예상 밖 객체를 제거하고 정상 reset을 실행했습니다.

```text
tutor_project 제거
course_project 유지
transaction_lab 유지
performance_lab 유지
security_lab 유지
nosql_lab 유지
ai_review_lab 유지
analysis_lab 유지
```

---

## 14. 발표자료·이미지

발표자료:

```text
이론 20장
실습 20장
모든 장표에 화면 구성·발표 스크립트
shared PresentationTTS.normalize
script_content_enhancer
asset version = 20260809a
```

이미지:

```text
Mermaid 8
SVG 8
stem 일치
SVG role=img
width=100%
viewBox
title
desc
본문에서 8개 SVG 참조
```

개념 구조가 최종 내용과 호환되어 이미지 의미 자체의 재설계는 필요하지 않았습니다.

---

## 15. 완료 게이트 분리

`10_completion_gate.sql` 통과 메시지:

```text
Chapter 15 database completion gate passed
```

하지만 한 게이트만 통과했다고 전체 프로젝트를 자동 완료로 보지 않습니다.

최종 증거는 다음처럼 분리합니다.

```text
DB 완료 게이트
Python SQL·pandas 교차검증
Role 허용·차단
백업·복원 P15-V09
문서·AI diff 사람 승인
```

자동화 가능한 앞 네 영역은 PostgreSQL 16 CI에서 실제 통과했습니다. 문서·AI 판단과 최종 출판 렌더링은 사람 검토 영역으로 유지합니다.

---

## 최종 자동 검증 1차 완전 통과

```text
Workflow: Validate Chapter 15
Run: 7
Run ID: 31303633119
Commit: 06112f85de97fca14e4ebffcdba79c97db56d8d9
PostgreSQL: 16
Conclusion: success
```

이 Run에서 다음 단계가 모두 성공했습니다.

```text
정적 Chapter 15 검사
Python 의존성 설치
잘못된 DB 차단
SQL 01→10
정확한 DB 기준값·재실행 차단
이전 Chapter 스키마 격리
SQL↔pandas 5종 교차검증
Role 허용·차단
custom-format 백업
SHA-256·pg_restore 목록
별도 template0 DB 복원
P15-V09 복원 검증
reset 예상 밖 객체 보호·격리
```

검토 기록과 체크리스트를 갱신한 최종 문서 상태에서 같은 전체 검증을 다시 실행해 definitive run으로 확정합니다.

---

## 수동 확인으로 남기는 항목

다음은 자동 통과로 표시하지 않습니다.

```text
브라우저 이론 20장 실제 렌더링
브라우저 실습 20장 실제 렌더링
semantic step/highlight 실제 조작
발표창 ↔ 스크립트창 실제 동기화
TTS 실제 청취·발음
모바일·프로젝터 가독성
SVG 실제 시각 품질
필요 시 Mermaid CLI 재생성
GitHub·Word·PDF·eBook 최종 렌더링과 페이지 수
AI diff의 내용적 최종 사람 승인
```
