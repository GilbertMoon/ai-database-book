# Chapter 01 이미지·도식 관리

## Chapter 01. AI 시대에 데이터베이스를 왜 배워야 하는가

이 문서는 Chapter 01 본문과 독자용 보조 자료에서 사용하는 도식의 목적, 파일명과 현재 사용 상태를 관리합니다.

Chapter 01은 데이터베이스를 처음 접하는 독자를 대상으로 하므로 장식용 이미지보다 **저장 방식 선택, AI 결과 검증과 책 전체 학습 흐름**을 중심으로 구성합니다.

---

## 도식 설계 원칙

```text
입문 독자가 한눈에 핵심 구조를 이해할 수 있어야 한다.
도구 이름보다 작업과 사람의 판단을 중심에 둔다.
문제 발견·수정·재실행·검증 완료 경로를 명확히 표시한다.
본문에 실제 필요한 도식만 사용해 시각적 과부하를 줄인다.
SVG_STYLE_GUIDE.md의 공통 디자인·내용 기준을 적용한다.
SVG와 같은 이름의 Mermaid 원본을 함께 관리한다.
```

---

## 최종 본문 사용 도식

현재 `book/chapter01/chapter01.md`에서 사용하는 도식은 세 개입니다.

| 본문 그림 | 파일명 | 도식 제목 | 본문 위치 | 핵심 목적 |
| --- | --- | --- | --- | --- |
| 그림 1-1 | `ch01_01_storage_options.svg` | 데이터 특성에 따른 저장 방식 선택 흐름 | 파일·스프레드시트·DBMS 중심 관리 | 관계·동시성·정확성·복구를 기준으로 선택 |
| 그림 1-2 | `ch01_04_ai_result_verification_cycle.svg` | AI 생성 결과 검증 사이클 | AI와 사람의 역할 | 요구사항·실행·비교·수정·기록 흐름 |
| 그림 1-3 | `ch01_03_ai_db_learning_flow.svg` | AI 시대의 데이터베이스 작업 흐름 | 책 전체 학습 흐름 | 개념부터 프로젝트까지의 검증 중심 학습 |

파일 번호와 본문 그림 번호가 다른 경우에는 **본문에 실제 등장하는 순서**를 그림 번호 기준으로 사용합니다.

---

## 미사용 보관 도식

다음 도식은 현재 Chapter 01 본문에서 참조하지 않습니다. 다른 원고·워크북에서 재사용 가능성을 고려해 파일은 보관하되, 본문 삽입 완료 도식으로 계산하지 않습니다.

| 파일명 | 기존 목적 | 현재 상태 |
| --- | --- | --- |
| `ch01_02_db_need_decision_flow.svg` | 데이터베이스 필요 여부 판단 | 그림 1-1과 내용 중복으로 미사용 보관 |
| `ch01_05_online_course_data_relationship.svg` | 온라인 강의 관계 | Chapter 05·07의 구체적 설계 도식과 중복 가능해 미사용 보관 |
| `ch01_06_storage_choice_matrix.svg` | 저장 방식 선택·확장 | 본문 표·그림 1-1과 중복으로 미사용 보관 |

미사용 SVG와 Mermaid의 실제 삭제는 전체 이미지 자산 정리 단계에서 결정합니다.

---

## 그림 1-2 검증 사이클 구성

`ch01_04_ai_result_verification_cycle.svg`는 다음 흐름을 표현합니다.

```text
질문·요구사항 확인
→ 실제 구조와 기준 데이터 확인
→ AI 초안 검토
→ 실행 전 예상 결과 작성
→ PostgreSQL 실행
→ 기준 행과 결과 비교
→ 문제 있으면 수정·재실행
→ 문제 없으면 근거 기록
```

핵심 메시지:

```text
AI는 초안을 빠르게 만들지만,
데이터 의미와 결과 검증은 사람이 책임진다.
```

---

## 그림 1-3 책 전체 흐름 구성

`ch01_03_ai_db_learning_flow.svg`는 도구 이름을 단순 나열하지 않고 다음 작업을 중심으로 구성합니다.

```text
요구사항 확인
→ 핵심 규칙 정리(ChatGPT 보조)
→ 데이터 모델 설계
→ DDL·SQL 초안 생성(Codex 보조)
→ SQL 실행·구조와 데이터 확인(PostgreSQL·DBeaver)
→ 요구사항과 실행 결과 비교
→ 문제 있음: 원인 확인 후 요구사항·모델·SQL 수정 및 재검증
→ 문제 없음: 검증 완료 및 GitHub 변경 근거 기록
```

---

## Mermaid 원본 파일

| Mermaid 파일 | 대상 SVG | 현재 본문 사용 |
| --- | --- | --- |
| `ch01_01_storage_options.mmd` | `ch01_01_storage_options.svg` | 사용 |
| `ch01_02_db_need_decision_flow.mmd` | `ch01_02_db_need_decision_flow.svg` | 미사용 보관 |
| `ch01_03_ai_db_learning_flow.mmd` | `ch01_03_ai_db_learning_flow.svg` | 사용 |
| `ch01_04_ai_result_verification_cycle.mmd` | `ch01_04_ai_result_verification_cycle.svg` | 사용 |
| `ch01_05_online_course_data_relationship.mmd` | `ch01_05_online_course_data_relationship.svg` | 미사용 보관 |
| `ch01_06_storage_choice_matrix.mmd` | `ch01_06_storage_choice_matrix.svg` | 미사용 보관 |

---

## 출판 렌더링 점검

```text
본문 설명과 SVG의 제목·용어·흐름이 일치하는가?
파일·스프레드시트·DBMS가 엄격한 저장 매체 분류처럼 보이지 않는가?
AI보다 사람의 판단·실행·검증이 중심에 있는가?
수정 후 재검증 경로와 완료 조건이 명확한가?
상자·텍스트·배지·연결선이 겹치지 않는가?
전자책 화면에서 축소해도 읽을 수 있는가?
SVG와 Mermaid 원본이 같은 논리를 표현하는가?
GitHub·Word·PDF·eBook에서 그림 1-1~1-3이 정상 표시되는가?
```
