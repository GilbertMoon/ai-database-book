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
→ 읽기 전용 DB 또는 출처 manifest가 있는 CSV
→ pandas strict 검증
→ 실제 SQL·pandas 교차 검증
```

실제 실행하지 않은 항목은 통과로 표시하지 않습니다.

---

## 1. 분석 질문과 용어

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| P14-Q01~Q05 | 본문·SQL·워크북 일치 | 완료 |
| 분석 기간 | `[2026-01-01, 2026-07-01)` | 완료 |
| 행 단위 | 수강신청 1건 | 완료 |
| `paid_amount` 의미 | 신청 당시 기록 금액 | 완료 |
| 분석 금액 이름 | `recorded_amount` | 완료 |
| 실제 매출 표현 | 사용하지 않음 | 완료 |
| 완료 상태 비중 | `completed_share_pct` | 완료 |
| 코호트 완료율과 구분 | 필수 | 완료 |

---

## 2. SQL 실행 안전성

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| 현재 DB 검사 | `ai_database_book` | 완료 |
| `SHOW search_path` | 모든 SQL | 완료 |
| 기존 `analysis_lab` 차단 | 예외 | 완료 |
| 구조 생성 | 단일 트랜잭션 | 완료 |
| Seed 재실행 차단 | 빈 테이블 검사 | 완료 |
| Seed 입력·판정 | 단일 트랜잭션 | 완료 |
| reset | 올바른 DB에서 명시 객체만 삭제 | 완료 |

---

## 3. 구조·무결성·IDENTITY

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| 테이블·VIEW | 4개·2개 | 자동 판정 |
| PK·FK·CHECK·UNIQUE | 21개 | 자동 판정 |
| IDENTITY | 4개 | 자동 판정 |
| 다음 ID | 109·204·306·1025 이상 | 자동 판정 |
| 활성 신청 중복 | 부분 고유 인덱스 | 완료 |
| 동일 날짜 원천 중복 | 복합 UNIQUE | 완료 |
| 완료·취소 뒤 재신청 | 허용 | 완료 |

---

## 4. 기준 데이터와 SQL 결과

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| students | 8 | 자동 판정 |
| instructors | 3 | 자동 판정 |
| courses | 5 | 자동 판정 |
| enrollments | 24 | 자동 판정 |
| 분석 VIEW | 24 | 자동 판정 |
| 기록 금액 합계 | 2770000 | 자동 판정 |
| 신청·수강중·완료·취소 | 4·5·12·3 | 자동 판정 |
| 월별 건수 | 3·4·5·4·4·4 | 자동 판정 |
| 완료 기간 | 12·25·18·36 | 자동 판정 |

---

## 5. 데이터 품질

| 점검 | 기대 | 상태 |
| --- | ---: | --- |
| PK·VIEW 중복 | 0 | 자동 판정 |
| 고아 학생·강의·강사 | 0 | 자동 판정 |
| 완료 상태·날짜 이상 | 0 | 자동 판정 |
| 신청일 < 가입일 | 0 | 자동 판정 |
| 신청일 < 개설일 | 0 | 자동 판정 |
| 음수·취소 금액 이상 | 0 | 자동 판정 |
| 기간 밖 행 | 0 | 자동 판정 |
| 활성 신청 중복 | 0 | 자동 판정 |

---

## 6. 기간 분석

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| 기간 중앙 관리 | `analysis_parameters` | 완료 |
| 모든 주요 SQL 기간 적용 | 필수 | 완료 |
| 분석 VIEW 기간 적용 | 필수 | 완료 |
| date spine | 1~6월 유지 | 완료 |
| 빈 월 0건 | 필수 | 완료 |
| `LAG` 이전 행 | 실제 이전 달 | 완료 |
| pandas date spine | SQL과 동일 | 완료 |

---

## 7. 분석 데이터셋

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| 정확한 컬럼 | 17개 | 자동 판정 |
| 강사 컬럼 | 포함 | 완료 |
| 금액 컬럼 | `recorded_amount` | 완료 |
| 한 행 | enrollment_id 1개 | 완료 |
| strict 자료형 | 날짜·숫자·boolean | 완료 |
| 상태·완료 규칙 | 일치 | 완료 |

---

## 8. SQL 최종 게이트

| 점검 | 상태 |
| --- | --- |
| `08_analysis_lab_validation.sql` | 신규 완료 |
| 실패 시 `RAISE EXCEPTION` | 완료 |
| 통과 NOTICE | `Chapter 14 analysis_lab validation passed` |
| 객체·컬럼·제약·인덱스 | 자동 판정 |
| 상태·월·기간·품질 | 자동 판정 |
| IDENTITY 다음 값 | 자동 판정 |

---

## 9. 접속 정보와 DB 연결

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| `DATABASE_URL` 방식 | 제거 | 완료 |
| libpq 변수 | PGHOST·PGPORT·PGDATABASE·PGUSER | 완료 |
| password file | `PGPASSFILE` | 완료 |
| 실제 비밀번호 | 저장소 밖 | 완료 |
| SQLAlchemy 구성 | `URL.create()` | 완료 |
| 올바른 DB | 코드 검사 | 완료 |
| VIEW 존재 | 코드 검사 | 완료 |
| 읽기 전용 | `transaction_read_only=on` | 완료 |

---

## 10. CSV·manifest

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| CSV 출처 DB·VIEW | manifest | 완료 |
| 분석 기간 | manifest | 완료 |
| 생성 시각 | UTC | 완료 |
| 행 수 | 24 | 완료 |
| SHA-256 | 검증 | 완료 |
| example manifest | 신규 | 완료 |
| SQL 기준 결과 JSON | 신규 | 완료 |
| 생성 데이터 Git 제외 | `.gitignore` | 완료 |

---

## 11. Python 공통 검증

| 점검 | 상태 |
| --- | --- |
| `validation_utils.py` | 신규 완료 |
| 정확한 컬럼 집합 | 완료 |
| 행 수·고유 ID | 완료 |
| 날짜 strict 변환 | 완료 |
| 기록 금액 strict 숫자 | 완료 |
| 완료 기간 strict 숫자 | 완료 |
| boolean 정규화 | 완료 |
| `errors='coerce'` 제거 | 완료 |
| 임의 `dropna`·중복 제거 없음 | 완료 |

---

## 12. 실제 SQL·pandas 교차 검증

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| 실제 SQL 상태별 결과 | DataFrame | 완료 |
| 실제 SQL 월별 결과 | date spine DataFrame | 완료 |
| 실제 SQL 완료 기간 | DataFrame | 완료 |
| pandas 동일 집계 | 필수 | 완료 |
| 같은 스냅샷 | REPEATABLE READ | 완료 |
| 읽기 전용 트랜잭션 | 필수 | 완료 |
| 구조 비교 | `assert_frame_equal` | 완료 |
| CSV 경로 | manifest + reference JSON | 완료 |

---

## 13. 시각화와 이미지

| 점검 | 기대 | 상태 |
| --- | --- | --- |
| matplotlib 백엔드 | `Agg` | 완료 |
| 한글 글꼴 | 탐색·없으면 경고 | 완료 |
| Y축 | 0부터 시작 | 완료 |
| 그래프 저장 경로 | Git 제외 | 완료 |
| 연결 Mermaid | libpq 변수·PGPASSFILE | 수정 완료 |
| 연결 SVG | 읽기 전용·URL.create·17개 컬럼 | 수정 완료 |
| 나머지 SVG 7종 | 최종 개념과 호환 | 유지 |

---

## 14. 문서 동기화

| 점검 | 상태 |
| --- | --- |
| 본문·워크북·구성안 P14 ID | 통과 |
| 기록 금액 용어 | 통과 |
| SQL 01→08 순서 | 통과 |
| Python 신규 파일 목록 | 통과 |
| 분석 VIEW 17개 컬럼 | 통과 |
| date spine·완료 비중 | 통과 |
| SQL·pandas 직접 비교 | 통과 |
| 권장 해설 | 통과 |
| Chapter 15 연결 | 통과 |
| 루트 README 상태 | 통과 |

---

## 15. 남은 실제 검증

```text
PostgreSQL에서 01→08 순차 실행
08 통과 NOTICE 확인
Python requirements 설치
읽기 전용 PostgreSQL 경로 실행
CSV·manifest 생성과 SHA-256 확인
PostgreSQL·CSV 두 경로의 04_result_validation.py 통과
Windows·macOS·Linux 한글 그래프 확인
GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 최종 판정

```text
Chapter 14는 금액 의미, 기간 조건, date spine, 활성 신청,
시간 관계 품질, SQL 완료 게이트, 읽기 전용 연결, manifest,
strict 자료형과 실제 SQL·pandas 비교를 최종 보완했다.

저장소 내용 기준 최종 출판 내용 검수 완료 상태로 판정한다.
```
