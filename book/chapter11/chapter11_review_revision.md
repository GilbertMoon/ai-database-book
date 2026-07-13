# Chapter 11 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter11/chapter11.md
book/chapter11/chapter11_activity.md
book/chapter11/chapter11_outline.md
code/chapter11/01_security_lab_schema.sql
code/chapter11/02_security_lab_seed.sql
code/chapter11/03_role_permission_plan.sql
code/chapter11/04_permission_checks.sql
code/chapter11/05_restore_validation.sql
code/chapter11/BACKUP_RESTORE_RUNBOOK.md
code/chapter11/reset_security_lab.sql
code/chapter11/security_backup_check.sql
code/chapter11/README.md
images/chapter11/README.md
notes/chapter11_review_checklist.md
.env.example
.gitignore
README.md
```

## 목적

Chapter 11을 `public.security_*` 테이블을 자동 삭제하는 단일 SQL 실습에서 **기존 프로젝트를 보호하면서 최소 권한과 실제 복원 가능성을 검증하는 운영 장**으로 재구성한다.

```text
보호 자산·위험
→ 역할·소유권 분리
→ 최소 권한 작업 행렬
→ 역할·권한 계획
→ 유효 권한 확인
→ 비밀·입력 보호
→ 백업 생성·파일 검증
→ 별도 DB 복원
→ 구조·데이터·권한 검증
→ RPO·RTO 실행 기록
```

---

## 1. 제목 변경

```text
기존: 데이터베이스 보안과 백업 기초
변경: 데이터베이스를 안전하게 지키고 복구하는 방법
```

---

## 2. 실습 스키마 격리

기존:

```text
public.security_students
public.security_courses
public.security_enrollments
자동 DROP 후 재생성
```

변경:

```text
security_lab.students
security_lab.courses
security_lab.enrollments
```

앞 장 스키마는 변경하지 않는다.

```text
course_project
transaction_lab
performance_lab
public
```

---

## 3. SQL 안전성 개선

| 항목 | 기존 | 변경 |
| --- | --- | --- |
| 기본키 | SERIAL | IDENTITY |
| ID 참조 | 자동 생성 1·2·3 가정 | 명시적 ID 101·201·1001 체계 |
| 초기화 | 생성 파일 자동 DROP | reset_security_lab.sql 분리 |
| 역할 | 단일 파일 주석 혼합 | 역할 계획·권한 확인 파일 분리 |
| 복원 | 본문 명령과 일부 검증 | 별도 검증 SQL·RUNBOOK 제공 |
| 기존 링크 | 파괴적 단일 파일 | 읽기 전용 진입점 |

Role은 클러스터 전역 객체이므로 자동 생성·삭제하지 않고 모든 변경 예시를 기본 주석 상태로 제공한다.

---

## 4. 역할·권한 모델 강화

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
```

강화 내용:

```text
- 인증·권한·소유권·감사 구분
- 소유 역할과 실행 역할 분리
- 역할별 작업 행렬
- 컬럼 단위 UPDATE(status)
- IDENTITY 시퀀스 권한
- PUBLIC·직접 권한·멤버십·소유권 경로 확인
- 현재 객체 GRANT와 미래 객체 Default Privileges 구분
```

---

## 5. 비밀·입력 보호 강화

```text
- 루트 .gitignore 추가
- 빈 .env.example 추가
- .env와 백업 파일 확장자 제외
- 비밀 노출 시 삭제보다 자격 증명 회전 우선
- 값 파라미터 바인딩과 동적 식별자 허용 목록 구분
- 로그·복원 임시 DB·백업 사본 보호 범위 포함
```

---

## 6. 백업·복원 구조 강화

### 백업

```text
security_lab 스키마 custom-format 예시
전체 DB custom-format 선택안
pg_dumpall --globals-only 선택안
--no-owner·--no-privileges 처리 근거
```

### 파일 검증

```text
종료 코드
경고
파일 크기·시각
pg_restore --list
SHA-256
보관 위치·접근 권한
```

### 복원

```text
원본 DB가 아닌 ai_database_book_restore
pg_restore --exit-on-error
plain SQL은 psql ON_ERROR_STOP=1
복원 후 05_restore_validation.sql 실행
```

### 검증

```text
3/3/3/JOIN 3
고아 FK 0
PK·FK·UNIQUE·CHECK
NOT NULL·IDENTITY
시퀀스 3개
소유자·ACL·컬럼 권한
```

---

## 7. 복구 실행 기록

`BACKUP_RESTORE_RUNBOOK.md`에 다음을 추가했다.

```text
도구·서버 버전
백업 범위·형식·저장 위치
RPO·RTO
종료 코드·경고·파일 크기·해시
복원 시작·완료 시각
구조·데이터·권한 검증
오류·해결·재검증
다음 복원 시험 날짜
```

---

## 8. 도식 처리

그림 11-8 AI 보안·백업 검토 도식은 권한 명령 검증과 별도 DB 복원 검증 분기가 명확하도록 보완했다.
나머지 Mermaid·SVG 7종은 인증·권한·최소 권한·환경 분리·Injection·복원이라는 일반 메시지가 새 본문과 호환되어 유지한다.

이미지 문서에는 새 제목과 `security_lab`·별도 복원 DB 기준을 반영한다.

---

## 9. 남은 확인 항목

```text
- 실제 PostgreSQL 테스트 DB에서 01→04 실행
- 관리자 테스트 환경에서 역할·GRANT 선택 실행
- 별도 DB에서 custom-format 백업·복원 실행
- 05_restore_validation.sql 통과 확인
- owner·ACL 제외·재적용 결과 확인
- Windows·Linux 명령 표현 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 10. 최종 상태

```text
Chapter 11 본문, 워크북, 구성안, 단계별 SQL, 복구 실행 문서와 저장소 비밀 보호 설정을 2차 재구성했다.
기존 프로젝트를 보호하면서 최소 권한과 복원 가능성을 실제 결과로 검증할 수 있다.
원격 main에 모든 변경을 직접 반영했다.
```
