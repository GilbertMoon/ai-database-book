# Chapter 13 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter13/chapter13.md
book/chapter13/chapter13_activity.md
book/chapter13/chapter13_outline.md
book/chapter13/chapter13_review_revision.md
code/chapter13/01_ai_review_lab_schema.sql
code/chapter13/02_bad_design_seed.sql
code/chapter13/03_good_design_schema.sql
code/chapter13/04_good_design_seed.sql
code/chapter13/05_metadata_validation.sql
code/chapter13/06_business_validation.sql
code/chapter13/07_negative_tests.sql
code/chapter13/08_ai_review_lab_validation.sql
code/chapter13/AI_REVIEW_REPORT_TEMPLATE.md
code/chapter13/PROMPT_TEMPLATES.md
code/chapter13/reset_ai_review_lab.sql
code/chapter13/ai_db_design_review_practice.sql
code/chapter13/README.md
notes/chapter13_review_checklist.md
README.md
```

## 최종 목표

Chapter 13을 AI 설계 설명 장이 아니라 다음 증거를 사용해 변경을 승인하는 운영형 검토 장으로 완성했습니다.

```text
P13 요구사항·결정
→ DB·스키마 보호
→ 원자적 생성·Seed
→ 정확한 메타데이터
→ 정상·경계값·반례
→ NULL 안전 업무 검증
→ IDENTITY·민감정보·diff
→ 최종 자동 판정
→ 사람 승인
```

---

## 1. 생성·초기화 보호

- 현재 DB가 `ai_database_book`이 아니면 생성·초기화 중단
- `course_project.enrollments = 5` 기준 확인
- 기존 `ai_review_lab` 존재 시 생성 중단
- 스키마와 테이블을 한 트랜잭션에서 생성
- reset은 자식→부모 순서로 `ai_review_lab`만 삭제
- 모든 SQL에 `SHOW search_path` 적용

---

## 2. Seed 재실행·부분 입력 방지

- 나쁜 설계 Seed는 대상 테이블 0행 확인
- 좋은 설계 Seed는 다섯 테이블 존재·0행 확인
- 각 Seed를 트랜잭션으로 실행
- COMMIT 전 기준 행 수와 금액 관계 자동 판정

---

## 3. IDENTITY 시작값 조정

```text
bad_enrollments → 4
students → 104
instructors → 203
courses → 304
enrollments → 1005
payments → 9005
```

명시적 ID가 시퀀스를 자동 이동시키지 않는다는 설명과 최종 검증을 본문·워크북·README에 동기화했습니다.

---

## 4. 추적 ID 통일

```text
P13-R01~P13-R09  요구사항
P13-D01~P13-D08  결정·범위
P13-T01~P13-T27  테스트
P13-V01~P13-V08  실행·검증
```

기존 R1·D1 형식을 Chapter 범위가 드러나는 ID로 변경했습니다.

---

## 5. Chapter 07 활성 신청 정책 유지

```sql
CREATE UNIQUE INDEX uq_ai_review_enrollments_active
ON ai_review_lab.enrollments (student_id, course_id)
WHERE status IN ('신청', '수강중');
```

전체 복합 UNIQUE는 사용하지 않습니다. 진행 중 중복만 차단하고 완료·취소 이력 뒤 재신청은 허용합니다.

---

## 6. 문자열·이메일 무결성

다음 필드에 공백 방지 CHECK를 추가했습니다.

```text
students.name·email
instructors.name·email·specialty
courses.course_code·title
payments.payment_reference
```

이메일은 정확히 같은 문자열만 중복 차단하며 대소문자 정규화는 P13-D07로 남겼습니다.

---

## 7. 결제·환불 의미 보완

기존 `paid_at` 하나에서 다음 두 시각으로 분리했습니다.

```text
paid_at
refunded_at
```

상태별 조합을 CHECK로 제한했습니다.

```text
결제대기·결제실패 → 두 시각 NULL
결제완료 → paid_at만 존재
환불 → paid_at·refunded_at 존재, 환불 시각이 이후
```

샘플은 전액 결제·전액 환불이며 부분 환불 원장은 범위 밖이라고 명시했습니다.

---

## 8. LEFT JOIN NULL 검증 오류 수정

결제 누락을 놓칠 수 있는 `<>` 비교를 `IS DISTINCT FROM`으로 수정했습니다.

```text
완료 → 결제완료 필수
취소 → 환불 필수
신청 → 결제 없음 허용, 있으면 결제대기
수강중 → 결제 없음 허용, 있으면 결제완료
```

---

## 9. 정확한 메타데이터 자동 검증

`05_metadata_validation.sql`은 다음을 자동 판정합니다.

```text
정확한 테이블 집합 6개
좋은 설계 제약조건 29개
정확한 FK 이름·출발·대상 4개
삭제 규칙 RESTRICT/NO ACTION
IDENTITY id 6개
활성 신청 부분 고유 인덱스
민감정보 전용 컬럼 이름 0개
```

단순 개수만으로 통과하지 않도록 수정했습니다.

---

## 10. 업무 정합성 전체 판정

`06_business_validation.sql`의 마지막 DO 블록이 다음을 모두 판정합니다.

```text
기준 행·JOIN
이메일 중복·필수 문자열 공백
합의·결제 금액
결제·환불 시각
고아 관계
활성 신청 중복
샘플 상태 조합
가격 차이 정보용 1행
```

---

## 11. 반례와 정상 경계값 확대

`07_negative_tests.sql`을 헬퍼 프로시저 기반으로 재작성했습니다.

```text
P13-T01~T22 expected_failure
P13-T23~T27 expected_success
전체 27 / 통과 27 / unexpected 0
```

`GET STACKED DIAGNOSTICS`로 다음을 기록합니다.

```text
SQLSTATE
constraint name
table name
column name
오류 상세
```

정상 경계값:

```text
가격 0
한 글자 이름·제목
NULL description
결제 없는 신청
완료·취소 이력 뒤 재신청
결제실패·금액 0·시각 NULL
```

---

## 12. 최종 자동 검증 파일 추가

신규 파일:

```text
code/chapter13/08_ai_review_lab_validation.sql
```

검증 범위:

```text
Chapter 07 신청 5행 유지
기준 행 3/3/2/3/4/4
JOIN 4
정확한 테이블·제약·FK·IDENTITY
필수 문자열·고아 관계·활성 중복 0
금액·시각·상태 조합 0
가격 차이 1행
IDENTITY 다음 값 > 최대 ID
같은 세션이면 07의 27/27 재확인
```

---

## 13. 민감정보 검증 증거 강화

컬럼명 검사만으로 카드번호 미저장을 증명하지 않도록 수정했습니다.

```text
전용 민감 컬럼 없음
payment_reference 의미 문서화
가상 Seed 값
로그·프롬프트 민감 패턴 검토
앱이 카드정보를 DB로 전달하지 않는 흐름 검토
```

---

## 14. 보고서·프롬프트·워크북 동기화

다음을 추가·수정했습니다.

```text
P13 ID
IDENTITY 다음 값
활성 부분 고유 인덱스
SQLSTATE·constraint name
정상 경계값 5개
paid_at·refunded_at
부분 환불 범위
08 최종 자동 검증
미실행 항목과 승인 상태
```

---

## 15. Chapter 14 연결 수정

기존 Vector DB·RAG 안내를 현재 목차에 맞게 수정했습니다.

```text
SQL 분석 질문
집계·윈도우 함수
Python·pandas 확장
SQL·Python 결과 교차 검증
AI 분석 코드 검토
```

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| DB·스키마 보호 | 완료 |
| Seed 재실행 차단 | 완료 |
| IDENTITY 시작값 | 완료 |
| P13 추적 ID | 완료 |
| 활성 신청 정책 | 완료 |
| 문자열 공백·이메일 범위 | 완료 |
| 결제·환불 시각 | 완료 |
| LEFT JOIN NULL 검증 | 완료 |
| 정확한 메타데이터 | 완료 |
| 업무 전체 판정 | 완료 |
| 반례·경계값 27개 | 완료 |
| constraint name 증거 | 완료 |
| 최종 08 검증 | 완료 |
| 민감정보 증거 | 완료 |
| Chapter 14 연결 | 완료 |
| 본문·워크북·문서 동기화 | 완료 |

## 남은 실제 확인

```text
- PostgreSQL에서 01→08 순차 실행
- 05·06·07·08 통과 메시지 확인
- 반례 27/27·unexpected 0 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

실제 실행하지 않은 항목은 검토 보고서에서 통과로 표시하지 않습니다.
