from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return (ROOT / path).read_text(encoding='utf-8')


def write(path, text):
    (ROOT / path).write_text(text, encoding='utf-8')


def replace_exact(path, old, new, count=1):
    text = read(path)
    actual = text.count(old)
    if actual < count:
        raise RuntimeError(f'{path}: expected at least {count} occurrence(s), found {actual}: {old[:120]!r}')
    write(path, text.replace(old, new, count))


# ------------------------------------------------------------------
# Main manuscript
# ------------------------------------------------------------------
p = 'book/chapter07/chapter07.md'
replace_exact(p,
    '| `P07-D01` | 무료 강의와 무료 신청 금액은 0 | `NOT NULL`, `CHECK >= 0` |',
    '| `P07-D01` | 무료 금액은 `0`으로 표현하고 `NULL`·음수는 허용하지 않음 | `NOT NULL`, `CHECK >= 0` |')
replace_exact(p,
    '| `P07-D02` | 신청 시 금액을 `recorded_amount`에 보존 | `NUMERIC(12, 0)` |',
    '| `P07-D02` | 할인 기능이 없는 현재 범위에서는 신청 생성 시 `courses.price`를 `recorded_amount`에 복사해 보존 | `INSERT ... SELECT` + `NUMERIC(12, 0)` |')
replace_exact(p,
    '두 값이 같아도 의미와 시점이 다릅니다. 강의 가격이 나중에 바뀌어도 과거 신청의 `recorded_amount`는 자동으로 바뀌지 않습니다.\n\n`recorded_amount`는 실제 결제 승인 금액을 뜻하지 않습니다.',
    '두 값이 같아도 의미와 시점이 다릅니다. 이번 프로젝트에는 쿠폰·할인 기능이 없으므로 **신청을 생성하는 순간의 `courses.price`를 `recorded_amount`에 복사**합니다. 강의 가격이 나중에 바뀌어도 과거 신청의 `recorded_amount`는 자동으로 바뀌지 않습니다.\n\n```sql\nINSERT INTO course_project.enrollments (\n    id, student_id, course_id, enrolled_at, status, recorded_amount\n)\nSELECT\n    1005, 102, c.id, DATE \'2026-04-07\', \'신청\', c.price\nFROM course_project.courses AS c\nWHERE c.id = 302;\n```\n\n이 복사는 `CHECK`나 외래키가 자동으로 수행하는 기능이 아닙니다. 현재 프로젝트에서는 신청 생성 SQL이 값을 복사하고, 이후 검증 SQL이 기대 금액을 확인합니다. 다른 행·다른 테이블의 현재 값을 `CHECK`로 계속 비교해 과거 기록을 강제로 맞추는 방식은 사용하지 않습니다.\n\n`recorded_amount`는 실제 결제 승인 금액을 뜻하지 않습니다.')
replace_exact(p,
    '완료·취소 이력은 여러 건 존재할 수 있지만 현재 진행 중인 신청은 학생·강의 조합당 최대 한 건만 허용합니다.',
    '완료·취소 이력은 여러 건 존재할 수 있지만 현재 진행 중인 신청은 학생·강의 조합당 최대 한 건만 허용합니다. `uq_course_enrollments_active`는 `UNIQUE` 제약조건이 아니라 조건을 만족하는 행에만 적용되는 **부분 고유 인덱스 객체**입니다.')
replace_exact(p,
    '현재 DB·쓰기 가능 상태·기존 스키마 확인\n→ course_project 스키마 생성',
    '현재 DB·DB의 `CREATE` 권한·쓰기 가능 상태·기존 스키마 확인\n→ course_project 스키마 생성')
replace_exact(p,
    '예상 상태와 실제 상태가 다르면 전체 변경을 완료하지 않습니다.',
    '예상 상태와 실제 상태가 다르면 전체 변경을 완료하지 않습니다. 조건부 `UPDATE`는 이 파일에서 실행하는 변경을 보호하는 방식이며, 모든 가능한 상태 전이를 데이터베이스 전체에서 강제하는 규칙은 아닙니다. 마지막 자동 검증까지 통과하지 못하면 같은 트랜잭션의 변경을 완료 상태로 보지 않습니다.')
replace_exact(p,
    '학생 이메일 중복\n허용되지 않은 난이도',
    '대표 `NOT NULL` 위반\n학생 이메일 중복\n허용되지 않은 난이도')
replace_exact(p,
    '새 기능은 바로 열을 추가하지 않고 다음 순서로 검토합니다.\n\n```text\n새 요구사항',
    '새 기능은 바로 열을 추가하지 않고 다음 순서로 검토합니다.\n\n[Chapter 07 독자 프로젝트 워크북](chapter07_activity.md)에는 실행 결과와 설계 판단을 직접 기록할 수 있는 체크 항목이 있습니다.\n\n```text\n새 요구사항')

# ------------------------------------------------------------------
# Outline
# ------------------------------------------------------------------
p = 'book/chapter07/chapter07_outline.md'
replace_exact(p, '| P07-D01 | 무료 금액은 0 | NOT NULL·CHECK |', '| P07-D01 | 무료 금액은 0, NULL·음수 금지 | NOT NULL·CHECK |')
replace_exact(p, '| P07-D02 | 신청 시 금액은 recorded_amount에 보존 | NUMERIC(12,0) |', '| P07-D02 | 신청 생성 시 현재 courses.price를 recorded_amount에 복사·보존 | INSERT ... SELECT·NUMERIC(12,0) |')
replace_exact(p,
    '| 01 | course_project 없음 | 네 테이블·명명 제약 15·NOT NULL 20·0행 |',
    '| 01 | course_project 없음 | DB CREATE 권한 확인·네 테이블·명명 제약 15·NOT NULL 20·0행 |')
replace_exact(p,
    '| 05 | 최종 상태 | 핵심 요구사항 경계·오류 테스트 |',
    '| 05 | 최종 상태 | 구조 기준 재확인·핵심 요구사항 경계·오류 테스트 |')
replace_exact(p,
    '01·02·03·reset은 작업 전체를 트랜잭션으로 묶는다. 04·05·06은 실행 전 기준 상태를 검사하며 기본 실행 자체는 프로젝트 데이터를 변경하지 않는다.',
    '01·02·03·reset은 작업 전체를 트랜잭션으로 묶는다. 01은 `CREATE SCHEMA` 전에 현재 역할의 데이터베이스 `CREATE` 권한도 확인한다. 04·05·06은 실행 전 구조와 기준 상태를 검사하며 기본 실행 자체는 프로젝트 데이터를 변경하지 않는다.')

# ------------------------------------------------------------------
# Workbook
# ------------------------------------------------------------------
p = 'book/chapter07/chapter07_activity.md'
replace_exact(p,
    '| 읽기 전용 여부 | 쓰기 가능한 연결 |  |',
    '| 읽기 전용 여부 | 쓰기 가능한 연결 |  |\n| DB `CREATE` 권한 | 01에서 스키마 생성 가능 |  |')
replace_exact(p,
    '`recorded_amount`가 실제 결제 승인 금액이나 회계 매출을 의미하지 않는 이유:\n\n```text\n________________________________________________________________________\n```',
    '`recorded_amount`가 실제 결제 승인 금액이나 회계 매출을 의미하지 않는 이유:\n\n```text\n________________________________________________________________________\n```\n\n할인 기능이 없는 이번 범위에서 신청 생성 시 `courses.price`를 `recorded_amount`에 복사하는 이유와, 이 규칙을 다른 테이블을 참조하는 `CHECK`로 만들지 않는 이유:\n\n```text\n________________________________________________________________________\n```')
replace_exact(p,
    '| 학생 이메일 중복 | 실패 |  | `uq_course_students_email` |',
    '| 학생 이름 NULL | 실패 |  | `NOT NULL` |\n| 학생 이메일 중복 | 실패 |  | `uq_course_students_email` |')

# ------------------------------------------------------------------
# Decisions
# ------------------------------------------------------------------
p = 'code/chapter07/PROJECT_DECISIONS.md'
replace_exact(p,
    '| P07-D01 | 무료 강의와 무료 신청 금액은 NULL이 아니라 0 | 0은 확정 금액, NULL은 미확정값과 구분 | NOT NULL·CHECK·경계 테스트 |',
    '| P07-D01 | 무료 금액은 0으로 표현하고 NULL·음수는 허용하지 않음 | 0은 확정 금액, NULL은 미확정값과 구분 | NOT NULL·CHECK·경계 테스트 |')
replace_exact(p,
    '| P07-D02 | 신청 시 금액을 recorded_amount에 보존 | 실제 결제 거래와 신청 행의 기록값을 구분 | NUMERIC(12,0), 과거 행 유지 |',
    '| P07-D02 | 할인 기능이 없는 현재 범위에서는 신청 생성 시 courses.price를 recorded_amount에 복사·보존 | 현재 기준 가격과 신청 당시 기록값을 구분 | INSERT ... SELECT, NUMERIC(12,0), 과거 행 유지 |')
replace_exact(p,
    '전체 기록 금액과 취소 제외 기록 금액은 회계 매출이나 환불 후 순수 금액이 아니다.',
    '현재 프로젝트에는 할인·쿠폰이 없으므로 신규 신청 SQL은 해당 시점의 `courses.price`를 조회해 `recorded_amount`로 복사한다. 이후 강의 가격이 바뀌어도 과거 신청 행은 갱신하지 않는다. 이 복사 규칙은 교차 테이블 `CHECK`로 구현하지 않고 신청 생성 SQL과 검증으로 관리한다.\n\n전체 기록 금액과 취소 제외 기록 금액은 회계 매출이나 환불 후 순수 금액이 아니다.')

# ------------------------------------------------------------------
# 01 schema: preflight CREATE privilege
# ------------------------------------------------------------------
for p in ['code/chapter07/01_course_project_schema.sql']:
    replace_exact(p,
        "    IF current_setting('transaction_read_only')::boolean THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: 현재 연결이 읽기 전용입니다.';\n    END IF;",
        "    IF NOT has_database_privilege(current_user, current_database(), 'CREATE') THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: 사용자 %에게 데이터베이스 %의 CREATE 권한이 없습니다.',\n            current_user,\n            current_database();\n    END IF;\n\n    IF current_setting('transaction_read_only')::boolean THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: 현재 연결이 읽기 전용입니다.';\n    END IF;")

# ------------------------------------------------------------------
# 03 changes: capture the course price rather than retyping it
# ------------------------------------------------------------------
p = 'code/chapter07/03_course_project_changes.sql'
replace_exact(p, '    v_active_102_302 bigint;\nBEGIN', '    v_active_102_302 bigint;\n    v_course_302_price numeric;\nBEGIN')
replace_exact(p,
    "    SELECT COUNT(*) INTO v_active_102_302\n    FROM course_project.enrollments\n    WHERE student_id = 102\n      AND course_id = 302\n      AND status IN ('신청', '수강중');\n\n    IF v_student_count <> 3",
    "    SELECT COUNT(*) INTO v_active_102_302\n    FROM course_project.enrollments\n    WHERE student_id = 102\n      AND course_id = 302\n      AND status IN ('신청', '수강중');\n\n    SELECT price INTO v_course_302_price\n    FROM course_project.courses\n    WHERE id = 302;\n\n    IF v_student_count <> 3")
replace_exact(p,
    '       OR v_count_1005 <> 0\n       OR v_active_102_302 <> 0 THEN',
    '       OR v_count_1005 <> 0\n       OR v_active_102_302 <> 0\n       OR v_course_302_price IS DISTINCT FROM 120000::numeric THEN')
replace_exact(p,
    "            '변경 시작 상태 불일치: rows=%/%/%/%, total=%, status1001=%, status1004=%, id1005=%, active102_302=%',",
    "            '변경 시작 상태 불일치: rows=%/%/%/%, total=%, status1001=%, status1004=%, id1005=%, active102_302=%, course302_price=%',")
replace_exact(p,
    '            v_count_1005,\n            v_active_102_302;',
    '            v_count_1005,\n            v_active_102_302,\n            v_course_302_price;')
replace_exact(p,
    "VALUES (\n    1005,\n    102,\n    302,\n    '2026-04-07',\n    '신청',\n    120000\n)\nRETURNING id, student_id, course_id, status, recorded_amount;",
    "SELECT\n    1005,\n    102,\n    c.id,\n    DATE '2026-04-07',\n    '신청',\n    c.price\nFROM course_project.courses AS c\nWHERE c.id = 302\nRETURNING id, student_id, course_id, status, recorded_amount;")

# ------------------------------------------------------------------
# 05/06 test files: verify structure before optional manual tests
# ------------------------------------------------------------------
for p in ['code/chapter07/05_course_project_integrity_tests.sql', 'code/chapter07/06_course_project_optional_tests.sql']:
    replace_exact(p, 'DO $$\nDECLARE\n', 'DO $$\nDECLARE\n    v_named_constraint_count bigint;\n    v_not_null_count bigint;\n', count=1)
    marker = "    IF to_regclass('course_project.students') IS NULL\n       OR to_regclass('course_project.instructors') IS NULL\n       OR to_regclass('course_project.courses') IS NULL\n       OR to_regclass('course_project.enrollments') IS NULL\n       OR to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN"
    pos = read(p).find(marker)
    if pos < 0:
        raise RuntimeError(f'{p}: object baseline marker missing')
    # Insert metadata verification after the object existence IF block.
    if p.endswith('05_course_project_integrity_tests.sql'):
        old = "        RAISE EXCEPTION '테스트 중단: Chapter 07 프로젝트 객체가 모두 존재하지 않습니다.';\n    END IF;\n\n    SELECT"
        new = "        RAISE EXCEPTION '테스트 중단: Chapter 07 프로젝트 객체가 모두 존재하지 않습니다.';\n    END IF;\n\n    SELECT COUNT(*) INTO v_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_named_constraint_count <> 15 OR v_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '테스트 중단: 구조 기준이 다릅니다. named_constraints=%, not_null_columns=%',\n            v_named_constraint_count, v_not_null_count;\n    END IF;\n\n    SELECT"
    else:
        old = "        RAISE EXCEPTION '선택 테스트 중단: Chapter 07 프로젝트 객체가 모두 존재하지 않습니다.';\n    END IF;\n\n    IF (SELECT COUNT(*) FROM course_project.students) <> 3"
        new = "        RAISE EXCEPTION '선택 테스트 중단: Chapter 07 프로젝트 객체가 모두 존재하지 않습니다.';\n    END IF;\n\n    SELECT COUNT(*) INTO v_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_named_constraint_count <> 15 OR v_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '선택 테스트 중단: 구조 기준이 다릅니다. named_constraints=%, not_null_columns=%',\n            v_named_constraint_count, v_not_null_count;\n    END IF;\n\n    IF (SELECT COUNT(*) FROM course_project.students) <> 3"
    replace_exact(p, old, new)

p = 'code/chapter07/05_course_project_integrity_tests.sql'
replace_exact(p,
    '-- 오류 1. 학생 이메일 중복 → uq_course_students_email',
    "-- 오류 0. 학생 이름 NULL → NOT NULL\n-- INSERT INTO course_project.students (id,name,email,joined_at)\n-- VALUES (1900,NULL,'null-name@example.com',DATE '2026-03-20');\n\n-- 오류 1. 학생 이메일 중복 → uq_course_students_email")

# ------------------------------------------------------------------
# README
# ------------------------------------------------------------------
p = 'code/chapter07/README.md'
replace_exact(p,
    '7. 완료 후 04 검증 파일을 다시 실행한다.\n```',
    '7. 완료 후 04 검증 파일을 다시 실행한다.\n8. 01에서 스키마를 생성한 역할과 같은 PostgreSQL 역할로 02~06·reset을 실행한다.\n```')
replace_exact(p,
    '| P07-D01 | 무료 금액은 0 | NOT NULL·CHECK |',
    '| P07-D01 | 무료 금액은 0, NULL·음수 금지 | NOT NULL·CHECK |')
replace_exact(p,
    '| P07-D02 | 신청 시 금액 보존 | recorded_amount |',
    '| P07-D02 | 신청 생성 시 현재 가격 복사·보존 | INSERT ... SELECT → recorded_amount |')
replace_exact(p,
    '두 열은 `NUMERIC(12,0)`을 사용합니다. `recorded_amount`는 실제 결제 승인액이나 환불 후 순수 금액, 회계 매출이 아닙니다. 실제 결제·환불 이력은 현재 프로젝트 범위 밖입니다.',
    '두 열은 `NUMERIC(12,0)`을 사용합니다. 현재 범위에는 할인·쿠폰이 없으므로 신규 신청은 해당 시점의 `courses.price`를 조회해 `recorded_amount`로 복사합니다. 이 복사는 `CHECK`가 자동 수행하는 것이 아니라 신청 생성 SQL의 책임이며, 과거 행은 이후 가격 변경과 분리해 보존합니다. `recorded_amount`는 실제 결제 승인액이나 환불 후 순수 금액, 회계 매출이 아닙니다. 실제 결제·환불 이력은 현재 프로젝트 범위 밖입니다.')
replace_exact(p,
    'course_project 스키마 존재\n네 테이블 존재',
    '현재 역할에 ai_database_book의 CREATE 권한 존재\ncourse_project 스키마 존재\n네 테이블 존재')
replace_exact(p,
    '실패: 학생·강사 이메일 중복',
    '실패: 대표 NOT NULL 위반\n실패: 학생·강사 이메일 중복')

# ------------------------------------------------------------------
# Theory/practice lecture plans
# ------------------------------------------------------------------
p = 'presentation/chapter07/chapter07_theory_lecture_plan.md'
replace_exact(p,
    '반면 `인롤먼츠.recorded_amount`는 특정 학생의 신청 행에 그 시점의 금액을 기록한 값입니다. 강의 가격이 나중에 바뀌어도 과거 신청의 기록 금액은 그대로 남습니다. 이 값은 실제 결제 승인액이나 회계 매출을 뜻하지 않습니다.',
    '반면 `인롤먼츠.recorded_amount`는 특정 학생의 신청 행에 그 시점의 금액을 기록한 값입니다. 이번 프로젝트에는 할인 기능이 없기 때문에 신규 신청을 만들 때 현재 `코시스.price`를 조회해서 기록 금액으로 복사합니다. 강의 가격이 나중에 바뀌어도 과거 신청의 기록 금액은 그대로 남습니다. 이 값은 실제 결제 승인액이나 회계 매출을 뜻하지 않습니다.')
replace_exact(p,
    '그래서 이 장에서는 상태가 `신청` 또는 `수강중`인 활성 신청에만 고유성을 적용합니다. 완료나 취소 이력은 남길 수 있지만, 현재 진행 중인 중복 신청은 차단합니다.',
    '그래서 이 장에서는 상태가 `신청` 또는 `수강중`인 활성 신청에만 고유성을 적용합니다. 완료나 취소 이력은 남길 수 있지만, 현재 진행 중인 중복 신청은 차단합니다. 이 객체는 일반 유니크 제약조건이 아니라 조건이 붙은 부분 고유 인덱스입니다.')

p = 'presentation/chapter07/chapter07_practice_lecture_plan.md'
replace_exact(p,
    '실행 후에는 네 테이블과 부분 고유 인덱스뿐 아니라 명명 제약조건 15개, 낫 널 열 20개, 네 테이블 0행 상태까지 자동 확인합니다. 중간 생성이 실패하면 전체 트랜잭션이 확정되지 않습니다.',
    '실행 전에는 현재 데이터베이스에서 스키마를 만들 수 있는 CREATE 권한도 확인합니다. 실행 후에는 네 테이블과 부분 고유 인덱스뿐 아니라 명명 제약조건 15개, 낫 널 열 20개, 네 테이블 0행 상태까지 자동 확인합니다. 중간 생성이 실패하면 전체 트랜잭션이 확정되지 않습니다.')
replace_exact(p,
    '이 파일을 실행하면 최종 신청 수는 4건에서 5건이 됩니다. 신청 1004는 취소되지만 삭제되지 않고, 신청 시 기록 금액 150000도 그대로 남습니다. 세 변경은 하나의 트랜잭션으로 실행됩니다.',
    '이 파일을 실행하면 최종 신청 수는 4건에서 5건이 됩니다. 신규 신청 1005의 기록 금액은 숫자 120000을 다시 적는 대신 강의 302의 현재 `price`를 조회해 복사합니다. 신청 1004는 취소되지만 삭제되지 않고, 신청 시 기록 금액 150000도 그대로 남습니다. 세 변경은 하나의 트랜잭션으로 실행됩니다.')

# ------------------------------------------------------------------
# Disable generic automatic narration expansion only for Chapter 07
# ------------------------------------------------------------------
p = 'presentation/chapter07/chapter07_script.html'
replace_exact(p, '<body>', '<body data-script-content-enhancer="off">')

p = 'presentation/common/script_content_enhancer.js'
replace_exact(p,
    "  const apply = (root = document) => {\n    root.querySelectorAll?.('#card, .card').forEach(enhanceCard);",
    "  const apply = (root = document) => {\n    if (document.body?.dataset?.scriptContentEnhancer === 'off') return;\n    root.querySelectorAll?.('#card, .card').forEach(enhanceCard);")
replace_exact(p,
    "  const start = () => {\n    apply(document);\n    observer.observe(document.body, { childList: true, subtree: true });\n  };",
    "  const start = () => {\n    if (document.body?.dataset?.scriptContentEnhancer === 'off') return;\n    apply(document);\n    observer.observe(document.body, { childList: true, subtree: true });\n  };")

# ------------------------------------------------------------------
# Review/checklist records
# ------------------------------------------------------------------
p = 'book/chapter07/chapter07_review_revision.md'
text = read(p)
if '## 최종 출판 검수 추가 반영 (2026-08-10)' not in text:
    text += '''\n\n---\n\n## 최종 출판 검수 추가 반영 (2026-08-10)\n\n- P07-D01을 “무료 금액은 0, NULL·음수 금지”로 정밀화했다.\n- 할인 기능이 없는 현재 범위에서 신규 신청은 `courses.price`를 조회해 `recorded_amount`로 복사하도록 P07-D02와 03 변경 SQL을 일치시켰다.\n- `recorded_amount` 복사는 교차 테이블 `CHECK`가 아니라 신청 생성 SQL의 책임이라는 경계를 명시했다.\n- `01_course_project_schema.sql`에 현재 역할의 데이터베이스 `CREATE` 권한 사전 검사를 추가했다.\n- 05·06 테스트 시작 시 명명 제약조건 15개와 NOT NULL 열 20개를 다시 확인하도록 보강했다.\n- 05 핵심 테스트에 대표 NOT NULL 실패 예제를 추가했다.\n- 부분 고유 인덱스를 `UNIQUE` 제약조건과 구분해 설명했다.\n- Chapter 07 발표 스크립트에서는 공통 자동 문장 보강을 비활성화해 작성된 스크립트만 사용하도록 했다.\n- 독자 프로젝트 워크북 링크와 실행 역할 주의사항을 추가했다.\n'''
write(p, text)

p = 'notes/chapter07_review_checklist.md'
text = read(p)
if '## 최종 출판 보완 (2026-08-10)' not in text:
    text += '''\n\n---\n\n## 최종 출판 보완 (2026-08-10)\n\n- [x] P07-D01 무료 금액의 0 / NULL / 음수 의미 구분\n- [x] P07-D02 신규 신청 시 `courses.price` → `recorded_amount` 복사 흐름 명시\n- [x] 교차 테이블 CHECK로 과거 금액을 강제하지 않는 이유 설명\n- [x] 01의 데이터베이스 CREATE 권한 사전 검사\n- [x] 05·06 시작 시 제약조건 15·NOT NULL 20 구조 재확인\n- [x] 대표 NOT NULL 실패 예제 추가\n- [x] 부분 고유 인덱스와 UNIQUE 제약조건 구분\n- [x] Chapter 07 자동 스크립트 보강 비활성화\n- [ ] 최신 PostgreSQL 16 전체 경로 재검증 결과 확인\n'''
write(p, text)

# Rebuild merged manuscript so publication source stays synchronized.
subprocess.run(['python', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)

print('Chapter 07 final publication review applied successfully')
