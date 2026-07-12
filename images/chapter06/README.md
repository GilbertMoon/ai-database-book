# Chapter 06 이미지/도식 설계

## Chapter 06. 정규화와 좋은 테이블 설계

각 SVG는 상세 표와 전체 SQL을 반복하지 않고 하나의 핵심 질문에 답하도록 구성합니다.

## 도식 목록

| 번호 | 파일 | 제목 | 핵심 역할 |
| --- | --- | --- | --- |
| 그림 6-1 | `ch06_01_normalization_problem_overview.svg` | 중복 저장이 만드는 정규화 문제 | 반복 저장이 왜 불일치와 정규화 필요성으로 이어지는가 |
| 그림 6-2 | `ch06_02_anomaly_types.svg` | 삽입·수정·삭제 이상 현상 | 세 이상 현상의 차이 |
| 그림 6-3 | `ch06_03_first_normal_form.svg` | 1정규형: 한 셀에 하나의 값 | 다중값 셀을 행으로 분리 |
| 그림 6-4 | `ch06_04_second_normal_form.svg` | 2정규형: 복합키 일부 의존 분리 | 부분 종속 컬럼의 주인 분리 |
| 그림 6-5 | `ch06_05_third_normal_form.svg` | 3정규형: 비키 컬럼 간 의존 분리 | 비키 결정 관계 분리 |
| 그림 6-6 | `ch06_06_library_normalization_flow.svg` | 도서 대여 테이블 정규화 흐름 | 세 업무 사실을 members·books·loans로 분리 |
| 그림 6-7 | `ch06_07_before_after_join_tradeoff.svg` | 정규화된 저장과 JOIN 조회 | 저장과 조회의 역할 구분 |
| 그림 6-8 | `ch06_08_ai_normalization_review_flow.svg` | AI 생성 테이블 구조 정규화 검토 | AI 초안의 반복 검증 흐름 |

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

## 정합성 기준

- 정규화 전: `library_records` 3행
- 정규화 후: `members` 2행, `books` 2행, `loans` 3행
- `returned_at` NULL 허용
- `members.email`, `books.isbn` UNIQUE 유지
- `loans.member_id → members.id`, `loans.book_id → books.id`
- 정규화와 운영 데이터 마이그레이션을 구분

## 현재 상태

```text
- Mermaid 원본 8종 단순화 완료
- SVG 8종 단순화 완료
- 본문 alt text와 캡션 갱신 완료
- SVG XML 파싱 완료
- Mermaid CLI 문법 검증은 실행 환경에 CLI가 없어 미실행
- GitHub·Word·PDF·eBook 실제 렌더링은 수동 확인 필요
```
