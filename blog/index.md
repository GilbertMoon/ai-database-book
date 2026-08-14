# AI 시대의 데이터베이스 입문 · 네이버 블로그 15강 전체 목차

안녕하세요. 아토믹데브입니다.

이 페이지는 **ChatGPT와 Codex를 활용해 PostgreSQL, SQL, 데이터 설계, 운영, AI 검증과 Python 데이터 분석까지 배우는 15강 수업 시리즈**의 전체 목차입니다.

데이터베이스를 처음 배우는 분도 순서대로 따라갈 수 있도록 구성했습니다.

이 과정의 목표는 SQL 문법을 많이 외우는 것이 아닙니다.

```text
업무 요구사항을 데이터 구조로 바꾸고
→ PostgreSQL로 구현하고
→ SQL 결과를 검증하고
→ AI가 만든 설계와 코드를 판단하고
→ Python 데이터 분석까지 확장하는 것
```

AI가 SQL을 빠르게 작성해 주는 시대일수록 **데이터의 의미와 관계를 이해하고 결과를 검증하는 능력**이 중요합니다.

---

## 이 강의에서 배우는 전체 흐름

```text
AI 시대의 데이터베이스 학습 방향
→ 데이터·DBMS 기본 개념
→ PostgreSQL·DBeaver 실습 환경
→ SQL과 CRUD
→ 요구사항·ERD
→ 정규화·무결성
→ 온라인 강의 DB 프로젝트
→ JOIN·집계
→ 트랜잭션·동시성
→ 인덱스·실행 계획
→ 보안·백업·복구
→ RDBMS·NoSQL 선택
→ AI 설계 검증
→ SQL·Python 데이터 분석
→ 종합 프로젝트
```

---

# 1부. 데이터베이스와 PostgreSQL 시작하기

## Chapter 01. AI가 SQL을 만들어 주는데도 데이터베이스를 배워야 할까?

AI 시대에 데이터베이스를 왜 배워야 하는지부터 시작합니다. 실행되는 SQL과 올바른 SQL이 왜 다른지, AI가 잘하는 일과 사람이 반드시 검증해야 하는 일을 이해합니다.

[Chapter 01 네이버 블로그 수업 자료](chapter01/chapter01_naver.md)

---

## Chapter 02. 데이터와 DBMS의 기본 개념 쉽게 이해하기

데이터, 데이터베이스, DBMS의 차이를 정리하고 PostgreSQL과 DBeaver의 역할, 서버 → 데이터베이스 → 스키마 → 테이블 구조, 행과 열, PK/FK의 기본 개념을 배웁니다.

[Chapter 02 네이버 블로그 수업 자료](chapter02/chapter02_naver.md)

---

## Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기

PostgreSQL과 DBeaver를 설치하고 연결한 뒤 `SELECT 1 + 1`부터 시작해 데이터베이스 생성, 현재 연결 정보, 스키마와 `search_path`까지 직접 확인합니다.

[Chapter 03 네이버 블로그 수업 자료](chapter03/chapter03_naver.md)

---

# 2부. SQL과 데이터 모델링 기초

## Chapter 04. 관계형 데이터베이스와 SQL 시작하기

테이블을 직접 만들고 `INSERT`, `SELECT`, `WHERE`, `ORDER BY`, `UPDATE`, `DELETE`를 실습합니다. CRUD와 데이터 타입, 제약조건의 기본도 함께 배웁니다.

[Chapter 04 네이버 블로그 수업 자료](chapter04/chapter04_naver.md)

---

## Chapter 05. 요구사항에서 데이터 모델과 ERD 만들기

업무 요구사항에서 엔터티와 속성을 찾고, 테이블 한 행의 의미를 정의하고, PK/FK와 1:N·N:M 관계를 ERD로 표현하는 방법을 배웁니다.

[Chapter 05 네이버 블로그 수업 자료](chapter05/chapter05_naver.md)

---

## Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기

중복 데이터와 삽입·수정·삭제 이상 현상을 살펴보고 1NF, 2NF, 3NF를 이해합니다. `NOT NULL`, `UNIQUE`, `CHECK`, FK 같은 무결성 제약조건도 PostgreSQL에서 직접 확인합니다.

[Chapter 06 네이버 블로그 수업 자료](chapter06/chapter06_naver.md)

---

# 3부. 온라인 강의 데이터베이스 프로젝트

## Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

`students`, `instructors`, `courses`, `enrollments` 테이블을 직접 설계하고 구현합니다. 신청 당시 금액 보존, 진행 중 중복 신청 방지, 검증 SQL까지 하나의 작은 프로젝트로 완성합니다.

[Chapter 07 네이버 블로그 수업 자료](chapter07/chapter07_naver.md)

---

## Chapter 08. JOIN과 집계로 서비스 질문에 답하기

`INNER JOIN`, `LEFT JOIN`, `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`, `COALESCE`를 사용해 학생별·강의별·상태별 서비스 질문에 답합니다. JOIN 후 과대 집계도 검증합니다.

[Chapter 08 네이버 블로그 수업 자료](chapter08/chapter08_naver.md)

---

# 4부. 안전하고 빠른 데이터베이스 운영

## Chapter 09. PostgreSQL 트랜잭션으로 데이터 정합성 지키기

`BEGIN`, `COMMIT`, `ROLLBACK`, ACID를 수강신청과 결제 사례로 배웁니다. 조건부 `UPDATE`, `RETURNING`, `SELECT ... FOR UPDATE`, Lock과 동시성 문제까지 다룹니다.

[Chapter 09 네이버 블로그 수업 자료](chapter09/chapter09_naver.md)

---

## Chapter 10. 실행 계획으로 인덱스 효과 검증하기

인덱스와 B-tree의 기본 원리를 이해하고 `EXPLAIN`, `EXPLAIN ANALYZE`, `BUFFERS`를 사용해 인덱스 생성 전후의 실행 계획을 직접 비교합니다.

[Chapter 10 네이버 블로그 수업 자료](chapter10/chapter10_naver.md)

---

## Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법

Role과 `GRANT / REVOKE`를 이용한 최소 권한 설계부터 `pg_dump`, `pg_restore`, 별도 DB 복원 검증까지 실습합니다. 백업은 파일 생성이 아니라 복원 성공까지 확인해야 한다는 원칙을 배웁니다.

[Chapter 11 네이버 블로그 수업 자료](chapter11/chapter11_naver.md)

---

# 5부. 저장소 선택과 AI 데이터베이스 검증

## Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기

RDBMS와 NoSQL을 단순 비교하지 않고 Source of Truth, 캐시, 이벤트, 문서 메타데이터와 같은 시스템 역할과 조회 패턴을 기준으로 저장소를 선택하는 방법을 배웁니다.

[Chapter 12 네이버 블로그 수업 자료](chapter12/chapter12_naver.md)

---

## Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기

ChatGPT와 Codex가 만든 ERD·DDL·SQL을 그대로 믿지 않고 요구사항 ID, 격리된 검토 스키마, 정상·경계·실패 테스트, PostgreSQL 메타데이터와 diff를 이용해 검증하는 방법을 배웁니다.

[Chapter 13 네이버 블로그 수업 자료](chapter13/chapter13_naver.md)

---

# 6부. SQL에서 Python 데이터 분석으로 확장하기

## Chapter 14. PostgreSQL SQL 분석을 Python pandas로 확장하기

분석 질문과 기간, 한 행의 단위와 지표 의미를 먼저 정의하고 SQL로 분석 데이터셋을 만든 뒤 pandas, 피벗, matplotlib으로 확장합니다. SQL과 pandas 결과를 교차 검증하는 방법도 실습합니다.

[Chapter 14 네이버 블로그 수업 자료](chapter14/chapter14_naver.md)

---

# 7부. 전체 내용을 하나의 프로젝트로 연결하기

## Chapter 15. AI 시대 데이터베이스 종합 프로젝트

AI 튜터링 질문 관리 서비스를 예제로 지금까지 배운 내용을 모두 연결합니다.

```text
요구사항
→ ERD
→ PostgreSQL DDL
→ Seed 데이터
→ 메타데이터 검증
→ JOIN·집계
→ 트랜잭션
→ 실패 테스트
→ 인덱스
→ 최소 권한
→ 백업·복원
→ 분석 VIEW
→ pandas 검증
→ AI diff 검토
→ Completion Gate
```

프로젝트의 완성도를 코드의 양이 아니라 **요구사항과 실제 실행 결과가 서로 추적되고 재현되는가**로 판단합니다.

[Chapter 15 네이버 블로그 수업 자료](chapter15/chapter15_naver.md)

---

# 이 강의를 공부하는 방법

처음부터 모든 SQL을 암기하려고 하지 않아도 됩니다.

다음 흐름으로 반복하면 좋습니다.

```text
1. 먼저 개념과 업무 상황을 이해한다.
2. 실행하기 전에 예상 결과를 생각한다.
3. SQL을 직접 실행한다.
4. 실제 결과와 예상 결과를 비교한다.
5. ChatGPT나 Codex로 다른 방법을 질문한다.
6. AI가 만든 SQL도 다시 실행해 검증한다.
7. 오류와 검증 결과를 기록한다.
```

특히 다음 질문을 계속 반복해 보세요.

```text
이 테이블의 한 행은 무엇을 의미하는가?
이 관계가 실제 업무와 맞는가?
이 SQL 결과의 숫자를 믿어도 되는가?
이 변경을 COMMIT해도 되는가?
AI가 추가한 규칙은 실제 요구사항에 있는가?
문제가 발생하면 데이터를 복구할 수 있는가?
```

---

# 이 과정을 모두 마치면

15강을 모두 학습하면 단순히 SQL 문법을 사용하는 수준을 넘어 다음 전체 흐름을 경험하게 됩니다.

```text
업무 요구사항 이해
→ 데이터 모델링
→ PostgreSQL 구현
→ SQL 조회와 검증
→ 데이터 변경과 트랜잭션
→ 성능 측정
→ 권한과 백업·복구
→ AI 생성 결과 검증
→ Python 데이터 분석
→ 종합 프로젝트 완성
```

AI 시대에 데이터베이스를 잘한다는 것은 SQL을 전부 외우는 것이 아닙니다.

> **업무를 데이터 구조로 표현하고, AI가 만든 결과까지 실제 데이터와 실행 증거로 검증할 수 있는 능력**

이것이 이 과정의 최종 목표입니다.

---

#데이터베이스 #PostgreSQL #SQL #DBeaver #ChatGPT #Codex #AI활용 #데이터모델링 #Python #pandas