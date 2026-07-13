-- Chapter 15 template seed data
-- 고정 PK 숫자에 의존하지 않고 RETURNING 결과를 사용합니다.

BEGIN;

WITH inserted AS (
    INSERT INTO students (name, email, joined_at) VALUES
    ('학생A', 'student.a@example.test', DATE '2026-01-10'),
    ('학생B', 'student.b@example.test', DATE '2026-02-14'),
    ('학생C', 'student.c@example.test', DATE '2026-03-20'),
    ('질문없는학생', 'student.noquestion@example.test', DATE '2026-04-01')
    RETURNING id
)
SELECT COUNT(*) AS inserted_students FROM inserted;

WITH inserted AS (
    INSERT INTO tutors (name, email, specialty) VALUES
    ('튜터SQL', 'tutor.sql@example.test', 'SQL'),
    ('튜터설계', 'tutor.design@example.test', 'Database Design'),
    ('튜터검증', 'tutor.review@example.test', 'Validation')
    RETURNING id
)
SELECT COUNT(*) AS inserted_tutors FROM inserted;

WITH s AS (SELECT email, id FROM students), inserted AS (
    INSERT INTO questions (student_id, title, body, status) VALUES
    ((SELECT id FROM s WHERE email='student.a@example.test'), 'JOIN과 GROUP BY 차이', 'JOIN과 GROUP BY를 언제 쓰는지 궁금합니다.', 'answered'),
    ((SELECT id FROM s WHERE email='student.a@example.test'), 'ERD 관계 질문', '질문과 학습 자료 관계를 어떻게 표현하나요?', 'answered'),
    ((SELECT id FROM s WHERE email='student.b@example.test'), '트랜잭션 오류 처리', '여러 INSERT 중 하나가 실패하면 어떻게 하나요?', 'open'),
    ((SELECT id FROM s WHERE email='student.c@example.test'), '인덱스 후보 검토', '질문 목록 조회에 어떤 인덱스를 고려해야 하나요?', 'answered'),
    ((SELECT id FROM s WHERE email='student.c@example.test'), '닫힌 질문 예시', '이미 해결된 질문입니다.', 'closed')
    RETURNING id
)
SELECT COUNT(*) AS inserted_questions FROM inserted;

WITH q AS (SELECT title, id FROM questions), t AS (SELECT email, id FROM tutors), inserted AS (
    INSERT INTO answers (question_id, tutor_id, answer_body) VALUES
    ((SELECT id FROM q WHERE title='JOIN과 GROUP BY 차이'), (SELECT id FROM t WHERE email='tutor.sql@example.test'), 'JOIN은 테이블을 연결하고 GROUP BY는 집계 단위를 만듭니다.'),
    ((SELECT id FROM q WHERE title='JOIN과 GROUP BY 차이'), (SELECT id FROM t WHERE email='tutor.review@example.test'), '실제 요구사항을 쿼리로 검증하면서 두 개념을 비교해 보세요.'),
    ((SELECT id FROM q WHERE title='ERD 관계 질문'), (SELECT id FROM t WHERE email='tutor.design@example.test'), '질문과 자료는 N:M이므로 연결 테이블을 둡니다.'),
    ((SELECT id FROM q WHERE title='인덱스 후보 검토'), (SELECT id FROM t WHERE email='tutor.sql@example.test'), '실제 WHERE, JOIN, ORDER BY 패턴을 보고 FK 인덱스를 후보로 검토합니다.'),
    ((SELECT id FROM q WHERE title='닫힌 질문 예시'), (SELECT id FROM t WHERE email='tutor.review@example.test'), '닫힌 질문은 추가 정책이 필요합니다.')
    RETURNING id
)
SELECT COUNT(*) AS inserted_answers FROM inserted;

WITH inserted AS (
    INSERT INTO learning_materials (title, material_type, url) VALUES
    ('JOIN 기본 문서', 'article', 'https://example.test/join'),
    ('GROUP BY 실습', 'document', 'https://example.test/group-by'),
    ('ERD 관계 설명', 'article', 'https://example.test/erd'),
    ('트랜잭션 영상', 'video', 'https://example.test/transaction'),
    ('인덱스 체크리스트', 'document', 'https://example.test/index'),
    ('연결되지 않은 자료', 'quiz', 'https://example.test/orphan')
    RETURNING id
)
SELECT COUNT(*) AS inserted_learning_materials FROM inserted;

WITH q AS (SELECT title, id FROM questions), m AS (SELECT title, id FROM learning_materials), inserted AS (
    INSERT INTO question_materials (question_id, material_id, display_order, note) VALUES
    ((SELECT id FROM q WHERE title='JOIN과 GROUP BY 차이'), (SELECT id FROM m WHERE title='JOIN 기본 문서'), 1, 'JOIN 복습'),
    ((SELECT id FROM q WHERE title='JOIN과 GROUP BY 차이'), (SELECT id FROM m WHERE title='GROUP BY 실습'), 2, '집계 실습'),
    ((SELECT id FROM q WHERE title='ERD 관계 질문'), (SELECT id FROM m WHERE title='ERD 관계 설명'), 1, '관계 설명'),
    ((SELECT id FROM q WHERE title='트랜잭션 오류 처리'), (SELECT id FROM m WHERE title='트랜잭션 영상'), 1, '트랜잭션 개념'),
    ((SELECT id FROM q WHERE title='인덱스 후보 검토'), (SELECT id FROM m WHERE title='인덱스 체크리스트'), 1, '성능 후보'),
    ((SELECT id FROM q WHERE title='닫힌 질문 예시'), (SELECT id FROM m WHERE title='JOIN 기본 문서'), 1, '복습 자료'),
    ((SELECT id FROM q WHERE title='닫힌 질문 예시'), (SELECT id FROM m WHERE title='ERD 관계 설명'), 2, '추가 자료')
    RETURNING question_id
)
SELECT COUNT(*) AS inserted_question_materials FROM inserted;

COMMIT;

SELECT 'students' AS table_name, COUNT(*) AS row_count FROM students
UNION ALL SELECT 'tutors', COUNT(*) FROM tutors
UNION ALL SELECT 'questions', COUNT(*) FROM questions
UNION ALL SELECT 'answers', COUNT(*) FROM answers
UNION ALL SELECT 'learning_materials', COUNT(*) FROM learning_materials
UNION ALL SELECT 'question_materials', COUNT(*) FROM question_materials
ORDER BY table_name;

-- 선택 오류 테스트: 하나씩 주석을 해제하고 실패를 확인한 뒤 ROLLBACK하세요.
-- BEGIN;
-- INSERT INTO students (name, email, joined_at) VALUES ('중복학생', 'student.a@example.test', CURRENT_DATE);
-- ROLLBACK;
-- BEGIN;
-- INSERT INTO questions (student_id, title, body, status) VALUES (9999, '없는 학생', 'FK 오류', 'open');
-- ROLLBACK;
-- BEGIN;
-- INSERT INTO questions (student_id, title, body, status) SELECT id, '잘못된 상태', 'CHECK 오류', 'waiting' FROM students LIMIT 1;
-- ROLLBACK;
-- BEGIN;
-- INSERT INTO learning_materials (title, material_type) VALUES ('잘못된 자료', 'audio');
-- ROLLBACK;
-- BEGIN;
-- INSERT INTO question_materials (question_id, material_id, display_order) SELECT q.id, m.id, 1 FROM questions q CROSS JOIN learning_materials m LIMIT 1;
-- INSERT INTO question_materials (question_id, material_id, display_order) SELECT q.id, m.id, 2 FROM questions q CROSS JOIN learning_materials m LIMIT 1;
-- ROLLBACK;
