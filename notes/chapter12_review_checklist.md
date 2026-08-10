# Chapter 12 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기
```

## 자동 검증 기준

```text
Workflow: Validate Chapter 12
Run: 2
Run ID: 31290291765
Commit: 1cdcaf3543cf36cff31c539ba96d7e2baa09e2e7
Conclusion: success
PostgreSQL: 16
```

---

## 1. Chapter 07·08 연속성

| 점검 항목 | 기대 | 실제 상태 |
| --- | --- | --- |
| students / instructors / courses / enrollments | 3 / 2 / 3 / 5 | PostgreSQL 통과 |
| 상태 분포 | 신청2 / 수강중1 / 완료1 / 취소1 | PostgreSQL 통과 |
| `recorded_amount` | `NUMERIC(12,0)` | PostgreSQL 통과 |
| 전체 기록 금액 | 590000 | PostgreSQL 통과 |
| 활성 신청 | 3 / 340000 | PostgreSQL 통과 |
| 취소 제외 | 4 / 440000 | PostgreSQL 통과 |
| 1001 | 완료 / 100000 | PostgreSQL 통과 |
| 1004 | 취소 / 150000 | PostgreSQL 통과 |
| 1005 | 신청 / 120000 | PostgreSQL 통과 |
| 활성 부분 고유 인덱스 | 존재 | PostgreSQL 통과 |
| 활성 중복 | 0 | PostgreSQL 통과 |
| Chapter 12 전후 원본 변경 | 없음 | fingerprint 동일 |

`recorded_amount`는 신청 시점 기록 금액이며 결제 승인액·환불 반영 순액·회계 매출이 아닙니다.

---

## 2. 생성 안전성

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| 잘못된 DB에서 01 차단 | 통과 | `postgres` DB에서 실패 |
| 읽기 전용 연결 보호 | 통과 | 코드 반영 |
| 기존 `nosql_lab` 차단 | 통과 | 코드 반영 |
| upstream amount drift 차단 | 통과 | 1005를 120001로 변경 시 01 실패 |
| drift 복원 후 재검증 | 통과 | 120000 복원 후 Chapter 08 gate 성공 |
| 생성 트랜잭션 | 통과 | BEGIN/COMMIT |
| 생성 대상 격리 | 통과 | `nosql_lab`만 생성 |
| `course_project` 변경 금지 | 통과 | 정적 검사 + fingerprint |
| transaction/performance/security lab 변경 금지 | 통과 | 정적 검사 |

---

## 3. `nosql_lab` 구조

| 항목 | 기대 | 실제 상태 |
| --- | ---: | --- |
| base table | 3 | PostgreSQL 통과 |
| 명시 제약조건 | 25 | PostgreSQL 통과 |
| NOT NULL | 26 | PostgreSQL 통과 |
| course_documents | 존재 | PostgreSQL 통과 |
| key_value_cache_examples | 존재 | PostgreSQL 통과 |
| storage_choice_cases | 존재 | PostgreSQL 통과 |
| 스키마 생성 성공 메시지 | 존재 | 확인 |

성공 메시지:

```text
Chapter 12 nosql lab schema validation passed
```

---

## 4. 원본·파생·저장소 역할

| 데이터 | 시스템 역할 | 상태 |
| --- | --- | --- |
| 수강신청·신청 당시 기록 금액 | source_of_truth | 통과 |
| 로그인 세션 | ephemeral_state | 통과 |
| 인기 강의 목록 | derived_cache | 통과 |
| 강의 태그·옵션·스냅샷 | flexible_metadata | 통과 |
| 학습 행동 | event_log | 통과 |
| 추천 관계 | relationship_index | 통과 |

원본과 파생 데이터를 섞지 않고, 파생 저장소는 원본에서 대조·재구축할 수 있도록 설명했습니다.

---

## 5. Seed 상태

| 검증 | 기대 | 실제 상태 |
| --- | ---: | --- |
| course_documents | 3 | PostgreSQL 통과 |
| cache examples | 4 | PostgreSQL 통과 |
| storage choices | 6 | PostgreSQL 통과 |
| 원본 강의 ID | 301 / 302 / 303 | PostgreSQL 통과 |
| course code | COURSE-301~303 | PostgreSQL 통과 |
| 제목·level 원본 일치 | 0건 불일치 | PostgreSQL 통과 |
| instructor snapshot 불일치 | 0 | PostgreSQL 통과 |
| copied_at 누락 | 0 | PostgreSQL 통과 |
| 필수 JSON 구조 위반 | 0 | PostgreSQL 통과 |
| 문서 version | 모두 1 | PostgreSQL 통과 |

성공 메시지:

```text
Chapter 12 nosql lab seed validation passed
```

---

## 6. 일반 컬럼과 JSONB 경계

| 항목 | 위치 | 상태 |
| --- | --- | --- |
| source_course_id | 일반 컬럼 | 통과 |
| course_code | 일반 컬럼 | 통과 |
| title | 일반 컬럼 | 통과 |
| level | 일반 컬럼 | 통과 |
| document_version | 일반 컬럼 | 통과 |
| created_at / updated_at | 일반 컬럼 | 통과 |
| tags | JSONB | 통과 |
| options | JSONB | 통과 |
| instructor_snapshot | JSONB | 통과 |
| metadata 자체 | JSONB object CHECK | 통과 |

물리적 외부 FK는 만들지 않고 `source_course_id`로 원본을 대조해 `nosql_lab`의 이동성을 유지합니다.

---

## 7. instructor_snapshot 검증

| 점검 항목 | 상태 |
| --- | --- |
| source_instructor_id 저장 | 통과 |
| name 원본 대조 | 통과 |
| specialty 원본 대조 | 통과 |
| copied_at 존재 | 통과 |
| 누락 필드 탐지 | `IS DISTINCT FROM` 방식으로 보완 |
| 최종 원본 | `course_project.instructors` |
| 복구 | 원본 ID로 재구축 |

---

## 8. JSONB 연산자

| 연산자 | 상태 |
| --- | --- |
| `->` | 통과 |
| `->>` | 통과 |
| `#>` | 통과 |
| `#>>` | 통과 |
| `?` | 통과 |
| `@>` | 통과 |
| JSON 구조 검증 책임 설명 | 통과 |

---

## 9. 낙관적 잠금

| 단계 | 기대 | 실제 상태 |
| --- | --- | --- |
| 변경 전 | certificate=true / version=1 | 통과 |
| UPDATE 조건 | course_code + version=1 + options object | 통과 |
| 영향 행 수 | 1 | 통과 |
| 트랜잭션 내부 | certificate=false / version=2 | 통과 |
| ROLLBACK 후 | certificate=true / version=1 | 통과 |
| stale version=999 | 0행 | Actions 실검증 통과 |
| stale update 후 기준 데이터 | 변경 없음 | 통과 |

성공 메시지:

```text
Chapter 12 document JSONB practice passed
```

---

## 10. Key-Value 시간 기준

| 검증 | 기대 | 실제 상태 |
| --- | ---: | --- |
| 전체 키 | 4 | PostgreSQL 통과 |
| Seed 기준 유효 | 3 | PostgreSQL 통과 |
| Seed 기준 만료 | 1 | PostgreSQL 통과 |
| 만료 정책 없음 | 1 | PostgreSQL 통과 |
| 실제 현재 유효 | 시간 의존 | 고정 정답 미사용 |
| 인기 강의 IDs | 301 / 302 / 303 | PostgreSQL 통과 |
| 기준 cache_key | 정확한 4종 | PostgreSQL 통과 |
| 자동 TTL 삭제 | 미구현 명시 | 통과 |
| eviction·메모리 저장·복제·샤딩 | 범위 밖 명시 | 통과 |

---

## 11. NoSQL 유형 설명

| 항목 | 상태 | 최종 기준 |
| --- | --- | --- |
| Key-Value | 통과 | 정확 키·TTL·미스·재생성 |
| Document | 통과 | 문서 경계·스냅샷·버전 |
| Column-Family | 통과 | 조회 문장에서 파티션·정렬 키 도출 |
| Cassandra 계열 용어 한정 | 통과 | 제품별 차이 명시 |
| Graph | 통과 | 단순 JOIN과 반복 다단계 탐색 구분 |
| NoSQL=항상 빠름 방지 | 통과 | 조회 패턴·분포·PoC 필요 |
| NoSQL=최종 일관성 단정 방지 | 통과 | 제품·설정·범위별 확인 |
| CAP 단순 표어 방지 | 통과 | 운영 조건과 요구사항으로 설명 |

---

## 12. 여러 저장소 동기화·복구

| 점검 항목 | 상태 |
| --- | --- |
| RDBMS COMMIT 후 캐시 실패 | 설명 반영 |
| 문서 스냅샷 갱신 실패 | 설명 반영 |
| 추천 인덱스 갱신 실패 | 설명 반영 |
| 이벤트 중복 | 설명 반영 |
| 변경 이벤트·CDC | 반영 |
| 재시도 | 반영 |
| 멱등성 키 | 반영 |
| 실패 대기열 | 반영 |
| 주기적 대조 | 반영 |
| 원본에서 재구축 | 반영 |

---

## 13. 저장소 선택 기록

| 점검 항목 | 기대 | 실제 상태 |
| --- | ---: | --- |
| 전체 사례 | 6 | PostgreSQL 통과 |
| system_role | 6종 | PostgreSQL 통과 |
| source_of_truth | 1 | PostgreSQL 통과 |
| adopted | 1 | PostgreSQL 통과 |
| poc_planned | 2 | PostgreSQL 통과 |
| candidate | 2 | PostgreSQL 통과 |
| hold | 1 | PostgreSQL 통과 |
| rejected | 0 | PostgreSQL 통과 |
| 필수 근거 공백 | 0 | PostgreSQL 통과 |
| Source of Truth reason | recorded_amount 의미 포함 | PostgreSQL 통과 |

---

## 14. JSONB 인덱스 후보

| 점검 항목 | 상태 | 실제 확인 |
| --- | --- | --- |
| metadata GIN | 통과 | access method=gin |
| online expression | 통과 | btree expression |
| 두 인덱스 하나의 transaction | 통과 | 06 적용 |
| 기존 인덱스 이름 충돌 차단 | 통과 | 사전 검사 |
| `IF NOT EXISTS` 미사용 | 통과 | 정의 동일성 오해 방지 |
| `indisvalid` | true | PostgreSQL 통과 |
| `indisready` | true | PostgreSQL 통과 |
| `jsonb_ops` 설명 | 통과 | 다양한 연산 |
| `jsonb_path_ops` 범위 | 통과 | `?` 미지원 명시 |
| 3행 Seq Scan 가능 | 정상 | 성능 과장 없음 |

성공 메시지:

```text
Chapter 12 JSONB index candidate validation passed
```

---

## 15. 07 최종 자동 게이트

| 검증 | 상태 |
| --- | --- |
| Chapter 07·08 canonical state 전체 | PostgreSQL 통과 |
| nosql_lab 3 / 4 / 6 | PostgreSQL 통과 |
| constraints 25 / NOT NULL 26 | PostgreSQL 통과 |
| 강의 원본 매핑 | PostgreSQL 통과 |
| instructor_snapshot | PostgreSQL 통과 |
| JSONB 구조·버전·시각 | PostgreSQL 통과 |
| COURSE-301 true/version1 | PostgreSQL 통과 |
| cache 4/3/1 + 무만료1 | PostgreSQL 통과 |
| 결정 상태 분포 | PostgreSQL 통과 |
| 인덱스 method/definition/valid/ready | PostgreSQL 통과 |
| title DRIFT 주입 | 07 실패 확인 |
| title 복원 | 07 재통과 |

통과 메시지:

```text
Chapter 12 nosql_lab validation passed
```

---

## 16. reset 원자성·격리

| 테스트 | 기대 | 실제 상태 |
| --- | --- | --- |
| 잘못된 DB | 차단 | 코드 반영 |
| 읽기 전용 | 차단 | 코드 반영 |
| 명시적 transaction | 사용 | 통과 |
| CASCADE | 미사용 | 정적 통과 |
| `keep_me` 예상 밖 객체 | reset 실패 | Actions 통과 |
| 실패한 reset의 known tables | 모두 복구 | Actions 통과 |
| keep_me | 유지 | Actions 통과 |
| 정상 reset | nosql_lab만 삭제 | Actions 통과 |
| course_project fingerprint | 전후 동일 | Actions 통과 |

성공 메시지:

```text
Chapter 12 nosql lab reset passed
```

---

## 17. 본문·워크북·발표·이미지

| 점검 항목 | 기대 | 상태 |
| --- | ---: | --- |
| 본문 번호 절 | 24 | 자동 통과 |
| 이론 발표 | 20 | 자동 통과 |
| 실습 발표 | 20 | 자동 통과 |
| 화면 구성 + 발표 스크립트 | 모든 절 | 자동 통과 |
| navigation 제목 | 1:1 | 자동 통과 |
| asset version | 20260809a | 자동 통과 |
| shared TTS | 연결 | 자동 통과 |
| script enhancer | 연결 | 자동 통과 |
| Markdown cache | no-store | 자동 통과 |
| Mermaid | 8 | 자동 통과 |
| SVG | 8 | 자동 통과 |
| Mermaid/SVG stem | 1:1 | 자동 통과 |
| SVG 접근성 속성 | role/title/desc/viewBox/width | 자동 통과 |
| 본문 SVG 참조 | 8개 | 자동 통과 |

---

## 18. 자동 검증 결과

```text
Validate Chapter 12
Run 2
Run ID 31290291765
Commit 1cdcaf3543cf36cff31c539ba96d7e2baa09e2e7
PostgreSQL 16
completed / success
```

검증 경로:

```text
wrong DB
→ Chapter 07·08 canonical build
→ source fingerprint
→ upstream amount drift failure/restore
→ Chapter 12 01→07
→ exact final state
→ stale document version
→ derived document drift failure/restore
→ source fingerprint unchanged
→ reset unexpected-object rollback
→ normal reset
→ source fingerprint unchanged
```

---

## 19. 수동 확인으로 남긴 항목

다음은 자동 통과로 처리하지 않습니다.

- [ ] 브라우저 이론 20장 최종 시각 렌더링
- [ ] 브라우저 실습 20장 최종 시각 렌더링
- [ ] semantic highlight 실제 시각 동작
- [ ] 발표자 스크립트 창 ↔ 장표 실제 조작 동기화
- [ ] TTS 실제 청취·발음
- [ ] 모바일·프로젝터 가독성
- [ ] Mermaid CLI 재생성
- [ ] GitHub SVG 육안 검수
- [ ] Word·PDF·eBook 표·코드·SVG 가독성
- [ ] 최종 28~32페이지 분량
- [ ] 별도 NoSQL 제품 실제 PoC

## 결론

```text
Chapter 12의 PostgreSQL JSONB 기반 선택 기준 실습은 실제 PostgreSQL 16에서 통과했습니다.
별도 NoSQL 제품의 성능·분산·트랜잭션 특성은 제품별 PoC 없이 단정하지 않습니다.
```

---

## 20. 2026-08-10 최종 출판 정밀 검수

- [x] Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 12 시작·최종 게이트에 추가
- [x] 현재 역할의 `ai_database_book` CREATE 권한을 `nosql_lab` DDL 전에 확인
- [x] Chapter 11 `security_lab` 존재를 Chapter 12 시작 조건으로 요구하지 않음
- [x] Key-Value의 핵심을 정확 키 조회로 정리하고 TTL을 선택 정책으로 구분
- [x] expiration과 eviction을 별도 동작으로 설명
- [x] Document DB 트랜잭션 보장을 제품·배포 구성별 확인하도록 정리
- [x] MongoDB 단일 문서 원자성·다중 문서 트랜잭션은 제품 사례로만 제시
- [x] Cassandra partition key·clustering column 설명을 공식 CQL 의미와 정렬
- [x] PostgreSQL `jsonb_ops` / `jsonb_path_ops` 지원 연산자 범위를 정밀화
- [x] 본문·구성안·워크북·코드 README·이론/실습 발표자료 정합성 반영
- [x] Chapter 12 작성 발표 스크립트 자동 확장 비활성화

최종 PostgreSQL 16 재검증 결과는 `notes/chapter12_validation_result.md`에 별도로 기록합니다.
