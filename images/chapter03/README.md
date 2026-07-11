# Chapter 03 이미지/도식 설계

## Chapter 03. PostgreSQL과 DBeaver 실습 환경 구축

이 문서는 Chapter 03 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 03은 실습 환경을 구축하는 장이므로, 도식은 **도구 간 역할, 연결 흐름, 설치 확인, SQL 실행 흐름, 오류 해결 과정**을 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 입문 독자가 PostgreSQL과 DBeaver의 역할을 구분할 수 있어야 한다.
- 로컬 DB와 클라우드 DB의 차이를 시각적으로 비교한다.
- DBeaver 연결 흐름을 단계별로 보여 준다.
- 실습 SQL 실행 결과가 어떤 순서로 확인되는지 표현한다.
- 오류 메시지를 ChatGPT에 질문하고 해결하는 흐름을 보여 준다.
- 단순 설치 화면 캡처보다 실습 흐름과 판단 기준을 중심으로 구성한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 3-1 | `ch03_01_practice_environment_flow.svg` | 전체 실습 환경 구조 | 2장 전체 실습 환경 구조 | 삽입 완료 |
| 그림 3-2 | `ch03_02_local_vs_cloud_db.svg` | 로컬 PostgreSQL과 클라우드 PostgreSQL 비교 | 5장 로컬 환경과 클라우드 환경 | 삽입 완료 |
| 그림 3-3 | `ch03_03_dbeaver_connection_flow.svg` | DBeaver에서 PostgreSQL 연결 흐름 | 10장 DBeaver에서 PostgreSQL 연결하기 | 삽입 완료 |
| 그림 3-4 | `ch03_04_sql_execution_check_flow.svg` | 기본 SQL 실행 확인 흐름 | 12장 기본 SQL 실행 테스트 | 삽입 완료 |
| 그림 3-5 | `ch03_05_setup_check_sql_flow.svg` | setup_check.sql 실행 흐름 | 16장 실습 SQL 파일로 저장하기 | 삽입 완료 |
| 그림 3-6 | `ch03_06_error_troubleshooting_flow.svg` | 오류 메시지 해결 흐름 | 19장 자주 발생하는 오류와 해결 방향 | 삽입 완료 |
| 그림 3-7 | `ch03_07_github_practice_file_structure.svg` | GitHub 실습 파일 관리 구조 | 17장 GitHub 저장소에서 실습 관리하기 | 삽입 완료 |
| 그림 3-8 | `ch03_08_ai_help_prompt_flow.svg` | ChatGPT와 Codex를 활용한 실습 보조 흐름 | 20~21장 AI 질문/요청 | 삽입 완료 |

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

## 4. 도식 제작 후 점검 항목

```text
- PostgreSQL과 DBeaver의 역할이 명확하게 구분되는가?
- 로컬 DB와 클라우드 DB 비교가 입문 독자에게 이해되는가?
- DBeaver 연결 흐름이 실제 입력 항목과 일치하는가?
- SQL 실행 확인 흐름이 Chapter 03 본문과 일치하는가?
- 오류 해결 도식이 오류 메시지 기록과 AI 질문 흐름을 포함하는가?
- GitHub 실습 파일 구조가 실제 저장소 구조와 일치하는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 03 도식 후보 8종 정리 완료
- Chapter 03 Mermaid 원본 8종 작성 완료
- Chapter 03 SVG 도식 8종 생성 완료
- Chapter 03 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 03 리뷰 체크리스트 작성
```
