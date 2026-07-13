-- Chapter 11. security_lab 정상 샘플 데이터
-- 실행 전 01_security_lab_schema.sql을 먼저 실행합니다.
-- 명시적 ID를 사용해 자동 증가값의 이전 상태를 가정하지 않습니다.

SELECT current_database();
SELECT current_schema();

INSERT INTO security_lab.students (id, name, email, joined_at)
VALUES
    (101, '김민지', 'minji.security@example.com', '2026-03-01'),
    (102, '이준호', 'junho.security@example.com', '2026-03-03'),
    (103, '박서연', 'seoyeon.security@example.com', '2026-03-05');

INSERT INTO security_lab.courses (id, title, level, price)
VALUES
    (201, '데이터베이스 보안 기초', 'basic', 100000),
    (202, '백업과 복구 이해', 'basic', 120000),
    (203, '권한 관리 입문', 'basic', 90000);

INSERT INTO security_lab.enrollments (
    id,
    student_id,
    course_id,
    status,
    paid_amount,
    enrolled_at
)
VALUES
    (1001, 101, 201, '수강중', 100000, '2026-04-01'),
    (1002, 102, 202, '신청', 120000, '2026-04-02'),
    (1003, 103, 203, '완료', 90000, '2026-04-03');

SELECT COUNT(*) AS student_count
FROM security_lab.students;

SELECT COUNT(*) AS course_count
FROM security_lab.courses;

SELECT COUNT(*) AS enrollment_count
FROM security_lab.enrollments;

SELECT COUNT(*) AS joined_row_count
FROM security_lab.enrollments AS e
JOIN security_lab.students AS s
    ON s.id = e.student_id
JOIN security_lab.courses AS c
    ON c.id = e.course_id;

-- 기대 결과: 3 / 3 / 3 / 3
