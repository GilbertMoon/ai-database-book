# publish/

이 폴더는 출판용 통합 산출물을 관리합니다.

주요 산출물:

```text
publish/full_manuscript.md
publish/ai_database_book.html
publish/ai_database_book.pdf
publish/full_book_source_qa_report.txt
publish/book_pdf_qa_report.txt
```

원칙:

```text
- Chapter별 원고의 기준은 book/chapterXX/chapterXX.md이다.
- 출판 레이아웃의 Source of Truth는 book/overview/overview.html과 book/chapter01~15/chapterXX.html이다.
- publish/ai_database_book.html은 위 출판 HTML을 scripts/build_full_book_html.py로 합쳐 생성한다.
- publish/ai_database_book.pdf는 통합 HTML을 Chromium 인쇄 엔진으로 A4 PDF 변환해 생성한다.
- PDF를 직접 수정하지 않고 HTML·CSS·이미지를 수정한 뒤 다시 빌드한다.
- PDF 생성 전 전체 Source QA를 통과해야 한다.
- PDF 생성 후 페이지 수, A4 크기, 텍스트 레이어와 첫/중간/마지막 페이지 렌더링을 검증한다.
```

자동화:

```text
.github/workflows/full-book-source-qa.yml
.github/workflows/build-full-book-pdf.yml
```
