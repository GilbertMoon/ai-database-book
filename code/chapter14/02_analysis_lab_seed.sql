-- Chapter 14. SQL 데이터 분석과 Python 확장
-- 목적: 기간·상태·지역·강의별 분석이 가능한 기준 데이터를 입력합니다.
-- 실행 전 01_analysis_lab_schema.sql을 먼저 실행합니다.
-- 명시적 ID를 사용해 이전 시퀀스 상태에 의존하지 않습니다.

INSERT INTO analysis_lab.students (id, name, region, joined_at)
VALUES
    (101, '김민지', '서울', '2026-01-05'),
    (102, '이준호', '경기', '2026-01-12'),
    (103, '박서연', '부산', '2026-02-02'),
    (104, '최유진', '서울', '2026-02-15'),
    (105, '정우성', '대구', '2026-03-01'),
    (106, '한지민', '경기', '2026-03-10'),
    (107, '윤서준', '부산', '2026-04-05'),
    (108, '강하늘', '서울', '2026-05-01');

INSERT INTO analysis_lab.instructors (id, name, specialty)
VALUES
    (201, '문길래', 'Database'),
    (202, '홍길동', 'Python'),
    (203, '김하나', 'Data Analysis');

INSERT INTO analysis_lab.courses (
    id,
    instructor_id,
    title,
    category,
    level,
    price,
    opened_at
)
VALUES
    (301, 201, '데이터베이스 입문', 'Database', 'basic', 100000, '2026-01-01'),
    (302, 201, 'SQL 데이터 분석', 'Database', 'intermediate', 130000, '2026-02-01'),
    (303, 202, '파이썬 데이터 분석', 'Python', 'basic', 150000, '2026-01-15'),
    (304, 203, '데이터 시각화', 'Data Analysis', 'intermediate', 140000, '2026-02-15'),
    (305, 203, 'AI 활용 데이터 설계', 'AI', 'intermediate', 160000, '2026-03-01');

INSERT INTO analysis_lab.enrollments (
    id,
    student_id,
    course_id,
    enrolled_at,
    status,
    paid_amount,
    completed_at
)
VALUES
    (1001, 101, 301, '2026-01-10', '완료',   100000, '2026-01-30'),
    (1002, 102, 301, '2026-01-18', '완료',   100000, '2026-02-05'),
    (1003, 101, 303, '2026-01-25', '취소',        0, NULL),

    (1004, 103, 301, '2026-02-05', '완료',   100000, '2026-02-28'),
    (1005, 104, 302, '2026-02-12', '수강중', 130000, NULL),
    (1006, 102, 303, '2026-02-20', '완료',   150000, '2026-03-20'),
    (1007, 103, 304, '2026-02-25', '신청',   140000, NULL),

    (1008, 105, 301, '2026-03-03', '완료',   100000, '2026-03-28'),
    (1009, 106, 302, '2026-03-08', '완료',   130000, '2026-04-05'),
    (1010, 104, 303, '2026-03-15', '완료',   150000, '2026-04-20'),
    (1011, 105, 304, '2026-03-22', '취소',        0, NULL),
    (1012, 101, 305, '2026-03-28', '수강중', 160000, NULL),

    (1013, 107, 301, '2026-04-08', '완료',   100000, '2026-05-01'),
    (1014, 106, 303, '2026-04-12', '수강중', 150000, NULL),
    (1015, 107, 304, '2026-04-18', '완료',   140000, '2026-05-15'),
    (1016, 103, 305, '2026-04-25', '신청',   160000, NULL),

    (1017, 108, 301, '2026-05-03', '수강중', 100000, NULL),
    (1018, 104, 302, '2026-05-10', '완료',   130000, '2026-06-01'),
    (1019, 108, 303, '2026-05-17', '취소',        0, NULL),
    (1020, 105, 305, '2026-05-24', '완료',   160000, '2026-06-20'),

    (1021, 107, 302, '2026-06-02', '신청',   130000, NULL),
    (1022, 108, 304, '2026-06-08', '완료',   140000, '2026-07-01'),
    (1023, 102, 305, '2026-06-15', '수강중', 160000, NULL),
    (1024, 106, 304, '2026-06-22', '신청',   140000, NULL);

-- 명시적 ID 이후 자동 생성 ID가 충돌하지 않도록 시퀀스를 맞춥니다.
SELECT setval(
    pg_get_serial_sequence('analysis_lab.students', 'id'),
    (SELECT MAX(id) FROM analysis_lab.students),
    true
);

SELECT setval(
    pg_get_serial_sequence('analysis_lab.instructors', 'id'),
    (SELECT MAX(id) FROM analysis_lab.instructors),
    true
);

SELECT setval(
    pg_get_serial_sequence('analysis_lab.courses', 'id'),
    (SELECT MAX(id) FROM analysis_lab.courses),
    true
);

SELECT setval(
    pg_get_serial_sequence('analysis_lab.enrollments', 'id'),
    (SELECT MAX(id) FROM analysis_lab.enrollments),
    true
);

-- 기대 행 수:
-- students 8, instructors 3, courses 5, enrollments 24
-- 상태별: 완료 12, 수강중 5, 신청 4, 취소 3
-- 결제금액 합계: 2,770,000
