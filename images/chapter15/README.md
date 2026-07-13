# Chapter 15 이미지/도식 설계

## Chapter 15. 실전 프로젝트 2: 재현 가능한 AI 데이터베이스 서비스 완성하기

기존 Mermaid·SVG 8종은 최종 프로젝트의 범위·구조·검증·AI 검토·완료 판단을 설명합니다. 2차 재구성에서는 `tutor_project`, 단계별 SQL, 운영·복구와 선택 RAG 확장 기준을 이미지 설명에 반영합니다.

## 공통 원칙

```text
- 기술 수보다 요구사항·실행 증거·재현성을 강조한다.
- 필수 경로와 선택 확장을 구분한다.
- 생성·검증·운영·보고 단계를 분리한다.
- 자동 DROP이나 운영 DB 직접 실행을 정상 흐름으로 표현하지 않는다.
- AI 변경 뒤 diff·재실행·사람 승인 단계를 포함한다.
- RAG는 원본 학습 자료와 벡터 파생 데이터를 구분한다.
- title, desc, role, aria-labelledby, width="100%", viewBox를 유지한다.
```

## 그림 목록

| 번호 | 파일 | 표시 역할 | 새 본문 연결 |
| --- | --- | --- | --- |
| 그림 15-1 | `ch15_01_service_project_flow.svg` | 통합 데이터베이스 서비스 완성 흐름 | 요구사항→실행→운영→완료 |
| 그림 15-2 | `ch15_02_scope_selection_guide.svg` | 필수 범위와 선택 확장 | 기본 DB·API·NoSQL·RAG·배포 판단 |
| 그림 15-3 | `ch15_03_project_structure.svg` | 재현 가능한 파일 구조 | 01~09 SQL·보고서·RUNBOOK |
| 그림 15-4 | `ch15_04_db_design_validation.svg` | 요구사항부터 실행 증거까지 | ERD·DDL·메타데이터·조회·반례 |
| 그림 15-5 | `ch15_05_ai_review_loop.svg` | AI 제안 검토 루프 | 최소 변경·diff·재실행·승인 |
| 그림 15-6 | `ch15_06_completion_dimensions.svg` | 프로젝트 완성도의 핵심 축 | 범위·설계·검증·운영·AI·한계 |
| 그림 15-7 | `ch15_07_project_story_flow.svg` | 설계 결정과 검증 근거 | final_report의 이야기 구조 |
| 그림 15-8 | `ch15_08_completion_checklist.svg` | 최종 완료 게이트 | 필수 통과·선택 확장·보류 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 2차 재구성 기준

```text
tutor_project 테이블 6
행 수 4·3·5·5·6·7
FK 5
IDENTITY PK 5
업무 인덱스 3
CASCADE 0
자동 반례 14
unexpected 0
```

선택 RAG:

```text
Source of Truth: learning_materials
활성 원문 후보: 5
public: 4
internal: 1
비활성 자료 제외
```

## 도식에서 피할 표현

```text
- 기능이 많을수록 완성도가 높다.
- CRUD·NoSQL·RAG·배포를 모두 필수로 한다.
- AI가 만든 SQL은 실행되면 승인한다.
- 생성 파일이 자동 DROP을 실행한다.
- 작은 샘플에서 인덱스 미사용은 오류다.
- 백업 파일이 있으면 복구 검증이 끝난다.
- 벡터 인덱스를 업무 원본으로 사용한다.
```

## 검수 기준

```text
- 본문 그림 번호 15-1~15-8 순서 일치
- 실제 템플릿 파일명과 도식 표현 일치
- 필수·선택·보류 상태를 색상뿐 아니라 텍스트로 표현
- tutor_project 외 스키마 변경 표현 없음
- 요구사항·실행 결과·운영 계획·AI diff 연결
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
