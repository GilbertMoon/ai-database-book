-- Chapter 09 선택 실습. 오류 상태와 SAVEPOINT 복구
-- 실행 전 01→06 주 실습을 완료합니다.
-- 오류를 의도적으로 발생시키는 문장은 기본 주석 상태입니다.
-- 같은 DBeaver 연결에서 번호 순서대로 한 구간씩 선택 실행합니다.

SELECT current_database();
SELECT current_schema();
SHOW search_path;

-- 사전 상태: 학생 101은 강의 301을 이미 수강중이며 remaining_seats는 1입니다.
SELECT
    e.id,
    e.student_id,
    e.course_id,
    e.status,
    ci.remaining_seats
FROM transaction_lab.enrollments AS e
JOIN transaction_lab.course_inventory AS ci
    ON ci.course_id = e.course_id
WHERE e.id = 9001;

-- ============================================================
-- 1. 트랜잭션과 SAVEPOINT 시작
-- 아래 두 문장을 선택 실행합니다.
-- ============================================================
-- BEGIN;
-- SAVEPOINT before_duplicate_enrollment;

-- ============================================================
-- 2. SAVEPOINT 이후 임시 좌석 차감
-- ============================================================
-- UPDATE transaction_lab.course_inventory
-- SET remaining_seats = remaining_seats - 1
-- WHERE course_id = 301
--   AND remaining_seats > 0
-- RETURNING *;

-- ============================================================
-- 3. 중복 활성 신청 오류 유발
-- uq_transaction_enrollments_active 오류가 발생해야 정상입니다.
-- 오류 후 일반 SQL은 current transaction is aborted 메시지로 거부될 수 있습니다.
-- ============================================================
-- INSERT INTO transaction_lab.enrollments (
--     id, student_id, course_id,
--     enrolled_at, status, paid_amount
-- )
-- VALUES (
--     9003, 101, 301,
--     CURRENT_TIMESTAMP, '수강중', 100000
-- );

-- ============================================================
-- 4. 오류가 발생한 뒤 SAVEPOINT까지 복구
-- ROLLBACK TO SAVEPOINT는 SAVEPOINT 이후의 좌석 차감과 실패 시도를 되돌립니다.
-- ============================================================
-- ROLLBACK TO SAVEPOINT before_duplicate_enrollment;

-- SELECT *
-- FROM transaction_lab.course_inventory
-- WHERE course_id = 301;

-- SELECT *
-- FROM transaction_lab.enrollments
-- WHERE id = 9003;

-- 기대 결과:
-- course 301 remaining_seats = 1
-- enrollment 9003 = 0행

-- ============================================================
-- 5. SAVEPOINT 정리와 전체 트랜잭션 종료
-- ============================================================
-- RELEASE SAVEPOINT before_duplicate_enrollment;
-- ROLLBACK;

-- SAVEPOINT가 없다면 오류 상태의 전체 트랜잭션을 다음처럼 종료합니다.
-- ROLLBACK;

-- 이 선택 실습은 최종 기준 데이터를 변경하지 않아야 합니다.
