# AI 시대의 데이터베이스 입문

## 프로젝트 개요

이 저장소는 **AI 시대의 데이터베이스 입문** 교재 집필을 위한 작업 저장소입니다.

이 책은 ChatGPT와 Codex를 활용해 데이터베이스 기본 개념, SQL, PostgreSQL, DB 설계, NoSQL, Vector DB, RAG 기초를 배우는 **실습형 eBook 겸 대학 교재**를 목표로 합니다.

단순히 SQL 문법을 배우는 것이 아니라, AI가 생성한 데이터베이스 설계와 SQL을 사람이 검토하고 수정할 수 있는 역량을 기르는 데 중점을 둡니다.

---

## 도서 기본 정보

| 항목 | 내용 |
| --- | --- |
| 가제 | AI 시대의 데이터베이스 입문 |
| 부제 | ChatGPT와 Codex로 배우는 DB 설계, SQL, PostgreSQL, NoSQL, Vector DB |
| 형태 | 실습형 eBook / 대학 교재 |
| 목표 분량 | 300~350페이지 |
| 구성 | 15챕터 |
| 중간 평가 | Chapter 07 |
| 최종 평가 | Chapter 15 |

---

## 대상 독자

이 책은 다음 독자를 대상으로 합니다.

```text
- 데이터베이스를 처음 배우는 일반 학습자
- 대학 데이터베이스 입문 수강생
- SQL과 DB 설계를 실습 중심으로 배우고 싶은 학습자
- ChatGPT, Codex 등 AI 도구를 활용해 개발을 배우려는 학습자
- 바이브코딩 환경에서 AI 생성 결과를 검증하는 능력을 기르고 싶은 학습자
```

---

## 학습 목표

이 책을 끝까지 학습한 독자는 다음을 할 수 있어야 합니다.

```text
1. DBMS의 기본 개념을 설명할 수 있다.
2. PostgreSQL과 DBeaver를 활용해 데이터베이스를 만들고 관리할 수 있다.
3. SELECT, INSERT, UPDATE, DELETE 등 기본 SQL을 작성할 수 있다.
4. 요구사항을 바탕으로 ERD와 테이블 구조를 설계할 수 있다.
5. PK, FK, 제약조건, 정규화의 필요성을 이해할 수 있다.
6. JOIN, 집계, 트랜잭션, 인덱스의 기본 원리를 이해할 수 있다.
7. AI가 생성한 SQL과 DB 설계의 오류를 검토하고 수정할 수 있다.
8. NoSQL과 Vector DB가 필요한 상황을 구분할 수 있다.
9. pgvector를 활용한 간단한 Vector DB/RAG 흐름을 이해할 수 있다.
10. 간단한 웹 CRUD 프로젝트를 통해 DB 설계 결과를 실행 가능한 형태로 검증할 수 있다.
```

---

## 핵심 도구

| 구분 | 도구 |
| --- | --- |
| AI 설계 도구 | ChatGPT |
| AI 코딩 도구 | Codex |
| 버전 관리 | GitHub |
| 로컬 DB | PostgreSQL |
| DB 관리 도구 | DBeaver |
| 웹 구현 | FastAPI 또는 Next.js |
| 배포 | Vercel |
| 배포용 DB | Neon PostgreSQL 또는 Supabase PostgreSQL |
| Vector DB 실습 | PostgreSQL + pgvector |

---

## 교재의 핵심 방향

이 책의 핵심 흐름은 다음과 같습니다.

```text
ChatGPT로 설계하고
→ Codex로 구현하고
→ PostgreSQL과 DBeaver로 검증하고
→ GitHub로 관리하고
→ 웹 CRUD와 Vector DB/RAG 실습으로 확장한다.
```

기존 데이터베이스 교재가 SQL 문법과 이론 중심이었다면, 이 교재는 **AI 시대에 필요한 DB 설계 검증 능력**을 함께 다룹니다.

---

## 전체 목차안

| Chapter | 제목 | 주요 내용 | 상태 |
| --- | --- | --- | --- |
| Chapter 01 | AI 시대에 데이터베이스를 왜 배우는가 | 데이터베이스의 필요성, 파일/엑셀/DB 차이, 바이브코딩 시대의 DB 학습 방향 | 구성 예정 |
| Chapter 02 | DBMS 기본 개념 | 데이터베이스, DBMS, 테이블, 행, 열, PK, FK, 관계, SQL, CRUD 개념 | 구성 예정 |
| Chapter 03 | PostgreSQL과 DBeaver 실습 환경 구축 | PostgreSQL 설치, DBeaver 연결, 기본 DB 생성, GitHub 저장소 준비 | 구성 예정 |
| Chapter 04 | 관계형 데이터베이스와 SQL 기초 | SELECT, INSERT, UPDATE, DELETE, WHERE, ORDER BY 등 기본 SQL | 구성 예정 |
| Chapter 05 | 데이터 모델링과 ERD | 엔티티, 속성, 관계, 1:N, N:M, ERD 작성 방법 | 구성 예정 |
| Chapter 06 | 정규화와 좋은 테이블 설계 | 중복 제거, 이상 현상, 1NF~3NF, 좋은 설계와 나쁜 설계 비교 | 구성 예정 |
| Chapter 07 | 중간 프로젝트 또는 중간 평가 | 간단한 서비스 요구사항을 바탕으로 ERD, 테이블, SQL 작성 및 검증 | 구성 예정 |
| Chapter 08 | JOIN과 집계 쿼리 | INNER JOIN, LEFT JOIN, GROUP BY, HAVING, 서브쿼리 기초 | 구성 예정 |
| Chapter 09 | 트랜잭션과 데이터 정합성 | ACID, COMMIT, ROLLBACK, Lock, Deadlock, 주문·결제·재고 예제 | 구성 예정 |
| Chapter 10 | 인덱스와 성능 기초 | 인덱스 개념, 검색 속도, 실행 계획, 느린 쿼리 개선 | 구성 예정 |
| Chapter 11 | 데이터베이스 보안과 백업 | SQL Injection, 권한 관리, 개인정보 보호, 백업과 복구 | 구성 예정 |
| Chapter 12 | NoSQL 이해와 선택 기준 | Key-Value, Document, Column, Graph DB 개념과 RDBMS와의 차이 | 구성 예정 |
| Chapter 13 | ChatGPT와 Codex로 DB 설계 검증하기 | AI가 만든 ERD, DDL, SQL의 오류 찾기, SQL Anti-pattern 검토 | 구성 예정 |
| Chapter 14 | Vector DB와 RAG 기초 | Embedding, Vector DB, pgvector, 의미 기반 검색, 간단한 RAG 테스트 | 구성 예정 |
| Chapter 15 | 최종 프로젝트 또는 최종 평가 | DB 설계부터 간단한 웹 구동까지 전체 프로젝트 수행 | 구성 예정 |

---

## 권장 페이지 배분

| 구분 | 챕터 | 권장 페이지 |
| --- | --- | ---: |
| 도입/기초 | 1~3장 | 50~60p |
| SQL/설계 핵심 | 4~6장 | 65~75p |
| 중간 프로젝트 | 7장 | 20~25p |
| 심화 기초 | 8~12장 | 90~110p |
| AI/Vector DB | 13~14장 | 50~65p |
| 최종 프로젝트 | 15장 | 35~45p |
| 부록/설치가이드/참고자료 | 부록 | 20~30p |

목표 전체 분량은 **300~350페이지**입니다.

---

## 표준 저장소 구조

이 저장소는 `book_authoring_guide.md`의 기준에 따라 다음 구조로 운영합니다.

```text
project-root/
├── README.md
├── BOOK_STYLE.md
├── book_authoring_guide.md
├── book/
│   ├── chapter01/
│   │   ├── chapter01_outline.md
│   │   └── chapter01.md
│   ├── chapter02/
│   │   ├── chapter02_outline.md
│   │   └── chapter02.md
│   └── ...
├── code/
│   ├── chapter01/
│   ├── chapter02/
│   └── ...
├── images/
├── notes/
├── scripts/
└── publish/
```

---

## 실습 프로젝트 흐름

교재 전체 실습은 다음 흐름을 기준으로 구성합니다.

```text
1. ChatGPT로 요구사항 정리
2. ERD 설계
3. PostgreSQL 테이블 생성
4. DBeaver로 데이터 확인
5. Codex로 간단한 웹 CRUD 구현
6. GitHub로 버전 관리
7. Vercel + Neon으로 배포 테스트
8. AI가 만든 SQL/설계 오류 검토 보고서 작성
```

---

## 주요 실습 주제 후보

| 단계 | 주제 |
| --- | --- |
| 초반 | 학생 관리 시스템 |
| 중반 | 온라인 강의 수강신청 시스템 |
| 후반 | 쇼핑몰 주문/결제/재고 시스템 |
| 최종 | AI 튜터링 서비스 또는 RAG 문서 검색 시스템 |

---

## Chapter 상태값 기준

Chapter별 진행 상태는 다음 값을 사용합니다.

```text
구성 설계 완료
원고 초안 작성 완료
실습 코드 작성 완료
도식 제작 완료
도식 본문 삽입 완료
원고 1차 리뷰 및 보완 완료
실습 코드 실행 검토 완료
1차 완료
```

---

## 현재 진행 상태

| 항목 | 상태 |
| --- | --- |
| 저장소 생성 | 완료 |
| 집필 가이드 확인 | 완료 |
| README.md 생성 | 완료 |
| BOOK_STYLE.md 작성 | 완료 |
| Chapter별 폴더 생성 | 예정 |
| Chapter 01 구성 설계 | 예정 |

---

## 다음 작업

가장 먼저 진행할 다음 작업은 다음과 같습니다.

```text
Chapter별 기본 폴더와 outline.md / chapter.md 초안 파일을 생성한다.
```

---

## 운영 원칙

```text
- 모든 Chapter는 원고, 코드, 도식, 리뷰 기록을 함께 관리한다.
- 초급 학습자가 따라 할 수 있도록 설명한다.
- 단순 문법 설명보다 실제 데이터베이스 설계와 검증 흐름을 중시한다.
- AI가 생성한 결과는 반드시 사람이 검토하고 수정하는 과정을 포함한다.
- 각 Chapter는 대학 수업 1주차 분량 또는 eBook 독립 학습 단위로 사용할 수 있어야 한다.
- 최종적으로 publish/full_manuscript.md로 통합 가능한 구조를 유지한다.
```
