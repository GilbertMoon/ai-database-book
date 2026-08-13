from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
BOOK_CSS = ROOT / "assets" / "css" / "book.css"
PRINT_CSS = ROOT / "assets" / "css" / "print.css"


def publication_html_files() -> list[Path]:
    files: list[Path] = []
    index = ROOT / "book" / "index.html"
    if index.exists():
        files.append(index)
    overview = ROOT / "book" / "overview" / "overview.html"
    if overview.exists():
        files.append(overview)
    files.extend(sorted((ROOT / "book").glob("chapter*/chapter*.html")))
    return files


def expected_css_prefix(path: Path) -> str:
    if path == ROOT / "book" / "index.html":
        return "../assets/css/"
    return "../../assets/css/"


def validate() -> list[str]:
    errors: list[str] = []

    for css_path in (BOOK_CSS, PRINT_CSS):
        if not css_path.exists():
            errors.append(f"missing shared CSS: {css_path.relative_to(ROOT)}")
        elif css_path.stat().st_size == 0:
            errors.append(f"empty shared CSS: {css_path.relative_to(ROOT)}")

    files = publication_html_files()
    if not files:
        errors.append("no publication HTML files found")
        return errors

    for path in files:
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(ROOT)
        prefix = expected_css_prefix(path)

        if re.search(r"<style(?:\s[^>]*)?>", text, flags=re.I):
            errors.append(f"inline <style> is not allowed: {rel}")

        if f'{prefix}book.css' not in text:
            errors.append(f"book.css link missing: {rel}")

        if f'{prefix}print.css' not in text:
            errors.append(f"print.css link missing: {rel}")

        if '<html lang="ko">' not in text and "<html lang='ko'>" not in text:
            errors.append(f"Korean lang attribute missing: {rel}")

        if '<meta name="viewport"' not in text and "<meta name='viewport'" not in text:
            errors.append(f"viewport metadata missing: {rel}")

    index = ROOT / "book" / "index.html"
    if index.exists():
        text = index.read_text(encoding="utf-8")
        if 'overview/overview.html' not in text:
            errors.append("book/index.html does not link Overview")
        for number in range(1, 16):
            token = f"CHAPTER {number:02d}"
            if token not in text:
                errors.append(f"book/index.html missing {token}")

    return errors


def main() -> int:
    errors = validate()
    if errors:
        print("Publication style validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    files = publication_html_files()
    print(f"Publication style validation passed: {len(files)} HTML files")
    print("Shared CSS: assets/css/book.css + assets/css/print.css")
    return 0


if __name__ == "__main__":
    sys.exit(main())
