# Chapter 08 구성안

## 제목

JOIN과 집계로 서비스 질문에 답하기

## 권장 분량

24~28페이지

## 이 장의 역할

Chapter 07의 `course_project` 최종 데이터를 그대로 사용해 정규화된 테이블을 실제 PK·FK 관계로 연결하고 업무 질문에 맞게 집계한다.

문법 소개에 머물지 않고 다음 판단 흐름을 강조한다.

```text
사전 기준 상태 확인
→ 업무 질문
→ 결과 한 행의 기준
→ 전체·활성·취소 제외 상태 범위
→ JOIN 경로와 종류
→ ON·WHERE 조건
→ 집계 대상과 NULL 처리
→ 업무 순서 정렬
→ 과대 집계 점검
→ 원본 기준값과 검산
```

## 핵심 질문

```text
Chapter 07 기준 데이터가 정확히 준비되었는가?
결과 한 행은 학생·신청·강의 중 무엇인가?
전체 신청, 활성 신청과 취소 제외 신청 이력 중 어떤 범위인가?
연결되지 않은 부모도 결과에 포함해야 하는가?
신청 건수와 고유 학생 수 중 무엇을 구하는가?
LEFT JOIN의 오른쪽 조건은 ON과 WHERE 중 어디에 있어야 하는가?
집계 함수가 NULL을 어떻게 처리하는가?
JOIN으로 행이 늘어난 뒤 값과 금액이 과대 계산되지 않았는가?
상태 결과를 어떤 업무 순서로 보여 줄 것인가?
상세 합계와 그룹 합계가 일치하는가?
```

## 독자가 얻게 될 것

- `00_check_course_project.sql`로 프로젝트 기준 상태를 확인할 수 있다.
- 모든 객체에 스키마를 명시하고 `SHOW search_path`를 확인할 수 있다.
- 실제 FK 경로를 따라 여러 테이블을 JOIN할 수 있다.
- 결과 한 행의 기준을 설명할 수 있다.
- `INNER JOIN`과 `LEFT JOIN`의 포함 범위를 구분할 수 있다.
- 외부 JOIN에서 `ON`과 `WHERE` 조건 차이를 설명할 수 있다.
- `LEFT JOIN ... IS NULL`과 `NOT EXISTS`로 연결되지 않은 대상을 찾을 수 있다.
- 전체 신청 이력, 활성 신청과 취소 제외 신청 이력을 구분할 수 있다.
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT column)`을 구분할 수 있다.
- `SUM`, `AVG`, `MIN`, `MAX`, `COALESCE`를 사용할 수 있다.
- 집계 함수의 NULL 처리와 빈 입력 결과를 설명할 수 있다.
- `GROUP BY`, `HAVING`과 PostgreSQL `FILTER`를 사용할 수 있다.
- `CASE`로 상태의 업무 순서를 명시할 수 있다.
- 여러 1:N JOIN에서 부모 수나 금액이 과대 계산될 가능성을 검토할 수 있다.
- 상세 데이터, 그룹 결과와 원본 기준값을 대조할 수 있다.
- AI가 만든 JOIN·집계 SQL의 누락, 용어 충돌과 과대 집계를 검토할 수 있다.

## 핵심 기준 데이터

Chapter 07 최종 상태를 그대로 사용한다.

```text
course_project.students = 3행
course_project.instructors = 2행
course_project.courses = 3행
course_project.enrollments = 5행
```

| 분석 범위 | 상태 | 건수 | 기록 금액 |
| --- | --- | ---: | ---: |
| 전체 신청 이력 | 모든 상태 | 5 | 590000 |
| 활성 신청 | 신청, 수강중 | 3 | 340000 |
| 취소 제외 신청 이력 | 신청, 수강중, 완료 | 4 | 440000 |
| 취소 신청 | 취소 | 1 | 150000 |

```text
전체 평균 기록 금액 = 118000.00
취소 제외 평균 기록 금액 = 110000.00
```

`recorded_amount`는 신청 당시 기록 금액이며 결제 성공, 환불과 회계 매출을 의미하지 않는다.

## 핵심 개념

- 실행 사전 조건
- 기준 데이터 복원
- 기준 행
- FK JOIN 경로
- `INNER JOIN`
- `LEFT JOIN`
- 다중 JOIN
- 테이블 별칭
- `ON` 조건
- `WHERE` 조건
- NULL 확장 행
- anti-join
- `NOT EXISTS`
- 전체·활성·취소 제외 상태 범위
- `COUNT`
- `DISTINCT`
- `SUM`
- `AVG`
- `MIN`
- `MAX`
- 집계 함수와 NULL
- `GROUP BY`
- `HAVING`
- `COALESCE`
- `FILTER`
- `CASE` 상태 순서
- 과대 집계
- 검산
- AI SQL 검토

## 본문 구성

1. Chapter 07 최종 데이터와 사전 조건 검사
2. SQL 작성 전 업무 질문과 상태 범위 정의
3. ERD의 관계 경로 확인
4. `INNER JOIN`과 신청 기준 결과
5. 다중 JOIN
6. `LEFT JOIN`과 NULL
7. `ON`과 `WHERE` 조건 차이
8. 연결되지 않은 대상 찾기
9. 기본 집계 기준값과 NULL 규칙
10. `GROUP BY`와 업무 상태 순서
11. `COUNT` 대상 비교
12. `FILTER` 조건부 집계와 활성 신청
13. 강의별 신청·기록 금액 집계
14. `WHERE`와 `HAVING`
15. 강사별 다단계 집계와 금액 과대 계산
16. 상세·집계 결과 검산
17. `DISTINCT` 오용 방지
18. AI SQL 검토
19. 자주 하는 실수
20. 스스로 확인하기
21. 권장 해설
22. 핵심 정리
23. 다음 장 연결

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
| `00_check_course_project.sql` | DB·객체·행 수·상태 범위·기록 금액 검사와 실행 차단 |
| `01_join_queries.sql` | INNER·다중·LEFT JOIN, ON/WHERE, NOT EXISTS |
| `02_aggregation_queries.sql` | 기본·조건부·그룹 집계, 상태 순서와 과대 집계 사례 |
| `03_join_aggregation_validation.sql` | 전체·활성·취소 제외 건수와 기록 금액 검산 |
| `join_aggregation_practice.sql` | 기존 링크 호환용 읽기 전용 핵심 쿼리 |

## 안전성과 재현성 원칙

- Chapter 08에서 테이블·스키마를 삭제하거나 다시 생성하지 않는다.
- Chapter 07 최종 데이터를 읽기만 한다.
- `00_check_course_project.sql`에서 조건이 다르면 예외로 중단한다.
- Chapter 07 무결성 테스트의 임시 행이 남았는지 확인한다.
- 기준값이 다르면 사용자가 선택적으로 Chapter 07 상태를 복원한다.
- 모든 테이블 이름에 `course_project` 스키마를 명시한다.
- 모든 SQL 파일에서 DB·스키마·`search_path`를 확인한다.
- 데이터 변경 SQL을 포함하지 않는다.
- 별도 Chapter 08 데이터셋을 만들지 않는다.

## 분석 기준

```text
전체 신청 이력
- 모든 enrollments 행

활성 신청
- status IN ('신청', '수강중')

취소 제외 신청 이력
- status <> '취소'
- 신청, 수강중, 완료

기록 금액
- 신청 당시 저장된 recorded_amount

실제 매출
- 결제 성공·환불·매출 인식 정책이 추가로 필요한 값
```

`status`는 Chapter 07에서 `NOT NULL`이다.

## 집계 함수 NULL 기준

| 함수 | 빈 입력 결과 |
| --- | --- |
| `COUNT(*)`, `COUNT(column)` | 0 |
| `SUM`, `AVG`, `MIN`, `MAX` | NULL |

`COALESCE`는 데이터 없음과 0의 업무 의미가 같을 때만 사용한다.

## 상태 정렬 기준

```sql
ORDER BY CASE status
    WHEN '신청' THEN 1
    WHEN '수강중' THEN 2
    WHEN '완료' THEN 3
    WHEN '취소' THEN 4
    ELSE 99
END
```

문자열 정렬 설정에 기대지 않고 서비스 업무 순서를 명시한다.

## 조건부 집계 기준

```text
requested_count = 2
learning_count = 1
active_enrollment_count = 3
completed_count = 1
cancelled_count = 1
active_recorded_amount = 340000
non_cancelled_recorded_amount = 440000
```

`수강중`만 세는 컬럼을 `active_count`라고 부르지 않는다.

## 과대 집계 원칙

```text
강의와 신청을 JOIN하면 강의 행이 신청 수만큼 반복된다.
부모의 가격·금액을 반복된 결과에서 바로 SUM하지 않는다.
SUM(DISTINCT value)는 서로 다른 대상의 같은 값을 제거할 수 있으므로 일반 해결책이 아니다.
합산할 기준 행 수준에서 먼저 계산한다.
```

## 워크북 구성

- 실행 위치와 사전 검사 기록
- 전체·활성·취소 제외 범위 정의
- 업무 질문 구체화
- JOIN 경로 작성
- INNER·다중 JOIN 결과 기록
- LEFT JOIN NULL 해석
- ON·WHERE 비교
- `NOT EXISTS` 비교
- 기본 집계 기준값
- 집계 함수 NULL 규칙
- 상태별 `GROUP BY`와 `CASE` 정렬
- `COUNT` 세 종류 비교
- `FILTER` 조건부 집계
- 강의·강사별 집계
- 과대 금액 집계 수정
- 상세·집계 검산
- AI SQL 수정
- 권장 해설

## 도식 사용

다음 네 도식을 사용한다.

```text
그림 8-1 JOIN이 필요한 이유
그림 8-2 다중 JOIN 경로
그림 8-3 WHERE·GROUP BY·HAVING 논리 흐름
그림 8-4 AI SQL 검토 흐름
```

상태별 세부 숫자와 전체 SQL은 본문·표·코드에서 관리하며 도식에 과도하게 중복하지 않는다.

## AI 활용 원칙

- 질문 정의와 전체·활성·취소 제외 상태 범위를 프롬프트에 명시한다.
- 결과 한 행 기준과 FK 경로를 설명하도록 요청한다.
- `LEFT JOIN`의 조건 위치와 `COUNT` 대상을 설명하도록 요청한다.
- 신청 당시 기록 금액과 실제 매출을 구분하도록 요청한다.
- 상태 업무 순서를 명시하도록 요청한다.
- 예상 결과와 검산 SQL을 함께 요구한다.
- 전체 `5·590000`, 활성 `3·340000`, 취소 제외 `4·440000`으로 검증한다.
- `DISTINCT`로 중복 원인을 숨기지 않는지 확인한다.

## 다음 장 연결

Chapter 09에서는 `course_project` 데이터를 바탕으로 여러 변경 작업을 하나의 업무 단위로 처리하는 트랜잭션과 데이터 정합성을 다룬다.
