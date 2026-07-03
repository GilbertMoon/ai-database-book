# Chapter 02 이미지/도식 설계

## Chapter 02. DBMS 기본 개념

이 문서는 Chapter 02 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 02는 데이터베이스 입문에서 가장 중요한 기본 용어를 다루므로, 도식은 **DBMS 계층 구조, 테이블 구조, 키와 관계, CRUD 흐름, 제약조건 역할**을 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 초급자가 테이블, 행, 열을 직관적으로 구분할 수 있어야 한다.
- 기본키와 외래키의 차이를 시각적으로 보여 준다.
- DBMS → 데이터베이스 → 테이블 → 행/열의 계층 구조를 명확히 표현한다.
- 학생-강의-수강신청 예제를 중심으로 관계를 설명한다.
- AI가 생성한 나쁜 테이블 구조와 개선 방향을 비교할 수 있어야 한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 2-1 | `ch02_01_dbms_hierarchy.png` | DBMS, 데이터베이스, 테이블의 계층 구조 | 2장 데이터베이스와 DBMS | PostgreSQL 안에 데이터베이스와 테이블이 구성되는 구조 설명 | 높음 |
| 그림 2-2 | `ch02_02_table_row_column.png` | 테이블, 행, 열의 구조 | 3장 테이블, 행, 열 | 테이블 구조와 row/column 개념 시각화 | 높음 |
| 그림 2-3 | `ch02_03_primary_key_concept.png` | 기본키가 행을 구분하는 방식 | 4장 기본키 | id가 같은 이름의 학생을 구분하는 역할 설명 | 높음 |
| 그림 2-4 | `ch02_04_foreign_key_relationship.png` | 외래키로 연결되는 학생-강의-수강신청 관계 | 5장 외래키 또는 9장 작은 예제 | FK가 다른 테이블의 PK를 참조하는 구조 설명 | 높음 |
| 그림 2-5 | `ch02_05_relationship_types.png` | 1:1, 1:N, N:M 관계 유형 | 6장 관계란 무엇인가 | 관계 유형을 간단한 예시로 비교 | 중간 |
| 그림 2-6 | `ch02_06_crud_flow.png` | CRUD와 SQL 명령어 흐름 | 7장 SQL과 CRUD | Create, Read, Update, Delete와 SQL 명령어 연결 | 중간 |
| 그림 2-7 | `ch02_07_constraints_guardrail.png` | 제약조건은 잘못된 데이터를 막는 안전장치 | 8장 제약조건 | PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE 등 역할 설명 | 중간 |
| 그림 2-8 | `ch02_08_ai_table_review.png` | AI 생성 테이블 구조 검토 흐름 | 10장 AI 활용 실습 | AI가 만든 테이블을 PK/FK/중복/제약조건 관점에서 검토하는 과정 | 높음 |

---

## 3. 본문 삽입 권장 위치

### 그림 2-1 DBMS, 데이터베이스, 테이블의 계층 구조

삽입 위치:

```text
Chapter 02 본문 2. 데이터베이스와 DBMS
```

본문 삽입 예시:

```markdown
![DBMS, 데이터베이스, 테이블의 계층 구조](../../images/chapter02/ch02_01_dbms_hierarchy.svg)

그림 2-1 DBMS, 데이터베이스, 테이블의 계층 구조
```

---

### 그림 2-2 테이블, 행, 열의 구조

삽입 위치:

```text
Chapter 02 본문 3. 테이블, 행, 열
```

본문 삽입 예시:

```markdown
![테이블, 행, 열의 구조](../../images/chapter02/ch02_02_table_row_column.svg)

그림 2-2 테이블, 행, 열의 구조
```

---

### 그림 2-3 기본키가 행을 구분하는 방식

삽입 위치:

```text
Chapter 02 본문 4. 기본키(PK)
```

본문 삽입 예시:

```markdown
![기본키가 행을 구분하는 방식](../../images/chapter02/ch02_03_primary_key_concept.svg)

그림 2-3 기본키가 행을 구분하는 방식
```

---

### 그림 2-4 외래키로 연결되는 학생-강의-수강신청 관계

삽입 위치:

```text
Chapter 02 본문 5. 외래키(FK)
또는 9. 작은 예제: 학생과 수강신청 구조
```

본문 삽입 예시:

```markdown
![외래키로 연결되는 학생-강의-수강신청 관계](../../images/chapter02/ch02_04_foreign_key_relationship.svg)

그림 2-4 외래키로 연결되는 학생-강의-수강신청 관계
```

---

### 그림 2-5 1:1, 1:N, N:M 관계 유형

삽입 위치:

```text
Chapter 02 본문 6. 관계란 무엇인가
```

본문 삽입 예시:

```markdown
![1:1, 1:N, N:M 관계 유형](../../images/chapter02/ch02_05_relationship_types.svg)

그림 2-5 1:1, 1:N, N:M 관계 유형
```

---

### 그림 2-6 CRUD와 SQL 명령어 흐름

삽입 위치:

```text
Chapter 02 본문 7. SQL과 CRUD
```

본문 삽입 예시:

```markdown
![CRUD와 SQL 명령어 흐름](../../images/chapter02/ch02_06_crud_flow.svg)

그림 2-6 CRUD와 SQL 명령어 흐름
```

---

### 그림 2-7 제약조건은 잘못된 데이터를 막는 안전장치

삽입 위치:

```text
Chapter 02 본문 8. 제약조건
```

본문 삽입 예시:

```markdown
![제약조건은 잘못된 데이터를 막는 안전장치](../../images/chapter02/ch02_07_constraints_guardrail.svg)

그림 2-7 제약조건은 잘못된 데이터를 막는 안전장치
```

---

### 그림 2-8 AI 생성 테이블 구조 검토 흐름

삽입 위치:

```text
Chapter 02 본문 10. AI 활용 실습: 테이블 구조 생성하고 검토하기
```

본문 삽입 예시:

```markdown
![AI 생성 테이블 구조 검토 흐름](../../images/chapter02/ch02_08_ai_table_review.svg)

그림 2-8 AI 생성 테이블 구조 검토 흐름
```

---

## 4. Mermaid 원본 파일 계획

다음 Mermaid 파일을 도식 제작 원본으로 사용합니다.

| Mermaid 파일 | 대상 이미지 |
| --- | --- |
| `ch02_01_dbms_hierarchy.mmd` | `ch02_01_dbms_hierarchy.svg` |
| `ch02_02_table_row_column.mmd` | `ch02_02_table_row_column.svg` |
| `ch02_03_primary_key_concept.mmd` | `ch02_03_primary_key_concept.svg` |
| `ch02_04_foreign_key_relationship.mmd` | `ch02_04_foreign_key_relationship.svg` |
| `ch02_05_relationship_types.mmd` | `ch02_05_relationship_types.svg` |
| `ch02_06_crud_flow.mmd` | `ch02_06_crud_flow.svg` |
| `ch02_07_constraints_guardrail.mmd` | `ch02_07_constraints_guardrail.svg` |
| `ch02_08_ai_table_review.mmd` | `ch02_08_ai_table_review.svg` |

---

## 5. 도식 제작 후 점검 항목

```text
- Chapter 02 본문 설명과 도식 내용이 일치하는가?
- DBMS, 데이터베이스, 테이블의 계층 구조가 명확한가?
- 테이블, 행, 열이 초급자에게 직관적으로 보이는가?
- PK와 FK의 차이가 시각적으로 구분되는가?
- 관계 유형이 1:1, 1:N, N:M으로 명확히 표현되는가?
- CRUD와 SQL 명령어가 연결되어 있는가?
- AI 검토 도식이 단순 생성이 아니라 검증 중심인가?
- 그림 번호와 캡션이 본문에 포함되었는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 02 도식 후보 8종 정리 완료
- 다음 작업: Chapter 02 Mermaid 도식 원본 8종 작성
```
