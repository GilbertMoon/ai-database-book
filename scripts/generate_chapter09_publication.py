from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter09" / "chapter09.md"
HTML_PATH = ROOT / "book" / "chapter09" / "chapter09.html"
IMAGE_DIR = ROOT / "images" / "chapter09"

TITLE = "Chapter 09. 트랜잭션으로 데이터 정합성 지키기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter09/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 09\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 09 · Transactions &amp; Consistency</div>
  <h1>트랜잭션으로 데이터 정합성 지키기</h1>
  <p class="hero-lead">여러 데이터 변경이 하나의 업무 단위로 함께 성공하거나 실패하도록 <strong>트랜잭션 경계를 설계하고, 좌석·신청·결제의 영향 행 수와 최종 상태를 검증해 데이터 정합성을 지키는 방법</strong>을 익힙니다.</p>
  <div class="tag-row"><span class="tag">BEGIN</span><span class="tag">COMMIT</span><span class="tag">ROLLBACK</span><span class="tag">ACID</span><span class="tag">FOR UPDATE</span><span class="tag">SAVEPOINT</span></div>
  <div class="hero-question">SQL이 오류 없이 실행되면 업무도 성공한 것일까?<br>동시 실행과 중간 실패에서도 관련 변경을 하나의 일관된 상태로 확정하려면 무엇이 필요할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>같은 온라인 강의 도메인의 조회 패턴을 바탕으로 인덱스와 실행 계획을 살펴보고, <code>WHERE</code>·<code>JOIN</code>·<code>ORDER BY</code>의 탐색 비용을 <code>EXPLAIN</code>으로 검증합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 09 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
