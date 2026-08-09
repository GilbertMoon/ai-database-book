# Chapter 12 이미지/도식 설계

## Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기

이 문서는 Chapter 12의 Mermaid·SVG 자산과 `nosql_lab` 기반 2차 재구성 기준을 정리합니다.

## 공통 원칙

```text
- NoSQL을 RDBMS의 대체재나 상위 기술로 표현하지 않는다.
- 제품명보다 시스템 역할과 조회 패턴을 먼저 보여 준다.
- 원본·캐시·이벤트·관계 인덱스를 구분한다.
- JSONB를 전용 Document DB와 동일하게 표현하지 않는다.
- Column-Family는 목표 조회·파티션·정렬 키를 함께 보여 준다.
- Graph는 단순 FK 관계와 다단계 탐색을 구분한다.
- title, desc, role="img", aria-labelledby, width="100%", viewBox를 유지한다.
```

## 도식 목록

| 번호 | 파일 | 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 12-1 | `ch12_01_rdbms_vs_nosql_overview.svg` | RDBMS와 NoSQL 역할 나누기 | 원본·조회·운영 기준 비교 |
| 그림 12-2 | `ch12_02_nosql_types_map.svg` | NoSQL 유형 정리 | Key-Value·Document·Column-Family·Graph |
| 그림 12-3 | `ch12_03_key_value_lookup.svg` | Key-Value 조회와 캐시 미스 | 정확한 키·TTL·원본 재조회 |
| 그림 12-4 | `ch12_04_document_json_structure.svg` | Document JSON 구조 | 문서 경계와 포함·참조 판단 |
| 그림 12-5 | `ch12_05_column_family_log_flow.svg` | Column-Family 조회 패턴 | 파티션·정렬 키와 시간 범위 조회 |
| 그림 12-6 | `ch12_06_graph_relationship_search.svg` | Graph 관계 탐색 | 단순 JOIN과 다단계 탐색 비교 |
| 그림 12-7 | `ch12_07_jsonb_practice_flow.svg` | PostgreSQL JSONB 실습 흐름 | 컬럼+JSONB·검증·ROLLBACK·인덱스 |
| 그림 12-8 | `ch12_08_ai_nosql_choice_review.svg` | AI 추천 NoSQL 선택 검토 흐름 | 원본·조회·동기화·운영·PoC 검토 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 2차 재구성 실습 기준

원본 기준:

```text
course_project = 3 / 2 / 3 / 5
recorded_amount = NUMERIC(12,0)
전체 = 590000
활성 = 3 / 340000
취소 제외 = 4 / 440000
```

실습 기준:

```text
nosql_lab.course_documents 3
nosql_lab.key_value_cache_examples 4
nosql_lab.storage_choice_cases 6
유효 캐시 3
만료 캐시 1
```

시스템 역할:

```text
source_of_truth
ephemeral_state
derived_cache
flexible_metadata
event_log
relationship_index
```

## 도식에서 피할 표현

```text
- NoSQL은 항상 RDBMS보다 빠르다.
- NoSQL에는 스키마와 트랜잭션이 없다.
- JSON을 저장하면 무조건 Document DB가 필요하다.
- 로그는 항상 Column-Family DB에 저장한다.
- 관계가 있으면 Graph DB가 필요하다.
- 캐시는 원본 데이터다.
- 여러 저장소에 직접 쓰면 항상 동기화된다.
- CAP는 모든 상황에서 단순히 세 가지 중 두 개만 선택하는 공식이다.
```

## 검수 기준

```text
- 본문 그림 번호 12-1~12-8과 README 순서 일치
- Key-Value 캐시의 Source of Truth가 별도로 표현됨
- 문서형 구조에서 필수 규칙과 유연 속성이 구분됨
- Column-Family 그림에 target query 포함
- Graph 그림에 관계 깊이와 탐색 방향 포함
- JSONB와 전용 Document DB의 차이 표현
- AI 검토 흐름에 동기화·복구·운영 비용 포함
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
