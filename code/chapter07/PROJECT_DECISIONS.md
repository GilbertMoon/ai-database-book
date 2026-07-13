# Chapter 07 프로젝트 설계 결정 기록

## 프로젝트

온라인 강의 수강신청 데이터베이스

## 1. 포함 범위

```text
students
instructors
courses
enrollments
```

## 2. 제외 범위

```text
결제·환불 이력
강의 정원·대기
상태 변경 이력
진도·수료
강의 콘텐츠
수강평
할인·쿠폰
```

## 3. 확정된 설계 결정

| 항목 | 결정 | 근거 |
| --- | --- | --- |
| 프로젝트 위치 | `course_project` 스키마 | 앞 장 테이블과 충돌 방지 |
| 학생·강사 | 별도 테이블 | 현재 속성과 업무 역할이 다름 |
| ID | `IDENTITY` 숫자 PK | 안정적인 내부 식별자 |
| 테스트 관계 | 명시적 ID 사용 | 실행 상태에 관계없는 재현성 |
| 금액 | 원 단위 `INTEGER` | 현재 프로젝트 범위 |
| 취소 | 상태로 보존 | 신청 이력 유지 |
| 삭제 정책 | `ON DELETE RESTRICT` | 참조 이력 보호 |
| 수강 상태 | `VARCHAR` + `CHECK` | 네 허용값을 명시 |

## 4. 보류한 결정

| 항목 | 보류 이유 | 확정 시 검토할 구조 |
| --- | --- | --- |
| 같은 강의 재신청 제한 | 취소 후 재신청 정책 미확정 | 복합 UNIQUE 또는 이력 모델 |
| 결제 테이블 | 결제 시도·환불 범위 제외 | payments와 payment_events |
| 상태 변경 이력 | 현재 상태만 요구됨 | enrollment_status_history |
| 강의 삭제 | 폐강·보존 정책 미확정 | active/status 또는 보존 정책 |

## 5. 요구사항 추적 요약

| 요구사항 | 반영 구조 | 검증 |
| --- | --- | --- |
| 학생 이메일 고유 | `students.email UNIQUE` | 중복 오류 테스트 |
| 강사가 여러 강의 담당 | `courses.instructor_id` | 강사 201 강의 2건 |
| 학생과 강의 N:M | `enrollments` | 학생 101·강의 301 관계 조회 |
| 신청 상태 제한 | status CHECK | 잘못된 상태 오류 테스트 |
| 음수 금액 금지 | price·paid_amount CHECK | 음수 오류 테스트 |
| 존재하는 부모 참조 | FK | 없는 ID 오류 테스트 |
| 취소 이력 보존 | status='취소' | 신청 1004 확인 |

## 6. AI 제안 비교 기록

| AI 제안 | 요구사항 근거 | 문제·누락 | 사람의 최종 결정 |
| --- | --- | --- | --- |
| 학생·강사를 users로 통합 | 미확정 | 기본 범위를 복잡하게 함 | 현재 버전은 분리 |
| 모든 FK에 CASCADE | 없음 | 과거 신청 이력 삭제 위험 | RESTRICT |
| 복합 UNIQUE 즉시 적용 | 미확정 | 취소 후 재신청 차단 가능 | 보류 |
| paid_amount 제거 | 요구사항과 불일치 | 신청 당시 가격 소실 | 유지 |

## 7. 실행 검증 기록

```text
실행 환경:
실행 날짜:
PostgreSQL 버전:

01 schema 결과:
02 seed 결과:
03 changes 결과:
04 validation 결과:
05 integrity tests 결과:

최종 행 수:
students =
instructors =
courses =
enrollments =

남은 문제:
```

## 8. Chapter 08 인계 기준

```text
students 3행
instructors 2행
courses 3행
enrollments 5행
1001 완료
1004 취소
1005 신청
```
