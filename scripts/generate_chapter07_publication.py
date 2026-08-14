from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter07" / "chapter07.md"
HTML_PATH = ROOT / "book" / "chapter07" / "chapter07.html"
IMAGE_DIR = ROOT / "images" / "chapter07"

TITLE = "Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter07/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 07\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 07 · Practical Project 1</div>
  <h1>실전 프로젝트 1: 온라인 강의 수강신청 DB 완성하기</h1>
  <p class="hero-lead">지금까지 배운 SQL, 요구사항 분석, ERD, 정규화와 무결성을 하나로 연결해 <strong>다른 사람이 같은 순서로 실행하고 같은 결과를 재현할 수 있는 온라인 강의 수강신청 데이터베이스 프로젝트</strong>를 완성합니다.</p>
  <div class="tag-row"><span class="tag">프로젝트</span><span class="tag">course_project</span><span class="tag">ERD</span><span class="tag">정규화</span><span class="tag">무결성</span><span class="tag">자동 검증</span></div>
  <div class="hero-question">SQL 파일이 모두 존재하면 프로젝트가 끝난 것일까?<br>설계 근거와 실행 결과를 다른 사람이 같은 방식으로 재현하려면 무엇이 필요할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>Chapter 07에서 완성한 <code>course_project</code> 기준 데이터를 이용해 <code>JOIN</code>과 집계로 여러 테이블을 연결하고 서비스 질문에 답합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 07 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
