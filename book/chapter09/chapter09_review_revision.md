# Chapter 09 출간용 문체 및 도식 보정 기록

## 대상 파일

```text
book/chapter09/chapter09.md
book/chapter09/chapter09_outline.md
book/chapter09/chapter09_activity.md
code/chapter09/*
images/chapter09/*
notes/chapter09_review_checklist.md
```

## 1. 기존 기록

Chapter 09의 1차 원고, 실습 SQL, 활동 자료, Mermaid와 SVG가 작성되어 있었으며 일반 독자용 문체 정리를 진행했습니다.

## 2. 이번 보정 내용

| 보완 항목 | 상태 | 반영 내용 |
| --- | --- | --- |
| 본문 절 구조 재정렬 | 완료 | 16개 절을 권장 흐름으로 정렬 |
| 그림 번호와 파일 연결 | 완료 | 그림 9-1~9-8을 서로 다른 파일로 한 번씩 배치 |
| ACID 절 | 완료 | 개념 표, 주의 문장, 그림 9-4 추가 |
| 동시성·Lock·Deadlock 절 | 완료 | 정상 대기와 순환 대기 구분, 그림 9-7 추가 |
| 확장 스키마 설명 | 완료 | courses 확장과 payments 추가 명시 |
| payments 관계 | 완료 | student_id·course_id 제거, enrollment_id UNIQUE FK 적용 |
| 상태와 제약조건 | 완료 | 기존 상태값과 금액·좌석 CHECK 통일 |
| DB 안전 경고 | 완료 | current_database와 DROP 대상 명시 |
| 좌석 UPDATE 0행 | 완료 | 자동 실패가 아니며 후속 INSERT 금지 명시 |
| 성공 SQL | 완료 | Lock, UPDATE RETURNING, 신청·결제 연결, COMMIT 전 SELECT 순서 적용 |
| ROLLBACK 예제 | 완료 | 세 테이블 임시 변경과 원상 복구 확인 |
| 정합성 검증 | 완료 | 좌석 범위, 결제 누락·금액, 좌석 사용량 SQL 추가 |
| SVG 8개 | 완료 | 한 메시지 중심, 접근성·유지보수 구조 적용 |
| Mermaid 8개 | 완료 | SVG 핵심 흐름과 동기화 |
| README·리뷰 문서 | 완료 | 실제 상태와 수동 확인 항목 갱신 |

## 3. 제거한 중복과 오해 가능성

```text
- 같은 SVG의 그림 번호 중복 사용
- 본문 표와 전체 SQL을 SVG 안에 반복한 내용
- COMMIT 전 검증 없이 즉시 확정하는 흐름
- UPDATE 0행이 자동 실패·자동 ROLLBACK된다는 인상
- payments.student_id와 payments.course_id 중복 관계
- 결제대기·결제완료 상태값
- Lock 대기를 곧바로 Deadlock으로 연결하는 표현
- Consistency와 Isolation이 모든 규칙·가시성을 자동 보장한다는 표현
```

## 4. 검증 결과

| 검증 항목 | 결과 |
| --- | --- |
| 본문·활동·SQL 구조와 예상값 | 통과 |
| payments FK와 상태값 | 통과 |
| 그림 번호·경로 중복 | 통과 |
| Mermaid 핵심 논리 | 통과 |
| SVG XML 파싱 | 통과 |
| SVG 접근성 구조 | 통과 |
| 임시 PNG 렌더링 | 통과 |
| Mermaid CLI 문법 실행 | 미실행 — CLI 없음 |
| PostgreSQL 실제 SQL 실행 | 미실행 — 정적 검토 |
| GitHub 실제 미리보기 | 수동 확인 필요 |
| Word/PDF/eBook 변환 | 미실행 — 수동 확인 필요 |

## 5. Chapter 08·10 비교

Chapter 08의 기본 `students`, `instructors`, `courses`, `enrollments` 구조와 상태값을 기준으로 Chapter 09의 확장 컬럼과 `payments`를 설명했습니다. Chapter 10의 인덱스 장 연결 문장을 유지했습니다. 두 Chapter 파일은 수정하지 않았습니다.

## 6. 결론

```text
Chapter 09는 트랜잭션 경계, 정합성 규칙, 좌석 확보 실패 처리와 동시성 기초를 하나의 일관된 수강신청 예제로 설명하도록 보정했다.
실제 PostgreSQL 실행과 출판 파이프라인 렌더링은 후속 수동 확인 항목으로 남긴다.
```
