from __future__ import annotations

from io import BytesIO
from pathlib import Path
import re

import markdown
from PIL import Image
from publication_svg_utils import svg2png

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter01" / "chapter01.md"
HTML_PATH = ROOT / "book" / "chapter01" / "chapter01.html"
IMAGE_DIR = ROOT / "images" / "chapter01"

FIGURES = [
    ("ch01_01_storage_options.svg", "ch01_01_storage_options.jpg"),
    ("ch01_04_ai_result_verification_cycle.svg", "ch01_04_ai_result_verification_cycle.jpg"),
]


def convert_svg_to_jpg(svg_name: str, jpg_name: str) -> None:
    svg_path = IMAGE_DIR / svg_name
    jpg_path = IMAGE_DIR / jpg_name
    if not svg_path.exists():
        raise FileNotFoundError(svg_path)

    png_bytes = svg2png(url=str(svg_path), output_width=1600)
    with Image.open(BytesIO(png_bytes)) as source:
        source = source.convert("RGBA")
        background = Image.new("RGBA", source.size, "white")
        background.alpha_composite(source)
        rgb = background.convert("RGB")
        rgb.save(jpg_path, "JPEG", quality=94, optimize=True, progressive=True)
    print(f"Generated {jpg_path}")


def figureize(html: str) -> str:
    pattern = re.compile(
        r'<p><img alt="([^"]*)" src="([^"]+\.jpg)" /></p>\s*<p>(그림 1-\d+[^<]*)</p>',
        re.MULTILINE,
    )
    return pattern.sub(
        lambda m: (
            f'<figure class="figure"><img src="{m.group(2)}" alt="{m.group(1)}">'
            f'<figcaption>{m.group(3)}</figcaption></figure>'
        ),
        html,
    )


def build_html() -> None:
    source = MD_PATH.read_text(encoding="utf-8")
    lines = source.splitlines()
    if not lines or not lines[0].startswith("# Chapter 01."):
        raise RuntimeError("Unexpected Chapter 01 title")

    body_md = "\n".join(lines[1:]).lstrip()
    if body_md.startswith("---"):
        body_md = body_md[3:].lstrip()

    body_md = body_md.replace(
        "../../images/chapter01/ch01_01_storage_options.svg",
        "../../images/chapter01/ch01_01_storage_options.jpg",
    ).replace(
        "../../images/chapter01/ch01_04_ai_result_verification_cycle.svg",
        "../../images/chapter01/ch01_04_ai_result_verification_cycle.jpg",
    )

    rendered = markdown.markdown(
        body_md,
        extensions=["fenced_code", "tables", "sane_lists"],
        output_format="html5",
    )
    rendered = figureize(rendered)

    title = "AI 시대에 데이터베이스를 왜 배워야 하는가"
    document = f'''<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Chapter 01 · {title}</title>
<link rel="stylesheet" href="../../assets/css/book.css">
<link rel="stylesheet" href="../../assets/css/print.css" media="print">
</head>
<body>
<main>
<header class="page hero">
  <div class="eyebrow">Chapter 01 · Why Databases Still Matter</div>
  <h1>{title}</h1>
  <p class="hero-lead">AI가 SQL과 데이터베이스 코드의 초안을 빠르게 만들 수 있는 시대입니다. 그래서 더 중요한 것은 문법을 많이 외우는 일이 아니라 <strong>데이터의 의미와 관계를 이해하고, 실행 결과가 실제 요구사항과 맞는지 검증하는 능력</strong>입니다.</p>
  <div class="tag-row"><span class="tag">AI 결과 검증</span><span class="tag">업무 규칙</span><span class="tag">정확한 SQL</span><span class="tag">데이터 구조</span><span class="tag">DBMS 선택</span></div>
  <div class="hero-question">AI가 SQL과 데이터베이스 코드를 작성해 준다면,<br>사람은 무엇을 이해하고 무엇을 검증해야 하는가?</div>
</header>
<div class="page content">
{rendered}
<div class="footer-next"><b>다음 장에서는</b><span>Chapter 02에서 데이터와 DBMS의 기본 개념을 배우고, 이후 PostgreSQL 실습을 위한 기초 언어를 정리합니다.</span></div>
</div>
</main>
</body>
</html>
'''
    HTML_PATH.write_text(document, encoding="utf-8")
    print(f"Generated {HTML_PATH}")


if __name__ == "__main__":
    for svg_name, jpg_name in FIGURES:
        convert_svg_to_jpg(svg_name, jpg_name)
    build_html()
