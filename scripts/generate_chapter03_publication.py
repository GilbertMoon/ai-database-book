from __future__ import annotations

import io
import re
from pathlib import Path

from publication_svg_utils import svg2png
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter03" / "chapter03.md"
HTML_PATH = ROOT / "book" / "chapter03" / "chapter03.html"
IMAGE_DIR = ROOT / "images" / "chapter03"

TITLE = "Chapter 03. PostgreSQL과 DBeaver로 실습 환경 만들기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter03/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 03\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 03 · PostgreSQL &amp; DBeaver Setup</div>
  <h1>PostgreSQL과 DBeaver로 실습 환경 만들기</h1>
  <p class="hero-lead">설치 화면을 따라가는 데서 끝나지 않고 <strong>PostgreSQL 서버가 실행되고, DBeaver 연결이 성공하며, 현재 데이터베이스·사용자·스키마와 SQL 실행 범위를 직접 확인할 수 있는 상태</strong>를 만드는 것이 이번 장의 목표입니다.</p>
  <div class="tag-row"><span class="tag">PostgreSQL</span><span class="tag">DBeaver</span><span class="tag">연결 설정</span><span class="tag">ai_database_book</span><span class="tag">환경 검증</span><span class="tag">비밀정보 보호</span></div>
  <div class="hero-question">설치가 끝났다는 사실만으로 실습 환경이 준비된 것일까?<br>지금 어느 데이터베이스에 어떤 사용자로 연결되어 있는지 어떻게 확인할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>준비한 PostgreSQL 연결에서 <code>public.students</code> 테이블을 만들고, 데이터를 입력·조회·수정·삭제하며 관계형 데이터베이스와 SQL의 기본 흐름을 시작합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 03 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
