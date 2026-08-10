from pathlib import Path


def read(path):
    return Path(path).read_text(encoding='utf-8')


def write(path, text):
    Path(path).write_text(text, encoding='utf-8')


def rep(text, old, new, label):
    if old not in text:
        raise SystemExit(f'missing replacement target: {label}')
    if text.count(old) != 1:
        raise SystemExit(f'non-unique replacement target: {label} count={text.count(old)}')
    return text.replace(old, new, 1)

# ------------------------------------------------------------------
# Main body
# ------------------------------------------------------------------
p='book/chapter14/chapter14.md'; t=read(p)
t=rep(t,
'''현재 DB = ai_database_book
analysis_lab 미존재''',
'''현재 DB = ai_database_book
현재 트랜잭션이 읽기 전용이 아님
현재 역할의 DB CREATE 권한
Chapter 07 명명 제약조건 15개
Chapter 07 NOT NULL 열 20개
Chapter 07 활성 신청 부분 고유 인덱스
course_project canonical 기준 상태
analysis_lab 미존재''','body preflight')
t=rep(t,
'''Chapter 14 analysis_lab validation passed''',
'''Chapter 14 analysis_lab validation passed: rows 8/3/5/24/24, amount 3210000''','body exact notice')
t=rep(t,
'''  "row_count": 24,
  "generated_at_utc": "...",
  "sha256": "..."''',
'''  "row_count": 24,
  "expected_recorded_amount_sum": 3210000,
  "generated_at_utc": "...",
  "sha256": "...",
  "amount_semantics": "recorded_amount = enrollment-time recorded amount; cancellation does not zero it"''','body manifest')
t=rep(t,
'''SQLAlchemy의 `URL.create()`를 사용해 사용자·호스트·DB를 구성하고, 비밀번호는 libpq password file에 맡깁니다. 코드·노트북·화면 캡처에 전체 접속 URL과 비밀번호를 남기지 않습니다.''',
'''SQLAlchemy의 `URL.create()`를 사용해 사용자·호스트·DB를 구성하고, 비밀번호는 libpq password file에 맡깁니다. 코드·노트북·화면 캡처에 전체 접속 URL과 비밀번호를 남기지 않습니다.

`transaction_read_only = on`은 분석 트랜잭션의 일반적인 비임시 테이블 변경을 막는 안전장치입니다. 다만 이것만으로 최소권한 보안 설계가 완성되는 것은 아니므로, 실제 환경에서는 분석 전용 계정에 필요한 `CONNECT`·`USAGE`·`SELECT`만 부여하고 코드에서도 변경 SQL을 허용하지 않는 방식을 함께 사용합니다.''','body read only nuance')
t=rep(t,
'''Python에서도 1~6월 기준표를 만들어 데이터가 없는 월을 0건으로 유지합니다.''',
'''Python에서도 `validation_utils.py`의 공통 분석 시작일·종료일을 사용해 월 기준표를 만들고 데이터가 없는 월을 0건으로 유지합니다. SQL 기간과 별도로 `2026-06-01` 같은 마지막 월을 다시 하드코딩하지 않습니다.''','body shared period')
write(p,t)

# ------------------------------------------------------------------
# Workbook
# ------------------------------------------------------------------
p='book/chapter14/chapter14_activity.md'; t=read(p)
t=rep(t,'| 제약조건 | 21개 |  |','| 제약조건 | 20개 |  |','activity constraints')
t=rep(t,
'''| 생성 UTC 시각 |  |
| SHA-256 |  |''',
'''| 생성 UTC 시각 |  |
| 기대 기록 금액 합계 | `3210000` |  |
| 기록 금액 의미 | 신청 시점 기록 금액 |  |
| SHA-256 |  |''','activity manifest fields')
t=rep(t,
'''| transaction_read_only |  |
| 분석 VIEW 존재 |  |''',
'''| transaction_read_only |  |
| 분석 VIEW 존재 |  |
| 분석 계정 최소권한 | CONNECT·USAGE·SELECT 중심 |  |''','activity readonly')
write(p,t)

# ------------------------------------------------------------------
# Outline
# ------------------------------------------------------------------
p='book/chapter14/chapter14_outline.md'; t=read(p)
t=rep(t,
'''- PostgreSQL 연결은 읽기 전용으로 설정한다.
- 비밀번호·전체 접속 URL·password file을 저장소에 기록하지 않는다.''',
'''- PostgreSQL 연결은 읽기 전용으로 설정하되, 읽기 전용 상태만 보안 경계로 보지 않고 분석 계정 최소권한과 함께 사용한다.
- Python 월 기준표는 `validation_utils.py`의 공통 분석 기간 상수에서 생성한다.
- 비밀번호·전체 접속 URL·password file을 저장소에 기록하지 않는다.''','outline safety')
write(p,t)

# ------------------------------------------------------------------
# Code README
# ------------------------------------------------------------------
p='code/chapter14/README.md'; t=read(p)
t=rep(t,'Chapter 14 analysis_lab validation passed','Chapter 14 analysis_lab validation passed: rows 8/3/5/24/24, amount 3210000','readme notice')
t=rep(t,
'''CSV manifest: DB·VIEW·기간·생성 시점·행 수·SHA-256
reference_metrics.json: SQL 기준값''',
'''CSV manifest: DB·VIEW·기간·생성 시점·행 수·기대 기록 금액·금액 의미·SHA-256
reference_metrics.json: SQL 기준값''','readme manifest')
t=rep(t,
'''transaction_read_only = on
정확한 컬럼과 24행''',
'''transaction_read_only = on
분석 계정은 실제 환경에서 CONNECT·USAGE·SELECT 중심 최소권한
정확한 컬럼과 24행''','readme readonly')
t=rep(t,
'''- PostgreSQL 연결은 읽기 전용으로 설정한다.
- 비밀번호·전체 접속 URL·password file을 코드에 기록하지 않는다.''',
'''- PostgreSQL 연결은 읽기 전용으로 설정하고 실제 환경에서는 최소권한 분석 계정과 함께 사용한다.
- Python 월 date spine은 공통 분석 기간 상수에서 생성한다.
- 비밀번호·전체 접속 URL·password file을 코드에 기록하지 않는다.''','readme safety')
write(p,t)

# ------------------------------------------------------------------
# Theory deck stale statement
# ------------------------------------------------------------------
p='presentation/chapter14/chapter14_theory_lecture_plan.md'; t=read(p)
t=rep(t,
'''여기서는 실제 결제 완료 매출이 아니라 신청 당시 기록된 금액으로 해석합니다. 신청이나 수강중 상태에도 양수 금액이 있을 수 있고, 취소는 기준 데이터에서 0으로 기록됩니다.''',
'''여기서는 실제 결제 완료 매출이 아니라 신청 당시 기록된 금액으로 해석합니다. 신청이나 수강중 상태에도 양수 금액이 있을 수 있고, 취소 상태가 되어도 신청 시점 기록 금액은 그대로 유지합니다.''','theory cancellation')
write(p,t)

# Finished presenter scripts should not be generically enhanced again.
p='presentation/chapter14/chapter14_script.html'; t=read(p)
t=rep(t,'<body>','<body data-script-content-enhancer="off">','script enhancer off')
write(p,t)

# ------------------------------------------------------------------
# Image README
# ------------------------------------------------------------------
p='images/chapter14/README.md'; t=read(p)
t=rep(t,
'''- SQL과 Python 결과를 별도의 기준값으로 교차 검증한다.''',
'''- PostgreSQL 경로는 같은 스냅샷의 실제 SQL 결과와 pandas 결과를, CSV 경로는 검증된 manifest와 버전 관리 SQL 기준값을 비교한다.''','image validation')
t=rep(t,'결제금액 합계 3,210,000','신청 시점 기록 금액 합계 3,210,000','image amount semantics')
write(p,t)

# ------------------------------------------------------------------
# Python shared contract
# ------------------------------------------------------------------
p='code/chapter14/python/validation_utils.py'; t=read(p)
t=rep(t,
'''EXPECTED_ROWS = 24

EXPECTED_COLUMNS = [''',
'''EXPECTED_ROWS = 24
EXPECTED_RECORDED_AMOUNT_SUM = 3210000
AMOUNT_SEMANTICS = (
    "recorded_amount = enrollment-time recorded amount; cancellation does not zero it"
)

EXPECTED_COLUMNS = [''','python constants')
t=rep(t,
'''        "row_count": row_count,
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "csv_path": str(csv_path.resolve()),
        "sha256": file_sha256(csv_path),''',
'''        "row_count": row_count,
        "expected_recorded_amount_sum": EXPECTED_RECORDED_AMOUNT_SUM,
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "csv_path": str(csv_path.resolve()),
        "sha256": file_sha256(csv_path),
        "amount_semantics": AMOUNT_SEMANTICS,''','write manifest')
t=rep(t,
'''        "row_count": EXPECTED_ROWS,
    }''',
'''        "row_count": EXPECTED_ROWS,
        "expected_recorded_amount_sum": EXPECTED_RECORDED_AMOUNT_SUM,
        "amount_semantics": AMOUNT_SEMANTICS,
    }''','validate manifest')
write(p,t)

for p in ['code/chapter14/python/03_pandas_analysis.py','code/chapter14/python/04_result_validation.py']:
    t=read(p)
    if p.endswith('03_pandas_analysis.py'):
        t=rep(t,
'''    DEFAULT_CSV_PATH,
    create_read_only_engine,''',
'''    ANALYSIS_END_DATE_EXCLUSIVE,
    ANALYSIS_START_DATE,
    DEFAULT_CSV_PATH,
    create_read_only_engine,''','03 imports')
    else:
        t=rep(t,
'''    DEFAULT_CSV_PATH,
    DEFAULT_MANIFEST_PATH,''',
'''    ANALYSIS_END_DATE_EXCLUSIVE,
    ANALYSIS_START_DATE,
    DEFAULT_CSV_PATH,
    DEFAULT_MANIFEST_PATH,''','04 imports')
    t=rep(t,
'''            "enrollment_month": pd.date_range(
                "2026-01-01",
                "2026-06-01",
                freq="MS",
            )''',
'''            "enrollment_month": pd.date_range(
                ANALYSIS_START_DATE,
                ANALYSIS_END_DATE_EXCLUSIVE,
                freq="MS",
                inclusive="left",
            )''',f'{p} shared date range')
    write(p,t)

# ------------------------------------------------------------------
# SQL Chapter 07 structural contract + DDL preflight
# ------------------------------------------------------------------
p='code/chapter14/01_analysis_lab_schema.sql'; t=read(p)
t=rep(t,
'''    status_cancelled BIGINT;
BEGIN''',
'''    status_cancelled BIGINT;
    project_named_constraint_count INTEGER;
    project_not_null_count INTEGER;
BEGIN''','01 declarations')
t=rep(t,
'''    IF to_regclass('course_project.students') IS NULL''',
'''    IF current_setting('transaction_read_only')::boolean THEN
        RAISE EXCEPTION '실행 중단: 현재 트랜잭션이 읽기 전용입니다. analysis_lab 생성이 가능한 연결을 사용하세요.';
    END IF;

    IF NOT has_database_privilege(current_user, current_database(), 'CREATE') THEN
        RAISE EXCEPTION
            '실행 중단: 사용자 %에게 데이터베이스 %의 CREATE 권한이 없습니다.',
            current_user, current_database();
    END IF;

    IF to_regclass('course_project.students') IS NULL''','01 create/read-only preflight')
marker='''    SELECT COUNT(*) FILTER (WHERE status = '신청'),'''
insert='''    SELECT COUNT(*)
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
            '실행 중단: Chapter 07 구조 계약은 명명 제약조건 15개 / NOT NULL 열 20개여야 하지만 현재 % / %입니다.',
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
        RAISE EXCEPTION '실행 중단: Chapter 07 활성 신청 부분 고유 인덱스 정의가 다릅니다.';
    END IF;

'''+marker
t=rep(t,marker,insert,'01 structure contract')
write(p,t)

p='code/chapter14/08_analysis_lab_validation.sql'; t=read(p)
t=rep(t,
'''    enrollments_next BIGINT;
BEGIN''',
'''    enrollments_next BIGINT;
    project_named_constraint_count INTEGER;
    project_not_null_count INTEGER;
BEGIN''','08 declarations')
marker='''    IF (SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = 'analysis_lab' '''
insert='''    SELECT COUNT(*)
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
t=rep(t,marker,insert,'08 structure contract')
write(p,t)

# ------------------------------------------------------------------
# Permanent comprehensive CI: strengthen checks + actual privilege gate
# ------------------------------------------------------------------
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

# ------------------------------------------------------------------
# Publishing CI: catch stale prose/table forms and image semantics
# ------------------------------------------------------------------
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

# ------------------------------------------------------------------
# Review records (pre-validation; definitive run appended after success)
# ------------------------------------------------------------------
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
if '## 18. 2026-08-11 최종 출판 재검수 보완' not in t:
    t += append
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
if '## 17. 2026-08-11 최종 출판 재검수 항목' not in t:
    t += append
write(p,t)

# Regenerate merged manuscript and validate Python syntax.
import subprocess, sys
subprocess.run([sys.executable, 'scripts/merge_chapters.py'], check=True)
subprocess.run([sys.executable, '-m', 'py_compile', 'scripts/merge_chapters.py'], check=True)
for f in Path('code/chapter14/python').glob('*.py'):
    subprocess.run([sys.executable, '-m', 'py_compile', str(f)], check=True)

# Final deterministic assertions before committing.
chapter=read('book/chapter14/chapter14.md')
activity=read('book/chapter14/chapter14_activity.md')
theory=read('presentation/chapter14/chapter14_theory_lecture_plan.md')
image=read('images/chapter14/README.md')
vu=read('code/chapter14/python/validation_utils.py')
p3=read('code/chapter14/python/03_pandas_analysis.py')
p4=read('code/chapter14/python/04_result_validation.py')
schema=read('code/chapter14/01_analysis_lab_schema.sql')
gate=read('code/chapter14/08_analysis_lab_validation.sql')
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
print('Chapter 14 final publication patch prepared successfully')
