# Chapter 15 이미지/도식 설계

## Chapter 15. 데이터베이스 종합 프로젝트

Mermaid·SVG 8종은 `tutor_project`의 요구사항, 설계, PostgreSQL 실행, SQL·Python 분석, 운영 계획, AI 검토와 완료 판단을 설명합니다.

## 공통 원칙

```text
- 기술 수보다 요구사항·실행 증거·재현성을 강조한다.
- SQL 분석과 Python 분석을 필수 경로로 표현한다.
- 웹 CRUD·API, NoSQL과 배포는 선택 확장으로 구분한다.
- 생성·검증·분석·운영·보고 단계를 분리한다.
- 자동 DROP이나 운영 DB 직접 실행을 정상 흐름으로 표현하지 않는다.
- AI 변경 뒤 diff·SQL 실행·Python 실행·사람 승인 단계를 포함한다.
- SQL과 pandas 결과가 같은 기준값을 만드는지 표현한다.
- 완료 게이트와 실제 운영·복구 완료를 동일하게 표현하지 않는다.
- title, desc, role, aria-labelledby, width="100%", viewBox를 유지한다.
```

## 그림 목록

| 번호 | 파일 | 표시 역할 | 본문 연결 |
| --- | --- | --- | --- |
| 그림 15-1 | `ch15_01_service_project_flow.svg` | 통합 프로젝트 완성 흐름 | 설계→SQL 검증→Python 분석→완료 |
| 그림 15-2 | `ch15_02_scope_selection_guide.svg` | 필수 범위와 선택 확장 | SQL·Python 필수, 웹·NoSQL·배포 선택 |
| 그림 15-3 | `ch15_03_project_structure.svg` | 재현 가능한 파일 구조 | 01~10 SQL·Python·보고서 |
| 그림 15-4 | `ch15_04_db_design_validation.svg` | 요구사항부터 분석 결과까지 | ERD·DDL·VIEW·pandas 교차 검증 |
| 그림 15-5 | `ch15_05_ai_review_loop.svg` | AI 제안 검토 루프 | diff·SQL·Python·사람 승인 |
| 그림 15-6 | `ch15_06_completion_dimensions.svg` | 프로젝트 완성도의 일곱 축 | 범위·설계·재현·분석·운영·AI·한계 |
| 그림 15-7 | `ch15_07_project_story_flow.svg` | 설계와 분석 근거 이야기 | final_report의 설명 구조 |
| 그림 15-8 | `ch15_08_completion_checklist.svg` | 최종 완료 게이트 | DB·분석·미실행 항목 판단 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 기준값

```text
tutor_project 테이블 6
행 수 4·3·5·5·6·7
FK 5
IDENTITY PK 5
업무 인덱스 3
CASCADE 0
자동 반례 unexpected 0
question_analysis_dataset 5행
question_id 중복 0
answer_count 합계 5
material_count 합계 7
SQL·pandas 핵심 집계 일치
required_completion_gate_passed true
```

`required_completion_gate_passed`는 필수 DB 구조와 SQL 분석 VIEW 검증 결과입니다. Python 실행 증거, Role 시험, 실제 백업·복원, 웹·NoSQL·배포는 별도로 기록합니다.

## 도식에서 피할 표현

```text
- 기능이 많을수록 완성도가 높다.
- 웹·NoSQL·배포를 모두 필수로 한다.
- Python 분석을 선택 확장으로 표현한다.
- AI가 만든 SQL이나 Python 코드는 실행되면 승인한다.
- 생성 파일이 자동 DROP을 실행한다.
- 작은 샘플에서 인덱스 미사용은 오류다.
- Python에서 중복·NULL을 제거하면 검증이 끝난다.
- SQL과 pandas 결과가 달라도 그래프가 나오면 완료다.
- 완료 게이트 true이면 운영 검증도 모두 완료되었다.
```

## 검수 기준

```text
- 본문 그림 번호 15-1~15-8 순서 일치
- 그림 15-6의 일곱 축과 본문 표현 일치
- 09_analysis_dataset.sql과 Python 파일이 구조 도식에 반영됨
- SQL·Python 분석이 필수 경로로 표시됨
- 선택 확장은 웹 CRUD·API, NoSQL, 배포만 표시됨
- 필수·선택·보류 상태를 색상뿐 아니라 텍스트로 표현
- tutor_project 외 스키마 변경 표현 없음
- 요구사항·DB 실행·분석 결과·운영 계획·AI diff 연결
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
