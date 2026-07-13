# Chapter 13 구성안

## 제목

AI와 실행 증거로 데이터베이스 설계 검증하기

## 권장 분량

28~32페이지

## 이 장의 역할

Chapter 13은 AI가 만든 ERD·DDL·SQL과 저장소 변경을 요구사항 추적, 실제 PostgreSQL 메타데이터, 정상·반례·업무 정합성 결과와 diff를 근거로 사람이 승인하는 방법을 다룬다.

```text
확인 요구사항·미확정 정책
→ AI 문맥 묶음
→ ERD·DDL·SQL 초안
→ 격리 스키마 생성
→ 정상·반례·메타데이터·업무 검증
→ 파괴적 변경·권한·성능 검토
→ diff
→ 승인·보류·거절
```

## 핵심 질문

```text
AI가 사용한 요구사항은 실제로 확인된 규칙인가?
미확정 정책을 UNIQUE·CASCADE·NOT NULL로 고정하지 않았는가?
수정 대상과 금지 범위가 명확한가?
DDL과 실제 PostgreSQL 메타데이터가 일치하는가?
정상 데이터와 반례가 모두 검증되었는가?
제약조건 밖의 업무 정합성 이상이 없는가?
파괴적 SQL·과도한 권한·중복 인덱스가 포함되지 않았는가?
파일별 diff와 남은 가정이 기록되었는가?
```

## 실습 구조

```text
ai_review_lab.bad_enrollments
ai_review_lab.students
ai_review_lab.instructors
ai_review_lab.courses
ai_review_lab.enrollments
ai_review_lab.payments
```

앞 장 스키마:

```text
course_project: 변경 금지
transaction_lab: 변경 금지
performance_lab: 변경 금지
security_lab: 변경 금지
nosql_lab: 변경 금지
```

## 기준 데이터

```text
bad_enrollments 3
students 3
instructors 2
courses 3
enrollments 4
payments 4
JOIN 4
FK 4
```

명시적 ID:

```text
students 101~103
instructors 201~202
courses 301~303
enrollments 1001~1004
payments 9001~9004
```

## 확인된 요구사항

```text
R1 학생 email UNIQUE
R2 강사 email UNIQUE
R3 강의→강사 FK
R4 학생·강의 N:M을 enrollments로 해소
R5 수강 상태 CHECK
R6 금액 0 이상
R7 결제→수강신청 FK
R8 실제 카드번호 미저장
```

## 핵심 개념

- AI 결과 검토
- 요구사항 기준선
- 미확정 정책
- 가정 기록
- 요구사항 추적
- 결정 로그
- 프롬프트 계약
- ERD·카디널리티
- 타입·제약조건
- 정상 테스트
- 반례 테스트
- PostgreSQL 예외 블록
- information_schema
- pg_constraint
- pg_indexes
- 업무 정합성
- 파괴적 마이그레이션
- 최소 권한
- 성능 증거
- git diff
- 승인·조건부 승인·보류·거절

## 본문 구성

1. AI와 사람의 책임
2. ChatGPT·Codex·사람 협업
3. 설계 문맥 묶음
4. 확인 요구사항·미확정 정책
5. 요구사항 추적·결정 기록
6. 프롬프트 계약
7. ERD 검토
8. 나쁜·좋은 설계 비교
9. 타입·제약조건
10. 의도된 시점 데이터
11. 격리 실습 구조
12. 재현 가능한 샘플
13. 실제 메타데이터
14. 정상·반례 테스트
15. 업무 정합성
16. 파괴적 SQL·마이그레이션
17. 권한·보안·성능 검토
18. Codex diff·재실행
19. 승인 상태
20. 프롬프트 예시
21. 자주 하는 실수
22. 스스로 확인하기
23. 핵심 정리
24. 다음 장 연결

## 코드·문서 파일

```text
code/chapter13/
├── 01_ai_review_lab_schema.sql
├── 02_bad_design_seed.sql
├── 03_good_design_schema.sql
├── 04_good_design_seed.sql
├── 05_metadata_validation.sql
├── 06_business_validation.sql
├── 07_negative_tests.sql
├── AI_REVIEW_REPORT_TEMPLATE.md
├── PROMPT_TEMPLATES.md
├── reset_ai_review_lab.sql
├── ai_db_design_review_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `01_ai_review_lab_schema.sql` | 전용 스키마와 나쁜 설계 테이블 생성 |
| `02_bad_design_seed.sql` | 역할 혼합·약한 타입·민감정보 문제 입력 |
| `03_good_design_schema.sql` | IDENTITY·명시적 제약조건 기반 좋은 설계 |
| `04_good_design_seed.sql` | 명시적 ID 정상 데이터 입력 |
| `05_metadata_validation.sql` | 테이블·컬럼·제약조건·FK·인덱스 검증 |
| `06_business_validation.sql` | JOIN·행 수·업무 이상 0행 검증 |
| `07_negative_tests.sql` | 예외 블록 기반 안전한 반례 테스트 |
| `AI_REVIEW_REPORT_TEMPLATE.md` | 요구사항·diff·증거·승인 기록 |
| `PROMPT_TEMPLATES.md` | 설계 검토·파일 수정 프롬프트 |
| `reset_ai_review_lab.sql` | ai_review_lab만 초기화 |
| `ai_db_design_review_practice.sql` | 안전한 호환 진입점 |

## 안전성 원칙

- 기존 스키마를 삭제·변경하지 않는다.
- 생성 파일에서 자동 DROP을 실행하지 않는다.
- SERIAL 대신 IDENTITY를 사용한다.
- 샘플 FK는 명시적 ID를 사용한다.
- 실제 개인정보·비밀번호·토큰·카드번호 형태를 사용하지 않는다.
- 반례는 예외 블록에서 독립적으로 실행해 기준 데이터를 유지한다.
- 파괴적 SQL·Role 변경·인덱스 제안은 별도 위험으로 검토한다.
- 검증하지 않은 항목을 통과로 기록하지 않는다.

## AI 활용 원칙

- 확인 요구사항과 미확정 정책을 분리해 제공한다.
- 현재 스키마·행 수·제약조건과 수정 파일을 제공한다.
- 수정 금지 범위와 완료 보고 형식을 명시한다.
- 정상·반례·메타데이터·업무 정합성 검증을 요구한다.
- 최소 변경과 파일별 diff를 검토한다.
- 결과를 승인·조건부 승인·보류·거절로 기록한다.

## 다음 장 연결

Chapter 14에서는 임베딩·Vector DB·RAG를 검색 품질, 근거, 권한과 실패 검증 관점에서 다룬다.
