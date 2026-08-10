from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding='utf-8')


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding='utf-8')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly 1 anchor, found {count}')
    return text.replace(old, new, 1)


baseline_old = (
    "기준 신청은 `1001 = 완료 / 100000`, `1004 = 취소 / 150000`, `1005 = 신청 / 120000`이고 "
    "`uq_course_enrollments_active`가 존재해야 합니다. Chapter 10은 이 상태를 읽기만 하고 변경하지 않습니다."
)
baseline_new = (
    "기준 신청은 `1001 = 완료 / 100000`, `1004 = 취소 / 150000`, `1005 = 신청 / 120000`이고 "
    "`uq_course_enrollments_active`가 존재해야 합니다. 또한 Chapter 07의 **명명 제약조건 15개와 `NOT NULL` 열 20개**가 유지되어야 합니다. "
    "Chapter 10은 이 상태를 읽기만 하고 변경하지 않습니다."
)

for path in [
    'book/chapter10/chapter10.md',
    'book/chapter10/chapter10_outline.md',
    'book/chapter10/chapter10_activity.md',
    'presentation/chapter10/chapter10_theory_lecture_plan.md',
    'presentation/chapter10/chapter10_practice_lecture_plan.md',
    'code/chapter10/README.md',
]:
    text = read(path)
    text = replace_once(text, baseline_old, baseline_new, f'{path} baseline contract')
    write(path, text)

# ---------------------------------------------------------------------------
# Main manuscript: make selectivity and planner-control reasoning explicit.
# ---------------------------------------------------------------------------
path = 'book/chapter10/chapter10.md'
text = read(path)
selectivity_anchor = """| 전체 `status = '수강중'` | 30,001 |\n\nPC 성능에 따라 데이터 생성 시간이 달라질 수 있습니다."""
selectivity_block = """| 전체 `status = '수강중'` | 30,001 |\n\n같은 `enrollments` 100,005행을 기준으로 반환 비율을 계산하면 인덱스 후보의 성격이 더 잘 보입니다.\n\n| 조건 | 반환 행 | 대략적인 반환 비율 | 해석 |\n| --- | ---: | ---: | --- |\n| `student_id = 5000` | 10 | 약 0.010% | 매우 적은 행 선택 |\n| `course_id = 1500` | 50 | 약 0.050% | 적은 행 선택 |\n| `course_id = 1500 AND status = '수강중'` | 15 | 약 0.015% | 매우 적은 행 선택 |\n| `status = '수강중'` | 30,001 | 약 30.0% | 많은 행 반환 |\n\n반환 비율이 낮다고 무조건 인덱스가 선택되는 것은 아니지만, 왜 `student_id`·`course_id` 조건은 인덱스 후보가 되고 `status` 단독 조건은 `Seq Scan`이 합리적일 수 있는지 설명하는 중요한 단서입니다. 선택도뿐 아니라 테이블 크기, 필요한 컬럼, 정렬, 캐시와 비용 추정도 함께 봅니다.\n\nPC 성능에 따라 데이터 생성 시간이 달라질 수 있습니다."""
text = replace_once(text, selectivity_anchor, selectivity_block, 'chapter10 selectivity block')
planner_anchor = """한 번의 실행 시간만으로 결론을 내리지 않습니다. 같은 환경에서 여러 번 관찰하고 계획, Buffers와 행 수를 함께 비교합니다.\n\n### 실행 계획과 결과 행은 다르다"""
planner_block = """한 번의 실행 시간만으로 결론을 내리지 않습니다. 같은 환경에서 여러 번 관찰하고 계획, Buffers와 행 수를 함께 비교합니다.\n\n이 실습에서는 `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`을 모두 기본값 `on`으로 둡니다. `SET enable_seqscan = off`처럼 특정 계획을 강제로 피하게 만들면 **인덱스가 존재할 때 실제 옵티마이저가 자발적으로 선택하는지**를 비교할 수 없습니다. 이런 설정은 진단용 가설 실험에는 쓸 수 있지만, 인덱스 효과의 최종 증거로 사용하지 않습니다.\n\n### 실행 계획과 결과 행은 다르다"""
text = replace_once(text, planner_anchor, planner_block, 'chapter10 planner settings')
summary_anchor = """7. 기준과 사후 측정은 같은 데이터·통계·SQL을 사용한다.\n8. 실행 계획과 결과 행 동일성은 별도로 검증한다."""
summary_new = """7. 기준과 사후 측정은 같은 데이터·통계·SQL과 기본 플래너 설정을 사용한다.\n8. `enable_seqscan=off` 같은 강제 설정은 최종 성능 증거로 사용하지 않는다.\n9. 실행 계획과 결과 행 동일성은 별도로 검증한다."""
text = replace_once(text, summary_anchor, summary_new, 'chapter10 summary planner principle')
# Renumber the remaining existing summary items 9~12 to 10~13.
for old, new in [
    ('9. 복합 인덱스는', '10. 복합 인덱스는'),
    ('10. 인덱스는 조회를', '11. 인덱스는 조회를'),
    ('11. 운영 인덱스 생성은', '12. 운영 인덱스 생성은'),
    ('12. AI 추천은', '13. AI 추천은'),
]:
    text = text.replace(old, new, 1)
write(path, text)

# ---------------------------------------------------------------------------
# Outline: propagate structure contract, selectivity and planner control.
# ---------------------------------------------------------------------------
path = 'book/chapter10/chapter10_outline.md'
text = read(path)
text = replace_once(
    text,
    """전체 수강중                 30001행\n```\n\n## IDENTITY 시작값""",
    """전체 수강중                 30001행\n```\n\n선택도 기준:\n\n```text\nstudent_id = 5000                  10 / 100005 ≈ 0.010%\ncourse_id = 1500                   50 / 100005 ≈ 0.050%\ncourse_id = 1500 + 수강중          15 / 100005 ≈ 0.015%\nstatus = 수강중                 30001 / 100005 ≈ 30.0%\n```\n\n낮은 반환 비율은 인덱스 후보 판단의 단서이지 단독 정답이 아니다. 실제 계획·Buffers·정렬·쓰기 비용을 함께 본다.\n\n## IDENTITY 시작값""",
    'outline selectivity',
)
text = replace_once(
    text,
    """인덱스 전후 사이에는 데이터, SQL과 테이블 통계를 변경하지 않는다.\n\n## 운영 인덱스 생성 범위""",
    """인덱스 전후 사이에는 데이터, SQL과 테이블 통계를 변경하지 않는다. `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`도 모두 기본값 `on`으로 유지하며, 특정 계획을 강제하는 설정은 최종 효과 증거로 사용하지 않는다.\n\n## 운영 인덱스 생성 범위""",
    'outline planner controls',
)
write(path, text)

# ---------------------------------------------------------------------------
# Workbook: make the prerequisite contract and selectivity measurable.
# ---------------------------------------------------------------------------
path = 'book/chapter10/chapter10_activity.md'
text = read(path)
text = replace_once(
    text,
    """| `recorded_amount` 타입 | `NUMERIC(12,0)` |  |\n| 전체 기록 금액 | `590000` |  |""",
    """| `recorded_amount` 타입 | `NUMERIC(12,0)` |  |\n| Chapter 07 명명 제약조건 | `15개` |  |\n| Chapter 07 `NOT NULL` 열 | `20개` |  |\n| 현재 역할의 DB `CREATE` 권한 | 있음 |  |\n| 전체 기록 금액 | `590000` |  |""",
    'activity prerequisite rows',
)
text = replace_once(
    text,
    """| 동일 학생·강의 활성 신청 중복 | 0 |  |\n\n```text\nperformance_lab에 Chapter 07의 활성 신청 부분 고유 인덱스를 미리 만들지 않은 이유:""",
    """| 동일 학생·강의 활성 신청 중복 | 0 |  |\n\n선택도 계산:\n\n| 조건 | 기대 행 | 전체 행 | 대략적 반환 비율 |\n| --- | ---: | ---: | ---: |\n| `student_id = 5000` | 10 | 100005 | 약 0.010% |\n| `course_id = 1500` | 50 | 100005 | 약 0.050% |\n| `course_id = 1500 AND status = '수강중'` | 15 | 100005 | 약 0.015% |\n| `status = '수강중'` | 30001 | 100005 | 약 30.0% |\n\n```text\n반환 비율만으로 인덱스 적용 여부를 결정하면 안 되는 이유:\n________________________________________________________________________\n```\n\n```text\nperformance_lab에 Chapter 07의 활성 신청 부분 고유 인덱스를 미리 만들지 않은 이유:""",
    'activity selectivity',
)
text = replace_once(
    text,
    """EXPLAIN ANALYZE만으로 일반 결과 행 동일성을 확인할 수 없는 이유:\n________________________________________________________________________\n```\n\n---\n\n## 7. 이메일 자동 인덱스 확인""",
    """EXPLAIN ANALYZE만으로 일반 결과 행 동일성을 확인할 수 없는 이유:\n________________________________________________________________________\n```\n\n```text\n`SET enable_seqscan = off`를 인덱스 효과의 최종 증거로 사용하면 안 되는 이유:\n________________________________________________________________________\n```\n\n---\n\n## 7. 이메일 자동 인덱스 확인""",
    'activity planner question',
)
write(path, text)

# ---------------------------------------------------------------------------
# Code README: publication-safe prerequisites and experiment interpretation.
# ---------------------------------------------------------------------------
path = 'code/chapter10/README.md'
text = read(path)
text = replace_once(
    text,
    """Chapter 07의 `course_project.enrollments`가 기준 5행 상태여야 합니다. Chapter 10은 해당 데이터를 읽기만 하며 변경하지 않습니다.""",
    """Chapter 07의 `course_project.enrollments`가 기준 5행 상태여야 합니다. 명명 제약조건 15개와 `NOT NULL` 열 20개도 유지되어야 하며, `01_performance_lab_schema.sql`을 실행하는 역할에는 `ai_database_book`의 `CREATE` 권한이 필요합니다. Chapter 10은 `course_project`를 읽기만 하며 변경하지 않습니다.""",
    'README prerequisite contract',
)
text = replace_once(
    text,
    """실행 시간은 캐시, JIT, 장비 부하의 영향을 받습니다. 한 번의 시간 숫자만으로 결론을 내리지 않고 **결과 행 동일성, 계획 노드, Index Cond, Buffers와 반복 측정**을 함께 봅니다.""",
    """실행 시간은 캐시, JIT, 장비 부하의 영향을 받습니다. 한 번의 시간 숫자만으로 결론을 내리지 않고 **결과 행 동일성, 계획 노드, Index Cond, Buffers와 반복 측정**을 함께 봅니다. `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`은 모두 `on`으로 유지하며, 특정 계획을 강제한 결과를 최종 성능 증거로 사용하지 않습니다.""",
    'README planner settings',
)
text = replace_once(
    text,
    """전체 수강중                 → 30001행\n```\n\nPC 성능이 낮아 생성 건수를 임의로 줄이면""",
    """전체 수강중                 → 30001행\n```\n\n`enrollments` 100,005행 기준 대략적인 반환 비율:\n\n```text\nstudent_id = 5000                 ≈ 0.010%\ncourse_id = 1500                  ≈ 0.050%\ncourse_id = 1500 + 수강중         ≈ 0.015%\nstatus = 수강중                   ≈ 30.0%\n```\n\n이 비율은 후보 판단의 단서이며 인덱스 사용을 보장하지 않습니다. 실제 실행 계획과 Buffers를 함께 확인합니다.\n\nPC 성능이 낮아 생성 건수를 임의로 줄이면""",
    'README selectivity',
)
text = text.replace('PostgreSQL PostgreSQL 18+에서의 Skip Scan', 'PostgreSQL 18+에서의 Skip Scan')
write(path, text)

# ---------------------------------------------------------------------------
# Theory/practice lecture plans: keep the visible explanation synchronized.
# ---------------------------------------------------------------------------
path = 'presentation/chapter10/chapter10_theory_lecture_plan.md'
text = read(path)
text = replace_once(
    text,
    """예를 들어 학생 5000의 신청은 10건, 강의 1500의 신청은 50건, 강의 1500의 수강중 신청은 15건이어야 합니다. 이 숫자가 기준값입니다.""",
    """예를 들어 학생 5000의 신청은 10건, 강의 1500의 신청은 50건, 강의 1500의 수강중 신청은 15건이어야 합니다. 반면 전체 수강중은 30001건입니다. 신청 100005건을 기준으로 보면 앞의 조건들은 약 0.01~0.05퍼센트만 고르지만 상태 단독 조건은 약 30퍼센트를 반환합니다. 이 차이가 인덱스 후보를 생각하는 중요한 단서입니다.""",
    'theory selectivity script',
)
# Add planner control to the EXPLAIN-focused slide script using a stable sentence.
text = replace_once(
    text,
    """이 실험에서는 데이터 생성 후 통계를 한 번 수집하고, 인덱스 전후 비교에서는 같은 데이터와 같은 통계를 유지합니다.""",
    """이 실험에서는 데이터 생성 후 통계를 한 번 수집하고, 인덱스 전후 비교에서는 같은 데이터와 같은 통계를 유지합니다. 또한 시퀀셜 스캔이나 인덱스 스캔을 강제로 끄지 않고 기본 플래너 설정에서 실제 선택을 비교합니다.""",
    'theory planner controls',
)
write(path, text)

path = 'presentation/chapter10/chapter10_practice_lecture_plan.md'
text = read(path)
text = replace_once(
    text,
    """이 기준이 있어야 인덱스 전후 계획이 달라져도 결과 의미가 같다고 확인할 수 있습니다.""",
    """이 기준이 있어야 인덱스 전후 계획이 달라져도 결과 의미가 같다고 확인할 수 있습니다. 신청 전체 100005건과 비교하면 학생 5000 조건은 약 0.01퍼센트, 강의 1500은 약 0.05퍼센트, 상태 수강중 단독은 약 30퍼센트를 반환합니다. 이 반환 비율도 계획을 해석할 때 함께 기록합니다.""",
    'practice selectivity script',
)
text = replace_once(
    text,
    """기준 계획에는 주요 계획 노드, 예상 rows, actual rows, Buffers, Execution Time을 기록합니다.""",
    """기준 계획에는 주요 계획 노드, 예상 rows, actual rows, Buffers, Execution Time을 기록합니다. 이때 `enable_seqscan`, `enable_indexscan`, `enable_bitmapscan`은 모두 `on`인지 확인하고, 특정 Scan을 강제로 끄지 않습니다.""",
    'practice planner settings',
)
write(path, text)

# ---------------------------------------------------------------------------
# 01 schema: preflight before explicit DDL transaction + Chapter 07 structure.
# ---------------------------------------------------------------------------
path = 'code/chapter10/01_performance_lab_schema.sql'
text = read(path)
text = replace_once(
    text,
    "SHOW server_version;\n\nBEGIN;\n\nDO $$",
    "SHOW server_version;\n\n-- 잘못된 환경에서는 DDL 트랜잭션을 열기 전에 중단합니다.\nDO $$",
    '01 preflight before BEGIN',
)
text = replace_once(
    text,
    """    v_non_cancelled_amount numeric(20,0);\nBEGIN""",
    """    v_non_cancelled_amount numeric(20,0);\n    v_named_constraint_count bigint;\n    v_not_null_count bigint;\nBEGIN""",
    '01 project structure vars',
)
structure_anchor = """    IF to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: Chapter 07 활성 신청 부분 고유 인덱스가 없습니다.';\n    END IF;\n\n    IF to_regnamespace('performance_lab') IS NOT NULL THEN"""
structure_block = """    IF to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: Chapter 07 활성 신청 부분 고유 인덱스가 없습니다.';\n    END IF;\n\n    IF NOT has_database_privilege(current_user, current_database(), 'CREATE') THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: 현재 역할 %에는 데이터베이스 %의 CREATE 권한이 없습니다.',\n            current_user, current_database();\n    END IF;\n\n    SELECT COUNT(*) INTO v_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_named_constraint_count <> 15 OR v_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '스키마 생성 중단: Chapter 07 구조 기준과 다릅니다. named_constraints=%, not_null_columns=%',\n            v_named_constraint_count, v_not_null_count;\n    END IF;\n\n    IF to_regnamespace('performance_lab') IS NOT NULL THEN"""
text = replace_once(text, structure_anchor, structure_block, '01 structure/privilege gate')
text = replace_once(
    text,
    """END\n$$;\n\nCREATE SCHEMA performance_lab;""",
    """END\n$$;\n\nBEGIN;\n\nCREATE SCHEMA performance_lab;""",
    '01 DDL BEGIN',
)
write(path, text)

# ---------------------------------------------------------------------------
# 07 final validation: verify inherited Chapter 07 structure contract too.
# ---------------------------------------------------------------------------
path = 'code/chapter10/07_result_validation.sql'
text = read(path)
text = replace_once(
    text,
    """    v_invalid_count bigint;\nBEGIN""",
    """    v_invalid_count bigint;\n    v_project_named_constraint_count bigint;\n    v_project_not_null_count bigint;\nBEGIN""",
    '07 project structure vars',
)
row_anchor = """    IF (SELECT COUNT(*) FROM course_project.students) <> 3\n       OR (SELECT COUNT(*) FROM course_project.instructors) <> 2"""
row_block = """    SELECT COUNT(*) INTO v_project_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_project_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_project_named_constraint_count <> 15 OR v_project_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '최종 검증 실패: Chapter 07 구조 기준이 변경되었습니다. named_constraints=%, not_null_columns=%',\n            v_project_named_constraint_count, v_project_not_null_count;\n    END IF;\n\n    IF (SELECT COUNT(*) FROM course_project.students) <> 3\n       OR (SELECT COUNT(*) FROM course_project.instructors) <> 2"""
text = replace_once(text, row_anchor, row_block, '07 structure contract')
write(path, text)

# ---------------------------------------------------------------------------
# Presentation: disable generic script expansion and synchronize cache version.
# ---------------------------------------------------------------------------
for p in Path('presentation/chapter10').glob('*'):
    if p.is_file() and p.suffix.lower() in {'.html', '.js'}:
        text = p.read_text(encoding='utf-8')
        text = text.replace('20260809a', '20260810a').replace('20260808e', '20260810a')
        p.write_text(text, encoding='utf-8')

path = 'presentation/chapter10/chapter10_script.html'
text = read(path)
text = replace_once(text, '<body>', '<body data-script-content-enhancer="off">', 'script enhancer off')
write(path, text)

print('Chapter 10 final publication review patch applied successfully')
