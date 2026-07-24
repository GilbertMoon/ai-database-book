# Chapter 03 최종 출판 내용 검수 반영 완료

## 대상 파일

```text
book/chapter03/chapter03.md
book/chapter03/chapter03_activity.md
book/chapter03/chapter03_outline.md
code/chapter03/setup_check.sql
code/chapter03/setup_validate_local.sql
code/chapter03/README.md
notes/chapter03_review_checklist.md
images/chapter03/README.md
images/chapter03/ch03_04_sql_execution_check_flow.mmd
images/chapter03/ch03_04_sql_execution_check_flow.svg
images/chapter03/ch03_05_setup_check_sql_flow.mmd
images/chapter03/ch03_05_setup_check_sql_flow.svg
README.md
```

## 검수 목적

Chapter 03을 단순 설치 안내가 아니라 다음 조건을 실제로 확인하고 자동 판정하는 환경 준비 장으로 완성했습니다.

```text
PostgreSQL 서버 실행
→ DBeaver 연결
→ ai_database_book 확인·생성
→ 새 DB로 다시 연결
→ 환경 정보 조회
→ 로컬 필수 조건 자동 검증
```

---

## 1. 출판 기준 환경과 검증 상태 구분

출판 기준 환경을 다음처럼 명시했습니다.

```text
기준 버전 확인일: 2026-07-24
운영체제 기준: Windows 11
PostgreSQL 기준: 18.4
DBeaver Community 기준: 26.1.3
호환 목표: PostgreSQL 15 이상
```

`원고 최종 검증 환경`이라는 과도한 표현을 제거하고 다음을 구분했습니다.

```text
공식 문서의 버전·정책 확인
실제 설치·연결 실행
SQL 자동 검증
Word·PDF·eBook 렌더링
```

실제 독자 PC의 통합 실행과 출판 렌더링은 별도 단계입니다.

---

## 2. 데이터베이스 생성 안전성

기존에는 바로 `CREATE DATABASE`를 실행했습니다. 최종 원고에서는 먼저 존재 여부와 소유자를 조회합니다.

```sql
SELECT datname,
       pg_get_userbyid(datdba) AS database_owner
FROM pg_database
WHERE datname = 'ai_database_book';
```

기존 DB가 있을 때 다음 선택을 구분했습니다.

```text
기존 DB 계속 사용
→ 소유자·스키마·객체 확인

다른 학습 DB 생성
→ 충돌 없는 새 이름 사용

초기화 필요
→ 백업과 삭제 대상을 확인한 별도 절차 사용
```

자동 `DROP DATABASE`를 안내하지 않습니다.

---

## 3. 관리자 계정 경계

`postgres` 관리자 계정은 개인 컴퓨터의 가상 데이터로 초기 환경을 구성할 때만 사용할 수 있다고 명시했습니다.

```text
로컬 개인 학습
→ 초기 구성에 관리자 계정 사용 가능

실제 애플리케이션·공용 서버
→ 관리자 계정 연결 금지
→ 최소 권한 전용 역할 사용
```

역할과 권한 구성은 Chapter 11로 연결했습니다.

---

## 4. 현재 스키마 판정 수정

기존 완료 기준의 `current_schema() = public` 절대 조건을 제거했습니다.

```text
current_schema()
→ search_path에서 실제로 사용할 수 있는 첫 스키마
→ 사용자 이름과 같은 스키마가 있으면 public이 아닐 수 있음
```

최종 완료 기준:

```text
current_database() = ai_database_book
public 스키마 존재
현재 사용자의 public USAGE 권한
search_path 의미 확인
```

Chapter 04는 `public.students`처럼 스키마를 명시합니다.

---

## 5. 환경 조회와 자동 판정 분리

### `setup_check.sql`

사람이 환경 정보를 읽고 기록하는 조회 파일입니다.

```text
version
current_database
current_schema
search_path
current_user
transaction_read_only
TimeZone
CURRENT_TIMESTAMP
1 + 1
한 행 요약
```

### `setup_validate_local.sql`

신규 파일이며 로컬 필수 경로를 예외 기반으로 판정합니다.

```text
PostgreSQL 15 이상
DB = ai_database_book
CONNECT 권한
public 존재
public USAGE 권한
transaction_read_only = off
SQL 계산 정상
```

통과 메시지:

```text
Chapter 03 local environment validation passed
```

두 파일 모두 테이블과 데이터를 변경하지 않습니다.

---

## 6. 읽기 전용·시간대 확인

Chapter 04의 변경 SQL을 실행할 수 있도록 다음을 추가했습니다.

```sql
SHOW transaction_read_only;
SHOW TimeZone;
```

Test Connection 성공이 쓰기 가능성을 보장하지 않는다는 설명을 추가했습니다. 시간대는 이후 `TIMESTAMPTZ`와 분석 기간 해석의 기초 정보로 사용합니다.

---

## 7. 실행 범위와 Auto-commit

DBeaver 기능 이름을 다음처럼 통일했습니다.

```text
Statement 실행
선택 영역 실행
Script 실행
```

Script 실행이 자동으로 하나의 트랜잭션이 아니라는 점과 Auto-commit·Manual commit의 차이를 설명했습니다. 화면 위치는 버전에 따라 다를 수 있으므로 현재 연결의 트랜잭션 표시와 Commit mode를 확인하도록 안내했습니다.

---

## 8. 비밀정보 정책 통일

책 전체의 최종 정책과 맞춰 다음 libpq 변수 체계를 사용합니다.

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
```

실제 비밀번호를 기본 `.env` 예제로 권장하지 않고 password file로 분리했습니다. 다음 항목도 공개 금지 대상으로 명시했습니다.

```text
실제 .env
.pgpass·pgpass.conf
DBeaver 연결 설정 내보내기
비밀번호가 보이는 화면 캡처
전체 클라우드 접속 문자열
```

---

## 9. 운영체제별 설치 범위

Windows를 필수 본문 경로로 유지하고 다음 내용을 보완했습니다.

```text
Stack Builder는 기본 실습에 필수 아님
Ubuntu의 postgresql-contrib는 선택 확장 모음
운영체제 저장소 버전은 Windows 기준 버전과 다를 수 있음
psql PATH 오류와 서버 설치 성공을 구분
```

macOS·Linux 상세 기록은 워크북 선택 활동으로 축소했습니다.

---

## 10. Supabase 선택 읽기 최신화

본문에서 Supabase의 핵심 차이만 유지했습니다.

```text
실제 PostgreSQL 제공
Storage 메타데이터와 객체 저장소 구분
storage 스키마 레코드는 SQL에서 읽기 전용 취급
파일 수정·삭제는 Storage API 사용
Direct 5432
Session pooler 5432
Transaction pooler 6543
Transaction pooler prepared statement 미지원
```

API 키도 다음처럼 최신화했습니다.

```text
publishable
→ 공개 클라이언트용, 인증·RLS 필요

secret
→ 신뢰할 수 있는 서버 전용, RLS 우회

legacy anon·service_role
→ 2026년 말 사용 중단 예정
```

세부 비교와 기록은 워크북 선택 활동으로 이동했습니다.

---

## 11. 워크북 재구성

### 핵심 활동

```text
환경 기록
역할 구분
연결
DB 존재·소유자 확인
DB 생성
현재 위치 확인
실행 범위·커밋 모드
setup_check
setup_validate_local
오류·보안 점검
```

### 선택 활동

```text
macOS·Linux
관리형 PostgreSQL·Supabase
AI 오류 질문
```

기존 18개 이상의 세부 활동을 핵심·선택 구조로 압축했습니다.

---

## 12. 도식 동기화

본문 도식은 6종을 유지했습니다.

```text
그림 3-1 전체 환경
그림 3-2 로컬·관리형 연결
그림 3-3 DBeaver 연결
그림 3-4 환경 정보 조회
그림 3-5 조회와 자동 판정
그림 3-6 오류 해결
```

그림 3-4에 읽기 전용 상태와 시간대를, 그림 3-5에 `setup_check.sql → setup_validate_local.sql` 역할 분리를 반영했습니다.

---

## 13. 최종 상태

| 항목 | 상태 |
| --- | --- |
| 본문 최종 검수 | 완료 |
| 워크북 핵심·선택 활동 분리 | 완료 |
| 구성안 동기화 | 완료 |
| `setup_check.sql` 확장 | 완료 |
| `setup_validate_local.sql` 신규 | 완료 |
| 코드 README 동기화 | 완료 |
| 최종 리뷰 체크리스트 교체 | 완료 |
| 도식 원본·SVG 동기화 | 완료 |
| 루트 README 상태 변경 | 완료 |
| 실제 PostgreSQL 실행 | 별도 통합 실행 단계에서 확인 예정 |
| Word·PDF·eBook 렌더링 | 전체 출판 렌더링 단계에서 확인 예정 |

---

## 결론

```text
Chapter 03은 설치 방법을 나열하는 장이 아니라,
올바른 데이터베이스와 스키마 권한에 연결하고
쓰기 가능 상태와 실행 결과를 자동 검증해
다음 장의 SQL을 재현 가능하게 시작하는 장으로 최종 정리했다.
```