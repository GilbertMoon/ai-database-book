# Chapter 11 독자 워크북

## 데이터베이스 보안과 백업 기초

이 워크북은 Chapter 11의 보안·권한·백업 실습을 점검하기 위한 자료입니다. 실제 운영 DB가 아니라 개인 실습 DB와 별도 복구 확인 DB를 기준으로 기록합니다.

---

## 1. 실습 파일 확인

실습 SQL 파일:

```text
code/chapter11/security_backup_check.sql
```

존재하지 않는 다른 파일명을 사용하지 않습니다.

| 항목 | 확인 |
| --- | --- |
| 현재 사용자 확인 |  |
| 현재 데이터베이스 확인 |  |
| 현재 스키마 확인 |  |
| 운영 DB가 아님을 확인 |  |
| 관리자 권한이 필요한 구간을 주석 상태로 확인 |  |

---

## 2. Chapter 11 전용 테이블

실행 가능한 실습 SQL에서는 다음 테이블명을 사용합니다.

- `public.security_students`
- `public.security_courses`
- `public.security_enrollments`

| 테이블 | 예상 행 수 | 실제 행 수 |
| --- | ---: | ---: |
| security_students | 3 |  |
| security_courses | 3 |  |
| security_enrollments | 3 |  |
| JOIN 결과 | 3 |  |

`security_enrollments`에는 `UNIQUE(student_id, course_id)`를 추가하지 않습니다. Chapter 07에서 동일 학생의 동일 강의 재신청 정책을 확정하지 않았기 때문입니다.

---

## 3. 인증과 권한 부여 구분

| 개념 | 핵심 질문 | 예시 |
| --- | --- | --- |
| 인증 | 누구인가? | 계정, 비밀번호, 인증서 |
| 권한 부여 | 무엇을 할 수 있는가? | SELECT, INSERT, UPDATE |
| 감사·기록 | 누가 무엇을 했는가? | 접속 로그, 작업 기록 |
| 복구 | 되돌릴 수 있는가? | 백업과 복구 테스트 |

### 생각해 보기

- 인증에 성공해도 테이블을 읽지 못할 수 있는 이유는 무엇인가?
- 권한 확인과 감사 기록이 서로 다른 이유는 무엇인가?

---

## 4. 로그인 역할과 권한 역할

| 역할 | LOGIN 여부 | 용도 | 예시 |
| --- | --- | --- | --- |
| 로그인 역할 | LOGIN | 실제 접속 계정 | `readonly_user` |
| 로그인 역할 | LOGIN | 애플리케이션 접속 계정 | `app_enrollment_user` |
| 권한 역할 | NOLOGIN | 읽기 권한 묶음 | `role_report_reader` |
| 권한 역할 | NOLOGIN | 서비스 권한 묶음 | `role_enrollment_app` |

### 확인 질문

- 실제 비밀번호를 SQL 파일에 기록하지 않았는가?
- 권한 역할을 로그인 계정과 분리하면 어떤 장점이 있는가?

---

## 5. 권한 범위 기록

| 권한 범위 | 필요한 권한 | 실제 확인 |
| --- | --- | --- |
| 데이터베이스 | CONNECT |  |
| 스키마 | USAGE |  |
| 테이블 | SELECT / INSERT / UPDATE |  |
| 시퀀스 | USAGE / SELECT |  |
| 역할 멤버십 | GRANT role TO user |  |

INSERT 실습에서 SERIAL 컬럼이 있다면 관련 시퀀스 권한이 필요한지 확인합니다.

---

## 6. GRANT·REVOKE 후 유효 권한 확인

| 확인 항목 | 기대 결과 | 실제 결과 | 해석 |
| --- | --- | --- | --- |
| DB CONNECT | 허용 |  |  |
| public USAGE | 허용 |  |  |
| security_students SELECT | 허용 |  |  |
| security_students INSERT | 차단 |  |  |
| security_enrollments INSERT | 서비스 계정만 허용 |  |  |
| security_enrollments DELETE | 차단 |  |  |
| 시퀀스 USAGE | 서비스 계정 허용 |  |  |

REVOKE 후에도 다른 역할 멤버십이나 PUBLIC 권한으로 접근이 남을 수 있습니다. `has_table_privilege`, `pg_has_role`, 명시적 권한 목록을 함께 확인합니다.

---

## 7. 비밀 정보와 파일 보호

| 점검 항목 | 확인 |
| --- | --- |
| 실제 비밀번호가 저장소에 없는가 |  |
| 실제 접속 URL이 문서에 없는가 |  |
| `.env.example`에는 값 없이 변수명만 있는가 |  |
| `.env`, `.env.local`은 커밋 대상에서 제외되는가 |  |
| 백업 파일 확장자가 커밋 대상에서 제외되는가 |  |
| 노출 시 삭제보다 자격 증명 회전을 우선하는가 |  |

---

## 8. SQL Injection 방어 점검

| 상황 | 위험 | 안전한 방향 |
| --- | --- | --- |
| 값 조건 | 문자열 결합 | 파라미터 바인딩 |
| 동적 정렬 컬럼 | 식별자 조작 | 허용 목록 |
| 동적 테이블명 | 임의 객체 접근 | 허용 목록과 권한 제한 |

입력값 검증만으로 SQL Injection 방어가 끝나는 것은 아닙니다. SQL 구조와 값을 분리하고, DB 계정 권한도 최소화합니다.

---

## 9. 백업과 복구 검증

| 구분 | 확인 |
| --- | --- |
| 백업 파일이 자동 암호화된다고 가정하지 않음 |  |
| pg_dump는 DB 단위 논리 백업임을 이해 |  |
| 역할 같은 전역 객체는 별도 관리 필요성을 검토 |  |
| 복구는 별도 DB에서 수행 |  |
| psql `ON_ERROR_STOP=1` 또는 pg_restore `--exit-on-error` 사용 |  |
| 복구 뒤 행 수, JOIN, 제약조건, 시퀀스, 권한 확인 |  |

### 복구 검증 결과

| 검증 대상 | 기대 결과 | 실제 결과 | 통과 여부 |
| --- | ---: | ---: | --- |
| security_students | 3 |  |  |
| security_courses | 3 |  |  |
| security_enrollments | 3 |  |  |
| JOIN 결과 | 3 |  |  |
| PK/FK/UNIQUE/CHECK | 유지 |  |  |
| 시퀀스 | 존재 |  |  |
| 필요한 권한 | 정책과 일치 |  |  |

---

## 10. RPO와 RTO

| 기준 | 나의 기준 | 이유 |
| --- | --- | --- |
| RPO |  |  |
| RTO |  |  |

RPO와 RTO는 기술뿐 아니라 비용, 서비스 특성, 사용자 영향까지 고려해 정합니다.

---

## 11. AI 명령 검토

| AI 제안 | 문제 가능성 | 수정 또는 보류 판단 |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |

### 반드시 확인할 항목

- 대상 환경이 테스트 DB인가?
- 실제 비밀번호나 접속 URL이 포함되어 있지 않은가?
- SUPERUSER, ALL PRIVILEGES처럼 과도한 권한을 주지 않는가?
- GRANT/REVOKE 뒤 유효 권한 확인이 있는가?
- 백업 파일 보호와 복구 검증이 포함되어 있는가?
- 복구 명령에 오류 중단 옵션이 있는가?

---

## 12. 핵심 정리

- 인증과 권한 부여는 다르다.
- PostgreSQL의 사용자는 LOGIN 가능한 Role이다.
- 최소 권한은 필요한 범위만 부여하는 원칙이다.
- REVOKE 뒤에도 유효 권한을 확인해야 한다.
- SQL Injection 방어는 파라미터 바인딩과 허용 목록, 최소 권한을 함께 사용한다.
- 백업 파일은 원본 데이터와 같은 수준으로 보호한다.
- 복구 가능성은 별도 DB에서 검증해야 한다.
