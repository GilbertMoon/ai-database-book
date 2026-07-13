# ERD 설명

## 테이블 관계

```text
students 1:N questions
questions 1:N answers
tutors 1:N answers
questions N:M learning_materials
questions 1:N question_materials N:1 learning_materials
```

## 테이블별 역할

| 테이블 | 역할 | 주요 제약 |
|---|---|---|
| `students` | 질문 등록 학생 | PK, email UNIQUE |
| `tutors` | 답변 작성 튜터 | PK, email UNIQUE |
| `questions` | 학생 질문 | student_id FK, status CHECK |
| `answers` | 튜터 답변 | question_id FK, tutor_id FK |
| `learning_materials` | 학습 자료 | material_type CHECK |
| `question_materials` | 질문-자료 연결 | 복합 PK, display_order CHECK |

## FK 목록

| 자식 테이블 | 컬럼 | 부모 테이블 |
|---|---|---|
| `questions` | `student_id` | `students(id)` |
| `answers` | `question_id` | `questions(id)` |
| `answers` | `tutor_id` | `tutors(id)` |
| `question_materials` | `question_id` | `questions(id)` |
| `question_materials` | `material_id` | `learning_materials(id)` |

FK는 총 5개입니다.

## 설계 메모

- `answers`에 학생 이름, 튜터 이름, 질문 제목을 중복 저장하지 않습니다.
- 삭제 정책은 요구사항이 없으므로 CASCADE를 사용하지 않습니다.
- `updated_at`은 자동 갱신되지 않습니다. 애플리케이션 또는 트리거 설계가 필요합니다.
- FK 컬럼 인덱스는 자동 생성된다고 가정하지 않고 성능 후보로만 검토합니다.
