-- Chapter 04. 02 샘플 학생 데이터 입력
-- 시작 상태: public.students 테이블이 존재하고 0행
-- 완료 상태: 샘플 학생 6명
-- 반복 실행: 중복 이메일 오류를 방지하기 위해 한 번만 실행합니다.

DO $$
DECLARE
    v_count bigint;
BEGIN
    IF to_regclass('public.students') IS NULL THEN
        RAISE EXCEPTION
            '입력 중단: public.students가 없습니다. 01_create_students.sql을 먼저 실행하세요.';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM public.students;

    IF v_count <> 0 THEN
        RAISE EXCEPTION
            '입력 중단: public.students에 이미 %행이 있습니다. 현재 상태를 확인하세요.',
            v_count;
    END IF;
END
$$;

-- 단일 행 입력과 자동값 확인
INSERT INTO public.students (name, email, major, grade)
VALUES ('김민지', 'minji@example.com', '컴퓨터공학', 2)
RETURNING id, name, created_at;

-- 여러 행 입력
INSERT INTO public.students (name, email, major, grade)
VALUES
    ('이준호', 'junho@example.com', '데이터사이언스', 3),
    ('박서연', 'seoyeon@example.com', '경영학', 1),
    ('최현우', 'hyunwoo@example.com', '컴퓨터공학', 4),
    ('정하늘', 'haneul@example.com', 'AI데이터공학', 2)
RETURNING id, name, major, grade;

-- 선택값을 생략해 NULL 확인
INSERT INTO public.students (name, email)
VALUES ('윤서진', 'seojin@example.com')
RETURNING id, name, major, grade, created_at;

-- 초기 데이터 상태 확인
SELECT COUNT(*) AS student_count
FROM public.students;

SELECT id, name, email, major, grade, created_at
FROM public.students
ORDER BY id ASC;
