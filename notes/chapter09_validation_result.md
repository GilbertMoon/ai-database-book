# Chapter 09 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 09
Run: 4
Run ID: 31283073263
Commit: 78d51a2a1ec8233b547ba7317bc24b2e8a03a047
Status: completed
Conclusion: success
Date: 2026-08-09 (Asia/Seoul)
PostgreSQL: 16
```

## 최종 통과 범위

### 정적 정합성

```text
- Chapter 09 본문 번호 절 1~23
- 이론 발표 강의안 20개 절
- 실습 발표 강의안 20개 절
- 모든 발표 절에 화면 구성·발표 스크립트 존재
- Chapter 09 학습·실행 소스의 현재 금액 열 이름 = recorded_amount
- Chapter 07·08 기준값 3/2/3/5, 590000, 340000, 440000 정합성
- JavaScript 문법
- 발표 자산 버전 = 20260809a
- 공통 TTS normalization 사용
- script_content_enhancer 연결
- 발표자 창·발표 창 자산 버전 전달 구조
- Chapter 09 SQL 파일 전체 존재
- Chapter 09 SQL이 보호 대상 course_project를 변경하지 않음
- Mermaid 8개 / SVG 8개 파일 쌍
- SVG XML 파싱, width=100%, viewBox, role=img, title, desc
- 본문 그림 9-1~9-8 연결
```

## PostgreSQL 16 실제 실행

### 1. 잘못된 데이터베이스 보호

`postgres` 데이터베이스에서 `01_transaction_lab_schema.sql`을 실행했을 때 실패하는 것을 확인했습니다.

```text
현재 DB != ai_database_book
→ transaction_lab 생성 중단
```

### 2. Chapter 07·08 기준 상태 실제 생성·검증

PostgreSQL 16에서 Chapter 07의 다음 파일을 순서대로 실제 실행했습니다.

```text
01_course_project_schema.sql
→ 02_course_project_seed.sql
→ 03_course_project_changes.sql
→ 04_course_project_validation.sql
```

이후 Chapter 08의 다음 자동 게이트를 다시 실행했습니다.

```text
00_check_course_project.sql
03_join_aggregation_validation.sql
```

기준 상태:

```text
students / instructors / courses / enrollments = 3 / 2 / 3 / 5
상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 recorded_amount = 590000
활성 신청 = 3 / 340000
취소 제외 신청 이력 = 4 / 440000
1001 = 완료 / 100000
1004 = 취소 / 150000
1005 = 신청 / 120000
```

### 3. 보호 데이터 fingerprint

Chapter 09 실행 전에 `course_project.students`, `instructors`, `courses`, `enrollments` 전체 데이터를 정렬된 JSON으로 직렬화해 MD5 fingerprint를 저장했습니다.

주 실습 완료 후와 reset 완료 후 같은 fingerprint인지 비교해 Chapter 09이 앞 장의 데이터를 변경하지 않았음을 실제 확인했습니다.

## 주 실습 01 → 06 실제 실행

```text
01_transaction_lab_schema.sql
→ 02_transaction_lab_seed.sql
→ 03_commit_transaction.sql
→ 04_rollback_transaction.sql
→ 05_commit_and_sold_out.sql
→ 06_transaction_validation.sql
```

모든 단계가 실제 PostgreSQL에서 통과했습니다.

통과 메시지:

```text
Chapter 09 transaction lab schema validation passed
Chapter 09 transaction lab seed validation passed
Chapter 09 first commit validation passed
Chapter 09 rollback validation passed
Chapter 09 sold-out validation passed
Chapter 09 main transaction validation passed
```

## 주 실습 최종 상태

reset 직전의 기준 상태는 다음과 같습니다.

```text
transaction_lab.course_inventory = 3
transaction_lab.enrollments = 2
transaction_lab.payments = 2

course 301 remaining = 1
course 302 remaining = 0
course 303 remaining = 1

9001 = student 101 / course 301 / 수강중 / recorded_amount 100000
9901 = enrollment 9001 / amount 100000

9002 = student 103 / course 302 / 수강중 / recorded_amount 120000
9902 = enrollment 9002 / amount 120000

9003 = 없음
9903 = 없음
```

정확한 핵심 상태 문자열:

```text
3:2:2:1:0:1
```

## ROLLBACK 실제 복구

`04_rollback_transaction.sql`에서 임시로 다음 상태를 만들었습니다.

```text
course 302 remaining = 0
enrollment 9002 존재
payment 9902 존재
```

`ROLLBACK` 후:

```text
course 302 remaining = 1
enrollment 9002 없음
payment 9902 없음
9001·9901 유지
course 301 remaining = 1 유지
```

자동 통과 메시지:

```text
Chapter 09 rollback validation passed
```

## 좌석 부족 실제 검증

두 번째 정상 COMMIT 후 course 302의 잔여 좌석이 0인 상태에서 추가 신청을 실행했습니다.

결과:

```text
조건부 seat UPDATE = 0행
9003 = 생성되지 않음
9903 = 생성되지 않음
course 302 remaining = 0 유지
```

좌석 부족이 SQL 문장 오류가 아니라 업무상 0행 결과로 안전하게 처리되는 것을 확인했습니다.

## 재실행 차단

주 실습 완료 상태에서 다음 파일을 다시 실행했습니다.

```text
01_transaction_lab_schema.sql
02_transaction_lab_seed.sql
```

결과:

```text
01 → 기존 transaction_lab 존재를 감지해 실패
02 → lab이 비어 있지 않음을 감지해 실패
```

따라서 실습을 잘못 재실행하여 기준 상태를 중복 생성하지 않도록 보호됨을 확인했습니다.

## 취소·좌석 복구 ROLLBACK 실제 검증

`08_cancel_and_restore.sql`을 실제 실행했습니다.

트랜잭션 내부:

```text
9001 수강중 → 취소
course 301 remaining 1 → 2
payment 9901 유지
```

마지막 `ROLLBACK` 후:

```text
9001 = 수강중 / recorded_amount 100000
9901 = amount 100000
course 301 remaining = 1
lab enrollments / payments = 2 / 2
```

통과 메시지:

```text
Chapter 09 cancel rollback validation passed
```

이후 `06_transaction_validation.sql`도 다시 성공했습니다.

## SAVEPOINT 오류 복구 실제 검증

전용 Actions에서 실제 오류 문장을 활성화한 것과 같은 시나리오를 실행했습니다.

```text
BEGIN
→ SAVEPOINT before_duplicate_enrollment
→ course 301 좌석 임시 차감
→ student 101 / course 301 중복 수강중 신청 INSERT
→ uq_transaction_enrollments_active 오류 발생
→ ROLLBACK TO SAVEPOINT
```

복구 결과:

```text
course 301 remaining = 1
9003 = 없음
savepoint_restored = true
```

이후 `06_transaction_validation.sql`이 다시 통과했습니다.

## 두 세션 Lock timeout 실제 검증

독립된 두 PostgreSQL 세션을 사용했습니다.

```text
Session A
BEGIN
→ course 303 SELECT ... FOR UPDATE
→ 잠금 유지

Session B
BEGIN
→ SET LOCAL lock_timeout = '1s'
→ 같은 course 303 SELECT ... FOR UPDATE
→ lock timeout 발생

Session A
ROLLBACK
```

복구 후:

```text
course 303 remaining = 1
```

`06_transaction_validation.sql`도 다시 성공했습니다.

따라서 Chapter 09의 Lock 대기 설명이 실제 PostgreSQL 동작과 연결됨을 확인했습니다.

## reset 실제 검증

`reset_transaction_lab.sql`을 실제 실행했습니다.

결과:

```text
transaction_lab 스키마 제거
course_project 유지
```

통과 메시지:

```text
Chapter 09 transaction lab reset passed
```

reset 후에도 `course_project` 전체 fingerprint가 실행 전과 동일했고, Chapter 08의 `00_check_course_project.sql`도 다시 통과했습니다.

## 초기 검증에서 발견된 사항

초기 Validate Chapter 09 Run 1은 정적 검증에서 실패했습니다.

원인:

```text
이론 발표 강의안이 자연어 '기록 금액'은 설명했지만
실제 컬럼명 recorded_amount를 직접 보여 주지 않았음
```

검증 기준을 낮추지 않고 본문·구성안·워크북·이론/실습 발표자료의 사전 조건을 현재 Chapter 07·08 스키마와 기준값에 맞춰 보완했습니다.

이후 Run 2가 정적·PostgreSQL 전체 검증을 통과했고, 리뷰·체크리스트 최종 반영 후 실행된 최신 Run 4도 전체 성공했습니다.

## 자동 검증으로 확인하지 않은 항목

다음은 실제 출력·조작 환경에서 별도 확인합니다.

```text
브라우저 이론 20장 / 실습 20장 최종 시각 렌더링
단계별 강조와 발표자 창 동기화 실제 조작
TTS 실제 음성 청취
모바일·프로젝터 화면 가독성
SVG 실제 화면·인쇄 가독성
Word·PDF·eBook 표·코드·SVG 최종 렌더링
```


---

## 2026-08-10 최종 출판 재검증

Chapter 09 최종 출판 보완 뒤 PostgreSQL 16에서 전용 검증 워크플로를 다시 실행했다.

```text
Workflow: Validate Chapter 09
Run: 5
Run ID: 31381404542
Commit: bd0095c51f7c0382796ba3a75a4bce4fdde44290
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 07 기준 상태 실제 생성 성공
Chapter 08 사전·집계 게이트 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
잘못된 데이터베이스에서 Chapter 09 시작 차단
DB CREATE 권한이 없는 역할에서 transaction_lab 생성 차단
권한 차단 뒤 transaction_lab 미생성 확인
01 → 02 → 03 → 04 → 05 → 06 주 실습 전체 성공
주 실습 최종 상태 = inventory/enrollment/payment 3/2/2
좌석 301/302/303 = 1/0/1
course_project 전체 fingerprint 불변
01·02 재실행 보호 성공
취소 성공 행에만 좌석 복구 연결
동일 취소 재시도 시 좌석 이중 복구 없음
08 선택 실습의 반복 취소/복구 = 0행 / 0행
SAVEPOINT 중복 활성 신청 오류 복구 성공
두 세션 FOR UPDATE lock timeout과 복구 성공
reset은 transaction_lab만 제거하고 course_project fingerprint 유지
Chapter 09 작성 발표 스크립트 자동 확장 비활성화
발표 자산 버전 = 20260810a
```

특히 취소 실습은 상태 변경과 좌석 복구를 독립 UPDATE로 두지 않고, `UPDATE ... RETURNING`으로 실제 취소된 행을 다음 좌석 복구 CTE의 입력으로 전달하도록 바꾸었다. 따라서 이미 취소된 신청을 다시 처리하면 취소 행이 0건이고 좌석 복구도 0건이 되어 좌석이 두 번 증가하지 않는다.

또한 `SELECT ... FOR UPDATE`는 모든 UPDATE 앞에 필수인 문법으로 설명하지 않는다. 조건부 `UPDATE ... RETURNING` 자체도 수정 대상 행에 필요한 잠금을 획득하며, 선행 `FOR UPDATE`는 잠근 상태를 읽고 여러 후속 판단을 이어가거나 두 세션 대기를 관찰할 때 특히 유용하다는 기준으로 정리했다.
