# Chapter 10 리뷰 후 보완 반영 기록

## 대상 원고

```text
book/chapter10/chapter10.md
```

## 반영 내용

| 보완 항목 | 반영 상태 | 반영 위치 |
| --- | --- | --- |
| UNIQUE 중복 인덱스 문제 수정 | 완료 | 본문, SQL, 활동지 |
| Chapter 09 잔존 `payments` 초기화 보정 | 완료 | SQL, 본문, README |
| 성능 실습용 대량 데이터 추가 | 완료 | SQL, 본문, 활동지 |
| 자동·수동 인덱스 설명 추가 | 완료 | 본문, 활동지, README |
| EXPLAIN과 EXPLAIN ANALYZE 구분 | 완료 | 본문, 활동지, SQL |
| ORDER BY LIMIT 실습 추가 | 완료 | 본문, SQL, 활동지 |
| FK 인덱스 설명 보정 | 완료 | 본문, SQL |
| 복합 인덱스 선두 컬럼 설명 추가 | 완료 | 본문, SQL, 활동지 |
| 단일·복합 인덱스 중복 검토 추가 | 완료 | 본문, SQL, 활동지 |
| AI 추천 인덱스 검토 흐름 보강 | 완료 | 본문, 도식, 활동지 |
| Mermaid와 SVG 8종 재정리 | 완료 | images/chapter10 |

## 남은 확인

- 로컬 PostgreSQL에서 SQL 전체 실행
- 환경별 실행 계획 차이 확인
- SVG의 브라우저/GitHub/Word 변환 렌더링 확인

## 결론

Chapter 10은 인덱스를 무조건 추가하는 장이 아니라, 실제 쿼리 패턴과 실행 계획을 근거로 적용·보류·제거를 판단하는 장으로 보정되었다.
