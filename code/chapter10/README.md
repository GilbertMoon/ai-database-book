# Chapter 10 실습 코드

## 실행 계획으로 인덱스 효과 검증하기

이 폴더는 기존 프로젝트를 변경하지 않고 `performance_lab`에서 대량 데이터를 생성해 인덱스 전후 실행 계획을 비교하는 SQL 파일을 관리합니다.

---

## 실행 전 조건

Chapter 07의 `course_project`가 준비되어 있어야 합니다. Chapter 10은 해당 데이터를 읽기만 하며 변경하지 않습니다.

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: Chapter 10 전용 실험 공간
```

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `01_performance_lab_schema.sql` | 전용 스키마와 네 테이블 생성 |
| `02_performance_lab_seed.sql` | 기본 데이터와 약 10만 건의 성능 데이터 생성 |
| `03_baseline_explain.sql` | 후보 인덱스 생성 전 기준 실행 계획 |
| `04_create_candidate_indexes.sql` | 세 개의 수동 인덱스 생성과 통계 갱신 |
| `05_after_index_explain.sql` | 같은 SQL의 인덱스 생성 후 계획 |
| `06_index_review.sql` | 자동·수동 인덱스, 크기와 사용 통계 검토 |
| `reset_performance_lab.sql` | performance_lab만 초기화 |
| `index_performance_practice.sql` | 기존 링크 호환용 안내·상태 확인 |

---

## 실행 순서

```text
01_performance_lab_schema.sql
→ 02_performance_lab_seed.sql
→ 03_baseline_explain.sql
→ 04_create_candidate_indexes.sql
→ 05_after_index_explain.sql
→ 06_index_review.sql
```

`03`의 결과를 먼저 기록한 뒤 `04`, `05`를 실행해야 인덱스 전후를 비교할 수 있습니다.

---

## 기준 데이터

| 테이블 | 기대 행 수 |
| --- | ---: |
| `performance_lab.students` | 10003 |
| `performance_lab.instructors` | 2 |
| `performance_lab.courses` | 2003 |
| `performance_lab.enrollments` | 100005 |

PC 성능이 낮으면 `02_performance_lab_seed.sql`의 생성 건수를 줄일 수 있습니다. 다만 행 수가 너무 적으면 PostgreSQL이 합리적으로 `Seq Scan`을 선택해 차이가 작게 보일 수 있습니다.

---

## 최종 수동 인덱스 후보

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

자동 인덱스:

```text
PRIMARY KEY
UNIQUE email
```

PostgreSQL은 외래키 자식 컬럼에 인덱스를 자동 생성하지 않습니다.

---

## 비교할 SQL

```text
학생 이메일 정확 일치
강의 제목 정확 일치
학생별 신청 JOIN
course_id 단독 조건
course_id + status 조건
status 단독 조건
ORDER BY title
ORDER BY title LIMIT 20
```

같은 SQL과 같은 데이터 상태를 인덱스 전후에 사용합니다.

---

## 실행 계획 기록 항목

```text
주요 계획 노드
cost
rows / actual rows
actual time
loops
Buffers hit/read
Filter
Index Cond
Sort
Planning Time
Execution Time
```

`cost`는 실행 시간이 아니며, 환경에 따라 계획과 시간은 달라질 수 있습니다.

---

## 안전 원칙

```text
- public, course_project, transaction_lab 객체를 삭제하지 않습니다.
- 생성 파일에서 자동 DROP을 실행하지 않습니다.
- EXPLAIN (ANALYZE, BUFFERS)는 SELECT에만 사용합니다.
- 실행 시간 한 번만 보고 판단하지 않습니다.
- 계획, 행 수, Buffers와 결과 동일성을 함께 확인합니다.
- idx_scan=0만으로 인덱스를 즉시 삭제하지 않습니다.
```

---

## 초기화

처음부터 다시 시작할 때만 다음 파일을 사용합니다.

```text
reset_performance_lab.sql
```

이 파일은 `performance_lab`의 네 테이블과 스키마만 삭제합니다.
