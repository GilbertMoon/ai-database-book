# Chapter 07 전체 점검·반영 기록

## Chapter

```text
Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기
```

## 전체 점검 범위

Chapter 07을 다음 흐름으로 다시 대조했다.

```text
프로젝트 범위
→ 요구사항·결정·질문
→ 한 행 의미와 관계
→ ERD·정규화
→ 제약조건·부분 고유 인덱스
→ 01 구조 생성
→ 02 기준 샘플
→ 03 변경 시나리오
→ 04 자동 완료 게이트
→ 05 핵심 경계·오류 테스트
→ 06 선택 경계 테스트
→ 안전한 초기화
→ 발표자료·스크립트·TTS
→ Chapter 08 실행 인계
```

검토 대상:

```text
book/chapter07/chapter07.md
book/chapter07/chapter07_outline.md
book/chapter07/chapter07_activity.md
book/chapter07/chapter07_review_revision.md
notes/chapter07_review_checklist.md

code/chapter07/01_course_project_schema.sql
code/chapter07/02_course_project_seed.sql
code/chapter07/03_course_project_changes.sql
code/chapter07/04_course_project_validation.sql
code/chapter07/05_course_project_integrity_tests.sql
code/chapter07/06_course_project_optional_tests.sql
code/chapter07/reset_course_project.sql
code/chapter07/online_course_project.sql
code/chapter07/PROJECT_DECISIONS.md
code/chapter07/README.md

images/chapter07/*.mmd
images/chapter07/*.svg
images/chapter07/README.md

presentation/chapter07/chapter07_theory_lecture_plan.md
presentation/chapter07/chapter07_practice_lecture_plan.md
presentation/chapter07/chapter07_slides.js
presentation/chapter07/chapter07_navigation.js
presentation/chapter07/chapter07_player.js
presentation/chapter07/chapter07_script.html
presentation/chapter07/chapter07_script.js
presentation/chapter07/chapter07_theory_presentation.html
presentation/chapter07/chapter07_practice_presentation.html

code/chapter08/00_check_course_project.sql
.github/workflows/validate-chapter07.yml
```

---

## 1. 본문·구성안·워크북

본문의 17개 절 구조와 최소 완료 경로는 유지했다.

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

선택 실습은 다음으로 분리한다.

```text
05_course_project_integrity_tests.sql
→ 핵심 요구사항의 경계·오류 테스트

06_course_project_optional_tests.sql
→ 허용 경계와 공백 문자열 세부 테스트
```

구성안과 워크북은 실제 코드의 자동 검증 범위에 맞춰 다음 내용을 추가·정리했다.

```text
01: 명명 제약조건 15개 / NOT NULL 열 20개 / 네 테이블 0행
02: 3/2/3/4 / 470000 / 관계 반복 2·2·2
03: 3/2/3/5 / 590000 / 취소 제외 4건·440000
04: 구조·관계·도메인·상태·금액 자동 완료 게이트
05: 핵심 실패 규칙 12종
06: 허용 경계와 공백 문자열 세부 규칙
Chapter 08: 590000 / 활성 340000 / 취소 제외 440000
```

---

## 2. 금액 의미와 용어

프로젝트의 확정 용어는 다음과 같다.

```text
courses.price
→ 현재 강의 기준 가격

enrollments.recorded_amount
→ 신청 시점에 신청 행에 기록한 금액
```

`recorded_amount`는 실제 결제 승인액, 환불 후 순수 금액, 회계 매출이 아니다. 실제 결제·환불 이력은 Chapter 07 범위에서 제외한다.

발표 강의안에 남아 있던 과거 `paid_amount` 표현과 “실제 금액” 표현을 제거했다. 런타임 JavaScript가 오래된 용어를 자동 치환해 소스 불일치를 숨기던 로직도 제거해, 앞으로는 Markdown 원본 자체가 정확해야 한다.

---

## 3. 요구사항·결정·범위

핵심 요구사항:

```text
P07-R01~P07-R09
```

핵심 프로젝트 결정:

```text
P07-D01~P07-D06
```

대표 미확정 질문:

```text
P07-Q01~P07-Q03
```

범위 제외:

```text
P07-O01~P07-O05
```

이론 발표자료에서 강의 콘텐츠·진도·수료를 잘못 `P07-O05`로 표시하던 부분을 `P07-O04`로 수정했다.

---

## 4. 01 스키마 생성

`01_course_project_schema.sql`은 다음을 확인한다.

```text
현재 DB = ai_database_book
읽기 전용 연결 아님
course_project 스키마 미존재
```

스키마·네 테이블·부분 고유 인덱스를 하나의 트랜잭션으로 생성한다.

커밋 전 자동 판정:

```text
students / instructors / courses / enrollments 존재
uq_course_enrollments_active 존재
명명 제약조건 = 15
NOT NULL 열 = 20
네 테이블 = 모두 0행
```

통과 메시지:

```text
Chapter 07 course project schema creation passed
```

---

## 5. 02 기준 샘플

`02_course_project_seed.sql`은 네 테이블이 모두 비어 있을 때만 실행된다.

전체 입력과 IDENTITY 다음 값 조정을 하나의 트랜잭션으로 처리한다.

커밋 전 기준:

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

통과 메시지:

```text
Chapter 07 course project seed passed
```

---

## 6. 03 변경 시나리오

시작 상태에서 470000과 3/2/3/4를 함께 확인한다.

변경:

```text
1005: 학생 102 → 강의 302 신규 신청
1001: 수강중 → 완료
1004: 신청 → 취소
```

세 변경과 IDENTITY 조정을 하나의 트랜잭션으로 처리한다.

최종 기준:

```text
students = 3
instructors = 2
courses = 3
enrollments = 5
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
활성 중복 = 0
전체 recorded_amount = 590000
취소 제외 = 4건 / 440000
```

통과 메시지:

```text
Chapter 07 course project changes passed
```

---

## 7. 04 자동 완료 게이트

`04_course_project_validation.sql`은 읽기 전용 검증 파일이다.

자동 확인:

```text
명명 제약조건 15
NOT NULL 열 20
최종 행 수 3/2/3/5
서비스 JOIN 결과 5
학생101 신청 2
강의301 신청 2
강사201 강의 2
학생·강의·강사 고아 관계 0
필수값·공백·난이도·상태·금액 오류 0
활성 중복 0
1001·1004·1005 상태와 기록 금액
전체 590000
취소 제외 4 / 440000
```

통과 메시지:

```text
Chapter 07 course project validation passed
```

---

## 8. 05 핵심 경계·오류 테스트

기본 실행은 데이터를 바꾸지 않고 최종 기준 상태를 먼저 확인한다.

허용 경계:

```text
course price = 0
course description = NULL
enrollment recorded_amount = 0
```

핵심 실패 사례:

```text
학생 이메일 중복
강사 이메일 중복
존재하지 않는 강사 참조
잘못된 강의 난이도
음수 강의 가격
잘못된 신청 상태
음수 신청 기록 금액
존재하지 않는 학생 참조
존재하지 않는 강의 참조
같은 학생·강의의 두 번째 활성 신청
참조 중인 학생 삭제
참조 중인 강사 삭제
```

테스트 뒤 기준 상태가 유지되면 다음 메시지를 사용한다.

```text
Chapter 07 core integrity test baseline preserved
```

---

## 9. 06 선택 경계·무결성 테스트

허용:

```text
description = NULL
공백이 아닌 한 글자 학생 이름
완료 이력 뒤 동일 학생·강의 재신청
참조되지 않는 학생 삭제
```

실패:

```text
학생 이름 공백
학생 이메일 공백
강사 이름 공백
강사 이메일 공백
강사 전문 분야 공백
강의 제목 공백
```

테스트 뒤 기준 상태가 유지되면 다음 메시지를 사용한다.

```text
Chapter 07 optional integrity test baseline preserved
```

---

## 10. 초기화

`reset_course_project.sql`도 명시적 트랜잭션으로 변경했다.

```text
현재 DB 확인
→ 읽기 전용 확인
→ 알려진 테이블을 자식→부모 순서로 삭제
→ DROP SCHEMA course_project
→ COMMIT
```

`CASCADE`는 사용하지 않는다. 예상하지 않은 객체가 남아 있으면 스키마 삭제가 실패하고 앞서 삭제한 알려진 테이블도 전체 롤백된다.

통과 메시지:

```text
Chapter 07 course project reset passed
```

---

## 11. 호환 확인 파일

`online_course_project.sql`은 프로젝트 생성 파일이 아니라 최종 상태를 조회하는 기존 링크 호환 파일이다.

현재 DB, 프로젝트 객체, `recorded_amount NUMERIC(12,0)` 존재 여부를 먼저 확인하고 읽기 전용 조회를 수행한다.

자동 완료 판정의 기준 파일은 계속 `04_course_project_validation.sql`이다.

---

## 12. 발표자료·스크립트·TTS

이론 18장, 실습 20장 구조를 유지했다.

반영 내용:

```text
P07-O04 범위 ID 수정
paid_amount 잔존 제거
recorded_amount 의미 정리
03의 명시적 트랜잭션 설명
04를 단순 조회가 아닌 자동 완료 게이트로 설명
05 핵심 / 06 선택 테스트 역할 분리
reset 원자적 롤백 설명
Chapter 08 인계 기준 추가
```

`chapter07_slides.js`의 용어 자동 치환은 제거했다. 강의안 Markdown이 그대로 런타임 장표와 스크립트의 원본이 된다.

공통 발표 인프라:

```text
chapter07_navigation.js
chapter07_script.js
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js
```

Chapter 07 자체 자산 버전은 `20260809a`로 갱신했다.

---

## 13. 이미지·도식

8개 Mermaid 원본과 8개 SVG 결과물을 유지한다.

```text
ch07_01_project_flow
ch07_02_requirement_to_entities
ch07_03_online_course_erd
ch07_04_many_to_many_enrollments
ch07_05_sql_validation_flow
ch07_06_normalization_review_flow
ch07_07_ai_review_flow
ch07_08_project_completion_checklist
```

자동 검증에서는 파일 쌍 존재, SVG XML 파싱, `role="img"`, `viewBox`, `title`, `desc`를 확인한다.

---

## 14. Chapter 08 실행 인계

Chapter 08의 실행 전 게이트:

```text
code/chapter08/00_check_course_project.sql
```

이 파일은 현재 Chapter 07 스키마와 동일하게 `recorded_amount`를 사용한다.

인계 기준:

```text
전체 신청 = 5 / 590000
활성 신청 = 3 / 340000
취소 제외 = 4 / 440000
```

통과 메시지:

```text
Chapter 08 prerequisite check passed
```

Chapter 08 본문 일부에 과거 금액 열 이름이 남아 있는 것은 Chapter 08 전체 개편에서 별도로 정리할 후속 편집 항목이다. Chapter 07의 실제 실행 인계 SQL은 현재 구조와 일치한다.

---

## 15. 자동 검증

전용 workflow:

```text
.github/workflows/validate-chapter07.yml
```

검증 범위:

```text
본문 17개 절
이론 18장 / 실습 20장
강의안 제목과 의미 단위 navigation 대응
JavaScript 문법
TTS·script enhancer 연결
Chapter 07 용어 정합성
01~06·reset·호환 파일 정적 안전 구조
Mermaid/SVG 8쌍과 SVG 접근성 기본 속성
잘못된 데이터베이스 보호
PostgreSQL 16에서 01→06 실제 실행
핵심·선택 경계값 실제 성공
금지 데이터 실제 실패와 기대 제약조건 이름
02 샘플 입력 전체 롤백
03 변경 시나리오 전체 롤백
예상 밖 객체가 있을 때 reset 전체 롤백
Chapter 08 실행 전 게이트 실제 통과
```

정확한 최종 Actions 실행 번호와 커밋은 `notes/chapter07_validation_result.md`에 기록한다.

---

## 16. 자동 검증과 별도 직접 확인의 구분

자동·PostgreSQL 검증과 별도로 다음은 직접 확인이 필요하다.

```text
브라우저 이론 장표 최종 시각 렌더링
브라우저 실습 장표 최종 시각 렌더링
의미 단위 강조와 발표자 스크립트 창 실제 동기화
TTS 실제 청취 발음
GitHub에서 SVG 최종 가독성
Word·PDF·eBook 최종 렌더링
최종 편집 분량 24~27페이지 여부
```

실제로 확인하지 않은 항목은 완료로 표시하지 않는다.


---

## 최종 출판 검수 추가 반영 (2026-08-10)

- P07-D01을 “무료 금액은 0, NULL·음수 금지”로 정밀화했다.
- 할인 기능이 없는 현재 범위에서 신규 신청은 `courses.price`를 조회해 `recorded_amount`로 복사하도록 P07-D02와 03 변경 SQL을 일치시켰다.
- `recorded_amount` 복사는 교차 테이블 `CHECK`가 아니라 신청 생성 SQL의 책임이라는 경계를 명시했다.
- `01_course_project_schema.sql`에 현재 역할의 데이터베이스 `CREATE` 권한 사전 검사를 추가했다.
- 05·06 테스트 시작 시 명명 제약조건 15개와 NOT NULL 열 20개를 다시 확인하도록 보강했다.
- 05 핵심 테스트에 대표 NOT NULL 실패 예제를 추가했다.
- 부분 고유 인덱스를 `UNIQUE` 제약조건과 구분해 설명했다.
- Chapter 07 발표 스크립트에서는 공통 자동 문장 보강을 비활성화해 작성된 스크립트만 사용하도록 했다.
- 독자 프로젝트 워크북 링크와 실행 역할 주의사항을 추가했다.


---

## 최종 출판 DB 재검증 완료 (2026-08-10)

최종 보완본을 PostgreSQL 16에서 다시 실행해 DB `CREATE` 권한 보호, 01~06 전체 경로, 현재 강의 가격의 `recorded_amount` 캡처, 대표 `NOT NULL` 실패, 구조 기준, Chapter 08 인계 게이트를 모두 확인했다. publication smoke Run 2(ID 31375936249)는 `success`로 완료됐다.
