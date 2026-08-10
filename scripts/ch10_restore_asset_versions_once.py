from pathlib import Path

root = Path('presentation/chapter10')
for path in root.iterdir():
    if path.is_file() and path.suffix.lower() in {'.html', '.js'}:
        text = path.read_text(encoding='utf-8')
        text = text.replace('20260810a', '20260809a')
        path.write_text(text, encoding='utf-8')

script_html = root / 'chapter10_script.html'
text = script_html.read_text(encoding='utf-8')
text = text.replace('../common/script_content_enhancer.js?v=20260809a', '../common/script_content_enhancer.js?v=20260808e')
if 'data-script-content-enhancer="off"' not in text:
    raise SystemExit('script enhancer-off marker must be preserved')
script_html.write_text(text, encoding='utf-8')

print('Chapter 10 presentation asset versions restored; enhancer-off preserved')
