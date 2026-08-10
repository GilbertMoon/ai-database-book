from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def update(path, transform):
    p = ROOT / path
    text = p.read_text(encoding='utf-8')
    p.write_text(transform(text), encoding='utf-8')


def checklist(text):
    text = text.replace(
        '- [ ] 최신 PostgreSQL 16 전체 경로 재검증 결과 확인',
        '- [x] 최신 PostgreSQL 16 전체 경로 재검증 성공 — publication smoke Run 2 / Run ID 31375936249'
    )
    marker = '## 최종 출판 PostgreSQL 재검증 (2026-08-10)'
    if marker not in text:
        text += '''\n\n---\n\n## 최종 출판 PostgreSQL 재검증 (2026-08-10)\n\n- [x] 데이터베이스 `CREATE` 권한 없는 역할에서 01 실행 거부 및 스키마 미생성 확인\n- [x] 01 → 02 → 03 → 04 → 05 → 06 전체 경로 PostgreSQL 16 실행 성공\n- [x] 신청 1005 `recorded_amount = 120000` 및 강의 302 현재 `price = 120000` 확인\n- [x] 명명 제약조건 15개·NOT NULL 열 20개·부분 고유 인덱스 확인\n- [x] 학생 이름 `NULL` 입력이 NOT NULL 위반으로 실제 거부됨\n- [x] Chapter 08 `00_check_course_project.sql` 인계 게이트 통과\n- [x] Chapter 07 스크립트 자동 문장 보강 비활성화 정적 확인\n\n```text\nWorkflow: Chapter 07 publication SQL smoke once\nRun: 2\nRun ID: 31375936249\nPostgreSQL: 16\nConclusion: success\nDate: 2026-08-10 (Asia/Seoul)\n```\n'''
    return text


def validation(text):
    marker = '## 2026-08-10 최종 출판 재검증'
    if marker not in text:
        text += '''\n\n---\n\n## 2026-08-10 최종 출판 재검증\n\nChapter 07 최종 출판 보완 뒤 PostgreSQL 16에서 별도 smoke test를 실행했다.\n\n```text\nWorkflow: Chapter 07 publication SQL smoke once\nRun: 2\nRun ID: 31375936249\nCommit: f07ab8ae1771c3054e9d247cd1b1cc685e8a3d94\nStatus: completed\nConclusion: success\nDate: 2026-08-10 (Asia/Seoul)\nPostgreSQL: 16\n```\n\n최종 확인 범위:\n\n```text\nDB CREATE 권한 없는 역할에서 01 실행 거부 + course_project 미생성\n01 → 02 → 03 → 04 → 05 → 06 전체 경로 성공\n03 신규 신청 1005 = course 302의 현재 price를 recorded_amount로 캡처\n1005 recorded_amount = 120000 / course 302 price = 120000\n명명 제약조건 = 15\nNOT NULL 열 = 20\n부분 고유 인덱스 uq_course_enrollments_active 존재\n학생 이름 NULL 입력 = NOT NULL 위반\nChapter 08 prerequisite check passed\nChapter 07 authored narration 자동 확장 비활성화 확인\n```\n\n첫 smoke run에서 발견된 `06_course_project_optional_tests.sql`의 선언부 범위 오류도 수정한 뒤 전체 경로를 다시 실행해 최종 성공을 확인했다.\n'''
    return text


def review(text):
    marker = '## 최종 출판 DB 재검증 완료 (2026-08-10)'
    if marker not in text:
        text += '''\n\n---\n\n## 최종 출판 DB 재검증 완료 (2026-08-10)\n\n최종 보완본을 PostgreSQL 16에서 다시 실행해 DB `CREATE` 권한 보호, 01~06 전체 경로, 현재 강의 가격의 `recorded_amount` 캡처, 대표 `NOT NULL` 실패, 구조 기준, Chapter 08 인계 게이트를 모두 확인했다. publication smoke Run 2(ID 31375936249)는 `success`로 완료됐다.\n'''
    return text


update('notes/chapter07_review_checklist.md', checklist)
update('notes/chapter07_validation_result.md', validation)
update('book/chapter07/chapter07_review_revision.md', review)
print('Chapter 07 final validation records updated')
