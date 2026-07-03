# Chapter 01 이미지/도식 설계

## Chapter 01. AI 시대에 데이터베이스를 왜 배우는가

이 문서는 Chapter 01 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 01은 데이터베이스 개념을 처음 소개하는 장이므로, 장식용 이미지보다 **판단 흐름, 비교 구조, AI 활용 흐름**을 보여 주는 도식 중심으로 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 초급자가 한눈에 이해할 수 있어야 한다.
- 파일, 엑셀, 데이터베이스의 차이를 시각적으로 비교한다.
- 데이터베이스 필요 여부를 판단하는 흐름을 보여 준다.
- AI가 만든 결과를 사람이 검증하는 과정을 강조한다.
- 복잡한 기술 아키텍처보다 학습 흐름과 판단 기준을 중심으로 표현한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 1-1 | `ch01_01_storage_options.svg` | 데이터 저장 방식의 선택지 | 3장 데이터 저장 방식은 여러 가지다 | 파일, JSON, CSV, 엑셀, DB, NoSQL, Vector DB의 위치를 보여 줌 | 높음 |
| 그림 1-2 | `ch01_02_db_need_decision_flow.svg` | 데이터베이스 필요 여부 판단 흐름 | 5장 데이터베이스가 필요한 경우 | 데이터 양, 동시성, 관계, 정합성, 검색/집계 기준으로 DB 필요 여부 판단 | 높음 |
| 그림 1-3 | `ch01_03_ai_db_learning_flow.svg` | AI 시대의 DB 학습 흐름 | 10장 이 책에서 사용하는 AI 학습 흐름 | ChatGPT, Codex, PostgreSQL, DBeaver, GitHub의 역할 연결 | 높음 |
| 그림 1-4 | `ch01_04_ai_result_verification_cycle.svg` | AI 생성 결과 검증 사이클 | 9장 AI가 잘하는 일과 사람이 해야 하는 일 | AI 생성 → 사람 검토 → 실행 → 수정 → 기록 흐름 설명 | 높음 |
| 그림 1-5 | `ch01_05_online_course_data_relationship.svg` | 온라인 강의 서비스 데이터 관계 | 13장 온라인 강의 서비스 | 학생, 강의, 강사, 수강신청, 결제 간 기본 관계 설명 | 중간 |
| 그림 1-6 | `ch01_06_storage_choice_matrix.svg` | 저장 방식 선택 매트릭스 | 활동 자료 또는 정리 부분 | 단순/복잡, 개인/다중 사용자 기준으로 저장 방식 선택 | 중간 |

---

## 3. 본문 삽입 권장 위치

### 그림 1-1 데이터 저장 방식의 선택지

삽입 위치:

```text
Chapter 01 본문 3. 데이터 저장 방식은 여러 가지다
```

본문 삽입 예시:

```markdown
![데이터 저장 방식의 선택지](../../images/chapter01/ch01_01_storage_options.svg)

그림 1-1 데이터 저장 방식의 선택지
```

---

### 그림 1-2 데이터베이스 필요 여부 판단 흐름

삽입 위치:

```text
Chapter 01 본문 5. 데이터베이스가 필요한 경우
또는 19. 이 장의 핵심 판단표
```

본문 삽입 예시:

```markdown
![데이터베이스 필요 여부 판단 흐름](../../images/chapter01/ch01_02_db_need_decision_flow.svg)

그림 1-2 데이터베이스 필요 여부 판단 흐름
```

---

### 그림 1-3 AI 시대의 DB 학습 흐름

삽입 위치:

```text
Chapter 01 본문 10. 이 책에서 사용하는 AI 학습 흐름
```

본문 삽입 예시:

```markdown
![AI 시대의 DB 학습 흐름](../../images/chapter01/ch01_03_ai_db_learning_flow.svg)

그림 1-3 AI 시대의 DB 학습 흐름
```

---

### 그림 1-4 AI 생성 결과 검증 사이클

삽입 위치:

```text
Chapter 01 본문 9. AI가 잘하는 일과 사람이 해야 하는 일
또는 18. AI 시대의 데이터베이스 학습 원칙
```

본문 삽입 예시:

```markdown
![AI 생성 결과 검증 사이클](../../images/chapter01/ch01_04_ai_result_verification_cycle.svg)

그림 1-4 AI 생성 결과 검증 사이클
```

---

### 그림 1-5 온라인 강의 서비스 데이터 관계

삽입 위치:

```text
Chapter 01 본문 13. 작은 사례: 온라인 강의 서비스
```

본문 삽입 예시:

```markdown
![온라인 강의 서비스 데이터 관계](../../images/chapter01/ch01_05_online_course_data_relationship.svg)

그림 1-5 온라인 강의 서비스 데이터 관계
```

---

### 그림 1-6 저장 방식 선택 매트릭스

삽입 위치:

```text
Chapter 01 활동 자료 또는 본문 14. 실습 활동 1
```

본문 삽입 예시:

```markdown
![저장 방식 선택 매트릭스](../../images/chapter01/ch01_06_storage_choice_matrix.svg)

그림 1-6 저장 방식 선택 매트릭스
```

---

## 4. Mermaid 원본 파일

다음 Mermaid 파일을 도식 제작 원본으로 사용합니다.

| Mermaid 파일 | 대상 이미지 |
| --- | --- |
| `ch01_01_storage_options.mmd` | `ch01_01_storage_options.svg` |
| `ch01_02_db_need_decision_flow.mmd` | `ch01_02_db_need_decision_flow.svg` |
| `ch01_03_ai_db_learning_flow.mmd` | `ch01_03_ai_db_learning_flow.svg` |
| `ch01_04_ai_result_verification_cycle.mmd` | `ch01_04_ai_result_verification_cycle.svg` |
| `ch01_05_online_course_data_relationship.mmd` | `ch01_05_online_course_data_relationship.svg` |
| `ch01_06_storage_choice_matrix.mmd` | `ch01_06_storage_choice_matrix.svg` |

---

## 5. 도식 제작 후 점검 항목

```text
- 본문 설명과 도식 내용이 일치하는가?
- 초급자가 이해할 수 있는 단순한 구조인가?
- 도식에 너무 많은 텍스트가 들어가지 않았는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
- 이미지 파일 경로가 올바른가?
- 도식이 단순 장식이 아니라 이해를 돕는 역할을 하는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Mermaid 원본 6종 작성 완료
- SVG 도식 6종 생성 완료
- Chapter 01 본문 삽입 완료
- 다음 작업: Chapter 01 리뷰 체크리스트 작성
```
