# Chapter 10 이미지/도식 설계

## Chapter 10. 실행 계획으로 인덱스 효과 검증하기

이 문서는 Chapter 10의 Mermaid·SVG 자산과 `performance_lab` 기반 2차 재구성 기준을 정리합니다.

## 공통 원칙

```text
- 하나의 SVG는 하나의 판단 메시지만 전달한다.
- 인덱스가 항상 정답인 것처럼 표현하지 않는다.
- Seq Scan과 Index Scan을 성공·실패로 단순 구분하지 않는다.
- 자동 인덱스와 수동 인덱스를 명확히 구분한다.
- 전체 SQL과 실행 계획 전문을 이미지에 넣지 않는다.
- 적용·보류·제거 분기를 텍스트로 표시한다.
- title, desc, role="img", aria-labelledby, width="100%", viewBox를 유지한다.
```

## 도식 목록

| 번호 | 파일 | 제목 | 새 본문 역할 |
| --- | --- | --- | --- |
| 그림 10-1 | `ch10_01_index_need_overview.svg` | 데이터 증가와 인덱스 검토 | 작은 데이터와 대량 데이터의 조회 경로 차이 |
| 그림 10-2 | `ch10_02_table_scan_vs_index_scan.svg` | Seq Scan과 Index Scan의 검색 경로 | 스캔 방식 비교 |
| 그림 10-3 | `ch10_03_where_index_candidate.svg` | WHERE 조건에서 인덱스 후보 판단하기 | 워크로드·선택도·기존 인덱스 검토 |
| 그림 10-4 | `ch10_05_join_foreign_key_index.svg` | JOIN 관계와 외래키 인덱스 후보 | FK 자식 컬럼 수동 검토 |
| 그림 10-5 | `ch10_06_composite_index_order.svg` | 복합 인덱스의 선두 컬럼과 쿼리 조건 | 컬럼 순서 판단 |
| 그림 10-6 | `ch10_04_order_by_index_flow.svg` | ORDER BY에서 인덱스가 사용되는 흐름 | 전체 정렬과 LIMIT 비교 |
| 그림 10-7 | `ch10_07_explain_before_after.svg` | 인덱스 전후 실행 계획 비교 | 동일 SQL 재측정 흐름 |
| 그림 10-8 | `ch10_08_ai_index_review_flow.svg` | AI 추천 인덱스 검토 흐름 | 적용·보류·제거 검토 |

모든 SVG에는 같은 이름의 `.mmd` 원본이 있습니다.

## 2차 재구성 데이터 기준

```text
performance_lab.students 10003
performance_lab.instructors 2
performance_lab.courses 2003
performance_lab.enrollments 100005
```

스키마 역할:

```text
course_project: 변경하지 않음
transaction_lab: 변경하지 않음
performance_lab: 인덱스 성능 실험 전용
```

최종 수동 후보:

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

## 도식에서 피할 표현

```text
- Index Scan은 항상 빠르다.
- Seq Scan은 오류다.
- cost는 실행 시간이다.
- FK에는 자동 인덱스가 있다.
- idx_scan=0이면 즉시 삭제한다.
- AI 추천 인덱스는 바로 적용한다.
```

## 검수 기준

```text
- 본문 그림 번호 10-1~10-8과 README 순서 일치
- XML 파싱 가능
- 텍스트와 박스 경계 충돌 없음
- 자동·수동 인덱스 라벨 구분
- 실행 계획 전후의 결과 동일성 표현
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
