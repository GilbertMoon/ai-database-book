"""Chapter 14: pandas 결과를 SQL 기준값과 자동 비교합니다."""

from __future__ import annotations

import argparse
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_CSV_PATH = SCRIPT_DIR.parent / "data" / "enrollment_analysis_dataset.csv"

EXPECTED_ROWS = 24
EXPECTED_PAID_AMOUNT_SUM = 2_770_000
EXPECTED_STATUS_COUNTS = {
    "완료": 12,
    "수강중": 5,
    "신청": 4,
    "취소": 3,
}
EXPECTED_MONTHLY_COUNTS = {
    "2026-01": 3,
    "2026-02": 4,
    "2026-03": 5,
    "2026-04": 4,
    "2026-05": 4,
    "2026-06": 4,
}
EXPECTED_MONTHLY_PAID_AMOUNTS = {
    "2026-01": 200_000,
    "2026-02": 520_000,
    "2026-03": 540_000,
    "2026-04": 550_000,
    "2026-05": 390_000,
    "2026-06": 570_000,
}
EXPECTED_COMPLETED_COUNT = 12
EXPECTED_AVG_COMPLETION_DAYS = 25.0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Chapter 14 SQL 기준값과 pandas 결과를 비교합니다."
    )
    parser.add_argument(
        "--source",
        choices=("csv", "postgresql"),
        default="csv",
        help="데이터 원본. 기본값: csv",
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV_PATH,
        help=f"CSV 경로. 기본값: {DEFAULT_CSV_PATH}",
    )
    return parser.parse_args()


def load_dataframe(source: str, csv_path: Path) -> pd.DataFrame:
    if source == "csv":
        if not csv_path.exists():
            raise FileNotFoundError(
                f"CSV 파일을 찾을 수 없습니다: {csv_path.resolve()}"
            )
        df = pd.read_csv(
            csv_path,
            parse_dates=["enrolled_at", "enrollment_month", "completed_at"],
        )
    else:
        load_dotenv(SCRIPT_DIR / ".env")
        database_url = os.getenv("DATABASE_URL")
        if not database_url:
            raise RuntimeError(
                "DATABASE_URL이 없습니다. python/.env를 설정하세요."
            )

        engine = create_engine(database_url, pool_pre_ping=True)
        query = text(
            """
            SELECT *
            FROM analysis_lab.enrollment_analysis_dataset
            ORDER BY enrollment_id
            """
        )
        try:
            with engine.connect() as connection:
                df = pd.read_sql_query(query, connection)
        finally:
            engine.dispose()

    df["enrollment_month"] = pd.to_datetime(df["enrollment_month"])
    df["paid_amount"] = pd.to_numeric(df["paid_amount"], errors="raise")
    df["completion_days"] = pd.to_numeric(
        df["completion_days"], errors="coerce"
    )
    return df


def assert_equal(label: str, actual: object, expected: object) -> None:
    if actual != expected:
        raise AssertionError(
            f"{label} 불일치: expected={expected!r}, actual={actual!r}"
        )
    print(f"[통과] {label}: {actual}")


def main() -> None:
    args = parse_args()
    df = load_dataframe(args.source, args.csv)

    assert_equal("전체 행 수", len(df), EXPECTED_ROWS)
    assert_equal(
        "고유 enrollment_id",
        int(df["enrollment_id"].nunique()),
        EXPECTED_ROWS,
    )
    assert_equal(
        "결제금액 합계",
        int(df["paid_amount"].sum()),
        EXPECTED_PAID_AMOUNT_SUM,
    )

    actual_status_counts = (
        df.groupby("status")["enrollment_id"]
        .count()
        .astype(int)
        .to_dict()
    )
    assert_equal(
        "상태별 신청 건수",
        actual_status_counts,
        EXPECTED_STATUS_COUNTS,
    )

    monthly = df.copy()
    monthly["month_label"] = monthly["enrollment_month"].dt.strftime(
        "%Y-%m"
    )

    actual_monthly_counts = (
        monthly.groupby("month_label")["enrollment_id"]
        .count()
        .astype(int)
        .to_dict()
    )
    assert_equal(
        "월별 신청 건수",
        actual_monthly_counts,
        EXPECTED_MONTHLY_COUNTS,
    )

    actual_monthly_paid_amounts = (
        monthly.groupby("month_label")["paid_amount"]
        .sum()
        .astype(int)
        .to_dict()
    )
    assert_equal(
        "월별 결제금액",
        actual_monthly_paid_amounts,
        EXPECTED_MONTHLY_PAID_AMOUNTS,
    )

    completed = df.loc[df["status"] == "완료", "completion_days"]
    assert_equal("완료 건수", int(completed.count()), EXPECTED_COMPLETED_COUNT)
    assert_equal(
        "평균 완료 기간",
        round(float(completed.mean()), 2),
        EXPECTED_AVG_COMPLETION_DAYS,
    )
    assert_equal("최소 완료 기간", int(completed.min()), 18)
    assert_equal("최대 완료 기간", int(completed.max()), 36)

    print("\nChapter 14 SQL·Python 분석 기준값 검증을 통과했습니다.")


if __name__ == "__main__":
    main()
