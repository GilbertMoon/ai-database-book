# Chapter 12 실습 코드

## NoSQL 이해와 선택 기준

이 폴더는 Chapter 12의 NoSQL 개념 실습 파일을 관리합니다.

별도 NoSQL 서버를 설치하지 않고 PostgreSQL의 `JSONB` 기능을 사용해 문서형 데이터 개념을 맛보고, Key-Value DB 개념을 단순 시뮬레이션합니다.

---

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `nosql_jsonb_practice.sql` | PostgreSQL JSONB 문서형 데이터 실습, Key-Value 개념 시뮬레이션, 데이터 유형별 저장 방식 선택 연습 |

---

## 실행 전 주의 사항

```text
- 이 파일은 실습용 예제입니다.
- 별도 NoSQL 서버를 설치하지 않습니다.
- PostgreSQL JSONB는 Document DB를 완전히 대체한다는 의미가 아닙니다.
- JSONB는 문서형 데이터 개념을 이해하기 위한 맛보기로 사용합니다.
- 실제 서비스에서는 데이터 구조, 조회 패턴, 정합성, 운영 난이도를 함께 검토해야 합니다.
```

---

## 권장 실행 환경

```text
- PostgreSQL
- DBeaver Community Edition
- ai_database_book 실습 데이터베이스
```

---

## 주요 실습 항목

```text
- JSONB 컬럼을 가진 content_documents 테이블 생성
- JSON 문서 형태의 콘텐츠 데이터 입력
- JSONB 특정 필드 조회
- 중첩 객체 필드 조회
- JSON 배열 태그 검색
- JSONB 포함 연산자 사용
- jsonb_set을 이용한 JSONB 필드 수정
- JSONB GIN 인덱스 맛보기
- Key-Value DB 개념 시뮬레이션
- 데이터 유형별 저장 방식 선택 사례 조회
- AI 추천 NoSQL 선택 결과 검토 질문
```

---

## 실습 운영 팁

입문 독자는 다음 순서로 진행하는 것을 권장합니다.

```text
1. 관계형 테이블과 JSON 문서 구조 차이 설명
2. content_documents 테이블 생성
3. metadata JSONB 필드 조회
4. tags 배열 검색 실습
5. JSONB 필드 업데이트 실습
6. Key-Value 캐시 예시 확인
7. storage_choice_cases 표를 이용한 DB 선택 토론
8. AI 추천 결과 검토 활동
```

---

## 핵심 포인트

```text
NoSQL은 관계형 DB를 무조건 대체하는 기술이 아닙니다.
데이터 구조와 조회 패턴에 따라 적합한 저장 방식을 선택해야 합니다.
정합성이 중요한 데이터는 관계형 DB가 더 적합할 수 있습니다.
문서형 데이터가 필요할 때 PostgreSQL JSONB도 선택지 중 하나가 될 수 있습니다.
AI가 추천한 DB 선택 결과도 사람이 검토해야 합니다.
```
