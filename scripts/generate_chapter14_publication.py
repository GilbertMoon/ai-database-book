from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter14" / "chapter14.md"
HTML_PATH = ROOT / "book" / "chapter14" / "chapter14.html"
IMAGE_DIR = ROOT / "images" / "chapter14"

TITLE = "Chapter 14. SQL 데이터 분석과 Python 확장"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter14/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 14\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 14 · SQL Analytics &amp; Python</div>
  <h1>SQL 데이터 분석과 Python 확장</h1>
  <p class="hero-lead">분석 코드를 먼저 쓰는 대신 <strong>질문·기간·한 행의 단위·지표 의미를 정의하고 SQL로 분석 경계를 확정한 뒤, Python·pandas·시각화로 확장한 결과를 같은 데이터 스냅샷에서 다시 교차 검증하는 방법</strong>을 익힙니다.</p>
  <div class="tag-row"><span class="tag">SQL Analytics</span><span class="tag">JOIN·집계</span><span class="tag">Data Quality</span><span class="tag">pandas</span><span class="tag">matplotlib</span><span class="tag">Cross Validation</span></div>
  <div class="hero-question">그래프가 그럴듯하고 Python 코드가 실행되면 분석 결과를 믿어도 될까?<br>SQL과 pandas가 같은 질문·기간·행 단위·스냅샷에서 같은 답을 냈는지 어떻게 증명할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>요구사항, ERD, 정규화, SQL 구현, 트랜잭션, 인덱스, 보안·복구, AI 검토와 SQL·Python 분석을 하나의 재현 가능한 데이터베이스 종합 프로젝트로 통합합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 14 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
