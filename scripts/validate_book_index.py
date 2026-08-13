from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
INDEX_PATH = BOOK_DIR / "index.html"


def chapter_title(number: int) -> str:
    md_path = BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.md"
    first = md_path.read_text(encoding="utf-8").splitlines()[0].strip()
    match = re.match(r"^#\s+Chapter\s+\d+\.\s*(.+)$", first)
    if not match:
        raise RuntimeError(f"unexpected chapter title: {first}")
    return match.group(1).strip()


def validate() -> list[str]:
    errors: list[str] = []
    if not INDEX_PATH.exists():
        return ["missing book/index.html"]

    text = INDEX_PATH.read_text(encoding="utf-8")

    required = [
        '<html lang="ko">',
        '<meta name="viewport"',
        '../assets/css/book.css',
        '../assets/css/print.css',
        'overview/overview.html',
        'AI 시대의 데이터베이스 입문',
        'Source of Truth 원칙',
        'Chapter HTML',
    ]
    for token in required:
        if token not in text:
            errors.append(f"book/index.html missing token: {token}")

    if re.search(r"<style(?:\s[^>]*)?>", text, flags=re.I):
        errors.append("book/index.html must not contain inline <style>")

    if not (BOOK_DIR / "overview" / "overview.html").exists():
        errors.append("overview publication HTML is missing")

    available = 0
    for number in range(1, 16):
        title = chapter_title(number)
        if title not in text:
            errors.append(f"Chapter {number:02d} title missing from index: {title}")

        html_rel = f"chapter{number:02d}/chapter{number:02d}.html"
        html_path = BOOK_DIR / html_rel
        if html_path.exists():
            available += 1
            if f'href="{html_rel}"' not in text:
                errors.append(f"available Chapter {number:02d} is not linked")
        elif f'href="{html_rel}"' in text:
            errors.append(f"unavailable Chapter {number:02d} must not be linked")

    if f"Chapter HTML {available}/15" not in text:
        errors.append(f"publication status is stale: expected Chapter HTML {available}/15")

    return errors


def main() -> int:
    errors = validate()
    if errors:
        print("Book index validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    available = sum(
        (BOOK_DIR / f"chapter{n:02d}" / f"chapter{n:02d}.html").exists()
        for n in range(1, 16)
    )
    print("Book index validation passed")
    print(f"Overview: linked")
    print(f"Chapter HTML: {available}/15 linked")
    return 0


if __name__ == "__main__":
    sys.exit(main())
