"""Create reproducible pandas summaries for the Chapter 15 project."""

from __future__ import annotations

from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

import pandas as pd

LOADER_PATH = Path(__file__).with_name("01_load_postgresql.py")
_spec = spec_from_file_location("chapter15_loader", LOADER_PATH)
if _spec is None or _spec.loader is None:
    raise RuntimeError(f"로더 모듈을 읽을 수 없습니다: {LOADER_PATH}")
_loader = module_from_spec(_spec)
_spec.loader.exec_module(_loader)
load_dataset = _loader.load_dataset


def build_summaries(df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Build status, month, and student summaries from one-question rows."""
    working = df.copy()
    working["question_created_at"] = pd.to_datetime(
        working["question_created_at"], errors="raise"
    )
    working["question_month"] = pd.to_datetime(
        working["question_month"], errors="raise"
    )

    status_summary = (
        working.groupby("status", as_index=False, dropna=False)
        .agg(question_count=("question_id", "count"))
        .sort_values("status")
        .reset_index(drop=True)
    )

    monthly_summary = (
        working.groupby("question_month", as_index=False)
        .agg(
            question_count=("question_id", "count"),
            answer_count=("answer_count", "sum"),
            material_count=("material_count", "sum"),
        )
        .sort_values("question_month")
        .reset_index(drop=True)
    )

    student_summary = (
        working.groupby(["student_id", "student_name"], as_index=False)
        .agg(question_count=("question_id", "count"))
        .sort_values("student_id")
        .reset_index(drop=True)
    )

    return {
        "status": status_summary,
        "monthly": monthly_summary,
        "student": student_summary,
    }


if __name__ == "__main__":
    dataset = load_dataset()
    summaries = build_summaries(dataset)
    for name, summary in summaries.items():
        print(f"\n[{name}]")
        print(summary.to_string(index=False))
