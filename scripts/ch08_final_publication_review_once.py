from pathlib import Path
import subprocess

ROOT = Path('.').resolve()


def read(path):
    return (ROOT / path).read_text(encoding='utf-8')


def write(path, text):
    (ROOT / path).write_text(text, encoding='utf-8')


def replace_exact(path, old, new, count=1):
    text = read(path)
    actual = text.count(old)
    if actual < count:
        raise RuntimeError(f'{path}: expected at least {count} occurrence(s), found {actual}: {old[:140]!r}')
    text = text.replace(old, new, count)
    write(path, text)


# ------------------------------------------------------------------
# 00 prerequisite gate: carry Chapter 07 structural contract forward.
# ------------------------------------------------------------------
p = 'code/chapter08/00_check_course_project.sql'
replace_exact(p,
    '    v_active_duplicate_count bigint;\n    v_status_1001 text;',
    '    v_active_duplicate_count bigint;\n    v_named_constraint_count bigint;\n    v_not_null_count bigint;\n    v_status_1001 text;')
replace_exact(p,
    '    SELECT COUNT(*) INTO v_student_count\n    FROM course_project.students;',
    '''    SELECT COUNT(*) INTO v_named_constraint_count
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

    SELECT COUNT(*) INTO v_student_count
    FROM course_project.students;''')

# ------------------------------------------------------------------
# 03 completion gate: validate HAVING and the over-aggregation lesson.
# ------------------------------------------------------------------
p = 'code/chapter08/03_join_aggregation_validation.sql'
replace_exact(p,
    '    v_instructor202_non_cancelled bigint;\nBEGIN',
    '''    v_instructor202_non_cancelled bigint;
    v_having_course_count bigint;
    v_instructor201_wrong_price_sum numeric;
    v_instructor201_correct_price_sum numeric;
    v_instructor202_wrong_price_sum numeric;
    v_instructor202_correct_price_sum numeric;
BEGIN''')
replace_exact(p,
    '    IF v_detail_count <> 5',
    '''    SELECT COUNT(*) INTO v_having_course_count
    FROM (
        SELECT c.id
        FROM course_project.courses AS c
        JOIN course_project.enrollments AS e
            ON c.id = e.course_id
        WHERE e.status <> '취소'
        GROUP BY c.id
        HAVING COUNT(e.id) >= 2
    ) AS having_courses;

    SELECT COALESCE(SUM(c.price), 0)
    INTO v_instructor201_wrong_price_sum
    FROM course_project.instructors AS i
    JOIN course_project.courses AS c
        ON i.id = c.instructor_id
    JOIN course_project.enrollments AS e
        ON c.id = e.course_id
    WHERE i.id = 201;

    SELECT COALESCE(SUM(price), 0)
    INTO v_instructor201_correct_price_sum
    FROM course_project.courses
    WHERE instructor_id = 201;

    SELECT COALESCE(SUM(c.price), 0)
    INTO v_instructor202_wrong_price_sum
    FROM course_project.instructors AS i
    JOIN course_project.courses AS c
        ON i.id = c.instructor_id
    JOIN course_project.enrollments AS e
        ON c.id = e.course_id
    WHERE i.id = 202;

    SELECT COALESCE(SUM(price), 0)
    INTO v_instructor202_correct_price_sum
    FROM course_project.courses
    WHERE instructor_id = 202;

    IF v_detail_count <> 5''')
replace_exact(p,
    "    RAISE NOTICE 'Chapter 08 join and aggregation validation passed';",
    '''    IF v_having_course_count <> 2
       OR v_instructor201_wrong_price_sum <> 440000
       OR v_instructor201_correct_price_sum <> 220000
       OR v_instructor202_wrong_price_sum <> 150000
       OR v_instructor202_correct_price_sum <> 150000 THEN
        RAISE EXCEPTION
            'Chapter 08 HAVING/과대 집계 검증 실패: having=%, i201_wrong/correct=%/%, i202_wrong/correct=%/%',
            v_having_course_count,
            v_instructor201_wrong_price_sum,
            v_instructor201_correct_price_sum,
            v_instructor202_wrong_price_sum,
            v_instructor202_correct_price_sum;
    END IF;

    RAISE NOTICE 'Chapter 08 join and aggregation validation passed';''')

# Add explicit expected values to the teaching SQL.
p = 'code/chapter08/02_aggregation_queries.sql'
replace_exact(p,
    '-- 10. 여러 JOIN에서 강의 가격을 잘못 합산하는 예',
    '-- 10. 여러 JOIN에서 강의 가격을 잘못 합산하는 예\n-- 기준 데이터에서 강사 201은 잘못된 합계 440000, 실제 강의 가격 합계 220000입니다.\n-- 강사 202는 신청이 한 건뿐이라 두 값이 우연히 150000으로 같지만, 쿼리 기준이 올바르다는 뜻은 아닙니다.')

# ------------------------------------------------------------------
# Book: make over-aggregation measurable, not only conceptual.
# ------------------------------------------------------------------
p = 'book/chapter08/chapter08.md'
replace_exact(p,
    "GROUP BY i.id;\n```\n\n`SUM(DISTINCT c.price)`도 일반적인 해결책이 아닙니다.",
    '''GROUP BY i.id;
```

현재 기준 데이터에서 결과는 다음과 같습니다.

| instructor_id | 잘못된 `SUM(c.price)` |
| ---: | ---: |
| 201 | 440000 |
| 202 | 150000 |

강사 201의 실제 강의는 301과 302 두 개이고 현재 기준 가격 합계는 `100000 + 120000 = 220000`입니다. 하지만 각 강의가 신청 두 건씩과 연결되면서 가격도 두 번씩 반복되어 `440000`으로 계산됩니다. 강사 202는 신청이 한 건뿐이라 잘못된 쿼리와 올바른 합계가 우연히 `150000`으로 같습니다. 값이 우연히 같다고 해서 집계 기준이 올바른 것은 아닙니다.

`SUM(DISTINCT c.price)`도 일반적인 해결책이 아닙니다.''')
replace_exact(p,
    "FROM course_project.courses\nGROUP BY instructor_id\nORDER BY instructor_id;\n```\n\n집계 전에 어떤 테이블의 한 행이 합산 대상인지 정해야 합니다.",
    '''FROM course_project.courses
GROUP BY instructor_id
ORDER BY instructor_id;
```

| instructor_id | 올바른 `course_price_sum` |
| ---: | ---: |
| 201 | 220000 |
| 202 | 150000 |

집계 전에 어떤 테이블의 한 행이 합산 대상인지 정해야 합니다.''')

# ------------------------------------------------------------------
# Workbook: require learners to record the numeric evidence.
# ------------------------------------------------------------------
p = 'book/chapter08/chapter08_activity.md'
replace_exact(p,
    '```text\n과대 계산 이유:\nSUM(DISTINCT c.price)가 일반 해결책이 아닌 이유:\n올바른 집계 기준:\n```',
    '''| 강사 | 신청 JOIN 뒤 잘못된 `SUM(c.price)` | 강의 수준의 올바른 합계 |
| --- | ---: | ---: |
| 문길래(201) | 440000 | 220000 |
| 홍길동(202) | 150000 | 150000 |

```text
과대 계산 이유:
강사 202에서 두 값이 우연히 같은데도 잘못된 SQL이라고 말해야 하는 이유:
SUM(DISTINCT c.price)가 일반 해결책이 아닌 이유:
올바른 집계 기준:
```''')

# ------------------------------------------------------------------
# Lecture plans: show the same numeric evidence.
# ------------------------------------------------------------------
p = 'presentation/chapter08/chapter08_theory_lecture_plan.md'
replace_exact(p,
    "- 위험: 신청 JOIN 후 `SUM(c.price)`",
    "- 위험: 신청 JOIN 후 `SUM(c.price)`\n- 강사 201: 잘못된 합계 440000 → 올바른 강의 합계 220000")
replace_exact(p,
    '무엇을 합산하는지 먼저 정하고, 그 기준 행이 있는 테이블에서 계산해야 합니다.',
    '현재 기준 데이터에서는 강사 201의 잘못된 합계가 440000이고, 강의 수준에서 계산한 올바른 합계는 220000입니다. 강사 202는 신청이 한 건뿐이라 두 값이 150000으로 우연히 같지만 잘못된 집계 방식이 올바르게 바뀐 것은 아닙니다. 무엇을 합산하는지 먼저 정하고, 그 기준 행이 있는 테이블에서 계산해야 합니다.')

p = 'presentation/chapter08/chapter08_practice_lecture_plan.md'
replace_exact(p,
    "- 잘못된 합계: 신청 JOIN 뒤 `SUM(c.price)`",
    "- 잘못된 합계: 신청 JOIN 뒤 `SUM(c.price)`\n- 강사 201: 440000(잘못) / 220000(올바름)")
replace_exact(p,
    '`썸(디스팅트 c.price)`도 일반 해결책이 아닙니다. 서로 다른 강의가 같은 가격이면 한 번만 더해질 수 있기 때문입니다.',
    '`썸(디스팅트 c.price)`도 일반 해결책이 아닙니다. 서로 다른 강의가 같은 가격이면 한 번만 더해질 수 있기 때문입니다. 실제로 강사 201은 신청 조인 뒤 440000으로 계산되지만, 강의 301과 302의 기준 가격만 더하면 220000입니다. 강사 202처럼 두 결과가 우연히 같은 경우에도 쿼리의 기준이 올바른 것은 아닙니다.')

# ------------------------------------------------------------------
# README: document strengthened gates.
# ------------------------------------------------------------------
p = 'code/chapter08/README.md'
replace_exact(p,
    'recorded_amount = NUMERIC(12,0)\n행 수 = 3 / 2 / 3 / 5',
    'recorded_amount = NUMERIC(12,0)\nChapter 07 명명 제약조건 = 15 / NOT NULL 열 = 20\n행 수 = 3 / 2 / 3 / 5')
replace_exact(p,
    '강사 202 = 강의 1 / 신청 1 / 취소 제외 0',
    '강사 202 = 강의 1 / 신청 1 / 취소 제외 0\nHAVING 취소 제외 2건 이상 강의 = 2개\n강사 201 가격: 신청 JOIN 뒤 잘못된 합계 440000 / 강의 수준 올바른 합계 220000\n강사 202 가격: 두 방식 모두 150000(우연히 같음)')

# ------------------------------------------------------------------
# Presenter: use authored narration without generic expansion.
# ------------------------------------------------------------------
p = 'presentation/chapter08/chapter08_script.html'
replace_exact(p, '<body>', '<body data-script-content-enhancer="off">')

# Refresh Chapter 08 presentation asset version consistently.
for p in [
    'presentation/chapter08/chapter08_script.html',
    'presentation/chapter08/chapter08_theory_presentation.html',
    'presentation/chapter08/chapter08_practice_presentation.html',
    'presentation/chapter08/chapter08_script.js',
]:
    text = read(p)
    if '20260809a' not in text:
        raise RuntimeError(f'{p}: old asset version not found')
    write(p, text.replace('20260809a', '20260810a'))

# ------------------------------------------------------------------
# Permanent validation workflow: validate new structural and teaching contracts.
# ------------------------------------------------------------------
p = '.github/workflows/validate-chapter08.yml'
text = read(p)
text = text.replace("      - 'notes/chapter08_review_checklist.md'\n", "      - 'notes/chapter08_review_checklist.md'\n      - 'presentation/common/script_content_enhancer.js'\n")
text = text.replace("          version = '20260809a'", "          version = '20260810a'")
text = text.replace(
    "          if '../common/script_content_enhancer.js' not in script_html:\n              raise SystemExit('shared script content enhancer is not loaded')",
    "          if '../common/script_content_enhancer.js' not in script_html:\n              raise SystemExit('shared script content enhancer is not loaded')\n          if 'data-script-content-enhancer=\"off\"' not in script_html:\n              raise SystemExit('Chapter 08 authored narration must disable automatic expansion')\n          enhancer = Path('presentation/common/script_content_enhancer.js').read_text(encoding='utf-8')\n          if \"dataset?.scriptContentEnhancer === 'off'\" not in enhancer:\n              raise SystemExit('shared enhancer does not honor the Chapter 08 opt-out')")
text = text.replace(
    "              'v_non_cancelled_count <> 4',\n              'Chapter 08 prerequisite check passed',",
    "              'v_non_cancelled_count <> 4',\n              'v_named_constraint_count <> 15',\n              'v_not_null_count <> 20',\n              'Chapter 08 prerequisite check passed',")
text = text.replace(
    "              'v_instructor201_courses <> 2',\n              'Chapter 08 join and aggregation validation passed',",
    "              'v_instructor201_courses <> 2',\n              'v_having_course_count <> 2',\n              'v_instructor201_wrong_price_sum <> 440000',\n              'v_instructor201_correct_price_sum <> 220000',\n              'Chapter 08 join and aggregation validation passed',")
write(p, text)

# ------------------------------------------------------------------
# Review records.
# ------------------------------------------------------------------
p = 'book/chapter08/chapter08_review_revision.md'
text = read(p)
if '## 최종 출판 검수 추가 반영 (2026-08-10)' not in text:
    text += '''\n\n---\n\n## 최종 출판 검수 추가 반영 (2026-08-10)\n\n- Chapter 07 인계 게이트에 명명 제약조건 15개와 NOT NULL 열 20개 확인을 추가했다.\n- 과대 집계 예제를 개념 설명에서 숫자 검산으로 강화했다: 강사 201은 신청 JOIN 뒤 440000, 강의 수준 올바른 합계는 220000이다.\n- 강사 202는 두 방식이 150000으로 우연히 같아도 잘못된 집계 기준이 정당화되지 않는다는 점을 추가했다.\n- `03_join_aggregation_validation.sql`에서 HAVING 결과와 과대 집계·올바른 집계 값을 자동 판정하도록 보강했다.\n- 본문·워크북·이론·실습 강의안·README가 같은 과대 집계 기준값을 사용하도록 맞췄다.\n- Chapter 08 발표 스크립트에서는 공통 자동 문장 보강을 비활성화해 작성된 스크립트를 그대로 사용하도록 했다.\n- 발표 자산 버전을 20260810a로 갱신했다.\n'''
write(p, text)

p = 'notes/chapter08_review_checklist.md'
text = read(p)
text = text.replace('- [x] 공통 `script_content_enhancer.js`를 유지한다.', '- [x] 공통 `script_content_enhancer.js` 로드는 유지하되 Chapter 08에서는 자동 문장 확장을 비활성화한다.')
text = text.replace('- [x] 발표자료 자산 버전을 `20260809a`로 통일한다.', '- [x] 발표자료 자산 버전을 `20260810a`로 통일한다.')
if '## 2026-08-10 최종 출판 보완' not in text:
    text += '''\n\n---\n\n## 2026-08-10 최종 출판 보완\n\n- [x] Chapter 07 구조 계약 15개 명명 제약조건 / 20개 NOT NULL 열을 00에서 확인\n- [x] HAVING 취소 제외 2건 이상 강의 = 2개 자동 검증\n- [x] 강사 201 과대 집계 440000 / 올바른 강의 가격 합계 220000 자동 검증\n- [x] 강사 202의 우연한 150000 일치가 잘못된 쿼리를 정당화하지 않음을 설명\n- [x] 본문·워크북·이론·실습·README 숫자 기준 동기화\n- [x] Chapter 08 작성 스크립트 자동 확장 비활성화\n- [ ] 최신 PostgreSQL 16 전체 경로 재검증 결과 확인\n'''
write(p, text)

# Keep merged publication manuscript synchronized.
subprocess.run(['python', 'scripts/merge_chapters.py'], cwd=ROOT, check=True)

print('Chapter 08 final publication review applied successfully')
