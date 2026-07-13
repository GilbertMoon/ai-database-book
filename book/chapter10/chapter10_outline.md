# Chapter 10 편집 구성안

## 제목

인덱스와 성능 기초

## 장의 역할

Chapter 10은 데이터가 많아졌을 때 조회 경로와 인덱스가 왜 중요해지는지 설명한다. 단순히 `CREATE INDEX` 문법을 익히는 장이 아니라, 실제 쿼리 패턴과 실행 계획을 기준으로 인덱스를 적용·보류·제거하는 판단 흐름을 다룬다.

## 주요 개념

- B-tree 인덱스
- PRIMARY KEY 자동 인덱스
- UNIQUE 자동 인덱스
- FOREIGN KEY 자식 컬럼과 수동 인덱스
- Seq Scan
- Index Scan
- Bitmap Heap Scan
- 선택도
- 복합 인덱스의 선두 컬럼
- EXPLAIN
- EXPLAIN ANALYZE
- Buffers
- 중복 인덱스
- AI 추천 인덱스 검토

## 본문 구성

1. 인덱스가 필요한 이유
2. 성능 실습 데이터셋
3. 자동 생성 인덱스와 수동 인덱스
4. Seq Scan과 Index Scan
5. WHERE 조건과 인덱스 후보
6. ORDER BY와 인덱스
7. JOIN과 FOREIGN KEY 인덱스
8. 복합 인덱스와 선두 컬럼
9. EXPLAIN과 EXPLAIN ANALYZE
10. 인덱스의 이점과 비용
11. AI 추천 인덱스 검토
12. 최종 인덱스 기준
13. 자주 하는 실수
14. 핵심 정리
15. 다음 장 연결

## 편집 원칙

- 인덱스가 있으면 항상 좋다고 설명하지 않는다.
- Seq Scan이 항상 오류라고 설명하지 않는다.
- EXPLAIN의 cost를 실행 시간으로 설명하지 않는다.
- EXPLAIN ANALYZE가 SQL을 실행한다는 점을 명확히 한다.
- `students.email`에는 수동 중복 인덱스를 만들지 않는다.
- Chapter 09의 `payments` 잔존 가능성을 SQL 초기화에 반영한다.
- Chapter 09와 Chapter 11 파일은 수정하지 않고 연결 관계만 확인한다.
