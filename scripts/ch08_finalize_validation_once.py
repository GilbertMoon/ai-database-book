from pathlib import Path

ROOT = Path('.').resolve()

validation_path = ROOT / 'notes/chapter08_validation_result.md'
validation = validation_path.read_text(encoding='utf-8')
marker = '## 2026-08-10 최종 출판 재검증'
if marker not in validation:
    validation += '''\n\n---\n\n## 2026-08-10 최종 출판 재검증\n\nChapter 08 최종 출판 보완 뒤 PostgreSQL 16에서 기존 전용 검증 워크플로를 다시 실행했다.\n\n```text\nWorkflow: Validate Chapter 08\nRun: 6\nRun ID: 31378288930\nCommit: 9dddfe224847e360a546a6a9e9c50e2ad9b447a4\nStatus: completed\nConclusion: success\nDate: 2026-08-10 (Asia/Seoul)\nPostgreSQL: 16\n```\n\n최종 확인 범위:\n\n```text\nChapter 07 기준 상태 실제 생성 성공\nChapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인\nChapter 08 00 → 01 → 02 → 03 → 호환 조회를 READ ONLY 트랜잭션에서 실행\n실행 전후 course_project 데이터 불변\n잘못된 데이터베이스에서 00 사전 게이트 차단\n기준 상태 변경 시 00 차단\nrecorded_amount 변경 시 03 차단\n전체 신청 = 5 / recorded_amount 590000\n활성 신청 = 3 / recorded_amount 340000\n취소 제외 = 4 / recorded_amount 440000\nHAVING 취소 제외 신청 2건 이상 강의 = 2개\n강사 201 신청 JOIN 뒤 잘못된 SUM(c.price) = 440000\n강사 201 강의 수준 올바른 가격 합계 = 220000\n강사 202 두 방식 = 150000 / 150000 (우연한 일치)\nChapter 08 authored narration 자동 확장 비활성화 정적 확인\nChapter 08 prerequisite check passed\nChapter 08 join and aggregation validation passed\n```\n\n과대 집계 예제는 이제 본문 설명에만 존재하지 않고 `03_join_aggregation_validation.sql`과 GitHub Actions에서 실제 숫자로 검증한다. 강사 202처럼 잘못된 방식과 올바른 방식의 결과가 우연히 같은 경우도 있기 때문에, 결과 숫자 하나가 맞는지만 보지 않고 합산 기준 행을 확인해야 한다.\n'''
validation_path.write_text(validation, encoding='utf-8')

check_path = ROOT / 'notes/chapter08_review_checklist.md'
check = check_path.read_text(encoding='utf-8')
check = check.replace('- [ ] 최신 PostgreSQL 16 전체 경로 재검증 결과 확인', '- [x] 최신 PostgreSQL 16 전체 경로 재검증 결과 확인 — Validate Chapter 08 Run 6 / 31378288930 성공')
if 'Run ID: 31378288930' not in check:
    check += '''\n\n### 최종 자동 검증 기록\n\n```text\nWorkflow: Validate Chapter 08\nRun: 6\nRun ID: 31378288930\nCommit: 9dddfe224847e360a546a6a9e9c50e2ad9b447a4\nPostgreSQL: 16\nConclusion: success\nDate: 2026-08-10 (Asia/Seoul)\n```\n'''
check_path.write_text(check, encoding='utf-8')

print('Chapter 08 final validation record updated')
