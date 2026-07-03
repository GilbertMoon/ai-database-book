from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
PUBLISH_DIR = ROOT / "publish"
OUTPUT_FILE = PUBLISH_DIR / "full_manuscript.md"

CHAPTER_COUNT = 15


def read_chapter(chapter_no: int) -> str:
    chapter_name = f"chapter{chapter_no:02d}"
    chapter_file = BOOK_DIR / chapter_name / f"{chapter_name}.md"

    if not chapter_file.exists():
        return f"\n\n<!-- Missing: {chapter_file} -->\n"

    return chapter_file.read_text(encoding="utf-8").strip()


def main() -> None:
    PUBLISH_DIR.mkdir(exist_ok=True)

    parts = [
        "# AI 시대의 데이터베이스 입문",
        "",
        "> 이 파일은 scripts/merge_chapters.py로 생성되는 통합 원고입니다.",
        "",
    ]

    for chapter_no in range(1, CHAPTER_COUNT + 1):
        parts.append(read_chapter(chapter_no))
        parts.append("\n---\n")

    OUTPUT_FILE.write_text("\n\n".join(parts), encoding="utf-8")
    print(f"Generated: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
