from pathlib import Path
import subprocess, sys

# First-stage script deterministically applies all edits through 01 and is
# expected to stop at the old 08 insertion marker. Keep that failure explicit.
r = subprocess.run(
    [sys.executable, 'scripts/ch14_final_publication_patch_once.py'],
    text=True,
    capture_output=True,
)
expected = 'missing replacement target: 08 structure contract'
if r.returncode != 1 or expected not in (r.stdout + r.stderr):
    print(r.stdout)
    print(r.stderr, file=sys.stderr)
    raise SystemExit(f'unexpected first-stage result: rc={r.returncode}')


def read(path): return Path(path).read_text(encoding='utf-8')
def write(path, text): Path(path).write_text(text, encoding='utf-8')
def rep(text, old, new, label):
    if old not in text:
        raise SystemExit(f'missing replacement target: {label}')
    if text.count(old) != 1:
        raise SystemExit(f'non-unique replacement target: {label} count={text.count(old)}')
    return text.replace(old, new, 1)

# Finish 08 with a stable comment insertion point.
p='code/chapter14/08_analysis_lab_validation.sql'; t=read(p)
t=rep(t,
'''    enrollments_next BIGINT;
BEGIN''',
'''    enrollments_next BIGINT;
    project_named_constraint_count INTEGER;
    project_not_null_count INTEGER;
BEGIN''','08 declarations')
marker='''    -- 정확한 테이블 집합 4개'''
insert='''    -- Chapter 07 구조 계약을 최종 게이트에서도 다시 확인합니다.
    SELECT COUNT(*)
    INTO project_named_constraint_count
    FROM pg_constraint
    WHERE conrelid IN (
        'course_project.students'::regclass,
        'course_project.instructors'::regclass,
        'course_project.courses'::regclass,
        'course_project.enrollments'::regclass
    )
      AND conname IN (
        'uq_course_students_email','chk_course_students_name_not_blank','chk_course_students_email_not_blank',
        'uq_course_instructors_email','chk_course_instructors_name_not_blank','chk_course_instructors_email_not_blank','chk_course_instructors_specialty_not_blank',
        'fk_course_courses_instructor','chk_course_courses_title_not_blank','chk_course_courses_level','chk_course_courses_price',
        'fk_course_enrollments_student','fk_course_enrollments_course','chk_course_enrollments_status','chk_course_enrollments_recorded_amount'
      );

    SELECT COUNT(*)
    INTO project_not_null_count
    FROM information_schema.columns
    WHERE table_schema = 'course_project'
      AND table_name IN ('students','instructors','courses','enrollments')
      AND is_nullable = 'NO';

    IF project_named_constraint_count <> 15 OR project_not_null_count <> 20 THEN
        RAISE EXCEPTION
            '검증 실패: Chapter 07 구조 계약은 명명 제약조건 15개 / NOT NULL 열 20개여야 하지만 현재 % / %입니다.',
            project_named_constraint_count, project_not_null_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'course_project'
          AND indexname = 'uq_course_enrollments_active'
          AND indexdef ILIKE 'CREATE UNIQUE INDEX%'
          AND indexdef ILIKE '%student_id%course_id%'
          AND indexdef ILIKE '%WHERE%status%신청%수강중%'
    ) THEN
        RAISE EXCEPTION '검증 실패: Chapter 07 활성 신청 부분 고유 인덱스 정의가 다릅니다.';
    END IF;

'''+marker
t=rep(t,marker,insert,'08 structure contract stable')
write(p,t)

# Permanent comprehensive CI.
p='.github/workflows/validate-chapter14.yml'; t=read(p)
t=rep(t,
'''          for token in ['recorded_amount NUMERIC(12,0) NOT NULL','price NUMERIC(12,0) NOT NULL','590000','340000','440000','table_type = \\'BASE TABLE\\'']:
              if token not in sql['01_analysis_lab_schema.sql']:
                  raise SystemExit(f'01 missing {token}')''',
'''          for token in ['recorded_amount NUMERIC(12,0) NOT NULL','price NUMERIC(12,0) NOT NULL','590000','340000','440000','table_type = \\'BASE TABLE\\'', "has_database_privilege(current_user, current_database(), 'CREATE')", 'project_named_constraint_count <> 15', 'project_not_null_count <> 20', 'uq_course_enrollments_active']:
              if token not in sql['01_analysis_lab_schema.sql']:
                  raise SystemExit(f'01 missing {token}')''','ci 01 tokens')
t=rep(t,
'''          for token in ['constraint_count <> 20','identity_count <> 4','3210000','590000','340000','440000','NUMERIC(12,0)',"table_type = 'BASE TABLE'",'Chapter 14 analysis_lab validation passed']:
              if token not in sql['08_analysis_lab_validation.sql']:
                  raise SystemExit(f'08 missing {token}')''',
'''          for token in ['constraint_count <> 20','identity_count <> 4','3210000','590000','340000','440000','NUMERIC(12,0)',"table_type = 'BASE TABLE'",'project_named_constraint_count <> 15','project_not_null_count <> 20','uq_course_enrollments_active','Chapter 14 analysis_lab validation passed']:
              if token not in sql['08_analysis_lab_validation.sql']:
                  raise SystemExit(f'08 missing {token}')''','ci 08 tokens')
t=rep(t,
'''          for token in ['ID_COLUMNS','recorded_amount는 정수 단위 금액','completion_days가 completed_at - enrolled_at과 일치하지 않습니다.','default_transaction_read_only=on','PGPASSFILE']:
              if token not in vu: raise SystemExit(f'validation_utils missing {token}')''',
'''          for token in ['ID_COLUMNS','EXPECTED_RECORDED_AMOUNT_SUM = 3210000','AMOUNT_SEMANTICS','expected_recorded_amount_sum','amount_semantics','recorded_amount는 정수 단위 금액','completion_days가 completed_at - enrolled_at과 일치하지 않습니다.','default_transaction_read_only=on','PGPASSFILE']:
              if token not in vu: raise SystemExit(f'validation_utils missing {token}')
          for py_name in ['03_pandas_analysis.py','04_result_validation.py']:
              py_text=(py/py_name).read_text(encoding='utf-8')
              for token in ['ANALYSIS_START_DATE','ANALYSIS_END_DATE_EXCLUSIVE','inclusive="left"']:
                  if token not in py_text: raise SystemExit(f'{py_name} missing shared period token {token}')
              if '"2026-06-01"' in py_text:
                  raise SystemExit(f'{py_name} still hardcodes final month')''','ci python tokens')
t=rep(t,
'''          if '../common/script_content_enhancer.js' not in script_html: raise SystemExit('enhancer missing')''',
'''          if '../common/script_content_enhancer.js' not in script_html: raise SystemExit('enhancer missing')
          if 'data-script-content-enhancer="off"' not in script_html: raise SystemExit('finished Chapter 14 script must disable generic enhancer')''','ci enhancer')
anchor='''      - name: Capture protected fingerprint and create sentinels
'''
step='''      - name: Verify inherited Chapter 07 structure and CREATE privilege preflight
        shell: bash
        run: |
          structure="$(psql -d ai_database_book -Atc "SELECT (SELECT COUNT(*) FROM pg_constraint WHERE conrelid IN ('course_project.students'::regclass,'course_project.instructors'::regclass,'course_project.courses'::regclass,'course_project.enrollments'::regclass) AND conname IN ('uq_course_students_email','chk_course_students_name_not_blank','chk_course_students_email_not_blank','uq_course_instructors_email','chk_course_instructors_name_not_blank','chk_course_instructors_email_not_blank','chk_course_instructors_specialty_not_blank','fk_course_courses_instructor','chk_course_courses_title_not_blank','chk_course_courses_level','chk_course_courses_price','fk_course_enrollments_student','fk_course_enrollments_course','chk_course_enrollments_status','chk_course_enrollments_recorded_amount'))||':'||(SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='course_project' AND table_name IN ('students','instructors','courses','enrollments') AND is_nullable='NO');")"
          test "$structure" = '15:20'
          psql -v ON_ERROR_STOP=1 -d ai_database_book <<'SQL'
          CREATE ROLE ch14_no_create LOGIN PASSWORD 'chapter14-test';
          GRANT CONNECT ON DATABASE ai_database_book TO ch14_no_create;
          REVOKE CREATE ON DATABASE ai_database_book FROM ch14_no_create;
          SQL
          set +e
          PGUSER=ch14_no_create PGPASSWORD=chapter14-test psql -h localhost -d ai_database_book -v ON_ERROR_STOP=1 -f code/chapter14/01_analysis_lab_schema.sql >/tmp/ch14_no_create.log 2>&1
          rc=$?
          set -e
          test "$rc" -ne 0
          grep -q 'CREATE 권한' /tmp/ch14_no_create.log
          test "$(psql -d ai_database_book -Atc "SELECT to_regnamespace('analysis_lab') IS NULL")" = t

'''+anchor
t=rep(t,anchor,step,'ci privilege step')
t=rep(t,
'''          python code/chapter14/python/02_load_postgresql.py --export-csv /tmp/ch14.csv --manifest /tmp/ch14.manifest.json
          python code/chapter14/python/01_load_csv.py''',
'''          python code/chapter14/python/02_load_postgresql.py --export-csv /tmp/ch14.csv --manifest /tmp/ch14.manifest.json
          python - <<'PY'
          import json
          m=json.load(open('/tmp/ch14.manifest.json',encoding='utf-8'))
          assert m['expected_recorded_amount_sum']==3210000
          assert m['amount_semantics']=='recorded_amount = enrollment-time recorded amount; cancellation does not zero it'
          PY
          python code/chapter14/python/01_load_csv.py''','ci manifest actual')
write(p,t)

# Permanent publishing CI.
p='.github/workflows/validate-chapter14-publishing.yml'; t=read(p)
t=rep(t,
'''              Path('presentation/chapter14/chapter14_navigation.js'),
              Path('notes/chapter14_review_checklist.md'),''',
'''              Path('presentation/chapter14/chapter14_navigation.js'),
              Path('images/chapter14/README.md'),
              Path('notes/chapter14_review_checklist.md'),''','publishing image readme')
t=rep(t,
'''              '제약조건 21개',
          ]''',
'''              '제약조건 21개',
              '| 제약조건 | 21개 |',
              '취소는 기준 데이터에서 0으로 기록됩니다',
              '결제금액 합계 3,210,000',
          ]''','publishing stale')
t=rep(t,
'''              'book/chapter14/chapter14_activity.md': [
                  'recorded_amount', '350000', '680000', '540000',
                  '750000', '700000', '1210000', '400000',
                  '취소 건의 신청 시점 기록 금액은 취소 후에도 유지된다',
              ],''',
'''              'book/chapter14/chapter14_activity.md': [
                  'recorded_amount', '350000', '680000', '540000',
                  '750000', '700000', '1210000', '400000',
                  '취소 건의 신청 시점 기록 금액은 취소 후에도 유지된다',
                  '| 제약조건 | 20개 |', '기대 기록 금액 합계', '기록 금액 의미',
              ],''','publishing activity required')
t=rep(t,
'''              'notes/chapter14_review_checklist.md': [
                  'recorded_amount', '3210000', 'PK·FK·CHECK·UNIQUE | 20개',
              ],''',
'''              'images/chapter14/README.md': [
                  '신청 시점 기록 금액 합계 3,210,000', '같은 스냅샷의 실제 SQL 결과',
              ],
              'notes/chapter14_review_checklist.md': [
                  'recorded_amount', '3210000', 'PK·FK·CHECK·UNIQUE | 20개',
              ],''','publishing image required')
write(p,t)

# Review records.
p='book/chapter14/chapter14_review_revision.md'; t=read(p)
append='''

---

## 18. 2026-08-11 최종 출판 재검수 보완

Chapter 13 최종 기준과 Chapter 15 인계까지 다시 대조해 다음 출판 불일치를 보완했습니다.

```text
워크북의 오래된 제약조건 21개 → 실제 20개로 수정
이론 발표의 오래된 “취소 금액 0” 문장 제거
이미지 README의 “결제금액” → 신청 시점 기록 금액으로 수정
01 시작 전에 read-only·DB CREATE 권한 확인
Chapter 07 구조 계약 명명 제약조건 15 / NOT NULL 20 / 활성 신청 인덱스 확인
08 최종 게이트에서도 같은 Chapter 07 구조 계약 재확인
Python 월 date spine의 1~6월 하드코딩 제거 → 공통 기간 상수 사용
자동 생성 manifest에 expected_recorded_amount_sum·amount_semantics 실제 기록
manifest 검증에서도 두 필드 확인
최종 NOTICE 문구를 실제 08 출력과 동기화
완성된 발표 스크립트의 generic enhancer 비활성화
publishing CI가 Markdown 표 형태의 21개와 stale 취소 문장을 놓치지 않도록 강화
```

`transaction_read_only=on`은 분석 안전장치로 유지하되, 실제 환경에서는 최소권한 분석 계정과 함께 사용해야 한다는 경계도 본문·README·워크북에 명시했습니다.

최종 PostgreSQL 16·Python·CSV·발표 정적 재검증 결과는 성공 Run 확인 후 검증 기록에 별도로 남깁니다.
'''
if '## 18. 2026-08-11 최종 출판 재검수 보완' not in t: t += append
write(p,t)

p='notes/chapter14_review_checklist.md'; t=read(p)
append='''

---

## 17. 2026-08-11 최종 출판 재검수 항목

```text
워크북 제약조건 20개 동기화
이론 발표 stale 취소 금액 0 설명 제거
이미지 README 금액 의미 동기화
DB CREATE 권한 없는 역할에서 01이 DDL 전에 실패
Chapter 07 명명 제약조건 15 / NOT NULL 20 / 활성 신청 인덱스 인계 확인
08 최종 게이트에서 Chapter 07 구조 계약 재확인
Python 월 date spine 공통 기간 상수 사용
manifest expected_recorded_amount_sum=3210000 실제 생성·검증
manifest amount_semantics 실제 생성·검증
완성 스크립트 generic enhancer 비활성화
publishing CI stale Markdown 표·문장 검출 강화
PostgreSQL 16 SQL 01→08 재실행
PostgreSQL/CSV Python 교차 검증 재실행
SHA-256 변조·wrong DB·reset 격리 재확인
```

실제 Run ID와 결론은 재검증 완료 후 definitive 결과로 기록합니다.
'''
if '## 17. 2026-08-11 최종 출판 재검수 항목' not in t: t += append
write(p,t)

# Regenerate merged manuscript and run local static syntax assertions.
subprocess.run([sys.executable, 'scripts/merge_chapters.py'], check=True)
subprocess.run([sys.executable, '-m', 'py_compile', 'scripts/merge_chapters.py'], check=True)
for f in Path('code/chapter14/python').glob('*.py'):
    subprocess.run([sys.executable, '-m', 'py_compile', str(f)], check=True)

chapter=read('book/chapter14/chapter14.md'); activity=read('book/chapter14/chapter14_activity.md')
theory=read('presentation/chapter14/chapter14_theory_lecture_plan.md'); image=read('images/chapter14/README.md')
vu=read('code/chapter14/python/validation_utils.py'); p3=read('code/chapter14/python/03_pandas_analysis.py'); p4=read('code/chapter14/python/04_result_validation.py')
schema=read('code/chapter14/01_analysis_lab_schema.sql'); gate=read('code/chapter14/08_analysis_lab_validation.sql')
assert '| 제약조건 | 20개 |' in activity and '| 제약조건 | 21개 |' not in activity
assert '취소는 기준 데이터에서 0으로 기록됩니다' not in theory
assert '신청 시점 기록 금액 합계 3,210,000' in image
assert 'EXPECTED_RECORDED_AMOUNT_SUM = 3210000' in vu and 'AMOUNT_SEMANTICS' in vu
assert 'expected_recorded_amount_sum' in vu and 'amount_semantics' in vu
assert '"2026-06-01"' not in p3 and '"2026-06-01"' not in p4
assert 'inclusive="left"' in p3 and 'inclusive="left"' in p4
assert "has_database_privilege(current_user, current_database(), 'CREATE')" in schema
assert 'project_named_constraint_count <> 15' in schema and 'project_not_null_count <> 20' in schema
assert 'project_named_constraint_count <> 15' in gate and 'project_not_null_count <> 20' in gate
assert 'data-script-content-enhancer="off"' in read('presentation/chapter14/chapter14_script.html')
assert 'Chapter 14 analysis_lab validation passed: rows 8/3/5/24/24, amount 3210000' in chapter
assert 'Chapter 14. SQL 데이터 분석과 Python 확장' in read('publish/full_manuscript.md')
print('Chapter 14 final publication patch v2 prepared successfully')
