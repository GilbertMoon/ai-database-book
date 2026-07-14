# AI 튜터링 질문 관리 서비스 운영 준비 기록

## 1. 기본 정보

| 항목 | 기록 |
| --- | --- |
| 실행 환경 | 개발 / 테스트 / 운영 |
| PostgreSQL 버전 |  |
| Python·pandas 버전 |  |
| 데이터베이스 |  |
| 스키마 | tutor_project |
| 담당자 |  |
| 기록일 |  |
| RPO |  |
| RTO |  |

---

## 2. 역할·권한 작업 행렬

| 역할 | CONNECT | USAGE | SELECT | INSERT | UPDATE | DELETE | CREATE |
| --- | --- | --- | --- | --- | --- | --- | --- |
| tutor_project_owner |  |  |  |  |  |  |  |
| tutor_project_app |  |  |  |  |  |  |  |
| tutor_project_report |  |  |  |  |  |  |  |

권장 방향:

```text
tutor_project_owner
- NOLOGIN
- 객체 소유

tutor_project_app
- 필요한 업무 테이블 작업만 허용
- schema CREATE·TRUNCATE·DROP 불허

tutor_project_report
- 분석 VIEW와 필요한 테이블 SELECT만 허용
- 쓰기 작업 불허
```

Role과 GRANT·REVOKE는 현재 멤버십과 영향을 검토한 뒤 관리자 테스트 환경에서 선택 적용합니다.

---

## 3. 비밀·개인정보·분석 파일 보호

| 점검 | 결과 |
| --- | --- |
| 실제 이름·이메일·전화번호 미사용 |  |
| 비밀번호·토큰·API 키 미포함 |  |
| 전체 접속 URL 미포함 |  |
| `.env`가 `.gitignore`에 포함 |  |
| 백업 파일이 `.gitignore`에 포함 |  |
| 실제 CSV·분석 산출물의 저장 위치 확인 |  |
| 로그에 질문 본문·개인정보 최소화 |  |
| 노출된 자격 증명 회전 절차 |  |

Python 분석 코드는 SELECT 중심으로 실행하고 원본 테이블 변경 SQL을 자동 실행하지 않습니다.

---

## 4. 백업 범위와 명령

스키마 단위 custom-format 예시:

```bash
pg_dump \
  -U <backup_user> \
  -d <database_name> \
  -Fc \
  --schema=tutor_project \
  --no-owner \
  --no-privileges \
  -f <backup-dir>/tutor_project.backup
```

| 항목 | 기록 |
| --- | --- |
| 백업 파일 위치 |  |
| 저장소 밖 경로 |  |
| 파일 크기 |  |
| 시작·완료 시각 |  |
| 종료 코드 |  |
| 경고·오류 |  |
| SHA-256 |  |
| 접근 가능 역할 |  |
| 보관 기간 |  |

아카이브 목록 확인:

```bash
pg_restore --list <backup-dir>/tutor_project.backup
```

---

## 5. 별도 DB 복원

원본 DB가 아닌 별도 검증 DB를 사용합니다.

```bash
createdb -U <admin_user> tutor_project_restore

pg_restore \
  -U <restore_user> \
  -d tutor_project_restore \
  --exit-on-error \
  --no-owner \
  --no-privileges \
  <backup-dir>/tutor_project.backup
```

복원 뒤 실행:

```text
03_metadata_validation.sql
04_requirement_queries.sql
08_operations_checks.sql
09_analysis_dataset.sql
10_completion_gate.sql
Python 결과 검증
```

---

## 6. 복원 검증

| 검증 | 기대 | 실제 | 통과 |
| --- | ---: | ---: | --- |
| tables | 6 |  |  |
| students | 4 |  |  |
| tutors | 3 |  |  |
| questions | 5 |  |  |
| answers | 5 |  |  |
| learning_materials | 6 |  |  |
| question_materials | 7 |  |  |
| FK | 5 |  |  |
| 업무 인덱스 | 3 |  |  |
| CASCADE | 0 |  |  |
| 정합성 이상 | 0행 |  |  |
| 분석 VIEW | 5행 |  |  |
| answer_count 합계 | 5 |  |  |
| material_count 합계 | 7 |  |  |

---

## 7. 장애·복구 시나리오

| 시나리오 | 탐지 | 대응 | 검증 |
| --- | --- | --- | --- |
| 실수 DELETE |  |  |  |
| 스키마 변경 실패 |  |  |  |
| 백업 파일 손상 |  |  |  |
| 권한 오설정 |  |  |  |
| 분석 VIEW 정의 오류 |  |  |  |
| SQL·Python 집계 불일치 |  |  |  |
| `.env` 또는 실제 CSV 노출 |  |  |  |

분석 VIEW는 원본 테이블에서 다시 생성할 수 있는 파생 객체입니다. SQL과 Python 결과가 다르면 기준값을 바꾸기 전에 원본 데이터, VIEW 정의, 자료형과 집계 단위를 확인합니다.

---

## 8. 모니터링과 정기 점검

| 항목 | 주기 | 담당 | 기준 |
| --- | --- | --- | --- |
| 백업 성공 |  |  |  |
| 복원 시험 |  |  |  |
| 정합성 조회 |  |  |  |
| 권한 검토 |  |  |  |
| 느린 쿼리 검토 |  |  |  |
| 분석 VIEW 행 수·중복 |  |  |  |
| SQL·Python 집계 비교 |  |  |  |
| `.env`·CSV 저장 위치 점검 |  |  |  |

다음 복원 시험 날짜:

```text
_______________________________________________________________
```

---

## 9. 최종 운영 준비 상태

```text
준비 완료 / 조건부 준비 / 보류 / 미준비
```

근거와 남은 조치:

```text
_______________________________________________________________
```
