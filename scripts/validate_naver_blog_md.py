from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BLOG_DIR = ROOT / "blog"


def has_any(text: str, patterns: list[str]) -> bool:
    return any(re.search(pattern, text, flags=re.MULTILINE) for pattern in patterns)


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

    # Chapters intentionally use slightly different introductory headings.
    learning_patterns = [
        r"^## 오늘 배울 내용\s*$",
        r"^## 이 장에서 살펴볼 내용\s*$",
        r"^## 이 장에서 완성할 것\s*$",
        r"^## .*배울 내용\s*$",
        r"^## .*학습 목표\s*$",
    ]
    if not has_any(text, learning_patterns):
        # Some project chapters introduce the goal directly before STEP 1.
        if "프로젝트" not in text[:2500] and "이번 시간" not in text[:2500]:
            errors.append(f"Chapter {chapter:02d}: missing learning-goal introduction")

    for practice_no in (1, 2):
        practice_pattern = rf"^#{{1,2}}\s+(?:AI 활용 )?실습 {practice_no}\."
        if not re.search(practice_pattern, text, flags=re.MULTILINE):
            errors.append(f"Chapter {chapter:02d}: missing AI/practice section {practice_no}")

    summary_patterns = [
        r"^#{{1,2}}\s+오늘의 핵심 정리\s*$",
        r"^#{{1,2}}\s+전체 과정 핵심 정리\s*$",
    ]
    if not has_any(text, summary_patterns):
        errors.append(f"Chapter {chapter:02d}: missing summary section")

    step_numbers = [
        int(n)
        for n in re.findall(r"^#{1,2}\s+STEP\s+(\d+)\.", text, flags=re.MULTILINE)
    ]
    if not step_numbers:
        errors.append(f"Chapter {chapter:02d}: no STEP sections found")
    else:
        expected = list(range(1, max(step_numbers) + 1))
        if step_numbers != expected:
            errors.append(
                f"Chapter {chapter:02d}: STEP numbers are not continuous: {step_numbers}"
            )

    # Naver posts should end with a useful tag set.
    hashtags = re.findall(r"(?<!\S)#([^\s#]+)", text)
    final_hashtag_line = next(
        (
            line.strip()
            for line in reversed(lines)
            if line.strip().startswith("#") and line.count("#") >= 2
        ),
        "",
    )
    final_hashtags = re.findall(r"(?<!\S)#([^\s#]+)", final_hashtag_line)
    if len(final_hashtags) < 8:
        errors.append(
            f"Chapter {chapter:02d}: expected at least 8 final hashtags; found {len(final_hashtags)}"
        )
    if not hashtags:
        errors.append(f"Chapter {chapter:02d}: no hashtags found")

    # Navigation can be an explicit chapter reference or a clear next-learning section.
    if chapter < 15:
        next_ref = f"Chapter {chapter + 1:02d}"
        has_next_guidance = (
            next_ref in text
            or "## 다음 시간에는" in text
            or "## 다음 학습" in text
        )
        if not has_next_guidance:
            errors.append(f"Chapter {chapter:02d}: missing next-learning guidance")
    else:
        if "## 전체 과정 핵심 정리" not in text or "Chapter 15" not in text:
            errors.append("Chapter 15: missing whole-course wrap-up")

    # Validate relative Markdown image links if curated posts include any.
    for target in re.findall(r"!\[[^\]]*\]\(([^)]+)\)", text):
        if re.match(r"^[a-z]+://", target, flags=re.IGNORECASE):
            continue
        image_path = (path.parent / target).resolve()
        if not image_path.exists():
            errors.append(f"Chapter {chapter:02d}: broken image path {target!r}")

    # Curated Naver files must not be overwritten by the auto-generated source banner.
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
