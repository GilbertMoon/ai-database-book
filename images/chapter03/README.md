# Chapter 03 이미지·도식 관리

## Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기

이 문서는 Chapter 03 본문에 사용하는 Mermaid 원본과 SVG 결과물을 관리합니다. 설치 화면을 그대로 복제하기보다 도구 연결, 환경 선택, 연결 순서, 환경 조회·자동 판정과 오류 해결 흐름을 보여 줍니다.

---

## 1. 도식 설계 원칙

```text
Markdown 표
→ 연결값·점검 기준·예상 결과

Markdown 코드 블록
→ SQL·폴더 구조·오류 질문 양식

SVG
→ 연결 구조·실행 순서·분기·반복 검증

Mermaid
→ SVG의 의미적 원본
```

공통 SVG 기준:

```text
width="100%"와 viewBox 사용
title·desc·role="img"·aria-labelledby 포함
외부 CSS·웹폰트·JavaScript·raster 이미지 미사용
긴 문장·대형 표·전체 SQL 미삽입
시스템 한글 폰트 스택 사용
```

---

## 2. 본문 사용 도식

| 번호 | 파일 | 제목 | 역할 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 3-1 | `ch03_01_practice_environment_flow.svg` | 전체 데이터베이스 작업 환경 | 사용자·DBeaver·PostgreSQL·SQL 파일 연결 | 사용 |
| 그림 3-2 | `ch03_02_local_vs_cloud_db.svg` | 로컬과 클라우드 PostgreSQL 연결 구조 | 필수 경로와 선택 경로 비교 | 사용 |
| 그림 3-3 | `ch03_03_dbeaver_connection_flow.svg` | DBeaver에서 PostgreSQL 연결하기 | 연결 생성과 Test Connection | 사용 |
| 그림 3-4 | `ch03_04_sql_execution_check_flow.svg` | SQL로 실습 환경 확인하기 | DB·스키마·사용자·읽기 전용·시간대 조회 | 최종 보완 |
| 그림 3-5 | `ch03_05_setup_check_sql_flow.svg` | 환경 조회와 자동 판정 흐름 | `setup_check`와 `setup_validate_local` 역할 분리 | 최종 보완 |
| 그림 3-6 | `ch03_06_error_troubleshooting_flow.svg` | 데이터베이스 오류 해결 기본 흐름 | 오류 분류와 재검증 | 사용 |

---

## 3. 본문 미사용 보관 도식

| 파일 | 기존 역할 | 현재 상태 |
| --- | --- | --- |
| `ch03_07_github_practice_file_structure.svg` | SQL 파일과 GitHub 기록 구조 | 미사용 보관 |
| `ch03_08_ai_help_prompt_flow.svg` | ChatGPT·Codex 활용 흐름 | 미사용 보관 |

삭제 여부는 전체 이미지 자산 정리 단계에서 결정합니다.

---

## 4. Mermaid와 SVG

| Mermaid | SVG | 관계 |
| --- | --- | --- |
| `ch03_01_practice_environment_flow.mmd` | `ch03_01_practice_environment_flow.svg` | 의미 원본·결과물 |
| `ch03_02_local_vs_cloud_db.mmd` | `ch03_02_local_vs_cloud_db.svg` | 의미 원본·결과물 |
| `ch03_03_dbeaver_connection_flow.mmd` | `ch03_03_dbeaver_connection_flow.svg` | 의미 원본·결과물 |
| `ch03_04_sql_execution_check_flow.mmd` | `ch03_04_sql_execution_check_flow.svg` | 최종 환경 조회 흐름 동기화 |
| `ch03_05_setup_check_sql_flow.mmd` | `ch03_05_setup_check_sql_flow.svg` | 조회·자동 판정 흐름 동기화 |
| `ch03_06_error_troubleshooting_flow.mmd` | `ch03_06_error_troubleshooting_flow.svg` | 의미 원본·결과물 |
| `ch03_07_github_practice_file_structure.mmd` | `ch03_07_github_practice_file_structure.svg` | 보관 |
| `ch03_08_ai_help_prompt_flow.mmd` | `ch03_08_ai_help_prompt_flow.svg` | 보관 |

---

## 5. 그림 3-4 최종 기준

다음 정보를 순서대로 표현합니다.

```text
ai_database_book 연결
→ setup_check.sql
→ version·current_database
→ current_schema·search_path
→ current_user·transaction_read_only
→ TimeZone·CURRENT_TIMESTAMP
→ 한 행 요약
→ 자동 검증 파일로 이동
```

`current_schema = public`을 절대 조건으로 표시하지 않습니다. 완료 기준은 `ai_database_book`, `public` 존재·USAGE 권한과 쓰기 가능 상태입니다.

---

## 6. 그림 3-5 최종 기준

```text
setup_check.sql로 정보 조회
→ DB·public·USAGE·쓰기 상태 확인
→ setup_validate_local.sql 실행
→ 예외 발생 시 실패 조건 수정
→ 통과 메시지 기록
→ 필요할 때 두 파일 재실행
```

두 파일 모두 테이블과 데이터를 변경하지 않는다는 문장을 유지합니다.

---

## 7. 출판 렌더링 점검

```text
본문과 SVG의 제목·용어·흐름이 일치하는가?
그림 3-1~3-6 번호와 실제 등장 순서가 일치하는가?
current_schema가 public 절대 조건으로 보이지 않는가?
transaction_read_only·TimeZone 라벨이 읽히는가?
setup_check와 setup_validate_local 역할이 구분되는가?
640px 너비에서 글자가 읽히는가?
SVG 접근성 요소가 포함되어 있는가?
GitHub·Word·PDF·eBook에서 정상 표시되는가?
```

현재 상태:

```text
본문 사용 도식: 6종
미사용 보관 도식: 2종
그림 3-4 Mermaid·SVG 최종 동기화: 완료
그림 3-5 Mermaid·SVG 최종 동기화: 완료
Word·PDF·eBook 렌더링: 전체 출판 단계에서 확인 예정
```