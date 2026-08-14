from __future__ import annotations

import io
import re
from pathlib import Path

from publication_svg_utils import svg2png
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter15" / "chapter15.md"
HTML_PATH = ROOT / "book" / "chapter15" / "chapter15.html"
IMAGE_DIR = ROOT / "images" / "chapter15"

TITLE = "Chapter 15. 데이터베이스 종합 프로젝트"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter15/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 15\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 15 · Integrated Database Project</div>
  <h1>데이터베이스 종합 프로젝트</h1>
  <p class="hero-lead">지금까지 배운 내용을 기술 목록으로 나열하는 대신 <strong>요구사항·ERD·PostgreSQL 구현·트랜잭션·인덱스·보안·복구·SQL/Python 분석·AI 검토를 하나의 재현 가능한 프로젝트와 실행 증거로 연결</strong>합니다.</p>
  <div class="tag-row"><span class="tag">Requirements</span><span class="tag">ERD·DDL</span><span class="tag">Validation</span><span class="tag">Recovery</span><span class="tag">SQL·pandas</span><span class="tag">AI Diff Review</span></div>
  <div class="hero-question">프로젝트가 한 번 실행됐다는 사실만으로 완성됐다고 할 수 있을까?<br>다른 사람이 같은 절차로 다시 실행하고 같은 구조·결과·복구 근거를 확인할 수 있도록 어떻게 증명할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>책을 마치며</b>데이터베이스의 완성은 SQL을 작성한 순간이 아니라 요구사항과 실제 구조, 정상·실패 검증, 성능·권한·복구, 분석 결과와 AI 변경 이력이 서로 추적되고 다른 사람이 같은 절차로 다시 확인할 수 있을 때 시작됩니다. 이제 이 기준을 웹 API, ORM·마이그레이션, 실제 인증·권한, NoSQL 연동, 자동화 테스트와 클라우드 운영으로 확장해 보세요.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 15 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
