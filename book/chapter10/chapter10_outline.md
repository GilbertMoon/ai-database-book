# Chapter 10 구성안

## 제목

실행 계획으로 인덱스 효과 검증하기

## 권장 분량

24~28페이지

## 이 장의 역할

Chapter 07~09의 데이터를 보호하면서 별도 `performance_lab` 스키마에서 대량 데이터를 생성하고, 같은 SQL의 인덱스 생성 전후 실행 계획을 비교해 적용·보류·제거를 판단한다.

```text
워크로드 정의
→ 데이터·기존 인덱스 확인
→ 기준 실행 계획
→ 후보 인덱스 생성
→ 통계 갱신
→ 동일 SQL 재측정
→ 읽기 이점·쓰기 비용 검토
→ 최종 결정 기록
```

## 핵심 질문

```text
실제로 반복되는 SQL인가?
현재 PK·UNIQUE·수동 인덱스와 겹치는가?
조건이 전체 행 중 적은 행을 선택하는가?
복합 인덱스 컬럼 순서가 쿼리와 맞는가?
인덱스 전후 결과 행은 동일한가?
계획·Buffers·실행 시간이 의미 있게 개선되는가?
쓰기 비용과 저장 공간을 감수할 가치가 있는가?
```

## 실습 구조

```text
performance_lab.students
performance_lab.instructors
performance_lab.courses
performance_lab.enrollments
```

앞 장 스키마:

```text
course_project: 변경 금지
transaction_lab: 변경 금지
```

## 기준 데이터

```text
students 10003
instructors 2
courses 2003
enrollments 100005
```

## 핵심 개념

- B-tree
- 자동·수동 인덱스
- 선택도
- Seq Scan
- Index Scan
- Bitmap Index/Heap Scan
- EXPLAIN
- EXPLAIN ANALYZE
- Buffers
- 예상·실제 rows
- JOIN FK 인덱스
- ORDER BY·LIMIT
- 복합 인덱스
- 선두 컬럼
- 중복 인덱스
- pg_stat_user_indexes
- 읽기·쓰기 비용
- AI 추천 검증

## 본문 구성

1. 프로젝트 데이터와 성능 데이터 분리
2. 파일과 실행 순서
3. 인덱스 필요성
4. 자동·수동 인덱스
5. 데이터와 통계
6. 실행 계획 읽기
7. Seq·Index·Bitmap Scan
8. WHERE 후보
9. JOIN과 FK 자식 컬럼
10. 복합 인덱스와 선두 컬럼
11. ORDER BY·LIMIT
12. 인덱스 전후 비교
13. 예상·실제 행 수
14. 인덱스 비용
15. 중복·제거 판단
16. 사용 통계 주의
17. AI 추천 검토
18. 자주 하는 실수
19. 스스로 확인하기
20. 핵심 정리
21. 다음 장 연결

## 코드 파일

```text
01_performance_lab_schema.sql
02_performance_lab_seed.sql
03_baseline_explain.sql
04_create_candidate_indexes.sql
05_after_index_explain.sql
06_index_review.sql
reset_performance_lab.sql
index_performance_practice.sql
README.md
```

## 최종 수동 인덱스 후보

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

## 안전성 원칙

- `performance_lab`만 생성·초기화한다.
- 기존 `course_project`, `transaction_lab`, `public` 객체를 삭제하지 않는다.
- 생성 파일에서 자동 DROP을 실행하지 않는다.
- `EXPLAIN ANALYZE`는 SELECT에만 사용한다.
- 동일 SQL과 데이터 상태로 전후 비교한다.
- 실행 시간만이 아니라 계획·Buffers·행 수를 함께 본다.
- 환경에 따른 계획 차이를 오류로 단정하지 않는다.

## AI 활용 원칙

- 실제 SQL·행 수·기존 인덱스 목록을 제공한다.
- 후보 컬럼 순서와 중복 여부의 근거를 요구한다.
- 검증 SQL과 적용·보류·제거 기준을 함께 요구한다.
- 자동 인덱스 중복, 무조건적인 Index Scan 선호와 쓰기 비용 누락을 검토한다.

## 다음 장 연결

Chapter 11에서는 성능보다 우선되는 접근 통제, 비밀정보 보호, 백업·복원과 복구 가능성을 다룬다.
