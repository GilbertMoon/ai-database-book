# Chapter 04 이미지·도식 관리

## Chapter 04. 관계형 데이터베이스와 SQL 시작하기

이 문서는 Chapter 04 본문에 사용하는 Mermaid 원본과 SVG 결과물을 관리합니다.

Chapter 04 도식은 SQL 전체 코드를 이미지로 반복하지 않고 다음 흐름을 시각적으로 보조합니다.

```text
CRUD 연결
행과 열의 변화
조건 필터링
결과 정렬
안전한 수정·삭제
AI SQL 영향 범위 검토
```

---

## 1. 도식 설계 원칙

```text
Markdown 표
→ 데이터 타입, 연산자, 상태와 검토 항목

SQL 코드 블록
→ 실제 실행 문법과 선택·심화 예제

SVG
→ 데이터 변화, 필터링, 정렬과 안전 실행 흐름

Mermaid
→ SVG의 의미적 원본
```

공통 SVG 기준:

```text
width="100%"와 viewBox 사용
title·desc·role="img"·aria-labelledby 포함
외부 CSS·웹폰트·JavaScript·raster 이미지 미사용
foreignObject·emoji·장식용 아이콘 미사용
전체 SQL·대형 표·고급 내부 동작 미삽입
```

---

## 2. 본문 사용 도식

| 본문 번호 | 파일 | 제목 | 역할 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 4-1 | `ch04_01_sql_crud_overview.svg` | SQL 명령어와 CRUD 대응 | INSERT·SELECT·UPDATE·DELETE 연결 | 유지 |
| 그림 4-2 | `ch04_03_insert_row_flow.svg` | INSERT로 새 행 추가하기 | 열과 값, 자동값과 RETURNING 확인 | 유지 |
| 그림 4-3 | `ch04_02_select_projection_flow.svg` | SELECT로 필요한 열 선택하기 | 결과 열 선택 | 유지 |
| 그림 4-4 | `ch04_04_where_filter_flow.svg` | WHERE 조건으로 대상 행 필터링하기 | 참인 행 선택 | 유지 |
| 그림 4-5 | `ch04_05_order_by_sort_flow.svg` | ORDER BY로 조회 결과 정렬하기 | ASC·DESC 표시 순서 | 유지 |
| 그림 4-6 | `ch04_06_update_safe_flow.svg` | 안전한 UPDATE 실행 절차 | SELECT → UPDATE → 결과 확인 | 유지 |
| 그림 4-7 | `ch04_07_delete_safe_flow.svg` | 안전한 DELETE 실행 절차 | SELECT → DELETE → 결과 확인 | 유지 |
| 그림 4-8 | `ch04_08_ai_sql_review_flow.svg` | AI 생성 SQL 검토 흐름 | 조건과 영향 범위 검토 | 유지 |

기존 SVG 8종은 개편된 17개 절의 핵심 학습 흐름과 일치하므로 새 도식을 추가하지 않습니다.

---

## 3. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch04_01_sql_crud_overview.mmd` | `ch04_01_sql_crud_overview.svg` |
| `ch04_02_select_projection_flow.mmd` | `ch04_02_select_projection_flow.svg` |
| `ch04_03_insert_row_flow.mmd` | `ch04_03_insert_row_flow.svg` |
| `ch04_04_where_filter_flow.mmd` | `ch04_04_where_filter_flow.svg` |
| `ch04_05_order_by_sort_flow.mmd` | `ch04_05_order_by_sort_flow.svg` |
| `ch04_06_update_safe_flow.mmd` | `ch04_06_update_safe_flow.svg` |
| `ch04_07_delete_safe_flow.mmd` | `ch04_07_delete_safe_flow.svg` |
| `ch04_08_ai_sql_review_flow.mmd` | `ch04_08_ai_sql_review_flow.svg` |

파일명 번호와 본문 그림 번호는 일부 다릅니다. 기존 파일명을 유지하면서 본문 등장 순서에 따라 그림 번호를 부여합니다.

---

## 4. 자율 학습형 개편 반영

```text
본문: 23개 절 → 17개 절
실습 상태: 체크포인트 A·B·C → 초기·수정 후·삭제 후 상태
코드: 단일 파일 중심 → 번호 파일 중심
고급 문법: 핵심 본문 → 선택·심화 박스
```

도식은 핵심 SQL 흐름에만 사용합니다. 다음 내용은 코드와 표로 설명합니다.

```text
데이터 타입 분류
CAST와 ::
DISTINCT
ILIKE
NULLS FIRST·NULLS LAST
IS DISTINCT FROM
UUID·JSONB
IDENTITY와 CURRENT_TIMESTAMP 내부 동작
```

번호 SQL 파일은 실행 순서와 상태를 관리하는 자료이며, 도식 안에 파일 구조를 추가해 화면을 복잡하게 만들지 않습니다.

---

## 5. 도식별 확인 기준

### 그림 4-2 INSERT

```text
입력 열과 값 대응
생략한 열의 자동값
성공·실패 구분
RETURNING 결과 확인
```

### 그림 4-5 ORDER BY

```text
정렬이 저장 순서를 바꾸는 것으로 보이지 않는가?
ASC와 DESC가 결과 표시 순서임이 명확한가?
NULLS LAST 같은 선택 문법을 필수 요소로 오해하지 않는가?
```

### 그림 4-6·4-7 변경 SQL

```text
SELECT로 대상 확인
→ 변경 SQL
→ 반환·영향 행 확인
→ SELECT로 실제 상태 확인
```

Auto-commit과 트랜잭션 상세는 본문 텍스트로 설명하고 도식에 과도하게 추가하지 않습니다.

### 그림 4-8 AI 검토

다음 핵심이 드러나야 합니다.

```text
현재 구조 확인
조건과 NULL 검토
예상 영향 행 확인
사전 SELECT
실행 후 실제 결과 비교
```

---

## 6. 검증 상태

| 항목 | 상태 |
| --- | --- |
| Mermaid와 SVG 핵심 흐름 일치 | 완료 |
| SVG 접근성 요소 | 완료 |
| SVG XML 파싱 | 완료 |
| 본문 그림 번호와 캡션 | 개편 후 확인 완료 |
| 17개 절과 그림 등장 순서 | 완료 |
| 선택·심화 문법 과밀 방지 | 완료 |
| 데이터 상태 새 명칭 | 문서 반영 완료 |

---

## 7. 출판 변환 시 점검

```text
Word·PDF·eBook에서 그림 순서가 유지되는가?
SVG가 PNG로 변환될 때 한글과 화살표가 선명한가?
640px 너비에서 글자가 읽히는가?
UPDATE·DELETE의 단계가 잘리지 않는가?
외부 폰트 파일이 추가되지 않았는가?
```
