-- Chapter 15 template verification queries

-- REQ-01: 학생과 질문 연결 확인
SELECT q.id, s.email, q.title, q.status
FROM questions q
JOIN students s ON s.id = q.student_id
ORDER BY q.id;

-- REQ-05: 질문별 답변 수
SELECT q.title, COUNT(a.id) AS answer_count
FROM questions q
LEFT JOIN answers a ON a.question_id = q.id
GROUP BY q.id, q.title
ORDER BY q.id;

-- REQ-06: 답변과 튜터 연결 확인
SELECT q.title, t.name AS tutor_name, a.answer_body
FROM answers a
JOIN questions q ON q.id = a.question_id
JOIN tutors t ON t.id = a.tutor_id
ORDER BY q.id, a.id;

-- REQ-07: 질문과 학습 자료 N:M 조회
SELECT q.title AS question_title, lm.title AS material_title, qm.display_order
FROM question_materials qm
JOIN questions q ON q.id = qm.question_id
JOIN learning_materials lm ON lm.id = qm.material_id
ORDER BY q.id, qm.display_order;

-- REQ-08: 질문이 없는 학생 조회, 예상 1명
SELECT s.name, COUNT(q.id) AS question_count
FROM students s
LEFT JOIN questions q ON q.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(q.id) = 0;

-- REQ-09: 연결되지 않은 학습 자료 조회, 예상 1건
SELECT lm.title, COUNT(qm.question_id) AS linked_question_count
FROM learning_materials lm
LEFT JOIN question_materials qm ON qm.material_id = lm.id
GROUP BY lm.id, lm.title
HAVING COUNT(qm.question_id) = 0;

-- 정합성 이상 확인: 모두 0행이어야 합니다.
SELECT q.id, q.title
FROM questions q
LEFT JOIN students s ON s.id = q.student_id
WHERE s.id IS NULL;

SELECT a.id
FROM answers a
LEFT JOIN questions q ON q.id = a.question_id
LEFT JOIN tutors t ON t.id = a.tutor_id
WHERE q.id IS NULL OR t.id IS NULL;

SELECT qm.question_id, qm.material_id
FROM question_materials qm
LEFT JOIN questions q ON q.id = qm.question_id
LEFT JOIN learning_materials lm ON lm.id = qm.material_id
WHERE q.id IS NULL OR lm.id IS NULL;

-- FK 개수 확인, 예상 5개
SELECT COUNT(*) AS foreign_key_count
FROM information_schema.table_constraints
WHERE table_schema = current_schema()
  AND constraint_type = 'FOREIGN KEY'
  AND table_name IN ('questions', 'answers', 'question_materials');

-- 인덱스 후보: 실제 조회 패턴을 기준으로 검토만 합니다.
-- CREATE INDEX idx_questions_student_status_created ON questions (student_id, status, created_at DESC);
-- CREATE INDEX idx_answers_question_id ON answers (question_id);
-- CREATE INDEX idx_question_materials_material_id ON question_materials (material_id);

-- 트랜잭션 예시: 실제 반영하지 않고 ROLLBACK합니다.
BEGIN;
INSERT INTO answers (question_id, tutor_id, answer_body)
SELECT q.id, t.id, '트랜잭션 테스트 답변입니다.'
FROM questions q
CROSS JOIN tutors t
WHERE q.status = 'open'
ORDER BY q.id, t.id
LIMIT 1;
SELECT COUNT(*) AS answers_inside_transaction FROM answers;
ROLLBACK;

-- 최종 요약
SELECT 'students' AS table_name, COUNT(*) AS row_count FROM students
UNION ALL SELECT 'tutors', COUNT(*) FROM tutors
UNION ALL SELECT 'questions', COUNT(*) FROM questions
UNION ALL SELECT 'answers', COUNT(*) FROM answers
UNION ALL SELECT 'learning_materials', COUNT(*) FROM learning_materials
UNION ALL SELECT 'question_materials', COUNT(*) FROM question_materials
ORDER BY table_name;
