# Chapter 08 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter08/chapter08.md
book/chapter08/chapter08_activity.md
book/chapter08/chapter08_outline.md
code/chapter08/00_check_course_project.sql
code/chapter08/01_join_queries.sql
code/chapter08/02_aggregation_queries.sql
code/chapter08/03_join_aggregation_validation.sql
code/chapter08/join_aggregation_practice.sql
code/chapter08/README.md
notes/chapter08_review_checklist.md
README.md
```

## 검수 목적

Chapter 08을 Chapter 07의 최종 프로젝트 데이터를 안전하게 읽고, 명확한 상태 범위와 기준 행을 바탕으로 JOIN·집계·검산을 수행하는 장으로 최종 보완했습니다.

```text
사전 조건 검사
→ 업무 질문과 상태 범위
→ 기준 행
→ JOIN 경로·종류
→ ON·WHERE 조건
→ 집계 대상과 NULL 처리
→ 상태 업무 순서
→ 과대 집계 검토
→ 전체·활성·취소 제외 검산
```

---

## 1. Chapter 07 사전 조건 검사 강화

`00_check_course_project.sql`은 다음 내용을 실제로 검사합니다.

```text
current_database() = ai_database_book
course_project 테이블 4개 존재
students = 3
instructors = 2
courses = 3
enrollments = 5
전체 기록 금액 = 590000
활성 신청 = 3 / 340000
취소 제외 신청 이력 = 4 / 440000
```

조건이 맞지 않으면 읽기 전용 `DO` 블록에서 예외를 발생시켜 실행을 중단합니다.

Chapter 07 무결성 테스트의 임시 행이 남아 있을 가능성과 선택적 기준 상태 복원 절차도 본문·워크북·코드 README에 추가했습니다.

---

## 2. 실행 위치 기준 통일

모든 Chapter 08 SQL 파일에 다음을 적용했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

모든 객체는 `course_project.students`처럼 스키마 한정 이름을 사용하므로 `current_schema()`가 `course_project`일 필요는 없음을 설명했습니다.

---

## 3. 상태 분석 범위 구분

Chapter 07과 동일한 용어를 사용하도록 범위를 구분했습니다.

| 범위 | 상태 | 건수 | 기록 금액 |
| --- | --- | ---: | ---: |
| 전체 신청 이력 | 모든 상태 | 5 | 590000 |
| 활성 신청 | 신청, 수강중 | 3 | 340000 |
| 취소 제외 신청 이력 | 신청, 수강중, 완료 | 4 | 440000 |
| 취소 신청 | 취소 | 1 | 150000 |

기존 `status = '수강중' AS active_count`는 Chapter 07의 활성 신청 정의와 충돌했습니다. 다음처럼 변경했습니다.

```text
requested_count = 신청
learning_count = 수강중
active_enrollment_count = 신청 + 수강중
```

---

## 4. 기록 금액 표현 통일

자연어 표현을 다음 기준으로 정리했습니다.

```text
recorded_amount
→ 신청 당시 기록 금액

전체·활성·취소 제외 기록 금액
→ 분석 범위별 저장값 합계

실제 매출
→ 결제 성공·환불·매출 인식 정책이 추가로 필요한 값
```

취소 신청에도 기록 금액이 남을 수 있으므로 이를 실제 결제 완료액이나 회계 매출로 단정하지 않습니다.

---

## 5. AVG 표시 형식 보완

Chapter 07의 `recorded_amount`는 `NUMERIC(12,0)`이며 PostgreSQL의 `AVG(recorded_amount)`는 `numeric`을 반환하므로 DBeaver에서 소수점 이하 0이 길게 표시될 수 있습니다.

예제 SQL을 다음처럼 통일했습니다.

```sql
ROUND(AVG(recorded_amount), 2)
```

기대값은 전체 `118000.00`, 취소 제외 `110000.00`입니다.

---

## 6. 상태 순서 명시

기존 `ORDER BY status`는 서비스의 상태 순서를 보장하지 않았습니다. 다음 `CASE` 정렬을 본문과 SQL 파일에 적용했습니다.

```sql
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END
```

---

## 7. 집계 함수의 NULL 규칙 보완

다음 원칙을 본문·워크북·코드 README에 추가했습니다.

```text
COUNT(*)와 COUNT(column)
→ 빈 입력에서 0

SUM·AVG·MIN·MAX
→ 빈 입력에서 NULL 가능
```

`COALESCE(..., 0)`는 데이터 없음과 숫자 0을 같은 업무 표현으로 처리해도 될 때만 사용하도록 제한했습니다.

---

## 8. 과대 집계 실제 사례 추가

강의와 신청을 JOIN한 뒤 `SUM(c.price)`를 계산하면 강의 가격이 신청 수만큼 반복되는 사례를 추가했습니다.

```text
SUM(DISTINCT c.price)
```

역시 서로 다른 강의의 가격이 같을 때 한 번만 합산할 수 있으므로 일반 해결책이 아님을 설명했습니다. 합산할 기준 행인 `courses` 수준에서 먼저 계산하도록 수정 방향을 제시했습니다.

---

## 9. 검산 기준 확대

기존 검산값에 활성 신청을 추가했습니다.

```text
전체 신청 이력: 5 / 590000
활성 신청: 3 / 340000
취소 제외 신청 이력: 4 / 440000
INNER JOIN 결과: 5행
고아 관계: 0행
```

`03_join_aggregation_validation.sql`에서도 상세 기준과 그룹 기준을 대조합니다.

---

## 10. JOIN 범위 명시

이 장은 `INNER JOIN`과 `LEFT JOIN`에 집중하도록 범위를 명확히 했습니다.

```text
RIGHT JOIN
FULL OUTER JOIN
CROSS JOIN
```

위 JOIN은 입문 프로젝트 범위에서 제외하며 `RIGHT JOIN`의 많은 사례는 테이블 순서를 바꾼 `LEFT JOIN`으로 표현할 수 있음을 안내했습니다.

---

## 11. 자기주도 학습 보완

본문과 워크북에 다음 내용을 추가했습니다.

- 사전 상태 오류와 복원 기록
- 전체·활성·취소 제외 범위 비교
- `learning_count`와 활성 신청 구분
- 집계 함수 NULL 표
- 상태 `CASE` 순서
- 평균 표시 형식
- 과대 금액 집계 수정
- 전체·활성·취소 제외 검산
- 개념·SQL 권장 해설

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 사전 조건 실제 차단 | 완료 |
| `SHOW search_path` 통일 | 완료 |
| Chapter 07 활성 신청 용어 동기화 | 완료 |
| 전체·활성·취소 제외 범위 구분 | 완료 |
| 상태 업무 순서 명시 | 완료 |
| 기록 금액 표현 통일 | 완료 |
| AVG 표시 형식 | 완료 |
| 집계 함수 NULL 규칙 | 완료 |
| 과대 금액 집계 사례 | 완료 |
| 활성 신청 검산 | 완료 |
| 임시 데이터 복구 안내 | 완료 |
| 권장 해설 | 완료 |

## 결론

```text
Chapter 08은 JOIN과 집계 문법을 소개하는 장을 넘어,
Chapter 07 기준 상태·상태 범위·기준 행·NULL·중복·금액 의미를
명시하고 상세 결과와 집계 결과를 대조하는 검증 장으로 최종 보완되었다.
```

실제 PostgreSQL에서 Chapter 07 기준 복원 후 `00 → 01 → 02 → 03` 전체 순차 실행과 출판 렌더링은 별도 제작 단계에서 확인합니다.
