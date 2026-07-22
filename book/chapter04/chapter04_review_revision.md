# Chapter 04 최종 출판 검수 반영 기록

## 대상 파일

```text
book/chapter04/chapter04.md
book/chapter04/chapter04_activity.md
book/chapter04/chapter04_outline.md
code/chapter04/basic_crud.sql
code/chapter04/reset_students.sql
code/chapter04/README.md
notes/chapter04_review_checklist.md
README.md
```

## 검수 목적

Chapter 04를 첫 SQL 실습 장으로 유지하면서, 실제 실행 결과가 원고 설명과 달라지거나 독자가 잘못된 위치와 범위에서 데이터를 변경하는 문제를 제거했습니다.

```text
실행 위치 확인
→ 기준 데이터 상태 확인
→ 예상 결과 작성
→ 자동 커밋과 실행 범위 확인
→ SQL 실행
→ 반환·영향 행과 RETURNING 확인
→ 실제 데이터 재확인
```

---

## 1. 실행 위치 기준 통일

본문, 워크북, SQL 파일과 초기화 파일의 위치 확인을 다음 세 문장으로 통일했습니다.

```sql
SELECT current_database();
SELECT current_schema();
SHOW search_path;
```

주요 SQL 예제는 `public.students`처럼 스키마를 명시해 앞선 검색 경로의 동명 객체를 잘못 사용할 가능성을 줄였습니다.

---

## 2. 테이블 정의 보완

기존 등록 시각 정의를 다음처럼 변경했습니다.

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
```

다음 내용을 추가했습니다.

- `TIMESTAMPTZ`는 시간대를 고려해 시각을 저장한다.
- `CURRENT_TIMESTAMP`는 현재 트랜잭션의 시작 시각을 반환한다.
- 같은 입력 문장이나 트랜잭션의 행은 동일한 `created_at`을 가질 수 있다.
- 최신 순서에는 `id`를 보조 정렬 기준으로 사용한다.

`IDENTITY`는 행 식별용이며 입력 실패, 삭제와 트랜잭션 취소로 빈 번호가 생길 수 있으므로 학생 수나 빈틈없는 업무 순번으로 사용하지 않도록 설명했습니다.

---

## 3. 정렬과 LIMIT 안정성 보완

`ORDER BY`가 없는 조회 결과는 입력 순서나 `id` 순서를 보장하지 않는다는 설명을 추가했습니다.

```sql
ORDER BY grade DESC NULLS LAST, id ASC
```

PostgreSQL의 내림차순 기본 정렬에서 `NULL`이 앞에 올 수 있으므로 `NULLS LAST`를 명시했습니다.

최신 3명 조회는 다음처럼 동률을 구분합니다.

```sql
ORDER BY created_at DESC, id DESC
LIMIT 3
```

---

## 4. NULL 비교 보완

다음 내용을 명확히 했습니다.

```text
major = NULL은 문법 오류가 아닐 수 있다.
비교 결과가 UNKNOWN이 되어 WHERE에서 참으로 선택되지 않는다.
major <> '경영학'도 major가 NULL인 행을 포함하지 않는다.
```

NULL을 포함하는 방법으로 다음 예제를 추가했습니다.

```sql
WHERE major <> '경영학'
   OR major IS NULL
```

PostgreSQL의 NULL 안전 비교인 `IS DISTINCT FROM`도 참고 예제로 포함했습니다.

---

## 5. LIKE와 ILIKE 보완

문자열 패턴에 다음 내용을 추가했습니다.

- `%`: 0개 이상의 문자
- `_`: 정확히 한 문자
- `ILIKE`: PostgreSQL의 대소문자 비구분 패턴 검색

`ILIKE`가 모든 DBMS에서 동일하게 제공되는 표준 문법이 아님을 설명했습니다.

---

## 6. 자동 커밋과 변경 SQL 안전성

Chapter 03의 안전 기준을 실제 변경 실습 직전에 다시 연결했습니다.

```text
자동 커밋 상태에서는 INSERT·UPDATE·DELETE가 실행 직후 확정될 수 있다.
일반적인 실행 취소 기능으로 되돌릴 수 있다고 가정하지 않는다.
```

UPDATE와 DELETE 흐름은 다음으로 통일했습니다.

```text
같은 조건의 SELECT
→ UPDATE 또는 DELETE RETURNING
→ 영향받은 행 수 확인
→ RETURNING 결과 확인
→ SELECT로 재확인
```

DBeaver의 특정 화면 문구 대신 버전과 실행 방식에 관계없이 영향받은 행 수와 `RETURNING` 결과를 확인하도록 수정했습니다.

---

## 7. 데이터 상태 충돌 해결

실습 순서에 따라 데이터가 달라지는 문제를 해결하기 위해 세 가지 체크포인트를 도입했습니다.

| 체크포인트 | 학생 수 | 이준호 학년 | 박서연 |
| --- | ---: | ---: | --- |
| A: 입력 완료 | 6 | 3 | 존재 |
| B: UPDATE 완료 | 6 | 4 | 존재 |
| C: DELETE 완료 | 5 | 4 | 삭제 |

기존 1학년 또는 경영학 학생 삭제 검토는 실제 DELETE 이후 대상이 0행이 되는 문제가 있었습니다. AI 검토 예제를 체크포인트 C의 컴퓨터공학 학생 두 명으로 바꾸고, 실행하지 않는 가상 예제로 명시했습니다.

자기 확인 문제는 체크포인트 A를 기준으로 하며, 앞 실습을 완료한 독자는 초기화 후 생성·입력 구간까지만 다시 실행하도록 안내했습니다.

---

## 8. 초기화 파일 안전성 강화

기존 단순 삭제문을 현재 데이터베이스와 스키마를 확인하는 보호 구문으로 변경했습니다.

```text
현재 데이터베이스가 ai_database_book인가?
현재 스키마가 public인가?
조건이 맞을 때만 public.students를 삭제한다.
```

`reset_students.sql`은 하나의 `DO` 블록 안에서 검증과 삭제를 수행하므로 조건이 맞지 않으면 `DROP TABLE`까지 진행하지 않습니다.

기본 `basic_crud.sql`에는 자동 삭제 SQL을 포함하지 않는 원칙을 유지했습니다.

---

## 9. 교육용 최소 구조의 한계 명시

현재 `students` 테이블은 기본 SQL 학습용 구조입니다. 다음 항목은 완전하게 검증하지 않음을 명시했습니다.

```text
학년 1~4 범위
전공 이름 표준화
이메일 대소문자와 업무 중복 기준
학생 탈퇴와 복구 정책
```

이 내용은 Chapter 06의 제약조건과 데이터 무결성으로 연결했습니다.

---

## 10. 자기주도 학습 보완

본문에 다음 해설을 추가했습니다.

- 개념 확인 권장 답
- SQL 작성 예시
- WHERE 없는 UPDATE 영향 범위
- DELETE 전 확인용 SELECT
- 체크포인트 A 기준 예상 결과
- 동률 정렬과 `LIMIT` 해설

워크북에는 다음 활동을 추가했습니다.

- 자동 커밋 상태 기록
- `search_path` 확인
- IDENTITY 번호 공백 판단
- `<>`와 `NULL` 비교
- `CURRENT_TIMESTAMP` 의미
- 체크포인트 A·B·C 기록
- 초기 상태 복원 절차
- Supabase나 다른 환경이 아닌 로컬 `ai_database_book` 기준 확인

---

## 11. 최종 상태

| 항목 | 상태 |
| --- | --- |
| 본문 최종 출판 검수 반영 | 완료 |
| 독자 워크북 동기화 | 완료 |
| 구성안 갱신 | 완료 |
| `TIMESTAMPTZ` 적용 | 완료 |
| IDENTITY 번호 공백 설명 | 완료 |
| `SHOW search_path` 통일 | 완료 |
| 안정적인 `ORDER BY`와 `LIMIT` 적용 | 완료 |
| `NULL`·`UNKNOWN` 설명 보완 | 완료 |
| 자동 커밋 경고 | 완료 |
| 데이터 상태 체크포인트 | 완료 |
| AI 삭제 예제 충돌 해결 | 완료 |
| 초기화 보호 구문 | 완료 |
| 권장 해설 추가 | 완료 |
| 코드 README 갱신 | 완료 |
| 최종 리뷰 체크리스트 갱신 | 완료 |
| 루트 README 상태 갱신 | 완료 |

## 결론

```text
Chapter 04는 단순 CRUD 문법을 소개하는 장을 넘어,
실행 위치·정렬·NULL·자동 커밋·영향 범위와 기준 데이터 상태를
직접 확인하는 첫 안전 SQL 실습 장으로 최종 보완되었다.
```

실제 PostgreSQL 통합 실행, DBeaver 버전별 화면과 Word·PDF·eBook의 SVG 렌더링은 전체 제작 환경에서 추가 확인합니다.
