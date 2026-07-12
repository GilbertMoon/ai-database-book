# Chapter 07 이미지/도식 설계

## Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계

이 문서는 Chapter 07 본문과 워크북에 사용하는 도식 자산을 정리합니다. 도식은 요구사항을 데이터 구조로 바꾸고, PostgreSQL과 샘플 데이터로 설계를 검증하는 흐름을 보여 줍니다.

## 공통 원칙

- `images/SVG_STYLE_GUIDE.md`의 스타일과 접근성 기준을 따른다.
- 하나의 SVG는 하나의 핵심 메시지만 전달한다.
- 본문 표나 SQL 전체를 도식 안에 반복하지 않는다.
- 모든 텍스트는 SVG 박스 안에 들어가도록 줄 수와 글자 크기를 제한한다.
- Mermaid 원본과 SVG 결과물의 제목, 단계명, 분기 라벨을 함께 관리한다.
- 실제 SQL 파일명은 `code/chapter07/online_course_project.sql` 하나만 사용한다.

## 도식 목록

| 그림 번호 | 파일명 | 도식 제목 | 본문 위치 |
| --- | --- | --- | --- |
| 그림 7-1 | `ch07_01_project_flow.svg` | 온라인 강의 DB 프로젝트 핵심 흐름 | 프로젝트 도입부 |
| 그림 7-2 | `ch07_02_requirement_to_entities.svg` | 요구사항을 데이터 구조로 바꾸기 | 요구사항 분석 |
| 그림 7-3 | `ch07_04_many_to_many_enrollments.svg` | enrollments로 학생-강의 N:M 관계 해소 | 관계 분석 |
| 그림 7-4 | `ch07_03_online_course_erd.svg` | 온라인 강의 수강신청 핵심 ERD | ERD 확인 |
| 그림 7-5 | `ch07_05_sql_validation_flow.svg` | 샘플 데이터와 JOIN으로 설계 검증 | JOIN 검증 |
| 그림 7-6 | `ch07_06_normalization_review_flow.svg` | 온라인 강의 프로젝트 정규화 점검 | 정규화 평가 |
| 그림 7-7 | `ch07_07_ai_review_flow.svg` | AI 제안을 검토된 설계로 바꾸기 | AI 활용 |
| 그림 7-8 | `ch07_08_project_completion_checklist.svg` | 온라인 강의 DB 프로젝트 완성도 점검 | 프로젝트 완성도 평가 |

각 SVG에는 같은 이름의 Mermaid 원본 `.mmd` 파일이 함께 있습니다.

## 데이터 상태 표현 기준

- 기본 샘플 입력 직후: `students` 3행, `instructors` 2행, `courses` 3행, `enrollments` 4행
- 첫 번째 전체 JOIN: 수강신청 4건
- CRUD 이후 최종 상태: `enrollments` 5행
- 최종 상태: id 1 완료, id 4 취소, DELETE 예시는 주석 상태

## 검수 기준

- SVG가 XML 파서로 정상 로드된다.
- `width="100%"`와 `viewBox`가 유지된다.
- `role="img"`, `aria-labelledby`, `title`, `desc`가 있다.
- 글꼴은 Windows 한글 렌더링을 고려한 스택을 사용한다.
- 실제 존재하는 `online_course_project.sql` 파일명만 사용한다.
- Chapter 08 이미지나 본문을 수정하지 않는다.
