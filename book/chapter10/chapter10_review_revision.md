# Chapter 10 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter10/chapter10.md
book/chapter10/chapter10_activity.md
book/chapter10/chapter10_outline.md
code/chapter10/01_performance_lab_schema.sql
code/chapter10/02_performance_lab_seed.sql
code/chapter10/03_baseline_explain.sql
code/chapter10/04_create_candidate_indexes.sql
code/chapter10/05_after_index_explain.sql
code/chapter10/06_index_review.sql
code/chapter10/reset_performance_lab.sql
code/chapter10/index_performance_practice.sql
code/chapter10/README.md
images/chapter10/README.md
notes/chapter10_review_checklist.md
README.md
```

## 목적

Chapter 10을 기존 프로젝트 테이블을 삭제하고 다시 만드는 단일 SQL 실습에서, **독립된 성능 실험 환경에서 동일 SQL의 인덱스 전후 실행 계획을 비교하는 장**으로 재구성한다.

```text
조회 패턴
→ 현재 인덱스와 데이터 규모
→ 기준 실행 계획
→ 후보 인덱스
→ 통계 갱신
→ 동일 SQL 재측정
→ 읽기 이점·쓰기 비용
→ 적용·보류·제거
```

---

## 1. 제목 변경

```text
기존: 인덱스와 성능 기초
변경: 실행 계획으로 인덱스 효과 검증하기
```

---

## 2. 성능 실습 격리

기존 SQL은 `public`의 `students`, `courses`, `enrollments`와 Chapter 09의 `payments`까지 삭제했다.

변경 후:

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: Chapter 10 전용
```

```text
performance_lab.students
performance_lab.instructors
performance_lab.courses
performance_lab.enrollments
```

초기화는 `reset_performance_lab.sql`에서 해당 스키마만 삭제한다.

---

## 3. 데이터 기준

| 테이블 | 기본 데이터 | 자동 생성 | 최종 행 수 |
| --- | ---: | ---: | ---: |
| students | 3 | 10000 | 10003 |
| instructors | 2 | 0 | 2 |
| courses | 3 | 2000 | 2003 |
| enrollments | 5 | 100000 | 100005 |

각 성능 학생은 약 10건, 각 성능 강의는 약 50건의 신청을 가진다. 동일 강의 안에서도 상태 값이 여러 종류로 분포하도록 생성 규칙을 조정했다.

---

## 4. 강화한 내용

| 항목 | 반영 내용 |
| --- | --- |
| 실험 격리 | performance_lab 전용 스키마 |
| 재현성 | 명시적 ID와 기대 행 수 제공 |
| 자동 인덱스 | PK·UNIQUE와 FK 차이 명확화 |
| 실행 계획 | cost·rows·actual rows·loops·Buffers 설명 |
| 스캔 종류 | Seq·Index·Bitmap Scan 구분 |
| 통계 | ANALYZE와 예상·실제 행 수 차이 설명 |
| 후보 판단 | WHERE·JOIN·ORDER BY·LIMIT 기반 검토 |
| 복합 인덱스 | 선두 컬럼과 상태 분포 실습 |
| 전후 비교 | 같은 SQL을 별도 파일에서 반복 측정 |
| 비용 | 읽기 이점과 쓰기·저장 비용 함께 검토 |
| 사용 통계 | idx_scan=0 즉시 삭제 금지 |
| AI 검토 | 중복·컬럼 순서·측정 근거 확인 |

---

## 5. SQL 구조 변경

### 기존

```text
index_performance_practice.sql
- public 테이블 자동 DROP
- SERIAL 테이블 생성
- 데이터 생성·인덱스 생성·전후 계획 혼합
```

### 변경

```text
01_performance_lab_schema.sql
- IDENTITY 기반 전용 테이블 생성

02_performance_lab_seed.sql
- 기본·대량 데이터 생성과 ANALYZE

03_baseline_explain.sql
- 수동 후보 인덱스 생성 전 기준 계획

04_create_candidate_indexes.sql
- 세 후보 인덱스 생성

05_after_index_explain.sql
- 동일 SQL 재측정

06_index_review.sql
- 정의·크기·사용 통계·중복 가능성 확인

reset_performance_lab.sql
- 전용 스키마만 초기화

index_performance_practice.sql
- 안전한 호환 진입점
```

---

## 6. 최종 수동 인덱스 후보

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

다음은 별도 생성하지 않는다.

```text
students(email)
- UNIQUE 자동 인덱스와 중복

별도 enrollments(course_id)
- (course_id, status) 선두 컬럼 활용과 중복 가능성을 우선 검토
```

---

## 7. 안전성 개선

```text
- 자동 DROP 제거
- SERIAL을 IDENTITY로 변경
- 스키마가 붙은 객체명 사용
- EXPLAIN ANALYZE를 SELECT에만 적용
- 인덱스 제거 문장은 주석 상태로 제공
- 앞 장 스키마 행 수를 보호 기준으로 확인
```

---

## 8. 도식 처리

기존 Mermaid·SVG 8종은 인덱스 판단, 스캔 경로, 복합 인덱스, 실행 계획과 AI 검토라는 일반 메시지가 새 본문과 호환되어 유지한다.

이미지 문서에는 새 제목과 `performance_lab` 기준, 본문 그림 번호를 반영한다.

---

## 9. 남은 확인 항목

```text
- 실제 PostgreSQL에서 01→06 순서 실행
- 대량 데이터 생성 시간 확인
- 환경별 Seq·Index·Bitmap 계획 차이 확인
- 인덱스 전후 Buffers와 실행 시간 기록
- course_project 5건 유지 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 10. 최종 상태

```text
Chapter 10 본문, 워크북, 구성안과 단계별 성능 SQL을 2차 재구성했다.
기존 프로젝트를 보호하면서 실행 계획을 근거로 인덱스를 판단할 수 있다.
원격 main에 모든 변경을 직접 반영했다.
```
