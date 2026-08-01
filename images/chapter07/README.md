# Chapter 07 이미지/도식 설계

## Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

이 문서는 Chapter 07 본문과 워크북에 사용하는 도식 자산의 역할과 정합성 기준을 정리합니다. 도식은 전체 SQL을 반복하지 않고 프로젝트 흐름의 핵심 판단을 보여 줍니다.

## 공통 원칙

- `images/SVG_STYLE_GUIDE.md`의 스타일과 접근성 기준을 따른다.
- 하나의 SVG는 하나의 핵심 메시지만 전달한다.
- 전체 SQL·요구사항 표·테스트 목록을 도식 안에 넣지 않는다.
- Mermaid 원본과 SVG의 제목·단계명·라벨을 함께 관리한다.
- 금액은 실제 결제액이 아니라 신청 시 기록 금액으로 표현한다.

## 도식 목록

| 그림 | 파일 | 제목 | 본문 역할 |
| --- | --- | --- | --- |
| 7-1 | `ch07_01_project_flow.svg` | 온라인 강의 DB 프로젝트 핵심 흐름 | 범위→설계→실행→검증 흐름 |
| 7-2 | `ch07_02_requirement_to_entities.svg` | 요구사항을 데이터 구조로 바꾸기 | 엔터티·속성·사건 도출 |
| 7-3 | `ch07_04_many_to_many_enrollments.svg` | enrollments로 N:M 관계 해소 | 학생·강의 관계와 사건 테이블 |
| 7-4 | `ch07_03_online_course_erd.svg` | 온라인 강의 수강신청 핵심 ERD | 네 테이블과 PK·FK |
| 7-5 | `ch07_06_normalization_review_flow.svg` | 프로젝트 정규화 점검 | 현재 사실과 신청 당시 사실 분리 |
| 7-6 | `ch07_05_sql_validation_flow.svg` | 샘플 데이터와 조회로 설계 검증 | 변경·자동 검증 흐름 |
| 7-7 | `ch07_07_ai_review_flow.svg` | AI 제안을 검토된 설계로 바꾸기 | AI 초안과 사람 결정 비교 |
| 7-8 | `ch07_08_project_completion_checklist.svg` | 프로젝트 완성도 점검 | 재현성·무결성·인계 기준 |

각 SVG에는 같은 이름의 Mermaid 원본 `.mmd` 파일이 함께 있습니다.

## 정합성 기준

```text
프로젝트 스키마: course_project
테이블: students, instructors, courses, enrollments
기본 샘플: 3 / 2 / 3 / 4행
최종 상태: 3 / 2 / 3 / 5행
최종 신청 상태: 1001 완료, 1004 취소, 1005 신청
금액 열: price, recorded_amount
금액 의미: 기준 가격, 신청 시 기록 금액
금액 타입: NUMERIC(12,0)
삭제 정책: RESTRICT
활성 신청: 신청·수강중 상태만 중복 제한
```

도식에서 기존 일반 표현을 유지할 수 있으나 `paid_amount` 또는 실제 결제·매출로 오해되는 표현은 사용하지 않습니다.

## 코드 파일 기준

```text
01_course_project_schema.sql
02_course_project_seed.sql
03_course_project_changes.sql
04_course_project_validation.sql
05_course_project_integrity_tests.sql
06_course_project_optional_tests.sql
reset_course_project.sql
PROJECT_DECISIONS.md
online_course_project.sql
```

## 검수 기준

- SVG가 XML 파서로 정상 로드된다.
- `width="100%"`와 `viewBox`가 유지된다.
- `role="img"`, `aria-labelledby`, `title`, `desc`가 있다.
- 긴 제목과 관계 라벨이 박스 밖으로 넘치지 않는다.
- 그림 번호와 본문 등장 순서가 일치한다.
- recorded_amount 변경이 필요한 SVG·Mermaid 텍스트가 없는지 검색한다.
- GitHub·Word·PDF·eBook 실제 렌더링은 수동 확인한다.
