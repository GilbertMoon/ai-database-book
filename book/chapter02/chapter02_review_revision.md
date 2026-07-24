# Chapter 02 최종 출판 내용 검수 반영 완료

## 대상 파일

```text
book/chapter02/chapter02.md
book/chapter02/chapter02_activity.md
book/chapter02/chapter02_outline.md
notes/chapter02_review_checklist.md
images/chapter02/README.md
images/chapter02/ch02_02_table_row_column.mmd
README.md
```

## 검수 목적

Chapter 02를 단순 용어 나열 장이 아니라 다음 구조를 정확히 읽는 입문 장으로 완성했습니다.

```text
사용자
→ DBeaver
→ PostgreSQL DBMS
→ 데이터베이스
→ 스키마
→ 테이블
→ 행과 열
```

Chapter 01에서 확정한 판단 기준과 용어를 이어받고, Chapter 03·04·07의 실제 객체 생성 순서, Chapter 05·06의 관계·무결성 설계, Chapter 08·14의 VIEW·분석 흐름과 일치하도록 정리했습니다.

---

## 1. 실제 실습 구조와 장 간 연결

이전 원고는 `ai_database_book.public`에 `students`, `courses`, `enrollments`가 모두 만들어지는 것처럼 설명했습니다. 최종 원고에서는 실제 책의 순서를 다음처럼 수정했습니다.

```text
PostgreSQL 서버
└── ai_database_book                 Chapter 03
    ├── public
    │   └── students                 Chapter 04
    └── course_project               Chapter 07
        ├── students
        ├── instructors
        ├── courses
        └── enrollments
```

Chapter 02의 학생·강의·수강신청 표는 개념 설명용 축약 예제라고 명시했습니다.

다음 장 연결도 다음처럼 구분했습니다.

```text
필수 경로
→ 로컬 PostgreSQL 설치
→ DBeaver 연결
→ ai_database_book 생성

선택 읽기
→ 관리형 PostgreSQL 구조
→ Supabase 사례
```

Supabase가 Chapter 04 이후의 로컬 필수 경로를 그대로 대체하는 것으로 설명하지 않습니다.

---

## 2. 온라인 강의 사례 용어 정리

기본 범위는 Chapter 07과 맞췄습니다.

```text
학생
강사
강의
수강신청
신청 상태
신청 당시 기록 금액
```

상태 예시는 `신청`, `수강중`, `완료`, `취소` 범위에서 사용합니다.

금액은 다음처럼 구분했습니다.

```text
신청 당시 기록 금액
≠ 결제 완료 금액
≠ 환불 반영 순금액
≠ 회계 매출
```

결제 시도·실패와 환불은 별도 결제 구조가 필요한 확장 범위로 설명했습니다.

---

## 3. 관계 용어 정확성 강화

‘관계형 데이터베이스’의 관계와 업무 대상 사이의 관계를 구분했습니다.

```text
릴레이션(Relation)
→ 관계 모델에서 행과 열로 구성된 테이블에 가까운 구조

업무 관계(Relationship)
→ 학생과 질문처럼 업무 대상이 연결되는 규칙

카디널리티(Cardinality)
→ 1:1, 1:N, N:M처럼 최대 연결 개수 표현
```

관계형 데이터베이스를 단순히 테이블을 연결하는 데이터베이스라고 설명하지 않도록 보완했습니다.

---

## 4. 테이블·행·열·셀 설명 보완

다음 오해를 차단했습니다.

```text
ORDER BY가 없으면 조회 결과의 행 순서는 보장되지 않는다.
화면상의 첫 번째·두 번째 행 위치를 데이터 식별 기준으로 사용하지 않는다.
셀은 표를 이해하기 위한 편의적 표현이다.
SQL에서는 행 조건과 열 이름으로 값을 다룬다.
```

기존 테이블 도식은 유지하되 본문에서 `id = 1` 같은 조건으로 값을 설명하도록 수정했습니다.

---

## 5. 기본키와 외래키 경계 설명

기본키와 외래키를 다음처럼 구분했습니다.

```text
기본키
→ 자신의 테이블에서 각 행을 고유하게 구분
→ 중복과 NULL 불가

외래키
→ 다른 행을 참조
→ 1:N 관계에서 같은 값 반복 가능
→ NULL 허용 여부는 NOT NULL로 별도 결정
→ 1:1 여부는 UNIQUE 같은 추가 규칙으로 결정
```

외래키를 정의했다고 필수 관계나 1:1 관계가 자동으로 완성되는 것은 아니라는 설명을 추가했습니다.

---

## 6. SQL과 CRUD 보완

CRUD의 Create와 SQL `CREATE TABLE`을 구분한 기존 설명을 유지했습니다.

CRUD Delete는 다음 두 구현을 모두 포함할 수 있다고 보완했습니다.

```text
물리 삭제
→ DELETE로 행 제거

상태 기반 삭제
→ status 또는 deleted_at 변경
→ 과거 업무 이력 보존
```

`DEFAULT`는 값을 생략했을 때 사용할 기본값 설정이며 `NOT NULL`, `UNIQUE`, `CHECK`와 역할이 다르다고 정리했습니다.

---

## 7. 데이터 분류와 저장 방식 분리

다음 두 분류를 같은 것으로 보지 않도록 수정했습니다.

```text
정형·반정형·비정형
→ 데이터의 구조적 특성

RDBMS·문서형 DB·파일·객체 저장소
→ 데이터를 저장하고 사용하는 방식
```

PostgreSQL도 `JSONB`로 반정형 데이터를 저장할 수 있으며 정형 데이터도 CSV나 스프레드시트로 전달될 수 있다는 예를 추가했습니다.

---

## 8. 기준 데이터·파생 데이터·AI 결과 통일

Chapter 01의 최종 용어를 Chapter 02 전체에 반영했습니다.

```text
기준 데이터(Source of Truth)
결정적 파생 데이터(Derived Data)
AI 생성 결과
```

AI 요약을 결정적 파생 데이터와 같은 범주로 처리하지 않습니다. 모델·입력 기준 시점·프롬프트·실행 조건에 따라 결과가 달라질 수 있음을 명시했습니다.

일반 VIEW와 결과 저장 객체도 구분했습니다.

```text
일반 VIEW
→ 조회 정의 저장
→ 호출할 때 원본 데이터 조회

Materialized View·집계 테이블·캐시
→ 결과를 별도로 저장 가능
→ 갱신 기준 필요
```

---

## 9. AI 구조 검토 기준 확대

AI가 만든 테이블을 다음 순서로 검토하도록 정리했습니다.

```text
1. 한 행의 의미
2. 테이블·열 이름
3. 기본키
4. 다른 데이터 참조
5. 서로 다른 데이터 혼합
6. 데이터 타입
7. 필수값과 선택값
8. 후속 장에서 검토할 상세 설계 문제
```

실제 관계 설계는 Chapter 05, 무결성과 제약조건은 Chapter 06, 체계적 AI 검증은 Chapter 13으로 넘깁니다.

---

## 10. 워크북 구조 개선

워크북을 다음처럼 구분했습니다.

### 핵심 활동

```text
DBeaver와 PostgreSQL 구분
PostgreSQL 계층 구조 읽기
테이블·행·열·셀 찾기
기본키·외래키 찾기
AI 생성 구조 검토
```

### 확장 활동

```text
릴레이션·업무 관계·카디널리티
CRUD와 삭제 방식
DBMS 운영 기능
데이터 구조 유형과 저장 방식
기준 데이터·결정적 파생·AI 결과
일반 VIEW와 저장된 결과
```

다음 권장 해설을 추가했습니다.

- 행 순서 비보장
- 기본키와 외래키
- 외래키 반복·NULL 가능성
- 관계 모델과 업무 관계
- CRUD Delete와 상태 기반 삭제
- 일반 VIEW와 저장된 파생 결과
- 데이터 구조 유형과 저장소 유형
- 신청 당시 기록 금액과 결제·매출

---

## 11. 도식 관리

본문 사용 도식은 5종입니다.

```text
ch02_02_table_row_column.svg
ch02_05_relationship_types.svg
ch02_03_primary_key_concept.svg
ch02_04_foreign_key_relationship.svg
ch02_08_ai_table_review.svg
```

`ch02_02_table_row_column.svg`는 수동 보정 SVG로 관리하고 Mermaid는 같은 논리를 표현하는 편집용 원본으로 정리했습니다. 두 파일이 자동으로 완전히 같은 형태로 생성된다고 설명하지 않습니다.

미사용 도식 3종은 보관 상태를 유지합니다.

---

## 12. 최종 상태

| 항목 | 상태 |
| --- | --- |
| 본문 최종 검수 | 완료 |
| 워크북 핵심·확장 활동 분리 | 완료 |
| 구성안 동기화 | 완료 |
| Chapter 01 용어 연결 | 완료 |
| Chapter 03·04·07 실제 실습 구조 반영 | 완료 |
| Chapter 05·06 범위 분리 | 완료 |
| Chapter 08·14 VIEW·분석 연결 | 완료 |
| 최종 리뷰 체크리스트 갱신 | 완료 |
| 이미지 관리 문서 갱신 | 완료 |
| Word·PDF·eBook SVG 렌더링 | 전체 출판 렌더링 단계에서 확인 예정 |

---

## 결론

```text
Chapter 02는 설계를 직접 완성하는 장이 아니라,
DBMS·데이터베이스·스키마·테이블·키와 데이터 역할을
정확한 용어로 읽고 설명하는 장으로 최종 정리했다.
```