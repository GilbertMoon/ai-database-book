# Chapter 11 이미지/도식 설계

## Chapter 11. 데이터베이스 보안과 백업 기초

모든 SVG는 `images/SVG_STYLE_GUIDE.md` 기준을 따른다. 하나의 도식은 하나의 핵심 메시지만 전달하고, 본문 SQL 전체를 반복하지 않는다.

## 도식 목록

| 번호 | 파일 | 제목 |
| --- | --- | --- |
| 그림 11-1 | `ch11_01_security_backup_overview.svg` | 보안 통제와 복구 준비 |
| 그림 11-2 | `ch11_02_account_permission_model.svg` | PostgreSQL 역할과 객체 권한 구조 |
| 그림 11-3 | `ch11_03_least_privilege_principle.svg` | 최소 권한 설계 절차 |
| 그림 11-4 | `ch11_04_grant_revoke_flow.svg` | GRANT·REVOKE와 유효 권한 확인 |
| 그림 11-5 | `ch11_05_dev_prod_account_separation.svg` | 개발·운영 환경과 계정 분리 |
| 그림 11-6 | `ch11_06_sql_injection_safe_query.svg` | 문자열 결합과 파라미터 바인딩 |
| 그림 11-7 | `ch11_07_backup_restore_flow.svg` | 백업 생성에서 복구 검증까지 |
| 그림 11-8 | `ch11_08_ai_security_review_flow.svg` | AI 보안·백업 명령 검토 흐름 |

## 검수 기준

- Mermaid 원본과 SVG 메시지가 일치한다.
- SVG에는 `role`, `aria-labelledby`, `title`, `desc`, `width="100%"`, `viewBox`가 있다.
- 외부 CSS, JavaScript, 외부 이미지, `foreignObject`를 사용하지 않는다.
- GRANT/REVOKE 뒤 유효 권한 확인 흐름을 표현한다.
- SQL Injection 도식은 문자열 결합 위험과 파라미터 바인딩을 구분한다.
- 복구 도식은 실패 시 수정 후 재검증 흐름을 포함한다.
- 브라우저, GitHub 미리보기, Word/PDF/eBook 변환 결과는 사람이 추가 확인한다.
