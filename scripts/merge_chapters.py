from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
PUBLISH_DIR = ROOT / "publish"
OUTPUT_FILE = PUBLISH_DIR / "full_manuscript.md"
OVERVIEW_FILE = BOOK_DIR / "overview" / "overview.md"

CHAPTER_COUNT = 15


def normalize_paths(content: str, chapter_name: str) -> str:
    """분리 원고의 상대 경로를 publish/full_manuscript.md 기준으로 바꾼다."""
    content = content.replace("../../images/", "../images/")
    content = content.replace("../../code/", "../code/")

    local_files = [
        f"{chapter_name}_activity.md",
        f"{chapter_name}_project_guide.md",
    ]
    for file_name in local_files:
        content = content.replace(
            f"]({file_name})",
            f"](../book/{chapter_name}/{file_name})",
        )

    return content


def read_chapter(chapter_no: int) -> str:
    chapter_name = f"chapter{chapter_no:02d}"
    chapter_file = BOOK_DIR / chapter_name / f"{chapter_name}.md"

    if not chapter_file.exists():
        raise FileNotFoundError(f"Missing chapter file: {chapter_file}")

    content = chapter_file.read_text(encoding="utf-8").strip()
    return normalize_paths(content, chapter_name)


def read_overview() -> str:
    if not OVERVIEW_FILE.exists():
        raise FileNotFoundError(f"Missing overview file: {OVERVIEW_FILE}")

    return OVERVIEW_FILE.read_text(encoding="utf-8").strip()


def chapter_title(content: str, chapter_no: int) -> str:
    for line in content.splitlines():
        if line.startswith("# "):
            return line.removeprefix("# ").strip()
    return f"Chapter {chapter_no:02d}"


def main() -> None:
    PUBLISH_DIR.mkdir(exist_ok=True)

    overview = read_overview()
    chapters = [read_chapter(no) for no in range(1, CHAPTER_COUNT + 1)]

    parts = [
        "# AI 시대의 데이터베이스 입문",
        "",
        "> 이 파일은 Overview와 Chapter 01~15 최신 원고를 기준으로 scripts/merge_chapters.py가 자동 생성한 통합본입니다.",
        "",
        "<!-- 이 파일을 직접 수정하지 말고 각 chapter 원고를 수정한 뒤 병합 스크립트를 실행하세요. -->",
        "",
        overview,
        "",
        "---",
        "",
        "## 목차",
        "",
    ]

    for chapter_no, content in enumerate(chapters, start=1):
        parts.append(f"{chapter_no}. {chapter_title(content, chapter_no)}")

    parts.append("")
    parts.append("---")
    parts.append("")

    for chapter_no, content in enumerate(chapters, start=1):
        if chapter_no > 1:
            parts.extend(["", "---", ""])
        parts.append(content)

    manuscript = "\n".join(parts).rstrip() + "\n"
    OUTPUT_FILE.write_text(manuscript, encoding="utf-8")
    print(f"Generated: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
