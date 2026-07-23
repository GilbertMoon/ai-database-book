-- Chapter 14. analysis_lab 최종 자동 검증
-- 목적: P14-V05 SQL·Python 확장 전에 구조·기간·품질·기준값을 예외 기반으로 판정합니다.
-- 하나라도 다르면 예외를 발생시키고, 모두 맞으면 통과 메시지를 출력합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

DO $$
DECLARE
    table_name_mismatch_count INTEGER;
    view_name_mismatch_count INTEGER;
    dataset_column_mismatch_count INTEGER;
    constraint_count INTEGER;
    identity_count INTEGER;
    quality_issue_count BIGINT;
    status_mismatch_count INTEGER;
    monthly_mismatch_count INTEGER;
    active_duplicate_count BIGINT;
    dataset_duplicate_count BIGINT;
    students_next BIGINT;
    instructors_next BIGINT;
    courses_next BIGINT;
    enrollments_next BIGINT;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '검증 중단: 현재 데이터베이스는 %입니다.',
            current_database();
    END IF;

    IF to_regclass('analysis_lab.students') IS NULL
       OR to_regclass('analysis_lab.instructors') IS NULL
       OR to_regclass('analysis_lab.courses') IS NULL
       OR to_regclass('analysis_lab.enrollments') IS NULL
       OR to_regclass('analysis_lab.analysis_parameters') IS NULL
       OR to_regclass('analysis_lab.enrollment_analysis_dataset') IS NULL THEN
        RAISE EXCEPTION
            '검증 실패: analysis_lab 핵심 테이블 또는 VIEW가 없습니다.';
    END IF;

    -- 정확한 테이블 집합 4개
    SELECT COUNT(*)
    INTO table_name_mismatch_count
    FROM (
        (
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'analysis_lab'
        )
        EXCEPT
        (
            SELECT expected_name
            FROM (VALUES
                ('students'),
                ('instructors'),
                ('courses'),
                ('enrollments')
            ) AS expected(expected_name)
        )

        UNION ALL

        (
            SELECT expected_name
            FROM (VALUES
                ('students'),
                ('instructors'),
                ('courses'),
                ('enrollments')
            ) AS expected(expected_name)
        )
        EXCEPT
        (
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'analysis_lab'
        )
    ) AS differences;

    IF table_name_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: analysis_lab 테이블 집합이 예상과 다릅니다.';
    END IF;

    -- 정확한 VIEW 집합 2개
    SELECT COUNT(*)
    INTO view_name_mismatch_count
    FROM (
        (
            SELECT table_name
            FROM information_schema.views
            WHERE table_schema = 'analysis_lab'
        )
        EXCEPT
        (
            SELECT expected_name
            FROM (VALUES
                ('analysis_parameters'),
                ('enrollment_analysis_dataset')
            ) AS expected(expected_name)
        )

        UNION ALL

        (
            SELECT expected_name
            FROM (VALUES
                ('analysis_parameters'),
                ('enrollment_analysis_dataset')
            ) AS expected(expected_name)
        )
        EXCEPT
        (
            SELECT table_name
            FROM information_schema.views
            WHERE table_schema = 'analysis_lab'
        )
    ) AS differences;

    IF view_name_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: analysis_lab VIEW 집합이 예상과 다릅니다.';
    END IF;

    -- 분석 기간
    IF NOT EXISTS (
        SELECT 1
        FROM analysis_lab.analysis_parameters
        WHERE start_date = DATE '2026-01-01'
          AND end_date_exclusive = DATE '2026-07-01'
    ) OR (SELECT COUNT(*) FROM analysis_lab.analysis_parameters) <> 1 THEN
        RAISE EXCEPTION
            '검증 실패: 분석 기간은 [2026-01-01, 2026-07-01) 한 행이어야 합니다.';
    END IF;

    -- 기준 행 수와 합계
    IF (SELECT COUNT(*) FROM analysis_lab.students) <> 8
       OR (SELECT COUNT(*) FROM analysis_lab.instructors) <> 3
       OR (SELECT COUNT(*) FROM analysis_lab.courses) <> 5
       OR (SELECT COUNT(*) FROM analysis_lab.enrollments) <> 24
       OR (SELECT COUNT(*) FROM analysis_lab.enrollment_analysis_dataset) <> 24 THEN
        RAISE EXCEPTION
            '검증 실패: 기준 행 수 8/3/5/24/24와 일치하지 않습니다.';
    END IF;

    IF (SELECT SUM(recorded_amount) FROM analysis_lab.enrollment_analysis_dataset) <> 2770000 THEN
        RAISE EXCEPTION
            '검증 실패: 신청 당시 기록 금액 합계는 2,770,000이어야 합니다.';
    END IF;

    -- 분석 데이터셋의 정확한 컬럼 집합 17개
    SELECT COUNT(*)
    INTO dataset_column_mismatch_count
    FROM (
        (
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'analysis_lab'
              AND table_name = 'enrollment_analysis_dataset'
        )
        EXCEPT
        (
            SELECT expected_name
            FROM (VALUES
                ('enrollment_id'), ('student_id'), ('student_name'), ('region'),
                ('course_id'), ('course_title'), ('category'), ('level'),
                ('instructor_id'), ('instructor_name'), ('enrolled_at'),
                ('enrollment_month'), ('status'), ('recorded_amount'),
                ('completed_at'), ('completion_days'), ('is_completed')
            ) AS expected(expected_name)
        )

        UNION ALL

        (
            SELECT expected_name
            FROM (VALUES
                ('enrollment_id'), ('student_id'), ('student_name'), ('region'),
                ('course_id'), ('course_title'), ('category'), ('level'),
                ('instructor_id'), ('instructor_name'), ('enrolled_at'),
                ('enrollment_month'), ('status'), ('recorded_amount'),
                ('completed_at'), ('completion_days'), ('is_completed')
            ) AS expected(expected_name)
        )
        EXCEPT
        (
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'analysis_lab'
              AND table_name = 'enrollment_analysis_dataset'
        )
    ) AS differences;

    IF dataset_column_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 분석 데이터셋 컬럼 집합이 예상과 다릅니다.';
    END IF;

    -- 21개 PK·FK·UNIQUE·CHECK 제약조건과 4개 IDENTITY
    SELECT COUNT(*)
    INTO constraint_count
    FROM pg_constraint
    WHERE connamespace = 'analysis_lab'::regnamespace;

    IF constraint_count <> 21 THEN
        RAISE EXCEPTION
            '검증 실패: analysis_lab 제약조건은 21개여야 하지만 %개입니다.',
            constraint_count;
    END IF;

    SELECT COUNT(*)
    INTO identity_count
    FROM information_schema.columns
    WHERE table_schema = 'analysis_lab'
      AND column_name = 'id'
      AND is_identity = 'YES'
      AND table_name IN ('students', 'instructors', 'courses', 'enrollments');

    IF identity_count <> 4 THEN
        RAISE EXCEPTION
            '검증 실패: IDENTITY PK는 4개여야 합니다.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'analysis_lab'
          AND indexname = 'uq_analysis_enrollments_active'
          AND indexdef ILIKE 'CREATE UNIQUE INDEX%'
          AND indexdef ILIKE '%(student_id, course_id)%'
          AND indexdef ILIKE '%WHERE%status%신청%수강중%'
    ) THEN
        RAISE EXCEPTION
            '검증 실패: 활성 신청 부분 고유 인덱스가 없거나 정의가 다릅니다.';
    END IF;

    -- 상태별 기준값
    WITH expected(status, expected_count) AS (
        VALUES
            ('완료'::varchar, 12),
            ('수강중'::varchar, 5),
            ('신청'::varchar, 4),
            ('취소'::varchar, 3)
    ),
    actual AS (
        SELECT status, COUNT(*)::integer AS actual_count
        FROM analysis_lab.enrollment_analysis_dataset
        GROUP BY status
    )
    SELECT COUNT(*)
    INTO status_mismatch_count
    FROM expected AS e
    FULL JOIN actual AS a
        ON a.status = e.status
    WHERE e.expected_count IS DISTINCT FROM a.actual_count;

    IF status_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 상태별 기준값 12/5/4/3과 일치하지 않습니다.';
    END IF;

    -- 월별 기준값과 금액
    WITH expected(month_value, expected_count, expected_amount) AS (
        VALUES
            (DATE '2026-01-01', 3, 200000),
            (DATE '2026-02-01', 4, 520000),
            (DATE '2026-03-01', 5, 540000),
            (DATE '2026-04-01', 4, 550000),
            (DATE '2026-05-01', 4, 390000),
            (DATE '2026-06-01', 4, 570000)
    ),
    actual AS (
        SELECT
            enrollment_month AS month_value,
            COUNT(*)::integer AS actual_count,
            SUM(recorded_amount)::integer AS actual_amount
        FROM analysis_lab.enrollment_analysis_dataset
        GROUP BY enrollment_month
    )
    SELECT COUNT(*)
    INTO monthly_mismatch_count
    FROM expected AS e
    FULL JOIN actual AS a
        ON a.month_value = e.month_value
    WHERE e.expected_count IS DISTINCT FROM a.actual_count
       OR e.expected_amount IS DISTINCT FROM a.actual_amount;

    IF monthly_mismatch_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 월별 건수 또는 기록 금액 기준값이 일치하지 않습니다.';
    END IF;

    -- 완료된 신청의 기간 통계
    IF (
        SELECT COUNT(*)
        FROM analysis_lab.enrollment_analysis_dataset
        WHERE is_completed
    ) <> 12
    OR (
        SELECT ROUND(AVG(completion_days), 2)
        FROM analysis_lab.enrollment_analysis_dataset
        WHERE is_completed
    ) <> 25.00
    OR (
        SELECT MIN(completion_days)
        FROM analysis_lab.enrollment_analysis_dataset
        WHERE is_completed
    ) <> 18
    OR (
        SELECT MAX(completion_days)
        FROM analysis_lab.enrollment_analysis_dataset
        WHERE is_completed
    ) <> 36 THEN
        RAISE EXCEPTION
            '검증 실패: 완료 건수·평균·최소·최대 기간 기준이 다릅니다.';
    END IF;

    -- 활성 중복과 데이터셋 중복
    SELECT COUNT(*)
    INTO active_duplicate_count
    FROM (
        SELECT student_id, course_id
        FROM analysis_lab.enrollments
        WHERE status IN ('신청', '수강중')
        GROUP BY student_id, course_id
        HAVING COUNT(*) > 1
    ) AS duplicates;

    SELECT COUNT(*)
    INTO dataset_duplicate_count
    FROM (
        SELECT enrollment_id
        FROM analysis_lab.enrollment_analysis_dataset
        GROUP BY enrollment_id
        HAVING COUNT(*) > 1
    ) AS duplicates;

    IF active_duplicate_count <> 0 OR dataset_duplicate_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 활성 신청 중복 %건, 데이터셋 PK 중복 %건입니다.',
            active_duplicate_count,
            dataset_duplicate_count;
    END IF;

    -- 모든 품질 이상을 하나의 수치로 합산
    SELECT
        (SELECT COUNT(*)
         FROM analysis_lab.enrollments AS e
         LEFT JOIN analysis_lab.students AS s ON s.id = e.student_id
         WHERE s.id IS NULL)
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments AS e
         LEFT JOIN analysis_lab.courses AS c ON c.id = e.course_id
         WHERE c.id IS NULL)
      + (SELECT COUNT(*)
         FROM analysis_lab.courses AS c
         LEFT JOIN analysis_lab.instructors AS i ON i.id = c.instructor_id
         WHERE i.id IS NULL)
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments
         WHERE status = '완료' AND completed_at IS NULL)
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments
         WHERE status <> '완료' AND completed_at IS NOT NULL)
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments AS e
         JOIN analysis_lab.students AS s ON s.id = e.student_id
         WHERE e.enrolled_at < s.joined_at)
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments AS e
         JOIN analysis_lab.courses AS c ON c.id = e.course_id
         WHERE e.enrolled_at < c.opened_at)
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments
         WHERE paid_amount < 0
            OR (status = '취소' AND paid_amount <> 0))
      + (SELECT COUNT(*)
         FROM analysis_lab.enrollments AS e
         CROSS JOIN analysis_lab.analysis_parameters AS p
         WHERE e.enrolled_at < p.start_date
            OR e.enrolled_at >= p.end_date_exclusive)
    INTO quality_issue_count;

    IF quality_issue_count <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: 데이터 품질 이상이 총 %건입니다.',
            quality_issue_count;
    END IF;

    -- IDENTITY 다음 값은 기존 최대 ID보다 커야 합니다.
    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO students_next
    FROM analysis_lab.students_id_seq;

    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO instructors_next
    FROM analysis_lab.instructors_id_seq;

    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO courses_next
    FROM analysis_lab.courses_id_seq;

    SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END
    INTO enrollments_next
    FROM analysis_lab.enrollments_id_seq;

    IF students_next <= (SELECT MAX(id) FROM analysis_lab.students)
       OR instructors_next <= (SELECT MAX(id) FROM analysis_lab.instructors)
       OR courses_next <= (SELECT MAX(id) FROM analysis_lab.courses)
       OR enrollments_next <= (SELECT MAX(id) FROM analysis_lab.enrollments) THEN
        RAISE EXCEPTION
            '검증 실패: IDENTITY 다음 값이 기존 최대 ID보다 크지 않습니다.';
    END IF;

    RAISE NOTICE 'Chapter 14 analysis_lab validation passed';
END
$$;
