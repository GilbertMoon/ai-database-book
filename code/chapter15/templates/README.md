# Chapter 15 프로젝트 템플릿

## AI 기반 데이터베이스 서비스 만들기

이 폴더는 Chapter 15의 실전 프로젝트를 시작할 때 사용할 수 있는 기본 템플릿입니다. 그대로 완성본으로 사용하는 것이 아니라, 해결하려는 문제와 데이터 구조에 맞게 파일과 내용을 수정합니다.

---

## 권장 프로젝트 구조

```text
project/
├── README.md
├── requirements.md
├── erd.md 또는 erd.png
├── schema.sql
├── seed.sql
├── queries.sql
├── ai_review.md
├── project_notes.md
└── screenshots/
```

---

## 파일 설명

| 파일 | 설명 |
| --- | --- |
| `README.md` | 프로젝트 목적, 사용 환경과 실행 순서 |
| `requirements.md` | 사용자, 기능, 데이터, 업무 규칙과 제외 범위 |
| `erd.md` | 텍스트 ERD 또는 테이블 관계 설명 |
| `schema.sql` | PostgreSQL 테이블과 제약조건 생성 |
| `seed.sql` | 핵심 상황을 재현하는 가상 샘플 데이터 |
| `queries.sql` | 기본 조회, JOIN, 집계와 검증 SQL |
| `ai_review.md` | AI 제안, 발견한 문제와 수정 근거 |
| `project_notes.md` | 현재 한계, 보안·성능 검토와 다음 버전 계획 |
| `screenshots/` | 필요한 경우 실행 결과를 보조하는 이미지 |

---

## 기본 실행 순서

```text
1. 작업용 또는 테스트용 PostgreSQL 데이터베이스에 연결한다.
2. schema.sql을 실행한다.
3. seed.sql을 실행한다.
4. queries.sql을 실행한다.
5. 예상 결과와 실제 결과를 비교한다.
6. 문제가 있으면 요구사항, ERD와 SQL을 함께 수정한다.
```

운영 데이터베이스에서 템플릿을 바로 실행하지 않습니다.

---

## 프로젝트 이름 예시

```text
ai_tutoring_db
online_course_db
library_service_db
reservation_service_db
internal_document_search
```

폴더와 데이터베이스 이름은 영문 소문자와 언더스코어를 사용하면 관리하기 쉽습니다.

---

## 완성도 확인

```text
- README에 문제, 환경과 실행 순서가 설명되어 있는가?
- requirements.md와 ERD가 일치하는가?
- ERD와 schema.sql이 일치하는가?
- schema.sql을 반복 실행할 수 있는가?
- seed.sql이 관계, 상태와 집계 상황을 재현하는가?
- queries.sql이 실제 요구사항을 증명하는가?
- 누락이나 모순을 찾는 검증 SQL이 있는가?
- AI가 만든 내용과 사람이 수정한 내용이 구분되는가?
- 비밀번호, API 키, 실제 .env와 개인정보가 포함되지 않았는가?
- 다른 사람이 같은 순서로 실행할 수 있는가?
```

---

## 안전 주의

```text
비밀번호와 접속 URL을 SQL 또는 Markdown 파일에 직접 기록하지 않는다.
실제 .env 파일을 공개 저장소에 추가하지 않는다.
실제 사용자 정보를 샘플 데이터로 사용하지 않는다.
DROP, DELETE, UPDATE는 대상과 조건을 확인한 뒤 실행한다.
AI가 만든 SQL은 작업용 DB에서 검증한 뒤 사용한다.
```
