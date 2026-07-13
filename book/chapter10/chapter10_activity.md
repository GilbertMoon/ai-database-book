# Chapter 10 독자 워크북

## 실행 계획으로 인덱스 효과 검증하기

> 이 워크북은 `performance_lab`에서 같은 SQL의 인덱스 생성 전후 실행 계획을 기록하고, 적용·보류·제거 판단 근거를 남기기 위한 보조 자료입니다. `course_project`와 `transaction_lab`은 변경하지 않습니다.

---

## 1. 실습 파일과 순서

```text
01_performance_lab_schema.sql
02_performance_lab_seed.sql
03_baseline_explain.sql
04_create_candidate_indexes.sql
05_after_index_explain.sql
06_index_review.sql
reset_performance_lab.sql
```

실행 순서:

```text
01 → 02 → 03 → 04 → 05 → 06
```

---

## 2. 환경과 데이터 확인

| 항목 | 기대값 | 실제값 |
| --- | ---: | ---: |
| performance_lab.students | 10003 |  |
| performance_lab.instructors | 2 |  |
| performance_lab.courses | 2003 |  |
| performance_lab.enrollments | 100005 |  |
| course_project.enrollments | 5 유지 |  |

PostgreSQL 버전:

```text
_______________________________________________________________
```

PC·메모리·캐시 상태 메모:

```text
_______________________________________________________________
```

---

## 3. 자동 인덱스 확인

| 테이블·컬럼 | 제약조건 | 자동 인덱스 | 수동 추가 필요 |
| --- | --- | --- | --- |
| students.id | PRIMARY KEY |  |  |
| students.email | UNIQUE |  |  |
| courses.id | PRIMARY KEY |  |  |
| enrollments.id | PRIMARY KEY |  |  |
| enrollments.student_id | FOREIGN KEY |  |  |
| enrollments.course_id | FOREIGN KEY |  |  |

`students.email`에 별도 수동 인덱스를 만들지 않는 이유:

```text
_______________________________________________________________
```

---

## 4. 실행 계획 항목 읽기

| 항목 | 나의 설명 |
| --- | --- |
| cost |  |
| rows |  |
| actual rows |  |
| actual time |  |
| loops |  |
| Buffers |  |
| Filter |  |
| Index Cond |  |
| Sort |  |

`ANALYZE table`과 `EXPLAIN ANALYZE`의 차이:

```text
_______________________________________________________________
```

---

## 5. 이메일 자동 인덱스 확인

대상 SQL:

```sql
SELECT id, name, email
FROM performance_lab.students
WHERE email = 'performance5000@example.com';
```

| 계획 노드 | Index Cond | actual rows | Buffers | 실행 시간 |
| --- | --- | ---: | --- | --- |
|  |  |  |  |  |

사용된 인덱스가 자동 생성된 이유:

```text
_______________________________________________________________
```

---

## 6. 강의 제목 인덱스 전후 비교

대상 SQL:

```sql
SELECT id, title, level, price
FROM performance_lab.courses
WHERE title = '성능 테스트 강의 00500';
```

| 항목 | 생성 전 | 생성 후 | 해석 |
| --- | --- | --- | --- |
| 주요 계획 노드 |  |  |  |
| 예상 rows |  |  |  |
| actual rows |  |  |  |
| Buffers |  |  |  |
| Execution Time |  |  |  |
| 결과 행 동일 |  |  |  |

적용 판단:

```text
적용 / 보류 / 제거
이유:
```

---

## 7. 학생별 신청 JOIN 인덱스 비교

대상 조건:

```text
e.student_id = 5000
```

| 항목 | 생성 전 | 생성 후 | 해석 |
| --- | --- | --- | --- |
| enrollments 접근 노드 |  |  |  |
| Index Cond |  |  |  |
| actual rows |  |  |  |
| Buffers |  |  |  |
| Execution Time |  |  |  |

FK 컬럼에 수동 인덱스를 검토한 이유:

```text
_______________________________________________________________
```

---

## 8. 복합 인덱스와 선두 컬럼

인덱스:

```sql
(course_id, status)
```

| 조건 | 주요 계획 노드 | Index Cond | actual rows | 해석 |
| --- | --- | --- | ---: | --- |
| course_id = 1500 |  |  |  |  |
| course_id = 1500 AND status = '수강중' |  |  |  |  |
| status = '수강중' |  |  |  |  |

`status` 단독 조건에서 제한적일 수 있는 이유:

```text
_______________________________________________________________
```

단일 `course_id` 인덱스를 별도로 유지할지 판단:

```text
유지 / 미생성 / 추가 검토
이유:
```

---

## 9. ORDER BY와 LIMIT 비교

| SQL | Sort 노드 | Index Scan | Buffers | 실행 시간 | 해석 |
| --- | --- | --- | --- | --- | --- |
| ORDER BY title 전체 |  |  |  |  |  |
| ORDER BY title LIMIT 20 |  |  |  |  |  |

LIMIT이 계획에 영향을 줄 수 있는 이유:

```text
_______________________________________________________________
```

---

## 10. 예상 rows와 actual rows 비교

| SQL | 예상 rows | actual rows | 차이 배수 | 통계 적절성 |
| --- | ---: | ---: | ---: | --- |
| 제목 검색 |  |  |  |  |
| 학생별 신청 |  |  |  |  |
| 강의+상태 검색 |  |  |  |  |

차이가 큰 경우 확인할 항목:

```text
ANALYZE 실행 여부:
데이터 분포:
조건 값의 빈도:
컬럼 상관관계:
```

---

## 11. 최종 인덱스 목록과 크기

| index_name | table_name | 자동/수동 | index_size | 역할 |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

최종 수동 후보:

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

---

## 12. 읽기 이점과 쓰기 비용

| 후보 인덱스 | 읽기 이점 | 쓰기·저장 비용 | 최종 판단 |
| --- | --- | --- | --- |
| courses(title) |  |  |  |
| enrollments(student_id) |  |  |  |
| enrollments(course_id, status) |  |  |  |

WHERE에 자주 나타난다는 이유만으로 모든 컬럼에 인덱스를 만들면 안 되는 이유:

```text
_______________________________________________________________
```

---

## 13. idx_scan 통계 검토

| index_name | idx_scan | 즉시 삭제 가능? | 추가 확인 |
| --- | ---: | --- | --- |
|  |  |  |  |
|  |  |  |  |

`idx_scan = 0`만으로 삭제하면 안 되는 이유:

```text
_______________________________________________________________
```

---

## 14. AI 추천 인덱스 검토

| AI 추천 | 기존 인덱스 중복 | 컬럼 순서 근거 | 전후 측정 | 쓰기 비용 | 판단 |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

대표 오류 점검:

```text
UNIQUE 자동 인덱스 중복:
모든 WHERE 컬럼 인덱스화:
복합 인덱스 순서 근거 부족:
Seq Scan 무조건 오류 판단:
실행 계획 없이 성능 향상 단정:
```

---

## 15. 최종 점검

| 점검 항목 | 완료 |
| --- | --- |
| performance_lab만 생성했다 |  |
| course_project와 transaction_lab을 변경하지 않았다 |  |
| 데이터 생성 후 ANALYZE를 실행했다 |  |
| 자동·수동 인덱스를 구분했다 |  |
| 같은 SQL을 생성 전후에 비교했다 |  |
| 결과 행이 동일한지 확인했다 |  |
| 계획 노드·rows·Buffers·시간을 기록했다 |  |
| 복합 인덱스 선두 컬럼을 확인했다 |  |
| 중복 인덱스 가능성을 검토했다 |  |
| 읽기 이점과 쓰기 비용을 함께 판단했다 |  |
| AI 추천을 측정 결과로 검증했다 |  |

이 장의 핵심을 자신의 말로 작성합니다.

```text
가치 있는 인덱스는 ________________________________________________이다.
```
