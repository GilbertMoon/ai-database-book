# Chapter 15 최종 출판 리뷰 체크리스트

## 대상

```text
Chapter 15. 데이터베이스 종합 프로젝트
```

실제 실행하지 않은 항목은 통과로 표시하지 않습니다.

## 1. 실행 안전성

| 점검 | 상태 | 실제 근거 |
| --- | --- | --- |
| 현재 DB 보호 | 실제 통과 | 잘못된 `postgres` DB에서 `01_schema.sql` 실패 |
| 기존 스키마 덮어쓰기 방지 | 실제 통과 | `tutor_project` 존재 시 01 재실행 실패 |
| 구조 원자성 | 실제 통과 | 구조 생성 한 트랜잭션 |
| Seed 재실행 차단 | 실제 통과 | 데이터 존재 시 02 실패 |
| reset 범위 | 실제 통과 | 예상 객체만 삭제, `CASCADE` 미사용 |
| reset 예상 밖 객체 | 실제 통과 | `keep_me` 존재 시 중단·기존 5개 질문 유지 |
| 이전 Chapter 격리 | 실제 통과 | 7개 sentinel 스키마 유지 |
| search_path 확인 | 완료 | SQL 형식 통일 |

## 2. 구조·무결성·IDENTITY

| 점검 | 기대 | 상태 |
| --- | ---: | --- |
| base tables / views / sequences | 6 / 4 / 5 | PostgreSQL 16 실제 통과 |
| constraints / FK / indexes | 36 / 5 / 3 | PostgreSQL 16 실제 통과 |
| CASCADE FK | 0 | 실제 통과 |
| 복합 PK | question_id·material_id | 실제 통과 |
| 문자열 공백 CHECK | 이메일·코드·버전·URL 등 | 실제 통과 |
| 질문 시간 CHECK | updated_at >= created_at | 실제 통과 |
| IDENTITY 다음 값 | 105·204·306·406·507 이상 | 실제 통과 |
| 정확한 객체 정의 | 이름·컬럼·대상·순서 | 실제 catalog 검증 통과 |

## 3. P15 추적성

| 체계 | 범위 | 상태 |
| --- | --- | --- |
| 요구사항 | P15-R01~R13 | 완료 |
| 결정·미확정 정책 | P15-D01~D08 | 완료 |
| 분석 질문 | P15-Q01~Q06 | 완료 |
| 트랜잭션·테스트 | P15-T01~T25 | 실제 실행 |
| 검증 단계 | P15-V01~V09 | 완료 |
| P15-V09 복원 추적 | `11_restore_validation.sql` | 완료 |
| 프로젝트 가이드 실행 순서 | 01→10→Python→backup/restore→11 | 완료 |

## 4. 업무·시간 검증

| 항목 | 기대 | 상태 |
| --- | ---: | --- |
| 질문 없는 학생 | 1 | 실제 통과 |
| 연결되지 않은 자료 | 1 | 실제 통과 |
| 답변 없는 open 질문 | 1 | 실제 통과 |
| 답변 2개 질문 | 1 | 실제 통과 |
| 고아 관계 | 0 | 실제 통과 |
| answered·답변 없음 | 0 | 실제 통과 |
| 질문 < 가입일 | 0 | 실제 통과 |
| 답변 < 질문·튜터 시각 | 0 | 실제 통과 |
| 자료 연결 < 질문 시각 | 0 | 실제 통과 |
| 미확정 상태·활성 정책 | DB 제약으로 임의 고정하지 않음 | 통과 |

## 5. 트랜잭션·반례·경계값

| 점검 | 기대 | 상태 |
| --- | ---: | --- |
| 정상 내부 answers | 6 | 실제 트랜잭션에서 확인 |
| 조건부 상태 UPDATE | 1행 | 실제 통과 |
| ROLLBACK 후 | answers 5·question 303 open | 실제 통과 |
| 실패 경로 부분 변경 | 0 | 실제 통과 |
| 실패 반례 | 18 | 실제 통과 |
| 정상 경계값 | 5 | 실제 통과 |
| 전체 테스트 | 23/23 | 실제 통과 |
| unexpected | 0 | 실제 통과 |
| SQLSTATE·constraint name | 정확히 일치 | 실제 통과 |

## 6. 인덱스·권한·보안

| 점검 | 상태 | 실제 근거 |
| --- | --- | --- |
| 업무 인덱스 정확한 정의 | 실제 통과 | 컬럼·정렬 검증 |
| 대표 questions 조회 | 실제 통과 | 복합 업무 인덱스 Index Scan |
| 대표 answers 조회 | 실제 통과 | answer 업무 인덱스 Bitmap Index Scan |
| 대표 material 역조회 | 실제 통과 | material 업무 인덱스 Bitmap Index Scan |
| 작은 Seed 한계 | 통과 | 성능 효과와 후보 사용 가능성 구분 |
| DB PUBLIC CONNECT | 실제 통과 | ACL 직접 해석 방식으로 수정 |
| PUBLIC 테이블·컬럼 권한 | 실제 통과 | information_schema 확인 |
| 08→09 VIEW 순서 | 수정·통과 | VIEW 없을 때 권한 조회 NULL 처리 |
| access_scope 의미 | 통과 | 데이터 분류, 실제 권한 아님 |
| 실제 개인정보·비밀 | 실제 통과 | example.test·demo 값 |
| PGPASSFILE | 실제 사용 | CI에서 저장소 밖 `/tmp` 사용 |

## 7. 실제 Role 허용·차단

| Role | 동작 | 기대 | 상태 |
| --- | --- | --- | --- |
| report | 분석 VIEW SELECT | 허용 | 실제 성공 |
| report | questions INSERT | 차단 | 실제 실패 |
| app | questions SELECT | 허용 | 실제 성공 |
| app | 허용된 questions INSERT | 허용 | 실제 성공 후 ROLLBACK |
| app | questions DELETE | 차단 | 실제 실패 |
| app | schema CREATE TABLE | 차단 | 실제 실패 |

## 8. 분석 구조와 Python

| 점검 | 기대 | 상태 |
| --- | ---: | --- |
| 분석 기간 | `[2026-01-01 00:00+09, 2026-06-01 00:00+09)` | 실제 통과 |
| 질문 VIEW | 5행 | 실제 통과 |
| 학생 VIEW | 4행·0건 1명 | 실제 통과 |
| 튜터 VIEW | 3행·답변 합계 5 | 실제 통과 |
| 월별 date spine | 2026-01~05 5행 | 실제 통과 |
| status | open1·answered3·closed1 | 실제 통과 |
| answer·material 합계 | 5·7 | 실제 통과 |
| 첫 답변 | 4건·평균2.00·최소0.50·최대3.50 | 실제 통과 |
| Python 읽기 전용 | REPEATABLE READ·READ ONLY | 실제 통과 |
| 필수 컬럼·자료형 | 엄격 검증 | 실제 통과 |
| SQL·pandas 직접 비교 | 상태·월·학생·튜터·첫 답변 | 5종 실제 통과 |
| 잘못된 PGDATABASE | 중단 | 실제 통과 |
| Seoul 월 경계 | UTC 변환 전 업무 시간대 보존 | 실제 수정·통과 |

## 9. DB 게이트·백업·복원

| 단계 | 기대 | 상태 |
| --- | --- | --- |
| `10_completion_gate.sql` | `Chapter 15 database completion gate passed` | 실제 통과 |
| custom-format 백업 | 파일 생성 | 실제 통과 |
| 백업 SHA-256 | 계산 | 실제 통과 |
| `pg_restore --list` | tutor_project 포함 | 실제 통과 |
| 복원 DB | template0 기반 `tutor_project_restore` | 실제 생성 |
| 원자적 복원 | `--single-transaction` | 실제 통과 |
| owner/ACL 옵션 | `--no-owner --no-privileges` | 실제 적용 |
| `11_restore_validation.sql` | `Chapter 15 restore validation passed` | 실제 통과 |
| 복원 구조 | table6·view4·sequence5 | 실제 통과 |
| 복원 데이터 | 4·3·5·5·6·7 | 실제 통과 |
| 복원 제약/FK/index | 36·5·3 | 실제 통과 |
| 복원 시간 이상 | 0 | 실제 통과 |
| 복원 분석 VIEW | 5·4·3 | 실제 통과 |
| 복원 owner | 현재 복원 역할 | 실제 통과 |

## 10. 발표·이미지·정적 정합성

| 점검 | 상태 |
| --- | --- |
| 이론 발표 20장 | 자동 통과 |
| 실습 발표 20장 | 자동 통과 |
| 모든 장표 화면 구성·스크립트 | 자동 통과 |
| JavaScript 문법 | 자동 통과 |
| Python 문법 | 자동 통과 |
| shared PresentationTTS | 자동 연결 확인 |
| script_content_enhancer | 자동 연결 확인 |
| asset version `20260809a` | 자동 통과 |
| Mermaid / SVG | 8 / 8 자동 통과 |
| SVG 접근성 메타데이터 | 자동 통과 |
| 본문 SVG 참조 | 8개 자동 통과 |

## 11. 문서 동기화

| 파일 | 상태 |
| --- | --- |
| 본문 | 완료 |
| 워크북·권장 해설 | 완료 |
| 구성안 | 완료 |
| 프로젝트 가이드 | 최종 실행 순서로 수정 완료 |
| 검수 기록 | 실제 실행 결과 반영 |
| requirements·erd | 완료 |
| template·code README | 완료 |
| Runbook·분석·AI·최종 보고서 | 완료 |
| 프로젝트 구조 도식 | 완료 |

## 12. 자동 검증 기준 실행

```text
Workflow: Validate Chapter 15
Run: 7
Run ID: 31303633119
Commit: 06112f85de97fca14e4ebffcdba79c97db56d8d9
PostgreSQL: 16
Conclusion: success
```

검토 기록·체크리스트 반영 후 최종 문서 상태에서 definitive run을 다시 수행합니다.

## 13. 수동 확인으로 남기는 항목

```text
- 브라우저 이론 20장 실제 시각 렌더링
- 브라우저 실습 20장 실제 시각 렌더링
- semantic step/highlight 실제 조작
- 발표창 ↔ 스크립트창 실제 동기화
- TTS 실제 청취·발음
- 모바일·프로젝터 가독성
- SVG 실제 시각 품질과 필요 시 Mermaid CLI 재생성
- GitHub·Word·PDF·eBook 최종 렌더링과 페이지 수
- AI diff 내용의 최종 사람 승인
```

## 최종 판정

```text
Chapter 15의 자동화 가능한 DB·Python·Role·백업·복원·reset 경로는
PostgreSQL 16 실제 실행으로 통과했다.

최종 출판 전 남은 항목은 브라우저/TTS/시각 렌더링과
사람이 판단해야 하는 문서·AI 승인 영역이다.
```
