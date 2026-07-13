-- Chapter 15. 조회 패턴과 인덱스 검토
-- 실행 전 01→06 파일을 실행합니다.
-- 작은 데이터에서는 Seq Scan이 정상일 수 있습니다.

SELECT current_database();

-- 1. 업무 인덱스 3개 존재 확인
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'tutor_project'
  AND indexname IN (
      'idx_tutor_project_questions_student_status_created',
      'idx_tutor_project_answers_question_created',
      'idx_tutor_project_qm_material'
  )
ORDER BY indexname;

-- 2. 학생별 상태별 질문 목록
EXPLAIN
SELECT
    id,
    question_code,
    title,
    status,
    created_at
FROM tutor_project.questions
WHERE student_id = 101
  AND status = 'answered'
ORDER BY created_at DESC;

-- 후보 인덱스:
-- questions(student_id, status, created_at DESC)

-- 3. 질문별 답변 시간순 조회
EXPLAIN
SELECT
    id,
    tutor_id,
    answer_body,
    created_at
FROM tutor_project.answers
WHERE question_id = 301
ORDER BY created_at;

-- 후보 인덱스:
-- answers(question_id, created_at)

-- 4. 자료별 연결 질문 조회
EXPLAIN
SELECT
    qm.question_id,
    q.question_code,
    q.title
FROM tutor_project.question_materials AS qm
JOIN tutor_project.questions AS q
    ON q.id = qm.question_id
WHERE qm.material_id = 501
ORDER BY qm.question_id;

-- 후보 인덱스:
-- question_materials(material_id)

-- 5. PK·UNIQUE 자동 인덱스와 업무 인덱스 구분
SELECT
    tablename,
    COUNT(*) AS index_count
FROM pg_indexes
WHERE schemaname = 'tutor_project'
GROUP BY tablename
ORDER BY tablename;

-- 6. 기대 수치
SELECT
    COUNT(*) AS business_indexes_expected_3
FROM pg_indexes
WHERE schemaname = 'tutor_project'
  AND indexname IN (
      'idx_tutor_project_questions_student_status_created',
      'idx_tutor_project_answers_question_created',
      'idx_tutor_project_qm_material'
  );

-- 운영 검토 시:
-- 1. 실제 데이터 크기와 분포를 준비합니다.
-- 2. 동일 SQL로 EXPLAIN (ANALYZE, BUFFERS)를 비교합니다.
-- 3. 읽기 이점과 INSERT·UPDATE·DELETE 비용을 함께 기록합니다.
-- 4. 중복되거나 사용되지 않는 인덱스는 제거 후보로 검토합니다.
