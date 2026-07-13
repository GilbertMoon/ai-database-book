-- Chapter 13. 정상 경로와 업무 정합성 검증
-- 실행 전 01→05 파일을 순서대로 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_database();

-- 1. 기준 행 수
SELECT
    (SELECT COUNT(*) FROM ai_review_lab.bad_enrollments)
        AS bad_rows_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.students)
        AS students_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.instructors)
        AS instructors_expected_2,
    (SELECT COUNT(*) FROM ai_review_lab.courses)
        AS courses_expected_3,
    (SELECT COUNT(*) FROM ai_review_lab.enrollments)
        AS enrollments_expected_4,
    (SELECT COUNT(*) FROM ai_review_lab.payments)
        AS payments_expected_4;

-- 2. 정상 JOIN: 기대 4행
SELECT
    e.id AS enrollment_id,
    s.id AS student_id,
    s.name AS student_name,
    s.email AS student_email,
    c.id AS course_id,
    c.course_code,
    c.title AS course_title,
    c.price AS current_course_price,
    i.name AS instructor_name,
    e.status AS enrollment_status,
    e.agreed_amount,
    p.payment_status,
    p.amount AS payment_amount,
    p.paid_at,
    p.payment_reference
FROM ai_review_lab.enrollments AS e
JOIN ai_review_lab.students AS s
    ON s.id = e.student_id
JOIN ai_review_lab.courses AS c
    ON c.id = e.course_id
JOIN ai_review_lab.instructors AS i
    ON i.id = c.instructor_id
LEFT JOIN ai_review_lab.payments AS p
    ON p.enrollment_id = e.id
ORDER BY e.id;

-- 3. 학생 이메일 중복: 기대 0행
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM ai_review_lab.students
GROUP BY email
HAVING COUNT(*) > 1;

-- 4. 강사 이메일 중복: 기대 0행
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM ai_review_lab.instructors
GROUP BY email
HAVING COUNT(*) > 1;

-- 5. 신청 합의 금액과 결제금액 불일치: 기대 0행
SELECT
    e.id AS enrollment_id,
    e.agreed_amount,
    p.amount AS payment_amount
FROM ai_review_lab.enrollments AS e
JOIN ai_review_lab.payments AS p
    ON p.enrollment_id = e.id
WHERE e.agreed_amount <> p.amount;

-- 6. 결제완료·환불인데 paid_at 없음: 기대 0행
SELECT
    id,
    enrollment_id,
    payment_status,
    paid_at
FROM ai_review_lab.payments
WHERE payment_status IN ('결제완료', '환불')
  AND paid_at IS NULL;

-- 7. 결제대기·결제실패인데 paid_at 존재: 기대 0행
SELECT
    id,
    enrollment_id,
    payment_status,
    paid_at
FROM ai_review_lab.payments
WHERE payment_status IN ('결제대기', '결제실패')
  AND paid_at IS NOT NULL;

-- 8. 고아 학생 참조: 기대 0행
SELECT e.*
FROM ai_review_lab.enrollments AS e
LEFT JOIN ai_review_lab.students AS s
    ON s.id = e.student_id
WHERE s.id IS NULL;

-- 9. 고아 강의 참조: 기대 0행
SELECT e.*
FROM ai_review_lab.enrollments AS e
LEFT JOIN ai_review_lab.courses AS c
    ON c.id = e.course_id
WHERE c.id IS NULL;

-- 10. 고아 결제 참조: 기대 0행
SELECT p.*
FROM ai_review_lab.payments AS p
LEFT JOIN ai_review_lab.enrollments AS e
    ON e.id = p.enrollment_id
WHERE e.id IS NULL;

-- 11. 이 장의 단순 샘플 상태 조합 위반: 기대 0행
-- 완료→결제완료, 신청→결제대기, 취소→환불을 사용합니다.
SELECT
    e.id AS enrollment_id,
    e.status AS enrollment_status,
    p.payment_status
FROM ai_review_lab.enrollments AS e
LEFT JOIN ai_review_lab.payments AS p
    ON p.enrollment_id = e.id
WHERE
    (e.status = '완료' AND p.payment_status <> '결제완료')
    OR (e.status = '신청' AND p.payment_status <> '결제대기')
    OR (e.status = '취소' AND p.payment_status <> '환불');

-- 12. 현재 강의 가격과 신청 시점 금액 차이: 정보용, 기대 1행
-- 결과가 있어도 할인·가격 변경일 수 있으므로 자동 오류로 판정하지 않습니다.
SELECT
    e.id AS enrollment_id,
    c.course_code,
    c.price AS current_course_price,
    e.agreed_amount
FROM ai_review_lab.enrollments AS e
JOIN ai_review_lab.courses AS c
    ON c.id = e.course_id
WHERE c.price <> e.agreed_amount
ORDER BY e.id;

-- 13. 최종 boolean 요약
SELECT
    (SELECT COUNT(*) FROM ai_review_lab.bad_enrollments) = 3
        AS bad_rows_ok,
    (SELECT COUNT(*) FROM ai_review_lab.students) = 3
        AS students_ok,
    (SELECT COUNT(*) FROM ai_review_lab.instructors) = 2
        AS instructors_ok,
    (SELECT COUNT(*) FROM ai_review_lab.courses) = 3
        AS courses_ok,
    (SELECT COUNT(*) FROM ai_review_lab.enrollments) = 4
        AS enrollments_ok,
    (SELECT COUNT(*) FROM ai_review_lab.payments) = 4
        AS payments_ok,
    (
        SELECT COUNT(*)
        FROM ai_review_lab.enrollments AS e
        JOIN ai_review_lab.students AS s ON s.id = e.student_id
        JOIN ai_review_lab.courses AS c ON c.id = e.course_id
        JOIN ai_review_lab.instructors AS i ON i.id = c.instructor_id
        LEFT JOIN ai_review_lab.payments AS p ON p.enrollment_id = e.id
    ) = 4 AS joined_rows_ok,
    NOT EXISTS (
        SELECT 1
        FROM ai_review_lab.enrollments AS e
        JOIN ai_review_lab.payments AS p ON p.enrollment_id = e.id
        WHERE e.agreed_amount <> p.amount
    ) AS payment_amounts_ok;

-- 모든 결과가 true여야 합니다.
