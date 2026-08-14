from __future__ import annotations

import io
import re
from pathlib import Path

from publication_svg_utils import svg2png
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter11" / "chapter11.md"
HTML_PATH = ROOT / "book" / "chapter11" / "chapter11.html"
IMAGE_DIR = ROOT / "images" / "chapter11"

TITLE = "Chapter 11. 데이터베이스를 안전하게 지키고 복구하는 방법"


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter11/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 11\..*?\n", "", md_text, count=1)
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
  <div class="eyebrow">Chapter 11 · Security, Backup &amp; Recovery</div>
  <h1>데이터베이스를 안전하게 지키고 복구하는 방법</h1>
  <p class="hero-lead">빠른 데이터베이스를 넘어 <strong>필요한 작업만 허용하는 최소 권한과 역할 설계, 비밀정보 보호, 그리고 실제 복원으로 증명하는 백업·복구 체계</strong>를 PostgreSQL 운영 흐름에 맞춰 익힙니다.</p>
  <div class="tag-row"><span class="tag">Role</span><span class="tag">GRANT·REVOKE</span><span class="tag">최소 권한</span><span class="tag">pg_dump</span><span class="tag">pg_restore</span><span class="tag">RPO·RTO</span></div>
  <div class="hero-question">백업 파일이 존재하면 복구 준비가 끝난 것일까?<br>권한은 최소화하면서도 실제 운영과 복원에 필요한 작업을 어떻게 검증할까?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>관계형 모델과 다른 저장 방식을 제공하는 문서·키-값·그래프·와이드 컬럼 NoSQL을 살펴보고, 조회 패턴·일관성·확장성·스키마 유연성을 기준으로 PostgreSQL과 전용 NoSQL의 선택 근거를 비교합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 11 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
