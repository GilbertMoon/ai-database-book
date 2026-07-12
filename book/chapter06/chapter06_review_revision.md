# Chapter 06 출간용 문체 및 도식 보정 기록

## 대상 원고

```text
book/chapter06/chapter06.md
book/chapter06/chapter06_activity.md
code/chapter06/normalization_practice.sql
code/chapter06/README.md
images/chapter06/*
notes/chapter06_review_checklist.md
```

## 기존 반영 이력

| 항목 | 상태 |
| --- | --- |
| 정규화 단계별 판단표 | 기존 반영 유지 |
| AI 구조 검토 주의 문장 | 기존 반영 유지·강화 |
| 일반 독자용 문체 | 유지 |
| Chapter 07 연결 | 유지 |

## 이번 보정

| 항목 | 상태 | 내용 |
| --- | --- | --- |
| 정규형 독립 예제 안내 | 완료 | 1NF·2NF·3NF가 독립 예제임을 명시 |
| 3NF 가정 | 완료 | zip_code → city를 단순화된 업무 가정으로 표시 |
| 실습 SQL 경고 | 완료 | 테이블 삭제와 current_database 확인 안내 |
| 컬럼 소유자 표 | 완료 | library_records 컬럼과 최종 주인 정리 |
| 추가 속성 설명 | 완료 | joined_at, published_year, isbn의 출처 명시 |
| SVG 8개 단순화 | 완료 | 한 그림당 한 핵심 질문으로 재구성 |
| Mermaid 동기화 | 완료 | SVG와 핵심 구조 일치 |
| 정규화·마이그레이션 구분 | 완료 | 운영 데이터 이관 절차 제거 |
| 과도한 정규화 설명 | 완료 | 실제 조회 패턴과 측정 근거 강조 |
| README·체크리스트 | 완료 | 실제 수정·검증 상태 반영 |

## 제거한 중복과 범위 밖 내용

```text
- SVG 내부 전체 SQL과 전체 JOIN 결과
- 대형 샘플 데이터 표와 세부 검증 카드
- 운영 데이터 정제·중복 병합·스테이징·이관 절차
- BCNF, 4NF, 5NF와 고급 종속 이론
- 인덱스, 잠금, ON DELETE, 복본 관리, 동시 대여 제약
- 근거 없는 반정규화 권장
```

## 검증 결과

| 검증 항목 | 결과 |
| --- | --- |
| 본문·활동·SQL 샘플 행 수 | 통과 |
| JOIN 컬럼과 returned_at | 통과 |
| 8개 SVG XML 파싱 | 통과 |
| title·desc·role·aria-labelledby | 통과 |
| width·viewBox·foreignObject 미사용 | 통과 |
| 핵심 글자 12px 이상 | 통과 |
| Mermaid와 SVG 의미 비교 | 통과 |
| Mermaid CLI 문법 검증 | 미실행 — CLI 없음 |
| GitHub 실제 렌더링 | 수동 확인 필요 |
| Word/PDF/eBook 변환 | 미실행 — 수동 확인 필요 |

## 결론

```text
Chapter 06은 정규화 판단 근거를 본문과 표에, 실행 SQL을 코드에, 전후 구조와 흐름을 SVG에 분리했다.
정규형 예제의 전제와 3NF 업무 가정을 명확히 했으며, 실제 출판 렌더링은 후속 수동 확인 항목으로 남겼다.
```
