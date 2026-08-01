# Chapter 06 자율 학습형 개편 반영 기록

## 대상 파일

```text
book/chapter06/chapter06.md
book/chapter06/chapter06_outline.md
book/chapter06/chapter06_activity.md
book/chapter06/chapter06_review_revision.md
notes/chapter06_review_checklist.md

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

images/chapter06/README.md
```

## 개편 목적

Chapter 06을 정규형과 PostgreSQL 고급 기능을 한꺼번에 소개하는 장에서 다음 질문을 중심으로 한 자율 학습 장으로 재구성했다.

```text
각 사실은 적절한 테이블에 한 번만 저장되는가?
확정된 업무 규칙이 정상값은 허용하고 오류값은 차단하는가?
기존 데이터가 새 규칙을 만족하는지 확인했는가?
```

## 주요 반영 사항

### 1. 대상 독자와 완료 기준

- 정규화와 데이터 무결성을 처음 배우는 독자로 명시했다.
- Chapter 05의 한 행 의미와 관계 이해를 선수 지식으로 연결했다.
- 학습 결과를 8개로 줄였다.
- 핵심·선택·심화 학습 표시를 적용했다.

### 2. 본문 구조

- 기존 28개 절을 18개 절로 재구성했다.
- 권장 분량을 23~26페이지로 조정했다.
- 위험한 중복, 이상 현상, 열의 주인, 정규형, 규칙 추가와 검증 흐름을 중심에 두었다.
- 주문 테이블 상세 활동과 긴 해설은 워크북으로 이동했다.

### 3. 정규형 설명 보완

- 1NF를 단순히 ‘한 셀에 하나’로만 설명하지 않고 독립 값을 문자열·반복 열로 섞지 않는 원칙으로 보완했다.
- 배열·JSON을 무조건 1NF 위반으로 단정하지 않고 Chapter 12로 연결했다.
- 2NF가 복합 후보키의 부분 종속 문제임을 명시했다.
- 3NF는 값의 반복이 아니라 업무상 결정 관계를 근거로 판단하도록 정리했다.

### 4. 무결성 체계화

```text
개체 무결성
필수값·도메인 무결성
고유성
참조 무결성
여러 행의 업무 규칙
```

- `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`의 역할을 분리했다.
- `CHECK` 결과가 `UNKNOWN`이면 통과할 수 있으므로 `NOT NULL`이 별도로 필요할 수 있음을 추가했다.
- 일반적인 PostgreSQL `UNIQUE`의 여러 NULL 허용 특성을 선택 학습으로 추가했다.
- `pk_`, `fk_`, `uq_`, `chk_` 이름이 오류 확인에 도움 된다는 설명을 보강했다.

### 5. ALTER TABLE과 기존 데이터 검사

다음 흐름을 본문과 SQL에 새로 반영했다.

```text
정책 확정
→ 기존 데이터 검사
→ 위반 데이터 처리 결정
→ ALTER TABLE로 규칙 추가
→ 정상·경계·오류 테스트
```

제약조건을 기본 테이블 생성 시 모두 적용하지 않고, 정상 샘플과 정규화 전후 비교 뒤 별도 파일에서 추가하도록 변경했다.

### 6. 번호형 SQL 흐름

```text
01_normalization_schema.sql
02_normalization_seed.sql
03_normalization_compare.sql
04_add_integrity_rules.sql
05_integrity_tests.sql
reset_normalization.sql
```

- 생성 파일은 PK와 타입 중심의 기본 구조를 만든다.
- 입력 파일은 네 테이블이 모두 비어 있는지 확인한다.
- 비교 파일은 데이터를 변경하지 않고 자동 요약 검증을 수행한다.
- 규칙 파일은 NULL·중복·공백·날짜·고아 참조·활성 중복을 검사한 뒤 하나의 트랜잭션에서 규칙을 추가한다.
- 테스트 파일은 경계·오류 SQL을 한 번에 하나씩 실행하도록 구성했다.

### 7. 기존 파일 호환

기존 링크와 자료를 위해 다음 파일을 유지하고 새 안전 기준으로 동기화했다.

```text
normalization_schema.sql
normalization_seed.sql
normalization_practice.sql
integrity_tests.sql
```

무결성 규칙 추가는 기존·번호 흐름 모두 `04_add_integrity_rules.sql`을 사용한다.

### 8. 초기화 안전성

- `current_schema() = public` 강제 조건을 제거했다.
- 현재 DB, `public` 스키마 존재와 읽기 전용 상태를 검사한다.
- 스키마를 명시한 Chapter 06 테이블만 자식→부모 순서로 삭제한다.

### 9. 선택·심화 범위 분리

선택 학습:

```text
ALTER TABLE
CHECK·UNIQUE와 NULL
삭제 정책
부분 고유 인덱스
주문 테이블 전이
```

심화 학습:

```text
후보키와 BCNF
UNIQUE NULLS NOT DISTINCT
DEFERRABLE
NOT VALID·VALIDATE CONSTRAINT
기간 중첩과 Exclusion Constraint
운영 마이그레이션과 롤백
```

### 10. AI 검토 기준 단순화

기존의 긴 검토표를 다음 7개 질문으로 압축했다.

```text
한 행 의미가 명확한가?
같은 현재 사실이 복사되어 있는가?
열의 주인이 적절한가?
정규형 위반의 업무 근거가 있는가?
제약조건이 확정 규칙에 연결되는가?
정상·경계·오류 기대 결과가 분명한가?
근거 없는 UNIQUE·CHECK·CASCADE가 없는가?
```

## 유지한 도식

```text
그림 6-1 중복 저장 문제
그림 6-2 삽입·수정·삭제 이상
그림 6-3 제1정규형
그림 6-4 제2정규형
그림 6-5 제3정규형
그림 6-6 도서 대여 정규화
그림 6-7 정규화된 저장과 조회
그림 6-8 AI 구조 검토
```

도식은 정규화 사고를 설명하고, 제약조건·`ALTER TABLE`·오류 테스트는 SQL과 표로 설명하는 역할 분리를 유지했다.

## 남은 실행·출판 검증

```text
PostgreSQL에서 01→05 순차 실행
기존 호환 파일 실행 결과 비교
04 파일 오류 시 전체 ROLLBACK 확인
경계·오류 테스트 개별 실행
GitHub Markdown 표·코드 렌더링
Word·PDF·eBook SVG 가독성
최종 분량 23~26페이지 확인
Chapter 05·07 중복 범위 확인
```
