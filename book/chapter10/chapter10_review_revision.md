# Chapter 10 최종 출판 검수 반영 기록

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
code/chapter10/07_result_validation.sql
code/chapter10/reset_performance_lab.sql
code/chapter10/index_performance_practice.sql
code/chapter10/README.md
notes/chapter10_review_checklist.md
README.md
```

## 검수 목적

Chapter 10을 단순히 인덱스를 만들고 실행 시간이 줄었는지 확인하는 장이 아니라, **재현 가능한 데이터와 통제된 비교 조건에서 실행 계획·결과 행·운영 비용을 검증하는 장**으로 최종 보완했습니다.

```text
사전 조건
→ 합성 데이터 의미·분포
→ 기준 통계
→ 인덱스 없는 계획
→ 실험 후보 인덱스 생성
→ 같은 통계·SQL 재측정
→ 결과 행 자동 검증
→ 적용·보류·제거 판단
```

---

## 1. 합성 데이터의 업무 정합성 수정

기존 생성식은 같은 학생·강의 조합을 여러 번 만들고 활성 상태도 반복해 Chapter 07의 중복 활성 신청 원칙과 충돌할 수 있었습니다.

새 생성식은 다음을 보장합니다.

```text
학생 10,000명
학생별 서로 다른 강의 10개
강의별 신청 50건
동일 학생·강의 조합 한 번만 생성
활성 신청 중복 조합 0건
```

`paid_amount`는 연결된 강의의 가격을 JOIN해 저장합니다.

---

## 2. 학생 ID와 이메일 번호 통일

기존에는 `performance5000@example.com`의 실제 학생 ID가 6000이었습니다.

다음처럼 실제 ID를 이메일 번호로 사용하도록 수정했습니다.

```text
student_id = 5000
email = performance5000@example.com
```

---

## 3. 기준 결과 확정

| 조건 | 기대 행 수 |
| --- | ---: |
| 이메일 검색 | 1 |
| 강의 제목 검색 | 1 |
| `student_id = 5000` | 10 |
| `course_id = 1500` | 50 |
| `course_id = 1500 AND status = '수강중'` | 15 |
| 전체 수강중 | 30001 |

상태 전체 분포도 업무 순서로 출력하도록 `CASE` 정렬을 적용했습니다.

---

## 4. IDENTITY 다음 값 조정

명시적 ID 입력 뒤 다음 자동값을 조정했습니다.

```text
students.id      → 11001
instructors.id   → 203
courses.id       → 3001
enrollments.id   → 110001
```

명시적 값이 IDENTITY 내부 시퀀스를 자동으로 이동시키지 않는다는 설명을 본문·워크북·코드에 반영했습니다.

---

## 5. 실행 위치와 안전 차단

모든 SQL 파일에서 다음을 확인합니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

`01` 파일은 다음을 검사합니다.

```text
현재 DB = ai_database_book
course_project.enrollments = 5
performance_lab 미존재
```

스키마와 네 테이블은 하나의 트랜잭션에서 생성합니다.

초기화 파일은 현재 DB가 `ai_database_book`일 때만 `performance_lab` 객체를 삭제합니다.

---

## 6. 기준·사후 측정 상태 보호

각 파일이 실행 순서에 맞는지 자동 검사합니다.

```text
03 기준 계획: 실험 후보 인덱스가 모두 없어야 함
04 인덱스 생성: 실험 후보 인덱스가 모두 없어야 함
05 사후 계획: 실험 후보 인덱스가 모두 존재해야 함
06 리뷰: 실험 후보 인덱스가 모두 존재해야 함
```

잘못된 상태에서는 예외를 발생시켜 기준 계획과 사후 계획이 뒤섞이지 않도록 했습니다.

---

## 7. 통계 조건 통제

`02`에서 대량 데이터 입력 후 `ANALYZE`를 한 번 실행합니다.

`04`에서 후보 인덱스를 생성한 뒤에는 `ANALYZE`를 다시 실행하지 않습니다.

```text
같은 데이터
+ 같은 SQL
+ 같은 테이블 통계
+ 실험 후보 인덱스 존재 여부만 변경
```

새 통계 표본의 영향이 인덱스 효과와 섞이지 않도록 비교 조건을 통제했습니다.

---

## 8. 결과 행 자동 검증 파일 추가

새 파일을 추가했습니다.

```text
code/chapter10/07_result_validation.sql
```

다음을 자동 판정합니다.

```text
course_project.enrollments 5행 유지
performance_lab 기준 행 수
기준 SQL 결과 행 수
활성 신청 중복 0건
실험 후보 인덱스 3개 존재
```

실행 계획 노드는 환경에 따라 달라질 수 있으므로 자동 성공·실패 기준으로 사용하지 않고 워크북에 기록합니다.

---

## 9. 복합 인덱스와 Skip Scan 보완

`(course_id, status)`에서 선두 컬럼 조건이 일반적으로 중요하다는 설명을 유지하면서 다음을 추가했습니다.

```text
선두 컬럼 조건이 없다고 절대 사용되지 않는 것은 아니다.
PostgreSQL은 데이터 분포와 비용에 따라 Skip Scan을 선택할 수 있다.
실제 선택은 실행 계획으로 확인한다.
```

현재 데이터에서는 `status='수강중'` 반환 비율이 높고 `course_id` 고유값이 많아 `Seq Scan`이 합리적일 가능성이 큽니다.

---

## 10. 실험 후보와 최종 적용 인덱스 구분

다음 세 인덱스를 “최종 후보”가 아니라 **전후 측정을 위한 실험 후보**로 통일했습니다.

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

최종 적용·보류·제거 판단은 워크북의 계획·Buffers·시간·비용 결과에 따라 달라집니다.

---

## 11. 운영 인덱스 생성 범위 추가

실습 환경에서는 일반 `CREATE INDEX`를 사용합니다.

운영 환경에서는 다음을 검토하도록 추가했습니다.

```text
쓰기 잠금 영향
생성 시간과 추가 공간
CREATE INDEX CONCURRENTLY 필요 여부
트랜잭션 블록 실행 불가
실패 후 INVALID 인덱스 존재 여부
```

---

## 12. idx_scan 설명 보완

다음을 구분했습니다.

```text
PK·UNIQUE 인덱스
→ 제약조건 유지에 직접 사용

FK 자식 컬럼 인덱스
→ FK 정확성을 위한 필수 구조는 아님
→ JOIN과 부모 삭제·키 변경 성능에 도움 가능
```

`idx_scan`을 단순 사용자 SQL 실행 횟수로 읽지 않도록 안내하고, 0이라는 이유만으로 즉시 삭제하지 않도록 했습니다.

---

## 13. 자기주도 학습 보완

본문과 워크북에 다음 해설을 추가했습니다.

```text
자동 인덱스 차이
Seq·Index·Bitmap Scan
cost·rows·actual rows·loops
Filter와 Index Cond
ANALYZE와 EXPLAIN ANALYZE
결과 행 별도 검증
통계 조건 통제
복합 인덱스와 Skip Scan
ORDER BY LIMIT
일반 CREATE INDEX와 CONCURRENTLY
idx_scan 해석
```

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 활성 신청 중복 생성식 수정 | 완료 |
| 학생 ID·이메일 통일 | 완료 |
| 기준 결과 행 수 확정 | 완료 |
| IDENTITY 시작값 조정 | 완료 |
| DB·스키마·search_path 확인 | 완료 |
| 생성·초기화 보호 구문 | 완료 |
| 기준·사후 인덱스 상태 검사 | 완료 |
| 사후 ANALYZE 제거 | 완료 |
| 결과 검증 파일 추가 | 완료 |
| Skip Scan 설명 | 완료 |
| 운영 CONCURRENTLY 안내 | 완료 |
| 실험 후보 표현 통일 | 완료 |
| idx_scan·FK 설명 보완 | 완료 |
| 권장 해설 추가 | 완료 |

## 결론

```text
Chapter 10은 인덱스를 무조건 추가하는 실습이 아니라,
재현 가능한 데이터와 통제된 조건에서 실행 계획과 결과를 비교하고
운영 비용까지 고려해 결정을 기록하는 성능 검증 장으로 최종 보완되었다.
```

실제 PostgreSQL에서 `01→07`을 순차 실행하고 환경별 계획·Buffers·시간을 기록하는 작업은 별도 실행 검증 단계에서 수행합니다.
