# Chapter 10 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 10. 실행 계획으로 인덱스 효과 검증하기
```

## 자동 검증 기준

```text
Workflow: Validate Chapter 10
Run: 4
Run ID: 31285494158
Commit: 76dc98e36fae6b717a2910a2b277c0e94238235c
Conclusion: success
PostgreSQL: 16.14
```

---

## 1. Chapter 07·08 연속성과 격리

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| `course_project` 행 수 | 통과 | 3 / 2 / 3 / 5 |
| 상태 분포 | 통과 | 신청2 / 수강중1 / 완료1 / 취소1 |
| 전체 기록 금액 | 통과 | 590000 |
| 활성 신청 | 통과 | 3건 / 340000 |
| 취소 제외 이력 | 통과 | 4건 / 440000 |
| 기준 신청 | 통과 | 1001·1004·1005 상태·금액 일치 |
| `recorded_amount` 타입 | 통과 | `NUMERIC(12,0)` |
| 활성 신청 인덱스 | 통과 | `uq_course_enrollments_active` 존재 |
| Chapter 10에서 project 변경 없음 | 통과 | SQL 정적 검사 + 전체 fingerprint 동일 |
| `transaction_lab` 간섭 없음 | 통과 | Chapter 10 검증 시작 시 미존재 확인 |

`course_project` fingerprint는 Chapter 10 실행 전·전체 실행 후·reset 후 모두 다음 값으로 유지되었습니다.

```text
cd1c890f3e9bb4a5816b5763c19fa646
```

---

## 2. 금액 열과 버전 정합성

| 점검 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| Chapter 10 금액 열 | 통과 | `recorded_amount`로 통일 |
| 과거 열 이름 제거 | 통과 | 07의 음성 검사 외 학습·실행 소스 제거 |
| 검증 기준 서버 | 통과 | PostgreSQL 16 명시 |
| Skip Scan 버전 | 통과 | PostgreSQL 18에서 B-tree Skip Scan 추가로 수정 |
| 서버 버전 기록 | 통과 | SQL·본문·강의안·발표 시작 화면 반영 |

---

## 3. `01_performance_lab_schema.sql`

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 잘못된 DB 차단 | 통과 | `postgres` DB에서 실패, lab 미생성 |
| 읽기 전용 차단 | 코드 반영 | `transaction_read_only` 검사 |
| Chapter 07·08 전체 기준 게이트 | 통과 | 행·상태·금액·기준 신청 검사 |
| `performance_lab` 기존 존재 차단 | 통과 | 재실행 시 실제 실패 |
| 원자적 생성 | 통과 | `BEGIN` → 검사·CREATE → 검증 → `COMMIT` |
| 핵심 테이블 | 통과 | 4개 생성 |
| 생성 직후 행 | 통과 | 모두 0행 |
| named constraints | 통과 | 15 |
| NOT NULL | 통과 | 20 |
| 자동 인덱스 | 통과 | 6 |
| 후보 인덱스 | 통과 | 0 |
| 금액 타입 | 통과 | price·recorded_amount = NUMERIC(12,0) |
| 통과 메시지 | 통과 | `Chapter 10 performance lab schema validation passed` |

---

## 4. `02_performance_lab_seed.sql`

| 검증 | 기대 | 실제 상태 |
| --- | ---: | --- |
| students | 10003 | 통과 |
| instructors | 2 | 통과 |
| courses | 2003 | 통과 |
| enrollments | 100005 | 통과 |
| 신청 | 30002 | 통과 |
| 수강중 | 30001 | 통과 |
| 완료 | 20001 | 통과 |
| 취소 | 20001 | 통과 |
| 생성 학생별 신청 | 10 | 통과 |
| 생성 강의별 신청 | 50 | 통과 |
| 활성 학생·강의 중복 | 0 | 통과 |
| `recorded_amount != course.price` | 0 | 통과 |
| 후보 인덱스 | 0 | 통과 |

IDENTITY 다음 값:

```text
students = 11001
instructors = 203
courses = 3001
enrollments = 110001
```

`02`의 삽입·IDENTITY 조정·ANALYZE·검증은 하나의 트랜잭션으로 구성했습니다.

---

## 5. 기준 결과 행 수

| SQL | 기대 | PostgreSQL 16 실제 확인 |
| --- | ---: | --- |
| 이메일 검색 | 1 | 통과 |
| 제목 검색 | 1 | 통과 |
| student_id 5000 | 10 | 통과 |
| course_id 1500 | 50 | 통과 |
| course_id 1500 + 수강중 | 15 | 통과 |
| 전체 수강중 | 30001 | 통과 |

---

## 6. 기준·사후 측정 통제

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 02에서 ANALYZE | 통과 | 실제 실행 |
| 04에서 ANALYZE 재실행 없음 | 통과 | 정적 검사 |
| 03·05 SQL 동일 | 통과 | 8개 SELECT 완전 일치 자동 검사 |
| 플래너 설정 | 통과 | seqscan/indexscan/bitmapscan 모두 on 검사 |
| 후보 생성 전 | 통과 | 전체 인덱스 6 / 후보 0 |
| 후보 생성 후 | 통과 | 전체 9 / 후보 3 |
| 후보 valid/ready | 통과 | 3개 모두 확인 |
| 03 실행 후 04 순서 | 통과 | Actions 실제 실행 순서로 검증 |

`03`은 읽기 전용이므로 “학습자가 결과를 기록했음” 자체는 DB 상태로 증명하지 않습니다. 학습자는 결과를 기록하고, CI는 실행 순서를 보장합니다.

---

## 7. PostgreSQL 16 실제 기준 계획

| 조회 | 후보 전 실제 계획 | 상태 |
| --- | --- | --- |
| email 정확 일치 | UNIQUE Index Scan | 통과 |
| title 정확 일치 | Seq Scan | 통과 |
| student_id 5000 JOIN | enrollments Seq Scan | 통과 |
| course_id 1500 | Seq Scan | 통과 |
| course+status | Seq Scan | 통과 |
| status 단독 | Seq Scan | 통과 |
| ORDER BY title | Seq Scan + Sort | 통과 |
| ORDER BY title LIMIT 20 | Seq Scan + top-N Sort | 통과 |

---

## 8. PostgreSQL 16 실제 사후 계획

| 조회 | 후보 후 실제 계획 | 상태 |
| --- | --- | --- |
| title 정확 일치 | `idx_performance_courses_title` Index Scan | 통과 |
| student_id 5000 | `idx_performance_enrollments_student_id` Index Scan | 통과 |
| course_id 1500 | 복합 인덱스 Bitmap Index Scan | 통과 |
| course+status | 복합 인덱스 Bitmap Index Scan | 통과 |
| ORDER BY title | title 인덱스 Index Scan | 통과 |
| ORDER BY title LIMIT 20 | Limit → title 인덱스 Index Scan | 통과 |
| status 단독 | **Seq Scan 유지** | 통과 |

PostgreSQL 16 `status='수강중'` 실제 결과:

```text
Node Type = Seq Scan
actual rows = 30001
Rows Removed by Filter = 70004
```

따라서 PostgreSQL 16 설명과 PostgreSQL 18+ Skip Scan 설명을 분리한 현재 문서가 실제 동작과 일치합니다.

---

## 9. 대표 전후 실행 증거

한 번의 Run 4 측정값이며 고정 성능 정답으로 사용하지 않습니다.

| 조회 | 기준 | 사후 |
| --- | ---: | ---: |
| student_id 5000 JOIN | 약 9.590 ms | 약 0.073 ms |
| course_id 1500 | 약 6.906 ms | 약 0.086 ms |
| course+status | 약 6.679 ms | 약 0.039 ms |
| status 단독 | 약 9.607 ms | 약 11.049 ms |
| ORDER BY title LIMIT 20 | Seq+Sort | 약 0.021 ms / Index Scan |

판단은 시간만이 아니라 결과 행·Plan Node·Index Cond·Filter·Buffers·반복 측정을 함께 사용하도록 반영했습니다.

---

## 10. 인덱스 리뷰

| 점검 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| 전체 인덱스 | 통과 | 9 |
| 실험 후보 | 통과 | 3 |
| valid / ready | 통과 | 모두 정상 |
| 정의·컬럼 순서 | 통과 | 자동 검사 |
| 인덱스 크기 | 통과 | 실제 조회 |
| 테이블/전체 인덱스 크기 | 통과 | 실제 조회 |
| `stats_reset` | 통과 | 함께 표시 |
| idx_scan 해석 | 통과 | 사용자 SQL 횟수와 1:1 아님 명시 |
| idx_scan=0 즉시 삭제 금지 | 통과 | 기간·업무 역할 함께 검토 |
| PK·UNIQUE 역할 | 통과 | 제약조건과 연결 |
| FK 자식 인덱스 역할 | 통과 | 정확성 필수와 성능 목적 분리 |

---

## 11. 최종 정합성 판정

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| lab 행 수 | 10003/2/2003/100005 | 실제 통과 |
| 상태 분포 | 30002/30001/20001/20001 | 실제 통과 |
| 기준 결과 | 1/1/10/50/15/30001 | 실제 통과 |
| 활성 중복 | 0 | 실제 통과 |
| 금액 불일치 | 0 | 실제 통과 |
| 학생 분포 오류 | 0 | 실제 통과 |
| 강의 분포 오류 | 0 | 실제 통과 |
| 전체/후보 인덱스 | 9/3 | 실제 통과 |
| invalid 후보 | 0 | 실제 통과 |
| Chapter 07·08 보존 | 유지 | fingerprint 실제 통과 |

최종 상태 문자열:

```text
10003:2:2003:100005:9:3
```

---

## 12. 재실행·초기화 안전성

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 01 재실행 차단 | 통과 | lab 기존 존재로 실패 |
| 02 재실행 차단 | 통과 | lab 비어 있지 않아 실패 |
| 04 재실행 차단 | 통과 | 후보 0 상태가 아니라 실패 |
| reset DB 보호 | 통과 | 코드 검사 |
| reset 트랜잭션 | 통과 | 실제 실행 |
| performance_lab 삭제 | 통과 | 실제 미존재 확인 |
| course_project 보존 | 통과 | fingerprint 동일 |
| Chapter 08 검증 재실행 | 통과 | 00·03 다시 성공 |

---

## 13. 발표자료·TTS·이미지 정합성

| 점검 항목 | 상태 |
| --- | --- |
| 이론 20개 절 | 자동 통과 |
| 실습 20개 절 | 자동 통과 |
| 각 절 화면 구성·스크립트 | 자동 통과 |
| 내비게이션 제목 연결 | 자동 통과 |
| JS 문법 | 자동 통과 |
| 자산 버전 `20260809a` | 자동 통과 |
| 공통 TTS normalization 연결 | 자동 통과 |
| script content enhancer | 자동 통과 |
| Mermaid 8개 | 자동 통과 |
| SVG 8개 | 자동 통과 |
| SVG 접근성 기본 속성 | 자동 통과 |

---

## 14. 자동 검증 과정

| Run | 결과 | 의미 |
| --- | --- | --- |
| Run 1 | 실패 | 구성안의 실제 `recorded_amount` 연결 누락 발견·수정 |
| Run 2 | 실패 | validator가 주석의 CONCURRENTLY 문구를 CREATE INDEX로 오인·수정 |
| Run 3 | 실패 | SQL은 성공, psql NOTICE stderr 캡처 문제 수정 |
| Run 4 | **성공** | 정적 + PostgreSQL 16 전체 경로 성공 |

상세 기록:

```text
notes/chapter10_validation_result.md
```

---

## 15. 수동 확인으로 남긴 항목

아래 항목은 자동 검증 완료로 표시하지 않습니다.

```text
[ ] 브라우저 이론 20장 최종 시각 렌더링
[ ] 브라우저 실습 20장 최종 시각 렌더링
[ ] 단계별 강조 실제 화면 동작
[ ] 발표자 스크립트 ↔ 장표 창 실제 동기화
[ ] TTS 실제 음성 청취·발음
[ ] 모바일·프로젝터 가독성
[ ] Mermaid CLI 재생성
[ ] GitHub SVG 실제 시각 렌더링
[ ] Word·PDF·eBook 최종 출력
```

---

## 최종 판정

```text
Chapter 10은 Chapter 07·08 기준 상태를 보호하면서
100,005건 신청 데이터를 실제 PostgreSQL 16에서 생성하고,
후보 인덱스 전후의 동일 SQL 실행 계획과 결과를 재현해 검증했다.

특히 PostgreSQL 16의 status 단독 조건은 복합 인덱스 생성 뒤에도
Seq Scan으로 유지됨을 실제 확인했고, Skip Scan은 PostgreSQL 18+로 분리했다.

Validate Chapter 10 Run 4가 전체 성공했으므로
자동화 가능한 내용·SQL 정합성 검수는 완료 상태로 판정한다.
```
