#!/usr/bin/env python3
"""Normalize presentation narration to Korean pronunciations for TTS.

The presentation keeps English technical terms on slide screens, while speaker
scripts use pronounceable Korean spellings. This command applies one shared
standard to the course overview and Chapter 01-15 narration sources, and makes
all script HTML pages load the shared browser-side pronunciation guard.

Run from the repository root:

    python scripts/normalize_presentation_tts_terms.py
    python scripts/normalize_presentation_tts_terms.py --apply
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Iterable

TERM_MAP: list[tuple[str, str, int]] = [
    (r"\bROLLBACK TO SAVEPOINT\b", "롤백 투 세이브포인트", 0),
    (r"\bEXPLAIN ANALYZE\b", "익스플레인 애널라이즈", 0),
    (r"\bBITMAP INDEX SCAN\b", "비트맵 인덱스 스캔", re.I),
    (r"\bBITMAP HEAP SCAN\b", "비트맵 힙 스캔", re.I),
    (r"\bCREATE UNIQUE INDEX\b", "크리에이트 유니크 인덱스", 0),
    (r"\bCREATE TABLE\b", "크리에이트 테이블", 0),
    (r"\bPRIMARY KEY\b", "프라이머리 키", 0),
    (r"\bFOREIGN KEY\b", "포린 키", 0),
    (r"\bFULL OUTER JOIN\b", "풀 아우터 조인", 0),
    (r"\bINNER JOIN\b", "이너 조인", 0),
    (r"\bLEFT JOIN\b", "레프트 조인", 0),
    (r"\bRIGHT JOIN\b", "라이트 조인", 0),
    (r"\bCROSS JOIN\b", "크로스 조인", 0),
    (r"\bGROUP BY\b", "그룹 바이", 0),
    (r"\bORDER BY\b", "오더 바이", 0),
    (r"\bPARTITION BY\b", "파티션 바이", 0),
    (r"\bFOR UPDATE\b", "포 업데이트", 0),
    (r"\bNOT EXISTS\b", "낫 이그지스츠", 0),
    (r"\bNOT NULL\b", "낫 널", 0),
    (r"\bON DELETE RESTRICT\b", "온 딜리트 리스트릭트", 0),
    (r"\bON DELETE CASCADE\b", "온 딜리트 캐스케이드", 0),
    (r"\bREPEATABLE READ\b", "리피터블 리드", 0),
    (r"\bREAD COMMITTED\b", "리드 커미티드", 0),
    (r"\bREAD ONLY\b", "리드 온리", 0),
    (r"\bSQLSTATE\b", "에스큐엘 스테이트", 0),
    (r"\bSQLAlchemy\b", "에스큐엘알케미", 0),
    (r"\bPostgreSQL\b", "포스트그레스큐엘", 0),
    (r"\bChatGPT\b", "챗지피티", 0),
    (r"\bDBeaver\b", "디비버", 0),
    (r"\bNoSQL\b", "노에스큐엘", 0),
    (r"\bRDBMS\b", "알디비엠에스", 0),
    (r"\bDBMS\b", "디비엠에스", 0),
    (r"\bJSONB\b", "제이슨비", 0),
    (r"\bJSON\b", "제이슨", 0),
    (r"\bPython\b", "파이썬", 0),
    (r"\bpandas\b", "판다스", re.I),
    (r"\bmatplotlib\b", "맷플롯립", re.I),
    (r"\bpsycopg\b", "사이코피지", re.I),
    (r"\bCodex\b", "코덱스", 0),
    (r"\bGitHub\b", "깃허브", 0),
    (r"\bGit\b", "깃", 0),
    (r"\bdiff\b", "디프", re.I),
    (r"\bChapter\b", "챕터", 0),
    (r"\bDatabase\b", "데이터베이스", 0),
    (r"\bSchema\b", "스키마", 0),
    (r"\bTable\b", "테이블", 0),
    (r"\bColumn\b", "열", 0),
    (r"\bRow\b", "행", 0),
    (r"\bCell\b", "셀", 0),
    (r"\bServer\b", "서버", 0),
    (r"\bClient\b", "클라이언트", 0),
    (r"\bEntity\b", "엔터티", 0),
    (r"\bAttribute\b", "애트리뷰트", 0),
    (r"\bRelationship\b", "릴레이션십", 0),
    (r"\bRequirements?\b", "리콰이어먼트", 0),
    (r"\bConceptual\b", "컨셉추얼", 0),
    (r"\bLogical\b", "로지컬", 0),
    (r"\bPhysical\b", "피지컬", 0),
    (r"\bAuto-commit\b", "오토 커밋", re.I),
    (r"\bManual commit\b", "매뉴얼 커밋", re.I),
    (r"\bcurrent transaction is aborted\b", "커런트 트랜잭션 이즈 어보티드", re.I),
    (r"\btransaction_lab\b", "트랜잭션 랩", 0),
    (r"\bcourse_project\b", "코스 프로젝트", 0),
    (r"\bcourse_inventory\b", "코스 인벤토리", 0),
    (r"\btutor_project_restore\b", "튜터 프로젝트 리스토어", 0),
    (r"\btutor_project\b", "튜터 프로젝트", 0),
    (r"\bquestion_materials\b", "퀘스천 머티리얼즈", 0),
    (r"\blearning_materials\b", "러닝 머티리얼즈", 0),
    (r"\bstudents\b", "스튜던츠", 0),
    (r"\binstructors\b", "인스트럭터스", 0),
    (r"\bcourses\b", "코시스", 0),
    (r"\benrollments\b", "인롤먼츠", 0),
    (r"\bpayments\b", "페이먼츠", 0),
    (r"\bSQL\b", "에스큐엘", 0),
    (r"\bAI\b", "에이아이", 0),
    (r"\bTTS\b", "티티에스", 0),
    (r"\bAPI\b", "에이피아이", 0),
    (r"\bERD\b", "이알디", 0),
    (r"\bDDL\b", "디디엘", 0),
    (r"\bDML\b", "디엠엘", 0),
    (r"\bDCL\b", "디씨엘", 0),
    (r"\bTCL\b", "티씨엘", 0),
    (r"\bCRUD\b", "크러드", 0),
    (r"\bCSV\b", "씨에스브이", 0),
    (r"\bURL\b", "유알엘", 0),
    (r"\bSSL\b", "에스에스엘", 0),
    (r"\bCTE\b", "씨티이", 0),
    (r"\bACID\b", "에이씨아이디", 0),
    (r"\bRLS\b", "알엘에스", 0),
    (r"\bACL\b", "에이씨엘", 0),
    (r"\bPK\b", "피케이", 0),
    (r"\bFK\b", "에프케이", 0),
    (r"\bID\b", "아이디", 0),
    (r"\bIDENTITY\b", "아이덴티티", 0),
    (r"\bVIEW\b", "뷰", 0),
    (r"\bRETURNING\b", "리터닝", 0),
    (r"\bROLLBACK\b", "롤백", 0),
    (r"\bCOMMIT\b", "커밋", 0),
    (r"\bBEGIN\b", "비긴", 0),
    (r"\bSAVEPOINT\b", "세이브포인트", 0),
    (r"\bEXPLAIN\b", "익스플레인", 0),
    (r"\bANALYZE\b", "애널라이즈", 0),
    (r"\bSeq Scan\b", "시퀀셜 스캔", 0),
    (r"\bIndex Only Scan\b", "인덱스 온리 스캔", 0),
    (r"\bIndex Scan\b", "인덱스 스캔", 0),
    (r"\bGIN\b", "진", 0),
    (r"\bB-tree\b", "비트리", re.I),
    (r"\bB\+Tree\b", "비플러스 트리", 0),
    (r"\bJOIN\b", "조인", 0),
    (r"\bNULL\b", "널", 0),
    (r"\bINSERT\b", "인서트", 0),
    (r"\bSELECT\b", "셀렉트", 0),
    (r"\bUPDATE\b", "업데이트", 0),
    (r"\bDELETE\b", "딜리트", 0),
    (r"\bWHERE\b", "웨어", 0),
    (r"\bHAVING\b", "해빙", 0),
    (r"\bDISTINCT\b", "디스팅트", 0),
    (r"\bFILTER\b", "필터", 0),
    (r"\bCOALESCE\b", "코얼레스", 0),
    (r"\bUNIQUE\b", "유니크", 0),
    (r"\bCHECK\b", "체크", 0),
    (r"\bREFERENCES\b", "레퍼런시스", 0),
    (r"\bCASCADE\b", "캐스케이드", 0),
    (r"\bRESTRICT\b", "리스트릭트", 0),
    (r"\bDEFAULT\b", "디폴트", 0),
    (r"\bPUBLIC\b", "퍼블릭", 0),
    (r"\bGRANT\b", "그랜트", 0),
    (r"\bPGPASSFILE\b", "피지 패스 파일", 0),
    (r"\bpg_dump\b", "피지 덤프", 0),
    (r"\bpg_restore\b", "피지 리스토어", 0),
    (r"\bLock\b", "락", 0),
    (r"\bDeadlock\b", "데드락", 0),
    (r"\block_timeout\b", "락 타임아웃", 0),
    (r"\bAtomicity\b", "아토미시티", 0),
    (r"\bConsistency\b", "컨시스턴시", 0),
    (r"\bIsolation\b", "아이솔레이션", 0),
    (r"\bDurability\b", "듀러빌리티", 0),
    (r"\b1NF\b", "제일 정규형", 0),
    (r"\b2NF\b", "제이 정규형", 0),
    (r"\b3NF\b", "제삼 정규형", 0),
    (r"COUNT\(\*\)", "카운트 별표", 0),
    (r"\bCOUNT\b", "카운트", 0),
    (r"\bSUM\b", "썸", 0),
    (r"\bAVG\b", "에버리지", 0),
    (r"\bMIN\b", "민", 0),
    (r"\bMAX\b", "맥스", 0),
]

SCRIPT_TAG_NAME = "tts_pronunciation.js"
ROOT_SCRIPT_TAG = '<script src="common/tts_pronunciation.js"></script>'
CHAPTER_SCRIPT_TAG = '<script src="../common/tts_pronunciation.js"></script>'


def normalize_text(text: str) -> str:
    result = text
    for pattern, replacement, flags in TERM_MAP:
        result = re.sub(pattern, replacement, result, flags=flags | re.ASCII)
    return result


def normalize_markdown_scripts(content: str) -> str:
    marker = re.compile(r"(\*\*발표 스크립트\*\*\s*\n)")
    parts = marker.split(content)
    if len(parts) == 1:
        return content

    output = [parts[0]]
    for index in range(1, len(parts), 2):
        output.append(parts[index])
        body = parts[index + 1]
        end = re.search(r"\n---(?:\n|$)", body)
        if end:
            output.append(normalize_text(body[: end.start()]))
            output.append(body[end.start() :])
        else:
            output.append(normalize_text(body))
    return "".join(output)


def _normalize_matched_string(match: re.Match[str]) -> str:
    return f"{match.group(1)}{normalize_text(match.group(2))}{match.group(3)}"


def normalize_js_scripts(content: str) -> str:
    patterns = [
        re.compile(r"((?:\.s\s*=|\bs\s*:)\s*`)(.*?)(`)", re.DOTALL),
        re.compile(r'((?:\.s\s*=|\bs\s*:)\s*")((?:\\.|[^"\\])*)(")', re.DOTALL),
        re.compile(r"((?:\.s\s*=|\bs\s*:)\s*')((?:\\.|[^'\\])*)(')", re.DOTALL),
    ]
    result = content
    for pattern in patterns:
        result = pattern.sub(_normalize_matched_string, result)
    return result


def normalize_course_overview(content: str) -> str:
    pattern = re.compile(r"(const DATA=)(\[.*?\])(,CH=)", re.DOTALL)
    match = pattern.search(content)
    if not match:
        return content

    try:
        slides = json.loads(match.group(2))
    except json.JSONDecodeError:
        return content

    for slide in slides:
        if isinstance(slide, dict) and isinstance(slide.get("texts"), list):
            slide["texts"] = [normalize_text(text) if isinstance(text, str) else text for text in slide["texts"]]

    encoded = json.dumps(slides, ensure_ascii=False, separators=(",", ":"))
    return content[: match.start()] + match.group(1) + encoded + match.group(3) + content[match.end() :]


def ensure_shared_script_tag(content: str, *, chapter_page: bool) -> str:
    if SCRIPT_TAG_NAME in content:
        return content
    tag = CHAPTER_SCRIPT_TAG if chapter_page else ROOT_SCRIPT_TAG
    closing = content.lower().rfind("</body>")
    if closing < 0:
        return content + "\n" + tag + "\n"
    return content[:closing] + tag + "\n" + content[closing:]


def normalize_html(path: Path, content: str) -> str:
    if path.name == "course_overview_script.html":
        result = normalize_course_overview(content)
        return ensure_shared_script_tag(result, chapter_page=False)
    if re.fullmatch(r"chapter\d{2}_script\.html", path.name):
        return ensure_shared_script_tag(content, chapter_page=True)
    return content


def normalize_file(path: Path) -> str:
    content = path.read_text(encoding="utf-8")
    if path.suffix == ".md":
        return normalize_markdown_scripts(content)
    if path.suffix == ".js":
        return normalize_js_scripts(content)
    if path.suffix == ".html":
        return normalize_html(path, content)
    return content


def iter_targets(root: Path) -> Iterable[Path]:
    presentation = root / "presentation"
    yield presentation / "course_overview_script.html"
    yield from presentation.glob("chapter*/chapter*_lecture_plan.md")
    yield from presentation.glob("chapter*/chapter*_script.html")
    for path in presentation.glob("chapter*/**/*.js"):
        if "presentation/common" not in path.as_posix():
            yield path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="rewrite files in place")
    args = parser.parse_args()

    root = Path.cwd()
    changed: list[Path] = []
    for path in sorted(set(iter_targets(root))):
        if not path.is_file():
            continue
        original = path.read_text(encoding="utf-8")
        updated = normalize_file(path)
        if updated != original:
            changed.append(path)
            if args.apply:
                path.write_text(updated, encoding="utf-8")

    action = "updated" if args.apply else "would update"
    if changed:
        for path in changed:
            print(f"{action}: {path.as_posix()}")
    else:
        print("No TTS normalization changes needed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
