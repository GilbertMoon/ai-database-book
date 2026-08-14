from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "book"
BLOG_DIR = ROOT / "blog"

SERIES_TITLE = "AI 시대의 데이터베이스 입문"
COMMON_TAGS = [
    "데이터베이스",
    "PostgreSQL",
    "SQL",
    "ChatGPT",
    "Codex",
    "AI활용",
    "데이터설계",
    "DBMS",
    "데이터분석",
    "초보자강의",
]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8").replace("\r\n", "\n")


def first_h1(markdown: str, fallback: str) -> str:
    match = re.search(r"^#\s+(.+?)\s*$", markdown, re.MULTILINE)
    return match.group(1).strip() if match else fallback


def blog_preamble(source_rel: str, title: str) -> str:
    return (
        "<!-- AUTO-GENERATED: scripts/generate_class_blog_md.py -->\n"
        f"<!-- SOURCE: {source_rel} -->\n\n"
        "> **수업용 블로그 자료**  \n"
        f"> 『{SERIES_TITLE}』 수업에서 바로 활용할 수 있도록 책 원고를 Markdown으로 정리한 자료입니다.  \n"
        "> 설명을 읽은 뒤 코드와 실습은 직접 실행하고, AI가 만든 답은 실행 결과로 검증하세요.\n\n"
    )


def blog_footer(chapter_no: int | None = None) -> str:
    tags = " ".join(f"#{tag}" for tag in COMMON_TAGS)
    nav = ""
    if chapter_no is not None:
        prev_link = (
            f"[← Chapter {chapter_no - 1:02d}](../chapter{chapter_no - 1:02d}/chapter{chapter_no - 1:02d}.md)"
            if chapter_no > 1
            else "[← 전체 목차](../index.md)"
        )
        next_link = (
            f"[Chapter {chapter_no + 1:02d} →](../chapter{chapter_no + 1:02d}/chapter{chapter_no + 1:02d}.md)"
            if chapter_no < 15
            else "[전체 목차 →](../index.md)"
        )
        nav = f"\n\n---\n\n{prev_link} · {next_link}\n"
    return f"{nav}\n\n---\n\n## 블로그 태그\n\n{tags}\n"


def write_blog_copy(source: Path, target: Path, chapter_no: int | None = None) -> str:
    body = read_text(source).strip() + "\n"
    title = first_h1(body, source.stem)
    rel = source.relative_to(ROOT).as_posix()
    output = blog_preamble(rel, title) + body + blog_footer(chapter_no)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(output, encoding="utf-8")
    return title


def find_overview() -> Path | None:
    candidates = [
        BOOK_DIR / "overview" / "overview.md",
        BOOK_DIR / "overview.md",
        BOOK_DIR / "00_overview.md",
    ]
    for path in candidates:
        if path.exists():
            return path
    return None


def build_index(chapter_titles: list[tuple[int, str]], overview_target: Path | None) -> None:
    lines = [
        "# AI 시대의 데이터베이스 입문 · 수업용 블로그 목차",
        "",
        "ChatGPT와 Codex를 활용해 PostgreSQL, SQL, 데이터 설계와 분석을 배우는 수업용 Markdown 자료입니다.",
        "",
        "## 학습 순서",
        "",
    ]
    if overview_target is not None:
        lines.append("- [Overview · 이 책을 시작하기 전에](overview/overview.md)")
    for no, title in chapter_titles:
        lines.append(f"- [Chapter {no:02d} · {title}](chapter{no:02d}/chapter{no:02d}.md)")
    lines.extend(
        [
            "",
            "## 활용 방법",
            "",
            "1. 각 Chapter의 개념 설명을 먼저 읽습니다.",
            "2. SQL과 코드는 직접 실행해 결과를 확인합니다.",
            "3. ChatGPT/Codex는 정답 생성기가 아니라 초안 작성과 검증 보조 도구로 사용합니다.",
            "4. 각 장의 activity 파일이 있으면 본문 학습 뒤 실습 과제로 진행합니다.",
            "",
            "## 공통 태그",
            "",
            " ".join(f"#{tag}" for tag in COMMON_TAGS),
            "",
        ]
    )
    BLOG_DIR.mkdir(parents=True, exist_ok=True)
    (BLOG_DIR / "index.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    if not BOOK_DIR.exists():
        raise FileNotFoundError(BOOK_DIR)

    BLOG_DIR.mkdir(parents=True, exist_ok=True)
    chapter_titles: list[tuple[int, str]] = []

    overview_source = find_overview()
    overview_target: Path | None = None
    if overview_source is not None:
        overview_target = BLOG_DIR / "overview" / "overview.md"
        write_blog_copy(overview_source, overview_target)

    missing: list[str] = []
    for no in range(1, 16):
        chapter = f"chapter{no:02d}"
        source = BOOK_DIR / chapter / f"{chapter}.md"
        if not source.exists():
            missing.append(source.relative_to(ROOT).as_posix())
            continue

        target = BLOG_DIR / chapter / f"{chapter}.md"
        full_title = write_blog_copy(source, target, chapter_no=no)
        clean_title = re.sub(r"^Chapter\s+\d+[.]?\s*", "", full_title, flags=re.IGNORECASE).strip()
        chapter_titles.append((no, clean_title))

        activity = BOOK_DIR / chapter / f"{chapter}_activity.md"
        if activity.exists():
            write_blog_copy(activity, BLOG_DIR / chapter / f"{chapter}_activity.md", chapter_no=None)

    if missing:
        raise FileNotFoundError("Missing chapter sources:\n" + "\n".join(missing))
    if len(chapter_titles) != 15:
        raise RuntimeError(f"Expected 15 chapters, generated {len(chapter_titles)}")

    build_index(chapter_titles, overview_target)

    generated_md = sorted(BLOG_DIR.rglob("*.md"))
    print(f"Generated {len(generated_md)} blog Markdown files")
    for path in generated_md:
        print(path.relative_to(ROOT).as_posix())


if __name__ == "__main__":
    main()
