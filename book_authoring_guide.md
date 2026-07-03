# Book Authoring Guide

## 새로운 주제로 실습형 eBook 교재를 만드는 표준 방법론

이 문서는 새로운 주제를 정한 뒤, 지금 이 저장소에서 진행한 방식과 동일한 절차로 하나의 교재형 eBook 콘텐츠를 만드는 방법론입니다.

목표는 단순히 원고를 작성하는 것이 아닙니다.

다음 네 가지가 함께 갖춰진 교재를 만드는 것입니다.

```text
1. 읽을 수 있는 원고
2. 따라 할 수 있는 실습 코드
3. 이해를 돕는 도식
4. 출판 가능한 통합 eBook 산출물
```

이 문서를 그대로 따라가면 새로운 주제에 대해서도 Chapter 단위로 원고, 코드, 도식, 리뷰 기록을 축적하고, 최종적으로 하나의 eBook 콘텐츠를 만들 수 있습니다.

---

## 1. 이 방법론의 핵심 철학

### 1.1 책은 목차가 아니라 학습 여정이다

좋은 교재는 주제를 단순히 나열하지 않습니다.

독자가 다음 흐름을 자연스럽게 따라갈 수 있어야 합니다.

```text
처음 알게 됨
→ 개념을 이해함
→ 작은 예제를 실행함
→ 실습을 확장함
→ 오류를 경험하고 해결함
→ 하나의 프로젝트로 완성함
```

따라서 책을 만들 때 가장 먼저 해야 할 일은 “무엇을 쓸 것인가”가 아니라 “독자가 어떤 순서로 성장해야 하는가”를 설계하는 것입니다.

---

### 1.2 Chapter는 하나의 수업 단위다

각 Chapter는 독립된 글이 아니라 하나의 수업 단위입니다.

Chapter 하나에는 다음 요소가 들어가야 합니다.

```text
- 학습 목표
- 핵심 개념
- 실습 코드
- 도식
- 실행 결과
- 자주 하는 실수
- 연습 문제
- 다음 장으로 이어지는 연결
```

이 구조를 유지하면 Chapter별로 수업 자료, eBook 원고, 실습 자료를 동시에 만들 수 있습니다.

---

### 1.3 원고, 코드, 도식, 리뷰 노트는 함께 관리한다

교재는 원고만으로 완성되지 않습니다.

실습형 eBook이라면 다음 산출물이 함께 있어야 합니다.

```text
- book/: Chapter별 원고
- code/: Chapter별 실습 코드
- images/: 원고에 들어갈 도식
- notes/: 작업 기록과 리뷰 기록
- publish/: 통합 Markdown, Word, PDF 산출물
- scripts/: 자동화 스크립트
```

원고와 코드가 분리되어 있으면 시간이 지나면서 불일치가 생깁니다.

따라서 Chapter별로 원고와 코드를 함께 점검하고, 리뷰 기록을 남기는 방식이 중요합니다.

---

### 1.4 마지막에는 반드시 하나의 통합 Markdown으로 묶는다

Chapter별 원고가 완성되어도 그것만으로 eBook 제작이 끝난 것은 아닙니다.

최종적으로는 다음과 같은 통합 파일이 필요합니다.

```text
publish/full_manuscript.md
```

이 파일을 기준으로 Word, PDF, 기타 eBook 포맷으로 변환합니다.

---

## 2. 이 방법론이 적합한 책의 유형

이 방법론은 특히 다음 유형의 책에 적합합니다.

```text
- AI / 데이터 / 개발 실습형 교재
- 대학 강의용 eBook
- 부트캠프 교재
- 기업 교육용 실습 교재
- 프로젝트 기반 실무 교재
- 강의 자료와 실습 코드를 함께 제공하는 책
```

반대로 순수 에세이, 소설, 논문형 단행본에는 일부 절차만 적용하면 됩니다.

---

## 3. 전체 제작 절차 요약

전체 절차는 다음과 같습니다.

```text
1. 새 책의 주제 정하기
2. 대상 독자와 최종 학습 목표 정의하기
3. 전체 목차와 Part 구조 설계하기
4. 저장소 구조 만들기
5. 집필 스타일 가이드 작성하기
6. Chapter별 구성 설계 작성하기
7. Chapter별 원고 초안 작성하기
8. Chapter별 실습 코드 작성하기
9. Chapter별 도식 제작하기
10. 도식 본문 삽입 확인하기
11. 원고 1차 리뷰 및 보완하기
12. 실습 코드 실행 검토하기
13. Chapter별 최종 점검 및 1차 완료 처리하기
14. 전체 원고 1차 통합 점검하기
15. 출판 전 원고/코드 통합 리뷰하기
16. 단일 통합 Markdown 생성하기
17. Word/PDF 변환 테스트하기
18. 독자용 실습 코드 공개 저장소 분리하기
19. 최종 교정 및 배포하기
```

이 절차를 한 줄로 요약하면 다음과 같습니다.

```text
주제 → 목차 → Chapter 설계 → 원고 → 코드 → 도식 → 리뷰 → 통합 Markdown → 출판 산출물
```

---

## 4. 새 책 시작 전 질문지

새로운 책을 만들기 전에 다음 질문에 답합니다.

### 4.1 책의 기본 정보

```text
- 책 제목은 무엇인가?
- 부제는 무엇인가?
- 이 책은 어떤 문제를 해결하는가?
- 이 책을 읽어야 하는 사람은 누구인가?
- 이 책을 다 읽은 독자는 무엇을 할 수 있어야 하는가?
```

### 4.2 독자 수준

```text
- 독자는 완전 초보자인가?
- 기본 개념은 알고 있는가?
- 코딩 경험이 있는가?
- 실무 경험이 있는가?
- 수업용인가, 자습용인가?
```

### 4.3 실습 환경

```text
- 사용할 프로그래밍 언어는 무엇인가?
- 권장 OS는 무엇인가?
- Python, Node.js, Docker 등 필요한 환경은 무엇인가?
- 외부 API나 클라우드 서비스가 필요한가?
- 무료 환경으로 실습 가능한가?
```

### 4.4 최종 프로젝트

```text
- 마지막에 독자가 완성할 프로젝트는 무엇인가?
- 그 프로젝트는 앞 Chapter의 내용을 종합하는가?
- 프로젝트 결과물이 실제로 실행 가능한가?
- 평가 기준을 만들 수 있는가?
```

---

## 5. 표준 저장소 구조

새 책을 만들 때는 다음 구조를 권장합니다.

```text
project-root/
├── README.md
├── BOOK_STYLE.md
├── book_authoring_guide.md
├── book/
│   ├── chapter01/
│   │   ├── chapter01_outline.md
│   │   └── chapter01.md
│   ├── chapter02/
│   │   ├── chapter02_outline.md
│   │   └── chapter02.md
│   └── ...
├── code/
│   ├── chapter01/
│   ├── chapter02/
│   └── ...
├── images/
├── notes/
├── scripts/
└── publish/
```

각 폴더의 역할은 다음과 같습니다.

| 폴더 | 역할 |
| --- | --- |
| `book/` | Chapter별 원고와 outline |
| `code/` | Chapter별 실습 코드 |
| `images/` | 원고에 삽입할 도식과 이미지 |
| `notes/` | 작업 기록, 리뷰 기록, 점검 결과 |
| `scripts/` | 원고 병합, 링크 점검, 변환 자동화 |
| `publish/` | 통합 Markdown, Word, PDF 등 출판 산출물 |

---

## 6. README 운영 방식

README는 프로젝트의 현재 상태판입니다.

최소한 다음 항목을 포함합니다.

```text
- 프로젝트 개요
- 프로젝트 목표
- 운영 원칙
- Chapter 진행 현황
- 전체 진행 상태
- 다음 작업
```

Chapter 진행 현황 예시:

```markdown
| Chapter | 제목 | 상태 |
| --- | --- | --- |
| Chapter 01 | 주제 개요 | 원고 초안 작성 완료 |
| Chapter 02 | 실습 환경 구축 | 실습 코드 작성 완료 |
| Chapter 03 | 기본 예제 | 1차 완료 |
```

상태값은 다음처럼 통일합니다.

```text
구성 설계 완료
원고 초안 작성 완료
실습 코드 작성 완료
도식 제작 완료
도식 본문 삽입 완료
원고 1차 리뷰 및 보완 완료
실습 코드 실행 검토 완료
1차 완료
```

README의 `다음 작업`은 항상 현재 프로젝트가 이어서 해야 할 일을 가리켜야 합니다.

---

## 7. BOOK_STYLE.md 작성

책 전체의 품질을 유지하기 위해 `BOOK_STYLE.md`를 작성합니다.

포함 항목:

```text
- 문체
- 독자 수준
- Chapter 기본 구조
- 코드 블록 작성 규칙
- 그림 캡션 규칙
- 표 작성 규칙
- 용어 표기 규칙
- 보안 표현 규칙
- 실습 코드 범위
```

예시:

```text
문체: 강의식, 친절한 설명, 실무형 예시 중심
독자 수준: 초중급
코드 설명: 코드보다 실행 흐름과 목적을 먼저 설명
도식: SVG 우선, 흰 배경, 한글 캡션
보안: 실제 인증 정보와 유사한 문자열 금지
```

---

## 8. 전체 목차 설계 방법

목차는 단순히 주제를 나열하는 방식이 아니라 학습 여정으로 설계합니다.

권장 Part 구조:

```text
Part 1. 입문과 전체 그림
Part 2. 핵심 기술 기초
Part 3. 실습 확장
Part 4. 서비스화와 운영
Part 5. 최종 프로젝트
```

목차 설계 체크리스트:

```text
- Chapter 01은 전체 그림을 보여주는가?
- Chapter 02~03은 기본기를 다지는가?
- 중반부는 실습을 단계적으로 확장하는가?
- 후반부는 운영, 배포, 품질 관리를 다루는가?
- 마지막 Chapter는 최종 프로젝트인가?
```

좋은 목차는 다음 흐름을 가집니다.

```text
개념 이해
→ 기초 실습
→ 기능 확장
→ 운영 품질
→ 최종 프로젝트
```

---

## 9. Chapter 구성 설계

각 Chapter는 원고를 쓰기 전에 먼저 outline을 작성합니다.

파일 예시:

```text
book/chapter01/chapter01_outline.md
```

outline 구조:

```markdown
# Chapter 01 구성 설계

## Chapter 제목

## Chapter 역할

## 이전 Chapter와의 연결

## 다음 Chapter로 이어지는 흐름

## 학습 목표

## 원고 구조 초안

## 예상 실습 파일 구조

## 예상 도식

## 완료 기준
```

outline 단계에서 확정해야 할 것:

```text
- 이 Chapter의 핵심 메시지
- 독자가 실습으로 만들 결과물
- 필요한 코드 파일
- 필요한 도식
- 다음 Chapter와의 연결
```

---

## 10. Chapter 원고 표준 템플릿

각 Chapter 원고는 다음 구조를 권장합니다.

```markdown
# Chapter XX. 제목

> 이 장에서 다룰 핵심 내용을 2~3문장으로 설명합니다.

---

## 학습 목표

이 장을 마치면 다음을 할 수 있습니다.

- 목표 1
- 목표 2
- 목표 3

---

## 학습 전 생각해 보기

- 질문 1
- 질문 2
- 질문 3

---

## 1. 개념 이해

## 2. 전체 구조

## 3. 실습 준비

## 4. 코드 작성

## 5. 실행 결과 확인

## 6. 자주 하는 실수

## 7. 정리

## 8. 연습 문제

## 9. 다음 장 예고

## 10. 출판 전 점검 체크리스트
```

원고 작성 원칙:

```text
- 한 Chapter는 하나의 명확한 학습 목표를 가져야 한다.
- 개념 설명 후 바로 실습으로 연결한다.
- 코드가 왜 필요한지 먼저 설명한다.
- 파일명과 함수명은 실제 코드와 일치해야 한다.
- 그림 번호와 이미지 파일명은 명확해야 한다.
```

---

## 11. 실습 코드 작성 방법

실습 코드는 Chapter 원고와 함께 관리합니다.

권장 구조:

```text
code/chapterXX/
├── README.md
├── requirements.txt
├── .env.example
├── .gitignore
├── main.py 또는 app.py
├── module_name.py
└── smoke_test.py
```

실습 코드 작성 원칙:

```text
- 독자가 그대로 실행할 수 있어야 한다.
- 코드가 너무 길면 역할별 파일로 나눈다.
- 외부 API가 필요한 경우 .env.example만 제공한다.
- 실제 인증 정보는 저장하지 않는다.
- 실행 결과 파일은 .gitignore에 포함한다.
- 가능하면 smoke_test.py를 둔다.
```

실습 README에 포함할 내용:

```text
- 실습 목표
- 파일 구성
- 설치 방법
- 환경 변수 설정
- 실행 방법
- 예상 결과
- 자주 발생하는 오류
- 확장 과제
```

---

## 12. 도식 제작 방법

도식은 독자가 구조를 빠르게 이해하도록 돕는 장치입니다.

도식 파일명 규칙:

```text
images/chXX_topic_name.svg
```

예시:

```text
images/ch04_rag_pipeline_overview.svg
images/ch10_agent_workflow_state.svg
images/ch15_agentops_loop.svg
```

도식 제작 원칙:

```text
- SVG 우선 사용
- 흰 배경
- 한글 텍스트 가독성 확보
- 그림 번호와 캡션 일치
- 너무 많은 정보를 넣지 않음
- 데이터 흐름 또는 실행 흐름 중심
```

도식 제작 기록 파일:

```text
notes/chapterXX_diagrams.md
```

도식 본문 삽입 확인 파일:

```text
notes/chapterXX_diagram_insertion.md
```

---

## 13. Chapter 리뷰 절차

각 Chapter는 최소 세 번 점검합니다.

```text
1. 원고 1차 리뷰
2. 실습 코드 실행 검토
3. 최종 점검
```

### 13.1 원고 1차 리뷰

확인 항목:

```text
- 원고 흐름이 자연스러운가?
- 이전/다음 Chapter와 연결되는가?
- 원고에 언급한 파일이 실제 존재하는가?
- 함수명과 실제 코드가 일치하는가?
- 도식 링크가 맞는가?
- 보안상 부적절한 예시가 없는가?
```

기록 파일:

```text
notes/chapterXX_review.md
```

### 13.2 실습 코드 실행 검토

확인 항목:

```text
- import 오류 가능성
- 실행 명령 정확성
- requirements.txt 필요 여부
- .env.example 필요 여부
- .gitignore 산출물 제외 여부
- smoke_test.py 존재 여부
- Dockerfile 또는 compose.yaml 필요 여부
```

기록 파일:

```text
notes/chapterXX_execution_review.md
```

### 13.3 최종 점검

확인 항목:

```text
- outline 완료
- 원고 완료
- 코드 완료
- 도식 완료
- 도식 삽입 확인 완료
- 리뷰 완료
- 실행 검토 완료
- README 상태 갱신 완료
```

기록 파일:

```text
notes/chapterXX_final_check.md
```

---

## 14. Chapter 완료 기준

Chapter를 `1차 완료`로 처리하려면 다음 조건을 만족해야 합니다.

```text
- book/chapterXX/chapterXX_outline.md 존재
- book/chapterXX/chapterXX.md 존재
- code/chapterXX/ 실습 코드 존재
- images/chXX_*.svg 도식 존재
- notes/chapterXX_diagrams.md 존재
- notes/chapterXX_diagram_insertion.md 존재
- notes/chapterXX_review.md 존재
- notes/chapterXX_execution_review.md 존재
- notes/chapterXX_final_check.md 존재
- README 상태가 1차 완료로 갱신됨
```

단, 모든 Chapter에 코드가 반드시 필요한 것은 아닙니다.

개념 중심 Chapter는 `code/chapterXX/README.md` 또는 간단한 예제 파일만 있어도 됩니다.

---

## 15. 전체 원고 통합 점검

모든 Chapter가 1차 완료되면 전체 원고 통합 점검을 수행합니다.

기록 파일:

```text
notes/overall_manuscript_integration_review.md
```

확인 항목:

```text
- 전체 목차 흐름이 자연스러운가?
- 난이도 상승이 적절한가?
- Part 구분이 필요한가?
- 용어 표기가 일관적인가?
- Chapter 간 중복이 과도하지 않은가?
- 최종 프로젝트가 앞 내용을 종합하는가?
- 실습 코드 난이도가 급격히 뛰지 않는가?
```

완료 판단:

```text
전체 원고 1차 통합 점검 완료
```

---

## 16. 출판 전 원고/코드 통합 리뷰

출판 전에는 원고와 코드가 실제 독자에게 제공 가능한 상태인지 점검합니다.

기록 파일:

```text
notes/pre_publication_manuscript_code_review.md
```

확인 항목:

```text
- 원고에 언급된 파일이 실제 존재하는가?
- 코드 함수명과 원고 설명이 일치하는가?
- 실행 명령이 실제로 맞는가?
- 이미지 링크가 깨지지 않는가?
- 보안 정보가 포함되지 않았는가?
- .env와 실행 산출물이 Git에서 제외되는가?
- Word/PDF 변환 시 깨질 가능성이 있는가?
```

---

## 17. 단일 통합 Markdown 생성

Chapter별 원고가 완성되면 eBook 변환용 단일 Markdown을 생성합니다.

권장 파일:

```text
publish/full_manuscript.md
```

자동 생성 스크립트:

```text
scripts/build_full_manuscript.py
```

통합 Markdown 구성:

```text
1. 제목 페이지
2. 저자 정보
3. 머리말
4. 전체 목차
5. Part 구분
6. Chapter 01
7. Chapter 02
8. ...
9. 마지막 Chapter
10. 부록
11. 용어집
12. 참고자료
```

이미지 경로 변환 규칙:

```text
Chapter별 원고: ../../images/example.svg
통합 원고: ../images/example.svg
```

---

## 18. Word/PDF 변환 절차

통합 Markdown이 생성되면 Word/PDF 변환을 수행합니다.

기본 명령 예시:

```bash
pandoc publish/full_manuscript.md -o publish/full_manuscript.docx
pandoc publish/full_manuscript.md -o publish/full_manuscript.pdf
```

Word 템플릿을 사용할 경우:

```bash
pandoc publish/full_manuscript.md \
  --reference-doc=publish/reference.docx \
  -o publish/full_manuscript.docx
```

PDF 변환에서 한글 폰트 문제가 있으면 다음 방식을 우선 고려합니다.

```text
Markdown → DOCX → Word 또는 한글에서 PDF 저장
```

---

## 19. 변환 결과 검수

변환 후 다음 항목을 확인합니다.

```text
- 제목 레벨이 제대로 적용되었는가?
- 목차가 정상 생성되는가?
- 표가 페이지 밖으로 넘치지 않는가?
- 코드 블록 줄바꿈이 적절한가?
- 이미지가 누락되지 않았는가?
- SVG가 정상 표시되는가?
- 한글 폰트가 깨지지 않는가?
- 그림 캡션이 유지되는가?
- 체크박스가 정상 표시되는가?
```

기록 파일:

```text
notes/publish_conversion_review.md
```

---

## 20. 독자용 실습 코드 공개 저장소 분리

출판용 private 저장소와 독자용 public 저장소는 분리하는 것이 좋습니다.

공개 저장소에 포함할 항목:

```text
- code/chapterXX/
- 실습용 README
- 공개 가능한 sample data
- requirements.txt
- .env.example
- 필요한 images 일부
```

공개 저장소에서 제외할 항목:

```text
- book/ 원고 전체
- notes/ 내부 작업 기록
- publish/ 출판 원고
- private 편집 자료
- 실제 실행 산출물
- 비공개 데이터
- 인증 정보
```

공개 전 점검:

```text
- 보안 키워드 스캔
- .env 파일 없음 확인
- 로그 파일 없음 확인
- 실행 산출물 없음 확인
- README 실행 명령 검증
```

---

## 21. 새 책 제작용 프롬프트 템플릿

새로운 주제를 정한 후 다음 프롬프트로 작업을 시작할 수 있습니다.

```text
새로운 eBook 교재를 만들고 싶습니다.
주제는 [주제명]입니다.
대상 독자는 [대상 독자]입니다.
최종 목표는 [독자가 만들거나 할 수 있어야 하는 것]입니다.

book_authoring_guide.md 절차에 따라 다음을 진행해 주세요.
1. 책 제목과 부제 제안
2. 대상 독자 정의
3. 전체 Part 구조 제안
4. 15개 Chapter 목차 제안
5. 각 Chapter별 학습 목표 제안
6. 최종 프로젝트 제안
7. 저장소 구조 제안
```

Chapter 생성용 프롬프트:

```text
Chapter XX 작업을 진행해 주세요.
book_authoring_guide.md 절차에 따라 다음 순서로 진행합니다.
1. Chapter 구성 설계
2. 원고 초안 작성
3. 실습 코드 작성
4. 도식 제작
5. 도식 본문 삽입 확인
6. 원고 1차 리뷰 및 보완
7. 실습 코드 실행 검토
8. 최종 점검 및 1차 완료 처리
```

---

## 22. 최종 배포 체크리스트

```text
- [ ] README에 전체 Chapter 상태가 정리되어 있는가?
- [ ] 모든 Chapter가 1차 완료 상태인가?
- [ ] 전체 원고 통합 점검이 완료되었는가?
- [ ] 출판 전 원고/코드 통합 리뷰가 완료되었는가?
- [ ] publish/full_manuscript.md가 생성되었는가?
- [ ] Word 변환이 완료되었는가?
- [ ] PDF 변환이 완료되었는가?
- [ ] 이미지와 도식이 정상 표시되는가?
- [ ] 코드 블록과 표가 깨지지 않는가?
- [ ] 실습 코드가 실행 검증되었는가?
- [ ] 보안 정보가 포함되지 않았는가?
- [ ] 독자용 공개 저장소가 분리되었는가?
```

---

## 23. 이 방법론으로 만들 수 있는 산출물

이 절차를 따르면 최종적으로 다음 산출물을 만들 수 있습니다.

```text
- Chapter별 Markdown 원고
- Chapter별 실습 코드
- Chapter별 도식 SVG
- 작업 및 리뷰 기록
- 통합 Markdown 원고
- Word 원고
- PDF eBook
- 독자용 실습 코드 저장소
```

---

## 24. 최종 정리

이 방법론의 핵심은 다음입니다.

```text
새로운 주제를 정한다.
학습 여정을 설계한다.
Chapter별로 원고, 코드, 도식을 만든다.
리뷰 기록을 남긴다.
전체 원고를 통합한다.
출판 가능한 eBook으로 변환한다.
```

즉, `book_authoring_guide.md`는 새로운 책을 만들 때 반복 사용할 수 있는 교재 제작 운영 매뉴얼입니다.

새 주제와 대상 독자만 바꾸면 같은 절차로 새로운 실습형 eBook을 제작할 수 있습니다.
