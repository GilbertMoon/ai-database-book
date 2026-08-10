from pathlib import Path

RUN_ID='31403974074'
RUN_COMMIT='806483b82ed7d388c91c764a102de04f96d71668'
CONTENT_COMMIT='bd1172d53fcfe2bc4abba0550c94b0ceeadbb095'

p=Path('notes/chapter14_validation_result.md')
t=p.read_text(encoding='utf-8')
section=f'''

---

## 13. 2026-08-11 최종 출판 재검증

Chapter 14 최종 출판 보완 뒤 PostgreSQL 16과 고정 Python 의존성 범위에서 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 14 definitive final validation once
Run: 1
Run ID: {RUN_ID}
Validation workflow commit: {RUN_COMMIT}
Content commit: {CONTENT_COMMIT}
Status: completed
Conclusion: success
Date: 2026-08-11 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
본문 번호 절 = 32
워크북 제약조건 20개 동기화
이론 발표의 stale 취소 금액 0 문장 제거
이미지 README 금액 의미 = 신청 시점 기록 금액
완성 발표자 스크립트 generic enhancer 비활성화
Python 문법·발표 JavaScript 정적 검사
잘못된 데이터베이스에서 01 차단
Chapter 07·08 canonical source 재생성·통과
Chapter 07 명명 제약조건 15 / NOT NULL 열 20 인계 확인
READ ONLY 트랜잭션에서 01이 DDL 전에 실패
DB CREATE 권한 없는 역할에서 01이 DDL 전에 실패
Chapter 14 SQL 01→08 전체 실행 성공
정확 상태 = 8/3/5/24/24, recorded_amount 합계 3210000
analysis_lab 제약조건 = 20
완료 = 12건 / 평균 25.00일 / 최소 18 / 최대 36
recorded_amount drift 주입 시 08 실패·복원 후 재통과
PostgreSQL 직접 경로 pandas 교차 검증 통과
CSV + manifest + reference_metrics 경로 교차 검증 통과
manifest expected_recorded_amount_sum = 3210000 실제 생성·검증
manifest amount_semantics 실제 생성·검증
CSV SHA-256 변조 탐지 통과
PostgreSQL·CSV 그래프 파일 실제 생성
예상 밖 analysis_lab.keep_me 존재 시 reset 전체 ROLLBACK
정상 reset 뒤 analysis_lab만 제거
course_project fingerprint 실행 전후 동일
transaction/performance/security/nosql/ai_review sentinel 유지
reset 뒤 Chapter 08 prerequisite gate 재통과
```

최종 메시지:

```text
Chapter 14 analysis_lab validation passed: rows 8/3/5/24/24, amount 3210000
Chapter 14 analysis lab reset passed
Chapter 14 definitive PostgreSQL 16 and Python validation passed
```

브라우저에서의 40장 최종 시각 확인, 실제 TTS 청취, OS별 한글 글꼴 렌더링, Word·PDF·eBook 최종 페이지 렌더링은 자동 검증 통과 범위로 주장하지 않습니다.
'''
if '## 13. 2026-08-11 최종 출판 재검증' not in t:
    t += section
p.write_text(t,encoding='utf-8')

p=Path('notes/chapter14_review_checklist.md'); t=p.read_text(encoding='utf-8')
old='실제 Run ID와 결론은 재검증 완료 후 definitive 결과로 기록합니다.'
new=f'''최종 재검증 결과:

```text
Workflow: Chapter 14 definitive final validation once
Run ID: {RUN_ID}
Validation commit: {RUN_COMMIT}
Content commit: {CONTENT_COMMIT}
PostgreSQL: 16
Conclusion: success
```'''
if old not in t:
    raise SystemExit('checklist placeholder not found')
t=t.replace(old,new,1)
p.write_text(t,encoding='utf-8')

p=Path('book/chapter14/chapter14_review_revision.md'); t=p.read_text(encoding='utf-8')
old='최종 PostgreSQL 16·Python·CSV·발표 정적 재검증 결과는 성공 Run 확인 후 검증 기록에 별도로 남깁니다.'
new=f'''최종 재검증은 PostgreSQL 16에서 성공했습니다. Run ID `{RUN_ID}`, 검증 workflow commit `{RUN_COMMIT}`, 콘텐츠 commit `{CONTENT_COMMIT}`이며 상세 실행 증거는 `notes/chapter14_validation_result.md`에 기록했습니다.'''
if old not in t:
    raise SystemExit('review placeholder not found')
t=t.replace(old,new,1)
p.write_text(t,encoding='utf-8')

print('Chapter 14 definitive validation record prepared')
