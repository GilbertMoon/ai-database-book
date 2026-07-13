-- Chapter 15. AI 튜터링 질문 관리 서비스 기준 데이터
-- 실행 전 01_schema.sql을 먼저 실행합니다.
-- 이전 시퀀스 상태를 가정하지 않도록 명시적 ID와 고정 시각을 사용합니다.

SELECT current_database();

BEGIN;

INSERT INTO tutor_project.students (
    id, name, email, joined_at, is_active
)
VALUES
    (101, '학생A', 'student.a@example.test', DATE '2026-01-10', TRUE),
    (102, '학생B', 'student.b@example.test', DATE '2026-02-14', TRUE),
    (103, '학생C', 'student.c@example.test', DATE '2026-03-20', TRUE),
    (104, '질문없는학생', 'student.noquestion@example.test', DATE '2026-04-01', TRUE);

INSERT INTO tutor_project.tutors (
    id, name, email, specialty, is_active, created_at
)
VALUES
    (201, '튜터SQL', 'tutor.sql@example.test', 'SQL', TRUE, TIMESTAMPTZ '2026-01-05 09:00:00+09'),
    (202, '튜터설계', 'tutor.design@example.test', 'Database Design', TRUE, TIMESTAMPTZ '2026-01-05 09:10:00+09'),
    (203, '튜터검증', 'tutor.review@example.test', 'Validation', TRUE, TIMESTAMPTZ '2026-01-05 09:20:00+09');

INSERT INTO tutor_project.questions (
    id, student_id, question_code, title, body, status, created_at, updated_at
)
VALUES
(
    301, 101, 'Q-2026-001', 'JOIN과 GROUP BY 차이',
    'JOIN과 GROUP BY를 언제 쓰는지 궁금합니다.',
    'answered',
    TIMESTAMPTZ '2026-07-01 10:00:00+09',
    TIMESTAMPTZ '2026-07-01 11:00:00+09'
),
(
    302, 101, 'Q-2026-002', 'ERD 관계 질문',
    '질문과 학습 자료 관계를 어떻게 표현하나요?',
    'answered',
    TIMESTAMPTZ '2026-07-02 10:00:00+09',
    TIMESTAMPTZ '2026-07-02 12:00:00+09'
),
(
    303, 102, 'Q-2026-003', '트랜잭션 오류 처리',
    '여러 INSERT 중 하나가 실패하면 어떻게 하나요?',
    'open',
    TIMESTAMPTZ '2026-07-03 10:00:00+09',
    TIMESTAMPTZ '2026-07-03 10:00:00+09'
),
(
    304, 103, 'Q-2026-004', '인덱스 후보 검토',
    '질문 목록 조회에 어떤 인덱스를 고려해야 하나요?',
    'answered',
    TIMESTAMPTZ '2026-07-04 10:00:00+09',
    TIMESTAMPTZ '2026-07-04 13:00:00+09'
),
(
    305, 103, 'Q-2026-005', '닫힌 질문 예시',
    '이미 해결된 질문입니다.',
    'closed',
    TIMESTAMPTZ '2026-07-05 10:00:00+09',
    TIMESTAMPTZ '2026-07-05 14:00:00+09'
);

INSERT INTO tutor_project.answers (
    id, question_id, tutor_id, answer_body, created_at
)
VALUES
(
    401, 301, 201,
    'JOIN은 테이블을 연결하고 GROUP BY는 집계 단위를 만듭니다.',
    TIMESTAMPTZ '2026-07-01 10:30:00+09'
),
(
    402, 301, 203,
    '실제 요구사항을 쿼리로 검증하면서 두 개념을 비교해 보세요.',
    TIMESTAMPTZ '2026-07-01 10:50:00+09'
),
(
    403, 302, 202,
    '질문과 자료는 N:M이므로 연결 테이블을 둡니다.',
    TIMESTAMPTZ '2026-07-02 11:30:00+09'
),
(
    404, 304, 201,
    'WHERE, JOIN, ORDER BY 패턴과 실행 계획을 기준으로 인덱스를 검토합니다.',
    TIMESTAMPTZ '2026-07-04 12:30:00+09'
),
(
    405, 305, 203,
    '닫힌 질문의 추가 답변 허용 여부는 별도 정책이 필요합니다.',
    TIMESTAMPTZ '2026-07-05 13:30:00+09'
);

INSERT INTO tutor_project.learning_materials (
    id, material_code, title, material_type, content_summary,
    source_url, access_scope, source_version, content_hash,
    is_active, updated_at
)
VALUES
(
    501, 'MAT-JOIN-01', 'JOIN 기본 문서', 'article',
    'JOIN의 목적과 INNER JOIN, LEFT JOIN의 기본 사용법을 설명합니다.',
    'https://example.test/join', 'public', 'v1', 'sha256-demo-join-v1', TRUE,
    TIMESTAMPTZ '2026-06-01 09:00:00+09'
),
(
    502, 'MAT-GROUP-01', 'GROUP BY 실습', 'document',
    'GROUP BY와 집계 함수, HAVING을 사용하는 실습 자료입니다.',
    'https://example.test/group-by', 'public', 'v1', 'sha256-demo-group-v1', TRUE,
    TIMESTAMPTZ '2026-06-02 09:00:00+09'
),
(
    503, 'MAT-ERD-01', 'ERD 관계 설명', 'article',
    '1:N과 N:M 관계를 연결 테이블로 표현하는 방법을 설명합니다.',
    'https://example.test/erd', 'public', 'v1', 'sha256-demo-erd-v1', TRUE,
    TIMESTAMPTZ '2026-06-03 09:00:00+09'
),
(
    504, 'MAT-TX-01', '트랜잭션 영상', 'video',
    'COMMIT, ROLLBACK과 원자성을 설명하는 내부 교육 영상입니다.',
    'https://example.test/transaction', 'internal', 'v1', 'sha256-demo-tx-v1', TRUE,
    TIMESTAMPTZ '2026-06-04 09:00:00+09'
),
(
    505, 'MAT-IDX-01', '인덱스 체크리스트', 'document',
    '반복 쿼리와 실행 계획을 기준으로 인덱스 후보를 평가합니다.',
    'https://example.test/index', 'public', 'v1', 'sha256-demo-index-v1', TRUE,
    TIMESTAMPTZ '2026-06-05 09:00:00+09'
),
(
    506, 'MAT-OLD-01', '연결되지 않은 과거 자료', 'quiz',
    '현재 프로젝트와 연결되지 않은 비활성 예제 자료입니다.',
    'https://example.test/orphan', 'public', 'v1', 'sha256-demo-old-v1', FALSE,
    TIMESTAMPTZ '2026-05-01 09:00:00+09'
);

INSERT INTO tutor_project.question_materials (
    question_id, material_id, display_order, note, created_at
)
VALUES
    (301, 501, 1, 'JOIN 복습', TIMESTAMPTZ '2026-07-01 11:00:00+09'),
    (301, 502, 2, '집계 실습', TIMESTAMPTZ '2026-07-01 11:00:00+09'),
    (302, 503, 1, '관계 설명', TIMESTAMPTZ '2026-07-02 12:00:00+09'),
    (303, 504, 1, '트랜잭션 개념', TIMESTAMPTZ '2026-07-03 10:30:00+09'),
    (304, 505, 1, '성능 후보', TIMESTAMPTZ '2026-07-04 13:00:00+09'),
    (305, 501, 1, '복습 자료', TIMESTAMPTZ '2026-07-05 14:00:00+09'),
    (305, 503, 2, '추가 자료', TIMESTAMPTZ '2026-07-05 14:00:00+09');

COMMIT;

SELECT
    (SELECT COUNT(*) FROM tutor_project.students) AS students_expected_4,
    (SELECT COUNT(*) FROM tutor_project.tutors) AS tutors_expected_3,
    (SELECT COUNT(*) FROM tutor_project.questions) AS questions_expected_5,
    (SELECT COUNT(*) FROM tutor_project.answers) AS answers_expected_5,
    (SELECT COUNT(*) FROM tutor_project.learning_materials) AS materials_expected_6,
    (SELECT COUNT(*) FROM tutor_project.question_materials) AS links_expected_7;
