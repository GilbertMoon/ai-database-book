# Chapter 13 구성안

## 제목

AI와 실행 증거로 데이터베이스 설계 검증하기

## 권장 분량

30~34페이지

## 이 장의 역할

Chapter 13은 AI가 만든 ERD·DDL·SQL과 저장소 변경을 요구사항 추적, 실제 PostgreSQL 메타데이터, 정상·경계값·반례·업무 정합성 결과와 diff를 근거로 사람이 승인하는 방법을 다룬다.

```text
P13 요구사항·결정·미확정 정책
→ AI 문맥 묶음
→ ERD·DDL·SQL 초안
→ DB·스키마 보호 검사
→ 격리 스키마 생성
→ Seed·IDENTITY 조정
→ 메타데이터·업무 검증
→ 반례·정상 경계값
→ 최종 자동 판정
→ diff
→ 승인·조건부 승인·보류·거절
```

## 핵심 질문

```text
AI가 사용한 요구사항은 실제로 확인된 규칙인가?
앞 장에서 확정한 활성 신청 정책을 유지했는가?
미확정 정책을 전체 UNIQUE·CASCADE·NOT NULL로 고정하지 않았는가?
생성·Seed·초기화가 잘못된 DB에서 차단되는가?
명시적 ID 뒤 IDENTITY 다음 값이 조정되었는가?
DDL과 실제 PostgreSQL 메타데이터가 정확히 일치하는가?
LEFT JOIN의 NULL을 놓치지 않는가?
정상 경계값과 반례가 모두 검증되었는가?
SQLSTATE와 실제 constraint name이 일치하는가?
결제·환불 시각과 금액 의미가 명확한가?
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

앞 장 스키마는 변경하지 않는다. `payments`는 `ai_review_lab`의 가상 리뷰 시나리오일 뿐이며 `course_project`에 결제·환불 원장이 추가되는 것이 아니다. 기존 `course_project.enrollments.recorded_amount NUMERIC(12,0)`의 의미는 신청 시점 기록 금액으로 유지한다.

## 기준 데이터

| 항목 | 행 수 | 명시적 ID | 다음 값 |
| --- | ---: | --- | ---: |
| bad_enrollments | 3 | 1~3 | 4 이상 |
| students | 3 | 101~103 | 104 이상 |
| instructors | 2 | 201~202 | 203 이상 |
| courses | 3 | 301~303 | 304 이상 |
| enrollments | 4 | 1001~1004 | 1005 이상 |
| payments | 4 | 9001~9004 | 9005 이상 |
| JOIN | 4 | - | - |
| FK | 4 | - | - |

## 추적 ID

```text
P13-R01~P13-R09  확인된 요구사항
P13-D01~P13-D08  결정·단순화·미확정 정책
P13-T01~P13-T30  반례·정상 경계값
P13-V01~P13-V08  실행·검증 단계
```

## 확인된 요구사항

```text
P13-R01 학생 email 공백 금지·정확 문자열 UNIQUE
P13-R02 강사 email 공백 금지·정확 문자열 UNIQUE
P13-R03 강의→강사 FK
P13-R04 학생·강의 N:M 해소
P13-R05 수강 상태 CHECK
P13-R06 가격·금액 0 이상
P13-R07 결제→수강신청 FK
P13-R08 원시 카드정보 미저장·가상 외부 reference 사용
P13-R09 활성 신청 학생·강의당 한 건
```

## 결정·범위

```text
P13-D01 완료·취소 이력 후 재신청 허용
P13-D02 현재 결제 상태 한 건
P13-D03 삭제 RESTRICT
P13-D04 개인정보 보관 조직 정책
P13-D05 상태 전이 별도 정책
P13-D06 전액 결제·전액 환불 샘플, 부분 환불 범위 밖
P13-D07 이메일 대소문자 별도 결정
P13-D08 결제 없는 신청 허용
```

## 핵심 개념

- AI 결과 검토
- 요구사항·결정·미확정 정책
- 프롬프트 계약
- ERD·카디널리티
- 전체 UNIQUE와 부분 고유 인덱스
- 정확 문자열 이메일 UNIQUE
- IDENTITY·명시적 ID·RESTART
- 정상 경계값·반례
- SQLSTATE·constraint name
- `GET STACKED DIAGNOSTICS`
- information_schema·pg_constraint·pg_indexes
- LEFT JOIN·NULL·`IS DISTINCT FROM`
- 현재 가격·신청 시점 기록 금액·결제 상태 기록 금액
- paid_at·refunded_at
- 민감정보 증거
- 파괴적 마이그레이션
- git diff
- 승인 상태

## 본문 구성

1. AI와 사람의 책임
2. ChatGPT·Codex·사람 협업
3. 설계 문맥 묶음
4. P13 요구사항·결정·정책
5. 요구사항 추적
6. 프롬프트 계약
7. ERD 검토
8. 나쁜·좋은 설계
9. 타입·제약조건
10. 이메일 정책
11. 시점별 금액
12. 결제·환불 시각
13. 격리 실습 구조
14. 샘플·IDENTITY
15. 정확한 메타데이터
16. 정상 경계값·반례
17. LEFT JOIN NULL 검증
18. 업무 정합성
19. 민감정보 증거
20. 최종 자동 판정
21. 파괴적 SQL
22. Codex diff·재실행
23. 승인 상태
24. 자주 하는 실수
25. 스스로 확인하기
26. 권장 해설
27. 핵심 정리
28. Chapter 14 연결

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
├── 08_ai_review_lab_validation.sql
├── AI_REVIEW_REPORT_TEMPLATE.md
├── PROMPT_TEMPLATES.md
├── reset_ai_review_lab.sql
├── ai_db_design_review_practice.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| 01 | DB·기준 상태 보호, 원자적 스키마·나쁜 테이블 생성 |
| 02 | 나쁜 Seed 재실행 차단·IDENTITY 조정 |
| 03 | P13 좋은 설계·활성 부분 인덱스·결제 시각 규칙 |
| 04 | 정상 Seed·IDENTITY 조정·COMMIT 전 판정 |
| 05 | 정확한 테이블·FK·제약·IDENTITY·인덱스 검증 |
| 06 | NULL 안전 업무 정합성 검증 |
| 07 | SQLSTATE·constraint name 반례 24개·경계값 6개 |
| 08 | 최종 영구 상태·메타데이터·업무·IDENTITY 판정 |
| 보고서 | 요구사항·정책·diff·실행 증거·승인 기록 |
| 프롬프트 | 설계·수정·오류·마이그레이션·승인 요청 |
| reset | DB 보호 후 ai_review_lab만 초기화 |

## 메타데이터 기준

```text
정확한 테이블 집합 6
좋은 설계 제약조건 29
정확한 FK 4
IDENTITY id 6
활성 신청 부분 고유 인덱스 존재
민감정보 전용 컬럼 이름 0
```

## 반례·경계값 기준

```text
P13-T01~T24 expected_failure
P13-T25~T30 expected_success
전체 30 / 통과 30 / unexpected 0
기준 행 수 유지
```

## 안전성 원칙

- 기존 스키마를 삭제·변경하지 않는다.
- 생성·Seed·초기화 파일은 현재 DB와 상태를 실제 검사한다.
- 구조·Seed는 트랜잭션으로 처리한다.
- 명시적 ID 뒤 IDENTITY 시작값을 조정한다.
- 전체 UNIQUE 대신 확정된 활성 상태 부분 고유 인덱스를 사용한다.
- 실제 개인정보·비밀번호·카드번호 형태를 사용하지 않는다.
- SQLSTATE와 constraint name을 함께 확인한다.
- 정상 경계값과 실패 반례를 모두 실행한다.
- 검증하지 않은 항목을 통과로 기록하지 않는다.

## 다음 장 연결

Chapter 14에서는 SQL 집계·윈도우 함수와 Python·pandas 확장을 사용해 분석 결과를 교차 검증한다.
