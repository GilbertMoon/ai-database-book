-- Chapter 04. 04 안전한 UPDATE와 DELETE
-- 시작 상태: 샘플 학생 6명, 이준호 grade 3, 박서연 존재
-- 완료 상태: 학생 5명, 이준호 grade 4, 박서연 삭제
-- 실행 방법: 각 단계의 SELECT와 변경 SQL을 순서대로 확인합니다.

DO $$
DECLARE
    v_count bigint;
    v_junho_grade integer;
    v_seoyeon_count bigint;
BEGIN
    IF to_regclass('public.students') IS NULL THEN
        RAISE EXCEPTION
            '변경 중단: public.students가 없습니다.';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM public.students;

    SELECT grade INTO v_junho_grade
    FROM public.students
    WHERE email = 'junho@example.com';

    SELECT COUNT(*) INTO v_seoyeon_count
    FROM public.students
    WHERE email = 'seoyeon@example.com';

    IF v_count <> 6
       OR v_junho_grade IS DISTINCT FROM 3
       OR v_seoyeon_count <> 1 THEN
        RAISE EXCEPTION
            '변경 중단: 초기 데이터 상태가 아닙니다. 학생 수=%, 이준호 학년=%, 박서연 행 수=%',
            v_count, v_junho_grade, v_seoyeon_count;
    END IF;
END
$$;

-- ============================================================
-- UPDATE: 이준호 학년을 3에서 4로 변경
-- ============================================================

-- 1. 대상 확인
SELECT id, name, email, grade
FROM public.students
WHERE email = 'junho@example.com';

-- 2. 수정과 반환값 확인
UPDATE public.students
SET grade = 4
WHERE email = 'junho@example.com'
RETURNING id, name, grade;

-- 3. 수정 결과 확인
SELECT id, name, email, grade
FROM public.students
WHERE email = 'junho@example.com';

-- ============================================================
-- DELETE: 박서연 학생 삭제
-- ============================================================

-- 1. 대상 확인
SELECT id, name, email, major
FROM public.students
WHERE email = 'seoyeon@example.com';

-- 2. 삭제와 반환값 확인
DELETE FROM public.students
WHERE email = 'seoyeon@example.com'
RETURNING id, name, email;

-- 3. 삭제 결과 확인: 기대 결과 0행
SELECT id, name, email
FROM public.students
WHERE email = 'seoyeon@example.com';

-- 최종 상태 확인
SELECT COUNT(*) AS remaining_student_count
FROM public.students;

SELECT id, name, email, major, grade
FROM public.students
ORDER BY id ASC;

-- ------------------------------------------------------------
-- 실행하지 않는 위험 SQL 예시
-- ------------------------------------------------------------

-- WHERE가 없으므로 모든 행을 수정합니다.
-- UPDATE public.students
-- SET grade = 1;

-- WHERE가 없으므로 모든 행을 삭제합니다.
-- DELETE FROM public.students;

-- 여러 열 수정 예시입니다. 기본 실습에서는 실행하지 않습니다.
-- UPDATE public.students
-- SET major = '소프트웨어공학',
--     grade = 3
-- WHERE email = 'minji@example.com'
-- RETURNING id, name, major, grade;
