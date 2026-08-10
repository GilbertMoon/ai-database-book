# AI 시대의 데이터베이스 입문

## 프로젝트 개요

이 저장소는 **AI 시대의 데이터베이스 입문** eBook을 집필하고 관리하기 위한 작업 저장소입니다.

이 책은 데이터베이스를 처음 접하는 일반 독자가 PostgreSQL과 SQL을 직접 실행하고, 데이터 모델링·정규화·트랜잭션·인덱스·보안·NoSQL·AI 활용·SQL 데이터 분석과 Python 확장까지 단계적으로 이해할 수 있도록 구성한 실습형 입문서입니다.

ChatGPT와 Codex는 설계와 SQL 초안을 빠르게 만드는 도구로 활용하되, 데이터 구조와 실행 결과를 사람이 직접 검토하는 과정을 중요하게 다룹니다.

---

## 도서 기본 정보

| 항목 | 내용 |
| --- | --- |
| 가제 | AI 시대의 데이터베이스 입문 |
| 부제 | ChatGPT와 Codex로 배우는 PostgreSQL, SQL, 데이터 설계와 분석 |
| 대상 | 데이터베이스를 처음 배우는 일반 독자와 예비 개발자 |
| 형태 | 설명과 실습을 결합한 eBook |
| 목표 분량 | 300~350페이지 |
| 구성 | 15개 Chapter |
| 기본 환경 | PostgreSQL + DBeaver + Python + GitHub |
| AI 활용 | ChatGPT와 Codex를 활용한 설계·SQL 작성 및 검증 |

---

## 전체 목차 및 진행 현황

Overview. 이 책을 시작하기 전에

| Chapter | 제목 | 상태 |
| --- | --- | --- |
| Chapter 01 | AI 시대에 데이터베이스를 왜 배워야 하는가 | 최종 출판 내용 검수 완료 |
| Chapter 02 | 데이터와 DBMS의 기본 개념 | 최종 출판 내용 검수 완료 |
| Chapter 03 | PostgreSQL과 DBeaver로 실습 환경 만들기 | 최종 출판 내용 검수 완료 |
| Chapter 04 | 관계형 데이터베이스와 SQL 시작하기 | 최종 출판 내용 검수 완료 |
| Chapter 05 | 요구사항에서 데이터 모델과 ERD 만들기 | 최종 출판 내용 검수 완료 |
| Chapter 06 | 정규화와 데이터 무결성으로 좋은 테이블 만들기 | 최종 출판 내용 검수 완료 |
| Chapter 07 | 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기 | 최종 출판 내용 검수 완료 |
| Chapter 08 | JOIN과 집계로 서비스 질문에 답하기 | 최종 출판 내용 검수 완료 |
| Chapter 09 | 트랜잭션으로 데이터 정합성 지키기 | 최종 출판 내용 검수 완료 |
| Chapter 10 | 실행 계획으로 인덱스 효과 검증하기 | 최종 출판 내용 검수 완료 |
| Chapter 11 | 데이터베이스를 안전하게 지키고 복구하는 방법 | 최종 출판 내용 검수 완료 |
| Chapter 12 | 조회 패턴으로 RDBMS와 NoSQL 선택하기 | 최종 출판 내용 검수 완료 |
| Chapter 13 | AI와 실행 증거로 데이터베이스 설계 검증하기 | 최종 출판 내용 검수 완료 |
| Chapter 14 | SQL 데이터 분석과 Python 확장 | 최종 출판 내용 검수 완료 |
| Chapter 15 | 데이터베이스 종합 프로젝트 | 최종 출판 내용 검수 완료 |

---

## 원고 구조

```text
book/overview/overview.md
    최종 출판본 앞부분의 책 안내·로드맵

book/chapterXX/chapterXX.md
    Chapter별 본문 원고

book/chapterXX/chapterXX_activity.md
    선택형 독자 워크북 또는 자기주도 실습 자료

code/chapterXX/
    본문에서 사용하는 SQL과 실행 예제

images/chapterXX/
    본문 도식과 설명 이미지

publish/full_manuscript.md
    Overview와 Chapter 01~15 최신 본문을 병합한 통합 원고
```

통합 원고는 [`scripts/merge_chapters.py`](scripts/merge_chapters.py)로 생성합니다. Chapter 본문 또는 병합 스크립트가 `main`에 반영되면 GitHub Actions가 [`publish/full_manuscript.md`](publish/full_manuscript.md)를 자동으로 갱신합니다.

---

## 현재 진행 상태

| 항목 | 상태 |
| --- | --- |
| Overview 출판용 Front Matter 최종 보완 | 완료 |
| 저장소와 집필 구조 구성 | 완료 |
| Chapter 01~15 본문 작성 | 완료 |
| 강의안 표현을 eBook 문체로 1차 수정 | 완료 |
| 활동 자료를 독자용 실습·워크북 형태로 1차 수정 | 완료 |
| Chapter 01 범위 분리·JOIN 반례·관리 방식·기준 데이터·AI 재현성·Chapter 07 용어 최종 보완 | 완료 |
| Chapter 02 실제 실습 계층·행 순서·관계 용어·외래키·VIEW·기준 데이터·금액 용어 최종 보완 | 완료 |
| Chapter 03 환경 조회·자동 판정·읽기 전용·시간대·PGPASSFILE·Supabase 최신 정책 최종 보완 | 완료 |
| Chapter 04 실행 위치·정렬·NULL·자동 커밋·데이터 상태 최종 보완 | 완료 |
| Chapter 05 요구사항 추적·미확정 정책·샘플 관계·IDENTITY·초기화 안전성 최종 보완 | 완료 |
| Chapter 06 확정 규칙·활성 대여·IDENTITY·경계값·오류 복구 최종 보완 | 완료 |
| Chapter 07 요구사항 ID·무료 금액·활성 신청·IDENTITY·상태 변경·경계값 최종 보완 | 완료 |
| Chapter 08 사전 상태·활성 범위·NULL·상태 순서·과대 집계·검산 최종 보완 | 완료 |
| Chapter 09 사전 검사·COMMIT 판정·IDENTITY·취소·SAVEPOINT·동시성 최종 보완 | 완료 |
| Chapter 10 합성 데이터·IDENTITY·실험 통제·결과 검증·PostgreSQL 18+ Skip Scan·운영 인덱스 최종 보완 | 완료 |
| Chapter 11 PUBLIC·최소 권한·IDENTITY·password file·원자적 복원·2단계 검증 최종 보완 | 완료 |
| Chapter 12 원본 매핑·TTL 재현성·JSONB 경계·낙관적 잠금·결정 상태·자동 검증 최종 보완 | 완료 |
| Chapter 13 P13 추적·DB 보호·IDENTITY·활성 신청·NULL·결제 시각·반례·자동 검증 최종 보완 | 완료 |
| Chapter 14 P14 추적·기록 금액·기간·date spine·읽기 전용 연결·manifest·SQL/pandas 교차 검증 최종 보완 | 완료 |
| Chapter 15 P15 추적·DB 보호·IDENTITY·시간 정합성·23개 테스트·PUBLIC·복원·SQL/pandas 직접 비교·완료 게이트 최종 보완 | 완료 |
| Chapter 01~15 장별 최종 출판 내용 검수 | 완료 |
| `publish/full_manuscript.md` 최신 원고 통합 | 자동 동기화 |
| 전체 원고 방향·용어·문체·링크 통합 검수 | 진행 중 |
| 실제 PostgreSQL·Python·복원 통합 실행 검증 | 예정 |
| Word·PDF·eBook 출판 렌더링 검수 | 예정 |

---

## 다음 작업

```text
1. Chapter 01~15의 제목, 용어, 문체, 표·캡션과 내부 링크를 통합 검수한다.
2. Chapter 03의 setup_check.sql과 setup_validate_local.sql을 실제 로컬 환경에서 실행한다.
3. Chapter 04~15의 PostgreSQL·Python 실습을 실제 환경에서 순차 실행한다.
4. Chapter 11·15의 Role 시험과 custom-format 백업·별도 DB 복원을 검증한다.
5. 전체 원고의 Word·PDF·eBook 렌더링과 분량을 최종 조정한다.
```

---

## 집필 및 편집 원칙

```text
- 일반 독자가 앞 장부터 순서대로 읽을 수 있는 흐름으로 설명한다.
- 강의, 제출, 배점, 평가와 같은 수업 운영 표현은 본문에서 사용하지 않는다.
- 단순 문법 설명보다 실제 데이터베이스 설계와 검증 과정을 중시한다.
- SQL은 가능한 한 PostgreSQL에서 직접 실행하고 결과를 확인한다.
- Python은 SQL 분석을 확장하는 도구로 사용하고 데이터베이스를 중심에 둔다.
- AI가 생성한 설계와 SQL은 초안으로 취급하고 사람이 검토한다.
- 비밀번호, 접속 URL, API 키와 실제 개인정보는 저장소에 기록하지 않는다.
- Overview와 Chapter별 원고를 기준으로 통합 원고를 자동 생성한다.
```
