# Chapter 06 이미지/도식 설계

## Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기

각 SVG는 상세 표와 전체 SQL을 반복하지 않고 정규화 과정의 하나의 핵심 질문에 답하도록 구성합니다. 데이터 무결성 제약조건과 오류 테스트는 SQL 코드와 표가 더 적합하므로 별도 SVG를 추가하지 않습니다.

## 도식 목록

| 번호 | 파일 | 제목 | 핵심 역할 |
| --- | --- | --- | --- |
| 그림 6-1 | `ch06_01_normalization_problem_overview.svg` | 중복 저장이 만드는 정규화 문제 | 같은 사실의 반복이 불일치 위험으로 이어지는 이유 |
| 그림 6-2 | `ch06_02_anomaly_types.svg` | 삽입·수정·삭제 이상 현상 | 세 이상 현상의 차이 |
| 그림 6-3 | `ch06_03_first_normal_form.svg` | 제1정규형: 한 셀에 하나의 값 | 다중값 셀과 반복 열 문제 |
| 그림 6-4 | `ch06_04_second_normal_form.svg` | 제2정규형: 복합키 일부 의존 분리 | 부분 종속 컬럼의 주인 분리 |
| 그림 6-5 | `ch06_05_third_normal_form.svg` | 제3정규형: 일반 컬럼 간 의존 분리 | 일반 컬럼의 결정 관계 분리 |
| 그림 6-6 | `ch06_06_library_normalization_flow.svg` | 도서 대여 테이블 정규화 흐름 | 회원·도서·대여 사실을 별도 테이블로 분리 |
| 그림 6-7 | `ch06_07_before_after_join_tradeoff.svg` | 정규화된 저장과 JOIN 조회 | 저장 구조와 조회 결과의 역할 구분 |
| 그림 6-8 | `ch06_08_ai_normalization_review_flow.svg` | AI 생성 테이블 구조 정규화 검토 | AI 초안의 구조 검토와 반복 검증 |

## Mermaid 원본과 SVG 결과물

| Mermaid | SVG |
| --- | --- |
| `ch06_01_normalization_problem_overview.mmd` | `ch06_01_normalization_problem_overview.svg` |
| `ch06_02_anomaly_types.mmd` | `ch06_02_anomaly_types.svg` |
| `ch06_03_first_normal_form.mmd` | `ch06_03_first_normal_form.svg` |
| `ch06_04_second_normal_form.mmd` | `ch06_04_second_normal_form.svg` |
| `ch06_05_third_normal_form.mmd` | `ch06_05_third_normal_form.svg` |
| `ch06_06_library_normalization_flow.mmd` | `ch06_06_library_normalization_flow.svg` |
| `ch06_07_before_after_join_tradeoff.mmd` | `ch06_07_before_after_join_tradeoff.svg` |
| `ch06_08_ai_normalization_review_flow.mmd` | `ch06_08_ai_normalization_review_flow.svg` |

## 공통 SVG 기준

```text
- 표준 SVG, 흰색 배경, width="100%", 적절한 viewBox
- title, desc, role="img", aria-labelledby 포함
- 외부 CSS·JavaScript·웹폰트·raster 이미지·foreignObject 미사용
- 안전한 한글 및 코드 폰트 스택 사용
- 핵심 글자 12px 이상
- PK·FK는 텍스트와 색상으로 함께 구분
- SVG 내부 전체 SQL과 대형 표 제거
- XML 들여쓰기와 유지보수 가능한 구조 유지
```

## 2차 재구성 정합성 기준

- 정규화 전 개념 구조는 `library_records_raw`이다.
- 정규화 후 실습 구조는 `members_nf`, `books_nf`, `loans_nf`이다.
- 원시 데이터는 3행, 정규화 후 회원 2명·도서 2건·대여 3건이다.
- `returned_at`은 NULL을 허용한다.
- 외래키는 `loans_nf.member_id → members_nf.id`, `loans_nf.book_id → books_nf.id`이다.
- 정규화 도식은 일반 개념을 설명하므로 `_nf` 접미사를 모든 이미지에 강제하지 않는다.
- 무결성 제약조건, 오류 SQL과 삭제 정책은 본문 표와 코드 파일에서 설명한다.
- 정규화와 운영 데이터 마이그레이션을 구분한다.
- BCNF 이상, 인덱스, 잠금과 성능 기반 반정규화는 도식 범위에서 제외한다.

## 현재 상태

```text
- Mermaid 원본 8종 유지
- SVG 8종 유지
- 새 Chapter 제목과 본문 역할 반영
- 정규화 핵심 도식과 무결성 SQL 역할 분리
- 기존 SVG XML·접근성 검증 결과 유지
- Mermaid CLI 문법 검증은 실행 환경에 CLI가 없어 미실행
- GitHub·Word·PDF·eBook 실제 렌더링은 수동 확인 필요
```
