# Chapter 13 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기
```

## 리뷰 기준

코드에 “구현되어 있다”와 실제 PostgreSQL에서 “통과했다”를 구분합니다. 아래 자동 실행 항목은 `Validate Chapter 13` Run 2, PostgreSQL 16에서 실제 확인했습니다.

```text
Run ID: 31291233314
Commit: 5fd926149d87f6f941b7015fedbdf1361beb0b20
Conclusion: success
```

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 기대 | 상태 |
| --- | --- | --- |
| 현재 DB | `ai_database_book` | 실제 통과 |
| 잘못된 DB 실행 | 생성 전 실패 | 실제 통과 |
| course_project | 변경 없음 | fingerprint 통과 |
| Chapter 07·08 행 수 | 3/2/3/5 | 실제 통과 |
| 상태 분포 | 신청2/수강중1/완료1/취소1 | 실제 통과 |
| recorded_amount 타입 | `NUMERIC(12,0)` | 실제 통과 |
| 전체 기록 금액 | 590000 | 실제 통과 |
| 활성 신청 | 3 / 340000 | 실제 통과 |
| 취소 제외 | 4 / 440000 | 실제 통과 |
| 핵심 1001 | 완료 / 100000 | 실제 통과 |
| 핵심 1004 | 취소 / 150000 | 실제 통과 |
| 핵심 1005 | 신청 / 120000 | 실제 통과 |
| 활성 신청 인덱스 | 존재 | 실제 통과 |
| Chapter 07 명명 제약조건 | 15 | 최종 재검증 대상 |
| Chapter 07 NOT NULL 열 | 20 | 최종 재검증 대상 |
| 현재 역할 DB CREATE 권한 | 생성 전 확인 | 최종 재검증 대상 |
| transaction_lab | 변경 없음 | sentinel 통과 |
| performance_lab | 변경 없음 | sentinel 통과 |
| security_lab | 변경 없음 | sentinel 통과 |
| nosql_lab | Chapter 12 상태 보호 | fingerprint·sentinel 통과 |
| ai_review_lab | Chapter 13 전용 | 실제 통과 |

---

## 2. Chapter 12 → 13 의미 연결

| 점검 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| `recorded_amount` 명칭 | 완료 | Chapter 07·08·12와 통일 |
| `recorded_amount` 의미 | 완료 | 신청 시점 기록 금액 |
| 결제 승인액으로 오해 방지 | 완료 | 명시 |
| 환불 반영 순액으로 오해 방지 | 완료 | 명시 |
| 회계 매출로 오해 방지 | 완료 | 명시 |
| 기존 course_project 결제 원장 | 없음 유지 | Chapter 13에서 변경 안 함 |
| Chapter 13 payments | 격리 시나리오 | `ai_review_lab`에만 존재 |

---

## 3. AI 협업 흐름

| 점검 항목 | 상태 |
| --- | --- |
| Chat: 빠른 질문·대화형 지원 | 반영 |
| Work: 긴 다단계 작업·완성 산출물 | 반영 |
| Work: 장시간 다단계 산출물 | 반영 |
| Codex: 코드·테스트·명령·저장소 작업 | 반영 |
| 제품 기능은 최신 공식 안내 재확인 | 반영 |
| AI가 미확정 정책 자동 확정 금지 | 반영 |
| 사람의 최종 승인 책임 | 반영 |
| 문맥 묶음·프롬프트 계약 | 반영 |
| 수정 금지 범위 | 반영 |
| 실제 비밀·개인정보 입력 금지 | 반영 |

---

## 4. 추적 ID와 정책

| 점검 항목 | 기대 | 상태 |
| --- | --- | --- |
| 요구사항 | P13-R01~R09 | 완료 |
| 결정·범위 | P13-D01~D08 | 완료 |
| 테스트 | P13-T01~T30 | 완료 |
| 검증 단계 | P13-V01~V08 | 완료 |
| 활성 신청 | 신청·수강중 조합당 1건 | 실제 통과 |
| 완료·취소 뒤 재신청 | 허용 | 테스트 통과 |
| 이메일 | 정확 문자열 UNIQUE | 테스트 통과 |
| 이메일 대소문자 정규화 | 미확정 | T30에서 현재 정책 확인 |
| 삭제 정책 | RESTRICT | T23·T24 통과 |
| 부분 환불 | 범위 밖 | 명시 |
| 상태 전이 | 별도 정책 | 명시 |

---

## 5. 나쁜 설계 기준선

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| bad_enrollments | 3 | 실제 통과 |
| 같은 학생 email 반복 | 2행 | 실제 통과 |
| 숫자가 아닌 price | 1행 | 실제 통과 |
| `created_at='yesterday'` | 1행 | 실제 통과 |
| payment_status=`done` | 1행 | 실제 통과 |
| enrollment_status=`finished` | 1행 | 실제 통과 |
| 실제 개인정보·카드번호 | 사용 안 함 | 가상값 확인 |
| 다음 IDENTITY | 4 이상 | 실제 통과 |

---

## 6. 좋은 구조 생성

| 점검 항목 | 기대 | 상태 |
| --- | ---: | --- |
| 좋은 설계 테이블 | 5 | 실제 통과 |
| ai_review_lab 전체 테이블 | 6 | 실제 통과 |
| 좋은 설계 제약조건 | 29 | 실제 통과 |
| FK | 4 | 실제 통과 |
| 좋은 테이블 IDENTITY | 5 | 생성 COMMIT 전 통과 |
| 전체 IDENTITY | 6 | metadata/final 통과 |
| 금액 타입 | 3개 `NUMERIC(12,0)` | 실제 통과 |
| 활성 부분 고유 인덱스 | 존재 | 실제 통과 |
| 구조 생성 원자성 | 전체 또는 0 | 실제 경로 통과 |

---

## 7. Seed·기준 상태

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 3 | 실제 통과 |
| instructors | 2 | 실제 통과 |
| courses | 3 | 실제 통과 |
| enrollments | 4 | 실제 통과 |
| payments | 4 | 실제 통과 |
| 정상 JOIN | 4 | 실제 통과 |
| recorded_amount 합계 | 470000 | 실제 통과 |
| payment amount 합계 | 470000 | 실제 통과 |
| 수강 상태 | 완료2/신청1/취소1/수강중0 | 실제 통과 |
| 결제 상태 | 완료2/대기1/환불1/실패0 | 실제 통과 |
| 1002 현재 가격 | 180000 | 실제 통과 |
| 1002 신청 시점 기록 금액 | 150000 | 실제 통과 |
| 결제 참조값 | `PAY-REVIEW-TEST-*` | 실제 통과 |

---

## 8. IDENTITY

| 테이블 | 다음 값 기대 | 상태 |
| --- | ---: | --- |
| bad_enrollments | > 3 | 실제 통과 |
| students | > 103 | 실제 통과 |
| instructors | > 202 | 실제 통과 |
| courses | > 303 | 실제 통과 |
| enrollments | > 1004 | 실제 통과 |
| payments | > 9004 | 실제 통과 |

명시적 ID 뒤 `RESTART WITH`를 사용하며 테스트 롤백으로 생기는 번호 공백은 정합성 오류로 보지 않습니다.

---

## 9. 메타데이터 검증

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 정확한 테이블 집합 | 6 | 실제 통과 |
| 좋은 설계 constraints | 29 | 실제 통과 |
| 정확한 FK 서명 | 4 | 실제 통과 |
| FK 삭제 규칙 | RESTRICT/NO ACTION | 실제 통과 |
| IDENTITY | 6 | 실제 통과 |
| money type | 3 | 실제 통과 |
| `recorded_amount` | 정확히 1 | 실제 통과 |
| 이전 격리 금액 컬럼 | 없음 | 실제 통과 |
| 활성 부분 고유 인덱스 | 정확한 정의 | 실제 통과 |
| 원시 카드/비밀 전용 컬럼명 | 0 | 실제 통과 |

---

## 10. 업무 정합성

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 이메일 중복 | 0 | 실제 통과 |
| 필수 문자열 공백 | 0 | 실제 통과 |
| recorded/payment amount 불일치 | 0 | 실제 통과 |
| 결제·환불 시각 위반 | 0 | 실제 통과 |
| 고아 학생·강의·결제 | 0 | 실제 통과 |
| 활성 신청 중복 | 0 | 실제 통과 |
| 샘플 상태 조합 위반 | 0 | 실제 통과 |
| LEFT JOIN NULL 누락 | 없음 | `IS DISTINCT FROM` 적용 |
| 현재가격 ↔ recorded 차이 | 1002 한 행 | 실제 통과 |

workflow에서 9001을 `결제대기 / paid_at NULL`로 의도적으로 변경했을 때 DB CHECK는 허용하지만 `06_business_validation.sql`이 업무 상태 불일치를 탐지하는지 확인했고, 복원 후 재통과했습니다.

---

## 11. 반례·정상 경계값

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| expected_failure | 24 | 실제 통과 |
| expected_success | 6 | 실제 통과 |
| 전체 | 30 | 실제 통과 |
| passed | 30 | 실제 통과 |
| unexpected | 0 | 실제 통과 |
| 기준 행 유지 | true | 실제 통과 |
| actual SQLSTATE | 기록 | 실제 실행 |
| actual constraint | 기록 | 실제 실행 |
| table·column diagnostics | 기록 가능 시 | 실제 실행 |

주요 경계:

```text
T23 참조 중인 instructor 삭제 → FK 실패
T24 참조 중인 enrollment 삭제 → FK 실패
T25 가격0·한 글자 문자열·NULL description → 성공
T26 결제 없는 신청 → 성공
T27 완료 이력 뒤 재신청 → 성공
T28 취소 이력 뒤 재신청 → 성공
T29 결제실패·0원·시각 NULL → 성공
T30 대소문자 다른 학생 email → 현재 정확 문자열 정책에서는 성공
```

---

## 12. 최종 08 완료 게이트

| 점검 항목 | 상태 |
| --- | --- |
| Chapter 07·08 canonical source | 실제 통과 |
| 기준 행 3/3/2/3/4/4 | 실제 통과 |
| 금액 470000/470000 | 실제 통과 |
| JOIN 4 | 실제 통과 |
| 정확한 객체·제약·FK·IDENTITY | 실제 통과 |
| 문자열·고아·활성 중복 0 | 실제 통과 |
| 금액·시각·상태 위반 0 | 실제 통과 |
| 가격 차이 1002 한 행 | 실제 통과 |
| 모든 IDENTITY next > max | 실제 통과 |
| 같은 세션의 07 증거 | 실제 통과 |
| tests 30/30 | 실제 통과 |
| final notice | 실제 통과 |

통과 메시지:

```text
Chapter 13 AI review lab validation passed: tests 30/30
```

---

## 13. reset 안전성

| 점검 항목 | 상태 |
| --- | --- |
| 잘못된 DB 차단 | 코드·workflow 확인 |
| 읽기 전용 차단 | 코드 반영 |
| 명시적 자식→부모 DROP | 실제 통과 |
| CASCADE 없음 | 정적 통과 |
| 예상 밖 객체 보호 | keep_me 테스트 통과 |
| 실패 시 앞선 DROP 전체 ROLLBACK | 실제 통과 |
| 정상 reset 후 schema 제거 | 실제 통과 |
| course_project 보존 | fingerprint 통과 |
| nosql_lab 보존 | fingerprint 통과 |

---

## 14. 민감정보·결제 참조값

| 점검 항목 | 상태 |
| --- | --- |
| 원시 카드번호·CVV 미저장 | 반영 |
| 가상 payment_reference 사용 | 반영 |
| payment_reference 자동 비민감 단정 금지 | 반영 |
| 실제 보호 수준은 조직 정책 | 반영 |
| 가상 Seed 값 | `PAY-REVIEW-TEST-*` |
| 컬럼명 검사만으로 완전 증명하지 않음 | 반영 |
| 로그·프롬프트·앱 흐름 함께 검토 | 반영 |

---

## 15. 프롬프트·보고서·워크북

| 점검 항목 | 상태 |
| --- | --- |
| P13 ID | 동기화 완료 |
| 요구사항/결정/미확정 분리 | 완료 |
| 수정 대상·금지 범위 | 완료 |
| 예상 diff | 완료 |
| 실행 증거 | 완료 |
| 미실행 항목 | 완료 |
| 남은 가정 | 완료 |
| 승인 4상태 | 완료 |
| 24 failures / 6 successes | 동기화 완료 |
| 30/30 | 동기화 완료 |

---

## 16. 이미지·발표·TTS

| 점검 항목 | 기대 | 상태 |
| --- | ---: | --- |
| Mermaid | 8 | 정적 통과 |
| SVG | 8 | 정적 통과 |
| stem 대응 | 8쌍 | 정적 통과 |
| SVG role/img | 적용 | 정적 통과 |
| SVG width=100% | 적용 | 정적 통과 |
| SVG viewBox | 존재 | 정적 통과 |
| SVG title/desc | 존재 | 정적 통과 |
| 본문 SVG 참조 | 8 | 정적 통과 |
| 이론 장표 | 20 | 정적 통과 |
| 실습 장표 | 20 | 정적 통과 |
| 화면 구성·스크립트 | 모든 장표 | 정적 통과 |
| navigation 제목 1:1 | 20+20 | 정적 통과 |
| Markdown fetch | `cache=no-store` | 정적 통과 |
| shared TTS | 사용 | 정적 통과 |
| script enhancer | 연결 | 정적 통과 |
| local asset version | `20260809a` | 정적 통과 |

---

## 17. 자동 검증 결과

```text
Workflow: Validate Chapter 13
Run: 2
Run ID: 31291233314
Commit: 5fd926149d87f6f941b7015fedbdf1361beb0b20
PostgreSQL: 16
Status: completed
Conclusion: success
```

모든 주요 단계가 성공했습니다.

```text
정적 source alignment
wrong DB guard
Chapter 07·08 build
Chapter 12 handoff build
protected fingerprints
upstream drift detection
Chapter 13 01→08
exact final state
business drift detection
protected schemas unchanged
reset atomicity and isolation
```

---

## 18. 수동 확인만 남은 항목

다음 항목은 자동 검증으로 통과했다고 표시하지 않습니다.

```text
1. 이론 20장 브라우저 최종 시각 확인
2. 실습 20장 브라우저 최종 시각 확인
3. semantic/step highlight 실제 동작
4. 스크립트 창 ↔ 장표 실제 동기화
5. TTS 실제 청취·발음
6. 모바일·프로젝터 가독성
7. Mermaid CLI 재생성
8. GitHub SVG 실제 시각 렌더링
9. Word·PDF·eBook 최종 렌더링
10. 최종 페이지 수
11. 실제 조직의 개인정보·결제 참조값 보호 정책
12. 운영 DB migration·lock·backup·rollback 검토
```


---

## 20. 2026-08-10 최종 출판 재검증 항목

```text
OpenAI 공식 안내 기준 Chat / Work / Codex 역할 최신화
Chapter 07 구조 계약 15 / 20 인계 확인
DB CREATE 권한 없는 역할에서 01이 DDL 전에 실패하는지 확인
권한 실패 뒤 ai_review_lab이 생성되지 않았는지 확인
08에서 Chapter 07 구조·recorded_amount·활성 신청 정책 재확인
워크북 24 실패 + 6 성공 = 30 정합성
T30 대소문자 이메일 정상 경계값 문서 동기화
이미지 README 30개 테스트 기준 동기화
발표자 스크립트 generic enhancer 비활성화
PostgreSQL 16 전체 01→08 재실행
protected schema fingerprint·reset 원자성 재확인
```

최종 재검증 결과:

```text
Workflow: Chapter 13 definitive final validation once
Run: 1
Run ID: 31393533155
Validation workflow commit: acb30219313559cd45d71dad07e584518d691bdb
Content commit: 114c681775fffc583848c28b65d026a8cf14e485
PostgreSQL: 16
Status: completed
Conclusion: success
```

추가 항목까지 모두 실제 통과했습니다.

```text
Chapter 07 구조 계약 15 / 20
DB CREATE 권한 사전 차단 및 DDL 미실행
Chapter 13 01→08
negative/boundary 30/30
exact final state
business drift 탐지·복원
protected fingerprints·sentinels 유지
unexpected-object reset ROLLBACK
정상 reset
reset 후 Chapter 08 gate
```
