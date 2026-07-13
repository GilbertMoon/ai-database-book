# Chapter 12 2차 재구성 반영 기록

## 대상 파일

```text
book/chapter12/chapter12.md
book/chapter12/chapter12_activity.md
book/chapter12/chapter12_outline.md
code/chapter12/01_nosql_lab_schema.sql
code/chapter12/02_nosql_lab_seed.sql
code/chapter12/03_document_jsonb_queries.sql
code/chapter12/04_key_value_cache_queries.sql
code/chapter12/05_storage_choice_review.sql
code/chapter12/reset_nosql_lab.sql
code/chapter12/nosql_jsonb_practice.sql
code/chapter12/README.md
images/chapter12/README.md
notes/chapter12_review_checklist.md
README.md
```

## 목적

Chapter 12를 NoSQL 유형 소개와 기본 스키마 자동 삭제 중심의 단일 SQL 실습에서 **데이터의 시스템 역할·조회 패턴·일관성·동기화·운영 비용을 근거로 저장소를 선택하는 장**으로 재구성한다.

```text
원본·파생 역할
→ 대표 읽기·쓰기
→ 트랜잭션·일관성 범위
→ RDBMS·JSONB·NoSQL 후보
→ 중복·동기화 실패
→ 작은 PoC
→ 운영·백업·복구 판단
```

---

## 1. 제목 변경

```text
기존: NoSQL 이해와 선택 기준
변경: 조회 패턴으로 RDBMS와 NoSQL 선택하기
```

---

## 2. 실습 스키마 격리

기존 SQL은 기본 검색 경로의 테이블을 자동 삭제했다.

변경 후:

```text
nosql_lab.course_documents
nosql_lab.key_value_cache_examples
nosql_lab.storage_choice_cases
```

앞 장 스키마는 변경하지 않는다.

```text
course_project
transaction_lab
performance_lab
security_lab
public
```

---

## 3. 개념 강화

| 영역 | 반영 내용 |
| --- | --- |
| 시스템 역할 | Source of Truth·캐시·임시 상태·이벤트·관계 인덱스 구분 |
| Key-Value | 키 네임스페이스·버전·TTL·캐시 미스·원본 부하 |
| Document | 포함·참조 기준과 문서 버전·마이그레이션 |
| Column-Family | 대표 조회·파티션 크기·핫스팟·늦은 이벤트 |
| Graph | 단순 JOIN과 다단계 탐색 구분 |
| 일관성 | 제품·설정·작업 범위별 검증 |
| CAP | 단순한 “항상 둘 선택” 설명 방지 |
| 동기화 | 이중 쓰기 실패·이벤트·재시도·멱등성·대조 |
| PoC | 성능뿐 아니라 실패·복구·비용 검증 |
| AI 검토 | 원본·조회·일관성·운영·복구 기준 강화 |

---

## 4. JSONB 설계 개선

```text
일반 컬럼:
- course_code
- title
- document_version
- created_at
- updated_at

JSONB:
- tags
- instructor 부가 정보
- options
- level 실습 필드
```

강화 내용:

```text
- metadata 객체 CHECK
- 문서 버전 CHECK
- 필수 키·타입 조회 검증
- jsonb_set 변경 후 ROLLBACK
- GIN과 경로 표현식 인덱스 구분
- 3행 표본의 Seq Scan을 정상 선택으로 설명
```

---

## 5. SQL 구조 변경

### 기존

```text
nosql_jsonb_practice.sql
- 기본 스키마 테이블 자동 DROP
- 생성·입력·수정·인덱스·선택표 혼합
```

### 변경

```text
01_nosql_lab_schema.sql
- 전용 스키마와 세 테이블 생성

02_nosql_lab_seed.sql
- 문서 3·캐시 4·선택 사례 6 입력

03_document_jsonb_queries.sql
- JSONB 조회·검증·ROLLBACK·인덱스 후보

04_key_value_cache_queries.sql
- 유효·만료·미스·원본 위치 확인

05_storage_choice_review.sql
- 시스템 역할·원본·일관성·동기화 근거 검증

reset_nosql_lab.sql
- nosql_lab만 초기화

nosql_jsonb_practice.sql
- 스키마 생성 전에도 실행 가능한 안전한 진입점
```

---

## 6. 기준 데이터

```text
course_documents 3
key_value_cache_examples 4
storage_choice_cases 6
유효 캐시 3
만료 캐시 1
```

저장 선택 사례:

```text
수강신청·결제
학생 로그인 세션
인기 강의 캐시
강의 유연 메타데이터
학습 행동 이벤트
학생-강의-주제 추천 관계
```

---

## 7. 안전성 개선

```text
- 자동 DROP 제거
- 모든 객체에 nosql_lab 명시
- 기준 문서 수정 후 ROLLBACK
- 만료 행 자동 DELETE 미실행
- 기존 링크 파일에서 to_regnamespace·to_regclass 사용
- 제품별 보장을 단정하지 않도록 문구 보정
```

---

## 8. 도식 처리

기존 Mermaid·SVG 8종은 RDBMS·NoSQL 역할, 네 유형, JSONB와 AI 검토라는 일반 메시지가 새 본문과 호환되어 유지한다.

이미지 문서에는 새 제목, 시스템 역할과 `nosql_lab` 기준을 반영한다.

---

## 9. 남은 확인 항목

```text
- 실제 PostgreSQL에서 01→05 순서 실행
- JSONB 구조 검증 boolean 모두 true 확인
- ROLLBACK 후 DB-101 문서 원복 확인
- 캐시 4/3/1 결과 확인
- 저장 선택 6개·역할 6종 확인
- GitHub·Word·PDF·eBook 렌더링 확인
```

---

## 10. 최종 상태

```text
Chapter 12 본문, 워크북, 구성안과 단계별 SQL을 2차 재구성했다.
저장소 유형 자체보다 원본 책임, 조회 패턴, 동기화 실패와 운영 비용을 기준으로 판단하도록 강화했다.
원격 main에 모든 변경을 직접 반영했다.
```
