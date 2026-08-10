from pathlib import Path

validation_path = Path('notes/chapter13_validation_result.md')
checklist_path = Path('notes/chapter13_review_checklist.md')

validation = validation_path.read_text(encoding='utf-8')
section = r'''

---

## 13. 2026-08-10 최종 출판 재검증

최종 출판 보완 뒤 PostgreSQL 16에서 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 13 definitive final validation once
Run: 1
Run ID: 31393533155
Validation workflow commit: acb30219313559cd45d71dad07e584518d691bdb
Content commit: 114c681775fffc583848c28b65d026a8cf14e485
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 13 본문 번호 절 = 28
워크북 expected_failure 24 / expected_success 6 / total 30 정합성
이론 발표·이미지 README의 이전 22·17 기준 제거
ChatGPT Chat / Work / Codex 역할 설명 최신화
작성된 발표자 스크립트 generic enhancer 비활성화
잘못된 데이터베이스에서 01 실행 차단
Chapter 07 canonical source와 Chapter 08 gate 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
CREATE 권한 없는 역할에서 01이 DDL 전에 실패
권한 실패 뒤 ai_review_lab 미생성 확인
Chapter 12 handoff 상태 생성과 보호 fingerprint 저장
1005 recorded_amount drift 주입 시 01 실패 확인·복원
Chapter 13 01→08 전체 실행 성공
negative/boundary tests = 30/30
expected failure = 24 / expected success = 6 / unexpected = 0
exact state = 3/3/2/3/4/4, recorded/payment amount = 470000/470000
좋은 설계 constraints = 29 / FK = 4
payment business drift 탐지·복원
course_project·nosql_lab fingerprint 실행 전후 동일
transaction_lab·performance_lab·security_lab·nosql_lab sentinel 유지
예상 밖 ai_review_lab.keep_me 존재 시 reset 전체 ROLLBACK
정상 reset 성공 후 ai_review_lab만 제거
reset 뒤 course_project·nosql_lab fingerprint 동일
reset 뒤 Chapter 08 prerequisite/final gate 재통과
```

최종 통과 메시지:

```text
Chapter 13 AI review lab validation passed: tests 30/30
Chapter 13 ai_review_lab reset passed
Chapter 13 definitive PostgreSQL 16 validation passed
```

별도 실제 운영 DB 변경, 실제 조직의 개인정보·결제 참조값 분류, 브라우저·TTS·PDF/eBook 시각 렌더링은 이번 자동 검증의 통과 범위로 주장하지 않습니다.
'''
if '## 13. 2026-08-10 최종 출판 재검증' not in validation:
    validation += section
validation_path.write_text(validation, encoding='utf-8')

checklist = checklist_path.read_text(encoding='utf-8')
old = '실제 Run ID와 최종 결과는 재검증 완료 후 갱신합니다.'
new = r'''최종 재검증 결과:

```text
Workflow: Chapter 13 definitive final validation once
Run: 1
Run ID: 31393533155
Validation workflow commit: acb30219313559cd45d71dad07e584518d691bdb
Content commit: 114c681775fffc583848c28b65d026a8cf14e485
PostgreSQL: 16
Status: completed
Conclusion: success
```

추가 항목까지 모두 실제 통과했습니다.

```text
Chapter 07 구조 계약 15 / 20
DB CREATE 권한 사전 차단 및 DDL 미실행
Chapter 13 01→08
negative/boundary 30/30
exact final state
business drift 탐지·복원
protected fingerprints·sentinels 유지
unexpected-object reset ROLLBACK
정상 reset
reset 후 Chapter 08 gate
```'''
if old in checklist:
    checklist = checklist.replace(old, new, 1)
elif 'Run ID: 31393533155' not in checklist:
    raise SystemExit('Checklist final validation placeholder not found')
checklist_path.write_text(checklist, encoding='utf-8')

print('Chapter 13 final validation record updated')
