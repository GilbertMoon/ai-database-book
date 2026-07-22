-- Chapter 06. 정규화 전후 정상 샘플 데이터
-- 실행 전 normalization_schema.sql을 먼저 실행합니다.
-- 관계를 명확히 재현하기 위해 명시적인 실습 ID를 사용합니다.
-- 명시적 ID 입력은 IDENTITY의 다음 값을 자동으로 바꾸지 않으므로 마지막에 시작값을 조정합니다.
-- 자동 커밋 상태에서는 일부 INSERT만 반영될 수 있으므로 실행 후 practice 파일로 확인합니다.

-- ============================================================
-- 0. 현재 실행 위치 확인
-- 기대 결과: ai_database_book / public
-- ============================================================
SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- ============================================================
-- 1. 정규화 전 원시 데이터 3행
-- 도서 201의 첫 대여는 4월 2일 반납된 뒤 4월 3일 다시 시작됩니다.
-- ============================================================
INSERT INTO public.library_records_raw (
    loan_id,
    member_name,
    member_email,
    book_title,
    author,
    borrowed_at,
    due_at,
    returned_at
)
VALUES
    (1001, '김민지', 'minji@example.com', '데이터베이스 입문', '문길래', '2026-04-01', '2026-04-15', '2026-04-02'),
    (1002, '김민지', 'minji@example.com', 'SQL 기초', '홍길동', '2026-04-02', '2026-04-16', NULL),
    (1003, '이준호', 'junho@example.com', '데이터베이스 입문', '문길래', '2026-04-03', '2026-04-17', NULL);

-- ============================================================
-- 2. 정규화 후 회원 2명
-- ============================================================
INSERT INTO public.members_nf (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji@example.com', '2026-03-01'),
    (102, '이준호', 'junho@example.com', '2026-03-05');

-- ============================================================
-- 3. 정규화 후 도서 2건
-- ============================================================
INSERT INTO public.books_nf (id, title, author, published_year, isbn)
VALUES
    (201, '데이터베이스 입문', '문길래', 2026, 'ISBN-001'),
    (202, 'SQL 기초', '홍길동', 2025, 'ISBN-002');

-- ============================================================
-- 4. 정규화 후 대여 기록 3건
-- 회원 101은 여러 대여 기록을 가집니다.
-- 도서 201은 시간에 따라 여러 대여 이력을 가집니다.
-- 같은 도서의 미반납 대여는 동시에 한 건만 존재합니다.
-- ============================================================
INSERT INTO public.loans_nf (
    id,
    member_id,
    book_id,
    borrowed_at,
    due_at,
    returned_at
)
VALUES
    (1001, 101, 201, '2026-04-01', '2026-04-15', '2026-04-02'),
    (1002, 101, 202, '2026-04-02', '2026-04-16', NULL),
    (1003, 102, 201, '2026-04-03', '2026-04-17', NULL);

-- ============================================================
-- 5. IDENTITY 다음 값 조정
-- 명시적 ID 입력은 연결된 IDENTITY 시퀀스를 소비하지 않습니다.
-- 이후 자동 생성값이 샘플 ID 범위와 충돌하지 않도록 조정합니다.
-- ============================================================
ALTER TABLE public.library_records_raw
    ALTER COLUMN loan_id RESTART WITH 1004;

ALTER TABLE public.members_nf
    ALTER COLUMN id RESTART WITH 103;

ALTER TABLE public.books_nf
    ALTER COLUMN id RESTART WITH 203;

ALTER TABLE public.loans_nf
    ALTER COLUMN id RESTART WITH 1004;

-- 같은 파일을 다시 실행하면 PK 또는 UNIQUE 중복 오류가 발생할 수 있습니다.
-- 처음부터 다시 시작해야 할 때만 reset_normalization.sql을 먼저 실행합니다.
