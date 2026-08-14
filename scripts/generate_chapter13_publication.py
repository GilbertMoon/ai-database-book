from __future__ import annotations

import io
import re
from pathlib import Path

from publication_svg_utils import svg2png
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter13" / "chapter13.md"
HTML_PATH = ROOT / "book" / "chapter13" / "chapter13.html"
IMAGE_DIR = ROOT / "images" / "chapter13"

TITLE = "Chapter 13. AI와 실행 증거로 데이터베이스 설계 검증하기"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter13/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 13\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 13 · AI-assisted Database Review</div>
  <h1>AI와 실행 증거로 데이터베이스 설계 검증하기</h1>
  <p class="hero-lead">ChatGPT와 Codex가 만든 설계와 SQL을 그대로 승인하지 않고, <strong>확인된 요구사항·격리 환경의 실제 메타데이터·정상/경계/반례 테스트·업무 정합성·파일 diff를 실행 증거로 연결해 데이터베이스 변경 후보를 검증하는 방법</strong>을 익힙니다.</p>
  <div class="tag-row"><span class="tag">ChatGPT</span><span class="tag">Codex</span><span class="tag">요구사항 추적</span><span class="tag">Metadata</span><span class="tag">Negative Tests</span><span class="tag">Diff Review</span></div>
  <div class="hero-question">AI가 만든 SQL이 오류 없이 실행되면 설계 검증도 끝난 것일까?<br>요구사항·메타데이터·반례·정합성·diff를 어떤 증거로 연결해야 승인할 수 있을까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>검증 원칙을 데이터 분석으로 확장해 분석 질문·기간·행 단위·지표를 먼저 정의하고, SQL 집계 결과를 Python·pandas로 확장한 뒤 같은 데이터 스냅샷에서 두 결과를 교차 검증합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 13 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
