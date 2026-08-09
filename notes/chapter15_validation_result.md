# Chapter 15 자동 검증 결과

## 최종 문서 상태 기준 definitive 실행

```text
Workflow: Validate Chapter 15
Run: 9
Run ID: 31303733804
Commit: d69c9d3c96aa0b9e4ee15993d1436103a66dae1c
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

이 Run은 Chapter 15의 코드 수정, 전체 검토 기록과 최종 체크리스트가 반영된 상태를 다시 검증했습니다.

---

## 1. 최종 구조·기준 데이터

```text
tutor_project BASE TABLE = 6
VIEW = 4
IDENTITY sequence = 5
constraints = 36
FK = 5
업무 인덱스 = 3
CASCADE FK = 0
```

기준 행 수:

```text
students = 4
tutors = 3
questions = 5
answers = 5
learning_materials = 6
question_materials = 7
question_analysis_dataset = 5
```

IDENTITY 다음 값:

```text
students >= 105
tutors >= 204
questions >= 306
answers >= 406
learning_materials >= 507
```

---

## 2. 실제 PostgreSQL 16 SQL 검증

Run 9에서 다음을 실제 실행했습니다.

```text
잘못된 DB에서 01 실패
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

통과 메시지:

```text
P15-V03 metadata validation passed
P15-V04 requirement validation passed
P15-T01~T02 transaction validation passed
P15-T03~T25 negative and boundary validation passed
P15-V05 index candidate validation passed
P15-V06 operational read-only checks passed
P15-V07 analysis dataset validation passed
Chapter 15 database completion gate passed
```

반례·경계값:

```text
실패 반례 = 18
정상 경계값 = 5
총 테스트 = 23
unexpected = 0
SQLSTATE·constraint name = 기대값과 일치
```

---

## 3. 실제 인덱스 사용 증거

PostgreSQL 16 실행 계획에서 대표 조회가 다음 후보 인덱스를 사용했습니다.

```text
questions(student_id, status, created_at DESC)
→ idx_tutor_project_questions_student_status_created

answers(question_id, created_at)
→ idx_tutor_project_answers_question_created

question_materials(material_id)
→ idx_tutor_project_qm_material
```

작은 Seed이므로 이 결과를 대용량 성능 향상으로 일반화하지 않습니다.

---

## 4. 운영 점검에서 실제 발견·수정한 오류

### PUBLIC 권한 조회

기존 SQL이 `PUBLIC`을 일반 Role 이름처럼 조회해 PostgreSQL에서 실패했습니다.

수정 후 DB ACL을 직접 해석해 PUBLIC CONNECT를 판정합니다.

### 08→09 실행 순서

08 운영 점검이 09에서 생성되는 분석 VIEW의 권한을 존재 전에 조회하던 문제를 수정했습니다.

```text
08 시점 VIEW 미존재 = 정상
존재할 때만 SELECT 권한 판정
09에서 VIEW 생성
```

---

## 5. 실제 SQL·pandas 교차 검증

Python 연결:

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
REPEATABLE READ, READ ONLY
```

같은 스냅샷에서 다음 5종 SQL 결과와 pandas 결과를 `assert_frame_equal()`로 직접 비교했습니다.

```text
상태별
월별
학생별
튜터별
첫 답변 시간
```

최종 기준:

```text
status = open1 / answered3 / closed1
월별 = 2026-01~05 각 1건
학생별 질문 = 2 / 1 / 2 / 0
튜터별 답변 = 2 / 1 / 2
answer_count 합계 = 5
material_count 합계 = 7
답변 있는 질문 = 4
평균 첫 답변 = 2.00시간
최소 = 0.50시간
최대 = 3.50시간
```

실제 실행 과정에서 UTC 변환으로 2025-12월이 잘못 생성되는 pandas date spine 오류를 발견했고, `Asia/Seoul`로 먼저 변환한 뒤 월 시작일을 생성하도록 수정했습니다.

통과 메시지:

```text
Chapter 15 SQL and pandas cross-validation passed
```

잘못된 `PGDATABASE=postgres`도 Python에서 실제 중단되는 것을 확인했습니다.

---

## 6. 실제 Role 허용·차단

```text
tutor_project_report
- 분석 VIEW SELECT = 허용
- questions INSERT = 차단

tutor_project_app
- questions SELECT = 허용
- 허용된 questions INSERT = 성공 후 ROLLBACK
- questions DELETE = 차단
- tutor_project CREATE TABLE = 차단
```

---

## 7. 실제 custom-format 백업·복원

백업:

```text
pg_dump -Fc
--schema=tutor_project
--no-owner
--no-privileges
백업 파일 생성
SHA-256 계산
pg_restore --list 확인
```

별도 복원 DB:

```text
createdb -T template0 tutor_project_restore
pg_restore --single-transaction --no-owner --no-privileges
```

P15-V09:

```text
11_restore_validation.sql
→ Chapter 15 restore validation passed
```

복원 후 실제 확인:

```text
table / view / sequence = 6 / 4 / 5
행 수 = 4 / 3 / 5 / 5 / 6 / 7
constraints / FK / indexes = 36 / 5 / 3
시간 관계 이상 = 0
분석 VIEW = 5 / 4 / 3
answer_count 합계 = 5
material_count 합계 = 7
IDENTITY next > max ID
복원 객체 owner = 현재 복원 역할
```

---

## 8. reset 원자성·격리

```text
tutor_project.keep_me 생성
→ reset 실패
→ questions 5행 유지
→ keep_me 유지
→ keep_me 제거
→ 정상 reset 성공
→ tutor_project만 제거
```

보호 대상 sentinel 스키마:

```text
course_project
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
analysis_lab
```

모두 유지되는 것을 확인했습니다.

---

## 9. 발표·정적 검증

```text
이론 20장
실습 20장
모든 장표 화면 구성·발표 스크립트
JavaScript 문법
Python 문법
shared PresentationTTS
script_content_enhancer
asset version 20260809a
Mermaid 8 / SVG 8
SVG role=img / width=100% / viewBox / title / desc
본문 SVG 8개 참조
P15-R/D/Q/T/V 추적성
11_restore_validation.sql = P15-V09
reset CASCADE 미사용
보호 스키마 mutation 금지
```

최근 navigation 자동 검증:

```text
Workflow: Validate Chapter 15 navigation
Run: 6
Run ID: 31303633114
Commit: 06112f85de97fca14e4ebffcdba79c97db56d8d9
Conclusion: success
```

---

## 10. 수동 확인으로 남는 항목

다음 항목은 자동 통과로 표시하지 않습니다.

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
AI diff 내용의 최종 사람 승인
```

이 결과 기록 파일 추가 후 전체 workflow가 다시 실행되며, 그 성공 여부를 최종 저장소 상태 재검증으로 사용합니다.
