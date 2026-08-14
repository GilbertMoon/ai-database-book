from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BLOG_DIR = ROOT / "blog"

REQUIRED_SECTIONS = [
    "## 오늘 배울 내용",
    "## AI 활용 실습 1.",
    "## AI 활용 실습 2.",
    "## 오늘의 핵심 정리",
    "## 관련 글",
]


def validate_chapter(chapter: int) -> list[str]:
    errors: list[str] = []
    path = BLOG_DIR / f"chapter{chapter:02d}" / f"chapter{chapter:02d}_naver.md"

    if not path.exists():
        return [f"Chapter {chapter:02d}: missing file: {path.relative_to(ROOT)}"]

    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    expected_prefix = f"# [AI 시대의 데이터베이스 입문 {chapter:02d}]"
    first_heading = next((line.strip() for line in lines if line.strip()), "")
    if not first_heading.startswith(expected_prefix):
        errors.append(
            f"Chapter {chapter:02d}: title must start with {expected_prefix!r}; got {first_heading!r}"
        )

    for section in REQUIRED_SECTIONS:
        if section not in text:
            errors.append(f"Chapter {chapter:02d}: missing required section containing {section!r}")

    step_numbers = [int(n) for n in re.findall(r"^## STEP\s+(\d+)\.", text, flags=re.MULTILINE)]
    if not step_numbers:
        errors.append(f"Chapter {chapter:02d}: no STEP sections found")
    else:
        expected = list(range(1, max(step_numbers) + 1))
        if step_numbers != expected:
            errors.append(
                f"Chapter {chapter:02d}: STEP numbers are not continuous: {step_numbers}"
            )

    tag_lines = [line.strip() for line in lines if line.strip().startswith("#") and not line.startswith("##")]
    hashtag_line = next((line for line in reversed(tag_lines) if " " in line or line.count("#") >= 2), "")
    hashtags = re.findall(r"(?<!\S)#([^\s#]+)", hashtag_line)
    if len(hashtags) < 8:
        errors.append(
            f"Chapter {chapter:02d}: expected at least 8 final hashtags; found {len(hashtags)}"
        )

    if chapter < 15:
        next_ref = f"Chapter {chapter + 1:02d}."
        if next_ref not in text:
            errors.append(f"Chapter {chapter:02d}: missing next chapter reference {next_ref!r}")
    else:
        if "Chapter 01~15" not in text and "Chapter 01부터 Chapter 15" not in text:
            errors.append("Chapter 15: missing whole-course wrap-up reference")

    # Validate relative Markdown image links if any are present in the Naver version.
    for target in re.findall(r"!\[[^\]]*\]\(([^)]+)\)", text):
        if re.match(r"^[a-z]+://", target, flags=re.IGNORECASE):
            continue
        image_path = (path.parent / target).resolve()
        if not image_path.exists():
            errors.append(
                f"Chapter {chapter:02d}: broken image path {target!r}"
            )

    # Catch accidental source-generation banner in curated Naver files.
    if "AUTO-GENERATED: scripts/generate_class_blog_md.py" in text:
        errors.append(f"Chapter {chapter:02d}: curated Naver file contains auto-generated banner")

    return errors


def main() -> int:
    all_errors: list[str] = []
    for chapter in range(1, 16):
        chapter_errors = validate_chapter(chapter)
        if chapter_errors:
            all_errors.extend(chapter_errors)
        else:
            print(f"PASS chapter{chapter:02d}")

    if all_errors:
        print("\nNaver blog Markdown QA FAILED:\n", file=sys.stderr)
        for error in all_errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("\nPASS: Chapter 01~15 Naver blog Markdown QA")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
