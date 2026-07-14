"""Validate Chapter 15 pandas results against the SQL baseline."""

from __future__ import annotations

from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

BASE_DIR = Path(__file__).parent


def _load_module(name: str, path: Path):
    spec = spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"모듈을 읽을 수 없습니다: {path}")
    module = module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


loader = _load_module("chapter15_loader", BASE_DIR / "01_load_postgresql.py")
analysis = _load_module("chapter15_analysis", BASE_DIR / "02_pandas_analysis.py")

EXPECTED_STATUS_COUNTS = {"answered": 3, "closed": 1, "open": 1}
EXPECTED_DATASET_ROWS = 5
EXPECTED_ANSWER_SUM = 5
EXPECTED_MATERIAL_SUM = 7
EXPECTED_NO_ANSWER = 1


def validate() -> None:
    df = loader.load_dataset()
    summaries = analysis.build_summaries(df)

    actual_status_counts = {
        row.status: int(row.question_count)
        for row in summaries["status"].itertuples(index=False)
    }

    checks = {
        "dataset_rows": len(df) == EXPECTED_DATASET_ROWS,
        "unique_question_id": not df["question_id"].duplicated().any(),
        "answer_count_sum": int(df["answer_count"].sum()) == EXPECTED_ANSWER_SUM,
        "material_count_sum": int(df["material_count"].sum())
        == EXPECTED_MATERIAL_SUM,
        "no_answer_questions": int((~df["has_answer"].astype(bool)).sum())
        == EXPECTED_NO_ANSWER,
        "status_counts": actual_status_counts == EXPECTED_STATUS_COUNTS,
    }

    failed = [name for name, passed in checks.items() if not passed]
    for name, passed in checks.items():
        print(f"{name}: {'PASS' if passed else 'FAIL'}")

    if failed:
        raise AssertionError(f"검증 실패: {failed}")

    print("SQL 기준값과 pandas 결과가 일치합니다.")


if __name__ == "__main__":
    validate()
