# Chapter 15 구성안

## 제목

데이터베이스 종합 프로젝트

## 권장 분량

34~40페이지

## 이 장의 역할

책 전체의 요구사항, ERD, PostgreSQL, SQL 검증, 트랜잭션, 인덱스, 보안·복구, SQL·Python 분석과 AI 변경 검토를 `tutor_project`에서 통합합니다.

```text
문제·범위
→ P15 요구사항·정책
→ 안전한 DDL·Seed·IDENTITY
→ 정확한 메타데이터·업무·시간 검증
→ 트랜잭션·반례·경계값
→ 인덱스 후보·PUBLIC·운영
→ 고정 기간 분석 VIEW
→ 예외 기반 DB 게이트
→ 실제 SQL·pandas 교차 검증
→ 별도 DB 복원·보고서·최종 판단
```

## 핵심 메시지

> SQL 실행이나 그래프 생성은 완료의 일부다. 구조·데이터·분석·복구와 사람이 승인한 증거가 함께 재현되어야 프로젝트가 완성된다.

## 실습 구조

```text
base tables 6
analysis views 4
identity sequences 5
constraints 36
foreign keys 5
business indexes 3
```

분석 VIEW:

```text
analysis_parameters
question_analysis_dataset       질문 1건
student_question_summary        학생 1명, 0건 포함
tutor_answer_summary            튜터 1명, 0건 포함
```

## 추적 ID

```text
P15-R01~R13 요구사항
P15-D01~D08 결정·미확정 정책
P15-Q01~Q06 분석 질문
P15-T01~T25 트랜잭션·반례·경계값
P15-V01~V09 검증 단계
```

## 기준 결과

```text
rows 4·3·5·5·6·7
identity next 105·204·306·406·507 이상
업무·시간 이상 0
테스트 23/23, unexpected 0
질문·학생·튜터 VIEW 5·4·3행
answer_count 5, material_count 7
첫 답변 4건·평균 2시간·음수 0
SQL·pandas 요약 5종 일치
```

## 본문 구성

1. 필수 경로와 선택 확장
2. 파일 구조와 실행 순서
3. 문제·사용자·범위
4. P15 요구사항·정책
5. ERD·DDL·메타데이터
6. 기준 데이터·IDENTITY
7. 업무·시간 정합성
8. 트랜잭션 정상·실패 경로
9. 반례·정상 경계값
10. 인덱스 후보와 효과 검증 범위
11. PUBLIC·소유권·access_scope
12. 백업·별도 DB 원자적 복원
13. 분석 기간·행 단위·date spine
14. 실제 SQL·pandas 교차 검증
15. DB 게이트와 전체 완료 분리
16. AI diff·실행 증거
17. 프로젝트 완성도
18. 자주 하는 실수
19. 책 전체 연결

## 코드 파일

```text
01_schema.sql
02_seed.sql
03_metadata_validation.sql
04_requirement_queries.sql
05_transaction_checks.sql
06_negative_tests.sql
07_performance_checks.sql
08_operations_checks.sql
09_analysis_dataset.sql
10_completion_gate.sql
11_restore_validation.sql
python/validation_utils.py
python/01_load_postgresql.py
python/02_pandas_analysis.py
python/03_result_validation.py
```

| 파일 | 역할 |
| --- | --- |
| `01` | DB 보호·원자적 구조·분석 기준 생성 |
| `02` | 빈 상태 검사·Seed·IDENTITY·COMMIT 전 검증 |
| `03` | 정확한 테이블·제약·FK·PK·인덱스 검증 |
| `04` | P15 요구사항·경계·시간 관계 검증 |
| `05` | 정상 원자성·실패 무변경·ROLLBACK |
| `06` | SQLSTATE·constraint name과 23개 테스트 |
| `07` | 인덱스 후보 정의·대표 EXPLAIN |
| `08` | PUBLIC·ACL·owner·가상 데이터 점검 |
| `09` | 고정 기간 분석 VIEW·date spine·SQL 기준 |
| `10` | 예외 기반 DB 완료 게이트 |
| `11` | 복원 DB 전용 구조·데이터·owner 검증 |
| Python | 읽기 전용 동일 스냅샷 SQL·pandas 직접 비교 |

## 완료 단계

```text
DB 완료          10 통과
Python 완료      실제 SQL·pandas 비교 통과
복구 완료        백업·별도 DB 복원·11 통과
권한 완료        실제 허용·차단 시험
문서 완료        요구사항·ERD·보고서·AI diff 승인
```

## 안전 원칙

- 생성·Seed·reset은 현재 DB와 상태를 실제 검사한다.
- 명시적 ID 뒤 IDENTITY를 조정한다.
- 개수보다 정확한 객체 정의를 검증한다.
- 모든 시험 변경을 정리하거나 ROLLBACK한다.
- PUBLIC·직접 GRANT·owner·유효 권한을 구분한다.
- `access_scope`를 실제 권한으로 오해하지 않는다.
- 실제 password file·백업·운영 데이터는 저장소 밖에 둔다.
- Python은 `REPEATABLE READ, READ ONLY`를 사용한다.
- 미실행 항목은 통과로 표시하지 않는다.
