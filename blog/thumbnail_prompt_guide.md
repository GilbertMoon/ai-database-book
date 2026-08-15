# AI 시대의 데이터베이스 입문 · 썸네일 이미지 생성 프롬프트 가이드

이 문서는 `blog/thumbnail_guide.md`에 정리된 Chapter 01~15의 문구를 실제 썸네일 이미지로 제작하기 위한 **공통 디자인 사양과 이미지 생성 프롬프트**입니다.

문구 자체는 [`thumbnail_guide.md`](thumbnail_guide.md)를 기준으로 하고, 이 문서는 **이미지 스타일·레이아웃·Chapter별 시각 소재·생성 프롬프트**에 집중합니다.

---

# 1. 제작 방식

썸네일은 다음 방식으로 제작하는 것을 권장합니다.

```text
1. AI로 텍스트 없는 배경 일러스트를 생성한다.
2. Chapter 번호와 제목은 Canva, PowerPoint, Figma 등에서 별도로 올린다.
3. 15개 Chapter에 동일한 레이아웃을 적용한다.
4. Chapter마다 우측 핵심 일러스트만 바꾼다.
```

AI 이미지 생성 단계에서 한글을 직접 넣으면 글자가 틀릴 수 있으므로 **배경 이미지는 텍스트 없이 생성하고, 한글 제목은 후처리로 삽입**하는 방식을 기본으로 합니다.

---

# 2. 공통 출력 사양

## 기본 캔버스

```text
정사각형 1:1
작업 기준: 1200 × 1200 px
최종 저장: JPG 또는 PNG
```

※ `1200 × 1200`은 이 시리즈를 통일하기 위한 내부 제작 기준입니다.

## 안전 영역

```text
상단 8%       : 시리즈 작은 문구
좌측 8~58%    : Chapter 번호 + 메인 제목
우측 55~94%   : Chapter 핵심 일러스트
하단 84~94%   : ChatGPT · Codex · PostgreSQL
```

핵심 제목은 썸네일 중앙을 기준으로 **좌측 영역에 크게 배치**합니다.

우측 일러스트는 제목을 침범하지 않도록 충분한 여백을 둡니다.

---

# 3. 전체 시리즈 공통 비주얼 콘셉트

## 스타일

```text
modern premium technology education illustration
clean editorial design
minimal 3D / isometric hybrid illustration
soft depth and subtle glow
professional, academic, trustworthy
not childish
not overly futuristic
```

## 분위기

- AI와 데이터베이스 기술을 다루지만 지나치게 SF처럼 만들지 않습니다.
- 기업 교육·대학교 강의·실무 기술 도서에 모두 사용할 수 있는 전문적인 분위기를 유지합니다.
- 복잡한 배경보다 **한눈에 개념이 보이는 단순한 핵심 오브젝트**를 사용합니다.
- 15개 이미지를 나란히 보았을 때 하나의 교육 시리즈로 보이도록 합니다.

## 색감

기본 톤:

```text
deep navy / dark blue background
soft indigo and violet gradient
cyan / electric blue accent
subtle white highlights
```

Chapter마다 색을 완전히 바꾸지 않고, 동일한 기본 색상 체계에서 포인트만 조금씩 변경합니다.

---

# 4. 공통 레이아웃

```text
┌──────────────────────────────┐
│ 아토믹데브 인공지능 개발도서 시리즈       │
│                              │
│ AI 시대의 데이터베이스 입문              │
│                              │
│ 01               [일러스트]  │
│ AI 시대에도                  │
│ 데이터베이스를               │
│ 배워야 할까?                 │
│                              │
│ ChatGPT · Codex · PostgreSQL │
└──────────────────────────────┘
```

공통 원칙:

- Chapter 번호는 크게 표시합니다.
- Chapter 번호는 `01`~`15` 두 자리로 통일합니다.
- 제목은 2~3줄을 기본으로 합니다.
- 오른쪽은 핵심 개념 일러스트 영역으로 사용합니다.
- 배경에 의미 없는 코드나 영문 문장을 잔뜩 넣지 않습니다.
- 출판사 로고나 전자도서 로고는 넣지 않습니다.

---

# 5. 이미지 생성 공통 프롬프트

각 Chapter 프롬프트 앞에 아래 공통 프롬프트를 붙여 사용합니다.

```text
Create a square 1:1 premium technology education thumbnail background for a Korean database and AI course series.

Visual style: modern editorial technology illustration, clean minimal 3D and isometric hybrid, professional university and corporate training aesthetic, deep navy background with subtle indigo-violet gradient, cyan and electric-blue highlights, soft depth, refined lighting, crisp shapes, high readability.

Composition: reserve the left 55 percent as clean negative space for Korean title typography that will be added later. Place the main conceptual illustration on the right side. Keep the top and bottom edges visually quiet for small series text and technology keywords.

Do not render any Korean or English text. Do not add logos, watermarks, publisher marks, random letters, fake UI text, or illegible code. Avoid clutter, cartoon style, childish characters, excessive neon, cyberpunk city imagery, photorealistic people, and busy backgrounds.

The image must feel like one chapter of a consistent 15-part professional educational series.
```

이 공통 프롬프트 뒤에 Chapter별 프롬프트를 이어 붙입니다.

---

# 6. Chapter 01

## 썸네일 문구

```text
01
AI 시대에도
데이터베이스를
배워야 할까?
```

## 핵심 시각 소재

```text
AI chip + database cylinder + human verification check
```

## Chapter별 추가 프롬프트

```text
On the right side, show an elegant AI processor symbol connected to a structured database cylinder. Add a subtle verification checkmark or validation layer between AI output and the database, visually communicating that AI can generate SQL but humans still need to understand and verify data. Keep the concept simple and instantly readable.
```

---

# 7. Chapter 02

## 썸네일 문구

```text
02
데이터베이스와
DBMS는
무엇이 다를까?
```

## 핵심 시각 소재

```text
data → database → DBMS → table structure
```

## Chapter별 추가 프롬프트

```text
On the right side, illustrate a clean hierarchy of data objects: small data blocks flowing into a database cylinder, then into organized table grids managed by a central DBMS layer. Show the relationship between raw data, database, database management system, tables, rows, and columns using simple connected shapes without any labels.
```

---

# 8. Chapter 03

## 썸네일 문구

```text
03
PostgreSQL
실습 환경
직접 만들기
```

## 핵심 시각 소재

```text
computer + PostgreSQL database + database client connection
```

## Chapter별 추가 프롬프트

```text
On the right side, show a desktop development workstation connected to a PostgreSQL-style database cylinder and a clean database client window. Emphasize the idea of installing, connecting, and successfully running a first database query. Use simple UI-like shapes with no readable text.
```

---

# 9. Chapter 04

## 썸네일 문구

```text
04
SQL로
데이터를 직접
다뤄보자
```

## 핵심 시각 소재

```text
table rows + CRUD actions
```

## Chapter별 추가 프롬프트

```text
On the right side, show a database table grid with rows being added, selected, modified, and removed through four clear visual actions. Represent CRUD with elegant icons and motion cues rather than words. Make the database table the central object.
```

---

# 10. Chapter 05

## 썸네일 문구

```text
05
요구사항에서
ERD를
만드는 방법
```

## 핵심 시각 소재

```text
requirements cards → entities → ERD relationships
```

## Chapter별 추가 프롬프트

```text
On the right side, show several simple requirement cards transforming into structured entity boxes connected by clean relationship lines. Emphasize the transition from business requirements to an ERD. Include subtle key and relationship symbols without text.
```

---

# 11. Chapter 06

## 썸네일 문구

```text
06
좋은 테이블은
어떻게
설계할까?
```

## 핵심 시각 소재

```text
messy table → normalized clean tables
```

## Chapter별 추가 프롬프트

```text
On the right side, illustrate one cluttered oversized table being reorganized into three clean related tables. Use visual arrows to show normalization and improved structure. Add subtle integrity symbols such as a shield, checkmark, and key without labels.
```

---

# 12. Chapter 07

## 썸네일 문구

```text
07
수강신청 DB
직접
완성하기
```

## 핵심 시각 소재

```text
students + courses + enrollments database
```

## Chapter별 추가 프롬프트

```text
On the right side, show a small online course enrollment system represented by student icons, course cards, instructor elements, and a central enrollment database. Connect them with clear relational lines. The result should look like a complete mini database project rather than a generic learning platform.
```

---

# 13. Chapter 08

## 썸네일 문구

```text
08
JOIN과 집계로
서비스 질문에
답하기
```

## 핵심 시각 소재

```text
multiple tables → JOIN → summary chart
```

## Chapter별 추가 프롬프트

```text
On the right side, show two or three database tables visually joining into one combined dataset, then flowing into a compact summary chart or KPI cards. Communicate JOIN, grouping, counting, and aggregation through structure and visual flow without any words.
```

---

# 14. Chapter 09

## 썸네일 문구

```text
09
데이터 변경을
안전하게
처리하는 방법
```

## 핵심 시각 소재

```text
transaction flow + commit + rollback + lock
```

## Chapter별 추가 프롬프트

```text
On the right side, show a transaction sequence moving through several database changes with a safe confirmation path and a rollback path. Include a subtle lock symbol protecting shared data. The illustration should communicate atomic safe updates, commit, rollback, and concurrency control without text.
```

---

# 15. Chapter 10

## 썸네일 문구

```text
10
느린 SQL은
어떻게
찾을까?
```

## 핵심 시각 소재

```text
query path + index + execution plan + speed
```

## Chapter별 추가 프롬프트

```text
On the right side, show a database query traveling through a branching execution path. Contrast a slow full-table path with a fast indexed path using a tree-like structure, magnifier, and speed cue. Keep the concept technical but visually simple.
```

---

# 16. Chapter 11

## 썸네일 문구

```text
11
DB를 안전하게
지키고
복구하는 방법
```

## 핵심 시각 소재

```text
database shield + permissions + backup + restore
```

## Chapter별 추가 프롬프트

```text
On the right side, show a protected database cylinder inside a clean security shield, with small permission keys and a backup copy moving safely to storage and back through a restore arrow. Emphasize database security, least privilege, backup, and recovery.
```

---

# 17. Chapter 12

## 썸네일 문구

```text
12
RDBMS와 NoSQL
무엇을
선택할까?
```

## 핵심 시각 소재

```text
relational tables vs document/key-value storage
```

## Chapter별 추가 프롬프트

```text
On the right side, show a balanced decision visual: structured relational tables and database relations on one side, flexible document or key-value data blocks on the other, connected to a central decision node. Do not make one side look universally better than the other.
```

---

# 18. Chapter 13

## 썸네일 문구

```text
13
AI가 만든 SQL
어떻게
검증할까?
```

## 핵심 시각 소재

```text
AI-generated schema/SQL → tests → metadata → verified result
```

## Chapter별 추가 프롬프트

```text
On the right side, show an AI processor generating structured database objects that pass through multiple verification gates: requirements, test checks, metadata inspection, and final validation. Use layered checkmarks, database structures, and diff-like comparison shapes without readable text.
```

---

# 19. Chapter 14

## 썸네일 문구

```text
14
SQL 분석을
Python으로
확장하기
```

## 핵심 시각 소재

```text
PostgreSQL → dataframe → chart
```

## Chapter별 추가 프롬프트

```text
On the right side, show a database feeding a clean dataframe-like grid and then flowing into a professional analytical chart. Add subtle Python-inspired data analysis visual cues without using logos or text. Emphasize the progression from SQL extraction to dataframe analysis and visualization.
```

---

# 20. Chapter 15

## 썸네일 문구

```text
15
AI 시대의
데이터베이스
종합 프로젝트
```

## 핵심 시각 소재

```text
requirements → ERD → SQL → transaction → index → security → analytics → AI verification
```

## Chapter별 추가 프롬프트

```text
On the right side, create a polished integrated database project ecosystem. Show requirements transforming into an ERD, database tables, safe transactions, indexed query paths, security protection, analytics charts, and a final AI verification layer. Use one cohesive circular or staged workflow rather than many disconnected icons. This should feel like the culmination of the entire 15-part series.
```

---

# 21. 15강 전체 대표 썸네일

## 대표 문구

```text
AI 시대의 데이터베이스 입문
15강 완성 과정

ChatGPT와 Codex로 배우는
PostgreSQL · SQL · 데이터 설계와 분석
```

## 대표 이미지 프롬프트

```text
Create a square 1:1 premium technology education hero thumbnail for a complete 15-part database and AI course.

Use a deep navy and indigo background with refined cyan and violet highlights. Reserve the left half as clean space for title typography to be added later.

On the right side, create one cohesive visual ecosystem combining a database cylinder, relational tables, ERD connections, SQL query flow, transaction safety, index tree, security shield, backup symbol, Python-style analytics chart, and an AI verification processor. The elements should feel integrated into one elegant workflow rather than scattered icons.

Style: professional editorial technology illustration, minimal 3D and isometric hybrid, university and corporate training quality, refined lighting, crisp geometry, modern but not cyberpunk.

No text, no letters, no logos, no watermarks, no fake code, no publisher marks, no photorealistic people, no clutter.
```

---

# 22. 후처리 텍스트 적용 규칙

AI가 생성한 배경 위에 아래 순서로 텍스트를 올립니다.

## 상단

```text
아토믹데브 인공지능 개발도서 시리즈
```

작고 얇게 표시합니다.

## 시리즈명

```text
AI 시대의 데이터베이스 입문
```

Chapter 제목보다 작게 표시합니다.

## Chapter 번호

```text
01
02
...
15
```

두 자리 번호를 크게 표시합니다.

## 메인 제목

`thumbnail_guide.md`의 Chapter별 메인 문구를 그대로 사용합니다.

가장 크고 굵게 표시합니다.

## 하단

```text
ChatGPT · Codex · PostgreSQL
```

작고 일정하게 표시합니다.

---

# 23. 이미지 생성 시 피해야 할 요소

다음 표현은 모든 Chapter에서 제외합니다.

```text
한글 또는 영어 자동 생성 텍스트
잘못된 SQL 문자열
의미 없는 코드 화면
과도한 해커 이미지
후드 쓴 인물
사이버펑크 도시
과도한 네온 효과
캐릭터형 로봇
유아적인 그림체
과도한 아이콘 나열
사진처럼 사실적인 사람 얼굴
브랜드 로고
출판사 로고
전자도서 로고
워터마크
```

특히 AI 관련 Chapter에서도 사람형 로봇보다 **AI processor, data flow, validation system** 같은 추상적인 기술 오브젝트를 우선합니다.

---

# 24. 15개 썸네일 일관성 검수

전체 이미지를 한 화면에 놓고 다음을 확인합니다.

- [ ] 배경 색상 계열이 동일하다.
- [ ] Chapter 번호 위치가 동일하다.
- [ ] 제목 위치와 최대 폭이 동일하다.
- [ ] 우측 일러스트의 크기가 비슷하다.
- [ ] 일러스트 스타일이 모두 같은 계열이다.
- [ ] 어느 Chapter도 지나치게 밝거나 어둡지 않다.
- [ ] 출판사 로고나 전자도서 로고가 없다.
- [ ] AI가 생성한 가짜 글자가 남아 있지 않다.
- [ ] 모바일 크기로 줄여도 Chapter 번호와 제목이 읽힌다.
- [ ] Chapter 01~15를 나열했을 때 한 세트처럼 보인다.

---

# 25. 권장 파일명

최종 이미지 파일은 다음 규칙을 사용합니다.

```text
chapter01_thumbnail.jpg
chapter02_thumbnail.jpg
chapter03_thumbnail.jpg
...
chapter15_thumbnail.jpg
```

대표 썸네일:

```text
database_course_thumbnail.jpg
```

각 Chapter 폴더에 저장할 경우:

```text
blog/chapter01/chapter01_thumbnail.jpg
blog/chapter02/chapter02_thumbnail.jpg
...
blog/chapter15/chapter15_thumbnail.jpg
```

---

# 완료 기준

썸네일 제작 작업은 다음 조건을 모두 만족할 때 완료로 봅니다.

```text
1. Chapter 01~15 배경 이미지 생성
2. 동일한 텍스트 레이아웃 적용
3. Chapter 번호와 제목 오탈자 검수
4. 모바일 축소 화면 확인
5. JPG 또는 PNG 최종 저장
6. 각 Chapter 폴더에 최종 이미지 배치
```

이 기준을 적용하면 15개 게시물이 개별 글이 아니라 **하나의 통일된 「AI 시대의 데이터베이스 입문」 교육 시리즈**로 보이게 됩니다.
