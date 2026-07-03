# Chapter 08. JOIN과 집계 쿼리

> 상태: 초안

## 이 장에서 배울 내용

이 장에서는 여러 테이블의 데이터를 함께 조회하는 JOIN과 데이터를 요약하는 집계 쿼리를 학습합니다.

- INNER JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- 집계 함수
- AI 생성 JOIN SQL 검토

## 왜 이 내용을 배우는가

실제 데이터는 하나의 테이블에 모두 저장되지 않습니다. 회원, 주문, 상품처럼 여러 테이블에 나누어 저장된 데이터를 연결해 조회해야 합니다.

## 기본 예제

```sql
SELECT s.name, c.title
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON c.id = e.course_id;
```

이 SQL은 학생과 수강신청, 강의 테이블을 연결하여 학생별 수강 과목을 조회합니다.

## AI 활용 실습

```text
students, courses, enrollments 테이블을 JOIN하여 학생별 수강 과목을 조회하는 SQL을 작성해 주세요.
강의별 수강 인원 집계 SQL도 함께 작성해 주세요.
```

## 검토 질문

- JOIN 조건이 빠지지 않았는가?
- N:M 연결 테이블을 제대로 사용했는가?
- GROUP BY 컬럼이 올바른가?

## 자주 하는 실수

- JOIN 조건을 빼서 데이터가 비정상적으로 많아진다.
- INNER JOIN과 LEFT JOIN의 결과 차이를 이해하지 못한다.
- 집계 함수와 GROUP BY를 함께 사용할 때 컬럼을 잘못 선택한다.

## 정리

JOIN과 집계 쿼리는 실제 데이터 분석과 서비스 조회에서 매우 자주 사용됩니다. AI가 만든 JOIN SQL은 반드시 관계와 결과 건수를 확인해야 합니다.

## 연습 문제

1. [기초] INNER JOIN과 LEFT JOIN의 차이를 설명해 보세요.
2. [응용] 강의별 수강 인원을 조회하는 SQL을 작성해 보세요.
3. [응용] 학생별 수강 과목 수를 조회하는 SQL을 작성해 보세요.
4. [심화] AI가 생성한 JOIN SQL에서 잘못된 JOIN 조건을 찾아 수정해 보세요.

## 다음 장에서는

다음 장에서는 트랜잭션과 데이터 정합성을 학습합니다.
