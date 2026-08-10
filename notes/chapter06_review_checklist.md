# Chapter 06 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기
```

---

## 1. 독자와 장의 역할

| 점검 항목 | 상태 | 최종 기준 |
| --- | --- | --- |
| 대상 독자가 명확한가 | 반영 완료 | 정규화·무결성 입문 독자 |
| 선수 지식이 명확한가 | 반영 완료 | Chapter 05의 한 행 의미·PK·FK·관계 |
| 완료 기준이 간결한가 | 반영 완료 | 8개 수행 결과 |
| 핵심·선택·심화가 구분되는가 | 반영 완료 | 본문·워크북에 동일 표시 |
| 정규화와 무결성을 구분하는가 | 반영 완료 | 사실의 주인 vs 저장 경계 |
| Chapter 07 연결이 명확한가 | 반영 완료 | 요구사항·ERD·정규화·제약조건을 프로젝트에 통합 |

---

## 2. 본문 구조

| 점검 항목 | 상태 | 최종 기준 |
| --- | --- | --- |
| 18개 절 구조인가 | 반영 완료 | 중복→정규형→정책→규칙→검증 |
| 위험한 중복과 정상 반복을 구분하는가 | 반영 완료 | 현재 사실 복사·관계 반복·이력 비교 |
| 삽입·수정·삭제 이상을 설명하는가 | 반영 완료 | SQL 오류가 아닌 구조 문제로 설명 |
| 한 행 의미가 중심인가 | 반영 완료 | raw·members_nf·books_nf·loans_nf 명시 |
| 열의 주인을 판단하는 질문이 있는가 | 반영 완료 | 누구의 값인지·변경 이유·이력 여부 |
| 함수적 종속이 업무 규칙에 근거하는가 | 반영 완료 | 샘플의 우연한 반복과 구분 |

---

## 3. 테이블별 한 행 의미

```text
library_records_raw
→ 대여 사건과 회원·도서 현재 사실이 섞인 한 건

members_nf
→ 회원 한 명

books_nf
→ 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건

loans_nf
→ 특정 회원이 특정 도서를 대여한 사건 한 건
```

- [x] `books_nf`를 제목·판본·실제 복본의 완전한 운영 모델처럼 설명하지 않음
- [x] 동일 ISBN 복본·여러 저자는 범위 밖으로 명시

---

## 4. 정규형 설명

| 점검 항목 | 상태 | 최종 기준 |
| --- | --- | --- |
| 1NF가 “셀 하나 값 하나”로만 축약되지 않는가 | 반영 완료 | 독립 값·반복 열·조회/관계 의미 포함 |
| JSON·배열을 무조건 위반으로 단정하지 않는가 | 반영 완료 | Chapter 12와 연결 |
| 2NF가 복합 후보키에 연결되는가 | 반영 완료 | 부분 종속 설명 |
| 단일 열 후보키의 2NF 범위를 설명하는가 | 반영 완료 | 부분 종속 없음 명시 |
| 3NF가 일반 열 간 결정 규칙에 근거하는가 | 반영 완료 | 단순 반복과 구분 |
| 1NF·2NF·3NF 예제의 전제가 드러나는가 | 반영 완료 | 업무 가정과 독립 예제 성격 안내 |

---

## 5. 확정 규칙 C-01~C-08

| 규칙 | 구현 | 상태 |
| --- | --- | --- |
| C-01 동일 이메일 문자열 중복 금지 | `UNIQUE (email)` | PostgreSQL 실제 검증 |
| C-02 ISBN 필수·동일 문자열 중복 금지 | `NOT NULL` + `UNIQUE (isbn)` | PostgreSQL 검증 대상 |
| C-03 공백 이름·제목 금지 | `CHECK` | PostgreSQL 실제 검증 |
| C-04 `due_at >= borrowed_at` | `CHECK` | PostgreSQL 실제 검증 |
| C-05 `returned_at IS NULL OR returned_at >= borrowed_at` | `CHECK` | PostgreSQL 실제 검증 |
| C-06 존재하는 회원·도서만 참조 | `FOREIGN KEY` | PostgreSQL 실제 검증 |
| C-07 참조 중 부모 삭제 금지 | `ON DELETE RESTRICT` | PostgreSQL 실제 검증 |
| C-08 도서당 미반납 최대 한 건 | 부분 고유 인덱스 | PostgreSQL 실제 검증 |

범위 제외:

```text
이메일 대소문자·별칭 정규화
동일 ISBN 실제 복본 모델
여러 저자
과거 기간 전체 중첩
BCNF·4NF·5NF 상세
운영 무중단 마이그레이션
```

---

## 6. 번호형 SQL 경로

```text
01_normalization_schema.sql
→ 02_normalization_seed.sql
→ 03_normalization_compare.sql
→ 04_add_integrity_rules.sql
→ 05_integrity_tests.sql
```

| 파일 | 최종 상태 | 핵심 확인 |
| --- | --- | --- |
| `01_normalization_schema.sql` | 실제 실행 성공 | 환경·미존재 검사, 트랜잭션, 4테이블 0행 확인 |
| `02_normalization_seed.sql` | 실제 실행·롤백 검증 성공 | 빈 상태, 트랜잭션, 3/2/2/3·관계·IDENTITY 확인 |
| `03_normalization_compare.sql` | 실제 실행 성공 | 반복·고아·날짜·재대여 순서·활성 중복 |
| `04_add_integrity_rules.sql` | 실제 실행·거부 원자성 검증 성공 | 데이터 선검사, 정확한 대상 규칙, 메타데이터 확인 |
| `05_integrity_tests.sql` | 실제 실행 성공 | 경계·오류 예제, 양쪽 FK, 테스트 후 기준 상태 |
| `reset_normalization.sql` | 실제 실행 성공 | DB/public/read-only 보호, 자식→부모 삭제 |

---

## 7. 01 생성 원자성

- [x] 현재 DB가 `ai_database_book`인지 검사
- [x] `public` 스키마 존재 검사
- [x] `public` 스키마 `USAGE`·`CREATE` 권한 검사
- [x] 읽기 전용 연결 검사
- [x] Chapter 06 네 테이블 미존재 검사
- [x] `BEGIN`·`COMMIT`으로 네 `CREATE TABLE`을 묶음
- [x] 커밋 전 네 테이블 존재 확인
- [x] 커밋 전 네 테이블 모두 0행 확인
- [x] PostgreSQL 16에서 정상 생성 경로 실제 실행
- [ ] 의도적으로 두 번째·세 번째 `CREATE TABLE`을 실패시켜 전체 롤백되는 별도 실패 주입 테스트

마지막 항목은 코드 구조상 트랜잭션으로 보호되지만 Run 6에서 별도 실패 주입까지 하지는 않았다.

---

## 8. 02 샘플 입력 원자성

기준 상태:

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
raw = 1004
members = 103
books = 203
loans = 1004
```

- [x] 입력 전 네 테이블 0행 확인
- [x] 전체 INSERT·IDENTITY 조정을 하나의 트랜잭션으로 처리
- [x] 커밋 전 기준 상태 자동 확인
- [x] PostgreSQL 16에서 정상 입력 실제 확인
- [x] 의도적 `loans_nf` 입력 실패 시 raw/member/book 입력까지 전체 롤백 실제 확인

실패 주입 뒤 실제 행 수:

```text
raw = 0
members = 0
books = 0
loans = 0
```

---

## 9. 03 정규화 비교

자동 판정:

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
도서201 재대여 순서 오류 0
활성 중복 0
```

- [x] 데이터 비변경 파일
- [x] 정규화 전 현재 사실 반복 조회
- [x] 정규화 후 관계를 최소 JOIN으로 재구성
- [x] PostgreSQL 실제 기준값 확인
- [x] 실제 통과 메시지 확인: `Chapter 06 normalization comparison passed`

---

## 10. 04 규칙 추가

- [x] NULL 검사
- [x] 중복 이메일·ISBN 검사
- [x] 공백 이름·제목 검사
- [x] 날짜 순서 검사
- [x] 회원·도서 고아 참조 검사
- [x] 활성 대여 중복 검사
- [x] 기존 규칙 존재 여부를 정확한 `conrelid`와 이름으로 확인
- [x] `SET NOT NULL`·`UNIQUE`·`CHECK`·FK·부분 고유 인덱스 원자적 적용
- [x] 실제 명명 제약조건 8개 확인
- [x] 실제 NOT NULL 열 10개 확인
- [x] 실제 `uq_loans_nf_active_book` 존재 확인
- [x] 기존 중복 이메일 데이터를 넣은 뒤 04가 적용을 거부하는지 실제 확인
- [x] 거부 시 Chapter 06 명명 제약조건 0개·부분 고유 인덱스 미생성 확인

---

## 11. 05 정상·경계·오류 테스트

### 허용 경계값 실제 성공

- [x] `due_at = borrowed_at`
- [x] `returned_at = borrowed_at`
- [x] `returned_at = NULL` 기준 데이터
- [x] `published_year = NULL`
- [x] 공백 아닌 한 글자 이름

### 오류값 실제 거부

- [x] NOT NULL
- [x] 이메일 UNIQUE
- [x] ISBN UNIQUE
- [ ] ISBN NOT NULL — 최종 출판 검수에서 추가, 최신 CI 재검증 대상
- [x] 공백 회원 CHECK
- [x] 공백 도서 CHECK
- [x] 존재하지 않는 회원 FK
- [x] 존재하지 않는 도서 FK
- [x] due_at CHECK
- [x] returned_at CHECK
- [x] 두 번째 활성 대여 부분 고유 인덱스
- [x] 참조 중 부모 삭제 FK/RESTRICT

각 테스트는 실제 PostgreSQL 오류 메시지에서 기대 제약조건 또는 인덱스 이름을 확인했다.

테스트 후 자동 판정:

```text
raw 3 / members 2 / books 2 / loans 3 / 미반납 2
회원101 2 / 도서201 2 / 고아 0 / 활성 중복 0
```

- [x] 실제 통과 메시지 확인: `Chapter 06 integrity test baseline preserved`

경계 테스트에서 발견한 오류:

```text
기존 ISBN-BOUNDARY-LOAN-001
→ VARCHAR(20) 초과
→ 날짜 경계값보다 먼저 문자열 길이 오류 발생

수정 ISBN-BND-LOAN-001
→ VARCHAR(20) 범위 안에서 날짜 경계값을 정상 검증
```

---

## 12. 호환 파일

| 호환 파일 | 번호 파일 대응 | 상태 |
| --- | --- | --- |
| `normalization_schema.sql` | 01 | 최신 안전 기준 동기화·실제 실행 성공 |
| `normalization_seed.sql` | 02 | 최신 안전 기준 동기화·실제 실행 성공 |
| `normalization_practice.sql` | 03 | 최신 검증 기준 동기화·실제 실행 성공 |
| `integrity_tests.sql` | 05 | 최신 테스트 기준 동기화·실제 실행 성공 |

- [x] 번호 파일과 호환 파일을 중복 실행하지 않는다는 경고
- [x] PostgreSQL 16에서 호환 경로 전체 실제 실행 확인

---

## 13. 워크북

| 점검 항목 | 상태 |
| --- | --- |
| 권장 01→05 실행 경로 | 일치 |
| 위험한 중복·정상 반복 기록 | 일치 |
| 이상 현상 판단 | 일치 |
| 열의 주인·함수적 종속 | 일치 |
| 1NF·2NF·3NF | 일치 |
| C-01~C-08 연결 | 일치 |
| 정상·경계·오류 기록 | 일치 |
| 선택·심화 범위 분리 | 일치 |

---

## 14. 이론 발표자료

- [x] 정규화가 테이블 수 늘리기가 아니라는 핵심 메시지
- [x] 위험 중복과 정상 반복 구분
- [x] 삽입·수정·삭제 이상
- [x] 한 행 의미·열의 주인
- [x] 함수적 종속
- [x] 1NF·2NF·3NF
- [x] 정규화와 제약조건 역할 분리
- [x] AI 초안 재검토
- [ ] 브라우저 최종 렌더링 직접 확인

---

## 15. 실습 발표자료

기존 구형 기본 흐름:

```text
normalization_schema.sql
→ normalization_seed.sql
→ normalization_practice.sql
→ integrity_tests.sql
```

현재 기본 흐름:

```text
01 → 02 → 03 → 04 → 05
```

- [x] 실습 강의안 16개 장표로 재구성
- [x] 실제 runtime patch도 16개 장표로 일치
- [x] 01이 기본 구조만 만든다는 설명
- [x] 04가 기존 데이터 확인 후 규칙을 추가한다는 설명
- [x] raw3/m2/b2/l3/open2 기준
- [x] 회원101·도서201 반복 이력
- [x] 제약조건 8개·NOT NULL 10개·부분 인덱스
- [x] 03·05 자동 판정 메시지
- [ ] 브라우저 장표·스크립트 포커스 실제 확인

---

## 16. 의미 단위 내비게이션·스크립트·TTS

- [x] `chapter06_navigation.js`에서 이론·실습 계획 유지
- [x] 실습 runtime 16개 제목이 navigation 대상과 일치
- [x] `chapter06_script.js`가 theory/practice patch를 사용
- [x] `window.PresentationTTS.normalize()` 사용
- [x] `presentation/common/tts_pronunciation.js` 로드
- [x] `presentation/common/script_content_enhancer.js` 로드
- [x] JavaScript 정적 문법 검증 통과
- [ ] 실제 포커스 단계와 장표 시각 동기화 확인
- [ ] 실제 TTS 청취 발음 확인

---

## 17. 이미지·도식

```text
ch06_01_normalization_problem_overview
ch06_02_anomaly_types
ch06_03_first_normal_form
ch06_04_second_normal_form
ch06_05_third_normal_form
ch06_06_library_normalization_flow
ch06_07_before_after_join_tradeoff
ch06_08_ai_normalization_review_flow
```

- [x] Mermaid 원본 8개 존재 확인
- [x] SVG 결과물 8개 존재 확인
- [x] 도식과 SQL의 역할 분리
- [ ] Mermaid CLI 재생성 검증
- [ ] GitHub 브라우저 실제 렌더링 확인
- [ ] Word·PDF·eBook 최종 SVG 가독성 확인

---

## 18. Chapter 06 자동 검증

```text
Workflow: Validate Chapter 06
Run: 6
Commit: 0f7505a2ffe431c31c1396f69649faa910733f5c
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-08
```

- [x] 본문 18개 절 정적 검증
- [x] 실습 강의안 16개 절 정적 검증
- [x] 실습 runtime 16개 장표와 navigation 제목 대응
- [x] TTS·script enhancer 연결
- [x] Mermaid·SVG 8쌍 존재
- [x] 번호형 `reset→01→02→03→04→05` 실제 실행
- [x] 허용 경계값 실제 성공
- [x] NOT NULL·UNIQUE·CHECK·양쪽 FK·부분 고유 인덱스·RESTRICT 실제 실패
- [x] 02 중간 실패 전체 롤백
- [x] 04 위반 데이터 거부와 일부 규칙 미적용
- [x] 호환 SQL 전체 경로 실제 실행

상세 실행 기록:

```text
notes/chapter06_validation_result.md
```

---

## 19. 최종 출판 전 직접 확인

자동 검증과 별도로 직접 확인해야 할 항목:

- [ ] 브라우저 이론 발표자료 최종 렌더링
- [ ] 브라우저 실습 발표자료 최종 렌더링
- [ ] 발표자 스크립트와 의미 단위 포커스 실제 동기화
- [ ] TTS 실제 청취 발음
- [ ] Word·PDF·eBook SVG 가독성
- [ ] 최종 편집 분량 23~26페이지 여부

실제 확인하지 않은 항목은 “통과”로 표시하지 않는다.


---

## 19. 2026-08-10 최종 출판 보완

- [x] Chapter 05의 ISBN NULL 허용 상태와 Chapter 06 정책 확정 흐름 연결
- [x] C-02를 ISBN `NOT NULL` + `UNIQUE`로 문서·SQL 테스트에 일치시킴
- [x] `NOT NULL`/`DEFAULT` 설명 교정
- [x] PostgreSQL 기본 `UNIQUE` NULL 동작과 `NULLS NOT DISTINCT` 구분
- [x] 1NF·2NF·3NF 표현 정밀화
- [x] `CHECK`의 교차 행 검증 한계와 부분 고유 인덱스 역할 구분
- [x] `RESTRICT`와 `NO ACTION` 차이 보완
- [x] 생성 SQL의 `public USAGE/CREATE` 권한 검사 추가
- [ ] ISBN NULL 실패 테스트의 최신 PostgreSQL CI 실행 결과 확인
