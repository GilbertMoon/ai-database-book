# Chapter 06 이미지/도식 설계

## Chapter 06. 정규화와 좋은 테이블 설계

이 문서는 Chapter 06 본문과 활동 자료에 삽입할 도식 후보를 정리한 이미지 설계 문서입니다.

Chapter 06은 나쁜 테이블 구조를 좋은 구조로 개선하는 장이므로, 도식은 **데이터 중복, 이상 현상, 1NF/2NF/3NF, 정규화 전후 비교, 테이블 분리 흐름, AI 생성 테이블 구조 검토**를 한눈에 이해할 수 있도록 구성합니다.

---

## 1. 도식 설계 원칙

```text
- 정규화 전 한 테이블 구조의 문제를 시각화한다.
- 데이터 중복이 삽입/수정/삭제 이상으로 이어지는 흐름을 보여 준다.
- 1NF, 2NF, 3NF를 초급자 기준으로 단순하게 표현한다.
- 도서 대여 시스템의 library_records를 members, books, loans로 나누는 흐름을 보여 준다.
- 정규화 후 JOIN이 필요하지만 데이터 일관성이 좋아진다는 점을 표현한다.
- AI가 만든 테이블 구조를 정규화 기준으로 검토하는 흐름을 포함한다.
```

---

## 2. 도식 목록

| 번호 | 파일명 | 도식 제목 | 삽입 위치 | 목적 | 우선순위 |
| --- | --- | --- | --- | --- | --- |
| 그림 6-1 | `ch06_01_normalization_problem_overview.svg` | 정규화가 필요한 이유 | 1장 왜 정규화를 배워야 하는가 | 한 테이블 구조의 중복 문제 설명 | 높음 |
| 그림 6-2 | `ch06_02_anomaly_types.svg` | 삽입·수정·삭제 이상 | 3장 이상 현상 이해하기 | 이상 현상 3종 비교 | 높음 |
| 그림 6-3 | `ch06_03_first_normal_form.svg` | 1정규형: 반복값 분리 | 8장 1정규형 | 한 칸의 여러 값을 여러 행으로 나누는 과정 설명 | 높음 |
| 그림 6-4 | `ch06_04_second_normal_form.svg` | 2정규형: 일부 키 의존 분리 | 9장 2정규형 | student/course 예제 분리 흐름 설명 | 중간 |
| 그림 6-5 | `ch06_05_third_normal_form.svg` | 3정규형: 일반 컬럼 의존 분리 | 10장 3정규형 | zip_code와 city 분리 흐름 설명 | 중간 |
| 그림 6-6 | `ch06_06_library_normalization_flow.svg` | 도서 대여 테이블 정규화 | 11장 도서 대여 시스템 정규화하기 | library_records를 3개 테이블로 분리 | 높음 |
| 그림 6-7 | `ch06_07_before_after_join_tradeoff.svg` | 정규화 전후 비교와 JOIN | 13장 정규화 전후 비교 | 중복 감소와 JOIN 필요성 비교 | 높음 |
| 그림 6-8 | `ch06_08_ai_normalization_review_flow.svg` | AI 생성 테이블 구조 검토 | 15장 AI가 만든 테이블 구조 검토하기 | AI 초안을 정규화 기준으로 검토 | 높음 |

---

## 3. 본문 삽입 권장 위치

| 그림 | 삽입 권장 위치 |
| --- | --- |
| 그림 6-1 | 1. 왜 정규화를 배워야 하는가 |
| 그림 6-2 | 3. 이상 현상 이해하기 |
| 그림 6-3 | 8. 1정규형 |
| 그림 6-4 | 9. 2정규형 |
| 그림 6-5 | 10. 3정규형 |
| 그림 6-6 | 11. 도서 대여 시스템 정규화하기 |
| 그림 6-7 | 13. 정규화 전후 비교 |
| 그림 6-8 | 15. AI가 만든 테이블 구조 검토하기 |

---

## 4. Mermaid 원본 파일 계획

| Mermaid 파일 | 대상 이미지 |
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

## 5. 도식 제작 후 점검 항목

```text
- 정규화 전 테이블의 중복 문제가 분명히 보이는가?
- 삽입/수정/삭제 이상이 서로 구분되는가?
- 1NF, 2NF, 3NF가 초급자에게 과도하게 어렵지 않은가?
- library_records가 members, books, loans로 분리되는 흐름이 명확한가?
- 정규화 후 JOIN이 필요한 이유와 장점이 함께 설명되는가?
- AI 생성 테이블 구조 검토 흐름에 중복, 이상 현상, 테이블 분리, 외래키 검토가 포함되는가?
```

---

## 6. 현재 상태 및 다음 작업

```text
- Chapter 06 도식 후보 8종 정리 완료
- 다음 작업: Chapter 06 Mermaid 도식 원본 8종 작성
```
