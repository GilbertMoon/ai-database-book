# Chapter 12 리뷰 반영 기록

## 대상

Chapter 12. NoSQL 이해와 선택 기준

## 반영 요약

이번 수정에서는 Chapter 12를 온라인 강의 서비스 도메인에 맞춰 다시 정리했습니다. 핵심은 NoSQL을 관계형 DB의 대체재가 아니라 데이터 구조와 조회 패턴에 따라 선택하는 저장 방식의 계열로 설명하는 것입니다.

## 주요 변경 사항

| 영역 | 반영 내용 |
|---|---|
| 본문 | RDBMS와 NoSQL 역할 비교를 먼저 제시하고, NoSQL 유형 정리를 뒤에 배치함 |
| 용어 | 이전 문서 테이블명을 제거하고 `course_documents`로 통일함 |
| NoSQL 정의 | “Not Only SQL”을 단정 공식처럼 제시하지 않고 일반적 해석으로만 다룸 |
| Key-Value | 세션, 캐시, feature flag와 cache miss 흐름을 추가함 |
| Document | 강의 메타데이터 JSON 예시와 설계 주의사항을 보강함 |
| Column-Family | partition key, sort key, target query 중심으로 수정함 |
| Graph | Student, Course, Topic 노드와 관계 탐색 기준으로 설명함 |
| JSONB | PostgreSQL JSONB와 실제 Document DB의 차이를 명시함 |
| SQL | 반복 실행 가능하도록 `DROP TABLE IF EXISTS` 후 생성하도록 수정함 |
| 활동지 | 점수표보다 자기 점검과 해석 질문 중심으로 재구성함 |
| 이미지 | 그림 12-1부터 12-8까지 요청 순서에 맞춰 정리함 |

## SQL 실습 기대 상태

| 테이블 | 기대 행 수 |
|---|---:|
| `course_documents` | 3 |
| `key_value_cache_examples` | 4 |
| `storage_choice_cases` | 5 |

## 검증 상태

| 항목 | 상태 | 메모 |
|---|---|---|
| Markdown 링크 | 확인 필요 | 로컬 파일 존재 여부 검사 필요 |
| SVG XML 문법 | 확인 필요 | XML 파서 검사 필요 |
| SQL 실제 실행 | 미확인 | 현재 환경에 `psql`이 없으면 실행 불가 |
| Chapter 11/13 변경 여부 | 확인 필요 | 이번 작업 범위 밖 파일은 수정하지 않아야 함 |

## 추가 검수 권장

- DOCX 변환 후 SVG 한글이 깨지지 않는지 확인한다.
- 그림 안 텍스트가 박스 밖으로 나가지 않는지 확인한다.
- PostgreSQL 설치 환경에서 SQL 파일을 실제 실행한다.
- AI 추천 검토 활동이 과도하게 정답형이 아니라 판단형으로 보이는지 확인한다.
