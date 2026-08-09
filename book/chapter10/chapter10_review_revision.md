# Chapter 10 전체 점검·반영 기록

## Chapter

```text
Chapter 10. 실행 계획으로 인덱스 효과 검증하기
```

## 전체 점검 범위

Chapter 10을 다음 흐름으로 다시 대조했습니다.

```text
Chapter 07·08 기준 상태
→ performance_lab 격리
→ 대량 합성 데이터 생성
→ ANALYZE
→ 후보 인덱스 없는 기준 계획
→ 실험 후보 3개 생성
→ 같은 SQL·같은 테이블 통계로 재측정
→ 결과 행·실행 계획·Buffers·시간 비교
→ 인덱스 정의·크기·사용 통계 검토
→ 최종 정합성 판정
→ 안전한 reset
```

점검 대상은 본문·구성안·워크북, Chapter 10 SQL 전체, 이미지 8쌍, 이론/실습 발표자료, 발표자 스크립트·내비게이션·TTS, 전용 GitHub Actions입니다.

---

## 1. Chapter 07·08 연속성 강화

Chapter 10은 다음 기준에서만 시작하도록 맞췄습니다.

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
course_project.enrollments.recorded_amount = NUMERIC(12,0)
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 이력 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
uq_course_enrollments_active 존재
```

본문·구성안·워크북·이론/실습 발표자료·코드 README에도 같은 기준을 직접 표시했습니다.

Chapter 10 SQL은 `course_project`를 읽기·참조만 하고 변경하지 않습니다.

---

## 2. 금액 열 이름을 `recorded_amount`로 통일

기존 Chapter 10 일부 원고와 코드에는 이전 이름인 `paid_amount`가 남아 있었습니다.

Chapter 07·08의 최종 스키마와 동일하게 다음 이름으로 원본 자체를 정리했습니다.

```text
course_project.enrollments.recorded_amount
performance_lab.enrollments.recorded_amount
```

금액 타입은 `NUMERIC(12,0)`으로 검증합니다.

`07_result_validation.sql`에는 과거 열이 실제 스키마에 남아 있지 않은지 확인하는 음성(negative) 검사만 유지했습니다.

---

## 3. PostgreSQL 16과 Skip Scan 버전 오류 수정

이번 점검에서 가장 중요한 개념 오류를 수정했습니다.

기존 설명은 `(course_id, status)` 복합 B-tree에서 선두 컬럼 조건이 없어도 PostgreSQL이 Skip Scan을 선택할 수 있다고 일반화했습니다.

최종 기준은 다음과 같습니다.

```text
자동 검증 기준 = PostgreSQL 16
PostgreSQL 16에는 B-tree Skip Scan 최적화가 없음
후행 status 단독 조건은 인덱스 전체에 가까운 탐색이 될 수 있음
현재 데이터 분포에서는 Seq Scan이 정상적이고 합리적일 수 있음
B-tree Skip Scan은 PostgreSQL 18에서 추가됨
PostgreSQL 18+에서는 동일 SQL의 계획이 달라질 수 있음
```

따라서 실습 기록에 서버 버전을 함께 남기도록 본문·워크북·이론/실습 발표자료·코드 README·발표 시작 화면까지 동기화했습니다.

---

## 4. `01_performance_lab_schema.sql` 사전 게이트 강화

`01`은 다음을 실제 검사합니다.

```text
현재 DB = ai_database_book
읽기 전용 연결 아님
course_project 핵심 4개 테이블 존재
Chapter 07·08 행 수·상태·금액 기준 일치
recorded_amount = NUMERIC(12,0)
기준 신청 1001·1004·1005 일치
활성 신청 부분 고유 인덱스 존재
performance_lab 미생성 상태
```

스키마와 네 테이블은 하나의 트랜잭션으로 생성합니다.

COMMIT 전 자동 판정:

```text
4개 테이블 존재
모두 0행
named constraints = 15
NOT NULL columns = 20
자동 인덱스 = 6
후보 인덱스 = 0
price / recorded_amount = NUMERIC(12,0)
```

통과 메시지:

```text
Chapter 10 performance lab schema validation passed
```

---

## 5. `02_performance_lab_seed.sql`을 원자적 대량 데이터 생성으로 강화

생성 결과:

```text
students      = 10003
instructors   = 2
courses       = 2003
enrollments   = 100005
```

합성 데이터는 다음을 보장합니다.

```text
생성 학생 10000명
생성 강의 2000개
생성 신청 100000건
학생별 서로 다른 강의 10개
강의별 신청 50건
활성 학생·강의 중복 0
recorded_amount = 해당 course.price
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
이메일 검색 = 1행
강의 제목 검색 = 1행
student_id 5000 = 10행
course_id 1500 = 50행
course_id 1500 + 수강중 = 15행
전체 수강중 = 30001행
```

모든 입력·IDENTITY 재시작·ANALYZE·자동 판정을 하나의 트랜잭션 안에서 처리합니다.

통과 메시지:

```text
Chapter 10 performance lab seed validation passed
```

---

## 6. IDENTITY 재현성 고정

대량 데이터가 명시적 ID를 사용하므로 다음 자동값으로 조정합니다.

```text
students.id      → 11001
instructors.id   → 203
courses.id       → 3001
enrollments.id   → 110001
```

명시적 ID 입력이 IDENTITY 다음 값을 자동으로 이동시키지 않는다는 설명도 본문·워크북·README와 동기화했습니다.

---

## 7. 기준·사후 측정 조건 통제

`03_baseline_explain.sql`과 `05_after_index_explain.sql`은 동일한 8개 SELECT를 사용합니다.

자동 정적 검증도 두 파일의 SELECT를 정규화하여 완전히 같은지 확인합니다.

공통 조건:

```text
같은 데이터
같은 8개 SQL
같은 테이블 통계
플래너 enable_seqscan/indexscan/bitmapscan = on
차이 = 실험 후보 인덱스 존재 여부
```

`02`에서 `ANALYZE`를 한 번 실행하고, `04` 후보 인덱스 생성 뒤에는 다시 `ANALYZE`하지 않습니다.

`03`은 읽기 전용이므로 데이터베이스 상태만으로 학습자가 결과를 실제 기록했는지는 증명할 수 없습니다. 따라서 학습자는 03 결과를 기록하고, 저장소 자동 검증은 실제 실행 순서를 `03 → 04`로 고정합니다.

---

## 8. 후보 인덱스 생성 안전성 강화

`04_create_candidate_indexes.sql`은 다음 세 실험 후보를 하나의 트랜잭션에서 생성합니다.

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

COMMIT 전:

```text
전체 인덱스 = 9
후보 = 3
모두 valid / ready
컬럼 순서 정확
```

을 확인합니다.

통과 메시지:

```text
Chapter 10 candidate index creation passed
```

운영 환경의 `CONCURRENTLY`는 실습 SQL과 분리해 설명하고, 트랜잭션 블록 제한·실패 후 INVALID 인덱스 확인을 안내합니다.

---

## 9. PostgreSQL 16 실제 전후 실행 계획 검증

전용 GitHub Actions에서 PostgreSQL 16.14로 실제 실행했습니다.

### 후보 생성 전

```text
강의 제목 정확 일치
→ Seq Scan / rows 1 / Rows Removed 2002

student_id = 5000 JOIN
→ enrollments Seq Scan / Rows Removed 99995

course_id = 1500
→ Seq Scan / rows 50 / Rows Removed 99955

course_id = 1500 AND status = '수강중'
→ Seq Scan / rows 15 / Rows Removed 99990

status = '수강중'
→ Seq Scan / rows 30001 / Rows Removed 70004
```

### 후보 생성 후

```text
강의 제목 정확 일치
→ Index Scan using idx_performance_courses_title

student_id = 5000 JOIN
→ Index Scan using idx_performance_enrollments_student_id

course_id = 1500
→ Bitmap Index Scan using idx_performance_enrollments_course_status

course_id = 1500 AND status = '수강중'
→ Bitmap Index Scan using idx_performance_enrollments_course_status

ORDER BY title
→ Index Scan using idx_performance_courses_title

ORDER BY title LIMIT 20
→ Limit → Index Scan using idx_performance_courses_title
```

### PostgreSQL 16의 `status` 단독 조건

복합 인덱스가 생성된 뒤에도 실제 계획은 다음과 같았습니다.

```text
Seq Scan
actual rows = 30001
Rows Removed by Filter = 70004
```

`EXPLAIN (FORMAT JSON)`에서도 `Node Type = Seq Scan`으로 확인했습니다.

이 결과가 PostgreSQL 16과 PostgreSQL 18+의 Skip Scan 설명을 분리한 실제 근거입니다.

---

## 10. 실행 시간은 보조 증거로 사용

Run 4에서 확인한 대표적인 한 번의 측정값은 다음과 같습니다.

```text
student_id 5000 JOIN
기준 약 9.590 ms → 사후 약 0.073 ms

course_id 1500
기준 약 6.906 ms → 사후 약 0.086 ms

course_id 1500 + 수강중
기준 약 6.679 ms → 사후 약 0.039 ms

ORDER BY title LIMIT 20
사후 약 0.021 ms
```

그러나 시간은 캐시·JIT·장비 부하의 영향을 받으므로 고정 정답으로 사용하지 않습니다.

최종 학습 기준은 다음을 함께 보는 것입니다.

```text
결과 행 동일성
Plan Node
Index Cond / Filter
Buffers
actual rows / loops
반복 측정 시간
운영 쓰기·공간 비용
```

---

## 11. `06_index_review.sql`과 `07_result_validation.sql` 강화

`06`은 다음을 확인합니다.

```text
전체 9개 / 후보 3개 / valid / ready
인덱스 정의
pg_stat_database.stats_reset
idx_scan / idx_tup_read / idx_tup_fetch
인덱스 크기
테이블·전체 인덱스 크기
PK·UNIQUE 역할
```

`idx_scan = 0`만으로 즉시 삭제하지 않도록 설명했습니다.

`07`은 다음을 자동 판정합니다.

```text
Chapter 07·08 기준 상태 보존
performance_lab 10003 / 2 / 2003 / 100005
상태 30002 / 30001 / 20001 / 20001
기준 조회 1 / 1 / 10 / 50 / 15 / 30001
활성 중복 = 0
금액 불일치 = 0
학생별 10건 분포 오류 = 0
강의별 50건 분포 오류 = 0
전체 인덱스 9 / 후보 3 / invalid 0
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

---

## 12. 재실행 차단과 reset 실제 검증

완료 상태에서 다음 파일을 다시 실행해 모두 의도대로 실패하는 것을 실제 확인했습니다.

```text
01 → performance_lab 기존 존재
02 → lab이 비어 있지 않음
04 → 자동 6 / 후보 0 상태가 아님
```

`reset_performance_lab.sql`은 트랜잭션으로 `performance_lab`만 삭제하고 `course_project`를 보존합니다.

실행 전 `course_project` fingerprint:

```text
cd1c890f3e9bb4a5816b5763c19fa646
```

전체 Chapter 10 실행 후와 reset 후에도 같은 fingerprint가 유지되었습니다.

reset 후 Chapter 08의 `00_check_course_project.sql`과 `03_join_aggregation_validation.sql`도 다시 통과했습니다.

---

## 13. 발표자료·내비게이션·TTS·이미지 동기화

자동 검증으로 확인한 항목:

```text
이론 계획 20장
실습 계획 20장
각 절 화면 구성 + 발표 스크립트 존재
내비게이션 제목 40개 연결
JavaScript 문법
발표 자산 버전 = 20260809a
공통 TTS normalization
script_content_enhancer
Mermaid 8개 + SVG 8개 일치
SVG role=img / width=100% / viewBox / title / desc
본문 그림 연결
```

발표 첫 화면에도 PostgreSQL 16 검증 기준과 PostgreSQL 18+ Skip Scan 차이를 표시했습니다.

---

## 14. 검증 과정에서 발견한 문제와 수정

### Run 1

구성안에 실제 컬럼 `recorded_amount`가 직접 연결되지 않은 **문서 정합성 문제**를 발견했습니다.

→ 본문·구성안·워크북·이론/실습 자료에 실제 스키마와 Chapter 07·08 기준값을 명시했습니다.

### Run 2

validator가 설명 주석의 `CREATE INDEX CONCURRENTLY`를 실제 네 번째 인덱스 생성문으로 오인했습니다.

→ 실행문처럼 보이지 않도록 주석을 고치고, validator도 주석을 제거한 SQL만 검사하도록 수정했습니다.

### Run 3

`01`·`02` SQL은 실제로 성공했지만 `RAISE NOTICE`가 stderr에 출력되어 stdout-only 로그 검색이 실패했습니다.

→ stdout+stderr를 함께 캡처하도록 validator를 보완했습니다.

### Run 4

정적 검증부터 PostgreSQL 실제 실행·전후 계획·재실행 차단·reset까지 전체 성공했습니다.

```text
Workflow: Validate Chapter 10
Run: 4
Run ID: 31285494158
Commit: 76dc98e36fae6b717a2910a2b277c0e94238235c
Conclusion: success
PostgreSQL: 16.14
```

상세 결과는 `notes/chapter10_validation_result.md`에 기록했습니다.

---

## 15. 자동 검증과 별도인 수동 확인

다음은 브라우저·출력 환경에서 별도 확인합니다.

```text
이론 20장 / 실습 20장 최종 시각 렌더링
단계별 강조 실제 시각 동작
발표자 스크립트 창 ↔ 장표 창 실제 동기화
TTS 실제 음성 청취·발음
모바일·프로젝터 가독성
Mermaid CLI 재생성
GitHub SVG 실제 시각 렌더링
Word·PDF·eBook 표·코드·SVG 최종 출력
```

## 결론

```text
Chapter 10은 인덱스를 무조건 추가하는 실습이 아니라,
PostgreSQL 버전·기준 데이터·통계·SQL을 통제한 상태에서
실제 실행 계획과 결과를 비교하고 운영 비용까지 고려해
적용·보류·제거 근거를 만드는 성능 검증 장으로 보완되었다.
```
