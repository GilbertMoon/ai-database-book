from __future__ import annotations

import argparse
from pathlib import Path
import sys

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PDF = ROOT / "publish" / "ai_database_book.pdf"
DEFAULT_REPORT = ROOT / "publish" / "book_pdf_qa_report.txt"
A4_WIDTH_PT = 595.28
A4_HEIGHT_PT = 841.89
A4_TOLERANCE_PT = 2.5
MIN_PAGES = 30
MIN_BYTES = 500_000


def validate(pdf_path: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    lines: list[str] = []

    if not pdf_path.exists():
        return [f"missing PDF: {pdf_path}"], lines
    size = pdf_path.stat().st_size
    if size < MIN_BYTES:
        errors.append(f"PDF is unexpectedly small: {size:,} bytes")

    try:
        reader = PdfReader(str(pdf_path))
    except Exception as exc:  # pragma: no cover - defensive build check
        return [f"PDF cannot be opened: {exc}"], lines

    page_count = len(reader.pages)
    if page_count < MIN_PAGES:
        errors.append(f"PDF page count is unexpectedly low: {page_count}")

    non_a4_pages: list[int] = []
    for index, page in enumerate(reader.pages, start=1):
        width = float(page.mediabox.width)
        height = float(page.mediabox.height)
        portrait_match = (
            abs(width - A4_WIDTH_PT) <= A4_TOLERANCE_PT
            and abs(height - A4_HEIGHT_PT) <= A4_TOLERANCE_PT
        )
        if not portrait_match:
            non_a4_pages.append(index)
    if non_a4_pages:
        sample = ", ".join(map(str, non_a4_pages[:10]))
        errors.append(f"non-A4 pages detected: {sample}")

    sample_indexes = sorted({0, max(0, page_count // 2), max(0, page_count - 1)})
    extracted_parts: list[str] = []
    for index in sample_indexes:
        try:
            extracted_parts.append(reader.pages[index].extract_text() or "")
        except Exception:
            extracted_parts.append("")
    extracted_text = "\n".join(extracted_parts).strip()
    if len(extracted_text) < 20:
        errors.append("sample pages do not expose a usable text layer")

    metadata_title = ""
    if reader.metadata:
        metadata_title = str(reader.metadata.get("/Title") or "")

    lines.extend(
        [
            "Book PDF QA",
            f"PDF: {pdf_path.relative_to(ROOT)}",
            f"Size: {size:,} bytes",
            f"Pages: {page_count}",
            "Page size: A4 portrait" if not non_a4_pages else "Page size: FAIL",
            f"Sample text layer chars: {len(extracted_text)}",
            f"Metadata title: {metadata_title or '(not set)'}",
            f"Repository commit limit check: {'OK' if size < 95_000_000 else 'PDF too large for normal Git commit'}",
        ]
    )
    return errors, lines


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate the generated full-book PDF")
    parser.add_argument("--pdf", type=Path, default=DEFAULT_PDF)
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    args = parser.parse_args()

    errors, lines = validate(args.pdf)
    args.report.parent.mkdir(parents=True, exist_ok=True)

    if errors:
        report = "\n".join(["Book PDF QA failed", *[f"- {error}" for error in errors], "", *lines]) + "\n"
        args.report.write_text(report, encoding="utf-8")
        print(report, end="")
        return 1

    report = "\n".join(["Book PDF QA passed", *lines]) + "\n"
    args.report.write_text(report, encoding="utf-8")
    print(report, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
