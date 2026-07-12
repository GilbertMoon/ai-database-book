# Chapter 06 실습 코드

## 정규화와 좋은 테이블 설계

| 파일 | 설명 |
| --- | --- |
| `normalization_practice.sql` | 정규화 전 `library_records`와 정규화 후 `members`, `books`, `loans`를 비교하고 JOIN으로 결과를 검증하는 실습 |

## 실행 전 주의

```text
- 이 파일은 loans, books, members, library_records를 삭제하고 다시 생성합니다.
- 개인 실습용 ai_database_book 데이터베이스에서만 실행합니다.
- 먼저 SELECT current_database();로 연결 대상을 확인합니다.
- 보존해야 할 데이터가 있는 데이터베이스에서는 실행하지 않습니다.
- 삭제 이상 비교용 DELETE는 주석 상태로 유지합니다.
```

## 실행 흐름

1. 현재 데이터베이스 확인
2. 정규화 전 `library_records` 생성과 3행 입력
3. 중복 회원·도서 정보 확인
4. 정규화 후 `members` 2행, `books` 2행, `loans` 3행 생성
5. JOIN으로 원래 업무 결과 3행 복원
6. `members` 한 행만 이메일 수정
7. 수정 후 JOIN 결과 재확인
8. 삭제 이상 예시는 주석으로 검토

`joined_at`, `published_year`, `isbn`은 정규화 전 테이블에서 자동으로 생기는 값이 아니라 Chapter 05의 추가 요구사항 속성입니다.
