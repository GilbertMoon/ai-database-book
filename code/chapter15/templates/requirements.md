# 요구사항 정의서

## 1. 확정 요구사항

| ID | 요구사항 | DB·분석 반영 | 검증 파일 |
| --- | --- | --- | --- |
| REQ-01 | 학생은 질문을 등록할 수 있다 | `questions.student_id` FK | `04_requirement_queries.sql` |
| REQ-02 | 학생 이메일은 중복될 수 없다 | `students.email UNIQUE` | `06_negative_tests.sql` |
| REQ-03 | 튜터 이메일은 중복될 수 없다 | `tutors.email UNIQUE` | `06_negative_tests.sql` |
| REQ-04 | 질문 상태는 허용값만 사용한다 | `questions.status CHECK` | `06_negative_tests.sql` |
| REQ-05 | 질문에는 여러 답변이 가능하다 | `questions 1:N answers` | 질문별 답변 집계 |
| REQ-06 | 답변은 튜터와 연결된다 | `answers.tutor_id` FK | 답변·튜터 JOIN |
| REQ-07 | 질문과 학습 자료는 N:M이다 | `question_materials` | N:M 조회 |
| REQ-08 | 질문이 없는 학생을 조회한다 | LEFT JOIN | 기대 1명 |
| REQ-09 | 연결되지 않은 자료를 조회한다 | LEFT JOIN | 기대 1건 |
| REQ-10 | 한 질문 안에서 자료 표시 순서는 중복되지 않는다 | `UNIQUE(question_id, display_order)` | 중복 순서 반례 |
| REQ-11 | 실제 개인정보와 비밀을 사용하지 않는다 | 가상 seed·민감 컬럼 검사 | `08_operations_checks.sql` |
| REQ-12 | 질문 1건 단위 분석 데이터셋을 제공한다 | `question_analysis_dataset` VIEW | `09_analysis_dataset.sql` |
| REQ-13 | SQL과 Python의 핵심 집계가 일치한다 | SQL 기준값·pandas 비교 | Python 검증 스크립트 |

---

## 2. 미확정 업무 규칙

| 질문 | 상태 | 현재 처리 |
| --- | --- | --- |
| 같은 튜터가 한 질문에 여러 답변을 작성할 수 있는가 | 미확정 | UNIQUE 추가 금지 |
| 답변 등록 시 질문 상태를 자동으로 바꾸는가 | 정책 필요 | 트랜잭션 예제에서 명시적 UPDATE |
| closed 질문에도 답변을 허용하는가 | 미확정 | 애플리케이션 정책으로 보류 |
| 학생 삭제 시 질문을 함께 삭제하는가 | 미확정 | `ON DELETE RESTRICT` |
| 질문·답변 보관 기간은 얼마인가 | 조직 정책 필요 | 자동 삭제 금지 |
| 분석 기준 시각과 갱신 주기는 무엇인가 | 미확정 | 실행 시점과 데이터 범위 기록 |

미확정 정책은 AI가 임의로 `UNIQUE`, `CASCADE`, 트리거 또는 Python 전처리 규칙으로 고정하지 않습니다.

---

## 3. 단순화 가정

```text
질문 상태: open, answered, closed
자료 유형: article, document, video, quiz
접근 범위: public, internal, restricted
한 질문에 여러 답변 허용
질문과 자료는 복합 PK 연결 테이블로 관리
삭제는 RESTRICT
updated_at 자동 변경은 현재 범위에서 제외
분석 데이터셋 한 행은 질문 1건
Python은 읽기 전용 SELECT만 사용
```

---

## 4. 검증 기준

```text
행 수 4·3·5·5·6·7
FK 5
IDENTITY PK 5
업무 인덱스 3
CASCADE FK 0
질문 없는 학생 1
연결되지 않은 자료 1
정합성 이상 0행
반례 unexpected 0
ROLLBACK 후 answers 5·질문 303 open
분석 VIEW 5행
question_id 중복 0
answer_count 합계 5
material_count 합계 7
답변 없는 질문 1
SQL·pandas 핵심 집계 일치
```

---

## 5. 선택 확장

| 확장 | 현재 포함 | 판단 기준 |
| --- | --- | --- |
| 웹 CRUD·API | 제외 | 외부 입력·조회 흐름 검증 필요 |
| NoSQL | 제외 | 별도 캐시·문서·이벤트 조회 패턴 필요 |
| 클라우드 배포 | 제외 | 공유·운영 검증 필요 |
