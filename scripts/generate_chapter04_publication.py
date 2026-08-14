from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter04" / "chapter04.md"
HTML_PATH = ROOT / "book" / "chapter04" / "chapter04.html"
IMAGE_DIR = ROOT / "images" / "chapter04"

TITLE = "Chapter 04. 관계형 데이터베이스와 SQL 시작하기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter04/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 04\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 04 · Relational Database &amp; SQL Basics</div>
  <h1>관계형 데이터베이스와 SQL 시작하기</h1>
  <p class="hero-lead">이번 장에서는 처음으로 <strong>테이블을 만들고 데이터를 입력·조회·수정·삭제하면서 SQL의 기본 흐름을 직접 실행하고 검증</strong>합니다. 문법 암기보다 실행 전 예상과 실행 후 결과를 비교하는 습관에 집중합니다.</p>
  <div class="tag-row"><span class="tag">CREATE TABLE</span><span class="tag">INSERT</span><span class="tag">SELECT</span><span class="tag">UPDATE</span><span class="tag">DELETE</span><span class="tag">CRUD</span></div>
  <div class="hero-question">SQL이 오류 없이 실행됐다는 사실만으로 충분할까?<br>어떤 행이 바뀌는지 실행 전에 예측하고 실행 후 어떻게 검증할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>이미 정해진 테이블을 사용하는 단계를 넘어, 요구사항을 읽고 무엇을 저장할지 결정한 뒤 데이터 모델과 ERD를 설계합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 04 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
