# Chapter 07 구성안

## 제목

실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기

## 권장 분량

24~28페이지

## 이 장의 역할

Chapter 01~06에서 배운 데이터베이스 기본 구조, PostgreSQL, SQL, 요구사항 분석, ERD, 정규화와 데이터 무결성을 하나의 재현 가능한 프로젝트로 통합한다.

단일 SQL 파일을 무조건 전체 실행하는 방식이 아니라 다음 산출물을 단계별로 완성한다.

```text
범위·가정
요구사항·미확정 질문
요구사항 추적표
관계 문장·ERD
정규화·무결성 검토
전용 스키마 DDL
정상 샘플 데이터
변경 시나리오
최종 검증
오류 데이터 테스트
AI 제안과 설계 결정 기록
```

## 핵심 질문

```text
프로젝트의 포함·제외 범위는 무엇인가?
확정된 규칙과 미확정 정책은 무엇인가?
각 테이블의 한 행은 무엇을 의미하는가?
요구사항이 어느 열·관계·제약조건에 반영되었는가?
정상·변경·오류 데이터로 구조를 증명할 수 있는가?
다른 사람이 같은 결과를 재현할 수 있는가?
AI 제안과 사람의 최종 결정을 구분할 수 있는가?
```

## 독자가 완성할 것

- 프로젝트 범위와 제외 기능 목록
- 확정 요구사항과 미확정 질문
- 요구사항 추적표
- `course_project` 전용 스키마
- `students`, `instructors`, `courses`, `enrollments` ERD
- 정규화·무결성 검토 기록
- IDENTITY 기반 PostgreSQL DDL
- 명시적 ID 정상 샘플 데이터
- 안전한 INSERT·UPDATE·취소 시나리오
- 최종 관계·행 수 검증 SQL
- 실패해야 하는 무결성 테스트
- `PROJECT_DECISIONS.md` 설계 결정 기록
- Chapter 08 인계용 최종 데이터 5건

## 핵심 개념

- 프로젝트 범위
- 확정·미확정 규칙
- 요구사항 추적표
- 한 행의 의미
- 사건·관계 엔터티
- 관계 문장
- 카디널리티와 선택성
- N:M 해소
- 전용 PostgreSQL 스키마
- IDENTITY
- 명시적 테스트 ID
- 정규화
- 데이터 무결성
- PK·FK·NOT NULL·UNIQUE·CHECK
- ON DELETE RESTRICT
- 정상·변경·오류 테스트
- 재현성
- 설계 결정 기록
- AI 제안 검토

## 본문 구성

1. 프로젝트 산출물과 실행 구조
2. 전용 스키마를 사용하는 이유
3. 프로젝트 범위와 설계 결정
4. 서비스 요구사항과 미확정 질문
5. 요구사항 추적표
6. 엔터티와 속성 도출
7. 테이블과 열 구성
8. 관계 문장과 카디널리티
9. ERD 확인
10. 정규화와 데이터 무결성 검토
11. PostgreSQL 스키마 구현
12. 샘플 데이터를 테스트 데이터로 설계
13. 안전한 변경 시나리오
14. 검증 SQL로 완료 조건 확인
15. 실패해야 하는 오류 데이터 테스트
16. AI 제안과 사람의 수정 기록
17. 프로젝트 완성도 점검
18. 확장 백로그
19. 자주 발생하는 프로젝트 오류
20. 핵심 정리
21. 다음 장 연결

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

### 범위 선택

```text
학생과 강사는 별도 테이블
원 단위 INTEGER 금액
취소는 상태로 보존
부모 삭제는 RESTRICT
재신청 정책은 미확정이므로 복합 UNIQUE 보류
결제·환불·진도·수강평·정원은 범위 제외
```

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
| `01_course_project_schema.sql` | 전용 스키마와 네 테이블·제약조건 생성 |
| `02_course_project_seed.sql` | 기본 정상 데이터 3/2/3/4행 입력 |
| `03_course_project_changes.sql` | 신규 신청과 완료·취소 상태 변경 |
| `04_course_project_validation.sql` | 최종 3/2/3/5행과 관계 검증 |
| `05_course_project_integrity_tests.sql` | 실패해야 하는 오류 SQL |
| `reset_course_project.sql` | 명시적 프로젝트 초기화 |
| `PROJECT_DECISIONS.md` | 범위·가정·대안·AI 수정 기록 |
| `online_course_project.sql` | 기존 링크 호환용 안내와 최종 확인 |

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
1001 완료
1004 취소
1005 신규 신청
```

## 안전성 원칙

- 프로젝트 생성 파일에서 자동 `DROP TABLE`을 실행하지 않는다.
- 앞 장 테이블과 충돌하지 않도록 `course_project` 스키마를 사용한다.
- `SERIAL` 대신 `IDENTITY`를 사용한다.
- 자동 증가값 1, 2, 3을 가정하지 않고 명시적 테스트 ID를 사용한다.
- 변경 전 참조 대상과 변경 대상을 `SELECT`로 확인한다.
- 취소는 기본적으로 상태 변경으로 보존한다.
- 오류 SQL은 주석 상태로 제공하고 한 문장씩 실행한다.
- 요구사항 근거 없는 복합 UNIQUE와 CASCADE를 적용하지 않는다.

## 워크북 구성

- 완료 기준 점검
- 프로젝트 범위 결정
- 확정·미확정 규칙 구분
- 요구사항 추적표
- 한 행의 의미와 엔터티 근거
- 관계 문장과 선택성
- ERD 검토
- 정규화·무결성 검토
- 스키마 파일 읽기
- 샘플 데이터 테스트 목적 기록
- 변경 시나리오 전후 기록
- 최종 검증 결과
- 오류 테스트와 데이터 보존 확인
- AI 제안 비교
- 설계 결정 기록
- 확장 백로그

## AI 활용 원칙

- AI에게 가정과 미확정 질문을 분리하도록 요청한다.
- 요구사항 추적표와 제약조건 근거를 함께 요구한다.
- 정상 데이터뿐 아니라 실패해야 하는 테스트를 요청한다.
- 요구사항 없는 `CASCADE`와 복합 `UNIQUE`를 임의로 추가하지 않도록 한다.
- AI 제안·문제·사람의 최종 결정을 문서로 남긴다.

## 다음 장 연결

Chapter 08에서는 `course_project` 스키마의 최종 신청 5건을 기준으로 JOIN과 집계 쿼리를 작성한다. Chapter 08은 이 장의 스키마·샘플·변경·검증 파일을 모두 실행한 상태를 전제로 한다.
