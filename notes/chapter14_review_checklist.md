# Chapter 14 최종 출판 리뷰 체크리스트

## 대상

```text
Chapter 14. SQL 데이터 분석과 Python 확장
```

## 목적

Chapter 14가 분석 질문·기간·행 단위·지표 의미를 SQL에서 확정하고, 분석 VIEW를 Python으로 확장한 뒤 실제 SQL 결과와 pandas 결과를 재현 가능한 증거로 비교하는지 점검합니다.

실제 실행하지 않은 항목은 통과로 표시하지 않습니다.

---

## 1. 장 연속성과 범위

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| Chapter 13 AI 검증 연결 | 통과 | AI 분석 코드·diff·실행 증거 검토 |
| Chapter 15 종합 프로젝트 연결 | 통과 | SQL·Python 분석을 프로젝트에 통합 |
| 데이터베이스 중심 유지 | 통과 | Python은 SQL 결과 확장 도구 |
| Vector DB·RAG 잔여 참조 | 통과 | 제거 |

---

## 2. P14 질문과 지표

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| P14-Q01 상태별 신청 | 통과 | 기간·행 단위 명시 |
| P14-Q02 월별 신청·기록 금액 | 통과 | date spine 적용 |
| P14-Q03 강의별 신청 | 통과 | `COUNT(e.id)` |
| P14-Q04 지역별 학생·신청 | 통과 | `COUNT(DISTINCT s.id)` |
| P14-Q05 완료 기간 | 통과 | 완료된 행만의 통계 |
| paid_amount 의미 | 통과 | 신청 당시 기록 금액 |
| 실제 매출 표현 제거 | 통과 | recorded_amount 용어 |
| 완료 비중·완료율 구분 | 통과 | `completed_share_pct` |

---

## 3. 분석 기간

| 항목 | 기대 | 상태 |
| --- | --- | --- |
| 시작일 | 2026-01-01 | 코드 반영 |
| 종료일 exclusive | 2026-07-01 | 코드 반영 |
| 반개방 구간 | `[start, end)` | 설명 반영 |
| 중앙 관리 | analysis_parameters VIEW | 완료 |
| SQL 집계 적용 | 모든 주요 쿼리 | 완료 |
| 분석 VIEW 적용 | 필수 | 완료 |
| Python 적용 | 필수 | 완료 |
| 기간 밖 기준 행 | 0 | 자동 판정 |

---

## 4. 생성·Seed·초기화 안전성

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| current_database 검사 | 통과 | `ai_database_book`만 허용 |
| `SHOW search_path` | 통과 | SQL 형식 통일 |
| analysis_lab 중복 생성 차단 | 통과 | 기존 스키마 시 예외 |
| 구조 생성 원자성 | 통과 | 한 트랜잭션 |
| Seed 테이블 존재 | 통과 | 실행 전 검사 |
| Seed 빈 상태 | 통과 | 재실행 차단 |
| Seed 원자성 | 통과 | BEGIN·판정·COMMIT |
| reset DB 보호 | 통과 | 잘못된 DB에서 중단 |
| reset 범위 | 통과 | VIEW·자식·부모·스키마 명시 삭제 |

---

## 5. 기준 데이터와 IDENTITY

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 8 | 코드 반영 |
| instructors | 3 | 코드 반영 |
| courses | 5 | 코드 반영 |
| enrollments | 24 | 코드 반영 |
| 분석 VIEW | 24 | 코드 반영 |
| 기록 금액 합계 | 2770000 | 자동 판정 |
| 완료 | 12 | 자동 판정 |
| students next | 109 이상 | 자동 판정 |
| instructors next | 204 이상 | 자동 판정 |
| courses next | 306 이상 | 자동 판정 |
| enrollments next | 1025 이상 | 자동 판정 |

---

## 6. 무결성·활성 신청

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| PK·FK | 통과 | 세 관계 |
| 상태 CHECK | 통과 | 신청·수강중·완료·취소 |
| 완료일 상태 CHECK | 통과 | 완료만 날짜 존재 |
| 완료일 순서 | 통과 | 완료일 >= 신청일 |
| 음수 금액 | 통과 | 차단 |
| 취소 기록 금액 | 통과 | 0 |
| 같은 날짜 원천 중복 | 통과 | 복합 UNIQUE |
| 활성 신청 중복 | 통과 | 부분 고유 인덱스 |
| 완료·취소 뒤 재신청 | 통과 | 허용 |

---

## 7. 데이터 품질

| 검증 | 기대 | 상태 |
| --- | ---: | --- |
| PK 중복 | 0 | 자동 판정 |
| 고아 학생 | 0 | 자동 판정 |
| 고아 강의 | 0 | 자동 판정 |
| 고아 강사 | 0 | 자동 판정 |
| 완료·완료일 이상 | 0 | 자동 판정 |
| 신청일 < 가입일 | 0 | 자동 판정 |
| 신청일 < 개설일 | 0 | 자동 판정 |
| 음수·취소 금액 이상 | 0 | 자동 판정 |
| 기간 밖 행 | 0 | 자동 판정 |
| 활성 신청 중복 | 0 | 자동 판정 |
| VIEW PK 중복 | 0 | 자동 판정 |

---

## 8. SQL 분석 정확성

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| 기간 필터 | 통과 | 공통 VIEW 사용 |
| JOIN 경로 | 통과 | PK·FK 기준 |
| LEFT JOIN 자식 건수 | 통과 | `COUNT(e.id)` |
| 부모 고유 수 | 통과 | `COUNT(DISTINCT ...)` |
| 기록 금액 별칭 | 통과 | `recorded_amount_sum` |
| 전체 합계 검산 | 통과 | 24·2770000 |
| NULL 의미 | 통과 | 상태와 함께 설명 |

---

## 9. date spine과 기간 비교

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| `generate_series` | 통과 | 1~6월 생성 |
| 데이터 없는 월 | 통과 | 0으로 유지 |
| `LAG` 이전 달 의미 | 통과 | 실제 이전 월 |
| pandas 월 기준표 | 통과 | 같은 6개월 |
| 그래프 점 개수 | 기대 6 | 실제 실행 대기 |

---

## 10. 상태·월별 기준값

상태:

| status | 기대 | 상태 |
| --- | ---: | --- |
| 신청 | 4 | 자동 판정 |
| 수강중 | 5 | 자동 판정 |
| 완료 | 12 | 자동 판정 |
| 취소 | 3 | 자동 판정 |

월별:

| 월 | 건수 | 기록 금액 | 상태 |
| --- | ---: | ---: | --- |
| 2026-01 | 3 | 200000 | 자동 판정 |
| 2026-02 | 4 | 520000 | 자동 판정 |
| 2026-03 | 5 | 540000 | 자동 판정 |
| 2026-04 | 4 | 550000 | 자동 판정 |
| 2026-05 | 4 | 390000 | 자동 판정 |
| 2026-06 | 4 | 570000 | 자동 판정 |

---

## 11. 완료 기간·해석

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| 완료 건수 | 12 | 자동 판정 |
| 평균 | 25 | 자동 판정 |
| 최소 | 18 | 자동 판정 |
| 최대 | 36 | 자동 판정 |
| 완료된 행만의 통계 명시 | 필수 | 통과 |
| 전체 대상 일반화 금지 | 필수 | 통과 |

---

## 12. 분석 데이터셋

| 항목 | 기대 | 상태 |
| --- | --- | --- |
| 행 단위 | 신청 1건 | 통과 |
| 기준 PK | enrollment_id | 통과 |
| 정확한 컬럼 | 17개 | 자동 판정 |
| instructor 컬럼 | 포함 | 통과 |
| 금액 컬럼 | recorded_amount | 통과 |
| 기간 적용 | 필수 | 통과 |
| 행 수 | 24 | 자동 판정 |
| PK 중복 | 0 | 자동 판정 |

---

## 13. SQL 최종 게이트

| 항목 | 상태 |
| --- | --- |
| `08_analysis_lab_validation.sql` 신규 | 완료 |
| 정확한 테이블 4개·VIEW 2개 | 자동 판정 |
| 제약조건 21개 | 자동 판정 |
| IDENTITY 4개 | 자동 판정 |
| 활성 부분 고유 인덱스 | 자동 판정 |
| 상태·월·완료 기간 | 자동 판정 |
| 품질 이상 0 | 자동 판정 |
| 실패 시 RAISE EXCEPTION | 완료 |
| 통과 NOTICE | 완료 |

---

## 14. CSV·manifest

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| UTF-8·헤더 | 설명 반영 |  |
| 출처 DB·VIEW | manifest | 완료 |
| 분석 기간 | manifest | 완료 |
| 생성 UTC 시각 | manifest | 완료 |
| 행 수 | manifest | 완료 |
| SHA-256 | manifest | 완료 |
| template | 신규 | 완료 |
| generated data Git 제외 | 통과 | `.gitignore` 유지 |

---

## 15. 접속 정보·읽기 전용

| 항목 | 상태 | 최종 반영 |
| --- | --- | --- |
| DATABASE_URL 제거 | 통과 | libpq 변수 |
| PGHOST·PGPORT | 통과 | `.env.example` |
| PGDATABASE | 통과 | ai_database_book 검사 |
| PGUSER | 통과 | 별도 계정 |
| PGPASSFILE | 통과 | 저장소 밖 |
| SQLAlchemy URL.create | 통과 | 비밀번호 코드 제외 |
| transaction_read_only | 통과 | `on` 검사 |
| VIEW 존재 검사 | 통과 | 연결 직후 확인 |

---

## 16. Python 공통 검증

| 항목 | 상태 |
| --- | --- |
| validation_utils.py 신규 | 완료 |
| 정확한 17개 컬럼 | 완료 |
| 행 수·PK 중복 | 완료 |
| 날짜 strict 변환 | 완료 |
| recorded_amount strict 숫자 | 완료 |
| completion_days strict 숫자 | 완료 |
| is_completed boolean | 완료 |
| status·is_completed 일치 | 완료 |
| 완료일·기간 일치 | 완료 |
| 기간 안의 행 | 완료 |
| `errors='coerce'` 제거 | 완료 |

---

## 17. 실제 SQL·pandas 교차 검증

| 항목 | 상태 |
| --- | --- |
| Python 하드코딩 상수만 비교하는 방식 제거 | 완료 |
| 실제 SQL 상태별 DataFrame | 완료 |
| 실제 SQL 월별 DataFrame | 완료 |
| 실제 SQL 완료 기간 DataFrame | 완료 |
| pandas 동일 집계 | 완료 |
| `assert_frame_equal` | 완료 |
| 같은 REPEATABLE READ 스냅샷 | 완료 |
| 읽기 전용 트랜잭션 | 완료 |
| CSV reference_metrics.json | 신규 완료 |
| CSV manifest 검증 | 완료 |

---

## 18. pandas·시각화

| 항목 | 상태 |
| --- | --- |
| 상태·월·강의 groupby | 완료 |
| date spine merge | 완료 |
| 피벗 | 완료 |
| 완료 기간 strict 숫자 | 완료 |
| `Agg` 백엔드 | 완료 |
| 한글 글꼴 탐색 | 완료 |
| 글꼴 없을 때 경고 | 완료 |
| Y축 0 시작 | 완료 |
| output Git 제외 | 완료 |

---

## 19. 본문·워크북·구성안 동기화

| 항목 | 상태 |
| --- | --- |
| P14 ID | 통과 |
| 기록 금액 용어 | 통과 |
| 분석 기간 | 통과 |
| 파일 순서 01→08 | 통과 |
| Python 신규 파일 | 통과 |
| 17개 VIEW 컬럼 | 통과 |
| date spine | 통과 |
| 완료 비중 명칭 | 통과 |
| SQL·pandas 직접 비교 | 통과 |
| 권장 해설 | 통과 |
| Chapter 15 연결 | 통과 |

---

## 20. 이미지

기존 SVG 8종은 다음 최종 개념과 호환됩니다.

```text
전체 분석 흐름
SQL·Python 역할
SQL 집계 흐름
데이터 품질
분석 데이터셋
PostgreSQL·Python 연결
pandas 분석
결과 교차 검증
```

SQL 명령과 세부 보안 설정을 이미지에 과도하게 중복하지 않는 원칙에 따라 변경하지 않았습니다.

---

## 21. 남은 실제 검증

```text
PostgreSQL 01→08 순차 실행
08 통과 NOTICE 확인
Python requirements 설치
읽기 전용 PostgreSQL 적재
CSV·manifest 생성과 해시 검증
PostgreSQL 경로 04_result_validation 통과
CSV 경로 04_result_validation 통과
한글 글꼴이 있는 환경과 없는 환경 확인
Windows·macOS·Linux 경로·명령 확인
GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 22. 최종 판정

```text
Chapter 14는 금액 의미, 기간 조건, date spine, 활성 신청 규칙,
시간 관계 품질, SQL 완료 게이트, 읽기 전용 연결, manifest,
strict 자료형과 실제 SQL·pandas 비교를 최종 보완했다.

본문·워크북·SQL·Python·README가 같은 분석 기간·행 단위·기준값을 사용하므로
최종 출판 전 내용 검수 완료 상태로 판정한다.
```
