from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
CHAPTER_COUNT = 15

HEADING_REPLACEMENTS = {
    "## 이 장에서 다룰 내용": "## 이 장에서 살펴볼 내용",
    "## 이 장에서 배울 내용": "## 이 장에서 살펴볼 내용",
}


def normalize_chapter(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines()
    normalized: list[str] = []
    skip_blank_after_status = False

    for line in lines:
        stripped = line.strip()

        if stripped.startswith("> 상태:"):
            skip_blank_after_status = True
            continue

        if skip_blank_after_status and stripped == "":
            skip_blank_after_status = False
            continue

        skip_blank_after_status = False
        normalized.append(HEADING_REPLACEMENTS.get(stripped, line))

    result = "\n".join(normalized).rstrip() + "\n"

    if result == original:
        return False

    path.write_text(result, encoding="utf-8")
    return True


def main() -> None:
    changed: list[Path] = []

    for chapter_no in range(1, CHAPTER_COUNT + 1):
        chapter_name = f"chapter{chapter_no:02d}"
        chapter_file = BOOK_DIR / chapter_name / f"{chapter_name}.md"

        if not chapter_file.exists():
            raise FileNotFoundError(f"Missing chapter file: {chapter_file}")

        if normalize_chapter(chapter_file):
            changed.append(chapter_file.relative_to(ROOT))

    if changed:
        print("Normalized chapter headers:")
        for path in changed:
            print(f"- {path}")
    else:
        print("Chapter headers are already normalized.")


if __name__ == "__main__":
    main()
