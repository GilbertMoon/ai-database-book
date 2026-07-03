# Chapter 04 이미지/도식 설계

## Chapter 04. 관계형 데이터베이스와 SQL 기초

이 문서는 Chapter 04 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 04는 SQL 기초 실습 장이므로, 도식은 **SQL 명령어의 역할, CRUD 흐름, SELECT 처리 과정, WHERE/ORDER BY, UPDATE/DELETE 안전 절차, AI 생성 SQL 검토**를 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- SQL 명령어와 CRUD 개념이 연결되어야 한다.
- SELECT, INSERT, UPDATE, DELETE가 테이블의 행과 열에 어떤 영향을 주는지 보여 준다.
- WHERE 조건이 “대상 행을 제한하는 장치”라는 점을 강조한다.
- UPDATE와 DELETE는 실행 전 SELECT로 확인하는 안전 절차를 시각화한다.
- AI가 만든 SQL도 사람이 영향 범위를 검토해야 한다는 흐름을 포함한다.
- Chapter 04의 students 테이블 예제와 연결한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 4-1 | `ch04_01_sql_crud_overview.svg` | SQL 명령어와 CRUD 흐름 | 4장 SQL의 기본 분류 또는 11장 CRUD 흐름 | INSERT, SELECT, UPDATE, DELETE와 CRUD 연결 | 높음 |
| 그림 4-2 | `ch04_02_select_projection_flow.svg` | SELECT와 컬럼 선택 흐름 | 5장 SELECT | `SELECT *`와 특정 컬럼 선택의 차이 설명 | 높음 |
| 그림 4-3 | `ch04_03_insert_row_flow.svg` | INSERT로 새 행 추가하기 | 6장 INSERT | VALUES가 테이블의 새 행으로 추가되는 과정 설명 | 중간 |
| 그림 4-4 | `ch04_04_where_filter_flow.svg` | WHERE 조건으로 행 필터링 | 7장 WHERE | 조건에 맞는 행만 선택되는 흐름 설명 | 높음 |
| 그림 4-5 | `ch04_05_order_by_sort_flow.svg` | ORDER BY 정렬 흐름 | 8장 ORDER BY | ASC와 DESC 정렬 차이 설명 | 중간 |
| 그림 4-6 | `ch04_06_update_safe_flow.svg` | 안전한 UPDATE 실행 절차 | 9장 UPDATE 또는 12장 SELECT 먼저 실행하는 습관 | SELECT 확인 → UPDATE → SELECT 확인 절차 강조 | 높음 |
| 그림 4-7 | `ch04_07_delete_safe_flow.svg` | 안전한 DELETE 실행 절차 | 10장 DELETE 또는 12장 SELECT 먼저 실행하는 습관 | 삭제 전후 SELECT 확인 절차 강조 | 높음 |
| 그림 4-8 | `ch04_08_ai_sql_review_flow.svg` | AI 생성 SQL 검토 흐름 | 13장 AI가 만든 SQL 검토하기 | AI SQL 초안 → 대상/조건/영향범위 확인 → 실행 판단 흐름 | 높음 |

---

## 3. 본문 삽입 권장 위치

### 그림 4-1 SQL 명령어와 CRUD 흐름

삽입 위치:

```text
Chapter 04 본문 4. SQL의 기본 분류
또는 11. CRUD 흐름으로 이해하기
```

본문 삽입 예시:

```markdown
![SQL 명령어와 CRUD 흐름](../../images/chapter04/ch04_01_sql_crud_overview.svg)

그림 4-1 SQL 명령어와 CRUD 흐름
```

---

### 그림 4-2 SELECT와 컬럼 선택 흐름

삽입 위치:

```text
Chapter 04 본문 5. SELECT: 데이터 조회하기
```

본문 삽입 예시:

```markdown
![SELECT와 컬럼 선택 흐름](../../images/chapter04/ch04_02_select_projection_flow.svg)

그림 4-2 SELECT와 컬럼 선택 흐름
```

---

### 그림 4-3 INSERT로 새 행 추가하기

삽입 위치:

```text
Chapter 04 본문 6. INSERT: 데이터 추가하기
```

본문 삽입 예시:

```markdown
![INSERT로 새 행 추가하기](../../images/chapter04/ch04_03_insert_row_flow.svg)

그림 4-3 INSERT로 새 행 추가하기
```

---

### 그림 4-4 WHERE 조건으로 행 필터링

삽입 위치:

```text
Chapter 04 본문 7. WHERE: 조건 지정하기
```

본문 삽입 예시:

```markdown
![WHERE 조건으로 행 필터링](../../images/chapter04/ch04_04_where_filter_flow.svg)

그림 4-4 WHERE 조건으로 행 필터링
```

---

### 그림 4-5 ORDER BY 정렬 흐름

삽입 위치:

```text
Chapter 04 본문 8. ORDER BY: 정렬하기
```

본문 삽입 예시:

```markdown
![ORDER BY 정렬 흐름](../../images/chapter04/ch04_05_order_by_sort_flow.svg)

그림 4-5 ORDER BY 정렬 흐름
```

---

### 그림 4-6 안전한 UPDATE 실행 절차

삽입 위치:

```text
Chapter 04 본문 9. UPDATE: 데이터 수정하기
또는 12. SELECT를 먼저 실행하는 습관
```

본문 삽입 예시:

```markdown
![안전한 UPDATE 실행 절차](../../images/chapter04/ch04_06_update_safe_flow.svg)

그림 4-6 안전한 UPDATE 실행 절차
```

---

### 그림 4-7 안전한 DELETE 실행 절차

삽입 위치:

```text
Chapter 04 본문 10. DELETE: 데이터 삭제하기
또는 12. SELECT를 먼저 실행하는 습관
```

본문 삽입 예시:

```markdown
![안전한 DELETE 실행 절차](../../images/chapter04/ch04_07_delete_safe_flow.svg)

그림 4-7 안전한 DELETE 실행 절차
```

---

### 그림 4-8 AI 생성 SQL 검토 흐름

삽입 위치:

```text
Chapter 04 본문 13. AI가 만든 SQL 검토하기
```

본문 삽입 예시:

```markdown
![AI 생성 SQL 검토 흐름](../../images/chapter04/ch04_08_ai_sql_review_flow.svg)

그림 4-8 AI 생성 SQL 검토 흐름
```

---

## 4. Mermaid 원본 파일 계획

| Mermaid 파일 | 대상 이미지 |
| --- | --- |
| `ch04_01_sql_crud_overview.mmd` | `ch04_01_sql_crud_overview.svg` |
| `ch04_02_select_projection_flow.mmd` | `ch04_02_select_projection_flow.svg` |
| `ch04_03_insert_row_flow.mmd` | `ch04_03_insert_row_flow.svg` |
| `ch04_04_where_filter_flow.mmd` | `ch04_04_where_filter_flow.svg` |
| `ch04_05_order_by_sort_flow.mmd` | `ch04_05_order_by_sort_flow.svg` |
| `ch04_06_update_safe_flow.mmd` | `ch04_06_update_safe_flow.svg` |
| `ch04_07_delete_safe_flow.mmd` | `ch04_07_delete_safe_flow.svg` |
| `ch04_08_ai_sql_review_flow.mmd` | `ch04_08_ai_sql_review_flow.svg` |

---

## 5. 도식 제작 후 점검 항목

```text
- CRUD와 SQL 명령어가 정확히 연결되는가?
- SELECT가 컬럼 선택과 행 조회를 구분해 설명하는가?
- INSERT가 새 행 추가라는 개념을 명확히 보여 주는가?
- WHERE가 대상 행을 제한한다는 점이 분명한가?
- ORDER BY의 ASC/DESC 차이가 이해되는가?
- UPDATE/DELETE 전후 SELECT 확인 절차가 강조되는가?
- AI 생성 SQL 검토 흐름이 대상 테이블, 조건, 영향 범위 확인을 포함하는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 04 도식 후보 8종 정리 완료
- 다음 작업: Chapter 04 Mermaid 도식 원본 8종 작성
```
