# Chapter 04 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter04/chapter04.md
book/chapter04/chapter04_activity.md
book/chapter04/chapter04_outline.md
code/chapter04/basic_crud.sql
code/chapter04/reset_students.sql
code/chapter04/README.md
images/chapter04/README.md
README.md
```

## 재구성 목적

Chapter 03에서 테이블 생성과 데이터 입력을 제거한 흐름을 이어받아 Chapter 04를 실제 첫 SQL 실습 장으로 재구성했습니다.

기존 CRUD 문법 설명은 유지하되 다음 원칙을 강화했습니다.

```text
현재 실행 위치 확인
→ SQL 실행 결과 예상
→ SQL 실행
→ 반환 행 또는 영향받은 행 수 확인
→ 실제 데이터와 비교
```

---

## 1. 제목과 역할 변경

### 기존 제목

```text
관계형 데이터베이스와 SQL 기초
```

### 변경 제목

```text
관계형 데이터베이스와 SQL 시작하기
```

### 변경된 역할

```text
PostgreSQL에서 첫 테이블을 만들고 데이터를 입력·조회·수정·삭제하면서,
실행 전 예상 결과와 실행 후 실제 변화를 비교하는 장
```

권장 분량은 20~25페이지에서 18~22페이지로 조정했습니다.

---

## 2. 새로 추가한 내용

| 추가 항목 | 반영 위치 |
| --- | --- |
| 현재 데이터베이스와 스키마 확인 | 본문 2절, 워크북 2절, SQL 0구간 |
| SQL 실행 전 예상 결과 작성 | 본문 3절, 워크북 전체 |
| `IDENTITY` 자동 번호 방식 | 본문 4절, SQL 테이블 정의 |
| `RETURNING` | INSERT, UPDATE, DELETE 예제 |
| 일부 열 생략과 NULL 입력 | 본문 7절, 워크북 5절 |
| `IN`과 괄호 | 본문 10절 |
| `LIKE`, `ILIKE` | 본문 11절 |
| `IS NULL`, `IS NOT NULL` | 본문 12절 |
| `LIMIT`, `NULLS LAST` | 본문 13절 |
| 영향받은 행 수 확인 | UPDATE·DELETE 절 |
| AI SQL의 타입·NULL·논리 검토 | 본문 17절 |
| 초기화 전용 파일 | `reset_students.sql` |

---

## 3. 기존 내용에서 축소한 부분

| 항목 | 처리 |
| --- | --- |
| 관계형 데이터베이스 기본 개념 반복 | Chapter 02 연결 수준으로 축소 |
| DDL·DML·DCL·TCL 분류 | 참고 수준으로 축소 |
| 본문과 워크북의 동일 설명 반복 | 실행 결과 예측·기록 활동으로 전환 |
| 제약조건 오류 실습 | Chapter 06으로 이동 |
| 고급 트랜잭션과 삭제 정책 | Chapter 09·11 범위로 유지 |

---

## 4. SQL 파일 안전성 개선

### 기존 방식

`basic_crud.sql`의 첫 구문이 다음과 같았습니다.

```sql
DROP TABLE IF EXISTS students;
```

파일 전체를 실행할 때 기존 데이터가 자동으로 삭제되는 위험이 있었습니다.

### 변경 방식

```text
basic_crud.sql
- 자동 DROP 제거
- 구간별 선택 실행
- 현재 DB·스키마 확인 추가
- NULL, IN, LIKE, LIMIT, RETURNING 추가

reset_students.sql
- 초기화가 필요할 때만 별도 실행
- DROP 실행 전 현재 DB·스키마 확인
```

이 변경을 통해 기본 실습과 파괴적 초기화 작업을 분리했습니다.

---

## 5. 샘플 데이터 통일

본문, 워크북과 SQL 파일은 다음 6명을 공통으로 사용합니다.

| 이름 | 이메일 | 전공 | 학년 |
| --- | --- | --- | ---: |
| 김민지 | minji@example.com | 컴퓨터공학 | 2 |
| 이준호 | junho@example.com | 데이터사이언스 | 3 |
| 박서연 | seoyeon@example.com | 경영학 | 1 |
| 최현우 | hyunwoo@example.com | 컴퓨터공학 | 4 |
| 정하늘 | haneul@example.com | AI데이터공학 | 2 |
| 윤서진 | seojin@example.com | NULL | NULL |

윤서진 행은 NULL 조회 실습을 위해 사용합니다.

---

## 6. 워크북 변경

기존 `Chapter 04 실습 자료` 명칭을 `Chapter 04 독자 워크북`으로 통일했습니다.

다음 활동을 강화했습니다.

```text
- 현재 DB·스키마 기록
- CREATE TABLE 구조 읽기
- INSERT 자동 생성값 예상
- SELECT 반환 열·행 예상
- AND·OR·IN 비교
- LIKE 패턴 해석
- NULL 조회 비교
- ORDER BY·LIMIT 결과 확인
- UPDATE·DELETE 영향받은 행 수 기록
- AI SQL 문제와 수정 SQL 작성
- 초기화 파일 실행 전 안전 점검
```

---

## 7. 도식 정합성

기존 SVG 8개는 유지했습니다.

본문에서 INSERT가 SELECT보다 먼저 등장하므로 다음 그림 연결 순서를 조정했습니다.

```text
그림 4-2 → ch04_03_insert_row_flow.svg
그림 4-3 → ch04_02_select_projection_flow.svg
```

NULL, IN, LIKE, LIMIT과 RETURNING은 별도 도식을 추가하지 않고 SQL 코드와 표로 설명했습니다.

---

## 8. 후속 장 연결

| 내용 | 후속 장 |
| --- | --- |
| 상세 제약조건과 오류 검증 | Chapter 06 |
| JOIN과 집계 | Chapter 08 |
| 트랜잭션으로 변경 보호 | Chapter 09 |
| AI SQL 상세 검증 | Chapter 13 |
| SQL 분석과 Python 확장 | Chapter 14 |

---

## 9. 최종 상태

| 항목 | 상태 |
| --- | --- |
| 본문 22절 재구성 | 완료 |
| 워크북 재구성 | 완료 |
| 구성안 갱신 | 완료 |
| `IDENTITY` 적용 | 완료 |
| NULL·IN·LIKE·LIMIT 추가 | 완료 |
| `RETURNING` 선택 기능 추가 | 완료 |
| 기본 SQL 자동 DROP 제거 | 완료 |
| `reset_students.sql` 분리 | 완료 |
| 코드 README 갱신 | 완료 |
| 이미지 README 갱신 | 완료 |
| Chapter 04 상태 갱신 | 완료 |

## 결론

```text
Chapter 04는 단순 CRUD 문법 장에서
첫 테이블 생성과 SQL 결과 검증 습관을 함께 익히는 장으로 전환되었다.
```

실제 PostgreSQL 실행, DBeaver 영향 행 수 표시와 Word/PDF/eBook의 SVG 렌더링은 최종 제작 환경에서 추가 확인이 필요합니다.
