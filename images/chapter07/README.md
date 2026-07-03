# Chapter 07 이미지/도식 설계

## Chapter 07. 중간 프로젝트 또는 중간 평가

이 문서는 Chapter 07 본문과 활동/평가 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 07은 Chapter 01~06의 내용을 종합하는 중간 프로젝트 장이므로, 도식은 **프로젝트 진행 흐름, 요구사항 분석, 온라인 강의 수강신청 ERD, SQL 검증 흐름, 정규화 검토, AI 활용 검토, 제출 산출물, 평가 기준**을 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 프로젝트 수행 순서를 한눈에 보여 준다.
- 요구사항에서 엔터티와 속성을 도출하는 흐름을 시각화한다.
- students, instructors, courses, enrollments 관계를 명확히 보여 준다.
- students와 courses의 N:M 관계를 enrollments로 해소하는 구조를 강조한다.
- CREATE TABLE, INSERT, JOIN, CRUD로 설계를 검증하는 흐름을 표현한다.
- 정규화와 AI 검토 기준이 평가와 연결되도록 보여 준다.
- 제출 산출물과 평가 기준을 학습자가 확인하기 쉽게 구성한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 7-1 | `ch07_01_midterm_project_flow.svg` | 중간 프로젝트 진행 흐름 | 1장 프로젝트 목표 또는 16장 진행 순서 | 요구사항 분석부터 최종 보고서까지 전체 흐름 설명 | 높음 |
| 그림 7-2 | `ch07_02_requirement_to_entities.svg` | 요구사항에서 엔터티 도출 | 3장 요구사항 분석 | 학생, 강사, 강의, 수강신청 도출 과정 설명 | 높음 |
| 그림 7-3 | `ch07_03_online_course_erd.svg` | 온라인 강의 수강신청 ERD | 6장 ERD 초안 작성 | 전체 테이블과 관계 구조 설명 | 높음 |
| 그림 7-4 | `ch07_04_many_to_many_enrollments.svg` | 학생-강의 N:M 관계 해소 | 5장 관계 분석 | students와 courses 관계를 enrollments로 풀어내는 과정 설명 | 높음 |
| 그림 7-5 | `ch07_05_sql_validation_flow.svg` | SQL 기반 설계 검증 흐름 | 7~10장 SQL 구현 및 CRUD | CREATE TABLE → INSERT → JOIN → CRUD 검증 흐름 설명 | 높음 |
| 그림 7-6 | `ch07_06_normalization_review_flow.svg` | 중간 프로젝트 정규화 검토 | 11장 정규화 관점 검토 | 중복, N:M, 이상 현상, 외래키 검토 흐름 설명 | 중간 |
| 그림 7-7 | `ch07_07_ai_review_report_flow.svg` | AI 활용 및 검토 보고 흐름 | 12장 AI 활용 방법 | AI 초안 생성 후 사람 검토와 수정 기록 흐름 설명 | 높음 |
| 그림 7-8 | `ch07_08_assessment_rubric_overview.svg` | 중간 프로젝트 평가 기준 | 14장 평가 기준 | 100점 루브릭의 평가 항목과 배점 요약 | 높음 |

---

## 3. 본문 삽입 권장 위치

| 그림 | 삽입 권장 위치 |
| --- | --- |
| 그림 7-1 | 1. 프로젝트 목표 또는 16. 프로젝트 진행 순서 |
| 그림 7-2 | 3. 요구사항 분석 |
| 그림 7-3 | 6. ERD 초안 작성 |
| 그림 7-4 | 5. 관계 분석 |
| 그림 7-5 | 7. PostgreSQL 테이블 설계 또는 10. CRUD SQL 작성 |
| 그림 7-6 | 11. 정규화 관점 검토 |
| 그림 7-7 | 12. AI 활용 방법 |
| 그림 7-8 | 14. 평가 기준 |

---

## 4. Mermaid 원본 파일 계획

| Mermaid 파일 | 대상 이미지 |
| --- | --- |
| `ch07_01_midterm_project_flow.mmd` | `ch07_01_midterm_project_flow.svg` |
| `ch07_02_requirement_to_entities.mmd` | `ch07_02_requirement_to_entities.svg` |
| `ch07_03_online_course_erd.mmd` | `ch07_03_online_course_erd.svg` |
| `ch07_04_many_to_many_enrollments.mmd` | `ch07_04_many_to_many_enrollments.svg` |
| `ch07_05_sql_validation_flow.mmd` | `ch07_05_sql_validation_flow.svg` |
| `ch07_06_normalization_review_flow.mmd` | `ch07_06_normalization_review_flow.svg` |
| `ch07_07_ai_review_report_flow.mmd` | `ch07_07_ai_review_report_flow.svg` |
| `ch07_08_assessment_rubric_overview.mmd` | `ch07_08_assessment_rubric_overview.svg` |

---

## 5. 도식 제작 후 점검 항목

```text
- 중간 프로젝트 수행 순서가 명확한가?
- 요구사항에서 엔터티가 도출되는 과정이 보이는가?
- students, instructors, courses, enrollments 관계가 정확한가?
- students와 courses의 N:M 관계가 enrollments로 해소되는 구조가 보이는가?
- SQL 실행 흐름이 설계 검증과 연결되어 있는가?
- 정규화 검토와 AI 검토가 평가 기준과 연결되는가?
- 평가 루브릭 배점이 본문과 일치하는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 07 도식 후보 8종 정리 완료
- 다음 작업: Chapter 07 Mermaid 도식 원본 8종 작성
```
