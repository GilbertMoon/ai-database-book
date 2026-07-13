# Chapter 07 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter07/chapter07.md
book/chapter07/chapter07_activity.md
book/chapter07/chapter07_outline.md
code/chapter07/01_course_project_schema.sql
code/chapter07/02_course_project_seed.sql
code/chapter07/03_course_project_changes.sql
code/chapter07/04_course_project_validation.sql
code/chapter07/05_course_project_integrity_tests.sql
code/chapter07/reset_course_project.sql
code/chapter07/PROJECT_DECISIONS.md
code/chapter07/online_course_project.sql
code/chapter07/README.md
images/chapter07/README.md
notes/chapter07_review_checklist.md
README.md
```

## 목적

Chapter 07을 단일 SQL 파일 중심의 예제에서 **요구사항부터 오류 테스트와 설계 결정 기록까지 포함하는 재현 가능한 프로젝트 장**으로 재구성한다.

Chapter 01~06의 내용을 다음 흐름으로 통합한다.

```text
범위·가정
→ 요구사항·미확정 질문
→ 추적표·관계 문장·ERD
→ 정규화·무결성
→ 전용 스키마 DDL
→ 정상 샘플
→ 변경 시나리오
→ 최종 검증
→ 오류 테스트
→ AI 제안과 사람의 결정 기록
```

---

## 1. 제목 변경

### 기존

```text
실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계
```

### 변경

```text
실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기
```

설계뿐 아니라 구현·변경·검증·오류 차단과 재현까지 포함하도록 역할을 확장했다.

---

## 2. 프로젝트 격리

기존에는 `public.students`, `courses` 등의 테이블을 자동 삭제하고 다시 생성했다.

변경 후에는 전용 스키마를 사용한다.

```text
course_project.students
course_project.instructors
course_project.courses
course_project.enrollments
```

효과:

```text
- Chapter 04·05·06 테이블과 이름 충돌 방지
- 프로젝트 범위 명확화
- Chapter 08 이후 명확한 데이터 참조
- 초기화 대상 제한
```

---

## 3. 프로젝트 문서 강화

| 항목 | 반영 내용 |
| --- | --- |
| 범위 | 포함·제외 기능과 설계 선택 기록 |
| 미확정 규칙 | 재신청·삭제·무료 강의·상태 이력 질문 분리 |
| 요구사항 추적표 | 요구사항과 구조·제약조건·테스트 연결 |
| 관계 문장 | 양방향 관계와 선택성 추가 |
| 정규화 | 현재 정보와 신청 당시 정보 구분 |
| 무결성 | PK·FK·NOT NULL·UNIQUE·CHECK·RESTRICT 적용 |
| 재현성 | 명시적 ID와 기대 행 수 제공 |
| 오류 검증 | 실패해야 하는 테스트 파일 분리 |
| 설계 결정 | `PROJECT_DECISIONS.md` 추가 |
| AI 검토 | 제안·근거·문제·최종 결정 기록 |

---

## 4. SQL 구조 변경

### 기존

```text
online_course_project.sql
- 자동 DROP
- SERIAL 테이블 생성
- 자동 생성 ID 1, 2, 3 가정
- 샘플·JOIN·CRUD·오류 테스트 혼합
```

### 변경

```text
01_course_project_schema.sql
- 전용 스키마와 IDENTITY 테이블 생성

02_course_project_seed.sql
- 명시적 ID 기본 샘플 입력

03_course_project_changes.sql
- 신규 신청과 완료·취소 변경

04_course_project_validation.sql
- 최종 행 수·관계·고아 데이터·도메인 검증

05_course_project_integrity_tests.sql
- 실패해야 하는 오류 SQL을 주석 상태로 제공

reset_course_project.sql
- 필요할 때만 프로젝트 객체 삭제

online_course_project.sql
- 기존 링크 호환용 안내와 읽기 전용 최종 확인
```

---

## 5. 데이터 상태 기준

### 기본 샘플

| 테이블 | 행 수 | ID |
| --- | ---: | --- |
| students | 3 | 101~103 |
| instructors | 2 | 201~202 |
| courses | 3 | 301~303 |
| enrollments | 4 | 1001~1004 |

### 변경 후 최종 상태

```text
students 3
instructors 2
courses 3
enrollments 5
1001 완료
1004 취소
1005 신청
```

이 상태를 Chapter 08 인계 기준으로 사용한다.

---

## 6. 제약조건 기준

```text
학생·강사 이메일 UNIQUE
이름·전문분야·제목 공백 CHECK
강의 level CHECK
강의 가격·결제 금액 0 이상 CHECK
수강 상태 CHECK
학생·강사·강의 FOREIGN KEY
참조 중인 부모 ON DELETE RESTRICT
```

재신청 정책이 미확정이므로 `UNIQUE(student_id, course_id)`는 적용하지 않는다.

---

## 7. 오류 테스트

다음 오류 SQL을 별도 파일에 추가했다.

```text
학생 이름 NULL
학생 이메일 중복
공백 강의 제목
허용되지 않은 난이도
음수 강의 가격
존재하지 않는 강사
존재하지 않는 학생·강의
허용되지 않은 수강 상태
음수 결제 금액
참조 중인 학생·강사·강의 삭제
```

모든 오류 SQL은 주석 처리하며 한 번에 하나씩 실행한다.

---

## 8. 도식 처리

기존 Mermaid·SVG 8종은 프로젝트 흐름, 엔터티 도출, ERD, N:M 관계, 검증, 정규화, AI 검토와 완료 점검의 핵심 메시지가 새 본문과 호환되어 유지한다.

본문에서 그림 번호와 캡션을 새 절 순서에 맞춰 조정했다.

전용 스키마, 요구사항 추적표와 단계별 파일은 표·코드가 더 적합하여 별도 SVG를 추가하지 않았다.

---

## 9. 남은 확인 항목

```text
- 실제 PostgreSQL에서 01→02→03→04 순서 실행
- 05 오류 테스트를 하나씩 실행
- Chapter 08을 course_project 최종 5건 기준으로 수정
- GitHub에서 기존 SVG 8종 표시 확인
- Word/PDF/eBook에서 긴 테이블과 SQL 줄바꿈 확인
```

---

## 10. 최종 상태

```text
Chapter 07 본문, 워크북, 구성안, 코드, 결정 기록과 검수 문서를 2차 재구성했다.
프로젝트는 앞 장 테이블을 삭제하지 않고 전용 스키마에서 재현 가능하다.
원격 main에 모든 변경을 직접 반영했다.
```
