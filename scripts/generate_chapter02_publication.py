from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter02" / "chapter02.md"
HTML_PATH = ROOT / "book" / "chapter02" / "chapter02.html"
IMAGE_DIR = ROOT / "images" / "chapter02"

TITLE = "Chapter 02. 데이터와 DBMS의 기본 개념"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter02/([^\s)]+\.svg)", md_text)))


def render_svg_to_jpg(svg_name: str) -> Path:
    svg_path = IMAGE_DIR / svg_name
    if not svg_path.exists():
        raise FileNotFoundError(svg_path)
    png_bytes = cairosvg.svg2png(url=str(svg_path), output_width=1600)
    with Image.open(io.BytesIO(png_bytes)) as image:
        rgb = Image.new("RGB", image.size, "white")
        if image.mode == "RGBA":
            rgb.paste(image, mask=image.getchannel("A"))
        else:
            rgb.paste(image.convert("RGB"))
        out_path = svg_path.with_suffix(".jpg")
        rgb.save(out_path, "JPEG", quality=92, optimize=True, progressive=True)
    return out_path


def make_html(md_text: str, image_names: list[str]) -> str:
    body_md = re.sub(r"^# Chapter 02\..*?\n", "", md_text, count=1)
    for name in image_names:
        body_md = body_md.replace(name, Path(name).with_suffix(".jpg").name)
    body = markdown.markdown(
        body_md,
        extensions=["fenced_code", "tables", "sane_lists"],
        output_format="html5",
    )
    return f'''<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{TITLE}</title>
<link rel="stylesheet" href="../../assets/css/book.css">
<link rel="stylesheet" href="../../assets/css/print.css" media="print">
</head>
<body>
<main>
<header class="page hero">
  <div class="eyebrow">Chapter 02 · Data and DBMS Fundamentals</div>
  <h1>데이터와 DBMS의 기본 개념</h1>
  <p class="hero-lead">SQL을 제대로 이해하려면 명령어보다 먼저 <strong>데이터가 어디에 저장되고, DBMS가 무엇을 관리하며, 서버·데이터베이스·스키마·테이블·행과 열이 어떻게 이어지는지</strong>를 정확히 구분할 수 있어야 합니다.</p>
  <div class="tag-row"><span class="tag">데이터</span><span class="tag">Database</span><span class="tag">DBMS</span><span class="tag">PostgreSQL 계층</span><span class="tag">행·열·셀</span><span class="tag">PK·FK</span></div>
  <div class="hero-question">지금 보고 있는 것은 데이터인가, 데이터베이스인가, DBMS인가?<br>그리고 한 행은 정확히 무엇을 의미하는가?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>PostgreSQL과 DBeaver를 설치하고 연결한 뒤, 지금 배운 서버·데이터베이스·스키마 구조를 실제 환경에서 확인합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 02 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
