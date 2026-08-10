from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding='utf-8')


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    if old not in text:
        raise SystemExit(f'missing replacement target in {path}: {old[:100]!r}')
    text = text.replace(old, new, 1)
    write(path, text)


# ------------------------------------------------------------------
# 1. 01 schema gate: precheck before DDL transaction + privilege/contract
# ------------------------------------------------------------------
path = 'code/chapter09/01_transaction_lab_schema.sql'
text = read(path)
text = text.replace(
    'SHOW search_path;\n\nBEGIN;\n\nDO $$',
    'SHOW search_path;\n\n-- 잘못된 환경에서는 DDL 트랜잭션을 열기 전에 중단합니다.\nDO $$',
    1,
)
text = text.replace(
    '    v_non_cancelled_amount NUMERIC;\nBEGIN',
    '    v_non_cancelled_amount NUMERIC;\n    v_named_constraint_count BIGINT;\n    v_not_null_count BIGINT;\nBEGIN',
    1,
)
anchor = """    IF to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: Chapter 07 활성 신청 부분 고유 인덱스를 확인하세요.';
    END IF;

    IF to_regnamespace('transaction_lab') IS NOT NULL THEN
"""
insert = """    IF to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN
        RAISE EXCEPTION
            '실행 중단: Chapter 07 활성 신청 부분 고유 인덱스를 확인하세요.';
    END IF;

    IF NOT has_database_privilege(current_user, current_database(), 'CREATE') THEN
        RAISE EXCEPTION
            '실행 중단: 현재 역할 %에는 데이터베이스 %의 CREATE 권한이 없습니다.',
            current_user,
            current_database();
    END IF;

    SELECT COUNT(*) INTO v_named_constraint_count
    FROM pg_constraint
    WHERE conrelid IN (
        'course_project.students'::regclass,
        'course_project.instructors'::regclass,
        'course_project.courses'::regclass,
        'course_project.enrollments'::regclass
    )
      AND conname IN (
        'uq_course_students_email',
        'chk_course_students_name_not_blank',
        'chk_course_students_email_not_blank',
        'uq_course_instructors_email',
        'chk_course_instructors_name_not_blank',
        'chk_course_instructors_email_not_blank',
        'chk_course_instructors_specialty_not_blank',
        'fk_course_courses_instructor',
        'chk_course_courses_title_not_blank',
        'chk_course_courses_level',
        'chk_course_courses_price',
        'fk_course_enrollments_student',
        'fk_course_enrollments_course',
        'chk_course_enrollments_status',
        'chk_course_enrollments_recorded_amount'
      );

    SELECT COUNT(*) INTO v_not_null_count
    FROM information_schema.columns
    WHERE table_schema = 'course_project'
      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')
      AND is_nullable = 'NO';

    IF v_named_constraint_count <> 15 OR v_not_null_count <> 20 THEN
        RAISE EXCEPTION
            '실행 중단: Chapter 07 구조 기준과 다릅니다. named_constraints=%, not_null_columns=%',
            v_named_constraint_count,
            v_not_null_count;
    END IF;

    IF to_regnamespace('transaction_lab') IS NOT NULL THEN
"""
if anchor not in text:
    raise SystemExit('01 privilege/contract anchor not found')
text = text.replace(anchor, insert, 1)
text = text.replace('END\n$$;\n\nCREATE SCHEMA transaction_lab;', 'END\n$$;\n\nBEGIN;\n\nCREATE SCHEMA transaction_lab;', 1)
write(path, text)

# ------------------------------------------------------------------
# 2. 06 final gate: keep Chapter 07 structure contract visible to Chapter 09
# ------------------------------------------------------------------
path = 'code/chapter09/06_transaction_validation.sql'
text = read(path)
anchor = """    IF (SELECT COUNT(*) FROM course_project.students) <> 3
       OR (SELECT COUNT(*) FROM course_project.instructors) <> 2
       OR (SELECT COUNT(*) FROM course_project.courses) <> 3
       OR (SELECT COUNT(*) FROM course_project.enrollments) <> 5 THEN
        RAISE EXCEPTION
            '최종 검증 실패: Chapter 07 기준 행 수 3/2/3/5가 유지되지 않았습니다.';
    END IF;

"""
insert = anchor + """    IF (
        SELECT COUNT(*)
        FROM pg_constraint
        WHERE conrelid IN (
            'course_project.students'::regclass,
            'course_project.instructors'::regclass,
            'course_project.courses'::regclass,
            'course_project.enrollments'::regclass
        )
          AND conname IN (
            'uq_course_students_email',
            'chk_course_students_name_not_blank',
            'chk_course_students_email_not_blank',
            'uq_course_instructors_email',
            'chk_course_instructors_name_not_blank',
            'chk_course_instructors_email_not_blank',
            'chk_course_instructors_specialty_not_blank',
            'fk_course_courses_instructor',
            'chk_course_courses_title_not_blank',
            'chk_course_courses_level',
            'chk_course_courses_price',
            'fk_course_enrollments_student',
            'fk_course_enrollments_course',
            'chk_course_enrollments_status',
            'chk_course_enrollments_recorded_amount'
          )
    ) <> 15 OR (
        SELECT COUNT(*)
        FROM information_schema.columns
        WHERE table_schema = 'course_project'
          AND table_name IN ('students', 'instructors', 'courses', 'enrollments')
          AND is_nullable = 'NO'
    ) <> 20 THEN
        RAISE EXCEPTION
            '최종 검증 실패: Chapter 07 구조 기준 15개 명명 제약조건 / 20개 NOT NULL 열이 유지되지 않았습니다.';
    END IF;

"""
if anchor not in text:
    raise SystemExit('06 structure anchor not found')
text = text.replace(anchor, insert, 1)
write(path, text)

# ------------------------------------------------------------------
# 3. Cancellation: restore seat only from a successful cancellation row
# ------------------------------------------------------------------
path = 'code/chapter09/08_cancel_and_restore.sql'
text = read(path)
old = """UPDATE transaction_lab.enrollments
SET status = '취소'
WHERE id = 9001
  AND status = '수강중'
RETURNING id, student_id, course_id, status;

UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats + 1
WHERE course_id = 301
  AND remaining_seats < capacity
RETURNING course_id, capacity, remaining_seats;
"""
new = """-- 상태 변경에 성공한 신청 행만 좌석 복구의 입력으로 사용합니다.
-- 같은 취소가 재시도되면 cancelled가 0행이므로 좌석도 다시 증가하지 않습니다.
WITH cancelled AS (
    UPDATE transaction_lab.enrollments
    SET status = '취소'
    WHERE id = 9001
      AND status = '수강중'
    RETURNING id, student_id, course_id, status
),
restored AS (
    UPDATE transaction_lab.course_inventory AS ci
    SET remaining_seats = ci.remaining_seats + 1
    FROM cancelled AS e
    WHERE ci.course_id = e.course_id
      AND ci.remaining_seats < ci.capacity
    RETURNING ci.course_id, ci.capacity, ci.remaining_seats
)
SELECT
    e.id AS enrollment_id,
    e.status,
    r.course_id,
    r.capacity,
    r.remaining_seats
FROM cancelled AS e
JOIN restored AS r
    ON r.course_id = e.course_id;

-- 동일 취소를 한 번 더 시도해도 상태 변경과 좌석 복구는 모두 0행입니다.
WITH cancelled AS (
    UPDATE transaction_lab.enrollments
    SET status = '취소'
    WHERE id = 9001
      AND status = '수강중'
    RETURNING course_id
),
restored AS (
    UPDATE transaction_lab.course_inventory AS ci
    SET remaining_seats = ci.remaining_seats + 1
    FROM cancelled AS e
    WHERE ci.course_id = e.course_id
      AND ci.remaining_seats < ci.capacity
    RETURNING ci.course_id
)
SELECT
    (SELECT COUNT(*) FROM cancelled) AS repeated_cancel_count,
    (SELECT COUNT(*) FROM restored) AS repeated_restore_count;
"""
if old not in text:
    raise SystemExit('08 independent cancellation block not found')
text = text.replace(old, new, 1)
write(path, text)

# ------------------------------------------------------------------
# 4. Concurrency note: FOR UPDATE is useful, not universally mandatory
# ------------------------------------------------------------------
path = 'code/chapter09/07_concurrency_two_sessions.sql'
replace_once(
    path,
    """-- RETURNING 또는 영향 행 수
--   → 좌석 확보 성공 여부를 확인합니다.
""",
    """-- RETURNING 또는 영향 행 수
--   → 좌석 확보 성공 여부를 확인합니다.
-- 단일 조건부 UPDATE ... RETURNING 자체도 수정 대상 행의 잠금을 획득합니다.
-- FOR UPDATE는 잠근 상태를 먼저 읽고 여러 후속 판단을 이어갈 때 특히 유용합니다.
""",
)

# ------------------------------------------------------------------
# 5. Book manuscript
# ------------------------------------------------------------------
path = 'book/chapter09/chapter09.md'
text = read(path)
text = text.replace(
    """course_project.uq_course_enrollments_active 존재
transaction_lab 스키마가 아직 없음
""",
    """course_project.uq_course_enrollments_active 존재
Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개
현재 역할에 ai_database_book CREATE 권한 존재
transaction_lab 스키마가 아직 없음
""",
    1,
)
text = text.replace(
    """스키마와 세 테이블 생성은 하나의 트랜잭션 안에서 실행합니다.

```sql
BEGIN;

-- 사전 조건 검사
-- CREATE SCHEMA
-- CREATE TABLE
-- CREATE INDEX

COMMIT;
```

중간의 `CREATE TABLE`이 실패하면 전체 생성 단위가 확정되지 않으므로 일부 객체만 남는 위험을 줄일 수 있습니다.
""",
    """사전 조건은 DDL 트랜잭션을 열기 전에 검사합니다. 잘못된 데이터베이스, Chapter 07 구조 드리프트, 권한 부족이나 기존 `transaction_lab`이 발견되면 스키마 생성을 시작하지 않습니다.

스키마와 세 테이블 생성 자체는 하나의 트랜잭션 안에서 실행합니다.

```sql
-- 사전 조건 검사

BEGIN;

-- CREATE SCHEMA
-- CREATE TABLE
-- CREATE INDEX
-- 생성 결과 검증

COMMIT;
```

중간의 `CREATE TABLE`이나 생성 결과 검증이 실패하면 DDL 트랜잭션을 `ROLLBACK`으로 정리한 뒤 원인을 수정합니다. PostgreSQL에서는 이 장에서 사용하는 `CREATE SCHEMA`, `CREATE TABLE`, `CREATE INDEX` 같은 DDL도 트랜잭션 경계 안에서 함께 취소할 수 있습니다.
""",
    1,
)
text = text.replace(
    """`FOR UPDATE OF ci`는 좌석 상태 행을 수정 대상으로 잠급니다. 그러나 잠금만으로 업무 성공이 결정되는 것은 아닙니다.

```text
SELECT ... FOR UPDATE
→ 대상 행 잠금과 현재 상태 관찰

UPDATE ... WHERE remaining_seats > 0
→ 좌석이 실제로 남아 있을 때만 변경

RETURNING·영향 행 수
→ 좌석 확보 성공 여부 확인
```
""",
    """`FOR UPDATE OF ci`는 좌석 상태 행을 수정 대상으로 잠급니다. 그러나 잠금만으로 업무 성공이 결정되는 것은 아닙니다.

```text
SELECT ... FOR UPDATE
→ 대상 행을 잠근 상태로 읽고 후속 판단 준비

UPDATE ... WHERE remaining_seats > 0
→ 좌석이 실제로 남아 있을 때만 변경

RETURNING·영향 행 수
→ 좌석 확보 성공 여부 확인
```

`UPDATE ... WHERE ... RETURNING` 자체도 수정 대상 행에 필요한 행 잠금을 획득하므로, 단일 조건부 변경만 필요한 경우 선행 `SELECT ... FOR UPDATE`가 항상 필수인 것은 아닙니다. 이 장에서는 좌석 행을 잠근 상태로 먼저 관찰한 뒤 여러 후속 판단을 이어 가는 흐름과 두 세션 대기를 명확히 학습하기 위해 `FOR UPDATE`를 명시합니다.
""",
    1,
)
old_cancel = """`08_cancel_and_restore.sql`은 신청 9001을 임시로 취소하고 강의 301 좌석을 1개 복구합니다.

```sql
BEGIN;

UPDATE transaction_lab.enrollments
SET status = '취소'
WHERE id = 9001
  AND status = '수강중';

UPDATE transaction_lab.course_inventory
SET remaining_seats = remaining_seats + 1
WHERE course_id = 301
  AND remaining_seats < capacity;

-- 검증
ROLLBACK;
```

선택 실습은 주 실습의 최종 상태를 보존하기 위해 기본적으로 ROLLBACK합니다.
"""
new_cancel = """`08_cancel_and_restore.sql`은 신청 9001을 임시로 취소하고 강의 301 좌석을 1개 복구합니다. 중요한 점은 두 UPDATE를 단순히 나란히 실행하는 것이 아니라, **취소에 실제로 성공한 행만 좌석 복구의 입력으로 연결한다**는 것입니다.

```sql
BEGIN;

WITH cancelled AS (
    UPDATE transaction_lab.enrollments
    SET status = '취소'
    WHERE id = 9001
      AND status = '수강중'
    RETURNING course_id
)
UPDATE transaction_lab.course_inventory AS ci
SET remaining_seats = ci.remaining_seats + 1
FROM cancelled AS e
WHERE ci.course_id = e.course_id
  AND ci.remaining_seats < ci.capacity;

-- 검증
ROLLBACK;
```

같은 취소를 다시 실행하면 첫 UPDATE가 0행이므로 `cancelled`도 비고 좌석 복구 UPDATE도 0행입니다. 이렇게 상태 전이의 성공 결과에 후속 변경을 연결하면 재시도나 동시 실행에서 좌석이 두 번 복구되는 위험을 줄일 수 있습니다. 이것은 외부 시스템 전체의 멱등성을 완성한다는 뜻은 아니며, 실제 서비스에서는 별도의 요청 ID나 멱등성 키도 함께 설계합니다.

선택 실습은 주 실습의 최종 상태를 보존하기 위해 기본적으로 ROLLBACK합니다.
"""
if old_cancel not in text:
    raise SystemExit('chapter cancellation section not found')
text = text.replace(old_cancel, new_cancel, 1)
text = text.replace(
    '9. 취소 상태만 바꾸고 좌석을 복구하지 않는다.\n',
    '9. 취소 UPDATE의 성공 여부와 무관하게 좌석을 별도로 복구해 중복 취소에서 좌석이 두 번 늘어날 수 있게 한다.\n',
    1,
)
text = text.replace(
    '8. FOR UPDATE와 조건부 UPDATE의 역할을 구분한다.\n',
    '8. FOR UPDATE가 항상 필수인 것은 아니며, 잠근 상태의 선행 읽기가 필요한 경우와 조건부 UPDATE 자체의 잠금을 구분한다.\n',
    1,
)
text = text.replace(
    '10. 취소와 좌석 복구도 하나의 트랜잭션으로 처리한다.\n',
    '10. 취소 성공 결과에 좌석 복구를 연결해 재시도에서도 한 번만 복구되게 한다.\n',
    1,
)
write(path, text)

# ------------------------------------------------------------------
# 6. Outline
# ------------------------------------------------------------------
path = 'book/chapter09/chapter09_outline.md'
text = read(path)
text = text.replace(
    'FOR UPDATE와 조건부 UPDATE의 역할은 어떻게 다른가?\n',
    'FOR UPDATE와 조건부 UPDATE의 역할은 어떻게 다르며, FOR UPDATE가 항상 필요한가?\n',
    1,
)
text = text.replace(
    '- `SELECT ... FOR UPDATE`와 조건부 UPDATE의 역할을 구분할 수 있다.\n',
    '- `SELECT ... FOR UPDATE`와 조건부 UPDATE의 역할을 구분하고 선행 잠금 조회가 필요한 경우를 설명할 수 있다.\n',
    1,
)
text = text.replace(
    '- 취소와 좌석 복구를 같은 트랜잭션으로 처리할 수 있다.\n',
    '- 취소 성공 결과에 좌석 복구를 연결해 중복 취소의 이중 복구를 막을 수 있다.\n',
    1,
)
text = text.replace(
    'uq_course_enrollments_active 존재\ntransaction_lab 미생성 상태\n',
    'uq_course_enrollments_active 존재\nChapter 07 명명 제약조건 15개 / NOT NULL 열 20개\n현재 역할의 ai_database_book CREATE 권한\ntransaction_lab 미생성 상태\n',
    1,
)
text = text.replace(
    '- 취소와 좌석 복구를 같은 트랜잭션으로 처리한다.\n',
    '- 취소 UPDATE가 성공한 행에만 좌석 복구를 연결한다.\n- 동일 취소 재시도에서 상태 변경·좌석 복구가 모두 0행인지 확인한다.\n',
    1,
)
write(path, text)

# ------------------------------------------------------------------
# 7. Reader activity
# ------------------------------------------------------------------
path = 'book/chapter09/chapter09_activity.md'
text = read(path)
text = text.replace(
    '| `recorded_amount` 타입 | `NUMERIC(12,0)` |  |\n',
    '| `recorded_amount` 타입 | `NUMERIC(12,0)` |  |\n| Chapter 07 명명 제약조건 | 15개 |  |\n| Chapter 07 NOT NULL 열 | 20개 |  |\n| 현재 역할 DB CREATE 권한 | 있음 |  |\n',
    1,
)
text = text.replace(
    """| CTE의 `seat` 결과 |  |  |

### COMMIT 전 결과
""",
    """| CTE의 `seat` 결과 |  |  |

```text
단일 조건부 UPDATE ... RETURNING만 사용할 때도 행 잠금은 발생합니다.
그렇다면 이 장에서 SELECT ... FOR UPDATE를 먼저 사용한 이유는 무엇인가요?
________________________________________________________________________
```

### COMMIT 전 결과
""",
    1,
)
text = text.replace(
    """상태만 취소로 바꾸고 좌석을 복구하지 않으면 발생하는 문제:
________________________________________________________________________
```

```text
payment 행을 유지하면서도 별도 환불 모델이 필요한 이유:
""",
    """상태만 취소로 바꾸고 좌석을 복구하지 않으면 발생하는 문제:
________________________________________________________________________
```

```text
취소 UPDATE가 0행일 때 좌석 UPDATE도 0행이어야 하는 이유:
________________________________________________________________________

동일 취소를 두 번 시도했을 때 기대하는 좌석 변화:
________________________________________________________________________
```

```text
payment 행을 유지하면서도 별도 환불 모델이 필요한 이유:
""",
    1,
)
write(path, text)

# ------------------------------------------------------------------
# 8. Code README
# ------------------------------------------------------------------
path = 'code/chapter09/README.md'
text = read(path)
text = text.replace(
    'uq_course_enrollments_active 존재\n강의 301/302/303 가격 = 100000/120000/150000\n',
    'uq_course_enrollments_active 존재\nChapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20\n현재 역할의 ai_database_book CREATE 권한\n강의 301/302/303 가격 = 100000/120000/150000\n',
    1,
)
text = text.replace(
    """`SELECT ... FOR UPDATE`는 행을 잠그고 최신 상태를 관찰하는 역할입니다. 실제 좌석 확보 성공은 `UPDATE ... WHERE remaining_seats > 0`의 결과와 `RETURNING`으로 판단합니다.

좌석 확보가 0행이면 SQL 오류가 아니라 업무상 좌석 부족이며 후속 신청·결제도 0건이어야 합니다.
""",
    """`SELECT ... FOR UPDATE`는 행을 잠근 상태로 읽고 여러 후속 판단을 이어갈 때 유용합니다. `UPDATE ... WHERE ... RETURNING` 자체도 수정 대상 행에 필요한 잠금을 획득하므로 선행 `FOR UPDATE`가 항상 필수인 것은 아닙니다. 실제 좌석 확보 성공은 `UPDATE ... WHERE remaining_seats > 0`의 결과와 `RETURNING`으로 판단합니다.

좌석 확보가 0행이면 SQL 오류가 아니라 업무상 좌석 부족이며 후속 신청·결제도 0건이어야 합니다.
""",
    1,
)
text = text.replace(
    """`08_cancel_and_restore.sql`은 다음을 같은 트랜잭션에서 실행합니다.

```text
9001 수강중 → 취소
course 301 remaining 1 → 2
payment 9901 기록 유지
```

선택 실습이므로 마지막에 ROLLBACK하고, 자동 게이트가 9001·9901·좌석이 주 실습 기준으로 정확히 돌아왔는지 확인합니다.
""",
    """`08_cancel_and_restore.sql`은 취소 UPDATE의 `RETURNING` 결과를 좌석 복구 CTE에 연결합니다.

```text
9001 수강중 → 취소 성공 1행
→ 성공 행의 course_id만 좌석 복구에 전달
→ course 301 remaining 1 → 2
→ 동일 취소 재시도 = 취소 0행 / 좌석 복구 0행
payment 9901 기록 유지
```

따라서 이미 취소된 신청을 다시 처리해도 좌석을 두 번 늘리지 않습니다. 선택 실습이므로 마지막에 ROLLBACK하고, 자동 게이트가 9001·9901·좌석이 주 실습 기준으로 정확히 돌아왔는지 확인합니다.
""",
    1,
)
write(path, text)

# ------------------------------------------------------------------
# 9. Theory/practice lecture plans
# ------------------------------------------------------------------
path = 'presentation/chapter09/chapter09_theory_lecture_plan.md'
text = read(path)
text = text.replace(
    'transaction_lab 기존 없음\n',
    'Chapter 07 구조 = 명명 제약조건 15 / NOT NULL 20\n현재 역할 DB CREATE 권한 있음\ntransaction_lab 기존 없음\n',
    1,
)
text = text.replace(
    """실제 성공 여부는 이후 `remaining_seats > 0` 조건이 있는 업데이트가 1행을 바꾸었는지로 확인해야 합니다.
""",
    """실제 성공 여부는 이후 `remaining_seats > 0` 조건이 있는 업데이트가 1행을 바꾸었는지로 확인해야 합니다.

단일 조건부 업데이트 자체도 수정할 행에 필요한 잠금을 획득하므로 `FOR UPDATE`가 모든 UPDATE 앞에 반드시 필요한 것은 아닙니다. 여기서는 잠근 상태의 좌석을 먼저 읽고 후속 판단을 이어가는 흐름과 두 세션 대기를 분명하게 보기 위해 사용합니다.
""",
    1,
)
text = text.replace(
    '취소와 좌석 복구도 하나의 트랜잭션입니다',
    '취소 성공 결과에 좌석 복구를 연결합니다',
    1,
)
text = text.replace(
    """수강중 신청을 취소하면 좌석도 같은 트랜잭션에서 복구해야 합니다.
""",
    """수강중 신청을 취소하면 좌석도 같은 트랜잭션에서 복구해야 합니다. 이때 취소 UPDATE의 성공 행을 좌석 복구의 입력으로 연결하면 이미 취소된 신청을 다시 처리해도 좌석이 두 번 증가하지 않습니다.
""",
    1,
)
write(path, text)

path = 'presentation/chapter09/chapter09_practice_lecture_plan.md'
text = read(path)
text = text.replace(
    'transaction_lab 기존 없음\n',
    'Chapter 07 구조 = 명명 제약조건 15 / NOT NULL 20\n현재 역할 DB CREATE 권한 있음\ntransaction_lab 기존 없음\n',
    1,
)
text = text.replace(
    """하지만 이 시점에는 좌석이 줄어든 것이 아닙니다. 잠금은 최신 상태를 확인하고 안전하게 변경할 준비를 하는 단계입니다.
""",
    """하지만 이 시점에는 좌석이 줄어든 것이 아닙니다. 잠금은 최신 상태를 확인하고 안전하게 변경할 준비를 하는 단계입니다.

또한 조건부 `UPDATE ... RETURNING` 자체도 수정 대상 행을 잠급니다. 선행 `FOR UPDATE`가 항상 필수인 것은 아니며, 이번 실습에서는 잠근 상태를 먼저 관찰하고 여러 후속 판단을 이어가는 흐름을 확인하기 위해 명시합니다.
""",
    1,
)
text = text.replace(
    '취소와 좌석 복구도 하나의 트랜잭션입니다',
    '취소 성공 결과에 좌석 복구를 연결합니다',
    1,
)
text = text.replace(
    """`08_cancel_and_restore.sql`은 기본적으로 마지막에 ROLLBACK합니다.
""",
    """`08_cancel_and_restore.sql`은 취소 UPDATE의 성공 행을 좌석 복구 CTE에 연결하고, 동일 취소를 한 번 더 시도했을 때 취소와 좌석 복구가 모두 0행인지 확인한 뒤 마지막에 ROLLBACK합니다.
""",
    1,
)
write(path, text)

# ------------------------------------------------------------------
# 10. Presentation authored narration + asset version
# ------------------------------------------------------------------
path = 'presentation/chapter09/chapter09_script.html'
text = read(path)
if '<body>' not in text:
    raise SystemExit('chapter09 script body target missing')
text = text.replace('<body>', '<body data-script-content-enhancer="off">', 1)
text = text.replace('script_content_enhancer.js?v=20260808e', 'script_content_enhancer.js?v=20260810a')
text = text.replace('20260809a', '20260810a')
write(path, text)

for path in [
    'presentation/chapter09/chapter09_player.js',
    'presentation/chapter09/chapter09_script.js',
    'presentation/chapter09/chapter09_theory_presentation.html',
    'presentation/chapter09/chapter09_practice_presentation.html',
    'presentation/chapter09/index.html',
]:
    text = read(path)
    text = text.replace('20260809a', '20260810a')
    write(path, text)

# ------------------------------------------------------------------
# 11. Review revision record
# ------------------------------------------------------------------
path = 'book/chapter09/chapter09_review_revision.md'
text = read(path)
append = """

---

## 2026-08-10 최종 출판 보완

- Chapter 09 시작 게이트가 Chapter 07의 15개 명명 제약조건과 20개 NOT NULL 열을 확인하도록 강화했다.
- 현재 역할에 `ai_database_book`의 `CREATE` 권한이 없으면 `transaction_lab` 생성을 시작하지 않도록 했다.
- 사전 조건 검사를 DDL `BEGIN`보다 먼저 수행해 잘못된 환경에서 불필요한 명시적 트랜잭션을 열지 않도록 정리했다.
- `SELECT ... FOR UPDATE`가 항상 필수인 것처럼 읽히지 않도록, 조건부 `UPDATE ... RETURNING` 자체도 수정 행 잠금을 획득한다는 점과 선행 잠금 조회가 유용한 경우를 구분했다.
- 취소와 좌석 복구를 독립 UPDATE 두 개가 아니라 취소 성공 행을 좌석 복구에 전달하는 데이터 변경 CTE로 연결했다.
- 동일 취소 재시도에서 취소 0행 / 좌석 복구 0행이 되어 좌석이 두 번 증가하지 않는 경로를 실습에 추가했다.
- Chapter 09 발표 스크립트는 작성 원문을 그대로 사용하도록 자동 content enhancer를 비활성화했다.
- 발표 자산 버전을 `20260810a`로 갱신했다.
"""
if '## 2026-08-10 최종 출판 보완' not in text:
    text += append
write(path, text)

# ------------------------------------------------------------------
# 12. Regenerate merged manuscript
# ------------------------------------------------------------------
import subprocess
subprocess.run(['python', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)

print('Chapter 09 final publication review applied successfully')
