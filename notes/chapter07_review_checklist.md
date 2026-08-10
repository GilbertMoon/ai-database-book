# Chapter 07 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기
```

## 1. 장의 역할

- [x] Chapter 01~06의 내용을 하나의 프로젝트로 연결한다.
- [x] 최소 완료 경로 01→02→03→04가 장 초반에 제시된다.
- [x] 핵심·선택·심화 학습이 구분된다.
- [x] 권장 분량은 24~27페이지다.
- [x] Chapter 08 실행 인계 기준이 명확하다.

## 2. 프로젝트 범위

- [x] 포함 기능과 제외 기능이 분리되어 있다.
- [x] 실제 결제·환불은 범위 밖이라고 명시한다.
- [x] 미확정 질문을 임의로 제약조건화하지 않는다.
- [x] 학생·강사 이메일 고유성은 각 테이블 내부 범위다.
- [x] 범위 ID P07-O01~O05와 발표자료 표기가 일치한다.

## 3. 한 행 의미와 관계

- [x] students 한 행은 학생 한 명이다.
- [x] instructors 한 행은 강사 한 명이다.
- [x] courses 한 행은 개설 강의 한 개다.
- [x] enrollments 한 행은 신청 사건 한 건이다.
- [x] 관계를 양방향 문장으로 설명한다.
- [x] 학생-강의 N:M 관계를 enrollments로 해소한다.
- [x] 학생101 신청 2·강의301 신청 2·강사201 강의 2를 실제 데이터로 검증한다.

## 4. 금액 의미

- [x] courses.price는 현재 강의 기준 가격이다.
- [x] enrollments.recorded_amount는 신청 시점에 신청 행에 기록한 금액이다.
- [x] recorded_amount를 실제 결제 승인액·환불 후 순액·회계 매출로 설명하지 않는다.
- [x] 금액 타입은 NUMERIC(12,0)이다.
- [x] 무료 금액 0과 NULL의 의미를 구분한다.
- [x] Chapter 07 이론·실습 강의안에서 과거 paid_amount 용어를 제거했다.
- [x] 런타임이 과거 용어를 조용히 치환하지 않고 Markdown 원본을 그대로 사용한다.

## 5. 상태와 이력

- [x] CHECK는 허용 상태값만 제한한다고 설명한다.
- [x] 상태값과 상태 전이 정책을 구분한다.
- [x] 완료·취소 행은 이력으로 유지한다.
- [x] 상태 변경 전 예상 이전 상태를 확인한다.
- [x] 상태 이력은 확장 범위로 남긴다.
- [x] 활성 중복만 부분 고유 인덱스로 차단하고 완료 이력 뒤 재신청은 허용한다.

## 6. 01 스키마 생성

- [x] ai_database_book 연결을 검사한다.
- [x] 읽기 전용 연결을 차단한다.
- [x] course_project 스키마 부재를 검사한다.
- [x] 스키마·네 테이블·인덱스 생성을 하나의 트랜잭션으로 실행한다.
- [x] 명명 제약조건 15개를 커밋 전에 확인한다.
- [x] NOT NULL 열 20개를 커밋 전에 확인한다.
- [x] 네 테이블 0행을 커밋 전에 확인한다.
- [x] `Chapter 07 course project schema creation passed` 메시지를 제공한다.
- [x] 잘못된 데이터베이스에서 실제 실행이 차단됨을 PostgreSQL 16에서 확인했다.

## 7. 02 샘플 입력

기준:

```text
students 3
instructors 2
courses 3
enrollments 4
recorded_amount 470000
학생101 신청 2
강의301 신청 2
강사201 강의 2
활성 중복 0
```

- [x] 네 테이블이 모두 비어 있을 때만 실행한다.
- [x] recorded_amount NUMERIC(12,0)을 확인한다.
- [x] 전체 INSERT와 IDENTITY 조정을 하나의 트랜잭션으로 실행한다.
- [x] 1001=수강중, 1004=신청, 1005 부재를 확인한다.
- [x] `Chapter 07 course project seed passed` 메시지를 제공한다.
- [x] 의도적 enrollments 실패 시 students/instructors/courses까지 모두 0행으로 롤백됨을 실제 확인했다.

## 8. 03 변경 시나리오

- [x] 시작 3/2/3/4와 전체 기록 금액 470000을 확인한다.
- [x] 1001·1004 예상 이전 상태를 확인한다.
- [x] 1005 부재와 학생102·강의302 활성 신청 부재를 확인한다.
- [x] 1005 INSERT, 1001 완료, 1004 취소를 하나의 트랜잭션으로 실행한다.
- [x] 최종 3/2/3/5, 590000, 취소 제외 4/440000을 확인한다.
- [x] `Chapter 07 course project changes passed` 메시지를 제공한다.
- [x] 1005 INSERT를 의도적으로 실패시켰을 때 1001·1004 상태와 4행·470000이 그대로 롤백되는 것을 실제 확인했다.

## 9. 04 자동 완료 게이트

- [x] 데이터를 변경하지 않는 반복 실행 가능한 검증 파일이다.
- [x] 명명 제약조건 15개를 확인한다.
- [x] NOT NULL 열 20개를 확인한다.
- [x] students=3 / instructors=2 / courses=3 / enrollments=5를 확인한다.
- [x] 서비스 JOIN=5를 확인한다.
- [x] 학생101=2 / 강의301=2 / 강사201=2를 확인한다.
- [x] 학생·강의·강사 고아 관계=0을 확인한다.
- [x] 필수값·공백·난이도·상태·금액 오류=0을 확인한다.
- [x] 활성 중복 신청=0을 확인한다.
- [x] 1001 완료/100000, 1004 취소/150000, 1005 신청/120000을 확인한다.
- [x] 전체 recorded_amount=590000을 확인한다.
- [x] 취소 제외 4건/440000을 확인한다.
- [x] `Chapter 07 course project validation passed` 실제 메시지를 확인했다.

## 10. 05 핵심 경계·무결성 테스트

허용:

- [x] course price=0 실제 성공
- [x] description=NULL 실제 성공
- [x] enrollment recorded_amount=0 실제 성공

실패:

- [x] 학생 이메일 중복 → uq_course_students_email
- [x] 강사 이메일 중복 → uq_course_instructors_email
- [x] 존재하지 않는 강사 → fk_course_courses_instructor
- [x] 잘못된 난이도 → chk_course_courses_level
- [x] 음수 가격 → chk_course_courses_price
- [x] 잘못된 신청 상태 → chk_course_enrollments_status
- [x] 음수 recorded_amount → chk_course_enrollments_recorded_amount
- [x] 존재하지 않는 학생 → fk_course_enrollments_student
- [x] 존재하지 않는 강의 → fk_course_enrollments_course
- [x] 두 번째 활성 신청 → uq_course_enrollments_active
- [x] 참조 중 학생 삭제 → FK/RESTRICT
- [x] 참조 중 강사 삭제 → FK/RESTRICT
- [x] 각 실패를 PostgreSQL 실제 오류와 기대 객체 이름으로 확인했다.
- [x] `Chapter 07 core integrity test baseline preserved` 실제 메시지를 확인했다.

## 11. 06 선택 경계·무결성 테스트

허용:

- [x] 공백 아닌 한 글자 학생 이름 실제 성공
- [x] 완료 이력 뒤 동일 학생·강의 재신청 실제 성공
- [x] 참조되지 않는 학생 삭제 실제 성공

실패:

- [x] 학생 이름 공백
- [x] 학생 이메일 공백
- [x] 강사 이름 공백
- [x] 강사 이메일 공백
- [x] 강사 전문 분야 공백
- [x] 강의 제목 공백
- [x] 각 실패를 PostgreSQL 실제 제약조건 이름으로 확인했다.
- [x] `Chapter 07 optional integrity test baseline preserved` 실제 메시지를 확인했다.

## 12. 초기화

- [x] ai_database_book 연결을 검사한다.
- [x] 읽기 전용 연결을 차단한다.
- [x] 삭제 전·후 객체를 표시한다.
- [x] 자식→부모 순서로 알려진 테이블만 삭제한다.
- [x] DROP SCHEMA ... CASCADE를 사용하지 않는다.
- [x] reset 전체를 명시적 트랜잭션으로 묶는다.
- [x] 예상하지 않은 객체가 있으면 스키마 삭제가 실패한다.
- [x] 예상 밖 `keep_me` 테이블을 추가한 실제 테스트에서 알려진 네 테이블까지 모두 복원되어 reset 전체가 롤백되는 것을 확인했다.

## 13. 문서와 워크북

- [x] 본문은 17개 절이다.
- [x] 구성안의 최소·선택 경로가 실제 파일과 일치한다.
- [x] 워크북은 핵심·선택·심화 활동으로 구분된다.
- [x] 워크북의 구조·관계·금액·테스트 기대값을 최신 자동 검증과 맞췄다.
- [x] PROJECT_DECISIONS.md가 P07-R/D/Q/O 체계와 일치한다.
- [x] online_course_project.sql은 보호된 읽기 전용 확인 파일이다.
- [x] 코드 README가 01~06·reset·04 완료 게이트를 설명한다.

## 14. 이론·실습 발표자료

- [x] 이론 18개 장표다.
- [x] 실습 20개 장표다.
- [x] 모든 장표에 화면 구성과 발표 스크립트가 있다.
- [x] 강의 콘텐츠 범위 ID를 P07-O04로 수정했다.
- [x] recorded_amount 의미를 실제 코드와 맞췄다.
- [x] 01~04 자동 검증 범위를 최신 코드와 맞췄다.
- [x] 05 핵심 / 06 선택 테스트 역할을 구분했다.
- [x] reset 원자적 롤백을 설명한다.
- [x] 강의안 제목이 chapter07_navigation.js 의미 단위 계획과 정적으로 대응한다.
- [x] Chapter 07 자산 버전을 20260809a로 갱신했다.
- [ ] 브라우저 이론 장표 최종 렌더링 직접 확인
- [ ] 브라우저 실습 장표 최종 렌더링 직접 확인

## 15. 스크립트·내비게이션·TTS

- [x] chapter07_navigation.js를 공통 의미 단위 데이터로 사용한다.
- [x] chapter07_script.js가 `window.PresentationTTS.normalize()`를 사용한다.
- [x] 공통 tts_pronunciation.js를 로드한다.
- [x] 공통 script_content_enhancer.js를 로드한다.
- [x] Chapter 07 JavaScript 문법 검증을 통과했다.
- [x] 런타임의 과거 금액 용어 자동 치환을 제거했다.
- [ ] 실제 장표 강조와 발표자 스크립트 창 동기화 확인
- [ ] 실제 TTS 청취 발음 확인

## 16. 이미지·도식

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

- [x] Mermaid 원본 8개 존재
- [x] SVG 결과물 8개 존재
- [x] SVG XML 파싱 성공
- [x] role="img"·viewBox·title·desc 정적 확인
- [ ] Mermaid CLI 재생성 검증
- [ ] GitHub 브라우저 실제 SVG 렌더링 확인
- [ ] Word·PDF·eBook 최종 SVG 가독성 확인

## 17. Chapter 08 실행 인계

- [x] `code/chapter08/00_check_course_project.sql`은 recorded_amount를 사용한다.
- [x] Chapter 08 실행 전 게이트를 Chapter 07 최종 DB 상태에서 실제 실행했다.
- [x] 전체 5/590000, 활성 3/340000, 취소 제외 4/440000을 실제 확인했다.
- [x] `Chapter 08 prerequisite check passed` 실제 메시지를 확인했다.
- [ ] Chapter 08 본문 일부의 과거 금액 열 표기는 Chapter 08 전체 점검 때 정리한다.

## 18. 자동 검증

```text
Workflow: Validate Chapter 07
PostgreSQL: 16
```

자동 확인 범위:

- [x] 본문 17개 절
- [x] 이론 18 / 실습 20
- [x] 장표·navigation 제목 대응
- [x] JavaScript 문법과 TTS wiring
- [x] 8개 Mermaid/SVG 쌍과 SVG 기본 접근성
- [x] 잘못된 DB 실행 차단
- [x] 01→06·호환 확인 실제 실행
- [x] 핵심·선택 경계와 실패 실제 실행
- [x] 02 전체 롤백
- [x] 03 전체 롤백
- [x] reset 전체 롤백
- [x] Chapter 08 실행 인계

정확한 최종 Run 번호·커밋은 `notes/chapter07_validation_result.md`에 기록한다.

## 19. 최종 직접 확인 필요

- [ ] 브라우저 이론·실습 장표 시각 렌더링
- [ ] 의미 단위 포커스와 발표자 창 실제 동기화
- [ ] TTS 실제 청취
- [ ] GitHub SVG 실제 렌더링
- [ ] Word·PDF·eBook 최종 렌더링
- [ ] 최종 편집 분량 24~27페이지 확인


---

## 최종 출판 보완 (2026-08-10)

- [x] P07-D01 무료 금액의 0 / NULL / 음수 의미 구분
- [x] P07-D02 신규 신청 시 `courses.price` → `recorded_amount` 복사 흐름 명시
- [x] 교차 테이블 CHECK로 과거 금액을 강제하지 않는 이유 설명
- [x] 01의 데이터베이스 CREATE 권한 사전 검사
- [x] 05·06 시작 시 제약조건 15·NOT NULL 20 구조 재확인
- [x] 대표 NOT NULL 실패 예제 추가
- [x] 부분 고유 인덱스와 UNIQUE 제약조건 구분
- [x] Chapter 07 자동 스크립트 보강 비활성화
- [x] 최신 PostgreSQL 16 전체 경로 재검증 성공 — publication smoke Run 2 / Run ID 31375936249


---

## 최종 출판 PostgreSQL 재검증 (2026-08-10)

- [x] 데이터베이스 `CREATE` 권한 없는 역할에서 01 실행 거부 및 스키마 미생성 확인
- [x] 01 → 02 → 03 → 04 → 05 → 06 전체 경로 PostgreSQL 16 실행 성공
- [x] 신청 1005 `recorded_amount = 120000` 및 강의 302 현재 `price = 120000` 확인
- [x] 명명 제약조건 15개·NOT NULL 열 20개·부분 고유 인덱스 확인
- [x] 학생 이름 `NULL` 입력이 NOT NULL 위반으로 실제 거부됨
- [x] Chapter 08 `00_check_course_project.sql` 인계 게이트 통과
- [x] Chapter 07 스크립트 자동 문장 보강 비활성화 정적 확인

```text
Workflow: Chapter 07 publication SQL smoke once
Run: 2
Run ID: 31375936249
PostgreSQL: 16
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
```
