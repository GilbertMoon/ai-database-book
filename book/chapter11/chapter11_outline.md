# Chapter 11 편집 구성안

## 제목

데이터베이스 보안과 백업 기초

## 장의 역할

Chapter 11은 데이터베이스를 안전하게 지키고 복구 가능하게 만드는 기본 원칙을 다룬다. 권한 명령을 단순히 외우는 장이 아니라 인증, 권한, 최소 권한, SQL Injection 방어, 백업과 복구 검증을 하나의 운영 관점으로 연결한다.

## 주요 개념

- 인증
- 권한 부여
- PostgreSQL Role
- LOGIN 역할
- NOLOGIN 권한 역할
- 역할 멤버십
- PUBLIC
- 데이터베이스·스키마·테이블·시퀀스 권한
- Default Privileges
- 비밀 정보 보호
- SQL Injection
- 파라미터 바인딩
- 허용 목록
- 논리 백업
- pg_dump와 pg_dumpall
- 복구 검증
- RPO와 RTO
- AI 보안·백업 명령 검토

## 본문 구성

1. 보안 통제와 복구 준비
2. Chapter 11 실습 테이블과 SQL 파일
3. PostgreSQL 역할과 계정 구조
4. 권한 범위 계층
5. 최소 권한 원칙
6. GRANT, REVOKE와 유효 권한 확인
7. 현재 객체와 미래 객체 권한
8. 개발·운영 환경과 계정 분리
9. SQL Injection과 안전한 입력 처리
10. 개인정보, 로그, 백업 파일 보호
11. 백업과 복제의 차이
12. pg_dump와 역할 백업
13. 별도 DB 복구 검증
14. RPO와 RTO
15. AI 보안·백업 명령 검토
16. 핵심 정리
17. 다음 장 연결

## 편집 원칙

- 실제 SQL 파일명은 `security_backup_check.sql`만 사용한다.
- 실습 테이블은 `security_` 접두사를 사용한다.
- 운영 DB에서 실행하도록 안내하지 않는다.
- 실제 비밀번호나 접속 URL을 넣지 않는다.
- `UNIQUE(student_id, course_id)`를 임의로 추가하지 않는다.
- REVOKE 후 유효 권한이 남을 수 있음을 설명한다.
- 백업 파일은 자동 암호화되지 않는다고 설명한다.
- AI 제안은 초안으로만 다룬다.
