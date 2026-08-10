from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

validation_path = ROOT / 'notes/chapter09_validation_result.md'
validation = validation_path.read_text(encoding='utf-8')
record = r'''

---

## 2026-08-10 최종 출판 재검증

Chapter 09 최종 출판 보완 뒤 PostgreSQL 16에서 전용 검증 워크플로를 다시 실행했다.

```text
Workflow: Validate Chapter 09
Run: 5
Run ID: 31381404542
Commit: bd0095c51f7c0382796ba3a75a4bce4fdde44290
Status: completed
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
PostgreSQL: 16
```

최종 확인 범위:

```text
Chapter 07 기준 상태 실제 생성 성공
Chapter 08 사전·집계 게이트 재통과
Chapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20 인계 확인
잘못된 데이터베이스에서 Chapter 09 시작 차단
DB CREATE 권한이 없는 역할에서 transaction_lab 생성 차단
권한 차단 뒤 transaction_lab 미생성 확인
01 → 02 → 03 → 04 → 05 → 06 주 실습 전체 성공
주 실습 최종 상태 = inventory/enrollment/payment 3/2/2
좌석 301/302/303 = 1/0/1
course_project 전체 fingerprint 불변
01·02 재실행 보호 성공
취소 성공 행에만 좌석 복구 연결
동일 취소 재시도 시 좌석 이중 복구 없음
08 선택 실습의 반복 취소/복구 = 0행 / 0행
SAVEPOINT 중복 활성 신청 오류 복구 성공
두 세션 FOR UPDATE lock timeout과 복구 성공
reset은 transaction_lab만 제거하고 course_project fingerprint 유지
Chapter 09 작성 발표 스크립트 자동 확장 비활성화
발표 자산 버전 = 20260810a
```

특히 취소 실습은 상태 변경과 좌석 복구를 독립 UPDATE로 두지 않고, `UPDATE ... RETURNING`으로 실제 취소된 행을 다음 좌석 복구 CTE의 입력으로 전달하도록 바꾸었다. 따라서 이미 취소된 신청을 다시 처리하면 취소 행이 0건이고 좌석 복구도 0건이 되어 좌석이 두 번 증가하지 않는다.

또한 `SELECT ... FOR UPDATE`는 모든 UPDATE 앞에 필수인 문법으로 설명하지 않는다. 조건부 `UPDATE ... RETURNING` 자체도 수정 대상 행에 필요한 잠금을 획득하며, 선행 `FOR UPDATE`는 잠근 상태를 읽고 여러 후속 판단을 이어가거나 두 세션 대기를 관찰할 때 특히 유용하다는 기준으로 정리했다.
'''
if '## 2026-08-10 최종 출판 재검증' not in validation:
    validation += record
validation_path.write_text(validation, encoding='utf-8')

check_path = ROOT / 'notes/chapter09_review_checklist.md'
check = check_path.read_text(encoding='utf-8')
check_record = r'''

---

## 15. 2026-08-10 최종 출판 보완 및 재검증

- [x] Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 09 시작·최종 게이트에서 확인
- [x] 현재 역할의 `ai_database_book` CREATE 권한을 스키마 생성 전에 확인
- [x] 사전 조건 검사를 DDL 트랜잭션 시작 전에 수행
- [x] 권한 없는 역할에서 `transaction_lab` 생성이 차단되고 객체가 남지 않음을 PostgreSQL 16에서 확인
- [x] `FOR UPDATE`와 조건부 `UPDATE ... RETURNING` 자체의 행 잠금 역할을 정확히 구분
- [x] 취소 성공 행을 좌석 복구 CTE의 입력으로 연결
- [x] 동일 취소 재시도에서 취소 0행 / 좌석 복구 0행 확인
- [x] 다른 활성 신청이 남아 있는 course 301에서도 같은 취소를 두 번 실행해 좌석이 한 번만 복구됨을 실제 확인
- [x] Chapter 09 작성 발표 스크립트 자동 확장 비활성화
- [x] 발표 자산 버전 `20260810a` 동기화
- [x] 주 실습 01→06 / SAVEPOINT / Lock timeout / reset 전체 재검증
- [x] `course_project` 전체 fingerprint 실행 전후·reset 후 동일

### 최종 자동 검증 기록

```text
Workflow: Validate Chapter 09
Run: 5
Run ID: 31381404542
Commit: bd0095c51f7c0382796ba3a75a4bce4fdde44290
PostgreSQL: 16
Conclusion: success
Date: 2026-08-10 (Asia/Seoul)
```
'''
if '## 15. 2026-08-10 최종 출판 보완 및 재검증' not in check:
    check += check_record
check_path.write_text(check, encoding='utf-8')

print('Chapter 09 final validation record written')
