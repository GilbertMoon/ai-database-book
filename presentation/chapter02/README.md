# Chapter 02 발표자료

## 기준과 대상

- 원고 기준: `book/chapter02/chapter02.md`, `chapter02_review_revision.md`, `chapter02_outline.md`, `chapter02_activity.md`
- 대상: 데이터베이스와 SQL을 처음 배우는 학습자
- 선수 Chapter: Chapter 01
- 제작 상태: 전면 개편 완료, 자동 검증 및 브라우저 검증 대상

## 운영 정보

- 최종 슬라이드: 45장
- 마이크로 파트: 11개
- 스크립트: 공백 제외 9,158자, 분당 150자 기준 약 61분
- 예상 순수 설명 시간: 약 61분
- 예상 활동 시간: 약 17분
- 예상 전환·질문 시간: 약 10분
- 예상 전체 운영 시간: 약 88분

## 핵심 학습 목표

사용자, 클라이언트, PostgreSQL DBMS, 데이터베이스, 스키마, 테이블, 행과 열, 기본키와 외래키의 역할을 연결해 설명한다. 테이블과 조회 결과, 내부 식별자와 업무 식별자를 구분하고 AI가 만든 구조를 다섯 질문으로 검토한다.

## 이 장에서 실행하지 않는 내용

PostgreSQL과 DBeaver 설치·연결은 Chapter 03, 테이블 생성과 CRUD SQL 실행은 Chapter 04에서 진행한다. 관계 설계와 정규화, 복합 키, 삭제 정책, 트랜잭션, 권한, 백업, VIEW, JSONB의 상세 내용은 후속 Chapter로 넘긴다.

## 파일

- 진입: `chapter02_presentation.html`
- 단일 데이터 원본: `chapter02_data.js`
- 발표자 스크립트: `chapter02_script.html`
- 자동 검증: `validate_chapter02.mjs`
- 공통 기능: `../common/presentation.css`, `presentation_runtime.js`, `script_runtime.js`

## 이미지

재사용: `ch02_03_primary_key_concept.svg`, `ch02_04_foreign_key_relationship.svg`, `ch02_05_relationship_types.svg`.

수정: `ch02_02_table_row_column.svg`, `ch02_08_ai_table_review.svg`.

추가: `ch02_09_client_dbms_flow.svg`, `ch02_10_postgresql_hierarchy.svg`, `ch02_11_table_vs_query_result.svg`.

## 조작

- 다음/이전: 방향키, `PageUp`, `PageDown`, `Space`, 화면 클릭
- 처음/끝: `Home`, `End`
- 전체 화면: `F`
- 발표용 커서: `C`
- 스크립트 팝업: `S`
- 오버레이 닫기: `Esc`
- 직접 링크: `#18/3` 형식
- 인쇄: 브라우저 인쇄에서 배경 그래픽과 가로 방향 사용

## 검증

```powershell
node presentation/chapter02/validate_chapter02.mjs
```
