# Chapter 15 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 15. 실전 프로젝트 2: 재현 가능한 AI 데이터베이스 서비스 완성하기
```

## 리뷰 목적

Chapter 15가 책 전체의 개념을 `tutor_project`에 통합하고, 다른 사람이 같은 순서로 실행해 같은 검증 결과를 확인할 수 있도록 구성되었는지 점검합니다.

---

## 1. 범위와 재현성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 필수·선택 확장 구분 | 통과 | 기본 DB 완성 후 API·NoSQL·RAG·배포 판단 |
| 프로젝트 사용자·문제 | 통과 | 학생·튜터·운영자·검색 서비스 |
| 전용 스키마 | 통과 | tutor_project 사용 |
| 앞 장 스키마 보호 | 통과 | 존재 여부 확인 외 변경 없음 |
| 자동 DROP 제거 | 통과 | reset 파일 분리 |
| SERIAL 제거 | 통과 | IDENTITY 사용 |
| 명시적 ID | 통과 | 101·201·301·401·501 체계 |
| 고정 시각·가상 데이터 | 통과 | 재현성·개인정보 보호 |

---

## 2. 요구사항·정책 추적

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| REQ-01~12 | 통과 | DDL·조회·반례·운영 검증 연결 |
| 미확정 정책 분리 | 통과 | 복수 답변·상태·closed·삭제·보관 |
| AI 임의 정책 방지 | 통과 | UNIQUE·CASCADE·트리거 자동 확정 금지 |
| requirements·erd 동기화 | 통과 | 새 구조 반영 |
| 완료 상태 | 통과 | 완료·조건부 완료·보류·미완료 |

---

## 3. DDL·ERD

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| 테이블 | 6 | 코드 반영 |
| FK | 5 | 코드 반영 |
| IDENTITY PK | 5 | 코드 반영 |
| 연결 테이블 복합 PK | 1 | 코드 반영 |
| 업무 인덱스 | 3 | 코드 반영 |
| CASCADE FK | 0 | 코드 반영 |
| question_code UNIQUE | 적용 | 통과 |
| material_code UNIQUE | 적용 | 통과 |
| display_order UNIQUE | 적용 | 통과 |
| 자료 유형·접근 범위 CHECK | 적용 | 통과 |

---

## 4. 기준 데이터

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 4 | 코드 반영 |
| tutors | 3 | 코드 반영 |
| questions | 5 | 코드 반영 |
| answers | 5 | 코드 반영 |
| learning_materials | 6 | 코드 반영 |
| question_materials | 7 | 코드 반영 |
| 질문 없는 학생 | 1 | 코드 반영 |
| 연결되지 않은 자료 | 1 | 코드 반영 |
| 답변 없는 open 질문 | 1 | 코드 반영 |
| 답변 2개 질문 | 1 | 코드 반영 |
| internal 자료 | 1 | 코드 반영 |
| inactive 자료 | 1 | 코드 반영 |

---

## 5. 메타데이터·업무 검증

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 실제 컬럼·타입·NULL | 통과 | information_schema 조회 |
| 제약조건 정의 | 통과 | pg_constraint 조회 |
| FK 삭제 규칙 | 통과 | RESTRICT·CASCADE 0 |
| 인덱스 정의 | 통과 | pg_indexes 조회 |
| 민감정보 형태 컬럼 | 통과 | 기대 0행 |
| 학생·질문 JOIN | 통과 | 기대 5행 |
| 답변·튜터 JOIN | 통과 | 기대 5행 |
| 질문·자료 N:M | 통과 | 기대 7행 |
| 정합성 이상 | 통과 | 모두 0행 기대 |
| 최종 boolean | 코드 반영 | 실제 실행 필요 |

---

## 6. 트랜잭션·반례

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 답변 INSERT·상태 UPDATE | 통과 | 한 트랜잭션 예제 |
| ROLLBACK 복구 | 코드 반영 | answers 5·질문 303 open 기대 |
| 임시 결과 테이블 | 통과 | 영구 테스트 객체 없음 |
| 하위 트랜잭션 반례 | 통과 | 기준 데이터 유지 |
| 반례 수 | 14 | 코드 반영 |
| unique_violation | 통과 | 이메일·연결·표시 순서 |
| foreign_key_violation | 통과 | 학생·질문·튜터·자료 |
| check_violation | 통과 | 상태·빈 값·유형·범위·순서 |
| unexpected | 0 | 실제 실행 필요 |

---

## 7. 성능

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 학생별 질문 인덱스 | 통과 | student_id·status·created_at |
| 질문별 답변 인덱스 | 통과 | question_id·created_at |
| 자료별 연결 질문 인덱스 | 통과 | material_id |
| 대표 EXPLAIN | 통과 | 세 조회 제공 |
| 작은 표본 해석 | 통과 | Seq Scan 정상 가능 설명 |
| 운영 비교 | 통과 | ANALYZE·BUFFERS와 쓰기 비용 요구 |

---

## 8. 보안·운영·복구

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 실제 개인정보 미사용 | 통과 | example.test·가상 이름 |
| 비밀 컬럼·값 검사 | 통과 | 08_operations_checks.sql |
| 역할 작업 행렬 | 통과 | owner·app·report 계획 |
| 자동 Role 변경 방지 | 통과 | RUNBOOK 선택 적용 |
| 백업 명령 | 통과 | custom-format 스키마 백업 |
| 별도 DB 복원 | 통과 | exit-on-error 예시 |
| 복원 검증 | 통과 | 03·04·08 재실행 |
| RPO·RTO | 통과 | 기록 템플릿 제공 |

---

## 9. 선택 RAG 확장

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 원문 Source of Truth | 통과 | learning_materials |
| 활성 자료만 뷰 노출 | 통과 | inactive 제외 |
| 접근 범위 유지 | 통과 | public·internal·restricted |
| 버전·해시 | 통과 | 재임베딩 기준 |
| 기대 원문 후보 | 5 | 코드 반영 |
| public 후보 | 4 | 코드 반영 |
| internal 후보 | 1 | 코드 반영 |
| 벡터 파생 구분 | 통과 | 원문과 분리 설명 |

---

## 10. 파일 구조

| 파일 | 상태 |
| --- | --- |
| `01_schema.sql` | 통과 |
| `02_seed.sql` | 통과 |
| `03_metadata_validation.sql` | 통과 |
| `04_requirement_queries.sql` | 통과 |
| `05_transaction_checks.sql` | 통과 |
| `06_negative_tests.sql` | 통과 |
| `07_performance_checks.sql` | 통과 |
| `08_operations_checks.sql` | 통과 |
| `09_optional_rag_extension.sql` | 통과 |
| `OPERATIONS_RUNBOOK.md` | 통과 |
| `reset_tutor_project.sql` | 통과 |
| 기존 schema·seed·queries 안전 전환 | 통과 |

---

## 11. AI·최종 보고서

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| commit·diff 기록 | 통과 | AI 보고서 확장 |
| 요구사항·가정 분리 | 통과 | REQ·미확정 정책 |
| 메타데이터·실행 증거 | 통과 | 기대 수치 포함 |
| 보안·성능·복구 | 통과 | 별도 검토 표 |
| 미실행 항목 | 통과 | 통과로 표시 금지 |
| 최종 상태 | 통과 | 네 상태 제공 |
| 다음 버전 | 통과 | API·ORM·RAG·배포 계획 |

---

## 12. 도식

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 기존 SVG 8종 | 통과 | 새 통합 흐름과 호환 |
| 새 제목·tutor_project 기준 | 통과 | 이미지 README 갱신 |
| 실제 파일명 | 통과 | 01~09·RUNBOOK·보고서 반영 |
| 접근성·렌더링 | 확인 필요 | 수동 출판 검수 필요 |

---

## 13. 남은 확인

```text
- 실제 PostgreSQL에서 01→08 실행
- 메타데이터 boolean 모두 true 확인
- 업무 조회·경계·정합성 결과 확인
- 트랜잭션 ROLLBACK 복구 확인
- 반례 14/14·unexpected 0 확인
- 대표 EXPLAIN 확인
- 스키마 백업·별도 DB 복원 시험
- 선택 RAG 뷰 5/4/1 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 14. 최종 판정

```text
Chapter 15는 요구사항·설계·실행·운영·AI 검토가 추적되는 재현 가능한 최종 프로젝트로 2차 재구성했다.
실제 PostgreSQL 실행, 복원 시험과 출판 렌더링은 수동 확인이 필요하다.
```
