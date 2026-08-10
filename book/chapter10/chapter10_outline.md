# Chapter 10 구성안

> **검증 기준 버전**
>
> 이 장의 자동 검증 기준은 **PostgreSQL 16**입니다. PostgreSQL 16의 다중 컬럼 B-tree에서는 선두 컬럼 제약이 없으면 후행 컬럼 조건만으로 탐색 범위를 줄이기 어렵습니다. **B-tree Skip Scan은 PostgreSQL 18에서 추가**되었으므로, PostgreSQL 18 이상에서는 동일 SQL의 계획이 달라질 수 있습니다. 실습 결과에는 서버 버전을 함께 기록합니다.

**Chapter 07·08 시작 기준**

`course_project`의 `students / instructors / courses / enrollments = 3 / 2 / 3 / 5`, 상태는 `신청 2 / 수강중 1 / 완료 1 / 취소 1`이어야 합니다.  
`course_project.enrollments.recorded_amount`는 `NUMERIC(12,0)`이며, 전체 기록 금액은 `590000`, 활성 신청은 `3건 / 340000`, 취소 제외 이력은 `4건 / 440000`입니다.  
기준 신청은 `1001 = 완료 / 100000`, `1004 = 취소 / 150000`, `1005 = 신청 / 120000`이고 `uq_course_enrollments_active`가 존재해야 합니다. 또한 Chapter 07의 **명명 제약조건 15개와 `NOT NULL` 열 20개**가 유지되어야 합니다. Chapter 10은 이 상태를 읽기만 하고 변경하지 않습니다.


## 제목

실행 계획으로 인덱스 효과 검증하기

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 07~09의 데이터를 보호하면서 별도 `performance_lab` 스키마에서 대량 데이터를 생성하고, 같은 데이터·통계·SQL의 인덱스 생성 전후 실행 계획을 비교해 적용·보류·제거를 판단한다.

```text
사전 조건 검사
→ 재현 가능한 대량 데이터 생성
→ 통계 수집
→ 기준 실행 계획
→ 실험 후보 인덱스 생성
→ 동일 SQL 재측정
→ 결과 행과 상태 자동 검증
→ 읽기 이점·쓰기 비용·운영 잠금 검토
→ 최종 결정 기록
```

## 핵심 질문

```text
실제 반복 워크로드인가?
현재 PK·UNIQUE·수동 인덱스와 겹치는가?
합성 데이터가 업무 규칙과 기대 분포를 만족하는가?
기준·사후 측정의 데이터·통계·SQL이 같은가?
조건이 전체 행 중 적은 행을 선택하는가?
복합 인덱스 PostgreSQL 16에서 컬럼 순서가 쿼리와 맞는가? PostgreSQL 18+에서는 Skip Scan으로 계획이 달라질 수 있는가?
실행 계획과 결과 행이 모두 검증되었는가?
계획·Buffers·실행 시간이 의미 있게 개선되는가?
쓰기 비용·저장 공간·운영 잠금을 감수할 가치가 있는가?
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
course_project: 변경 금지, 3/2/3/5와 상태 2/1/1/1, recorded_amount 590000/340000/440000 기준 유지
transaction_lab: 변경 금지
```

## 기준 데이터

| 테이블 | 행 수 |
| --- | ---: |
| `students` | 10003 |
| `instructors` | 2 |
| `courses` | 2003 |
| `enrollments` | 100005 |

합성 데이터 기준:

```text
학생 ID 1001~11000
학생별 신청 10건
강의별 신청 50건
활성 학생·강의 중복 0건
performance5000@example.com = 학생 ID 5000
```

기준 결과:

```text
이메일 검색                    1행
강의 제목 검색                 1행
student_id = 5000            10행
course_id = 1500             50행
course_id 1500 + 수강중       15행
전체 수강중                 30001행
```

선택도 기준:

```text
student_id = 5000                  10 / 100005 ≈ 0.010%
course_id = 1500                   50 / 100005 ≈ 0.050%
course_id = 1500 + 수강중          15 / 100005 ≈ 0.015%
status = 수강중                 30001 / 100005 ≈ 30.0%
```

낮은 반환 비율은 인덱스 후보 판단의 단서이지 단독 정답이 아니다. 실제 계획·Buffers·정렬·쓰기 비용을 함께 본다.

## IDENTITY 시작값

```text
students.id      → 11001
instructors.id   → 203
courses.id       → 3001
enrollments.id   → 110001
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
- 결과 행 검증
- 통계 표본과 실험 통제
- JOIN FK 인덱스
- ORDER BY·LIMIT
- 복합 인덱스
- 선두 컬럼
- PostgreSQL 18+ Skip Scan
- 중복 인덱스
- `pg_stat_user_indexes`
- 읽기·쓰기 비용
- `CREATE INDEX CONCURRENTLY`
- AI 추천 검증

## 본문 구성

1. 프로젝트 데이터와 성능 데이터 분리
2. 실습 파일·순서와 단계별 보호
3. 기준 데이터와 재현성
4. 명시적 ID와 IDENTITY
5. 인덱스 필요성
6. 자동·수동 인덱스
7. 통계 수집과 비교 조건 통제
8. 실행 계획과 결과 행 검증
9. Seq·Index·Bitmap Scan
10. WHERE 후보
11. JOIN과 FK 자식 컬럼
12. 복합 인덱스·선두 컬럼·PostgreSQL 18+ Skip Scan
13. ORDER BY·LIMIT
14. 같은 조건의 전후 비교
15. 예상·실제 행 수
16. 인덱스 비용
17. 일반 CREATE INDEX와 운영 환경
18. 중복·제거 판단
19. 사용 통계 주의
20. AI 추천 검토
21. 자주 하는 실수
22. 스스로 확인하기
23. 권장 해설
24. 핵심 정리
25. 다음 장 연결

## 코드 파일

```text
01_performance_lab_schema.sql
02_performance_lab_seed.sql
03_baseline_explain.sql
04_create_candidate_indexes.sql
05_after_index_explain.sql
06_index_review.sql
07_result_validation.sql
reset_performance_lab.sql
index_performance_practice.sql
README.md
```

## 단계별 상태 보호

```text
01: DB·Chapter 07 기준 상태·performance_lab 미존재 검사
02: 빈 테이블·후보 인덱스 미존재 검사
03: 기준 행 수·후보 인덱스 0개 검사
04: 기준 행 수·후보 인덱스 0개 검사
05: 기준 행 수·후보 인덱스 3개 검사
06: 후보 인덱스 3개 검사
07: 결과 행·기준 상태·후보 인덱스 자동 판정
reset: ai_database_book에서만 performance_lab 삭제
```

## 전후 측정을 위한 실험 후보

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

“최종 적용 인덱스”가 아니라 측정 후보로 표현한다. 최종 결정은 워크북 결과에 따라 달라진다.

## 실험 통제 원칙

```text
02에서 데이터 생성과 ANALYZE
03에서 기준 계획 기록
04에서 인덱스만 생성하고 ANALYZE 재실행 없음
05에서 동일 SQL 재측정
07에서 결과 행과 상태 검증
```

인덱스 전후 사이에는 데이터, SQL과 테이블 통계를 변경하지 않는다. `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`도 모두 기본값 `on`으로 유지하며, 특정 계획을 강제하는 설정은 최종 효과 증거로 사용하지 않는다.

## 운영 인덱스 생성 범위

```text
실습: 일반 CREATE INDEX
운영: 잠금·시간·디스크 검토
필요 시 CREATE INDEX CONCURRENTLY
트랜잭션 블록 실행 불가와 INVALID 인덱스 확인
```

## 안전성 원칙

- `performance_lab`만 생성·초기화한다.
- 기존 `course_project`, `transaction_lab`, `public` 객체를 삭제하지 않는다.
- 모든 위치 확인에 DB·스키마·`SHOW search_path`를 사용한다.
- 생성 파일에서 자동 DROP을 실행하지 않는다.
- 초기화 파일은 DB 보호 구문 안에서만 삭제한다.
- `EXPLAIN ANALYZE`는 `SELECT`에만 사용한다.
- 동일 SQL·데이터·통계 상태로 전후 비교한다.
- 실행 계획과 결과 행 동일성을 별도로 검증한다.
- 환경에 따른 계획 차이를 오류로 단정하지 않는다.
- `idx_scan=0`만으로 삭제하지 않는다.

## AI 활용 원칙

- 실제 SQL·행 수·기존 인덱스 목록을 제공한다.
- 후보 컬럼 순서와 PostgreSQL 18+ Skip Scan·중복 여부의 근거를 요구한다.
- 검증 SQL과 결과 동일성 판정을 함께 요구한다.
- 자동 인덱스 중복, 무조건적인 Index Scan 선호와 쓰기 비용 누락을 검토한다.
- 운영 환경에서는 잠금과 `CONCURRENTLY` 검토를 요구한다.

## 다음 장 연결

Chapter 11에서는 성능보다 우선되는 접근 통제, 비밀정보 보호, 백업·복원과 복구 가능성을 다룬다.
