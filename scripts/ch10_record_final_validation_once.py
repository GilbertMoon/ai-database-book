from pathlib import Path

validation_path = Path('notes/chapter10_validation_result.md')
checklist_path = Path('notes/chapter10_review_checklist.md')

validation = validation_path.read_text(encoding='utf-8').rstrip() + '''

---

## 2026-08-10 최종 출판 재검증

Chapter 10 최종 출판 보완 뒤 PostgreSQL 16에서 별도 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 10 final publication validation once
Run: 1
Run ID: 31382892778
Validation commit: 5cc10f3fb23ae093f6cd3b4ae2c58de7ba9bb295
Content commit: 98f6a9461bdbdcd7c92d867d2b3062982d14e615
Asset compatibility commit: 72701b0c5e790276286d619f0163fca0b5fdb088
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 07 01→04 기준 상태 실제 생성 성공
Chapter 08 사전·집계 게이트 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
현재 역할의 ai_database_book CREATE 권한 사전 검사 확인
CREATE 권한이 없는 역할에서 performance_lab 생성 차단
권한 차단 뒤 performance_lab 미생성 확인
performance_lab = students 10003 / instructors 2 / courses 2003 / enrollments 100005
선택도 기준 결과 = 10 / 50 / 15 / 30001 / 전체 100005
03·05의 enable_seqscan/indexscan/bitmapscan = on 기준 유지
SQL 파일에서 강제 enable_* = off 설정 없음
후보 인덱스 3개 생성 및 실제 선택 확인
PostgreSQL 16 status 단독 조건 = Seq Scan 유지
ORDER BY title LIMIT 20 = title 후보 인덱스 선택 확인
05→06→07 사후 측정·리뷰·최종 검증 성공
course_project 전체 fingerprint 실행 전후 동일
reset은 performance_lab만 제거하고 course_project fingerprint 유지
Chapter 08 게이트 reset 후 재통과
Chapter 10 작성 발표 스크립트 자동 확장 비활성화
검증된 발표 자산 버전 = 20260809a 유지
```

### 선택도 설명 보강

`performance_lab.enrollments` 100,005행을 기준으로 다음 반환 비율을 본문·워크북·발표자료에 추가했습니다.

```text
student_id = 5000                 10행   ≈ 0.010%
course_id = 1500                  50행   ≈ 0.050%
course_id = 1500 + 수강중         15행   ≈ 0.015%
status = 수강중                30001행   ≈ 30.0%
```

이 비율은 인덱스 후보를 이해하기 위한 단서이며 단독 정답으로 사용하지 않습니다. 실제 판단은 계획 노드, Index Cond, Buffers, 결과 행, 반복 측정과 쓰기 비용을 함께 봅니다.

### 플래너 설정 기준 보강

`SET enable_seqscan = off`처럼 특정 계획을 강제로 피하게 만든 결과는 인덱스 효과의 최종 증거로 사용하지 않습니다. Chapter 10의 기준·사후 측정은 `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`을 모두 `on`으로 유지해 PostgreSQL 옵티마이저가 실제로 선택한 계획을 비교합니다.

### 시작 게이트 보강

`01_performance_lab_schema.sql`은 잘못된 환경에서 명시적 DDL 트랜잭션을 열기 전에 사전 조건을 검사합니다. Chapter 07 구조 계약 15/20과 DB `CREATE` 권한이 맞아야 `BEGIN → CREATE SCHEMA/TABLE → 검증 → COMMIT` 단계로 진입합니다.
'''
validation_path.write_text(validation + '\n', encoding='utf-8')

checklist = checklist_path.read_text(encoding='utf-8').rstrip() + '''

---

## 16. 2026-08-10 최종 출판 보완 및 재검증

- [x] Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 10 시작·최종 게이트에서 확인
- [x] 현재 역할의 `ai_database_book` CREATE 권한을 `performance_lab` 생성 전에 확인
- [x] 사전 조건 검사를 명시적 DDL 트랜잭션 시작 전에 수행
- [x] CREATE 권한 없는 역할에서 `performance_lab` 생성이 차단되고 객체가 남지 않음을 PostgreSQL 16에서 확인
- [x] 선택도 기준을 10/50/15/30001행과 약 0.010%/0.050%/0.015%/30.0%로 본문·워크북·발표자료에 연결
- [x] 선택도는 인덱스 선택의 단서이지 단독 정답이 아님을 명시
- [x] `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`을 모두 `on`으로 유지해 전후 계획 비교
- [x] `SET enable_seqscan = off` 같은 강제 설정을 최종 성능 증거로 사용하지 않도록 명시
- [x] PostgreSQL 16에서 title/student/course/course+status 후보 인덱스 실제 선택 확인
- [x] PostgreSQL 16 `status='수강중'` 단독 조건은 Seq Scan 유지 확인
- [x] `ORDER BY title LIMIT 20`에서 title 인덱스 선택 확인
- [x] Chapter 10 작성 발표 스크립트 자동 확장 비활성화
- [x] 기존 검증 자산 버전 `20260809a` 유지
- [x] `course_project` fingerprint 실행 전후·reset 후 동일
- [x] `performance_lab` reset 뒤 Chapter 08 사전·집계 게이트 재통과

### 최종 자동 검증 기록

```text
Workflow: Chapter 10 final publication validation once
Run: 1
Run ID: 31382892778
Validation commit: 5cc10f3fb23ae093f6cd3b4ae2c58de7ba9bb295
Content commit: 98f6a9461bdbdcd7c92d867d2b3062982d14e615
PostgreSQL: 16
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
```
'''
checklist_path.write_text(checklist + '\n', encoding='utf-8')

print('Chapter 10 final validation record appended')
