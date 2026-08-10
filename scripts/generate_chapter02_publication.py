from __future__ import annotations

import io
import re
from pathlib import Path

import cairosvg
import markdown
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "book" / "chapter02" / "chapter02.md"
HTML_PATH = ROOT / "book" / "chapter02" / "chapter02.html"
IMAGE_DIR = ROOT / "images" / "chapter02"

TITLE = "Chapter 02. 데이터와 DBMS의 기본 개념"

CSS = r'''
:root{
  --ink:#17212b;--muted:#5e6b78;--navy:#15304a;--blue:#2f6fed;--blue-soft:#eaf1ff;
  --teal:#168c8c;--teal-soft:#e9f7f6;--green:#2f855a;--green-soft:#eaf7ef;
  --orange:#b56a14;--orange-soft:#fff4e6;--line:#d8e0e8;--paper:#fff;--canvas:#eef3f8;--code:#142536;
}
*{box-sizing:border-box}
html{font-family:Pretendard,"Noto Sans KR","Apple SD Gothic Neo","Malgun Gothic",sans-serif;color:var(--ink);background:var(--canvas);line-height:1.75}
body{margin:0}main{width:min(980px,calc(100% - 32px));margin:32px auto 80px;background:var(--paper);box-shadow:0 18px 55px rgba(21,48,74,.10)}
.page{padding:72px 78px}.hero{min-height:620px;display:flex;flex-direction:column;justify-content:center;background:linear-gradient(145deg,#f9fbfd 0%,#eef4fb 62%,#f7fafc 100%);border-bottom:1px solid var(--line)}
.eyebrow{font-size:14px;letter-spacing:.14em;font-weight:900;color:var(--blue);text-transform:uppercase;margin-bottom:18px}
h1{font-size:48px;line-height:1.2;letter-spacing:-.045em;margin:0;color:var(--navy)}.hero-lead{font-size:21px;line-height:1.82;margin:34px 0 0;max-width:790px;color:#334254}
.hero-question{margin-top:36px;padding:24px 28px;border:1px solid #cedcf0;border-radius:20px;background:#fff;color:var(--navy);font-size:21px;font-weight:850;line-height:1.6}
.tag-row{display:flex;flex-wrap:wrap;gap:10px;margin-top:32px}.tag{border:1px solid #c9d7e6;border-radius:999px;padding:8px 14px;font-size:14px;font-weight:750;color:#35516d;background:#fff}
.content>h2{font-size:31px;line-height:1.38;letter-spacing:-.035em;margin:68px 0 18px;color:var(--navy);padding-top:8px}.content>h2:first-child{margin-top:0}
.content h3{font-size:23px;line-height:1.45;margin:34px 0 12px;color:var(--navy);letter-spacing:-.02em}p{margin:0 0 17px}strong{color:#122f4c}
ul,ol{padding-left:24px;margin:12px 0 22px}li{margin:7px 0}hr{border:0;height:1px;background:var(--line);margin:54px 0}
blockquote{margin:28px 0;padding:20px 24px;border-left:4px solid var(--blue);background:#f7faff;border-radius:0 16px 16px 0;color:#2d4052}blockquote p:last-child{margin-bottom:0}
table{width:100%;border-collapse:collapse;margin:24px 0 28px;font-size:15px;break-inside:avoid}th,td{border-bottom:1px solid var(--line);padding:13px 12px;text-align:left;vertical-align:top}th{background:#f6f8fb;color:var(--navy);font-weight:850}
pre{margin:24px 0;padding:20px 22px;background:var(--code);color:#eef5fb;border-radius:18px;overflow:auto;line-height:1.65;font-size:14px;break-inside:avoid;white-space:pre-wrap;word-break:break-word}
code{font-family:"Cascadia Code","D2Coding","SFMono-Regular",Consolas,monospace}p code,li code,td code{padding:2px 6px;border-radius:6px;background:#f0f4f8;color:#173d66;font-size:.92em}
.content img{display:block;width:100%;height:auto;border:1px solid var(--line);border-radius:20px;margin:34px auto 10px;background:#fff}.content p:has(>img){margin-bottom:8px}
.content p:has(>strong:first-child){padding:18px 20px;border-radius:16px;background:#f7f9fc}.footer-next{margin-top:72px;padding:32px 34px;border:1px solid #d7e3f2;border-radius:22px;background:#f1f6fd}
.footer-next b{display:block;font-size:22px;color:var(--navy);margin-bottom:7px}a{color:#245fc7}
@media(max-width:760px){main{width:100%;margin:0;box-shadow:none}.page{padding:44px 24px}.hero{min-height:auto;padding-top:68px;padding-bottom:68px}h1{font-size:38px}.hero-lead{font-size:18px}.hero-question{font-size:19px}.content>h2{font-size:27px}table{font-size:13.5px}}
@media print{@page{size:A4;margin:15mm 14mm 16mm}html,body{background:#fff}main{width:auto;margin:0;box-shadow:none}.page{padding:0}.hero{min-height:245mm;border:0;break-after:page;background:#fff}.content>h2{margin-top:11mm;break-after:avoid}.content h3{break-after:avoid}.content img,table,pre,blockquote,.footer-next{break-inside:avoid}a{color:inherit;text-decoration:none}*{-webkit-print-color-adjust:exact;print-color-adjust:exact}}
'''


def referenced_svgs(md_text: str) -> list[str]:
    return sorted(set(re.findall(r"\.\./\.\./images/chapter02/([^\s)]+\.svg)", md_text)))


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
    body_md = re.sub(r"^# Chapter 02\..*?\n", "", md_text, count=1)
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
<style>{CSS}</style>
</head>
<body>
<main>
<header class="page hero">
  <div class="eyebrow">Chapter 02 · Data and DBMS Fundamentals</div>
  <h1>데이터와 DBMS의 기본 개념</h1>
  <p class="hero-lead">SQL을 제대로 이해하려면 명령어보다 먼저 <strong>데이터가 어디에 저장되고, DBMS가 무엇을 관리하며, 서버·데이터베이스·스키마·테이블·행과 열이 어떻게 이어지는지</strong>를 정확히 구분할 수 있어야 합니다.</p>
  <div class="tag-row"><span class="tag">데이터</span><span class="tag">Database</span><span class="tag">DBMS</span><span class="tag">PostgreSQL 계층</span><span class="tag">행·열·셀</span><span class="tag">PK·FK</span></div>
  <div class="hero-question">지금 보고 있는 것은 데이터인가, 데이터베이스인가, DBMS인가?<br>그리고 한 행은 정확히 무엇을 의미하는가?</div>
</header>
<div class="page content">
{body}
<div class="footer-next"><b>다음 장에서는</b>PostgreSQL과 DBeaver를 설치하고 연결한 뒤, 지금 배운 서버·데이터베이스·스키마 구조를 실제 환경에서 확인합니다.</div>
</div>
</main>
</body>
</html>'''


def main() -> None:
    md_text = MD_PATH.read_text(encoding="utf-8")
    images = referenced_svgs(md_text)
    if not images:
        raise RuntimeError("Chapter 02 manuscript has no referenced SVG assets")
    generated = [render_svg_to_jpg(name) for name in images]
    html = make_html(md_text, images)
    HTML_PATH.write_text(html, encoding="utf-8")
    print(f"Generated {HTML_PATH}")
    for path in generated:
        print(f"Generated {path}")


if __name__ == "__main__":
    main()
