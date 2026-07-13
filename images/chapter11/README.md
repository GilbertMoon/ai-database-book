# Chapter 11 이미지/도식 설계

## Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법

이 문서는 Chapter 11의 Mermaid·SVG 자산과 `security_lab` 기반 2차 재구성 기준을 정리합니다.

## 공통 원칙

```text
- 하나의 도식은 하나의 보안·복구 판단만 전달한다.
- 로그인 성공과 객체 접근 권한을 동일하게 표현하지 않는다.
- 최소 권한은 역할별 작업 행렬에서 출발한다.
- GRANT·REVOKE 뒤 유효 권한 확인 단계를 포함한다.
- 백업 생성과 복원 검증을 별도 단계로 표현한다.
- 전체 SQL·비밀번호·접속 URL을 이미지에 넣지 않는다.
- title, desc, role="img", aria-labelledby, width="100%", viewBox를 유지한다.
```

## 도식 목록

| 번호 | 파일 | 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 11-1 | `ch11_01_security_backup_overview.svg` | 보안 통제와 복구 준비 | 인증·권한·비밀·감사·복구 통합 |
| 그림 11-2 | `ch11_02_account_permission_model.svg` | PostgreSQL 역할과 객체 권한 구조 | LOGIN·NOLOGIN·소유권·멤버십 |
| 그림 11-3 | `ch11_03_least_privilege_principle.svg` | 최소 권한 설계 절차 | 작업 행렬에서 GRANT까지 |
| 그림 11-4 | `ch11_04_grant_revoke_flow.svg` | GRANT·REVOKE와 유효 권한 확인 | 직접 권한·멤버십·PUBLIC 재검증 |
| 그림 11-5 | `ch11_05_dev_prod_account_separation.svg` | 개발·운영 환경과 계정 분리 | 계정·데이터·백업 분리 |
| 그림 11-6 | `ch11_06_sql_injection_safe_query.svg` | 문자열 결합과 파라미터 바인딩 | 값 바인딩·식별자 허용 목록 |
| 그림 11-7 | `ch11_07_backup_restore_flow.svg` | 백업 생성에서 복구 검증까지 | 파일 검증·별도 DB 복원·재시험 |
| 그림 11-8 | `ch11_08_ai_security_review_flow.svg` | AI 보안·백업 명령 검토 흐름 | 범위·권한·비밀·복원 검토 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 2차 재구성 실습 기준

```text
security_lab.students 3
security_lab.courses 3
security_lab.enrollments 3
JOIN 3
```

```text
students ID 101~103
courses ID 201~203
enrollments ID 1001~1003
```

역할 예시:

```text
lab_role_security_owner NOLOGIN
lab_role_report_reader NOLOGIN
lab_role_enrollment_app NOLOGIN
lab_readonly_user LOGIN
lab_enrollment_user LOGIN
```

복원 흐름:

```text
security_lab custom-format 백업
→ pg_restore --list
→ SHA-256 기록
→ ai_database_book_restore 생성
→ --exit-on-error 복원
→ 05_restore_validation.sql
→ 역할·권한 재적용·검증
```

## 도식에서 피할 표현

```text
- 로그인하면 모든 테이블을 사용할 수 있다.
- REVOKE 한 번이면 모든 권한이 사라진다.
- ALL PRIVILEGES가 앱 계정에 편리하므로 안전하다.
- 백업 파일은 자동 암호화된다.
- 복제는 백업과 같다.
- 파일이 존재하면 복구 가능하다.
- pg_dump에 클러스터 역할이 모두 포함된다.
- AI가 만든 복원 명령은 원본 DB에 바로 실행한다.
```

## 검수 기준

```text
- 본문 그림 번호 11-1~11-8과 README 순서 일치
- security_lab과 별도 복원 DB의 역할 구분
- 권한 적용 후 검증 분기 표현
- 복원 실패 시 수정·재백업·재검증 흐름 포함
- XML 파싱·텍스트 경계·접근성 확인
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
