# Chapter 13 독자 워크북

## ChatGPT와 Codex로 DB 설계 검증하기

> 용도: 자기주도 실습 / Chapter 13 보조 자료

---

## 1. 실습 목표

이 워크북은 AI가 만든 데이터베이스 설계와 SQL을 요구사항, 실제 메타데이터, 실행 결과와 diff를 기준으로 검토하는 연습을 제공합니다.

```text
AI 결과는 정답이 아니라 검토 대상 초안이다.
실행 성공, 요구사항 반영과 업무 정합성을 각각 확인한다.
```

ChatGPT와 Codex의 기능과 지원 환경은 바뀔 수 있습니다. 이 자료의 역할 구분은 절대적인 기능 경계가 아니라 권장 작업 흐름입니다.

---

## 2. 준비와 안전 확인

사용 파일:

```text
code/chapter13/ai_db_design_review_practice.sql
```

> **실습 DB 확인**
>
> 이 파일은 Chapter 13 전용 `ai_bad_`, `ai_good_` 테이블을 삭제하고 다시 생성합니다. 개인 실습용 `ai_database_book`에서만 실행하고 운영 DB나 보존해야 할 데이터가 있는 DB에서는 실행하지 않습니다.

먼저 다음 결과를 기록합니다.

```sql
SELECT
    current_database() AS current_database_name,
    current_user AS current_user_name,
    current_schema() AS current_schema_name;
```

| 확인 항목 | 실제 결과 |
| --- | --- |
| 현재 데이터베이스 |  |
| 현재 사용자 |  |
| 현재 스키마 |  |
| DROP 대상이 Chapter 13 전용인가? |  |
| 오류 SQL이 주석 상태인가? |  |
| 실제 개인정보·카드번호·비밀번호가 없는가? |  |

---

## 3. 확인된 요구사항 기준선

| ID | 확인된 요구사항 | 설계 반영 위치 | 검증 방법 |
| --- | --- | --- | --- |
| R1 | 학생 이메일 중복 금지 |  |  |
| R2 | 강사 이메일 중복 금지 |  |  |
| R3 | 강의는 강사 한 명 참조 |  |  |
| R4 | 학생과 강의 N:M을 중간 테이블로 해소 |  |  |
| R5 | 수강 상태는 허용값만 사용 |  |  |
| R6 | 가격과 금액은 음수 금지 |  |  |
| R7 | 결제는 수강신청 참조 |  |  |
| R8 | 실제 카드번호 저장 금지 |  |  |

각 요구사항이 어떤 DDL, 오류 테스트 또는 메타데이터 결과와 연결되는지 작성합니다.

---

## 4. 사람이 결정해야 하는 미확정 규칙

| 질문 | 현재 판단 | AI가 임의로 확정했는가? | 추가 결정 |
| --- | --- | --- | --- |
| 취소 후 같은 강의 재신청 허용 여부 | 미확정 |  |  |
| 결제 시도를 여러 건 저장할지 | 단순 예제 1건 |  |  |
| 강의 가격 변경 후 기존 신청 금액 기준 | 신청 시점 금액 |  |  |
| 결제 없이 신청 상태 유지 가능 여부 | 가능 |  |  |
| 강의 삭제 시 기존 이력 처리 | 미확정 |  |  |
| 개인정보 보관 기간 | 조직 정책 필요 |  |  |

### 확인 질문

```text
미확정 정책이 UNIQUE, CASCADE 또는 NOT NULL로 임의 고정된 부분이 있는가?
```

---

## 5. 요구사항 추적표

| 요구사항 ID | AI 초안 반영 | 발견한 문제 | 수정 파일·위치 | 검증 증거 |
| --- | --- | --- | --- | --- |
| R1 |  |  |  |  |
| R2 |  |  |  |  |
| R3 |  |  |  |  |
| R4 |  |  |  |  |
| R5 |  |  |  |  |
| R6 |  |  |  |  |
| R7 |  |  |  |  |
| R8 |  |  |  |  |

검증 증거 예:

```text
DDL 줄, information_schema 결과, 오류 INSERT 결과,
정상 JOIN 결과, 예상 행 수, git diff
```

---

## 6. 나쁜 설계 분석

`ai_bad_enrollments`를 확인합니다.

```sql
SELECT
    id,
    student_email,
    course_title,
    course_price,
    payment_status,
    LEFT(card_number_plaintext, 9) || '...' AS unsafe_value_preview,
    enrollment_status,
    created_at
FROM ai_bad_enrollments
ORDER BY id;
```

| 요소 | 문제 | 수정 방향 |
| --- | --- | --- |
| 학생 정보 반복 |  |  |
| 강의·강사 정보 반복 |  |  |
| `course_price TEXT` |  |  |
| 상태값 자유 입력 |  |  |
| `created_at TEXT` |  |  |
| 평문 민감정보 형태 컬럼 |  |  |
| FK 부재 |  |  |
| 역할 혼합 |  |  |

나쁜 설계의 값은 `TEST-CARD-PLAINTEXT-01` 같은 가상 문자열입니다. 실제 카드번호가 아닙니다. 좋은 설계에는 카드번호 컬럼이 없어야 합니다.

---

## 7. 좋은 설계 테이블 역할

| 테이블 | 역할 | PK | FK |
| --- | --- | --- | --- |
| `ai_good_students` |  |  |  |
| `ai_good_instructors` |  |  |  |
| `ai_good_courses` |  |  |  |
| `ai_good_enrollments` |  |  |  |
| `ai_good_payments` |  |  |  |

### 관계 기록

| 부모 | 카디널리티 | 자식 | FK |
| --- | --- | --- | --- |
| instructors | 1 : 0..N | courses |  |
| students | 1 : 0..N | enrollments |  |
| courses | 1 : 0..N | enrollments |  |
| enrollments | 1 : 0..1 | payments |  |

마지막 관계는 단순 예제의 가정입니다. 결제 이력을 여러 건 저장하려면 무엇을 바꿔야 하는지 작성합니다.

---

## 8. 재신청 UNIQUE 정책 검토

다음 제약조건이 없는 이유를 설명합니다.

```sql
UNIQUE (student_id, course_id)
```

| 질문 | 답 |
| --- | --- |
| 취소 후 재신청이 가능해야 할 수 있는가? |  |
| 이력 보존에 어떤 문제가 생길 수 있는가? |  |
| 어떤 업무 정책이 확정되면 UNIQUE를 검토할 수 있는가? |  |

---

## 9. 현재 가격과 신청 시점 금액 구분

| 컬럼 | 의미 | 변경 시점 |
| --- | --- | --- |
| `courses.price` |  |  |
| `enrollments.agreed_amount` |  |  |
| `payments.amount` |  |  |

다음 조회 결과가 존재해도 자동 오류가 아닌 이유를 설명합니다.

```sql
SELECT
    e.id,
    c.price AS current_course_price,
    e.agreed_amount
FROM ai_good_enrollments AS e
JOIN ai_good_courses AS c
    ON c.id = e.course_id
WHERE c.price <> e.agreed_amount;
```

반면 다음 조회는 이 장의 단순 예제에서 0행이어야 합니다.

```sql
SELECT
    e.id,
    e.agreed_amount,
    p.amount
FROM ai_good_enrollments AS e
JOIN ai_good_payments AS p
    ON p.enrollment_id = e.id
WHERE e.agreed_amount <> p.amount;
```

---

## 10. 예상 행 수와 실제 결과

| 항목 | 예상값 | 실제 결과 |
| --- | ---: | ---: |
| `ai_bad_enrollments` | 3 |  |
| `ai_good_students` | 3 |  |
| `ai_good_instructors` | 2 |  |
| `ai_good_courses` | 3 |  |
| `ai_good_enrollments` | 4 |  |
| `ai_good_payments` | 4 |  |
| 정상 JOIN | 4 |  |
| 외래키 관계 | 4 |  |

---

## 11. 정상 JOIN 결과 기록

| enrollment_id | student_name | course_code | course_title | enrollment_status | agreed_amount | payment_status | payment_amount |
| ---: | --- | --- | --- | --- | ---: | --- | ---: |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |

JOIN이 필요하더라도 테이블을 분리하는 이유를 작성합니다.

---

## 12. 선택적 오류 테스트

오류 SQL은 한 번에 하나씩 주석을 해제합니다.

| 오류 테스트 | 기대 제약조건 | 실제 오류 요약 | 기본 데이터 유지 |
| --- | --- | --- | --- |
| 중복 학생 이메일 | UNIQUE |  |  |
| 없는 학생 FK | FOREIGN KEY |  |  |
| 없는 강의 FK | FOREIGN KEY |  |  |
| 잘못된 수강 상태 | CHECK |  |  |
| 음수 강의 가격 | CHECK |  |  |
| 음수 신청 금액 | CHECK |  |  |
| 음수 결제금액 | CHECK |  |  |
| 잘못된 결제 상태 | CHECK |  |  |
| 결제완료인데 `paid_at` NULL | CHECK |  |  |
| 중복 `payment_reference` | UNIQUE |  |  |

오류 후 다음 정상 SELECT가 실행되지 않는다면 현재 트랜잭션이 aborted 상태인지 확인하고 `ROLLBACK`합니다.

```sql
ROLLBACK;
```

---

## 13. 실제 메타데이터 확인

### 테이블과 컬럼

| 테이블 | 주요 컬럼·타입 | NULL 허용 검토 |
| --- | --- | --- |
| students |  |  |
| instructors |  |  |
| courses |  |  |
| enrollments |  |  |
| payments |  |  |

### CHECK와 UNIQUE

`information_schema.table_constraints`와 `information_schema.check_constraints`를 함께 조회해 실제 CHECK 내용을 확인합니다.

| table_name | constraint_type | check_clause 또는 의미 |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |

### 외래키 관계: 예상 4개

| source_table | source_column | target_table | target_column |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

정렬 순서는 환경에 따라 달라질 수 있으므로 관계 자체를 확인합니다.

### 인덱스

`pg_indexes` 결과에서 PK, UNIQUE가 어떤 인덱스로 구현되었는지 확인합니다.

| tablename | indexname | 확인 내용 |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |

---

## 14. 업무 정합성 검증

다음 조회의 예상 결과는 모두 0행입니다.

| 검증 | 실제 행 수 | 해석 |
| --- | ---: | --- |
| 학생 이메일 중복 |  |  |
| 강사 이메일 중복 |  |  |
| 합의 금액과 결제금액 불일치 |  |  |
| 결제완료·환불인데 `paid_at` NULL |  |  |
| 결제대기·결제실패인데 `paid_at` 존재 |  |  |

수강 상태와 결제 상태 조합은 표시용으로 검토합니다.

```text
완료 → 결제완료
신청 → 결제대기
취소 → 환불
```

이 조합이 모든 서비스에 적용되는 보편 규칙이 아닌 이유를 작성합니다.

---

## 15. 좋은 프롬프트 작성

| 요소 | 작성 |
| --- | --- |
| 배경과 목표 |  |
| 확인된 요구사항 |  |
| 미확정 규칙 |  |
| PostgreSQL·금액 가정 |  |
| 수정 대상 파일 |  |
| 수정 금지 범위 |  |
| 출력 형식 |  |
| 검증 기준 |  |
| 완료 보고 |  |

---

## 16. 오류 메시지의 민감정보 제거

AI에 전달할 수 있는 정보:

```text
오류 코드·유형, 관련 SQL, 테이블·컬럼명,
재현 단계, 기대 결과, 실제 결과
```

제거하거나 마스킹할 정보:

```text
비밀번호, API 키, 전체 연결 문자열, 실제 서버 주소,
실제 고객 이메일, 카드번호, 운영 데이터, 비밀 파일 내용
```

다음 오류 수정 프롬프트를 안전하게 완성합니다.

```text
다음 PostgreSQL 오류를 분석하고
code/chapter13/ai_db_design_review_practice.sql을 수정해 주세요.

오류:
[비밀정보를 제거한 오류]

재현 단계:
[작성]

기대 결과:
[작성]

수정 금지:
[작성]

검증:
[작성]
```

---

## 17. Codex 변경 후 diff 검토

| 자기점검 항목 | 확인 | 보완 내용 |
| --- | --- | --- |
| 요청한 파일만 변경되었는가? |  |  |
| 기존 요구사항이 유지되었는가? |  |  |
| 새로운 UNIQUE·CASCADE가 임의 추가되지 않았는가? |  |  |
| 비밀번호나 실제 데이터가 포함되지 않았는가? |  |  |
| DROP·DELETE·UPDATE 범위가 안전한가? |  |  |
| 실행 결과와 예상값이 함께 제공되었는가? |  |  |
| 본문·README·워크북과 일치하는가? |  |  |
| 관련 없는 포맷 변경이 없는가? |  |  |

AI가 수정한 코드뿐 아니라 diff 자체를 사람이 검토해야 하는 이유를 작성합니다.

---

## 18. 요구사항 추적 최종 기록

| 요구사항 | 최종 설계 위치 | 검증 증거 | 통과 여부 |
| --- | --- | --- | --- |
| 이메일 중복 금지 |  |  |  |
| 강사 FK |  |  |  |
| N:M 해소 |  |  |  |
| 상태 제한 |  |  |  |
| 음수 금액 차단 |  |  |  |
| 결제 FK |  |  |  |
| 카드번호 미저장 |  |  |  |
| 미확정 규칙 미고정 |  |  |  |

---

## 19. 최종 자기점검

| 자기점검 항목 | 확인 | 보완 내용 |
| --- | --- | --- |
| 요구사항과 미확정 규칙을 구분했는가? |  |  |
| AI가 임의로 추가한 제약조건을 찾았는가? |  |  |
| PK·FK·CHECK·UNIQUE를 실제 메타데이터로 확인했는가? |  |  |
| 정상 결과와 오류 테스트를 모두 확인했는가? |  |  |
| 오류에서 비밀정보를 제거했는가? |  |  |
| Codex가 수정한 diff를 검토했는가? |  |  |
| 예상 행 수와 실제 결과가 일치하는가? |  |  |
| 남은 업무 가정을 기록했는가? |  |  |

점수나 배점보다 부족한 근거와 미확정 규칙을 발견하고 보완하는 데 집중합니다.

---

## 20. 핵심 정리

```text
- AI 결과는 요구사항과 실행 증거로 검토한다.
- 미확정 정책을 제약조건으로 임의 고정하지 않는다.
- 현재 가격, 신청 시점 금액과 결제금액을 구분한다.
- 실제 DB 구조는 information_schema와 pg_indexes로 확인한다.
- 오류 메시지에서 비밀정보를 제거한다.
- Codex 변경은 diff와 재실행 결과를 사람이 승인한다.
```
