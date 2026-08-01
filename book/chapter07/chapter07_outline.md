# Chapter 07 구성안

## 제목

실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

## 대상 독자와 선수 지식

- Chapter 04의 기본 SQL을 실행할 수 있는 독자
- Chapter 05의 한 행 의미·관계 문장·ERD를 이해한 독자
- Chapter 06의 정규화와 기본 무결성 제약조건을 이해한 독자

## 권장 분량

24~27페이지

## 이 장의 역할

Chapter 01~06의 내용을 하나의 재현 가능한 PostgreSQL 프로젝트로 통합한다.

```text
프로젝트 범위
→ 핵심 요구사항과 결정
→ 한 행 의미·관계·ERD
→ 정규화·무결성
→ 전용 스키마·샘플
→ 안전한 변경
→ 자동 검증
→ 설계 결정 기록
```

## 최소 완료 경로

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

선택 확장:

```text
05_course_project_integrity_tests.sql
06_course_project_optional_tests.sql
PROJECT_DECISIONS.md
```

## 학습 결과

- 프로젝트의 포함·제외 범위를 정한다.
- 요구사항과 프로젝트 결정을 구분한다.
- 테이블별 한 행 의미와 관계를 설명한다.
- 전용 스키마에 프로젝트 구조를 생성한다.
- 검증 목적의 샘플 데이터를 설계한다.
- 예상 이전 상태를 확인하며 데이터를 변경한다.
- 자동 검증으로 최종 상태를 판정한다.
- 설계 결정과 실행 결과를 재현 가능하게 기록한다.

## 핵심 프로젝트 범위

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

## 핵심 요구사항

| ID | 내용 |
| --- | --- |
| P07-R01 | 학생 이름·이메일·가입일 |
| P07-R02 | 강사 이름·이메일·전문 분야 |
| P07-R03 | 강의 제목·선택 설명·난이도·기준 가격·개설일 |
| P07-R04 | 강의는 정확히 한 강사를 참조 |
| P07-R05 | 신청은 학생·강의·신청일·상태·신청 시 기록 금액 보유 |
| P07-R06 | 상태는 신청·수강중·완료·취소 |
| P07-R07 | 학생·강사 이메일은 테이블별 공백·동일 문자열 중복 금지 |
| P07-R08 | 가격과 기록 금액은 0 이상 |
| P07-R09 | 존재하는 부모만 참조 |

## 핵심 프로젝트 결정

| ID | 결정 | 구현 |
| --- | --- | --- |
| P07-D01 | 무료 금액은 0 | NOT NULL·CHECK |
| P07-D02 | 신청 시 금액은 recorded_amount에 보존 | NUMERIC(12,0) |
| P07-D03 | 진행 중 중복 신청 금지 | 부분 고유 인덱스 |
| P07-D04 | 상태 변경 시 예상 이전 상태 확인 | 조건부 UPDATE |
| P07-D05 | 학생·강사 별도 역할 | 별도 테이블 |
| P07-D06 | 참조 중 부모 삭제 제한 | RESTRICT |

## 의미 구분

```text
courses.price
→ 현재 강의 기준 가격

enrollments.recorded_amount
→ 신청 시점에 신청 행에 기록한 금액

payments·refunds
→ 실제 결제·환불 거래, 현재 범위 제외
```

## 관계

```text
instructors 1 : 0..N courses
students    1 : 0..N enrollments
courses     1 : 0..N enrollments
students N : M courses → enrollments로 해소
```

## 금액 타입

```sql
price NUMERIC(12, 0) NOT NULL
recorded_amount NUMERIC(12, 0) NOT NULL
```

## 활성 신청 규칙

```sql
CREATE UNIQUE INDEX uq_course_enrollments_active
ON course_project.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

## 본문 구성

1. 프로젝트 목표와 최소 완료 경로
2. 프로젝트 산출물과 실행 파일
3. 전용 스키마와 프로젝트 범위
4. 핵심 요구사항·결정·미확정 질문
5. 테이블별 한 행의 의미
6. 관계 문장과 ERD
7. 현재 사실과 신청 당시 사실
8. 정규화와 무결성 규칙
9. PostgreSQL 프로젝트 구조 만들기
10. 검증 목적의 샘플 데이터 입력
11. 안전한 신청과 상태 변경
12. 자동 검증으로 최종 상태 확인
13. 경계·오류 데이터 테스트
14. 설계 결정과 AI 제안 기록
15. 프로젝트 완료 점검
16. 확장 백로그
17. 핵심 정리와 Chapter 08 인계

## SQL 파일 구성

```text
code/chapter07/
├── 01_course_project_schema.sql
├── 02_course_project_seed.sql
├── 03_course_project_changes.sql
├── 04_course_project_validation.sql
├── 05_course_project_integrity_tests.sql
├── 06_course_project_optional_tests.sql
├── reset_course_project.sql
├── PROJECT_DECISIONS.md
├── online_course_project.sql
└── README.md
```

## 파일별 안전 기준

| 파일 | 시작 상태 | 완료 상태 |
| --- | --- | --- |
| 01 | course_project 없음 | 스키마·테이블·인덱스 생성 |
| 02 | 네 테이블 비어 있음 | 기본 3/2/3/4행 |
| 03 | 기본 샘플 상태 | 최종 3/2/3/5행 |
| 04 | 최종 상태 | 자동 검증 통과 |
| 05 | 최종 상태 | 핵심 경계·오류 테스트 |
| 06 | 최종 상태 | 선택 경계·오류 테스트 |
| reset | 어떤 프로젝트 상태 | 알려진 객체 삭제 |

01·02·03 파일은 전체 작업을 트랜잭션으로 묶고 시작·완료 상태를 자동 확인한다.

## 최종 데이터 기준

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료 / recorded_amount 100000
1004 취소 / recorded_amount 150000
1005 신청 / recorded_amount 120000
활성 중복 0
전체 기록 금액 590000
취소 제외 기록 금액 440000
```

## 핵심 테스트

성공:

```text
무료 강의와 무료 신청 금액 0
선택 설명 NULL
```

실패:

```text
학생 이메일 중복
잘못된 난이도
음수 기록 금액
없는 부모 참조
두 번째 활성 신청
참조 중 부모 삭제
```

## 선택·심화 범위

선택:

```text
전체 요구사항 추적표
공백 문자열 세부 테스트
완료 뒤 재신청
AI 제안 비교
확장 백로그
```

심화:

```text
통합 사용자 계정
실제 결제·환불
상태 이력
정원·대기열
소프트 삭제·익명화
동시 신청 처리
```

## 다음 장 연결

Chapter 08에서는 최종 신청 5건을 기준으로 JOIN과 집계를 수행한다. `recorded_amount` 합계 590000과 취소 제외 합계 440000을 검산 기준으로 사용한다.
