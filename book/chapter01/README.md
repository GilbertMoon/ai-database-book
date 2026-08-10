# Chapter 01 출판용 구현

Chapter 01은 원고 Markdown과 별도로 브라우저·PDF 변환용 출판형 HTML을 제공합니다.

- `chapter01.md`: 통합 원고에 사용하는 Markdown 원본
- `chapter01.html`: 최종 출판형 HTML

`chapter01.html`은 `scripts/generate_chapter01_publication.py`가 Markdown 원본을 읽어 생성합니다. 따라서 출판형 HTML은 원고 내용을 복사해서 별도로 관리하지 않고, 원고를 기준으로 다시 만들 수 있습니다.

## 출판형 HTML 특징

- Overview와 같은 네이비·블루 계열 디자인 시스템
- Chapter 표지형 첫 페이지
- A4 인쇄/PDF용 `@media print` 스타일
- 모바일 화면 대응
- 표·코드·인용문·목록의 출판용 스타일
- 본문에서 실제 사용하는 핵심 도식 2개를 JPG로 표시
- 원본 Markdown의 전체 절과 핵심 문장을 유지

## JPG 도식

출판형 HTML에서 사용하는 JPG는 다음 두 파일입니다.

```text
../../images/chapter01/ch01_01_storage_options.jpg
../../images/chapter01/ch01_04_ai_result_verification_cycle.jpg
```

두 JPG는 기존 최종 SVG를 1600px 폭으로 렌더링한 출판용 사본입니다. SVG·Mermaid 원본은 계속 편집 원본으로 유지합니다.

## 로컬 미리보기

저장소 루트에서 다음을 실행합니다.

```bash
python -m http.server 8000
```

브라우저에서 다음 주소를 엽니다.

```text
http://localhost:8000/book/chapter01/chapter01.html
```

PDF 제작 전에는 Chrome 또는 Edge 인쇄 미리보기에서 A4, 배경 그래픽 포함, 코드 줄바꿈, 표와 그림의 페이지 나눔을 확인합니다.

## 재생성

필요한 Python 패키지는 `markdown`, `cairosvg`, `Pillow`입니다.

```bash
python scripts/generate_chapter01_publication.py
```

이 명령은 `chapter01.html`과 두 JPG 파일을 다시 생성합니다.
