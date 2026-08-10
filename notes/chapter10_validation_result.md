# Chapter 10 자동 검증 결과

## 최종 기준 실행

```text
Workflow: Validate Chapter 10
Run: 4
Run ID: 31285494158
Commit: 76dc98e36fae6b717a2910a2b277c0e94238235c
Status: completed
Conclusion: success
PostgreSQL: 16.14
Date: 2026-08-09 (Asia/Seoul)
```

## 검증 범위

Chapter 10의 본문·구성안·워크북·SQL·이미지·이론/실습 발표자료·발표자 스크립트·내비게이션·TTS 연결과 실제 PostgreSQL 성능 실험 경로를 함께 검증했습니다.

```text
Chapter 07·08 기준 상태
→ performance_lab 생성
→ 10만 건 합성 데이터 생성
→ 후보 인덱스 없는 기준 계획
→ 후보 인덱스 3개 생성
→ 같은 SQL 사후 계획
→ 인덱스 정의·크기·사용 통계
→ 결과·분포·보호 상태 자동 판정
→ 재실행 차단
→ performance_lab reset
→ Chapter 07·08 기준 상태 재검증
```

## 1. 정적 정합성

Run 4에서 다음 항목이 통과했습니다.

```text
- Chapter 10 본문 번호 절 25개
- 이론 발표 강의안 20개 절
- 실습 발표 강의안 20개 절
- 모든 발표 절에 화면 구성·발표 스크립트 존재
- 금액 열 이름 = recorded_amount
- 검증 기준 PostgreSQL 16 명시
- PostgreSQL 18+ Skip Scan 버전 차이 명시
- 발표 자산 버전 = 20260809a
- JavaScript 문법
- 공통 TTS normalization 사용
- script_content_enhancer 연결
- 03과 05의 EXPLAIN 대상 SELECT 8개 완전 일치
- 04 후보 인덱스 정확히 3개
- Chapter 10 SQL이 course_project를 변경하지 않음
- Mermaid 8개 / SVG 8개 쌍
- SVG role=img, width=100%, viewBox, title, desc
```

## 2. Chapter 07·08 시작 기준

PostgreSQL 16에서 Chapter 07의 01→04를 실제 실행하고 Chapter 08의 기준 검증을 다시 실행했습니다.

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 recorded_amount = 590000
활성 신청 = 3 / 340000
취소 제외 이력 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

Chapter 10 실행 전 `course_project` 전체를 정렬된 JSON으로 직렬화해 MD5 fingerprint를 저장했습니다.

```text
cd1c890f3e9bb4a5816b5763c19fa646
```

Chapter 10 전체 실행 후와 reset 후에도 동일한 fingerprint인지 자동 비교했습니다.

## 3. 01 스키마 생성 실제 검증

`01_performance_lab_schema.sql`이 실제 PostgreSQL 16에서 통과했습니다.

```text
performance_lab.students
performance_lab.instructors
performance_lab.courses
performance_lab.enrollments
```

생성 직후:

```text
4개 테이블 모두 0행
named constraints = 15
NOT NULL columns = 20
자동 인덱스 = 6
후보 인덱스 = 0
price = NUMERIC(12,0)
recorded_amount = NUMERIC(12,0)
```

통과 메시지:

```text
Chapter 10 performance lab schema validation passed
```

잘못된 데이터베이스 `postgres`에서 실행하면 `performance_lab`을 생성하지 않고 실패하는 것도 확인했습니다.

## 4. 02 대량 데이터 실제 생성

실제 생성 결과:

```text
students      = 10003
instructors   = 2
courses       = 2003
enrollments   = 100005
```

상태 분포:

```text
신청    = 30002
수강중  = 30001
완료    = 20001
취소    = 20001
```

기준 결과:

```text
performance5000@example.com = 1행
성능 테스트 강의 00500 = 1행
student_id 5000 = 10행
course_id 1500 = 50행
course_id 1500 + 수강중 = 15행
전체 수강중 = 30001행
```

추가 검증:

```text
생성 학생마다 신청 10건
생성 강의마다 신청 50건
활성 학생·강의 중복 = 0
recorded_amount != course.price = 0
후보 인덱스 = 0
```

통과 메시지:

```text
Chapter 10 performance lab seed validation passed
```

## 5. 후보 인덱스 생성 전 실제 계획

후보 인덱스 생성 전 자동 인덱스는 6개였습니다.

주요 PostgreSQL 16 실행 결과:

### 이메일 검색

```text
Index Scan using uq_performance_students_email
rows = 1
Buffers shared hit = 3
Execution Time ≈ 0.027 ms
```

### 강의 제목 정확 일치

```text
Seq Scan on courses
rows = 1
Rows Removed by Filter = 2002
Buffers hit = 34
Execution Time ≈ 0.279 ms
```

### student_id = 5000 JOIN

```text
enrollments = Seq Scan
Rows Removed by Filter = 99995
Buffers hit = 736
Execution Time ≈ 9.590 ms
```

### course_id = 1500

```text
Seq Scan on enrollments
rows = 50
Rows Removed by Filter = 99955
Buffers hit = 736
Execution Time ≈ 6.906 ms
```

### course_id = 1500 AND status = '수강중'

```text
Seq Scan on enrollments
rows = 15
Rows Removed by Filter = 99990
Buffers hit = 736
Execution Time ≈ 6.679 ms
```

### status = '수강중'

```text
Seq Scan
rows = 30001
Rows Removed by Filter = 70004
Buffers hit = 736
Execution Time ≈ 9.607 ms
```

기준 측정 통과 메시지:

```text
Chapter 10 baseline explain validation passed
```

## 6. 후보 인덱스 생성

실제 생성한 후보는 다음 3개입니다.

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

생성 후:

```text
전체 인덱스 = 9
후보 인덱스 = 3
세 후보 모두 valid / ready
```

`04`에서는 `ANALYZE`를 다시 실행하지 않아 기준·사후 측정이 동일한 테이블 통계를 사용하게 했습니다.

통과 메시지:

```text
Chapter 10 candidate index creation passed
```

## 7. 후보 인덱스 생성 후 실제 계획

### 제목 정확 일치

```text
Index Scan using idx_performance_courses_title
Buffers hit = 3
Execution Time ≈ 0.034 ms
```

### student_id = 5000 JOIN

```text
Index Scan using idx_performance_enrollments_student_id
Index Cond: student_id = 5000
Execution Time ≈ 0.073 ms
```

### course_id = 1500

```text
Bitmap Heap Scan
→ Bitmap Index Scan on idx_performance_enrollments_course_status
Index Cond: course_id = 1500
rows = 50
Buffers hit = 52
Execution Time ≈ 0.086 ms
```

### course_id = 1500 AND status = '수강중'

```text
Bitmap Heap Scan
→ Bitmap Index Scan on idx_performance_enrollments_course_status
Index Cond: course_id = 1500 AND status = '수강중'
rows = 15
Buffers hit = 17
Execution Time ≈ 0.039 ms
```

### status = '수강중' — PostgreSQL 16 핵심 검증

복합 인덱스 `(course_id, status)`가 존재해도 PostgreSQL 16 실제 계획은 다음과 같았습니다.

```text
Seq Scan
actual rows = 30001
Rows Removed by Filter = 70004
Buffers hit = 736
Execution Time ≈ 11.049 ms
```

Actions에서는 같은 SQL을 `EXPLAIN (FORMAT JSON)`으로도 확인했고 `Node Type = Seq Scan`이었습니다.

따라서 Chapter 10은 PostgreSQL 16 기준으로 “후행 `status` 조건만으로 복합 인덱스가 자동으로 효율적으로 사용된다”고 설명하지 않습니다. PostgreSQL 18 이상에서는 B-tree Skip Scan 추가로 계획이 달라질 수 있으므로 버전을 분리해 설명합니다.

### ORDER BY title

```text
Index Scan using idx_performance_courses_title
rows = 2003
Execution Time ≈ 0.788 ms
```

### ORDER BY title LIMIT 20

```text
Limit
→ Index Scan using idx_performance_courses_title
Buffers hit = 3
Execution Time ≈ 0.021 ms
```

사후 측정 통과 메시지:

```text
Chapter 10 after-index explain validation passed
```

## 8. 인덱스 리뷰와 최종 판정

실제 리뷰 시점에는 다음과 같이 확인됐습니다.

```text
전체 인덱스 = 9
후보 인덱스 = 3
모든 후보 valid / ready
```

최종 자동 검증은 다음을 함께 검사했습니다.

```text
기준 결과 1 / 1 / 10 / 50 / 15 / 30001
상태 분포 30002 / 30001 / 20001 / 20001
활성 중복 = 0
금액 불일치 = 0
학생별 분포 오류 = 0
강의별 분포 오류 = 0
Chapter 07·08 기준 상태 유지
```

통과 메시지:

```text
Chapter 10 index review validation passed
Chapter 10 performance result validation passed
```

최종 상태 문자열:

```text
10003:2:2003:100005:9:3
```

## 9. 재실행 차단

완료 상태에서 다음 파일을 다시 실행해 모두 실패하는 것을 확인했습니다.

```text
01 → performance_lab 기존 존재로 중단
02 → lab이 비어 있지 않아 중단
04 → 자동 6 / 후보 0 상태가 아니므로 중단
```

따라서 기준·사후 실험 상태를 잘못 섞는 재실행을 차단합니다.

## 10. reset 격리 검증

`reset_performance_lab.sql`을 실제 실행했습니다.

```text
performance_lab 제거
course_project 유지
```

통과 메시지:

```text
Chapter 10 performance lab reset passed
```

reset 후:

```text
performance_lab = 없음
course_project fingerprint = 실행 전과 동일
Chapter 08 00_check_course_project.sql = 통과
Chapter 08 03_join_aggregation_validation.sql = 통과
```

## 11. 검증 과정에서 발견·수정한 문제

### Run 1 — 실제 문서 정합성 문제

구성안에 자연어 설명은 있었지만 실제 스키마 열 `recorded_amount`가 직접 연결되지 않았습니다.

검증 조건을 낮추지 않고 본문·구성안·워크북·이론/실습 강의안에 Chapter 07·08의 실제 열과 기준값을 추가했습니다.

### Run 2 — validator 주석 오인

검증 정규식이 설명 주석의 `CREATE INDEX CONCURRENTLY`를 실제 네 번째 인덱스 생성문으로 오인했습니다.

주석을 실행문처럼 보이지 않도록 고치고 validator도 주석을 제거한 SQL만 검사하도록 보완했습니다.

### Run 3 — psql NOTICE 캡처 문제

`01`과 `02` SQL 자체는 실제 PostgreSQL에서 성공했지만 `RAISE NOTICE`가 stderr로 출력되어 stdout-only 로그 검사에서 통과 메시지를 놓쳤습니다.

validator가 stdout과 stderr를 함께 캡처하도록 수정했습니다.

### Run 4 — 전체 성공

정적 검증부터 PostgreSQL 실제 실행, 재실행 차단, reset까지 전 단계가 성공했습니다.

## 12. 자동 검증과 별도인 수동 확인

다음은 실제 브라우저·출력 환경에서 별도 확인합니다.

```text
이론 20장 / 실습 20장 최종 시각 렌더링
단계별 강조 실제 시각 동작
발표자 스크립트 창 ↔ 장표 창 실제 동기화
TTS 실제 음성 청취·발음
모바일·프로젝터 가독성
Mermaid CLI 재생성
GitHub SVG 실제 렌더링
Word·PDF·eBook 표·코드·SVG 최종 출력
```

---

## 2026-08-10 최종 출판 재검증

Chapter 10 최종 출판 보완 뒤 PostgreSQL 16에서 별도 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 10 final publication validation once
Run: 1
Run ID: 31382892778
Validation commit: 5cc10f3fb23ae093f6cd3b4ae2c58de7ba9bb295
Content commit: 98f6a9461bdbdcd7c92d867d2b3062982d14e615
Asset compatibility commit: 72701b0c5e790276286d619f0163fca0b5fdb088
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 07 01→04 기준 상태 실제 생성 성공
Chapter 08 사전·집계 게이트 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
현재 역할의 ai_database_book CREATE 권한 사전 검사 확인
CREATE 권한이 없는 역할에서 performance_lab 생성 차단
권한 차단 뒤 performance_lab 미생성 확인
performance_lab = students 10003 / instructors 2 / courses 2003 / enrollments 100005
선택도 기준 결과 = 10 / 50 / 15 / 30001 / 전체 100005
03·05의 enable_seqscan/indexscan/bitmapscan = on 기준 유지
SQL 파일에서 강제 enable_* = off 설정 없음
후보 인덱스 3개 생성 및 실제 선택 확인
PostgreSQL 16 status 단독 조건 = Seq Scan 유지
ORDER BY title LIMIT 20 = title 후보 인덱스 선택 확인
05→06→07 사후 측정·리뷰·최종 검증 성공
course_project 전체 fingerprint 실행 전후 동일
reset은 performance_lab만 제거하고 course_project fingerprint 유지
Chapter 08 게이트 reset 후 재통과
Chapter 10 작성 발표 스크립트 자동 확장 비활성화
검증된 발표 자산 버전 = 20260809a 유지
```

### 선택도 설명 보강

`performance_lab.enrollments` 100,005행을 기준으로 다음 반환 비율을 본문·워크북·발표자료에 추가했습니다.

```text
student_id = 5000                 10행   ≈ 0.010%
course_id = 1500                  50행   ≈ 0.050%
course_id = 1500 + 수강중         15행   ≈ 0.015%
status = 수강중                30001행   ≈ 30.0%
```

이 비율은 인덱스 후보를 이해하기 위한 단서이며 단독 정답으로 사용하지 않습니다. 실제 판단은 계획 노드, Index Cond, Buffers, 결과 행, 반복 측정과 쓰기 비용을 함께 봅니다.

### 플래너 설정 기준 보강

`SET enable_seqscan = off`처럼 특정 계획을 강제로 피하게 만든 결과는 인덱스 효과의 최종 증거로 사용하지 않습니다. Chapter 10의 기준·사후 측정은 `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`을 모두 `on`으로 유지해 PostgreSQL 옵티마이저가 실제로 선택한 계획을 비교합니다.

### 시작 게이트 보강

`01_performance_lab_schema.sql`은 잘못된 환경에서 명시적 DDL 트랜잭션을 열기 전에 사전 조건을 검사합니다. Chapter 07 구조 계약 15/20과 DB `CREATE` 권한이 맞아야 `BEGIN → CREATE SCHEMA/TABLE → 검증 → COMMIT` 단계로 진입합니다.

