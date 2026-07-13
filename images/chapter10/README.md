# Chapter 10 이미지/도식 설계

## Chapter 10. 인덱스와 성능 기초

이 문서는 Chapter 10 본문과 활동지에 사용하는 Mermaid 원본과 SVG 자산을 정리합니다. 모든 SVG는 `images/SVG_STYLE_GUIDE.md` 기준을 우선 적용합니다.

## 공통 원칙

- 하나의 SVG는 하나의 핵심 메시지만 전달한다.
- 본문 SQL 전체나 실행 계획 전문을 SVG에 넣지 않는다.
- 자동 인덱스와 수동 인덱스를 명확히 구분한다.
- Seq Scan과 Index Scan은 색상뿐 아니라 텍스트로도 구분한다.
- 판단 분기에는 적용, 보류, 제거 또는 예/아니요 라벨을 넣는다.
- 실패하거나 근거가 부족한 경우 이전 검토 단계로 돌아가는 흐름을 표시한다.
- SVG에는 `role`, `aria-labelledby`, `title`, `desc`, `width="100%"`, `viewBox`를 포함한다.

## 도식 목록

| 번호 | 파일 | 제목 |
| --- | --- | --- |
| 그림 10-1 | `ch10_01_index_need_overview.svg` | 데이터 증가와 인덱스 검토 |
| 그림 10-2 | `ch10_02_table_scan_vs_index_scan.svg` | Seq Scan과 Index Scan의 검색 경로 |
| 그림 10-3 | `ch10_03_where_index_candidate.svg` | WHERE 조건에서 인덱스 후보 판단하기 |
| 그림 10-4 | `ch10_04_order_by_index_flow.svg` | ORDER BY에서 인덱스가 사용되는 흐름 |
| 그림 10-5 | `ch10_05_join_foreign_key_index.svg` | JOIN 관계와 외래키 인덱스 후보 |
| 그림 10-6 | `ch10_06_composite_index_order.svg` | 복합 인덱스의 선두 컬럼과 쿼리 조건 |
| 그림 10-7 | `ch10_07_explain_before_after.svg` | 인덱스 전후 실행 계획 비교 |
| 그림 10-8 | `ch10_08_ai_index_review_flow.svg` | AI 추천 인덱스 검토 흐름 |

## 검수 결과 기록

- Mermaid 원본은 한국어 노드로 갱신한다.
- SVG는 접근성 속성을 포함한다.
- XML 파싱과 텍스트 넘침 여부는 최종 검증 단계에서 확인한다.
- 브라우저, GitHub 미리보기, Word/PDF/eBook 변환 결과는 사람이 추가 확인한다.
