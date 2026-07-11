# Chapter 11 이미지/도식 설계

## Chapter 11. 데이터베이스 보안과 백업

이 문서는 Chapter 11 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 11은 데이터베이스를 안전하게 보호하고, 장애나 실수 발생 시 복구할 수 있도록 준비하는 기본 원칙을 설명하는 장입니다. 따라서 도식은 **계정과 권한 구조, 최소 권한 원칙, GRANT/REVOKE 흐름, SQL Injection 방어, 백업/복구 흐름, AI 생성 보안·백업 명령 검토**를 입문 독자가 직관적으로 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 보안과 백업이 기능 개발만큼 중요하다는 점을 보여 준다.
- 사용자, 역할, 권한, 테이블의 관계를 단순하게 표현한다.
- 최소 권한 원칙을 읽기 전용 계정과 서비스 계정 예시로 설명한다.
- GRANT와 REVOKE를 권한 부여와 권한 회수 흐름으로 보여 준다.
- SQL Injection은 문자열 결합 위험과 파라미터 바인딩 방향을 비교한다.
- 백업과 복구는 백업 파일 생성보다 복구 테스트가 중요하다는 흐름을 강조한다.
- AI가 제안한 보안 설정과 백업 명령은 사람이 검토해야 한다는 절차를 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 11-1 | `ch11_01_security_backup_overview.svg` | 보안과 백업이 필요한 이유 | 1장 왜 데이터베이스 보안과 백업을 배워야 하는가 | 삽입 완료 |
| 그림 11-2 | `ch11_02_account_permission_model.svg` | 계정과 권한 구조 | 3장 계정과 권한 관리 | 삽입 완료 |
| 그림 11-3 | `ch11_03_least_privilege_principle.svg` | 최소 권한 원칙 | 3장 계정과 권한 관리 | 삽입 완료 |
| 그림 11-4 | `ch11_04_grant_revoke_flow.svg` | GRANT와 REVOKE 흐름 | 5장 GRANT와 REVOKE | 삽입 완료 |
| 그림 11-5 | `ch11_05_dev_prod_account_separation.svg` | 개발용 계정과 운영용 계정 분리 | 6장 개발용 계정과 운영용 계정 구분 | 삽입 완료 |
| 그림 11-6 | `ch11_06_sql_injection_safe_query.svg` | SQL Injection 위험과 안전한 쿼리 | 8장 SQL Injection 개념 | 삽입 완료 |
| 그림 11-7 | `ch11_07_backup_restore_flow.svg` | 백업과 복구 테스트 흐름 | 10장 백업이란 무엇인가 | 삽입 완료 |
| 그림 11-8 | `ch11_08_ai_security_review_flow.svg` | AI 보안·백업 명령 검토 흐름 | 15장 AI가 제안한 보안 설정과 백업 명령 검토하기 | 삽입 완료 |

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch11_01_security_backup_overview.mmd` | `ch11_01_security_backup_overview.svg` |
| `ch11_02_account_permission_model.mmd` | `ch11_02_account_permission_model.svg` |
| `ch11_03_least_privilege_principle.mmd` | `ch11_03_least_privilege_principle.svg` |
| `ch11_04_grant_revoke_flow.mmd` | `ch11_04_grant_revoke_flow.svg` |
| `ch11_05_dev_prod_account_separation.mmd` | `ch11_05_dev_prod_account_separation.svg` |
| `ch11_06_sql_injection_safe_query.mmd` | `ch11_06_sql_injection_safe_query.svg` |
| `ch11_07_backup_restore_flow.mmd` | `ch11_07_backup_restore_flow.svg` |
| `ch11_08_ai_security_review_flow.mmd` | `ch11_08_ai_security_review_flow.svg` |

---

## 4. 도식 제작 후 점검 항목

```text
- 보안과 백업이 각각 보호와 복구의 관점으로 구분되어 보이는가?
- 사용자, 역할, 권한, 테이블의 관계가 입문 독자에게 직관적으로 전달되는가?
- 최소 권한 원칙이 읽기 전용 계정 예시와 연결되는가?
- GRANT와 REVOKE의 차이가 시각적으로 드러나는가?
- 개발/운영 계정 분리가 안전한 운영 원칙으로 표현되는가?
- SQL Injection 방어가 문자열 결합 금지와 파라미터 바인딩으로 설명되는가?
- 백업 후 복구 테스트가 핵심이라는 점이 표현되는가?
- AI 검토 흐름에 권한, 비밀번호, 운영 DB 여부, 위험 명령, 복구 테스트가 포함되는가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 5. 현재 상태 및 다음 작업

```text
- Chapter 11 도식 후보 8종 정리 완료
- Chapter 11 Mermaid 원본 8종 작성 완료
- Chapter 11 SVG 도식 8종 생성 완료
- Chapter 11 본문 그림 링크와 캡션 삽입 완료
- 다음 작업: Chapter 11 리뷰 체크리스트 작성
```
