-- Chapter 05 호환 파일: 03_library_validation.sql과 같은 역할
-- 기존 링크와 강의 자료 호환을 위해 유지합니다.
-- 이 파일은 데이터를 변경하지 않으므로 반복 실행할 수 있습니다.

SELECT current_database();
SELECT current_user;
SELECT current_schema();
SHOW search_path;

DO $$
DECLARE
    v_member_count bigint;
    v_book_count bigint;
    v_loan_count bigint;
    v_open_loan_count bigint;
    v_orphan_member_count bigint;
    v_orphan_book_count bigint;
    v_member_101_count bigint;
    v_book_201_count bigint;
    v_book_201_invalid_order bigint;
BEGIN
    IF current_database() <> 'ai_database_book' THEN
        RAISE EXCEPTION
            '검증 중단: 현재 데이터베이스는 %입니다. ai_database_book에 연결하세요.',
            current_database();
    END IF;

    IF to_regclass('public.members') IS NULL
       OR to_regclass('public.books') IS NULL
       OR to_regclass('public.loans') IS NULL THEN
        RAISE EXCEPTION
            '검증 중단: Chapter 05 테이블이 모두 존재하지 않습니다.';
    END IF;

    SELECT COUNT(*) INTO v_member_count FROM public.members;
    SELECT COUNT(*) INTO v_book_count FROM public.books;
    SELECT COUNT(*) INTO v_loan_count FROM public.loans;

    SELECT COUNT(*) INTO v_open_loan_count
    FROM public.loans
    WHERE returned_at IS NULL;

    SELECT COUNT(*) INTO v_orphan_member_count
    FROM public.loans AS l
    LEFT JOIN public.members AS m ON l.member_id = m.id
    WHERE m.id IS NULL;

    SELECT COUNT(*) INTO v_orphan_book_count
    FROM public.loans AS l
    LEFT JOIN public.books AS b ON l.book_id = b.id
    WHERE b.id IS NULL;

    SELECT COUNT(*) INTO v_member_101_count
    FROM public.loans
    WHERE member_id = 101;

    SELECT COUNT(*) INTO v_book_201_count
    FROM public.loans
    WHERE book_id = 201;

    SELECT COUNT(*) INTO v_book_201_invalid_order
    FROM public.loans AS earlier
    JOIN public.loans AS later
        ON earlier.book_id = later.book_id
       AND earlier.borrowed_at < later.borrowed_at
    WHERE earlier.book_id = 201
      AND earlier.returned_at IS NOT NULL
      AND earlier.returned_at >= later.borrowed_at;

    IF v_member_count <> 3
       OR v_book_count <> 3
       OR v_loan_count <> 4
       OR v_open_loan_count <> 3
       OR v_orphan_member_count <> 0
       OR v_orphan_book_count <> 0
       OR v_member_101_count <> 2
       OR v_book_201_count <> 2
       OR v_book_201_invalid_order <> 0 THEN
        RAISE EXCEPTION
            '검증 실패: members=%, books=%, loans=%, open=%, orphan_member=%, orphan_book=%, member101=%, book201=%, invalid_order=%',
            v_member_count,
            v_book_count,
            v_loan_count,
            v_open_loan_count,
            v_orphan_member_count,
            v_orphan_book_count,
            v_member_101_count,
            v_book_201_count,
            v_book_201_invalid_order;
    END IF;

    RAISE NOTICE 'Chapter 05 library model validation passed';
END
$$;

SELECT id, name, email, joined_at
FROM public.members
ORDER BY id;

SELECT id, title, author, published_year, isbn
FROM public.books
ORDER BY id;

SELECT id, member_id, book_id, borrowed_at, due_at, returned_at
FROM public.loans
ORDER BY id;

SELECT
    l.id AS loan_id,
    m.name AS member_name,
    b.title AS book_title,
    l.borrowed_at,
    l.due_at,
    l.returned_at
FROM public.loans AS l
JOIN public.members AS m ON l.member_id = m.id
JOIN public.books AS b ON l.book_id = b.id
ORDER BY l.id;

SELECT id, member_id, book_id, borrowed_at, due_at
FROM public.loans
WHERE returned_at IS NULL
ORDER BY due_at, id;

SELECT id, member_id, book_id, borrowed_at, returned_at
FROM public.loans
WHERE member_id = 101
ORDER BY borrowed_at, id;

SELECT id, member_id, borrowed_at, due_at, returned_at
FROM public.loans
WHERE book_id = 201
ORDER BY borrowed_at, id;

SELECT
    (SELECT COUNT(*) FROM public.members) AS member_count,
    (SELECT COUNT(*) FROM public.books) AS book_count,
    (SELECT COUNT(*) FROM public.loans) AS loan_count,
    (SELECT COUNT(*) FROM public.loans WHERE returned_at IS NULL) AS open_loan_count,
    (SELECT COUNT(*) FROM public.loans WHERE member_id = 101) AS member_101_loan_count,
    (SELECT COUNT(*) FROM public.loans WHERE book_id = 201) AS book_201_loan_count,
    (
        SELECT COUNT(*)
        FROM public.loans AS l
        LEFT JOIN public.members AS m ON l.member_id = m.id
        WHERE m.id IS NULL
    ) AS orphan_member_reference_count,
    (
        SELECT COUNT(*)
        FROM public.loans AS l
        LEFT JOIN public.books AS b ON l.book_id = b.id
        WHERE b.id IS NULL
    ) AS orphan_book_reference_count;
