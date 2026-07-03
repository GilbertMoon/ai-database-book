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

## 전체 목차 및 진행 현황

| Chapter | 제목 | 상태 |
| --- | --- | --- |
| Chapter 01 | AI 시대에 데이터베이스를 왜 배우는가 | 원고 1차 확장 완료 / 활동 자료 작성 완료 / 도식 후보 정리 완료 / SVG 도식 생성 완료 / 본문 그림 삽입 완료 |
| Chapter 02 | DBMS 기본 개념 | 원고 초안 작성 완료 |
| Chapter 03 | PostgreSQL과 DBeaver 실습 환경 구축 | 원고 초안 작성 완료 |
| Chapter 04 | 관계형 데이터베이스와 SQL 기초 | 원고 초안 작성 완료 |
| Chapter 05 | 데이터 모델링과 ERD | 원고 초안 작성 완료 |
| Chapter 06 | 정규화와 좋은 테이블 설계 | 원고 초안 작성 완료 |
| Chapter 07 | 중간 프로젝트 또는 중간 평가 | 원고 초안 작성 완료 |
| Chapter 08 | JOIN과 집계 쿼리 | 원고 초안 작성 완료 |
| Chapter 09 | 트랜잭션과 데이터 정합성 | 원고 초안 작성 완료 |
| Chapter 10 | 인덱스와 성능 기초 | 원고 초안 작성 완료 |
| Chapter 11 | 데이터베이스 보안과 백업 | 원고 초안 작성 완료 |
| Chapter 12 | NoSQL 이해와 선택 기준 | 원고 초안 작성 완료 |
| Chapter 13 | ChatGPT와 Codex로 DB 설계 검증하기 | 원고 초안 작성 완료 |
| Chapter 14 | Vector DB와 RAG 기초 | 원고 초안 작성 완료 |
| Chapter 15 | 최종 프로젝트 또는 최종 평가 | 원고 초안 작성 완료 |

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

```text
project-root/
├── README.md
├── BOOK_STYLE.md
├── book_authoring_guide.md
├── book/
│   ├── chapter01/
│   │   ├── chapter01_outline.md
│   │   ├── chapter01.md
│   │   └── chapter01_activity.md
│   ├── chapter02/
│   │   ├── chapter02_outline.md
│   │   └── chapter02.md
│   └── ...
├── code/
│   ├── chapter01/
│   ├── chapter02/
│   └── ...
├── images/
│   ├── chapter01/
│   │   ├── README.md
│   │   ├── ch01_01_storage_options.mmd
│   │   ├── ch01_01_storage_options.svg
│   │   ├── ch01_02_db_need_decision_flow.mmd
│   │   ├── ch01_02_db_need_decision_flow.svg
│   │   └── ...
│   ├── chapter02/
│   └── ...
├── notes/
├── scripts/
└── publish/
```

---

## 실습 프로젝트 흐름

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

## 현재 진행 상태

| 항목 | 상태 |
| --- | --- |
| 저장소 생성 | 완료 |
| 집필 가이드 확인 | 완료 |
| README.md 생성 | 완료 |
| BOOK_STYLE.md 작성 | 완료 |
| Chapter별 book 폴더 생성 | 완료 |
| Chapter별 outline 파일 생성 | 완료 |
| Chapter별 chapter 초안 파일 생성 | 완료 |
| Chapter별 code 폴더 생성 | 완료 |
| Chapter별 images 폴더 생성 | 완료 |
| publish/full_manuscript.md 초기 파일 생성 | 완료 |
| scripts/merge_chapters.py 초기 파일 생성 | 완료 |
| Chapter 01 원고 확장 | 완료 |
| Chapter 01 활동/실습 자료 작성 | 완료 |
| Chapter 01 도식 후보 정리 | 완료 |
| Chapter 01 Mermaid 도식 원본 작성 | 완료 |
| Chapter 01 SVG 도식 생성 | 완료 |
| Chapter 01 본문 그림 링크 및 캡션 삽입 | 완료 |
| Chapter 01 리뷰 체크리스트 작성 | 예정 |

---

## 다음 작업

가장 먼저 진행할 다음 작업은 다음과 같습니다.

```text
Chapter 01 리뷰 체크리스트를 작성하고, 원고 1차 리뷰 및 보완을 진행한다.
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
