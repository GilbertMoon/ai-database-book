# Chapter 08 2차 재구성 반영 기록

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
images/chapter08/README.md
notes/chapter08_review_checklist.md
README.md
```

## 목적

Chapter 08을 별도 데이터셋을 다시 만드는 장에서 **Chapter 07의 실제 프로젝트 데이터를 그대로 조회하고 검산하는 장**으로 재구성한다.

```text
업무 질문
→ 기준 행
→ JOIN 경로·종류
→ ON·WHERE 조건
→ 집계 대상
→ NULL·중복 처리
→ 상세·그룹 결과 검산
→ AI SQL 검토
```

---

## 1. 제목 변경

```text
기존: JOIN과 집계 쿼리
변경: JOIN과 집계로 서비스 질문에 답하기
```

---

## 2. Chapter 07 데이터 연속성

기존 Chapter 08은 `public`의 네 테이블을 삭제하고 4/3/4/5행 전용 데이터를 다시 생성했다.

변경 후에는 다음 Chapter 07 최종 상태만 사용한다.

```text
course_project.students 3
course_project.instructors 2
course_project.courses 3
course_project.enrollments 5
```

```text
전체 신청 5
전체 저장 금액 590000
평균 118000
취소 제외 신청 4
취소 제외 금액 440000
```

---

## 3. 강화한 내용

| 항목 | 반영 내용 |
| --- | --- |
| 질문 정의 | 결과 한 행·상태·0건 포함·집계 대상을 먼저 결정 |
| 기준 행 | 신청 한 건과 학생·강의 한 개 결과 구분 |
| ON·WHERE | LEFT JOIN 오른쪽 조건 위치 차이 추가 |
| anti-join | LEFT JOIN IS NULL과 NOT EXISTS 비교 |
| COUNT | `COUNT(*)`, `COUNT(e.id)`, `COUNT(DISTINCT ...)` 구분 |
| 조건부 집계 | PostgreSQL `FILTER` 추가 |
| 과대 집계 | 여러 1:N JOIN에서 DISTINCT 필요성 설명 |
| 금액 정의 | 전체·취소 제외·실제 매출 구분 |
| 검산 | 상세·상태별·강의별 건수와 금액 대조 |
| AI 검토 | 누락·과대 계산·조건 위치·금액 정의 검토 |

---

## 4. SQL 구조 변경

### 기존

```text
join_aggregation_practice.sql
- 자동 DROP
- SERIAL 테이블 생성
- Chapter 08 별도 데이터 입력
- 조회와 집계 혼합
```

### 변경

```text
00_check_course_project.sql
- Chapter 07 최종 상태 확인

01_join_queries.sql
- INNER·다중·LEFT JOIN
- ON/WHERE 차이
- LEFT JOIN IS NULL·NOT EXISTS

02_aggregation_queries.sql
- 기본 집계·GROUP BY·FILTER·HAVING
- 강의·강사·학생별 집계

03_join_aggregation_validation.sql
- 상세·그룹 건수와 금액 검산

join_aggregation_practice.sql
- 읽기 전용 호환 진입점
```

모든 Chapter 08 SQL에서 CREATE·INSERT·UPDATE·DELETE·DROP을 제거했다.

---

## 5. 핵심 예상 결과

```text
상태별 건수: 신청 2 / 수강중 1 / 완료 1 / 취소 1
강의 301 취소 제외: 2건 / 200000
강의 302 취소 제외: 2건 / 240000
강의 303 취소 제외: 0건 / 0
취소 제외 신청 없는 학생: 박서연
취소 제외 신청 2건 이상 강의: 301, 302
```

---

## 6. 도식 처리

기존 8개 SVG 자산은 유지한다.

새 본문에서는 Chapter 07 최종 데이터와 충돌하지 않는 네 도식만 사용한다.

```text
JOIN 필요성
다중 JOIN 경로
WHERE·GROUP BY·HAVING 논리 흐름
AI SQL 검토 흐름
```

4/3/4 전용 데이터의 이름·행 수를 직접 표시하는 기존 도식은 새 본문에서 제외하고 자산으로만 유지한다.

---

## 7. 남은 확인 항목

```text
- 실제 PostgreSQL에서 Chapter 07 최종 상태 확인
- Chapter 08 네 파일 순서 실행
- 5·590000 및 4·440000 검산
- FILTER 지원과 결과 타입 확인
- GitHub·PDF·Word·eBook 렌더링 확인
- Chapter 09가 course_project 연속성을 유지하는지 확인
```

---

## 8. 최종 상태

```text
Chapter 08 본문, 워크북, 구성안과 조회 전용 SQL 구조를 2차 재구성했다.
Chapter 07 데이터를 삭제·재생성하지 않고 실제 프로젝트 질문에 답하도록 변경했다.
원격 main에 변경을 직접 반영했다.
```
