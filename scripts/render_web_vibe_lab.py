from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math

OUT = Path("images/web-vibe-lab")
OUT.mkdir(parents=True, exist_ok=True)
W, H = 1600, 900
BG = "#F7F9FC"
TEXT = "#1F2937"
MUTED = "#6B7280"
BLUE, BLUEB = "#DCEEFF", "#3B82F6"
GREEN, GREENB = "#DDF6E8", "#22A06B"
ORANGE, ORANGEB = "#FFE9CC", "#F59E0B"
PURPLE, PURPLEB = "#EEE5FF", "#8B5CF6"
GRAY, GRAYB = "#EEF2F7", "#94A3B8"
RED, REDB = "#FEE2E2", "#EF4444"
FONT = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"
BOLD = "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
F = {}
for name, size in [("title", 44), ("h", 30), ("body", 24), ("small", 20), ("tiny", 17), ("big", 36)]:
    F[name] = ImageFont.truetype(BOLD if name in ("title", "h", "big") else FONT, size)


def center_text(d, rect, text, font, fill=TEXT, spacing=6):
    x1, y1, x2, y2 = rect
    b = d.multiline_textbbox((0, 0), text, font=font, spacing=spacing, align="center")
    tw, th = b[2] - b[0], b[3] - b[1]
    d.multiline_text(((x1 + x2 - tw) / 2, (y1 + y2 - th) / 2), text, font=font, fill=fill, spacing=spacing, align="center")


def box(d, rect, label, fill, outline, font="h", radius=26):
    d.rounded_rectangle(rect, radius=radius, fill=fill, outline=outline, width=4)
    center_text(d, rect, label, F[font])


def arrow(d, p1, p2, color=GRAYB, width=8, label=None, label_yoff=-34):
    d.line([p1, p2], fill=color, width=width)
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    length = 20
    pts = [p2, (p2[0] - length * math.cos(ang - 0.55), p2[1] - length * math.sin(ang - 0.55)), (p2[0] - length * math.cos(ang + 0.55), p2[1] - length * math.sin(ang + 0.55))]
    d.polygon(pts, fill=color)
    if label:
        mx = (p1[0] + p2[0]) / 2
        my = (p1[1] + p2[1]) / 2 + label_yoff
        b = d.textbbox((0, 0), label, font=F["small"])
        tw = b[2] - b[0]
        d.rounded_rectangle((mx - tw / 2 - 10, my - 4, mx + tw / 2 + 10, my + 30), 8, fill=BG)
        d.text((mx - tw / 2, my), label, font=F["small"], fill=TEXT)


def title(d, text, subtitle=None):
    d.text((70, 45), text, font=F["title"], fill=TEXT)
    if subtitle:
        d.text((72, 105), subtitle, font=F["small"], fill=MUTED)


def save(name, drawfn):
    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)
    drawfn(d)
    d.text((70, 850), "2026-2 데이터베이스 · 바이브코딩 웹 개발 실습", font=F["tiny"], fill=MUTED)
    im = im.convert("P", palette=Image.Palette.ADAPTIVE, colors=128)
    im.save(OUT / name, optimize=True, compress_level=9)


save("01_client_server_database.png", lambda d: (
    title(d, "웹 기본 구조", "브라우저의 요청이 DB까지 갔다가 다시 화면으로 돌아옵니다."),
    box(d, (70, 300, 310, 470), "Browser", BLUE, BLUEB),
    box(d, (430, 300, 760, 470), "Apache / PHP", GREEN, GREENB),
    box(d, (950, 300, 1210, 470), "MySQL", ORANGE, ORANGEB),
    arrow(d, (310, 350), (430, 350), BLUEB, label="HTTP Request"),
    arrow(d, (760, 350), (950, 350), GREENB, label="SQL"),
    arrow(d, (950, 425), (760, 425), ORANGEB, label="Result"),
    arrow(d, (430, 425), (310, 425), GREENB, label="HTML Response")
))


def fig2(d):
    title(d, "정적 웹 vs 동적 웹", "파일을 그대로 보내는가, 데이터에 따라 HTML을 만들어 보내는가?")
    d.text((250, 190), "정적 웹", font=F["big"], fill=TEXT)
    d.text((1020, 190), "동적 웹", font=F["big"], fill=TEXT)
    box(d, (100, 310, 380, 470), "HTML File", GRAY, GRAYB)
    box(d, (500, 310, 780, 470), "Browser", BLUE, BLUEB)
    arrow(d, (380, 390), (500, 390), GRAYB)
    box(d, (850, 290, 1080, 450), "Browser", BLUE, BLUEB)
    box(d, (1170, 290, 1400, 450), "PHP", GREEN, GREENB)
    box(d, (1170, 560, 1400, 720), "DB", ORANGE, ORANGEB)
    arrow(d, (1080, 370), (1170, 370), BLUEB)
    arrow(d, (1285, 450), (1285, 560), GREENB)
    arrow(d, (1170, 640), (1080, 440), ORANGEB, label="HTML 생성")
    d.line([(800, 220), (800, 760)], fill="#D1D5DB", width=3)


save("02_static_vs_dynamic_web.png", fig2)


def fig3(d):
    title(d, "Modern Full Stack vs LAMP", "두 구조 모두 ‘화면 ↔ 애플리케이션 ↔ 데이터베이스’의 원리는 같습니다.")
    d.text((250, 190), "Modern Full Stack", font=F["big"], fill=TEXT)
    d.text((1080, 190), "이번 실습: LAMP 방식", font=F["big"], fill=TEXT)
    box(d, (80, 330, 360, 500), "React +\nTypeScript", BLUE, BLUEB)
    box(d, (470, 330, 750, 500), "FastAPI", GREEN, GREENB)
    box(d, (470, 590, 750, 740), "DB", ORANGE, ORANGEB)
    arrow(d, (360, 415), (470, 415), BLUEB)
    arrow(d, (610, 500), (610, 590), GREENB)
    box(d, (870, 330, 1110, 500), "Browser", BLUE, BLUEB)
    box(d, (1210, 330, 1500, 500), "Apache / PHP", GREEN, GREENB)
    box(d, (1210, 590, 1500, 740), "MySQL", ORANGE, ORANGEB)
    arrow(d, (1110, 415), (1210, 415), BLUEB)
    arrow(d, (1355, 500), (1355, 590), GREENB)
    d.text((925, 770), "복잡한 프레임워크보다 흐름을 먼저 이해합니다.", font=F["small"], fill=PURPLEB)


save("03_modern_fullstack_vs_lamp.png", fig3)


def fig4(d):
    title(d, "Windows 로컬 개발 환경", "한 대의 PC 안에서 개발 도구·웹 서버·DB 도구가 함께 동작합니다.")
    d.rounded_rectangle((160, 190, 1440, 790), 36, fill="white", outline="#CBD5E1", width=4)
    d.text((210, 225), "내 Windows PC", font=F["big"], fill=TEXT)
    box(d, (240, 340, 500, 500), "VS Code", PURPLE, PURPLEB)
    box(d, (650, 300, 950, 470), "Apache / PHP", GREEN, GREENB)
    box(d, (1100, 300, 1350, 470), "MySQL", ORANGE, ORANGEB)
    box(d, (650, 570, 950, 710), "Browser", BLUE, BLUEB)
    box(d, (1100, 570, 1350, 710), "DBeaver", GRAY, GRAYB)
    arrow(d, (500, 420), (650, 385), PURPLEB)
    arrow(d, (950, 385), (1100, 385), GREENB)
    arrow(d, (800, 570), (800, 470), BLUEB)
    arrow(d, (1225, 570), (1225, 470), GRAYB)


save("04_local_development_environment.png", fig4)


def fig5(d):
    title(d, "DBeaver에서 MySQL 연결", "교육용 로컬 환경: localhost:3306 · root / 1234")
    box(d, (120, 300, 430, 500), "DBeaver", GRAY, GRAYB)
    box(d, (650, 260, 1000, 540), "MySQL\nlocalhost:3306\nroot / 1234", ORANGE, ORANGEB)
    box(d, (1180, 260, 1470, 430), "Schema", GREEN, GREENB)
    box(d, (1180, 550, 1470, 720), "Tables", BLUE, BLUEB)
    arrow(d, (430, 400), (650, 400), GRAYB, label="DB 연결")
    arrow(d, (1000, 340), (1180, 340), ORANGEB)
    arrow(d, (1325, 430), (1325, 550), GREENB)
    d.rounded_rectangle((300, 660, 1040, 760), 18, fill=RED, outline=REDB, width=2)
    center_text(d, (300, 660, 1040, 760), "1234는 수업용 로컬 실습에서만 사용하는 임시 비밀번호", F["body"], fill="#991B1B")


save("05_dbeaver_mysql_connection.png", fig5)


def fig6(d):
    title(d, "온라인 강좌 시스템 ERD", "학생·강사·강좌·수강신청 4개 테이블의 관계")
    box(d, (90, 290, 410, 530), "students\nPK student_id", BLUE, BLUEB)
    box(d, (620, 210, 980, 450), "enrollments\nPK enrollment_id\nFK student_id\nFK course_id", GREEN, GREENB, font="body")
    box(d, (1190, 290, 1510, 530), "courses\nPK course_id\nFK instructor_id", ORANGE, ORANGEB, font="body")
    box(d, (1190, 620, 1510, 770), "instructors\nPK instructor_id", PURPLE, PURPLEB, font="body")
    arrow(d, (410, 410), (620, 330), BLUEB, label="1 : N")
    arrow(d, (980, 330), (1190, 410), ORANGEB, label="N : 1")
    arrow(d, (1350, 620), (1350, 530), PURPLEB, label="1 : N")


save("06_course_system_erd.png", fig6)


def fig7(d):
    title(d, "students.php의 요청 처리 흐름", "한 페이지가 DB를 조회하고 HTML을 만들어 브라우저에 보여주는 과정")
    xs = [70, 260, 450, 650, 850, 1040, 1230, 1420]
    labels = [("Browser", BLUE, BLUEB), ("PHP", GREEN, GREENB), ("SQL", GREEN, GREENB), ("MySQL", ORANGE, ORANGEB), ("Result", ORANGE, ORANGEB), ("PHP", GREEN, GREENB), ("HTML", BLUE, BLUEB), ("Browser", BLUE, BLUEB)]
    for i, (label, fill, outline) in enumerate(labels):
        x = xs[i]
        box(d, (x, 340, x + 150, 480), label, fill, outline, font="body", radius=20)
        if i < len(labels) - 1:
            arrow(d, (x + 150, 410), (xs[i + 1], 410), outline, width=6)
    d.text((560, 580), "핵심: PHP 문법보다 ‘요청 → SQL → 결과 → HTML’ 흐름을 이해합니다.", font=F["body"], fill=TEXT)


save("07_php_sql_html_flow.png", fig7)


def fig8(d):
    title(d, "웹 페이지를 구성하는 4개 층", "학생이 직접 수정하고 브라우저에서 변화를 확인할 영역")
    items = [("HTML", "구조·텍스트·버튼", BLUE, BLUEB), ("CSS", "색상·간격·스타일", PURPLE, PURPLEB), ("JavaScript", "이벤트·알림·동작", GREEN, GREENB), ("SQL", "조회·정렬·조건", ORANGE, ORANGEB)]
    y = 220
    for i, (left, right, fill, outline) in enumerate(items):
        yy = y + i * 145
        box(d, (250, yy, 560, yy + 105), left, fill, outline)
        box(d, (680, yy, 1320, yy + 105), right, "white", outline, font="body")
        arrow(d, (560, yy + 52), (680, yy + 52), outline, width=6)


save("08_html_css_js_sql_layers.png", fig8)


def fig9(d):
    title(d, "JOIN으로 ID를 사람이 읽는 정보로 바꾸기", "enrollments 화면은 숫자 ID 대신 이름과 강좌 정보를 보여줍니다.")
    box(d, (90, 300, 390, 560), "enrollments\nstudent_id = 101\ncourse_id = 12", GRAY, GRAYB, font="body")
    box(d, (550, 240, 860, 410), "students\n101 → 김민수", BLUE, BLUEB, font="body")
    box(d, (550, 470, 860, 640), "courses\n12 → 데이터베이스", ORANGE, ORANGEB, font="body")
    box(d, (550, 690, 860, 820), "instructors\n→ 이서연", PURPLE, PURPLEB, font="body")
    arrow(d, (390, 390), (550, 325), BLUEB, label="JOIN")
    arrow(d, (390, 470), (550, 555), ORANGEB, label="JOIN")
    arrow(d, (705, 640), (705, 690), PURPLEB)
    box(d, (1050, 300, 1490, 610), "웹 화면\n김민수\n데이터베이스\n이서연 강사\n수강중 · 2026-09-30", GREEN, GREENB, font="body")
    arrow(d, (860, 500), (1050, 455), GREENB, label="표시")


save("09_join_to_web_page.png", fig9)


def fig10(d):
    title(d, "Local에서 Public Web Service까지", "이번 실습은 첫 단계. 이후 자동 배포와 클라우드까지 확장합니다.")
    items = [("Local\nDevelopment", BLUE, BLUEB), ("GitHub", PURPLE, PURPLEB), ("CI/CD", PURPLE, PURPLEB), ("Cloud", GREEN, GREENB), ("Public\nWeb Service", ORANGE, ORANGEB)]
    xs = [70, 370, 670, 970, 1270]
    for i, (label, fill, outline) in enumerate(items):
        box(d, (xs[i], 330, xs[i] + 230, 520), label, fill, outline, font="body")
        if i < 4:
            arrow(d, (xs[i] + 230, 425), (xs[i + 1], 425), outline, width=7)
    d.text((430, 620), "Local → GitHub → 자동화 → 서버 배포 → 누구나 접속", font=F["big"], fill=TEXT)


save("10_local_to_cloud_cicd.png", fig10)
print(f"created {len(list(OUT.glob('*.png')))} files in {OUT}")
