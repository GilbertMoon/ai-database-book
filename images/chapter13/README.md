# Chapter 13 이미지/도식 설계

## Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기

이 문서는 Chapter 13의 Mermaid·SVG 자산과 `ai_review_lab` 기반 2차 재구성 기준을 정리합니다.

## 공통 원칙

```text
- AI 결과는 정답이 아니라 검토 대상 초안으로 표현한다.
- 확인 요구사항·미확정 정책·AI 가정을 구분한다.
- 요구사항에서 실제 메타데이터·정상·반례·업무 검증으로 연결한다.
- ChatGPT Chat·Work·Codex의 역할은 절대적 기능 경계가 아니라 권장 흐름으로 표현한다.
- Codex 변경 후 파일별 diff와 사람의 승인 단계를 포함한다.
- 상세 SQL·표·제품 UI는 본문과 코드 파일에 둔다.
- title, desc, role="img", aria-labelledby, width="100%", viewBox를 유지한다.
```

## 도식 목록

| 번호 | 파일 | 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 13-1 | `ch13_01_ai_db_design_review_flow.svg` | AI 기반 DB 설계 검증 전체 흐름 | 요구사항·초안·실행 증거·승인 |
| 그림 13-2 | `ch13_02_chatgpt_codex_roles.svg` | ChatGPT·Codex·사람의 협업 흐름 | 도구 역할 중첩과 사람의 책임 |
| 그림 13-3 | `ch13_03_good_prompt_structure.svg` | 실행 가능한 DB 작업 프롬프트의 구성 | 문맥·범위·금지·검증·보고 |
| 그림 13-4 | `ch13_04_erd_review_checkpoints.svg` | 요구사항을 기준으로 ERD 검토하기 | 엔터티·카디널리티·선택성·미확정 정책 |
| 그림 13-5 | `ch13_05_bad_vs_good_design.svg` | 역할이 섞인 설계와 분리된 설계 | 데이터 소유자·변경 이유 분리 |
| 그림 13-6 | `ch13_06_constraints_review.svg` | 업무 규칙을 제약조건과 테스트로 검증하기 | 정상·반례·메타데이터 연결 |
| 그림 13-7 | `ch13_07_information_schema_review.svg` | 예상 설계와 실제 메타데이터 비교 | 카탈로그 불일치 시 재생성·재검증 |
| 그림 13-8 | `ch13_08_codex_error_fix_loop.svg` | Codex 변경·검증·재수정 루프 | 최소 변경·diff·재실행·승인 상태 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 2차 재구성 실습 기준

```text
ai_review_lab.bad_enrollments 3
ai_review_lab.students 3
ai_review_lab.instructors 2
ai_review_lab.courses 3
ai_review_lab.enrollments 4
ai_review_lab.payments 4
정상 JOIN 4
FK 4
예상 실패 24
정상 경계값 6
전체 30 / 통과 30
unexpected 0
```

명시적 ID:

```text
students 101~103
instructors 201~202
courses 301~303
enrollments 1001~1004
payments 9001~9004
```

검토 상태:

```text
승인
조건부 승인
보류
거절
```

## 도식에서 피할 표현

```text
- AI가 만든 SQL이 실행되면 올바른 설계다.
- ChatGPT는 설계만, Codex는 코드만 할 수 있다.
- 미확정 정책을 UNIQUE·CASCADE로 자동 확정한다.
- 현재 가격과 과거 신청 시점 기록 금액 차이는 항상 오류다.
- 오류 메시지와 운영 데이터를 그대로 AI에 전달한다.
- Codex가 수정했으므로 diff 검토가 필요 없다.
- 검증하지 않은 항목도 통과로 표시한다.
```

## 검수 기준

```text
- 본문 그림 번호 13-1~13-8과 README 순서 일치
- 요구사항·설계·실제 구조·테스트·승인 연결
- 실패 시 수정·초기화·재검증 복귀점 표시
- 기능 변화 가능성이 큰 제품 UI·요금제 고정 표현 없음
- ai_review_lab 외 스키마 변경 표현 없음
- 성공·실패·보류 상태를 색상뿐 아니라 텍스트로 표시
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
