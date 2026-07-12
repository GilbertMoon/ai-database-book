# Chapter 09 리뷰 체크리스트

## 대상 Chapter

```text
Chapter 09. 트랜잭션과 데이터 정합성
```

## 1. 본문 구조

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 권장 16개 절 순서 반영 | 통과 | 필요성부터 다음 장 연결까지 재정렬 |
| ACID 본문 포함 | 통과 | 표와 그림 9-4 추가 |
| 동시성·Lock·Deadlock 본문 포함 | 통과 | 그림 9-7과 기본 설명 추가 |
| Chapter 08 연결 | 통과 | 같은 도메인을 사용하되 확장 스키마임을 명시 |
| Chapter 10 연결 | 통과 | 인덱스와 성능 기초 연결 유지 |

## 2. 스키마와 제약조건

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| Chapter 09 확장 스키마 설명 | 통과 | courses 확장과 payments 추가 명시 |
| payments 관계 | 통과 | enrollment_id UNIQUE FK로 변경 |
| 상태 CHECK 정합성 | 통과 | 신청·수강중·완료·취소 사용 |
| 금액 CHECK | 통과 | price, paid_amount, amount에 음수 방지 |
| 좌석 CHECK | 통과 | 0 이상 capacity 이하 |
| returned/환불 확장 | 범위 제외 | 결제 시도·환불·좌석 복구 정책은 후속 범위 |

## 3. 트랜잭션 정확성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| COMMIT 전 SELECT | 통과 | 세 테이블 JOIN 검증 포함 |
| ROLLBACK 전후 세 테이블 | 통과 | courses·enrollments·payments 비교 |
| COMMIT 후 ROLLBACK 오해 방지 | 통과 | 같은 트랜잭션에서 불가함을 명시 |
| UPDATE 0행 처리 | 통과 | 후속 INSERT 금지와 즉시 ROLLBACK 명시 |
| SELECT FOR UPDATE | 통과 | 대상 행 Lock과 최신 좌석 재확인 설명 |
| Lock 대기·Deadlock 구분 | 통과 | 정상 대기와 순환 대기를 분리 |
| 트랜잭션 자동 정합성 오해 방지 | 통과 | 제약조건·업무 검증 역할 구분 |

## 4. 본문·활동 자료·SQL 정합성

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 초기 행 수 | 통과 | 3·2·3·0·0으로 통일 |
| 최종 행 수 | 통과 | enrollments 2, payments 2 |
| 최종 좌석 | 통과 | 강의 1은 1, 강의 2는 0, 강의 3은 1 |
| 결제 연결 컬럼 | 통과 | 모든 파일에서 enrollment_id 사용 |
| 상태값 | 통과 | 결제대기·결제완료 제거 |
| 위험 실습 | 통과 | Deadlock 자동 실행 없음, 성공 구간 문장별 실행 |

## 5. 그림과 원본

| 점검 항목 | 상태 | 리뷰 의견 |
| --- | --- | --- |
| 그림 9-1~9-8 각각 다른 파일 | 통과 | 중복 삽입 제거 |
| 모든 그림 본문에 한 번 삽입 | 통과 | 8개 절에 각각 배치 |
| Mermaid·SVG 핵심 논리 | 통과 | 단계·분기·피드백 경로 동기화 |
| SVG title·desc·role·aria | 통과 | 8개 모두 포함 |
| width·viewBox | 통과 | width 100%, 높이 850 이하 |
| 외부 리소스·foreignObject | 통과 | 미사용 |
| XML 파싱 | 통과 | 8개 파일 확인 |
| 임시 PNG 렌더링 | 통과 | 로컬 렌더링 확인, PNG 미커밋 |
| GitHub 미리보기 | 수동 확인 필요 | 저장소 화면 확인 필요 |
| Word/PDF/eBook | 미실행 | 실제 출판 변환에서 확인 필요 |

## 6. 읽기 전용 Chapter 정합성 비교

| 대상 | 결과 |
| --- | --- |
| Chapter 08 본문·SQL | 기본 4개 테이블과 상태값을 유지하며 Chapter 09가 확장 구조임을 명시함 |
| Chapter 10 본문 | Chapter 09 이후 인덱스 장으로 연결되는 문장 유지 |
| Chapter 08·10 파일 변경 | 없음 |

## 7. 최종 판정

```text
Chapter 09의 본문, outline, 활동 자료, SQL, README, Mermaid, SVG와 리뷰 문서를 정합성 기준으로 보정했다.
정적 검증과 임시 PNG 렌더링은 완료했으며 GitHub 및 출판 변환은 수동 확인이 필요하다.
```
