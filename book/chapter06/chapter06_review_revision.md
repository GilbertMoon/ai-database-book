# Chapter 06 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter06/chapter06.md
book/chapter06/chapter06_activity.md
book/chapter06/chapter06_outline.md
code/chapter06/normalization_schema.sql
code/chapter06/normalization_seed.sql
code/chapter06/normalization_practice.sql
code/chapter06/integrity_tests.sql
code/chapter06/reset_normalization.sql
code/chapter06/README.md
images/chapter06/README.md
notes/chapter06_review_checklist.md
README.md
```

## 목적

Chapter 06을 정규형 개념 설명 중심에서 **정규화와 데이터 무결성을 함께 검증하는 장**으로 재구성한다.

Chapter 05에서 이동한 외래키 오류, 참조 무결성과 삭제 정책을 수용하고, Chapter 04·05에서 확립한 안전 실행 원칙과 `IDENTITY` 방식을 유지한다.

---

## 1. 제목과 역할 변경

### 기존 제목

```text
정규화와 좋은 테이블 설계
```

### 변경 제목

```text
정규화와 데이터 무결성으로 좋은 테이블 만들기
```

### 새 흐름

```text
행 의미·컬럼 주인
→ 중복과 이상 현상
→ 함수적 종속
→ 1NF·2NF·3NF
→ 정규화 구조
→ PK·FK·NOT NULL·UNIQUE·CHECK
→ 정상·오류 데이터 테스트
→ 삭제 정책
→ 과도한 분리와 AI 검토
```

---

## 2. 강화한 내용

| 항목 | 반영 내용 |
| --- | --- |
| 위험한 중복 | 같은 사실의 복사본과 정상적인 FK 반복 구분 |
| 컬럼의 주인 | 회원·도서·대여 사실을 소유자 기준으로 분리 |
| 함수적 종속 | `X → Y`의 업무 규칙 의미 추가 |
| 정규형 | 1NF·2NF·3NF 독립 예제와 전제 유지 |
| 데이터 무결성 | 정규화와 제약조건의 역할 차이 추가 |
| 제약조건 | PK, FK, NOT NULL, UNIQUE, CHECK 상세 연결 |
| 참조 무결성 | 존재하지 않는 부모 참조 오류 실습 추가 |
| 삭제 정책 | RESTRICT, NO ACTION, CASCADE, SET NULL 비교 |
| CASCADE 주의 | 요구사항 근거 없는 자동 삭제 금지 강조 |
| 오류 테스트 | 실패해야 하는 SQL과 오류 후 데이터 보존 확인 |
| 이력 데이터 | 주문 당시 가격과 현재 가격의 의미 차이 추가 |
| AI 검토 | 구조·제약조건·삭제 정책·오류 테스트까지 확대 |

---

## 3. 후속 장과 범위 구분

| 내용 | 처리 |
| --- | --- |
| JOIN 문법과 다양한 결합 | Chapter 08에서 상세 학습 |
| 여러 단계 작업의 원자성 | Chapter 09 트랜잭션에서 학습 |
| 인덱스·실행 계획과 반정규화 판단 | Chapter 10 이후 측정 기반 검토 |
| 운영 데이터 정제·중복 병합·마이그레이션 | 이 장 범위 제외 |
| BCNF·4NF·5NF | 입문 범위 제외 |

---

## 4. SQL 구조 변경

### 기존

```text
normalization_practice.sql
- 자동 DROP
- 원시·정규화 테이블 생성
- 샘플 데이터 입력
- JOIN
- UPDATE
```

### 변경

```text
normalization_schema.sql
- 현재 DB·스키마 확인
- 원시·정규화 테이블과 제약조건 생성

normalization_seed.sql
- 명시적 ID 정상 샘플 입력

normalization_practice.sql
- 중복·행 수·관계·수정 이상 감소 확인

integrity_tests.sql
- 실패해야 하는 오류 SQL을 주석 상태로 제공

reset_normalization.sql
- 필요할 때만 자식→부모 순서로 삭제
```

### 안전성 개선

```text
- 자동 DROP 제거
- SERIAL을 IDENTITY로 변경
- Chapter 05 테이블과 충돌하지 않도록 _nf 접미사 사용
- 자동 증가값 1, 2, 3 가정 제거
- 오류 SQL은 모두 주석 처리하고 한 문장씩 선택 실행
- 참조 중인 부모 삭제를 ON DELETE RESTRICT로 차단
```

---

## 5. 실습 테이블과 샘플 기준

| 테이블 | 행 수 | ID |
| --- | ---: | --- |
| `library_records_raw` | 3 | 1001~1003 |
| `members_nf` | 2 | 101, 102 |
| `books_nf` | 2 | 201, 202 |
| `loans_nf` | 3 | 1001~1003 |

적용 제약조건:

```text
members_nf.name: NOT NULL + 공백 CHECK
members_nf.email: NOT NULL + UNIQUE
books_nf.title: NOT NULL + 공백 CHECK
books_nf.isbn: NOT NULL + UNIQUE
loans_nf.member_id, book_id: FK + NOT NULL + RESTRICT
loans_nf.due_at: 대여일 이후 CHECK
loans_nf.returned_at: NULL 또는 대여일 이후 CHECK
```

---

## 6. 오류 테스트

`integrity_tests.sql`에 다음 실패 테스트를 추가했다.

```text
NOT NULL 위반
UNIQUE 위반
공백 이름 CHECK 위반
존재하지 않는 회원 FOREIGN KEY 위반
잘못된 반납예정일 CHECK 위반
잘못된 실제반납일 CHECK 위반
참조 중인 회원 삭제 RESTRICT 위반
참조되지 않는 회원 정상 삭제
```

오류 발생 후 행 수와 기존 데이터를 다시 조회하도록 구성했다.

---

## 7. 도식 처리

기존 Mermaid·SVG 8종은 정규화 핵심 설명과 호환되므로 유지한다.

```text
중복 문제
세 이상 현상
1NF
2NF
3NF
도서 대여 정규화 흐름
정규화 저장과 JOIN 조회
AI 구조 검토
```

무결성 제약조건과 삭제 정책은 SQL 코드·표가 더 적합하므로 별도 SVG를 추가하지 않았다.

---

## 8. 남은 확인 항목

```text
- 실제 PostgreSQL에서 schema → seed → practice 순서 실행
- integrity_tests.sql의 오류 SQL을 한 문장씩 실행
- 제약조건 이름과 오류 메시지 확인
- 오류 후 정상 행 수가 유지되는지 확인
- GitHub에서 기존 SVG 8종 표시 확인
- Word/PDF/eBook 변환 시 표와 SQL 줄바꿈 확인
- Chapter 07 프로젝트가 새 무결성 검증 기준을 수용하는지 확인
```

---

## 9. 최종 상태

```text
Chapter 06 본문, 워크북, 구성안과 SQL 실행 구조를 2차 재구성했다.
정규화와 데이터 무결성을 하나의 검증 흐름으로 연결했다.
원격 main에는 Chapter 06 관련 변경을 직접 반영했다.
```
