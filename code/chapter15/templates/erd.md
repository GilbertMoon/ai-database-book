# ERD 설명

## 1. 스키마

```text
tutor_project
```

모든 프로젝트 테이블과 분석 VIEW는 이 스키마에 생성합니다.

---

## 2. 관계

```text
students 1 → 0..N questions
questions 1 → 0..N answers
tutors 1 → 0..N answers
questions 1 → 0..N question_materials
learning_materials 1 → 0..N question_materials
```

질문과 학습 자료의 N:M 관계는 `question_materials`로 해소합니다.

---

## 3. 테이블별 역할

| 테이블 | 역할 | 주요 제약 |
| --- | --- | --- |
| `students` | 질문 등록 학생 | IDENTITY PK, email UNIQUE |
| `tutors` | 답변 작성 튜터 | IDENTITY PK, email UNIQUE |
| `questions` | 질문과 상태 | student FK, question_code UNIQUE, status CHECK |
| `answers` | 튜터 답변 | question·tutor FK, 빈 본문 CHECK |
| `learning_materials` | 학습 자료 메타데이터 | material_code UNIQUE, 유형·접근 범위 CHECK |
| `question_materials` | 질문·자료 연결 | 복합 PK, 표시 순서 UNIQUE·CHECK |

---

## 4. 외래키 5개

| 자식 | 컬럼 | 부모 | 삭제 규칙 |
| --- | --- | --- | --- |
| questions | student_id | students(id) | RESTRICT |
| answers | question_id | questions(id) | RESTRICT |
| answers | tutor_id | tutors(id) | RESTRICT |
| question_materials | question_id | questions(id) | RESTRICT |
| question_materials | material_id | learning_materials(id) | RESTRICT |

요구사항 없이 `CASCADE`를 사용하지 않습니다.

---

## 5. 업무 인덱스

| 인덱스 | 조회 패턴 |
| --- | --- |
| `questions(student_id, status, created_at DESC)` | 학생별 상태별 질문 |
| `answers(question_id, created_at)` | 질문별 답변 시간순 조회 |
| `question_materials(material_id)` | 자료별 연결 질문 |

PK와 UNIQUE의 자동 인덱스와 별도로 실제 반복 조회를 근거로 추가합니다.

---

## 6. 분석 VIEW

`09_analysis_dataset.sql`은 `tutor_project.question_analysis_dataset` VIEW를 생성합니다.

```text
한 행 = questions.id 한 건
```

주요 컬럼:

```text
question_id
question_code
question_created_at
question_month
student_id
student_name
status
answer_count
first_answer_at
first_response_hours
material_count
has_answer
has_material
```

`answers`와 `question_materials`를 동시에 직접 JOIN하면 답변 수와 자료 수의 곱만큼 행이 늘어날 수 있습니다. 먼저 질문별로 각각 집계한 뒤 질문 테이블에 연결해야 합니다.

검증 기준:

```text
VIEW 행 수 5
question_id 중복 0
answer_count 합계 5
material_count 합계 7
답변 없는 질문 1
```

---

## 7. 미확정 정책

```text
answers에 UNIQUE(question_id, tutor_id)를 추가하지 않는다.
답변 등록 시 상태 자동 변경 트리거를 만들지 않는다.
closed 질문 답변 허용 여부를 DB 제약으로 고정하지 않는다.
삭제 정책을 CASCADE로 고정하지 않는다.
분석 기준 시각과 갱신 주기를 임의로 확정하지 않는다.
```

---

## 8. 설계 메모

```text
- updated_at은 자동 갱신되지 않는다.
- 실제 개인정보와 비밀을 저장하지 않는다.
- 명시적 ID 샘플로 시퀀스 상태 의존을 제거한다.
- 실제 구조는 03_metadata_validation.sql로 검증한다.
- 분석 VIEW는 원본을 복제하지 않는 파생 조회다.
- Python 분석은 VIEW를 읽고 SQL 기준값과 비교한다.
- 운영 변경은 별도 마이그레이션·백업·복구 계획이 필요하다.
```
