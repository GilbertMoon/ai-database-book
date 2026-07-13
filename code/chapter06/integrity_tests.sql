-- Chapter 06. 데이터 무결성 오류 테스트
-- 목적: 잘못된 값과 관계가 각 제약조건에 의해 차단되는지 확인합니다.
-- 실행 전 normalization_schema.sql과 normalization_seed.sql을 실행합니다.
--
-- 중요:
-- 아래 오류 SQL은 모두 주석 처리되어 있습니다.
-- 한 번에 하나의 SQL만 주석 해제해 실행하고 오류 메시지를 확인합니다.
-- 오류가 발생해야 정상인 테스트입니다.

-- ============================================================
-- 0. 현재 실행 위치와 기존 행 수 확인
-- ============================================================
SELECT current_database();
SELECT current_schema();
SELECT COUNT(*) AS member_count_before FROM members_nf;
SELECT COUNT(*) AS book_count_before FROM books_nf;
SELECT COUNT(*) AS loan_count_before FROM loans_nf;

-- ============================================================
-- 테스트 1. NOT NULL 위반
-- 기대 결과: name의 NOT NULL 제약조건 오류
-- ============================================================
-- INSERT INTO members_nf (id, name, email, joined_at)
-- VALUES (1901, NULL, 'null-name@example.com', '2026-03-20');

-- ============================================================
-- 테스트 2. UNIQUE 위반
-- 기대 결과: email의 UNIQUE 제약조건 오류
-- ============================================================
-- INSERT INTO members_nf (id, name, email, joined_at)
-- VALUES (1902, '중복 이메일 회원', 'minji@example.com', '2026-03-20');

-- ============================================================
-- 테스트 3. CHECK 위반: 공백 이름
-- 기대 결과: chk_members_nf_name_not_blank 오류
-- ============================================================
-- INSERT INTO members_nf (id, name, email, joined_at)
-- VALUES (1903, '   ', 'blank-name@example.com', '2026-03-20');

-- ============================================================
-- 테스트 4. FOREIGN KEY 위반
-- 기대 결과: 존재하지 않는 member_id 999 참조 오류
-- ============================================================
-- INSERT INTO loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1904, 999, 201,
--     '2026-04-10', '2026-04-24', NULL
-- );

-- ============================================================
-- 테스트 5. CHECK 위반: 잘못된 반납예정일
-- 기대 결과: chk_loans_nf_due_date 오류
-- ============================================================
-- INSERT INTO loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1905, 101, 201,
--     '2026-04-20', '2026-04-10', NULL
-- );

-- ============================================================
-- 테스트 6. CHECK 위반: 실제반납일이 대여일보다 빠름
-- 기대 결과: chk_loans_nf_returned_date 오류
-- ============================================================
-- INSERT INTO loans_nf (
--     id, member_id, book_id,
--     borrowed_at, due_at, returned_at
-- )
-- VALUES (
--     1906, 101, 201,
--     '2026-04-20', '2026-05-04', '2026-04-10'
-- );

-- ============================================================
-- 테스트 7. 참조 중인 부모 삭제
-- 기대 결과: ON DELETE RESTRICT 또는 외래키 오류
-- 회원 101은 loans_nf에서 참조 중입니다.
-- ============================================================
-- DELETE FROM members_nf
-- WHERE id = 101;

-- ============================================================
-- 테스트 8. 참조되지 않는 부모는 삭제 가능
-- 정상 동작을 확인하는 선택 테스트입니다.
-- 아래 INSERT와 DELETE를 두 문장 함께 선택 실행할 수 있습니다.
-- ============================================================
-- INSERT INTO members_nf (id, name, email, joined_at)
-- VALUES (1908, '미대여 회원', 'unused@example.com', '2026-03-20');
--
-- DELETE FROM members_nf
-- WHERE id = 1908;

-- ============================================================
-- 오류 테스트 후 기존 데이터가 유지되는지 확인
-- 기대 결과: 정상 샘플 행 수가 변하지 않음
-- ============================================================
SELECT COUNT(*) AS member_count_after FROM members_nf;
SELECT COUNT(*) AS book_count_after FROM books_nf;
SELECT COUNT(*) AS loan_count_after FROM loans_nf;

SELECT * FROM members_nf ORDER BY id;
SELECT * FROM loans_nf ORDER BY id;
