# Chapter 14 전체 점검·수정 반영 기록

## Chapter

```text
Chapter 14. SQL 데이터 분석과 Python 확장
```

## 전체 점검 범위

Chapter 14를 본문 설명만이 아니라 다음 전체 흐름으로 다시 점검했습니다.

```text
Chapter 07·08 canonical source
→ analysis_lab 합성 분석 시나리오
→ 분석 질문·기간·행 단위·지표 의미
→ SQL 구조·Seed·품질 검사
→ 집계·date spine·분석 VIEW
→ SQL 완료 게이트
→ 읽기 전용 PostgreSQL 또는 CSV + manifest
→ pandas strict 검증
→ 실제 SQL·pandas 교차 검증
→ 결과·한계 기록
```

점검 대상:

```text
book/chapter14
code/chapter14
code/chapter14/python
images/chapter14
presentation/chapter14
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js
notes/chapter14_review_checklist.md
.github/workflows/validate-chapter14.yml
.github/workflows/validate-chapter14-navigation.yml
.github/workflows/validate-chapter14-publishing.yml
```

---

## 1. Chapter 13 → 14 연결

Chapter 13의 핵심 원칙은 “AI가 만든 결과를 설명이 아니라 실행 증거로 검증한다”입니다. Chapter 14에서는 이 원칙을 데이터 분석으로 확장했습니다.

```text
분석 질문을 먼저 정의한다.
→ SQL로 기준 결과를 만든다.
→ Python/pandas로 같은 질문을 다시 계산한다.
→ 두 결과를 같은 행 단위·기간·지표 의미로 비교한다.
→ 불일치가 있으면 기대값을 실제값에 맞추지 않고 원인을 찾는다.
```

Chapter 14의 분석 질문은 P14-Q01~Q05로 유지합니다.

```text
P14-Q01 상태별 수강신청 건수
P14-Q02 월별 신청 수와 신청 시점 기록 금액
P14-Q03 강의별 신청 건수
P14-Q04 지역별 학생·신청 건수
P14-Q05 완료된 신청의 완료 기간
```

공통 분석 기간:

```text
[2026-01-01, 2026-07-01)
날짜 기준 = enrolled_at
기본 행 단위 = 수강신청 1건
```

---

## 2. analysis_lab은 합성 분석 시나리오

`analysis_lab`의 8명·3명·5개·24건은 SQL·Python 분석을 학습하기 위한 합성 기준 데이터입니다.

```text
course_project를 복제한 운영 데이터가 아니다.
course_project의 행 수를 확장한 것이 아니다.
기존 Chapter 스키마는 변경하지 않는다.
```

다만 Chapter 07 이후 확정한 금액 의미는 그대로 이어 갑니다.

```text
course_project.enrollments.recorded_amount
analysis_lab.enrollments.recorded_amount
→ 신청 시점 기록 금액
```

두 컬럼 모두 `NUMERIC(12,0)` 기준을 사용합니다.

---

## 3. 가장 중요한 금액 의미 보정

초기 Chapter 14에는 격리 테이블의 물리 컬럼이 `paid_amount INTEGER`로 남아 있었고, 취소 건은 금액을 0으로 저장했습니다.

이를 다음처럼 수정했습니다.

```text
paid_amount 제거
→ recorded_amount NUMERIC(12,0)

취소 상태
→ recorded_amount를 0으로 덮어쓰지 않음
→ 신청 시점 역사값 유지
```

취소 행:

```text
1003 = 취소 / 150000
1011 = 취소 / 140000
1019 = 취소 / 150000
```

따라서 Chapter 14 합성 데이터의 최종 기록 금액은 다음으로 확정됩니다.

```text
전체 recorded_amount = 3210000
```

`recorded_amount`는 결제 승인액·환불 반영 순액·회계 매출이 아닙니다. 환불·순매출을 계산하려면 별도 결제·환불 원장이 필요합니다.

기존 취소금액 0 강제 CHECK를 제거하면서 analysis_lab의 PK·FK·CHECK·UNIQUE 제약조건 수는 **20개**가 되었습니다.

---

## 4. Chapter 07·08 시작 기준 게이트

`01_analysis_lab_schema.sql`은 생성 전에 보호 대상 `course_project`의 canonical 상태를 확인합니다.

```text
students = 3
instructors = 2
courses = 3
enrollments = 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
recorded_amount = NUMERIC(12,0)
전체 = 590000
활성 = 3 / 340000
취소 제외 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

Run 5에서는 1005의 금액을 일시적으로 변경한 뒤 `01`이 실제로 실패하는 것을 확인하고 원상복구했습니다.

---

## 5. 스키마·Seed·시간 관계 강화

최종 구조:

```text
BASE TABLE 4개
students
instructors
courses
enrollments

VIEW 2개
analysis_parameters
enrollment_analysis_dataset
```

`information_schema.tables`에서 VIEW가 함께 보일 수 있는 점을 고려해 자동 검증에서는 `table_type = 'BASE TABLE'`을 명시했습니다.

Seed 실제 실행 과정에서 다음 오류를 발견했습니다.

```text
1005의 신청일 < 학생 104 가입일
1009의 신청일 < 학생 106 가입일
```

검증 조건을 약화하지 않고 합성 Seed 자체를 수정했습니다.

```text
학생 104 joined_at = 2026-02-10
학생 106 joined_at = 2026-03-05
```

그리고 `02_analysis_lab_seed.sql`의 COMMIT 전 게이트에 다음 시간 관계를 추가했습니다.

```text
신청일 < 학생 가입일 = 0
신청일 < 강의 개설일 = 0
완료일 < 신청일 = 0
```

---

## 6. 최종 기준 데이터

```text
students = 8
instructors = 3
courses = 5
enrollments = 24
enrollment_analysis_dataset = 24
```

상태:

```text
신청 = 4
수강중 = 5
완료 = 12
취소 = 3
```

월별 신청 시점 기록 금액:

```text
2026-01 = 350000
2026-02 = 520000
2026-03 = 680000
2026-04 = 550000
2026-05 = 540000
2026-06 = 570000
합계 = 3210000
```

강의별 기록 금액:

```text
301 데이터베이스 입문 = 600000
302 SQL 데이터 분석 = 520000
303 파이썬 데이터 분석 = 750000
304 데이터 시각화 = 700000
305 AI 활용 데이터 설계 = 640000
```

지역별 기록 금액:

```text
서울 = 1210000
경기 = 830000
부산 = 770000
대구 = 400000
```

완료 신청:

```text
건수 = 12
평균 완료 기간 = 25.00일
최소 = 18일
최대 = 36일
```

---

## 7. date spine과 분석 VIEW

월별 분석은 1~6월의 date spine을 먼저 만든 뒤 실제 집계를 LEFT JOIN합니다.

이 방식은 데이터가 없는 월도 0으로 유지하고 `LAG`가 실제 이전 달을 의미하도록 합니다.

`06_analysis_dataset.sql`은 다음 17개 컬럼의 기간 제한 VIEW를 트랜잭션 안에서 생성합니다.

```text
enrollment_id
student_id
student_name
region
course_id
course_title
category
level
instructor_id
instructor_name
enrolled_at
enrollment_month
status
recorded_amount
completed_at
completion_days
is_completed
```

COMMIT 전 자동 판정:

```text
행 수 = 24
enrollment_id 고유 = 24
recorded_amount 합계 = 3210000
```

---

## 8. 데이터 품질 검증

품질 이상은 모두 0이어야 합니다.

```text
PK·VIEW 중복
고아 student/course/instructor
완료 상태와 completed_at 불일치
완료일 < 신청일
신청일 < 가입일
신청일 < 개설일
음수 recorded_amount
취소 후 recorded_amount가 0으로 덮어써진 행
분석 기간 밖 기준 행
활성 신청 중복
```

취소 상태의 금액이 0이 아닌 것은 오류가 아니라 정상입니다. 역사적 신청 시점 금액을 0으로 지우는 것이 이 실습에서는 이상 상태입니다.

---

## 9. SQL 최종 완료 게이트

`08_analysis_lab_validation.sql`은 다음을 예외 기반으로 최종 판정합니다.

```text
Chapter 07·08 protected source 유지
BASE TABLE 4 / VIEW 2
정확한 분석 기간 1행
행 수 8/3/5/24/24
recorded_amount 합계 3210000
정확한 17개 VIEW 컬럼
제약조건 20
IDENTITY 4
활성 신청 부분 고유 인덱스
상태 4/5/12/3
월별 350/520/680/550/540/570k
완료 기간 12/25/18/36
품질 이상 0
다음 ID > 현재 최대 ID
```

통과 메시지:

```text
Chapter 14 analysis_lab validation passed: rows 8/3/5/24/24, amount 3210000
```

---

## 10. Python strict 검증 강화

공통 `validation_utils.py`는 다음을 엄격히 검사합니다.

```text
정확한 17개 컬럼
24행
enrollment_id 고유
ID 4종 NULL 없는 정수
날짜 errors='raise'
recorded_amount NULL 없는 정수 단위 금액
completion_days 숫자
is_completed boolean
상태와 완료 필드 일치
completion_days = completed_at - enrolled_at
분석 기간 일치
```

오류를 숨기는 `errors='coerce'`, 임의 `dropna`, 임의 `drop_duplicates`는 사용하지 않습니다.

---

## 11. PostgreSQL 읽기 전용 경로

Python DB 연결은 단일 `DATABASE_URL` 문자열을 저장하지 않고 libpq 환경 변수를 사용합니다.

```text
PGHOST
PGPORT
PGDATABASE
PGUSER
PGPASSFILE
```

연결 후 확인:

```text
current_database = ai_database_book
분석 VIEW 존재
transaction_read_only = on
```

`04_result_validation.py --source postgresql`은 같은 `REPEATABLE READ, READ ONLY` 트랜잭션에서 SQL 결과와 pandas 결과를 직접 비교합니다.

---

## 12. CSV + manifest 경로

PostgreSQL에서 CSV를 내보낼 때 manifest에 다음을 기록합니다.

```text
source database
source user
source view
read-only 상태
분석 기간
row_count = 24
expected_recorded_amount_sum = 3210000
생성 시각 UTC
CSV 경로
SHA-256
recorded_amount 의미
```

Run 5에서는 CSV 한 행의 `recorded_amount`를 의도적으로 바꾼 뒤 SHA-256 검증이 실제로 실패하는 것을 확인했습니다.

CSV 경로의 SQL 기준값은 `reference_metrics.json`으로 버전 관리합니다.

---

## 13. 실제 SQL·pandas 교차 검증

`04_result_validation.py`는 다음 세 결과를 `assert_frame_equal`로 비교합니다.

```text
상태별 집계
월별 date spine 집계
완료 기간 집계
```

실제 자동 검증에서 모두 통과했습니다.

```text
PostgreSQL 직접 경로 = 통과
CSV + manifest + reference_metrics 경로 = 통과
PostgreSQL/Python 잘못된 DB 차단 = 통과
CSV SHA-256 변조 탐지 = 통과
헤드리스 matplotlib PNG 생성 = 통과
```

그래프는 해석 보조 자료이며 SQL·pandas 검증을 대신하지 않습니다.

---

## 14. reset 격리와 보호 범위

`reset_analysis_lab.sql`은 `CASCADE`를 사용하지 않습니다.

삭제 전 정확한 예상 객체 집합을 검사하고 예상 밖 객체가 있으면 중단합니다.

Run 5에서는 `analysis_lab.keep_me`를 추가한 뒤 reset이 실제로 실패하고 기존 24행이 유지되는 것을 확인했습니다. `keep_me`를 제거한 뒤 정상 reset을 수행하고 `analysis_lab`만 사라지는 것을 확인했습니다.

다음 보호 스키마 sentinel도 모두 유지됐습니다.

```text
transaction_lab
performance_lab
security_lab
nosql_lab
ai_review_lab
```

`course_project`는 실행 전·후 MD5 fingerprint가 동일했습니다.

---

## 15. 발표자료·TTS·이미지

발표자료:

```text
이론 20장
실습 20장
asset version = 20260809a
```

자동 정적 검증:

```text
모든 장표에 화면 구성·발표 스크립트 존재
navigation 제목 순서 일치
Markdown fetch cache=no-store
공통 PresentationTTS.normalize 사용
script_content_enhancer 연결
JavaScript 문법 통과
```

이미지:

```text
Mermaid 8
SVG 8
stem 1:1 일치
role=img
width=100%
viewBox
title
desc
본문 SVG 8개 참조
```

---

## 16. 출판값 전용 자동 검증

금액 의미 보정 후 본문·워크북·README·실습 강의안의 과거 집계값이 일부 남아 있는 것을 추가 발견해 모두 수정했습니다.

현재 출판값 전용 CI가 다음을 별도로 확인합니다.

```text
paid_amount 잔존 금지
취소 금액 0이라는 과거 설명 금지
1월 350000
3월 680000
5월 540000
파이썬 데이터 분석 750000
데이터 시각화 700000
서울 1210000
대구 400000
총합 3210000
```

검증:

```text
Workflow: Validate Chapter 14 publishing evidence
Run: 2
Run ID: 31293074025
Conclusion: success
```

---

## 17. 실제 자동 검증 기록

출판값 정렬 후 정상 사용자 커밋에서 다시 실행한 전체 검증:

```text
Workflow: Validate Chapter 14
Run: 5
Run ID: 31293106457
Commit: 9084886fb6998c8356d9df1af55ae6c88db3b23d
PostgreSQL: 16
Conclusion: success
```

같은 커밋의 발표 navigation 검증:

```text
Workflow: Validate Chapter 14 navigation
Run: 10
Run ID: 31293106459
Conclusion: success
```

Run 5 자동 범위:

```text
정적 본문·SQL·Python·SVG·발표 정합성
잘못된 DB 보호
Chapter 07·08 baseline 실제 생성
upstream drift 탐지
SQL 01→08 실제 실행
정확한 SQL 기준값 검증
재실행 차단
analysis_lab drift 탐지
protected fingerprint·sentinel 불변
PostgreSQL Python 경로
CSV + manifest Python 경로
SQL·pandas assert_frame_equal
SHA-256 변조 탐지
잘못된 Python DB 차단
reset 예상 밖 객체 차단
정상 reset 및 격리 확인
```

---

## 최종 자동 확인 상태

| 영역 | 상태 |
| --- | --- |
| Chapter 13→14 연결 | 완료 |
| 합성 분석 시나리오 경계 | 완료 |
| recorded_amount 의미·타입 | 완료 |
| 취소 후 역사 금액 보존 | 완료 |
| Chapter 07·08 prerequisite | 실제 통과 |
| 스키마·Seed 원자성 | 실제 통과 |
| Seed 시간 관계 | 실제 통과 |
| SQL 집계·date spine | 실제 통과 |
| 분석 VIEW | 실제 통과 |
| SQL 최종 게이트 | 실제 통과 |
| Python strict 자료형 | 실제 통과 |
| 읽기 전용 PostgreSQL | 실제 통과 |
| CSV manifest·SHA-256 | 실제 통과 |
| SQL·pandas 직접 비교 | 실제 통과 |
| reset 격리 | 실제 통과 |
| protected source 불변 | 실제 통과 |
| 발표 navigation 정적 검사 | 통과 |
| 출판 기준값 정적 검사 | 통과 |
| Mermaid/SVG 구조 검사 | 통과 |

---

## 남은 수동 확인

다음은 자동 통과로 표시하지 않습니다.

```text
1. 이론 20장 브라우저 최종 육안 렌더링
2. 실습 20장 브라우저 최종 육안 렌더링
3. 의미 단위 highlight/step 실제 조작
4. 발표 창 ↔ 스크립트 창 실제 동기화
5. 실제 TTS 청취·발음 확인
6. 모바일·프로젝터 가독성
7. Windows·macOS·Linux 한글 그래프 글꼴 육안 확인
8. Mermaid CLI 재생성이 필요할 경우 실제 재생성
9. SVG의 GitHub/브라우저 최종 육안 확인
10. Word·PDF·eBook 최종 렌더링
11. 출판 페이지 수 최종 확인
```

실제로 실행하거나 렌더링하지 않은 항목은 “통과”로 표시하지 않습니다.


---

## 18. 2026-08-11 최종 출판 재검수 보완

Chapter 13 최종 기준과 Chapter 15 인계까지 다시 대조해 다음 출판 불일치를 보완했습니다.

```text
워크북의 오래된 제약조건 21개 → 실제 20개로 수정
이론 발표의 오래된 “취소 금액 0” 문장 제거
이미지 README의 “결제금액” → 신청 시점 기록 금액으로 수정
01 시작 전에 read-only·DB CREATE 권한 확인
Chapter 07 구조 계약 명명 제약조건 15 / NOT NULL 20 / 활성 신청 인덱스 확인
08 최종 게이트에서도 같은 Chapter 07 구조 계약 재확인
Python 월 date spine의 1~6월 하드코딩 제거 → 공통 기간 상수 사용
자동 생성 manifest에 expected_recorded_amount_sum·amount_semantics 실제 기록
manifest 검증에서도 두 필드 확인
최종 NOTICE 문구를 실제 08 출력과 동기화
완성된 발표 스크립트의 generic enhancer 비활성화
publishing CI가 Markdown 표 형태의 21개와 stale 취소 문장을 놓치지 않도록 강화
```

`transaction_read_only=on`은 분석 안전장치로 유지하되, 실제 환경에서는 최소권한 분석 계정과 함께 사용해야 한다는 경계도 본문·README·워크북에 명시했습니다.

최종 재검증은 PostgreSQL 16에서 성공했습니다. Run ID `31403974074`, 검증 workflow commit `806483b82ed7d388c91c764a102de04f96d71668`, 콘텐츠 commit `bd1172d53fcfe2bc4abba0550c94b0ceeadbb095`이며 상세 실행 증거는 `notes/chapter14_validation_result.md`에 기록했습니다.
