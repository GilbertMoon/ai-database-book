# Chapter 03 이미지·도식 설계

## Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기

이 문서는 Chapter 03 본문에 사용하는 Mermaid 원본과 SVG 결과물을 관리합니다.

Chapter 03의 도식은 설치 화면을 그대로 복제하지 않고, 도구 연결 구조, 환경 선택, 연결 순서, 환경 검증과 오류 해결 흐름을 보여 주는 보조 자료로 사용합니다.

---

## 1. 도식 설계 원칙

```text
- Markdown 표: 연결값, 점검 기준, 예상 결과
- Markdown 코드 블록: SQL, 폴더 구조, 오류 질문 양식
- SVG: 연결 구조, 실행 순서, 분기와 반복 검증 흐름
- Mermaid: SVG의 의미적 원본
```

공통 SVG 기준은 다음과 같습니다.

```text
- width="100%"와 viewBox를 사용한다.
- title, desc, role="img", aria-labelledby를 포함한다.
- 외부 CSS, 웹폰트, JavaScript와 raster 이미지를 사용하지 않는다.
- 긴 문장, 대형 표, 전체 SQL과 전체 폴더 트리를 SVG 안에 넣지 않는다.
- 한글은 Malgun Gothic, Apple SD Gothic Neo, Noto Sans KR, Arial, sans-serif 순서의 폰트 스택을 사용한다.
```

---

## 2. 본문 사용 도식

| 본문 번호 | 파일명 | 도식 제목 | 역할 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 3-1 | `ch03_01_practice_environment_flow.svg` | 전체 데이터베이스 작업 환경 | 사용자·SQL 파일·DBeaver·PostgreSQL과 보조 도구 연결 | 유지 |
| 그림 3-2 | `ch03_02_local_vs_cloud_db.svg` | 로컬과 클라우드 PostgreSQL 연결 구조 | 기본 경로와 대안 경로 비교 | 유지 |
| 그림 3-3 | `ch03_03_dbeaver_connection_flow.svg` | DBeaver에서 PostgreSQL 연결하기 | 연결 생성과 테스트 순서 | 유지 |
| 그림 3-4 | `ch03_04_sql_execution_check_flow.svg` | SQL로 실습 환경 확인하기 | 서버·DB·스키마·사용자·실행 결과 검증 | 2차 수정 완료 |
| 그림 3-5 | `ch03_05_setup_check_sql_flow.svg` | setup_check.sql 실행과 재실행 흐름 | 읽기 전용 환경 확인 파일의 반복 실행 | 2차 수정 완료 |
| 그림 3-6 | `ch03_06_error_troubleshooting_flow.svg` | 데이터베이스 오류 해결 기본 흐름 | 오류 유형 분류와 재검증 | 유지 |

---

## 3. 현재 본문에서 참조하지 않는 보관 도식

다음 파일은 기존 1차 원고에서 사용했지만 2차 재구성 후 본문에서는 참조하지 않습니다. 파일은 삭제하지 않고 향후 GitHub·AI 활용 보조 자료로 사용할 수 있도록 보관합니다.

| 파일명 | 기존 역할 | 현재 상태 |
| --- | --- | --- |
| `ch03_07_github_practice_file_structure.svg` | SQL 파일과 GitHub 기록 구조 | 보관 |
| `ch03_08_ai_help_prompt_flow.svg` | ChatGPT·Codex 활용 흐름 | 보관 |

---

## 4. Mermaid 원본과 SVG 결과물

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

## 5. 2차 재구성 반영 사항

```text
- 그림 3-4에 current_schema, current_user, CURRENT_TIMESTAMP 확인을 추가했다.
- 그림 3-5에서 students 테이블 생성, 샘플 입력과 UNIQUE 오류 흐름을 제거했다.
- setup_check.sql을 조회문 전용 반복 검증 파일로 표현했다.
- 기존 GitHub·AI 도식은 본문에서 제외하고 보관 상태로 전환했다.
```

---

## 6. 검증 상태

| 항목 | 상태 |
| --- | --- |
| Mermaid와 SVG 핵심 흐름 일치 | 완료 |
| SVG 접근성 요소 포함 | 완료 |
| 외부 리소스 미사용 | 완료 |
| 본문 그림 번호와 캡션 정합성 | 완료 |
| Chapter 03 2차 범위와 도식 내용 일치 | 완료 |
| GitHub 화면 렌더링 | 확인 필요 |
| Word·PDF·eBook 변환 렌더링 | 출간 단계 확인 필요 |

---

## 7. 변환 시 점검

```text
- Word·PDF·eBook 변환 과정에서 한글, 화살표와 박스 여백을 확인한다.
- PNG 변환 시 글자가 흐리거나 잘리면 SVG 글자 크기와 viewBox를 보정한다.
- 외부 font 파일을 저장소에 추가하지 않는다.
```
