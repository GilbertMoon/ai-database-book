# Chapter 02 이미지·도식 관리

## 발표 및 본문 사용 도식

| 파일 | 목적 | 상태 |
| --- | --- | --- |
| `ch02_02_table_row_column.svg` | 테이블·행·열·셀 | 수정, 발표·본문 사용 |
| `ch02_03_primary_key_concept.svg` | 기본키가 행을 구분 | 재사용 |
| `ch02_04_foreign_key_relationship.svg` | 정확한 PK·FK 참조 | 재사용 |
| `ch02_05_relationship_types.svg` | 1:1·1:N·N:M | 재사용 |
| `ch02_08_ai_table_review.svg` | AI 구조 검토 다섯 질문 | 전면 교체 |
| `ch02_09_client_dbms_flow.svg` | 사용자·클라이언트·DBMS 요청/응답 | 발표용 추가 |
| `ch02_10_postgresql_hierarchy.svg` | 서버·DB·스키마·객체·테이블·행/열 | 발표용 추가 |
| `ch02_11_table_vs_query_result.svg` | 원본 테이블과 조회 결과 비교 | 발표용 추가 |

## 미사용 보관

`ch02_01_dbms_hierarchy.svg`는 스키마 단계가 없어 사용하지 않는다. `ch02_06_crud_flow.svg`와 `ch02_07_constraints_guardrail.svg`는 현재 Chapter 02 범위보다 상세하여 사용하지 않는다.

## 변경 내용

### 테이블·행·열·셀

굵은 외곽선으로 테이블 전체를 표시하고, 가로 전체 행과 세로 전체 열, 하나의 교차 셀을 분리했다. 1~4 번호를 추가했으며 실선, 긴 점선, 짧은 점선, 굵은 선으로 색 이외의 구분 수단을 제공한다.

### AI 구조 검토

기존 8단계 실행 흐름을 제거하고 다음 다섯 질문으로 통일했다.

1. 한 행의 의미
2. 기본키
3. 다른 행 참조
4. 데이터 혼합
5. 타입과 필수 여부

## 접근성 및 렌더링 기준

사용 SVG는 `role="img"`, `title`, `desc`를 포함한다. 1280×720 발표 화면에서 하나의 큰 이미지로 사용하며 연결선, 번호, 라벨로 의미를 구분한다.
