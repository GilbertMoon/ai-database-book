# Chapter 13 이미지/도식 설계

## Chapter 13. ChatGPT와 Codex로 DB 설계 검증하기

Chapter 13 도식은 `images/SVG_STYLE_GUIDE.md`를 우선 적용합니다. 각 SVG는 하나의 핵심 메시지를 전달하며, 상세 표와 전체 SQL은 본문 또는 실습 파일에 둡니다.

## 도식 목록

| 번호 | 파일 | 제목 | 역할 |
| --- | --- | --- | --- |
| 그림 13-1 | `ch13_01_ai_db_design_review_flow.svg` | AI 기반 DB 설계 검증 전체 흐름 | 요구사항부터 실행 증거와 재검토까지 |
| 그림 13-2 | `ch13_02_chatgpt_codex_roles.svg` | ChatGPT·Codex·사람의 협업 흐름 | 고정 기능 경계가 아닌 권장 역할 |
| 그림 13-3 | `ch13_03_good_prompt_structure.svg` | 실행 가능한 DB 작업 프롬프트의 구성 | 범위·요구사항·검증 기준 |
| 그림 13-4 | `ch13_04_erd_review_checkpoints.svg` | 요구사항을 기준으로 ERD 검토하기 | N:M, FK, 선택성, 미확정 정책 검토 |
| 그림 13-5 | `ch13_05_bad_vs_good_design.svg` | 역할이 섞인 설계와 분리된 설계 | 데이터 소유자와 변경 이유 분리 |
| 그림 13-6 | `ch13_06_constraints_review.svg` | 업무 규칙을 제약조건과 테스트로 검증하기 | 요구사항·제약·오류 입력·메타데이터 |
| 그림 13-7 | `ch13_07_information_schema_review.svg` | 예상 설계와 실제 메타데이터 비교 | 실제 생성된 구조의 반복 검증 |
| 그림 13-8 | `ch13_08_codex_error_fix_loop.svg` | Codex 변경·검증·재수정 루프 | 민감정보 제거, 최소 변경, diff와 재실행 |

## Mermaid와 SVG 대응

| Mermaid | SVG |
| --- | --- |
| `ch13_01_ai_db_design_review_flow.mmd` | `ch13_01_ai_db_design_review_flow.svg` |
| `ch13_02_chatgpt_codex_roles.mmd` | `ch13_02_chatgpt_codex_roles.svg` |
| `ch13_03_good_prompt_structure.mmd` | `ch13_03_good_prompt_structure.svg` |
| `ch13_04_erd_review_checkpoints.mmd` | `ch13_04_erd_review_checkpoints.svg` |
| `ch13_05_bad_vs_good_design.mmd` | `ch13_05_bad_vs_good_design.svg` |
| `ch13_06_constraints_review.mmd` | `ch13_06_constraints_review.svg` |
| `ch13_07_information_schema_review.mmd` | `ch13_07_information_schema_review.svg` |
| `ch13_08_codex_error_fix_loop.mmd` | `ch13_08_codex_error_fix_loop.svg` |

## 공통 기준

```text
- 표준 SVG, 흰색 배경, width="100%"와 적절한 viewBox
- title, desc, role="img", aria-labelledby
- 외부 CSS·JavaScript·웹폰트·외부 이미지·foreignObject 미사용
- 일반 한글은 Malgun Gothic 중심의 안전한 폰트 스택
- SQL·파일명은 Consolas, D2Coding 계열 폰트
- 핵심 글자 12px 이상
- 성공·실패, 일치·불일치 라벨을 텍스트로 표시
- 실패 후 수정과 재검증 복귀 지점 명시
- Mermaid와 SVG 핵심 논리 동기화
```

## 정합성 기준

- AI 초안은 요구사항과 실행 증거를 통과해야 검토된 설계가 됨
- ChatGPT와 Codex의 기능은 겹칠 수 있으며 도식은 권장 작업 흐름을 표현
- 요구사항 없는 UNIQUE·CASCADE를 정답으로 표현하지 않음
- 현재 가격과 신청 시점 금액을 구분
- 오류 메시지에서 비밀정보를 제거
- Codex 변경 뒤 diff와 관련 없는 변경 여부 확인

## 검증 상태

```text
- Mermaid 원본 8개 한국어화 및 핵심 흐름 동기화
- SVG 8개 접근성·들여쓰기 구조 반영
- XML 파싱과 임시 PNG 렌더링 결과는 작업 완료 시 리뷰 문서에 기록
- GitHub 미리보기와 Word/PDF/eBook 변환은 별도 수동 확인
- Chapter 13 리뷰 체크리스트가 이미 존재하며 이번 변경에 맞게 갱신
```
