# Chapter 04 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 04. 관계형 데이터베이스와 SQL 시작하기
```

## 리뷰 목적

Chapter 04가 첫 SQL 실습 장으로서 기술적으로 정확하고, 독자가 잘못된 위치·순서·범위에서 변경 SQL을 실행하지 않도록 충분한 안전장치를 갖추었는지 최종 점검합니다.

---

## 1. 구조와 장 간 연결

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| Chapter 03과 연결되는가 | 통과 | `current_database()`, `current_schema()`, `SHOW search_path` 기준 통일 |
| SQL 기초 흐름이 단계적인가 | 통과 | 위치 확인 → 생성 → 입력 → 조회 → 조건·NULL·정렬 → 수정·삭제 → AI 검토 |
| CRUD 개념과 연결되는가 | 통과 | CRUD Create와 `CREATE TABLE`의 차이까지 설명 |
| 데이터 상태가 일관적인가 | 통과 | 체크포인트 A·B·C로 입력·수정·삭제 이후 상태 구분 |
| 활동 자료가 연결되는가 | 통과 | 본문에서 `chapter04_activity.md` 안내 |
| 다음 장과 연결되는가 | 통과 | Chapter 05의 데이터 모델링과 ERD로 연결 |

---

## 2. 테이블 정의와 데이터 타입

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 스키마가 명시되는가 | 통과 | 모든 주요 예제에서 `public.students` 사용 |
| 시간 타입이 적절한가 | 통과 | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` 적용 |
| `CURRENT_TIMESTAMP` 설명이 정확한가 | 통과 | 현재 트랜잭션 시작 시각임을 설명 |
| IDENTITY 설명이 정확한가 | 통과 | 빈 번호 가능, 행 수·업무 순번으로 사용 금지 |
| 교육용 최소 구조임을 밝히는가 | 통과 | 학년 범위·전공 표준화·이메일 규칙은 Chapter 06으로 연결 |

---

## 3. SELECT와 결과 순서

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| `ORDER BY` 없는 결과 순서를 경고하는가 | 통과 | 입력·ID 순서를 가정하지 않도록 설명 |
| `DESC`의 NULL 위치를 명시하는가 | 통과 | `NULLS LAST` 사용 |
| 동률 정렬이 안정적인가 | 통과 | `id`를 보조 정렬 기준으로 추가 |
| `LIMIT`이 안정적인 정렬과 함께 사용되는가 | 통과 | `created_at DESC, id DESC LIMIT 3` 적용 |
| DBeaver 특정 화면 문구에 의존하지 않는가 | 통과 | 영향받은 행 수와 `RETURNING` 결과 중심으로 설명 |

---

## 4. NULL과 조건 처리

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| `= NULL` 설명이 정확한가 | 통과 | 문법 오류가 아니라 `UNKNOWN`이 되어 일반적으로 0행 반환 |
| `<>`에서 NULL 제외를 설명하는가 | 통과 | 윤서진이 제외되는 이유 설명 |
| NULL 포함 조건을 제공하는가 | 통과 | `OR major IS NULL`과 `IS DISTINCT FROM` 제시 |
| LIKE 패턴이 충분한가 | 통과 | `%`, `_`, PostgreSQL의 `ILIKE` 설명 |

---

## 5. 변경 SQL 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 자동 커밋 위험을 설명하는가 | 통과 | 변경 직후 확정 가능성과 실행 취소 불가 가정 금지 |
| UPDATE 전 SELECT가 있는가 | 통과 | `SELECT → UPDATE RETURNING → 영향 행 수 → SELECT` |
| DELETE 전 SELECT가 있는가 | 통과 | `SELECT → DELETE RETURNING → 영향 행 수 → SELECT` |
| WHERE 없는 변경의 위험이 있는가 | 통과 | 전체 행 수정·삭제 예제를 실행 금지로 제시 |
| AI 삭제 SQL이 실제 상태와 맞는가 | 통과 | 체크포인트 C의 컴퓨터공학 2명을 대상으로 검토만 수행 |
| 자기 확인 문제 상태가 명확한가 | 통과 | 체크포인트 A 복원 안내 추가 |

---

## 6. 초기화 파일 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 기본 SQL에 자동 DROP이 없는가 | 통과 | `basic_crud.sql`과 초기화 분리 유지 |
| 삭제 대상 스키마가 명확한가 | 통과 | `public.students` 명시 |
| 잘못된 DB에서 실행을 차단하는가 | 통과 | `DO` 블록에서 `ai_database_book` 확인 |
| 잘못된 스키마에서 실행을 차단하는가 | 통과 | `DO` 블록에서 `public` 확인 |
| 파일 설명이 본문과 일치하는가 | 통과 | 본문·워크북·코드 README 동기화 |

---

## 7. 자기주도 학습 지원

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 기준 데이터 상태가 제공되는가 | 통과 | 체크포인트 A·B·C 표 제공 |
| 권장 해설이 있는가 | 통과 | 개념·SQL·위험 SQL·예상 결과 해설 추가 |
| 워크북이 최신 SQL과 일치하는가 | 통과 | `TIMESTAMPTZ`, `search_path`, 정렬, NULL, 자동 커밋 반영 |
| 실제 ID를 기록하도록 안내하는가 | 통과 | ID가 반드시 1이라는 가정 제거 |
| AI 검토 활동이 안전한가 | 통과 | 실행하지 않는 가상 DELETE로 명시 |

---

## 8. 동기화 대상

| 파일 | 상태 |
| --- | --- |
| `book/chapter04/chapter04.md` | 완료 |
| `book/chapter04/chapter04_activity.md` | 완료 |
| `book/chapter04/chapter04_outline.md` | 완료 |
| `code/chapter04/basic_crud.sql` | 완료 |
| `code/chapter04/reset_students.sql` | 완료 |
| `code/chapter04/README.md` | 완료 |
| `book/chapter04/chapter04_review_revision.md` | 완료 |
| 루트 `README.md` 상태 | 완료 |

---

## 9. 최종 판정

```text
Chapter 04는 실행 위치, 시간 타입, 정렬 안정성, NULL 비교,
자동 커밋, 데이터 상태 충돌과 초기화 안전성 보완을 완료했다.

본문·워크북·SQL·초기화 파일·구성안·코드 안내의 핵심 예제가 동기화되었으므로
최종 출판 전 내용 검수 완료 상태로 판정한다.
```

실제 PostgreSQL 통합 실행과 Word·PDF·eBook 렌더링은 전체 제작 단계에서 별도로 확인합니다.
