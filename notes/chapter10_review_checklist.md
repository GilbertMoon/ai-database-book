# Chapter 10 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 10. 실행 계획으로 인덱스 효과 검증하기
```

## 리뷰 목적

Chapter 10이 기존 프로젝트 데이터를 보호하면서 `performance_lab`에서 동일 SQL의 인덱스 생성 전후 실행 계획을 비교하고, 읽기 이점과 쓰기 비용을 근거로 적용·보류·제거를 판단하도록 구성되었는지 점검합니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| course_project 보호 | 통과 | 행 수 확인만 수행하고 변경 없음 |
| transaction_lab 보호 | 통과 | Chapter 10 SQL에서 참조·변경 없음 |
| performance_lab 전용 | 통과 | 대량 데이터·인덱스 실험 격리 |
| 자동 DROP 제거 | 통과 | 생성 파일에 삭제 없음 |
| 초기화 분리 | 통과 | reset_performance_lab.sql만 사용 |
| Chapter 11 연결 | 통과 | 성능에서 보안·복구로 연결 |

---

## 2. 데이터·스키마 정합성

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 10003 | 코드 반영 |
| instructors | 2 | 코드 반영 |
| courses | 2003 | 코드 반영 |
| enrollments | 100005 | 코드 반영 |
| 기본키 | IDENTITY | 통과 |
| 학생·강사 email | UNIQUE | 통과 |
| FK 자식 인덱스 | 자동 생성 안 됨 | 본문·SQL 반영 |
| 강의별 상태 분포 | 여러 상태 | 생성 규칙 반영 |

---

## 3. 실행 계획 설명

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| EXPLAIN | 통과 | 예상 계획이며 실제 실행 안 함 |
| EXPLAIN ANALYZE | 통과 | 실제 실행과 실제 수치 표시 |
| SELECT 한정 | 통과 | 변경 SQL 실실행 위험 방지 |
| cost | 통과 | 상대적 예상 비용으로 설명 |
| rows·actual rows | 통과 | 예상·실제 차이 검토 |
| loops | 통과 | 반복 작업량 해석 추가 |
| Buffers | 통과 | 블록 읽기 비교 기준 |
| Filter·Index Cond | 통과 | 사후 필터와 탐색 조건 구분 |
| Sort | 통과 | ORDER BY·LIMIT 비교 |

---

## 4. 인덱스 판단 정확성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| PK·UNIQUE 자동 인덱스 | 통과 | email 중복 수동 인덱스 방지 |
| FK 자식 컬럼 | 통과 | student_id·course_id 수동 검토 |
| Seq Scan | 통과 | 항상 나쁜 계획으로 설명하지 않음 |
| Index Scan | 통과 | 항상 최선으로 설명하지 않음 |
| Bitmap Scan | 통과 | 중간 선택도 접근 설명 |
| 선택도 | 통과 | 반환 비율과 함께 판단 |
| 복합 인덱스 | 통과 | `(course_id, status)` 사용 |
| 선두 컬럼 | 통과 | course_id·두 조건·status 단독 비교 |
| ORDER BY·LIMIT | 통과 | 전체 정렬과 상위 20건 비교 |
| 중복 인덱스 | 통과 | email·course_id 역할 중복 검토 |

---

## 5. 단계별 SQL

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_performance_lab_schema.sql` | 전용 스키마·테이블 생성 | 통과 |
| `02_performance_lab_seed.sql` | 기본·대량 데이터와 ANALYZE | 통과 |
| `03_baseline_explain.sql` | 생성 전 기준 계획 | 통과 |
| `04_create_candidate_indexes.sql` | 세 후보 인덱스 생성 | 통과 |
| `05_after_index_explain.sql` | 동일 SQL 재측정 | 통과 |
| `06_index_review.sql` | 정의·크기·사용 통계 확인 | 통과 |
| `reset_performance_lab.sql` | 실험 스키마만 초기화 | 통과 |
| `index_performance_practice.sql` | 안전한 호환 진입점 | 통과 |
| `README.md` | 실행 순서·안전 원칙 | 통과 |

---

## 6. 전후 비교 기준

| 비교 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 동일 SQL | 통과 | 03·05 파일의 SELECT 일치 |
| 동일 데이터 상태 | 통과 | 인덱스만 추가 |
| 결과 행 동일성 | 워크북 반영 | 측정 시 기록 필요 |
| 계획 노드 | 워크북 반영 | 환경별 차이 허용 |
| rows·actual rows | 워크북 반영 | 추정 정확도 확인 |
| Buffers | 워크북 반영 | 읽기 감소 확인 |
| Execution Time | 워크북 반영 | 캐시 영향 주의 |
| 쓰기 비용 | 본문 반영 | 읽기만으로 승인하지 않음 |

---

## 7. 최종 인덱스 후보

```text
idx_performance_courses_title
idx_performance_enrollments_student_id
idx_performance_enrollments_course_status
```

| 검토 항목 | 상태 |
| --- | --- |
| 기존 자동 인덱스와 이름·키 중복 없음 | 통과 |
| 단일 course_id 인덱스 자동 생성 안 함 | 통과 |
| 제거 SQL 기본 주석 처리 | 통과 |
| idx_scan=0 즉시 삭제 금지 | 통과 |

---

## 8. AI 추천 검토

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 실제 SQL·행 수 제공 | 통과 | 프롬프트 예시 포함 |
| 기존 인덱스 제공 | 통과 | pg_indexes 결과 요구 |
| 컬럼 순서 근거 | 통과 | 복합 인덱스 검토 |
| 전후 실행 계획 | 통과 | 검증 SQL 요구 |
| 쓰기 비용 | 통과 | 적용 판단 기준 포함 |
| 중복 추천 방지 | 통과 | UNIQUE email 예시 |
| 스키마 범위 | 통과 | performance_lab 외 변경 금지 |

---

## 9. 도식

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 기존 SVG 8종 | 통과 | 일반 인덱스 판단 흐름과 호환 |
| 그림 번호 | 통과 | 새 본문 순서 반영 |
| 새 제목·스키마 기준 | 통과 | 이미지 README 갱신 |
| XML·접근성 | 기존 검증 유지 | 실제 렌더링 수동 확인 필요 |

---

## 10. 남은 확인

```text
- 실제 PostgreSQL에서 01→06 실행
- 대량 데이터 생성 시간과 행 수 확인
- 환경별 실행 계획 기록
- 인덱스 전후 Buffers·시간 비교
- course_project.enrollments 5건 유지 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 11. 최종 판정

```text
Chapter 10은 기존 프로젝트를 보호하면서 대량 데이터와 실행 계획을 근거로 인덱스 효과를 검증하는 장으로 2차 재구성했다.
실제 PostgreSQL 실행 결과는 환경별로 수동 기록이 필요하다.
```
