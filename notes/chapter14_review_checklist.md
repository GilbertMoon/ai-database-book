# Chapter 14 최종 출판 리뷰 체크리스트

## 대상

```text
Chapter 14. SQL 데이터 분석과 Python 확장
```

## 최종 판정 기준

```text
분석 질문·기간·행 단위·지표 의미
→ SQL 품질·집계
→ 기간 제한 분석 VIEW
→ 읽기 전용 PostgreSQL 또는 출처 manifest가 있는 CSV
→ pandas strict 검증
→ 실제 SQL·pandas 교차 검증
```

자동 실행과 수동 렌더링을 구분합니다.

---

## 1. Chapter 연속성과 보호 범위

| 점검 항목 | 기대 | 상태 |
| --- | --- | --- |
| course_project 기준 상태 | 3/2/3/5 | PostgreSQL 16 실제 통과 |
| 상태 분포 | 신청2/수강중1/완료1/취소1 | 실제 통과 |
| upstream 전체 recorded_amount | 590000 | 실제 통과 |
| upstream 활성 기록 금액 | 340000 | 실제 통과 |
| upstream 취소 제외 기록 금액 | 440000 | 실제 통과 |
| key row 1001 | 완료/100000 | 실제 통과 |
| key row 1004 | 취소/150000 | 실제 통과 |
| key row 1005 | 신청/120000 | 실제 통과 |
| upstream drift 탐지 | 실패해야 함 | 실제 통과 |
| protected fingerprint | 전후 동일 | 실제 통과 |
| 다른 Chapter 스키마 sentinel | 유지 | 실제 통과 |

---

## 2. analysis_lab 격리 의미

| 점검 항목 | 상태 |
| --- | --- |
| 합성 분석 데이터임을 명시 | 완료 |
| course_project 복제·확장 운영 데이터로 오해 방지 | 완료 |
| analysis_lab만 생성·조회·reset | 완료 |
| 잘못된 DB에서 생성 차단 | 실제 통과 |
| reset에서 다른 스키마 변경 금지 | 실제 통과 |

---

## 3. 금액 의미와 타입

| 점검 항목 | 기대 | 상태 |
| --- | --- | --- |
| 물리 컬럼 | recorded_amount | 완료 |
| 타입 | NUMERIC(12,0) | 실제 통과 |
| 의미 | 신청 시점 기록 금액 | 완료 |
| paid_amount 잔존 | 0 | 자동 정적 통과 |
| 취소 후 금액 0 덮어쓰기 | 금지 | 실제 통과 |
| 취소 1003 | 150000 | 실제 통과 |
| 취소 1011 | 140000 | 실제 통과 |
| 취소 1019 | 150000 | 실제 통과 |
| 전체 recorded_amount | 3210000 | 실제 통과 |
| 결제·환불·회계 매출로 오해 금지 | 명시 | 완료 |

---

## 4. 구조·제약·IDENTITY

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| BASE TABLE | 4 | 실제 통과 |
| VIEW | 2 | 실제 통과 |
| PK·FK·CHECK·UNIQUE | 20개 | 실제 통과 |
| IDENTITY id | 4 | 실제 통과 |
| 활성 신청 부분 고유 인덱스 | 존재 | 실제 통과 |
| students 다음 ID | 109 이상 | 실제 통과 |
| instructors 다음 ID | 204 이상 | 실제 통과 |
| courses 다음 ID | 306 이상 | 실제 통과 |
| enrollments 다음 ID | 1025 이상 | 실제 통과 |
| BASE TABLE과 VIEW 메타데이터 구분 | table_type 적용 | 완료 |

---

## 5. Seed 기준 데이터

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 8 | 실제 통과 |
| instructors | 3 | 실제 통과 |
| courses | 5 | 실제 통과 |
| enrollments | 24 | 실제 통과 |
| dataset VIEW | 24 | 실제 통과 |
| 완료 | 12 | 실제 통과 |
| 수강중 | 5 | 실제 통과 |
| 신청 | 4 | 실제 통과 |
| 취소 | 3 | 실제 통과 |
| 신청일 < 가입일 | 0 | 실제 통과 |
| 신청일 < 개설일 | 0 | 실제 통과 |
| 완료일 < 신청일 | 0 | 실제 통과 |
| Seed COMMIT 전 시간 관계 게이트 | 존재 | 실제 통과 |

Seed 검토 중 발견한 1005·1009의 가입일/신청일 역전은 검증기를 약화하지 않고 합성 Seed 날짜를 정상화했습니다.

---

## 6. 분석 질문·기간·행 단위

| 항목 | 기대 | 상태 |
| --- | --- | --- |
| P14-Q01 | 상태별 신청 건수 | 완료 |
| P14-Q02 | 월별 신청 수·recorded_amount | 완료 |
| P14-Q03 | 강의별 신청 건수 | 완료 |
| P14-Q04 | 지역별 학생·신청 건수 | 완료 |
| P14-Q05 | 완료 신청의 완료 기간 | 완료 |
| 기간 | [2026-01-01, 2026-07-01) | 실제 통과 |
| 날짜 기준 | enrolled_at | 완료 |
| 행 단위 | 수강신청 1건 | 완료 |

---

## 7. 월별 기준값

| 월 | 신청 수 | recorded_amount | 상태 |
| --- | ---: | ---: | --- |
| 2026-01 | 3 | 350000 | 실제 통과 |
| 2026-02 | 4 | 520000 | 실제 통과 |
| 2026-03 | 5 | 680000 | 실제 통과 |
| 2026-04 | 4 | 550000 | 실제 통과 |
| 2026-05 | 4 | 540000 | 실제 통과 |
| 2026-06 | 4 | 570000 | 실제 통과 |
| 합계 | 24 | 3210000 | 실제 통과 |

출판 본문·워크북·README·실습 강의안의 과거 값도 전용 publishing CI로 별도 확인합니다.

---

## 8. 강의·지역 기준값

| 항목 | 기록 금액 | 상태 |
| --- | ---: | --- |
| 301 데이터베이스 입문 | 600000 | 출판값 정렬 |
| 302 SQL 데이터 분석 | 520000 | 출판값 정렬 |
| 303 파이썬 데이터 분석 | 750000 | 출판값 정렬 |
| 304 데이터 시각화 | 700000 | 출판값 정렬 |
| 305 AI 활용 데이터 설계 | 640000 | 출판값 정렬 |
| 서울 | 1210000 | 출판값 정렬 |
| 경기 | 830000 | 출판값 정렬 |
| 부산 | 770000 | 출판값 정렬 |
| 대구 | 400000 | 출판값 정렬 |

---

## 9. 데이터 품질

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| PK 중복 | 0 | 실제 통과 |
| dataset enrollment_id 중복 | 0 | 실제 통과 |
| 고아 student/course/instructor | 0 | 실제 통과 |
| 완료 상태·완료일 불일치 | 0 | 실제 통과 |
| 완료일 < 신청일 | 0 | 실제 통과 |
| 신청일 < 가입일 | 0 | 실제 통과 |
| 신청일 < 개설일 | 0 | 실제 통과 |
| 음수 recorded_amount | 0 | 실제 통과 |
| 취소 후 recorded_amount 0 덮어쓰기 | 0 | 실제 통과 |
| 분석 기간 밖 기준 행 | 0 | 실제 통과 |
| 활성 신청 중복 | 0 | 실제 통과 |

---

## 10. 분석 VIEW

| 점검 항목 | 기대 | 상태 |
| --- | --- | --- |
| enrollment_analysis_dataset | 존재 | 실제 통과 |
| 정확한 컬럼 수 | 17 | 실제 통과 |
| 행 수 | 24 | 실제 통과 |
| enrollment_id 고유 | 24 | 실제 통과 |
| recorded_amount 합계 | 3210000 | 실제 통과 |
| 생성 트랜잭션 | BEGIN/COMMIT | 완료 |
| COMMIT 전 완료 게이트 | 존재 | 실제 통과 |

---

## 11. 완료 기간

| 지표 | 기대 | 상태 |
| --- | ---: | --- |
| 완료 건수 | 12 | 실제 통과 |
| 평균 | 25.00일 | 실제 통과 |
| 최소 | 18일 | 실제 통과 |
| 최대 | 36일 | 실제 통과 |
| Python completion_days 재계산 | DB 날짜 차이와 동일 | 실제 통과 |

---

## 12. Python strict 검증

| 점검 항목 | 상태 |
| --- | --- |
| 정확한 17개 컬럼 | 실제 통과 |
| ID 4종 정수·NULL 금지 | 실제 통과 |
| 날짜 errors=raise | 실제 통과 |
| recorded_amount 숫자·정수 단위·NULL 금지 | 실제 통과 |
| completion_days 숫자 | 실제 통과 |
| is_completed boolean | 실제 통과 |
| 상태와 완료 필드 일치 | 실제 통과 |
| completion_days = completed_at-enrolled_at | 실제 통과 |
| 분석 기간 검증 | 실제 통과 |

---

## 13. PostgreSQL 직접 경로

| 점검 항목 | 상태 |
| --- | --- |
| PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSFILE | 적용 |
| 현재 DB ai_database_book | 실제 통과 |
| transaction_read_only = on | 실제 통과 |
| REPEATABLE READ, READ ONLY | 실제 통과 |
| SQL 상태별 ↔ pandas | assert_frame_equal 통과 |
| SQL 월별 ↔ pandas | assert_frame_equal 통과 |
| SQL 완료기간 ↔ pandas | assert_frame_equal 통과 |
| 잘못된 Python DB 차단 | 실제 통과 |

---

## 14. CSV + manifest 경로

| 점검 항목 | 상태 |
| --- | --- |
| CSV export | 실제 통과 |
| row_count 24 | 실제 통과 |
| expected_recorded_amount_sum 3210000 예시 명시 | 완료 |
| 분석 기간 manifest | 실제 통과 |
| SHA-256 | 실제 통과 |
| 변조 CSV 탐지 | 실제 실패 확인 |
| reference_metrics.json | 3210000 기준 |
| CSV pandas 분석 | 실제 통과 |
| CSV SQL 기준값 비교 | 실제 통과 |

---

## 15. 시각화

| 점검 항목 | 상태 |
| --- | --- |
| matplotlib Agg 백엔드 | 실제 PNG 생성 통과 |
| PostgreSQL 경로 PNG | 생성 통과 |
| CSV 경로 PNG | 생성 통과 |
| 그래프가 검증을 대신하지 않음 | 명시 |
| OS별 한글 글꼴 육안 확인 | 수동 확인 필요 |

---

## 16. reset·격리

| 점검 항목 | 상태 |
| --- | --- |
| CASCADE 미사용 | 자동 통과 |
| 예상 객체만 삭제 | 실제 통과 |
| 예상 밖 keep_me 존재 시 중단 | 실제 통과 |
| 실패 후 24행 보존 | 실제 통과 |
| 정상 reset 후 analysis_lab 제거 | 실제 통과 |
| course_project fingerprint 유지 | 실제 통과 |
| 다른 Chapter sentinel 유지 | 실제 통과 |

---

## 17. 발표·TTS·시각 자료

| 점검 항목 | 상태 |
| --- | --- |
| 이론 20장 | 자동 통과 |
| 실습 20장 | 자동 통과 |
| 화면 구성·발표 스크립트 | 자동 통과 |
| navigation 제목 순서 | 자동 통과 |
| asset version | 20260809a |
| shared PresentationTTS.normalize | 자동 통과 |
| script_content_enhancer | 자동 통과 |
| Markdown cache=no-store | 자동 통과 |
| Mermaid | 8 |
| SVG | 8 |
| SVG role/img/viewBox/title/desc | 자동 통과 |
| 실제 브라우저 단계 이동 | 수동 확인 필요 |
| 실제 TTS 청취 | 수동 확인 필요 |

---

## 18. 자동 검증 기록

전체 SQL·Python 실행:

```text
Workflow: Validate Chapter 14
Run: 5
Run ID: 31293106457
Commit: 9084886fb6998c8356d9df1af55ae6c88db3b23d
PostgreSQL: 16
Conclusion: success
```

발표 정적/navigation:

```text
Workflow: Validate Chapter 14 navigation
Run: 10
Run ID: 31293106459
Conclusion: success
```

출판 기준값:

```text
Workflow: Validate Chapter 14 publishing evidence
Run: 2
Run ID: 31293074025
Conclusion: success
```

---

## 19. 남은 수동 확인

```text
1. 이론 20장 브라우저 최종 육안 렌더링
2. 실습 20장 브라우저 최종 육안 렌더링
3. semantic highlight/step 실제 조작
4. 발표 창 ↔ 스크립트 창 실제 동기화
5. 실제 TTS 청취·발음
6. 모바일·프로젝터 가독성
7. OS별 한글 그래프 글꼴 육안 확인
8. 필요 시 Mermaid CLI 실제 재생성
9. SVG GitHub/브라우저 육안 확인
10. Word·PDF·eBook 최종 렌더링
11. 출판 페이지 수 최종 확인
```

자동 실행하지 않은 항목은 통과로 표시하지 않습니다.
