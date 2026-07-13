# Chapter 15 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter15/chapter15.md
book/chapter15/chapter15_activity.md
book/chapter15/chapter15_outline.md
code/chapter15/README.md
code/chapter15/templates/README.md
code/chapter15/templates/requirements.md
code/chapter15/templates/erd.md
code/chapter15/templates/01_schema.sql
code/chapter15/templates/02_seed.sql
code/chapter15/templates/03_metadata_validation.sql
code/chapter15/templates/04_requirement_queries.sql
code/chapter15/templates/05_transaction_checks.sql
code/chapter15/templates/06_negative_tests.sql
code/chapter15/templates/07_performance_checks.sql
code/chapter15/templates/08_operations_checks.sql
code/chapter15/templates/09_optional_rag_extension.sql
code/chapter15/templates/OPERATIONS_RUNBOOK.md
code/chapter15/templates/ai_review_report.md
code/chapter15/templates/final_report.md
code/chapter15/templates/reset_tutor_project.sql
code/chapter15/templates/schema.sql
code/chapter15/templates/seed.sql
code/chapter15/templates/queries.sql
images/chapter15/README.md
notes/chapter15_review_checklist.md
README.md
```

## 목적

Chapter 15를 기본 스키마 테이블 자동 삭제와 세 개 SQL 파일 중심의 프로젝트에서 **요구사항·설계·실행·운영·AI 검토가 추적되는 재현 가능한 최종 프로젝트**로 재구성한다.

```text
문제·범위
→ 요구사항·미확정 정책
→ ERD·DDL
→ 기준 데이터
→ 메타데이터·업무 조회
→ 트랜잭션·반례
→ 인덱스·운영·복구
→ AI diff
→ 선택 RAG
→ 완료 게이트
```

---

## 1. 제목 변경

```text
기존: 실전 프로젝트 2: AI 기반 데이터베이스 서비스 완성하기
변경: 실전 프로젝트 2: 재현 가능한 AI 데이터베이스 서비스 완성하기
```

AI 기술 수보다 다른 사람이 다시 실행하고 같은 증거를 확인할 수 있는지를 중심에 둔다.

---

## 2. 실습 스키마 격리

기존:

```text
기본 검색 경로의 students·tutors·questions 등
schema.sql에서 자동 DROP
SERIAL 사용
```

변경:

```text
tutor_project.students
tutor_project.tutors
tutor_project.questions
tutor_project.answers
tutor_project.learning_materials
tutor_project.question_materials
```

앞 장 스키마와 `public`은 변경하지 않는다.

---

## 3. 단계별 실행 구조

```text
01_schema.sql
02_seed.sql
03_metadata_validation.sql
04_requirement_queries.sql
05_transaction_checks.sql
06_negative_tests.sql
07_performance_checks.sql
08_operations_checks.sql
09_optional_rag_extension.sql
```

기존 `schema.sql`, `seed.sql`, `queries.sql`은 자동 삭제·변경을 하지 않는 호환 안내 파일로 전환했다.

---

## 4. DDL 개선

```text
- SERIAL → IDENTITY
- 명시적 제약조건 이름
- question_code·material_code UNIQUE
- 자료 유형·접근 범위 CHECK
- 질문별 display_order UNIQUE
- 모든 FK ON DELETE RESTRICT
- 업무 조회 기반 인덱스 3개
- RAG 원문용 source_version·content_hash·is_active
```

미확정인 튜터별 복수 답변, 상태 자동 변경, closed 답변, 삭제·보관 정책은 제약으로 고정하지 않았다.

---

## 5. 기준 데이터·재현성

```text
students 4
tutors 3
questions 5
answers 5
learning_materials 6
question_materials 7
```

명시적 ID:

```text
students 101~104
tutors 201~203
questions 301~305
answers 401~405
learning_materials 501~506
```

고정 시각과 `example.test` 주소를 사용해 실제 개인정보와 실행 시점 의존을 제거했다.

---

## 6. 검증 강화

### 메타데이터

```text
테이블 6
FK 5
IDENTITY PK 5
복합 PK 1
업무 인덱스 3
CASCADE 0
민감정보 형태 컬럼 0
```

### 정상·경계·정합성

```text
학생·질문 5행
답변·튜터 5행
질문·자료 7행
질문 없는 학생 1행
연결되지 않은 자료 1행
답변 없는 open 질문 1건
답변 2개 질문 1건
고아·상태·표시 순서 이상 0행
```

### 트랜잭션

```text
answers 5 → 내부 6 → ROLLBACK 후 5
질문 303 open → 내부 answered → open
```

### 반례

```text
14개 자동 테스트
unique_violation
foreign_key_violation
check_violation
unexpected 0
기준 데이터 유지
```

---

## 7. 성능·운영·복구

```text
- 인덱스 존재와 대표 EXPLAIN 분리
- 작은 표본의 Seq Scan을 오류로 단정하지 않음
- 객체 소유자·명시적 권한·PUBLIC 권한 확인
- example.test 이외 이메일 검출
- 역할 작업 행렬과 최소 권한 계획
- custom-format 스키마 백업
- 별도 DB 복원과 03·04·08 재검증
- RPO·RTO·다음 복원 시험 기록
```

---

## 8. 선택 RAG 확장

`learning_materials`를 원문 메타데이터의 Source of Truth로 사용하고 선택 뷰에서 활성 자료만 노출한다.

```text
활성 원문 후보 5
public 4
internal 1
inactive MAT-OLD-01 제외
```

벡터·청크·검색 로그는 원문에서 다시 만들 수 있는 파생 데이터로 설명한다.

---

## 9. 문서·AI 검토 강화

```text
requirements.md: REQ-01~12·미확정 정책·검증 기준
erd.md: 역할·FK·인덱스·RAG 원본 구조
ai_review_report.md: commit·diff·실행 증거·승인 상태
final_report.md: 요구사항·검증·운영·한계·다음 버전
OPERATIONS_RUNBOOK.md: 권한·비밀·백업·복원·RPO·RTO
```

---

## 10. 도식 처리

기존 Mermaid·SVG 8종은 통합 흐름, 범위, 파일 구조, 검증, AI 검토, 완성도, 보고서와 완료 게이트라는 일반 메시지가 새 본문과 호환되어 유지한다.

이미지 문서에는 새 제목과 `tutor_project`, 01~09 실행 구조, 운영·RAG 완료 기준을 반영한다.

---

## 11. 남은 확인

```text
- 실제 PostgreSQL에서 01→08 실행
- 메타데이터 boolean 모두 true 확인
- 요구사항·정합성 결과 확인
- ROLLBACK 복구 확인
- 반례 14/14·unexpected 0 확인
- 대표 EXPLAIN 확인
- 별도 DB 백업·복원 시험
- 선택 RAG 뷰 5/4/1 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 12. 최종 상태

```text
Chapter 15 본문, 워크북, 구성안과 최종 프로젝트 템플릿을 2차 재구성했다.
자동 삭제·SERIAL·수동 오류 테스트를 제거하고, 전용 스키마·단계별 검증·운영·선택 RAG·완료 보고 구조로 강화했다.
원격 main에 모든 변경을 직접 반영했다.
```
