# Chapter 15 제출 템플릿

## 최종 프로젝트 제출 폴더

이 폴더는 Chapter 15 최종 프로젝트 제출 템플릿입니다.

학습자는 이 폴더 구조를 복사해 자신의 프로젝트에 맞게 내용을 채우면 됩니다.

---

## 권장 제출 구조

```text
final_project/
├── README.md
├── requirements.md
├── erd.md 또는 erd.png
├── schema.sql
├── seed.sql
├── queries.sql
├── ai_review_report.md
├── final_report.md
└── screenshots/
```

---

## 파일 설명

| 파일 | 설명 |
| --- | --- |
| `README.md` | 프로젝트 개요와 실행/확인 방법 |
| `requirements.md` | 요구사항 정의서 |
| `erd.md` | 텍스트 기반 ERD 또는 테이블 관계 설명 |
| `schema.sql` | PostgreSQL 테이블 생성 SQL |
| `seed.sql` | 샘플 데이터 입력 SQL |
| `queries.sql` | 핵심 조회, JOIN, 집계, 검증 SQL |
| `ai_review_report.md` | AI 활용 및 검토 보고서 |
| `final_report.md` | 최종 보고서 |

---

## 제출 파일명 권장

```text
학번_이름_final_project.zip
```

예시:

```text
20260001_홍길동_final_project.zip
```

---

## 제출 전 확인

```text
- SQL 파일이 실행 가능한 순서로 작성되었는가?
- schema.sql 실행 후 seed.sql을 실행할 수 있는가?
- queries.sql의 핵심 쿼리가 실제 결과를 반환하는가?
- AI 활용 보고서에 프롬프트와 수정 내용이 기록되어 있는가?
- 최종 보고서에 설계 판단과 한계가 포함되어 있는가?
```
