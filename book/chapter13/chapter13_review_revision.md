# Chapter 13 출간용 문체 및 설계 검증 보정 기록

## 대상 파일

```text
book/chapter13/chapter13.md
book/chapter13/chapter13_outline.md
book/chapter13/chapter13_activity.md
code/chapter13/ai_db_design_review_practice.sql
code/chapter13/README.md
images/chapter13/README.md
notes/chapter13_review_checklist.md
images/chapter13/ch13_*.mmd
images/chapter13/ch13_*.svg
```

## 목적

AI 결과를 정답처럼 소개하던 흐름을 요구사항 기준선, 미확정 정책, 실제 메타데이터, 정상·오류 테스트와 diff를 근거로 검토하는 흐름으로 보정했습니다.

---

## 1. 기존 기록 유지

기존 원고는 AI 설계 검토, ERD·DDL, SQL Anti-pattern과 Codex 오류 수정의 기본 흐름을 포함하고 있었습니다. 이번 보정은 기존 주제를 삭제하는 것이 아니라 기술적 정확성과 검증 근거를 강화한 작업입니다.

---

## 2. 이번 보정 내역

| 보정 항목 | 상태 | 내용 |
| --- | --- | --- |
| OpenAI 제품 역할 설명 | 완료 | 고정 기능 경계가 아닌 권장 작업 흐름으로 변경 |
| 공식 문서 확인 | 완료 | 작업 시점 OpenAI 공식 문서 기준으로 검토 |
| 요구사항 기준선 | 완료 | R1~R8과 설계·검증 위치 연결 |
| 미확정 규칙 | 완료 | 재신청·결제 이력·삭제 정책 등 분리 |
| 요구사항 추적표 | 완료 | 수정 파일과 검증 증거 기록 |
| 좋은 프롬프트 구조 | 완료 | 목표·요구사항·금지 범위·검증·완료 보고 포함 |
| 민감정보 전달 원칙 | 완료 | 오류의 기술 내용 유지, 비밀정보 제거 |
| 재신청 UNIQUE | 제거 | 정책 미확정 상태를 제약으로 고정하지 않음 |
| 강의 식별자 | 완료 | `course_code UNIQUE` 추가 |
| 가격 의미 분리 | 완료 | 현재 가격·합의 금액·결제금액 구분 |
| 결제 단순화 가정 | 완료 | 한 수강신청당 현재 결제 1건 |
| 나쁜 설계 가상값 | 완료 | 실제 카드번호 형태 제거 |
| SQL 안전 실행 | 완료 | DB·사용자·스키마 확인과 오류 후 ROLLBACK |
| 예상값 | 완료 | 3·3·2·3·4·4, JOIN 4행, FK 4개 |
| 메타데이터 | 완료 | CHECK 정의와 `pg_indexes`까지 확장 |
| 업무 정합성 | 완료 | 이상 조회 예상 0행 |
| Codex diff 검토 | 완료 | 관련 없는 변경·임의 정책·보안 확인 |
| Mermaid | 완료 | 8개 한국어화와 반복 경로 보강 |
| SVG | 완료 | 접근성·들여쓰기·유지보수 구조 재작성 |
| 워크북 | 완료 | 잘못된 행 수와 배점표 보정 |
| outline | 완료 | 웹 CRUD 범위 제거, 실제 본문 순서 동기화 |

---

## 3. 좋은 설계 DDL 변경

```text
- courses: course_code 추가, 제목 기반 UNIQUE 제거
- enrollments: agreed_amount 추가, 학생·강의 UNIQUE 제거
- payments: enrollment_id FK, 상태·paid_at CHECK, payment_reference
- 실제 카드번호 컬럼은 좋은 설계에서 사용하지 않음
```

`courses.price`는 현재 기본 가격, `enrollments.agreed_amount`는 신청 시점 금액, `payments.amount`는 실제 결제 기록으로 분리했습니다.

---

## 4. 그림별 변경

| 그림 | 변경 내용 |
| --- | --- |
| 13-1 | 요구사항·AI 초안·사람 검토·SQL 실행·증거 검증과 실패 시 반복 |
| 13-2 | ChatGPT·Codex의 기능 중첩과 사람의 정책·권한·승인 책임 |
| 13-3 | 배경·요구사항·미확정 규칙·파일 범위·출력·검증 기준 |
| 13-4 | 요구사항 기준 ERD 검토와 임의 UNIQUE·CASCADE 재검토 |
| 13-5 | 역할이 섞인 테이블과 역할별 분리 구조 비교 |
| 13-6 | 업무 규칙에서 제약조건·오류 테스트·메타데이터로 연결 |
| 13-7 | 예상 설계와 실제 메타데이터의 반복 비교 |
| 13-8 | 오류 재현·비밀정보 제거·최소 변경·diff·재실행·사람 승인 |

---

## 5. 제거한 잘못된 내용과 중복

```text
- ChatGPT와 Codex의 절대적인 기능 경계 표현
- 존재하지 않는 schema.sql 수정 예시
- 웹 CRUD 구현 범위
- 실제 카드번호처럼 보이는 테스트 문자열
- 근거 없는 UNIQUE(instructor_id, title)
- 미확정 재신청 정책을 고정한 UNIQUE(student_id, course_id)
- 현재 강의 가격과 과거 결제금액의 직접 오류 비교
- 오류 메시지를 비밀정보 제거 없이 전달하는 안내
- 실행 성공만으로 검증 완료 처리
- SVG의 전체 표·SQL 반복
- 워크북의 100점 배점표
```

---

## 6. 검증 결과

| 검증 | 결과 |
| --- | --- |
| SQL 정적 구조·예상값 검토 | 통과 |
| PostgreSQL 실제 실행 | 미실행 |
| Mermaid 핵심 구조·한국어 노드 검토 | 통과 |
| Mermaid CLI 문법 실행 | 미실행 |
| SVG XML 파싱 | 8개 통과 |
| SVG 접근성 속성 | 8개 통과 |
| 임시 PNG 렌더링 | 8개 통과 |
| GitHub 실제 미리보기 | 수동 확인 필요 |
| Word·PDF·eBook 변환 | 미실행 |
| Chapter 12·14 원본 변경 | 없음 |

---

## 7. 남은 업무 가정

```text
- 취소 후 같은 강의 재신청 정책
- 결제 재시도·실패·부분결제·환불 이력 모델
- 강의와 관련 이력의 삭제 정책
- 개인정보 보관 기간
- 상태 전이 규칙
```

이 항목은 요구사항이 확정되기 전까지 제약조건으로 고정하지 않습니다.

---

## 결론

```text
Chapter 13은 AI가 만든 설계를 설명하는 장에서
요구사항과 실행 증거로 AI 결과를 검증하는 장으로 보정했다.
실제 PostgreSQL 실행과 출판 변환 결과는 후속 확인이 필요하다.
```
