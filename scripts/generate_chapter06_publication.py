from __future__ import annotations

import io
import re
from pathlib import Path

from publication_svg_utils import svg2png
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter06" / "chapter06.md"
HTML_PATH = ROOT / "book" / "chapter06" / "chapter06.html"
IMAGE_DIR = ROOT / "images" / "chapter06"

TITLE = "Chapter 06. 정규화와 데이터 무결성으로 좋은 테이블 만들기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter06/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 06\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 06 · Normalization &amp; Data Integrity</div>
  <h1>정규화와 데이터 무결성으로 좋은 테이블 만들기</h1>
  <p class="hero-lead">좋은 테이블은 단순히 데이터를 저장하는 구조가 아니라 <strong>같은 사실의 불필요한 복사를 줄이고, 확정된 업무 규칙을 제약조건으로 지켜 데이터가 변해도 의미와 일관성을 유지하는 구조</strong>입니다.</p>
  <div class="tag-row"><span class="tag">정규화</span><span class="tag">1NF·2NF·3NF</span><span class="tag">함수적 종속</span><span class="tag">UNIQUE</span><span class="tag">CHECK</span><span class="tag">FOREIGN KEY</span></div>
  <div class="hero-question">값이 반복된다고 모두 잘못된 중복일까?<br>그리고 확정된 업무 규칙을 데이터베이스가 직접 지키게 하려면 무엇이 필요할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>요구사항 ID, ERD, 정규화, 제약조건과 검증 시나리오를 하나로 연결해 온라인 강의 수강신청 데이터베이스 프로젝트를 완성합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 06 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
