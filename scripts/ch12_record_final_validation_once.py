from pathlib import Path

validation_path = Path('notes/chapter12_validation_result.md')
validation = validation_path.read_text(encoding='utf-8')
marker = '## 2026-08-10 최종 출판 재검증'
if marker not in validation:
    validation += r'''

---

## 2026-08-10 최종 출판 재검증

Chapter 12 최종 출판 보완 뒤 PostgreSQL 16에서 강화 검증을 다시 실행했습니다.

```text
Workflow: Chapter 12 final publication validation v2 once
Run: 1
Run ID: 31390439293
Validation commit: 96ce73e3a03593ae0c604dc9637fdf241fe1bc03
Content commit: b5c868b36cb71d5957ff05c392bca771d35f57b5
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 07 01→04 canonical source 생성 성공
Chapter 08 prerequisite/final gate 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
현재 역할의 ai_database_book CREATE 권한 사전 검사 확인
CREATE 권한 없는 역할에서 nosql_lab 생성 차단
권한 차단 뒤 nosql_lab 미생성 확인
nosql_lab = course_documents 3 / key_value_cache_examples 4 / storage_choice_cases 6
nosql_lab 명시 제약조건 = 25 / NOT NULL = 26
Chapter 12 01→07 전체 실행 성공
COURSE-301 = certificate true / document_version 1 기준 유지
stale document_version 조건 UPDATE = 0행
GIN·표현식 인덱스 2개 valid / ready
COURSE-301 title DRIFT 주입 시 07 실패 확인
원본 제목 복원 뒤 07 재통과
course_project 전체 fingerprint 실행 전후 동일
예상 밖 nosql_lab.keep_me 존재 시 reset 전체 ROLLBACK
정상 reset 뒤 nosql_lab만 제거
reset 뒤 course_project fingerprint 동일
reset 뒤 Chapter 08 gate 재통과
Chapter 12 작성 발표 스크립트 자동 확장 비활성화 확인
```

### 최종 개념 경계

```text
NoSQL 계열 이름만으로 트랜잭션·일관성·확장성 보장을 단정하지 않음
Key-Value의 정확 키 조회와 TTL 정책을 구분
TTL expiration과 메모리 압박 eviction을 구분
Document DB 원자성·다중 문서 트랜잭션을 제품·배포 구성별로 확인
Cassandra partition key·clustering column 설명을 조회 패턴 중심으로 한정
PostgreSQL jsonb_ops·jsonb_path_ops 지원 연산자 범위를 실제 질의와 연결
```

별도 MongoDB·Redis·Cassandra·Graph DB 서버의 성능·분산·장애 특성은 이번 PostgreSQL 자동 검증의 통과 범위로 주장하지 않습니다.
'''
    validation_path.write_text(validation.rstrip() + '\n', encoding='utf-8')

checklist_path = Path('notes/chapter12_review_checklist.md')
checklist = checklist_path.read_text(encoding='utf-8')
run_marker = 'Run ID: 31390439293'
if run_marker not in checklist:
    checklist += r'''

### 최종 자동 검증 기록

```text
Workflow: Chapter 12 final publication validation v2 once
Run: 1
Run ID: 31390439293
Validation commit: 96ce73e3a03593ae0c604dc9637fdf241fe1bc03
Content commit: b5c868b36cb71d5957ff05c392bca771d35f57b5
PostgreSQL: 16
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
```
'''
    checklist_path.write_text(checklist.rstrip() + '\n', encoding='utf-8')

print('Chapter 12 final validation record prepared')
