from __future__ import annotations

import argparse
from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_HTML = ROOT / "publish" / "ai_database_book.html"
DEFAULT_PDF = ROOT / "publish" / "ai_database_book.pdf"


def build_pdf(html_path: Path, output_path: Path) -> None:
    if not html_path.exists():
        raise FileNotFoundError(html_path)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1440, "height": 1000})
        page.goto(html_path.resolve().as_uri(), wait_until="networkidle")
        page.emulate_media(media="print")
        page.evaluate(
            """
            async () => {
              if (document.fonts && document.fonts.ready) {
                await document.fonts.ready;
              }
              await Promise.all(Array.from(document.images).map((img) => {
                if (img.complete) return Promise.resolve();
                return new Promise((resolve, reject) => {
                  img.addEventListener('load', resolve, {once: true});
                  img.addEventListener('error', () => reject(new Error(`Image failed: ${img.src}`)), {once: true});
                });
              }));
            }
            """
        )
        page.pdf(
            path=str(output_path),
            print_background=True,
            prefer_css_page_size=True,
            display_header_footer=False,
            margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
        )
        browser.close()

    if not output_path.exists() or output_path.stat().st_size == 0:
        raise RuntimeError(f"PDF was not generated: {output_path}")

    print(f"Generated: {output_path}")
    print(f"Size: {output_path.stat().st_size:,} bytes")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build the full publication PDF with Chromium")
    parser.add_argument("--html", type=Path, default=DEFAULT_HTML)
    parser.add_argument("--output", type=Path, default=DEFAULT_PDF)
    args = parser.parse_args()
    build_pdf(args.html, args.output)


if __name__ == "__main__":
    main()
