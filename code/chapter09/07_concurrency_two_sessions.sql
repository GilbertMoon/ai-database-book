-- Chapter 09. 두 세션 Lock 대기 실습
-- 목적: SELECT ... FOR UPDATE로 같은 좌석 행을 잠글 때의 대기를 관찰합니다.
-- 주의: 아래 트랜잭션 SQL은 실수로 대기 상태를 만들지 않도록 모두 주석 처리되어 있습니다.
-- 서로 다른 연결 세션의 DBeaver SQL Editor 두 개를 열고 필요한 블록만 선택 실행합니다.

SELECT current_database();

-- ============================================================
-- 사전 조건
-- course 303 remaining_seats가 1인지 확인합니다.
-- ============================================================
SELECT *
FROM transaction_lab.course_inventory
WHERE course_id = 303;

-- ============================================================
-- 세션 A
-- 1. 아래 BEGIN과 SELECT를 세션 A에서 실행합니다.
-- 2. COMMIT하지 않은 상태로 세션 B를 실행합니다.
-- ============================================================
-- BEGIN;
--
-- SELECT *
-- FROM transaction_lab.course_inventory
-- WHERE course_id = 303
-- FOR UPDATE;
--
-- -- 잠금을 확인하는 동안 트랜잭션을 오래 방치하지 않습니다.

-- ============================================================
-- 세션 B
-- 세션 A가 잠금을 유지한 상태에서 아래를 실행하면 대기할 수 있습니다.
-- ============================================================
-- BEGIN;
--
-- SELECT *
-- FROM transaction_lab.course_inventory
-- WHERE course_id = 303
-- FOR UPDATE;

-- ============================================================
-- 세션 A 종료
-- 변경 없이 잠금만 관찰했다면 ROLLBACK으로 종료합니다.
-- ============================================================
-- ROLLBACK;

-- ============================================================
-- 세션 B 재개 후 종료
-- A가 종료되면 B가 잠금을 얻고 최신 값을 조회합니다.
-- ============================================================
-- SELECT *
-- FROM transaction_lab.course_inventory
-- WHERE course_id = 303;
--
-- ROLLBACK;

-- ============================================================
-- 선택 확장: 세션 A가 좌석을 차감하는 경우
-- ============================================================
-- -- 세션 A
-- BEGIN;
-- SELECT *
-- FROM transaction_lab.course_inventory
-- WHERE course_id = 303
-- FOR UPDATE;
--
-- UPDATE transaction_lab.course_inventory
-- SET remaining_seats = remaining_seats - 1
-- WHERE course_id = 303
--   AND remaining_seats > 0
-- RETURNING *;
--
-- COMMIT;
--
-- -- 세션 B는 A의 COMMIT 후 최신 remaining_seats를 확인해야 합니다.
-- -- 0이면 후속 신청을 실행하지 않습니다.

-- 실습 후 course 303을 원래 상태로 되돌려야 한다면
-- 전체 transaction_lab을 reset하고 01~06 순서를 다시 실행하는 것이 가장 명확합니다.

-- Deadlock을 의도적으로 유발하는 SQL은 이 파일에 포함하지 않습니다.
-- Deadlock은 서로 다른 행을 반대 순서로 잠그는 순환 대기이며,
-- 단순히 한 잠금의 해제를 기다리는 상황과 다릅니다.
