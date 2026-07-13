# Chapter 15 이미지 자료

Chapter 15의 SVG는 `images/SVG_STYLE_GUIDE.md`를 따르며, 최종 프로젝트의 필수 DB 완성과 선택 확장 판단을 설명합니다.

## 그림 목록

| 번호 | 파일 | 제목 | 본문 위치 |
|---|---|---|---|
| 그림 15-1 | `ch15_01_service_project_flow.svg` | 통합 데이터베이스 서비스 완성 흐름 | 장 도입부 |
| 그림 15-2 | `ch15_02_scope_selection_guide.svg` | 필수 범위와 선택 확장 결정하기 | 범위 결정 |
| 그림 15-3 | `ch15_03_project_structure.svg` | 재현 가능한 프로젝트 파일 구조 | 프로젝트 구조 |
| 그림 15-4 | `ch15_04_db_design_validation.svg` | 요구사항부터 실행 결과까지 검증하기 | ERD/DDL/SQL 검증 |
| 그림 15-5 | `ch15_05_ai_review_loop.svg` | AI 제안 검토·수정·재실행 루프 | AI 검토 |
| 그림 15-6 | `ch15_06_completion_dimensions.svg` | 프로젝트 완성도의 여섯 축 | 완성도 판단 |
| 그림 15-7 | `ch15_07_project_story_flow.svg` | 설계 결정과 검증 근거를 설명하는 흐름 | 보고서 작성 |
| 그림 15-8 | `ch15_08_completion_checklist.svg` | 최종 완료 판단 게이트 | 최종 점검 |

## Mermaid와 SVG

| Mermaid | SVG |
|---|---|
| `ch15_01_service_project_flow.mmd` | `ch15_01_service_project_flow.svg` |
| `ch15_02_scope_selection_guide.mmd` | `ch15_02_scope_selection_guide.svg` |
| `ch15_03_project_structure.mmd` | `ch15_03_project_structure.svg` |
| `ch15_04_db_design_validation.mmd` | `ch15_04_db_design_validation.svg` |
| `ch15_05_ai_review_loop.mmd` | `ch15_05_ai_review_loop.svg` |
| `ch15_06_completion_dimensions.mmd` | `ch15_06_completion_dimensions.svg` |
| `ch15_07_project_story_flow.mmd` | `ch15_07_project_story_flow.svg` |
| `ch15_08_completion_checklist.mmd` | `ch15_08_completion_checklist.svg` |

## 검수 기준

- 모든 그림이 본문에 실제 삽입되어 있는가?
- 그림 15-1부터 15-8까지 정식 번호를 갖는가?
- `ai_review_report.md`, `final_report.md`처럼 실제 템플릿 파일명을 사용하는가?
- 필수 DB 완성과 선택 확장을 구분하는가?
- SVG 높이가 800px 이하인가?
- `title`, `desc`, `role`, `aria-labelledby`, `width="100%"`, `viewBox`를 포함하는가?
- 외부 이미지, `foreignObject`, JavaScript, 중복 ID를 사용하지 않는가?

## 렌더링 상태

- XML 문법: 로컬 검사 필요
- GitHub 미리보기: 수동 확인 필요
- Word/PDF/eBook 변환: 수동 확인 필요
