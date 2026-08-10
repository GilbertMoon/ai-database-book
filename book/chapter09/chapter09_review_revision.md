# Chapter 09 전체 점검·반영 기록

## Chapter

```text
Chapter 09. 트랜잭션으로 데이터 정합성 지키기
```

## 전체 점검 범위

Chapter 09을 다음 흐름으로 다시 대조했습니다.

```text
Chapter 07·08 기준 상태
→ transaction_lab 격리
→ 사전 조건 게이트
→ BEGIN
→ FOR UPDATE와 조건부 UPDATE
→ 신청·결제 생성
→ COMMIT 전 자동 판정
→ COMMIT / ROLLBACK
→ 좌석 부족 0행
→ 취소·좌석 복구
→ 오류·SAVEPOINT
→ 두 세션 Lock 대기
→ 최종 정합성 검증
→ 안전한 reset
```

점검 대상은 본문·구성안·워크북, Chapter 09 SQL 전체, 이미지 8쌍, 이론/실습 발표자료, 발표자 스크립트·내비게이션·TTS, 전용 GitHub Actions입니다.

---

## 1. Chapter 07·08 연속성 강화

Chapter 09은 다음 기준 상태에서만 시작하도록 맞췄습니다.

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 recorded_amount = 590000
활성 신청 = 3 / 340000
취소 제외 신청 이력 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
recorded_amount = NUMERIC(12,0)
uq_course_enrollments_active 존재
```

본문·구성안·워크북·이론/실습 발표자료에도 같은 기준을 직접 표시했습니다.

---

## 2. 금액 열 이름을 원본에서 통일

실제 Chapter 07 스키마와 Chapter 09 SQL은 `recorded_amount`를 사용하지만 일부 원고와 발표 소스에는 이전 금액 열 이름이 남아 있었습니다.

이번 점검에서 Chapter 09 범위의 학습·실행 소스를 현재 이름으로 정리했습니다.

```text
course_project.enrollments.recorded_amount
transaction_lab.enrollments.recorded_amount
```

기존 `chapter09_slides.js`가 원고의 열 이름을 화면에서만 바꾸던 런타임 치환도 제거했습니다. 이제 원본 Markdown과 실제 SQL이 동일한 이름을 사용합니다.

---

## 3. 01 스키마 파일을 강한 사전 게이트로 보완

`01_transaction_lab_schema.sql`은 다음을 실제 검사합니다.

```text
현재 DB = ai_database_book
course_project 4개 핵심 테이블 존재
Chapter 07·08 행 수·상태·금액 기준 일치
recorded_amount = NUMERIC(12,0)
활성 신청 부분 고유 인덱스 존재
학생 101~103 존재
강의 301~303와 가격 일치
transaction_lab 미생성 상태
```

이후 `transaction_lab` 스키마, 세 테이블, 부분 고유 인덱스를 하나의 트랜잭션으로 생성합니다.

생성 후 COMMIT 전에 객체·금액 타입·빈 테이블 상태를 다시 판정합니다.

통과 메시지:

```text
Chapter 09 transaction lab schema validation passed
```

---

## 4. 02 초기 데이터 검증 강화

초기 상태:

```text
course 301 = capacity 2 / remaining 2
course 302 = capacity 1 / remaining 1
course 303 = capacity 1 / remaining 1
lab enrollments = 0
payments = 0
```

단순 행 수뿐 아니라 세 좌석 행의 정확한 값까지 COMMIT 전에 검사합니다.

통과 메시지:

```text
Chapter 09 transaction lab seed validation passed
```

---

## 5. 성공 COMMIT 경로

`03_commit_transaction.sql`은 다음 업무 단위를 하나로 처리합니다.

```text
course 301 좌석 잠금
→ remaining 2 → 1
→ enrollment 9001 / student 101 / course 301
→ recorded_amount 100000
→ payment 9901 / amount 100000
→ 자동 판정
→ COMMIT
```

`FOR UPDATE`는 행 잠금·관찰 역할이고, 실제 좌석 확보는 `UPDATE ... WHERE remaining_seats > 0`과 `RETURNING` 결과로 판단하도록 설명을 통일했습니다.

통과 메시지:

```text
Chapter 09 first commit validation passed
```

---

## 6. ROLLBACK 후 원상복구 자동 검증

`04_rollback_transaction.sql`은 student 102 / course 302의 임시 신청을 만든 뒤 전체 ROLLBACK합니다.

ROLLBACK 직전:

```text
course 302 remaining = 0
enrollment 9002 존재
payment 9902 존재
```

ROLLBACK 후 자동 확인:

```text
course 302 remaining = 1
enrollment 9002 없음
payment 9902 없음
이전 COMMIT 9001·9901 유지
course 301 remaining = 1 유지
```

통과 메시지:

```text
Chapter 09 rollback validation passed
```

---

## 7. 좌석 부족 경로와 IDENTITY 처리

`05_commit_and_sold_out.sql`은 student 103 / course 302를 정상 확정한 뒤 같은 강의에 추가 신청을 시도합니다.

정상 확정:

```text
9002 / student 103 / course 302 / recorded_amount 120000
9902 / amount 120000
course 302 remaining = 0
```

좌석 부족 시:

```text
seat UPDATE = 0행
9003 = 0행
9903 = 0행
remaining = 0 유지
```

좌석 부족은 SQL 문법 오류가 아니라 업무상 실패라는 설명을 유지합니다.

명시적 ID 입력은 IDENTITY 다음 값을 자동 이동시키지 않으므로 두 `RESTART WITH` 문을 하나의 트랜잭션으로 묶었습니다.

```text
enrollments next = 9003
payments next = 9903
```

통과 메시지:

```text
Chapter 09 sold-out validation passed
```

---

## 8. 최종 검증을 Chapter 07·08 보존까지 확대

`06_transaction_validation.sql`은 lab만 검사하지 않습니다.

보호 데이터:

```text
course_project = 3 / 2 / 3 / 5
상태 = 2 / 1 / 1 / 1
전체 = 590000
활성 = 3 / 340000
취소 제외 = 4 / 440000
1001·1004·1005 기준 상태 유지
```

lab 최종 상태:

```text
course_inventory = 3
lab enrollments = 2
payments = 2
301 remaining = 1
302 remaining = 0
303 remaining = 1
9001 / 9901 = 100000
9002 / 9902 = 120000
9003 / 9903 없음
```

추가 검증:

```text
좌석 범위 위반 = 0
결제 누락·금액 불일치 = 0
고아 payment = 0
중복 활성 신청 = 0
활성 신청 수 = 사용 좌석 수
```

통과 메시지:

```text
Chapter 09 main transaction validation passed
```

---

## 9. 취소와 좌석 복구 선택 실습

`08_cancel_and_restore.sql`은 다음을 같은 트랜잭션에서 실행합니다.

```text
9001 수강중 → 취소
course 301 remaining 1 → 2
payment 9901 기록 유지
```

선택 실습은 마지막에 ROLLBACK하고 다음 원래 상태가 돌아왔는지 자동 검사합니다.

```text
9001 = 수강중 / 100000
9901 = 100000
course 301 remaining = 1
lab enrollments/payments = 2 / 2
```

통과 메시지:

```text
Chapter 09 cancel rollback validation passed
```

---

## 10. 오류와 SAVEPOINT 실제 검증

`09_error_and_savepoint.sql`은 안전한 수동 실습을 위해 오류 유발 SQL을 기본 주석 상태로 유지합니다.

전용 Actions에서는 같은 시나리오를 실제 실행했습니다.

```text
BEGIN
→ SAVEPOINT
→ course 301 좌석 임시 차감
→ student 101 / course 301 중복 활성 신청 INSERT
→ uq_transaction_enrollments_active 위반 확인
→ ROLLBACK TO SAVEPOINT
→ course 301 remaining = 1
→ 9003 없음
→ 전체 ROLLBACK
```

따라서 PostgreSQL의 aborted transaction과 SAVEPOINT 복구 설명이 실제 동작과 일치함을 확인했습니다.

---

## 11. 두 세션 Lock 대기 실제 검증

`07_concurrency_two_sessions.sql`은 학습자가 두 연결에서 실행하도록 명령을 주석 형태로 제공합니다.

전용 Actions에서는 두 실제 PostgreSQL 세션을 사용했습니다.

```text
Session A
BEGIN → course 303 FOR UPDATE → 잠금 유지

Session B
BEGIN → lock_timeout 1s → 같은 행 FOR UPDATE
→ lock timeout 확인 → ROLLBACK

Session A
ROLLBACK
```

복구 후 course 303 remaining = 1이며 `06_transaction_validation.sql`이 다시 통과하는 것을 확인했습니다.

Lock 대기와 Deadlock은 별개의 개념으로 유지했습니다.

---

## 12. reset 안전성 강화

`reset_transaction_lab.sql`은 다음 순서로 동작합니다.

```text
현재 DB 검사
→ 보호할 course_project 존재 확인
→ BEGIN
→ transaction_lab 객체만 삭제
→ transaction_lab 제거 확인
→ course_project 3/2/3/5와 전체 590000 재검증
→ COMMIT
```

통과 메시지:

```text
Chapter 09 transaction lab reset passed
```

실제 Actions에서도 reset 전후 `course_project` 전체 데이터 fingerprint가 동일함을 확인했습니다.

---

## 13. 발표자료·스크립트·도식

발표 구조:

```text
이론 20장
실습 20장
```

반영 내용:

```text
원본 Markdown에서 recorded_amount 사용
사전 조건 화면에 3/2/3/5·상태·590000/340000/440000 표시
자산 버전 = 20260809a
공통 TTS normalization 유지
script_content_enhancer 유지
스크립트 ↔ 발표 창 postMessage 동기화 유지
```

Mermaid 8개와 SVG 8개는 동일 stem으로 유지하며 본문 그림 9-1~9-8과 연결됩니다. SVG의 XML, `width="100%"`, `viewBox`, `role="img"`, `title`, `desc`를 정적으로 검사했습니다.

---

## 14. 전용 자동 검증 결과

```text
Workflow: Validate Chapter 09
Run: 2
Run ID: 31282972035
Commit: 39775d598692f434133302a4c1a3485ccfd37e51
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

실제 통과 범위:

```text
JavaScript 문법
본문 23개 절
이론 20 / 실습 20
현재 금액 열 이름과 발표 자산 정합성
Mermaid/SVG 8쌍
잘못된 DB에서 01 실행 차단
Chapter 07 기준 실제 생성 + Chapter 08 기준 재검증
course_project 전체 fingerprint 보존
01→06 실제 실행
01·02 재실행 차단
취소 ROLLBACK 복구
SAVEPOINT 오류 복구
두 세션 Lock timeout 복구
reset 후 transaction_lab 제거
reset 후 course_project fingerprint 보존
```

---

## 자동 검증으로 확인하지 않은 항목

다음은 실제 출력·조작 환경에서 별도 확인합니다.

```text
브라우저 이론 20장 / 실습 20장 최종 시각 렌더링
단계별 강조와 발표자 창 동기화 실제 조작
TTS 실제 음성 청취
모바일·프로젝터 가독성
SVG 실제 화면·인쇄 가독성
Word·PDF·eBook 최종 렌더링
```

## 결론

```text
Chapter 09는 트랜잭션 문법 설명을 넘어,
앞 장 기준 데이터 보호, 정상 COMMIT, 전체 ROLLBACK,
좌석 부족, 취소 복구, SAVEPOINT 오류 복구와 실제 Lock 대기를
PostgreSQL에서 재현하고 자동 판정하는 안전한 변경 실습 장으로 정리되었다.
```


---

## 2026-08-10 최종 출판 보완

- Chapter 09 시작 게이트가 Chapter 07의 15개 명명 제약조건과 20개 NOT NULL 열을 확인하도록 강화했다.
- 현재 역할에 `ai_database_book`의 `CREATE` 권한이 없으면 `transaction_lab` 생성을 시작하지 않도록 했다.
- 사전 조건 검사를 DDL `BEGIN`보다 먼저 수행해 잘못된 환경에서 불필요한 명시적 트랜잭션을 열지 않도록 정리했다.
- `SELECT ... FOR UPDATE`가 항상 필수인 것처럼 읽히지 않도록, 조건부 `UPDATE ... RETURNING` 자체도 수정 행 잠금을 획득한다는 점과 선행 잠금 조회가 유용한 경우를 구분했다.
- 취소와 좌석 복구를 독립 UPDATE 두 개가 아니라 취소 성공 행을 좌석 복구에 전달하는 데이터 변경 CTE로 연결했다.
- 동일 취소 재시도에서 취소 0행 / 좌석 복구 0행이 되어 좌석이 두 번 증가하지 않는 경로를 실습에 추가했다.
- Chapter 09 발표 스크립트는 작성 원문을 그대로 사용하도록 자동 content enhancer를 비활성화했다.
- 발표 자산 버전을 `20260810a`로 갱신했다.
