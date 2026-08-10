# Chapter 02 출판용 구현

Chapter 02는 원고 Markdown과 별도로 브라우저·PDF 변환용 출판형 HTML을 제공합니다.

- `chapter02.md`: 통합 원고에 사용하는 Markdown 원본
- `chapter02.html`: 최종 출판형 HTML

`chapter02.html`은 `scripts/generate_chapter02_publication.py`가 Markdown 원본을 읽어 생성합니다. 원고 내용을 HTML에 따로 복사해 관리하지 않고, Markdown을 기준으로 다시 만들 수 있습니다.

## 출판형 HTML 특징

- Overview·Chapter 01과 같은 네이비·블루 계열 디자인 시스템
- Chapter 표지형 첫 페이지
- A4 인쇄/PDF용 `@media print` 스타일
- 모바일 화면 대응
- 표·코드·인용문·목록의 출판용 스타일
- 원본 Markdown의 전체 절과 핵심 설명 유지
- 본문에서 실제 참조하는 SVG만 자동 탐지해 JPG로 변환

## JPG 도식

현재 Chapter 02 본문에서 사용하는 출판용 JPG는 5개입니다.

```text
../../images/chapter02/ch02_02_table_row_column.jpg
../../images/chapter02/ch02_03_primary_key_concept.jpg
../../images/chapter02/ch02_04_foreign_key_relationship.jpg
../../images/chapter02/ch02_05_relationship_types.jpg
../../images/chapter02/ch02_08_ai_table_review.jpg
```

각 JPG는 기존 최종 SVG를 1600px 폭으로 렌더링한 출판용 사본입니다. SVG는 편집 원본으로 계속 유지합니다. 발표 전용 또는 현재 본문에서 사용하지 않는 SVG는 JPG로 만들지 않습니다.

## 로컬 미리보기

저장소 루트에서 다음을 실행합니다.

```bash
python -m http.server 8000
```

브라우저에서 다음 주소를 엽니다.

```text
http://localhost:8000/book/chapter02/chapter02.html
```

PDF 제작 전에는 Chrome 또는 Edge 인쇄 미리보기에서 A4, 배경 그래픽 포함, 표의 열 너비, 코드 줄바꿈, 그림과 캡션의 페이지 나눔을 확인합니다.

## 재생성

필요한 Python 패키지는 `markdown`, `cairosvg`, `Pillow`입니다.

```bash
python scripts/generate_chapter02_publication.py
```

이 명령은 `chapter02.html`과 현재 Markdown에서 실제 참조하는 Chapter 02 JPG 파일을 다시 생성합니다.
