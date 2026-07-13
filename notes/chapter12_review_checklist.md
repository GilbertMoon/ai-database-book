# Chapter 12 검수 체크리스트

## 대상

Chapter 12. NoSQL 이해와 선택 기준

## 검수 목적

Chapter 12가 NoSQL을 관계형 DB의 대체재가 아니라 데이터 구조와 조회 패턴에 따른 저장 방식의 계열로 설명하는지 확인합니다. 온라인 강의 서비스 도메인과 SQL 실습, 그림, 활동지가 서로 일관되는지도 점검합니다.

## 1. 본문 구조

| 항목 | 상태 | 메모 |
|---|---|---|
| 온라인 강의 도메인 용어 사용 | 통과 | `students`, `courses`, `enrollments`, `course_documents` 기준으로 정리됨 |
| 그림 12-1과 12-2 순서 | 통과 | RDBMS/NoSQL 역할 비교 후 NoSQL 유형 정리 순서로 수정됨 |
| NoSQL 정의 | 통과 | “Not Only SQL”을 절대 공식처럼 제시하지 않고 다양한 저장 모델 계열로 설명함 |
| 오해 정리 | 통과 | SQL, 스키마, 트랜잭션, 성능, 확장성 관련 오해를 분리해 설명함 |

## 2. 유형별 설명

| 유형 | 상태 | 메모 |
|---|---|---|
| Key-Value DB | 통과 | 세션, 캐시, feature flag와 정확한 키 조회 중심으로 설명됨 |
| Document DB | 통과 | 강의 메타데이터 JSON 예시와 설계 주의사항 포함 |
| Column-Family DB | 통과 | partition key, sort key, target query 중심으로 수정됨 |
| Graph DB | 통과 | Student, Course, Topic 노드와 관계 탐색 기준으로 설명됨 |
| 범위 제한 | 통과 | 검색 엔진, 벡터 DB, 오브젝트 스토어는 Chapter 12 범위에서 제외함 |

## 3. SQL 실습

| 항목 | 상태 | 메모 |
|---|---|---|
| 반복 실행 가능성 | 통과 | `DROP TABLE IF EXISTS` 후 `CREATE TABLE` 구조로 수정됨 |
| `course_documents` 사용 | 통과 | 이전 문서 테이블명을 제거하고 현재 테이블명으로 통일함 |
| 기대 행 수 | 통과 | `course_documents` 3, `key_value_cache_examples` 4, `storage_choice_cases` 5 |
| JSONB 연산자 | 통과 | `->`, `->>`, `?`, `@>` 포함 |
| Key-Value 한계 설명 | 통과 | 자동 TTL 삭제, 분산, 복제, 성능 구현이 아님을 명시 |
| 인덱스 설명 | 통과 | GIN 인덱스와 표현식 인덱스 구분 |
| 실행 검증 | 미확인 | 현재 환경에서 `psql` 명령을 사용할 수 없어 실제 DB 실행은 미확인 |

## 4. 활동지

| 항목 | 상태 | 메모 |
|---|---|---|
| 점수표 제거 | 통과 | 자기 점검 문항 중심으로 수정됨 |
| 기대 결과 포함 | 통과 | 3/4/5 행 수와 JSONB 결과표 포함 |
| 개념 질문 | 통과 | JSONB vs Document DB, cache miss, expired_at, Column-Family, Graph vs JOIN 포함 |
| AI 검토 질문 | 통과 | 원본/캐시, 조회 패턴, 정합성, 운영 복잡도 검토 포함 |

## 5. 이미지

| 항목 | 상태 | 메모 |
|---|---|---|
| 그림 12-1~12-8 구성 | 통과 | 요청된 순서로 정리됨 |
| SVG XML 문법 | 통과 | XML 파서로 로드 확인 필요 |
| DOCX 렌더링 | 미확인 | Word 변환 후 한글 위치와 줄바꿈 추가 확인 필요 |

## 6. 남은 확인 사항

- PostgreSQL이 있는 환경에서 `code/chapter12/nosql_jsonb_practice.sql`을 실제 실행한다.
- DOCX 변환 후 SVG 텍스트가 박스 안에 유지되는지 확인한다.
- Chapter 11과 Chapter 13 파일은 이번 작업에서 수정하지 않았는지 diff로 확인한다.

## 7. 수정 이력

- Chapter 12 본문을 온라인 강의 도메인 기준으로 정리했다.
- 이전 문서 테이블명을 현재 테이블명으로 교체했다.
- NoSQL 정의와 오해를 보수적으로 수정했다.
- Key-Value, Document, Column-Family, Graph 설명을 요구 범위에 맞게 조정했다.
- SQL 실습을 반복 실행 가능하도록 수정했다.
- 활동지를 자기 점검형으로 재구성했다.
- 그림 목록과 순서를 본문 흐름에 맞게 정리했다.
