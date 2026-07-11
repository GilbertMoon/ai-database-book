from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REPLACEMENTS = {
    ROOT / "book/chapter01/chapter01.md": {
        "![AI 시대의 DB 학습 흐름](../../images/chapter01/ch01_03_ai_db_learning_flow.svg)":
        "![AI 시대의 데이터베이스 작업 흐름](../../images/chapter01/ch01_03_ai_db_learning_flow.svg)",
    },
}


def update_file(path: Path, replacements: dict[str, str]) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = original

    for old, new in replacements.items():
        updated = updated.replace(old, new)

    if updated == original:
        return False

    path.write_text(updated, encoding="utf-8")
    return True


def main() -> None:
    changed: list[Path] = []

    for path, replacements in REPLACEMENTS.items():
        if not path.exists():
            raise FileNotFoundError(f"Missing file: {path}")
        if update_file(path, replacements):
            changed.append(path.relative_to(ROOT))

    if changed:
        print("Synchronized image references:")
        for path in changed:
            print(f"- {path}")
    else:
        print("Image references are already synchronized.")


if __name__ == "__main__":
    main()
