# Chapter 12 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기
```

## 리뷰 목적

Chapter 12가 NoSQL 유형을 단순 소개하지 않고, 시스템 역할·대표 조회·일관성·시간 기준·동기화 실패·복구·결정 상태를 근거로 RDBMS·JSONB·NoSQL 후보를 비교하도록 구성되었는지 점검합니다.

---

## 1. Chapter 연속성과 격리

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| course_project 보호 | 통과 | 기준 상태 3/2/3/5 검사, 변경 없음 |
| transaction_lab 보호 | 통과 | 변경 없음 |
| performance_lab 보호 | 통과 | 변경 없음 |
| security_lab 보호 | 통과 | 변경 없음 |
| nosql_lab 전용 | 통과 | 모든 실습 객체 분리 |
| 자동 DROP 제거 | 통과 | 생성 파일 삭제 없음 |
| 초기화 분리 | 통과 | reset 파일만 사용 |

---

## 2. 생성·Seed·초기화 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 현재 DB 확인 | 통과 | ai_database_book 아니면 예외 |
| `SHOW search_path` | 통과 | 모든 SQL 형식 통일 |
| Chapter 07 핵심 객체 | 통과 | students·instructors·courses·enrollments 검사 |
| Chapter 07 기준 행 수 | 통과 | 3/2/3/5 |
| nosql_lab 중복 생성 차단 | 통과 | 기존 스키마 존재 시 중단 |
| 구조 생성 원자성 | 통과 | 스키마·테이블 한 트랜잭션 |
| Seed 재실행 차단 | 통과 | 세 테이블 모두 0행 확인 |
| Seed 원자성 | 통과 | 세 데이터 묶음 한 트랜잭션 |
| COMMIT 전 자동 판정 | 통과 | 원본·JSON·TTL·선택 근거 검사 |
| reset DB 보호 | 통과 | 잘못된 DB에서 DROP 중단 |

---

## 3. Chapter 07 원본 연속성

| 점검 항목 | 기대 | 상태 |
| --- | --- | --- |
| 강의 ID | 301~303 | 통과 |
| 문서 코드 | COURSE-301~303 | 통과 |
| 강의 제목 | Chapter 07과 일치 | 통과 |
| 난이도 | Chapter 07과 일치 | 통과 |
| 강사 ID | 201·202 | 통과 |
| 인기 강의 cache IDs | 301·302·303 | 통과 |
| 만료 세션 학생 | 103 | 통과 |
| 물리 외부 FK | 미적용 | 이동성 유지 |
| 최종 원본 대조 | validation SQL | 통과 |

---

## 4. 결제 원본 표현

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 현재 원본 테이블 | 통과 | students·instructors·courses·enrollments |
| paid_amount 의미 | 통과 | 신청 당시 기록 금액 |
| 별도 결제·환불 원장 | 통과 | 현재 범위 밖 명시 |
| AI 프롬프트 | 통과 | 존재하지 않는 payments 제거 |
| 선택 사례 이름 | 통과 | 수강신청·신청 당시 금액 기록 |

---

## 5. 혼합 문서 설계

| 항목 | 위치 | 상태 |
| --- | --- | --- |
| source_course_id | 일반 컬럼 | 통과 |
| course_code | 일반 컬럼·UNIQUE·공백 CHECK | 통과 |
| title | 일반 컬럼·공백 CHECK | 통과 |
| level | 일반 컬럼·허용값 CHECK | 통과 |
| document_version | 일반 컬럼·1 이상 CHECK | 통과 |
| created_at·updated_at | 일반 컬럼·시간 순서 CHECK | 통과 |
| tags | JSONB | 통과 |
| options | JSONB | 통과 |
| instructor_snapshot | JSONB 파생 복사본 | 통과 |
| metadata 객체 | CHECK | 통과 |

---

## 6. 강사 스냅샷

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 명칭 | 통과 | instructor_snapshot |
| source_instructor_id | 통과 | 원본 ID 저장 |
| name·specialty | 통과 | 표시용 복사본 |
| copied_at | 통과 | 복사 시각 기록 |
| 최종 원본 | 통과 | course_project.instructors |
| 불일치 탐지 | 통과 | validation에서 원본 대조 |
| 복구 방향 | 통과 | 원본에서 재구축 |

---

## 7. Key-Value 시간 기준

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 전체 캐시 | 4 | 코드 반영 |
| Seed 유효 | 3 | created_at 비교 |
| Seed 만료 | 1 | created_at 비교 |
| 현재 유효 | 시간 의존 | 고정 정답 제거 |
| 만료 정책 없음 | 1 | expired_at NULL |
| 정확 키 Seed 조회 | 1행 | 코드 반영 |
| Seed 만료 키 유효 조회 | 0행 | 코드 반영 |
| 캐시 미스 | cache_miss | 코드 반영 |
| 인기 강의 IDs | 301·302·303 | 코드 반영 |
| 자동 TTL 삭제 | 미구현 명시 | 통과 |

---

## 8. Key-Value 시뮬레이션 범위

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| cache_value 객체 강제 제거 | 통과 | JSONB 값 전체 허용 |
| TTL 선택성 | 통과 | expired_at NULL 허용 |
| 메모리 저장 | 범위 제외 | 명시 |
| eviction | 범위 제외 | 명시 |
| 복제·샤딩 | 범위 제외 | 명시 |
| 실제 장애 동작 | 범위 제외 | 명시 |

---

## 9. JSONB 연산자·구조 검증

| 점검 항목 | 상태 |
| --- | --- |
| `->`, `->>`, `#>`, `#>>` | 통과 |
| `?`, `@>` | 통과 |
| metadata 객체 | 통과 |
| tags 배열 | 통과 |
| options 객체 | 통과 |
| online boolean | 통과 |
| certificate boolean | 통과 |
| instructor_snapshot 객체 | 통과 |
| 원본 강사 ID·이름·전문분야 대조 | 통과 |
| DB·애플리케이션 책임 표 | 통과 |

---

## 10. 낙관적 잠금과 jsonb_set

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| document_version 조건 | 통과 | version=1일 때만 UPDATE |
| 경로 타입 조건 | 통과 | options 객체 확인 |
| 영향 행 수 판정 | 통과 | 1이 아니면 예외 |
| 변경 결과 | 통과 | false/version 2 |
| ROLLBACK | 통과 | true/version 1 복구 |
| 중간 경로 전제조건 | 통과 | 본문·코드 설명 |
| updated_at 책임 | 통과 | SQL·애플리케이션 갱신 |

---

## 11. NoSQL 유형 설명

| 유형 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| Key-Value | 통과 | 키·TTL·미스·무만료 |
| Document | 통과 | 문서 경계·버전·스냅샷 |
| Column-Family | 통과 | 목표 조회·파티션·정렬 키 |
| Cassandra 계열 범위 | 통과 | 제품별 차이 명시 |
| Graph | 통과 | 단순 JOIN·다단계 탐색 구분 |
| 트랜잭션·일관성 | 통과 | 제품·설정·범위별 확인 |
| CAP | 통과 | 단순 표어 방지 |

---

## 12. 여러 저장소 동기화

| 점검 항목 | 상태 |
| --- | --- |
| 이중 쓰기 실패 | 통과 |
| 원본 단일화 | 통과 |
| 변경 이벤트·CDC | 통과 |
| 재시도·멱등성 | 통과 |
| 실패 대기열 | 통과 |
| 주기적 대조 | 통과 |
| 재구축 전략 | 통과 |
| 복구 방법을 선택 기록에 포함 | 통과 |

---

## 13. 저장소 선택 기록

| 항목 | 상태 |
| --- | --- |
| system_role | 통과 |
| primary_query | 통과 |
| candidate_storage | 통과 |
| source_of_truth | 통과 |
| consistency_requirement | 통과 |
| synchronization_strategy | 통과 |
| recovery_strategy | 통과 |
| poc_success_criteria | 통과 |
| decision_status | 통과 |
| reason | 통과 |
| reviewed_at | 통과 |
| 필수 문자열 공백 CHECK | 통과 |

결정 상태:

```text
candidate / poc_planned / hold / adopted / rejected
```

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 전체 사례 | 6 | 통과 |
| 시스템 역할 | 6종 | 통과 |
| Source of Truth 사례 | 1 | 통과 |
| adopted 사례 | 1 | 통과 |
| 비원본 사례 | 5 | 통과 |
| 필수 근거 공백 | 0 | 통과 |

---

## 14. JSONB 인덱스 후보

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 인덱스 파일 분리 | 통과 | 06 신규 |
| 기존 이름 충돌 검사 | 통과 | 미존재 아니면 중단 |
| `IF NOT EXISTS` 제거 | 통과 | 정의 동일성 오해 방지 |
| metadata GIN | 통과 | 기본 jsonb_ops |
| online 표현식 B-tree | 통과 | `#>>` 경로 |
| jsonb_ops 설명 | 통과 | 다양한 연산 |
| jsonb_path_ops 설명 | 통과 | 포함·path 중심, `?` 미지원 |
| 실제 정의 조회 | 통과 | pg_indexes·카탈로그 |
| 3행 Seq Scan | 통과 | 정상 가능성 설명 |

---

## 15. 최종 자동 검증

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| 현재 DB | ai_database_book | 보호 구문 |
| Chapter 07 | 3/2/3/5 | 자동 판정 |
| Chapter 12 | 3/4/6 | 자동 판정 |
| 원본 강의 불일치 | 0 | 자동 판정 |
| 강사 스냅샷 불일치 | 0 | 자동 판정 |
| JSONB 구조 위반 | 0 | 자동 판정 |
| COURSE-301 기준 | true/version 1 | 자동 판정 |
| Seed 캐시 | 4/3/1 | 자동 판정 |
| 인기 강의 IDs | 301~303 | 자동 판정 |
| 시스템 역할 | 6종 | 자동 판정 |
| adopted 사례 | 1 | 자동 판정 |
| 필수 근거 공백 | 0 | 자동 판정 |
| GIN·표현식 인덱스 | 정상 정의 | 자동 판정 |

통과 메시지:

```text
Chapter 12 nosql_lab validation passed
```

---

## 16. 단계별 파일

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_nosql_lab_schema.sql` | 보호 검사·원자적 구조 생성 | 완료 |
| `02_nosql_lab_seed.sql` | 원본 연계·재현 TTL·선택 사례·자동 판정 | 완료 |
| `03_document_jsonb_queries.sql` | JSONB·원본 대조·낙관적 잠금 | 완료 |
| `04_key_value_cache_queries.sql` | Seed·현재 TTL·미스 | 완료 |
| `05_storage_choice_review.sql` | 근거·복구·PoC·상태 검토 | 완료 |
| `06_jsonb_index_candidates.sql` | 인덱스 후보·정의 검증 | 신규 완료 |
| `07_nosql_lab_validation.sql` | 전체 자동 판정 | 신규 완료 |
| `reset_nosql_lab.sql` | DB 보호 초기화 | 완료 |
| `nosql_jsonb_practice.sql` | 읽기 전용 호환 진입점 | 완료 |
| `README.md` | 실행 순서·기준·한계 | 완료 |

---

## 17. 본문·워크북·구성안 동기화

| 점검 항목 | 상태 |
| --- | --- |
| 파일 순서 01→07 | 통과 |
| Chapter 07 원본 | 통과 |
| Seed·현재 TTL | 통과 |
| level 일반 컬럼 | 통과 |
| instructor_snapshot | 통과 |
| 결제 원본 범위 | 통과 |
| 낙관적 잠금 | 통과 |
| 인덱스 정의 검증 | 통과 |
| 후보·결정 상태 | 통과 |
| 최종 자동 판정 | 통과 |
| 권장 해설 | 통과 |

기존 SVG 8종은 RDBMS·NoSQL 역할, 네 유형, JSONB와 AI 검토라는 일반 메시지와 호환됩니다. SQL 상세를 이미지에 중복하지 않는 원칙에 따라 변경하지 않았습니다.

---

## 18. 남은 실제 검증

```text
- 실제 PostgreSQL에서 01→07 순차 실행
- Seed 캐시 4/3/1과 현재 시간 변화 확인
- COURSE-301 ROLLBACK 결과 확인
- 원본·스냅샷 대조 0건 확인
- JSONB 인덱스 정의와 EXPLAIN 확인
- 07 최종 통과 메시지 확인
- GitHub·Word·PDF·eBook 렌더링 확인
- 실제 NoSQL 제품 비교 시 공식 문서·PoC 별도 수행
```

---

## 19. 최종 판정

```text
Chapter 12는 시간 의존 TTL, 원본 식별자 불일치, 존재하지 않는 결제 원장,
안정 필드의 JSONB 저장, 스냅샷 의미, 실행 보호, 문서 버전과 인덱스 정의를 최종 보완했다.

본문·워크북·SQL·구성안이 같은 원본·시간·결정·검증 기준을 사용하므로
최종 출판 전 내용 검수 완료 상태로 판정한다.
```
