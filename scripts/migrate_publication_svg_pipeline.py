from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = ROOT / "scripts"


def migrate_generator(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    original = text

    if "from publication_svg_utils import svg2png" not in text:
        text = text.replace("import cairosvg\n", "from publication_svg_utils import svg2png\n")

    text = text.replace("cairosvg.svg2png(", "svg2png(")

    if text == original:
        return False

    path.write_text(text, encoding="utf-8")
    return True


def main() -> None:
    generators = sorted(SCRIPTS_DIR.glob("generate_chapter??_publication.py"))
    if len(generators) != 15:
        raise RuntimeError(f"Expected 15 chapter publication generators, found {len(generators)}")

    changed: list[Path] = []
    for path in generators:
        if migrate_generator(path):
            changed.append(path)

    print(f"Publication SVG renderer migration complete: {len(changed)} file(s) changed")
    for path in changed:
        print(f"- {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
