# Chapter 04 이미지/도식 설계

## Chapter 04. 관계형 데이터베이스와 SQL 기초

이 문서는 Chapter 04 본문에 삽입한 Mermaid 원본과 SVG 결과물을 관리하기 위한 이미지 설계 문서입니다.

Chapter 04 도식은 SQL 문법 전체를 이미지로 반복하지 않고, **행과 열의 변화, 필터링, 정렬, 안전 실행 흐름, AI SQL 검토 흐름**을 보여 주는 보조 자료로 사용합니다.

---

## 1. 도식 설계 원칙

```text
- Markdown 표: 정의, 비교, 연산자, 검토 항목, 실행 순서
- SQL 코드 블록: 실제 실행할 SQL과 올바른 문법
- SVG: 행과 열의 변화, 필터링, 정렬, 안전 실행 흐름
- Mermaid: SVG의 의미적·구조적 원본
```

공통 SVG 기준은 다음과 같습니다.

```text
- width="100%"와 viewBox를 사용한다.
- title, desc, role="img", aria-labelledby를 포함한다.
- 외부 CSS, 웹폰트, JavaScript, raster 이미지를 사용하지 않는다.
- foreignObject, emoji, 장식용 아이콘을 사용하지 않는다.
- SVG 안에 대형 비교표, 전체 SQL 스크립트, 고급 트랜잭션·FK 삭제 정책을 넣지 않는다.
```

---

## 2. 도식 목록

| 번호 | 파일 | 제목 | 단순화된 목적 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 4-1 | `ch04_01_sql_crud_overview.svg` | SQL DML 명령어와 CRUD 대응 | INSERT, SELECT, UPDATE, DELETE와 CRUD 연결 | 보정 완료 |
| 그림 4-2 | `ch04_02_select_projection_flow.svg` | SELECT로 필요한 컬럼 선택하기 | SELECT 목록이 결과 컬럼과 순서를 정하는 과정 | 보정 완료 |
| 그림 4-3 | `ch04_03_insert_row_flow.svg` | INSERT로 새 행 추가하기 | 컬럼과 값 대응 후 새 행 추가 | 보정 완료 |
| 그림 4-4 | `ch04_04_where_filter_flow.svg` | WHERE 조건으로 대상 행 필터링하기 | 조건이 참인 행만 결과에 포함되는 흐름 | 보정 완료 |
| 그림 4-5 | `ch04_05_order_by_sort_flow.svg` | ORDER BY로 조회 결과 정렬하기 | ASC와 DESC의 표시 순서 차이 | 보정 완료 |
| 그림 4-6 | `ch04_06_update_safe_flow.svg` | 안전한 UPDATE 실행 절차 | SELECT → UPDATE → SELECT 확인 절차 | 보정 완료 |
| 그림 4-7 | `ch04_07_delete_safe_flow.svg` | 안전한 DELETE 실행 절차 | SELECT → DELETE → SELECT 확인 절차 | 보정 완료 |
| 그림 4-8 | `ch04_08_ai_sql_review_flow.svg` | AI 생성 SQL 검토 흐름 | AI SQL의 대상과 영향 범위 검토 순서 | 보정 완료 |

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

---

## 4. 검증 상태

| 항목 | 상태 |
| --- | --- |
| Mermaid와 SVG의 핵심 노드 및 흐름 일치 | 완료 |
| SVG 접근성 요소 포함 | 완료 |
| SVG XML 파싱 | 완료 |
| GitHub 렌더링 기준 검토 | 완료 |
| 본문 그림 번호와 캡션 정합성 | 완료 |
| Chapter 04 범위를 넘는 고급 내용 제거 | 완료 |

---

## 5. 변환 시 점검

```text
- Word/PDF/eBook 변환 과정에서 SVG가 PNG로 변환되면 한글, 화살표, 박스 여백을 확인한다.
- PNG가 흐리거나 한글이 깨지면 SVG 글자 크기와 폰트 스택을 보정한다.
- 외부 font 파일을 저장소에 추가하지 않는다.
```
