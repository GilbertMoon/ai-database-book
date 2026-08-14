from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter08" / "chapter08.md"
HTML_PATH = ROOT / "book" / "chapter08" / "chapter08.html"
IMAGE_DIR = ROOT / "images" / "chapter08"

TITLE = "Chapter 08. JOIN과 집계로 서비스 질문에 답하기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter08/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 08\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 08 · JOIN &amp; Aggregation</div>
  <h1>JOIN과 집계로 서비스 질문에 답하기</h1>
  <p class="hero-lead">Chapter 07에서 완성한 온라인 강의 데이터를 바탕으로 <strong>관계에 따라 테이블을 연결하고, 결과 한 행의 기준과 상태 범위를 정한 뒤 집계와 검산으로 서비스 질문에 정확하게 답하는 방법</strong>을 익힙니다.</p>
  <div class="tag-row"><span class="tag">INNER JOIN</span><span class="tag">LEFT JOIN</span><span class="tag">COUNT</span><span class="tag">SUM·AVG</span><span class="tag">GROUP BY</span><span class="tag">HAVING</span></div>
  <div class="hero-question">JOIN 결과 행이 늘어났다면 오류일까, 정상적인 1:N 관계일까?<br>그리고 집계 결과가 실제 질문에 맞는지 무엇으로 검산할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>조회 결과를 확인하는 단계를 넘어 <code>BEGIN</code>·<code>COMMIT</code>·<code>ROLLBACK</code>으로 여러 데이터 변경을 하나의 업무 단위로 묶고, 오류와 동시 실행에서도 데이터 정합성을 지키는 트랜잭션을 학습합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 08 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
