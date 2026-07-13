# Chapter 06 구성안

## 제목

정규화와 데이터 무결성으로 좋은 테이블 만들기

## 권장 분량

22~26페이지

## 이 장의 역할

Chapter 05에서 만든 데이터 모델을 대상으로 중복과 이상 현상을 분석하고, 제1·제2·제3정규형 수준에서 구조를 개선한다. 이어서 `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`와 삭제 정책을 적용해 잘못된 값과 관계를 DBMS가 차단하도록 한다.

정규화와 무결성을 한 장에서 연결해 다음 두 문제를 함께 다룬다.

```text
사실이 잘못된 테이블에 저장되는 문제
잘못된 값과 관계가 저장되는 문제
```

## 핵심 질문

```text
한 행은 하나의 분명한 사실을 나타내는가?
각 컬럼의 주인은 누구인가?
같은 사실의 복사본이 여러 곳에 저장되는가?
독립 INSERT, 한 곳 UPDATE, 안전한 DELETE가 가능한가?
어떤 값과 관계를 DBMS가 직접 차단해야 하는가?
삭제 정책에 업무 근거가 있는가?
```

## 독자가 얻게 될 것

- 위험한 중복과 정상적인 반복을 구분할 수 있다.
- 삽입·수정·삭제 이상을 설명할 수 있다.
- 컬럼의 주인과 한 행의 의미를 판단할 수 있다.
- 함수적 종속의 기초를 설명할 수 있다.
- 제1·제2·제3정규형의 핵심 질문을 구분할 수 있다.
- 도서 대여 원시 테이블을 회원·도서·대여 테이블로 분리할 수 있다.
- 정규화와 무결성 제약조건의 역할 차이를 설명할 수 있다.
- `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`를 적용할 수 있다.
- 정상 데이터와 실패해야 하는 오류 데이터로 제약조건을 검증할 수 있다.
- 참조 무결성과 외래키 오류를 설명할 수 있다.
- `RESTRICT`, `CASCADE`, `SET NULL` 삭제 정책을 업무 관점에서 검토할 수 있다.
- 과도한 테이블 분리를 구분할 수 있다.
- AI가 만든 구조와 제약조건을 검토할 수 있다.

## 핵심 개념

- 정규화
- 위험한 중복
- 의미 있는 반복
- 삽입 이상
- 수정 이상
- 삭제 이상
- 행의 의미
- 컬럼의 주인
- 함수적 종속
- 제1정규형
- 제2정규형
- 제3정규형
- 데이터 무결성
- 기본키
- 외래키
- 참조 무결성
- `NOT NULL`
- `UNIQUE`
- `CHECK`
- 삭제 정책
- `RESTRICT`
- `CASCADE`
- `SET NULL`
- 과도한 정규화
- AI 설계 검증

## 본문 구성

1. 좋은 테이블은 데이터가 변할 때 드러난다
2. 중복의 핵심 문제는 불일치다
3. 삽입·수정·삭제 이상
4. 한 행의 의미와 컬럼의 주인
5. 함수적 종속의 기초
6. 제1정규형
7. 제2정규형
8. 제3정규형
9. 도서 대여 테이블 정규화하기
10. 정규화와 무결성 제약조건은 함께 필요하다
11. 기본키
12. `NOT NULL`, `UNIQUE`, `CHECK`
13. 외래키와 참조 무결성
14. 삭제 정책과 `CASCADE` 주의점
15. PostgreSQL 실습 구조 만들기
16. 정상 데이터와 오류 데이터로 검증하기
17. 정규화 전후의 저장과 조회
18. 정규화와 과도한 분리 구분하기
19. AI가 만든 구조와 제약조건 검토하기
20. 주문 테이블 개선 실습
21. 자주 하는 실수
22. 스스로 확인하기
23. 핵심 정리
24. 다음 장에서는

## 실습 테이블

Chapter 05 테이블과 충돌하지 않도록 실습 전용 접미사를 사용한다.

```text
library_records_raw
members_nf
books_nf
loans_nf
```

| 테이블 | 역할 |
| --- | --- |
| `library_records_raw` | 회원·도서·대여 사실이 섞인 정규화 전 구조 |
| `members_nf` | 회원의 현재 정보 |
| `books_nf` | 도서의 현재 정보 |
| `loans_nf` | 회원과 도서를 연결하는 대여 사건 |

## 실습 파일 구성

```text
code/chapter06/
├── normalization_schema.sql
├── normalization_seed.sql
├── normalization_practice.sql
├── integrity_tests.sql
├── reset_normalization.sql
└── README.md
```

| 파일 | 역할 |
| --- | --- |
| `normalization_schema.sql` | 원시·정규화 테이블과 제약조건 생성 |
| `normalization_seed.sql` | 명시적 ID를 사용한 정상 샘플 입력 |
| `normalization_practice.sql` | 중복·행 수·관계·수정 이상 감소 확인 |
| `integrity_tests.sql` | 실패해야 하는 오류 SQL을 한 문장씩 실행 |
| `reset_normalization.sql` | 필요할 때만 실습 테이블 삭제 |

## 주요 제약조건

```text
members_nf.name: NOT NULL + 공백 이름 CHECK
members_nf.email: NOT NULL + UNIQUE
books_nf.title: NOT NULL + 공백 제목 CHECK
books_nf.isbn: NOT NULL + UNIQUE
loans_nf.member_id: FK + NOT NULL + ON DELETE RESTRICT
loans_nf.book_id: FK + NOT NULL + ON DELETE RESTRICT
loans_nf.due_at: due_at >= borrowed_at CHECK
loans_nf.returned_at: NULL 또는 borrowed_at 이후 CHECK
```

## 워크북 구성

- 정규화 전 행 의미 분석
- 위험한 중복과 정상 반복 구분
- 이상 현상 분류
- 컬럼 소유자 정리
- 함수적 종속 작성
- 1NF·2NF·3NF 독립 예제
- 도서 대여 구조 분리
- 정규화와 무결성 역할 비교
- 제약조건 읽기
- 정상 데이터 실행
- 오류 데이터와 오류 메시지 기록
- 삭제 정책 비교
- 과도한 분리 검토
- AI 구조·제약조건 검토
- 주문 도메인 확장

## 범위 이동

- JOIN 문법과 다양한 결합 방식은 Chapter 08로 이동한다.
- 운영 데이터 마이그레이션과 중복 병합은 범위에서 제외한다.
- 실제 성능 기반 반정규화는 Chapter 10 이후 판단 대상으로 남긴다.
- 트랜잭션을 이용한 여러 단계 일관성 제어는 Chapter 09에서 다룬다.

## AI 활용 원칙

- 구조와 제약조건을 별도로 검토하도록 요청한다.
- 수정 제안마다 요구사항 근거를 요구한다.
- 정상 데이터와 실패해야 하는 오류 테스트를 함께 생성하도록 요청한다.
- 요구사항에 없는 `CASCADE`를 임의로 추가하지 않도록 요청한다.
- 실행 성공을 정답으로 보지 않고 오류 메시지와 저장 결과를 사람이 확인한다.

## 다음 장 연결

Chapter 07에서는 요구사항, ERD, 정규화, 무결성 제약조건과 정상·오류 데이터 검증을 온라인 강의 수강신청 프로젝트에 통합한다.
