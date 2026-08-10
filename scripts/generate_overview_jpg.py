from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import textwrap

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "images" / "overview"
OUT.mkdir(parents=True, exist_ok=True)

BG = "#F7F9FC"
PAPER = "#FFFFFF"
NAVY = "#15304A"
BLUE = "#2F6FED"
BLUE_SOFT = "#EAF1FF"
TEAL = "#168C8C"
TEAL_SOFT = "#E9F7F6"
GREEN = "#2F855A"
GREEN_SOFT = "#EAF7EF"
ORANGE = "#B56A14"
ORANGE_SOFT = "#FFF4E6"
GRAY = "#5E6B78"
LINE = "#D8E0E8"
DARK = "#17212B"

FONT_REGULAR_CANDIDATES = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJKkr-Regular.otf",
    "/usr/share/fonts/truetype/noto/NotoSansKR-Regular.ttf",
]
FONT_BOLD_CANDIDATES = [
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJKkr-Bold.otf",
    "/usr/share/fonts/truetype/noto/NotoSansKR-Bold.ttf",
]


def find_font(candidates):
    for path in candidates:
        if Path(path).exists():
            return path
    raise FileNotFoundError("Noto Sans CJK/KR font not found")


REGULAR = find_font(FONT_REGULAR_CANDIDATES)
BOLD = find_font(FONT_BOLD_CANDIDATES)


def font(size, bold=False):
    return ImageFont.truetype(BOLD if bold else REGULAR, size=size)


def rounded(draw, box, radius=26, fill=PAPER, outline=None, width=2):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def text(draw, xy, value, size, fill=DARK, bold=False, anchor=None):
    draw.text(xy, value, font=font(size, bold), fill=fill, anchor=anchor)


def multiline(draw, box, value, size, fill=DARK, bold=False, spacing=8, align="left"):
    x1, y1, x2, y2 = box
    f = font(size, bold)
    # Pixel-aware wrapping with Korean-friendly character fallback.
    lines = []
    for paragraph in value.split("\n"):
        if not paragraph:
            lines.append("")
            continue
        current = ""
        for ch in paragraph:
            trial = current + ch
            if draw.textbbox((0, 0), trial, font=f)[2] <= (x2 - x1):
                current = trial
            else:
                if current:
                    lines.append(current)
                current = ch
        if current:
            lines.append(current)
    draw.multiline_text((x1, y1), "\n".join(lines), font=f, fill=fill, spacing=spacing, align=align)
    return lines


def arrow(draw, start, end, fill=BLUE, width=6):
    draw.line([start, end], fill=fill, width=width)
    ex, ey = end
    sx, sy = start
    import math
    angle = math.atan2(ey - sy, ex - sx)
    length = 18
    spread = 0.55
    p1 = (ex - length * math.cos(angle - spread), ey - length * math.sin(angle - spread))
    p2 = (ex - length * math.cos(angle + spread), ey - length * math.sin(angle + spread))
    draw.polygon([end, p1, p2], fill=fill)


def save(img, name):
    path = OUT / name
    img.convert("RGB").save(path, "JPEG", quality=92, optimize=True, progressive=True)
    print(f"Generated {path}")


def header(draw, title_value, subtitle):
    text(draw, (90, 72), title_value, 48, NAVY, True)
    text(draw, (92, 138), subtitle, 24, GRAY, False)
    draw.line((90, 188, 1510, 188), fill=LINE, width=2)


def roadmap():
    img = Image.new("RGB", (1600, 920), BG)
    d = ImageDraw.Draw(img)
    header(d, "AI 시대의 데이터베이스 입문 · 전체 학습 로드맵", "기초 → 설계 → 운영 → AI·분석·종합 프로젝트")

    stages = [
        ("STAGE 1", "Chapter 01–04", "데이터베이스 기초", "필요성·DBMS·PostgreSQL·SQL 시작", BLUE, BLUE_SOFT),
        ("STAGE 2", "Chapter 05–07", "좋은 데이터 구조", "요구사항·ERD·정규화·첫 프로젝트", TEAL, TEAL_SOFT),
        ("STAGE 3", "Chapter 08–12", "조회와 안정적 운영", "JOIN·트랜잭션·인덱스·보안·저장소 선택", GREEN, GREEN_SOFT),
        ("STAGE 4", "Chapter 13–15", "AI와 분석으로 확장", "AI 검증·SQL/Python 분석·종합 프로젝트", ORANGE, ORANGE_SOFT),
    ]
    x_positions = [90, 465, 840, 1215]
    y1, y2 = 270, 700
    card_w = 295
    for i, (stage, chapters, title_v, desc, accent, soft) in enumerate(stages):
        x = x_positions[i]
        rounded(d, (x, y1, x + card_w, y2), 30, PAPER, LINE, 2)
        rounded(d, (x + 24, y1 + 28, x + 150, y1 + 70), 18, soft, None, 0)
        text(d, (x + 42, y1 + 38), stage, 18, accent, True)
        text(d, (x + 25, y1 + 100), chapters, 23, GRAY, True)
        multiline(d, (x + 25, y1 + 155, x + card_w - 25, y1 + 245), title_v, 30, NAVY, True, 6)
        multiline(d, (x + 25, y1 + 270, x + card_w - 25, y2 - 32), desc, 22, DARK, False, 10)
        if i < len(stages) - 1:
            arrow(d, (x + card_w + 16, (y1 + y2)//2), (x_positions[i+1] - 18, (y1 + y2)//2), LINE, 5)

    rounded(d, (90, 755, 1510, 850), 22, NAVY, None, 0)
    text(d, (120, 785), "핵심 흐름", 22, "#B9D4F5", True)
    text(d, (286, 785), "업무 질문 → 요구사항 → 데이터 모델·ERD → 테이블·SQL → 검증·운영 → 분석·AI 활용", 25, "#FFFFFF", True)
    save(img, "overview_learning_roadmap.jpg")


def structure():
    img = Image.new("RGB", (1600, 1220), BG)
    d = ImageDraw.Draw(img)
    header(d, "15개 Chapter 구조", "각 단계는 다음 단계의 실습 근거로 이어집니다")

    groups = [
        ("STAGE 1 · 기초", BLUE, BLUE_SOFT, [
            ("01", "AI 시대의 DB"), ("02", "데이터·DBMS"), ("03", "PostgreSQL 환경"), ("04", "관계형 DB·SQL")]),
        ("STAGE 2 · 설계", TEAL, TEAL_SOFT, [
            ("05", "데이터 모델·ERD"), ("06", "정규화·무결성"), ("07", "수강신청 프로젝트")]),
        ("STAGE 3 · 운영", GREEN, GREEN_SOFT, [
            ("08", "JOIN·집계"), ("09", "트랜잭션"), ("10", "인덱스·실행 계획"), ("11", "보안·백업·복구"), ("12", "RDBMS·NoSQL 선택")]),
        ("STAGE 4 · 확장", ORANGE, ORANGE_SOFT, [
            ("13", "AI 설계 검증"), ("14", "SQL·Python 분석"), ("15", "종합 프로젝트")]),
    ]

    y = 235
    for gi, (label, accent, soft, chapters) in enumerate(groups):
        group_h = 205 if len(chapters) <= 4 else 250
        rounded(d, (90, y, 1510, y + group_h), 28, PAPER, LINE, 2)
        rounded(d, (115, y + 25, 360, y + 70), 18, soft, None, 0)
        text(d, (140, y + 35), label, 20, accent, True)
        cols = 5 if len(chapters) == 5 else len(chapters)
        gap = 18
        inner_x = 115
        inner_w = 1370
        card_w = (inner_w - gap * (cols - 1)) // cols
        cy = y + 95
        for idx, (num, title_v) in enumerate(chapters):
            cx = inner_x + idx * (card_w + gap)
            rounded(d, (cx, cy, cx + card_w, cy + 85), 18, soft, None, 0)
            text(d, (cx + 18, cy + 18), num, 22, accent, True)
            multiline(d, (cx + 60, cy + 17, cx + card_w - 14, cy + 72), title_v, 18, DARK, True, 4)
        y += group_h + 26

    rounded(d, (90, 1110, 1510, 1170), 18, NAVY, None, 0)
    text(d, (800, 1140), "Chapter 07 → Chapter 13 → Chapter 15 : 프로젝트를 만들고, 검증하고, 통합한다", 23, "#FFFFFF", True, anchor="mm")
    save(img, "overview_book_structure.jpg")


def study_flow():
    img = Image.new("RGB", (1600, 930), BG)
    d = ImageDraw.Draw(img)
    header(d, "이 책의 학습·실습 검증 흐름", "AI가 초안을 만들고, 사람은 실행 위치와 결과를 확인합니다")

    steps = [
        ("1", "읽기", "개념과 업무 질문을 이해합니다", BLUE, BLUE_SOFT),
        ("2", "예상", "SQL 실행 전 결과를 먼저 생각합니다", TEAL, TEAL_SOFT),
        ("3", "실행", "PostgreSQL·DBeaver에서 직접 실행합니다", GREEN, GREEN_SOFT),
        ("4", "검증", "행 수·값·메타데이터를 근거로 확인합니다", ORANGE, ORANGE_SOFT),
        ("5", "AI 활용", "설계·SQL 초안을 받고 diff와 테스트로 검토합니다", BLUE, BLUE_SOFT),
        ("6", "기록", "재현 가능한 결과와 다음 질문을 남깁니다", TEAL, TEAL_SOFT),
    ]

    coords = [(120, 270), (550, 270), (980, 270), (980, 570), (550, 570), (120, 570)]
    w, h = 330, 190
    for idx, ((n, title_v, desc, accent, soft), (x, y)) in enumerate(zip(steps, coords)):
        rounded(d, (x, y, x+w, y+h), 28, PAPER, LINE, 2)
        d.ellipse((x+24, y+24, x+76, y+76), fill=soft)
        text(d, (x+50, y+50), n, 22, accent, True, anchor="mm")
        text(d, (x+94, y+28), title_v, 27, NAVY, True)
        multiline(d, (x+28, y+98, x+w-28, y+h-20), desc, 20, DARK, False, 7)

    # arrows across top, down, then back across bottom
    arrow(d, (450, 365), (535, 365), BLUE, 5)
    arrow(d, (880, 365), (965, 365), BLUE, 5)
    arrow(d, (1145, 470), (1145, 555), BLUE, 5)
    arrow(d, (980, 665), (895, 665), BLUE, 5)
    arrow(d, (550, 665), (465, 665), BLUE, 5)
    arrow(d, (285, 570), (285, 485), BLUE, 5)

    rounded(d, (120, 800, 1310, 870), 18, NAVY, None, 0)
    text(d, (715, 835), "실행 성공 ≠ 올바른 결과 · AI 결과 = 검토하고 테스트할 변경 후보", 23, "#FFFFFF", True, anchor="mm")
    save(img, "overview_study_flow.jpg")


if __name__ == "__main__":
    roadmap()
    structure()
    study_flow()
