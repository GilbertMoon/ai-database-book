# AI 시대의 데이터베이스 입문

## 프로젝트 개요

이 저장소는 **AI 시대의 데이터베이스 입문** eBook을 집필하고 관리하기 위한 작업 저장소입니다.

이 책은 데이터베이스를 처음 접하는 일반 독자가 PostgreSQL과 SQL을 직접 실행하고, 데이터 모델링·정규화·트랜잭션·인덱스·보안·NoSQL·Vector DB·RAG까지 하나의 흐름으로 이해할 수 있도록 구성한 실습형 입문서입니다.

ChatGPT와 Codex는 설계와 SQL 초안을 빠르게 만드는 도구로 활용하되, 데이터 구조와 실행 결과를 사람이 직접 검토하는 과정을 중요하게 다룹니다.

---

## 도서 기본 정보

| 항목 | 내용 |
| --- | --- |
| 가제 | AI 시대의 데이터베이스 입문 |
| 부제 | ChatGPT와 Codex로 배우는 DB 설계, SQL, PostgreSQL, NoSQL, Vector DB |
| 대상 | 데이터베이스를 처음 배우는 일반 독자와 예비 개발자 |
| 형태 | 설명과 실습을 결합한 eBook |
| 목표 분량 | 300~350페이지 |
| 구성 | 15개 Chapter |
| 기본 환경 | PostgreSQL + DBeaver + GitHub |
| AI 활용 | ChatGPT와 Codex를 활용한 설계·SQL 생성 및 검증 |

---

## 전체 목차 및 진행 현황

| Chapter | 제목 | 상태 |
| --- | --- | --- |
| Chapter 01 | AI 시대에 데이터베이스를 왜 배워야 하는가 | 2차 재구성 완료 |
| Chapter 02 | 데이터와 DBMS의 기본 개념 | 2차 재구성 완료 |
| Chapter 03 | PostgreSQL과 DBeaver로 실습 환경 만들기 | 2차 재구성 완료 |
| Chapter 04 | 관계형 데이터베이스와 SQL 시작하기 | 2차 재구성 완료 |
| Chapter 05 | 요구사항에서 데이터 모델과 ERD 만들기 | 2차 재구성 완료 |
| Chapter 06 | 정규화와 좋은 테이블 설계 | eBook 1차 수정 완료 |
| Chapter 07 | 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계 | eBook 1차 수정 완료 |
| Chapter 08 | JOIN과 집계 쿼리 | eBook 1차 수정 완료 |
| Chapter 09 | 트랜잭션과 데이터 정합성 | eBook 1차 수정 완료 |
| Chapter 10 | 인덱스와 성능 기초 | eBook 1차 수정 완료 |
| Chapter 11 | 데이터베이스를 안전하게 지키고 복구하는 방법 | eBook 1차 수정 완료 |
| Chapter 12 | NoSQL 이해와 선택 기준 | eBook 1차 수정 완료 |
| Chapter 13 | ChatGPT와 Codex로 DB 설계 검증하기 | eBook 1차 수정 완료 |
| Chapter 14 | Vector DB와 RAG 기초 | eBook 1차 수정 완료 |
| Chapter 15 | 실전 프로젝트 2: AI 기반 데이터베이스 서비스 완성하기 | eBook 1차 수정 완료 |

---

## 원고 구조

```text
book/chapterXX/chapterXX.md
    Chapter별 본문 원고

book/chapterXX/chapterXX_activity.md
    선택형 독자 워크북 또는 자기주도 실습 자료

code/chapterXX/
    본문에서 사용하는 SQL과 실행 예제

images/chapterXX/
    본문 도식과 설명 이미지

publish/full_manuscript.md
    Chapter 01~15 최신 본문을 병합한 통합 원고
```

통합 원고는 [`scripts/merge_chapters.py`](scripts/merge_chapters.py)로 생성합니다. Chapter 본문 또는 병합 스크립트가 `main`에 반영되면 GitHub Actions가 [`publish/full_manuscript.md`](publish/full_manuscript.md)를 자동으로 갱신합니다.

---

## 현재 진행 상태

| 항목 | 상태 |
| --- | --- |
| 저장소와 집필 구조 구성 | 완료 |
| Chapter 01~15 본문 작성 | 완료 |
| 강의안 표현을 eBook 문체로 1차 수정 | 완료 |
| 활동 자료를 독자용 실습·워크북 형태로 1차 수정 | 완료 |
| Chapter 07·15 평가형 장을 실전 프로젝트 장으로 전환 | 완료 |
| `publish/full_manuscript.md` 최신 원고 통합 | 완료 |
| 통합 원고 자동 동기화 | 완료 |
| 전체 원고 2차 일관성 검수 | 예정 |

---

## 다음 작업

```text
1~15장 전체에서 제목, 용어, 문체, 이미지 캡션과 내부 링크의 일관성을 2차 검수한다.
```

---

## 집필 및 편집 원칙

```text
- 일반 독자가 앞 장부터 순서대로 읽을 수 있는 흐름으로 설명한다.
- 강의, 제출, 배점, 평가와 같은 수업 운영 표현은 본문에서 사용하지 않는다.
- 단순 문법 설명보다 실제 데이터베이스 설계와 검증 과정을 중시한다.
- SQL은 가능한 한 PostgreSQL에서 직접 실행하고 결과를 확인한다.
- AI가 생성한 설계와 SQL은 초안으로 취급하고 사람이 검토한다.
- 비밀번호, 접속 URL, API 키와 실제 개인정보는 저장소에 기록하지 않는다.
- Chapter별 원고를 기준으로 통합 원고를 자동 생성한다.
```
