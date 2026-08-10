# Overview 출판용 구현

이 폴더는 Overview의 원고와 최종 출판형 HTML 샘플을 함께 보관합니다.

- `overview.md`: 통합 원고에 사용하는 Markdown 원본
- `overview.html`: 브라우저·PDF 변환용 출판형 HTML

`overview.html`은 외부 CSS 프레임워크 없이 독립 실행되며 다음을 포함합니다.

- 책 제목·부제와 Overview 도입부
- 대상 독자 카드
- AI 활용 원칙
- 네 가지 핵심 역량
- 4단계 전체 학습 로드맵
- Chapter 01~15 전체 구조
- Chapter 07 → 13 → 15 프로젝트 흐름
- 핵심/선택/심화 학습 안내
- 실습 도구와 실습 원칙
- A4 인쇄/PDF용 `@media print` 스타일
- 모바일 화면 대응

사용하는 JPG 자산은 `../../images/overview/`에 있으며 `scripts/generate_overview_jpg.py`로 재생성할 수 있습니다.

## 로컬 미리보기

저장소 루트에서 간단한 HTTP 서버를 실행합니다.

```bash
python -m http.server 8000
```

브라우저에서 다음 경로를 엽니다.

```text
http://localhost:8000/book/overview/overview.html
```

PDF 제작 전에는 Chrome/Edge의 인쇄 미리보기에서 A4, 배경 그래픽 포함, 이미지 축소 가독성과 페이지 나눔을 확인합니다.
