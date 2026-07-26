#!/usr/bin/env python3
"""Normalize English technical terms inside presentation script text for TTS.

This script only rewrites narration areas:
- Markdown lecture plans: text after '**발표 스크립트**' until the next slide separator '---'.
- Chapter 01 JavaScript slide scripts: template strings assigned to '.s'.

It intentionally avoids screen-composition blocks, SQL code blocks, file paths, and table labels.
Run from the repository root:

    python scripts/normalize_presentation_tts_terms.py --apply

Without --apply, it prints files that would change.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

TERM_MAP: list[tuple[str, str]] = [
    (r"\bAI\b", "에이아이"),
    (r"\bSQLSTATE\b", "에스큐엘 스테이트"),
    (r"\bSQL\b", "에스큐엘"),
    (r"\bINNER JOIN\b", "이너 조인"),
    (r"\bLEFT JOIN\b", "레프트 조인"),
    (r"\bJOIN\b", "조인"),
    (r"\bNULL\b", "널"),
    (r"\bDBMS\b", "디비엠에스"),
    (r"\bRDBMS\b", "알디비엠에스"),
    (r"\bNoSQL\b", "노에스큐엘"),
    (r"\bPostgreSQL\b", "포스트그레스큐엘"),
    (r"\bDBeaver\b", "디비버"),
    (r"\bERD\b", "이알디"),
    (r"\bDDL\b", "디디엘"),
    (r"\bDML\b", "디엠엘"),
    (r"\bDCL\b", "디씨엘"),
    (r"\bTCL\b", "티씨엘"),
    (r"\bPK\b", "기본키"),
    (r"\bFK\b", "외래키"),
    (r"\bID\b", "아이디"),
    (r"\bAPI\b", "에이피아이"),
    (r"\bCRUD\b", "크러드"),
    (r"\bCSV\b", "씨에스브이"),
    (r"\bJSONB\b", "제이슨비"),
    (r"\bJSON\b", "제이슨"),
    (r"\bPython\b", "파이썬"),
    (r"\bpandas\b", "판다스"),
    (r"\bmatplotlib\b", "맷플롯립"),
    (r"\bSQLAlchemy\b", "에스큐엘알케미"),
    (r"\bpsycopg\b", "사이코피지"),
    (r"\bGit\b", "깃"),
    (r"\bdiff\b", "디프"),
    (r"\bCodex\b", "코덱스"),
    (r"\bChatGPT\b", "챗지피티"),
    (r"\bTTS\b", "티티에스"),
    (r"\bVIEW\b", "뷰"),
    (r"\bRETURNING\b", "리터닝"),
    (r"\bROLLBACK\b", "롤백"),
    (r"\bCOMMIT\b", "커밋"),
    (r"\bBEGIN\b", "비긴"),
    (r"\bEXPLAIN\b", "익스플레인"),
    (r"\bSeq Scan\b", "시퀀셜 스캔"),
    (r"\bIndex Scan\b", "인덱스 스캔"),
    (r"\bGIN\b", "진"),
    (r"\bB-tree\b", "비트리"),
    (r"\bB\+Tree\b", "비플러스 트리"),
    (r"COUNT\(\*\)", "카운트 별표"),
    (r"COUNT\(", "카운트 함수"),
]


def normalize_text(text: str) -> str:
    result = text
    for pattern, replacement in TERM_MAP:
        result = re.sub(pattern, replacement, result)
    return result


def normalize_markdown_scripts(content: str) -> str:
    parts = re.split(r"(\*\*발표 스크립트\*\*\n)", content)
    if len(parts) == 1:
        return content

    out = [parts[0]]
    for i in range(1, len(parts), 2):
        marker = parts[i]
        body = parts[i + 1]
        match = re.search(r"\n---\n", body)
        if match:
            script = body[: match.start()]
            rest = body[match.start() :]
            out.append(marker)
            out.append(normalize_text(script))
            out.append(rest)
        else:
            out.append(marker)
            out.append(normalize_text(body))
    return "".join(out)


def normalize_js_scripts(content: str) -> str:
    pattern = re.compile(r"(\.s\s*=\s*`)(.*?)(`;)", re.DOTALL)
    return pattern.sub(lambda m: m.group(1) + normalize_text(m.group(2)) + m.group(3), content)


def normalize_file(path: Path) -> str:
    content = path.read_text(encoding="utf-8")
    if path.suffix == ".md":
        return normalize_markdown_scripts(content)
    if path.suffix == ".js":
        return normalize_js_scripts(content)
    return content


def iter_targets(root: Path):
    presentation = root / "presentation"
    yield from presentation.glob("chapter*/chapter*_lecture_plan.md")
    yield from presentation.glob("chapter01/*script*.js")
    yield from presentation.glob("chapter01/*patch*.js")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="rewrite files in place")
    args = parser.parse_args()

    root = Path.cwd()
    changed: list[Path] = []
    for path in sorted(set(iter_targets(root))):
        original = path.read_text(encoding="utf-8")
        updated = normalize_file(path)
        if updated != original:
            changed.append(path)
            if args.apply:
                path.write_text(updated, encoding="utf-8")

    if changed:
        action = "updated" if args.apply else "would update"
        for path in changed:
            print(f"{action}: {path.as_posix()}")
    else:
        print("No TTS normalization changes needed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
