# Chapter 01 이미지/도식 설계

## Chapter 01. AI 시대에 데이터베이스를 왜 배우는가

이 문서는 Chapter 01 본문과 독자용 보조 자료에서 사용하는 도식의 목적, 파일명과 실제 본문 삽입 순서를 관리합니다.

Chapter 01은 데이터베이스를 처음 접하는 독자를 대상으로 하므로 장식용 이미지보다 **저장 방식 비교, 판단 흐름, 데이터 관계와 AI 활용·검증 흐름**을 중심으로 구성합니다.

---

## 도식 설계 원칙

```text
- 입문 독자가 한눈에 핵심 구조를 이해할 수 있어야 한다.
- 파일, 스프레드시트와 데이터베이스의 차이를 시각적으로 구분한다.
- 데이터베이스 필요 여부를 논리적인 판단 흐름으로 보여 준다.
- AI는 작업을 보조하는 도구로 표현하고, 실제 작업과 사람의 판단을 중심에 둔다.
- 문제 발견, 수정, 재실행과 검증 완료 경로를 명확히 표시한다.
- SVG_STYLE_GUIDE.md의 공통 디자인·내용 기준을 적용한다.
- SVG와 같은 이름의 Mermaid 원본을 함께 갱신한다.
```

---

## 본문 기준 도식 목록

| 그림 | 파일명 | 도식 제목 | 본문 위치 | 핵심 목적 |
| --- | --- | --- | --- | --- |
| 그림 1-1 | `ch01_01_storage_options.svg` | 데이터 저장 방식의 선택지 | 데이터 저장 방식 설명 | 파일·스프레드시트·데이터베이스의 계층과 활용 사례 비교 |
| 그림 1-2 | `ch01_02_db_need_decision_flow.svg` | 데이터베이스 필요 여부 판단 흐름 | 데이터베이스가 필요한 경우 | 동시성·관계·검색·정확성을 기준으로 저장 방식 판단 |
| 그림 1-3 | `ch01_04_ai_result_verification_cycle.svg` | AI 생성 결과 검증 사이클 | AI가 잘하는 일과 사람이 맡아야 할 일 | AI 초안의 사람 검토·실행·수정·기록 흐름 설명 |
| 그림 1-4 | `ch01_03_ai_db_learning_flow.svg` | AI 시대의 데이터베이스 작업 흐름 | 이 책에서 AI를 활용하는 방식 | 요구사항부터 설계·SQL·실행·검증·GitHub 기록까지 연결 |
| 그림 1-5 | `ch01_05_online_course_data_relationship.svg` | 온라인 강의 서비스 데이터 관계 | 온라인 강의 서비스 사례 | 회원·강의·강사·수강신청·결제의 기본 관계 설명 |
| 그림 1-6 | `ch01_06_storage_choice_matrix.svg` | 저장 방식 선택 매트릭스 | 독자용 정리·워크북 | 데이터 복잡성·운영 범위와 특수 요구 조건 기준으로 저장 방식 비교 |

파일 번호와 본문 그림 번호가 다른 경우에는 **본문에 실제 등장하는 순서**를 그림 번호의 기준으로 사용합니다.

---

## 그림 1-4 작업 흐름 구성

`ch01_03_ai_db_learning_flow.svg`는 도구 이름을 단순 나열하지 않고 다음 작업을 중심으로 구성합니다.

```text
요구사항 확인
→ 핵심 규칙 정리(ChatGPT 보조)
→ 데이터 모델 설계
→ DDL·SQL 초안 생성(Codex 보조)
→ SQL 실행·구조와 데이터 확인(PostgreSQL·DBeaver)
→ 요구사항과 실행 결과 비교
→ 문제 있음: 문제 원인 확인 후 요구사항·모델·SQL·실행 단계 수정 및 재검증
→ 문제 없음: 검증 완료 및 GitHub 변경 이력 기록
```

핵심 메시지는 다음과 같습니다.

```text
AI는 초안을 빠르게 만들지만,
요구사항 판단과 실행 결과 검증은 사람이 책임진다.
```

---

## Mermaid 원본 파일

| Mermaid 파일 | 대상 SVG |
| --- | --- |
| `ch01_01_storage_options.mmd` | `ch01_01_storage_options.svg` |
| `ch01_02_db_need_decision_flow.mmd` | `ch01_02_db_need_decision_flow.svg` |
| `ch01_03_ai_db_learning_flow.mmd` | `ch01_03_ai_db_learning_flow.svg` |
| `ch01_04_ai_result_verification_cycle.mmd` | `ch01_04_ai_result_verification_cycle.svg` |
| `ch01_05_online_course_data_relationship.mmd` | `ch01_05_online_course_data_relationship.svg` |
| `ch01_06_storage_choice_matrix.mmd` | `ch01_06_storage_choice_matrix.svg` |

---

## 제작 완료 후 점검

```text
- 본문 설명과 SVG의 제목·용어·흐름이 일치하는가?
- 도구 이름보다 작업과 판단이 중심에 있는가?
- 수정 후 재검증 경로와 검증 완료 조건이 명확한가?
- 상자, 텍스트, 배지와 연결선이 겹치지 않는가?
- 전자책 화면에서 축소해도 읽을 수 있는가?
- SVG와 Mermaid 원본이 같은 논리를 표현하는가?
- 그림 번호와 실제 본문 등장 순서가 일치하는가?
```
