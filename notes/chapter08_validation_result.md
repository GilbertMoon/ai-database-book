# Chapter 08 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 08
Run: 5
Run ID: 31282383450
Commit: fb41fb74c31624efb533f4cc467141cde16e49bb
Status: completed
Conclusion: success
Date: 2026-08-09 (Asia/Seoul)
PostgreSQL: 16
```

## 최종 통과 범위

### 정적 정합성

```text
- Chapter 08 본문 23개 절
- 이론 발표 강의안 20개 절
- 실습 발표 강의안 20개 절
- 모든 발표 절에 화면 구성·발표 스크립트 존재
- Chapter 08 학습·실행 소스의 현재 금액 열 이름 = recorded_amount
- 전체 590000 / 활성 340000 / 취소 제외 440000 기준값 정합성
- recorded_amount = NUMERIC(12,0) 설명
- JavaScript 문법
- 발표 자산 버전 = 20260809a
- 발표자 스크립트의 공통 TTS normalization 사용
- script_content_enhancer 연결
- 스크립트 창에서 발표 창을 열 때 동일 자산 버전 전달
- 00·01·02·03·호환 SQL 파일 존재
- Chapter 08 조회 SQL에 DML·DDL 문장 없음
- Mermaid 8개 / SVG 8개 파일 쌍
- SVG XML 파싱, width=100%, viewBox, role=img, title, desc
- 현재 본문 핵심 도식 01·03·07·08 경로 존재
```

## PostgreSQL 16 실제 실행

### 1. 잘못된 데이터베이스 보호

`postgres` 데이터베이스에서 다음 파일을 실행했습니다.

```text
code/chapter08/00_check_course_project.sql
```

결과:

```text
실행 실패
→ ai_database_book 연결 안내
```

따라서 Chapter 08 실습을 잘못된 데이터베이스에서 시작하지 않도록 사전 보호가 동작함을 확인했습니다.

### 2. Chapter 07 기준 상태 실제 생성

PostgreSQL 16에서 다음 순서를 실제 실행했습니다.

```text
code/chapter07/01_course_project_schema.sql
→ code/chapter07/02_course_project_seed.sql
→ code/chapter07/03_course_project_changes.sql
→ code/chapter07/04_course_project_validation.sql
```

Chapter 07 최종 상태:

```text
students = 3
instructors = 2
courses = 3
enrollments = 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 recorded_amount = 590000
활성 = 3 / 340000
취소 제외 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

### 3. Chapter 08 전체 경로 READ ONLY 실행

다음 Chapter 08 경로를 하나의 PostgreSQL 읽기 전용 트랜잭션에서 실제 실행했습니다.

```text
BEGIN TRANSACTION READ ONLY
→ 00_check_course_project.sql
→ 01_join_queries.sql
→ 02_aggregation_queries.sql
→ 03_join_aggregation_validation.sql
→ join_aggregation_practice.sql
→ ROLLBACK
```

결과:

```text
Chapter 08 prerequisite check passed
Chapter 08 join and aggregation validation passed
```

실행 전후 `course_project.enrollments`의 행 수·금액·상태 스냅샷이 동일한 것도 확인했습니다. 즉 Chapter 08의 실습 경로가 Chapter 07 기준 데이터를 변경하지 않는 조회 전용 경로임을 실제로 확인했습니다.

## 00 사전 게이트 실제 검증 기준

실제 자동 확인 기준:

```text
current_database = ai_database_book
네 프로젝트 테이블 존재
uq_course_enrollments_active 존재
recorded_amount = NUMERIC(12,0)
rows = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 = 5 / 590000 / 평균 118000.00
활성 = 3 / 340000
취소 제외 = 4 / 440000
고아 관계 = 0 / 0 / 0
활성 중복 = 0
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

통과 메시지:

```text
Chapter 08 prerequisite check passed
```

## 03 자동 완료 게이트 실제 검증 기준

실제 자동 확인 기준:

```text
상세 신청 = 5
상태별 건수 합 = 5
상세 recorded_amount = 590000
강의별 recorded_amount 합 = 590000
활성 상세·그룹 = 3 / 340000
취소 제외 상세·강의별 = 4 / 440000
INNER JOIN = 5
고아 관계 = 0 / 0 / 0
anti-join LEFT JOIN 방식 = 1
anti-join NOT EXISTS 방식 = 1
ON 조건 학생 = 3
WHERE 조건 학생 = 2
강의 301 = 2건 / 2명 / 200000
강의 302 = 2건 / 2명 / 240000
강의 303 = LEFT JOIN 1행 / 실제 신청 0 / 학생 0 / 기록 금액 0
강사 201 = 강의 2 / 신청 4 / 취소 제외 4
강사 202 = 강의 1 / 신청 1 / 취소 제외 0
```

통과 메시지:

```text
Chapter 08 join and aggregation validation passed
```

## 기준 상태 드리프트 차단 실제 확인

신청 1002의 상태를 임시로 `완료`로 변경해 Chapter 07 기준 상태를 의도적으로 깨뜨렸습니다.

결과:

```text
00_check_course_project.sql 실패
```

원래 `신청` 상태로 복원한 뒤 다시 실행하면 다음 메시지를 확인했습니다.

```text
Chapter 08 prerequisite check passed
```

따라서 단순 행 수가 같더라도 상태 범위가 달라지면 Chapter 08 분석을 시작하지 않도록 보호됨을 실제 확인했습니다.

## 집계값 드리프트 차단 실제 확인

신청 1005의 `recorded_amount`를 120000에서 120001로 임시 변경했습니다.

결과:

```text
03_join_aggregation_validation.sql 실패
```

120000으로 복원한 뒤 다시 실행하면 다음 메시지를 확인했습니다.

```text
Chapter 08 join and aggregation validation passed
```

따라서 JOIN 결과 행 수가 같더라도 금액 집계가 기준과 다르면 완료로 판정하지 않는 것을 실제 확인했습니다.

## 최종 재검산

최종 실제 상태:

```text
전체 신청 = 5
전체 recorded_amount = 590000
활성 신청 = 3
활성 recorded_amount = 340000
취소 제외 = 4
취소 제외 recorded_amount = 440000
```

정확한 최종 검산 문자열:

```text
5:590000:3:340000:4:440000
```

## 검토 과정에서 수정한 주요 문제

```text
1. Chapter 08 문서·발표자료·도식의 과거 금액 열 이름을 recorded_amount로 정리
2. 본문의 AVG 설명을 현재 NUMERIC(12,0) 구조에 맞춤
3. 현재 본문에서 사용하는 JOIN 도식의 열 이름 정합성 수정
4. 00 파일을 Chapter 07 최종 상태 자동 사전 게이트로 강화
5. 03 파일을 조회 예제 모음에서 실제 자동 완료 게이트로 강화
6. 실습 발표자료에서 recorded_amount 실제 열 이름과 03 통과 메시지를 직접 연결
7. 발표 자산 버전을 20260809a로 통일하고 팝업 발표 창에도 전달
8. Chapter 08 전체 조회 경로를 READ ONLY 트랜잭션에서 검증하도록 전용 Actions 추가
```

## 초기 검증에서 발견된 사항

초기 Validate Chapter 08 실행에서는 다음 정합성 문제가 순차적으로 발견됐습니다.

```text
- 실습 발표 강의안에서 실제 열 이름 recorded_amount를 직접 보여 주지 않음
- 이미지 README가 현재 열 이름을 명시하지 않음
- 검수 기록 자체에 과거 열 이름 문자열이 남아 정적 검색에 잡힘
```

각 항목을 현재 의미에 맞게 수정한 뒤 최신 Run 5에서 정적·PostgreSQL 검증을 모두 통과했습니다.

## 자동 검증으로 확인하지 않은 항목

다음은 실제 출력·조작 환경에서 별도 확인합니다.

```text
브라우저 이론 20장 / 실습 20장 최종 시각 렌더링
단계별 강조와 발표자 창 동기화 실제 조작
TTS 실제 음성 청취
모바일·프로젝터 화면 가독성
SVG의 실제 화면·인쇄 가독성
Word·PDF·eBook 표·코드·SVG 최종 렌더링
```


---

## 2026-08-10 최종 출판 재검증

Chapter 08 최종 출판 보완 뒤 PostgreSQL 16에서 기존 전용 검증 워크플로를 다시 실행했다.

```text
Workflow: Validate Chapter 08
Run: 6
Run ID: 31378288930
Commit: 9dddfe224847e360a546a6a9e9c50e2ad9b447a4
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 07 기준 상태 실제 생성 성공
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
Chapter 08 00 → 01 → 02 → 03 → 호환 조회를 READ ONLY 트랜잭션에서 실행
실행 전후 course_project 데이터 불변
잘못된 데이터베이스에서 00 사전 게이트 차단
기준 상태 변경 시 00 차단
recorded_amount 변경 시 03 차단
전체 신청 = 5 / recorded_amount 590000
활성 신청 = 3 / recorded_amount 340000
취소 제외 = 4 / recorded_amount 440000
HAVING 취소 제외 신청 2건 이상 강의 = 2개
강사 201 신청 JOIN 뒤 잘못된 SUM(c.price) = 440000
강사 201 강의 수준 올바른 가격 합계 = 220000
강사 202 두 방식 = 150000 / 150000 (우연한 일치)
Chapter 08 authored narration 자동 확장 비활성화 정적 확인
Chapter 08 prerequisite check passed
Chapter 08 join and aggregation validation passed
```

과대 집계 예제는 이제 본문 설명에만 존재하지 않고 `03_join_aggregation_validation.sql`과 GitHub Actions에서 실제 숫자로 검증한다. 강사 202처럼 잘못된 방식과 올바른 방식의 결과가 우연히 같은 경우도 있기 때문에, 결과 숫자 하나가 맞는지만 보지 않고 합산 기준 행을 확인해야 한다.
