# Chapter 14 자동 검증 결과

## 최종 definitive 실행

```text
Workflow: Validate Chapter 14
Run: 8
Run ID: 31293265843
Commit: 26015009b7c4b10bd81195e369fa8361755db224
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

이 Run은 Chapter 14의 본문·SQL·Python·검토 기록·최종 체크리스트가 모두 반영된 상태를 다시 검증한 definitive run입니다.

---

## 1. 최종 기준

### Chapter 07·08 protected source

```text
students = 3
instructors = 2
courses = 3
enrollments = 5
상태 = 신청2 / 수강중1 / 완료1 / 취소1
recorded_amount = NUMERIC(12,0)
전체 기록 금액 = 590000
활성 기록 금액 = 340000
취소 제외 기록 금액 = 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

### Chapter 14 analysis_lab

```text
students = 8
instructors = 3
courses = 5
enrollments = 24
enrollment_analysis_dataset = 24
상태 = 신청4 / 수강중5 / 완료12 / 취소3
recorded_amount = NUMERIC(12,0)
전체 recorded_amount = 3210000
제약조건 = 20
IDENTITY id = 4
```

취소 건도 신청 시점의 `recorded_amount`를 보존합니다.

```text
1003 = 취소 / 150000
1011 = 취소 / 140000
1019 = 취소 / 150000
```

---

## 2. 월별·완료기간 기준

```text
2026-01 = 3 / 350000
2026-02 = 4 / 520000
2026-03 = 5 / 680000
2026-04 = 4 / 550000
2026-05 = 4 / 540000
2026-06 = 4 / 570000
합계 = 24 / 3210000
```

완료 신청:

```text
건수 = 12
평균 완료기간 = 25.00일
최소 = 18일
최대 = 36일
```

---

## 3. 실제 SQL 검증

Run 8에서 다음을 실제 PostgreSQL 16에서 확인했습니다.

```text
잘못된 DB에서 01 실행 실패
Chapter 07·08 canonical state 실제 생성·검증
course_project fingerprint 저장
upstream recorded_amount drift 시 01 실패
Chapter 14 SQL 01→08 전체 실행
BASE TABLE 4 / VIEW 2
행 수 8/3/5/24/24
기록 금액 3210000
상태 4/5/12/3
월별 기준값 일치
완료기간 12/25/18/36
NUMERIC(12,0) 2개 금액 컬럼 확인
제약조건 20
취소 recorded_amount 0행 0건
01·02·06 재실행 차단
analysis_lab 금액 drift 시 08 실패
course_project fingerprint 불변
다른 Chapter sentinel 불변
```

---

## 4. 실제 Python 검증

PostgreSQL 직접 경로:

```text
읽기 전용 연결
ai_database_book 확인
REPEATABLE READ, READ ONLY
SQL 상태별 ↔ pandas assert_frame_equal
SQL 월별 ↔ pandas assert_frame_equal
SQL 완료기간 ↔ pandas assert_frame_equal
matplotlib Agg PNG 생성
```

CSV 경로:

```text
PostgreSQL VIEW → CSV export
manifest 생성
row_count 24
분석 기간 확인
SHA-256 확인
reference_metrics.json = 3210000 기준
CSV pandas 분석
CSV ↔ SQL 기준값 검증
변조 CSV의 SHA-256 실패 확인
```

잘못된 `PGDATABASE=postgres`에서도 Python 로더가 실제로 중단되는 것을 확인했습니다.

---

## 5. 데이터 품질·Seed 보정

실제 실행 과정에서 발견한 합성 Seed 오류:

```text
1005 신청일이 학생 104 가입일보다 빠름
1009 신청일이 학생 106 가입일보다 빠름
```

검증을 약화하지 않고 학생 가입일을 정상화하고 Seed COMMIT 전 게이트를 강화했습니다.

```text
신청일 < 가입일 = 0
신청일 < 개설일 = 0
완료일 < 신청일 = 0
```

---

## 6. reset 원자성·격리

Run 8에서 다음을 실제 확인했습니다.

```text
analysis_lab.keep_me 생성
→ reset 실행 실패
→ 기존 enrollments 24행 유지
→ keep_me 유지
→ keep_me 제거
→ 정상 reset 성공
→ analysis_lab만 제거
→ course_project fingerprint 불변
→ transaction_lab/performance_lab/security_lab/nosql_lab/ai_review_lab sentinel 유지
```

`reset_analysis_lab.sql`은 `CASCADE`를 사용하지 않습니다.

---

## 7. 발표·출판 정합성

발표 navigation의 마지막 실제 검증:

```text
Workflow: Validate Chapter 14 navigation
Run: 10
Run ID: 31293106459
Commit: 9084886fb6998c8356d9df1af55ae6c88db3b23d
Conclusion: success
```

확인 범위:

```text
이론 20장
실습 20장
화면 구성·발표 스크립트
navigation 제목 순서
JavaScript/Python 문법
shared PresentationTTS.normalize
script_content_enhancer
asset version 20260809a
reference_metrics 3210000
```

최종 출판 기준값 검증:

```text
Workflow: Validate Chapter 14 publishing evidence
Run: 5
Run ID: 31293265841
Commit: 26015009b7c4b10bd81195e369fa8361755db224
Conclusion: success
```

확인 범위:

```text
이전 금액 컬럼명 미사용
취소 금액을 0으로 설명하는 과거 문구 미사용
1월 350000
3월 680000
5월 540000
파이썬 데이터 분석 750000
데이터 시각화 700000
서울 1210000
대구 400000
전체 3210000
```

---

## 8. 자동 정적 검증

```text
본문 번호 절 = 32
이론 발표 = 20
실습 발표 = 20
모든 발표 절 화면 구성·스크립트 존재
recorded_amount canonical naming
NUMERIC(12,0)
합성 analysis_lab 경계
JavaScript 문법
Python 문법
strict ID/금액/날짜/완료기간 검사
Markdown fetch cache=no-store
asset version 20260809a
Mermaid 8 / SVG 8
Mermaid/SVG stem 일치
SVG role=img / width=100% / viewBox / title / desc
본문 SVG 8개 참조
reset CASCADE 미사용
Chapter 14 SQL protected schema 변경 금지
```

---

## 9. 자동 통과로 표시하지 않은 수동 항목

```text
1. 이론 20장 브라우저 최종 육안 렌더링
2. 실습 20장 브라우저 최종 육안 렌더링
3. semantic highlight/step 실제 조작
4. 발표 창 ↔ 스크립트 창 실제 동기화
5. 실제 TTS 청취·발음 확인
6. 모바일·프로젝터 가독성
7. Windows·macOS·Linux 한글 그래프 글꼴 육안 확인
8. 필요 시 Mermaid CLI 실제 재생성
9. SVG GitHub/브라우저 최종 육안 확인
10. Word·PDF·eBook 최종 렌더링
11. 출판 페이지 수 최종 확인
```

실제로 실행하거나 렌더링하지 않은 항목은 통과로 표시하지 않습니다.


---

## 13. 2026-08-11 최종 출판 재검증

Chapter 14 최종 출판 보완 뒤 PostgreSQL 16과 고정 Python 의존성 범위에서 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 14 definitive final validation once
Run: 1
Run ID: 31403974074
Validation workflow commit: 806483b82ed7d388c91c764a102de04f96d71668
Content commit: bd1172d53fcfe2bc4abba0550c94b0ceeadbb095
Status: completed
Conclusion: success
Date: 2026-08-11 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
본문 번호 절 = 32
워크북 제약조건 20개 동기화
이론 발표의 stale 취소 금액 0 문장 제거
이미지 README 금액 의미 = 신청 시점 기록 금액
완성 발표자 스크립트 generic enhancer 비활성화
Python 문법·발표 JavaScript 정적 검사
잘못된 데이터베이스에서 01 차단
Chapter 07·08 canonical source 재생성·통과
Chapter 07 명명 제약조건 15 / NOT NULL 열 20 인계 확인
READ ONLY 트랜잭션에서 01이 DDL 전에 실패
DB CREATE 권한 없는 역할에서 01이 DDL 전에 실패
Chapter 14 SQL 01→08 전체 실행 성공
정확 상태 = 8/3/5/24/24, recorded_amount 합계 3210000
analysis_lab 제약조건 = 20
완료 = 12건 / 평균 25.00일 / 최소 18 / 최대 36
recorded_amount drift 주입 시 08 실패·복원 후 재통과
PostgreSQL 직접 경로 pandas 교차 검증 통과
CSV + manifest + reference_metrics 경로 교차 검증 통과
manifest expected_recorded_amount_sum = 3210000 실제 생성·검증
manifest amount_semantics 실제 생성·검증
CSV SHA-256 변조 탐지 통과
PostgreSQL·CSV 그래프 파일 실제 생성
예상 밖 analysis_lab.keep_me 존재 시 reset 전체 ROLLBACK
정상 reset 뒤 analysis_lab만 제거
course_project fingerprint 실행 전후 동일
transaction/performance/security/nosql/ai_review sentinel 유지
reset 뒤 Chapter 08 prerequisite gate 재통과
```

최종 메시지:

```text
Chapter 14 analysis_lab validation passed: rows 8/3/5/24/24, amount 3210000
Chapter 14 analysis lab reset passed
Chapter 14 definitive PostgreSQL 16 and Python validation passed
```

브라우저에서의 40장 최종 시각 확인, 실제 TTS 청취, OS별 한글 글꼴 렌더링, Word·PDF·eBook 최종 페이지 렌더링은 자동 검증 통과 범위로 주장하지 않습니다.
