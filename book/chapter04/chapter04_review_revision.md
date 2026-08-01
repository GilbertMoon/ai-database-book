# Chapter 04 자율 학습형 개편 반영 기록

## 대상 파일

```text
book/chapter04/chapter04.md
book/chapter04/chapter04_outline.md
book/chapter04/chapter04_activity.md
notes/chapter04_review_checklist.md
code/chapter04/01_create_students.sql
code/chapter04/02_insert_students.sql
code/chapter04/03_select_students.sql
code/chapter04/04_update_delete_students.sql
code/chapter04/verify_students.sql
code/chapter04/reset_students.sql
code/chapter04/basic_crud.sql
code/chapter04/README.md
images/chapter04/README.md
```

## 개편 목적

Chapter 04를 SQL 기능을 많이 나열하는 장이 아니라, 일반 독자가 첫 테이블과 기본 CRUD를 직접 실행하고 결과를 검증하는 자율 학습형 장으로 정리했다.

```text
현재 연결 확인
→ SQL 읽기와 예상
→ 필요한 범위 실행
→ 반환 행·영향 행 확인
→ 실제 데이터와 비교
```

---

## 1. 대상 독자와 완료 기준

다음 내용을 장 시작 부분에 추가했다.

- SQL을 처음 실행하는 독자를 대상으로 함
- Chapter 03 환경 외 별도 SQL 경험이 필요하지 않음
- 현재 연결과 실행 범위를 먼저 확인함
- 테이블 생성, 입력, 조회, 조건, NULL, 정렬, 수정과 삭제를 기본 완료 범위로 설정함
- AI SQL의 예상 영향 범위와 실제 결과를 비교함

세분된 학습 결과는 다음 핵심 작업으로 줄였다.

```text
테이블 생성
데이터 입력
조건 조회
NULL 확인
중복 제거·정렬·개수 제한
안전한 수정과 삭제
예상과 실제 결과 비교
```

---

## 2. 본문 구조 단순화

기존 23개 절을 다음 17개 절로 재구성했다.

```text
1. 첫 번째 테이블과 SQL 실습 흐름
2. 실습 위치와 실행 범위 확인하기
3. SQL의 기본 작성 규칙
4. CREATE TABLE로 첫 테이블 만들기
5. 열, 데이터 타입과 제약조건 읽기
6. INSERT로 데이터 입력하기
7. SELECT로 필요한 데이터 조회하기
8. WHERE와 비교 연산자
9. AND, OR, IN으로 조건 조합하기
10. LIKE로 문자열 검색하기
11. NULL 값 확인하기
12. DISTINCT, ORDER BY와 LIMIT
13. UPDATE를 안전하게 실행하기
14. DELETE를 안전하게 실행하기
15. AI가 만든 SQL 검토하기
16. 자주 하는 실수와 스스로 확인하기
17. 핵심 정리와 다음 장
```

별도 CRUD 서비스 연결 절과 종합 실습 반복 절은 도입부·정리·워크북으로 통합했다.

---

## 3. 실행 위치 원칙 정합성

Chapter 03의 개편 원칙에 맞춰 `current_schema() = public`을 절대 완료 조건으로 사용하지 않는다.

```text
현재 데이터베이스와 사용자를 확인한다.
search_path를 읽는다.
주요 객체는 public.students처럼 스키마를 명시한다.
```

`reset_students.sql`도 현재 스키마 대신 다음을 검사하도록 수정했다.

```text
current_database() = ai_database_book
public 스키마 존재
읽기 전용 연결이 아님
```

---

## 4. SQL 작성 규칙 추가

초급 독자를 위해 다음 내용을 한 절에 모았다.

```text
키워드 대문자
식별자 소문자 snake_case
문자열 작은따옴표
숫자 따옴표 없이 작성
세미콜론
-- 한 줄 주석
```

문자열 작은따옴표와 식별자 큰따옴표의 역할을 구분하고, 초급 실습에서는 큰따옴표가 필요한 객체 이름을 사용하지 않도록 했다.

---

## 5. 데이터 타입과 형 변환 보강

기존 실습 타입 외에 대표 데이터 타입을 용도 중심으로 정리했다.

```text
INTEGER·BIGINT
NUMERIC
VARCHAR·TEXT
BOOLEAN
DATE
TIMESTAMPTZ
```

금액처럼 정확성이 중요한 값에는 `NUMERIC`을 우선 검토하도록 안내했다.

형 변환은 선택 학습으로 추가했다.

```sql
CAST('3' AS INTEGER)
'3'::INTEGER
```

`UUID`와 `JSONB`는 선택 미리보기로 소개하고 Chapter 12로 연결했다.

---

## 6. 핵심·선택·심화 구분

### 핵심 학습

```text
CREATE TABLE
기본 타입과 제약조건
INSERT·SELECT
WHERE와 비교
AND·OR·IN
LIKE
NULL·IS NULL·IS NOT NULL
DISTINCT
ORDER BY·LIMIT
UPDATE·DELETE
```

### 선택 학습

```text
AS
RETURNING
ILIKE
NULLS FIRST·NULLS LAST
IS DISTINCT FROM
CAST와 ::
여러 열 UPDATE
UUID·JSONB 미리보기
```

### 심화 학습

```text
IDENTITY 번호 공백
CURRENT_TIMESTAMP와 트랜잭션 시각
NULL의 UNKNOWN
자동 생성 시퀀스
```

`RETURNING`은 본문 실습에서 사용하되 PostgreSQL 기능임을 표시했다.

---

## 7. DISTINCT 추가

기본 조회 학습에 `DISTINCT`를 추가했다.

```sql
SELECT DISTINCT major
FROM public.students
WHERE major IS NOT NULL
ORDER BY major;
```

`DISTINCT`가 원본 데이터를 삭제하는 기능이 아니라 조회 결과의 중복을 제거하는 기능임을 명시했다.

---

## 8. 데이터 상태 표현 개선

기존 체크포인트 A·B·C를 다음과 같이 직관적인 상태 이름으로 변경했다.

```text
초기 데이터 상태
수정 실습 후 상태
삭제 실습 후 상태
```

자기 확인 문제는 초기 데이터 상태를 기준으로 한다. 수정·삭제 후에는 초기화와 번호 파일을 통해 상태를 복원하도록 안내했다.

---

## 9. 실습 SQL 파일 분리

초보자의 반복 실행 오류를 줄이기 위해 다음 파일을 추가했다.

```text
01_create_students.sql
02_insert_students.sql
03_select_students.sql
04_update_delete_students.sql
verify_students.sql
```

| 파일 | 시작 상태 | 완료 상태 |
| --- | --- | --- |
| 생성 | 테이블 없음 | 빈 테이블 |
| 입력 | 빈 테이블 | 학생 6명 |
| 조회 | 학생 6명 | 변경 없음 |
| 수정·삭제 | 초기 학생 6명 | 수정·삭제 상태 |
| 확인 | 어떤 상태 | 구조와 데이터 조회 |

생성·입력·변경 파일은 예상 시작 상태를 확인하고, 조회·확인 파일은 반복 실행할 수 있도록 구성했다.

기존 `basic_crud.sql`은 삭제하지 않고 통합 참고 파일로 유지했다.

---

## 10. UPDATE와 DELETE 안전성

변경 흐름은 다음으로 통일했다.

```text
SELECT로 대상 확인
→ UPDATE 또는 DELETE
→ RETURNING과 영향받은 행 수 확인
→ SELECT로 결과 재확인
```

`WHERE` 없는 전체 변경 예시는 주석 상태로 유지했다. 여러 열 수정 예제도 선택 학습으로 제시하고 기본 실습에서는 실행하지 않는다.

---

## 11. AI SQL 검토 단순화

기존 세부 검토 항목을 다음 여섯 질문으로 줄였다.

```text
1. 현재 연결과 테이블이 맞는가?
2. 열과 데이터 타입이 맞는가?
3. WHERE와 NULL 처리가 맞는가?
4. 예상 반환 행 또는 영향 행 수는 몇 개인가?
5. 변경 전에 같은 조건으로 SELECT했는가?
6. 실제 결과가 예상과 일치하는가?
```

조회 SQL에서는 정렬과 `LIMIT` 필요 여부를 추가로 확인한다.

---

## 12. 워크북 개편

워크북을 핵심·선택·심화 활동으로 재구성했다.

```text
핵심
→ 위치, 작성 규칙, 테이블, 입력, 조회, NULL, 정렬, 수정·삭제, AI 검토

선택
→ RETURNING, ILIKE, NULLS LAST, 형 변환, 여러 열 UPDATE

심화
→ IDENTITY, CURRENT_TIMESTAMP, UNKNOWN, IS DISTINCT FROM
```

모든 활동을 완료하지 않아도 핵심 활동 후 다음 장으로 진행할 수 있다.

---

## 13. 도식과 문서 동기화

기존 도식 8종은 핵심 CRUD와 안전 실행 흐름에 적합하므로 유지했다. 이미지 관리 문서에는 다음 개편 원칙을 추가했다.

- 본문 17개 절과 그림 순서 일치
- 선택·심화 문법은 도식보다 코드와 표로 설명
- 데이터 상태 명칭 변경 반영
- 번호 SQL 파일과 도식 역할 구분

---

## 최종 상태

| 항목 | 상태 |
| --- | --- |
| 본문 17개 절 개편 | 완료 |
| 핵심·선택·심화 구분 | 완료 |
| SQL 작성 규칙 | 완료 |
| 데이터 타입·형 변환 보강 | 완료 |
| `DISTINCT` 추가 | 완료 |
| 데이터 상태 명칭 개선 | 완료 |
| 번호 SQL 파일 분리 | 완료 |
| 상태 확인 파일 추가 | 완료 |
| 초기화 조건 수정 | 완료 |
| 워크북 동기화 | 완료 |
| 체크리스트 동기화 | 완료 |

## 결론

```text
Chapter 04는 첫 SQL 실습 장으로서
문법의 양보다 현재 연결, 예상 결과, 영향 범위와 실제 결과를
반복 확인하는 학습 흐름에 집중하도록 개편되었다.
```

실제 PostgreSQL 통합 실행과 Word·PDF·eBook 렌더링은 전체 제작 단계에서 추가 확인한다.
