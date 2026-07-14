"""Safely finalize project image asset migration.

This script used to regenerate Chapter 15 Mermaid and SVG assets from embedded
legacy templates. Those templates no longer match the current Chapter 15
方向, where SQL and Python analysis are mandatory and RAG is removed.

The migration is now intentionally non-generative:

1. clean up obsolete legacy filenames;
2. verify that the current Chapter 15 assets exist;
3. fail fast when stale RAG or legacy references reappear.

Current Mermaid, SVG, and README files are maintained directly in
``images/chapter15`` and must not be overwritten by this migration utility.
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMAGE_DIR = ROOT / "images"
CHAPTER07_DIR = IMAGE_DIR / "chapter07"
CHAPTER15_DIR = IMAGE_DIR / "chapter15"

CHAPTER07_RENAMES = {
    "ch07_01_midterm_project_flow": "ch07_01_project_flow",
    "ch07_07_ai_review_report_flow": "ch07_07_ai_review_flow",
    "ch07_08_assessment_rubric_overview": "ch07_08_project_completion_checklist",
}

CHAPTER15_LEGACY_STEMS = (
    "ch15_01_final_project_flow",
    "ch15_02_evaluation_modes",
    "ch15_03_submission_structure",
    "ch15_06_rubric_breakdown",
    "ch15_07_presentation_flow",
    "ch15_08_final_checklist",
)

CHAPTER15_CURRENT_STEMS = (
    "ch15_01_service_project_flow",
    "ch15_02_scope_selection_guide",
    "ch15_03_project_structure",
    "ch15_04_db_design_validation",
    "ch15_05_ai_review_loop",
    "ch15_06_completion_dimensions",
    "ch15_07_project_story_flow",
    "ch15_08_completion_checklist",
)

FORBIDDEN_CHAPTER15_TERMS = (
    "Vector DB",
    "벡터 DB",
    "RAG",
    "09_optional_rag_extension.sql",
    "ch15_02_evaluation_modes",
    "ch15_03_submission_structure",
    "ch15_07_presentation_flow",
    "ch15_08_final_checklist",
)

REQUIRED_CONTENT = {
    "README.md": (
        "SQL·Python 분석",
        "웹 CRUD·API, NoSQL과 배포는 선택 확장",
    ),
    "ch15_02_scope_selection_guide.mmd": (
        "Python·pandas 분석",
        "웹 CRUD/API",
        "NoSQL",
        "배포",
    ),
    "ch15_03_project_structure.mmd": (
        "09_analysis_dataset.sql",
        "python/01_load_postgresql.py",
        "analysis_report.md",
    ),
    "ch15_07_project_story_flow.mmd": (
        "SQL 분석·분석 VIEW",
        "Python·pandas 분석",
        "SQL·Python 결과 비교",
    ),
    "ch15_08_completion_checklist.mmd": (
        "VIEW 5행",
        "SQL·pandas 핵심 집계 일치",
        "required_completion_gate_passed = true",
    ),
}


def migrate_chapter07_filenames() -> list[Path]:
    """Rename remaining Chapter 07 legacy files without rewriting content."""
    changed: list[Path] = []

    for old_stem, new_stem in CHAPTER07_RENAMES.items():
        for suffix in (".mmd", ".svg"):
            old_path = CHAPTER07_DIR / f"{old_stem}{suffix}"
            new_path = CHAPTER07_DIR / f"{new_stem}{suffix}"

            if not old_path.exists():
                continue

            if new_path.exists():
                old_path.unlink()
                changed.append(old_path)
            else:
                old_path.rename(new_path)
                changed.extend((old_path, new_path))

    return changed


def remove_chapter15_legacy_files() -> list[Path]:
    """Remove obsolete Chapter 15 filenames; never regenerate their content."""
    removed: list[Path] = []

    for stem in CHAPTER15_LEGACY_STEMS:
        for suffix in (".mmd", ".svg"):
            path = CHAPTER15_DIR / f"{stem}{suffix}"
            if path.exists():
                path.unlink()
                removed.append(path)

    return removed


def chapter15_files() -> list[Path]:
    files = [CHAPTER15_DIR / "README.md"]
    for stem in CHAPTER15_CURRENT_STEMS:
        files.extend(
            (
                CHAPTER15_DIR / f"{stem}.mmd",
                CHAPTER15_DIR / f"{stem}.svg",
            )
        )
    return files


def validate_chapter15_assets() -> None:
    """Ensure current SQL/Python assets exist and stale RAG content is absent."""
    missing = [path for path in chapter15_files() if not path.exists()]
    if missing:
        relative = "\n".join(f"- {path.relative_to(ROOT)}" for path in missing)
        raise FileNotFoundError(
            "Chapter 15 current assets are missing. Restore the maintained files "
            f"instead of regenerating legacy templates:\n{relative}"
        )

    stale_matches: list[str] = []
    for path in chapter15_files():
        text = path.read_text(encoding="utf-8")
        for term in FORBIDDEN_CHAPTER15_TERMS:
            if term in text:
                stale_matches.append(f"{path.relative_to(ROOT)}: {term}")

    if stale_matches:
        details = "\n".join(f"- {item}" for item in stale_matches)
        raise ValueError(
            "Legacy Chapter 15 content was detected. Keep SQL/Python integration "
            f"and remove RAG-era references:\n{details}"
        )

    missing_markers: list[str] = []
    for relative_path, markers in REQUIRED_CONTENT.items():
        path = CHAPTER15_DIR / relative_path
        text = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in text:
                missing_markers.append(f"{path.relative_to(ROOT)}: {marker}")

    if missing_markers:
        details = "\n".join(f"- {item}" for item in missing_markers)
        raise ValueError(
            "Chapter 15 SQL/Python integration markers are missing:\n"
            f"{details}"
        )


def main() -> None:
    changed = migrate_chapter07_filenames()
    changed.extend(remove_chapter15_legacy_files())
    validate_chapter15_assets()

    if changed:
        print("Cleaned legacy project image assets:")
        for path in changed:
            print(f"- {path.relative_to(ROOT)}")

    print(
        "Chapter 15 assets are current: SQL/Python analysis is mandatory, "
        "RAG references are absent, and no files were regenerated."
    )


if __name__ == "__main__":
    main()
