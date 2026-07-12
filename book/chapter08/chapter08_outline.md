# Chapter 08 Outline

## 제목
JOIN과 집계 쿼리

## 권장 분량
20~25페이지

## 이 장의 목적
정규화된 여러 테이블을 실제 PK·FK 관계로 연결해 조회하고, GROUP BY와 집계 함수로 결과를 요약하는 방법을 다룬다.

## 이 장에서 다룰 내용
- INNER JOIN과 LEFT JOIN의 포함 범위를 설명할 수 있다.
- enrollments를 기준 행으로 삼아 여러 테이블을 연결할 수 있다.
- GROUP BY와 HAVING의 역할을 구분할 수 있다.
- COUNT, SUM, AVG, COALESCE, COUNT DISTINCT를 상황에 맞게 사용할 수 있다.
- AI가 생성한 JOIN·집계 SQL을 검산 기준으로 검토할 수 있다.

## 주요 개념
- INNER JOIN
- LEFT JOIN
- 다중 JOIN
- 테이블 별칭
- COUNT
- SUM
- AVG
- GROUP BY
- HAVING
- COALESCE
- COUNT DISTINCT
- AI SQL 검토

## 본문 구성안
1. 정규화된 테이블에 JOIN이 필요한 이유
2. Chapter 08 샘플 데이터와 실습 안전 확인
3. INNER JOIN과 결과 5행 해석
4. 다중 JOIN과 정확한 FK 경로
5. LEFT JOIN과 NULL 결과 6행 해석
6. 기본 집계와 상태별 GROUP BY
7. 강의별 수강신청 건수, 고유 학생 수, 결제금액 합계
8. HAVING과 WHERE의 차이
9. AI 생성 JOIN·집계 SQL 검토

## 그림 역할
- 그림 8-1: 정규화된 사실을 조회 시점에 조립하는 이유
- 그림 8-2: INNER JOIN의 포함 범위와 5행 결과
- 그림 8-3: enrollments에서 students, courses, instructors로 가는 FK 경로
- 그림 8-4: LEFT JOIN의 6행 결과와 NULL 생성 원리
- 그림 8-5: 5개 원본 행이 3개 상태 그룹으로 바뀌는 과정
- 그림 8-6: 강의별 신청 건수, 고유 학생 수, 결제금액 합계의 구분
- 그림 8-7: 집계 쿼리의 논리적 처리 흐름
- 그림 8-8: AI SQL 검토와 수정·재실행 루프

## 실습 구성
- 기본 건수 검증
- INNER JOIN 결과 확인
- 다중 JOIN 결과 확인
- LEFT JOIN 결과 확인
- 수강신청이 없는 학생 찾기
- 상태별 GROUP BY
- 강의별 수강신청 건수와 고유 학생 수 구하기
- 강의별 결제금액 합계 구하기
- 강사별 개설 강의 수 구하기
- HAVING과 WHERE + GROUP BY 비교
- AI SQL 검토

## 다음 장 연결
다음 장에서는 Chapter 08에서 조회와 집계로 확인한 데이터를 바탕으로 트랜잭션과 데이터 정합성을 다룬다.
