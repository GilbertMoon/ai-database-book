# Chapter 15 코드 자료

이 폴더는 Chapter 15 최종 프로젝트용 템플릿 패키지를 제공합니다. 템플릿은 AI 튜터링 질문 관리 서비스를 기준 예제로 사용하지만, 독자는 자신의 주제에 맞게 테이블명과 업무 규칙을 바꾸어야 합니다.

## 폴더 구조

```text
code/chapter15/
└── templates/
    ├── README.md
    ├── requirements.md
    ├── erd.md
    ├── schema.sql
    ├── seed.sql
    ├── queries.sql
    ├── ai_review_report.md
    └── final_report.md
```

## 실행 순서

1. 별도 실습용 PostgreSQL 데이터베이스를 준비합니다.
2. 현재 DB와 사용자를 확인합니다.
3. `schema.sql`을 실행합니다.
4. `seed.sql`을 실행합니다.
5. `queries.sql`을 실행합니다.
6. 예상 결과와 실제 결과를 비교합니다.
7. 오류 테스트는 주석을 해제해 선택적으로 실행합니다.
8. 문제가 있으면 requirements, ERD, SQL을 함께 수정합니다.

## 안전 주의

- 운영 DB에서 실행하지 않습니다.
- 실제 개인정보, API 키, DB 비밀번호를 넣지 않습니다.
- 템플릿은 테이블을 삭제하고 다시 생성합니다.
- NoSQL, RAG, 웹 CRUD는 선택 확장입니다. 기본 DB 설계와 SQL 검증을 먼저 완료합니다.
- 오류 테스트는 기본 흐름과 분리해 실행합니다.

## 기대 결과

| 테이블 | 기대 행 수 |
|---|---:|
| `students` | 4 |
| `tutors` | 3 |
| `questions` | 5 |
| `answers` | 5 |
| `learning_materials` | 6 |
| `question_materials` | 7 |

FK는 5개입니다. 정합성 이상 조회 결과는 0행이어야 합니다.
