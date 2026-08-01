# Chapter 06 이미지/도식 설계

## Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기

Chapter 06 도식은 정규형 정의와 전체 SQL을 이미지로 반복하지 않고, **같은 사실의 중복·이상 현상·열의 주인·정규화 전후 구조**를 설명하는 보조 자료로 사용합니다.

무결성 제약조건, `ALTER TABLE`, 경계·오류 테스트는 SQL 코드와 표가 더 적합하므로 별도 대형 도식을 추가하지 않습니다.

---

## 1. 도식 목록

| 본문 번호 | 파일 | 제목 | 역할 | 상태 |
| --- | --- | --- | --- | --- |
| 그림 6-1 | `ch06_01_normalization_problem_overview.svg` | 중복 저장이 만드는 정규화 문제 | 같은 현재 사실의 복사본이 불일치 위험으로 이어지는 과정 | 유지 |
| 그림 6-2 | `ch06_02_anomaly_types.svg` | 삽입·수정·삭제 이상 현상 | 데이터 변경 시 나타나는 세 구조 문제 | 유지 |
| 그림 6-3 | `ch06_03_first_normal_form.svg` | 제1정규형 | 독립 값을 문자열·반복 열에 섞지 않는 이유 | 유지 |
| 그림 6-4 | `ch06_04_second_normal_form.svg` | 제2정규형 | 복합키 일부에만 의존하는 열 분리 | 유지 |
| 그림 6-5 | `ch06_05_third_normal_form.svg` | 제3정규형 | 일반 열 간 결정 관계 분리 | 유지 |
| 그림 6-6 | `ch06_06_library_normalization_flow.svg` | 도서 대여 구조 정규화 | 회원·도서·대여 사실의 주인 분리 | 유지 |
| 그림 6-7 | `ch06_07_before_after_join_tradeoff.svg` | 정규화된 저장과 조회 결과 | 저장 구조와 JOIN 결과의 역할 구분 | 유지 |
| 그림 6-8 | `ch06_08_ai_normalization_review_flow.svg` | AI 생성 구조 검토 | 구조·규칙·실행 검증의 반복 | 유지 |

---

## 2. Mermaid 원본과 SVG 결과물

| Mermaid 원본 | SVG 결과물 |
| --- | --- |
| `ch06_01_normalization_problem_overview.mmd` | `ch06_01_normalization_problem_overview.svg` |
| `ch06_02_anomaly_types.mmd` | `ch06_02_anomaly_types.svg` |
| `ch06_03_first_normal_form.mmd` | `ch06_03_first_normal_form.svg` |
| `ch06_04_second_normal_form.mmd` | `ch06_04_second_normal_form.svg` |
| `ch06_05_third_normal_form.mmd` | `ch06_05_third_normal_form.svg` |
| `ch06_06_library_normalization_flow.mmd` | `ch06_06_library_normalization_flow.svg` |
| `ch06_07_before_after_join_tradeoff.mmd` | `ch06_07_before_after_join_tradeoff.svg` |
| `ch06_08_ai_normalization_review_flow.mmd` | `ch06_08_ai_normalization_review_flow.svg` |

---

## 3. 개편 후 본문 역할

```text
그림 6-1~6-2
→ 왜 정규화가 필요한가

그림 6-3~6-5
→ 1NF·2NF·3NF에서 무엇을 질문하는가

그림 6-6~6-7
→ 사실의 주인을 분리하고 필요한 결과를 조회로 다시 구성하는 방법

그림 6-8
→ AI가 만든 구조를 요구사항·규칙·실행 결과로 검토하는 흐름
```

다음 내용은 도식보다 SQL과 표로 설명합니다.

```text
PRIMARY KEY·NOT NULL·UNIQUE·CHECK·FOREIGN KEY
CHECK와 UNIQUE의 NULL 처리
ALTER TABLE 전 기존 데이터 검사
부분 고유 인덱스
삭제 정책
정상·경계·오류 테스트
```

---

## 4. 내용 정합성 기준

```text
library_records_raw 한 행
→ 대여 사건과 회원·도서 현재 사실이 혼합

members_nf 한 행
→ 회원 한 명

books_nf 한 행
→ 대여 대상으로 관리하는 도서 한 건

loans_nf 한 행
→ 특정 회원의 특정 도서 대여 사건 한 건
```

샘플 기준:

```text
원시 데이터 3행
회원 2명
도서 2건
대여 3건
미반납 2건
도서 201 대여 이력 2건
활성 대여 중복 0건
```

- 그림 6-3은 JSON·배열을 무조건 1NF 위반으로 단정하지 않는다.
- 그림 6-4는 복합키 일부 의존을 설명한다.
- 그림 6-5는 단순 반복이 아니라 업무상 결정 관계를 설명한다.
- 그림 6-6은 존재하지 않던 속성을 정규화가 만들어 내는 것처럼 표현하지 않는다.
- 그림 6-7은 JOIN이 데이터를 다시 중복 저장하는 작업처럼 보이지 않게 한다.
- 그림 6-8은 AI 결과를 정답이 아니라 검토할 초안으로 표현한다.

---

## 5. 공통 SVG 기준

```text
- 표준 SVG, 흰색 배경, width="100%", 적절한 viewBox
- title, desc, role="img", aria-labelledby 포함
- 외부 CSS·JavaScript·웹폰트·raster 이미지·foreignObject 미사용
- 안전한 한글 및 코드 폰트 스택 사용
- 핵심 글자 12px 이상
- 색상만으로 의미를 구분하지 않음
- SVG 내부 전체 SQL과 대형 표 제거
- 외부 font 파일을 저장소에 추가하지 않음
```

---

## 6. 검증 상태

| 항목 | 상태 |
| --- | --- |
| 기존 Mermaid·SVG 8종 유지 | 완료 |
| 개편된 18개 절과 그림 순서 일치 | 완료 |
| 정규형 설명 범위와 도식 역할 일치 | 완료 |
| SQL·표와 도식의 역할 분리 | 완료 |
| SVG XML·접근성 기존 결과 유지 | 완료 |
| Mermaid CLI 재검증 | 미실행 |
| GitHub 실제 렌더링 | 확인 필요 |
| Word·PDF·eBook 실제 렌더링 | 확인 필요 |

---

## 7. 변환 시 점검

```text
- 1NF·2NF·3NF 도식의 작은 글자가 읽히는지 확인한다.
- SVG가 PNG로 변환될 때 한글과 화살표가 깨지지 않는지 확인한다.
- 그림 6-6의 세 테이블 관계가 명확한지 확인한다.
- 그림 6-7이 저장 구조와 조회 결과를 혼동시키지 않는지 확인한다.
- 그림 6-8의 검토 순환이 본문의 7개 질문과 충돌하지 않는지 확인한다.
```
