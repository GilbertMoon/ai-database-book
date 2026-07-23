# Chapter 07 최종 출판 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기
```

## 리뷰 목적

Chapter 07이 Chapter 01~06의 내용을 하나의 재현 가능한 프로젝트로 통합하고, 요구사항 ID·ERD·무결성·IDENTITY·상태 변경·경계/오류 테스트·AI 결정 기록과 Chapter 08 인계까지 일관되게 설명하는지 점검합니다.

---

## 1. 구조와 추적성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 프로젝트 완료 기준 | 통과 | 재현성·추적성·경계·오류 증거 중심 |
| 요구사항 ID | 통과 | `P07-R`, `P07-D`, `P07-Q`, `P07-O` 체계 |
| 요구사항 추적표 | 통과 | ID·상태·구조·검증 연결 |
| 범위와 미확정 질문 | 통과 | 결제·상태 이력·폐강·재수강 정책 구분 |
| 본문·워크북·코드·결정 기록 | 통과 | 동일 정책·ID·행 수·금액 사용 |
| Chapter 08 인계 | 통과 | 최종 신청 5건과 검산값 명시 |

---

## 2. 설계 정확성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 전용 스키마 | 통과 | `course_project` 사용 |
| 기본 테이블 | 통과 | students, instructors, courses, enrollments |
| 한 행의 의미 | 통과 | 학생·강사·강의·신청 사건 구분 |
| 관계 문장 | 통과 | 양방향 문장과 0..N/1 선택성 |
| N:M 해소 | 통과 | enrollments로 두 개의 1:N 구현 |
| 현재 가격·신청 당시 금액 | 통과 | 서로 다른 사실로 유지 |
| description 선택성 | 통과 | 요구사항과 `TEXT NULL` 일치 |
| 무료 금액 | 통과 | 0 사용, NULL과 의미 구분 |
| 취소 금액 | 통과 | 신청 당시 값 유지, 환불은 범위 제외 |

---

## 3. 무결성 규칙

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| IDENTITY PK | 통과 | 네 테이블 적용 |
| 명시적 테스트 ID | 통과 | 101/201/301/1001 체계 |
| IDENTITY 시작값 | 통과 | 104·203·304·1005/1006 조정 |
| NOT NULL | 통과 | 필수 속성과 FK 적용 |
| 이메일 공백 | 통과 | 학생·강사 `CHECK` |
| 이메일 UNIQUE | 통과 | 정확히 같은 문자열 중복 차단 |
| 공백 이름·제목·전문분야 | 통과 | `CHECK` |
| level·status | 통과 | 허용값 `CHECK` |
| 금액 | 통과 | 0 이상 `CHECK` |
| FOREIGN KEY | 통과 | 강사·학생·강의 참조 |
| RESTRICT | 통과 | 참조 중 부모 삭제 차단 |
| 활성 중복 신청 | 통과 | 부분 고유 인덱스 |

---

## 4. 상태와 변경 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 신규 신청 전 중복 확인 | 통과 | 학생 102·강의 302 활성 신청 0행 확인 |
| 예상 이전 상태 | 통과 | `WHERE id AND status` 사용 |
| RETURNING 0행 처리 | 통과 | 다음 단계 중지·원인 확인 안내 |
| 상태 CHECK 범위 | 통과 | 허용값만 보장, 전이 순서는 별도 |
| 자동 커밋 부분 실행 | 통과 | 일부 변경만 반영될 수 있음 경고 |
| 취소 처리 | 통과 | 행 삭제·금액 0 처리 없이 상태 보존 |

---

## 5. 코드 구조

| 파일 | 역할 | 상태 |
| --- | --- | --- |
| `01_course_project_schema.sql` | 스키마·테이블·제약조건·부분 인덱스 | 완료 |
| `02_course_project_seed.sql` | 기본 3/2/3/4행·IDENTITY 조정 | 완료 |
| `03_course_project_changes.sql` | 신규 신청·상태 전이·최종 IDENTITY | 완료 |
| `04_course_project_validation.sql` | 최종 3/2/3/5·관계·검산 | 완료 |
| `05_course_project_integrity_tests.sql` | 경계·오류 테스트 | 완료 |
| `reset_course_project.sql` | DB 보호 초기화 | 완료 |
| `PROJECT_DECISIONS.md` | ID·정책·AI·검증 기록 | 완료 |
| `online_course_project.sql` | 읽기 전용 최종 확인 | 완료 |
| `README.md` | 실행 순서와 안전 원칙 | 완료 |

---

## 6. 실행 위치와 초기화 안전성

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| 위치 확인 | 통과 | DB·스키마·`search_path` 통일 |
| 스키마 한정 이름 | 통과 | 모든 객체에 `course_project` 명시 |
| current_schema 해석 | 통과 | course_project일 필요 없음 설명 |
| 자동 DROP 제거 | 통과 | 생성·샘플·변경 파일에서 삭제 없음 |
| 초기화 보호 구문 | 통과 | `ai_database_book`이 아니면 예외 |
| CASCADE 미사용 | 통과 | 예상 외 객체를 조용히 삭제하지 않음 |

---

## 7. 경계 테스트

| 테스트 | 기대 결과 | 상태 |
| --- | --- | --- |
| 무료 강의 가격 0 | 성공 | 코드 반영 |
| 무료 신청 paid_amount 0 | 성공 | 코드 반영 |
| description NULL | 성공 | 코드 반영 |
| 한 글자 학생 이름 | 성공 | 코드 반영 |
| 완료 이력 뒤 재신청 | 성공 | 코드 반영 |
| 참조되지 않는 학생 삭제 | 성공 | 코드 반영 |

---

## 8. 오류 테스트

| 테스트 | 기대 결과 | 상태 |
| --- | --- | --- |
| 학생 이름 NULL·공백 | NOT NULL·CHECK 오류 | 반영 |
| 학생 이메일 공백·중복 | CHECK·UNIQUE 오류 | 반영 |
| 강사 이름·이메일·전문분야 오류 | CHECK·UNIQUE 오류 | 반영 |
| 강의 제목 공백 | CHECK 오류 | 반영 |
| 잘못된 난이도·음수 가격 | CHECK 오류 | 반영 |
| 없는 부모 참조 | FK 오류 | 반영 |
| 잘못된 상태·음수 결제 금액 | CHECK 오류 | 반영 |
| 두 번째 활성 신청 | 부분 고유 인덱스 오류 | 반영 |
| 참조 중 부모 삭제 | RESTRICT/FK 오류 | 반영 |
| 오류 후 ROLLBACK | 실패 트랜잭션 종료 | 안내 반영 |

---

## 9. 데이터 상태 정합성

### 기본 상태

| 테이블 | 기대 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 4 |

### 최종 상태

| 테이블 | 기대 행 수 |
| --- | ---: |
| students | 3 |
| instructors | 2 |
| courses | 3 |
| enrollments | 5 |

```text
1001 완료 / 100000
1004 취소 / 150000
1005 신청 / 120000
활성 중복 0건
전체 저장 금액 590000
취소 제외 금액 440000
```

본문·워크북·코드 README·결정 기록·Chapter 08이 동일 기준을 사용합니다.

---

## 10. AI 활용

| 점검 항목 | 상태 | 최종 반영 내용 |
| --- | --- | --- |
| AI 역할 | 통과 | 요구사항·ERD·DDL·테스트 초안 보조 |
| 임의 가정 방지 | 통과 | ID와 상태 구분 요청 |
| CASCADE 검토 | 통과 | 근거 없는 자동 삭제 거부 |
| 복합 UNIQUE 검토 | 통과 | 전체 이력 대신 부분 고유 인덱스 |
| IDENTITY 검토 | 통과 | 명시적 ID 뒤 시작값 요구 |
| 경계·오류 테스트 | 통과 | 두 종류 모두 요청 |
| 사람 결정 기록 | 통과 | `PROJECT_DECISIONS.md` 갱신 |

---

## 11. 도식

| 점검 항목 | 상태 | 의견 |
| --- | --- | --- |
| 기존 SVG 8종 의미 | 통과 | 프로젝트 흐름과 핵심 모델에 호환 |
| 부분 인덱스·IDENTITY 표현 | 본문 처리 | SQL·표가 더 적합 |
| GitHub 렌더링 | 수동 확인 필요 | 실제 저장소 화면 확인 |
| Word/PDF/eBook | 수동 확인 필요 | 표·SQL 줄바꿈 확인 |

---

## 12. 동기화 대상

| 파일 | 상태 |
| --- | --- |
| `book/chapter07/chapter07.md` | 완료 |
| `book/chapter07/chapter07_activity.md` | 완료 |
| `book/chapter07/chapter07_outline.md` | 완료 |
| `book/chapter07/chapter07_review_revision.md` | 완료 |
| `code/chapter07/01_course_project_schema.sql` | 완료 |
| `code/chapter07/02_course_project_seed.sql` | 완료 |
| `code/chapter07/03_course_project_changes.sql` | 완료 |
| `code/chapter07/04_course_project_validation.sql` | 완료 |
| `code/chapter07/05_course_project_integrity_tests.sql` | 완료 |
| `code/chapter07/reset_course_project.sql` | 완료 |
| `code/chapter07/PROJECT_DECISIONS.md` | 완료 |
| `code/chapter07/online_course_project.sql` | 완료 |
| `code/chapter07/README.md` | 완료 |
| 루트 `README.md` | 완료 |

---

## 13. 최종 판정

```text
Chapter 07은 IDENTITY 시작값, 초기화 차단, 무료 금액,
이메일 공백, 활성 중복 신청, 상태 기반 변경, 경계·오류 테스트와
Chapter 08 금액 검산을 최종 보완했다.

본문·워크북·SQL·결정 기록이 같은 요구사항 ID와 데이터 상태를 사용하므로
최종 출판 전 내용 검수 완료 상태로 판정한다.
```

실제 PostgreSQL 전체 순차 실행과 Word·PDF·eBook 렌더링은 별도 제작 단계에서 확인합니다.
