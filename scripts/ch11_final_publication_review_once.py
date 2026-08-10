from pathlib import Path


def read(path):
    return Path(path).read_text(encoding='utf-8')


def write(path, text):
    Path(path).write_text(text, encoding='utf-8')


def replace_once(text, old, new, label):
    if old not in text:
        raise SystemExit(f'missing target for {label}')
    if text.count(old) != 1:
        raise SystemExit(f'expected one target for {label}, got {text.count(old)}')
    return text.replace(old, new, 1)

# 1) Main chapter
path = 'book/chapter11/chapter11.md'
text = read(path)
text = replace_once(
    text,
    "1005 = 신청 / 120000\nuq_course_enrollments_active 존재\n```",
    "1005 = 신청 / 120000\nuq_course_enrollments_active 존재\nChapter 07 명명 제약조건 15개 / NOT NULL 열 20개 유지\n```",
    'chapter inherited structure baseline',
)
text = replace_once(
    text,
    "1001·1004·1005 기준 상태 일치\n활성 신청 부분 고유 인덱스 존재\nsecurity_lab 미존재\n```",
    "1001·1004·1005 기준 상태 일치\n활성 신청 부분 고유 인덱스 존재\nChapter 07 명명 제약조건 15개 / NOT NULL 열 20개 유지\n현재 역할이 ai_database_book에 CREATE 권한 보유\nsecurity_lab 미존재\n```",
    'chapter preflight checklist',
)
text = replace_once(
    text,
    "`PGPASSWORD`를 저장소 예제에 두지 않습니다. 실제 libpq password file은 저장소 밖에 두고 OS 접근 권한을 제한합니다. Windows에서는 사용자 프로필의 PostgreSQL 암호 파일 위치나 별도의 보호 경로를 사용합니다.\n",
    "`PGPASSWORD`를 저장소 예제에 두지 않습니다. PostgreSQL 16 공식 문서도 일부 운영체제에서 프로세스 환경 변수가 다른 사용자에게 보일 수 있어 `PGPASSWORD` 사용을 권장하지 않습니다. 대신 실제 libpq password file은 저장소 밖에 두고 `PGPASSFILE`로 위치를 지정합니다.\n\nUnix 계열에서는 password file이 그룹·다른 사용자에게 읽히지 않도록 `chmod 0600` 수준으로 제한해야 하며, 권한이 느슨하면 libpq가 파일을 무시합니다. Windows는 별도 파일 권한 검사를 하지 않으므로 사용자 프로필의 PostgreSQL 암호 파일 위치나 접근이 제한된 보호 경로에 저장합니다.\n",
    'chapter password file guidance',
)
text = replace_once(
    text,
    "pg_dump 주요 버전이 원본 서버보다 오래되면 중단한다.\n복원 서버가 원본보다 오래된 주요 버전이면 호환성을 별도로 검토한다.\n확장 기능과 외부 모듈 버전도 확인한다.\n```",
    "pg_dump 주요 버전이 원본 서버보다 오래되면 중단한다.\n복원에는 가능하면 백업 생성에 사용한 것과 같은 주요 버전의 pg_restore를 사용한다.\n복원 서버가 원본보다 오래된 주요 버전이면 호환성을 별도로 검토한다.\n확장 기능과 외부 모듈 버전도 확인한다.\n```",
    'chapter version guidance',
)
write(path, text)

# 2) SQL preflight hardening
path = 'code/chapter11/01_security_lab_schema.sql'
text = read(path)
text = replace_once(
    text,
    "    v_non_cancelled_amount NUMERIC;\nBEGIN",
    "    v_non_cancelled_amount NUMERIC;\n    v_project_named_constraint_count BIGINT;\n    v_project_not_null_count BIGINT;\nBEGIN",
    'schema declarations',
)
insert_after = "    IF to_regclass('course_project.uq_course_enrollments_active') IS NULL THEN\n        RAISE EXCEPTION '실행 중단: course_project 활성 신청 부분 고유 인덱스가 없습니다.';\n    END IF;\n"
addition = insert_after + "\n    IF NOT has_database_privilege(current_user, current_database(), 'CREATE') THEN\n        RAISE EXCEPTION\n            '실행 중단: 현재 역할 %에는 데이터베이스 %의 CREATE 권한이 없습니다.',\n            current_user, current_database();\n    END IF;\n\n    SELECT COUNT(*) INTO v_project_named_constraint_count\n    FROM pg_constraint\n    WHERE conrelid IN (\n        'course_project.students'::regclass,\n        'course_project.instructors'::regclass,\n        'course_project.courses'::regclass,\n        'course_project.enrollments'::regclass\n    )\n      AND conname IN (\n        'uq_course_students_email',\n        'chk_course_students_name_not_blank',\n        'chk_course_students_email_not_blank',\n        'uq_course_instructors_email',\n        'chk_course_instructors_name_not_blank',\n        'chk_course_instructors_email_not_blank',\n        'chk_course_instructors_specialty_not_blank',\n        'fk_course_courses_instructor',\n        'chk_course_courses_title_not_blank',\n        'chk_course_courses_level',\n        'chk_course_courses_price',\n        'fk_course_enrollments_student',\n        'fk_course_enrollments_course',\n        'chk_course_enrollments_status',\n        'chk_course_enrollments_recorded_amount'\n      );\n\n    SELECT COUNT(*) INTO v_project_not_null_count\n    FROM information_schema.columns\n    WHERE table_schema = 'course_project'\n      AND table_name IN ('students', 'instructors', 'courses', 'enrollments')\n      AND is_nullable = 'NO';\n\n    IF v_project_named_constraint_count <> 15 OR v_project_not_null_count <> 20 THEN\n        RAISE EXCEPTION\n            '실행 중단: Chapter 07 구조 기준과 다릅니다. named_constraints=%, not_null_columns=%',\n            v_project_named_constraint_count, v_project_not_null_count;\n    END IF;\n"
text = replace_once(text, insert_after, addition, 'schema create privilege and inherited structure gate')
write(path, text)

# 3) Code README
path = 'code/chapter11/README.md'
text = read(path)
needle = "uq_course_enrollments_active"
if needle in text and '명명 제약조건 15개' not in text:
    text = text.replace(needle, needle + "\n- Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개 유지\n- 현재 역할의 `ai_database_book` CREATE 권한 확인", 1)
if 'chmod 0600' not in text:
    marker = '`PGPASSFILE`'
    pos = text.find(marker)
    if pos != -1:
        end = text.find('\n', pos)
        text = text[:end+1] + "\nUnix 계열 password file은 그룹·다른 사용자 접근을 막도록 `chmod 0600` 수준으로 제한합니다. Windows는 별도 권한 검사를 하지 않으므로 접근이 제한된 사용자 경로를 사용합니다.\n" + text[end+1:]
write(path, text)

# 4) Outline
path = 'book/chapter11/chapter11_outline.md'
text = read(path)
if '명명 제약조건 15개' not in text:
    marker = 'uq_course_enrollments_active'
    text = text.replace(marker, marker + "\nChapter 07 명명 제약조건 15개 / NOT NULL 열 20개 유지\n현재 역할의 ai_database_book CREATE 권한 확인", 1)
if 'chmod 0600' not in text:
    text += "\n\n## 최종 출판 보안 보완\n\n- `PGPASSWORD` 장기 사용을 피하고 `PGPASSFILE` 기반 password file을 사용한다.\n- Unix 계열 password file은 `chmod 0600` 수준으로 제한하고, Windows는 접근이 제한된 보호 경로를 사용한다.\n- Chapter 07 구조 계약 15/20과 DB CREATE 권한을 `security_lab` 생성 전에 확인한다.\n"
write(path, text)

# 5) Activity workbook
path = 'book/chapter11/chapter11_activity.md'
text = read(path)
if '명명 제약조건 15개' not in text:
    target = '| `course_project` 행 수 | `3 / 2 / 3 / 5` |  |'
    if target in text:
        text = text.replace(target, target + "\n| Chapter 07 명명 제약조건 | `15` |  |\n| Chapter 07 NOT NULL 열 | `20` |  |\n| 현재 역할 DB CREATE 권한 | 있어야 함 |  |", 1)
if 'chmod 0600' not in text:
    text += "\n\n## 최종 출판 보안 확인\n\n```text\nUnix password file 권한을 chmod 0600 수준으로 제한한 이유:\n________________________________________________________________________\n\nPGPASSWORD 대신 PGPASSFILE을 사용하는 이유:\n________________________________________________________________________\n```\n"
write(path, text)

# 6) Theory and practice plans
for path in ['presentation/chapter11/chapter11_theory_lecture_plan.md', 'presentation/chapter11/chapter11_practice_lecture_plan.md']:
    text = read(path)
    if '명명 제약조건 15개' not in text:
        marker = 'uq_course_enrollments_active'
        if marker in text:
            text = text.replace(marker, marker + "이 존재하고, Chapter 07 명명 제약조건 15개·NOT NULL 열 20개가 유지되어야 합니다. `security_lab` 생성 역할에는 `ai_database_book`의 CREATE 권한도 필요합니다", 1)
    if 'chmod 0600' not in text:
        text += "\n\n> **최종 출판 보안 메모**: 실제 비밀번호는 저장소나 `PGPASSWORD`에 장기 보관하지 않습니다. `PGPASSFILE`을 사용하며 Unix 계열에서는 password file을 `chmod 0600` 수준으로 제한하고, Windows에서는 접근이 제한된 사용자 경로에 저장합니다.\n"
    write(path, text)

# 7) Runbook
path = 'code/chapter11/BACKUP_RESTORE_RUNBOOK.md'
text = read(path)
if 'chmod 0600' not in text:
    marker = 'PGPASSFILE'
    pos = text.find(marker)
    if pos != -1:
        end = text.find('\n', pos)
        text = text[:end+1] + "\nUnix 계열에서는 password file을 `chmod 0600` 수준으로 제한합니다. 권한이 느슨하면 libpq가 파일을 무시합니다. Windows는 별도 권한 검사를 하지 않으므로 접근이 제한된 보호 경로를 사용합니다.\n" + text[end+1:]
write(path, text)

# 8) Compatibility entry point
path = 'code/chapter11/security_backup_check.sql'
text = read(path)
if 'chmod 0600' not in text:
    text += "\n-- Unix 계열 password file은 그룹·다른 사용자 접근을 막도록 chmod 0600 수준으로 제한합니다.\n-- Windows는 별도 권한 검사를 하지 않으므로 접근이 제한된 사용자 경로를 사용합니다.\n"
write(path, text)

# 9) Presenter script: preserve authored script, disable generic expansion
path = 'presentation/chapter11/chapter11_script.html'
text = read(path)
text = replace_once(text, '<body>', '<body data-script-content-enhancer="off">', 'presenter script enhancer')
write(path, text)

# 10) Review revision historical note
path = 'book/chapter11/chapter11_review_revision.md'
text = read(path)
if '## 2026-08-10 최종 출판 보완' not in text:
    text += """

---

## 2026-08-10 최종 출판 보완

- Chapter 07 명명 제약조건 15개 / NOT NULL 열 20개를 Chapter 11 시작 게이트에 추가
- `security_lab` 생성 전 현재 역할의 `ai_database_book` CREATE 권한 검사 추가
- `PGPASSWORD` 장기 사용을 피하고 `PGPASSFILE` 기반 password file 사용 원칙을 구체화
- Unix password file `chmod 0600` 및 Windows 보호 경로 차이를 명시
- 작성된 Chapter 11 발표 스크립트의 일반 자동 확장 비활성화
- PostgreSQL 16 실제 권한·백업·별도 DB 복원 경로를 재검증 대상으로 지정
"""
write(path, text)

# 11) Permanent validator enhancements
path = '.github/workflows/validate-chapter11.yml'
text = read(path)
text = replace_once(
    text,
    "          for token in ['590000', '340000', '440000', \"v_requested_count <> 2\", \"v_learning_count <> 1\", 'NUMERIC(12,0)']:\n              if token not in sql['01_security_lab_schema.sql']:\n                  raise SystemExit(f'01 missing Chapter 07/08 gate {token}')",
    "          for token in ['590000', '340000', '440000', \"v_requested_count <> 2\", \"v_learning_count <> 1\", 'NUMERIC(12,0)', \"has_database_privilege(current_user, current_database(), 'CREATE')\", 'v_project_named_constraint_count <> 15', 'v_project_not_null_count <> 20']:\n              if token not in sql['01_security_lab_schema.sql']:\n                  raise SystemExit(f'01 missing Chapter 07/08 or CREATE gate {token}')",
    'validator schema tokens',
)
text = replace_once(
    text,
    "          if '../common/script_content_enhancer.js' not in script_html:\n              raise SystemExit('shared script content enhancer is not loaded')",
    "          if '../common/script_content_enhancer.js' not in script_html:\n              raise SystemExit('shared script content enhancer is not loaded')\n          if 'data-script-content-enhancer=\"off\"' not in script_html:\n              raise SystemExit('Chapter 11 authored presenter script must disable generic expansion')",
    'validator script enhancer',
)
text = replace_once(
    text,
    "          if 'PGPASSWORD=' in env_example or 'PGPASSFILE=' not in env_example:\n              raise SystemExit('.env.example must use PGPASSFILE and must not expose PGPASSWORD')",
    "          if 'PGPASSWORD=' in env_example or 'PGPASSFILE=' not in env_example:\n              raise SystemExit('.env.example must use PGPASSFILE and must not expose PGPASSWORD')\n          for name, source in [('chapter', chapter), ('code README', code_readme), ('runbook', runbook)]:\n              if 'chmod 0600' not in source:\n                  raise SystemExit(f'{name} missing Unix password-file permission guidance')",
    'validator password guidance',
)
marker = "      - name: Capture protected project fingerprint\n"
if marker not in text:
    raise SystemExit('validator runtime marker missing')
block = """      - name: Verify inherited Chapter 07 structure contract
        shell: bash
        run: |
          STRUCTURE=$(psql -d ai_database_book -At -v ON_ERROR_STOP=1 <<'SQL'
          SELECT
            (SELECT COUNT(*)
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
             )) || ':' ||
            (SELECT COUNT(*)
             FROM information_schema.columns
             WHERE table_schema='course_project'
               AND table_name IN ('students','instructors','courses','enrollments')
               AND is_nullable='NO');
          SQL
          )
          echo "Chapter 07 structure contract: $STRUCTURE"
          test "$STRUCTURE" = "15:20"

      - name: Verify CREATE privilege protection before security_lab creation
        shell: bash
        run: |
          psql -v ON_ERROR_STOP=1 -d ai_database_book <<'SQL'
          CREATE ROLE ch11_no_create LOGIN PASSWORD 'chapter11-test';
          GRANT CONNECT ON DATABASE ai_database_book TO ch11_no_create;
          REVOKE CREATE ON DATABASE ai_database_book FROM ch11_no_create;
          GRANT USAGE ON SCHEMA course_project TO ch11_no_create;
          GRANT SELECT ON ALL TABLES IN SCHEMA course_project TO ch11_no_create;
          SQL

          set +e
          PGUSER=ch11_no_create PGPASSWORD=chapter11-test psql -h localhost -d ai_database_book -v ON_ERROR_STOP=1 -f code/chapter11/01_security_lab_schema.sql > /tmp/ch11_no_create.log 2>&1
          status=$?
          set -e
          cat /tmp/ch11_no_create.log
          test "$status" -ne 0
          grep -q "CREATE 권한" /tmp/ch11_no_create.log
          test "$(psql -d ai_database_book -Atc "SELECT to_regnamespace('security_lab') IS NULL")" = "t"

"""
text = text.replace(marker, block + marker, 1)
write(path, text)

print('Chapter 11 final publication review patch prepared successfully')
