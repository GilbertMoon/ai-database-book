# Chapter 03 이미지/도식 설계

## Chapter 03. PostgreSQL과 DBeaver 실습 환경 구축

이 문서는 Chapter 03 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 03은 실습 환경을 구축하는 장이므로, 도식은 **도구 간 역할, 연결 흐름, 설치 확인, SQL 실행 흐름, 오류 해결 과정**을 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 초급자가 PostgreSQL과 DBeaver의 역할을 구분할 수 있어야 한다.
- 로컬 DB와 클라우드 DB의 차이를 시각적으로 비교한다.
- DBeaver 연결 흐름을 단계별로 보여 준다.
- 실습 SQL 실행 결과가 어떤 순서로 확인되는지 표현한다.
- 오류 메시지를 ChatGPT에 질문하고 해결하는 흐름을 보여 준다.
- 단순 설치 화면 캡처보다 학습 흐름과 판단 기준을 중심으로 구성한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 3-1 | `ch03_01_practice_environment_flow.svg` | 전체 실습 환경 구조 | 2장 전체 실습 환경 구조 | ChatGPT, Codex, PostgreSQL, DBeaver, GitHub의 역할 연결 | 높음 |
| 그림 3-2 | `ch03_02_local_vs_cloud_db.svg` | 로컬 PostgreSQL과 클라우드 PostgreSQL 비교 | 5장 로컬 환경과 클라우드 환경 | 로컬 설치 방식과 클라우드 DB 대안 비교 | 높음 |
| 그림 3-3 | `ch03_03_dbeaver_connection_flow.svg` | DBeaver에서 PostgreSQL 연결 흐름 | 10장 DBeaver에서 PostgreSQL 연결하기 | Host, Port, Database, Username, Password 입력 흐름 설명 | 높음 |
| 그림 3-4 | `ch03_04_sql_execution_check_flow.svg` | 기본 SQL 실행 확인 흐름 | 12장 기본 SQL 실행 테스트 | version, current_database, 계산 테스트, students 테이블 확인 순서 | 높음 |
| 그림 3-5 | `ch03_05_setup_check_sql_flow.svg` | setup_check.sql 실행 흐름 | 16장 실습 SQL 파일로 저장하기 | SQL 파일이 테이블 생성, 데이터 입력, 조회로 이어지는 흐름 | 중간 |
| 그림 3-6 | `ch03_06_error_troubleshooting_flow.svg` | 오류 메시지 해결 흐름 | 19장 자주 발생하는 오류와 해결 방향 | 오류 발생 → 원인 분류 → 확인 → ChatGPT 질문 → 해결 기록 흐름 | 높음 |
| 그림 3-7 | `ch03_07_github_practice_file_structure.svg` | GitHub 실습 파일 관리 구조 | 17장 GitHub 저장소에서 실습 관리하기 | code/chapter03 폴더와 setup_check.sql 관리 구조 설명 | 중간 |
| 그림 3-8 | `ch03_08_ai_help_prompt_flow.svg` | ChatGPT와 Codex를 활용한 실습 보조 흐름 | 20~21장 AI 질문/요청 | 오류 질문과 SQL 파일 생성 요청 흐름 설명 | 중간 |

---

## 3. 본문 삽입 권장 위치

### 그림 3-1 전체 실습 환경 구조

삽입 위치:

```text
Chapter 03 본문 2. 전체 실습 환경 구조
```

본문 삽입 예시:

```markdown
![전체 실습 환경 구조](../../images/chapter03/ch03_01_practice_environment_flow.svg)

그림 3-1 전체 실습 환경 구조
```

---

### 그림 3-2 로컬 PostgreSQL과 클라우드 PostgreSQL 비교

삽입 위치:

```text
Chapter 03 본문 5. 로컬 환경과 클라우드 환경
```

본문 삽입 예시:

```markdown
![로컬 PostgreSQL과 클라우드 PostgreSQL 비교](../../images/chapter03/ch03_02_local_vs_cloud_db.svg)

그림 3-2 로컬 PostgreSQL과 클라우드 PostgreSQL 비교
```

---

### 그림 3-3 DBeaver에서 PostgreSQL 연결 흐름

삽입 위치:

```text
Chapter 03 본문 10. DBeaver에서 PostgreSQL 연결하기
```

본문 삽입 예시:

```markdown
![DBeaver에서 PostgreSQL 연결 흐름](../../images/chapter03/ch03_03_dbeaver_connection_flow.svg)

그림 3-3 DBeaver에서 PostgreSQL 연결 흐름
```

---

### 그림 3-4 기본 SQL 실행 확인 흐름

삽입 위치:

```text
Chapter 03 본문 12. 기본 SQL 실행 테스트
```

본문 삽입 예시:

```markdown
![기본 SQL 실행 확인 흐름](../../images/chapter03/ch03_04_sql_execution_check_flow.svg)

그림 3-4 기본 SQL 실행 확인 흐름
```

---

### 그림 3-5 setup_check.sql 실행 흐름

삽입 위치:

```text
Chapter 03 본문 16. 실습 SQL 파일로 저장하기
```

본문 삽입 예시:

```markdown
![setup_check.sql 실행 흐름](../../images/chapter03/ch03_05_setup_check_sql_flow.svg)

그림 3-5 setup_check.sql 실행 흐름
```

---

### 그림 3-6 오류 메시지 해결 흐름

삽입 위치:

```text
Chapter 03 본문 19. 자주 발생하는 오류와 해결 방향
```

본문 삽입 예시:

```markdown
![오류 메시지 해결 흐름](../../images/chapter03/ch03_06_error_troubleshooting_flow.svg)

그림 3-6 오류 메시지 해결 흐름
```

---

### 그림 3-7 GitHub 실습 파일 관리 구조

삽입 위치:

```text
Chapter 03 본문 17. GitHub 저장소에서 실습 관리하기
```

본문 삽입 예시:

```markdown
![GitHub 실습 파일 관리 구조](../../images/chapter03/ch03_07_github_practice_file_structure.svg)

그림 3-7 GitHub 실습 파일 관리 구조
```

---

### 그림 3-8 ChatGPT와 Codex를 활용한 실습 보조 흐름

삽입 위치:

```text
Chapter 03 본문 20. ChatGPT로 오류 메시지 질문하기
또는 21. Codex로 실습 SQL 파일 만들기
```

본문 삽입 예시:

```markdown
![ChatGPT와 Codex를 활용한 실습 보조 흐름](../../images/chapter03/ch03_08_ai_help_prompt_flow.svg)

그림 3-8 ChatGPT와 Codex를 활용한 실습 보조 흐름
```

---

## 4. Mermaid 원본 파일 계획

다음 Mermaid 파일을 도식 제작 원본으로 사용합니다.

| Mermaid 파일 | 대상 이미지 |
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

## 5. 도식 제작 후 점검 항목

```text
- PostgreSQL과 DBeaver의 역할이 명확하게 구분되는가?
- 로컬 DB와 클라우드 DB 비교가 초급자에게 이해되는가?
- DBeaver 연결 흐름이 실제 입력 항목과 일치하는가?
- SQL 실행 확인 흐름이 Chapter 03 본문과 일치하는가?
- 오류 해결 도식이 오류 메시지 기록과 AI 질문 흐름을 포함하는가?
- GitHub 실습 파일 구조가 실제 저장소 구조와 일치하는가?
- 그림 번호와 캡션을 본문에 삽입할 수 있는 형태인가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 03 도식 후보 8종 정리 완료
- 다음 작업: Chapter 03 Mermaid 도식 원본 8종 작성
```
