-- Chapter 15 template schema
-- 주의: 이 파일은 AI 튜터링 질문 관리 예제 테이블을 삭제하고 다시 생성합니다.
-- 별도 작업용 또는 테스트용 데이터베이스에서만 실행하세요.

SELECT
    current_database() AS current_database_name,
    current_user AS current_user_name,
    current_schema() AS current_schema_name;

DROP TABLE IF EXISTS question_materials;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS learning_materials;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS tutors;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    joined_at DATE NOT NULL
);

CREATE TABLE tutors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    specialty VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'answered', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE answers (
    id SERIAL PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES questions(id),
    tutor_id INTEGER NOT NULL REFERENCES tutors(id),
    answer_body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE learning_materials (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    material_type VARCHAR(30) NOT NULL
        CHECK (material_type IN ('article', 'document', 'video', 'quiz')),
    url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE question_materials (
    question_id INTEGER NOT NULL REFERENCES questions(id),
    material_id INTEGER NOT NULL REFERENCES learning_materials(id),
    display_order INTEGER NOT NULL CHECK (display_order > 0),
    note TEXT,
    PRIMARY KEY (question_id, material_id)
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = current_schema()
  AND table_name IN ('students', 'tutors', 'questions', 'answers', 'learning_materials', 'question_materials')
ORDER BY table_name;

SELECT tc.table_name, tc.constraint_name, tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = current_schema()
  AND tc.table_name IN ('students', 'tutors', 'questions', 'answers', 'learning_materials', 'question_materials')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 설계 메모:
-- 1. 요구사항이 없으므로 ON DELETE CASCADE를 사용하지 않습니다.
-- 2. answers에 UNIQUE(question_id, tutor_id)를 추가하지 않습니다. 같은 튜터의 복수 답변 가능 여부가 미확정입니다.
-- 3. FK 컬럼 인덱스는 PostgreSQL이 자동 생성하지 않습니다. 실제 조회 패턴을 보고 후보로 검토합니다.
-- 4. updated_at은 자동 갱신되지 않습니다. 애플리케이션 또는 트리거 정책이 필요합니다.
