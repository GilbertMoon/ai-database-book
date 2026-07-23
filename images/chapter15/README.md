# Chapter 15 이미지·도식 설계

## Chapter 15. 데이터베이스 종합 프로젝트

Mermaid·SVG 8종은 `tutor_project`의 요구사항, PostgreSQL 검증, SQL·Python 분석, 별도 DB 복원, AI 검토와 완료 판단을 설명합니다.

## 공통 원칙

```text
- 기술 수보다 요구사항·실행 증거·재현성을 강조한다.
- SQL 분석과 Python 분석을 필수 경로로 표현한다.
- 웹 CRUD·API, NoSQL과 배포는 선택 확장으로 구분한다.
- 생성·검증·분석·복원·보고 단계를 분리한다.
- AI 변경 뒤 diff·DB 실행·Python 실행·사람 승인을 포함한다.
- Python은 실제 SQL 결과와 같은 스냅샷에서 비교한다.
- DB 완료 게이트와 Python·권한·복구·전체 완료를 동일하게 표현하지 않는다.
- title, desc, role, aria-labelledby, width="100%", viewBox를 유지한다.
```

## 그림 목록

| 번호 | 파일 | 표시 역할 |
| --- | --- | --- |
| 15-1 | `ch15_01_service_project_flow.svg` | 통합 프로젝트 흐름 |
| 15-2 | `ch15_02_scope_selection_guide.svg` | 필수 범위와 선택 확장 |
| 15-3 | `ch15_03_project_structure.svg` | 01~10·Python·11·보고서 구조 |
| 15-4 | `ch15_04_db_design_validation.svg` | 요구사항→DDL→VIEW→pandas 검증 |
| 15-5 | `ch15_05_ai_review_loop.svg` | AI diff·SQL·Python·사람 승인 |
| 15-6 | `ch15_06_completion_dimensions.svg` | 프로젝트 완성도의 일곱 축 |
| 15-7 | `ch15_07_project_story_flow.svg` | 설계·분석·복구 근거 이야기 |
| 15-8 | `ch15_08_completion_checklist.svg` | 단계별 완료 증거 판단 |

모든 SVG에는 같은 이름의 `.mmd` 원본이 있습니다.

## 기준값

```text
tables·views·sequences 6·4·5
constraints·FK·indexes 36·5·3
rows 4·3·5·5·6·7
IDENTITY next 105·204·306·406·507 이상
테스트 23/23, unexpected 0
질문·학생·튜터 VIEW 5·4·3행
answer_count 5 · material_count 7
첫 답변 4건 · 평균 2시간 · 음수 0
실제 SQL·pandas 요약 5종 일치
```

완료 단계:

```text
10_completion_gate.sql → DB 완료
Python 03               → SQL·pandas 완료
11_restore_validation   → 복구 완료
Role 시험               → 권한 완료
문서·AI diff 승인       → 전체 완료 근거
```

## 도식에서 피할 표현

```text
- 기능이 많을수록 완성도가 높다.
- 웹·NoSQL·배포를 모두 필수로 한다.
- 작은 Seed의 인덱스 계획만으로 성능 효과를 확정한다.
- Python 상수와 비교하면서 실제 SQL 교차 검증이라고 표현한다.
- access_scope 값만으로 접근이 차단된다고 표현한다.
- DB 게이트 통과가 Python·복원·권한 완료까지 뜻한다고 표현한다.
- 미실행 항목을 완료로 표시한다.
```

## 검수 기준

```text
- 본문 그림 번호 15-1~15-8 순서 일치
- 그림 15-3에 11_restore_validation.sql과 validation_utils.py 포함
- 그림 15-8에 DB·Python·복구·권한·문서 증거 분리
- SQL·Python 분석이 필수 경로로 표시
- 선택 확장은 웹 CRUD·API, NoSQL, 배포
- tutor_project 외 스키마 변경 표현 없음
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
