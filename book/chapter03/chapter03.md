# Chapter 03. PostgreSQL과 DBeaver 실습 환경 구축

> 상태: 초안

## 이 장에서 배울 내용

이 장에서는 이후 실습을 진행하기 위한 기본 개발 환경을 준비합니다.

- PostgreSQL의 역할
- DBeaver 연결 방법
- 실습용 데이터베이스 생성
- GitHub 저장소 준비
- 클라우드 DB 대안

## 왜 이 내용을 배우는가

실습형 데이터베이스 교재에서는 모든 학습자가 가능한 한 같은 환경에서 실습하는 것이 중요합니다. 이 책은 PostgreSQL과 DBeaver를 기본 환경으로 사용합니다.

## 핵심 개념

### PostgreSQL

PostgreSQL은 대표적인 오픈소스 관계형 DBMS입니다. 실무에서는 Postgres라고 줄여 부르기도 합니다.

### DBeaver

DBeaver는 여러 DBMS에 연결해 테이블, 데이터, SQL 실행 결과를 확인할 수 있는 DB 관리 도구입니다.

## 실습 준비

기본 권장 환경은 다음과 같습니다.

```text
로컬 DB: PostgreSQL
DB 관리 도구: DBeaver
버전 관리: GitHub
AI 도구: ChatGPT + Codex
```

## 작은 실습

DBeaver에서 PostgreSQL 연결을 생성한 뒤 다음 SQL을 실행해 봅니다.

```sql
SELECT version();
```

정상적으로 PostgreSQL 버전이 출력되면 기본 연결이 완료된 것입니다.

## AI 활용 실습

설치나 연결 오류가 발생하면 오류 메시지를 복사해 ChatGPT에 입력합니다.

```text
PostgreSQL과 DBeaver 연결 중 다음 오류가 발생했습니다.
오류 메시지를 분석하고 해결 방법을 단계별로 알려 주세요.
[오류 메시지 붙여넣기]
```

## 자주 하는 실수

- PostgreSQL 서버가 실행 중인지 확인하지 않는다.
- 포트 번호를 잘못 입력한다.
- 사용자명 또는 비밀번호를 잘못 입력한다.
- 데이터베이스 이름과 서버 이름을 혼동한다.

## 정리

이 장에서는 PostgreSQL과 DBeaver 중심의 실습 환경을 준비했습니다. 이후 장에서는 이 환경을 바탕으로 SQL, ERD, 정규화, 트랜잭션, 웹 CRUD 실습을 진행합니다.

## 연습 문제

1. [기초] PostgreSQL과 DBeaver의 역할을 각각 설명해 보세요.
2. [기초] Postgres와 PostgreSQL의 관계를 설명해 보세요.
3. [응용] DBeaver에서 새 데이터베이스 연결을 만드는 순서를 정리해 보세요.
4. [심화] 로컬 DB 설치가 어려운 학습자를 위한 클라우드 DB 대안을 조사해 보세요.

## 다음 장에서는

다음 장에서는 관계형 데이터베이스와 SQL 기초를 학습합니다.
