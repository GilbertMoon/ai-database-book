# Chapter 03 이미지/도식 설계

## Chapter 03. PostgreSQL과 DBeaver로 데이터베이스 환경 만들기

이 문서는 Chapter 03 본문에 삽입한 Mermaid 원본과 SVG 결과물을 관리하기 위한 이미지 설계 문서입니다.

Chapter 03의 도식은 상세 비교표나 SQL 전체 코드를 이미지 안에 반복하지 않고, **도구 연결 구조, 실행 순서, 분기, 반복 검증 흐름**을 보여 주는 보조 자료로 사용합니다.

---

## 1. 도식 설계 원칙

```text
- Markdown 표: 상세 비교, 입력 항목, 점검 기준
- Markdown 코드 블록: SQL, 폴더 구조, 프롬프트 예시
- SVG: 연결 구조, 실행 순서, 분기, 반복 검증 흐름
- Mermaid: SVG의 의미적 원본
```

공통 SVG 기준은 다음과 같습니다.

```text
- width="100%"와 viewBox를 사용한다.
- title, desc, role="img", aria-labelledby를 포함한다.
- 외부 CSS, 웹폰트, JavaScript, raster 이미지를 사용하지 않는다.
- 긴 문장, 대형 표, 전체 SQL, 전체 폴더 트리를 SVG 안에 넣지 않는다.
- 한글은 Malgun Gothic, Apple SD Gothic Neo, Noto Sans KR, Arial, sans-serif 순서의 폰트 스택을 사용한다.
```

---

## 2. 도식 목록

| 본문 번호 | 파일명 | 도식 제목 | 역할 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 3-1 | `ch03_01_practice_environment_flow.svg` | 전체 데이터베이스 작업 환경 | 전체 작업 환경과 도구 연결 | 보정 완료 |
| 그림 3-2 | `ch03_02_local_vs_cloud_db.svg` | 로컬 PostgreSQL과 클라우드 PostgreSQL 연결 구조 | 로컬과 클라우드의 연결 구조 | 보정 완료 |
| 그림 3-3 | `ch03_03_dbeaver_connection_flow.svg` | DBeaver에서 PostgreSQL 연결하기 | DBeaver 연결 생성 순서 | 보정 완료 |
| 그림 3-4 | `ch03_04_sql_execution_check_flow.svg` | 기본 SQL로 데이터베이스 환경 확인하기 | 기본 SQL 환경 검증 순서 | 보정 완료 |
| 그림 3-5 | `ch03_05_setup_check_sql_flow.svg` | setup_check.sql 실행과 재실행 흐름 | `setup_check.sql` 실행·재실행 흐름 | 보정 완료 |
| 그림 3-6 | `ch03_07_github_practice_file_structure.svg` | SQL 실습 파일과 GitHub 기록 흐름 | SQL 파일과 GitHub 기록 흐름 | 보정 완료 |
| 그림 3-7 | `ch03_06_error_troubleshooting_flow.svg` | 데이터베이스 오류 해결 기본 흐름 | 데이터베이스 오류 해결 반복 흐름 | 보정 완료 |
| 그림 3-8 | `ch03_08_ai_help_prompt_flow.svg` | ChatGPT와 Codex를 활용한 실습 보조 흐름 | ChatGPT·Codex 활용과 실행 검증 흐름 | 보정 완료 |

> 파일명은 기존 번호를 유지한다. 본문 등장 순서상 그림 3-6은 `ch03_07`, 그림 3-7은 `ch03_06` 파일을 사용한다.

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch03_01_practice_environment_flow.mmd` | `ch03_01_practice_environment_flow.svg` |
| `ch03_02_local_vs_cloud_db.mmd` | `ch03_02_local_vs_cloud_db.svg` |
| `ch03_03_dbeaver_connection_flow.mmd` | `ch03_03_dbeaver_connection_flow.svg` |
| `ch03_04_sql_execution_check_flow.mmd` | `ch03_04_sql_execution_check_flow.svg` |
| `ch03_05_setup_check_sql_flow.mmd` | `ch03_05_setup_check_sql_flow.svg` |
| `ch03_06_error_troubleshooting_flow.mmd` | `ch03_06_error_troubleshooting_flow.svg` |
| `ch03_07_github_practice_file_structure.mmd` | `ch03_07_github_practice_file_structure.svg` |
| `ch03_08_ai_help_prompt_flow.mmd` | `ch03_08_ai_help_prompt_flow.svg` |

---

## 4. 그림별 검증 상태

| 항목 | 상태 |
| --- | --- |
| Mermaid와 SVG의 핵심 노드 및 흐름 일치 | 완료 |
| SVG 접근성 요소 포함 | 완료 |
| SVG XML 파싱 | 완료 |
| GitHub 렌더링 기준 검토 | 완료 |
| 본문 그림 번호와 캡션 정합성 | 완료 |
| 그림 3-6과 3-7의 파일 연결 정합성 | 완료 |

---

## 5. 변환 시 점검

```text
- Word/PDF/eBook 변환 과정에서 SVG가 PNG로 변환되면 한글, 화살표, 박스 여백을 확인한다.
- PNG가 흐리거나 한글이 깨지면 SVG 글자 크기와 폰트 스택을 보정한다.
- 외부 font 파일을 저장소에 추가하지 않는다.
```
