-- Chapter 15. 요구사항별 업무 조회와 정합성 검증
-- 실행 전 01→03 파일을 실행합니다.
-- 데이터를 변경하지 않습니다.

SELECT current_database();

-- REQ-01: 학생과 질문 연결, 기대 5행
SELECT
    q.id AS question_id,
    q.question_code,
    s.id AS student_id,
    s.name AS student_name,
    s.email,
    q.title,
    q.status,
    q.created_at
FROM tutor_project.questions AS q
JOIN tutor_project.students AS s
    ON s.id = q.student_id
ORDER BY q.id;

-- REQ-05: 질문별 답변 수, 기대 5행
SELECT
    q.id AS question_id,
    q.question_code,
    q.title,
    q.status,
    COUNT(a.id) AS answer_count
FROM tutor_project.questions AS q
LEFT JOIN tutor_project.answers AS a
    ON a.question_id = q.id
GROUP BY q.id, q.question_code, q.title, q.status
ORDER BY q.id;

-- REQ-06: 답변과 튜터 연결, 기대 5행
SELECT
    a.id AS answer_id,
    q.question_code,
    q.title,
    t.name AS tutor_name,
    t.specialty,
    a.answer_body,
    a.created_at
FROM tutor_project.answers AS a
JOIN tutor_project.questions AS q
    ON q.id = a.question_id
JOIN tutor_project.tutors AS t
    ON t.id = a.tutor_id
ORDER BY a.id;

-- REQ-07·10: 질문과 학습 자료 N:M 및 표시 순서, 기대 7행
SELECT
    q.question_code,
    q.title AS question_title,
    m.material_code,
    m.title AS material_title,
    m.material_type,
    m.access_scope,
    m.is_active,
    qm.display_order,
    qm.note
FROM tutor_project.question_materials AS qm
JOIN tutor_project.questions AS q
    ON q.id = qm.question_id
JOIN tutor_project.learning_materials AS m
    ON m.id = qm.material_id
ORDER BY q.id, qm.display_order;

-- REQ-08: 질문이 없는 학생, 기대 1행
SELECT
    s.id,
    s.name,
    s.email,
    COUNT(q.id) AS question_count
FROM tutor_project.students AS s
LEFT JOIN tutor_project.questions AS q
    ON q.student_id = s.id
GROUP BY s.id, s.name, s.email
HAVING COUNT(q.id) = 0
ORDER BY s.id;

-- REQ-09: 연결되지 않은 자료, 기대 1행
SELECT
    m.id,
    m.material_code,
    m.title,
    m.is_active,
    COUNT(qm.question_id) AS linked_question_count
FROM tutor_project.learning_materials AS m
LEFT JOIN tutor_project.question_materials AS qm
    ON qm.material_id = m.id
GROUP BY m.id, m.material_code, m.title, m.is_active
HAVING COUNT(qm.question_id) = 0
ORDER BY m.id;

-- REQ-11: 활성 public 자료
SELECT
    material_code,
    title,
    material_type,
    access_scope,
    source_version,
    updated_at
FROM tutor_project.learning_materials
WHERE is_active = TRUE
  AND access_scope = 'public'
ORDER BY material_code;

-- 경계 사례 확인
SELECT
    COUNT(*) FILTER (
        WHERE answer_count = 0 AND status = 'open'
    ) AS open_without_answer_expected_1,
    COUNT(*) FILTER (
        WHERE answer_count = 2
    ) AS two_answer_question_expected_1
FROM (
    SELECT
        q.id,
        q.status,
        COUNT(a.id) AS answer_count
    FROM tutor_project.questions AS q
    LEFT JOIN tutor_project.answers AS a
        ON a.question_id = q.id
    GROUP BY q.id, q.status
) AS counts;

-- 정합성 1: 고아 질문, 기대 0행
SELECT q.*
FROM tutor_project.questions AS q
LEFT JOIN tutor_project.students AS s
    ON s.id = q.student_id
WHERE s.id IS NULL;

-- 정합성 2: 고아 답변 또는 튜터, 기대 0행
SELECT a.*
FROM tutor_project.answers AS a
LEFT JOIN tutor_project.questions AS q
    ON q.id = a.question_id
LEFT JOIN tutor_project.tutors AS t
    ON t.id = a.tutor_id
WHERE q.id IS NULL OR t.id IS NULL;

-- 정합성 3: 고아 질문·자료 연결, 기대 0행
SELECT qm.*
FROM tutor_project.question_materials AS qm
LEFT JOIN tutor_project.questions AS q
    ON q.id = qm.question_id
LEFT JOIN tutor_project.learning_materials AS m
    ON m.id = qm.material_id
WHERE q.id IS NULL OR m.id IS NULL;

-- 정합성 4: answered인데 답변 없음, 기대 0행
SELECT
    q.id,
    q.question_code,
    q.title
FROM tutor_project.questions AS q
LEFT JOIN tutor_project.answers AS a
    ON a.question_id = q.id
WHERE q.status = 'answered'
GROUP BY q.id, q.question_code, q.title
HAVING COUNT(a.id) = 0;

-- 정합성 5: 질문별 표시 순서 중복, 기대 0행
SELECT
    question_id,
    display_order,
    COUNT(*) AS duplicate_count
FROM tutor_project.question_materials
GROUP BY question_id, display_order
HAVING COUNT(*) > 1;

-- 최종 요약
SELECT
    (SELECT COUNT(*) FROM tutor_project.students) = 4 AS students_ok,
    (SELECT COUNT(*) FROM tutor_project.tutors) = 3 AS tutors_ok,
    (SELECT COUNT(*) FROM tutor_project.questions) = 5 AS questions_ok,
    (SELECT COUNT(*) FROM tutor_project.answers) = 5 AS answers_ok,
    (SELECT COUNT(*) FROM tutor_project.learning_materials) = 6 AS materials_ok,
    (SELECT COUNT(*) FROM tutor_project.question_materials) = 7 AS links_ok,
    (
        SELECT COUNT(*)
        FROM (
            SELECT s.id
            FROM tutor_project.students AS s
            LEFT JOIN tutor_project.questions AS q
                ON q.student_id = s.id
            GROUP BY s.id
            HAVING COUNT(q.id) = 0
        ) AS no_question_students
    ) = 1 AS no_question_student_ok,
    (
        SELECT COUNT(*)
        FROM (
            SELECT m.id
            FROM tutor_project.learning_materials AS m
            LEFT JOIN tutor_project.question_materials AS qm
                ON qm.material_id = m.id
            GROUP BY m.id
            HAVING COUNT(qm.question_id) = 0
        ) AS unlinked_materials
    ) = 1 AS unlinked_material_ok;

-- 모든 결과가 true여야 합니다.
