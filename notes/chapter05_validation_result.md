# Chapter 05 자동 검증 결과

## 최종 실행

```text
Workflow: Validate Chapter 05
Run: 3
Commit: 2c6e6e0c69795ef9464155fc37eac7175ab7f91f
Status: completed
Conclusion: success
Date: 2026-08-08
```

## 통과 범위

```text
- Chapter 05 JavaScript 문법
- 본문 17개 절 순서
- 본문 DDL과 3/3/4·미반납 3 기준
- 01_library_schema.sql / library_schema.sql 트랜잭션·보호·0행 검증
- 02_library_seed.sql / library_seed.sql 트랜잭션·3/3/4·관계 검증
- 03_library_validation.sql / library_validation.sql 반복 관계·고아 참조·시간 순서 검증
- reset_library.sql 보호와 loans → books → members DROP 순서
- 실습 발표 강의안 16개 절과 최신 DDL·샘플 상태
- 이론 발표 강의안 화면 구성·스크립트 구조
- chapter05_content_patch.js 최신 모델·DDL·번호 파일 기준
- 이론/실습 wrapper·직접 presentation HTML·script runtime의 content patch 연결
- TTS normalizer와 script_content_enhancer 연결
- 사람이 읽기 쉬운 발표 스크립트 label 우선
- Chapter 05 Mermaid 원본 8개와 SVG 8개 존재
```

## 첫 실패와 수정

첫 검증에서 `reset_library.sql`의 실제 DROP 순서가 아니라 파일 앞부분에 먼저 등장한 테이블 이름 문자열 위치를 비교해 실패했다.

실제 DROP은 다음 순서로 정상이다.

```text
public.loans
→ public.books
→ public.members
```

검증 코드를 각 `DROP TABLE IF EXISTS ...` 문장의 위치만 비교하도록 수정한 뒤 Run 3에서 성공했다.

## 정적 검증과 실제 실행의 구분

이 성공은 저장소 파일의 정적 일관성을 검증한 결과다. 다음은 별도 실제 확인 대상이다.

```text
- PostgreSQL reset → 01 → 02 → 03 실제 순차 실행
- 의도적 오류에서 01 부분 생성 롤백
- 의도적 오류에서 02 부분 입력 롤백
- 잘못된 DB·읽기 전용 연결 보호
- 브라우저 이론/실습 장표 최종 렌더링
- 의미 단위 포커스와 발표자 스크립트 동기화
- TTS 실제 발음
- Word·PDF·eBook SVG 최종 렌더링
```
