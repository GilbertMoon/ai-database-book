from __future__ import annotations

import io
import re
from pathlib import Path

from publication_svg_utils import svg2png
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter10" / "chapter10.md"
HTML_PATH = ROOT / "book" / "chapter10" / "chapter10.html"
IMAGE_DIR = ROOT / "images" / "chapter10"

TITLE = "Chapter 10. 실행 계획으로 인덱스 효과 검증하기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter10/([^\s)]+\.svg)", md_text)))


def render_svg_to_jpg(svg_name: str) -> Path:
    svg_path = IMAGE_DIR / svg_name
    if not svg_path.exists():
        raise FileNotFoundError(svg_path)
    png_bytes = svg2png(url=str(svg_path), output_width=1600)
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
    body_md = re.sub(r"^# Chapter 10\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 10 · Indexes &amp; Execution Plans</div>
  <h1>실행 계획으로 인덱스 효과 검증하기</h1>
  <p class="hero-lead">데이터가 많아졌을 때 PostgreSQL이 어떤 경로로 행을 찾는지 확인하고, <strong>실제 조회 패턴·데이터 규모·기존 인덱스를 기준으로 후보를 만든 뒤 실행 계획과 버퍼·실행 시간으로 전후 효과를 검증하는 방법</strong>을 익힙니다.</p>
  <div class="tag-row"><span class="tag">B-tree</span><span class="tag">EXPLAIN ANALYZE</span><span class="tag">Seq Scan</span><span class="tag">Index Scan</span><span class="tag">복합 인덱스</span><span class="tag">CONCURRENTLY</span></div>
  <div class="hero-question">인덱스가 존재하면 쿼리는 항상 빨라질까?<br>같은 데이터·통계·SQL에서 실제 읽기 비용이 줄었는지 어떻게 증명할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>빠른 조회를 넘어 데이터베이스를 안전하게 보호하고 복구하기 위해 최소 권한, 역할과 사용자, 접속 정보 보호, 논리 백업·복원과 복구 가능성 검증을 학습합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 10 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
