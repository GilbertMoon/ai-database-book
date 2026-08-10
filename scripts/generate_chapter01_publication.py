from __future__ import annotations

from io import BytesIO
from pathlib import Path
import re

import markdown
from PIL import Image
import cairosvg

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter01" / "chapter01.md"
HTML_PATH = ROOT / "book" / "chapter01" / "chapter01.html"
IMAGE_DIR = ROOT / "images" / "chapter01"

FIGURES = [
    ("ch01_01_storage_options.svg", "ch01_01_storage_options.jpg"),
    ("ch01_04_ai_result_verification_cycle.svg", "ch01_04_ai_result_verification_cycle.jpg"),
]

CSS = r"""
:root{
  --ink:#17212b;--muted:#5e6b78;--navy:#15304a;--blue:#2f6fed;--blue-soft:#eaf1ff;
  --teal:#168c8c;--teal-soft:#e9f7f6;--green:#2f855a;--green-soft:#eaf7ef;
  --orange:#b56a14;--orange-soft:#fff4e6;--red:#b63c3c;--red-soft:#fff0f0;
  --line:#d8e0e8;--paper:#fff;--canvas:#eef3f8;--code:#142536;
}
*{box-sizing:border-box}
html{font-family:Pretendard,"Noto Sans KR","Apple SD Gothic Neo","Malgun Gothic",sans-serif;color:var(--ink);background:var(--canvas);line-height:1.75}
body{margin:0}
main{width:min(980px,calc(100% - 32px));margin:32px auto 80px;background:var(--paper);box-shadow:0 18px 55px rgba(21,48,74,.10)}
.page{padding:72px 78px}
.hero{min-height:620px;display:flex;flex-direction:column;justify-content:center;background:linear-gradient(145deg,#f9fbfd 0%,#eef4fb 62%,#f7fafc 100%);border-bottom:1px solid var(--line)}
.eyebrow{font-size:14px;letter-spacing:.14em;font-weight:900;color:var(--blue);text-transform:uppercase;margin-bottom:18px}
h1{font-size:48px;line-height:1.2;letter-spacing:-.045em;margin:0;color:var(--navy)}
.hero-lead{font-size:21px;line-height:1.82;margin:34px 0 0;max-width:770px;color:#334254}
.hero-question{margin-top:36px;padding:24px 28px;border:1px solid #cedcf0;border-radius:20px;background:#fff;color:var(--navy);font-size:22px;font-weight:850;line-height:1.6}
.tag-row{display:flex;flex-wrap:wrap;gap:10px;margin-top:32px}
.tag{border:1px solid #c9d7e6;border-radius:999px;padding:8px 14px;font-size:14px;font-weight:750;color:#35516d;background:#fff}
.content>h2{font-size:31px;line-height:1.38;letter-spacing:-.035em;margin:68px 0 18px;color:var(--navy);padding-top:8px}
.content>h2:first-child{margin-top:0}
.content h3{font-size:23px;line-height:1.45;margin:34px 0 12px;color:var(--navy);letter-spacing:-.02em}
p{margin:0 0 17px}
strong{color:#122f4c}
ul,ol{padding-left:24px;margin:12px 0 22px}li{margin:7px 0}
hr{border:0;height:1px;background:var(--line);margin:54px 0}
blockquote{margin:28px 0;padding:20px 24px;border-left:4px solid var(--blue);background:#f7faff;border-radius:0 16px 16px 0;color:#2d4052}
blockquote p:last-child{margin-bottom:0}
table{width:100%;border-collapse:collapse;margin:24px 0 28px;font-size:15px;break-inside:avoid}
th,td{border-bottom:1px solid var(--line);padding:13px 12px;text-align:left;vertical-align:top}
th{background:#f6f8fb;color:var(--navy);font-weight:850}
pre{margin:24px 0;padding:20px 22px;background:var(--code);color:#eef5fb;border-radius:18px;overflow:auto;line-height:1.65;font-size:14px;break-inside:avoid;white-space:pre-wrap;word-break:break-word}
code{font-family:"Cascadia Code","D2Coding","SFMono-Regular",Consolas,monospace}
p code,li code,td code{padding:2px 6px;border-radius:6px;background:#f0f4f8;color:#173d66;font-size:.92em}
.figure{margin:36px 0 30px;break-inside:avoid}
.figure img{display:block;width:100%;height:auto;border:1px solid var(--line);border-radius:20px;background:#fff}
figcaption{margin-top:10px;text-align:center;color:var(--muted);font-size:13.5px}
.content>p>img{display:block;width:100%;height:auto;border:1px solid var(--line);border-radius:20px;margin:34px 0}
.content>p:has(>strong:first-child){padding:18px 20px;border-radius:16px;background:#f7f9fc}
.callout{margin:34px 0;padding:24px 26px;border:1px solid #cedcf0;border-radius:20px;background:#f7faff;color:#24384b}
.callout b{display:block;color:var(--blue);font-size:14px;letter-spacing:.08em;margin-bottom:8px}
.footer-next{margin-top:72px;padding:32px 34px;border:1px solid #d7e3f2;border-radius:22px;background:#f1f6fd}
.footer-next b{display:block;font-size:22px;color:var(--navy);margin-bottom:7px}
.small{font-size:13.5px;color:var(--muted)}
a{color:#245fc7}
@media(max-width:760px){
  main{width:100%;margin:0;box-shadow:none}.page{padding:44px 24px}.hero{min-height:auto;padding-top:68px;padding-bottom:68px}
  h1{font-size:38px}.hero-lead{font-size:18px}.hero-question{font-size:19px}.content>h2{font-size:27px}
}
@media print{
  @page{size:A4;margin:15mm 14mm 16mm}
  html,body{background:#fff}main{width:auto;margin:0;box-shadow:none}.page{padding:0}
  .hero{min-height:245mm;border:0;break-after:page;background:#fff}
  .content>h2{margin-top:11mm;break-after:avoid}.content h3{break-after:avoid}
  .figure,table,pre,blockquote,.callout,.footer-next{break-inside:avoid}
  a{color:inherit;text-decoration:none}*{-webkit-print-color-adjust:exact;print-color-adjust:exact}
}
"""


def convert_svg_to_jpg(svg_name: str, jpg_name: str) -> None:
    svg_path = IMAGE_DIR / svg_name
    jpg_path = IMAGE_DIR / jpg_name
    if not svg_path.exists():
        raise FileNotFoundError(svg_path)

    png_bytes = cairosvg.svg2png(url=str(svg_path), output_width=1600)
    with Image.open(BytesIO(png_bytes)) as source:
        source = source.convert("RGBA")
        background = Image.new("RGBA", source.size, "white")
        background.alpha_composite(source)
        rgb = background.convert("RGB")
        rgb.save(jpg_path, "JPEG", quality=94, optimize=True, progressive=True)
    print(f"Generated {jpg_path}")


def figureize(html: str) -> str:
    pattern = re.compile(
        r'<p><img alt="([^"]*)" src="([^"]+\.jpg)" /></p>\s*<p>(그림 1-\d+[^<]*)</p>',
        re.MULTILINE,
    )
    return pattern.sub(
        lambda m: (
            f'<figure class="figure"><img src="{m.group(2)}" alt="{m.group(1)}">'
            f'<figcaption>{m.group(3)}</figcaption></figure>'
        ),
        html,
    )


def build_html() -> None:
    source = MD_PATH.read_text(encoding="utf-8")
    lines = source.splitlines()
    if not lines or not lines[0].startswith("# Chapter 01."):
        raise RuntimeError("Unexpected Chapter 01 title")

    body_md = "\n".join(lines[1:]).lstrip()
    if body_md.startswith("---"):
        body_md = body_md[3:].lstrip()

    body_md = body_md.replace(
        "../../images/chapter01/ch01_01_storage_options.svg",
        "../../images/chapter01/ch01_01_storage_options.jpg",
    ).replace(
        "../../images/chapter01/ch01_04_ai_result_verification_cycle.svg",
        "../../images/chapter01/ch01_04_ai_result_verification_cycle.jpg",
    )

    rendered = markdown.markdown(
        body_md,
        extensions=["fenced_code", "tables", "sane_lists"],
        output_format="html5",
    )
    rendered = figureize(rendered)

    title = "AI 시대에 데이터베이스를 왜 배워야 하는가"
    document = f'''<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Chapter 01 · {title}</title>
<style>{CSS}</style>
</head>
<body>
<main>
<header class="page hero">
  <div class="eyebrow">Chapter 01 · Why Databases Still Matter</div>
  <h1>{title}</h1>
  <p class="hero-lead">AI가 SQL과 데이터베이스 코드의 초안을 빠르게 만들 수 있는 시대입니다. 그래서 더 중요한 것은 문법을 많이 외우는 일이 아니라 <strong>데이터의 의미와 관계를 이해하고, 실행 결과가 실제 요구사항과 맞는지 검증하는 능력</strong>입니다.</p>
  <div class="tag-row"><span class="tag">AI 결과 검증</span><span class="tag">업무 규칙</span><span class="tag">정확한 SQL</span><span class="tag">데이터 구조</span><span class="tag">DBMS 선택</span></div>
  <div class="hero-question">AI가 SQL과 데이터베이스 코드를 작성해 준다면,<br>사람은 무엇을 이해하고 무엇을 검증해야 하는가?</div>
</header>
<div class="page content">
{rendered}
<div class="footer-next"><b>다음 장에서는</b><span>Chapter 02에서 데이터와 DBMS의 기본 개념을 배우고, 이후 PostgreSQL 실습을 위한 기초 언어를 정리합니다.</span></div>
</div>
</main>
</body>
</html>
'''
    HTML_PATH.write_text(document, encoding="utf-8")
    print(f"Generated {HTML_PATH}")


if __name__ == "__main__":
    for svg_name, jpg_name in FIGURES:
        convert_svg_to_jpg(svg_name, jpg_name)
    build_html()
