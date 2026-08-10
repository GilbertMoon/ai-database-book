from pathlib import Path

RUN_ID = '31387035835'
VALIDATION_COMMIT = 'f65dc2e90ffcdbd7883ade11a225eae16222a33a'
CONTENT_COMMIT = '8c3fc44ccd5d752f13e867e80497bac255f79415'
README_ALIGNMENT_COMMIT = '68aaa9380a2ab1fc2f547892709306e9811c8dc3'

validation_path = Path('notes/chapter11_validation_result.md')
validation = validation_path.read_text(encoding='utf-8')
heading = '## 2026-08-10 최종 출판 재검증'
if heading not in validation:
    validation += f'''\n\n---\n\n{heading}\n\nChapter 11 최종 출판 보완 뒤 PostgreSQL 16에서 별도 강화 검증을 다시 실행했습니다.\n\n```text\nWorkflow: Chapter 11 final publication validation v2 once\nRun: 1\nRun ID: {RUN_ID}\nValidation commit: {VALIDATION_COMMIT}\nContent commit: {CONTENT_COMMIT}\nREADME alignment commit: {README_ALIGNMENT_COMMIT}\nStatus: completed\nConclusion: success\nDate: 2026-08-10 (Asia/Seoul)\nPostgreSQL: 16\n```\n\n최종 확인 범위:\n\n```text\nChapter 07 01→04 기준 상태 실제 생성 성공\nChapter 08 사전·집계 게이트 재통과\nChapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인\n현재 역할의 ai_database_book CREATE 권한 사전 검사 확인\nCREATE 권한이 없는 역할에서 security_lab 생성 차단\n권한 차단 뒤 security_lab 미생성 확인\nsecurity_lab = students 3 / courses 3 / enrollments 3 / recorded_amount 합계 310000\nPostgreSQL 16 역할 멤버십·최소 권한 모델 재현\n읽기 역할 INSERT 차단 확인\n앱 역할 status 작업 허용·recorded_amount UPDATE·DELETE·schema CREATE 차단 확인\nUnix password file chmod 0600 확인\n최소 백업 역할로 security_lab custom archive 생성 성공\npg_restore --list에서 schema/table/sequence/index 항목 확인\nSHA-256 생성 성공\n별도 ai_database_book_restore에 --single-transaction --no-owner --no-privileges 복원 성공\n06_restore_validation.sql 구조·데이터·IDENTITY·소유권 검증 성공\n복원 DB에 course_project 미복원 확인\ncourse_project 전체 fingerprint 실행 전후 동일\nreset은 security_lab만 제거하고 course_project fingerprint 유지\nChapter 08 게이트 reset 후 재통과\nChapter 11 작성 발표 스크립트 자동 확장 비활성화 확인\n```\n\n### 최종 보안 보완\n\n`01_security_lab_schema.sql`은 `security_lab` DDL을 시작하기 전에 Chapter 07 구조 계약과 현재 역할의 DB `CREATE` 권한을 검사합니다. 잘못된 역할에서는 스키마를 만들기 전에 중단되며, 실제 PostgreSQL 16에서 객체가 남지 않는 것을 확인했습니다.\n\n### password file 보완\n\n`PGPASSWORD`를 저장소 예제로 사용하지 않고 `PGPASSFILE` 기반 password file을 사용하도록 설명을 구체화했습니다. Unix 계열에서는 `chmod 0600` 수준의 접근 제한을 명시하고, Windows에서는 접근이 제한된 사용자 보호 경로를 사용하도록 정리했습니다.\n\n### 복구 판정\n\n백업 파일 존재와 해시는 중간 증거로만 사용합니다. 최종 성공 판정은 별도 데이터베이스에서 custom archive를 실제 복원하고, 구조·데이터·IDENTITY·소유권 검증을 모두 통과한 경우에만 합니다.\n'''
    validation_path.write_text(validation, encoding='utf-8')

checklist_path = Path('notes/chapter11_review_checklist.md')
checklist = checklist_path.read_text(encoding='utf-8')
heading2 = '## 16. 2026-08-10 최종 출판 보완 및 재검증'
if heading2 not in checklist:
    checklist += f'''\n\n---\n\n{heading2}\n\n- [x] Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 11 시작 게이트에서 확인\n- [x] 현재 역할의 `ai_database_book` CREATE 권한을 `security_lab` 생성 전에 확인\n- [x] CREATE 권한 없는 역할에서 `security_lab` 생성이 차단되고 객체가 남지 않음을 PostgreSQL 16에서 확인\n- [x] 본문·구성안·워크북·코드 README·Runbook의 `PGPASSFILE` 안내 정합성 확인\n- [x] Unix password file `chmod 0600` 기준을 문서와 실제 검증에 반영\n- [x] 최소 권한 역할의 허용·차단 동작 재검증\n- [x] custom archive 생성 및 `pg_restore --list` 항목 확인\n- [x] SHA-256 생성 확인\n- [x] 별도 복원 DB에 `--single-transaction --no-owner --no-privileges` 복원 성공\n- [x] `06_restore_validation.sql` 구조·데이터·IDENTITY·소유권 검증 성공\n- [x] 원본 `course_project` fingerprint 실행 전후·reset 후 동일\n- [x] `security_lab` reset 뒤 Chapter 08 사전·집계 게이트 재통과\n- [x] Chapter 11 작성 발표 스크립트 자동 확장 비활성화\n\n### 최종 자동 검증 기록\n\n```text\nWorkflow: Chapter 11 final publication validation v2 once\nRun: 1\nRun ID: {RUN_ID}\nValidation commit: {VALIDATION_COMMIT}\nContent commit: {CONTENT_COMMIT}\nPostgreSQL: 16\nConclusion: success\nDate: 2026-08-10 (Asia/Seoul)\n```\n'''
    checklist_path.write_text(checklist, encoding='utf-8')

print('Chapter 11 final validation record updated')
