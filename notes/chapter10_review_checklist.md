# Chapter 10 리뷰 체크리스트

## 대상 Chapter

Chapter 10. 인덱스와 성능 기초

## 리뷰 목적

Chapter 10이 PostgreSQL 인덱스와 실행 계획을 정확히 설명하고, 실습 SQL과 도식이 본문 흐름과 일치하는지 점검한다.

## 핵심 점검

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| `students.email` 중복 수동 인덱스를 제거했는가 | 통과 | UNIQUE 자동 인덱스 확인 방식으로 변경 |
| 자동 인덱스와 수동 인덱스를 구분했는가 | 통과 | PRIMARY KEY, UNIQUE, FOREIGN KEY 차이 설명 |
| Chapter 09의 `payments` 잔존 가능성을 초기화에 반영했는가 | 통과 | SQL에서 `payments`를 먼저 삭제 |
| 성능 실습용 대량 데이터셋을 추가했는가 | 통과 | students 10,005 / courses 2,005 / enrollments 100,007 기준 |
| EXPLAIN과 EXPLAIN ANALYZE를 구분했는가 | 통과 | 실제 실행 여부와 SELECT 한정 사용 안내 |
| cost를 실행 시간으로 설명하지 않는가 | 통과 | 상대적 예상 비용으로 설명 |
| ORDER BY와 LIMIT 비교가 포함되었는가 | 통과 | 전체 정렬과 LIMIT 20 비교 |
| FK 컬럼 인덱스가 자동 생성되지 않음을 설명했는가 | 통과 | `enrollments.student_id`, `course_id` 수동 검토 |
| 복합 인덱스의 선두 컬럼을 설명했는가 | 통과 | `course_id`, `course_id + status`, `status` 조건 비교 |
| 단일·복합 인덱스 중복 검토가 있는가 | 통과 | `idx_enrollments_course_id`는 비교 후 제거 |
| AI 추천 인덱스 검토 흐름이 있는가 | 통과 | 기존 인덱스, 실행 계획, 쓰기 비용 점검 |
| SVG 접근성 구조가 있는가 | 확인 필요 | XML 검증과 렌더링 확인 필요 |
| Chapter 09/11 파일을 수정하지 않았는가 | 확인 필요 | 최종 diff에서 확인 필요 |

## 수동 검수 필요 항목

| 항목 | 확인 방법 |
| --- | --- |
| SQL 실행 | 개인 PostgreSQL DB에서 전체 실행 후 예상 건수 확인 |
| 실행 계획 | 환경별로 달라질 수 있으므로 Plan 이름만 정답으로 고정하지 않음 |
| SVG 렌더링 | 브라우저, GitHub 미리보기, Word/PDF/eBook 변환에서 텍스트 넘침 확인 |
| Chapter 연결 | Chapter 09와 Chapter 11 파일 변경 없음 확인 |
