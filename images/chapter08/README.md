# Chapter 08 이미지/도식 설계

## Chapter 08. JOIN과 집계로 서비스 질문에 답하기

이 문서는 Chapter 08의 Mermaid·SVG 자산 역할과 2차 재구성 기준을 정리합니다.

## 공통 원칙

```text
- JOIN을 문법이 아니라 PK·FK 관계 경로로 설명한다.
- 결과 한 행의 기준과 포함 범위를 먼저 보여 준다.
- 전체 SQL과 대형 결과표를 SVG에 반복하지 않는다.
- Chapter 07 최종 데이터와 충돌하는 고정 행 수·이름은 새 본문에서 사용하지 않는다.
- title, desc, role="img", aria-labelledby를 유지한다.
```

## 도식 목록

| 파일 | 제목 | 2차 본문 사용 |
| --- | --- | --- |
| `ch08_01_join_why_needed.svg` | 정규화된 테이블에 JOIN이 필요한 이유 | 사용 |
| `ch08_02_inner_join_concept.svg` | INNER JOIN은 일치하는 행만 포함한다 | 자산 유지, 본문 미사용 |
| `ch08_03_multi_table_join_path.svg` | 수강신청 현황을 만드는 다중 JOIN 경로 | 사용 |
| `ch08_04_left_join_null_rows.svg` | LEFT JOIN은 왼쪽 행을 모두 유지한다 | 자산 유지, 본문 미사용 |
| `ch08_05_group_by_aggregation_flow.svg` | GROUP BY로 상태별 행 묶기 | 자산 유지, 본문 미사용 |
| `ch08_06_course_revenue_summary.svg` | 강의별 신청 건수와 결제금액 집계 | 자산 유지, 본문 미사용 |
| `ch08_07_where_group_having_order.svg` | 집계 쿼리의 논리적 처리 흐름 | 사용 |
| `ch08_08_ai_join_sql_review_flow.svg` | AI 생성 JOIN·집계 SQL 검토 흐름 | 사용 |

## 본문 그림 순서

```text
그림 8-1 JOIN이 필요한 이유
그림 8-2 다중 JOIN 경로
그림 8-3 WHERE·GROUP BY·HAVING 논리 흐름
그림 8-4 AI SQL 검토 흐름
```

## 2차 재구성 데이터 기준

```text
course_project.students 3
course_project.instructors 2
course_project.courses 3
course_project.enrollments 5

전체 금액 590000
취소 제외 4건 / 440000
상태: 신청 2, 수강중 1, 완료 1, 취소 1
```

기존 도식 중 다음 요소는 Chapter 08 이전 전용 데이터셋을 표현하므로 새 본문에서는 사용하지 않습니다.

```text
최현우 학생
집계 쿼리 실습 강의
students 4 / instructors 3 / courses 4
수강중 2 / 완료 1 / 신청 2
LEFT JOIN 결과 6행
```

파일 자체는 이전 변경 이력과 자산 보존을 위해 유지합니다. 향후 전체 이미지 일관성 작업에서 새 데이터 기준으로 다시 제작할 수 있습니다.

## Mermaid 원본과 SVG

모든 SVG에는 같은 이름의 `.mmd` 원본이 있습니다. 새 본문에서 사용하는 네 자산은 일반 관계·흐름 중심이므로 현재 원고와 호환됩니다.

## 검수 기준

```text
- XML 파싱 가능
- width="100%"와 viewBox 유지
- 외부 CSS·JS·웹폰트·foreignObject 미사용
- PK·FK 경로가 본문과 일치
- 그림 번호와 캡션이 새 본문 순서와 일치
- GitHub·Word·PDF·eBook 실제 렌더링은 수동 확인
```
