from __future__ import annotations

from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMAGE_DIR = ROOT / "images"


def write_if_changed(path: Path, content: str) -> bool:
    content = content.rstrip() + "\n"
    if path.exists() and path.read_text(encoding="utf-8") == content:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return True


def replace_in_file(path: Path, replacements: dict[str, str]) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = original
    for old, new in replacements.items():
        updated = updated.replace(old, new)
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def flow_svg(title: str, nodes: list[str], footer: str) -> str:
    width = 1200
    box_w, box_h = 190, 72
    cols = 5
    x_gap = 35
    start_x = 55
    row_y = [125, 350]
    height = 620

    boxes: list[str] = []
    arrows: list[str] = []
    positions: list[tuple[float, float]] = []

    for index, label in enumerate(nodes):
        row, col = divmod(index, cols)
        x = start_x + col * (box_w + x_gap)
        y = row_y[row]
        positions.append((x, y))
        css = "m" if index == 0 else ("g" if index == len(nodes) - 1 else "b")
        boxes.append(f'<rect x="{x}" y="{y}" width="{box_w}" height="{box_h}" class="{css}"/>')
        lines = label.split("|")
        if len(lines) == 1:
            boxes.append(f'<text x="{x + box_w / 2}" y="{y + 36}" class="l">{escape(lines[0])}</text>')
        else:
            boxes.append(f'<text x="{x + box_w / 2}" y="{y + 27}" class="l">{escape(lines[0])}</text>')
            boxes.append(f'<text x="{x + box_w / 2}" y="{y + 50}" class="s">{escape(lines[1])}</text>')

    for index in range(len(positions) - 1):
        x1, y1 = positions[index]
        x2, y2 = positions[index + 1]
        if y1 == y2:
            start = (x1 + box_w, y1 + box_h / 2)
            end = (x2, y2 + box_h / 2)
        else:
            start = (x1 + box_w / 2, y1 + box_h)
            end = (x2 + box_w / 2, y2)
        arrows.append(
            f'<line x1="{start[0]}" y1="{start[1]}" x2="{end[0]}" y2="{end[1]}" '
            'stroke="#4a5568" stroke-width="2" marker-end="url(#arrow)"/>'
        )

    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
        '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto">'
        '<path d="M0 0L10 5L0 10z" fill="#4a5568"/></marker>'
        '<style>text{font-family:Malgun Gothic,Apple SD Gothic Neo,Noto Sans KR,Arial,sans-serif;fill:#1a202c}'
        '.t{font-size:25px;font-weight:700}.b{fill:#f7fafc;stroke:#4a5568;stroke-width:2;rx:12}'
        '.m{fill:#ebf8ff;stroke:#2b6cb0;stroke-width:2;rx:12}.g{fill:#f0fff4;stroke:#38a169;stroke-width:2;rx:12}'
        '.l{font-size:15px;text-anchor:middle;dominant-baseline:middle}.s{font-size:12px;text-anchor:middle;dominant-baseline:middle}'
        '</style></defs><rect width="100%" height="100%" fill="white"/>'
        f'<text x="600" y="42" text-anchor="middle" class="t">{escape(title)}</text>'
        + "".join(arrows)
        + "".join(boxes)
        + '<rect x="330" y="520" width="540" height="58" class="g"/>'
        + f'<text x="600" y="549" class="l">{escape(footer)}</text></svg>'
    )


def grid_svg(title: str, items: list[str], footer: str) -> str:
    width, height = 1200, 680
    box_w, box_h = 245, 78
    cols = 4
    start_x, start_y = 65, 130
    x_gap, y_gap = 35, 75
    boxes: list[str] = []

    for index, label in enumerate(items):
        row, col = divmod(index, cols)
        x = start_x + col * (box_w + x_gap)
        y = start_y + row * (box_h + y_gap)
        css = "m" if index % 3 == 0 else ("g" if index % 3 == 2 else "b")
        boxes.append(f'<rect x="{x}" y="{y}" width="{box_w}" height="{box_h}" class="{css}"/>')
        lines = label.split("|")
        boxes.append(f'<text x="{x + box_w / 2}" y="{y + 29}" class="l">{escape(lines[0])}</text>')
        if len(lines) > 1:
            boxes.append(f'<text x="{x + box_w / 2}" y="{y + 54}" class="s">{escape(lines[1])}</text>')

    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
        '<defs><style>text{font-family:Malgun Gothic,Apple SD Gothic Neo,Noto Sans KR,Arial,sans-serif;fill:#1a202c}'
        '.t{font-size:25px;font-weight:700}.b{fill:#f7fafc;stroke:#4a5568;stroke-width:2;rx:12}'
        '.m{fill:#ebf8ff;stroke:#2b6cb0;stroke-width:2;rx:12}.g{fill:#f0fff4;stroke:#38a169;stroke-width:2;rx:12}'
        '.l{font-size:15px;text-anchor:middle;dominant-baseline:middle}.s{font-size:12px;text-anchor:middle;dominant-baseline:middle}'
        '</style></defs><rect width="100%" height="100%" fill="white"/>'
        f'<text x="600" y="42" text-anchor="middle" class="t">{escape(title)}</text>'
        + "".join(boxes)
        + '<rect x="300" y="545" width="600" height="62" class="g"/>'
        + f'<text x="600" y="576" class="l">{escape(footer)}</text></svg>'
    )


def migrate_asset(directory: Path, old_stem: str, new_stem: str, mmd: str, svg: str) -> list[Path]:
    changed: list[Path] = []
    new_mmd = directory / f"{new_stem}.mmd"
    new_svg = directory / f"{new_stem}.svg"
    if write_if_changed(new_mmd, mmd):
        changed.append(new_mmd)
    if write_if_changed(new_svg, svg):
        changed.append(new_svg)

    if old_stem != new_stem:
        for suffix in (".mmd", ".svg"):
            old_path = directory / f"{old_stem}{suffix}"
            if old_path.exists():
                old_path.unlink()
                changed.append(old_path)
    return changed


def main() -> None:
    changed: list[Path] = []
    ch07 = IMAGE_DIR / "chapter07"
    ch15 = IMAGE_DIR / "chapter15"

    changed += migrate_asset(
        ch07,
        "ch07_01_midterm_project_flow",
        "ch07_01_project_flow",
        """flowchart LR
    A[요구사항] --> B[엔터티와 속성]
    B --> C[관계와 업무 규칙]
    C --> D[ERD]
    D --> E[PostgreSQL DDL]
    E --> F[샘플 데이터]
    F --> G[JOIN과 CRUD 검증]
    G --> H[정규화 검토]
    H --> I[AI 제안 검토]
    I --> J[재현 가능한 프로젝트]
""",
        flow_svg(
            "온라인 강의 데이터베이스 프로젝트 진행 흐름",
            ["요구사항", "엔터티·속성", "관계·규칙", "ERD", "PostgreSQL DDL", "샘플 데이터", "JOIN·CRUD|실행 검증", "정규화 검토", "AI 제안 검토", "재현 가능한|프로젝트"],
            "요구사항을 구조로 바꾸고 실제 데이터와 SQL로 검증한다",
        ),
    )

    changed += migrate_asset(
        ch07,
        "ch07_06_normalization_review_flow",
        "ch07_06_normalization_review_flow",
        """flowchart TD
    A[프로젝트 설계] --> B[엔터티 분리 검토]
    B --> C[중복 검토]
    C --> D[N:M 관계 검토]
    D --> E[외래키 검토]
    E --> F[이상 현상 검토]
    F --> G[JOIN 검증]
    G --> H[정규화 검토 완료]
""",
        flow_svg(
            "프로젝트 정규화 검토 흐름",
            ["프로젝트 설계", "엔터티 분리", "중복 확인", "N:M 관계", "외래키", "이상 현상|삽입·수정·삭제", "JOIN 검증", "정규화 완료"],
            "중복을 줄이면서 필요한 관계와 조회가 유지되는지 확인한다",
        ),
    )

    changed += migrate_asset(
        ch07,
        "ch07_07_ai_review_report_flow",
        "ch07_07_ai_review_flow",
        """flowchart LR
    A[AI에 요구사항 입력] --> B[AI 설계 초안]
    B --> C[테이블과 관계 검토]
    C --> D[PK/FK와 제약조건 검토]
    D --> E[SQL 실행]
    E --> F[오류와 결과 확인]
    F --> G[사람이 수정]
    G --> H[검토 기록]
    H --> C
""",
        flow_svg(
            "AI 제안을 실행 가능한 설계로 바꾸는 검토 흐름",
            ["요구사항 입력", "AI 설계 초안", "테이블·관계", "PK·FK·제약", "SQL 실행", "오류·결과 확인", "사람이 수정", "검토 기록"],
            "AI 결과는 초안이며 실행 결과와 데이터베이스 원리로 검증한다",
        ),
    )

    changed += migrate_asset(
        ch07,
        "ch07_08_assessment_rubric_overview",
        "ch07_08_project_completion_checklist",
        """flowchart TB
    A[프로젝트 완성도 점검]
    A --> B[요구사항과 범위]
    A --> C[ERD와 관계]
    A --> D[DDL과 제약조건]
    A --> E[샘플 데이터와 SQL]
    A --> F[정규화와 정합성]
    A --> G[AI 검토 기록]
    A --> H[재현성]
""",
        grid_svg(
            "온라인 강의 DB 프로젝트 완성도 점검",
            ["요구사항·범위|문제와 제외 항목", "ERD·관계|PK·FK·N:M", "DDL·제약조건|타입과 업무 규칙", "샘플 데이터|관계와 경계 상황", "핵심 SQL|JOIN·CRUD·검증", "정규화·정합성|중복과 이상 현상", "AI 검토 기록|제안·문제·수정", "재현성|다시 실행 가능한가"],
            "점수가 아니라 빠진 설계 근거와 검증 단계를 찾기 위한 점검표",
        ),
    )

    changed += migrate_asset(
        ch15,
        "ch15_01_final_project_flow",
        "ch15_01_service_project_flow",
        """flowchart LR
    A[문제 정의] --> B[사용자와 범위]
    B --> C[요구사항]
    C --> D[ERD와 DDL]
    D --> E[샘플 데이터와 핵심 SQL]
    E --> F[트랜잭션·성능·보안·복구]
    F --> G[AI 제안 검토]
    G --> H[재현 가능한 문서화]
""",
        flow_svg(
            "AI 기반 데이터베이스 서비스 완성 흐름",
            ["문제 정의", "사용자·범위", "요구사항", "ERD·DDL", "샘플·핵심 SQL", "트랜잭션·성능", "보안·복구", "AI 제안 검토", "재현 가능한|문서화"],
            "화면보다 데이터 구조와 검증 근거를 먼저 완성한다",
        ),
    )

    changed += migrate_asset(
        ch15,
        "ch15_02_evaluation_modes",
        "ch15_02_scope_selection_guide",
        """flowchart TB
    A[프로젝트 범위 선택] --> B[기본 범위]
    A --> C[선택 확장]
    A --> D[이번 버전에서 제외]
    B --> B1[핵심 사용자·데이터·CRUD]
    C --> C1[웹 API·NoSQL·Vector DB·RAG]
    D --> D1[외부 결제·대규모 운영·고급 자동화]
""",
        grid_svg(
            "데이터베이스 프로젝트 범위 선택 가이드",
            ["기본 사용자|누가 사용하는가", "핵심 데이터|반드시 저장할 정보", "기본 기능|등록·조회·상태 변경", "검증 SQL|JOIN·집계·오류 확인", "선택 확장|웹 CRUD·API", "선택 확장|NoSQL·Vector DB·RAG", "이번 버전 제외|외부 결제·고급 운영", "후속 계획|다음 버전에서 검토"],
            "핵심 데이터 흐름을 먼저 완성한 뒤 필요한 기술만 확장한다",
        ),
    )

    changed += migrate_asset(
        ch15,
        "ch15_03_submission_structure",
        "ch15_03_project_structure",
        """flowchart TB
    A[project 폴더] --> B[README.md]
    A --> C[requirements.md]
    A --> D[erd.md 또는 erd.png]
    A --> E[schema.sql]
    A --> F[seed.sql]
    A --> G[queries.sql]
    A --> H[ai_review.md]
    A --> I[project_notes.md]
    A --> J[screenshots]
""",
        grid_svg(
            "재현 가능한 데이터베이스 프로젝트 구조",
            ["README.md|목적·환경·실행 순서", "requirements.md|사용자·기능·규칙", "erd.md / erd.png|테이블과 관계", "schema.sql|반복 실행 가능한 DDL", "seed.sql|검증 시나리오 데이터", "queries.sql|조회·JOIN·검증", "ai_review.md|AI 제안과 수정 근거", "project_notes.md|한계와 다음 계획"],
            "다른 사람이 파일 순서와 설계 이유를 이해하고 다시 실행할 수 있어야 한다",
        ),
    )

    changed += migrate_asset(
        ch15,
        "ch15_06_rubric_breakdown",
        "ch15_06_completion_dimensions",
        """flowchart TB
    A[프로젝트 완성도]
    A --> B[문제와 요구사항]
    A --> C[ERD와 제약조건]
    A --> D[샘플 데이터와 SQL]
    A --> E[트랜잭션과 성능]
    A --> F[보안과 복구]
    A --> G[AI 검토]
    A --> H[재현성]
""",
        grid_svg(
            "데이터베이스 서비스 프로젝트 완성도 구성",
            ["문제·사용자|해결 대상이 분명한가", "범위·요구사항|규칙과 제외 항목", "ERD·관계|PK·FK·N:M", "DDL·제약조건|잘못된 값 차단", "데이터·SQL|시나리오와 검증", "트랜잭션·성능|업무 단위와 조회 패턴", "보안·복구|권한·비밀정보·백업", "AI·재현성|수정 근거와 실행 방법"],
            "각 영역을 점수화하지 않고 빠진 설계와 검증 근거를 찾는다",
        ),
    )

    changed += migrate_asset(
        ch15,
        "ch15_07_presentation_flow",
        "ch15_07_project_story_flow",
        """flowchart LR
    A[문제] --> B[중요한 설계 결정]
    B --> C[구현]
    C --> D[샘플 데이터와 SQL 검증]
    D --> E[AI 제안과 수정]
    E --> F[발견한 한계]
    F --> G[다음 버전]
""",
        flow_svg(
            "프로젝트를 설명하는 이야기 흐름",
            ["문제", "설계 결정", "구현", "데이터·SQL 검증", "AI 제안·수정", "발견한 한계", "다음 버전"],
            "기능 목록보다 왜 그렇게 설계했고 어떻게 검증했는지를 설명한다",
        ),
    )

    changed += migrate_asset(
        ch15,
        "ch15_08_final_checklist",
        "ch15_08_completion_checklist",
        """flowchart TB
    A[프로젝트 완성도 점검]
    A --> B[문제와 범위]
    A --> C[요구사항과 ERD]
    A --> D[schema.sql]
    A --> E[seed.sql]
    A --> F[queries.sql]
    A --> G[AI 검토 기록]
    A --> H[보안과 복구]
    A --> I[README와 재현성]
""",
        grid_svg(
            "AI 기반 데이터베이스 서비스 완성도 점검",
            ["문제·범위|사용자와 제외 기능", "요구사항·ERD|데이터와 관계", "schema.sql|타입·PK·FK·제약", "seed.sql|정상·경계·오류 상황", "queries.sql|JOIN·집계·검증", "AI 검토 기록|제안과 수정 이유", "보안·복구|권한·비밀정보·백업", "README·재현성|다른 사람이 실행 가능"],
            "제출 여부가 아니라 서비스 구조와 검증 근거가 완성되었는지 확인한다",
        ),
    )

    text_replacements = {
        ROOT / "book/chapter07/chapter07.md": {
            "ch07_01_midterm_project_flow.svg": "ch07_01_project_flow.svg",
            "ch07_07_ai_review_report_flow.svg": "ch07_07_ai_review_flow.svg",
        },
        ROOT / "book/chapter15/chapter15.md": {
            "![최종 프로젝트 진행 흐름](../../images/chapter15/ch15_01_final_project_flow.svg)": "![데이터베이스 서비스 프로젝트 진행 흐름](../../images/chapter15/ch15_01_service_project_flow.svg)",
            "![최종 제출 체크리스트](../../images/chapter15/ch15_08_final_checklist.svg)": "![프로젝트 완성도 체크리스트](../../images/chapter15/ch15_08_completion_checklist.svg)",
        },
    }
    for path, replacements in text_replacements.items():
        if replace_in_file(path, replacements):
            changed.append(path)

    chapter07_readme = """# Chapter 07 이미지/도식 설계

## Chapter 07. 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계

이 문서는 Chapter 07 본문과 독자 프로젝트 워크북에 사용하는 도식 자산을 정리합니다. 도식은 요구사항을 데이터 구조로 바꾸고, PostgreSQL과 샘플 데이터로 설계를 검증하는 흐름을 보여 줍니다.

## 도식 설계 원칙

```text
- 프로젝트 수행 순서를 한눈에 보여 준다.
- 요구사항에서 엔터티, 속성, 관계와 업무 규칙을 도출하는 흐름을 시각화한다.
- students, instructors, courses, enrollments의 관계를 명확히 보여 준다.
- CREATE TABLE, 샘플 데이터, JOIN과 CRUD로 설계를 검증하는 흐름을 표현한다.
- 정규화와 AI 검토는 점수나 평가가 아니라 설계 품질을 확인하는 과정으로 설명한다.
- 파일명과 도식 내부 문구에 중간고사, 제출, 배점 표현을 사용하지 않는다.
```

## 도식 목록

| 번호 | 파일명 | 도식 제목 | 사용 위치 |
| --- | --- | --- | --- |
| 그림 7-1 | `ch07_01_project_flow.svg` | 온라인 강의 DB 프로젝트 진행 흐름 | 장 도입부 |
| 그림 7-2 | `ch07_02_requirement_to_entities.svg` | 요구사항에서 엔터티 도출 | 요구사항 분석 |
| 그림 7-3 | `ch07_04_many_to_many_enrollments.svg` | 학생-강의 N:M 관계 해소 | 관계 분석 |
| 그림 7-4 | `ch07_03_online_course_erd.svg` | 온라인 강의 수강신청 ERD | ERD 확인 |
| 그림 7-5 | `ch07_05_sql_validation_flow.svg` | SQL 기반 설계 검증 흐름 | JOIN 검증 |
| 그림 7-6 | `ch07_06_normalization_review_flow.svg` | 프로젝트 정규화 검토 | 정규화 점검 |
| 그림 7-7 | `ch07_07_ai_review_flow.svg` | AI 제안 검토 흐름 | AI 활용 |
| 보조 도식 | `ch07_08_project_completion_checklist.svg` | 프로젝트 완성도 점검 | 워크북·추가 점검 |

각 SVG에는 동일한 이름의 Mermaid 원본 `.mmd` 파일이 함께 있습니다.
"""
    if write_if_changed(ch07 / "README.md", chapter07_readme):
        changed.append(ch07 / "README.md")

    chapter15_readme = """# Chapter 15 이미지/도식 설계

## Chapter 15. 실전 프로젝트 2: AI 기반 데이터베이스 서비스 완성하기

이 문서는 Chapter 15 본문과 독자 프로젝트 워크북에 사용하는 도식 자산을 정리합니다. 도식은 프로젝트 범위를 작게 정하고, 데이터 구조를 구현·검증하며, 다른 사람이 다시 실행할 수 있도록 문서화하는 흐름을 보여 줍니다.

## 도식 설계 원칙

```text
- 화면 구현보다 데이터베이스 설계와 검증을 우선한다.
- 문제 정의, 범위, 요구사항, ERD, DDL, 샘플 데이터와 핵심 SQL을 연결한다.
- 웹 CRUD, NoSQL, Vector DB와 RAG는 목적에 따른 선택 확장으로 구분한다.
- AI 결과는 초안이며 사람이 실행하고 수정하는 흐름을 드러낸다.
- 프로젝트 구조와 완성도 점검은 제출 형식이나 배점이 아니라 재현성을 기준으로 설명한다.
- 파일명과 도식 내부 문구에 최종고사, 평가, 제출, 배점 표현을 사용하지 않는다.
```

## 도식 목록

| 번호 | 파일명 | 도식 제목 | 사용 위치 |
| --- | --- | --- | --- |
| 그림 15-1 | `ch15_01_service_project_flow.svg` | AI 기반 DB 서비스 완성 흐름 | 장 도입부 |
| 보조 도식 | `ch15_02_scope_selection_guide.svg` | 프로젝트 범위 선택 가이드 | 범위 설정 |
| 보조 도식 | `ch15_03_project_structure.svg` | 재현 가능한 프로젝트 구조 | 프로젝트 문서화 |
| 그림 15-2 | `ch15_04_db_design_validation.svg` | DB 설계 검증 흐름 | 샘플 데이터와 SQL |
| 그림 15-3 | `ch15_05_ai_review_loop.svg` | AI 활용 및 검토 루프 | AI 활용 |
| 보조 도식 | `ch15_06_completion_dimensions.svg` | 프로젝트 완성도 구성 | 완성도 점검 |
| 보조 도식 | `ch15_07_project_story_flow.svg` | 프로젝트 설명과 회고 흐름 | 문서화·회고 |
| 그림 15-4 | `ch15_08_completion_checklist.svg` | 프로젝트 완성도 체크리스트 | 최종 점검 |

각 SVG에는 동일한 이름의 Mermaid 원본 `.mmd` 파일이 함께 있습니다.
"""
    if write_if_changed(ch15 / "README.md", chapter15_readme):
        changed.append(ch15 / "README.md")

    code_readme = """# Chapter 07 프로젝트 코드

## 실전 프로젝트 1: 온라인 강의 수강신청 데이터베이스 설계

이 폴더는 Chapter 07에서 사용하는 실행 가능한 PostgreSQL 프로젝트 SQL을 관리합니다.

## 파일 목록

| 파일 | 설명 |
| --- | --- |
| `online_course_project.sql` | 테이블 생성, 샘플 데이터, CRUD, JOIN과 정규화 검토를 포함한 온라인 강의 데이터베이스 프로젝트 |

## 실행 순서

1. DBeaver에서 작업용 PostgreSQL 데이터베이스에 연결합니다.
2. SQL Editor에서 `online_course_project.sql`을 엽니다.
3. 파일을 위에서 아래 순서대로 실행합니다.
4. `students`, `instructors`, `courses`, `enrollments` 테이블을 확인합니다.
5. 샘플 데이터와 JOIN 결과가 요구사항을 표현하는지 확인합니다.
6. UPDATE와 DELETE 예제는 대상 행을 SELECT로 먼저 확인한 뒤 실행합니다.
7. 정규화, 제약조건과 재실행 가능성을 검토합니다.

## 주의 사항

```text
- 테스트용 데이터베이스에서 실행합니다.
- DROP TABLE IF EXISTS가 포함되어 있으므로 운영 데이터베이스에서 실행하지 않습니다.
- 실제 개인정보나 접속 비밀번호를 예제에 사용하지 않습니다.
- AI가 생성한 SQL은 PostgreSQL에서 직접 실행하고 결과를 검증합니다.
```
"""
    code_readme_path = ROOT / "code/chapter07/README.md"
    if write_if_changed(code_readme_path, code_readme):
        changed.append(code_readme_path)

    if changed:
        print("Migrated project image assets and references:")
        for path in changed:
            print(f"- {path.relative_to(ROOT)}")
    else:
        print("Project image assets are already migrated.")


if __name__ == "__main__":
    main()
