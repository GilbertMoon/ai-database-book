from __future__ import annotations

from html.parser import HTMLParser
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
EXPECTED_CHAPTERS = 15


class PublicationParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.links: list[tuple[str, str]] = []
        self.ids: set[str] = set()
        self.has_title = False
        self.title_text = ""
        self._in_title = False
        self.has_charset = False
        self.has_viewport = False
        self.has_korean_lang = False
        self.has_inline_style_tag = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attr = {key.lower(): value or "" for key, value in attrs}
        tag = tag.lower()

        if tag == "html" and attr.get("lang", "").lower() == "ko":
            self.has_korean_lang = True
        if tag == "meta":
            if "charset" in attr and attr["charset"].lower() == "utf-8":
                self.has_charset = True
            if attr.get("name", "").lower() == "viewport":
                self.has_viewport = True
        if tag == "title":
            self.has_title = True
            self._in_title = True
        if tag == "style":
            self.has_inline_style_tag = True
        if "id" in attr and attr["id"]:
            self.ids.add(attr["id"])

        if tag == "a" and attr.get("href"):
            self.links.append(("href", attr["href"]))
        if tag in {"img", "script", "source", "video", "audio", "iframe"} and attr.get("src"):
            self.links.append(("src", attr["src"]))
        if tag == "link" and attr.get("href"):
            self.links.append(("href", attr["href"]))

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "title":
            self._in_title = False

    def handle_data(self, data: str) -> None:
        if self._in_title:
            self.title_text += data


def publication_files() -> list[Path]:
    return [
        BOOK_DIR / "index.html",
        BOOK_DIR / "overview" / "overview.html",
        *[
            BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.html"
            for number in range(1, EXPECTED_CHAPTERS + 1)
        ],
    ]


def markdown_title(number: int) -> str:
    path = BOOK_DIR / f"chapter{number:02d}" / f"chapter{number:02d}.md"
    if not path.exists():
        return ""
    first = path.read_text(encoding="utf-8").splitlines()[0].strip()
    match = re.match(r"^#\s+Chapter\s+\d+\.\s*(.+)$", first)
    return match.group(1).strip() if match else ""


def is_external(value: str) -> bool:
    lowered = value.lower()
    return lowered.startswith(("http://", "https://", "mailto:", "tel:", "data:", "javascript:")) or value.startswith("//")


def resolve_local_reference(html_path: Path, value: str) -> tuple[Path | None, str | None]:
    if is_external(value):
        return None, None

    parsed = urlparse(value)
    raw_path = unquote(parsed.path)
    fragment = unquote(parsed.fragment) if parsed.fragment else None

    if not raw_path:
        return html_path, fragment

    target = (html_path.parent / raw_path).resolve()
    return target, fragment


def parse(path: Path) -> PublicationParser:
    parser = PublicationParser()
    parser.feed(path.read_text(encoding="utf-8"))
    return parser


def validate() -> tuple[list[str], dict[str, int]]:
    errors: list[str] = []
    files = publication_files()
    stats = {
        "html_files": 0,
        "local_references": 0,
        "external_references": 0,
        "image_references": 0,
        "jpg_references": 0,
        "svg_references": 0,
    }

    expected = set(files)
    actual = {BOOK_DIR / "index.html", BOOK_DIR / "overview" / "overview.html"}
    actual.update(sorted(BOOK_DIR.glob("chapter*/chapter*.html")))

    for path in files:
        if not path.exists():
            errors.append(f"missing publication HTML: {path.relative_to(ROOT)}")
        elif path.stat().st_size == 0:
            errors.append(f"empty publication HTML: {path.relative_to(ROOT)}")

    unexpected = sorted(path for path in actual if path not in expected)
    for path in unexpected:
        errors.append(f"unexpected publication HTML: {path.relative_to(ROOT)}")

    if errors:
        return errors, stats

    parsed_cache: dict[Path, PublicationParser] = {}
    for path in files:
        stats["html_files"] += 1
        parser = parse(path)
        parsed_cache[path.resolve()] = parser
        rel = path.relative_to(ROOT)

        if not parser.has_korean_lang:
            errors.append(f"missing html lang=ko: {rel}")
        if not parser.has_charset:
            errors.append(f"missing UTF-8 charset: {rel}")
        if not parser.has_viewport:
            errors.append(f"missing viewport metadata: {rel}")
        if not parser.has_title or not parser.title_text.strip():
            errors.append(f"missing non-empty title: {rel}")
        if parser.has_inline_style_tag:
            errors.append(f"inline <style> is not allowed: {rel}")

        text = path.read_text(encoding="utf-8")
        if re.search(r"(?:href|src)=[\"'][^\"']+\.svg(?:[?#][^\"']*)?[\"']", text, flags=re.I):
            errors.append(f"SVG reference remains in publication HTML: {rel}")

        if path.name.startswith("chapter") and path.parent.name.startswith("chapter"):
            number_text = path.parent.name.removeprefix("chapter")
            if number_text.isdigit():
                number = int(number_text)
                title = markdown_title(number)
                if title and title not in parser.title_text:
                    errors.append(f"HTML title does not match Markdown title: {rel}")

    for path in files:
        parser = parsed_cache[path.resolve()]
        rel = path.relative_to(ROOT)
        for kind, value in parser.links:
            if is_external(value):
                stats["external_references"] += 1
                continue

            stats["local_references"] += 1
            lowered_path = urlparse(value).path.lower()
            if kind == "src" and lowered_path:
                stats["image_references"] += 1
                if lowered_path.endswith((".jpg", ".jpeg")):
                    stats["jpg_references"] += 1
                if lowered_path.endswith(".svg"):
                    stats["svg_references"] += 1

            target, fragment = resolve_local_reference(path, value)
            if target is None:
                continue
            try:
                target.relative_to(ROOT.resolve())
            except ValueError:
                errors.append(f"local reference escapes repository: {rel} -> {value}")
                continue

            if not target.exists():
                errors.append(f"broken local reference: {rel} -> {value}")
                continue
            if target.is_file() and target.stat().st_size == 0:
                errors.append(f"local reference points to empty file: {rel} -> {value}")

            if fragment and target.suffix.lower() in {".html", ".htm"}:
                target_resolved = target.resolve()
                target_parser = parsed_cache.get(target_resolved)
                if target_parser is None:
                    try:
                        target_parser = parse(target)
                    except UnicodeDecodeError:
                        target_parser = None
                if target_parser is not None and fragment not in target_parser.ids:
                    errors.append(f"broken HTML fragment: {rel} -> {value}")

    index = BOOK_DIR / "index.html"
    index_text = index.read_text(encoding="utf-8")
    if "Chapter HTML 15/15" not in index_text or "출판 HTML 15 / 15" not in index_text:
        errors.append("book/index.html does not report complete 15/15 publication status")
    for number in range(1, EXPECTED_CHAPTERS + 1):
        link = f"chapter{number:02d}/chapter{number:02d}.html"
        if f'href="{link}"' not in index_text:
            errors.append(f"book/index.html missing Chapter {number:02d} link")

    for path in files:
        text = path.read_text(encoding="utf-8")
        css_prefix = "../assets/css/" if path == BOOK_DIR / "index.html" else "../../assets/css/"
        for css_name in ("book.css", "print.css"):
            if f"{css_prefix}{css_name}" not in text:
                errors.append(f"shared CSS reference missing: {path.relative_to(ROOT)} -> {css_name}")

    return errors, stats


def main() -> int:
    errors, stats = validate()
    if errors:
        print("Full book Source QA failed:")
        for error in errors:
            print(f"- {error}")
        print(f"Errors: {len(errors)}")
        return 1

    print("Full book Source QA passed")
    print(f"Publication HTML: {stats['html_files']} files (index + overview + 15 chapters)")
    print(f"Local references checked: {stats['local_references']}")
    print(f"External references skipped: {stats['external_references']}")
    print(f"Image references checked: {stats['image_references']}")
    print(f"JPG references: {stats['jpg_references']}")
    print(f"SVG references remaining: {stats['svg_references']}")
    print("Publication status: Chapter HTML 15/15")
    return 0


if __name__ == "__main__":
    sys.exit(main())
