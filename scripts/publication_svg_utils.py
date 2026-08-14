from __future__ import annotations

from pathlib import Path
import re

import cairosvg

KOREAN_FONT_STACK = (
    '"Noto Sans CJK KR", "Noto Sans KR", "NanumGothic", '
    '"Malgun Gothic", sans-serif'
)

_FONT_STYLE_MARKER = "publication-korean-font-fix"


def inject_korean_font_style(svg_text: str) -> str:
    """Force a Korean-capable font stack for publication SVG text.

    The generated SVG assets may contain Arial/system-ui style declarations that
    work in a browser but resolve to fonts without Hangul glyphs in CairoSVG.
    Injecting this rule at the end of the SVG gives it precedence while leaving
    path-based icons and other vector shapes unchanged.
    """
    if _FONT_STYLE_MARKER in svg_text:
        return svg_text

    style = f'''\n<style id="{_FONT_STYLE_MARKER}">
svg text,
svg tspan,
svg foreignObject,
svg foreignObject * {{
  font-family: {KOREAN_FONT_STACK} !important;
}}
</style>\n'''

    if re.search(r"</svg\s*>", svg_text, flags=re.IGNORECASE):
        return re.sub(
            r"</svg\s*>",
            style + "</svg>",
            svg_text,
            count=1,
            flags=re.IGNORECASE,
        )

    raise ValueError("Invalid SVG: closing </svg> tag not found")


def svg2png(*, url: str, output_width: int | None = None, **kwargs) -> bytes:
    """CairoSVG-compatible wrapper with Korean font injection.

    Existing chapter publication generators can call this function with the
    same arguments they previously passed to cairosvg.svg2png().
    """
    svg_path = Path(url)
    if not svg_path.exists():
        raise FileNotFoundError(svg_path)

    svg_text = svg_path.read_text(encoding="utf-8")
    patched = inject_korean_font_style(svg_text)

    return cairosvg.svg2png(
        bytestring=patched.encode("utf-8"),
        output_width=output_width,
        **kwargs,
    )
