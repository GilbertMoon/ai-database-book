# Chapter 09 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 09. 트랜잭션으로 데이터 정합성 지키기
```

## 리뷰 목적

Chapter 09가 Chapter 07·08의 `course_project` 기준 데이터를 보호하면서 별도 `transaction_lab`에서 정상 COMMIT, ROLLBACK, 좌석 부족, 취소, 오류 복구와 동시성 대기를 안전하게 설명·실행·검증하는지 확인합니다.

---

## 1. Chapter 연속성과 사전 조건

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| Chapter 07·08 데이터 사용 | 통과 | 동일 `course_project` 기준 상태 사용 |
| `course_project` 행 수 | 통과 | 3 / 2 / 3 / 5 자동 검사 |
| 상태별 건수 | 통과 | 신청2·수강중1·완료1·취소1 |
| 전체 기록 금액 | 통과 | 590000 |
| 활성 신청 | 통과 | 3 / 340000 |
| 취소 제외 | 통과 | 4 / 440000 |
| 핵심 신청 | 통과 | 1001·1004·1005 상태·금액 검사 |
| 금액 타입 | 통과 | `recorded_amount NUMERIC(12,0)` |
| 활성 부분 고유 인덱스 | 통과 | `uq_course_enrollments_active` 존재 확인 |
| 잘못된 DB | 실제 통과 | `postgres` DB에서 01 실행 실패 확인 |
| 기존 lab 스키마 | 실제 통과 | 재실행 시 생성 차단 확인 |

---

## 2. 원고·워크북·발표자료

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 본문 구조 | 통과 | 번호 절 1~23 유지 |
| 구성안 | 통과 | 현재 기준 상태·트랜잭션 흐름 동기화 |
| 워크북 | 통과 | 3/2/3/5·상태·금액·타입 기록 표 반영 |
| 이론 발표 | 통과 | 20장, 모든 절 화면 구성·발표 스크립트 |
| 실습 발표 | 통과 | 20장, 모든 절 화면 구성·발표 스크립트 |
| 실제 금액 열 이름 | 통과 | `recorded_amount`로 원본 자체 통일 |
| 런타임 열 이름 우회 | 제거 | 원고를 화면에서만 치환하던 코드 제거 |
| 자산 버전 | 통과 | `20260809a` |
| 공통 TTS | 정적 통과 | `tts_pronunciation.js` 연결 |
| 스크립트 보완 | 정적 통과 | `script_content_enhancer.js` 연결 |
| 창 동기화 | 정적 통과 | postMessage·자산 버전 전달 구조 유지 |

---

## 3. 스키마·제약조건

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 실습 스키마 분리 | 통과 | `transaction_lab` 사용 |
| 좌석 CHECK | 통과 | `0 <= remaining_seats <= capacity` |
| 학생·강의 FK | 통과 | `course_project` 참조 |
| payment FK | 통과 | lab enrollment 참조 |
| payment 최대 한 건 | 통과 | enrollment_id UNIQUE |
| 중복 활성 신청 | 통과 | 부분 고유 인덱스 |
| 신청 기록 금액 | 통과 | `NUMERIC(12,0)`·0 이상 |
| payment 금액 | 통과 | `NUMERIC(12,0)`·0 이상 |
| 스키마 생성 원자성 | 실제 통과 | BEGIN→생성→자동 판정→COMMIT |

---

## 4. 주 실습 01→06

| 단계 | 기대 결과 | 실제 검증 |
| --- | --- | --- |
| 01 schema | lab 3개 테이블·인덱스 생성, 빈 상태 | 통과 |
| 02 seed | inventory 3 / enrollment 0 / payment 0 | 통과 |
| 03 COMMIT | 9001·9901, 301 remaining 1 | 통과 |
| 04 ROLLBACK | 임시 9002·9902 제거, 302 remaining 1 복구 | 통과 |
| 05 COMMIT | 9002·9902, 302 remaining 0 | 통과 |
| 05 sold-out | 9003·9903 미생성, 좌석 0 유지 | 통과 |
| 06 final | inventory/enrollment/payment = 3/2/2 | 통과 |
| 최종 좌석 | 301/302/303 = 1/0/1 | 통과 |
| project 보호 | 전체 데이터 fingerprint 불변 | 통과 |

주 실습의 모든 자동 통과 메시지를 PostgreSQL 16에서 실제 확인했습니다.

---

## 5. ROLLBACK과 IDENTITY

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 임시 행 전체 취소 | 실제 통과 | 9002·9902 제거 |
| 좌석 복구 | 실제 통과 | 302 remaining 0→1 |
| 이전 COMMIT 보존 | 실제 통과 | 9001·9901·301 remaining 1 유지 |
| 명시적 ID 재사용 | 통과 | ROLLBACK 후 9002·9902 직접 재사용 |
| IDENTITY 회수 오해 | 통과 | 자동 할당 번호는 일반적으로 회수되지 않음 설명 |
| RESTART 원자성 | 통과 | enrollment/payment 두 조정을 한 트랜잭션으로 처리 |

---

## 6. FOR UPDATE·좌석 확보·0행

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| `FOR UPDATE` 역할 | 통과 | 잠금·최신 상태 관찰 |
| 조건부 UPDATE | 통과 | `remaining_seats > 0`으로 실제 자격 판단 |
| `RETURNING` | 통과 | 좌석 확보 성공 결과 전달 |
| data-modifying CTE | 통과 | 좌석 성공 시에만 신청·결제 생성 |
| UPDATE 0행 | 실제 통과 | 좌석 부족 업무 실패로 처리 |
| 9003·9903 | 실제 통과 | 생성되지 않음 |

---

## 7. 최종 정합성 자동 게이트

| 검증 | 기대 | 실제 결과 |
| --- | ---: | --- |
| project 4테이블 | 3/2/3/5 | 통과 |
| project 상태 | 2/1/1/1 | 통과 |
| project 금액 | 590000 / 340000 / 440000 | 통과 |
| lab inventory/enrollment/payment | 3/2/2 | 통과 |
| 9001 / 9901 | 101·301·100000 | 통과 |
| 9002 / 9902 | 103·302·120000 | 통과 |
| 좌석 범위 위반 | 0 | 통과 |
| 결제 누락·금액 불일치 | 0 | 통과 |
| 고아 payment | 0 | 통과 |
| 중복 활성 신청 | 0 | 통과 |
| 활성 신청 = 사용 좌석 | 모두 일치 | 통과 |
| 9003·9903 | 0행 | 통과 |

---

## 8. 취소와 좌석 복구

| 점검 항목 | 상태 | 실제 검증 |
| --- | --- | --- |
| 9001 수강중→취소 | 통과 | 트랜잭션 내부 확인 |
| 301 좌석 1→2 | 통과 | 트랜잭션 내부 확인 |
| payment 9901 유지 | 통과 | 100000 유지 |
| 선택 실습 ROLLBACK | 통과 | 실행 |
| 원래 9001 상태 복구 | 통과 | 수강중·100000 |
| 301 좌석 복구 | 통과 | remaining 1 |
| 최종 06 재검증 | 통과 | 주 실습 기준 상태 유지 |

---

## 9. 오류와 SAVEPOINT

| 점검 항목 | 상태 | 실제 검증 |
| --- | --- | --- |
| SAVEPOINT 설명 | 통과 | 수동 실습 파일 제공 |
| 실제 중복 오류 | 통과 | `uq_transaction_enrollments_active` 위반 재현 |
| aborted 상태 복구 | 통과 | `ROLLBACK TO SAVEPOINT` 실행 |
| 좌석 임시 변경 복구 | 통과 | 301 remaining 1 |
| 오류 행 제거 | 통과 | 9003 없음 |
| 최종 06 재검증 | 통과 | 기준 상태 유지 |

---

## 10. 동시성

| 점검 항목 | 상태 | 실제 검증 |
| --- | --- | --- |
| 기본 격리 수준 설명 | 통과 | `READ COMMITTED` 기준 |
| 두 세션 사용 | 실제 통과 | 독립 psql 세션 A/B 실행 |
| Session A `FOR UPDATE` | 실제 통과 | course 303 잠금 |
| Session B Lock 대기 | 실제 통과 | 동일 행 잠금 시도 |
| `lock_timeout` | 실제 통과 | 1초 timeout 재현 |
| timeout 후 복구 | 실제 통과 | 트랜잭션 종료 후 상태 정상 |
| course 303 | 실제 통과 | remaining 1 유지 |
| Lock vs Deadlock | 통과 | 개념 구분 유지 |

---

## 11. reset

| 점검 항목 | 상태 | 실제 검증 |
| --- | --- | --- |
| 현재 DB 검사 | 통과 | 보호 구문 |
| `course_project` 존재 검사 | 통과 | 보호 대상 확인 |
| lab 객체만 삭제 | 실제 통과 | transaction_lab 제거 |
| reset 트랜잭션 | 실제 통과 | BEGIN/COMMIT |
| project 행 수·금액 | 실제 통과 | 3/2/3/5·590000 유지 |
| project fingerprint | 실제 통과 | reset 전후 동일 |
| Chapter 08 사전 게이트 | 실제 통과 | reset 후 재검증 성공 |

---

## 12. 이미지·도식

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| Mermaid | 통과 | 8개 |
| SVG | 통과 | 8개, stem 일치 |
| 본문 연결 | 통과 | 그림 9-1~9-8 모두 사용 |
| XML 파싱 | 통과 | 자동 검사 |
| 접근성 메타 | 통과 | role·title·desc |
| 반응형 | 통과 | width=100%·viewBox |
| 실제 출력 가독성 | 수동 확인 필요 | 브라우저·인쇄·eBook |

---

## 13. 자동 검증 결과

```text
Workflow: Validate Chapter 09
Run: 2
Run ID: 31282972035
Commit: 39775d598692f434133302a4c1a3485ccfd37e51
Status: completed
Conclusion: success
PostgreSQL: 16
Date: 2026-08-09 (Asia/Seoul)
```

초기 Run 1은 이론 발표자료가 자연어 “기록 금액”만 사용하고 실제 컬럼명 `recorded_amount`를 직접 표시하지 않아 정적 검증에서 실패했습니다. 이론·실습·본문·워크북의 사전 조건을 실제 스키마 및 Chapter 07·08 기준값과 연결한 뒤 Run 2에서 전체 검증을 통과했습니다.

---

## 14. 최종 판정

```text
Chapter 09은 앞 장의 기준 데이터 보호부터
정상 COMMIT, 전체 ROLLBACK, 좌석 부족 0행,
취소 복구, SAVEPOINT 오류 복구, 실제 두 세션 Lock 대기와 reset까지
PostgreSQL 16에서 재현·검증된 상태다.
```

자동 검증과 별개로 브라우저 최종 렌더링, 단계별 강조 실제 조작, TTS 청취, 모바일·프로젝터·Word·PDF·eBook 출력은 수동 제작 검수 범위로 남깁니다.


---

## 15. 2026-08-10 최종 출판 보완 및 재검증

- [x] Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 09 시작·최종 게이트에서 확인
- [x] 현재 역할의 `ai_database_book` CREATE 권한을 스키마 생성 전에 확인
- [x] 사전 조건 검사를 DDL 트랜잭션 시작 전에 수행
- [x] 권한 없는 역할에서 `transaction_lab` 생성이 차단되고 객체가 남지 않음을 PostgreSQL 16에서 확인
- [x] `FOR UPDATE`와 조건부 `UPDATE ... RETURNING` 자체의 행 잠금 역할을 정확히 구분
- [x] 취소 성공 행을 좌석 복구 CTE의 입력으로 연결
- [x] 동일 취소 재시도에서 취소 0행 / 좌석 복구 0행 확인
- [x] 다른 활성 신청이 남아 있는 course 301에서도 같은 취소를 두 번 실행해 좌석이 한 번만 복구됨을 실제 확인
- [x] Chapter 09 작성 발표 스크립트 자동 확장 비활성화
- [x] 발표 자산 버전 `20260810a` 동기화
- [x] 주 실습 01→06 / SAVEPOINT / Lock timeout / reset 전체 재검증
- [x] `course_project` 전체 fingerprint 실행 전후·reset 후 동일

### 최종 자동 검증 기록

```text
Workflow: Validate Chapter 09
Run: 5
Run ID: 31381404542
Commit: bd0095c51f7c0382796ba3a75a4bce4fdde44290
PostgreSQL: 16
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
```
