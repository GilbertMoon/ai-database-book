# Chapter 07 이미지/도식 설계

## Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

이 문서는 Chapter 07 본문과 워크북에 사용하는 도식 자산을 정리합니다. 도식은 요구사항을 데이터 구조로 바꾸고, 전용 PostgreSQL 스키마와 테스트 데이터로 프로젝트를 검증하는 흐름을 보여 줍니다.

## 공통 원칙

- `images/SVG_STYLE_GUIDE.md`의 스타일과 접근성 기준을 따른다.
- 하나의 SVG는 하나의 핵심 메시지만 전달한다.
- 본문 표나 SQL 전체를 도식 안에 반복하지 않는다.
- 모든 텍스트는 SVG 박스 안에 들어가도록 줄 수와 글자 크기를 제한한다.
- Mermaid 원본과 SVG 결과물의 제목, 단계명과 분기 라벨을 함께 관리한다.
- 전용 스키마와 단계별 파일 구조는 표·코드로 설명하고 도식에는 과도하게 넣지 않는다.

## 도식 목록

| 그림 번호 | 파일명 | 도식 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 7-1 | `ch07_01_project_flow.svg` | 온라인 강의 DB 프로젝트 핵심 흐름 | 범위에서 검증까지 전체 흐름 |
| 그림 7-2 | `ch07_02_requirement_to_entities.svg` | 요구사항을 데이터 구조로 바꾸기 | 엔터티·속성·사건 도출 |
| 그림 7-3 | `ch07_04_many_to_many_enrollments.svg` | enrollments로 학생-강의 N:M 관계 해소 | 관계 문장과 연결 테이블 |
| 그림 7-4 | `ch07_03_online_course_erd.svg` | 온라인 강의 수강신청 핵심 ERD | 네 테이블과 PK·FK 확인 |
| 그림 7-5 | `ch07_06_normalization_review_flow.svg` | 온라인 강의 프로젝트 정규화 점검 | 현재 사실과 신청 당시 사실 분리 |
| 그림 7-6 | `ch07_05_sql_validation_flow.svg` | 샘플 데이터와 조회로 설계 검증 | 정상·변경 데이터 검증 |
| 그림 7-7 | `ch07_07_ai_review_flow.svg` | AI 제안을 검토된 설계로 바꾸기 | AI 제안과 사람 결정 비교 |
| 그림 7-8 | `ch07_08_project_completion_checklist.svg` | 온라인 강의 DB 프로젝트 완성도 점검 | 재현성·무결성·인계 기준 점검 |

각 SVG에는 같은 이름의 Mermaid 원본 `.mmd` 파일이 함께 있습니다.

## 2차 재구성 정합성 기준

```text
프로젝트 스키마: course_project
테이블: students, instructors, courses, enrollments
기본 샘플: 3 / 2 / 3 / 4행
최종 상태: 3 / 2 / 3 / 5행
최종 신청 상태: 1001 완료, 1004 취소, 1005 신청
기본키: IDENTITY
삭제 정책: RESTRICT
재신청 복합 UNIQUE: 미적용
```

도식은 일반적인 테이블 이름을 유지할 수 있지만, 본문과 SQL에서는 `course_project.<table>`을 명확히 사용합니다.

## 코드 파일 기준

```text
01_course_project_schema.sql
02_course_project_seed.sql
03_course_project_changes.sql
04_course_project_validation.sql
05_course_project_integrity_tests.sql
reset_course_project.sql
PROJECT_DECISIONS.md
online_course_project.sql
```

기존 `online_course_project.sql`은 자동 삭제·생성 파일이 아니라 안내와 최종 확인 파일입니다.

## 검수 기준

- SVG가 XML 파서로 정상 로드된다.
- `width="100%"`와 `viewBox`가 유지된다.
- `role="img"`, `aria-labelledby`, `title`, `desc`가 있다.
- 글꼴은 Windows 한글 렌더링을 고려한 스택을 사용한다.
- 본문 그림 번호와 README 순서가 일치한다.
- 긴 제목과 관계 라벨이 박스 밖으로 넘치지 않는다.
- GitHub·Word·PDF·eBook 실제 렌더링은 수동 확인한다.
