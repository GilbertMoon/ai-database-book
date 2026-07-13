# Chapter 08 구성안

## 제목

JOIN과 집계로 서비스 질문에 답하기

## 권장 분량

22~26페이지

## 이 장의 역할

Chapter 07의 `course_project` 최종 데이터를 그대로 사용해, 정규화된 테이블을 실제 PK·FK 관계로 연결하고 업무 질문에 맞게 집계한다.

문법 소개에 머물지 않고 다음 판단 흐름을 강조한다.

```text
업무 질문
→ 결과 한 행의 기준
→ 포함할 상태와 누락 대상
→ JOIN 경로와 종류
→ 집계 대상
→ NULL·중복 처리
→ 원본 기준값과 검산
```

## 핵심 질문

```text
결과 한 행은 학생·신청·강의 중 무엇인가?
연결되지 않은 부모도 결과에 포함해야 하는가?
취소 신청을 포함할 것인가?
신청 건수와 고유 학생 수 중 무엇을 구하는가?
LEFT JOIN의 오른쪽 조건은 ON과 WHERE 중 어디에 있어야 하는가?
JOIN으로 행이 늘어난 뒤 집계가 과대 계산되지 않았는가?
상세 합계와 그룹 합계가 일치하는가?
```

## 독자가 얻게 될 것

- 실제 FK 경로를 따라 여러 테이블을 JOIN할 수 있다.
- 결과 한 행의 기준을 설명할 수 있다.
- `INNER JOIN`과 `LEFT JOIN`의 포함 범위를 구분할 수 있다.
- 외부 JOIN에서 `ON`과 `WHERE` 조건 차이를 설명할 수 있다.
- `LEFT JOIN ... IS NULL`과 `NOT EXISTS`로 연결되지 않은 대상을 찾을 수 있다.
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT column)`을 구분할 수 있다.
- `SUM`, `AVG`, `MIN`, `MAX`, `COALESCE`를 사용할 수 있다.
- `GROUP BY`, `HAVING`과 PostgreSQL `FILTER`를 사용할 수 있다.
- 여러 1:N JOIN에서 부모 수나 금액이 과대 계산될 가능성을 검토할 수 있다.
- 상세 데이터, 그룹 결과와 원본 기준값을 대조할 수 있다.
- AI가 만든 JOIN·집계 SQL의 누락과 과대 집계를 검토할 수 있다.

## 핵심 기준 데이터

Chapter 07 최종 상태를 그대로 사용한다.

```text
course_project.students = 3행
course_project.instructors = 2행
course_project.courses = 3행
course_project.enrollments = 5행
```

```text
상태별 건수
신청 2
수강중 1
완료 1
취소 1
```

```text
전체 저장 결제금액 = 590000
전체 평균 결제금액 = 118000
취소 제외 신청 = 4
취소 제외 결제금액 = 440000
```

## 핵심 개념

- 기준 행
- FK JOIN 경로
- INNER JOIN
- LEFT JOIN
- 다중 JOIN
- 테이블 별칭
- ON 조건
- WHERE 조건
- NULL 확장 행
- anti-join
- NOT EXISTS
- COUNT
- DISTINCT
- SUM
- AVG
- MIN
- MAX
- GROUP BY
- HAVING
- COALESCE
- FILTER
- 과대 집계
- 검산
- AI SQL 검토

## 본문 구성

1. Chapter 07 최종 데이터와 실행 파일
2. SQL 작성 전 업무 질문 정의
3. ERD의 관계 경로 확인
4. INNER JOIN과 신청 기준 결과
5. 다중 JOIN
6. LEFT JOIN과 NULL
7. ON과 WHERE 조건 차이
8. 연결되지 않은 대상 찾기
9. 기본 집계 기준값
10. GROUP BY
11. COUNT 대상 비교
12. FILTER 조건부 집계
13. 강의별 신청·금액 집계
14. WHERE와 HAVING
15. 강사별 다단계 집계와 DISTINCT
16. 상세·집계 결과 검산
17. DISTINCT 오용 방지
18. AI SQL 검토
19. 자주 하는 실수
20. 스스로 확인하기
21. 핵심 정리
22. 다음 장 연결

## 코드 파일 구성

```text
code/chapter08/
├── 00_check_course_project.sql
├── 01_join_queries.sql
├── 02_aggregation_queries.sql
├── 03_join_aggregation_validation.sql
├── join_aggregation_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `00_check_course_project.sql` | Chapter 07 스키마·행 수·상태 기준 확인 |
| `01_join_queries.sql` | INNER·다중·LEFT JOIN, ON/WHERE, NOT EXISTS |
| `02_aggregation_queries.sql` | 기본 집계, GROUP BY, FILTER, 강의·강사 집계 |
| `03_join_aggregation_validation.sql` | 상세·그룹 건수와 금액 검산 |
| `join_aggregation_practice.sql` | 기존 링크 호환용 읽기 전용 핵심 쿼리 |

## 안전성 원칙

- Chapter 08에서 테이블·스키마를 삭제하거나 다시 생성하지 않는다.
- Chapter 07 최종 데이터를 읽기만 한다.
- 모든 테이블 이름에 `course_project` 스키마를 명시한다.
- 데이터 변경 SQL을 포함하지 않는다.
- 별도 Chapter 08 데이터셋을 만들지 않는다.
- 결과가 다르면 먼저 Chapter 07 실행 상태를 확인한다.

## 분석 기준

이 장에서는 다음 표현을 명시적으로 구분한다.

```text
전체 신청 = 모든 enrollments 행
취소 제외 신청 = status <> '취소'
저장 결제금액 합계 = paid_amount의 합
실제 매출 = 결제·환불·매출 인식 정책이 추가로 필요한 값
```

## 워크북 구성

- 기준 데이터 기록
- 업무 질문 구체화
- JOIN 경로 작성
- INNER·다중 JOIN 결과 기록
- LEFT JOIN NULL 해석
- ON·WHERE 비교
- NOT EXISTS 비교
- 기본 집계 기준값
- 상태별 GROUP BY 검산
- COUNT 세 종류 비교
- FILTER 조건부 집계
- 강의·강사별 집계
- 상세·집계 검산
- AI SQL 수정
- 직접 SQL 작성

## 도식 사용

새 본문에서는 데이터셋과 충돌하지 않는 네 도식을 사용한다.

```text
그림 8-1 JOIN이 필요한 이유
그림 8-2 다중 JOIN 경로
그림 8-3 WHERE·GROUP BY·HAVING 논리 흐름
그림 8-4 AI SQL 검토 흐름
```

기존 데이터별 행 수를 표시한 INNER·LEFT·GROUP BY·강의별 집계 도식은 자산으로 유지하되 새 본문에서는 사용하지 않는다.

## AI 활용 원칙

- 질문 정의와 상태 포함 기준을 프롬프트에 명시한다.
- 결과 한 행 기준과 FK 경로를 설명하도록 요청한다.
- LEFT JOIN의 조건 위치와 COUNT 대상을 설명하도록 요청한다.
- 예상 결과와 검산 SQL을 함께 요구한다.
- 전체 5건·590000, 취소 제외 4건·440000으로 검증한다.
- `DISTINCT`로 중복 원인을 숨기지 않는지 확인한다.

## 다음 장 연결

Chapter 09에서는 `course_project` 데이터를 바탕으로 여러 변경 작업을 하나의 업무 단위로 처리하는 트랜잭션과 데이터 정합성을 다룬다.
