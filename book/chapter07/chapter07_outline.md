# Chapter 07 구성안

## 제목

실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 01~06에서 배운 PostgreSQL, 기본 SQL, 요구사항 분석, ERD, 정규화와 데이터 무결성을 하나의 재현 가능한 프로젝트로 통합한다.

```text
범위
→ 요구사항·결정·질문 ID
→ 추적표·관계 문장·ERD
→ 정규화·무결성
→ 전용 스키마 DDL
→ 정상 샘플과 IDENTITY 조정
→ 상태를 확인하는 변경 시나리오
→ 최종 검증
→ 경계·오류 테스트
→ AI 제안과 설계 결정 기록
```

## 핵심 질문

```text
프로젝트의 포함·제외 범위는 무엇인가?
확정 요구사항, 프로젝트 결정과 미확정 질문은 어떻게 다른가?
각 테이블의 한 행은 무엇을 의미하는가?
요구사항 ID가 어느 열·관계·제약조건·테스트에 반영되는가?
무료 강의, 취소 금액과 중복 활성 신청을 어떻게 처리하는가?
명시적 샘플 ID 뒤 IDENTITY 다음 값은 어떻게 조정하는가?
상태 변경 전에 예상 이전 상태를 어떻게 확인하는가?
정상·경계·오류 데이터로 구조를 증명할 수 있는가?
다른 사람이 같은 결과를 재현할 수 있는가?
```

## 독자가 완성할 것

- 프로젝트 범위와 제외 기능 목록
- `P07-R`, `P07-D`, `P07-Q`, `P07-O` 식별자가 있는 요구사항 체계
- 요구사항 추적표
- `course_project` 전용 스키마
- `students`, `instructors`, `courses`, `enrollments` ERD
- 정규화·무결성 검토 기록
- IDENTITY 기반 PostgreSQL DDL
- 이메일 공백·중복 규칙
- 활성 신청 부분 고유 인덱스
- 명시적 ID 정상 샘플과 IDENTITY 시작값 조정
- 예상 이전 상태를 포함한 INSERT·UPDATE 시나리오
- 최종 관계·행 수·금액 검산 SQL
- 성공해야 하는 경계값과 실패해야 하는 오류값 테스트
- 보호 구문이 있는 초기화 파일
- `PROJECT_DECISIONS.md` 설계 결정 기록
- Chapter 08 인계용 최종 데이터 5건

## 확정 요구사항

| ID | 핵심 내용 |
| --- | --- |
| `P07-R01` | 학생 이름·이메일·가입일 |
| `P07-R02` | 강사 이름·이메일·전문 분야 |
| `P07-R03` | 강의 제목·선택 설명·난이도·가격·개설일 |
| `P07-R04` | 강의는 정확히 한 강사 참조 |
| `P07-R05` | 강사는 0..N 강의 담당 |
| `P07-R06` | 학생은 0..N 신청 보유 |
| `P07-R07` | 강의는 0..N 신청 보유 |
| `P07-R08` | 신청일·상태·실제 결제 금액 저장 |
| `P07-R09` | 네 가지 상태 허용 |
| `P07-R10` | 학생·강사 이메일 공백·동일 문자열 중복 금지 |
| `P07-R11` | 가격·실제 결제 금액 0 이상 |
| `P07-R12` | 존재하는 부모만 참조 |

## 프로젝트 결정

| ID | 결정 | 구현 |
| --- | --- | --- |
| `P07-D01` | 무료 가격·결제 금액은 0 | `NOT NULL`, `CHECK >= 0` |
| `P07-D02` | 취소 행과 신청 당시 금액 보존 | 상태 변경, 금액 유지 |
| `P07-D03` | 진행 중 중복 신청 금지 | 부분 고유 인덱스 |
| `P07-D04` | UPDATE 전에 이전 상태 확인 | `WHERE id AND status` |
| `P07-D05` | 학생·강사 분리 | 별도 테이블 |
| `P07-D06` | 원 단위 정수 금액 | `INTEGER` |
| `P07-D07` | 부모 삭제 제한 | `ON DELETE RESTRICT` |
| `P07-D08` | 명시적 ID 뒤 IDENTITY 조정 | `RESTART WITH` |

## 범위 제외와 미확정

```text
- 결제·환불 이력
- 강의 정원·대기
- 상태 변경 이력
- 진도·수료
- 강의 콘텐츠
- 수강평
- 할인·쿠폰
- 개설 후 강사 변경 정책
- 회원 탈퇴·익명화 정책
- 폐강·삭제 구분
- 재수강 횟수·기간 제한
```

## 핵심 개념

- 프로젝트 범위
- 요구사항·결정·질문·범위 ID
- 요구사항 추적표
- 한 행의 의미
- 사건·관계 엔터티
- 관계 문장과 카디널리티
- N:M 해소
- 전용 PostgreSQL 스키마
- IDENTITY와 명시적 테스트 ID
- `RESTART WITH`
- 현재 가격과 신청 당시 금액
- 무료 금액 0 정책
- 취소 이력과 환불 범위
- PK·FK·NOT NULL·UNIQUE·CHECK
- 부분 고유 인덱스
- `ON DELETE RESTRICT`
- 상태 허용값과 상태 전이
- 자동 커밋과 부분 실행
- 정상·경계·오류 테스트
- `ROLLBACK`
- 재현성
- AI 제안 검토

## 본문 구성

1. 프로젝트 산출물과 실행 구조
2. 전용 스키마를 사용하는 이유
3. 프로젝트 범위와 설계 선택
4. 확정 요구사항과 미확정 질문
5. 요구사항 추적표
6. 엔터티와 속성 도출
7. 테이블과 열 구성
8. 관계 문장과 카디널리티
9. ERD 확인
10. 정규화와 데이터 무결성 검토
11. PostgreSQL 스키마 구현
12. 샘플 데이터와 IDENTITY 조정
13. 안전한 변경 시나리오
14. 검증 SQL과 금액 검산
15. 경계·오류 데이터 테스트
16. 초기화 안전장치
17. AI 제안과 사람의 수정 기록
18. 프로젝트 완성도 점검
19. 확장 백로그
20. 자주 발생하는 오류
21. 스스로 확인하기
22. 권장 해설
23. 핵심 정리
24. 다음 장 연결

## 기본 설계

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

### 관계

```text
instructors 1 : 0..N courses
students    1 : 0..N enrollments
courses     1 : 0..N enrollments
students    N : M courses → enrollments로 해소
```

### 활성 신청 규칙

```sql
CREATE UNIQUE INDEX uq_course_enrollments_active
ON course_project.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

완료·취소 이력은 여러 건 허용하고 진행 중인 신청만 중복 차단한다.

## 코드 파일 구성

```text
code/chapter07/
├── 01_course_project_schema.sql
├── 02_course_project_seed.sql
├── 03_course_project_changes.sql
├── 04_course_project_validation.sql
├── 05_course_project_integrity_tests.sql
├── reset_course_project.sql
├── PROJECT_DECISIONS.md
├── online_course_project.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_course_project_schema.sql` | 전용 스키마, 테이블, 제약조건과 부분 고유 인덱스 생성 |
| `02_course_project_seed.sql` | 기본 3/2/3/4행 입력과 IDENTITY 조정 |
| `03_course_project_changes.sql` | 신규 신청·상태 전이·IDENTITY 최종 조정 |
| `04_course_project_validation.sql` | 최종 행 수·관계·도메인·금액 검산 |
| `05_course_project_integrity_tests.sql` | 정상 경계와 실패 오류 테스트 |
| `reset_course_project.sql` | DB 보호 구문 안에서 프로젝트 초기화 |
| `PROJECT_DECISIONS.md` | 요구사항·결정·질문·AI 수정 기록 |
| `online_course_project.sql` | 기존 링크 호환용 읽기 전용 확인 |

## 데이터 상태 기준

### 기본 샘플

```text
students 3
instructors 2
courses 3
enrollments 4
```

### 변경 이후 최종 상태

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료 / 100000
1004 취소 / 150000
1005 신청 / 120000
활성 중복 0건
```

### 금액 검산

```text
전체 저장 결제금액 590000
취소 제외 결제금액 440000
```

## IDENTITY 기준

```text
students      → 104
instructors   → 203
courses       → 304
enrollments   → seed 후 1005, changes 후 1006
```

## 경계·오류 테스트

성공해야 하는 경계:

```text
가격 0
paid_amount 0
description NULL
한 글자 이름
완료 이력 뒤 재신청
참조되지 않는 부모 삭제
```

실패해야 하는 오류:

```text
이름·이메일·전문분야·제목 공백
이메일 중복
잘못된 난이도·상태
음수 가격·결제 금액
없는 부모 참조
두 번째 활성 신청
참조 중 부모 삭제
```

## 안전성 원칙

- 모든 위치 확인에 `current_database()`, `current_schema()`, `SHOW search_path`를 사용한다.
- 모든 프로젝트 객체에 `course_project`를 명시한다.
- 생성·샘플·변경 파일에서 자동 DROP을 실행하지 않는다.
- 초기화는 현재 DB를 검사하는 보호 구문에서 수행한다.
- `DROP SCHEMA ... CASCADE`로 예상하지 않은 객체를 조용히 삭제하지 않는다.
- 명시적 ID 입력 뒤 IDENTITY 값을 조정한다.
- 변경 전 참조 대상과 예상 이전 상태를 조회한다.
- UPDATE `RETURNING`이 0행이면 원인을 확인한다.
- 상태 `CHECK`와 상태 전이 규칙을 구분한다.
- 자동 커밋의 부분 실행 위험을 설명한다.
- 오류 SQL은 주석 상태로 제공하고 필요 시 `ROLLBACK`한다.
- AI 제안은 요구사항 ID와 실행 증거로 검토한다.

## 도식 원칙

기존 SVG 8종은 프로젝트 흐름, 엔터티 도출, ERD, N:M 해소, 정규화, 검증, AI 검토와 완료 점검의 핵심 메시지를 유지한다. 부분 고유 인덱스와 IDENTITY 조정은 본문·SQL 표기가 더 명확하므로 도식에 과도하게 추가하지 않는다.

## 다음 장 연결

Chapter 08에서는 `course_project` 스키마의 최종 신청 5건을 기준으로 JOIN과 집계를 수행한다. 전체 저장 금액 590000과 취소 제외 금액 440000을 기본 검산값으로 사용한다.
