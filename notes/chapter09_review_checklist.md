# Chapter 09 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 09. 트랜잭션으로 데이터 정합성 지키기
```

## 리뷰 목적

Chapter 09가 Chapter 07·08의 `course_project` 데이터를 보호하면서 별도 `transaction_lab`에서 성공·ROLLBACK·좌석 부족·오류·취소·동시성 경로를 안전하게 검증하는지 점검합니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| `course_project` 보호 | 통과 | DROP·ALTER·UPDATE 없이 읽기·FK 참조만 수행 |
| `transaction_lab` 격리 | 통과 | 좌석·신청·결제 실습 상태 분리 |
| 학생·강의 ID 연속성 | 통과 | 101~103, 301~303 사용 |
| Chapter 08 기준 유지 | 통과 | project enrollments 5행 검사 |
| 위치 확인 통일 | 통과 | DB·스키마·`SHOW search_path` |
| 초기화 범위 | 통과 | 현재 DB 검사 후 `transaction_lab`만 삭제 |

---

## 2. 사전 조건과 재실행 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 현재 DB 실제 차단 | 통과 | `ai_database_book`이 아니면 예외 |
| 프로젝트 테이블 존재 | 통과 | `to_regclass` 기반 검사 |
| 학생 101~103 | 통과 | 모두 존재해야 진행 |
| 강의 301~303·가격 | 통과 | 100000·120000·150000 검사 |
| project 신청 수 | 통과 | 5행 검사 |
| 중복 schema 생성 | 통과 | 기존 `transaction_lab` 존재 시 예외 |
| 원자적 schema 생성 | 통과 | 검사·CREATE·COMMIT을 한 트랜잭션으로 처리 |
| seed 재실행 | 통과 | lab이 비어 있지 않으면 예외 |
| 트랜잭션 파일 재실행 | 통과 | 좌석·ID·동일 활성 신청 사전 검사 |

---

## 3. 트랜잭션 개념

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 업무 단위 | 통과 | 좌석·신청·결제 세 변경 |
| BEGIN·COMMIT·ROLLBACK | 통과 | 같은 연결 사용 강조 |
| ACID | 통과 | 특성과 오해 구분 |
| 제약조건·트랜잭션 역할 | 통과 | 값·관계와 여러 변경 경계 분리 |
| COMMIT 전 검증 | 통과 | 사람이 보는 SELECT와 자동 `DO` 판정 |
| 잘못된 결과 COMMIT 차단 | 통과 | 기대 상태 불일치 시 예외 |
| 이미 COMMIT된 변경 | 통과 | 같은 ROLLBACK으로 취소 불가 설명 |

---

## 4. IDENTITY와 ROLLBACK

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 명시적 ID 재사용 | 통과 | ROLLBACK된 행의 9002·9902 직접 재사용 |
| 자동값 회수 오해 제거 | 통과 | IDENTITY 자동 번호는 회수되지 않을 수 있음 |
| 명시적 ID와 시퀀스 | 통과 | 다음 값 자동 이동 없음 설명 |
| 최종 IDENTITY 조정 | 통과 | enrollment 9003, payment 9903 |

---

## 5. 스키마·제약조건과 업무 규칙

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 좌석 CHECK | 통과 | `0 <= remaining <= capacity` |
| lab enrollment FK | 통과 | project students·courses 참조 |
| payment FK | 통과 | lab enrollment 참조 |
| 신청당 payment 최대 한 건 | 통과 | 명시적 UNIQUE 제약조건 |
| payment 최소 한 건 규칙 | 통과 | 제약조건 범위와 트랜잭션 검증 구분 |
| 상태 CHECK | 통과 | 수강중·취소 |
| 금액 CHECK | 통과 | 0 이상 |
| 중복 활성 신청 | 통과 | 부분 고유 인덱스 적용 |
| 신청·결제 금액 | 통과 | 신청 시점 가격 복사와 최종 일치 검증 |

---

## 6. 정상·실패 경로

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 성공 COMMIT 1 | 통과 | 9001·9901, course 301 좌석 1 |
| ROLLBACK | 통과 | 임시 9002·9902 제거, 좌석 복구 |
| 성공 COMMIT 2 | 통과 | 9002·9902, course 302 좌석 0 |
| 좌석 부족 | 통과 | 9003·9903 0건, SQL 오류와 구분 |
| CTE 연결 | 통과 | 좌석 성공 결과가 있을 때만 후속 INSERT |
| 조건부 UPDATE | 통과 | `remaining_seats > 0` 적용 |
| 최종 행 수 | 통과 | lab enrollments 2, payments 2 |

---

## 7. FOR UPDATE와 동시성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| FOR UPDATE 역할 | 통과 | 행 잠금과 상태 관찰 |
| 조건부 UPDATE 역할 | 통과 | 실제 변경 가능 여부 판단 |
| 영향 행 수 | 통과 | 성공 증거로 사용 |
| 격리 수준 | 통과 | READ COMMITTED 기준 명시 |
| `SHOW transaction_isolation` | 통과 | 코드 반영 |
| Lock timeout | 통과 | 선택적으로 5초 설정 |
| timeout 후 복구 | 통과 | ROLLBACK 안내 |
| Lock 대기 | 통과 | 한 잠금 해제 대기 |
| Deadlock | 통과 | 순환 대기와 구분 |
| 다른 격리 수준 | 통과 | 동시 변경 오류 가능성 설명 |

---

## 8. 오류와 SAVEPOINT

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| UPDATE 0행 | 통과 | 업무상 실패이며 문장 오류 아님 |
| aborted transaction | 통과 | 오류 후 일반 SQL 거부 가능 설명 |
| 전체 ROLLBACK | 통과 | 기본 복구 방법 |
| SAVEPOINT 파일 | 통과 | `09_error_and_savepoint.sql` 추가 |
| 실제 오류 근거 | 통과 | 중복 활성 신청 부분 인덱스 위반 |
| 부분 복구 | 통과 | 좌석 임시 차감까지 SAVEPOINT로 복구 |
| 안전 실행 | 통과 | 오류 유발 문장 기본 주석 상태 |

---

## 9. 취소와 좌석 복구

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 취소 선택 파일 | 통과 | `08_cancel_and_restore.sql` 추가 |
| 상태 변경과 좌석 | 통과 | 같은 트랜잭션에서 처리 |
| COMMIT 전 검증 | 통과 | 취소 상태·좌석·payment 확인 |
| 기준 상태 보존 | 통과 | 기본 ROLLBACK |
| 환불 범위 | 통과 | 금액·상태·승인 ID는 확장 범위 |

---

## 10. 최종 정합성 자동 판정

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| `course_project.enrollments` | 5 | 자동 판정 |
| lab enrollments | 2 | 자동 판정 |
| payments | 2 | 자동 판정 |
| 301 remaining | 1 | 자동 판정 |
| 302 remaining | 0 | 자동 판정 |
| 303 remaining | 1 | 자동 판정 |
| 좌석 범위 위반 | 0행 | 코드 반영 |
| 결제 누락·금액 불일치 | 0행 | 코드 반영 |
| 고아 payment | 0행 | 코드 반영 |
| 중복 활성 신청 | 0행 | 코드 반영 |
| active enrollment = used seats | 모두 true | 자동 판정 |
| 9003·9903 | 0행 | 자동 판정 |
| 최종 통과 메시지 | 출력 | 코드 반영 |

---

## 11. 코드 파일

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_transaction_lab_schema.sql` | 사전 검사·원자적 스키마 생성 | 완료 |
| `02_transaction_lab_seed.sql` | 초기 좌석·자동 검증 | 완료 |
| `03_commit_transaction.sql` | 첫 성공 COMMIT·자동 판정 | 완료 |
| `04_rollback_transaction.sql` | ROLLBACK·IDENTITY 설명 | 완료 |
| `05_commit_and_sold_out.sql` | 두 번째 COMMIT·좌석 부족·시퀀스 | 완료 |
| `06_transaction_validation.sql` | 최종 pass/fail 판정 | 완료 |
| `07_concurrency_two_sessions.sql` | 격리 수준·Lock 대기 | 완료 |
| `08_cancel_and_restore.sql` | 취소·좌석 복구 | 완료 |
| `09_error_and_savepoint.sql` | aborted·SAVEPOINT | 완료 |
| `reset_transaction_lab.sql` | DB 보호 초기화 | 완료 |
| `transaction_consistency_practice.sql` | 읽기 전용 안전 진입점 | 완료 |
| `README.md` | 실행 순서·규칙·주의 | 완료 |

---

## 12. 자기주도 학습 지원

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 워크북 동기화 | 통과 | 사전 조건·ID·취소·SAVEPOINT·격리 반영 |
| 권장 해설 | 통과 | 업무 경계·0행·잠금·결제·IDENTITY·취소 |
| AI 검토 | 통과 | 중복·복구·격리·재실행·외부 작업 추가 |
| 실행 결과 기록 | 통과 | 주 실습과 선택 실습 표 제공 |

---

## 13. 도식

기존 SVG 8종은 트랜잭션 필요성, 기본 흐름, 정합성, ACID, 성공·ROLLBACK, Lock과 AI 검토의 일반 메시지와 호환됩니다. 상세 SQL·SAVEPOINT·취소 표는 본문과 코드에서 설명하므로 이미지에 과도하게 중복하지 않았습니다.

---

## 14. 최종 판정

```text
Chapter 09는 사전 상태, COMMIT 전 판정, IDENTITY,
활성 중복, 취소·좌석 복구, 오류·SAVEPOINT와 READ COMMITTED를 보완했다.

본문·워크북·SQL·구성안·코드 안내가 같은 기준 상태와 규칙을 사용하므로
최종 출판 전 내용 검수 완료 상태로 판정한다.
```

실제 PostgreSQL에서 주 실습 `01→06`과 선택 실습 `07→09`를 수동으로 실행하는 통합 검증은 별도 제작 단계에서 확인합니다.
