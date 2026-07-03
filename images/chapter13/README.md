# Chapter 13 이미지/도식 설계

## Chapter 13. ChatGPT와 Codex로 DB 설계 검증하기

이 문서는 Chapter 13 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 13은 AI가 생성한 ERD, 테이블 설계, SQL을 사람이 검토하고 수정하는 흐름을 설명하는 장입니다. 따라서 도식은 **AI 설계 검증 전체 흐름, ChatGPT와 Codex 역할 구분, 좋은 프롬프트 구조, ERD 검토 흐름, 나쁜 설계와 좋은 설계 비교, 제약조건 검증, information_schema 점검, Codex 오류 수정 루프**를 초급자가 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- AI 결과를 정답이 아니라 검토 대상 초안으로 표현한다.
- ChatGPT는 요구사항 정리와 검토, Codex는 SQL 파일 작성과 오류 수정에 강점이 있음을 구분한다.
- 좋은 프롬프트에는 업무 배경, 엔터티, 관계, 제약조건, 출력 형식, 검토 기준이 포함되어야 함을 보여 준다.
- AI가 만든 ERD와 DDL은 PK/FK/UNIQUE/CHECK/NOT NULL/정규화/보안 기준으로 검토해야 함을 강조한다.
- 나쁜 설계와 좋은 설계를 시각적으로 비교해 테이블 역할 분리와 제약조건의 의미를 드러낸다.
- SQL 실행 전 안전 검토와 Codex 오류 수정 루프를 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 13-1 | `ch13_01_ai_db_design_review_flow.svg` | AI 기반 DB 설계 검증 전체 흐름 | 1장 왜 AI 기반 DB 설계 검증을 배워야 하는가 | 삽입 완료 |
| 그림 13-2 | `ch13_02_chatgpt_codex_roles.svg` | ChatGPT와 Codex 역할 구분 | 2장 ChatGPT와 Codex의 역할 구분 | 삽입 완료 |
| 그림 13-3 | `ch13_03_good_prompt_structure.svg` | 좋은 DB 설계 프롬프트 구조 | 3장 AI에게 요구사항을 명확하게 전달하기 | 삽입 완료 |
| 그림 13-4 | `ch13_04_erd_review_checkpoints.svg` | ERD 초안 검토 체크포인트 | 4장 AI가 만든 ERD 초안 검토하기 | 삽입 완료 |
| 그림 13-5 | `ch13_05_bad_vs_good_design.svg` | 나쁜 설계와 좋은 설계 비교 | 5장 테이블 설계 검토하기 | 삽입 완료 |
| 그림 13-6 | `ch13_06_constraints_review.svg` | PK/FK/UNIQUE/CHECK 제약조건 검토 | 6장 AI가 만든 DDL 검토하기 | 삽입 완료 |
| 그림 13-7 | `ch13_07_information_schema_review.svg` | information_schema 기반 메타데이터 점검 | 11장 AI 생성 SQL 실행 전 안전 검토 | 삽입 완료 |
| 그림 13-8 | `ch13_08_codex_error_fix_loop.svg` | Codex 오류 수정 루프 | 12장 Codex를 활용한 수정 루프 | 삽입 완료 |

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch13_01_ai_db_design_review_flow.mmd` | `ch13_01_ai_db_design_review_flow.svg` |
| `ch13_02_chatgpt_codex_roles.mmd` | `ch13_02_chatgpt_codex_roles.svg` |
| `ch13_03_good_prompt_structure.mmd` | `ch13_03_good_prompt_structure.svg` |
| `ch13_04_erd_review_checkpoints.mmd` | `ch13_04_erd_review_checkpoints.svg` |
| `ch13_05_bad_vs_good_design.mmd` | `ch13_05_bad_vs_good_design.svg` |
| `ch13_06_constraints_review.mmd` | `ch13_06_constraints_review.svg` |
| `ch13_07_information_schema_review.mmd` | `ch13_07_information_schema_review.svg` |
| `ch13_08_codex_error_fix_loop.mmd` | `ch13_08_codex_error_fix_loop.svg` |

---

## 4. 도식 제작 후 점검 항목

```text
- AI 결과가 정답이 아니라 검토 대상 초안으로 표현되는가?
- ChatGPT, Codex, 사람의 역할 차이가 분명한가?
- 좋은 프롬프트 구조가 업무 배경, 엔터티, 관계, 제약조건, 출력 형식, 검토 기준을 포함하는가?
- ERD 검토에 핵심 엔터티, N:M 관계, FK, 역할 분리가 포함되는가?
- 나쁜 설계와 좋은 설계 비교에서 정규화와 테이블 역할 분리가 드러나는가?
- 제약조건 도식에서 PK/FK/UNIQUE/CHECK/NOT NULL이 막는 오류가 설명되는가?
- information_schema 도식이 메타데이터 점검 흐름을 보여 주는가?
- Codex 오류 수정 루프에 오류 메시지, 수정 요청, 재실행, 검증이 포함되는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 13 도식 후보 8종 정리 완료
- Chapter 13 Mermaid 원본 8종 작성 완료
- Chapter 13 SVG 도식 8종 생성 완료
- Chapter 13 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 13 리뷰 체크리스트 작성
```
