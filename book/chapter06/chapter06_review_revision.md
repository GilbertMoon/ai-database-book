# Chapter 06 전체 점검·반영 기록

## Chapter

```text
Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기
```

## 점검 범위

Chapter 06을 다음 흐름으로 전체 대조했다.

```text
한 행 의미
→ 위험한 중복·이상 현상
→ 열의 주인
→ 함수적 종속
→ 1NF·2NF·3NF
→ 정규화된 구조
→ 정책 C-01~C-08 확정
→ 기존 데이터 검사
→ 제약조건·부분 고유 인덱스 적용
→ 정상·경계·오류 데이터 검증
→ 실패 후 기준 상태 보존
```

검토 대상:

```text
book/chapter06/chapter06.md
book/chapter06/chapter06_outline.md
book/chapter06/chapter06_activity.md
book/chapter06/chapter06_review_revision.md
notes/chapter06_review_checklist.md
notes/chapter06_validation_result.md

code/chapter06/01_normalization_schema.sql
code/chapter06/02_normalization_seed.sql
code/chapter06/03_normalization_compare.sql
code/chapter06/04_add_integrity_rules.sql
code/chapter06/05_integrity_tests.sql
code/chapter06/normalization_schema.sql
code/chapter06/normalization_seed.sql
code/chapter06/normalization_practice.sql
code/chapter06/integrity_tests.sql
code/chapter06/reset_normalization.sql
code/chapter06/README.md

images/chapter06/*.mmd
images/chapter06/*.svg
images/chapter06/README.md

presentation/chapter06/chapter06_theory_lecture_plan.md
presentation/chapter06/chapter06_practice_lecture_plan.md
presentation/chapter06/chapter06_theory_slides.js
presentation/chapter06/chapter06_theory_patch.js
presentation/chapter06/chapter06_practice_slides.js
presentation/chapter06/chapter06_practice_patch.js
presentation/chapter06/chapter06_navigation.js
presentation/chapter06/chapter06_player.js
presentation/chapter06/chapter06_script.html
presentation/chapter06/chapter06_script.js
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js

.github/workflows/validate-chapter06.yml
```

---

## 1. 본문 구조와 역할

본문은 18개 절 구조를 유지한다.

```text
1. 좋은 테이블은 데이터가 변할 때 드러난다
2. 위험한 중복과 의미 있는 반복
3. 삽입·수정·삭제 이상
4. 한 행의 의미와 열의 주인
5. 함수적 종속의 기초
6. 제1정규형
7. 제2정규형
8. 제3정규형
9. 도서 대여 구조 정규화하기
10. 미확정 정책을 확정 규칙으로 바꾸기
11. 정규화와 데이터 무결성의 역할
12. PRIMARY KEY·NOT NULL·UNIQUE·CHECK
13. 외래키와 참조 무결성
14. 기존 테이블에 규칙 추가하기
15. 여러 행에 걸친 업무 규칙
16. 정상·경계·오류 데이터로 검증하기
17. AI 설계 검토와 자주 하는 실수
18. 핵심 정리와 다음 장
```

정규화는 “테이블 수를 늘리는 작업”이 아니라 같은 현재 사실의 복사본을 여러 곳에서 관리하지 않도록 사실의 주인을 정하는 과정으로 설명한다.

```text
정규화
→ 각 사실을 적절한 테이블에 배치

무결성 제약조건
→ 확정된 업무 규칙에 따라 저장 가능한 값과 관계의 경계를 선언
```

---

## 2. 한 행 의미와 Chapter 05 연결

본문·워크북·코드 README·실습 발표자료의 기준:

```text
library_records_raw 한 행
= 대여 사건과 회원·도서 현재 사실이 섞인 한 건

members_nf 한 행
= 회원 한 명

books_nf 한 행
= 이 장에서 대여 대상으로 관리하는 도서 한 건

loans_nf 한 행
= 특정 회원이 특정 도서를 대여한 사건 한 건
```

`books_nf`를 제목·판본·실제 복본을 완전히 분리한 운영 모델로 설명하지 않는다. 동일 ISBN의 실제 복본과 여러 저자는 범위 밖이다.

---

## 3. 정규형 설명 기준

### 1NF

```text
업무상 독립적으로 다뤄야 할 여러 값을
쉼표 문자열이나 반복 열 하나에 섞지 않는다.
```

JSON·배열을 형식만 보고 무조건 1NF 위반으로 단정하지 않고 저장 의미와 사용 방식을 별도로 판단한다.

### 2NF

복합 후보키가 있을 때 일반 열이 키 전체가 아니라 일부에만 의존하는지 확인한다.

```text
student_id → student_name
course_id → course_name
(student_id, course_id) → grade
```

단일 열 후보키만 있는 경우 부분 종속은 발생하지 않는다.

### 3NF

일반 열이 다른 일반 열을 결정하는 업무 규칙이 있는지 확인한다. 단순한 값 반복만으로 전이 종속을 단정하지 않는다.

---

## 4. 규칙 C-01~C-08

| ID | 확정 규칙 | 구현 |
| --- | --- | --- |
| C-01 | 정확히 같은 이메일 문자열 중복 금지 | `UNIQUE (email)` |
| C-02 | 같은 ISBN 문자열 중복 금지 | `UNIQUE (isbn)` |
| C-03 | 회원 이름·도서 제목 공백 문자열 금지 | `CHECK` |
| C-04 | `due_at >= borrowed_at` | `CHECK` |
| C-05 | `returned_at IS NULL OR returned_at >= borrowed_at` | `CHECK` |
| C-06 | 존재하는 회원·도서만 참조 | `FOREIGN KEY` |
| C-07 | 대여 이력이 있는 부모 삭제 금지 | `ON DELETE RESTRICT` |
| C-08 | 도서당 현재 미반납 대여 최대 한 건 | 부분 고유 인덱스 |

범위 제외:

```text
이메일 대소문자·별칭 정규화
동일 ISBN 실제 복본 모델
여러 저자 관계
과거 대여 기간 전체의 중첩
운영 무중단 마이그레이션
```

---

## 5. 번호형 SQL 실행 경로

기본 학습 경로:

```text
01_normalization_schema.sql
→ 02_normalization_seed.sql
→ 03_normalization_compare.sql
→ 04_add_integrity_rules.sql
→ 05_integrity_tests.sql에서 한 테스트씩 실행
```

초기화가 필요한 경우에만:

```text
reset_normalization.sql
```

호환 파일:

```text
normalization_schema.sql
normalization_seed.sql
normalization_practice.sql
integrity_tests.sql
```

번호 파일과 호환 파일은 같은 역할이므로 중복 실행하지 않는다. 무결성 규칙 추가는 두 경로 모두 `04_add_integrity_rules.sql`을 사용한다.

---

## 6. 01 생성 파일 원자성 보강

기존 01 파일은 환경 검사 후 네 `CREATE TABLE`이 각각 실행되는 구조라 중간 오류가 발생하면 일부 객체가 남을 가능성이 있었다.

현재 흐름:

```text
DB·public·쓰기 가능 여부 확인
→ 네 테이블 미존재 확인
→ BEGIN
→ library_records_raw
→ members_nf
→ books_nf
→ loans_nf
→ 네 테이블 존재·모두 0행 확인
→ COMMIT
```

호환 `normalization_schema.sql`도 같은 안전 기준으로 동기화했다.

PostgreSQL 16에서 정상 생성 경로는 실제 실행해 확인했다. 별도의 의도적 CREATE 중간 실패 주입 테스트까지는 하지 않았으므로 그 항목은 체크리스트에서 별도 미확인으로 유지한다.

---

## 7. 02 입력 파일 원자성 보강 및 실제 검증

현재 흐름:

```text
DB·쓰기 가능 여부 확인
→ 네 테이블 존재·0행 확인
→ BEGIN
→ raw 3행 입력
→ members_nf 2행 입력
→ books_nf 2행 입력
→ loans_nf 3행 입력
→ IDENTITY 다음 값 조정
→ 기준 상태 자동 검증
→ COMMIT
```

커밋 전 기준:

```text
raw = 3
members = 2
books = 2
loans = 3
미반납 = 2
회원 101 대여 = 2
도서 201 대여 = 2
```

IDENTITY 다음 값:

```text
raw.loan_id = 1004부터
members_nf.id = 103부터
books_nf.id = 203부터
loans_nf.id = 1004부터
```

호환 `normalization_seed.sql`도 같은 동작으로 맞췄다.

Actions에서 `loans_nf` 입력을 강제로 실패시킨 뒤 실제 행 수가 다음처럼 모두 0으로 돌아가는 것을 확인했다.

```text
raw = 0
members = 0
books = 0
loans = 0
```

따라서 부분 입력 상태가 남지 않는 것을 실제 PostgreSQL에서 검증했다.

---

## 8. 03 정규화 비교 자동 검증 강화

최종 자동 판정:

```text
raw 3
members 2
books 2
loans 3
미반납 2
회원101 2
도서201 2
회원 고아 0
도서 고아 0
날짜 오류 0
도서201 재대여 시간 순서 오류 0
활성 중복 0
```

통과 메시지:

```text
Chapter 06 normalization comparison passed
```

호환 `normalization_practice.sql`도 같은 판정을 사용한다.

Run 6에서 실제 기준값과 통과 메시지를 확인했다.

---

## 9. 04 무결성 규칙 적용 보강 및 실제 검증

기존 제약조건 존재 확인이 `conname`만 검사하여 다른 테이블이나 스키마에 같은 이름이 있으면 오탐할 가능성이 있었다.

현재는 다음 실제 대상까지 함께 확인한다.

```text
public.members_nf
public.books_nf
public.loans_nf
```

`pg_constraint.conrelid`를 사용해 대상 테이블과 제약조건 이름을 함께 검증한다.

기존 데이터 검사 후 다음을 하나의 트랜잭션으로 적용한다.

```text
SET NOT NULL
UNIQUE
CHECK
FOREIGN KEY + ON DELETE RESTRICT
부분 고유 인덱스
```

커밋 전에 메타데이터를 자동 확인한다.

```text
명명된 Chapter 06 제약조건 = 8개
NOT NULL 적용 열 = 10개
uq_loans_nf_active_book 존재
```

Run 6에서 실제 PostgreSQL 메타데이터까지 확인했다.

또한 04 실행 전에 중복 이메일 데이터를 미리 넣어 기존 데이터 검사에서 실패하도록 만든 결과:

```text
04 실행 실패
Chapter 06 명명 제약조건 = 0
uq_loans_nf_active_book 미생성
```

따라서 일부 규칙만 적용된 상태가 남지 않는 것도 실제 확인했다.

---

## 10. 05 정상·경계·오류 테스트 보강

테스트 시작 시 정확한 Chapter 06 대상의 제약조건 8개와 부분 고유 인덱스 존재를 확인한다.

허용 경계값:

```text
due_at = borrowed_at
returned_at = borrowed_at
returned_at = NULL
published_year = NULL
공백이 아닌 한 글자 이름
```

오류 테스트:

```text
NOT NULL 이름
중복 이메일
중복 ISBN
공백 회원 이름
공백 도서 제목
존재하지 않는 회원 참조
존재하지 않는 도서 참조
잘못된 due_at
잘못된 returned_at
같은 도서의 두 번째 미반납 대여
참조 중인 회원 삭제
```

각 오류 예제에 기대 제약조건 또는 인덱스 이름을 표시했다.

테스트 후 다음 기준을 자동 재검증한다.

```text
raw 3 / members 2 / books 2 / loans 3 / 미반납 2
회원 101 = 2 / 도서 201 = 2
고아 참조 = 0 / 활성 중복 = 0
```

통과 메시지:

```text
Chapter 06 integrity test baseline preserved
```

Run 6에서 허용 경계값의 실제 성공과 11개 오류 SQL의 실제 실패, 기대 제약조건·인덱스 이름, 테스트 후 기준 상태 보존을 확인했다.

---

## 11. 경계 테스트 ISBN 실제 오류 발견·수정

자동 검증 과정에서 실제 콘텐츠 오류를 발견했다.

기존 경계 테스트 값:

```text
ISBN-BOUNDARY-LOAN-001
```

이 문자열은 `books_nf.isbn VARCHAR(20)`보다 길었다. 따라서 같은 날 대여·반납 경계 규칙을 검증하기 전에 문자열 길이 오류가 먼저 발생했다.

현재 값:

```text
ISBN-BND-LOAN-001
```

다음 세 위치를 모두 같은 값으로 맞췄다.

```text
05_integrity_tests.sql
integrity_tests.sql
Validate Chapter 06 workflow의 실제 PostgreSQL 경계 테스트
```

수정 후 Run 6에서 날짜 경계값이 실제 성공하는 것을 확인했다.

---

## 12. reset 안전성

`reset_normalization.sql`은 다음 환경을 확인한다.

```text
현재 DB = ai_database_book
public 스키마 존재
읽기 전용 연결 아님
```

삭제 순서:

```text
public.loans_nf
→ public.books_nf
→ public.members_nf
→ public.library_records_raw
```

Run 6의 번호형·호환 경로에서 실제 실행했다.

---

## 13. 워크북 동기화

워크북의 권장 경로는 번호형 01→05 기준이다.

핵심 활동:

```text
원시 행 의미
위험한 중복과 정상 반복
삽입·수정·삭제 이상
열의 주인
함수적 종속
1NF·2NF·3NF
정규화 구조
C-01~C-08
무결성 유형
정상·경계·오류 결과
```

선택 활동은 `ALTER TABLE`, NULL 처리, 삭제 정책, 부분 고유 인덱스와 주문 예제로 분리되어 있고 운영 마이그레이션과 고급 제약조건은 심화 범위다.

---

## 14. 실습 강의안의 오래된 실행 흐름 수정

기존 실습 강의안과 런타임에는 다음 구형 흐름이 남아 있었다.

```text
normalization_schema.sql
→ normalization_seed.sql
→ normalization_practice.sql
→ integrity_tests.sql
```

일부 설명은 `normalization_schema.sql`이 테이블과 제약조건을 함께 만든다고 표현해 현재 코드의 01/04 분리와 맞지 않았다.

현재는 다음으로 통일했다.

```text
01 기본 구조
→ 02 정상 샘플
→ 03 정규화 비교
→ 04 기존 데이터 검사 후 규칙 추가
→ 05 경계·오류 테스트
```

실습 발표 강의안은 실제 런타임 내비게이션과 같은 16개 장표로 재구성했다.

각 장표에는 `화면 구성`과 `발표 스크립트`가 있으며 다음 기준을 반영한다.

```text
3 / 2 / 2 / 3 / 미반납 2
회원101 2건
도서201 2건
제약조건 8개
NOT NULL 열 10개
부분 고유 인덱스
03·05 통과 메시지
```

---

## 15. 실습 발표 런타임 전체 재정렬

`chapter06_practice_patch.js`를 현재 코드·본문 기준으로 다시 구성했다.

기존 의미 단위 내비게이션이 사용하는 16개 장표 제목은 유지하면서 실제 표시 내용과 발표 스크립트를 최신화했다.

다음 오해를 제거했다.

```text
01에서 모든 제약조건을 생성한다
→ 01은 PK·타입 중심의 기본 구조
→ 04에서 기존 데이터 확인 후 업무 규칙 적용

호환 4파일이 기본 실행 경로다
→ 번호형 01→05가 기본
→ 기존 파일은 링크 호환용
```

`books_nf`의 한 행 의미도 본문과 같은 “대여 대상으로 관리하는 도서 한 건”으로 설명한다.

---

## 16. 이론 발표자료·의미 단위 내비게이션·TTS

이론 발표자료는 다음 핵심 흐름을 유지한다.

```text
위험한 중복
→ 이상 현상
→ 한 행 의미·열의 주인
→ 함수적 종속
→ 1NF·2NF·3NF
→ 확정 규칙
→ 제약조건·검증
```

`chapter06_navigation.js`는 이론·실습 장표의 표, 목록, 흐름, 코드 요소를 의미 단위로 포커스한다.

발표자 스크립트는 다음 공통 자산을 사용한다.

```text
presentation/common/tts_pronunciation.js
presentation/common/script_content_enhancer.js
```

`chapter06_script.js`는 `window.PresentationTTS.normalize()`를 사용하며 이론·실습 patch를 모두 로드한다.

Run 6에서 JavaScript 문법, 16개 실습 장표 제목과 navigation 대응, 공통 TTS·script enhancer 연결을 정적으로 검증했다.

---

## 17. 이미지·도식

Mermaid 원본과 SVG 결과물 8쌍:

```text
01 normalization problem overview
02 anomaly types
03 first normal form
04 second normal form
05 third normal form
06 library normalization flow
07 before/after JOIN tradeoff
08 AI normalization review flow
```

Run 6에서 8개의 `.mmd`와 8개의 `.svg` 존재를 확인했다.

도식은 사고 흐름과 관계를 설명하고 실제 제약조건·오류 테스트는 SQL과 표가 담당한다.

---

## 18. Chapter 06 전용 자동 검증 최종 결과

```text
Workflow: Validate Chapter 06
Run: 6
Commit: 0f7505a2ffe431c31c1396f69649faa910733f5c
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-08
```

최종 통과:

```text
본문 18개 절
실습 강의안 16개 절
실습 runtime 16개 장표와 navigation 제목 대응
JavaScript 문법
TTS·script_content_enhancer 연결
Mermaid·SVG 8쌍
reset → 01 → 02 → 03 → 04 → 05 실제 PostgreSQL 실행
허용 경계값 실제 성공
NOT NULL·UNIQUE·CHECK·양쪽 FK·부분 고유 인덱스·RESTRICT 실제 실패
02 입력 중간 실패 시 전체 롤백
04 기존 위반 데이터 발견 시 일부 규칙 미적용
호환 SQL 전체 경로 실제 실행
```

상세 기록:

```text
notes/chapter06_validation_result.md
```

---

## 최종 상태

| 영역 | 상태 |
| --- | --- |
| 본문 18절 구조 | 반영 완료 |
| 정규형 설명·범위 | 반영 완료 |
| C-01~C-08 | PostgreSQL 실제 검증 완료 |
| 워크북 | 동기화 확인 |
| 01 생성 원자성 | 코드 보강·정상 경로 실제 확인 |
| 02 입력 원자성 | 보강·실패 롤백 실제 확인 |
| 03 비교 검증 | 보강·실제 통과 |
| 04 규칙 적용·메타데이터 | 보강·실제 통과·거부 원자성 확인 |
| 05 정상·경계·오류 | 실제 검증 완료 |
| 호환 SQL | 동기화·실제 실행 완료 |
| reset | 실제 실행 완료 |
| 실습 강의안 | 16장표 기준 재구성 완료 |
| 실습 발표 런타임 | 번호형 01→05 기준 재작성 완료 |
| 의미 단위 내비게이션 | 정적 연결 검증 완료 |
| 공통 TTS·스크립트 보강 | 정적 연결 검증 완료 |
| Mermaid·SVG 8쌍 | 존재 정적 확인 완료 |
| Chapter 06 Actions | Run 6 success |

## 별도 직접 확인 대상

자동 검증으로 대신할 수 없는 항목:

```text
브라우저 이론 발표자료 최종 시각 렌더링
브라우저 실습 발표자료 최종 시각 렌더링
의미 단위 포커스와 발표자 창의 실제 동기화
TTS 실제 청취 발음
Word·PDF·eBook SVG 최종 가독성
최종 편집 분량 23~26페이지 여부
```

실제 확인하지 않은 항목은 “통과”로 표시하지 않는다.
