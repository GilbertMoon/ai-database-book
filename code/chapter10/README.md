# Chapter 10 실습 코드

## 인덱스와 성능 기초

이 폴더는 Chapter 10에서 사용하는 PostgreSQL 인덱스 성능 실습 SQL을 관리합니다.

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `index_performance_practice.sql` | 성능 비교용 데이터 생성, 자동/수동 인덱스 확인, EXPLAIN ANALYZE 비교, 복합 인덱스 실습 |

## 실행 전 주의

`index_performance_practice.sql`은 `payments`, `enrollments`, `courses`, `instructors`, `students`를 삭제하고 다시 생성합니다. 개인 실습용 `ai_database_book` 데이터베이스에서만 실행하세요.

실행 전에 현재 연결 대상을 확인합니다.

```sql
SELECT current_database();
```

대량 데이터 생성에는 시간이 걸릴 수 있습니다. 일반 개인 PC에서 너무 오래 걸리면 SQL 파일의 `enrollments` 자동 생성 건수를 100,000에서 50,000으로 줄여 실습할 수 있습니다.

## 예상 데이터 건수

| 테이블 | 최종 예상 행 수 |
| --- | ---: |
| students | 10,005 |
| instructors | 3 |
| courses | 2,005 |
| enrollments | 100,007 |

## 핵심 보정 사항

- Chapter 09에서 `payments`가 남아 있을 수 있으므로 먼저 삭제합니다.
- `students.email`은 UNIQUE 제약조건으로 자동 인덱스가 있으므로 수동 `idx_students_email`을 만들지 않습니다.
- PostgreSQL은 PRIMARY KEY와 UNIQUE에는 자동 인덱스를 만들지만, FOREIGN KEY 자식 컬럼에는 자동 인덱스를 만들지 않습니다.
- `EXPLAIN`은 예상 계획이고 `EXPLAIN ANALYZE`는 SQL을 실제 실행합니다.
- 이 실습의 `EXPLAIN (ANALYZE, BUFFERS)`는 SELECT 쿼리에만 사용합니다.
- `ANALYZE table_name`은 통계 갱신 명령이며 `EXPLAIN ANALYZE`와 다릅니다.
- 실행 계획은 PostgreSQL 버전, 데이터 분포, 통계, 메모리 설정, 캐시 상태에 따라 달라질 수 있습니다.

## 최종 수동 인덱스 기준

- `idx_courses_title`
- `idx_enrollments_student_id`
- `idx_enrollments_course_status`

`idx_enrollments_course_id`는 단일 인덱스와 복합 인덱스의 역할 중복을 비교하기 위한 실습용 인덱스이며, 최종 상태에서는 제거합니다.
