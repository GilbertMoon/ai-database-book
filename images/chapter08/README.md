# Chapter 08 이미지/도식 설계

## Chapter 08. JOIN과 집계로 서비스 질문에 답하기

이 문서는 Chapter 08의 Mermaid·SVG 자산 역할과 현재 본문 정합성 기준을 정리합니다.

## 공통 원칙

```text
- JOIN을 문법이 아니라 PK·FK 관계 경로로 설명한다.
- 결과 한 행의 기준과 포함 범위를 먼저 보여 준다.
- 전체 SQL과 대형 결과표를 SVG에 반복하지 않는다.
- Chapter 07 최종 데이터와 충돌하는 고정 행 수·이름은 현재 본문에서 사용하지 않는다.
- 금액은 실제 결제·매출이 아니라 enrollments.recorded_amount의 기록 금액으로 표현한다.
- title, desc, role="img", aria-labelledby를 유지한다.
```

## 도식 목록

| 파일 | 제목 | 현재 본문 사용 |
| --- | --- | --- |
| `ch08_01_join_why_needed.svg` | 정규화된 테이블에 JOIN이 필요한 이유 | 사용 |
| `ch08_02_inner_join_concept.svg` | INNER JOIN은 일치하는 행만 포함한다 | 자산 유지, 본문 미사용 |
| `ch08_03_multi_table_join_path.svg` | 수강신청 현황을 만드는 다중 JOIN 경로 | 사용 |
| `ch08_04_left_join_null_rows.svg` | LEFT JOIN은 왼쪽 행을 모두 유지한다 | 자산 유지, 본문 미사용 |
| `ch08_05_group_by_aggregation_flow.svg` | GROUP BY로 상태별 행 묶기 | 자산 유지, 본문 미사용 |
| `ch08_06_course_revenue_summary.svg` | 강의별 신청 건수와 기록 금액 집계 | 자산 유지, 본문 미사용 |
| `ch08_07_where_group_having_order.svg` | 집계 쿼리의 논리적 처리 흐름 | 사용 |
| `ch08_08_ai_join_sql_review_flow.svg` | AI 생성 JOIN·집계 SQL 검토 흐름 | 사용 |

`ch08_06_course_revenue_summary`의 파일명은 기존 링크·자산 호환을 위해 유지하지만, 현재 도식의 SQL·표현은 `recorded_amount`와 **기록 금액**을 사용합니다. 파일명만으로 실제 회계 매출을 의미하지 않습니다.

## 본문 그림 순서

```text
그림 8-1 JOIN이 필요한 이유
그림 8-2 다중 JOIN 경로
그림 8-3 WHERE·GROUP BY·HAVING 논리 흐름
그림 8-4 AI SQL 검토 흐름
```

## 현재 데이터 기준

```text
course_project.students = 3
course_project.instructors = 2
course_project.courses = 3
course_project.enrollments = 5

상태 = 신청 2 / 수강중 1 / 완료 1 / 취소 1
전체 신청 이력 = 5 / recorded_amount 590000
활성 신청 = 3 / recorded_amount 340000
취소 제외 신청 이력 = 4 / recorded_amount 440000
취소 신청 = 1 / recorded_amount 150000
```

현재 본문에서 사용하지 않는 일부 기존 자산에는 과거 실습 데이터 구성이 남아 있을 수 있습니다.

```text
최현우 학생
집계 쿼리 실습 강의
students 4 / instructors 3 / courses 4
수강중 2 / 완료 1 / 신청 2
LEFT JOIN 결과 6행
```

이 자산들은 변경 이력과 호환성을 위해 보존하되, **현재 본문의 기준값 설명에는 사용하지 않습니다.** 현재 본문에서 사용하는 01·03·07·08 자산은 Chapter 08의 현재 관계·흐름과 맞춰 관리합니다.

## Mermaid 원본과 SVG

모든 SVG에는 같은 이름의 `.mmd` 원본이 있습니다. `paid_amount` 구용어는 Chapter 08의 Mermaid·SVG 전체에서 제거하고 `recorded_amount`로 통일합니다.

## 검수 기준

```text
- Mermaid 8개 / SVG 8개 파일 쌍 유지
- XML 파싱 가능
- width="100%"와 viewBox 유지
- role="img", title, desc 유지
- 외부 CSS·JS·웹폰트·foreignObject 미사용
- paid_amount 구용어 없음
- PK·FK 경로가 본문과 일치
- 그림 번호와 캡션이 현재 본문 순서와 일치
- GitHub·브라우저·Word·PDF·eBook 실제 렌더링은 수동 확인
```
