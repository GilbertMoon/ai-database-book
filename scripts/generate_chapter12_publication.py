from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter12" / "chapter12.md"
HTML_PATH = ROOT / "book" / "chapter12" / "chapter12.html"
IMAGE_DIR = ROOT / "images" / "chapter12"

TITLE = "Chapter 12. 조회 패턴으로 RDBMS와 NoSQL 선택하기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter12/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 12\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 12 · RDBMS, JSONB &amp; NoSQL</div>
  <h1>조회 패턴으로 RDBMS와 NoSQL 선택하기</h1>
  <p class="hero-lead">모든 데이터를 한 저장소에 넣는 대신 <strong>Source of Truth·캐시·가변 메타데이터·이벤트·관계 인덱스의 역할과 반복되는 조회·실패·복구 패턴</strong>을 기준으로 RDBMS, JSONB와 NoSQL 후보를 비교하고 선택하는 방법을 익힙니다.</p>
  <div class="tag-row"><span class="tag">RDBMS</span><span class="tag">NoSQL</span><span class="tag">JSONB</span><span class="tag">Key-Value</span><span class="tag">Document</span><span class="tag">Graph</span></div>
  <div class="hero-question">데이터 모양이 JSON이면 Document DB가 정답일까?<br>원본 책임·조회 패턴·일관성·동기화 실패·복구 비용까지 포함해 저장소 선택을 어떻게 검증할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>ChatGPT와 Codex를 활용해 요구사항·ERD·DDL·DML·조회 SQL을 검토하고, 격리된 실습 환경의 실제 메타데이터·반례·자동 판정·diff를 실행 증거로 연결해 AI가 만든 데이터베이스 변경 후보를 검증합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 12 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
