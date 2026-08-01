# Chapter 05 이미지·도식 관리

## Chapter 05. 요구사항에서 데이터 모델과 ERD 만들기

이 문서는 Chapter 05 본문에 사용하는 Mermaid 원본과 SVG 결과물의 역할을 정리합니다. 도식은 ERD 기호를 장식적으로 보여 주기보다 엔터티·사건 구분, 관계 방향, N:M 해소와 검토 흐름을 설명하는 데 사용합니다.

---

## 1. 도식 설계 원칙

```text
Markdown 표
→ 요구사항, 한 행 의미, 추적표, 검증 시나리오

텍스트 블록
→ 관계 문장, 텍스트 ERD, 범위 가정

SVG
→ 엔터티·사건 구분, 관계 방향, N:M 해소, ERD, 검토 흐름

Mermaid
→ SVG의 의미적 원본
```

공통 SVG 기준:

```text
width="100%"와 viewBox 사용
title·desc·role="img"·aria-labelledby 포함
외부 CSS·웹폰트·JavaScript·raster 이미지 미사용
긴 요구사항 표와 전체 SQL 미삽입
기호만 제시하지 않고 자연어 설명과 함께 사용
```

---

## 2. 본문 사용 도식

| 본문 번호 | 파일 | 제목 | 역할 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 5-1 | `ch05_02_entity_attribute_classification.svg` | 엔터티·속성·사건 구분하기 | 회원·도서·대여 사건과 속성 구분 | 사용 |
| 그림 5-2 | `ch05_04_one_to_many_relationship.svg` | 1:N 관계와 외래키 위치 | N쪽 `loans`에 FK가 위치하는 이유 | 사용 |
| 그림 5-3 | `ch05_05_many_to_many_bridge_table.svg` | N:M 관계를 사건 테이블로 풀기 | 회원·도서 N:M을 두 개의 1:N으로 변환 | 사용 |
| 그림 5-4 | `ch05_06_library_erd_overview.svg` | 도서 대여 시스템 핵심 ERD | 한 행 의미·PK·FK·카디널리티 확인 | 사용 |
| 그림 5-5 | `ch05_07_erd_to_sql_flow.svg` | ERD를 PostgreSQL 구조로 변환하기 | 엔터티·속성·관계를 테이블·열·FK로 연결 | 사용 |
| 그림 5-6 | `ch05_08_ai_erd_review_flow.svg` | AI 생성 ERD 검토 흐름 | 요구사항 근거·가정·시나리오 검토 | 사용 |

기존 SVG 파일명은 유지하고 본문 등장 순서에 따라 그림 번호를 부여합니다.

---

## 3. 본문 미사용 보관 도식

| 파일 | 기존 역할 | 현재 상태 |
| --- | --- | --- |
| `ch05_01_modeling_process.svg` | 요구사항에서 SQL 검증까지 전체 흐름 | 본문 텍스트 흐름으로 대체·보관 |
| `ch05_03_primary_foreign_key_relationship.svg` | PK와 FK 참조 방향 | 1:N 도식과 본문 표로 통합·보관 |

삭제 여부는 전체 이미지 자산 정리 단계에서 결정합니다.

---

## 4. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 | 현재 사용 |
| --- | --- | --- |
| `ch05_01_modeling_process.mmd` | `ch05_01_modeling_process.svg` | 보관 |
| `ch05_02_entity_attribute_classification.mmd` | `ch05_02_entity_attribute_classification.svg` | 사용 |
| `ch05_03_primary_foreign_key_relationship.mmd` | `ch05_03_primary_foreign_key_relationship.svg` | 보관 |
| `ch05_04_one_to_many_relationship.mmd` | `ch05_04_one_to_many_relationship.svg` | 사용 |
| `ch05_05_many_to_many_bridge_table.mmd` | `ch05_05_many_to_many_bridge_table.svg` | 사용 |
| `ch05_06_library_erd_overview.mmd` | `ch05_06_library_erd_overview.svg` | 사용 |
| `ch05_07_erd_to_sql_flow.mmd` | `ch05_07_erd_to_sql_flow.svg` | 사용 |
| `ch05_08_ai_erd_review_flow.mmd` | `ch05_08_ai_erd_review_flow.svg` | 사용 |

---

## 5. 도식별 편집 기준

### 그림 5-1 엔터티·속성·사건

```text
회원·도서
→ 독립 관리 대상

대여 기록
→ 시간에 따라 반복되는 사건

이메일·ISBN·날짜
→ 대상을 설명하는 속성
```

### 그림 5-2 1:N 관계

```text
members 1 : N loans
books   1 : N loans
```

외래키가 N쪽에 위치하는 이유를 보여 줍니다. 부모의 관계 최소값은 0일 수 있고 대여 행의 부모 참조는 필수임을 본문 관계 문장과 함께 해석합니다.

### 그림 5-3 N:M 해소

```text
members N : M books
→ members 1 : N loans N : 1 books
```

`loans`가 단순 연결뿐 아니라 대여 날짜와 반납 상태를 가진 사건 테이블임을 표현합니다.

### 그림 5-4 핵심 ERD

다음 정보를 표시합니다.

```text
members·books·loans
PK·FK
0..N과 1 관계
returned_at 선택값
이메일·ISBN 고유성 미확정
```

도서 제목·판본·실제 복본을 완전히 분리한 모델처럼 보이지 않도록 범위 설명과 함께 사용합니다.

### 그림 5-5 ERD에서 SQL

```text
엔터티 → 테이블
속성 → 열
식별자 → PK
1:N → N쪽 FK
필수 속성 → NOT NULL 후보
```

`UNIQUE`, `CHECK`와 삭제 정책은 요구사항이 확정된 경우에만 후보가 된다는 점을 유지합니다.

### 그림 5-6 AI 검토

기존의 긴 검토 목록 대신 다음 핵심 흐름을 지원합니다.

```text
요구사항 근거
→ 한 행 의미
→ 관계·카디널리티
→ 미확정 정책
→ 작은 시나리오
→ 수정·재검증
```

---

## 6. 표현 원칙

다음 표현을 사용합니다.

```text
테이블별 한 행 의미
업무 사실·규칙·미확정 질문
양방향 관계 문장
카디널리티와 선택성
사건·업무 테이블
요구사항 추적표
정상 검증 시나리오
```

다음 오해를 만들지 않습니다.

```text
ERD 기호만으로 업무 규칙이 모두 구현됨
1:N 관계가 동시 활성 대여까지 차단함
샘플 이메일·ISBN이 다르므로 UNIQUE가 확정됨
books 한 행이 제목·판본·복본을 모두 엄밀히 나타냄
AI가 만든 ERD가 요구사항의 정답임
```

---

## 7. 변환 시 점검

```text
Word·PDF·eBook 변환 후 Crow’s Foot 기호가 식별되는가?
PK·FK 글자가 너무 작지 않은가?
관계선이 테이블 경계와 겹치지 않는가?
0..N과 1 방향이 본문 문장과 일치하는가?
한글이 깨지지 않는가?
모바일 폭에서도 표와 그림이 읽히는가?
```

외부 폰트 파일은 저장소에 추가하지 않습니다.
