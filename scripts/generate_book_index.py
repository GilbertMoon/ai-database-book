from __future__ import annotations

from html import escape
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
INDEX_PATH = BOOK_DIR / "index.html"

STAGES = [
    ("STAGE 1 · CHAPTER 01–04", "데이터베이스 기초", range(1, 5)),
    ("STAGE 2 · CHAPTER 05–07", "좋은 데이터 구조", range(5, 8)),
    ("STAGE 3 · CHAPTER 08–12", "조회와 안정적 운영", range(8, 13)),
    ("STAGE 4 · CHAPTER 13–15", "AI와 분석으로 확장", range(13, 16)),
]


def chapter_title(number: int) -> str:
    md_path = BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.md"
    if not md_path.exists():
        raise FileNotFoundError(f"missing chapter manuscript: {md_path}")
    first_line = md_path.read_text(encoding="utf-8").splitlines()[0].strip()
    match = re.match(r"^#\s+Chapter\s+\d+\.\s*(.+)$", first_line)
    if not match:
        raise RuntimeError(f"unexpected chapter title line: {first_line}")
    return match.group(1).strip()


def chapter_card(number: int) -> str:
    title = chapter_title(number)
    html_rel = f"chapter{number:02d}/chapter{number:02d}.html"
    html_path = BOOK_DIR / html_rel
    status = "출판 HTML 준비 완료" if html_path.exists() else "출판 HTML 준비 중"
    action = (
        f'<a href="{html_rel}">Chapter {number:02d} 열기</a>'
        if html_path.exists()
        else '<span class="small">Markdown 원고 있음 · HTML 제작 대기</span>'
    )
    return f'''<article class="chapter">
  <b>CHAPTER {number:02d} · {status}</b>
  <span>{escape(title)}</span>
  <p class="small">{action}</p>
</article>'''


def build_index() -> str:
    available = [
        number
        for number in range(1, 16)
        if (BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.html").exists()
    ]
    total = 15

    stage_html: list[str] = []
    for label, title, numbers in STAGES:
        cards = "\n".join(chapter_card(number) for number in numbers)
        stage_html.append(f'''<section>
  <div class="stage-label">{label}</div>
  <h2 class="section-title">{title}</h2>
  <div class="chapter-grid">
{cards}
  </div>
</section>''')

    stages = "\n".join(stage_html)
    return f'''<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>AI 시대의 데이터베이스 입문 · 출판용 목차</title>
<link rel="stylesheet" href="../assets/css/book.css">
<link rel="stylesheet" href="../assets/css/print.css" media="print">
</head>
<body>
<main>
<header class="page hero">
  <div class="eyebrow">Publication Book Index</div>
  <h1>AI 시대의 데이터베이스 입문</h1>
  <h2>출판용 HTML 목차</h2>
  <p class="lead">이 페이지는 책 전체의 출판용 진입점입니다. <strong>Overview와 Chapter 01~15의 원고 상태를 한곳에서 확인하고, 준비된 출판 HTML로 바로 이동</strong>할 수 있습니다.</p>
  <div class="tag-row">
    <span class="tag">Overview 준비 완료</span>
    <span class="tag">Chapter HTML {len(available)}/{total}</span>
    <span class="tag">공통 CSS</span>
    <span class="tag">A4/PDF 준비</span>
  </div>
</header>

<div class="page">
<section>
  <h2 class="section-title">책을 시작하기 전에</h2>
  <div class="cards">
    <article class="card">
      <div class="card-num">OVERVIEW</div>
      <h3>이 책을 시작하기 전에</h3>
      <p>독자, AI 활용 원칙, 전체 학습 로드맵과 Chapter 01~15의 연결 구조를 먼저 확인합니다.</p>
      <p><a href="overview/overview.html">Overview 열기</a></p>
    </article>
    <article class="card">
      <div class="card-num">PUBLICATION STATUS</div>
      <h3>출판 HTML {len(available)} / {total}</h3>
      <p>원고 Markdown은 전체 15개 Chapter를 유지하고, 출판 HTML은 준비가 끝난 장부터 순차적으로 활성화합니다.</p>
    </article>
  </div>
  <div class="note">
    <div class="note-title">Source of Truth 원칙</div>
    <p>출판용 HTML은 공통 <code>book.css</code>와 <code>print.css</code>를 사용합니다. PDF를 직접 수정하지 않고 HTML·CSS·이미지·코드 원본을 수정한 뒤 다시 빌드하는 방식을 기준으로 합니다.</p>
  </div>
</section>

{stages}

<section>
  <h2 class="section-title">프로젝트 학습 흐름</h2>
  <div class="flow-box">Chapter 07 프로젝트 완성 → Chapter 13 AI·실행 증거 검증 → Chapter 15 종합 프로젝트</div>
  <p>각 Chapter의 HTML이 추가되면 이 목차를 다시 생성해 링크 상태를 갱신합니다.</p>
</section>

<div class="footer-cta">
  <b>출판 제작의 기준 페이지</b>
  <span>이 페이지에서 Overview와 모든 Chapter를 연결한 뒤, 다음 단계에서 전체 Source QA와 PDF 빌드 파이프라인을 연결합니다.</span>
</div>
</div>
</main>
</body>
</html>
'''


def main() -> None:
    for number in range(1, 16):
        chapter_title(number)
    INDEX_PATH.write_text(build_index(), encoding="utf-8")
    print(f"Generated {INDEX_PATH}")


if __name__ == "__main__":
    main()
