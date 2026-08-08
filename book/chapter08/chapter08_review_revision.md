# Chapter 08 전체 점검·반영 기록

## Chapter

```text
Chapter 08. JOIN과 집계로 서비스 질문에 답하기
```

## 전체 점검 범위

Chapter 08을 다음 연결로 다시 대조했습니다.

```text
Chapter 07 최종 상태
→ 분석 범위 정의
→ 결과 한 행의 기준
→ PK·FK JOIN 경로
→ INNER / LEFT JOIN
→ ON / WHERE 조건 위치
→ anti-join
→ COUNT 대상
→ SUM·AVG·NULL
→ GROUP BY·FILTER·HAVING
→ 과대 집계
→ 자동 검산
→ Chapter 09 인계
```

점검 대상:

```text
book/chapter08/chapter08.md
book/chapter08/chapter08_outline.md
book/chapter08/chapter08_activity.md
book/chapter08/chapter08_review_revision.md
notes/chapter08_review_checklist.md

code/chapter08/00_check_course_project.sql
code/chapter08/01_join_queries.sql
code/chapter08/02_aggregation_queries.sql
code/chapter08/03_join_aggregation_validation.sql
code/chapter08/join_aggregation_practice.sql
code/chapter08/README.md

images/chapter08/*.mmd
images/chapter08/*.svg
images/chapter08/README.md

presentation/chapter08/chapter08_theory_lecture_plan.md
presentation/chapter08/chapter08_practice_lecture_plan.md
presentation/chapter08/chapter08_slides.js
presentation/chapter08/chapter08_navigation.js
presentation/chapter08/chapter08_player.js
presentation/chapter08/chapter08_script.html
presentation/chapter08/chapter08_script.js
presentation/chapter08/chapter08_theory_presentation.html
presentation/chapter08/chapter08_practice_presentation.html
presentation/chapter08/index.html

.github/workflows/validate-chapter08.yml
```

---

## 1. 가장 큰 정합성 문제: `paid_amount` 구용어

Chapter 07의 현재 스키마는 다음과 같습니다.

```text
course_project.enrollments.recorded_amount NUMERIC(12,0)
```

그러나 Chapter 08의 본문·워크북·구성안·이론 발표자료와 일부 Mermaid/SVG에는 과거 `paid_amount`가 남아 있었습니다. 본문의 SQL 예제를 그대로 실행하면 현재 Chapter 07 스키마에서 컬럼 오류가 발생할 수 있는 상태였습니다.

이번 점검에서 Chapter 08 범위의 구용어를 다음처럼 통일했습니다.

```text
paid_amount
→ recorded_amount

결제금액
→ 기록 금액
```

금액 의미도 다음으로 고정했습니다.

```text
courses.price
→ 현재 강의 기준 가격

enrollments.recorded_amount
→ 신청 시점에 신청 행에 기록한 금액
```

`recorded_amount`는 실제 결제 승인액·환불 후 금액·회계 매출이 아닙니다.

---

## 2. Chapter 07 사전 조건 게이트 강화

`00_check_course_project.sql`을 단순 행 수 검사에서 Chapter 07 최종 상태 자동 게이트로 강화했습니다.

자동 확인:

```text
current_database = ai_database_book
네 테이블 존재
uq_course_enrollments_active 존재
recorded_amount = NUMERIC(12,0)
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 = 5 / 590000 / 평균 118000.00
활성 = 3 / 340000
취소 제외 = 4 / 440000
고아 관계 = 0 / 0 / 0
활성 중복 = 0
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

통과 메시지:

```text
Chapter 08 prerequisite check passed
```

기준 상태가 다르면 JOIN·집계 실습으로 넘어가지 않고 예외로 중단합니다.

---

## 3. 분석 범위를 세 가지로 고정

Chapter 07과 같은 용어를 사용합니다.

| 범위 | 상태 | 건수 | recorded_amount |
| --- | --- | ---: | ---: |
| 전체 신청 이력 | 모든 상태 | 5 | 590000 |
| 활성 신청 | 신청, 수강중 | 3 | 340000 |
| 취소 제외 신청 이력 | 신청, 수강중, 완료 | 4 | 440000 |
| 취소 신청 | 취소 | 1 | 150000 |

`수강중`만 세는 값은 `learning_count`이며, `active_enrollment_count`는 `신청 + 수강중`입니다.

---

## 4. JOIN의 기준 행과 경로

결과 한 행의 의미를 먼저 정하도록 본문·워크북·발표자료를 맞췄습니다.

```text
enrollments.student_id → students.id
enrollments.course_id  → courses.id
courses.instructor_id   → instructors.id
```

신청 현황의 기준 행은 `enrollments` 한 건입니다. 따라서 INNER JOIN 후 학생 이름·강의 제목·강사 이름이 붙어도 기준 행은 그대로 신청 한 건이며 결과는 5행입니다.

정상적인 1:N 반복을 지우기 위해 무조건 `DISTINCT`를 추가하지 않도록 설명합니다.

---

## 5. LEFT JOIN의 ON·WHERE 차이

취소 제외 신청이 없는 학생도 유지하는 질문을 기준으로 차이를 명확히 했습니다.

```text
ON에 e.status <> '취소'
→ 학생 3명 유지
→ 박서연 포함 / 신청 0건

WHERE에 e.status <> '취소'
→ NULL 확장 행 제거
→ 학생 2명
→ 박서연 제외
```

`LEFT JOIN ... IS NULL`과 `NOT EXISTS`는 현재 기준 데이터에서 모두 박서연 1명을 반환합니다.

---

## 6. COUNT 대상과 LEFT JOIN 0건

다음 세 값을 구분합니다.

```text
COUNT(*)
→ JOIN 결과 행 수

COUNT(e.id)
→ 실제 연결된 신청 행 수

COUNT(DISTINCT e.student_id)
→ 고유 학생 수
```

강의 303은 취소 제외 신청이 없으므로:

```text
LEFT JOIN 결과 행 = 1
COUNT(*) = 1
COUNT(e.id) = 0
고유 학생 = 0
recorded_amount = 0
```

이 사례를 통해 `COUNT(*)`를 무조건 “자식 건수”로 읽지 않도록 정리했습니다.

---

## 7. 집계·NULL·평균

Chapter 07의 현재 타입에 맞춰 AVG 설명도 수정했습니다.

```text
recorded_amount = NUMERIC(12,0)
AVG(recorded_amount) = numeric
```

예제 표시:

```sql
ROUND(AVG(recorded_amount), 2)
```

기준값:

```text
전체 평균 = 118000.00
취소 제외 평균 = 110000.00
```

빈 입력에서는 다음 차이를 설명합니다.

```text
COUNT(*) / COUNT(column) → 0
SUM / AVG / MIN / MAX   → NULL 가능
```

`COALESCE(..., 0)`는 데이터 없음과 0을 같은 업무 의미로 표시해도 될 때만 사용합니다.

---

## 8. GROUP BY·FILTER·HAVING

상태의 업무 순서는 문자열 정렬에 맡기지 않고 다음 순서를 명시합니다.

```text
신청 → 수강중 → 완료 → 취소
```

`FILTER`에서는 다음 의미를 분리합니다.

```text
requested_count = 신청
learning_count = 수강중
active_enrollment_count = 신청 + 수강중
completed_count = 완료
cancelled_count = 취소
```

`WHERE`는 그룹 전 개별 행 필터, `HAVING`은 그룹 후 집계 결과 필터로 설명합니다.

---

## 9. 과대 집계 보완

연속된 1:N JOIN에서는 상위 행이 반복될 수 있습니다.

```text
강사 1:N 강의 1:N 신청
```

강의와 신청을 JOIN한 뒤 `SUM(c.price)`를 실행하면 강의 가격이 신청 수만큼 반복되어 과대 합산될 수 있습니다.

`SUM(DISTINCT c.price)`도 서로 다른 강의가 같은 가격이면 한 번만 더할 수 있으므로 일반적인 해결책이 아닙니다.

질문의 기준 행이 강의라면 강의 수준에서 먼저 집계하도록 설명합니다.

---

## 10. `03_join_aggregation_validation.sql` 자동 완료 게이트

기존 03 파일은 검산용 SELECT를 보여 주는 역할이 중심이었습니다. 이번 점검에서 **실제 자동 판정 파일**로 강화했습니다.

자동 확인:

```text
상세 신청 = 5
상태별 건수 합 = 5
상세 recorded_amount = 590000
강의별 recorded_amount 합 = 590000
활성 상세·그룹 = 3 / 340000
취소 제외 상세·강의별 = 4 / 440000
INNER JOIN = 5
고아 관계 = 0 / 0 / 0
anti-join 두 방식 = 각각 1
ON 조건 학생 = 3
WHERE 조건 학생 = 2
강의 301 = 2건 / 2명 / 200000
강의 302 = 2건 / 2명 / 240000
강의 303 = LEFT JOIN 1행 / 실제 신청 0 / 학생 0 / 금액 0
강사 201 = 강의 2 / 신청 4 / 취소 제외 4
강사 202 = 강의 1 / 신청 1 / 취소 제외 0
```

통과 메시지:

```text
Chapter 08 join and aggregation validation passed
```

---

## 11. 조회 전용 원칙 강화

Chapter 08의 다음 파일은 모두 조회 전용입니다.

```text
00_check_course_project.sql
01_join_queries.sql
02_aggregation_queries.sql
03_join_aggregation_validation.sql
join_aggregation_practice.sql
```

전용 GitHub Actions에서는 DML·DDL 키워드가 실제 SQL 문장에 없는지 정적으로 확인하고, PostgreSQL의 `BEGIN TRANSACTION READ ONLY` 안에서 전체 파일을 실행해 조회 전용성을 검증하도록 구성했습니다.

---

## 12. 발표자료·스크립트

이론 20장 / 실습 20장 구조를 유지합니다.

보완:

```text
발표 강의안의 paid_amount 제거
실습 장표에 recorded_amount 실제 열 이름 표시
03 자동 완료 게이트와 통과 메시지 연결
자산 버전 = 20260809a
공통 TTS normalization 유지
script_content_enhancer 유지
스크립트 ↔ 장표 postMessage 동기화 유지
새 발표 창에도 동일 자산 버전 전달
```

Markdown 강의안이 발표 장표의 실제 소스이므로 런타임 치환에 의존하지 않고 원본 자체를 현재 용어로 유지합니다.

---

## 13. 이미지·도식

Mermaid 8개와 SVG 8개 쌍을 유지합니다.

현재 본문 사용:

```text
ch08_01_join_why_needed
ch08_03_multi_table_join_path
ch08_07_where_group_having_order
ch08_08_ai_join_sql_review_flow
```

01·03 도식에 남아 있던 `paid_amount`를 `recorded_amount`로 수정했습니다. 06 도식의 `결제금액` 표현도 `기록 금액`으로 수정했습니다.

`ch08_06_course_revenue_summary` 파일명은 기존 링크 호환을 위해 유지하지만, 현재 표시 의미는 실제 회계 매출이 아니라 기록 금액 집계입니다.

---

## 14. 전용 자동 검증

새 파일:

```text
.github/workflows/validate-chapter08.yml
```

검증 범위:

```text
JavaScript 문법
본문 23개 절
이론 20 / 실습 20
화면 구성·발표 스크립트 존재
paid_amount 잔존 차단
recorded_amount·기준값 정합성
발표 자산 버전·TTS·스크립트 연결
조회 SQL의 DML·DDL 부재
Mermaid/SVG 8쌍과 SVG 접근성
PostgreSQL 16에서 Chapter 07 기준 상태 생성
잘못된 DB의 00 차단
Chapter 08 전체 READ ONLY 실행
실행 전후 데이터 불변
00 기준 상태 드리프트 차단
03 집계 드리프트 차단
최종 5/590000, 3/340000, 4/440000 재검산
```

실제 Actions 실행 결과는 `notes/chapter08_validation_result.md`에 별도로 기록합니다.

---

## 수동 확인으로 남는 범위

자동 검증과 별개로 다음은 실제 출력 환경에서 확인합니다.

```text
브라우저 이론/실습 최종 렌더링
단계별 강조와 발표자 창 동기화 실제 조작
TTS 실제 청취
SVG 화면 가독성
모바일·프로젝터 가독성
Word·PDF·eBook 표·코드·SVG 렌더링
```
