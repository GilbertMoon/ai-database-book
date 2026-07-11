# Chapter 07 이미지/도식 설계

## Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계

이 문서는 Chapter 07 본문과 독자 프로젝트 워크북에 사용하는 도식 자산을 정리합니다. 도식은 요구사항을 데이터 구조로 바꾸고, PostgreSQL과 샘플 데이터로 설계를 검증하는 흐름을 보여 줍니다.

## 도식 설계 원칙

```text
- 프로젝트 수행 순서를 한눈에 보여 준다.
- 요구사항에서 엔터티, 속성, 관계와 업무 규칙을 도출하는 흐름을 시각화한다.
- students, instructors, courses, enrollments의 관계를 명확히 보여 준다.
- CREATE TABLE, 샘플 데이터, JOIN과 CRUD로 설계를 검증하는 흐름을 표현한다.
- 정규화와 AI 검토는 점수표가 아니라 설계 품질을 확인하는 과정으로 설명한다.
- 파일명과 도식 내부 문구에는 점수표 중심 표현을 사용하지 않는다.
```

## 도식 목록

| 번호 | 파일명 | 도식 제목 | 사용 위치 |
| --- | --- | --- | --- |
| 그림 7-1 | `ch07_01_project_flow.svg` | 온라인 강의 DB 프로젝트 진행 흐름 | 장 도입부 |
| 그림 7-2 | `ch07_02_requirement_to_entities.svg` | 요구사항에서 엔터티 도출 | 요구사항 분석 |
| 그림 7-3 | `ch07_04_many_to_many_enrollments.svg` | 학생-강의 N:M 관계 해소 | 관계 분석 |
| 그림 7-4 | `ch07_03_online_course_erd.svg` | 온라인 강의 수강신청 ERD | ERD 확인 |
| 그림 7-5 | `ch07_05_sql_validation_flow.svg` | SQL 기반 설계 검증 흐름 | JOIN 검증 |
| 그림 7-6 | `ch07_06_normalization_review_flow.svg` | 프로젝트 정규화 검토 | 정규화 점검 |
| 그림 7-7 | `ch07_07_ai_review_flow.svg` | AI 제안 검토 흐름 | AI 활용 |
| 보조 도식 | `ch07_08_project_completion_checklist.svg` | 프로젝트 완성도 점검 | 워크북·추가 점검 |

각 SVG에는 동일한 이름의 Mermaid 원본 `.mmd` 파일이 함께 있습니다.
