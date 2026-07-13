# Chapter 03 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter03/chapter03.md
book/chapter03/chapter03_activity.md
book/chapter03/chapter03_outline.md
code/chapter03/setup_check.sql
code/chapter03/README.md
images/chapter03/
README.md
```

## 목적

Chapter 03의 역할을 여러 SQL 기능을 미리 실습하는 장에서, PostgreSQL과 DBeaver를 연결하고 현재 데이터베이스와 스키마를 정확히 확인하는 실습 환경 준비 장으로 재정의한다.

Chapter 02에서 강화한 클라이언트·DBMS·데이터베이스·스키마 구조를 실제 DBeaver 화면과 연결하고, Chapter 04의 CRUD 및 Chapter 06의 제약조건 실습과 중복되는 내용을 이동한다.

---

## 1. 2차 재구성 핵심 방향

```text
기존:
설치·연결
→ 테이블 생성
→ 데이터 입력·조회
→ UNIQUE 오류
→ GitHub·AI 활용

변경:
서버 준비
→ DBeaver 연결
→ 작업용 데이터베이스 생성
→ 새 DB로 재연결
→ 데이터베이스·스키마 확인
→ SQL 편집기 실행 범위 이해
→ 환경 검증 SQL 실행
→ 재실행 가능한 파일 저장
```

이 장의 완료 기준을 다음처럼 변경했다.

```text
프로그램 설치 완료
```

가 아니라,

```text
올바른 데이터베이스와 스키마에 연결해
SQL 결과를 확인하고 같은 환경 확인 절차를 재현할 수 있음
```

---

## 2. 제목과 분량 변경

| 항목 | 기존 | 변경 |
| --- | --- | --- |
| 제목 | PostgreSQL과 DBeaver로 데이터베이스 환경 만들기 | PostgreSQL과 DBeaver로 실습 환경 만들기 |
| 권장 분량 | 20~25페이지 | 15~18페이지 |
| 본문 절 수 | 28개 | 21개 |

---

## 3. 유지·강화한 내용

| 내용 | 반영 방향 |
| --- | --- |
| PostgreSQL과 DBeaver 연결 | 핵심 실습으로 유지 |
| Host, Port, Database, Username, Password | 의미와 점검 기준 강화 |
| `ai_database_book` 생성 | 유지 |
| 새 데이터베이스로 재연결 | 초급자 핵심 오류로 강조 |
| `current_database()` | 현재 연결 확인의 핵심 SQL로 유지 |
| 비밀번호와 접속 URL 보호 | 세 가지 보안 원칙으로 정리 |
| 연결 오류 해결 | 서버·인증·DB·스키마·SQL 유형으로 통합 |
| AI 오류 질문 | 재현 가능한 질문 템플릿 하나로 통합 |

---

## 4. 새로 추가한 내용

| 추가 내용 | 목적 |
| --- | --- |
| `postgres` 사용자와 `postgres` 데이터베이스 구분 | 같은 이름으로 인한 혼동 방지 |
| `current_schema()` | 현재 스키마 확인 |
| `SHOW search_path` | 기본 `public` 스키마 선택 과정 이해 |
| DBeaver의 `Schemas → public → Tables` 구조 | Chapter 02의 스키마 개념을 실제 화면과 연결 |
| 현재 문장·선택 영역·전체 스크립트 실행 구분 | 의도하지 않은 전체 실행 방지 |
| `current_user` | 현재 접속 계정 확인 |
| `CURRENT_TIMESTAMP` | 서버 SQL 처리 확인 |
| 조회문 전용 `setup_check.sql` | 안전한 반복 실행 보장 |
| 테이블이 아직 없는 상태도 정상이라는 안내 | Chapter 04 전 단계 혼동 방지 |

---

## 5. 축소한 내용

| 기존 내용 | 변경 방향 |
| --- | --- |
| PostgreSQL·DBeaver·GitHub·AI 역할의 반복 설명 | Chapter 02 내용을 짧게 복습 |
| 로컬·클라우드 환경 상세 비교 | 로컬 기본, 클라우드 대안으로 축소 |
| 운영체제별 설치 상세 | Windows 기본 흐름, 다른 OS는 완료 기준 중심 안내 |
| GitHub 파일 구조 독립 절 | SQL 파일 저장·보안 원칙에 통합 |
| ChatGPT와 Codex 별도 절 | 오류 질문과 선택형 파일 생성 요청으로 통합 |
| 비밀정보 종류의 반복 설명 | 세 가지 핵심 규칙으로 압축 |

---

## 6. 후속 장으로 이동한 내용

| 이동 내용 | 대상 장 | 이유 |
| --- | --- | --- |
| `students` 테이블 생성 | Chapter 04 | SQL 기초와 DDL 학습에 적합 |
| 샘플 데이터 `INSERT`와 `SELECT` | Chapter 04 | CRUD 학습에 적합 |
| `CREATE TABLE IF NOT EXISTS` | Chapter 04 | 재실행 가능한 SQL 작성 범위 |
| 중복 이메일 `UNIQUE` 오류 | Chapter 06 | 제약조건 정상·오류 테스트 범위 |
| 제약조건 상세 검토 | Chapter 06 | 무결성 학습 범위 |
| AI가 만든 SQL 상세 검증 | Chapter 13 | AI 설계·SQL 검증의 핵심 범위 |

---

## 7. `setup_check.sql` 변경

### 기존

```text
서버 확인
+ students 테이블 생성
+ 샘플 데이터 입력
+ 데이터 조회
+ UNIQUE 오류 실습
```

### 변경

```text
version()
current_database()
current_schema()
current_user
CURRENT_TIMESTAMP
1 + 1
```

환경 확인 파일은 조회문만 포함하므로 여러 번 실행해도 데이터베이스 상태가 변하지 않는다.

---

## 8. 워크북 변경

기존 워크북의 다음 활동을 제거했다.

- `students` 테이블 생성
- 샘플 데이터 입력과 조회
- `UNIQUE` 오류 만들기
- 제약조건 구조 분석

다음 활동을 새로 추가하거나 강화했다.

- PostgreSQL과 DBeaver 역할 구분
- `postgres` 사용자와 데이터베이스 구분
- 작업용 데이터베이스 생성과 재연결
- 현재 데이터베이스·스키마·search path 기록
- DBeaver에서 `public` 스키마 탐색
- SQL 실행 범위 비교
- `setup_check.sql` 반복 실행 기록
- 오류 유형 분류
- 공개 가능한 정보와 비밀정보 판단
- 재현 가능한 AI 오류 질문 작성

---

## 9. 도식 정합성 변경

| 도식 | 처리 |
| --- | --- |
| 그림 3-1 전체 작업 환경 | 유지 |
| 그림 3-2 로컬·클라우드 연결 | 유지 |
| 그림 3-3 DBeaver 연결 | 유지 |
| 그림 3-4 환경 검증 SQL | DB·스키마·사용자·시각 확인을 포함하도록 수정 |
| 그림 3-5 `setup_check.sql` | 테이블·데이터 변경 없는 반복 확인 흐름으로 수정 |
| 그림 3-6 오류 해결 | 유지 |
| 기존 GitHub 파일 구조 도식 | 본문 참조 제거, 파일은 보관 |
| 기존 ChatGPT·Codex 흐름 도식 | 본문 참조 제거, 파일은 보관 |

---

## 10. 최종 반영 상태

| 항목 | 상태 |
| --- | --- |
| 제목과 장 역할 변경 | 완료 |
| 본문 21개 절 재구성 | 완료 |
| 스키마·search path 설명 추가 | 완료 |
| SQL 편집기 실행 범위 추가 | 완료 |
| CRUD·제약조건 실습 후속 장 이동 | 완료 |
| 워크북 재구성 | 완료 |
| 구성안 재작성 | 완료 |
| `setup_check.sql` 조회문 전용 변경 | 완료 |
| 코드 README 갱신 | 완료 |
| 관련 도식 원본·SVG 수정 | 완료 |
| 루트 README 상태 변경 | 완료 |
| 통합 원고 자동 반영 확인 | 대기 후 확인 |

---

## 11. 결론

```text
Chapter 03은 2차 재구성 완료 상태로 전환한다.

이 장은 PostgreSQL 설치 기능을 나열하는 장이 아니라,
독자가 이후의 모든 SQL을 올바른 데이터베이스와 스키마에서
안전하고 재현 가능하게 실행하도록 준비하는 장으로 사용한다.
```
