# Chapter 07 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 07
Run: 4
Run ID: 31281070109
Commit: 7d0f795596e811293798fdee88925df4396077ee
Status: completed
Conclusion: success
Date: 2026-08-09 (Asia/Seoul)
PostgreSQL: 16
```

## 최종 통과 범위

### 정적 일관성

```text
- Chapter 07 본문 17개 절 순서
- P07-R01~R09 / P07-D01~D06 핵심 용어
- 본문 recorded_amount / NUMERIC(12,0) 정합성
- Chapter 07 본문·이론·실습 강의안의 paid_amount 잔존 차단
- 이론 발표 강의안 18개 절
- 실습 발표 강의안 20개 절
- 각 장표의 화면 구성·발표 스크립트 존재
- 강의안 제목과 chapter07_navigation.js 의미 단위 제목 대응
- Chapter 07 JavaScript 문법
- 발표자 script의 공통 TTS normalization 사용
- script_content_enhancer 연결
- Chapter 07 자산 버전 20260809a
- 01~06·reset·호환 확인 파일 존재와 정적 안전 구조
- Mermaid 원본 8개와 SVG 결과물 8개 존재
- SVG XML 파싱·role=img·viewBox·title·desc
- Chapter 08 실행 전 게이트의 recorded_amount·590000·340000·440000 기준
```

## PostgreSQL 실제 기본 경로

다음 순서를 PostgreSQL 16에서 실제 실행했다.

```text
reset_course_project.sql
→ 01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
→ 05_course_project_integrity_tests.sql
→ 06_course_project_optional_tests.sql
→ online_course_project.sql
→ code/chapter08/00_check_course_project.sql
```

실제 통과 메시지:

```text
Chapter 07 course project reset passed
Chapter 07 course project schema creation passed
Chapter 07 course project seed passed
Chapter 07 course project changes passed
Chapter 07 course project validation passed
Chapter 07 core integrity test baseline preserved
Chapter 07 optional integrity test baseline preserved
Chapter 08 prerequisite check passed
```

## 실제 구조 기준

01 실행 후 실제 검증 기준:

```text
course_project 스키마 존재
students / instructors / courses / enrollments 존재
uq_course_enrollments_active 존재
명명 제약조건 = 15
NOT NULL 열 = 20
네 테이블 모두 0행
```

## 실제 샘플 상태

02 실행 후:

```text
students = 3
instructors = 2
courses = 3
enrollments = 4
recorded_amount 합계 = 470000
학생 101 신청 = 2
강의 301 신청 = 2
강사 201 강의 = 2
활성 중복 = 0
1001 = 수강중
1004 = 신청
1005 = 없음
```

## 실제 최종 상태

03·04 실행 후:

```text
students = 3
instructors = 2
courses = 3
enrollments = 5
서비스 JOIN = 5
학생 101 신청 = 2
강의 301 신청 = 2
강사 201 강의 = 2
고아 관계 = 0
활성 중복 = 0
1001 = 완료 / recorded_amount 100000
1004 = 취소 / recorded_amount 150000
1005 = 신청 / recorded_amount 120000
전체 recorded_amount = 590000
취소 제외 = 4건 / recorded_amount 440000
```

## 실제 허용 경계값 성공

다음 값을 PostgreSQL 16에서 실제 저장·정리했다.

```text
course.price = 0
course.description = NULL
enrollment.recorded_amount = 0
공백이 아닌 한 글자 학생 이름
완료 이력 뒤 동일 학생·강의 재신청
참조되지 않는 학생 삭제
```

## 실제 오류값 거부

다음 오류 SQL이 실제 PostgreSQL에서 실패하고 기대 제약조건 또는 인덱스 이름을 확인했다.

```text
1. 학생 이메일 중복 → uq_course_students_email
2. 강사 이메일 중복 → uq_course_instructors_email
3. 존재하지 않는 강사 참조 → fk_course_courses_instructor
4. 잘못된 강의 난이도 → chk_course_courses_level
5. 음수 강의 가격 → chk_course_courses_price
6. 잘못된 신청 상태 → chk_course_enrollments_status
7. 음수 recorded_amount → chk_course_enrollments_recorded_amount
8. 존재하지 않는 학생 참조 → fk_course_enrollments_student
9. 존재하지 않는 강의 참조 → fk_course_enrollments_course
10. 같은 학생·강의의 두 번째 활성 신청 → uq_course_enrollments_active
11. 참조 중인 학생 삭제 → fk_course_enrollments_student
12. 참조 중인 강사 삭제 → fk_course_courses_instructor
13. 학생 이름 공백 → chk_course_students_name_not_blank
14. 학생 이메일 공백 → chk_course_students_email_not_blank
15. 강사 이름 공백 → chk_course_instructors_name_not_blank
16. 강사 이메일 공백 → chk_course_instructors_email_not_blank
17. 강사 전문 분야 공백 → chk_course_instructors_specialty_not_blank
18. 강의 제목 공백 → chk_course_courses_title_not_blank
```

실패 테스트 뒤 04·05·06을 다시 실행해 정상 기준 상태가 유지되는 것도 확인했다.

## 잘못된 데이터베이스 보호 실제 확인

`postgres` 데이터베이스에서 `01_course_project_schema.sql`을 실행했다.

결과:

```text
실행 실패
→ ai_database_book 연결 안내
→ postgres 데이터베이스에는 course_project 스키마가 생성되지 않음
```

## 02 샘플 입력 원자성 실제 확인

`course_project.enrollments` 입력을 강제로 실패시키는 임시 CHECK를 추가한 뒤 02를 실행했다.

결과:

```text
02 실행 실패
students = 0
instructors = 0
courses = 0
enrollments = 0
```

따라서 부모 테이블 데이터만 일부 남지 않고 전체 샘플 입력이 롤백되는 것을 확인했다.

## 03 변경 시나리오 원자성 실제 확인

신규 신청 ID 1005가 실패하도록 임시 CHECK를 추가한 뒤 03을 실행했다.

결과:

```text
03 실행 실패
enrollments = 4
recorded_amount = 470000
1001 = 수강중
1004 = 신청
1005 = 없음
```

따라서 신규 신청 실패 전에 수행된 다른 변경이 일부만 남지 않고 변경 트랜잭션 전체가 롤백되는 것을 확인했다.

## reset 원자성 실제 확인

예상하지 않은 객체를 추가했다.

```text
course_project.keep_me
```

그 상태에서 `reset_course_project.sql`을 실행했다.

결과:

```text
reset 실패
students 존재
instructors 존재
courses 존재
enrollments 존재
keep_me 존재
```

즉 알려진 테이블을 먼저 삭제했더라도 예상 밖 객체 때문에 `DROP SCHEMA`가 실패하면 삭제 작업 전체가 롤백되는 것을 확인했다.

예상 밖 객체를 제거한 뒤 reset을 다시 실행하면 정상적으로 완료됐다.

## Chapter 08 실행 인계 실제 확인

Chapter 07 최종 상태를 다시 생성한 뒤 다음 파일을 실제 실행했다.

```text
code/chapter08/00_check_course_project.sql
```

실제 확인 기준:

```text
전체 신청 = 5 / recorded_amount 590000
활성 신청 = 3 / recorded_amount 340000
취소 제외 = 4 / recorded_amount 440000
```

통과 메시지:

```text
Chapter 08 prerequisite check passed
```

Chapter 08의 실행 가능한 사전검사 SQL은 Chapter 07의 현재 `recorded_amount` 구조와 일치한다.

## 검토 과정에서 수정한 주요 문제

### 1. 발표자료 원본의 과거 paid_amount 용어

기존 이론·실습 강의안 일부에 `paid_amount`와 결제 금액 의미가 남아 있었다.

현재:

```text
recorded_amount
→ 신청 시점에 신청 행에 기록한 금액
→ 실제 결제 승인액·환불 후 순수 금액·회계 매출 아님
```

런타임 JavaScript에서 과거 용어를 자동 치환하던 로직도 제거했다. 앞으로 원본 Markdown 자체가 정확해야 한다.

### 2. 범위 제외 ID 불일치

이론 발표자료에서 강의 콘텐츠·진도·수료를 `P07-O05`로 표시하던 부분을 본문·프로젝트 결정 문서와 동일한 `P07-O04`로 수정했다.

### 3. 05·06 테스트 역할 혼합

핵심 테스트와 선택 테스트의 책임을 분명히 했다.

```text
05 → 핵심 요구사항의 경계·오류
06 → 허용 경계와 공백 문자열 세부 규칙
```

### 4. reset 부분 삭제 위험

기존 reset은 알려진 테이블을 삭제한 뒤 예상 밖 객체에서 실패할 경우 클라이언트 실행 방식에 따라 부분 삭제 위험을 설명하기 어려웠다.

현재 전체 reset을 명시적 트랜잭션으로 묶어 예상 밖 객체가 있으면 알려진 테이블 삭제까지 함께 롤백되도록 했다.

## 정적·DB 검증과 별도 직접 확인의 구분

Run 4 성공으로 저장소 내용과 PostgreSQL 실행 의미는 검증했다.

다음은 자동 검증이 대신할 수 없는 별도 직접 확인 항목이다.

```text
- 브라우저 이론 발표자료 최종 시각 렌더링
- 브라우저 실습 발표자료 최종 시각 렌더링
- 의미 단위 포커스와 발표자 스크립트 창의 실제 동기화
- TTS 실제 청취 발음
- Mermaid CLI 재생성 결과
- GitHub 브라우저 SVG 실제 가독성
- Word·PDF·eBook 최종 렌더링
- 최종 편집 분량 24~27페이지 여부
```

또한 Chapter 08 본문 일부의 과거 금액 열 표기는 Chapter 08 전체 점검에서 별도로 정리한다. Chapter 07에서 사용하는 Chapter 08 실행 전 게이트 SQL은 현재 구조와 실제 실행이 모두 검증됐다.

실제 확인하지 않은 항목은 “통과”로 표시하지 않는다.
