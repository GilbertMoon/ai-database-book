# Chapter 09 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 09. 트랜잭션으로 데이터 정합성 지키기
```

## 리뷰 목적

Chapter 09가 Chapter 07·08의 `course_project` 데이터를 보호하면서 별도 `transaction_lab`에서 성공·ROLLBACK·좌석 부족·동시성 경로를 검증하는지 점검합니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| course_project 보호 | 통과 | DROP·ALTER·UPDATE 없이 읽기·FK 참조만 수행 |
| transaction_lab 사용 | 통과 | 좌석·신청·결제 실습 상태 분리 |
| 학생·강의 ID 연속성 | 통과 | 101~103, 301~303 사용 |
| Chapter 08 기준 유지 | 통과 | project enrollments 5건 유지 |
| 초기화 범위 | 통과 | reset 파일이 transaction_lab만 삭제 |

---

## 2. 트랜잭션 개념

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 업무 단위 설명 | 통과 | 좌석·신청·결제 세 변경 |
| BEGIN·COMMIT·ROLLBACK | 통과 | 같은 연결 세션 사용 강조 |
| ACID | 통과 | 각 특성과 오해 구분 |
| 제약조건·트랜잭션 역할 | 통과 | 값·관계와 여러 변경 경계 분리 |
| COMMIT 전 검증 | 통과 | 좌석·신청·결제 JOIN 확인 |
| 이미 COMMIT된 변경 | 통과 | 같은 ROLLBACK으로 취소 불가 설명 |

---

## 3. 정상·실패 경로

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 성공 COMMIT 1 | 통과 | 9001·9901, course 301 좌석 1 |
| ROLLBACK | 통과 | 9002·9902 임시 생성 후 제거, 좌석 복구 |
| ID 재사용 | 통과 | ROLLBACK 후 9002·9902 정상 COMMIT |
| 좌석 부족 | 통과 | 9003·9903 0건, SQL 오류와 구분 |
| CTE 연결 | 통과 | 좌석 성공 결과가 있을 때만 후속 INSERT |
| 최종 행 수 | 통과 | lab enrollments 2, payments 2 |

---

## 4. 오류와 복구

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| UPDATE 0행 | 통과 | 업무상 실패이며 자동 오류 아님 |
| SQL 문장 오류 | 통과 | PostgreSQL aborted 상태 설명 |
| ROLLBACK 대응 | 통과 | 오류 상태 기본 복구 방법 |
| SAVEPOINT | 통과 | 부분 복구 경계의 기본 개념 포함 |
| 재실행 위험 | 통과 | 명시적 ID와 실행 순서·초기화 안내 |

---

## 5. 동시성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| SELECT FOR UPDATE | 통과 | 좌석 행 잠금과 최신 상태 확인 |
| 조건부 UPDATE | 통과 | remaining_seats > 0 적용 |
| 두 세션 실습 | 통과 | 위험 SQL 기본 주석 처리 |
| Lock 대기 | 통과 | 다른 세션의 종료까지 대기 가능 |
| Deadlock 구분 | 통과 | 순환 대기와 단순 대기 분리 |
| 장기 트랜잭션 | 통과 | 사용자·외부 API 대기 위험 설명 |

---

## 6. 스키마·제약조건

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| lab 기본키 | 통과 | IDENTITY 사용 |
| course_inventory FK | 통과 | course_project.courses 참조 |
| lab enrollment FK | 통과 | project students·courses 참조 |
| payment FK | 통과 | lab enrollment UNIQUE 참조 |
| 좌석 CHECK | 통과 | 0 이상 capacity 이하 |
| 상태 CHECK | 통과 | 수강중·취소 |
| 금액 CHECK | 통과 | 0 이상 |

---

## 7. 코드 파일

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_transaction_lab_schema.sql` | 격리 스키마 생성 | 통과 |
| `02_transaction_lab_seed.sql` | 좌석 초기 상태 | 통과 |
| `03_commit_transaction.sql` | 성공 COMMIT | 통과 |
| `04_rollback_transaction.sql` | ROLLBACK 전후 | 통과 |
| `05_commit_and_sold_out.sql` | 두 번째 COMMIT·좌석 부족 | 통과 |
| `06_transaction_validation.sql` | 최종 정합성 검증 | 통과 |
| `07_concurrency_two_sessions.sql` | 선택 동시성 실습 | 통과 |
| `reset_transaction_lab.sql` | lab만 초기화 | 통과 |
| `transaction_consistency_practice.sql` | 안전한 호환 진입점 | 통과 |
| `README.md` | 실행 순서·상태·주의 | 통과 |

---

## 8. 최종 정합성 기준

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| course_project.enrollments | 5 | 코드 반영 |
| lab enrollments | 2 | 코드 반영 |
| payments | 2 | 코드 반영 |
| 301 remaining | 1 | 코드 반영 |
| 302 remaining | 0 | 코드 반영 |
| 303 remaining | 1 | 코드 반영 |
| 좌석 범위 위반 | 0행 | 코드 반영 |
| 결제 누락·금액 불일치 | 0행 | 코드 반영 |
| 고아 payment | 0행 | 코드 반영 |
| active enrollment = used seats | 모두 true | 코드 반영 |
| 9003·9903 | 0행 | 코드 반영 |

---

## 9. AI SQL 검토

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 업무 경계 | 통과 | 좌석·신청·결제 포함 |
| 기존 데이터 보호 | 통과 | course_project 변경 금지 |
| 영향 행 수 | 통과 | 좌석 0·1행 구분 |
| 실패 경로 | 통과 | ROLLBACK·오류 상태·SAVEPOINT |
| 동시성 | 통과 | 행 잠금과 최신 좌석 확인 |
| 장기 작업 | 통과 | 외부 API 대기 분리 |
| 재실행 | 통과 | 중복·멱등성 위험 언급 |

---

## 10. 도식

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 기존 SVG 8종 | 통과 | 일반 트랜잭션 흐름과 호환 |
| 새 제목·스키마 기준 | 통과 | 이미지 README 갱신 |
| 접근성·XML | 기존 검증 유지 | 실제 출판 렌더링 수동 확인 |

---

## 11. 남은 확인

```text
- 실제 PostgreSQL에서 01→06 실행
- CTE 반환 행과 COMMIT 전 결과 확인
- ROLLBACK 후 ID 재사용 확인
- 두 세션 Lock 대기 확인
- SQL 오류·SAVEPOINT 선택 실습
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 12. 최종 판정

```text
Chapter 09는 기존 프로젝트를 보호하면서 트랜잭션의 정상·실패·동시성 경로를 단계별로 검증하는 장으로 2차 재구성했다.
실제 PostgreSQL 실행과 두 세션 실습은 수동 확인이 필요하다.
```
