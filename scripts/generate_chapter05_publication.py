from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter05" / "chapter05.md"
HTML_PATH = ROOT / "book" / "chapter05" / "chapter05.html"
IMAGE_DIR = ROOT / "images" / "chapter05"

TITLE = "Chapter 05. 요구사항에서 데이터 모델과 ERD 만들기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter05/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 05\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 05 · Data Modeling &amp; ERD</div>
  <h1>요구사항에서 데이터 모델과 ERD 만들기</h1>
  <p class="hero-lead">실제 프로젝트에서는 테이블이 먼저 주어지지 않습니다. 이번 장에서는 <strong>업무 요구사항에서 관리 대상·속성·사건을 찾고, 각 테이블의 한 행 의미와 관계를 정의한 뒤 ERD와 PostgreSQL 구조로 연결</strong>합니다.</p>
  <div class="tag-row"><span class="tag">요구사항 분석</span><span class="tag">엔터티</span><span class="tag">속성</span><span class="tag">카디널리티</span><span class="tag">ERD</span><span class="tag">추적성</span></div>
  <div class="hero-question">요구사항의 어떤 문장이 테이블·열·관계가 되는가?<br>그리고 그 설계가 실제 업무 규칙을 빠짐없이 표현하는지 어떻게 검증할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>Chapter 05에서 만든 모델을 정규화하고, <code>UNIQUE</code>·<code>CHECK</code>·외래키 같은 제약조건과 <code>ALTER TABLE</code>을 사용해 더 안전한 데이터베이스 구조로 발전시킵니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 05 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
