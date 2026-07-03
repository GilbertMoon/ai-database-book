# Chapter 11 실습 코드

## 데이터베이스 보안과 백업

이 폴더는 Chapter 11의 데이터베이스 보안과 백업 실습 SQL 파일을 관리합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `security_backup_practice.sql` | 사용자/권한, GRANT/REVOKE, 권한 확인, SQL Injection 안전 원칙, 백업/복구 명령 구조 점검 실습 |

---

## 실행 전 주의 사항

```text
- 이 파일은 교육용 예제입니다.
- 운영 데이터베이스에서 그대로 실행하지 마세요.
- CREATE ROLE, GRANT, REVOKE는 관리자 권한이 있는 계정에서만 실행됩니다.
- 실습용 역할과 비밀번호는 예시이며 실제 환경에서 사용하면 안 됩니다.
- 백업/복구 명령은 SQL Editor가 아니라 터미널에서 실행하는 명령입니다.
```

---

## 권장 실행 환경

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 실습 데이터베이스
- 실습 전용 로컬 DB 또는 교육용 DB
```

운영 DB가 아닌 실습용 DB에서만 실행하는 것을 권장합니다.

---

## 주요 실습 항목

```text
- 보안 실습용 테이블 생성
- 현재 사용자와 현재 데이터베이스 확인
- PostgreSQL 역할 목록 확인
- 읽기 전용 역할 생성 예시
- GRANT를 통한 SELECT 권한 부여 예시
- REVOKE를 통한 권한 회수 예시
- has_table_privilege로 권한 확인
- information_schema.role_table_grants로 권한 목록 확인
- SQL Injection 위험 패턴과 파라미터 바인딩 원칙 확인
- pg_dump 백업 명령 구조 확인
- psql 복구 명령 구조 확인
- 복구 후 데이터 수 검증 SQL 확인
- AI 생성 보안/백업 명령 검토 질문
```

---

## 실습 운영 팁

초급자 수업에서는 `CREATE ROLE`, `GRANT`, `REVOKE`를 실제로 모두 실행하기보다, 먼저 주석 처리된 명령의 의미를 해석하게 하는 방식이 안전합니다.

권한 실습을 실제로 진행하려면 다음 흐름을 권장합니다.

```text
1. 실습용 로컬 PostgreSQL DB를 준비한다.
2. 관리자 계정으로 접속한다.
3. readonly_user 역할 생성 명령을 실행한다.
4. SELECT 권한만 부여한다.
5. has_table_privilege로 권한을 확인한다.
6. REVOKE로 일부 권한을 회수한다.
7. 다시 has_table_privilege로 결과를 비교한다.
```

백업/복구 실습은 운영 DB가 아니라 별도 테스트 DB에서 수행해야 합니다.

---

## 학습 포인트

```text
보안 실습의 핵심은 명령을 많이 실행하는 것이 아니라, 어떤 권한이 왜 필요한지 설명할 수 있는 것입니다.
백업 실습의 핵심은 백업 파일 생성이 아니라 복구 가능한지 확인하는 것입니다.
AI가 추천한 보안 설정이나 백업 명령도 최종 실행 전 반드시 사람이 검토해야 합니다.
```
