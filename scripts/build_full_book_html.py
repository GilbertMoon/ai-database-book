from __future__ import annotations

from html import escape
import os
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
PUBLISH_DIR = ROOT / "publish"
OUTPUT_PATH = PUBLISH_DIR / "ai_database_book.html"
CHAPTER_COUNT = 15

STAGES = [
    ("STAGE 1 · CHAPTER 01–04", "데이터베이스 기초", range(1, 5)),
    ("STAGE 2 · CHAPTER 05–07", "좋은 데이터 구조", range(5, 8)),
    ("STAGE 3 · CHAPTER 08–12", "조회와 안정적 운영", range(8, 13)),
    ("STAGE 4 · CHAPTER 13–15", "AI와 분석으로 확장", range(13, 16)),
]

EXTERNAL_PREFIXES = (
    "http://",
    "https://",
    "mailto:",
    "tel:",
    "data:",
    "javascript:",
    "//",
)


def chapter_title(number: int) -> str:
    md_path = BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.md"
    first = md_path.read_text(encoding="utf-8").splitlines()[0].strip()
    match = re.match(r"^#\s+Chapter\s+\d+\.\s*(.+)$", first)
    if not match:
        raise RuntimeError(f"Unexpected chapter title: {first}")
    return match.group(1).strip()


def extract_main(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"<main(?:\s[^>]*)?>(.*)</main>", text, flags=re.I | re.S)
    if not match:
        raise RuntimeError(f"<main> not found: {path.relative_to(ROOT)}")
    return match.group(1).strip()


def rewrite_reference(value: str, source_path: Path) -> str:
    lowered = value.lower()
    if value.startswith("#") or lowered.startswith(EXTERNAL_PREFIXES):
        return value

    parsed = urlsplit(value)
    if parsed.scheme or parsed.netloc or not parsed.path:
        return value

    target = (source_path.parent / unquote(parsed.path)).resolve()
    try:
        target.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise RuntimeError(
            f"Reference escapes repository: {source_path.relative_to(ROOT)} -> {value}"
        ) from exc

    if not target.exists():
        raise FileNotFoundError(
            f"Broken source reference: {source_path.relative_to(ROOT)} -> {value}"
        )

    rel = os.path.relpath(target, OUTPUT_PATH.parent).replace(os.sep, "/")
    return urlunsplit(("", "", rel, parsed.query, parsed.fragment))


def rewrite_fragment(fragment: str, source_path: Path) -> str:
    pattern = re.compile(
        r"(?P<attr>href|src)=(?P<quote>[\"'])(?P<value>.*?)(?P=quote)",
        flags=re.I,
    )

    def replace(match: re.Match[str]) -> str:
        value = rewrite_reference(match.group("value"), source_path)
        return f'{match.group("attr")}={match.group("quote")}{value}{match.group("quote")}'

    return pattern.sub(replace, fragment)


def source_units() -> list[tuple[str, str, Path]]:
    units: list[tuple[str, str, Path]] = [
        ("overview", "이 책을 시작하기 전에", BOOK_DIR / "overview" / "overview.html")
    ]
    for number in range(1, CHAPTER_COUNT + 1):
        units.append(
            (
                f"chapter{number:02d}",
                f"Chapter {number:02d}. {chapter_title(number)}",
                BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.html",
            )
        )
    return units


def toc_html() -> str:
    blocks = [
        '<div class="page book-toc">',
        '  <div class="eyebrow">Table of Contents</div>',
        '  <h1>목차</h1>',
        '  <div class="chapter-grid">',
        '    <article class="chapter">',
        '      <b>OVERVIEW</b>',
        '      <span>이 책을 시작하기 전에</span>',
        '      <p class="small"><a href="#overview">Overview</a></p>',
        '    </article>',
        '  </div>',
    ]

    for stage_label, stage_title, numbers in STAGES:
        blocks.extend(
            [
                f'  <div class="stage-label">{escape(stage_label)}</div>',
                f'  <h2 class="section-title">{escape(stage_title)}</h2>',
                '  <div class="chapter-grid">',
            ]
        )
        for number in numbers:
            title = chapter_title(number)
            blocks.extend(
                [
                    '    <article class="chapter">',
                    f'      <b>CHAPTER {number:02d}</b>',
                    f'      <span>{escape(title)}</span>',
                    f'      <p class="small"><a href="#chapter{number:02d}">Chapter {number:02d}</a></p>',
                    '    </article>',
                ]
            )
        blocks.append('  </div>')

    blocks.append('</div>')
    return "\n".join(blocks)


def build_html() -> str:
    unit_blocks: list[str] = []
    for unit_id, label, path in source_units():
        if not path.exists():
            raise FileNotFoundError(path)
        fragment = rewrite_fragment(extract_main(path), path)
        unit_blocks.append(
            f'<!-- {escape(label)} -->\n<div class="book-unit" id="{unit_id}">\n{fragment}\n</div>'
        )

    cover = '''<header class="page hero book-cover">
  <div class="eyebrow">Publication Edition · Full Book</div>
  <h1>AI 시대의 데이터베이스 입문</h1>
  <h2>ChatGPT와 Codex로 배우는 PostgreSQL, SQL, 데이터 설계와 분석</h2>
  <p class="hero-lead">Overview부터 Chapter 15까지의 출판용 HTML을 하나의 A4 인쇄본으로 연결한 통합본입니다. <strong>요구사항과 데이터 모델링에서 시작해 SQL, 트랜잭션, 인덱스, 보안·복구, AI 검증과 Python 분석까지</strong> 한 흐름으로 이어집니다.</p>
  <div class="tag-row"><span class="tag">PostgreSQL</span><span class="tag">SQL</span><span class="tag">ERD·정규화</span><span class="tag">트랜잭션·인덱스</span><span class="tag">보안·복구</span><span class="tag">AI·Python</span></div>
</header>'''

    return f'''<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>AI 시대의 데이터베이스 입문 · 통합 출판본</title>
<link rel="stylesheet" href="../assets/css/book.css">
<link rel="stylesheet" href="../assets/css/print.css" media="print">
</head>
<body>
<main class="full-book">
{cover}
{toc_html()}
{chr(10).join(unit_blocks)}
</main>
</body>
</html>
'''


def main() -> None:
    PUBLISH_DIR.mkdir(parents=True, exist_ok=True)
    html = build_html()
    if "Source of Truth" in html:
        raise RuntimeError("Development-only Source of Truth note remains in full-book HTML")
    if re.search(r"(?:href|src)=[\"'][^\"']+\.svg(?:[?#][^\"']*)?[\"']", html, flags=re.I):
        raise RuntimeError("SVG reference remains in full-book HTML")
    for number in range(1, CHAPTER_COUNT + 1):
        if f'id="chapter{number:02d}"' not in html:
            raise RuntimeError(f"Chapter {number:02d} anchor missing")
    OUTPUT_PATH.write_text(html, encoding="utf-8")
    print(f"Generated: {OUTPUT_PATH}")
    print("Included: Overview + Chapter 01~15")


if __name__ == "__main__":
    main()
