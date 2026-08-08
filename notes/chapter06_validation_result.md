# Chapter 06 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 06
Run: 6
Commit: 0f7505a2ffe431c31c1396f69649faa910733f5c
Status: completed
Conclusion: success
Date: 2026-08-08
PostgreSQL: 16
```

## 최종 통과 범위

### 정적 일관성

```text
- Chapter 06 본문 18개 절 순서
- C-01~C-08과 번호형 01~05 파일 연결
- 실습 발표 강의안 16개 절
- 실습 runtime 16개 장표와 의미 단위 navigation 제목 대응
- Chapter 06 JavaScript 문법
- 발표자 script의 공통 TTS normalization 사용
- script_content_enhancer 연결
- 번호형·호환 SQL 필수 파일 존재
- 01·02 트랜잭션 안전 구조
- 03 반복·고아·날짜·재대여·활성 중복 판정
- 04 대상 테이블 한정 제약조건 검사와 메타데이터 판정
- 05 양쪽 FK 오류 예제와 테스트 후 기준 상태 판정
- Mermaid 원본 8개와 SVG 결과물 8개 존재
```

### PostgreSQL 실제 번호형 경로

다음 순서를 PostgreSQL 16에서 실제 실행했다.

```text
reset_normalization.sql
→ 01_normalization_schema.sql
→ 02_normalization_seed.sql
→ 03_normalization_compare.sql
→ 04_add_integrity_rules.sql
→ 05_integrity_tests.sql
```

실제 확인된 기준 상태:

```text
library_records_raw = 3
members_nf = 2
books_nf = 2
loans_nf = 3
미반납 = 2
회원 101 대여 = 2
도서 201 대여 = 2
고아 참조 = 0
활성 중복 = 0
```

실제 통과 메시지:

```text
Chapter 06 normalization comparison passed
Chapter 06 integrity test baseline preserved
```

04 적용 후 실제 메타데이터:

```text
명명 제약조건 = 8개
NOT NULL 적용 열 = 10개
uq_loans_nf_active_book 존재
```

## 실제 경계값 성공

다음 값이 실제 저장 가능한지 확인했다.

```text
due_at = borrowed_at
returned_at = borrowed_at
published_year = NULL
공백이 아닌 한 글자 이름
```

기준 샘플에는 `returned_at = NULL`인 미반납 행도 존재한다.

## 실제 오류값 거부

다음 오류 SQL이 실제 PostgreSQL에서 실패하고 기대 객체가 오류 메시지에 나타나는지 확인했다.

```text
1. NULL 이름 → NOT NULL
2. 중복 이메일 → uq_members_nf_email
3. 중복 ISBN → uq_books_nf_isbn
4. 공백 회원 이름 → chk_members_nf_name_not_blank
5. 공백 도서 제목 → chk_books_nf_title_not_blank
6. 존재하지 않는 회원 → fk_loans_nf_member
7. 존재하지 않는 도서 → fk_loans_nf_book
8. due_at < borrowed_at → chk_loans_nf_due_date
9. returned_at < borrowed_at → chk_loans_nf_returned_date
10. 같은 도서의 두 번째 미반납 대여 → uq_loans_nf_active_book
11. 참조 중인 회원 삭제 → fk_loans_nf_member
```

실패 테스트 뒤 `05_integrity_tests.sql`을 다시 실행해 기준 상태가 유지되는 것도 확인했다.

## 02 입력 원자성 실제 확인

`loans_nf` 입력이 강제로 실패하도록 임시 제약조건을 만든 뒤 `02_normalization_seed.sql`을 실행했다.

결과:

```text
02 실행 실패
→ raw = 0
→ members = 0
→ books = 0
→ loans = 0
```

따라서 raw·회원·도서만 일부 입력된 상태가 남지 않고 전체 입력 트랜잭션이 롤백되는 것을 확인했다.

## 04 규칙 추가 원자성 실제 확인

04 실행 전에 중복 이메일 데이터를 미리 입력해 기존 데이터 검사에서 실패하도록 만들었다.

결과:

```text
04 실행 실패
→ Chapter 06 명명 제약조건 = 0
→ uq_loans_nf_active_book 미생성
```

따라서 기존 데이터가 새 규칙을 만족하지 않으면 일부 제약조건만 적용된 상태로 남지 않는 것을 확인했다.

## 호환 경로 실제 확인

다음 기존 파일명 경로도 PostgreSQL 16에서 실제 실행했다.

```text
normalization_schema.sql
→ normalization_seed.sql
→ normalization_practice.sql
→ 04_add_integrity_rules.sql
→ integrity_tests.sql
```

번호 파일과 호환 파일이 같은 기준 상태·검증 의미를 유지하는 것을 확인했다.

## 검증 과정에서 발견해 수정한 문제

### 1. 자동 검증 범위 과다

초기 workflow가 SQL 실행 메시지 문자열을 본문에도 요구해 정적 검증이 실패했다.

수정:

```text
본문은 개념·파일 연결을 확인
SQL 통과 메시지는 실제 SQL 파일과 PostgreSQL 실행 단계에서 확인
```

### 2. 경계 테스트 ISBN 길이 오류

기존 경계 테스트 값:

```text
ISBN-BOUNDARY-LOAN-001
```

이 값은 `books_nf.isbn VARCHAR(20)`보다 길어 날짜 경계값을 검증하기 전에 문자열 길이 오류가 발생했다.

현재 값:

```text
ISBN-BND-LOAN-001
```

`05_integrity_tests.sql`, 호환 `integrity_tests.sql`, Actions 실제 테스트 데이터를 모두 같은 값으로 수정했다.

## 정적·DB 검증과 별도 직접 확인의 구분

Run 6 성공으로 저장소 내용과 PostgreSQL 실행 의미는 검증했다.

다음은 자동 검증이 대신할 수 없는 별도 직접 확인 항목이다.

```text
- 브라우저 이론 발표자료 최종 시각 렌더링
- 브라우저 실습 발표자료 최종 시각 렌더링
- 의미 단위 포커스와 발표자 스크립트 창의 실제 동기화
- TTS 실제 청취 발음
- Word·PDF·eBook SVG 최종 가독성
- 최종 편집 분량 23~26페이지 여부
```

실제 확인하지 않은 항목은 “통과”로 표시하지 않는다.
